#===============================================================================
# ¦ PZE Time System
#-------------------------------------------------------------------------------
# Time system built especially for the PZE
#-------------------------------------------------------------------------------
# Author: Maximusmaxy, Silent Resident & Night_Runner
# Version 1.1: 3/Mar/2012
# Thanks to:
# ForeverZer0 - Advance Weather script.
#===============================================================================
#
# Introduction:
# There are three different Time modes available to choose from and use.
#
# 1) Majora's Mask - The Clock is visible on player's screen. The Days are shown
# on the Clock HUD. At the beggining of each Day, there is a message showing
# which Day it is. There is a time limit of 3 Days, at which the player has to
# beat the game. At end of the third (and final) Day you get a Gameover Screen.
#
# 2) Standard - The Clock is visible on player's screen. But instead of Days, 
# the Clock HUD displays when it is daytime in the game's world (Sun - from 
# sunrise to sunset) and when it is nighttime (Moon - from dusk to dawn of next
# day). There is no time limit of 3 days in the game's world (infinite days)
# There is no Gameover Screen at the end of a specific day.
#
# 3) None - No Clock is visible on player's screen, The Clock HUD is disabled.
# There is no day limit or time limit at which the player has to beat the game.
# There is no Gameover Screen at the end of a specific day.
#
# NOTE: The Day/Night Cycle (the Screen Color tones that simulate phases of the
# bright day and the dark night, such as dawn, noon, evening, sunset, dusk, etc)
# and the Weather system are not affectd by the 3 Time modes - and can be
# enabled or disabled separately.
# 
#
# Instructions:
# All the details for enabling/disabling the Time, Tone or Weather are in the
# script calls and the configuration.
#
#                             New in Version 0.4:
# Interior Tilesets:
# You can now specify interior tilesets, these tilesets will not be effected
# by weather or tone, to create a more realistic interior setting without the
# need to change tone/weather every time you change maps. Look in the
# configuration for more information.
#
#                             New in Version 0.5:
# Weather Tilesets:
# You can now specify tilesets that always have a particular type of weather.
# These tilesets will not be effected by the weather of the time system,
# and can have a BGS specified to create a more realistic atmosphere.
# Check the configuration for more details.
#
# Ocarina functions: 
# PZE.storm(hours) - for the song of storms
# PZE.phase_fast_forward - for the suns song
# Chck the script calls for more details.
#
#                             New in Version 0.6:
# Progressive Time Variables:
# These new variables allow you to set up your events to do specific things at 
# specific times with only the one variable condition on the event as opposed
# to many (minute/hour/day). The difference between the progressive variables 
# and the normal variables is the variables don't reset at the end of the hour 
# or day. 
#
# You can work out the progressive time by using one of the following script
# calls:
# PZE.progressive_minute(minute,hour,day)
# PZE.progressive_hour(hour,day)
#
# EG. Say you wanted someone to appear at 4:32AM on the third day exactly.
# You would enter the following script call in an event to check what the
# progressive minute variable will be:
# "p PZE.progressive_minute(32,4,3)"
# This would print out 2792, set the events variable condition to progressive
# minute 2792 and he will appear at 4:32AM on the third day.
#
#                           New in Version 0.7:
# Rotating Clock Tower Disk:
# You are able to implement your own rotating clock tower disk into your games.
# It will rotate based on the current time so the only configuration needed
# to implement it in your game is choosing the map and X/Y location.
# Check the configuration for more details.
#
# Time Debug HUD:
# To make debugging easier I've included the debug HUD i used to debug the time
# system. It can be activated/deactivated on the fly and provides a less
# ambiguous time display, but at the cost of aesthetics. The debug hud is only 
# available in debug mode, and the default key to activate it is F7.
# This can be changed in the configuration.
#
#                           New in Version 0.8:
# Event Time/Location Adjustment(Now compatible with Eventing Shortcuts V0.4):
# To make event patrols more realistic, the location of the event is adjusted
# if the event has pages with custom move routes and a progressive variable.
# It calculates where the event would be if time had passed on the map prior
# to entering it, making it seem as if the event has been continuing his patrol
# as normal.
# Note: If random movements or movements in relation to the player (eg. move
# toward player) are in the custom move route, they will not be accounted for
# and it's advised not to use them for events affected by progressive variables.
#
# Script calls are as follows:
#
# PZE.clock_enable
# PZE.clock_disable
# Enables/Disables the clock
#
# PZE.time_enable
# PZE.time_disable
# Enables/Disables movement of time
#
# PZE.tone_enable
# PZE.tone_disable
# Enables/Disables the tone
#
# PZE.tone_enable(DURATION)
# PZE.tone_disable(DURATION)
# DURATION is how long the change takes
#
# PZE.weather_enable
# PZE.weather_disable
# Enables/Disables the weather
#
# PZE.weather_enable(DURATION)
# PZE.weather_disable(DURATION)
# DURATION is how long the transition takes
#
# PZE.time_normal
# sets time back to normal speed
#
# PZE.time_inverted
# sets time to a third of normal speed
#
# PZE.phase_advance
# advances to the next phase
#
# PZE.phase_reset
# resets back to dawn of the first day if using the 3 day system
#
# PZE.phase_fast_forward
# fast forwards to next phase(the suns song)
#
# Note: If you are planning to use time_set or time_advance in Majora's Mask 
# mode, make sure to disallow certain time progressions that skip past the 
# game over time. 
#
# PZE.time_set(minute, hour) or PZE.time_set(minute, hour, day)
# sets the current time to the minute/hour/day specified
# Note: If no day is specified time will always move forward.
#
# PZE.time_advance(minute, hour) or PZE.time_advance(minute, hour, day)
# advances time by the amount specified.
# 
# PZE.season_summer
# sets Season to Summer
#
# PZE.season_autumn
# sets Season to Autumn
#
# PZE.season_winter
# sets Season to Winter
#
# PZE.season_spring
# sets Season to Spring
#
# PZE.storm(HOURS)
# makes it Storm for however many Hours you specify
#
# PZE.progressive_hour(hour, day)
# returns the amount of Hours passed at specified Hour and Day
#
# PZE.progressive_minute(minute, hour, day)
# returns the amount of Minutes passed at specified Minute/Hour/Day
# 
#===============================================================================

$pze_time = 1.0

module PZE
  #Don't delete this line
  TILESET = []
#===============================================================================
# Configuration
#===============================================================================
  #Set the clock type here, Majora's Mask = 0, Standard = 1, None = 2
  CLOCK = 0
  #Set the clocks visibility, can be changed with the call script.
  CLOCK_VISIBLE = true
  #switches that are activated by time of Day
  DAY_SWITCH = 63         #morning is from 6:00 to 18:00
  NIGHT_SWITCH = 64       #night is from 18:00 to 6:00
  #variables that represent the Time
  MINUTE = 51
  HOUR = 52
  DAY = 53
  #variables that represent how many Minutes/Hours have progressed.
  PROG_MINUTE = 54
  PROG_HOUR = 55
  #variables that represent remaining Time.
  REMAIN_MINUTE = 65
  REMAIN_HOUR = 66
  REMAIN_DAY = 67
  #How many frames to 1 minute in game. Sets the Time Flow's speed. Default = 30
  FRAMES = 30
  #switches that represent the Season
  SUMMER = 65
  AUTUMN = 66
  WINTER = 67
  SPRING = 68
  #choose your starting Season: Summer = 0, Autumn = 1, Winter = 2, Spring = 3
  SEASON = 0
  #Use the Time system, can be changed with the script call
  TIME = true
  #Use the tone system, can be changed with the script call
  TONE = true
  #Use the Weather system, can be changed with the script call
  WEATHER = true
  #State the ID's of interior tilesets here.
  #tilesets included here won't be affected by tone/weather
  INTERIORS = [6,23,24]
  #Switch that is activated when you are inside
  INTERIOR_SWITCH = 69
  #State the ID's of tilesets with a specific weather here.
  #It follows this format:
  #TILESET[ID] = [WEATHER,STRENGTH]
  #             or
  #TILESET[ID] = [WEATHER,STRENGTH,BGS,VOLUME]
  #EG. TILESET[25] = [1,30,'006-Rain02',70] will make it rain on tileset ID 25.
  TILESET[0] = [1,30,'006-Rain02',70]
  #Switch that is activated when Time is inverted
  INVERTED_SWITCH = 70
  #Set whether you want your Day indicator to show the Time speed colors or
  #just regular colors. Green = Normal (default), Blue = Inverted (slow).
  TIME_INVERTED = true
  #Set whether you want your Day indicator to update every 24 Hours as opposed
  #to the beggining of each Day (0:00). 
  HOUR24 = true
  #Set the location of the Clock Tower disk.
  CLOCK_MAP = 12     #set CLOCK_MAP = 0 if not using the clock tower disk.
  CLOCK_X = 374     
  CLOCK_Y = 30
  CLOCK_PRECISION = 0.5
  #Set true if using the Time Debug, this will only be activated in debug mode.
  TIME_DEBUG = true
  #Set the key to enable/disable the Time Debug HUD
  TIME_DEBUG_INPUT = Input::F7
