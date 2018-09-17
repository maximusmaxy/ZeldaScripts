#===============================================================================
# ¦ PZE Minimap
#-------------------------------------------------------------------------------
# Displays an Ocarina of Time/Majora's Mask style Minimap
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.5: 6/1/12
# Thanks to:
# Blizzard, Charlie Fleed, Selwyn - Inspirational minimap scripts.
#===============================================================================
#
# Introduction:
# This script displays a passability minimap in the bottom right corner of the
# screen much like the minimap from Ocarina of Time and Majora's Mask. It
# displays passable tiles a darker color and impassable tiles a lighter color.
# The impassable eges of the map are shaved off, to give the map more shape.
# Because of the way the minimap is drawn you need to be passability conscious,
# as if tiles have the wrong passability, your minimap won't look as expected.
#
# Instructions:
# You can have certain events displayed as certain things on the minimap.
# Events with a transfer player command will be shown as white squares on 
# the minimap.
#
# Custom Images:
# You can define your own images to show up on the minimap eg. you can have an
# orange square for chests. The images for your minimap go in the icons
# folder. The setup follows the following format:
#
# CUSTOM[COMMENT] = FILENAME
# COMMENT is the comment flag you will be using eg. '\chest'
# FILENAME is the filename of the image in the icons folder
#
# To make the image show up on the minimap just place the comment specified
# on the event.
#
# It is recommended to have very small images otherwise they may appear too 
# big depending on your zoom ratio. 8x8 is a good size.
#
# Active Events:
# You can now show moving events shown on the minimap by specifying them in the
# configuration as active events. The setup is the same as custom images.
#
# ACTIVE[COMMENT] = FILENAME
# COMMENT is the comment flag you will be using eg. '\npc'
# FILENAME is the filename of the image in the icons folder
#
# However it should be noted that an event should not be specified as an active
# event unless necessary, as too many active events may cause lag. If an event
# doesn't move just use custom images.
#
# Script Calls:
#
# MINIMAP.enable
# enables the minimap
#
# MINIMAP.disable
# disables the minimap
#
# MINIMAP.temp_disable
# disables the minimap until map changes
#
# MINIMAP.refresh
# Refreshes the minimap. Call this if the passabillity of a map changes.
# (refreshing of transfers and images will be done automatically)
#
# MINIMAP.corner(CORNER)
# CORNER is the new corner 
# Top Left = 1, Top Right = 2, Bottom Left = 3, Bottom Right = 4
#
# MINIMAP.offset(X, Y)
# X, Y is the new offset from the selected corner
#
# MINIMAP.zoom(RATIO)
# RATIO is the new zoom ratio
#
#===============================================================================

$pze_minimap = 0.5

module MINIMAP
  CUSTOM = {}
  ACTIVE = {}
#===============================================================================
# Configuration
#===============================================================================
  #display the minimap, can be changed with a script call
  MINIMAP = true
  #Corner The minimap is displayed in. UL = 1, UR = 2, DL = 3, DR = 4
  CORNER = 4
  #set the offset from the corner of the map in pixels
  X = 4
  Y = 4
  #set the minumum and maximum opacity of the minimap
  MIN = 80
  MAX = 160
  #set the zoom ratio, this value is the maximum amount of visible tiles shown
  #on the minimap, if the width/height of the map is larger then this value
  #then the minimap will scroll when neccessary.
  ZOOM = 35
  #select your minimap colours - Color.new(RED,GREEN,BLUE)
  PLAYER = Color.new(255,255,0) #player arrow
  ENTRANCE = Color.new(255,0,0) #entrance location arrow
  PASS = Color.new(30,100,100) #passable 
  NO_PASS = Color.new(30,180,180) #not passable
  BORDER = Color.new(30,180,180) #outer border
  TRANSFER = Color.new(255,255,255) #transfer events
  #Custom image setup
  CUSTOM['\chest'] = 'Minimap_Chest_Small'
  CUSTOM['\bigchest'] = 'Minimap_Chest_Big'
  CUSTOM['\owl'] = 'Minimap_Owl_Statues'
  CUSTOM['\warp'] = 'Minimap_Warps'
  CUSTOM['\portal'] = 'Minimap_Warps'
  #Active event setup
  ACTIVE['\npc'] = 'Minimap_NPC'
