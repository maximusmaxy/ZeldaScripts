#===============================================================================
# ¦ PZE Navi
#-------------------------------------------------------------------------------
# A functional navi that follows you around and gives information.
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.5: 10/1/12
#===============================================================================
#
# Introduction:
# Navi has many features similar to the features from Ocarina of Time and 
# Majora's Mask. She will normally follow you around, but if there is an event 
# in front of you with a graphic and at least 1 event command, she will lock 
# onto it. If navi has something to say about the event she will turn a 
# green color. You can then press the navi key to here what navi has to say,
# if no event is targeted she will tell you general quest information.
#
# Instructions:
# You can move navi to locations on the map by using call scripts, information
# on how to set up navi's event information is in the configuration.
#
# Event Checking:
# Navi will check in a square in front of you for events with a graphic and at
# least 1 event command. You can set how many tiles in front, and how many
# tiles to the side navi will check in the configuration.
# EG.             
#                        X X X   
#                      P 1 2 3   front = 3
#                        2 X X   side = 2
#
# Locking:
# If you want navi to lock to a certain event, place a '\lock' comment
# somewhere on the event, otherwise if you don't want navi to lock place an
# '\unlock' comment. Locking/Unlocking will be done automatically in most cases
# so you usually don't need to worry about it. 
#
# NR's Zelda Style HUD addon:
# If using NR's Zelda HUD place this script somewhere underneath it and when
# navi locks onto an event with information his C button will appear.
# 
# Script calls:
#
# NAVI.enable
# Enables navi
#
# NAVI.disable
# Disables navi
#
# NAVI.lock_enable
# Enables navi locking
#
# NAVI.lock_disable
# Disables navi locking
#
# NAVI.quest(KEY)
# Set the quest text to the relevant KEY, check the configuration for details.
#
# NAVI.front
# Moves navi in front of you, useful for cutscenes.
#
# NAVI.event(ID)
# Moves navi to the event ID specified, useful for cutscenes.
#
# NAVI.location(X,Y)
# Moves navi to the X and Y location specified, useful for cutscenes.
#
# NAVI.reset
# Resets navi to following you again, useful for after cutscenes.
#
# NAVI.wait
# Wait for navi's move completion (like wait for move route's completion).
#
#===============================================================================

$pze_navi = 0.5

module NAVI
  #dont delete these lines
  INFO = {}
  QUEST = {}
#===============================================================================
# Configuration
#===============================================================================
  #true if using navi, false if not, can be changed with the call script
  NAVI = true
  #Set true if navi locks to nearby events, can be changed with the call script
  LOCK = true
  #Input button to trigger navi's event/quest information
  INPUT = Input::R
  #the amount of spaces to the front navi checks for events
  FRONT = 3
  #the amount of spaces to the side navi checks for events
  SIDE = 2
  #true if locking to the top of events, false if center
  TOP = true
  #character graphic for navi
  CHARACTER = 'Navi[8]'
  #locked character graphic for navi
  LOCKED_CHARACTER = 'NaviEventTargetLock[8]'
  #rate at which the character frame updates
  RATE = 6
  #sound effect played when navi moves to an event (Name, Volume, Pitch)
  EVENT_SE = RPG::AudioFile.new('Fairy  - Tael - 04', 80, 100)
  #windowskin used when navi speaks, set to '' to not change the windowskin
  WINDOWSKIN = 'Windowskin - PZE - Fairy'
  #NR's Zelda Style HUD addon
  NaviShowingSwitch = 5
  NaviX = 554
  NaviY = 2
