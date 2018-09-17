#===============================================================================
# ¦ PZE Map Names
#-------------------------------------------------------------------------------
# Displays the name of the map on entry
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.5: 6/1/12
# Thanks to:
# Blizzard - Uses his slice text method
#===============================================================================
#
# Introduction:
# Shows the name of the map upon entry. There are two styles you are able to
# choose from.
# Type 1 = Classic PZE
# Type 2 = Majora's Mask
#
# Instructions:
# To use this script, simply set whether you would like to use this script on
# not in the configuration. You can add the map ID in the configuration to
# denote it doesn't allow the pop up. Or you can use the script call to 
# enable/disable the map name pop up at will.
#
# It automatically prints any text not enclosed in either type of brackets () []
# so you are able to comment or document things in your map names. It also
# automatically splits the text to up to 3 lines if it does not fit in the box
# so no configuration of text is required.
#
# Examples:
# 'Big tree' will output: Big tree
# 'Debug Room (for debugging)' will output: Debug Room
#
# Script calls:
#
# MAP_NAMES.enable
# enables map names
#
# MAP_NAMES.disable
# disables map names
#
# MAP_NAMES.type(TYPE)
# change to TYPE specified
#
# MAP_NAMES.show
#          or
# MAP_NAMES.show(TEXT)
#          or
# MAP_NAMES.show(TEXT 1, TEXT 2)
# force the map name to show with specified TEXT, can be 2 lines if needed but
# don't use two lines in classic mode.
#
#===============================================================================

$pze_map_names = 0.5

module MAP_NAMES
  
#===============================================================================
# Configuration
#===============================================================================
  #state whether you want map names enabled. Can be changed with the call script
  MAP_NAMES = true
  #Type used, 1 = PZE, 2 = Majora's Mask. Can be changed with the call script
  TYPE = 2
  #Y location of map names type 2
  MAP_NAME2_Y = :below_nr_zelda_hud
  #you can state the ID's of maps that never have the pop up here
  NO_MAP_NAME = [23,24,25,26,27,28,29]
#===============================================================================
# End Configuration
#===============================================================================

  def self.enable
    $game_system.map_names = true
    return
  end
  
  def self.disable
    $game_system.map_names = false
    return
  end
  
  def self.type(type)
    $game_system.map_names_type = type
    return
  end
  
  def self.show(text = '', text2 = '', lbl = true)
    $game_temp.map_names_popup = true
    return if text == ''
    if text2 != '' && $game_system.map_names_type == 1
      text2 = ''
    end
    $game_temp.map_names_text = (text2 == '' ? text : [text,text2,lbl])
    return
  end
  
  def self.get_map_name
    #use the specified text if text is set
    if $game_temp.map_names_text != ''
      text = $game_temp.map_names_text
      $game_temp.map_names_text = ''
      return text
    end
    #return if map id is in the no map name array
    return '' if NO_MAP_NAME.include?($game_map.map_id)
    #get the map name
    map_name = $data_map_infos[$game_map.map_id].name.clone
    #remove stuff in brackets
    map_name.slice!(/[\(\[].*[\)\]]/)
    #return the map name
    return map_name
  end
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor :map_names_popup
  attr_accessor :map_names_text
  alias max_mapname_initialize_later initialize
  def initialize
    max_mapname_initialize_later
    #temp variable for resetting the window
    @map_names_popup = MAP_NAMES::MAP_NAMES
    @map_names_text = ''
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :map_names
  attr_accessor :map_names_type
  alias max_mapname_initialize_later initialize
  def initialize
    max_mapname_initialize_later
    #variable for whether pop up is enabled/disabled
    @map_names = MAP_NAMES::MAP_NAMES
    @map_names_type = MAP_NAMES::TYPE
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  alias max_mapname_setup_later setup
  def setup(*args)
    max_mapname_setup_later(*args)
    #reset pop up if changing maps
    $game_temp.map_names_popup = true if $game_system.map_names
  end
