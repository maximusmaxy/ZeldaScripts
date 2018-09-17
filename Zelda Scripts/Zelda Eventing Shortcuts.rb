#===============================================================================
# ¦ Maximusmaxy's Eventing Shortcuts (XAS VERSION)
#-------------------------------------------------------------------------------
# Increases your eventing power.
#-------------------------------------------------------------------------------
# Author Maximusmaxy
# Version 0.5.1 301111 
# Thanks to
# Baffou - Gave me idea's and suggestions to make this script
#===============================================================================
#
# Instructions
# Implement one of the following call scripts on your events to do specific
# functions. The functions are pretty self explanatory. The call scripts can 
# also be placed in the move route script command, and will effect the 
# referenced event.
#
# Script Calls
#
# The following are the move commands repeated multiple times.
#
# EVENT.down(TIMES)
# EVENT.left(TIMES)
# EVENT.right(TIMES)
# EVENT.up(TIMES)
# EVENT.downleft(TIMES)
# EVENT.downright(TIMES)
# EVENT.upleft(TIMES)
# EVENT.upright(TIMES)
# EVENT.random(TIMES)
# EVENT.toward(TIMES)
# EVENT.away(TIMES)
# EVENT.forward(TIMES)
# EVENT.backward(TIMES)
# TIMES is the amount of moves made 
#
# EVENT.jump(X,Y,TIMES)
# X and Y are the xy distance
# TIMES is the amount of jumps made
#
# EVENT.location(X,Y,DIRECTION)
# X and Y are the new location of the character
# DIRECTION is the new facing direction, can be ommited if retained
#
# The following script calls may only be used on events. The duration can be 
# ommitted if you want the change to be instant.
#
# EVENT.fade(OPACITY, DURATION)
# OPACITY is your target opacity. Transparent = 0, Opaque = 255
# DURATION is how long the transition takes
#
# EVENT.zoom(RATIO, DURATION)
# RATIO is the ratio of zoom. Default is 1.0
# DURATION is how long the transition takes
#
# EVENT.reset(DURATION)
# DURATION is how long it takes to reset the opacity and zoom ratio.
# 
# EVENT.animation(ID,LOOP)
# ID of the animation
# If LOOP is true the animation will loop until an EVENT.end command
# LOOP defaults as false and can be ommitted
# 
# EVENT.end
# ends the animation loop
#
# The following script calls scroll the map to have the specified 
# player, event, location as the center of the screen. Duration is in frames.
#
# EVENT.scroll(DURATION)
# scrolls to the player as the center of the map.
#
# EVENT.scroll(DURATION,EVENT)
# EVENT is the event ID that the map will scroll to
#
# EVENT.scroll(DURATION,X,Y)
# X,Y are the target center coordinates of the map.
#
# EVENT.scroll_wait
# waits for scroll, also works for regular scrolling.
#
#===============================================================================

$max_events = 0.51

#===============================================================================
# EVENT
#===============================================================================