#-------------------------------------------------------------------------------
# Navi Information Database
#-------------------------------------------------------------------------------
# To give an event navi information, you set the information to the events
# graphic, that way all events of the same graphic have the same information.
# The information follows this format:
#
# INFO[GRAPHIC] = TEXT
# GRAPHIC is the filename of the graphic
# TEXT is the text which navi displays
#
# EG. INFO['002-Fighter02'] = "A strong fighter" will display the text
# 'A strong fighter', when locked onto an event with the graphic '002-Fighter02'
#
# For events without a graphic or you want different text for the same graphic,
# you can specify a number reference and add a '\navi(NUMBER)' comment to the 
# event. The setup is still the same EG. INFO[7] = "An interesting number" will
# be displayed if the event has the comment '\navi(7)'
#
# To set navi's general quest information, which he will tell you if the navi
# key is pressed while not targeting an event, use the following format:
#
# QUEST[KEY] = TEXT
# KEY can be either a number or a string
# TEXT is the text which navi displays
#
# It is the same as the info format, the quest key defaults as 0 but can
# be changed with the call script PZE.navi_quest(KEY)
#
# If at any time you need to do a line break in the text, put a \n in the 
# string and make sure the text is enclosed in double quotes "".
#-------------------------------------------------------------------------------
    #Set the first line to be the same each time eg "Navi:" or leave it as ""
  INFO_FIRST = ""
  #Place any tags for your custom message systems here
  TAGS = "\\ty[F]\\al[c,m]\\h[20]\\b[on]\\p[0]"
#=================================NPCS==========================================
  INFO['NPC - Singer'] = "She's a singer.\\|\nShe may know some \\u[2]ocarina songs\\u[0] to teach you!"
  INFO['Dungeon - Chest - Treasure Chest - 01 - 1x1 Red & Purple'] = "It's a \\u[2]treasure chest\\u[0].\\|\nOpen it up and find out what's inside!"
  INFO['Dungeon - Chest - Treasure Chest - 01 - 3x1 Red & Purple'] = "It's a \\u[2]treasure chest\\u[0].\\|\nOpen it up and find out what's inside!"
  INFO['Overworld - Monument - Owl Statue - 01 - 1x1 [2]'] = "A \\u[2]statue of an Owl\\u[0].\\| It look sleepy!\n \\|What if you hit it with an weapon to wake it up..."
  INFO['Dungeon - Block - Keyhole Block - 01 - 1x1 Green'] = "Hummm??\\| This block as a key Hole!\\|\n Maybe you should come back with \\u[2]a key\\u[0]!"
  #================================CLOCK TOWN=====================================
  INFO[1] = "Maybe if you play \\u[2]Zelda's Lullaby\\u[0],\\.\nthe tent will open."
  INFO[2] = "A \\u[2]Deku flower\\u[0].\\|\nIt can only be used by the \\u[2]Deku Scrubs\\u[0]."
  INFO[3] = "The \\u[2]Postman\\u[0] is the only one who can open the \\u[2]postboxes\\u[0]. \\|\nI wonder, where is he?"
  INFO[4] = "Information panel about the upcoming \\u[2]Carnival of Time\\u[0] !\\|\nI can't wait!"
  INFO[5] = "Aah! \\u[2]A frog\\u[0]! i don't like this kind of animal.\\|\nI have heard that \\u[2]they can eat fairies\\u[0]!\n Sorry I don't want to get any closer!!"
  INFO[6] = "Hey \\ac[004],\\| do you remember this guy?\\|\nI don't forget this face when we have disturbed \nthe mechanisms  of his windmill at \\u[2]Kakariko Village\\u[0]!!"
  INFO[7] = "This \\u[2]fairy\\u[0] seems lost.. \\|shall we get her back to the \\u[2]fairy fountain\\u[0]? \n\\..\\..\\..what??\\| You said there is no \\u[2]fairy fountain\\u[0]?\\|\n What the mappers are doing?!!"
  INFO[8] = "\\u[3]'Tingle, Tingle, Kooloo-Limpah!'\\u[0]\\|\n\\u[2]Don't steal his words\\u[0], otherwise he will turn mad!!"
  INFO[8] = "It looks like a \\u[2]ringing bell\\u[0]\\..\\..\\..\nWonder why it has been placed by the river?"
  INFO[9] = "Mayor's Residence"
  INFO[10] = "The sign says: \\u[2]'Stock Pot Inn'\\u[0],\nI have heard the owner often confuses her customers!\\|\n It could be an opportunity,\\. don't you think,\\. \\ac[004]?"
  INFO[11] = "The sign says: \\u[2]'Milk Bar Latte'\\u[0]\nApparently only members are allowed here.\\|\nAre you a member \\ac[004]?"
  INFO[12] = "The \\u[2]Stock Pot Inn's large bell\\u[0],\\| when it is rang,\\.\\. \nit is impossible to forget that we got \\u[2]only three Days\\u[0] to save the world!"
  INFO[13] = "Hey \\ac[004], shall we ring the bell \nand awake the people in the town?\\| \nTee hee!\\| We could have lots of fun!"
  INFO[14] = "Yeah! The \\u[4]Indigo-Go's\\u[0]! \nHey \\ac[004] can we watch their concert,\\. please?!\\| \nWe can worry about the \\u[2]falling Moon\\u[0],\\. later!"
  INFO[15] = "Absolutely Guaranteed!\\| \nWe shall guard your assets! \nClock Town Bank"
  INFO[16] = "C'mon, \\ac[004]!\\| Are you lazy to read it yourself?"
  INFO[17] = "Honey and Darling's,\\.\ngaming center.\\| Changes daily!"
  INFO[18] = "A personnal diary!\\|\n\\\ac[004]..\\..\\..\\. shall we read it?"
  INFO[19] = "Hey Look! It's \\u[2]Guru-Guru\\u[0]!!\\| When I see this little guy,\nI remember that we once broke his windmill,\\. in Kakriko,\\. apart.\\..\\.."
  INFO[20] = "Yeah, they are recruiting new soldiers.\\|\nHey, \\ac[001]!\\| Do you want to become a soldier too?"
  INFO[21] = "The sign says: \\u[2]'Bomb Shop'\\u[0]!"
  INFO[22] = "The sign says: \\u[2]'Trading Post'\\u[0]!"
  INFO[23] = "The sign says: \\u[2]'Curiosity Shop'\\u[0]!"
  INFO[24] = "The sign says: \\u[2]'Lottery Shop'\\u[0]!"
  INFO[25] = "The sign says: \\u[2]'Clock Town Bank'\\u[0]!"
  #============================Earth Temple=======================================
  INFO[100] = "\\ac[004]!\\| This Signpost has musical notes on it.\\|\nMaybe you should check it out."
  INFO[101] = "Those Telepathic tiles are used for communication.\\| \\u[2]Sahasralah\\u[0] used them to contact you tylepathetically!\\| What?!\\| You don't remember that?\\| \\..\\..\\..nevermind."
  INFO[102] = "Don't forget to check those telepathic tiles if you get stuck!"
  #================================QUEST==========================================
  QUEST[0] = "We only got \\u[2]\\v[66] hours\\u[0] to work out how to stop\nthe Moon from crashing into Termina.\\|\nWhat are we going to do?"