#===============================================================================
# End Configuration
#===============================================================================
  
  def self.clock_enable
    $game_system.clock_visible(true)    
  end
  
  def self.clock_disable
    $game_system.clock_visible(false)
  end
  
  def self.time_enable
    $game_system.time_active(true)
  end
  
  def self.time_disable
    $game_system.time_active(false)
  end
  
  def self.tone_enable(duration = 0)
    $game_system.tone_active(true,duration)
  end
  
  def self.tone_disable(duration = 0)
    $game_system.tone_active(false,duration)
  end
  
  def self.weather_enable(duration = 0)
    $game_system.weather_active(true,duration)
  end
  
  def self.weather_disable(duration = 0)
    $game_system.weather_active(false,duration)
  end
  
  def self.time_normal
    $game_system.time_normal
  end
  
  def self.time_inverted
    $game_system.time_inverted
  end
  
  def self.phase_advance
    $game_system.time_phase_advance
    return true
  end
  
  def self.phase_reset
    $game_system.time_phase_reset
    return true
  end
  
  def self.phase_fast_forward
    $game_system.time_fast_forward
  end
  
  def self.time_set(minute, hour, day = 0)
    $game_system.time_set(minute, hour, day)
  end
  
  def self.time_advance(minute, hour, day = 0)
    $game_system.time_advance(minute, hour, day)
  end
  
  def self.season_summer
    self.season_reset
    $game_system.pze_summer = true
    $game_switches[SUMMER] = true
    $game_screen.reset_tone_weather
  end
  
  def self.season_autumn
    self.season_reset
    $game_system.pze_autumn = true
    $game_switches[AUTUMN] = true
    $game_screen.reset_tone_weather
  end
  
  def self.season_winter
    self.season_reset
    $game_system.pze_winter = true
    $game_switches[WINTER] = true
    $game_screen.reset_tone_weather
  end
  
  def self.season_spring
    self.season_reset
    $game_system.pze_spring = true
    $game_switches[SPRING] = true
    $game_screen.reset_tone_weather
  end
  
  def self.season_reset
    $game_system.pze_summer = false
    $game_system.pze_autumn = false
    $game_system.pze_winter = false
    $game_system.pze_spring = false
    $game_switches[SUMMER] = false
    $game_switches[AUTUMN] = false
    $game_switches[WINTER] = false
    $game_switches[SPRING] = false
    $game_map.need_refresh = true
  end
  
  def self.storm(hours)
    $game_system.weather_storm(hours)
  end  
  
  def self.progressive_hour(hour, day)
    return $game_system.get_prog_hour(hour, day)
  end
  
  def self.progressive_minute(minute, hour, day)
    return $game_system.get_prog_minute(minute, hour, day)
  end
  
  def self.disk_fade(fade)
    $game_temp.pze_disk_fade = fade
    return
  end
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor :pze_time_increment
  attr_accessor :pze_storm
  attr_accessor :pze_time_reset
  attr_accessor :pze_time_debug
  alias max_time_initialize_later initialize unless $@
  def initialize
    max_time_initialize_later
    #temp variables for storm/fast forward
    @pze_time_increment = 0
    @pze_storm = 0
    @pze_time_reset = false
    @pze_time_debug = false
  end
end

#===============================================================================
# Game_Switches
#===============================================================================

class Game_Switches
  alias max_time_initialize_later initialize unless $@
  def initialize
    max_time_initialize_later
    case PZE::SEASON
    when 0 then @data[PZE::SUMMER] = true
    when 1 then @data[PZE::AUTUMN] = true
    when 2 then @data[PZE::WINTER] = true
    when 3 then @data[PZE::SPRING] = true
    end
  end
end
    

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :pze_time_active
  attr_accessor :pze_tone_active
  attr_accessor :pze_weather_active
  attr_accessor :pze_summer
  attr_accessor :pze_autumn
  attr_accessor :pze_winter
  attr_accessor :pze_spring
  attr_reader :pze_clock_visible
  attr_reader :pze_count
  attr_reader :pze_minute
  attr_reader :pze_hour
  attr_reader :pze_day
  attr_reader :pze_time_increment
  attr_reader :pze_minute_prog
  attr_reader :pze_hour_prog
  attr_reader :pze_time_inverted
  attr_reader :pze_night
  alias max_time_initialize_later initialize unless $@
  alias max_time_update_later update unless $@
  def initialize
    #hud variable
    @pze_clock_visible = PZE::CLOCK_VISIBLE
    #time variables
    @pze_time_active = PZE::TIME
    @pze_time_increment = 1
    @pze_time_inverted = false
    @pze_minute = 0
    @pze_hour = 6
    @pze_day = 1
    @pze_count = 0
    @pze_original_minute = @pze_minute
    @pze_original_hour = @pze_hour
    @pze_night = false
    #progressive time variables
    @pze_minute_prog = 0
    @pze_hour_prog = 0
    #weather variables
    @pze_tone_active = PZE::TONE
    @pze_weather_active = PZE::WEATHER
    @pze_summer = (PZE::SEASON == 0 ? true : false)
    @pze_autumn = (PZE::SEASON == 1 ? true : false)
    @pze_winter = (PZE::SEASON == 2 ? true : false)
    @pze_spring = (PZE::SEASON == 3 ? true : false)
    max_time_initialize_later
  end
  
  def update
    max_time_update_later
    pze_time_update
  end
  
  def pze_time_update
    #increment count
    return unless @pze_time_active && !$game_system.map_interpreter.running?
    @pze_count += 1
    #increment minute
    if @pze_count >= PZE::FRAMES * @pze_time_increment
      @pze_minute += ($game_temp.pze_time_increment > 0 ? 5 : 1)
      @pze_count = 0
    end
    #increment hour
    if @pze_minute >= 60
      @pze_minute = 0
      @pze_hour += 1
    end
    #increment day
    if @pze_hour >= 24
      @pze_hour = 0
      @pze_day += 1
    end
    #adjust progressive minute/hour
    @pze_hour_prog = get_prog_hour(@pze_hour, @pze_day)
    @pze_minute_prog = get_prog_minute(@pze_minute, @pze_hour, @pze_day)
    #adjust time variables if fast forwarding
    if $game_temp.pze_time_increment > 0
      if @pze_minute == 0 && (@pze_hour == 6 || @pze_hour == 18)
        @pze_time_increment = $game_temp.pze_time_increment
        $game_temp.pze_time_increment = 0
      end
    end
    #adjust tone/weather if storming
    if $game_temp.pze_storm > @pze_minute_prog
      $game_temp.pze_storm = 0
      $game_screen.set_time_tone
      $game_screen.set_time_weather
    end
    #change day/night switches
    if @pze_hour >= 6 && @pze_hour < 18 #day
      $game_switches[PZE::DAY_SWITCH] = true
      $game_switches[PZE::NIGHT_SWITCH] = false
      @pze_night = false
    else
      $game_switches[PZE::DAY_SWITCH] = false
      $game_switches[PZE::NIGHT_SWITCH] = true
      @pze_night = true
    end
    #change minute/hour/day variables
    if @pze_minute != $game_variables[PZE::MINUTE] #minute
      $game_variables[PZE::MINUTE] = @pze_minute
      $game_variables[PZE::PROG_MINUTE] = @pze_minute_prog
      $game_variables[PZE::REMAIN_MINUTE] = 60 - @pze_minute
      $game_map.need_time_refresh = true
    end 
    if @pze_hour != $game_variables[PZE::HOUR] #hour
      $game_variables[PZE::HOUR] = @pze_hour
      $game_variables[PZE::PROG_HOUR] = @pze_hour_prog
      $game_variables[PZE::REMAIN_HOUR] = 72 - @pze_hour_prog
      $game_map.need_time_refresh = true
    end
    if @pze_day != $game_variables[PZE::DAY] #day
      $game_variables[PZE::DAY] = @pze_day
      $game_variables[PZE::REMAIN_DAY] = 3 - @pze_day
      $game_map.need_time_refresh = true
    end
    #show message at beggining of phase
    if @pze_hour == 6 && @pze_minute == 0 && @pze_count == 0 && PZE::CLOCK == 0
      @pze_count += 1
      $scene = Scene_Phase_Message.new
    end
    #play rooster (cucco) or wolf sound
    if @pze_minute == 2 && @pze_count == 0 && PZE::CLOCK == 0
      if @pze_hour == 6
        Audio.me_play('Audio/ME/Day-Night Cycle - 6am Rooster', 100)
      elsif @pze_hour == 18
        Audio.me_play('Audio/ME/Day-Night Cycle - 6pm Wolf', 70)
        #show the night message if map names exists
        if !$pze_map_names.nil? && $pze_map_names >= 0.3 
          if MAP_NAMES::TYPE == 2
            case @pze_day
            when 1
              text1 = 'Night of the First Day'
              text2 = '-60 Hours Remain-'
            when 2
              text1 = 'Night of the Second Day'
              text2 = '-36 Hours Remain-'
            when 3
              text1 = 'Night of the Final Day'
              text2 = '-12 Hours Remain-'
            end
            MAP_NAMES.show(text1, text2, false)
          end
        end        
      end
    end
    #update tone/weather every half hour
    if @pze_minute % 30 == 0 && @pze_count == 0
      unless PZE::INTERIORS.include?($game_map.tileset_id) ||
            !PZE::TILESET[$game_map.tileset_id].nil?
        $game_screen.set_time_tone if @pze_tone_active
        $game_screen.set_time_weather if @pze_weather_active
        $game_map.need_refresh = true
      end
    end
  end
  #resets time speed back to normal
  def time_normal
    @pze_count = 0
    @pze_time_increment = 1
    @pze_time_inverted = false
    $game_variables[PZE::INVERTED_SWITCH] = false
    $game_temp.pze_time_increment = 0
  end
  #makes time go a third of normal speed
  def time_inverted
    @pze_count = 0
    @pze_time_increment = 3
    @pze_time_inverted = true
    $game_variables[PZE::INVERTED_SWITCH] = true
    $game_temp.pze_time_increment = 0
  end
  #advances to next time phase
  def time_phase_advance
    if @pze_hour >= 6 && @pze_hour < 18 #night
      @pze_hour = 18
    else #morning
      @pze_day += 1 if @pze_hour >= 18  
      @pze_hour = 6
      if PZE::CLOCK == 0
        $game_temp.pze_time_reset = true
        $scene = Scene_Phase_Message.new 
      end
    end
    @pze_count = 1
    @pze_minute = 0
    @pze_hour_prog = get_prog_hour(@pze_hour, @pze_day)
    @pze_minute_prog = get_prog_minute(@pze_minute, @pze_hour, @pze_day)
    @pze_night = !@pze_night
    if $game_temp.pze_time_increment != 0
      @pze_time_increment = $game_temp.pze_time_increment
      $game_temp.pze_time_increment = 0
    end
    $game_temp.pze_storm = 0
    $game_screen.reset_tone_weather
    return
  end
  #resets back to beggining of first phase
  def time_phase_reset
    @pze_count = 1
    @pze_minute = @pze_original_minute
    @pze_hour = @pze_original_hour
    @pze_day = 1
    @pze_hour_prog = 0
    @pze_minute_prog = 0
    @pze_time_increment = 1
    $game_variables[PZE::INVERTED_SWITCH] = false
    @pze_night = false
    $game_temp.pze_time_increment = 0
    $game_temp.pze_storm = 0
    $game_screen.reset_tone_weather
    $game_temp.pze_time_reset = true
    $scene = Scene_Phase_Message.new if PZE::CLOCK == 0
    return
  end
  #fast forward to next phase
  def time_fast_forward
    $game_temp.pze_time_increment = @pze_time_increment
    @pze_time_increment = 0.001
  end  
  #shows/hides the clock hud
  def clock_visible(visible)
    @pze_clock_visible = visible
    return
  end 
  #plays, pauses time
  def time_active(active)
    @pze_time_active = active
    return
  end
  #activates/deactivates tone
  def tone_active(active, duration = 0)
    @pze_tone_active = active
    $game_map.need_refresh = true
    $game_screen.reset_tone_weather(duration)
    return
  end
  #activates/deactivates weather
  def weather_active(active, duration = 0)
    @pze_weather_active = active
    $game_map.need_refresh = true
    $game_screen.reset_tone_weather(duration)
    return
  end
  #sets the time to a certain minute/hour
  def time_set(minute, hour, day = 0)
    #do not go before 6AM on first day
    hour = 6 if day == 1 && hour < @pze_original_hour
    #advance the day if needed and no day is specified
    if day == 0 && (@pze_hour > hour || (@pze_hour == hour &&
                                         @pze_minute > minute))
      day = @pze_day + 1
    else
      day = @pze_day
    end
    #set the variables
    @pze_count = 1
    @pze_minute = minute
    @pze_hour = hour
    @pze_day = day
    @pze_hour_prog = get_prog_hour(@pze_hour, @pze_day)
    @pze_minute_prog = get_prog_minute(@pze_minute, @pze_hour, @pze_day)
    $game_temp.pze_storm = 0
    $game_screen.reset_tone_weather
    if $game_temp.pze_time_increment != 0
      @pze_time_increment = $game_temp.pze_time_increment
      $game_temp.pze_time_increment = 0
    end
    return
  end
  #advances time by minute/hour/day
  def time_advance(minute, hour, day = 0)
    @pze_count = 1
    hour += (@pze_minute + minute) / 60
    day += (@pze_hour + hour) / 24
    @pze_hour = (@pze_hour + hour) % 24
    @pze_minute = (@pze_minute + minute) % 60
    @pze_day = (@pze_day + day)
    @pze_hour_prog = get_prog_hour(@pze_hour, @pze_day)
    @pze_minute_prog = get_prog_minute(@pze_minute, @pze_hour, @pze_day)
    $game_temp.pze_storm = 0
    $game_screen.reset_tone_weather
    if $game_temp.pze_time_increment != 0
      @pze_time_increment = $game_temp.pze_time_increment
      $game_temp.pze_time_increment = 0
    end
    return
  end
  #Makes it storm
  def weather_storm(hours)
    $game_temp.pze_storm = @pze_minute_prog + hours * 60
    unless PZE::INTERIORS.include?($game_map.tileset_id)
      $game_screen.start_tone_change(Tone.new(-100,-50,50,50),100)
      $game_screen.weather(36,40,100)
      Audio.bgs_play('Audio/BGS/006-Rain02', 90)
    end
    return
  end
  #returns the progressive minute
  def get_prog_minute(minute, hour, day)
    return (minute - @pze_original_minute) + (hour - @pze_original_hour) * 60 +
           (day - 1) * 1440
  end
  #returns the progressive hour
  def get_prog_hour(hour, day)
    return (hour - @pze_original_hour) + (day - 1) * 24
  end