#===============================================================================
# End Configuration
#===============================================================================

  def self.enable
    $game_system.minimap = true
    return true
  end
  
  def self.disable
    $game_system.minimap = false
    return true
  end
  
  def self.temp_disable
    $game_system.minimap_disable = true
    return true
  end
  
  def self.refresh
    $scene.spriteset.minimap.dispose
    $scene.spriteset.minimap = Sprite_Minimap.new
    return true
  end
  
  def self.corner(corner)
    $game_system.minimap_corner = corner
    $scene.spriteset.minimap.setup_viewport
    return true
  end
  
  def self.offset(x, y)
    $game_system.minimap_offset = [x, y]
    $scene.spriteset.minimap.setup_viewport
    return true
  end
  
  def self.zoom(ratio)
    $game_system.minimap_zoom = ratio
    self.refresh
    return true
  end
  
  #=============================================================================
  # Arrows
  #=============================================================================

  class Arrows
    attr_reader :player
    attr_reader :last
    def initialize
      #caches for storing the player arrows
      @player = {}
      @last = {}
      #draw the player triangles
      draw_triangle(@player, PLAYER, [1,3,5,7], 7) #odd
      draw_triangle(@player, PLAYER, [2,4,6,8], 8) #even
      draw_triangle(@last, ENTRANCE, [1,3,5,7], 7) #odd
      draw_triangle(@last, ENTRANCE, [2,4,6,8], 8) #even
    end
    
    def draw_triangle(arrow, color, array, size)
      array.each do |direction|
        arrow[direction] = Bitmap.new(size, size)
        (0...(size + 1) / 2).each do |i|
          (0...(size - i * 2)).each do |j|
            case direction
            when 1,2 #down
              arrow[direction].set_pixel(j + i, i + 2, color)
            when 3,4 #left
              arrow[direction].set_pixel(6 - i, j + i, color)
            when 5,6 #right
              arrow[direction].set_pixel(2 + i, j + i, color)
            when 7,8 #up
              arrow[direction].set_pixel(j + i, 6 - i, color)
            end
          end
        end
      end
    end
  end
  #create a arrows object
  ARROWS = Arrows.new
end

#===============================================================================
# Game_Temp
#===============================================================================

class Game_Temp
  attr_accessor :minimap_refresh
  attr_accessor :minimap_last
  alias max_minimap_initialize_later initialize
  def initialize
    max_minimap_initialize_later
    #minimap refresh variable
    @minimap_refresh = false
    #minimap last location
    @minimap_last = []
  end