end

#===============================================================================
# Bitmap
#===============================================================================

class Bitmap
  #draw map name type 1
  def draw_pze_map_name_type1(map_name)
    if FileTest.exist?('Graphics/Pictures/MapName.png')
      #draw the background
      bitmap = RPG::Cache.picture('MapName')
      blt(0,0,bitmap,bitmap.rect)
    elsif $DEBUG
      raise "The map name background image type 1 could not be found.\n" + 
      'either place it in your Pictures folder or change to type 2'
    end
    #slice the text into seperate lines
    map_name = slice_text(map_name, width - 24)
    #center the text
    space = (3 - map_name.size) * 10
    #print the text
    map_name.each_index do |i| 
      draw_text(12, i * 20 + space - 2, width - 24, 64, map_name[i], 1)
    end
  end
  #this method slices the text into lines
  def slice_text(text, width)
    words = text.split(' ')
    return words if words.size == 1
    result, current_text = [], words.shift
    words.each_index {|i|
    if self.text_size("#{current_text} #{words[i]}").width > width
      result.push(current_text)
      current_text = words[i]
    else
      current_text = "#{current_text} #{words[i]}"
    end
    result.push(current_text) if i >= words.size - 1}
    return result
  end
end

#===============================================================================
# Sprite_Map_Name
#===============================================================================

class Sprite_Map_Name < Sprite
  attr_reader :dispose_me
  def initialize
    super(nil)
    self.z = 10000
    self.opacity = 0
    @count = 0
    @dispose_me = false
  end
end

#===============================================================================
# Sprite_Map_Name_Type1
# - PZE Style
#===============================================================================

class Sprite_Map_Name_Type1 < Sprite_Map_Name
  def initialize
    super
    self.bitmap = Bitmap.new(150,101)
    self.x, self.y = 250, -101
    self.bitmap.font.name = 'P'
    self.bitmap.font.color = Color.new(0,0,0,255)
    @text = MAP_NAMES.get_map_name
    if @text = ''
      @dispose_me = true
      return
    end
    refresh
  end
  
  def dispose
    #dispose the bitmap aswell
    self.bitmap.dispose
    super
  end
  
  def refresh
    #draw the map name/image
    self.bitmap.clear
    self.bitmap.draw_pze_map_name_type1(@text)
  end
  
  def update
    #increment the count
    @count += 1
    #move/fade in
    if @count < 16
      self.x += 15
      self.y += 15
      self.opacity += 20
    #move/fade out
    elsif @count >= 60 && @count < 80
      self.y -= 15
      self.opacity -= 20
    #flag for disposal
    elsif @count >= 80
      @dispose_me = true
    end
  end
end

#===============================================================================
# Sprite_Map_Name_Type2
# - Majora's Mask Style
#===============================================================================

class Sprite_Map_Name_Type2 < Sprite_Map_Name
  def initialize
    super
    self.bitmap = Bitmap.new(640,80)
    #create the content on a seperate sprite
    @content = Sprite_Map_Name_Type2_Content.new
    @lines = @content.text.is_a?(Array)
    if @content.text.is_a?(String) && @content.text == '' 
      @dispose_me = true
      return
    end
    self.x = 0
    if @lines && !@content.text[2]
      self.y = 120
    else
      y = MAP_NAMES::MAP_NAME2_Y
      self.y = (y == :below_nr_zelda_hud) ? $game_temp.max_map_names_y : y
    end
    refresh
  end
  
  def dispose
    #dispose bitmap and contents aswell
    @content.dispose
    self.bitmap.dispose
    super
  end
  
  def refresh
    self.bitmap.clear
    #purple background
    for i in 0...640
      self.bitmap.fill_rect(i,0,1, @lines ? 80 : 48,
      Color.new(i / 640.0 * 180,0,i / 640.0 * 220,255 - i * 255 / 640.0)) 
    end
  end
  
  def update
    #update the content
    @content.update if @count >= 30
    #increment count
    @count += 1
    #fade in
    if @count < 30
      self.opacity += 7
    #fade in content
    elsif @count < @content.time + 45
      self.opacity += 7
      @content.opacity += 14
    #fade out content
    elsif @count >= @content.time + 65 && @count < @content.time + 95
      @content.opacity -= 10
    #fad out 
    elsif @count >= @content.time + 95 && @count < @content.time + 145
      self.opacity -= 10
    #flag for disposal
    elsif @count >= @content.time + 145
      @dispose_me = true
    end
  end