end

#===============================================================================
# Game_Screen
#===============================================================================

class Game_Screen
  attr_accessor :tone
  alias max_time_initialize_later initialize unless $@
  def initialize
    max_time_initialize_later
    #change initial tone to the tone of the hour
    @tone = get_time_tone if $game_system.pze_tone_active
  end
  #resets the tone/weather
  def reset_tone_weather(duration = 0)
    if $game_system.pze_tone_active &&
       !PZE::INTERIORS.include?($game_map.tileset_id)
      start_tone_change(get_time_tone, duration)
    else
      start_tone_change(Tone.new(0, 0, 0, 0), duration)
    end
    if $game_system.pze_weather_active && 
       !PZE::INTERIORS.include?($game_map.tileset_id)
      weather(get_time_weather,get_strength_weather,duration)
    else
      weather(0,0,0)
      Audio.bgs_stop
    end
  end
  #changes the tone of the screen dependant on the hour
  def set_time_tone
    start_tone_change(get_time_tone, $game_temp.pze_time_increment == 0 ? (
    PZE::FRAMES * 30 * $game_system.pze_time_increment) : 30)
  end
  #returns the tone for the hour
  def get_time_tone
    #Storm tone
    if $game_temp.pze_storm != 0
      return Tone.new(-100,-50,50,50)
    end
   if PZE::CLOCK == 0 #Majora's Mask Mode
      case $game_system.pze_day
      when 1 #1st Day
        case $game_system.pze_hour
        #the 1st Day begins - daytime
        when 6
          if $game_system.pze_minute < 30 
            return Tone.new(-28,-18,48,45) #6:00
          else 
            return Tone.new(-25,-16,46,43) #6:30
          end
        when 7
          if $game_system.pze_minute < 30 
            return Tone.new(-23,-14,43,40) #7:00
          else
            return Tone.new(-19,-12,41,35) #7:30
          end
        when 8
          if $game_system.pze_minute < 30 
            return Tone.new(-15,-10,38,30) #8:00
          else
            return Tone.new(-11,-8,32,25) #8:30
          end
        when 9
          if $game_system.pze_minute < 30 
            return Tone.new(-7,-5,25,18) #9:00
          else
            return Tone.new(-4,-2,18,10) #9:30
          end
        when 10
          if $game_system.pze_minute < 30 
            return Tone.new(0,-2,7,5) #10:00
          else
            return Tone.new(0,0,0,0) #10:30
          end
        when 11,12
          return Tone.new(0,0,0,0)
        when 13
          if $game_system.pze_minute < 30 
            return Tone.new(0,0,0,0) #13:00
          else
            return Tone.new(2,1,-5,2) #13:30
          end
        when 14
          if $game_system.pze_minute < 30 
            return Tone.new(5,3,-8,4) #14:00
          else
            return Tone.new(9,5,-10,6) #14:30
          end
        when 15
          if $game_system.pze_minute < 30 
            return Tone.new(12,8,-12,9) #15:00
          else
            return Tone.new(15,10,-14,12) #15:30
          end
        when 16
          if $game_system.pze_minute < 30 
            return Tone.new(18,15,-18,15) #16:00
          else
            return Tone.new(25,8,-25,23) #16:30
          end
        when 17
          if $game_system.pze_minute < 30 
            return Tone.new(40,-10,-60,32) #17:00
          else
            return Tone.new(55,-18,-50,40) #17:30
          end
        #nighttime begins
        when 18
          if $game_system.pze_minute < 30 
            return Tone.new(25,-23,-30,45) #18:00
          else
            return Tone.new(5,-26,-15,48) #18:30
          end
        when 19
          if $game_system.pze_minute < 30 
            return Tone.new(-20,-30,0,50) #19:00
          else
            return Tone.new(-35,-32,2,52) #19:30
          end
        when 20
          if $game_system.pze_minute < 30 
            return Tone.new(-45,-35,5,54) #20:00
          else
            return Tone.new(-65,-40,10,56) #20:30
          end
        when 21
          if $game_system.pze_minute < 30 
            return Tone.new(-75,-45,15,58) #21:00
          else
            return Tone.new(-85,-50,17,61) #21:30
          end
        when 22
          if $game_system.pze_minute < 30 
            return Tone.new(-90,-55,20,65) #22:00
          else
            return Tone.new(-95,-60,22,70) #22:30
          end
        when 23
          return Tone.new(-100,-60,25,80)
        else
          return Tone.new(0,0,0,0) #This will not appear ingame
        end
      when 2 #2nd Day
        case $game_system.pze_hour
        #the 2nd Day begins
        when 0 
          return Tone.new(-100,-65,25,85)
        when 1
          if $game_system.pze_minute < 30 
            return Tone.new(-100,-60,25,88) #1:00
          else
            return Tone.new(-100,-65,25,95) #1:30
          end
        when 2
          if $game_system.pze_minute < 30 
            return Tone.new(-100,-65,25,100) #2:00
          else
            return Tone.new(-100,-65,25,105) #2:30
          end
        when 3
          if $game_system.pze_minute < 30 
            return Tone.new(-95,-62,25,110) #3:00
          else
            return Tone.new(-90,-60,25,115) #3:30
          end
        when 4
          if $game_system.pze_minute < 30 
            return Tone.new(-85,-55,25,120) #4:00
          else
            return Tone.new(-80,-50,25,125) #4:30
          end
        when 5
          if $game_system.pze_minute < 30 
            return Tone.new(-75,-45,25,130) #5:00
          else
            return Tone.new(-70,-40,25,135) #5:30
          end
        #daytime begins
        when 6
          if $game_system.pze_minute < 30 
            return Tone.new(-65,-35,25,140) #6:00
          else 
            return Tone.new(-60,-30,25,145) #6:30
          end
        when 7
          if $game_system.pze_minute < 30 
            return Tone.new(-55,-25,25,150) #7:00
          else
            return Tone.new(-50,-20,25,150) #7:30
          end
        when 8
          if $game_system.pze_minute < 30 
            return Tone.new(-45,-15,25,150) #8:00
          else
            return Tone.new(-43,-13,25,150) #8:30
          end
        when 9,10
          return Tone.new(-40,-10,25,150)
        when 11
          if $game_system.pze_minute < 30 
            return Tone.new(-17,0,5,150) #11:00
          else
            return Tone.new(-15,-2,3,150) #11:30
          end
        when 12
          if $game_system.pze_minute < 30 
            return Tone.new(-13,-5,0,150) #12:00
          else
            return Tone.new(-11,-7,-2,150) #12:30
          end
        when 13
          if $game_system.pze_minute < 30 
            return Tone.new(-10,-9,-5,150) #13:00
          else
            return Tone.new(-10,-11,-7,150) #13:30
          end
        when 14
          if $game_system.pze_minute < 30 
            return Tone.new(-10,-13,-10,150) #14:00
          else
            return Tone.new(-10,-15,-13,150) #14:30
          end
        when 15
          if $game_system.pze_minute < 30 
            return Tone.new(-10,-17,-16,150) #15:00
          else
            return Tone.new(-10,-20,-19,150) #15:30
          end
        when 16
          if $game_system.pze_minute < 30 
            return Tone.new(-10,-23,-22,150) #16:00
          else
            return Tone.new(0,-25,-25,150) #16:30
          end
        when 17
          if $game_system.pze_minute < 30 
            return Tone.new(15,-30,-30,150) #17:00
          else
            return Tone.new(10,-35,-25,150) #17:30
          end
        #nighttime begins
        when 18
          if $game_system.pze_minute < 30 
            return Tone.new(-10,-40,-10,150) #18:00
          else
            return Tone.new(-30,-45,0,150) #18:30
          end
        when 19
          if $game_system.pze_minute < 30 
            return Tone.new(-55,-50,5,150) #19:00
          else
            return Tone.new(-65,-50,10,145) #19:30
          end
        when 20
          if $game_system.pze_minute < 30 
            return Tone.new(-70,-50,13,140) #20:00
          else
            return Tone.new(-75,-55,16,135) #20:30
          end
        when 21
          if $game_system.pze_minute < 30 
            return Tone.new(-80,-55,19,120) #21:00
          else
            return Tone.new(-85,-55,21,105) #21:30
          end
        when 22
          if $game_system.pze_minute < 30 
            return Tone.new(-90,-60,23,95) #22:00
          else
            return Tone.new(-95,-60,25,85) #22:30
          end
        when 23
          return Tone.new(-100,-60,25,80)
        else
          return Tone.new(0,0,0,0) #This will not appear ingame
        end
      when 3 #Final Day
        case $game_system.pze_hour
        #the Final Day begins
        when 0 
          return Tone.new(-100,-60,25,80)
        when 1
          if $game_system.pze_minute < 30 
            return Tone.new(-97,-50,50,50) #1:00
          else
            return Tone.new(-95,-50,50,50) #1:30
          end
        when 2
          if $game_system.pze_minute < 30 
            return Tone.new(-90,-50,50,50) #2:00
          else
            return Tone.new(-85,-50,50,50) #2:30
          end
        when 3
          if $game_system.pze_minute < 30 
            return Tone.new(-80,-50,50,50) #3:00
          else
            return Tone.new(-75,-50,50,50) #3:30
          end
        when 4
          if $game_system.pze_minute < 30 
            return Tone.new(-65,-50,50,50) #4:00
          else
            return Tone.new(-55,-40,50,50) #4:30
          end
        when 5
          if $game_system.pze_minute < 30 
            return Tone.new(-45,-30,50,50) #5:00
          else
            return Tone.new(-35,-20,50,50) #5:30
          end
        #daytime begins
        when 6
          if $game_system.pze_minute < 30 
            return Tone.new(0,-10,50,25) #6:00
          else 
            return Tone.new(0,-8,40,20) #6:30
          end
        when 7
          if $game_system.pze_minute < 30 
            return Tone.new(0,-6,30,15) #7:00
          else
            return Tone.new(0,-5,20,10) #7:30
          end
        when 8
          if $game_system.pze_minute < 30 
            return Tone.new(0,-3,14,8) #8:00
          else
            return Tone.new(0,-2,7,5) #8:30
          end
        when 9,10
          return Tone.new(0,0,0,0)
        when 11
          if $game_system.pze_minute < 30 
            return Tone.new(2,1,-5,3) #11:00
          else
            return Tone.new(5,3,-10,6) #11:30
          end
        when 12
          if $game_system.pze_minute < 30 
            return Tone.new(10,5,-18,9) #12:00
          else
            return Tone.new(13,10,-25,12) #12:30
          end
        when 13
          return Tone.new(18,13,-30,15) #13:00
        when 14
          if $game_system.pze_minute < 30 
            return Tone.new(23,15,-35,17) #14:00
          else
            return Tone.new(27,20,-40,22) #14:30
          end
        when 15
          if $game_system.pze_minute < 30 
            return Tone.new(35,20,-50,25) #15:00
          else
            return Tone.new(45,10,-75,30) #15:30
          end
        when 16
          if $game_system.pze_minute < 30 
            return Tone.new(55,0,-90,35) #16:00
          else
            return Tone.new(75,-10,-110,40) #16:30
          end
        when 17
          if $game_system.pze_minute < 30 
            return Tone.new(90,-20,-150,50) #17:00
          else
            return Tone.new(65,-30,-90,55) #17:30
          end
        #nighttime begins
        when 18
          if $game_system.pze_minute < 30 
            return Tone.new(25,-40,-30,55) #18:00
          else
            return Tone.new(-20,-50,0,50) #18:30
          end
        when 19
          if $game_system.pze_minute < 30 
            return Tone.new(-45,-50,20,50) #19:00
          else
            return Tone.new(-60,-50,40,50) #19:30
          end
        when 20
          if $game_system.pze_minute < 30 
            return Tone.new(-80,-50,50,50) #20:00
          else
            return Tone.new(-90,-50,50,50) #20:30
          end
        when 21,22,23
          return Tone.new(-100,-50,50,50)
        else
          return Tone.new(0,0,0,0) #This will not appear ingame
        end
      when 4 #New Day
        case $game_system.pze_hour
        #First 6 hours of New Day
        when 0 
          return Tone.new(-100,-50,50,50)
        when 1
          if $game_system.pze_minute < 30 
            return Tone.new(-97,-50,50,50) #1:00
          else
            return Tone.new(-95,-50,50,50) #1:30
          end
        when 2
          if $game_system.pze_minute < 30 
            return Tone.new(-90,-50,50,50) #2:00
          else
            return Tone.new(-85,-50,50,50) #2:30
          end
        when 3
          if $game_system.pze_minute < 30 
            return Tone.new(-80,-50,50,50) #3:00
          else
            return Tone.new(-70,-50,50,50) #3:30
          end
        when 4
          if $game_system.pze_minute < 30 
            return Tone.new(-55,-50,50,50) #4:00
          else
            return Tone.new(-45,-40,50,50) #4:30
          end
        when 5
          if $game_system.pze_minute < 30 
            return Tone.new(-25,-30,50,50) #5:00
          else
            return Tone.new(-5,-20,50,50) #5:30
          end
        else
          return Tone.new(0,0,0,0) #This will not appear ingame
        end
      end
    else #Standard/No Clock mode
    if $game_system.pze_winter #winter
      case $game_system.pze_hour
      when 23, 0..1 #dusk
        return Tone.new(-100, -50, 50, 50)
      when 2..4 #night
        return Tone.new(-50, -40, 50, 50)
      when 5..7 #dawn
        return Tone.new(0, -30, 50, 50)
      when 8..11 #day
        return Tone.new(0, 0, 0, 0)
      when 12..14 #midday
        return Tone.new(15, 10, 10, 15)
      when 15..17 #evening
        return Tone.new(10, 25, 10, 35)
      when 18..19 #sunset
        return Tone.new(20, 0, 10, 100)
      when 20..22 #twilight
        return Tone.new(-25, -50, 20, 50)
      end
    else #summer/spring/autumn
      case $game_system.pze_hour
      #day begins
      when 6
        if $game_system.pze_minute < 30 
          return Tone.new(0,-10,50,25) #6:00
        else 
          return Tone.new(0,-8,40,20) #6:30
        end
      when 7
        if $game_system.pze_minute < 30 
          return Tone.new(0,-6,30,15) #7:00
        else
          return Tone.new(0,-5,20,10) #7:30
        end
      when 8
        if $game_system.pze_minute < 30 
          return Tone.new(0,-3,14,8) #8:00
        else
          return Tone.new(0,-2,7,5) #8:30
        end
      when 9,10
        return Tone.new(0,0,0,0)
      when 11
        if $game_system.pze_minute < 30 
          return Tone.new(2,1,-5,3) #11:00
        else
          return Tone.new(5,3,-10,6) #11:30
        end
      when 12
        if $game_system.pze_minute < 30 
          return Tone.new(10,5,-18,9) #12:00
        else
          return Tone.new(13,10,-25,12) #12:30
        end
      when 13
        return Tone.new(18,13,-30,15)
      when 14
        if $game_system.pze_minute < 30 
          return Tone.new(23,15,-35,17) #14:00
        else
          return Tone.new(27,20,-40,22) #14:30
        end
      when 15
        if $game_system.pze_minute < 30 
          return Tone.new(35,20,-50,25) #15:00
        else
          return Tone.new(45,10,-75,30) #15:30
        end
      when 16
        if $game_system.pze_minute < 30 
          return Tone.new(55,0,-90,35) #16:00
        else
          return Tone.new(75,-10,-110,40) #16:30
        end
      when 17
        if $game_system.pze_minute < 30 
          return Tone.new(90,-20,-150,50) #17:00
        else
          return Tone.new(65,-30,-90,55) #17:30
        end
      #night begins
      when 18
        if $game_system.pze_minute < 30 
          return Tone.new(25,-40,-30,55) #18:00
        else
          return Tone.new(-20,-50,0,50) #18:30
        end
      when 19
        if $game_system.pze_minute < 30 
          return Tone.new(-45,-50,20,50) #19:00
        else
          return Tone.new(-60,-50,40,50) #19:30
        end
      when 20
        if $game_system.pze_minute < 30 
          return Tone.new(-80,-50,50,50) #20:00
        else
          return Tone.new(-90,-50,50,50) #20:30
        end
      when 21,22,23,0 
        return Tone.new(-100,-50,50,50)
      when 1
        if $game_system.pze_minute < 30 
          return Tone.new(-97,-50,50,50) #1:00
        else
          return Tone.new(-95,-50,50,50) #1:30
        end
      when 2
        if $game_system.pze_minute < 30 
          return Tone.new(-90,-50,50,50) #2:00
        else
          return Tone.new(-85,-50,50,50) #2:30
        end
      when 3
        if $game_system.pze_minute < 30 
          return Tone.new(-80,-50,50,50) #3:00
        else
          return Tone.new(-70,-50,50,50) #3:30
        end
      when 4
        if $game_system.pze_minute < 30 
          return Tone.new(-55,-50,50,50) #4:00
        else
          return Tone.new(-45,-40,50,50) #4:30
        end
      when 5
        if $game_system.pze_minute < 30 
          return Tone.new(-25,-30,50,50) #5:00
        else
          return Tone.new(-5,-20,50,50) #5:30
        end
      end
    end
  end
  end
  #changes the weather dependant on the hour
  def set_time_weather
    weather(get_time_weather,get_strength_weather,
    $game_temp.pze_time_increment == 0 ? (
    PZE::FRAMES * 30 * $game_system.pze_time_increment) : 30)
  end
  #returns the weather for the hour
  def get_time_weather
    Audio.bgs_stop
    #storm weather
    if $game_temp.pze_storm != 0
      Audio.bgs_play('Audio/BGS/006-Rain02', 70)
      return 36
    end
    if PZE::CLOCK == 0 #Majora's Mask Mode
      case $game_system.pze_day
      when 2 #2nd Day
        case $game_system.pze_hour
        when 7,11,12,13,16
          Audio.bgs_play('Audio/BGS/006-Rain02', 70)
          return 1 #Rain
        when 8,9,10,14,15
          Audio.bgs_play('Audio/BGS/006-Rain02', 80)
          return 36 #Thunderstorm
        else #Every other hour then the ones not specified
          return 0 #no weather
        end
      else
        return 0 #no weather
      end
    else #Standard/No Clock Mode
    if $game_system.pze_summer #summer
      case $game_system.pze_hour
      when 21 #evening
        Audio.bgs_play('Audio/BGS/006-Rain02', 80)
        return 1 #rain
      when 22,23,0,1 #night
        Audio.bgs_play('Audio/BGS/006-Rain02', 90)
        return 5 #thunder
      when 2
        Audio.bgs_play('Audio/BGS/006-Rain02', 70)
        $game_system.bgs_fade(100)
        return 0 #nothing
      else 
        return 0 #nothing
      end
    elsif $game_system.pze_autumn #autumn
      case $game_system.pze_hour
      when 9, 10, 11, 12, 13, 14 #mid day
        return 8 #leaves
      when 21 #evening
        Audio.bgs_play('Audio/BGS/006-Rain02', 80)
        return 1 #rain
      when 22,23,0,1 #night
        Audio.bgs_play('Audio/BGS/006-Rain02', 90)
        return 5 #thunder
      when 2
        Audio.bgs_play('Audio/BGS/006-Rain02', 70)
        $game_system.bgs_fade(100)
        return 0
      else
        return 0 #nothing
      end
    elsif $game_system.pze_winter #winter
      return 16 #snow
    elsif $game_system.pze_spring #spring
      case $game_system.pze_hour
      when 21 #evening
        Audio.bgs_play('Audio/BGS/006-Rain02', 80)
        return 1 #rain
      when 22,23,0,1 #night
        Audio.bgs_play('Audio/BGS/006-Rain02', 90)
        return 5 #thunder
      when 2
        Audio.bgs_play('Audio/BGS/006-Rain02', 70)
        $game_system.bgs_fade(100)
        return 0 #nothing
      else 
        return 0 #nothing
      end
    end
    end
  end
  #returns the strength of the weather
  def get_strength_weather
    if PZE::CLOCK == 0 #Majora's Mask Mode
      case $game_system.pze_day
      when 2
        case $game_system.pze_hour
        when 7,11,12,13,16
          return 25
        when 8,9,10,14,15
          return 35
        else
          return 25
        end
      else
        return 0
      end
    else
    if $game_system.pze_winter #winter
      case $game_system.pze_hour
      when 20, 21, 22, 23, 0, 1, 2, 3, 4
        return 40 #stong
      when 18, 19, 5, 6
        return 30 #medium
      else
        return 25 #normal
      end
    elsif $game_system.pze_autumn #autmn
      case $game_system.pze_hour
      when 10, 11, 12, 13
        return 25 #normal
      when 21,22,23,0,1
        return 30 #strong
      else
        return 10 #weak
      end
    else #summer/spring
      return 30 #normal
    end
    end
  end