#===============================================================================
# End Configuration
#===============================================================================

  def self.enable
    $game_system.navi_enabled = true
    return true
  end
  
  def self.disable
    $game_system.navi_enabled = false
    return true
  end
  
  def self.lock_enable
    $game_system.navi.lock = true
    return true
  end
  
  def self.lock_disable
    $game_system.navi.lock = false
    return true
  end
  
  def self.quest(key)
    if QUEST[key].nil?
      p "#{key} is an invalid quest key" 
    else
      $game_system.navi.quest = key
    end
    return true
  end
  
  def self.front
    $game_system.se_play(EVENT_SE) unless $game_system.navi.front
    self.reset(false)
    $game_system.navi.front = true
    return true
  end
  
  def self.event(id)
    self.reset(false)
    $game_system.navi.event = $game_map.events[id]
    return true
  end
  
  def self.location(x,y)
    $game_system.se_play(EVENT_SE) if $game_system.navi.location.empty?
    self.reset(false)
    $game_system.navi.location = [x,y]
    return true
  end  
  
  def self.reset(sound = true)
    if sound && ($game_system.navi.location.empty? || !$game_system.navi.front)
      $game_system.se_play(EVENT_SE)
    end
    $game_system.navi.front = false
    $game_system.navi.event = nil
    $game_system.navi.location.clear
    return true
  end
  
  def self.wait
    return true unless $scene.is_a?(Scene_Map)
    $game_system.navi.update
    return false if $game_system.navi.screen_x != $scene.spriteset.navi.x
    return false if $game_system.navi.screen_y != $scene.spriteset.navi.y
    return true
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :navi_enabled
  attr_reader :navi
  alias max_navi_initialize_later initialize
  def initialize
    max_navi_initialize_later
    @navi_enabled = NAVI::NAVI
    @navi = Game_Navi.new
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  attr_reader :scroll_speed
end

#===============================================================================
# Game_Character
#===============================================================================

