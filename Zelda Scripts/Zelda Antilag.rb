#===============================================================================
# ¦ Maximusmaxy's Antilag (PZE/XAS VERSION)
#-------------------------------------------------------------------------------
# Reduces lag caused by events and sprites
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.3: 15/3/12
# Thanks to:
# Blizzard - Control Sprite Method
#===============================================================================
# 
# Introduction:
# This script will reduce your lag by restricting the update of events and
# sprites to the visible screen. It further reduces lag by disposing all
# sprites outside of the visible screen. The antilag system will not effect
# autorun/parallel process events, XAS tools, Enemies with large sensor ranges
# and events specified with a comment flag.
#
# Intructions:
# To make an event update outside the visible screen (for events with longer
# move routes) you place a '\lag' comment on the event. You can also disable
# the antilag system entirely using the script call.
# 
# Script Calls:
#
# ANTILAG.enable
# enables the antilag system
#
# ANTILAG.disable
# disables the antilag system
#
#===============================================================================

$max_antilag = 0.3

module ANTILAG
#==============================================================================
# Configuration
#==============================================================================
  #Is the antilag system enabled
  ANTILAG = true
#==============================================================================
# End Configuration
#==============================================================================

  def self.enable
    $game_system.antilag = true
    return
  end
  
  def self.disable
    $game_system.antilag = false
    return
  end
end

#==============================================================================
# Game_System
#==============================================================================

class Game_System
  attr_accessor :antilag
  alias max_abseal_initialize_later initialize
  def initialize
    max_abseal_initialize_later
    @antilag = ANTILAG::ANTILAG
  end
end

#==============================================================================
# Game_Character
#==============================================================================

class Game_Character
  attr_accessor :sprite_size
  alias max_lag_initialize_later initialize
  def initialize
    #initialize the size of the sprite with very large values
    @sprite_size = [-1600, 1600, -1600, 1600]
    max_lag_initialize_later
  end
end
  
#==============================================================================
# Game_Event
#==============================================================================

class Game_Event < Game_Character
  alias max_lag_update_later update
  alias max_lag_refresh_later refresh
  def update
    #update if allowed
    max_lag_update_later if self.update_event?
  end
  
  def refresh
    max_lag_refresh_later
    #update if a autorun/parallel process or a token event
    @update = [3,4].include?(self.trigger) || self.is_a?(Token_Event)
    #if the event has a list and not erased
    unless @list.nil? || @erased
      #search the events list
      @list.each do |line|
        #if there is a comment
        if line.code == 108
          #update is true if flagged for update
          @update = true if line.parameters[0].downcase == '\lag'
        else 
          break
        end
      end
    end
  end
  
  def update_event?
    #update if the antilag is disabled
    return true if !$game_system.antilag
    #update if update flag is true
    return true if @update
    #update if a battler with a large sensor range
    return true if (!self.battler.nil? && self.battler.sensor_range > 15)
    #update if the sprite can update
    return update_sprite?
  end
  
  def update_sprite?
    #do not update if not on the screen
    return false if @real_x >= $game_map.display_x + 2560 - @sprite_size[0]
    return false if @real_x < $game_map.display_x - @sprite_size[1]
    return false if @real_y >= $game_map.display_y + 1920 - @sprite_size[2]
    return false if @real_y < $game_map.display_y - @sprite_size[3]
    #update if passed all checks
    return true
  end
end

#==============================================================================
# Sprite_Character_New
#==============================================================================

class Sprite_Character_New
  attr_reader :character
  attr_reader :sprite
  def initialize(viewport, character = nil)
    #intiailize character and viewport
    self.character = character
    @viewport = viewport
  end
  
  def character=(char)
    #set both character and the sprites character
    @character = char
    @sprite.character = char unless @sprite.nil?
  end
  
  def update
    #if the character exists, is an event, and can update
    if !@character.nil? && (@character.is_a?(Game_Event) &&
        @character.update_sprite? || !@character.is_a?(Game_Event))
      #if the sprite doesn't exist
      if @sprite.nil? || @sprite.disposed?
        #create the sprite
        @sprite = Sprite_Character_Old.new(@viewport, @character)
      else #else update
        @sprite.update
      end
      #if the bitmap exists
      unless @sprite.bitmap.nil?
        #set the characters sprite size
        @character.sprite_size = [64 - @sprite.src_rect.width * 2,
        60 + @sprite.src_rect.width * 2, 128 - @sprite.src_rect.height * 4, 124]
        #if the character is an event and can't update
        if @character.is_a?(Game_Event) && !@character.update_sprite?
          #dispose the sprite
          @sprite.dispose unless @sprite.disposed?
          @sprite = nil
        end
      else #else create a dummy character size
        @character.sprite_size = [0, 124, 0, 124]
      end
    #elsif the sprite still exists
    elsif !@sprite.nil?
      #dispose the sprite
      @sprite.dispose unless @sprite.disposed?
      @sprite = nil
    end
  end
  
  def dispose
    #dispose the sprite if it exists
    unless @sprite.nil? || @sprite.disposed?
      @sprite.dispose
      @sprite = nil
    end
  end
end

#===============================================================================
# Sprite_Character_Old
#===============================================================================

class Sprite_Character_Old < Sprite_Character
  #create a dummy class to hold the old sprite character
end

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character < Sprite_Character_New
  #overwrite the old sprite character with the new sprite character
end
  