#===============================================================================
# ¦ PZE Discovered Item
#-------------------------------------------------------------------------------
# Shows discovered item's above links head.
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.2: 11/3/12
#===============================================================================
#
# Note: This script requires XAS
#
# Introduction:
# Shows discovered items above links head without the need to create extra
# sprites. Saves time and money.
#
# Instructions:
# Just use the call script.
#
# Call Scripts:
# DISCOVER.show(NAME)
# NAME is the name of the icon you want shown
#
# DISCOVER.hide
# Reverts character back to it's original character
# 
# Note: If a file name contains the single quote (') -i.e. Biggoron's Sword, 
# Roc's Feather, or Romani's Mask-, you can either use double quotes (''), or 
# just put a backslash before the quote symbol (\').
#
#===============================================================================

$pze_discover = 0.1

module DISCOVER
  
#===============================================================================
# Configuration
#===============================================================================
  #Character sprite shown
  SUFFIX = '_DISCOVER[1]'
  #How many pixels above your character do you want the item shown
  Y_OFFSET = 48
  #How many frames per icon update
  FRAMES = 10
#===============================================================================
# End Configuration
#===============================================================================

  def self.show(name)
    $game_player.discover_icon(name)
  end
  
  def self.hide
    $game_player.character_name_suffix = nil
  end
end

#===============================================================================
# Game_Player
#===============================================================================

class Game_Player < Game_Character
  attr_accessor :discovered_icon
  alias max_discovered_initialize_later initialize
  def intialize
    max_discovered_initialize_later
    @discovered_icon = ''
  end
  
  def discover_icon(name)
    #change character to the discover character
    self.character_name_suffix = DISCOVER::SUFFIX
    #set the type and id
    @discovered_icon = name
    return true
  end
end

#===============================================================================
# Sprite_Discovered_Icon
#===============================================================================

class Sprite_Discovered_Icon < Sprite
  def initialize(viewport, icon)
    super(viewport)
    #set the bitmap
    self.bitmap = RPG::Cache.icon(icon)
    #get the amount of frames, check for Cogs REGEXP
    if defined?(COG_ExtraFrames) && icon[COG_ExtraFrames::REGEXP]  
      @frames = $1.to_i
    else
      @frames = 1
    end
    #initialize the count
    @count = 0
    #move into place
    @width = self.bitmap.width / @frames
    @height = self.bitmap.height
    self.ox = @width / 2
    self.oy = @height
  end
  
  def update
    #update the frame
    @count = (@count + 1) % (@frames * DISCOVER::FRAMES)
    self.src_rect.set(@width * (@count / DISCOVER::FRAMES), 0, @width, @height)
  end
end

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character < RPG::Sprite
  alias max_discovered_update_later update
  def update
    max_discovered_update_later
    #if the character is a player and the player has discovered an item
    if @character.is_a?(Game_Player) && @character.discovered_icon != ''
      #if the player character is the discover character
      if @character.character_name_suffix == DISCOVER::SUFFIX
        #create the discovered icon sprite if it doesn't exist
        if @discovered_icon.nil?
          #create the sprite
          @discovered_icon = Sprite_Discovered_Icon.new(
                             self.viewport, @character.discovered_icon)
        end
        #update the location of the sprite
        @discovered_icon.x = self.x
        @discovered_icon.y = self.y - DISCOVER::Y_OFFSET
        @discovered_icon.z = self.z
        #update the icon
        @discovered_icon.update
      #else if the discovered icon still exists?
      elsif !@discovered_icon.nil?
        #dispose the icon
        @discovered_icon.dispose
        @discovered_icon = nil
        #reset the discovered item
        @character.discovered_icon = ''
      end       
    end
  end
end