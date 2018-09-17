#===============================================================================
# ¦ PZE Map Cursor
#-------------------------------------------------------------------------------
# Displays an animated on the cursor on the map
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.2: 8/3/12
#===============================================================================
# 
# Introduction:
# Displays an animated cursor similar to the cursor from the Ocarina of Time
# and Majora's Mask Menu systems. Allows you to highlight things of interest.
#
# Instuctions:
# You can move the cursor around the map using the script calls, the cursor will
# continue to follow the player/event as they move. If you want to change the
# cursor type you can use the script call
#
# Type 1 = Classic
# Type 2 = Animated
#
# Script Calls:
# 
# CURSOR.type(ID)
# ID is the type of cursor you are changing to
# 
# CURSOR.show
# Shows the cursor at the player position
#
# CURSOR.show(EVENT_ID)
# Shows the cursor at the EVENT_ID specified
#
# CURSOR.show(X, Y)
# Shows the cursor at the X and Y coordinates on the map
#
# CURSOR.move(DURATION)
# Moves the cursor to the player, DURATION is in frames.
#
# CURSOR.move(EVENT_ID, DURATION)
# Moves the cursor to the EVENT_ID, DURATION is in frames.
#
# CURSOR.move(X, Y, DURATION)
# Shows the cursor at the X and Y coordinates on the map
#
# CURSOR.hide
# Hides the cursor from view
#===============================================================================

$pze_cursor = 0.2

module CURSOR
  
#===============================================================================
# Configuration
#===============================================================================
  #Type used, can be changed with the script call
  TYPE = 1
  #Cursor images
  CLASSIC_IMAGE = 'Map_Cursor_Classic'
  ANIMATED_IMAGE = 'Map_Cursor_Animated'
  #Animated cursor settings
  SPEED = 5
  MIN_RADIUS = 20
  MAX_RADIUS = 30
#===============================================================================
# End Configuration
#===============================================================================
  
  def self.type(id)
    return true if id == $game_system.map_cursor_type
    $game_system.map_cursor_type = id
    $scene.spriteset.change_map_cursor
    return true
  end
  
  def self.show(*args)
    $scene.spriteset.show_map_cursor(*args)
    return true
  end
  
  def self.move(*args)
    $scene.spriteset.move_map_cursor(*args)
    return true
  end
  
  def self.hide
     $scene.spriteset.hide_map_cursor
    return true
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :map_cursor_type
  alias max_cursor_initialize_later initialize
  def initialize
    max_cursor_initialize_later
    @map_cursor_type = CURSOR::TYPE
  end
end

#===============================================================================
# Sprite_Map_Cursor
#===============================================================================

class Sprite_Map_Cursor
  attr_accessor :x
  attr_accessor :y
  attr_accessor :duration
  attr_reader   :width
  attr_reader   :height
  def initialize
    @width = @height = @count = @duration = @x = @y = 0
    @data = []
  end
  
  def update
    #get the location
    case @data.size
    when 0
      x = $game_player.screen_x - @width
      y = $game_player.screen_y - 16 - @height
    when 1
      x = $game_map.events[@data[0]].screen_x - @width
      y = $game_map.events[@data[0]].screen_y - 16 - @height
    when 2
      x = (@data[0] * 128 - $game_map.display_x + 3) / 4 + 16 - @width
      y = (@data[1] * 128 - $game_map.display_y + 3) / 4 + 16 - @height
    end
    #move to location
    if @duration > 0
      @x = (@x * (@duration - 1) + x) / @duration
      @y = (@y * (@duration - 1) + y) / @duration
      @duration -= 1
    else
      @x, @y = x, y
    end
  end
  
  def show(*args)
    @data = args
    update
  end
  
  def visible=(boolean)
    @sprite.visible = boolean
  end
end

#===============================================================================
# Sprite_Map_Cursor_Classic
#===============================================================================