end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :minimap
  attr_accessor :minimap_corner
  attr_accessor :minimap_offset
  attr_accessor :minimap_zoom
  attr_accessor :minimap_disable
  alias max_minimap_initialize_later initialize
  def initialize
    max_minimap_initialize_later
    #minimap variables
    @minimap = MINIMAP::MINIMAP
    @minimap_corner = MINIMAP::CORNER
    @minimap_offset = [MINIMAP::X, MINIMAP::Y]
    @minimap_zoom = MINIMAP::ZOOM
    @minimap_disable = false
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  #class variable for the minimap passability
  @@minimap_passability = {}
  attr_reader :minimap_passability
  attr_reader :minimap_border
  alias max_minimap_setup_later setup
  def setup(*args)
    #if the minimap has been temporarily disabled, re-enable
    $game_system.minimap_disable = false
    max_minimap_setup_later(*args)
    #if the minimap passability data doesn't exist
    if @@minimap_passability[@map_id].nil?
      #setup the minimap passability table
      setup_minimap_passability
    else
      #else load the passability data
      @minimap_passability = @@minimap_passability[@map_id]
    end
  end
  
  #setup the minimap passability table
  def setup_minimap_passability
    #create the table
    @minimap_passability = Table.new(width, height, 2)
    #initialize checks
    @minimap_check = []
    @minimap_checked = false
    #loop through each map coordinate
    (0...width).each do |i|
      (0...height).each do |j|
        #prevent script hanging error if too many iterations have occured
        Graphics.update if (i * width + j) % 50000 == 0
        #get passability for each direction of the coordinate and store it
        pass = 0
        pass |= 1 if mpassable?(i, j, 2) #down 
        pass |= 2 if mpassable?(i, j, 4) #left
        pass |= 4 if mpassable?(i, j, 6) #right
        pass |= 8 if mpassable?(i, j, 8) #up
        @minimap_passability[i,j,0] = pass #passability
        @minimap_passability[i,j,1] = 0 #borders
      end
    end
    #remove the outer edges
    check_minimap_outer(0, 0, 2, width, true) #top
    check_minimap_outer(0, height - 1, 8,width, true) #bottom
    check_minimap_outer(0, 0, 6, height, false) #left
    check_minimap_outer(width - 1, 0, 4, height, false) #right
    #remove the remaining adjacent impassable tiles
    loop do
      #check each side of each element in the array
      @minimap_check.each do |s|
        check_minimap_side(s[0], s[1] + 1, 2) #down
        check_minimap_side(s[0] - 1, s[1], 4) #left
        check_minimap_side(s[0] + 1, s[1], 6) #right
        check_minimap_side(s[0], s[1] - 1, 8) #up
        check_minimap_corner(s[0], s[1] + 1, s[0] - 1, s[1], 1) #dl
        check_minimap_corner(s[0], s[1] + 1, s[0] + 1, s[1], 3) #dr
        check_minimap_corner(s[0], s[1] - 1, s[0] - 1, s[1], 7) #ul
        check_minimap_corner(s[0], s[1] - 1, s[0] + 1, s[1], 9) #ur
        #remove the coordinate from checking
        s = nil
      end
      #loop until all are checked
      break unless @minimap_checked
      @minimap_checked = false
    end
    #save the minimap in the cache if map id is valid
    @@minimap_passability[@map_id] = @minimap_passability
  end
  
  #minimap passable check excluding tile ID events
  def mpassable?(x, y, d)
    return false unless valid?(x, y)
    bit = (1 << (d / 2 - 1)) & 0x0f
    for i in [2, 1, 0]
      tile_id = data[x, y, i]
      if tile_id == nil
        return false
      elsif @passages[tile_id] & bit != 0
        return false
      elsif @passages[tile_id] & 0x0f == 0x0f
        return false
      elsif @priorities[tile_id] == 0
        return true
      end
    end
    return true
  end
  
  #check the outer edges to be removed
  def check_minimap_outer(x,y,d,s,w)
    #get the x and y increments
    xi = w ? 1 : 0
    yi = w ? 0 : 1
    #loop through each coordinate
    (0...s).each do |i|
      #remove if impassible
      if @minimap_passability[x + xi * i, y + yi * i, 0] == 0
        @minimap_passability[x + xi * i, y + yi * i, 0] |= 16
        @minimap_check << [x + xi * i, y + yi * i]
      #add a border if passable
      elsif @minimap_passability[x + xi * i, y + yi * i, 0] < 16
        add_minimap_border(x + xi * i, y + yi * i, d)        
      end
    end
  end
  
  #remove the side
  def check_minimap_side(x,y,d)
    #return if invalid
    return unless valid?(x, y)
    #remove if impassable
    p x, y if @minimap_passability[x, y, 0].nil?
    if @minimap_passability[x,y,0] == 0
      @minimap_passability[x,y,0] |= 16
      @minimap_check.push [x,y]
      @minimap_checked = true
    #add a border if passable
    elsif @minimap_passability[x,y,0] < 16
      add_minimap_border(x,y,d)
    end
  end
  
  #check for inner corners
  def check_minimap_corner(x1,y1,x2,y2,d)
    #return if invalid
    return unless valid?(x1, y1) && valid?(x2, y2)
    #add corner border if both locations are passable
    if @minimap_passability[x1,y1,0] < 16 && @minimap_passability[x2,y2,0] < 16
      add_minimap_border(x2,y1,d)
    end
  end
  #adds a border to the location
  def add_minimap_border(x,y,d)
    #get exponent based on direction
    n = (d < 5 ? d - 1 : d - 2)
    #add to the border table
    @minimap_passability[x,y,1] |= 2 ** n
  end
