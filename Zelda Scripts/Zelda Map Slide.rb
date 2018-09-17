#===============================================================================
# ¦ PZE Map Slide
#-------------------------------------------------------------------------------
# Link to the Past style map slide transition
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.6: 8/3/12
#===============================================================================
#
# Introduction:
# This script allows you to have standard map links and link to the past map
# slide transitions.
#
# Instructions:
# NOTE: Map slides can only be done between maps with the SAME TILESET.
# NOTE: The size of the connecting sides of each map MUST BE EQUAL.
# To set up a map slide place an event on the edge of the map where you want
# the map slide to occur with one of the following as the events name:
# 
# <MaplinkX> - flags that side of the map as a maplink.
# <MapslideX> - flags that side of the map as a mapslide.
# X is the map id the link/slide will transition to.
#
# If the name is maplink, a normal transition will occur when you touch the 
# edge of the map (this should be used for maps with different tilesets).
#
# If the name is mapslide, a map slide will occur when you touch the edge
# of the map.
#
# Script Calls:
#
# To force a map slide use the following script call:
#
# SLIDE.force(MAP,DIRECTION)
# MAP is the id of the new map
# DIRECTION is the direction of the map slide
# Down = 2, Left = 4, Right = 6, Up = 8 (like the numberpad) 
#
#===============================================================================

$pze_slide = 0.6

module SLIDE
  
#===============================================================================
# Configuration
#===============================================================================
  #speed of the map slide
  SPEED = 6
