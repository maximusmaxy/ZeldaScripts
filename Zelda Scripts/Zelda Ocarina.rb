#===============================================================================
# ¦ PZE Ocarina
#-------------------------------------------------------------------------------
# Play and Create your own Ocarina songs
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.7: 8/1/12
#===============================================================================
#
# Instructions:
# Information on how to create your own songs are in the configuration. There
# are 3 modes to choose from:
# 1: Classic PZE - The bar and the notes are all displayed on the screen while
# you play the song. When your successful the notes will flash
# 2: OOT/MM - No bar or notes are shown, Just play away.
# 3: LA - In this mode you are given 3 songs to choose from, select the
# corresponding key to play the song.
#
# NOTE: Remember you have to add the songs with the call script before you
#       can play them! PZE.ocarina_song_add(ID)
#
# Ocarina Event Triggers:
# You can trigger the self switch of events in a radius around the player, 
# by placing a comment somewhere on the event. You can use this to trigger a
# range of things like opening doors and such. Use your imagination!
# The comment follows this format:
#
# \ocarina(SONG_ID,DISTANCE)
# SONG_ID is the ID of the song in the congifuration.
# DISTANCE is the maximum distance from the event you can be to trigger the
# events self switch. A distance of 4 will be triggered in a shape like this:
#
#                                   o
#                                 o o o
#                               o o o o o
#                             o o o o o o o
#                           o o o o E o o o o
#                             o o o o o o o
#                               o o o o o
#                                 o o o
#                                   o
# 
# Script Calls:
#
# OCARINA.play
# Start playing the ocarina
#
# OCARINA.learn(SONG)
# Starts a learn the song scene. SONG is the song id in the configuration.
# Note: It is not recommended to use this in LA mode
#
# OCARINA.trigger
# checks for ocarina event triggers
#
# OCARINA.type(TYPE)
# changes the ocarina TYPE to the number specified
# Note: It is not recommended to change to or from LA mode
#
# In LA Mode the SONG ID's for song adding and removing are:
# Manbo's Mambo = 0
# Ballad of the Windfish = 1
# Frog's Song of Souls = 2
#
# OCARINA.song_add(SONG)
# adds the SONG id to the player
#
# OCARINA.song_remove(SONG)
# removes the SONG id from the player
#
# OCARINA.soaring_remember(KEY)
# KEY can either be a number or text
#
# OCARINA.soaring_transfer(KEY)
# KEY is the same as the soaring remember key to transfer to that point
#
#===============================================================================

$pze_ocarina = 0.7

module OCARINA
  #don't remove these lines
  SONG = []
#===============================================================================
# Configuration
#===============================================================================
  #Set Ocarina Type, Classic PZE = 1, OOT/MM = 2, LA = 3
  TYPE = 1
  #Variable which represents the last song played
  LAST_SONG = 57
  #Switch which is activated when learning 
  LEARNING_SWITCH = 71

  #NOTE: The ocarina start/finish functions require scripting knowledge so
  #don't worry if you don't understand how to use it. You can place script
  #calls from other scripts to disable/enable there functions.
  #EG. PZE.time_disable will pause time, examine the script calls
  #of other scripts for more information.
  
  #add anything you want to be disable at the start of playing
  def self.start
    #change character graphic to playing the ocarina
    $game_player.character_name_suffix = '_OCARINA'
    #pause time
    PZE.time_disable
    #disable navi's locking
    NAVI.lock_disable
  end
  
  #add anything you want to re-enable after playing
  def self.finish
    #change character graphic back to normal
    $game_player.character_name_suffix = nil
    #play time
    PZE.time_enable
    #re-enable navi's locking
    NAVI.lock_enable
  end
