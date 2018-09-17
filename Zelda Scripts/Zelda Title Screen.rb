#===============================================================================
# ¦ PZE Title/Load/Save/Name/Gameover Screens
#-------------------------------------------------------------------------------
# Ocarina of Time/Majora's Mask style Title
# Link to the Past style Gameover
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.3.4: 11/12/11
#===============================================================================
# 
# Introduction:
# This script overides the standard title screen with a Zelda title screen
# simular to the title screens from Ocarina of time and the Majora's Mask.
# The old gameover screen has been updated to use a Link to the Past style
# save and continue/quit style screen. The script also features methods of 
# quicksaving and autosaving.
#
# Instuctions:
# All instructions to set up the title screen are in the configuration.
# 
# Zelda Style Saving:
# In a majority of zelda games, after loading a saved game you will return to
# the entrance of the map or the begginning of the dungeon. To achieve this
# the player coordinates are saved each time you enter a map. When the game
# is saved the player coordinates will be altered in the save file. The
# autosaving of the coordinates can be disabled ie. for dungeons when you want
# the player to return to the entrance, by using the script call:
# PZE.autosave(false), and then PZE.autosave(true) to re-enable it.
#
# After a gameover, and you use the save and continue, you will return to the
# last saved coordinates and your player hp will return to the amount specified
# in the configuration or the call script.
#
# Script Calls:
#
# PZE.save
# Saves the game to the loaded save file.
#
# PZE.load
# Loads the game from the loaded save file.
# 
# PZE.autosave(ENABLED)
# ENABLED can be true or false for enabling/disabling the autosave coordinates.
#
# PZE.gameover_hp(HP)
# HP is the amount of hp you will recieve after a gameover.
#
#===============================================================================

$pze_ztitle = 0.34

module PZE

#===============================================================================
# Configuration
#===============================================================================
  #determine the font used for the title screen
  TITLE_FONT_NAME = 'P'
  TITLE_FONT_SIZE = 22
  #automatically change the hero's name to the same as the file name
  HERO_NAME = false
  #quick start skips the title in debug mode. Useful for debugging
  QUICK_START = true
  #use the full keyboard to input your name. Requires Yan Keyboard Input.
  KEYBOARD_NAME = false
  #Zelda style saving. Read Zelda Style saving in the configuration.
  ZELDASAVE = true
  #Save the player coordinates on map entry. Change with the call script.
  AUTOSAVE = true
  #Zelda style gameover screen
  GAMEOVER = true
  #The amount of HP recieved after gameover. Change with the call script.
  GAMEOVER_HP = 12 #3 hearts
  #enable/disable the quicksave feature
  QUICKSAVE = true
  #quick save input key
  QUICKSAVE_INPUT = Input::F5
  #quick load input key
  QUICKLOAD_INPUT = Input::F6
  #common event that runs at the start of a new game. set to 0 to disable
  COMMON_EVENT = 2
  #-----------------------------------------------------------------------------
  # File Information Display Setup
  #-----------------------------------------------------------------------------
  #Hero
  Hero_Display = true
  Hero_Speed = 5
  Hero_X = -30
  Hero_Y = -30
  #Hearts
  Heart_Display = true
  Heart_Columns = 10 
  Heart_X = 53
  Heart_Y = 42
  #Heart Container Pieces
  Heart_Piece_Display = true
  Heart_Piece_X = 280
  Heart_Piece_Y = 40
  #Magic
  Magic_Display = true
  Magic_Width = 80
  Magic_Color = Color.new(32, 192, 40)
  Magic_X = 200
  Magic_Y = 76
  #Rupees/Gold
  Rupee_Display = true
  Rupee_X = 290
  Rupee_Y = 8
  #-----------------------------------------------------------------------------
  # Custom Information Display Setup
  #-----------------------------------------------------------------------------
  # Custom information setup follows this format:
  # [IMAGE, X, Y, CONDITION, ID],
  # IMAGE is the filename of the image located in the titles folder.
  # X,Y is the location of the image
  # CONDITION can be 'switch', 'variable' or 'item'.
  # ID is the ID of the selected condition
  #
  # EG.['Picture', 6, 9, 'switch', 69]
  #
  # NOTE: Condition can be left as '' to always be shown.
  #
  # NOTE: If the condition is a variable, the amount will be shown next to it.
  # The same will be applied if the condition is an item and there is more then
  # 1 of the item possessed.
  #-----------------------------------------------------------------------------
  Custom_Display = [             #set to Custom_Display = [] if not applicable
  #['QM_Heart_4.4', 280, 40, '', 0],
  #['some picture', 69, 69, 'item', 7]
  ]
#===============================================================================
# End Configuration
#===============================================================================

  def self.save
    return if $game_temp.pze_quickstart
    file = File.open("Save#{$game_system.file_id + 1}.rxdata", 'wb')
    temp_save = Scene_Save.new
    temp_save.write_save_data(file)
    file.close
  end
  
  def self.load
    return if $game_temp.pze_quickstart
    file = File.open("Save#{$game_system.file_id + 1}.rxdata", 'r')
    temp_load = Scene_Load.new
    temp_load.read_save_data(file)
    file.close
    $game_temp.pze_loading = true
    return
  end
  
  def self.autosave(save)
    $game_system.pze_autosave = save
    return
  end
  
  def self.gameover_hp(hp)
    $game_system.pze_gameover_hp = hp
    return
  end
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor :autosave_coordinates
  attr_accessor :pze_quicksaving
  attr_accessor :pze_loading
  attr_accessor :pze_quickstart
  alias max_ztitle_initialize_later initialize unless $@
  def initialize
    max_ztitle_initialize_later
    @autosave_coordinates = []
    @pze_quicksaving = false
    @pze_loading = false
    @pze_quickstart = false
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :file_name
  attr_accessor :file_id
  attr_accessor :pze_autosave
  attr_accessor :pze_gameover_hp
  alias max_ztitle_initialize_later initialize unless $@
  def initialize
    max_ztitle_initialize_later
    @file_name = ''
    @file_id = 0
    @pze_autosave = PZE::AUTOSAVE
    @pze_gameover_hp = PZE::GAMEOVER_HP
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  attr_accessor :map_id
end

#===============================================================================
# Sprite_Zelda_Title
#===============================================================================