class Game_Character
  attr_accessor :navi_height
  alias max_navi_initialize_later initialize
  def initialize
    @navi_height = 0
    max_navi_initialize_later
  end  
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_reader :navi
  attr_reader :navi_text
  alias max_navi_refresh_later refresh
  def refresh
    max_navi_refresh_later
    @navi_text = ''
    @navi = false
    #if not erased
    unless @erased || @list.nil?
      #activate navi if the character has a graphic and isn't a tile
      if (@character_name != '' || @tile_id > 0)
        #navi if the list does not only include blank, comments and scripts
        @navi = true if @list.any?{|i| ![0,108,408].include?(i.code)}
      end
      #set navi text if the events character graphic has text
      if NAVI::INFO.has_key?(@character_name)
        @navi = true
        if NAVI::INFO_FIRST == ''
          @navi_text = NAVI::INFO[@character_name]
        else
          @navi_text = NAVI::INFO_FIRST + "\n" + NAVI::INFO[@character_name]
        end
        @navi_text = NAVI::TAGS + @navi_text
      end
      #search the events list
      @list.each do |line|
        #if there is a comment
        if line.code == 108
          #if the comment denotes it as having text
          if line.parameters[0] =~ /\\navi\((\d*)\)/
            unless NAVI::INFO[$1.to_i].nil?
              if NAVI::INFO_FIRST == ''
                @navi_text = NAVI::INFO[$1.to_i]
              else
                @navi_text = NAVI::INFO_FIRST + "\n" + NAVI::INFO[$1.to_i]
              end
              @navi_text = NAVI::TAGS + @navi_text
              @navi = true
            end
          end
          #if the comment denotes it as lockable
          @navi = true if line.parameters[0].downcase == '\lock'
          #if the comment denotes it as unlockable
          @navi = false if line.parameters[0].downcase == '\unlock'
        else
          break
        end
      end
    end
  end
end

#===============================================================================
# Game_Navi
#===============================================================================