end
    
#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_reader :erased
  attr_reader :minimap_custom
  attr_reader :minimap_transfer
  attr_reader :minimap_active
  alias max_minimap_refresh_later refresh
  def refresh
    max_minimap_refresh_later
    #check if the event is a minimap event
    minimap_event_check
  end
  
  def minimap_event_check
    #if the event has a list and not erased
    unless @list.nil? || @erased
      #search the events list
      @list.each do |line|
        #break if there is a show text command
        break if line.code == 101
        #if there is a transfer
        if line.code == 201
          #refresh the minimap if there is a change
          $game_temp.minimap_refresh = true unless @minimap_transfer
          @minimap_transfer = true
          return
        #if there is a comment
        elsif line.code == 108
          #if the comment is a custom minimap graphic
          if !MINIMAP::CUSTOM[line.parameters[0]].nil?
            #refresh the minimap if there is a change
            if @minimap_custom != line.parameters[0]
              $game_temp.minimap_refresh = true 
            end
            @minimap_custom = line.parameters[0]
            return
          #if the comment is an active event
          elsif !MINIMAP::ACTIVE[line.parameters[0]].nil?
            #refresh the minimap if there is a change
            if @minimap_active != line.parameters[0]
              $game_temp.minimap_refresh = true
            end
            @minimap_active = line.parameters[0]
            return
          end
        end
      end
    end
    #refresh the minimap if there is a change
    if @minimap_transfer || @minimap_custom != ''  || @minimap_active != ''
      $game_temp.minimap_refresh = true 
    end
    @minimap_transfer = false
    @minimap_custom = ''
    @minimap_active = ''
  end
end

#===============================================================================
# Sprite_Minimap
#===============================================================================