module EVENT
  def self.down(times) #down
    $game_temp.eventing_character.force_move_multiple(1,times)
    return
  end
  
  def self.left(times) #left
    $game_temp.eventing_character.force_move_multiple(2,times)
    return
  end
  
  def self.right(times) #right
    $game_temp.eventing_character.force_move_multiple(3,times)
    return
  end
  
  def self.up(times) #up
   $game_temp.eventing_character.force_move_multiple(4,times)
    return
  end
  
  def self.downleft(times) #lower left
    $game_temp.eventing_character.force_move_multiple(5,times)
    return
  end
  
  def self.downright(times) #lower right
    $game_temp.eventing_character.force_move_multiple(6,times)
    return
  end
  
  def self.upleft(times) #upper left
    $game_temp.eventing_character.force_move_multiple(7,times)
    return
  end
  
  def self.upright(times) #upper right
    $game_temp.eventing_character.force_move_multiple(8,times)
    return
  end
  
  def self.random(times) #random
    $game_temp.eventing_character.force_move_multiple(9,times)
    return
  end
  
  def self.toward(times) #toward
    $game_temp.eventing_character.force_move_multiple(10,times)
    return
  end
  
  def self.away(times) #away
    $game_temp.eventing_character.force_move_multiple(11,times)
    return
  end
  
  def self.forward(times) #forward
    $game_temp.eventing_character.force_move_multiple(12,times)
    return
  end
  
  def self.backward(times) #backward
    $game_temp.eventing_character.force_move_multiple(13,times)
    return
  end
  
  def self.jump(x,y,times) #jump
    $game_temp.eventing_character.force_jump_multiple(x,y,times)
    return
  end
  
  def self.location(x,y,d = $game_temp.eventing_character.direction) #move to
    $game_temp.eventing_character.moveto(x,y)
    case d
    when 2
      $game_temp.eventing_character.turn_down
    when 4
      $game_temp.eventing_character.turn_left
    when 6
      $game_temp.eventing_character.turn_right
    when 8
      $game_temp.eventing_character.turn_up
    end
    return true
  end
  
  def self.fade(opacity,duration = 0) #fade the character
    if $game_temp.eventing_character.is_a(Game_Player)
      raise 'the players opacity cannot be adjusted'
    end
    $game_temp.eventing_character.change_fade(opacity, duration)
    return true
  end
  
  def self.zoom(ratio, duration = 0) #zoom the character
    if $game_temp.eventing_character.is_a(Game_Player)
      raise 'the players zoom ratio cannot be adjusted'
    end
    $game_temp.eventing_character.change_zoom(ratio, duration)
    return true
  end
  
  def self.reset(duration = 0) #reset the opacity and zoom ratio
    self.fade(255,duration)
    self.zoom(1.0,duration)
    return true
  end
  
  def self.animation(id, loop = false) #loop an animation
    if loop
      if $game_temp.eventing_character.is_a(Game_Player)
        raise 'the players animation cannot be looped'
      end
      $game_temp.eventing_character.animation_loop_id = id
    else
      $game_temp.eventing_character.animation_id = id
    end
    return true
  end
  
  def self.end #end an animation loop
    $game_temp.eventing_character.animation_loop_id = 0
    return true
  end
  
  def self.scroll(speed,event = nil,location = nil) #scroll the map
    $game_map.diagonal_scroll(speed, event, location)
    return true
  end
  
  def self.scroll_wait #wait for scroll
    return !$game_map.scrolling
  end
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor eventing_character
  alias max_event_initialize_later initialize unless $@
  def initialize
    max_event_initialize_later
    #character object accessable from script calls
    @eventing_character = nil
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  alias max_event_setup_later setup unless $@
  alias max_event_update_later update unless $@
  alias max_event_scrolling_later scrolling unless $@
  def setup(args)
    max_event_setup_later(args)
    #intialize diagonal scroll variables
    @diagonal_scroll_x = 0
    @diagonal_scroll_y = 0
    @diagonal_scroll_duration = 0
  end
  
  def update
    max_event_update_later
    #scroll diagonally to specified in location
    if @diagonal_scroll_duration  0
      x, y = @diagonal_scroll_x, @diagonal_scroll_y
      x  0  scroll_left(-x)  scroll_right(x)
      y  0  scroll_up(-y)  scroll_down(y)
      @diagonal_scroll_duration -= 1
    end
  end
  
  def scrolling
    #check for diagonal scrolling aswell
    return true if @diagonal_scroll_duration  0
    max_event_scrolling_later
  end
  
  def diagonal_scroll(frames, a, b)
    #center adjustment
    x, y = 1216, 896
    if a.nil #scroll to player
      @diagonal_scroll_x = ($game_player.real_x - @display_x - x)  frames
      @diagonal_scroll_y = ($game_player.real_y - @display_y - y)  frames
    elsif b.nil #scroll to event
      return if $game_map.events[a].nil
      @diagonal_scroll_x = ($game_map.events[a].real_x - @display_x - x)  frames
      @diagonal_scroll_y = ($game_map.events[a].real_y - @display_y - y)  frames
    else #scroll to location
      a, b = [[a, 0].max, width - 1].min, [[b, 0].max, height - 1].min
      @diagonal_scroll_x = (a  128 - @display_x - x)  frames
      @diagonal_scroll_y = (b  128 - @display_y - y)  frames
    end
    #set the speed in frames
    @diagonal_scroll_duration = frames
  end
