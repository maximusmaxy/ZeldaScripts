#===============================================================================
# ¦ PZE World Swap
#-------------------------------------------------------------------------------
# Swap between worlds like in LTTP and OoA
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.3: 16/3/12
#===============================================================================
#
# Introduction:
# This script allows you to do light world/dark world map swaps by simply 
# flagging map names with text tags, and using the call script.
#
# Instructions:
# You specify the linked maps in the configuration. All setup information is
# in the configuration.
#
# Call Scripts:
#
# SWAP.activate
# Activates the swap.
#
# SWAP.type(TYPE)
# TYPE is the new transition type. 1 = Normal, 2 = LTTP, 3 = OoA
#
# SWAP.create_portal
# Makes a return portal at your position.
#
# SWAP.remove_portal
# Removes the portal
#
#===============================================================================

module SWAP

#===============================================================================
# Configuration
#===============================================================================
  #light world switch, true when light world, false when dark world
  SWITCH = 26
  #Start in the light world, true is light world, false is dark world
  LIGHT_START = true
  #Transition Type: 1 = Normal, 2 = LTTP, 3 = OoA
  TRANSITION_TYPE = 3
  #If the next world is impassable, activate swap again
  IMPASSABLE_SWAP = true
  #Sound Effects = RPG::AudioFile.new('Name', Volume, Pitch)
  LTTP_SE = RPG::AudioFile.new('Teleportation - Warp - 01', 100, 100)
  OOA_SE = RPG::AudioFile.new('Teleportation - Warp - 01', 100, 100)
  #Use the shake effect for LTTP transitions
  SHAKE = true
  #Shake Effect = [Power, Speed, Duration]
  SHAKE_EFFECT = [7, 4, 40]
  #Animation ID displayed during Oracle of Ages transition
  OOA_ANIMATION1 = 678
  #Animation ID displayed after the Oracle of Ages transition
  OOA_ANIMATION2 = 678
  #Automatically creates/remove portals
  AUTO_PORTAL = true
  #Graphic for the Portal
  PORTAL_CHARACTER = 'Weapon - Effect - MagicMirror - Portal[2]'
  #Speed of the stop animation (1-6)
  PORTAL_SPEED = 5
  #Animation ID displayed when the portal is created
  PORTAL_ANIMATION = 176
  #World Link Format: Light World ID => Dark World ID
  LINKS = {
  41 => 42,
  44 => 45,
  }