end
  
#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  attr_reader :tileset_id
  attr_accessor :need_time_refresh
  alias max_time_setup_later setup unless $@
  alias max_time_update_later update unless $@
  def setup(*args)
    max_time_setup_later(*args)
    @tileset_id = @map.tileset_id
    #change tone/weather if interior
    if PZE::INTERIORS.include?(@tileset_id)
      $game_switches[PZE::INTERIOR_SWITCH] = true
      if $game_system.pze_tone_active
        $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 0)
      end
      if $game_system.pze_weather_active
        $game_screen.weather(0, 0, 0)
        Audio.bgs_stop
      end
    #change tone/weather if a specific tileset
    elsif !PZE::TILESET[@tileset_id].nil?
      $game_switches[PZE::INTERIOR_SWITCH] = false
      if $game_system.pze_tone_active
        $game_screen.start_tone_change($game_screen.get_time_tone, 0)
      end
      if $game_system.pze_weather_active
        $game_screen.weather(PZE::TILESET[@tileset_id][0],
        PZE::TILESET[@tileset_id][1],0)
        Audio.bgs_play('Audio/BGS/' + PZE::TILESET[@tileset_id][2],
        PZE::TILESET[@tileset_id][3]) unless PZE::TILESET[@tileset_id][2].nil?
      end
    #else use a regular tone
    else
      $game_switches[PZE::INTERIOR_SWITCH] = false
      if $game_system.pze_tone_active
        $game_screen.start_tone_change($game_screen.get_time_tone, 0)
      end
      if $game_system.pze_weather_active
        $game_screen.weather($game_screen.get_time_weather,
        $game_screen.get_strength_weather,0)
      end
    end
    #flag for time refresh
    @need_time_refresh = false
  end
  
  def update
    #refresh only the time events if needed
    if @need_time_refresh
      time_refresh unless @need_refresh
      @need_time_refresh = false
    end
    max_time_update_later
  end
  #refresh only the events effected by time variables
  def time_refresh
    @events.each_value { |event| event.refresh if event.time_event }
    @common_events.each_value { |event| event.refresh if event.time_event }
  end