class Sprite_Minimap < Sprite
  #include MINIMAP module
  include MINIMAP
  
  def initialize
    #get the zoom ratio
    zoom = $game_system.minimap_zoom
    #determine the pixel increment dependant on height/width ratio
    if zoom < 80 && ($game_map.height > zoom || $game_map.width > zoom)
      @i = 160 / zoom
    elsif $game_map.height > 80 || $game_map.width > 80
      @i = 2
    elsif $game_map.height > $game_map.width
      @i = 160 / $game_map.height
    else
      @i = 160 / $game_map.width
    end
    #determine the even or odd player triangle
    @even = (@i % 2 == 0)
    #determine the player triangle adjustment variable
    @t = (@i + 1) / 2 - 4
    #determine the height and width
    @height = [$game_map.height, zoom].min * @i
    @width = [$game_map.width, zoom].min * @i
    #set the viewport
    super(Viewport.new(*setup_viewport))
    viewport.z = 9996
    #create the player arrow sprite
    @player = Sprite.new(self.viewport)
    @player.z = 1
    #create active events array
    @events = []
    #set up bitmap
    self.bitmap = Bitmap.new(@i * $game_map.width,@i * $game_map.height)
    #disable visibillity if scene isn't the map or map sliding
    if !$scene.is_a?(Scene_Map) || 
       (!$pze_slide.nil? && $game_temp.map_slide != 0)
      self.visible = false 
      @player.visible = false
      return
    end
    #get the background image
    draw_background
    #draw the background and event images
    refresh
    #update to get everything into the correct position
    update
  end
  
  def dispose
    #dispose the bitmap, player arrow, events and background
    self.bitmap.dispose
    @player.dispose
    @events.each {|sprite| sprite.dispose}
    @back.dispose unless @back.nil?
    super
  end

  def setup_viewport
    #get the x and y offsets
    x, y = *$game_system.minimap_offset
    #adjust the x and y values based on which corner is selected
    x = [2,4].include?($game_system.minimap_corner) ? 640 - x - @width : x
    y = [3,4].include?($game_system.minimap_corner) ? 480 - y - @height : y
    #if the viewport hasn't been created yet, return the values to the super
    return x, y, @width, @height if self.disposed?
    #set the rect
    viewport.rect.set(x, y, @width, @height)
  end
  
  def draw_background
    #create the background bitmap
    @back = Bitmap.new(@i * $game_map.width, @i * $game_map.height)
    #draw the background
    (0...$game_map.width).each do |i|
      (0...$game_map.height).each do |j|
        x = i * @i
        y = j * @i
        #draw the passability
        p = $game_map.minimap_passability[i,j,0]
        if p == 0
          @back.fill_rect(x, y, @i, @i, NO_PASS)
        elsif p < 16
          @back.fill_rect(x, y, @i, @i, PASS)
          @back.fill_rect(x, y + @i - 1, @i, 1, NO_PASS) if p & 0x01 != 0x01 #d
          @back.fill_rect(x, y, 1, @i, NO_PASS) if p & 0x02 != 0x02 #l
          @back.fill_rect(x + @i - 1, y, 1, @i, NO_PASS) if p & 0x04 != 0x04 #r
          @back.fill_rect(x, y, @i, 1, NO_PASS) if p & 0x08 != 0x08 #u
        end
        #draw the borders
        b = $game_map.minimap_passability[i,j,1]
        unless b == 0
          @back.set_pixel(x + @i - 1, y, BORDER) if b & 0x01 == 0x01 #ur
          @back.fill_rect(x, y, @i, 1, BORDER) if b & 0x02 == 0x02 #u
          @back.set_pixel(x, y, BORDER) if b & 0x04 == 0x04 #ul
          @back.fill_rect(x + @i - 1, y, 1, @i, BORDER) if b & 0x08 == 0x08 #r
          @back.fill_rect(x, y, 1, @i, BORDER) if b & 0x10 == 0x10 #l
          @back.set_pixel(x + @i - 1, y + @i - 1, BORDER) if b & 0x20 == 0x20 #dr
          @back.fill_rect(x, y + @i - 1, @i, 1, BORDER) if b & 0x40 == 0x40 #d
          @back.set_pixel(x, y + @i - 1, BORDER) if b & 0x80 == 0x80 #dl
        end
      end
    end
  end
  
  def refresh
    #clear the bitmap
    self.bitmap.clear
    #draw the background
    self.bitmap.blt(0, 0, @back, @back.rect)
    #dispose the active events that are no longer active events
    @events.each do |sprite|
      if sprite.event.minimap_active == ''
        sprite.dispose
        @events.delete(sprite)
      end
    end
    #draw the event images
    $game_map.events.each_value do |event|
      #next event if the event is erased
      next if event.erased
      x = event.x * @i
      y = event.y * @i
      #if event is a transfer
      if event.minimap_transfer
        self.bitmap.fill_rect(x, y, @i, @i, TRANSFER)
      #if the event is a custom image
      elsif !event.minimap_custom.nil? && event.minimap_custom != '' 
        bitmap = RPG::Cache.icon(CUSTOM[event.minimap_custom])
        w = (@i + 1) / 2 - bitmap.width / 2
        h = (@i + 1) / 2 - bitmap.height / 2
        self.bitmap.blt(x + w, y + h, bitmap, bitmap.rect)  
      elsif !event.minimap_active.nil? && event.minimap_active != '' 
        bitmap = RPG::Cache.icon(ACTIVE[event.minimap_active])
        @events << Sprite_Minimap_Event.new(self.viewport, event, bitmap)
        @events[-1].update(@i, self.x, self.y)
      end
    end
    #draw the player original location arrow
    last = $game_temp.minimap_last
    unless last.empty?
      bitmap = ARROWS.last[last[2] - (@even ? 0 : 1)]
      self.bitmap.blt(last[0] * @i + @t, last[1] * @i + @t, bitmap, bitmap.rect)
    end
    #clear the refresh flag
    $game_temp.minimap_refresh = false
  end
  
  def update
    #do not update if not visible
    return unless self.visible
    #refresh if needed
    refresh if $game_temp.minimap_refresh
    #update the bitmap scroll location
    scroll_x = @width / 2 - $game_player.real_x / 128.0 * @i
    self.x = [[@width - self.bitmap.width, scroll_x].max, 0].min
    scroll_y = @height / 2 - $game_player.real_y / 128.0 * @i
    self.y = [[@height - self.bitmap.height, scroll_y].max, 0].min
    #fade out if player is under the sprite
    if under?
      self.opacity = [self.opacity - 10, MIN].max
    #else fade in
    else
      self.opacity = [self.opacity + 10, MAX].min
    end
    #set the player arrow opacity to minimap opacity
    @player.opacity = self.opacity
    #change player arrow direction if needed
    if @player_direction != $game_player.direction
      @player_direction = $game_player.direction
      @player.bitmap = ARROWS.player[@player_direction - (@even ? 0 : 1)]
    end
    #move the player arrow
    @player.x = $game_player.real_x / 128.0 * @i + @t + self.x
    @player.y = $game_player.real_y / 128.0 * @i + @t + self.y
    #update each events opacity, and location
    @events.each do |event|
      event.opacity = self.opacity
      event.update(@i, self.x, self.y)
    end
  end
  
  def under?
    #return true if under, false if not
    rect = viewport.rect
    case $game_system.minimap_corner
    when 1
      return false if $game_player.screen_x > rect.x + rect.width + 16
      return false if $game_player.screen_y > rect.y + rect.height + 32
    when 2
      return false if $game_player.screen_x < rect.x - 16
      return false if $game_player.screen_y > rect.y + rect.height + 32
    when 3
      return false if $game_player.screen_x > rect.x + rect.width + 16
      return false if $game_player.screen_y < rect.y
    when 4
      return false if $game_player.screen_x < rect.x - 16
      return false if $game_player.screen_y < rect.y
    end
    return true
  end
