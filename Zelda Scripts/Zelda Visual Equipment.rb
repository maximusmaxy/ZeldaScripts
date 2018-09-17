#===============================================================================
# ¦ PZE Visual Equipment
#-------------------------------------------------------------------------------
# Shows what you have equipped
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.2: 13/3/12
#===============================================================================
# 
# Note: This script requires XAS
#
# Introduction:
# Shows what you have equipped.
#
# Instructions:
# All information is in the configuration.
#
#===============================================================================

module VISUAL

#===============================================================================
# Configuration
#===============================================================================
  WEAPON = {
  #Weapon ID => Character Graphic

  }
  
  SHIELD = {
  #Armor ID => Character Graphic
  }
  
  HELMET = {
  #Armor ID => Character Graphic
  137 => 'Mask - All-Night Mask',
  138 => 'Mask - Blast Mask',
  139 => 'Mask - Bremem Mask',
  140 => 'Mask - Bunny Hood',
  141 => 'Mask - Captain Hat',
  142 => 'Mask - Circus Leader Mask',
  143 => 'Mask - Couple Mask',
  144 => 'Mask - Doggie Mask',
  145 => 'Mask - Don Gero Mask',
  146 => 'Mask - Garo Mask',
  147 => 'Mask - Giant Mask',
  148 => 'Mask - Gibdo Mask',
  149 => 'Mask - Great Fairy Mask',
  150 => 'Mask - Kafei Mask',
  151 => 'Mask - Kamaro Mask',
  152 => 'Mask - Keaton Mask',
  153 => 'Mask - Mask of Scents',
  154 => 'Mask - Mask Of Truth',
  155 => 'Mask - Moon Mask',
  156 => 'Mask - Postman Hat',
  157 => 'Mask - Romani Mask',
  158 => 'Mask - Stone Mask',
  159 => 'Mask - Sun Mask',
  160 => 'Mask - Skull Mask',
  161 => 'Mask - Spooky Mask',
  162 => 'Mask - Gerudo Mask'
  
 }
  
  BODY = {
  #Armor ID => Character Graphic
  23 => 'Link[7]',
  24 => 'Red_Link[7]',
  25 => 'Blue_Link[7]',
  27 => 'Link[7]',
  28 => 'Red_Link[7]',
  29 => 'Blue_Link[7]',
  31 => 'Link[7]',
  32 => 'Red_Link[7]',
  33 => 'Blue_Link[7]',
  }
  
  ACCESSORY = {
  #Armor ID => Character Graphic
  }
  