end

#===============================================================================
# Game_CommonEvent
#===============================================================================

class Game_CommonEvent
  attr_reader :time_event
  alias max_time_initialize_later initialize unless $@
  def initialize(*args)
    @time_event = false
    max_time_initialize_later(*args)
    #if the trigger is autorun or parallel
    if trigger > 0
      #if the trigger is a time switch
      if switch_id == PZE::DAY_SWITCH || switch_id == PZE::NIGHT_SWITCH
        #common event is a time event
        @time_event = true
      end
    end
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_reader :time_event
  alias max_time_initialize_later initialize unless $@
  alias max_time_stop_later update_stop unless $@
  alias max_time_steps_later increase_steps unless $@
  alias max_time_custom_later move_type_custom unless $@
  def initialize(*args)
    @time_stop = 0
    @time_event = false
    max_time_initialize_later(*args)
    #calculate the initialized page id
    for i in 0...@event.pages.size
      if @page == @event.pages[i]
        @init_page_id = i
        break
      end
    end
    #if not erased or no page
    unless @erased
      #flag for setting time event
      set_time_event_flag = false
      #loop through the pages
      for page in @event.pages
        c = page.condition
        #if switch 1 condition is valid
        if c.switch1_valid
          #if the variable is a time switch
          if c.switch1_id == PZE::DAY_SWITCH ||
             c.switch1_id == PZE::NIGHT_SWITCH
            @time_event = true
          end
        end
        #if switch 1 condition is valid
        if c.switch2_valid
          #if the variable is a time switch
          if c.switch2_id == PZE::DAY_SWITCH ||
             c.switch2_id == PZE::NIGHT_SWITCH
            @time_event = true
          end
        end
        #if the variable condition is valid
        if c.variable_valid
          #if the variable is a time variable
          if c.variable_id == PZE::MINUTE ||
             c.variable_id == PZE::HOUR ||
             c.variable_id == PZE::DAY ||
             c.variable_id == PZE::PROG_HOUR || 
             c.variable_id == PZE::PROG_MINUTE
            #event is effected by time
            @time_event = true
            #change to progressive minute if progressive hour
            if c.variable_id == PZE::PROG_HOUR
              c.variable_id = PZE::PROG_MINUTE
              c.variable_value *= 60
            end
            set_time_event_flag = true if c.variable_id == PZE::PROG_MINUTE
          end
        end
      end
      set_time_event if set_time_event_flag
    end
  end
  #set the location/conditions of the event in relation to time
  def set_time_event
    #return if there is no initialized page
    return if @init_page_id.nil?
    #loop through each page until the initialized page
    for page in 0..@init_page_id
      #temp page
      p = @event.pages[page]
      #if prog min, custom movement, graphic and variable is valid
      if p.condition.variable_id == PZE::PROG_MINUTE && p.move_type == 3 && 
         p.graphic.character_name != '' && p.condition.variable_valid
        #local variables
        x = @x #x
        y = @y #y
        d = @direction #direction
        t = 0 #time increment (in frames)
        dfix = p.direction_fix #direction fix
        through = p.through #through
        speed = p.move_speed #move speed
        frequency = p.move_frequency #move frequency
        last = (page == @init_page_id) #true if page is initialized page
        index = 0 #move route index
        #loop through move route list and ammend location/direction
        for i in 0...p.move_route.list.size
          #move route command
          c = p.move_route.list[index]
          #save last x/y/d
          x_ = x
          y_ = y
          d_ = d
          case c.code
          when 1 #down
            y += 1
            d = 2
          when 2 #left
            x -= 1
            d = 4
          when 3 #right
            x += 1
            d = 6
          when 4 #up
            y -= 1
            d = 8
          when 5 #dl
            x -= 1
            y += 1
            d = (d == 6 ? 4 : d == 8 ? 2 : d)
          when 6 #dr
            x += 1
            y += 1
            d = (d == 4 ? 6 : d == 8 ? 2 : d)
          when 7 #ul
            x -= 1
            y -= 1
            d = (d == 6 ? 4 : d == 2 ? 8 : d)
          when 8 #ur
            x += 1
            y -= 1
            d = (d == 4 ? 6 : d == 2 ? 8 : d)
          when 12 #forward
            case d
            when 2 #down
              y += 1
            when 4 #left
              x -= 1
            when 6 #right
              x += 1
            when 8 #up
              y -= 1
            end
          when 13 #backward
            case d
            when 2 #down
              y -= 1 
            when 4 #left
              x += 1
            when 6 #right
              x -= 1
            when 8 #up
              y += 1
            end
            d = 10 - d
          when 14 #jump
            x += c.parameters[0]
            y += c.parameters[1]
            d = c.parameters[0] < 0 ? 4 : 6
            d = c.parameters[1] < 0 ? 8 : 2
          when 15 #wait
            t += c.parameters[0] * 2 - 1
          when 16 #down
            d = 2
          when 17 #left
            d = 4
          when 18 #right
            d = 6
          when 19 #up
            d = 8
          when 20 #90 right
            case d
            when 2
              d = 4
            when 4 
              d = 8
            when 6
              d = 2
            when 8
              d = 6
            end
          when 21 #90 left
            case d
            when 2
              d = 6
            when 4 
              d = 2
            when 6
              d = 8
            when 8
              d = 4
            end
          when 22 #180
            d = 10 - d
          when 27 #switch on
            $game_switches[c.parameters[0]] = true
          when 28 #switch off
            $game_switches[c.parameters[0]] = false
          when 29 #speed
            speed = c.parameters[0]
          when 30 #freq
            frequency = c.parameters[0]
          when 31 #dfix on
            dfix = true
          when 32 #dfix off
            dfix = false
          when 33 #t on
            through = true
          when 32 #t off
            through = false
          when 41 #graphic
            d = c.parameters[2]
          when 45
            #if event shortcuts are active account for them
            if !$max_events.nil? && $max_events >= 0.3
              x_times = 0
              y_times = 0
              times = 0
              #change direction, based on regexp
              if c.parameters[0] =~ /EVENT\.(\w*)\((\d*),?(\d*),?(\d*)\)/
                if $1 == 'down'
                  y_times = 1
                  d = 2
                elsif $1 == 'left'
                  x_times = -1
                  d = 4
                elsif $1 == 'right'
                  x_times = 1
                  d = 6
                elsif $1 == 'up'
                  y_times = -1
                  d = 8
                elsif $1 == 'downleft'
                  x_times = -1
                  y_times = 1
                  d = (d == 6 ? 4 : d == 8 ? 2 : d)
                elsif $1 == 'downright'
                  x_times = 1
                  y_times = 1
                  d = (d == 4 ? 6 : d == 8 ? 2 : d)
                elsif $1 == 'upleft'
                  x_times = -1
                  y_times = -1
                  d = (d == 6 ? 4 : d == 2 ? 8 : d)
                elsif $1 == 'upright'
                  x_times = 1 
                  y_times = -1
                  d = (d == 4 ? 6 : d == 2 ? 8 : d)
                elsif $1 == 'forward' || $1 == 'backward'
                  d = 10 - d if $1 == 'backward'
                  x_times = (d == 6 ? 1 : d == 4 ? -1 : 0)
                  y_times = (d == 2 ? 1 : d == 8 ? -1 : 0)
                elsif $1 == 'jump'
                  x_times = $2.to_i
                  y_times = $3.to_i
                  times = $4.to_i
                  d = $2.to_i < 0 ? 4 : 6
                  d = $3.to_i < 0 ? 8 : 2
                elsif $1 == 'location'
                  x = $2.to_i
                  y = $3.to_i
                end
                times = $2.to_i if $4 == ''
              end
              #if there is an amount and not a location
              if $2 != '' && $1 != 'location'
                #adjust the move route on initialized page
                if last
                  #change the move route
                  force_move_multiple(d / 2, times, index)
                  #adjust index
                  index -= 1
                end
                #loop for each movement iteration
                for j in 0...times
                  #increment the location
                  x += x_times
                  y += y_times
                  #increase time by move speed and frequency
                  t += 128 / (2 ** speed)
                  t += (40 - frequency * 2) * (6 - frequency)
                  #if initialized page
                  if last
                    #increment index
                    index += 1
                    #if the temp time is greater then the current time 
                    if p.condition.variable_value + t / PZE::FRAMES >
                       $game_system.pze_minute_prog
                      #break loop
                      break
                    end
                  end
                end
                #decrement time by frequency once
                t -= (40 - frequency * 2) * (6 - frequency)
              end
            end
          end
          #if a move command increment the time by speed
          t += (128 / (2 ** speed)) if c.code > 0 && c.code < 15
          #reset direction if direction fix
          d = d_ if dfix
          #increment time in relation to move frequency
          t += (40 - frequency * 2) * (6 - frequency)
          #if initialized page
          if last
            #adjust the move route index
            @move_route_index = index
            #if the temp time is greater then the current time 
            if p.condition.variable_value + t / PZE::FRAMES >
               $game_system.pze_minute_prog
              #increment to next index
              @move_route_index += 1
              #set variables
              @direction_fix = dfix
              @through = through
              @move_speed = speed
              @move_frequency = frequency
              #end loop
              break
            end
          end
          #increment index
          index += 1
        end
        #move and set direction
        moveto(x, y)
        @direction = d
      end
    end
  end
  
  def update_stop
    #if the event is a time event and move type is custom
    if @time_event && @move_type == 3 && @character_name != '' 
      command = @move_route.list[@move_route_index]
      if command.code > 0 && command.code < 15 && @wait_count == 0 
        #update the time stop
        @time_stop += 1
        #if time stop is equal to frame rate
        if @time_stop >= PZE::FRAMES
          #loop through the pages
          for page in @event.pages
            c = page.condition
            #if the variable condition is valid
            if c.variable_valid
              #if variable is a prog minute
              if c.variable_id == PZE::PROG_MINUTE
                #increment the minute condition
                c.variable_value += 1
              end
            end
          end
          #reset the time stop
          @time_stop = 0
        end
      end
    end
    max_time_stop_later
  end
  
  def increase_steps
    @time_stop -= 1 if @time_event && @move_type == 3 && @character_name != ''
    max_time_steps_later
  end
  
  def move_type_custom
    return if @time_event && $game_system.map_interpreter.running? &&
              !@move_route_forcing
    max_time_custom_later
  end