#-------------------------------------------------------------------------------
# Songs
#-------------------------------------------------------------------------------
# Add your songs here. Songs can be anywhere up to 8 notes in length. The code
# for the notes is as follows:
# A = 0, Down = 1, Right = 2, Left = 3, Up = 4
# EG. SONG[4] = [0,3,2,3,1,4] would give you:
# A, Left, Right, Left, Down, Up
#-------------------------------------------------------------------------------
  SONG[0] = [3,4,2,3,4,2]      #Zelda's Lullaby
  SONG[1] = [1,2,3,1,2,3]      #Saria's Song
  SONG[2] = [2,1,4,2,1,4]      #Sun's Song
  SONG[3] = [2,0,1,2,0,1]      #Song of Time
  SONG[4] = [1,0,2,1,0,2]      #Inverted Song of Time
  SONG[5] = [2,2,0,0,1,1]      #Song of Double Time
  SONG[6] = [4,3,2,4,3,2]      #Epona's Song
  SONG[7] = [0,1,4,0,1,4]      #Song of Storms
  SONG[8] = [3,2,1,3,2,1]      #Song of Healing
  SONG[9] = [1,3,4,1,3,4]      #Song of Soaring
  SONG[10] = [4,2,4,2,3,4]     #Prelude of Light
  SONG[11] = [0,4,3,2,3,2]     #Minuet of Forest
  SONG[12] = [1,0,1,0,2,1,2,1] #Bolero of Fire
  SONG[13] = [0,1,2,2,3]       #Serenade of Water
  SONG[14] = [3,2,2,0,3,2,1]   #Nocturne of Shadow
  SONG[15] = [0,1,0,2,1,0]     #Requiem of Spirit
  SONG[16] = [4,3,4,3,0,2,0]   #Sonata of Awakening
  SONG[17] = [0,2,3,0,2,3,2,0] #Goron Lullaby
  SONG[18] = [3,4,3,2,1,3,2]   #New Wave Bossa Nova
  SONG[19] = [2,3,2,1,2,4,3]   #Elegy of Emptiness
  SONG[20] = [2,1,0,1,2,4]     #Oath to Order
  SONG[21] = []                #Tune of Echoes
  SONG[22] = []                #Ballad of the Wind Fish
  SONG[23] = []                #Manbo's Mambo
  SONG[24] = []                #Frog song of soul
#-------------------------------------------------------------------------------
# Ocarina Common Events
#-------------------------------------------------------------------------------
# At the end of the song, the common event specified will be triggered. You can
# then show an animation, play a song, activate event triggers ect.
# The setup follows this format:
# EG. when 6
#       return 7
# Will trigger common event ID #007 after song ID #006 is played
#-------------------------------------------------------------------------------
  def self.common_event(song)
    case song
    #--------------Start the ocarina's Common Event configuration here----------
    when 0..20
      return 7 #trigger the Common Event ID #007
    #---------------End the ocarina's Common Event configuration here-----------
    else
      return 0
    end
  end