class Game_Navi
  attr_reader :x
  attr_reader :y
  attr_accessor :z
  attr_reader :locked
  attr_reader :pattern
  attr_reader :direction
  attr_accessor :lock
  attr_accessor :front
  attr_accessor :event
  attr_accessor :location
  attr_accessor :quest
  def initialize
    @x = 0
    @y = 0
    @z = 0
    @count = 0
    @pattern = 0
    @direction = 0
    @rate = NAVI::RATE
    @lock = NAVI::LOCK
    @locked = 0
    @quest = 0
    @front = false
    @event = nil
    @location = []
    @check_event = nil
    get_character(NAVI::CHARACTER)
    get_character(NAVI::LOCKED_CHARACTER, true)
  end
  
  def get_character(character, lock = false)
    #change the character graphic
    lock ? @locked_character = character : @character = character
    #compatibillity with Cogwheels extra frames
    if defined?(COG_ExtraFrames) && character[COG_ExtraFrames::REGEXP]
      lock ? @locked_frames = $1.to_i : @frames = $1.to_i
    else
      lock ? @locked_frames = 4 : @frames = 4
    end
  end
  
  def character
    return information? ? @locked_character : @character
  end
  
  def frames
    return @locked == 0 ? @locked_frames : @frames
  end
  
  def information?
    return @locked != 0 && $game_map.events[@locked].navi_text != '' rescue false
  end
  
  def event_check
    #return if not checking
    return nil unless @lock
    #only check every 4 frames to prevent lag
    return @check_event if @count % 4 != 0
    #return if there is no front/side distance
    return nil if NAVI::FRONT < 1 || NAVI::SIDE < 1
    #change variables based on player direction
    x, y, d = $game_player.x, $game_player.y, $game_player.direction
    xi = (d == 6 ? 1 : d == 4 ? -1 : 0)
    yi = (d == 2 ? 1 : d == 8 ? -1 : 0)
    xj = (d == 4 || d == 6 ? 0 : 1)
    yj = (d == 2 || d == 8 ? 0 : 1)
    #loop for each front and side value
    (1..NAVI::FRONT).each do |i|
      (0...NAVI::SIDE).each do |j|
        #check to the left
        event = check_lock(x + xi * i + j * xj, y + yi * i + j * yj)
        return event unless event.nil?
        #return if side distance is 0
        next if j == 0
        #check to the right
        event = check_lock(x + xi * i - j * xj, y + yi * i - j * yj)
        return event unless event.nil?
      end
    end
    #return nil if nothing could be found
    return nil
  end
  
  def check_lock(x,y)
    #loop for each event
    $game_map.events.each_value do |event|
      #if the event is lockable and the coordinates are equal
      if event.navi && event.x == x && event.y == y
        #return the event
        return event
      end
    end
    return nil
  end
  
  def screen_x
    #return the screen x
    return (@x - $game_map.display_x + 3) / 4 + 16
  end
  
  def screen_y
    #return the screen y
    y = (@y - $game_map.display_y + 3) / 4 + 32
    if @locked != 0 && NAVI::TOP
      y += 32 - $game_map.events[@locked].navi_height rescue nil
    end
    return y
  end
  
  def update
    #update the pattern
    @count += 1
    @count = 0 if @count == @rate * frames
    @pattern = (@pattern + 1) % frames if @count % @rate == 0
    #get the event check event
    @check_event = event_check
    #store the locked value
    last_locked = @locked
    #update the location to travel to
    if @front #front
      @locked = 0
      @direction = 10 - $game_player.direction
      @x, @y = $game_player.real_x + follow[0], $game_player.real_y + follow[1]
    elsif !@event.nil? #event
      @locked = @event.id
      @direction = 2
      @x, @y = @event.real_x, @event.real_y
    elsif !@location.empty? #location
      @locked = 0
      @direction = 2
      @x, @y = @location[0] * 128, @location[1] * 128
    elsif @lock && !@check_event.nil? && @check_event.opacity != 0 #check event
      @locked = @check_event.id
      @direction = 2
      @x, @y = @check_event.real_x, @check_event.real_y
    else #follow
      @locked = 0
      @direction = $game_player.direction
      @x, @y = $game_player.real_x + follow[0], $game_player.real_y + follow[1]
    end
    #play the moving sound effect
    if @locked != 0 && @locked != last_locked
      $game_system.se_play(NAVI::EVENT_SE)
    end
    #display navi text
    if Input.trigger?(NAVI::INPUT) && !$game_system.map_interpreter.running?
      unless @locked == 0 #locked
        setup_info if $game_map.events[@locked].navi_text != ''
      else #not locked
        setup_quest
      end
    end
  end
  
  def follow
    #return the following direction adjustment
    d = @front ? 10 - $game_player.direction : $game_player.direction
    case d
    when 2 then return 0, -128
    when 4 then return 128, 0
    when 6 then return -128, 0
    when 8 then return 0, 128
    end
  end
  
  def setup_info
    #create the text command
    text = RPG::EventCommand.new
    text.code = 101
    text.parameters = [$game_map.events[@locked].navi_text]
    #create the talk reset command
    talk = RPG::EventCommand.new
    talk.code = 355
    talk.parameters = ['return']
    #create the finish command
    finish = RPG::EventCommand.new
    #if there is a windowskin
    if NAVI::WINDOWSKIN != ''
      #create the windowskin commands
      old_skin = $game_system.windowskin_name
      $game_system.windowskin_name = NAVI::WINDOWSKIN
      skin = RPG::EventCommand.new
      skin.code = 131
      skin.parameters = [old_skin]
      wait = RPG::EventCommand.new
      wait.code = 355
      wait.parameters = ['!$game_temp.message_window_showing']
      #setup the interpreter
      $game_system.map_interpreter.setup([text,talk,wait,skin,finish], 0)
    else
      #setup the interpreter
      $game_system.map_interpreter.setup([text,talk,finish], 0)
    end
  end
  
  def setup_quest
    #get the quest message
    message = ''
    message += NAVI::INFO_FIRST + "\n" unless NAVI::INFO_FIRST == ''
    message += NAVI::QUEST[@quest]
    message = NAVI::TAGS + message
    #create the navi front command
    front = RPG::EventCommand.new
    front.code = 355
    front.parameters = ['NAVI.front']
    #create the text command
    text = RPG::EventCommand.new
    text.code = 101
    text.parameters = [message]
    #create the navi reset command
    reset = RPG::EventCommand.new
    reset.code = 355
    reset.parameters = ['NAVI.reset']
    #create the finish command
    finish = RPG::EventCommand.new
    #if there is a windowskin
    if NAVI::WINDOWSKIN != ''
      #create the windowskin commands
      old_skin = $game_system.windowskin_name
      $game_system.windowskin_name = NAVI::WINDOWSKIN
      skin = RPG::EventCommand.new
      skin.code = 131
      skin.parameters = [old_skin]
      wait = RPG::EventCommand.new
      wait.code = 355
      wait.parameters = ['!$game_temp.message_window_showing']
      #setup the interpreter
      $game_system.map_interpreter.setup([front,text,reset,wait,skin,finish], 0)
    else
      
      #setup the interpreter
      $game_system.map_interpreter.setup([front,text,reset,finish], 0)
    end
  end