end

#===============================================================================
# Sprite_Clock_Background
#===============================================================================

class Sprite_Clock_Background < Sprite
  def initialize
    super(nil)
    self.bitmap = Bitmap.new(174,90)
    self.x, self.y, self.z = 233, 390, 9995
    refresh
  end
  
  def dispose
    self.bitmap.dispose
    super
  end
  
  def refresh
    #reset variables
    @day = $game_system.pze_day
    @night = $game_system.pze_night
    @time_inverted = $game_system.pze_time_inverted
    #clear the bitmap
    self.bitmap.clear
    #draw the background
    background = RPG::Cache.picture('Clock_base')
    self.bitmap.blt(0,0,background,background.rect)
    #get the day number
    if PZE::HOUR24
      day_number = $game_system.pze_hour_prog / 24 + 1
    else
      day_number = $game_system.pze_day
    end
    #get the diamond
    if PZE::TIME_INVERTED
      if PZE::CLOCK == 0 #3-Day Cycle
        if @time_inverted #when Time is inverted
          diamond = RPG::Cache.picture('Day_Indicator_(Blue)')
        else #when Time is not inverted
          diamond = RPG::Cache.picture('Day_Indicator_(Green)')
        end
      elsif PZE::CLOCK == 1 #Day-Night Cycle
        if @time_inverted #when Time is inverted
          if $game_system.pze_hour_prog / 12 % 2 == 0 #day
            diamond = RPG::Cache.picture('Day_Indicator_(Blue)')
          else #night
            diamond = RPG::Cache.picture('Day_Indicator_(Blue)')
          end
        else #when Time is not inverted
          if $game_system.pze_hour_prog / 12 % 2 == 0 #day
            diamond = RPG::Cache.picture('Day_Indicator_(Green)')
          else #night
            diamond = RPG::Cache.picture('Day_Indicator_(Green)')
          end
        end
      end
    else
      if PZE::CLOCK == 0 #3-Day Cycle
        case day_number
        when 1 #1st Day (non-inverted)
          diamond = RPG::Cache.picture('Day_Indicator_(Green)')
        when 2 #2nd Day (non-inverted)
          diamond = RPG::Cache.picture('Day_Indicator_(Green)')
        when 3, 4 #Final Day (non-inverted)
          diamond = RPG::Cache.picture('Day_Indicator_(Green)')
        end
      elsif PZE::CLOCK == 1 #Day-Night Cycle
        #swap the color for night and day
        if $game_system.pze_hour_prog / 12 % 2 == 0
          diamond = RPG::Cache.picture('Day_Indicator_(Green)')
        else
          diamond = RPG::Cache.picture('Day_Indicator_(Green)')
        end
      end
    end
    #draw the diamond
    self.bitmap.blt(54,35,diamond,diamond.rect)
    #get the day indicator
    if PZE::CLOCK == 0
      case day_number
      when 1
        day = RPG::Cache.picture('1st_Day')
      when 2
        day = RPG::Cache.picture('2nd_Day')
      when 3, 4
        day = RPG::Cache.picture('Final_Day')
      end
    elsif PZE::CLOCK == 1
      if $game_system.pze_hour_prog / 12 % 2 == 0
        day = RPG::Cache.picture('Day_Indicator_(DayTime)')
      else
        day = RPG::Cache.picture('Day_Indicator_(NightTime)')
      end
    end
    #draw the day indicator
    self.bitmap.blt(87 - day.width / 2,43,day,day.rect) 
  end
  
  def update
    #check if time is inverted
    if PZE::TIME_INVERTED && $game_system.pze_time_inverted != @time_inverted
      refresh
      return
    end
    #MM
    if PZE::CLOCK == 0
      #update every 24 hours
      if PZE::HOUR24
        if $game_system.pze_hour_prog >= @day * 24 || 
           $game_system.pze_hour_prog < (@day - 1) * 24
          #don't update if changing the scene
          return if $scene.is_a?(Scene_Phase_Message)
          refresh
        end
      #else update every new day
      else
        refresh if $game_system.pze_day != @day
      end
    #Standard
    elsif PZE::CLOCK == 1
      #refresh if day changes
      refresh if $game_system.pze_night != @night
    end
  end
