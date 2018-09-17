#===============================================================================
# ¦ Maximusmaxy's Event Fade
#-------------------------------------------------------------------------------
# Makes events fade when you stand behind/underneath them.
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.3: 11/3/12
#===============================================================================
#
# Introduction:
# This script makes events fade when the player is standing behind or
# underneath them.
#
# Instructions:
# To use this script place a '\fade' comment on an event. You can set the 
# default opacity in the config or specify the opacity in the call like so:
# '\fade(69)'. 0 = transparent, 255 = opaque.
# 
#===============================================================================

$max_fade = 0.3

module FADE
  
#===============================================================================
# Configuration
#===============================================================================
  #set the default opacity to fade to here
  DEFAULT = 100
#===============================================================================
# End Configuration
#===============================================================================

end

#===============================================================================
# Game_Character
#===============================================================================

class Game_Character
  attr_accessor :fade_target
  alias max_under_initialize_later initialize
  def initialize
    max_under_initialize_later
    #initialize fade value
    @fade_target = 255
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_writer :opacity
  alias max_under_refresh_later refresh
  def refresh
    @fade_target = 255
    max_under_refresh_later
    unless @erased || @list.nil?
      #search the events list
      @list.each do |line|
        #if there is a comment
        if line.code == 108
          #if the comment denotes it as being a fade event
          if line.parameters[0] =~ /\\[Ff]ade\(?(\d*)\)?/
            @fade_target = $1 == '' ? FADE::DEFAULT : $1.to_i
          end
        else
          break
        end
      end
    end
  end
end

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character < RPG::Sprite
  #class variable for the fade cache
  @@fade_cache = {}
  alias max_under_initialize_later initialize
  alias max_under_update_later update
  def initialize(*args)
    #initialize under coordinates
    @under = Array.new(4,-1)
    max_under_initialize_later(*args)
    #determine the edges for the fade if a fade event
    if @character.fade_target != 255
      load_under_coordinates 
      #fade the character if underneath initially
      @character.opacity = self.opacity = @character.fade_target if under?
    end
  end
  
  #determine the underneath coordinates
  def load_under_coordinates
    key = [@character.character_name,@character.direction,@character.pattern]
    #if the data has already been created, use the cached data
    unless @@fade_cache[key].nil?
      @under = @@fade_cache[key]
    #else find the data
    else
      find_under_coordinates
    end
  end
  
  #find the real coordinates at which the player is under the event
  def find_under_coordinates
    #search from the middle point of each side to find the first pixel that
    #isn't transparent, set the under coordinates when found.
    sx = @character.pattern * @cw
    sy = (@character.direction - 2) / 2 * @ch
    (0...@cw).each do |i|
      if @under[0] == -1 && self.bitmap.get_pixel(sx + i, sy + @ch / 2).alpha != 0
        @under[0] = i
      end
      if @under[2] == -1 && self.bitmap.get_pixel(sx + @cw - i, sy + @ch / 2).alpha != 0
        @under[2] = @cw - i 
      end
      #break if all the coordinates have been set
      break if @under[0] != -1 && @under[2] != -1
    end
    (0...@ch).each do |i|
      if @under[1] == -1 && self.bitmap.get_pixel(sx + @cw / 2, sy + i).alpha != 0
        @under[1] = i
      end
      if @under[3] == -1 && self.bitmap.get_pixel(sx + @cw / 2, sy + @ch - i).alpha != 0
        @under[3] = @ch - i
      end       
      #break if all the coordinates have been set
      break if @under[1] != -1 && @under[3] != -1
    end
    #store data in the fade cache
    key = [@character.character_name,@character.direction,@character.pattern]
    @@fade_cache[key] = @under
    #prevent frame skip
    Graphics.frame_reset
  end
  
  #is the player underneath the event?
  def under?
    return false if $game_player.screen_x < self.x + @under[0] - @cw / 2
    return false if $game_player.screen_y < self.y + @under[1] - @ch
    return false if $game_player.screen_x > self.x + @under[2] - @cw / 2
    return false if $game_player.screen_y > self.y + @under[3] - @ch + 16
    return true
  end
  
  def update
    max_under_update_later
    #if the event is a fade event
    if @character.fade_target != 255
      #reload the under coordinates if the image changes
      if @character_name != @character.character_name ||
         @character_direction != @character.direction ||
         @character_pattern != @character.pattern
        @character_direction = @character.direction
        @character_pattern = @character.pattern
        load_under_coordinates
      end
      #if the player is under the event
      if under?
        #fade the event
        @character.opacity = [self.opacity - 10, @character.fade_target].max
      else
        #else defade
        @character.opacity = [self.opacity + 10, 255].min
      end
    end
  end
end