#===============================================================================
# End Configuration
#===============================================================================

  def self.play
    if $game_temp.ocarina_finish
      $game_temp.ocarina_finish = false
      return true
    end
    $game_temp.ocarina = true
    $game_temp.ocarina_learning = false
    $game_switches[LEARNING_SWITCH] = false
    return false
  end
  
  def self.learn(song)
    if $game_temp.ocarina_finish
      $game_temp.ocarina_finish = false
      return true
    end
    return if $game_system.ocarina_type == 3
    $game_temp.ocarina_learning = true
    $game_switches[LEARNING_SWITCH] = true
    $game_temp.ocarina_song = song
    $game_variables[LAST_SONG] = song
    $game_temp.ocarina = true
    return false
  end
  
  def self.type(type)
    $game_system.ocarina_type = type
    return true
  end
  
  def self.trigger
    $game_map.check_ocarina_trigger
    return true
  end  
  
  def self.song_add(number)
    if $game_system.ocarina_type == 3
      $game_system.ocarina_songs_la[number] = true
    else
      $game_system.ocarina_songs[number] = true
    end
    return true
  end
  
  def self.song_remove(number)
    if $game_system.ocarina_type == 3
      $game_system.ocarina_songs_la[number] = false
    else
      $game_system.ocarina_songs[number] = false
    end
    return true
  end
  
  def self.soaring_remember(key)
    location = [$game_map.map_id, $game_player.x, $game_player.y]
    $game_system.soaring_points[key] = location
    return true
  end
  
  def self.soaring_transfer(key)
    location = $game_system.soaring_points[key]
    $game_temp.player_transferring = true
    $game_temp.player_new_map_id = location[0]
    $game_temp.player_new_x = location[1]
    $game_temp.player_new_y = location[2]
    $game_temp.player_new_direction = 2
    return true
  end
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor :ocarina
  attr_accessor :ocarina_learning
  attr_accessor :ocarina_song
  attr_accessor :ocarina_finish
  alias max_ocarina_initialize_later initialize unless $@
  def initialize
    max_ocarina_initialize_later
    #temp variables for the ocarina
    @ocarina = false
    @ocarina_learning = false
    @ocarina_song = 0
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :ocarina_songs
  attr_accessor :soaring_points
  attr_accessor :ocarina_type
  attr_accessor :ocarina_songs_la
  alias max_ocarina_initialize_later initialize unless $@
  def initialize
    max_ocarina_initialize_later
    #array for known ocarina songs
    @ocarina_type = OCARINA::TYPE
    @ocarina_songs = []
    @soaring_points = {}
    @ocarina_songs_la = []
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  #check for ocarina triggers
  def check_ocarina_trigger
    #check all events
    @events.each_value do |event|
      #if the event has an ocarina trigger
      unless event.ocarina_trigger.empty?
        #if the song is correct
        if $game_temp.ocarina_song == event.ocarina_trigger[0] ||
           $game_variables[OCARINA::LAST_SONG] == event.ocarina_trigger[0]
          #if you are within the correct distance
          if event.ocarina_trigger[1] >= ($game_player.x - event.x).abs +
                                         ($game_player.y - event.y).abs
            #trigger the self switch
            key = [@map_id,event.id,'A']
            $game_self_switches[key] = true
            @need_refresh = true
          end
        end
      end
    end
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_reader :ocarina_trigger
  alias max_ocarina_initialize_later initialize unless $@
  alias max_ocarina_refresh_later refresh unless $@
  def initialize(*args)
    #events ocarina trigger
    @ocarina_trigger = []
    max_ocarina_initialize_later(*args)
  end
  
  def refresh
    max_ocarina_refresh_later
    #if the event has a list and not erased
    unless @list.nil? || @erased
      #search the events list
      @list.each do |line|
        #if there is a comment
        if line.code == 108
          #if the comment denotes it as an ocarina trigger
          if line.parameters[0] =~ /\\ocarina\((\d*),(\d*)\)/
            @ocarina_trigger = [$1.to_i,$2.to_i]
          end
        else
          break
        end
      end
    end
  end
end

#===============================================================================
# Game_Player
#===============================================================================

class Game_Player < Game_Character
  attr_writer :character_name
  attr_writer :step_anime
end

#===============================================================================
# Sprite_Ocarina_Bar
#===============================================================================

class Sprite_Ocarina_Bar < Sprite
  def initialize(type)
    super(nil)
    @type = type
    self.x, self.y, self.z = 23, 291, 9997
    refresh
  end
  
  def refresh
    case @type
    when 0 #bar
      bitmap = 'Ocarina_Bar'
    when 1 #memorise this
      bitmap = 'Ocarina_Bar_Memory'
    when 2 #example bar
      bitmap = 'Ocarina_Bar_Example'
    when 3 #LA bar
      bitmap = 'Ocarina_Bar_LA'
    end
    if FileTest.exist?('Graphics/Pictures/' + bitmap + '.png') #draw the bar
      self.bitmap = RPG::Cache.picture(bitmap)
    elsif $DEBUG #error handling
      raise bitmap + ".png could not be found/nPlease place " + bitmap + 
      '.png in the pictures folder'
    end
  end

  def change_type(type)
    @type = type
    refresh
  end
end

#===============================================================================
# Sprite_Ocarina_Button
#===============================================================================