class Sprite_Map_Cursor_Classic < Sprite_Map_Cursor
  def initialize(viewport)
    super()
    @sprite = Sprite.new(viewport)
    @sprite.z = 1000
    @sprite.bitmap = RPG::Cache.picture(CURSOR::CLASSIC_IMAGE)
    @width = @sprite.bitmap.width / 2
    @height = @sprite.bitmap.height / 2
  end
  
  def dispose
    @sprite.dispose
  end
  
  def update
    super
    @sprite.x = @x
    @sprite.y = @y
  end
end

#===============================================================================
# Sprite_Map_Cursor_Animated
#===============================================================================

class Sprite_Map_Cursor_Animated < Sprite_Map_Cursor
  def initialize(viewport)
    super()
    #create an array for the sprites
    @sprites = []
    #create each sprite
    4.times do
      sprite = Sprite.new(viewport)
      sprite.z = 1000
      sprite.bitmap = RPG::Cache.picture(CURSOR::ANIMATED_IMAGE)
      sprite.color.set(255,255,255,0)
      @sprites << sprite
    end
    @width = @sprites[0].bitmap.width / 2
    @height = @sprites[0].bitmap.height / 2
    @min = CURSOR::MIN_RADIUS
    @max = CURSOR::MAX_RADIUS
    @speed = CURSOR::SPEED
  end

  def dispose
    #dispose all sprites
    @sprites.each{|sprite| sprite.dispose}
  end

  def update
    super
    #update the count
    @count = (@count + @speed) % 360
    #get the sin/cos wave
    sin = Math.sin(@count * Math::PI / 180)
    cos = Math.cos(@count * Math::PI / 180)
    #get the offset
    offset = @min + (@max - @min) / 2 + (@max - @min) / 2 * sin
    #update each sprites offset
    @sprites[0].ox = sin * offset
    @sprites[0].oy = cos * -offset
    @sprites[1].ox = sin * -offset
    @sprites[1].oy = cos * offset
    @sprites[2].ox = cos * offset
    @sprites[2].oy = sin * offset
    @sprites[3].ox = cos * -offset
    @sprites[3].oy = sin * -offset
    #get the alpha
    alpha = (0.5 + sin) * 100
    #apply location and alpha to each sprite
    @sprites.each do |sprite|
      sprite.x = @x
      sprite.y = @y
      sprite.color.alpha = alpha
    end
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  attr_reader :map_cursor
  alias max_cursor_update_later update
  alias max_cursor_dispose_later dispose
  def update
    max_cursor_update_later
    @map_cursor.update unless @map_cursor.nil?
  end
  
  def dispose
    max_cursor_dispose_later
    @map_cursor.dispose unless @map_cursor.nil?
  end
  
  def get_map_cursor
    #returns the cursor based on type
    case $game_system.map_cursor_type
    when 1 then return Sprite_Map_Cursor_Classic.new(@viewport1)
    when 2 then return Sprite_Map_Cursor_Animated.new(@viewport1)
    end
  end
  
  def show_map_cursor(*args)
    #show the map cursor at specified position
    @map_cursor = get_map_cursor if @map_cursor.nil?
    @map_cursor.duration = 0
    @map_cursor.show(*args)
  end
  
  def move_map_cursor(*args)
    #move the map cursor to position
    @map_cursor = get_map_cursor if @map_cursor.nil?
    @map_cursor.duration = args.pop
    @map_cursor.show(*args)
  end
  
  def hide_map_cursor
    #dispose the map cursor if it exists
    unless @map_cursor.nil?
      @map_cursor.dispose
      @map_cursor = nil
    end
  end
  
  def set_invisible_map_cursor
    # Set the cursor invisible if it exists
    unless @map_cursor.nil?
      @map_cursor.visible = false
    end
  end
  
  def set_visible_map_cursor
    # Set the cursor visible if it exists
    unless @map_cursor.nil?
      @map_cursor.visible = true
    end
  end
  
  def change_map_cursor
    return if @map_cursor.nil?
    #get the current information
    x, y, d = @map_cursor.x, @map_cursor.y, @map_cursor.duration
    #swap the cursor
    @map_cursor.dispose
    @map_cursor = get_map_cursor
    #set the old information
    @map_cursor.x, @map_cursor.y, @map_cursor.duration = x, y, d
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  attr_reader :spriteset
end