end

#===============================================================================
# Sprite_Clock_Minute
#===============================================================================

class Sprite_Clock_Minute < Sprite
  def initialize
    super(nil)
    self.bitmap = RPG::Cache.picture('Minute_Indicator')
    self.x, self.y, self.z = 310, 418, 9996
    update
  end
  
  def update
    #increment of the minute indicator
    inc = $game_system.pze_minute + $game_system.pze_count / 
          (PZE::FRAMES * $game_system.pze_time_increment).to_f
    #move to the right
    if $game_system.pze_minute < 15 
      self.x = 310 + 34 * inc / 15.0
    #move to the left
    elsif $game_system.pze_minute < 45
      self.x = 344 - 68 * (inc - 15) / 30.0
    #move back to the right
    else
      self.x = 276 + 34 * (inc - 45) / 15.0
    end
    #move up and down
    self.y = 470 - 54 * (30 - inc).abs / 30.0
  end
end

#===============================================================================
# Sprite_Clock_Sun_Moon
#===============================================================================

class Sprite_Clock_Sun_Moon
  def initialize
    #sun sprite
    @sun = Sprite.new
    @sun.bitmap = RPG::Cache.picture('Hour_Indicator_(DayTime)')
    #moon sprite
    @moon = Sprite.new
    @moon.bitmap = RPG::Cache.picture('Hour_Indicator_(NightTime)')
    #hour sprites
    @sun_hour = Sprite.new
    @sun_hour.bitmap = Bitmap.new(30,30)
    @sun_hour.bitmap.font.name = 'P'
    @sun_hour.bitmap.font.size = 20
    @moon_hour = Sprite.new
    @moon_hour.bitmap = @sun_hour.bitmap.clone
    #store the sprites in an array
    @sprites = [@sun, @moon, @sun_hour, @moon_hour]
    #set the location of the sprites
    @sun.x = @moon.x = @sun_hour.x = @moon_hour.x = 304
    @sun.y = @moon.y = @sun_hour.y = @moon_hour.y = 451
    @sun.z = @moon.z = @sun_hour.z = @moon_hour.z = 9996
    @opacity = 255
    #update to move into position
    update
  end
  
  def dispose
    #dispose the hour indicator aswell
    @sun_hour.bitmap.dispose
    @moon_hour.bitmap.dispose
    @sprites.each {|sprite| sprite.dispose}
  end
  
  def opacity
    return @opacity
  end
  
  def opacity=(opacity)
    @opacity = opacity
    @sprites.each {|sprite| sprite.opacity = @opacity}
  end
  
  def visible=(bool)
    @sprites.each {|sprite| sprite.visible = bool}
  end
  
  def update
    #get the radians
    radians = ($game_system.pze_hour + $game_system.pze_minute / 60.0) * Math::PI / 12
    #calculate the sine and cosine wave
    sin = Math.sin(radians)
    cos = Math.cos(radians)
    #set positions along the wave
    @sun.ox = sin * 74
    @sun.oy = cos * -62
    @moon.ox = sin * -74
    @moon.oy = cos * 62
    @sun_hour.ox = sin * 98
    @sun_hour.oy = cos * -90
    @moon_hour.ox = sin * -98
    @moon_hour.oy = cos * 90
    #change the hour if needed
    if @hour != $game_system.pze_hour
      @hour = $game_system.pze_hour
      hour = @hour % 12
      hour = 12 if hour == 0
      @sun_hour.bitmap.clear
      @sun_hour.bitmap.draw_text(0, 0, 30, 30, hour.to_s, 1)
      @moon_hour.bitmap.clear
      @moon_hour.bitmap.draw_text(0, 0, 30, 30, hour.to_s, 1)
    end
  end
end 

#===============================================================================
# Spriteset_Clock
#===============================================================================

class Spriteset_Clock
  def initialize
    #load the individual sprites
    @sprites = []
    @sprites << Sprite_Clock_Background.new
    @sprites << Sprite_Clock_Minute.new
    @sprites << Sprite_Clock_Sun_Moon.new
    @opacity = under? ? 100 : 255
    @sprites.each {|sprite| sprite.opacity = @opacity}
    @sprites.each {|sprite| sprite.visible = false} if !$scene.is_a?(Scene_Map)
  end
  
  def dispose
    #dispose all sprites
    @sprites.each {|sprite| sprite.dispose}
  end
  
  def update
    @sprites.each {|sprite| sprite.update}
    #fade out if player is under the sprite, else fade in
    if under?
      @opacity = [@opacity - 10, 80].max    
    else
      @opacity = [@opacity + 10, 255].min
    end
    @sprites.each {|sprite| sprite.opacity = @opacity}
  end
  
  def under?
    return false if $game_player.screen_x < 233
    return false if $game_player.screen_x > 412
    return false if $game_player.screen_y < 390
    return true
  end
end

#===============================================================================
# Sprite_Dawn_Message
#===============================================================================

class Sprite_Dawn_Message < Sprite
  def initialize
    super(nil)
    self.bitmap = Bitmap.new(440,192)
    self.x, self.y, self.z = 100, 128, 1
    self.bitmap.font.name = 'TS'
    self.opacity = 0
    refresh
  end
  
  def dispose
    self.bitmap.dispose
    super
  end
  
  def refresh
    #get the text for each day
    case $game_system.pze_day
    when 1
      text = 'The First Day'
    when 2
      text = 'The Second Day'
    when 3
      text = 'The Final Day'
    end
    #draw the text
    self.bitmap.font.size = 64
    self.bitmap.draw_text(0,0,440,64,'Dawn of',1)
    self.bitmap.font.size = 96
    self.bitmap.draw_text(0,48,440,96,text,1)
  end
  
  def update
    #increase opacity
    self.opacity += 10
  end
end

#===============================================================================
# Sprite_Hour_Message
#===============================================================================

class Sprite_Hour_Message < Sprite
  def initialize
    super(nil)
    self.bitmap = Bitmap.new(440,64)
    self.x, self.y, self.z = 100, 288, 1
    self.bitmap.font.name = 'TS'
    self.bitmap.font.size = 48
    self.opacity = 0
    @count = 0
    refresh
  end
  
  def dispose
    self.bitmap.dispose
    super
  end
  
  def refresh
    #get the amount of hours remaining
    case $game_system.pze_day
    when 1
      text = '-72 Hours Remain-'
    when 2
      text = '-48 Hours Remain-'
    when 3
      text = '-24 Hours Remain-'
    end
    #draw the text
    self.bitmap.draw_text(0,0,440,48,text,1)
  end
  
  def update
    #increment the count
    @count += 1
    #increase opacity
    if @count > 30
      self.opacity += 10
    end
  end