end


#===============================================================================
# Game_Character
#===============================================================================

class Game_Character
  alias max_event_custom_later move_type_custom unless $@
  def move_type_custom
    #change temp character
    $game_temp.eventing_character = self
    max_event_custom_later
  end
  
  def force_move_multiple(d, times, time_location = -1)
    #create an array to store move commands
    route = []
    #add the move command multiple times
    (0...times).each do i
      route[i] = RPGMoveCommand.new
      route[i].code = d
    end
    #acount for the time system
    index = (time_location == -1  @move_route_index  time_location)
    #delete the script at index
    @move_route.list.delete_at(index) 
    #insert the move route commands into the characters move route
    @move_route.list.insert index, route
    #decrement the move route index
    @move_route_index -= 1 if time_location == -1
    return
  end
  
  def force_jump_multiple(x, y, times, time_location = -1)
    #create an array to store move commands
    route = []
    #add the move command multiple times
    (0...times).each do i
      route[i] = RPGMoveCommand.new
      route[i].code = 14
      route[i].parameters = [x, y]
    end
    #acount for the time system
    index = (time_location == -1  @move_route_index  time_location)
    #delete the script at index
    @move_route.list.delete_at(index) 
    #insert the move route commands into the characters move route
    @move_route.list.insert index, route
    #decrement the move route index
    @move_route_index -= 1 if time_location == -1
    return
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event  Game_Character
  attr_accessor animation_loop_id
  attr_reader zoom_ratio
  alias max_event_initialize_later initialize unless $@
  alias max_event_refresh_later refresh unless $@
  alias max_event_update_later update unless $@
  def initialize(args)
    #variables to smoothly change opacity
    @opacity_target = 0
    @opacity_duration = 0
    @zoom_ratio = 1.0
    @zoom_target = @zoom_ratio
    @zoom_duration = 0
    @animation_loop_id = 0
    max_event_initialize_later(args)
  end

  def update
    #update the opacity
    if @opacity_duration  0
      d = @opacity_duration
      @opacity = (@opacity  (d - 1) + @opacity_target)  d
      @opacity_duration -= 1
    end
    #update the zoom
    if @zoom_duration  0
      d = @zoom_duration
      @zoom_ratio = (@zoom_ratio  (d - 1) + @zoom_target)  d
      @zoom_duration -= 1
    end
    max_event_update_later
  end
  
  def change_zoom(ratio, duration)
    #zoom instantly if duration is 0
    duration == 0  @zoom_ratio = ratio  @zoom_target = ratio
    @zoom_duration = duration
  end
  
  def change_fade(opacity, duration)
    #fade instantly if duration is 0
    duration == 0  @opacity = opacity  @opacity_target = opacity
    @opacity_duration = duration    
  end
end

#===============================================================================
# Sprite_Character
#===============================================================================

class Sprite_Character  RPGSprite
  alias max_event_initialize_later initialize# unless $@
  alias max_event_update_later update# unless $@
  def initialize(args)
    @animation_looping = false
    max_event_initialize_later(args)
  end
  
  def update
    max_event_update_later
    #adjust the zoom level
    unless @character.is_a(Game_Player)
      self.zoom_x = @character.zoom_ratio
      self.zoom_y = @character.zoom_ratio
      #loop an animation
      if @character.animation_loop_id != 0
        #if the animation isn't looping
        unless @animation_looping  @character.animation_loop_id.nil
          #start the animation loop
          loop_animation($data_animations[@character.animation_loop_id])
          @animation_looping = true
        end
      else
        #if the animation is looping
        if @animation_looping
          #end the animation
          dispose_loop_animation
          @animation_looping = false
        end
      end
    end
  end
end

#===============================================================================
# Interpreter
#===============================================================================

class Interpreter
  alias max_event_355_later command_355 unless $@
  def command_355
    #change temp character
    $game_temp.eventing_character = $game_map.events[@event_id]
    max_event_355_later
  end
end