#===============================================================================
# End Configuration
#===============================================================================
  
  def self.force(map, d)
    $game_map.setup_map_slide(map, $game_player.x, $game_player.y, d)
  end
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor :map_slide
  attr_accessor :link_transition
  alias max_slide_initialize_later initialize unless $@
  def initialize
    max_slide_initialize_later
    @map_slide = 0
    @link_transition = false
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  attr_accessor :fog_ox
  attr_accessor :fog_oy
  attr_reader :maplinks
  alias max_slide_setup_later setup unless $@
  def setup(*args)
    #initialize maplinks array
    @maplinks = []
    max_slide_setup_later(*args)
    #if transition is flagged adjust the new location
    if $game_temp.link_transition
      case $game_temp.player_new_direction
      when 2
        $game_temp.player_new_y = 0
      when 4
        $game_temp.player_new_x = width - 1
      when 6
        $game_temp.player_new_x = 0
      when 8
        $game_temp.player_new_y = height - 1
      end
    end
  end
  
  def setup_map_slide(map2, x2, y2, d)
    #freeze graphics for the map setup
    Graphics.freeze
    #set up locals
    x1, y1 = $game_player.x, $game_player.y
    #store the map ID's
    map1_id = @map_id
    map2_id = map2
    #set to an invalid map id
    @map_id = 0
    #adjust the new location
    case d
    when 2
      y2 = 0
    when 4
      x2 = width - 1
    when 6
      x2 = 0
    when 8
      y2 = height - 1
    end
    #setup the temp variables
    $game_temp.player_new_map_id = map2
    $game_temp.player_new_direction = d
    $game_temp.player_new_x = x2
    $game_temp.player_new_y = y2
    #load the map data of each map
    map1 = @map
    map2 = load_data(sprintf("Data/Map%03d.rxdata", map2))
    #get the width/height of the new map
    w = (@display_x % 128 == 0 ? 20 : 21)
    w = w * (d == 4 || d == 6 ? 2 : 1)
    h = 15 * (d == 2 || d == 8 ? 2 : 1)
    #create the map object
    @map = RPG::Map.new(w, h)
    #get the x and y offsets
    xo1, xo2 = (d == 4 ? width / 2 : 0), (d == 6 ? width / 2 : 0)
    yo1, yo2 = (d == 8 ? height / 2 : 0), (d == 2 ? height / 2 : 0)
    xi1, yi1 = (@display_x / 128).truncate, (@display_y / 128).truncate
    xi2 = ([0,[x2 * 128 - 1216,(map2.width - 20) * 128].min].max / 128).truncate
    yi2 = ([0,[y2 * 128 - 896,(map2.height - 15) * 128].min].max / 128).truncate
    #setup the map data
    (0...width / (d == 4 || d == 6 ? 2 : 1)).each do |x|
      (0...height / (d == 2 || d == 8 ? 2 : 1)).each do |y|
        (0..2).each do |z|
          @map.data[x + xo1, y + yo1, z] = map1.data[x + xi1, y + yi1, z]
          @map.data[x + xo2, y + yo2, z] = map2.data[x + xi2, y + yi2, z]
        end
      end
    end
    #get the tileset information
    tileset = $data_tilesets[map1.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @passages = tileset.passages
    @priorities = tileset.priorities
    #adjust fog location
    @fog_ox += xi1 * 32 - (d == 4 ? 640 : 0)
    @fog_oy += yi1 * 32 - (d == 8 ? 480 : 0)
    #clear refresh flag
    @need_refresh = false
    #setup map 1 events
    @events = {}
    map1.events.each do |i,event|
      #get the new coordinates
      event.x = event.x - xi1 + (d == 4 ? width / 2 : 0)
      event.y = event.y - yi1 + (d == 8 ? height / 2 : 0)
      #next event if the event is out of range
      next unless valid?(event.x, event.y)
      #create the event
      @events[i] = Game_Event.new(map1_id, event)
      #clear automatic movement/triggers/interpreters
      @events[i].move_type = 0
      @events[i].trigger = 0
      @events[i].interpreter = nil
      @events[i].clear_starting
    end
    #setup map 2 events
    map2.events.each do |i,event|
      #get the new coordinates
      event.x = event.x - xi2 + (d == 6 ? width / 2 : 0)
      event.y = event.y - yi2 + (d == 2 ? height / 2 : 0)
      #next event if the event is out of range
      next unless valid?(event.x, event.y)
      #create the event and move into place
      @events[1000 + i] = Game_Event.new(map2_id, event)
      #increment the id
      @events[1000 + i].id += 1000
      #clear automatic movement/triggers
      @events[1000 + i].move_type = 0
      @events[1000 + i].trigger = 0
      @events[1000 + i].interpreter = nil
      @events[1000 + i].clear_starting
    end
    #get the display_x offset
    x_offset = @display_x % 128
    #move player into position
    x, y = $game_player.real_x / 128 - xi1, $game_player.real_y / 128 - yi1
    $game_player.moveto(x + (d == 4 ? width/2 : 0), y + (d == 8 ? height/2 : 0))
    #set the display coordinates
    @display_x = (d == 4 ? width / 2 * 128 : 0) + x_offset
    @display_y = (d == 8 ? height / 2 * 128 : 0)
    #scroll the map
    start_scroll(d, (d == 4 || d == 6 ? width/2 : height/2), SLIDE::SPEED)
    #initialize the map slide
    $game_temp.map_slide = 1
  end
  
  def setup_map_link(map, direction, slide)
    @maplinks[(direction - 2) / 2] = [map, slide]
  end
  
  def map_link_transition(link, x, y, d)
    #slide
    if @maplinks[link][1]
      setup_map_slide(@maplinks[link][0], x, y, d)
    #normal transition
    else
      Graphics.freeze
      $game_temp.link_transition = true
      $game_temp.player_new_map_id = map
      $game_temp.player_new_x = x
      $game_temp.player_new_y = y
      $game_temp.player_new_direction = direction
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
      $scene.transfer_player
    end
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_writer :id
  attr_writer :trigger
  attr_writer :move_type
  attr_writer :interpreter
  alias max_slide_initialize_later initialize unless $@
  def initialize(*args)
    max_slide_initialize_later(*args)
    #if the event name is <maplinkX> or <mapslideX>
    if @event.name =~ /<[Mm]ap([linkslide]*)(\d*)>/
      #get the direction
      direction = 0
      if @x == 0
        direction = 4
      elsif @x == $game_map.width - 1
        direction = 6
      elsif @y == 0
        direction = 8
      elsif @y == $game_map.height - 1
        direction = 2
      end
      #if map link or slide is valid
      if direction != 0 && $2 != ''
        #setup the link or slide
        if $1 == 'link'
          $game_map.setup_map_link($2.to_i, direction, false)
        elsif $1 == 'slide'
          $game_map.setup_map_link($2.to_i, direction, true)
        end
      end
    end
  end
end

#===============================================================================
# Game_Player
#===============================================================================

class Game_Player < Game_Character
  alias max_slide_update_later update unless $@
  alias max_slide_down_later move_down unless $@
  alias max_slide_left_later move_left unless $@
  alias max_slide_right_later move_right unless $@
  alias max_slide_up_later move_up unless $@
  def update
    #pause player update while map slide is ocurring
    return if $game_temp.map_slide == 2
    max_slide_update_later
  end
  
  def move_down(*args)
    max_slide_down_later(*args)
    #map transition down if on the bottom of the map
    if @real_y == ($game_map.height - 1) * 128 && !$game_map.maplinks[0].nil?
      $game_map.map_link_transition(0, $game_player.real_x / 128, 0, 2)
    end
  end
  
  def move_left(*args)
    max_slide_left_later(*args)
    #map transition left if on the left side of the map
    if @real_x == 0 && !$game_map.maplinks[1].nil?
      $game_map.map_link_transition(1, $game_map.width - 1, 
                                    $game_player.real_y / 128, 4)
    end
  end
  
  def move_right(*args)
    max_slide_right_later(*args)
    #map transition right if on the right side of the map
    if @real_x == ($game_map.width - 1) * 128 && !$game_map.maplinks[2].nil?
      $game_map.map_link_transition(2, 0, $game_player.real_y / 128, 6)
    end
  end
  
  def move_up(*args)
    max_slide_up_later(*args)
    #map transition up if on the top of the map
    if @real_y == 0 && !$game_map.maplinks[3].nil?
      $game_map.map_link_transition(3, $game_player.real_x / 128, 
                                    $game_map.height - 1, 8)
    end
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  attr_reader :panorama
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  alias max_slide_update_later update unless $@
  def update
    max_slide_update_later
    if $game_temp.map_slide != 0
      #hold the panorama in place
      @spriteset.panorama.ox = 0
      @spriteset.panorama.oy = 0
      if $game_temp.map_slide == 1
        #refresh the spriteset
        @spriteset.dispose
        @spriteset = Spriteset_Map.new
        #transition to the slide map
        Graphics.transition(0)
        #increment map slide
        $game_temp.map_slide = 2
      elsif $game_temp.map_slide == 2
        #if not scrolling
        unless $game_map.scrolling?
          #account for diagonal movement
          if $xrxs_xas && XAS::DIAGONAL_MOVEMENT
            $game_player.quarter = false
            $game_player.direction = $game_temp.player_new_direction
          end
          #move the player onto the map
          $game_player.move_forward
          #change new location if moving diagonally
          if $game_player.direction == 2 || $game_player.direction == 8
            if $game_player.x < $game_player.real_x / 128
              $game_temp.player_new_x -= 1
            elsif $game_player.x > $game_player.real_x / 128
              $game_temp.player_new_x += 1
            end
          elsif $game_player.direction == 4 || $game_player.direction == 6
            if $game_player.y < $game_player.real_y / 128
              $game_temp.player_new_y -= 1
            elsif $game_player.y > $game_player.real_y / 128
              $game_temp.player_new_y += 1
            end
          end
          #increment map slide
          $game_temp.map_slide = 3
        end
      elsif $game_temp.map_slide == 3
        #if the player isn't moving
        unless $game_player.moving?
          #deflag map slide
          $game_temp.map_slide = 0
          #save the fog location
          fog_ox = $game_map.fog_ox + ($game_player.direction == 6 ? 640 : 0)
          fog_oy = $game_map.fog_oy + ($game_player.direction == 2 ? 480 : 0)
          #get the x_offset
          x_offset = $game_map.display_x % 128
          #transfer the player to the new map
          transfer_player
          #increment the offset
          $game_map.display_x -= $game_map.display_x % 128 - x_offset
          #reset fog location
          $game_map.fog_ox = fog_ox - $game_map.display_x / 4 + x_offset / 4
          $game_map.fog_oy = fog_oy - $game_map.display_y / 4
          #update the spriteset to move the fog into position
          @spriteset.update
        end
      end
    end
  end
end