end

#===============================================================================
# Sprite_Clock_Disk
#===============================================================================

class Sprite_Clock_Disk < Sprite #base class for the clock disks
  def initialize(viewport = nil)
    super(viewport)
    @x = PZE::CLOCK_X * 4
    @y = PZE::CLOCK_Y * 4
    self.z = 1000
    refresh
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
    @last_angle = -999
    @angle = -999
    @precision = PZE::CLOCK_PRECISION
    update
  end
  
  def refresh
    self.bitmap.dispose if not self.bitmap.nil?
    self.bitmap = RPG::Cache.picture(@bitmap_name)
    @last_set_bitmap_name = @bitmap_name.clone
  end
  
  def update
    # Load the bitmap if it's changed
	  if @last_set_bitmap_name != @bitmap_name
	    refresh
    end
    # Update the disk's position
    self.x = (@x - $game_map.display_x + 3) / 4 + 16 + self.ox
    self.y = (@y - $game_map.display_y + 3) / 4 + 32 + self.oy
    # Skip if it's not on the screen
    # Change the angle if necessaryover 5 degrees has happened
    if (@angle - @last_angle).abs > @precision
      self.angle = 360 - @angle
      @last_angle = @angle
    end
    super
  end
end

#===============================================================================
# Sprite_Clock_Minute_Disk
#===============================================================================

class Sprite_Clock_Minute_Disk < Sprite_Clock_Disk
  def initialize(viewport = nil)
    @bitmap_name = 'Clock_Minute_Disk'
    @frames_per_sec = PZE::FRAMES
    super(viewport)
  end 
  
  def update
    secs = $game_system.pze_count * 60 / (@frames_per_sec * $game_system.pze_time_increment)
    mins = $game_system.pze_minute
    @angle = mins * 6.0 + secs / 10.0
    return unless self.viewport.ox == 0
    super
  end
end

#===============================================================================
# Sprite_Clock_Hour_Disk
#===============================================================================

class Sprite_Clock_Hour_Disk < Sprite_Clock_Disk
  def initialize(viewport = nil)
    @bitmap_name = 'Clock_Hour_Disk'
    super(viewport)
  end
  
  def update
    hour = $game_system.pze_hour % 12
    mins = $game_system.pze_minute
    @angle = (hour - 6) * 30.0 + mins / 2.0
    super
  end
end

#===============================================================================
# Sprite_Sun_Moon_Disk
#===============================================================================

class Sprite_Sun_Moon_Disk < Sprite_Clock_Disk
  def initialize(viewport = nil)
    hour = $game_system.pze_hour
    if hour.between?(6, 17) #day
      @bitmap_name = 'Clock_Day_Disk_DayTime'
    else #night
      @bitmap_name = 'Clock_Day_Disk_NightTime'
    end
    super(viewport)
  end
  
  def update
    hour = $game_system.pze_hour
    mins = $game_system.pze_minute
    @angle = (hour % 12 - 6) * 30.0 + mins / 2.0
    #change bitmap if needed
	  if hour.between?(6, 17)
      @bitmap_name = 'Clock_Day_Disk_DayTime'
    else
      @bitmap_name = 'Clock_Day_Disk_NightTime'
    end
    super
  end
end

#===============================================================================
# Spriteset_Clock_Tower
#===============================================================================

class Spriteset_Clock_Tower
  def initialize(viewport = nil)
    @sprites = []
    #initialize all the clock tower disk sprites
    @sprites << Sprite_Clock_Minute_Disk.new(viewport)
    @sprites << Sprite_Clock_Hour_Disk.new(viewport)
    @sprites << Sprite_Sun_Moon_Disk.new(viewport)
    @opacity = under? ? 100 : 255
    @sprites.each {|sprite| sprite.opacity = @opacity }
  end
  
  def dispose
    #dispose all sprites
    @sprites.each {|sprite| sprite.dispose}
  end
  
  def update
    #update all sprites
    @sprites.each {|sprite| sprite.update}
    # Change the opacity if the player is underneath
    if under?
      @opacity = [@opacity - 10, 100].max
    else
      @opacity = [@opacity + 10, 255].min
    end
    @sprites.each {|sprite| sprite.opacity = @opacity }
  end
  
  def under?
    #return true if under the sprite, false if not
    return false if $game_player.screen_x < @sprites[0].x - @sprites[0].ox - 16
    return false if $game_player.screen_x > @sprites[0].x + @sprites[0].ox + 16
    return false if $game_player.screen_y < @sprites[0].y - @sprites[0].oy - 16
    return false if $game_player.screen_y > @sprites[0].y + @sprites[0].oy + 16
    return true
  end
end

#===============================================================================
# Sprite_Time_Debug
#===============================================================================

class Sprite_Time_Debug < Sprite
  def initialize
    super(nil)
    self.bitmap = Bitmap.new(192,128)
    self.x, self.y, self.z = 16, 144, 9996
    refresh
  end
  
  def refresh
    @minute = $game_system.pze_minute
    self.bitmap.clear
    self.bitmap.draw_text(0,0,192,32,$game_system.pze_hour.to_s + ':' + @minute.to_s)
    self.bitmap.draw_text(0,16,192,32,'prog min: ' + $game_system.pze_minute_prog.to_s)
    self.bitmap.draw_text(0,32,192,32,'prog hour: ' + $game_system.pze_hour_prog.to_s)
    self.bitmap.draw_text(0,48,192,32,'day: ' + $game_system.pze_day.to_s)
  end
  
  def update
    refresh if $game_system.pze_minute != @minute
  end
end

#===============================================================================
# Interpreter
#===============================================================================

class Interpreter
  alias max_time_execute_later execute_command unless $@
  def execute_command
    #pause interpreter while reseting time
    return false if $game_temp.pze_time_reset
    max_time_execute_later
  end
end

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title
  alias max_time_command_new_game_later command_new_game unless $@
  def command_new_game
    max_time_command_new_game_later
    #show the phase message if necessary
    if PZE::CLOCK == 0 && $game_system.pze_time_active
      $scene = Scene_Phase_Message.new 
    end
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  alias max_time_initialize_later initialize unless $@
  alias max_time_dispose_later dispose unless $@
  alias max_time_update_later update unless $@
  def initialize
    max_time_initialize_later
    #create the clock tower disk
    if $game_map.map_id == PZE::CLOCK_MAP
      #if the file can be found
      if FileTest.exist?('Graphics/Pictures/Clock_Minute_Disk.png')
        @clock_tower = Spriteset_Clock_Tower.new(@viewport1)
      #else if it can't be found and in debug mode, show an error
      elsif $DEBUG
        raise 'The Clock Tower Disk images could not be found, either place ' +
        "the clock tower disk images in the Pictures folder,\nor set the " +
        'CLOCK_MAP variable in the configuration to 0 to disable this feature.'
      end
    end
  end
  
  def dispose
    max_time_dispose_later
    #dispose everything if they exist
    @clock_hud.dispose unless @clock_hud.nil?
    @time_debug.dispose unless @time_debug.nil?
    @clock_tower.dispose unless @clock_tower.nil?
  end
  
  def update
    max_time_update_later
    #create/update/dispose the clock hud
    if $game_system.pze_clock_visible && PZE::CLOCK != 2
      if @clock_hud.nil?
        if FileTest.exist?('Graphics/Pictures/Clock_base.png')
          @clock_hud = Spriteset_Clock.new
        #else if it can't be found and in debug mode, show an error
        elsif $DEBUG
          raise 'The Clock HUD images could not be found, either place the ' +
          "clock HUD images in the Pictures folder,\nor set the CLOCK " +
          'variable in the configuration to 2.'
        end
      end
      @clock_hud.update
    elsif !@clock_hud.nil?
      @clock_hud.dispose
      @clock_hud = nil
    end
    #create/update/dispose the time debug sprite
    if $game_temp.pze_time_debug
      @time_debug = Sprite_Time_Debug.new if @time_debug.nil?
      @time_debug.update
    elsif !@time_debug.nil?
      @time_debug.dispose
      @time_debug = nil
    end
    #update the clock tower
    @clock_tower.update unless @clock_tower.nil?
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  alias max_time_update_later update unless $@
  def update
    max_time_update_later
    #toggle the time debug sprite if the time debug input is triggered
    if Input.trigger?(PZE::TIME_DEBUG_INPUT) && $DEBUG && PZE::TIME_DEBUG
      $game_temp.pze_time_debug = !$game_temp.pze_time_debug
    end
  end
end

#===============================================================================
# Scene_Phase_Message
#===============================================================================

class Scene_Phase_Message
  def main
    if $game_system.pze_day == 4
      $scene = Scene_Gameover.new
      return
    end
    #start count
    @count = 0
    @dawn = Sprite_Dawn_Message.new
    @hour = Sprite_Hour_Message.new
    #stop music
    Audio.bgm_stop
    Audio.bgs_stop
    #play the sound effect
    Audio.me_play('Audio/ME/Day-Night Cycle - Dawn', 100)
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    #dispose sprites
    @dawn.dispose
    @hour.dispose
    #autoplay music
    $game_map.autoplay
  end
  
  def update
    #update the message
    @dawn.update
    @hour.update
    #update the count
    @count += 1
    #exit to map if count hits maximum or a key is triggered
    if @count == 100 || Input.trigger?(Input::C) || Input.trigger?(Input::B)
      $scene = Scene_Map.new
      $game_map.refresh
      $game_temp.pze_time_reset = false
    end
  end
end

#===============================================================================
#                               d==(o.0)==b
#===============================================================================