class Sprite_Ocarina_Button < Sprite
  attr_reader :flash
  def initialize(note, type = true) 
    super(nil)
    self.z = 9998
    @note = note
    @type = type
    @count = 0
    @target = 0
    @flash = 0
    bitmap = get_bitmap
    bitmap = bitmap + ' - Stamp' unless @type
    if FileTest.exist?('Graphics/Pictures/' + bitmap + '.png') #draw note
      self.bitmap = RPG::Cache.picture(bitmap)
    elsif $DEBUG #error handling
      raise bitmap + ".png could not be found/nPlease place " + bitmap + 
      '.png in the pictures folder'
    end
  end
  
  def get_bitmap
    case @note
    when 0 #A
      if $game_system.ocarina_type == 3
        self.x, self.y = 95, 401
        return "Manbo's Mambo Song"
      end
      Audio.se_play('Audio/SE/Ocarina - Key - A') if @type
      self.y = 411
      return 'Ocarina Button - A'
    when 1 #down
      if $game_system.ocarina_type == 3
        self.x, self.y = 205, 361
        return "Ballad of the Wind Fish"
      end
      Audio.se_play('Audio/SE/Ocarina - Key - Down') if @type
      self.y = 400
      return 'Ocarina Button - Down'
    when 2 #right
      if $game_system.ocarina_type == 3
        self.x, self.y = 360, 401
        return "Frog's Song of Soul"
      end
      Audio.se_play('Audio/SE/Ocarina - Key - Right') if @type
      self.y = 379
      return 'Ocarina Button - Right'
    when 3 #left
      Audio.se_play('Audio/SE/Ocarina - Key - Left') if @type
      self.y = 367
      return 'Ocarina Button - Left'
    when 4 #up
      Audio.se_play('Audio/SE/Ocarina - Key - Up') if @type
      self.y = 345
      return 'Ocarina Button - Up'
    end
  end
  
  def set(target, count)
    @target = target
    @count = count    
  end
  
  def update
    if @count >= 1
      @flash = (@flash * (@count - 1) + @target) / @count
      tone.red = tone.green = tone.blue = @flash
      @count -= 1
    end
  end
end

#===============================================================================
# Sprite_Ocarina_Error
#===============================================================================

class Sprite_Ocarina_Error < Sprite
  def initialize
    super()
    self.x, self.y, self.z = 23, 291, 9999
    @enabled = false
    self.bitmap = RPG::Cache.picture('Ocarina_Bar_Error')
    self.visible = false
  end
  
  def update
    return unless @enabled
    @count += 1
    self.visible = !self.visible if @count % 8 == 0
    @enabled = false if @count == 48
  end
  
  def show_error
    @count = 0
    @enabled = true
  end
end

#===============================================================================
# Ocarina
#===============================================================================