end

#===============================================================================
# Sprite_Navi
#===============================================================================

class Sprite_Navi < Sprite
  def initialize(viewport = nil)
    super(viewport)
    #get the navi object
    @navi = $game_system.navi
    #move navi into place
    @navi.update
    self.x = @navi.screen_x
    self.y = @navi.screen_y
  end

  def update
    #update the bitmap
    if @character != @navi.character
      @character = @navi.character
      self.bitmap = RPG::Cache.character(@navi.character, 0)
      @cw = self.bitmap.width / @navi.frames
      @ch = self.bitmap.height / 4
      self.ox = @cw / 2
      self.oy = @ch
    end
    #update the pattern
    d = (@navi.direction - 2) / 2
    self.src_rect.set(@cw * @navi.pattern, @ch * d, @cw, @ch)
    #get the travel to location
    x = @navi.screen_x
    y = @navi.screen_y
    #get the speed 
    speed = $game_map.scrolling? ? 2 ** $game_map.scroll_speed : 4
    #get the accelleration
    xa = ((self.x - x).abs / 32 + 1) * speed
    ya = ((self.y - y).abs / 32 + 1) * speed
    #update the x, y value
    if self.x < x
      self.x = [self.x + xa, x].min
    elsif self.x > x
      self.x = [self.x - xa, x].max
    end
    if self.y < y
      self.y = [self.y + ya, y].min
    elsif self.y > y
      self.y = [self.y - ya, y].max
    end
    #update z value
    self.z = (@navi.locked == 0 ? @navi.z : 999)
  end
end

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character
  alias max_navi_update_later update
  def update
    max_navi_update_later
    @character.navi_height = @character_name == '' ? 32 : @ch
    $game_system.navi.z = self.z if @character.is_a?(Game_Player)
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  attr_reader :navi
  alias max_navi_dispose_later dispose
  alias max_navi_update_later update
  def dispose
    max_navi_dispose_later   
    #dispose navi if he exists
    @navi.dispose unless @navi.nil?
  end
  
  def update
    max_navi_update_later
    if $game_system.navi_enabled
      #create navi if needed
      @navi = Sprite_Navi.new(@viewport1) if @navi.nil?
      #update navi object and sprite
      $game_system.navi.update
      @navi.update
    elsif !@navi.nil?
      #dispose navi
      @navi.dispose
      @navi = nil
    end
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  attr_reader :spriteset
end

#===============================================================================
# Sprite_ZeldaHUD
#===============================================================================

#if the zelda hud exists
if defined?(Sprite_ZeldaHUD)
  
class Sprite_ZeldaHUD  < Sprite
  alias max_navi_initialize_later initialize
  alias max_navi_update_later update
  alias max_navi_dispose_later dispose
  def initialize(viewport = Viewport.new(0, 0, 640, 480))
    #initialize the navi sprite
    @navi_sprite = Sprite.new(viewport)
    @navi_sprite.bitmap = RPG::Cache.windowskin('C_Navi')
    @navi_sprite.x = NAVI::NaviX
    @navi_sprite.y = NAVI::NaviY
    max_navi_initialize_later(viewport)
  end
  
  def update
    max_navi_update_later
    #show the navi sprite if locked on an event with information
    if $game_switches[NAVI::NaviShowingSwitch] &&
       $game_system.navi.information?
      @navi_sprite.visible = true
    else #else hide the sprite
      @navi_sprite.visible = false
    end
  end
  
  def dispose
    #dispose the navi sprite
    @navi_sprite.dispose
    max_navi_dispose_later
  end
end

end