#===============================================================================
# Suffix Offset Setup
#-------------------------------------------------------------------------------
# The Format follows this setup:
#
# 'SUFFIX' => [
# [DX1, DY1, DZ1], [DX2, DY2, DZ2], [DX3, DY3, DZ3], [DX4, DY4, DZ4],
# [LX1, LY1, LZ1], [LX2, LY2, LZ2], [LX3, LY3, LZ3], [LX4, LY4, LZ4],
# [RX1, RY1, RZ1], [RX2, RY2, RZ2], [RX3, RY3, RZ3], [RX4, RY4, RZ4],
# [UX1, UY1, UZ1], [UX2, UY2, UZ2], [UX3, UY3, UZ3], [UX4, UY4, UZ4],
# ]
#
# Where the first letter is the direction
# The second is the X, Y or Z
# the third is the frame, if your character has more or less than 4 frames,
# then continue in the same pattern.
#
# In each of these blocks you put the offset of your visual equipment like so:
#
# 'SUFFIX' => [
# [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0],
# [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0],
# [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0],
# [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0],
# ] 
#
#===============================================================================
  WEAPON_SUFFIX = {

  
  }

  SHIELD_SUFFIX = {
  
  }
  
  HELMET_SUFFIX = {
  '' => [
  [0,2,1], [0,1,1], [0,0,1], [0,2,1], [0,1,1], [0,0,1], [0,2,1],
  [0,-1,1], [0,-2,1], [0,-1,1], [0,-1,1], [0,-2,1], [0,-1,1], [0,0,1],
  [0,-1,1], [0,-2,2], [0,-1,1], [0,-1,1], [0,-2,1], [0,-1,2], [0,0,1],
  [0,8,-1], [0,7,-1], [0,6,-1], [0,8,-1], [0,7,-1], [0,6,-1], [0,7,-1],
  ],
  
  '_SWORD(16)[6]' => [ 
  [0,-7,1], [0,-7,1], [0,-7,1], [0,-7,1], [0,-7,1], [0,-7,1],
  [-1,-15,1], [-2,-15,1], [-2,-15,1], [-2,-15,1], [-2,-15,1], [-2,-15,1],
  [1,-14,1], [2,-14,2], [2,-14,1], [2,-14,1], [2,-14,1], [1,-14,2],
  [0,8,-1], [0,7,-1], [0,6,-1], [0,8,-1], [0,7,-1], [0,6,-1],
  ],
  
  '_SWORD_MASTER(24)[6]' => [ 
  [0,-21,1], [0,-22,1], [0,-21,1], [0,-21,1], [0,-22,1], [0,-22,1],
  [-1,-25,1], [-1,-25,1], [-1,-25,1], [0,-25,1], [-1,-25,1], [-1,-25,1],
  [1,-24,2], [1,-24,1], [1,-24,1], [0,-24,1], [1,-24,1], [1,-24,2],
  [0,-18,-1], [0,-18,-1], [0,-18,-1], [0,-18,-1], [0,-18,-1], [0,-18,-1],
  ],
  
  '_SWORD_ORDON(16)[6]' => [ 
  [0,-7,1], [0,-7,1], [0,-7,1], [0,-7,1], [0,-7,1], [0,-7,1],
  [-1,-15,1], [-2,-15,1], [-2,-15,1], [-2,-15,1], [-2,-15,1], [-2,-15,1],
  [1,-14,1], [2,-14,2], [2,-14,1], [2,-14,1], [2,-14,1], [1,-14,2],
  [0,8,-1], [0,7,-1], [0,6,-1], [0,8,-1], [0,7,-1], [0,6,-1],
  ],
  
  '_SWORD_BIGGORONS(36)[6]' => [
  [0,-32,1], [0,-32,1], [0,-32,1], [0,-32,1], [0,-32,1], [0,-32,1],
  [-1,-35,1], [-2,-35,1], [-2,-35,1], [-2,-35,1], [-2,-35,1], [-2,-35,1],
  [1,-34,1], [2,-34,2], [2,-34,1], [2,-34,1], [2,-34,1], [1,-34,2],
  [0,8,-1], [0,7,-1], [0,6,-1], [0,8,-1], [0,7,-1], [0,6,-1],
  ],
  
  '_SLINGSHOT[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,-1],
  ],
  
  '_HSLINGSHOT[1]' => [ 
  [0,7,1],[0,0,1],[0,0,1],[0,10,-1],
  ],
  
  '_FIREROD[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,-1],
  ],
  
  '_ICEROD[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,-1],
  ],
 
  '_HOOKSHOT(16)[1]' => [
  [0,-16,1],[3,-16,1],[-3,-16,1],[0,-5,-1],
  ],
  
  '_LONGSHOT(16)[1]' => [
  [0,-16,1],[3,-16,1],[-3,-16,1],[0,-5,-1],
  ],
  
  '_BOW[3]' => [
  [0,3,1],[0,3,1],[0,0,1],
  [0,0,1],[0,0,1],[0,0,1],
  [0,0,1],[0,0,1],[0,0,1],
  [0,0,-1],[0,0,-1],[0,0,-1],
  ],
  
  '_SEEDSHOOTER(16)[1]' => [
  [0,-15,1],[2,-16,1],[-2,-16,1],[0,-10,1],
  ],
  
  
  '_BALLCHAIN(16)[1]' => [
  [0,-16,1],[3,-16,1],[-3,-16,1],[0,-5,-1],
  ],
  
  '_HAMMER[3]' => [
  [0,3,1],[0,3,1],[0,0,1],
  [0,0,1],[0,0,1],[0,0,1],
  [0,0,1],[0,0,1],[0,0,1],
  [0,0,-1],[0,0,-1],[0,0,-1],
  ],
  
  '_MHAMMER1(16)[3]' => [
  [0,-16,1],[0,-16,1],[0,-16,1],
  [2,-18,1],[2,-18,1],[2,-18,1],
  [-2,-18,1],[-2,-18,1],[-2,-18,1],
  [0,-5,0],[0,-5,0],[0,-5,0],
  ],
  
  '_MHAMMER2(16)[1]' => [
  [0,-16,1],[2,-18,1],[-2,-18,1],[0,-5,0],
  ],
  
  '_LANTERN(16)' => [
  [0,-10,1],[0,-10,1],[0,-10,1],[0,-10,1],
  [0,-16,1],[0,-16,1],[0,-16,1],[0,-16,1],
  [0,-16,1],[0,-16,1],[0,-16,1],[0,-16,1],
  [0,-5,0],[0,-5,0],[0,-5,0],[0,-5,0],
  ],
  
  '_MPOWDER[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,-1],
  ],
  
  '_ICEROD[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,-1],
  ],
  
  
  '_CANE_SOMARIA(16)[1]' => [
  [0,-16,1],[0,-18,1],[0,-18,1],[0,-5,-1],
  ],
  
  '_CANE_PACCI(16)[1]' => [
  [0,-16,1],[0,-18,1],[0,-18,1],[0,-5,-1],
  ],
  
  
  '_DEKUNUT[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  ],
  
  '_JUMP[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  ],
  
  '_PICKUP[2]' => [
  [0,7,1],[0,0,1],
  [0,7,1],[0,0,1],
  [0,7,1],[0,0,1],
  [0,7,1],[0,0,1],
  ],
  
  '_DROP[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  ],
  
  
  '_Throw[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  ],
  
  '_DISCOVER[1]' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  ],
  
  '_CARRY[6]' => [
  [0,8,1], [0,7,1], [0,7,1], [0,6,1], [0,7,1], [0,8,1],
  [0,0,1], [0,0,1], [0,0,1], [0,-1,1], [0,-2,1], [0,-1,1],
  [0,-1,1], [0,-2,1], [0,-1,1], [0,-1,1], [0,-2,1], [0,-1,1],
  [0,8,-1], [0,7,-1], [0,6,-1], [0,8,-1], [0,7,-1], [0,6,-1],
  ],
  
  '_HIT' => [
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  [0,7,1],[0,0,1],[0,0,1],[0,10,1],
  ],
  
  
  }
  
  ACCESSORY_SUFFIX = {
  
  }
  