end

#===============================================================================
# Sprite_Minimap_Event
#===============================================================================

class Sprite_Minimap_Event < Sprite
  attr_reader :event
  def initialize(viewport, event, bitmap)
    super(viewport)
    self.bitmap = bitmap
    @event = event
    @width = self.bitmap.width / 2
    @height = self.bitmap.height / 2
  end
  
  def update(i, x, y)
    #update the location
    self.x = @event.real_x / 128.0 * i + (i + 1) / 2 - @width + x
    self.y = @event.real_y / 128.0 * i + (i + 1) / 2 - @height + y
    self.opacity = 0 if @event.opacity == 0
  end
end

#===============================================================================
# Spriteset_Map
#===============================================================================

class Spriteset_Map
  attr_accessor :minimap
  alias max_minimap_dispose_later dispose
  alias max_minimap_update_later update
  def dispose
    max_minimap_dispose_later
    #dispose the minimap if it exists or not map sliding
    @minimap.dispose unless @minimap.nil?
  end
  
  def update
    max_minimap_update_later
    if $game_system.minimap && !$game_system.minimap_disable
      #create the minimap
      @minimap = Sprite_Minimap.new if @minimap.nil?
      #update the minimap
      @minimap.update
    elsif !@minimap.nil?
      #dispose the minimap
      @minimap.dispose
      @minimap = nil
    end
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  attr_reader :spriteset
  alias max_minimap_transfer_later transfer_player
  def transfer_player
    #store the last location arrow data
    if $game_temp.player_new_direction == 0
      direction = $game_player.direction
    else
      direction = $game_temp.player_new_direction
    end
    $game_temp.minimap_last = [$game_temp.player_new_x,
    $game_temp.player_new_y, direction]
    max_minimap_transfer_later
  end
end