#===============================================================================
# End Configuration
#===============================================================================

  def self.activate
    #get the old map id
    old_id = $game_map.map_id
    #get the map id
    id = nil
    if $game_switches[SWITCH]
      id = LINKS[old_id]
    else
      LINKS.each {|key, value| id = key if value == old_id }
    end
    #skip the swap if the id is nil
    return if id.nil?
    #setup temps
    $game_temp.player_new_map_id = id
    $game_temp.player_new_x = $game_player.x
    $game_temp.player_new_y = $game_player.y
    $game_temp.player_new_direction = $game_player.direction
    $game_temp.transition_processing = false
    #straighten the player
    $game_player.straighten
    #get the current game data
    temp = $game_temp
    system = $game_system
    map = $game_map
    #transition to the new map
    self.get_transition
    #if the new location is impassable
    if IMPASSABLE_SWAP && !self.passable?
      #transfer back and reset game data
      $game_temp.player_new_map_id = old_id
      self.get_transition(temp, system, map)
    end
    #clear the transition name if one exists
    $game_temp.transition_name == ''
    return true
  end
  
  def self.get_transition(*args)
    #execute the transition type stored
    case $game_system.swap_type
    when 1 then return normal_transition(*args)
    when 2 then return lttp_transition(*args)
    when 3 then return ooa_transition(*args)
    end
  end
  
   def self.normal_transition(*game_data)
    #freeze graphics
    Graphics.freeze
    #swap the switches
    $game_switches[SWITCH] = !$game_switches[SWITCH]
    #remove the portal if needed
    self.remove_portal if AUTO_PORTAL && $game_switches[SWITCH]
    #if there is no map specified
    if game_data.size == 0
      #transfer to the new map
      $scene.transfer_player
    else
      #reset game data (for compatibility)
      $game_temp = game_data[0]
      $game_system = game_data[1]
      $game_map = game_data[2]
      #reset the spriteset
      $scene.spriteset.dispose
      $scene.spriteset = Spriteset_Map.new
      #autoplay bgm, bgs
      $game_map.autoplay
    end
    #transition using a graphic if one exists
    if $game_temp.transition_name == ''
      Graphics.transition(20)
    else
      transition = 'Graphics/Transitions/' + $game_temp.transition_name
      Graphics.transition(40, transition)
    end
    #create the portal if needed
    if AUTO_PORTAL && $game_switches[SWITCH] && self.passable?
      self.make_portal
    end
  end
  
  def self.lttp_transition(*game_data)
    #setup a blank white sprite on top of everything
    sprite = Sprite.new
    sprite.z = 5000
    sprite.opacity = 0
    sprite.bitmap = Bitmap.new(640,480)
    sprite.bitmap.fill_rect(sprite.bitmap.rect, Color.new(255,255,255))
    #setup a player on top of the white sprite
    player = Sprite_Character.new(nil, $game_player.clone)
    tone = $scene.spriteset.viewport1.tone
    if $max_antilag
      player.update
      player.sprite.z = 5001
      player.sprite.tone = tone
    else
      player.z = 5001
      player.tone = tone
    end
    #hide the real player
    $game_player.transparent = true
    #play the sound effect
    $game_system.se_play(LTTP_SE)
    #shake the screen
    $game_screen.start_shake(*SHAKE_EFFECT) if SHAKE
    #transition to the white screen
    26.times do
      Graphics.update
      $game_screen.update
      $scene.spriteset.update
      sprite.opacity += 10
    end
    #swap the switches
    $game_switches[SWITCH] = !$game_switches[SWITCH]
    #remove the portal if needed
    self.remove_portal if AUTO_PORTAL && $game_switches[SWITCH]
    #if there is no map specified
    if game_data.size == 0
      #transfer to the new map
      $scene.transfer_player
    else
      #reset game data (for compatibility)
      $game_temp = game_data[0]
      $game_system = game_data[1]
      $game_map = game_data[2]
      #reset the spriteset
      $scene.spriteset.dispose
      $scene.spriteset = Spriteset_Map.new
      #autoplay bgm, bgs
      $game_map.autoplay
    end
    #transition back to the map
    26.times do
      Graphics.update
      $game_screen.update
      $scene.spriteset.update
      sprite.opacity -= 10
    end
    #create the portal if needed
    if AUTO_PORTAL && $game_switches[SWITCH] && self.passable?
      self.make_portal
    end
    #show the real player again
    $game_player.transparent = false
    #dispose the sprites
    sprite.bitmap.dispose
    sprite.dispose
    player.dispose
  end
  
  def self.ooa_transition(*game_data)
    #turn player downwards
    $game_player.turn_down
    #update the spriteset
    $scene.spriteset.update
    #create a viewport
    viewport = Viewport.new(0,0,640,480)
    viewport.z = 5000
    #create a black and white sprite
    black = Sprite.new(viewport)
    black.opacity = 0
    black.bitmap = Bitmap.new(640,480)
    black.bitmap.fill_rect(black.bitmap.rect, Color.new(0,0,0))
    white = Sprite.new
    white.z = 10000
    white.opacity = 0
    white.bitmap = Bitmap.new(640,480)
    white.bitmap.fill_rect(white.bitmap.rect, Color.new(255,255,255))
    #create a player sprite
    player = Sprite_Character.new(viewport, $game_player.clone)
    tone = $scene.spriteset.viewport1.tone
    if $max_antilag
      player.update
      player.sprite.z = 1
      player.sprite.tone = tone
      #dispose shadow if xas exists
      if $xrxs_xas
        player.sprite.shadow.dispose
        player.sprite.shadow = nil
      end
    else
      player.z = 1
      player.tone = tone
      #dispose shadow if xas exists
      if $xrxs_xas
        player.shadow.dispose
        player.shadow = nil
      end
    end
    #hide the real player
    $game_player.transparent = true
    #play the sound effect
    $game_system.se_play(OOA_SE)
    #transition to the black screen
    10.times do
      Graphics.update
      black.opacity += 30
    end
    #swap the switches
    $game_switches[SWITCH] = !$game_switches[SWITCH]
    #remove the portal if needed
    self.remove_portal if AUTO_PORTAL && $game_switches[SWITCH]
    #if there is no map specified
    if game_data.size == 0
      #transfer to the new map
      $scene.transfer_player
    else
      #reset game data (for compatibility)
      $game_temp = game_data[0]
      $game_system = game_data[1]
      $game_map = game_data[2]
      #reset the spriteset
      $scene.spriteset.dispose
      $scene.spriteset = Spriteset_Map.new
      #autoplay bgm, bgs
      $game_map.autoplay
    end
    #start the animation
    animation = $data_animations[OOA_ANIMATION1]
    if $max_antilag
      player.sprite.animation(animation, false) 
    else
      player.animation(animation, false) 
    end
    #wait for the animation to play
    count = animation.frame_max * 2
    count.times do |i|
      Graphics.update
      player.update rescue nil
      #disable player visibility if half way through
      if i == count / 2
        $max_antilag ? player.sprite.visible = false : player.visible = false
      end
    end
    #transition to the white screen
    30.times do
      Graphics.update
      white.opacity += 10
    end
    #dispose black and player sprites
    black.bitmap.dispose
    black.dispose
    player.dispose
    viewport.dispose
    #update the spriteset
    $scene.spriteset.update
    #transition to the map
    30.times do
      Graphics.update
      white.opacity -= 10
    end
    #dispose the white sprite
    white.bitmap.dispose
    white.dispose
    #wait for the animation to finish
    $game_player.animation_id = OOA_ANIMATION2
    count = $data_animations[OOA_ANIMATION2].frame_max * 2
    count.times do |i|
      Graphics.update
      $game_screen.update
      $game_map.update
      $scene.spriteset.update
      #make player visible half way through
      $game_player.transparent = false if i == count / 2
    end
    #create the portal if needed
    if AUTO_PORTAL && $game_switches[SWITCH] && self.passable?
      self.make_portal
    end
  end
  
  def self.passable?
    #return true if the tile is passable, false if not
    player = $game_player
    return false if !$game_map.passable?(player.x, player.y, 0, player)
    $game_map.events.each_value do |event|
      if event.x == player.x && event.y == player.y
        next if event.through
        return false if event.character_name != ''
      end
    end
    return true
  end
  
  def self.type(type)
    #change the transition type
    $game_system.swap_type = type
    return true
  end
  
  def self.make_portal
    #remove the current portal if needed
    self.remove_portal
    #Save the portal map and coordinates
    $game_system.swap_portal = [$game_map.map_id,
                                $game_player.x, $game_player.y]
    #create the map portal
    event = $game_map.make_swap_portal
    $scene.spriteset.make_swap_portal(event)
    return true
  end
  
  def self.remove_portal
    #return if there is no portal
    return if $game_system.swap_portal.nil?
    #if the portal is on the current map
    if $game_system.swap_portal[0] == $game_map.map_id
      #erase the portal
      $game_map.events[999].erase unless $game_map.events[999].nil?
    end
    #delete the portal information
    $game_system.swap_portal = nil
    return true
  end
