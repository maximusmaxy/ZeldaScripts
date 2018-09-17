#===============================================================================
# ¦ PZE Dark Rooms
#-------------------------------------------------------------------------------
# LTTP Style dark rooms and lighting effects
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.3: 14/3/12
#===============================================================================
# 
# NOTE: Timed torches may work incorrectly with antilag systems, make sure to
# disable your antilag system for your torches.
#
# Introduction:
# Dark Rooms RAWR!
#
# Instructions:
# use the call scripts.
# 
# Call Scripts:
# DARKROOM.start
# starts a dark room
#
# DARKROOM.end
# ends a dark room
#
# DARKROOM.darken(PERCENT)
# darkens your dark room by PERCENT
#
# DARKROOM.brighten(PERCENT)
# brightens your dark room by PERCENT
#
# DARKROOM.brighten(PERCENT, TIME)
# TIME is the amount of time in seconds, for self switch 'A' to be
# automatically turned off, and a darken will occur.
#
#===============================================================================

module DARKROOM
  
#===============================================================================
# Configuration
#===============================================================================
  #Dark room pictures
  DOWN = 'LightDown'
  LEFT = 'LightLeft'
  RIGHT = 'LightRight'
  UP = 'LightUp'
  #Brighten SE - RPG::AudioFile.new('NAME',VOLUME,PITCH)
  BRIGHT_SE = RPG::AudioFile.new('Weapon - Fire - 01',100,100)
  #Darken SE - RPG::AudioFile.new('NAME',VOLUME,PITCH)
  DARK_SE = RPG::AudioFile.new('Weapon - Fire - 01',100,100)
  #speed at which the room brightens/darkens
  SPEED = 3
  #Add map id's seperated by a comma to setup your dark rooms
  ROOMS = [29]
  #Automatically start and stop dark rooms using the array above
  AUTODARK = true
#===============================================================================
# End Configuration
#===============================================================================
  
  def self.start
    if !$game_system.dark_room && $scene.is_a?(Scene_Map)
      $scene.spriteset.dark_room = Sprite_Dark_Room.new
    end
    $game_system.dark_room = true
    return true
  end
  
  def self.end
    if $game_system.dark_room && $scene.is_a?(Scene_Map)
      $scene.spriteset.dark_room.dispose
      $scene.spriteset.dark_room = nil
    end
    $game_system.dark_room = false
    return true
  end
  
  def self.brighten(perc, time = 0)
    $game_system.se_play(BRIGHT_SE)
    if $game_system.dark_room
      $scene.spriteset.dark_room.change_opacity(-perc)
    else
      $game_system.dark_room_opacity -= perc * 2.55
    end
    if time != 0
      id = $game_system.map_interpreter.event_id
      $game_map.events[id].dark_room_timer = time * 40
      $game_map.events[id].dark_room_opacity = perc
    end
    return true
  end

  def self.darken(perc)
    $game_system.se_play(DARK_SE)
    if $game_system.dark_room
      $scene.spriteset.dark_room.change_opacity(perc)
    else
      $game_system.dark_room_opacity += perc * 2.55
    end
    return true
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :dark_room
  attr_accessor :dark_room_opacity
  alias max_dark_initialize_later initialize
  def initialize
    max_dark_initialize_later
    @dark_room = false
    @dark_room_opacity = 255
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  alias max_dark_setup_later setup
  def setup(*args)
    max_dark_setup_later(*args)
    if DARKROOM::AUTODARK
      DARKROOM::ROOMS.include?(@map_id) ? DARKROOM.start : DARKROOM.end
    end
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event
  attr_accessor :dark_room_timer
  attr_accessor :dark_room_opacity
  alias max_dark_initialize_later initialize
  alias max_dark_update_later update
  def initialize(*args)
    max_dark_initialize_later(*args)
    #initialize the timer
    @dark_room_timer = 0
    @dark_room_opacity = 0
  end
  
  def update
    max_dark_update_later
    #update dark room timer
    if @dark_room_timer > 0
      @dark_room_timer -= 1
      #disable the self switch if timer is up
      if @dark_room_timer <= 0
        DARKROOM.darken(@dark_room_opacity)
        $game_self_switches[[@map_id, @id, 'A']] = false
        $game_map.need_refresh = true
      end
    end
  end
end

#===============================================================================
# Sprite_Dark_Room
#===============================================================================

class Sprite_Dark_Room < Sprite
  def initialize
    super()
    self.z = 5000
    self.opacity = @opacity = $game_system.dark_room_opacity
    @map_id = $game_map.map_id
    update
  end
  
  def dispose
    #store the dark room opacity if on the same map
    if @map_id == $game_map.map_id
      $game_system.dark_room_opacity = @opacity
    else #else reset the dark room opacity
      $game_system.dark_room_opacity = 255
    end
    super
  end
  
  def update
    #if the player changes direction change the picture
    if @direction != $game_player.direction
      @direction = $game_player.direction
      case @direction
      when 2 then picture = DARKROOM::DOWN
      when 4 then picture = DARKROOM::LEFT
      when 6 then picture = DARKROOM::RIGHT
      when 8 then picture = DARKROOM::UP
      end
      self.bitmap = RPG::Cache.picture(picture)
    end
    #update location
    self.x = $game_player.screen_x - self.bitmap.width / 2 
    self.y = $game_player.screen_y - self.bitmap.height / 2
    #update brightness
    if @opacity < self.opacity
      self.opacity = [self.opacity - DARKROOM::SPEED, @opacity].max
    elsif @opacity > self.opacity
      self.opacity = [self.opacity + DARKROOM::SPEED, @opacity].min
    end
  end
  
  def change_opacity(perc)
    #add percentage to the opacity
    @opacity = [@opacity + perc * 2.55, 255].min
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  attr_accessor :dark_room
  alias max_dark_initialize_later initialize
  alias max_dark_dispose_later dispose
  alias max_dark_update_later update
  def initialize
    #create a dark room sprite if needed
    @dark_room = Sprite_Dark_Room.new if $game_system.dark_room
    max_dark_initialize_later
  end
  
  def dispose
    max_dark_dispose_later
    #dispose the dark room sprite aswell
    @dark_room.dispose unless @dark_room.nil?
  end
  
  def update
    max_dark_update_later
    #update dark room if it exists
    @dark_room.update unless @dark_room.nil?
  end
end

#===============================================================================
# Interpreter
#===============================================================================

class Interpreter
  attr_reader :event_id
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  attr_reader :spriteset
  alias max_dark_transfer_later transfer_player
  def transfer_player
    #reset current timed event switches
    if $game_map.map_id != $game_temp.player_new_map_id
      $game_map.events.each do |id, event|
        if event.dark_room_timer > 0
          $game_self_switches[[$game_map.map_id, id, 'A']] = false
        end
      end
    end
    max_dark_transfer_later
  end
end