#===============================================================================
# End Configuration
#===============================================================================

end

#===============================================================================
# Game_Actor
#===============================================================================

class Game_Actor
  attr_reader :weapon_name
  attr_reader :shield_name
  attr_reader :helmet_name
  attr_reader :accessory_name
  alias max_visual_setup_later setup
  alias max_visual_equip_later equip
  def setup(*args)
    max_visual_setup_later(*args)
    #initialize visual names
    @weapon_name = ''
    @shield_name = ''
    @helmet_name = ''
    @accessory_name = ''
  end
  
  def equip(type, id)
    max_visual_equip_later(type, id)
    case type
    when 0 #weapon
      name = VISUAL::WEAPON[id]
      @weapon_name = name.nil? ? '' : name
    when 1 #shield
      name = VISUAL::SHIELD[id]
      @shield_name = name.nil? ? '' : name
    when 2 #helmet
      name = VISUAL::HELMET[id]
      @helmet_name = name.nil? ? '' : name
    when 3 #body
      name = VISUAL::BODY[id]
      @character_name = name unless character_name.nil?
    when 4 #accessory
      name = VISUAL::ACCESSORY[id]
      @accessory_name = name.nil? ? '' : name
    end
    #refresh the player if actor is the player
    $game_player.refresh if $game_party.actors[0] == self
  end
end

#===============================================================================
# Game_Player
#===============================================================================