class Sprite_Zelda_Title < Sprite
  attr_reader :character_table
  attr_reader :file_name
  def initialize(viewport = nil)
    super(viewport)
    @fade_in = false
    @fade_out = false
    @fade_speed = 0
    @phase = false
    @phase_count = 0
    @move_x = 0
    @move_y = 0
    @move_duration = 0
    self.opacity = 0
    self.color = Color.new(255,255,255,0)
  end
  
  def update
    #update phase
    if @phase
      self.color.alpha += 4 * (@phase_count < 15 ? 1 : -1)
      @phase_count += 1
      @phase_count = 0 if @phase_count == 30
    end
    #update fade in
    if @fade_in
      self.opacity += @fade_speed
      @fade_in = false if self.opacity >= 255
    end
    #update fade out
    if @fade_out
      self.opacity -= @fade_speed
      @fade_out = false if self.opacity <= 0
    end
    #update move
    if @move_duration > 0
      self.x = (self.x * (@move_duration - 1) + @move_x) / @move_duration
      self.y = (self.y * (@move_duration - 1) + @move_y) / @move_duration
      @move_duration -= 1
    end
    #update the actor sprite
    unless @hero.nil?
      #update pattern
      @hero_count += 1
      if @hero_count % PZE::Hero_Speed == 0
        s = PZE::Hero_Speed
        @hero_count = 0 if @hero_count / s == @hero_frames
        @hero.src_rect = Rect.new(@hero_count / s * @hw, 0, @hw, @hh)
      end
    end
  end
  
  def dispose
    #dispose the hero sprite aswell
    unless @hero.nil?
      @hero.dispose 
      @hero = nil
    end
    super
  end
  
  def bitmap=(*args)
    super(*args)
    #set the font on bitmap creation
    self.bitmap.font.name = PZE::TITLE_FONT_NAME
    self.bitmap.font.size = PZE::TITLE_FONT_SIZE
  end
  
  def x=(value)
    super
    #move the hero sprite aswell
    @hero.x = value + PZE::Hero_X unless @hero.nil?
  end
  
  def y=(value)
    super
    #move the hero sprite aswell
    @hero.y = value + PZE::Hero_Y unless @hero.nil?
  end
  
  def opacity=(value)
    super
    #set the hero opacity to the bitmap opacity
    @hero.opacity = value unless @hero.nil?
  end
  
  def phase=(bool)
    #enable/disable the phase
    @phase = bool
    #adjust the phase count to about the middle
    @phase_count = 7
    #adjust alpha level
    self.color.alpha = (@phase ? 30 : 0)
  end
  
  def fade_in(speed)
    #fade the sprite in at specified speed
    @fade_in = true
    @fade_speed = speed
  end
  
  def fade_out(speed = nil)
    #return true if the sprite is fading out
    return @fade_out if speed.nil?
    #fade the sprite out at specified speed
    @fade_out = true
    @fade_speed = speed
  end
  
  def move_to(x, y, speed)
    #set the move to coordinates
    @move_x = x
    @move_y = y
    #set the duration of the move
    @move_duration = speed
  end
  
  def draw_bar(text)
    #draw a bar with text for the menu options
    self.bitmap = Bitmap.new(130,33)
    bar = RPG::Cache.title('ZBar')
    self.bitmap.blt(0,0,bar,bar.rect)
    self.bitmap.draw_text(0,0,130,33,text,1)
  end
  
  def draw_info(text, align = 0)
    #draw information text
    self.bitmap = Bitmap.new(640,32) if self.bitmap.nil?
    self.bitmap.clear
    self.bitmap.draw_text(0,0,640,32,text,align)
  end
  
  def draw_link
    #draw a file link
    self.bitmap = RPG::Cache.title('ZFile_Link')
  end
  
  def draw_cursor
    #draw a name input cursor
    self.bitmap = RPG::Cache.title('ZCursor')
    self.phase = true
    self.opacity = 200
  end
  
  def draw_back
    #draw a name input back key
    self.bitmap = RPG::Cache.title('ZBack')
  end
  
  def draw_end
    #draw a name input end key
    self.bitmap = Bitmap.new(91,33)
    bitmap = RPG::Cache.title('ZEnd')
    self.bitmap.blt(0,0,bitmap,bitmap.rect)
    self.bitmap.draw_text(0,0,91,33,'END',1)
  end
  
  def draw_character_table
    #draw a name input character table
    self.bitmap = Bitmap.new(455, 175)
    @character_table =
    ['A','B','C','D','E','F','G','H','I','J','K','L','M',
     'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
     'a','b','c','d','e','f','g','h','i','j','k','l','m',
     'n','o','p','q','r','s','t','u','v','w','x','y','z',
     '1','2','3','4','5','6','7','8','9','0','.','-',' ']
    @character_table.each_with_index do |char, i|
      self.bitmap.draw_text((i % 13) * 35, (i / 13) * 35, 35, 35, char)
    end
  end
  
  def draw_name(text = '')
    #draw a name bar
    self.bitmap = Bitmap.new(219,33) if self.bitmap.nil?
    self.bitmap.clear
    bitmap = RPG::Cache.title('ZName')
    self.bitmap.blt(0,0,bitmap,bitmap.rect)
    self.bitmap.draw_text(34,0,185,33,text)
  end
  
  def draw_display(i)
    #draw a file information display
    self.bitmap = Bitmap.new(350,101) if self.bitmap.nil?
    self.bitmap.clear
    display = RPG::Cache.title('ZDisplay')
    self.bitmap.blt(0,0,display,display.rect)
    #load temp file data
    file = File.open("Save#{i + 1}.rxdata", 'r')
    characters = Marshal.load(file)
    frame_count = Marshal.load(file)
    system = Marshal.load(file)
    switches = Marshal.load(file)
    variables = Marshal.load(file)
    self_switches = Marshal.load(file)
    screen = Marshal.load(file)
    actors = Marshal.load(file)
    party = Marshal.load(file)
    file.close
    #get the file name for the name window
    @file_name = system.file_name
    self.bitmap.draw_text(164,0,185,33,@file_name)
    #rupees/gold display
    if PZE::Rupee_Display
      bitmap = RPG::Cache.title('ZRupee')
      x, y = PZE::Rupee_X, PZE::Rupee_Y
      self.bitmap.blt(x,y,bitmap,bitmap.rect)
      self.bitmap.draw_text(x + bitmap.rect.width + 4,
      y, 350, PZE::TITLE_FONT_SIZE, 'x ')
      old_color = self.bitmap.font.color.clone
      #change font color to green if rupee count has reached the maximum
      if defined?(ZeldaHUD_Customization) &&
         party.gold == variables[ZeldaHUD_Customization::GoldCapVariable] &&
         party.gold != 0
        self.bitmap.font.color = Color.new(50,255,50)
      end
      self.bitmap.draw_text(x + bitmap.rect.width + 4 + bitmap.text_size(
      'x ').width, y, 350, PZE::TITLE_FONT_SIZE, party.gold.to_s)
      self.bitmap.font.color = old_color
    end
    #Custom display images
    PZE::Custom_Display.each do |info|
      next if info[3] == 'switch' && !switches[info[4]]
      next if info[3] == 'item' && party.item_number(info[4]) == 0
      bitmap = RPG::Cache.title(info[0])
      self.bitmap.blt(info[1],info[2],bitmap,bitmap.rect)
      if info[3] == 'variable'
        self.bitmap.draw_text(info[1] + bitmap.rect.width + 4,
        info[2], 350, PZE::TITLE_FONT_SIZE, 'x ' + variables[info[4]].to_s)
      elsif info[3] == 'item'
        value = party.item_number(info[4])
        if value > 1
          self.bitmap.draw_text(info[1] + bitmap.rect.width + 4,
          info[2], 350, PZE::TITLE_FONT_SIZE, 'x ' + value.to_s)
        end
      end
    end
    #get the hero
    hero = party.actors[0]
    #skip drawing hero stats if the hero does not exist
    return if hero.nil?
    #hero display
    if PZE::Hero_Display
      #draw the hero sprite
      @hero = Sprite.new
      @hero.bitmap = RPG::Cache.character(
                     hero.character_name, hero.character_hue)
      @hero_count = 0
      @hero.opacity = 0
      @hero.z = 3
      #compatibility with COG extra frames
      if defined?(COG_ExtraFrames)
        hero.character_name[/\[(\d+)\]$/]
        @hero_frames = $1.nil? ? 4 : $1.to_i
      else
        @hero_frames = 4
      end
      #set the source rect dependant on bitmap width/height
      @hw, @hh = @hero.bitmap.width / @hero_frames, @hero.bitmap.height / 4
      @hero.src_rect = Rect.new(0, 0, @hw, @hh)
    end
    #hearts display
    if PZE::Heart_Display
      bitmap = RPG::Cache.title('ZHearts_List')
      x, y, c = PZE::Heart_X, PZE::Heart_Y, PZE::Heart_Columns
      (0...(hero.maxhp / 4)).each do |i|
        self.bitmap.blt(i % c * 17 + x, i / c * 17 + y, bitmap, Rect.new([[
        hero.hp % 4 + (hero.hp / 4 - i) * 4, 0].max, 4].min * 16, 0, 16, 16))
      end
    end
    #heart container piece display
    if PZE::Heart_Piece_Display
      bitmap = RPG::Cache.title('ZHeart_Container_Pieces_List')
      x, y = PZE::Heart_Piece_X, PZE::Heart_Piece_Y
      self.bitmap.blt(x, y, bitmap, Rect.new(52 * (hero.maxhp % 4), 0, 52, 48))
    end
    #magic display
    if PZE::Magic_Display
      bitmap = RPG::Cache.title('ZMagic_Bar_List')
      x, y, width = PZE::Magic_X, PZE::Magic_Y, PZE::Magic_Width
      self.bitmap.blt(x, y, bitmap, Rect.new(0,0,4,21))
      dest_rec = Rect.new(x + 4, y, width - 8, 21) 
      self.bitmap.stretch_blt(dest_rec, bitmap, Rect.new(4, 0, 1, 21))
      self.bitmap.blt(x + width - 4, y, bitmap, Rect.new(5, 0, 4, 21))
      rate = hero.sp / hero.maxsp
      self.bitmap.fill_rect(x + 4, y + 4,(width - 8) * rate,13,PZE::Magic_Color)
    end
  end