end

#===============================================================================
# Sprite_Map_Name_Type2_Content
#===============================================================================

class Sprite_Map_Name_Type2_Content < Sprite_Map_Name
  attr_reader :text
  attr_reader :time
  def initialize
    super
    self.bitmap = Bitmap.new(608,64)
    @text = MAP_NAMES.get_map_name
    @lines = @text.is_a?(Array)
    @time = @lines ? (@text[0].size + @text[1].size) * 2 : @text.size * 2
    self.x = 16
    if @lines && !@text[2]
      self.y = 128
    else
      y = MAP_NAMES::MAP_NAME2_Y
      self.y = 8 + ((y == :below_nr_zelda_hud) ? $game_temp.max_map_names_y : y)
    end
    self.z = 10001
    @x = 0
    refresh if !@text[2]
  end
  
  def dispose
    #dispose the bitmap aswell
    self.bitmap.dispose
    super
  end
  
  def refresh
    #draw the content text
    if @lines
      if @text[2]
        @x = 0 if @count / 2 == @text[0].size
        if @count / 2 < @text[0].size
          self.bitmap.draw_text(@x, 0, 608, 32, @text[0][@count / 2, 1])
          @x += self.bitmap.text_size(@text[0][@count / 2, 1]).width
        else
          self.bitmap.draw_text(@x, 32, 608, 32, @text[1][@count/2 - @text[0].size,1])
          @x += self.bitmap.text_size(@text[1][@count / 2 - @text[0].size, 1]).width
        end
      else
        self.bitmap.font.color = Color.new(255,255,0)
        self.bitmap.draw_text(128, 0, 608, 32, @text[0])
        self.bitmap.font.color = Color.new(255,0,0)
        self.bitmap.draw_text(128, 32, 608, 32, @text[1])
      end
    else
      self.bitmap.draw_text(@x, 0, 608, 32, @text[@count / 2, 1])
      @x += self.bitmap.text_size(@text[@count / 2, 1]).width
    end
  end
  
  def update
    if @count % 2 == 0 && @text[2]
      if (@lines && @count / 2 < @text[0].size + @text[1].size) || 
         (!@lines && @count / 2 < @text.size)
        refresh
      end
    end
    @count += 1
  end
end
  
#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  alias max_mapname_dispose_later dispose
  alias max_mapname_update_later update
  def dispose
    max_mapname_dispose_later
    #dispose the pop up sprite if it exists
    @map_name.dispose unless @map_name.nil?
  end
  
  def update
    max_mapname_update_later
    #if popping up is activated
    if $game_temp.map_names_popup
      #dispose the sprite if it already exists
      unless @map_name.nil?
        @map_name.dispose
        @map_name = nil
      end
      #set up a new map pop up sprite
      case $game_system.map_names_type
      when 1
        @map_name = Sprite_Map_Name_Type1.new
      when 2
        @map_name = Sprite_Map_Name_Type2.new
      end
      $game_temp.map_names_popup = false
    end
    #if there is a map pop up
    unless @map_name.nil?
      #dispose if flagged for disposal
      if @map_name.dispose_me
        @map_name.dispose
        @map_name = nil
      #else update
      else
        @map_name.update
      end
    end
  end
end

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title
  alias max_mapname_main_later main
  def main
    #load the map info data on start up
    $data_map_infos = load_data("Data/MapInfos.rxdata") if $data_map_info.nil?
    max_mapname_main_later
  end
end