end

#===============================================================================
# Game_Switches
#===============================================================================

class Game_Switches
  alias max_swap_initialize_later initialize
  def initialize
    max_swap_initialize_later
    @data[SWAP::SWITCH] = SWAP::LIGHT_START
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :swap_portal
  attr_accessor :swap_type
  alias max_swap_initialize_later initialize
  def initialize
    max_swap_initialize_later
    @swap_portal = nil
    @swap_type = SWAP::TRANSITION_TYPE
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  alias max_swap_setup_later setup
  def setup(*args)
    max_swap_setup_later(*args)
    #if there is a portal on the map, make it
    if !$game_system.swap_portal.nil? && $game_system.swap_portal[0] == @map_id
      make_swap_portal
    end
  end
  
  def make_swap_portal
    #make the portal event
    portal = $game_system.swap_portal
    event = RPG::Event.new(portal[1], portal[2])
    event.id = 999
    page = RPG::Event::Page.new
    graphic = RPG::Event::Page::Graphic.new
    graphic.character_name = SWAP::PORTAL_CHARACTER
    page.graphic = graphic
    page.move_speed = SWAP::PORTAL_SPEED
    page.step_anime = true
    page.through = true
    page.trigger = 1
    comment = RPG::EventCommand.new
    comment.code = 108
    comment.parameters = ['\portal']
    swap = RPG::EventCommand.new
    swap.code = 355
    swap.parameters = ['SWAP.activate']
    page.list = [comment, swap, RPG::EventCommand.new]
    event.pages = [page]
    @events[event.id] = Game_Event.new(@map_id, event)
    return @events[event.id]
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  attr_reader :viewport1
  def make_swap_portal(event)
    #add the portal sprite
    @character_sprites.push Sprite_Character.new(@viewport1, event)
    return if SWAP::PORTAL_ANIMATION == 0
    #play the portal sprite creation animation
    animation = $data_animations[SWAP::PORTAL_ANIMATION]
    if $max_antilag
      @character_sprites[-1].update
      @character_sprites[-1].sprite.animation(animation, false) 
    else
      @character_sprites[-1].animation(animation, false) 
    end
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  attr_accessor :spriteset
end