end

#===============================================================================
# Sprite_Quick_Save_Load
#===============================================================================

class Sprite_Quick_Save_Load < Sprite
  attr_reader :count
  def initialize(text)
    super(nil)
    self.bitmap = Bitmap.new(300,32)
    self.bitmap.draw_text(0,0,300,32,text)
    self.x, self.y, self.z = 0, 448, 99999
    @count = 0
  end
  
  def dispose
    #dispose the bitmap aswell
    self.bitmap.dispose
    super
  end
  
  def update
    #update the count
    @count += 1
  end
end

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title
  def main
    #go to battle test if battle testing
    if $BTEST
      battle_test
      return
    end
    #load the data
    $data_actors        = load_data('Data/Actors.rxdata')
    $data_classes       = load_data('Data/Classes.rxdata')
    $data_skills        = load_data('Data/Skills.rxdata')
    $data_items         = load_data('Data/Items.rxdata')
    $data_weapons       = load_data('Data/Weapons.rxdata')
    $data_armors        = load_data('Data/Armors.rxdata')
    $data_enemies       = load_data('Data/Enemies.rxdata')
    $data_troops        = load_data('Data/Troops.rxdata')
    $data_states        = load_data('Data/States.rxdata')
    $data_animations    = load_data('Data/Animations.rxdata')
    $data_tilesets      = load_data('Data/Tilesets.rxdata')
    $data_common_events = load_data('Data/CommonEvents.rxdata')
    $data_system        = load_data('Data/System.rxdata')
    #quick start if activated
    if PZE::QUICK_START && $DEBUG
      quick_start
      return
    end
    #create the game system
    $game_system = Game_System.new
    #stop audio and play the title bgm
    Audio.me_stop
    Audio.bgs_stop
    $game_system.bgm_play($data_system.title_bgm)
    #initialize variables
    @scene = 1
    @index = 0
    @file = 0
    @ce = true #true = copy, false = erase
    @copy_to = 0
    @text = ''
    #make the sprites
    make_sprites
    #array for holding the active sprites
    @sprites = [@window,@copy,@erase,@options,@info,@keys,*@files]
    #transition
    Graphics.transition
    #fade in
    wait(25, true)
    #change active sprites
    @sprites = [@copy,@erase,@options,*@files]
    #phase first file
    @files[0].phase = true
    #main loop
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    #freeze
    Graphics.freeze
    #dispose everything
    dispose_sprites
  end
  
  def make_sprites
    #background
    @background = Plane.new
    @background.bitmap = RPG::Cache.title('ZBackground')
    #window
    @window = Sprite_Zelda_Title.new
    @window.bitmap = RPG::Cache.title('ZWindow')
    #files, names, links and displays
    @files = []
    @names = {}
    @links = {}
    @displays = {}
    (0..2).each do |i|
      #files
      @files[i] = Sprite_Zelda_Title.new
      @files[i].draw_bar("File #{i + 1}")
      @files[i].x, @files[i].y = 124, 148 + i * 33
      #if the file exists
      if FileTest.exist?("Save#{i + 1}.rxdata")
        #displays
        @displays[i] = Sprite_Zelda_Title.new
        @displays[i].draw_display(i)
        @displays[i].x, @displays[i].y, @displays[i].z = 124, 148, 1
        #names
        @names[i] = Sprite_Zelda_Title.new
        @names[i].draw_name(@displays[i].file_name)
        @names[i].x, @names[i].y = @files[i].x + 130, @files[i].y
        #links
        @links[i] = Sprite_Zelda_Title.new
        @links[i].draw_link
        @links[i].x, @links[i].y = @files[i].x + 110, @files[i].y + 9
        @links[i].z = 2
      end
    end
    #copy
    @copy = Sprite_Zelda_Title.new
    @copy.draw_bar('Copy')
    @copy.x, @copy.y = 124, 264
    #erase
    @erase = Sprite_Zelda_Title.new
    @erase.draw_bar('Erase')
    @erase.x, @erase.y = 124, 297
    #options
    @options = Sprite_Zelda_Title.new
    @options.draw_bar('Options')
    @options.x, @options.y = 124, 347
    #yes
    @yes = Sprite_Zelda_Title.new
    @yes.draw_bar('Yes')
    @yes.x, @yes.y = 124, 314
    #quit
    @quit = Sprite_Zelda_Title.new
    @quit.draw_bar('Quit')
    @quit.x, @quit.y = 124, 347
    #info
    @info = Sprite_Zelda_Title.new
    @info.draw_info('Please Select a File')
    @info.x, @info.y = 125, 91
    #keys
    @keys = Sprite_Zelda_Title.new
    @keys.draw_info('C - Decide · X - Cancel', 1)
    @keys.y = 423
    #name
    @name = Sprite_Zelda_Title.new
    @name.draw_name
    #message
    @message = Sprite_Zelda_Title.new
    @message.draw_info('This is an Empty File')
    @message.x, @message.z = 260, 10
    #character table
    @table = Sprite_Zelda_Title.new
    @table.draw_character_table
    @table.x, @table.y, @table.z = 124, 148, 100
    #back
    @back = Sprite_Zelda_Title.new
    @back.draw_back
    @back.x, @back.y, @back.z = 398, 328, 100
    #end
    @end = Sprite_Zelda_Title.new
    @end.draw_end
    @end.x, @end.y, @end.z = 468, 328, 100
  end
  
  def dispose_sprites
    #background
    @background.dispose
    #window
    @window.dispose
    #files
    @files.each do |file|
      file.bitmap.dispose
      file.dispose
    end
    #names
    @names.each_value do |name|
      name.bitmap.dispose
      name.dispose
    end
    #displays
    @displays.each_value do |display| 
      display.bitmap.dispose
      display.dispose
    end
    #links
    @links.each_value {|link| link.dispose}
    #bar and info windows
    [@copy,@erase,@options,@yes,@quit,@info,@keys,@message,@table,
     @end].each do |sprite| 
      sprite.bitmap.dispose
      sprite.dispose
    end
    #back
    @back.dispose
  end
  
  def quick_start
    #reset all objects and go straight to the map
    Graphics.frame_count = 0
    $game_temp          = Game_Temp.new
    $game_temp.pze_quickstart = true
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    command_new_game
  end
  
  def wait(frames, fade = nil)
    #fade in/out if specified
    @sprites.each{|sprite| sprite.fade_in(255 / frames)} if fade
    @sprites.each{|sprite| sprite.fade_out(255 / frames)} if fade == false
    #wait for each frame
    (frames + 1).times do
      Graphics.update
      update_sprites
    end
  end
  
  def update
    update_sprites
    case @scene
    when 1 #main
      update_main
    when 2 #select
      update_select
    when 3 #name
      update_name
    when 4 #copy/erase which
      update_copy_erase
    when 5 #copy to
      update_copy_to
    when 6 #are you sure
      update_are_you_sure
    when 7 #options
      update_options
    end
  end
  
  def update_sprites
    #pan the background
    @background.ox -= 1
    #update the sprites
    @sprites.each {|sprite| sprite.update}
    #move links/names to the relative file position
    @links.each do |i, link|
      next if link.fade_out
      link.x, link.y = @files[i].x + 102, @files[i].y + 6
      link.opacity = @files[i].opacity
    end
    @names.each do |i, name|
      name.x, name.y = @files[i].x + 130, @files[i].y
      name.opacity = @files[i].opacity
    end
  end
  #-----------------------------------------------------------------------------
  # Main
  #-----------------------------------------------------------------------------
  def update_main
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      case @index
      when 0,1,2
        @names[@index].nil? ? main_name_transition : main_select_transition
      when 3,4
        @ce = @index == 3 ? true : false
        main_copy_erase_transition
      when 5
        main_options_transition
      end
    elsif Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
    elsif Input.repeat?(Input::DOWN)
      @index += 1
      @index = 0 if @index == 6
      update_main_index
    elsif Input.repeat?(Input::UP)
      @index -= 1
      @index = 5 if @index == -1
      update_main_index
    end
  end
  
  def update_main_index
    $game_system.se_play($data_system.cursor_se)
    @sprites.each {|sprite| sprite.phase = false}
    case @index
    when 0,1,2
      @files[@index].phase = true
    when 3
      @copy.phase = true
    when 4
      @erase.phase = true
    when 5
      @options.phase = true
    end
  end
  
  def main_select_transition
    @file = @index
    @files[@index].phase = false
    @sprites = [@copy,@erase,@options,@files[(@index+1)%3],@files[(@index+2)%3]]
    wait(10, false)
    @info.draw_info('Open this file?')
    @files[@index].move_to(124,148,10)
    @sprites = [@files[@index],@displays[@index],@yes,@quit]
    wait(10, true)
    @sprites = [@yes,@quit,@displays[@index]]
    @yes.phase = true
    @scene = 2
    @index = 0
  end
  
  def main_name_transition
    @file = @index
    @files[@index].phase = false
    @sprites = [@copy,@erase,@options,*@files]
    wait(10, false)
    @info.draw_info('Name?')
    @name.x, @name.y = 480, 91
    @name.move_to(200,91,10)
    @sprites = [@name,@table,@end,@back]
    wait(10, true)
    if PZE::KEYBOARD_NAME
      @keys.draw_info('Enter - Accept · Esc - Quit', 1)
      @keyboard = Sprite_Zelda_Title.new
      @keyboard.draw_info('Type your name using the keyboard', 1)
      @keyboard.y, @keyboard.opacity = 26, 255
    else
      @letter_cursor = Sprite_Zelda_Title.new
      @letter_cursor.draw_cursor
      @letter_cursor.x, @letter_cursor.y = 100, 136
    end
    @name_cursor = Sprite_Zelda_Title.new
    @name_cursor.draw_cursor
    @name_cursor.x, @name_cursor.y = 210, 78
    @scene = 3
    @index = 0
  end
  
  def main_copy_erase_transition
    @sprites.each{|sprite| sprite.phase = false}
    @sprites = [@copy,@erase,@options]
    wait(10, false)
    @info.draw_info((@ce ? 'Copy' : 'Erase') + ' which file?')
    @message.draw_info('This is an Empty File')
    @files.each_with_index {|file, i| file.move_to(124, 248 + i * 33, 10)}
    @message.visible = false
    @sprites = [@quit,@message,*@files]
    wait(10, true)
    @quit.phase = true
    @scene = 4
    @index = 3
  end
  
  def main_options_transition
    @sprites.each{|sprite| sprite.phase = false}
    wait(10, false)
    @info.draw_info('Options')
    @scene = 7
  end
  #-----------------------------------------------------------------------------
  # Select
  #-----------------------------------------------------------------------------
  def update_select
    if Input.trigger?(Input::C)
      case @index
      when 0
        load_game
      when 1
        select_main_transition
      end
    elsif Input.trigger?(Input::B)
      select_main_transition
    elsif Input.repeat?(Input::DOWN) || Input.repeat?(Input::UP)
      @index = (@index == 0 ? 1 : 0)
      update_select_index
    end
  end
  
  def update_select_index
    #play the cursor sound effect
    $game_system.se_play($data_system.cursor_se)
    #phase the selected index
    @sprites.each {|sprite| sprite.phase = false}
    case @index
    when 0
      @yes.phase = true
    when 1
      @quit.phase = true
    end
  end
  
  def load_game
    Audio.se_play('Audio/SE/Title Screen - Press Start', 100) #####
    file = File.open("Save#{@file + 1}.rxdata", 'rb')
    temp_load = Scene_Load.new
    temp_load.read_save_data(file)
    file.close
    if Graphics.frame_count <= 2
      #start a new game
      command_new_game
    else
      #load game
      $game_system.bgm_play($game_system.playing_bgm)
      $game_system.bgs_play($game_system.playing_bgs)
      $game_map.update
      $scene = Scene_Map.new
      if PZE::HERO_NAME
        $data_actors[$game_party.actors[0].id].name = $game_system.file_name
      end
    end
    #setup initial autosave coordinates
    $game_temp.autosave_coordinates = [$game_map.map_id, $game_player.x,
    $game_player.y, $game_player.direction]
  end
  
  def command_new_game
    #create the startup common event
    $game_temp.common_event_id = PZE::COMMON_EVENT
    #setup starting data
    $game_party.setup_starting_members
    $game_map.setup($data_system.start_map_id)
    if PZE::HERO_NAME && $game_party.actors[0] != nil
      $game_party.actors[0].name = $game_system.file_name
      $data_actors[$game_party.actors[0].id].name = $game_system.file_name
    end
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $game_map.autoplay
    $game_map.update
    $game_system.map_interpreter.update if PZE::COMMON_EVENT != 0
    $scene = Scene_Map.new
  end
  
  def select_main_transition
    $game_system.se_play($data_system.cancel_se)
    @sprites.each {|sprite| sprite.phase = false}
    @sprites = [@displays[@file],@yes,@quit]
    wait(10, false)
    @info.draw_info('Please Select a File')
    @files[@file].move_to(124, 148 + @file * 33, 10)
    @sprites = [@erase,@copy,@options,*@files]
    wait(10, true)
    @files[@file].phase = true
    @index = @file
    @scene = 1
  end
  #-----------------------------------------------------------------------------
  # Name Entry
  #-----------------------------------------------------------------------------
  def update_name
    @name_cursor.update
    if PZE::KEYBOARD_NAME
      if Input.repeat?(Input::BACK)
        $game_system.se_play($data_system.cancel_se)
        return if @text == ''
        @text = @text[0,@text.size - 1] 
        @name.draw_name(@text)
        update_name_index
      elsif Input.trigger?(Input::ESC)
        $game_system.se_play($data_system.cancel_se)
        name_main_transition
      elsif Input.trigger?(Input::ENTER)
        if @text == ''
          $game_system.se_play($data_system.cancel_se)
          name_main_transition
        else
          new_file
        end
      elsif Input.typing?
        if @name.bitmap.text_size(@text).width >= 170
          $game_system.se_play($data_system.cancel_se)
        else
          $game_system.se_play($data_system.cursor_se)
          @text += Input.key_type
          @name.draw_name(@text)
          update_name_index
        end
      end
    else
      @letter_cursor.update
      if Input.repeat?(Input::C)
        case @index
        when 73, 74 #back
          $game_system.se_play($data_system.cancel_se)
          return if @text == ''
          @text = @text[0,@text.size - 1] 
          @name.draw_name(@text)
          update_name_index
        when 75, 76, 77 #end
          if @text == ''
            $game_system.se_play($data_system.cancel_se)
            name_main_transition
          else
            new_file
          end
        else #text
          if @name.bitmap.text_size(@text).width >= 170
            $game_system.se_play($data_system.cancel_se)
          else
            $game_system.se_play($data_system.decision_se)
            @text += @table.character_table[@index]
            @name.draw_name(@text)
            update_name_index
          end
        end
      elsif Input.repeat?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        if @text == ''
          name_main_transition
        else
          @text = @text[0,@text.size - 1] 
          @name.draw_name(@text)
          update_name_index
        end
      elsif Input.repeat?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        if @index > 59
          @index / 13 == 5 ? @index -= 65 : @index += 13
        else
          @index / 13 == 4 ? @index -= 52 : @index += 13
        end
        update_name_index
      elsif Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        if (@index > 7 && @index < 13) || @index > 72
          @index / 13 == 0 ? @index += 65  : @index -= 13
        else
          @index / 13 == 0 ? @index += 52  : @index -= 13
        end
        update_name_index
      elsif Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        if @index > 74
          @index = 74
        elsif @index > 72
          @index = 75
        else
          @index % 13 == 0 ? @index += 12 : @index -= 1
        end
        update_name_index
      elsif Input.repeat?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        if @index > 74
          @index = 74
        elsif @index > 72
          @index = 75
        else
          @index % 13 == 12 ? @index -= 12 : @index += 1
        end
        update_name_index
      end
    end
  end
  
  def update_name_index
    unless PZE::KEYBOARD_NAME
      @letter_cursor.x = 100 + (@index % 13) * 35
      @letter_cursor.y = 136 + (@index / 13) * 35
    end
    size = @name.bitmap.text_size(@text).width
    @name_cursor.x = 210 + size if size < 170
    @sprites.each {|sprite| sprite.phase = false}
    case @index
    when 73, 74 #back
      @back.phase = true
      @letter_cursor.visible = false unless PZE::KEYBOARD_NAME
    when 75, 76, 77 #end
      @end.phase = true
      @letter_cursor.visible = false unless PZE::KEYBOARD_NAME
    else #text
      @letter_cursor.visible = true unless PZE::KEYBOARD_NAME
    end
  end
  
  def new_file
    $game_system.se_play($data_system.decision_se)
    #reset globals
    Graphics.frame_count = 0
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_system.file_name = @text
    $game_system.file_id = @file
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    #setup starting data
    $game_party.setup_starting_members
    if PZE::HERO_NAME && $game_party.actors[0] != nil
      $game_party.actors[0].name = $game_system.file_name
      $data_actors[$game_party.actors[0].id].name = $game_system.file_name
    end
    $game_map.setup($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    #open the file
    file = File.open("Save#{@file + 1}.rxdata", 'wb')
    #create a temp save scene and write the save data
    temp_save = Scene_Save.new
    temp_save.write_save_data(file)
    #close the file
    file.close
    #create the name, display and link
    @names[@file] = Sprite_Zelda_Title.new
    @names[@file].draw_name(@text)
    @displays[@file] = Sprite_Zelda_Title.new
    @displays[@file].draw_display(@file)
    @displays[@file].x, @displays[@file].y, @displays[@file].z = 124, 148, 1
    @links[@file] = Sprite_Zelda_Title.new
    @links[@file].draw_link
    @links[@file].z = 2
    #transfer to main menu
    name_main_transition
  end
  
  def name_main_transition
    @sprites.each {|sprite| sprite.phase = false}
    unless PZE::KEYBOARD_NAME
      @letter_cursor.dispose 
      @letter_cursor = nil
    end
    @name_cursor.dispose
    @name_cursor = nil
    wait(10, false)
    if PZE::KEYBOARD_NAME
      @keys.draw_info('C - Decide · X - Cancel', 1)
      @keyboard.dispose
      @keyboard = nil
    end
    @info.draw_info('Please Select a File')
    @text = ''
    @name.draw_name
    @sprites = [@copy,@erase,@options,*@files]
    wait(10, true)
    @files[@file].phase = true
    @index = @file
    @scene = 1
  end
  #-----------------------------------------------------------------------------
  # Copy/Erase
  #-----------------------------------------------------------------------------
  def update_copy_erase
    if Input.trigger?(Input::C)
      case @index
      when 0,1,2
        if FileTest.exist?("Save#{@index + 1}.rxdata")
          $game_system.se_play($data_system.decision_se)
          @ce ? copy_copy_to_transition : erase_are_you_sure_transition
        else
          $game_system.se_play($data_system.buzzer_se)
        end
      when 3
        copy_erase_main_transition
      end
    elsif Input.trigger?(Input::B)
      copy_erase_main_transition
    elsif Input.repeat?(Input::DOWN)
      @index += 1
      @index = 0 if @index == 4
      update_copy_erase_index
    elsif Input.repeat?(Input::UP)
      @index -= 1
      @index = 3 if @index == -1
      update_copy_erase_index
    end
  end
  
  def update_copy_erase_index
    #play the cursor sound effect
    $game_system.se_play($data_system.cursor_se)
    #phase the selected index
    @sprites.each {|sprite| sprite.phase = false}
    case @index
    when 0,1,2
      @files[@index].phase = true
      if FileTest.exist?("Save#{@index + 1}.rxdata")
        @message.y = (@index - (@index < @file ? 0 : 1)) * 33 + 281
        @message.visible = (@scene == 4 ? false : true)
      else
        @message.y = @index * 33 + 248
        @message.visible = (@scene == 4 ? true : false)
      end
    when 3
      @message.visible = false
      @quit.phase = true
    end
  end
  
  def copy_erase_main_transition
    $game_system.se_play($data_system.cancel_se)
    @sprites.each {|sprite| sprite.phase = false}
    @message.visible = false
    @sprites = [@quit,@message]
    wait(10, false)
    @info.draw_info('Please Select a File')
    @files.each_with_index{|file, i| file.move_to(124, 148 + i * 33, 10)}
    @sprites = [@erase,@copy,@options,*@files]
    wait(10, true)
    @ce ? @copy.phase = true : @erase.phase = true
    @index = @ce ? 3 : 4
    @scene = 1
  end
  
  def copy_copy_to_transition
    @file = @index
    @sprites.each {|sprite| sprite.phase = false}
    @message.visible = false
    @files[@index].move_to(124, 148, 10)
    @files[0].move_to(124, 281, 10) if @index > 0
    @files[1].move_to(124, 314, 10) if @index > 1
    @sprites = [@quit,@displays[@index],*@files]
    wait(10, true)
    @info.draw_info('Copy to which file?')
    @message.draw_info('This file is in use')
    @quit.phase = true
    @index = 3
    @scene = 5
  end
  
  def erase_are_you_sure_transition
    @file = @index
    @sprites.each {|sprite| sprite.phase = false}
    @message.visible = false
    @sprites = [@files[(@index+1)%3],@files[(@index+2)%3]]
    wait(10, false)
    @info.draw_info('Are you sure?')
    @files[@index].move_to(124, 148, 10)
    @sprites = [@yes,@displays[@file],@files[@file]]
    wait(10, true)
    @sprites = [@yes,@quit,@displays[@file]]
    @quit.phase = true
    @index = 1
    @scene = 6
  end
  #-----------------------------------------------------------------------------
  # Copy to
  #-----------------------------------------------------------------------------
  def update_copy_to
    if Input.trigger?(Input::C)
      case @index
      when 0,1,2
        if FileTest.exist?("Save#{@index + 1}.rxdata")
          $game_system.se_play($data_system.buzzer_se)
        else
          $game_system.se_play($data_system.decision_se)
          copy_to_are_you_sure_transition
        end
      when 3
        copy_to_copy_transition
      end
    elsif Input.trigger?(Input::B)
      copy_to_copy_transition
    elsif Input.repeat?(Input::DOWN)
      loop do
        @index += 1
        @index = 0 if @index == 4
        break if @index != @file
      end
      update_copy_erase_index
    elsif Input.repeat?(Input::UP)
      loop do
        @index -= 1
        @index = 3 if @index == -1
        break if @index != @file
      end
      update_copy_erase_index
    end
  end
  
  def copy_to_copy_transition
    $game_system.se_play($data_system.cancel_se)
    @sprites.each {|sprite| sprite.phase = false}
    @message.visible = false
    @sprites = [@displays[@file],@yes]
    wait(10, false)
    @info.draw_info((@ce ? 'Copy' : 'Erase') + ' which file?')
    @message.draw_info('This is an Empty File')
    @files.each_with_index {|file, i| file.move_to(124, 248 + i * 33, 10)}
    @sprites = [@quit,*@files]
    wait(10, true)
    @quit.phase = true
    @index = 3
    @scene = 4
  end
  
  def copy_to_are_you_sure_transition
    @copy_to = @index
    @sprites.each {|sprite| sprite.phase = false}
    @message.visible = false
    @sprites = [@files[3 - (@file + @copy_to)]]
    wait(10, false)
    @info.draw_info('Are you sure?')
    @message.draw_info('This is an Empty File')
    @files[@index].move_to(124,249,10)
    @sprites = [@files[@copy_to],@yes,@quit]
    wait(10, true)
    @sprites = [@displays[@file],@yes,@quit]
    @quit.phase = true
    @index = 1
    @scene = 6
  end
  #-----------------------------------------------------------------------------
  # Are You Sure?
  #-----------------------------------------------------------------------------
  def update_are_you_sure
    if Input.trigger?(Input::C)
      case @index
      when 0
        $game_system.se_play($data_system.decision_se)
        @ce ? copy_file : erase_file
      when 1
        @ce ? are_you_sure_copy_to_transition : copy_to_copy_transition
      end
    elsif Input.trigger?(Input::B)
      @ce ? are_you_sure_copy_to_transition : copy_to_copy_transition
    elsif Input.repeat?(Input::DOWN) || Input.repeat?(Input::UP)
      @index = (@index == 0 ? 1 : 0)
      update_select_index
    end
  end
  
  def copy_file
    @sprites.each {|sprite| sprite.phase = false}
    Audio.se_play('Audio/SE/System - Load Screen - Copy File', 100) ##
    [@yes,@quit].each{|sprite| sprite.fade_out(255 / 10)}
    @sprites = [@displays[@file],@yes,@quit]
    wait(10)
    @displays[@copy_to] = Sprite_Zelda_Title.new
    @displays[@copy_to].draw_display(@file)
    @displays[@copy_to].x, @displays[@copy_to].y = 124, 249
    @displays[@copy_to].z = 1
    @names[@copy_to] = Sprite_Zelda_Title.new
    @names[@copy_to].draw_name(@displays[@file].file_name)
    @names[@copy_to].x, @names[@copy_to].y = 154, 249
    @links[@copy_to] = Sprite_Zelda_Title.new
    @links[@copy_to].draw_link
    @links[@copy_to].x, @links[@copy_to].y = 134, 258
    @links[@copy_to].z = 2
    @sprites = [@displays[@file],@displays[@copy_to]]
    wait(10, true)
    @sprites = [@displays[@file],@displays[@copy_to],@links[@copy_to]]
    wait(10, true)
    file = File.open("Save#{@file + 1}.rxdata",'rb')
    copy = File.open("Save#{@copy_to + 1}.rxdata",'wb')
    copy.write(file.read)
    file.close
    copy.close
    wait(20)
    @sprites = [@displays[@file],@displays[@copy_to]]
    wait(10,false)
    @info.draw_info('Please Select a File')
    @files.each_with_index{|file, i| file.move_to(124,148 + i * 33,10)}
    @sprites = [@copy,@erase,@options,*@files]
    wait(10,true)
    @displays[@copy_to].y = 148
    @files[0].phase = true
    @index = 0
    @scene = 1
  end
  
  def erase_file
    @sprites.each {|sprite| sprite.phase = false}
    Audio.se_play('Audio/SE/System - Load Screen - Erase File', 100) ########
    @sprites = [@yes,@quit,@links[@file]]
    wait(10,false)
    @links[@file].dispose
    @links.delete(@file)
    @names[@file].dispose
    @names.delete(@file)
    @info.draw_info('File erased')
    @displays[@file].move_to(124,480,10)
    @sprites = [@displays[@file],@files[(@file+1)%3],@files[(@file+2)%3]]
    wait(10,false)
    @displays[@file].dispose
    @displays.delete(@file)
    File.delete("Save#{@file + 1}.rxdata") 
    wait(20)
    @info.draw_info('Please Select a File')
    @files.each_with_index{|file, i| file.move_to(124,148 + i * 33,10)}
    @sprites = [@copy,@erase,@options,*@files]
    wait(10,true)
    @files[0].phase = true
    @index = 0
    @scene = 1
  end
  
  def are_you_sure_copy_to_transition
    $game_system.se_play($data_system.cancel_se)
    @sprites.each {|sprite| sprite.phase = false}
    @sprites = [@yes]
    wait(10, false)
    @info.draw_info('Copy to which file?')
    @message.draw_info('This file is in use')
    y = 281 + ((3 - (@file + @copy_to)) < @copy_to ? 33 : 0)
    @files[@copy_to].move_to(124, y, 10)
    @sprites = [@displays[@file],@quit,*@files]
    wait(10, true)
    @quit.phase = true
    @index = 3
    @scene = 5
  end
  #-----------------------------------------------------------------------------
  # Options
  #-----------------------------------------------------------------------------
  def update_options
    if Input.trigger?(Input::B)
      options_main_transition
    end
  end
  
  def options_main_transition
    $game_system.se_play($data_system.cancel_se)
    wait(10, true)
    @info.draw_info('Please Select a File')
    @options.phase = true
    @index = 5
    @scene = 1
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  alias max_ztitle_main_later main unless $@
  alias max_ztitle_update_later update unless $@
  alias max_ztitle_transfer_later transfer_player unless $@
  def main
    max_ztitle_main_later
    #dispose the quicksave sprite if it exists
    @quick_save_load.dispose unless @quick_save_load.nil?
  end
  
  def update
    max_ztitle_update_later
    if PZE::QUICKSAVE && !$game_temp.message_window_showing
      if Input.trigger?(PZE::QUICKSAVE_INPUT) #save
        #delete the old sprite
        unless @quick_save_load.nil?
          @quick_save_load.dispose
          @quick_save_load = nil
        end
        #flag for quicksave
        $game_temp.pze_quicksaving = true
        #save the game
        number = ($game_temp.pze_quickstart ? 0 : $game_system.file_id + 1)
        file = File.open("Quicksave#{number}.rxdata", 'wb')
        temp_save = Scene_Save.new
        temp_save.write_save_data(file)
        Marshal.dump($game_temp, file)
        file.close
        #deflag quicksave
        $game_temp.pze_quicksaving = false
        #show the save sprite
        @quick_save_load = Sprite_Quick_Save_Load.new('Quicksave Wrote')
      elsif Input.trigger?(PZE::QUICKLOAD_INPUT) #load
        #delete the old sprite
        unless @quick_save_load.nil?
          @quick_save_load.dispose
          @quick_save_load = nil
        end
        number = ($game_temp.pze_quickstart ? 0 : $game_system.file_id + 1)
        #if a quicksave file exists
        if FileTest.exist?("Quicksave#{number}.rxdata")
          #load the game
          file = File.open("Quicksave#{number}.rxdata", 'r')
          temp_load = Scene_Load.new
          temp_load.read_save_data(file)
          $game_temp = Marshal.load(file)
          file.close
          #refresh the spriteset
          @spriteset.dispose
          @spriteset = Spriteset_Map.new
          #replay music
          $game_system.bgm_play($game_system.playing_bgm)
          $game_system.bgs_play($game_system.playing_bgs)
          #update the map
          $game_map.update
          #show the load sprite
          @quick_save_load = Sprite_Quick_Save_Load.new('Quicksave Loaded')
        #else if there is no quicksave available
        else
          #show error message
          error = 'Error: No quicksave available'
          @quick_save_load = Sprite_Quick_Save_Load.new(error)
        end
      end
      unless @quick_save_load.nil?
        #update the sprite
        @quick_save_load.update
        #dispose the sprite if needed
        if @quick_save_load.count == 100
          @quick_save_load.dispose
          @quick_save_load = nil
        end
      end
    end
    if $game_temp.pze_loading
      @spriteset.dispose
      @spriteset = Spriteset_Map.new
      $game_temp.pze_loading = false
    end
  end
  
  def transfer_player
    max_ztitle_transfer_later
    #autosave coordinates if enabled
    if $game_system.pze_autosave
      $game_temp.autosave_coordinates = [$game_map.map_id,
      $game_player.x, $game_player.y, $game_player.direction]
    end
  end
end

#===============================================================================
# Scene_Save
#===============================================================================

class Scene_Save < Scene_File
  alias max_ztitle_save_later write_save_data unless $@
  def write_save_data(*args)
    if PZE::ZELDASAVE && !$scene.is_a?(Scene_Title) &&
       !$game_temp.pze_quicksaving
      #save current data
      map = $game_map.map_id
      x, y, d = $game_player.x, $game_player.y, $game_player.direction
      map_x, map_y = $game_map.display_x, $game_map.display_y
      #overwrite current data
      $game_map.map_id = $game_temp.autosave_coordinates[0]
      $game_player.moveto($game_temp.autosave_coordinates[1],
                          $game_temp.autosave_coordinates[2])
      case $game_temp.autosave_coordinates[3]
      when 2  # down
        $game_player.turn_down
      when 4  # left
        $game_player.turn_left
      when 6  # right
        $game_player.turn_right
      when 8  # up
        $game_player.turn_up
      end
      #end the running interpreter
      $game_system.map_interpreter.command_end
      #write the save data
      max_ztitle_save_later(*args)
      #reload the old data
      $game_map.map_id = map
      $game_player.moveto(x,y)
      $game_map.display_x, $game_map.display_y = map_x, map_y
      case d
      when 2  # down
        $game_player.turn_down
      when 4  # left
        $game_player.turn_left
      when 6  # right
        $game_player.turn_right
      when 8  # up
        $game_player.turn_up
      end
    else
      max_ztitle_save_later(*args)
    end
  end
end

#===============================================================================
# Scene_Gameover
#===============================================================================

class Scene_Gameover
  alias max_ztitle_update_later update unless $@
  def update
    if PZE::GAMEOVER
      unless @command.nil?
        @command.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          #deflag gameover
          $game_temp.gameover = false
          #recover the player
          $game_party.actors[0].recover_all
          #set player hp to gameover hp
          $game_party.actors[0].hp = $game_system.pze_gameover_hp
          #refresh the player
          $game_player.refresh
          case @command.index
          when 0 #save and continue
            #save, load then go to map
            PZE.save
            PZE.load
            $scene = Scene_Map.new
          when 1 #save and quit
            #save and go to title
            PZE.save
            $scene = Scene_Title.new
          when 2 #continue without saving
            #reset coordinates if zeldasave
            if PZE::ZELDASAVE
              if $game_map.map_id != $game_temp.autosave_coordinates[0]
                $game_map.setup_map($game_temp.autosave_coordinates[0])
              end
              $game_player.moveto($game_temp.autosave_coordinates[1],
                                  $game_temp.autosave_coordinates[2])
              case $game_temp.autosave_coordinates[3]
              when 2  # down
                $game_player.turn_down
              when 4  # left
                $game_player.turn_left
              when 6  # right
                $game_player.turn_right
              when 8  # up
                $game_player.turn_up
              end
              #end the interpreter
              $game_system.map_interpreter.command_end
            end
            #reset to scene map
            $scene = Scene_Map.new
          end
          #setup initial coordinates
          $game_temp.autosave_coordinates = [$game_map.map_id, $game_player.x,
          $game_player.y, $game_player.direction]
          #fade out
          8.times do 
            Graphics.update
            @command.opacity -= 32
          end
          @command.dispose
        end
      else
        if Input.trigger?(Input::C) || Input.trigger?(Input::B)
          $game_system.se_play($data_system.decision_se)
          #create the command window
          text = ['Save and Continue','Save and Quit','Continue without saving']
          @command = Window_Command.new(260, text)
          @command.x, @command.y = 190, 288
          @command.opacity = 0
          #fade in
          8.times do 
            Graphics.update
            @command.opacity += 32
          end
        end
      end
    else
      max_ztitle_update_later
    end
  end
end