class Ocarina
  def initialize
    #call the ocarina start
    OCARINA.start
    #turn the player down and start the animation
    $game_player.turn_down
    $game_player.step_anime = true
    #setup the dummy interpreter for the ocarina
    $game_system.map_interpreter.ocarina_dummy
    $game_temp.ocarina_finish = false
    #instance variables
    @type = $game_system.ocarina_type
    if $game_temp.ocarina_learning
      @bar = Sprite_Ocarina_Bar.new(1)
    elsif @type == 1
      @bar = Sprite_Ocarina_Bar.new(0)
    elsif @type == 3
      @bar = Sprite_Ocarina_Bar.new(3)
    else
      @count = 0
    end
    @buttons = []
    @memory = []
    @wait = 0
    @clear = false
    @play = false
    #create la songs if type 3
    if @type == 3
      for i in 0..2
        if $game_system.ocarina_songs_la[i]
          @buttons.push Sprite_Ocarina_Button.new(i)
        end
      end
    end
    #create teaching variables if teaching
    if $game_temp.ocarina_learning
      @error = Sprite_Ocarina_Error.new
      @song = $game_temp.ocarina_song
      @memory_buttons = []
      for i in 0...OCARINA::SONG[@song].size
        @memory_buttons[i] = Sprite_Ocarina_Button.new(
                             OCARINA::SONG[@song][i],false)
        @memory_buttons[i].x = 98 + 60 * i
        @teach = true
        @wait = 20
      end
    else
      @song = 0
    end
  end

  def dispose
    #dispose everything
    @bar.dispose unless @bar.nil?
    @buttons.each {|button| button.dispose} unless @buttons.nil?
    @memory_buttons.each {|button| button.dispose} unless @memory_buttons.nil?
    @error.dispose unless @error.nil?
  end
   
  def update
    #update the buttons
    unless @buttons.nil?
      @buttons.each {|button| button.update}
      #flash buttons if successful
      if @play && @wait % 8 == 0
        if @type == 3
          unless @buttons[@song].nil?
            @buttons[@song].set((@wait == 40 ? 150 : 0), 8)
          end
        else
          @buttons.each do |button|
            button.set((button.flash == 0 ? 150 : 0), 8)
          end
        end
      end
    end
    #update the error bar
    @error.update unless @error.nil?
    #wait if needed
    if @wait > 0
      #clear if needed
      if @wait == 1 && @clear
        #change bar if teaching
        if @teach
          @teach = false
          @bar.change_type(2)
        end
        #clear the bar
        clear
      end
      @wait -= 1
      return
    end
    #teach the song 
    if @teach
      if @buttons.size == OCARINA::SONG[@song].size
        @wait = 40
        @clear = true
        return
      end
      button_update(OCARINA::SONG[@song][@buttons.size])
      @wait = 20
    end
    #play the song
    if @play
      #learn the song
      OCARINA.song_add(@song) if $game_temp.ocarina_learning
      #call the ocarina finish
      OCARINA.finish
      $game_player.step_anime = false
      $game_temp.ocarina = false
      $game_temp.ocarina_song = @song
      $game_temp.ocarina_finish = true
      $game_variables[OCARINA::LAST_SONG] = @song
      Audio.me_stop
      Audio.se_stop
      #activate the common event
      if $game_system.map_interpreter.running?
        $game_system.map_interpreter.parameters = [OCARINA.common_event(@song)]
        $game_system.map_interpreter.command_117
      else
        $game_temp.common_event_id = OCARINA.common_event(@song)
      end
      return
    end
    #dont update input if teaching
    return if @teach
    #update the input for the notes
    if Input.trigger?(Input::C) || Input.trigger?(Input::A)
      Audio.se_play('Audio/SE/Ocarina - Key - A') if @type == 2
      button_update(0) 
    elsif Input.trigger?(Input::DOWN)
      Audio.se_play('Audio/SE/Ocarina - Key - Down') if @type == 2
      button_update(1) 
    elsif Input.trigger?(Input::RIGHT)
      Audio.se_play('Audio/SE/Ocarina - Key - Right') if @type == 2
      button_update(2) 
    elsif Input.trigger?(Input::LEFT)
      Audio.se_play('Audio/SE/Ocarina - Key - Left') if @type == 2
      button_update(3) 
    elsif Input.trigger?(Input::UP)
      Audio.se_play('Audio/SE/Ocarina - Key - Up') if @type == 2
      button_update(4)
    end
    #reset the bar if S is pressed
    clear if Input.trigger?(Input::Y)
    #disallow exit if learning
    return if $game_temp.ocarina_learning
    #exit and dispose if X is pressed
    if Input.trigger?(Input::B)
      #call the ocarina finish
      OCARINA.finish
      $game_player.step_anime = false
      $game_temp.ocarina = false
      $game_temp.ocarina_finish = !$game_system.map_interpreter.running?
    end
  end
  #place the note on the bar
  def button_update(note)
    #if type 2
    if @type == 2 && !$game_temp.ocarina_learning
      #create array if needed
      @memory[@count] = [] if @memory[@count].nil?
      #loop through each array in the memory
      @memory.each do |array|
        #if full remove the first index
        array.shift if array.size == 8
        #add the note on the end of the array
        array.push note 
      end
      #loop for each song
      OCARINA::SONG.each_index do |i|
        #skip if there is no song or you don't have the song
        next if OCARINA::SONG[i].nil? || !$game_system.ocarina_songs[i]
        #loop for each memory array
        for j in 0...@memory.size
          #temp memory array with the song size
          memory = @memory[j][-OCARINA::SONG[i].size, OCARINA::SONG[i].size]
          #flag song to be played if it is correct
          if OCARINA::SONG[i] == memory
            #flag the song to be played
            Audio.se_play('Audio/SE/Ocarina - Song is Correct')
            @song = i
            @play = true
            @wait = 20
            return
          end
        end
      end
      #increment the count
      @count += 1 if @count <= 8
      return
    #if type 3
    elsif @type == 3 && !$game_temp.ocarina_learning
      return if note == 0 || note == 1
      case note
      when 2 #right
        return if !$game_system.ocarina_songs_la[2]
        @song = 2
      when 3 #left
        return if !$game_system.ocarina_songs_la[0]
        @song = 0
      when 4 #up
        return if !$game_system.ocarina_songs_la[1]
        @song = 1
      end
      #flag the song to be played
      Audio.se_play('Audio/SE/Ocarina - Song is Correct')
      @play = true
      @wait = 40
      return
    end
    #add the note to the bar
    @memory.push note
    @buttons.push Sprite_Ocarina_Button.new(note)
    size = @buttons.size - 1
    @buttons[size].x = 98 + 60 * size
    #skip checks if teaching
    return if @teach
    #check for teached song if teaching
    if $game_temp.ocarina_learning
      #if you play an incorrect note
      if OCARINA::SONG[@song][0,@memory.size] != @memory
        #show the error
        Audio.se_play('Audio/SE/System - Menu Error')
        @error.show_error
        @clear = true
        @wait = 55
        return
      end
      #play song if correct
      if OCARINA::SONG[@song] == @memory
        #flag the song to be played
        Audio.se_play('Audio/SE/Ocarina - Song is Correct')
        @play = true
        @wait = 48
        return
      end
      #clear if bar is full
      if size == OCARINA::SONG[@song].size - 1
        @clear = true
        @wait = 20
      end
      return
    end
    #check the song
    OCARINA::SONG.each_index do |i|
      #skip if there is no song or you don't have the song
      next if OCARINA::SONG[i].nil? || !$game_system.ocarina_songs[i]
      #if a song exists
      if OCARINA::SONG[i] == @memory
        #flag the song to be played
        Audio.se_play('Audio/SE/Ocarina - Song is Correct')
        @song = i
        @play = true
        @wait = 48
        return
      end
    end
    #clear bar if full
    if size == 7 
      @clear = true
      @wait = 20
    end
  end
  #dispose all the buttons and clear the memory
  def clear
    return if (@type == 2 || @type == 3) && !$game_temp.ocarina_learning
    @buttons.each{|button| button.dispose}
    @buttons.clear
    @memory.clear
    @clear = false
  end
end

#===============================================================================
# Interpreter
#===============================================================================

class Interpreter
  attr_writer :parameters
  def ocarina_dummy
    #dummy command to pause the interpreter while the ocarina is playing
    ocarina = RPG::EventCommand.new
    ocarina.code = 355
    ocarina.parameters = ['return !$game_temp.ocarina']
    finish = RPG::EventCommand.new
    #if running setup the child interpreter
    if running?
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup([ocarina,finish],0)
    else #else setup the main interpreter
      setup([ocarina,finish],0)
    end
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  alias max_ocarina_main_later main unless $@
  alias max_ocarina_update_later update unless $@
  def main
    max_ocarina_main_later
    #dispose ocarina if it exists
    @ocarina.dispose unless @ocarina.nil?
  end
  
  def update
    max_ocarina_update_later
    if $game_temp.ocarina
      #create the ocarina if it doesn't exist
      if @ocarina.nil? && !$game_temp.message_window_showing
        @ocarina = Ocarina.new 
      end #else update the ocarina if it exists
      @ocarina.update unless @ocarina.nil?
    elsif !@ocarina.nil? #else dispose if needed
      @ocarina.dispose
      @ocarina = nil
    end
  end
end