class Game_Player
  attr_reader :visual_names
  attr_reader :need_visual_refresh
  alias max_visual_initialize_later initialize
  alias max_visual_refresh_later refresh
  def initialize
    max_visual_initialize_later
    #initialize visual name array and refresh flag
    @visual_names = Array.new(4, '')
    @need_visual_refresh = false
  end
  
  def refresh
    max_visual_refresh_later
    #get the actor
    actor = $game_party.actors[0]
    #get the original names
    names = [@weapon_name, @shield_name, @helmet_name, @accessory_name]
    #set each name
    @weapon_name = actor.weapon_name
    @shield_name = actor.shield_name
    @helmet_name = actor.helmet_name
    @accessory_name = actor.accessory_name
    #get the new names
    new_names = [@weapon_name, @shield_name, @helmet_name, @accessory_name]
    #flag for refresh if the names have changed
    if names != new_names
      @need_visual_refresh = true
      @visual_names = new_names
    end
  end
end

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character < RPG::Sprite
  alias max_visual_initialize_later initialize
  alias max_visual_update_later update
  def initialize(viewport, character)
    #initialize equipment and equipment names if the player
    if character.is_a?(Game_Player)
      @visual_names = []
      @visual_equipment = Array.new(4)
    end
    max_visual_initialize_later(viewport, character)
  end
  
  def update
    max_visual_update_later
    #if the character is the player
    if @character.is_a?(Game_Player)
      #if the character needs his visual equipment refreshed
      if @character.need_visual_refresh
        #loop through each new visual name and index
        @character.visual_names.each_with_index do |name, i|
          #skip if the name is the same
          next if @visual_names[i] == name
          #store the new name
          @visual_names[i] = name
          #dispose the existing equipment if it exists
          unless @visual_equipment[i].nil?
            @visual_equipment[i].dispose
            @visual_equipment[i] = nil
          end
          #skip if the name is empty
          next if name == ''
          #create the new sprite
          @visual_equipment[i] = Sprite_Visual_Equipment.new(
          self.viewport, name, i, self.x, self.y, self.z)
        end
      end
      #update each visual equipment sprite
      @visual_equipment.each do |sprite|
        next if sprite.nil?
        sprite.update(self.x, self.y, self.z)
      end
    end
  end
end

#===============================================================================
# Sprite_Visual_Equipment
#===============================================================================

class Sprite_Visual_Equipment < Sprite
  attr_reader :name
  def initialize(viewport, name, type, x, y, z)
    super(viewport)
    #set the bitmap
    self.bitmap = RPG::Cache.character(name, 0)
    #get the width and height
    @width = self.bitmap.width
    @height = self.bitmap.height / 4
    #adjust the original position
    self.ox = @width / 2
    self.oy = @height
    #set the type and player
    @type = type
    @player = $game_player
    #setup the suffix
    setup_new_suffix(@player.character_name_suffix)
    #update to move everything into position
    update(x, y, z)
  end
  
  def update(x, y, z)
    #setup new suffix if the suffix has changed
    if @suffix != @player.character_name_suffix
      setup_new_suffix(@player.character_name_suffix)
    end
    #get the direction and index of the offset array
    direction = @player.direction / 2 - 1
    index = @frames * direction + @player.pattern
    #disable visibillity if offset is nil
    return self.visible = false if @offset[index].nil?
    #enable visibillity
    self.visible = true
    #set location
    self.x = x + @offset[index][0]
    self.y = y + @offset[index][1]
    self.z = z + @offset[index][2]
    #set the source rect
    self.src_rect.set(0, direction * @height, @width, @height)
  end
  
  def setup_new_suffix(suffix)
    #set the new suffix
    @suffix = suffix
    #change suffix if needed
    suffix = suffix.nil? ? '' : suffix
    #get the amount of frames the player has
    @frames = 4
    if defined?(COG_ExtraFrames)
      if suffix == '' && $game_player.character_name[COG_ExtraFrames::REGEXP]
        @frames = $1.to_i
      elsif suffix[COG_ExtraFrames::REGEXP]
        @frames = $1.to_i
      end
    end
    #get the offset array based on type
    case @type
    when 0 then offset = VISUAL::WEAPON_SUFFIX[suffix]
    when 1 then offset = VISUAL::SHIELD_SUFFIX[suffix]
    when 2 then offset = VISUAL::HELMET_SUFFIX[suffix]
    when 3 then offset = VISUAL::ACCESSORY_SUFFIX[suffix]
    end
    @offset = offset.nil? ? [] : offset
  end
end