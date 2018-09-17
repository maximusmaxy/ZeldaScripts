#===============================================================================
# ¦ PZE Shop
#-------------------------------------------------------------------------------
# 2D OoT/MM Style Shop
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.4: 9/3/12
#===============================================================================
#
# Introduction:
# Replaces the default shop system with an on screen map shop, similar to the
# shops featured in the 3D Zelda games.
# 
# Instructions:
# There are two things you will need to do to set up your shop. The first is
# to set up your shop keeper event, and what he will say in what situation.
# This requires a simple eventing setup which will be explained bellow. The
# seccond thing to do is to setup your shop items.
#
# Shop Keeper:
# The shop keeper uses an eventing setup using labels to determine what the
# shop keeper says, when and where. The script will handle the processing of 
# the labels, all you need to do is fill them out.
# 
# the required labels are:
# introduction - what the shop keeper says when highlighted.
# talk - what the shop keeper says when you talk to him.
# success - what the shop keeper says when you successfully buy an item.
# error - what the shop keeper says if you don't have enough gold/rupee's.
# exit - what the shop keeper says when you are leaving.
#
# the additional labels are:
# tags - these will be put before every message
# item - what the shop keeper says when an item is highlighted.
# buy - what the shop keeper says when you try to buy an item.
# condition - what the shop keeper says if you don't meet the items condition.
# recieve - what the shop keeper says when you recieve an item.
#
# Shop Items:
# The shop items are events placed wherever you want on the map. Shop item
# events must be titled '<Item>'. They use a simple comment setup, so you can
# specify the item, the amount of the item, and the stock limit of the item.
#
# The required comments are:
# id - the id of the item in the database
# type - can be 'item', 'weapon' or 'armor'
# 
# The additional comments are:
# amount - the amount of the item (defaults as 1)
# limit - the limit of that item (defaults as unlimited)
# price - the price of the item (defaults as the value in the database)
# condition - the conditional requirement of the item, can be:
#             'item' - requires at least one of an item
#             'weapon' - requires at least one of a weapon
#             'armor' - requires at least one of an armor
#             'switch' - requires a switch to be triggered
# condition_id - the id of the switch,item,weapon,armor in the database
#
# Here is an example of how to set up your comments
#
# id: 200
# type: weapon
# amount: 20 
# 
# This will refference weapon id 200 in the database, and will sell you 20
# of that weapon at a time.
#
# If you want to specify different text for an item, you may use the labels
# method used by the shop keeper to create your own custom messages. The
# labels used by the item can be:
# item, buy, success, error, condition and receive
# If a label isn't specified the default in the configuration will be used.
#
# Script Calls:
#
# setup_shop
# Starts the shopping scene, it's not required if using AUTOSHOP
#
# The following script calls reset all limits back to normal
#
# SHOP.reset(MAP)  resets the shop at the specified MAP id
# SHOP.reset       resets all shops
# 
# the following script calls manually adjust shop item limits
#
# SHOP.limit(MAP, EVENT, VALUE)    sets the limit
# SHOP.add(MAP, EVENT, VALUE)      adds to the limit
# SHOP.subtract(MAP, EVENT, VALUE) subtracts from the limit
#
# MAP is the id of shop map
# EVENT is the id of the event
# VALUE is the number you are setting, adding or subtracting
#
#===============================================================================

$pze_shop = 0.4

module SHOP
  
#===============================================================================
# Configuration
#===============================================================================
  #Automatically start the shop
  AUTOSHOP = false
  #Shop Hud Images
  DOWN = "HUD_Shop_Down"
  DOWN_X = 320
  DOWN_Y = 300
  LEFT = "HUD_Shop_Left"
  LEFT_X = 220
  LEFT_Y = 220
  RIGHT = "HUD_Shop_Right"
  RIGHT_X = 420
  RIGHT_Y = 220
  UP = "HUD_Shop_Up"
  UP_X = 320
  UP_Y = 140
  #Speed at which the hud images bounce
  SPEED = 5
  #Distance from the origin they bounce in pixels
  DISTANCE = 10
  #Whether the arrows follow the cursor or use the aforementioned X & Y
  ARROWS_FOLLOW_CURSOR = true
  #Whether to hide Max's cursor (only works if arrows follow the cursor)
  HIDE_DEFAULT_CURSOR = false
  #Whether to bounce the arrows
  BOUNCING_ARROWS = true
  #Fanfare Sound effect = RPG::AudioFile.new("name", volume, pitch)
  FANFARE = RPG::AudioFile.new("Dungeon - Item - Item Discovered 01", 100, 100)
  #Word Setup
  ACCEPT = "\\u[3]I'll buy them"
  CANCEL = "\\u[3]No thanks"
  #The Item/Buy message is created by the script depending on the item selected
  #/name is replaced by the items name
  #/price is replaced by the price of the item
  #/amount is replaced by the amount of the item
  #/limit is replaced by the limit of the item
  #/gold is replaced by the currency you are using
  #/description is replaced by the item description
  #/condition is replaced with the name of the condition item
  #\n is replaced with a line break
  #you can use CMS tags to change the color ect.
  ITEM = "\\sp[0]\\u[2]/name:   \\u[3]/price /gold\\u[0]\n/description"
  BUY = "\\sp[0]\\u[2]/name:   \\u[3]/price /gold\\u[0]\\*"
  RECEIVE = "You got \\u[2]/name\\u[0]!\nIs there anything else you may need?"
  CONDITION_ITEM = "I'm sorry, you'll need a /condition if you want to buy one of those. Come back when you have one."
  CONDITION_SWITCH = "I'm sorry, you can't buy that at the moment, come back later."
  #Add plurals to the currency name
  PLURAL = true
#===============================================================================
# End Configuration
#===============================================================================
  
  def self.reset(map = 0)
    if map == 0
      $game_system.shop_item_limits.clear
    else
      $game_system.shop_item_limits.each do |limit|
        $game_system.shop_item_limits.delete(limit) if limit[0] == map
      end
    end
    self.refresh
    return true
  end
  
  def self.limit(map, event, value)
    $game_system.shop_item_limits[[map, event]] = value
    self.refresh
    return true    
  end
  
  def self.add(map, event, value)
    $game_system.shop_item_limits[[map, event]] += value
    self.refresh
    return true 
  end
  
  def self.subtract(map, event, value)
    $game_system.shop_item_limits[[map, event]] -= value
    self.refresh
    return true 
  end
  
  def self.refresh
    $game_map.events.each_value do |event|
      event.setup_shop_item unless event.shop_item.nil?
    end
  end
  
  def self.setup_sublist(list, string)
    #temp list to store commands
    sublist = []
    #create a temp index
    index = 0
    #increment index until the list parameter has been met
    until list[index].code == 118 &&
          list[index].parameters[0].downcase == string
      index += 1
      #return if the index reaches the end of the list
      return sublist if index >= list.size
    end
    #increment to the next line
    index += 1
    #add commands to the list until reaching the next label
    until list[index].code == 118
      sublist.push list[index] unless [108,408].include?(list[index].code)
      index += 1
      #skip check if the index has reached the end of the code
      break if index >= list.size
    end
    #return the sublist
    return sublist
  end
  
#===============================================================================
# SHOP::Shop
#===============================================================================

class Shop
  attr_reader :index
  attr_reader :tags
  attr_reader :introduction
  attr_reader :talk
  attr_reader :item
  attr_reader :buy
  attr_reader :success
  attr_reader :error
  attr_reader :condition
  attr_reader :receive
  attr_reader :exit
  attr_accessor :input
  attr_reader :directions
  def initialize
    @events = []
    @positions = []
    @index = 0
    @tags = []
    @introduction = []
    @talk = []
    @item = []
    @buy = []
    @success = []
    @error = []
    @condition = []
    @receive = []
    @exit = []
    @input = true
    @directions = []
  end
    
  def event
    return @events[@index]
  end
  
  def shop_item
    return @events[@index].shop_item.shop_item
  end

  def shop_keeper?
    return false if @events[@index].nil?
    return @events[@index].shop_item.nil?
  end
  
  def setup(event_id)
    #loop through each map coordinate
    $game_map.width.times {|x| $game_map.height.times {|y|
    #get the event id at the current coordinate
      id = $game_map.check_event(x, y)
      #go to next itteration if no event exists
      next if id.is_a?(Array)
      #get the event
      check_event = $game_map.events[id]
      #if the event is a shop item event or the shop keeper
      if !check_event.shop_item.nil? || event_id == id
        #add the event and position
        @events << check_event 
        @positions << [check_event.x, check_event.y]
        #set index if the event is a shop keeper
        @index = @events.size - 1 if event_id == id
      end
    }}
    #make the event rectangle to save some processing time
    @rect = Rect.new(@positions.min{|a,b| a[0] - b[0]}[0],
                     @positions.min{|a,b| a[1] - b[1]}[1],
                     @positions.max{|a,b| a[0] - b[0]}[0],
                     @positions.max{|a,b| a[1] - b[1]}[1])
    #get the list of the shop keeper
    list = self.event.list
    #setup sublists of the main list
    ['tags', 'introduction', 'talk', 'item', 'buy', 'success', 'error',
    'condition', 'receive', 'exit'].each do |string| 
      eval("@#{string} = SHOP.setup_sublist(list, string)")
    end
  end
  
  def change_index(direction)
    #if there is a direction specified change the index
    if direction != 0
      #return if the next move can't be completed
      return unless @directions.include?(direction)
      index = check_index(direction)
      return if index.nil?
      @index = index
    end
    #check in all directions for possible next move
    @directions = []
    @directions.push 2 unless check_index(2).nil?
    @directions.push 4 unless check_index(4).nil?
    @directions.push 6 unless check_index(6).nil?
    @directions.push 8 unless check_index(8).nil?
  end
  
  def check_index(direction)
    #get the current position
    x, y = *@positions[@index]
    #get the direction increments
    xi = (direction == 6 ? 1 : direction == 4 ? -1 : 0)
    yi = (direction == 2 ? 1 : direction == 8 ? -1 : 0)
    xj = (direction == 4 || direction == 6 ? 0 : 1)
    yj = (direction == 2 || direction == 8 ? 0 : 1)
    #get the last loop iteration
    case direction
    when 2 then last = @rect.height - y
    when 4 then last = x - @rect.x
    when 6 then last = @rect.width - x
    when 8 then last = y - @rect.y
    end
    #loop through each position based on direction
    (0..last).each do |i|
      (0..i).each do |j|
        #next iteration if first loop
        next if i == 0
        #check to the left
        index = @positions.index([x + xi * i + j * xj, y + yi * i + j * yj])
        return index unless index.nil?
        #next iteration if center
        next if j == 0
        #check to the right
        index = @positions.index([x + xi * i - j * xj, y + yi * i - j * yj])
        return index unless index.nil?
      end
    end
    return nil
  end
  
  def shop_keeper_index
    @index = (@index + 1) % @events.size until shop_keeper?
    change_index(0)
  end
  
  def remove_event(event)
    return unless event.shop_item.limited
    if event.shop_item.limit == 0
      event.shop_item = nil
      index = @events.index(event)
      @events.delete_at(index)
      @positions.delete_at(index)
      shop_keeper_index
    end   
  end
end

#===============================================================================
# SHOP::Item
#===============================================================================

class Item
  attr_accessor :id
  attr_accessor :type
  attr_accessor :amount
  attr_writer :price
  attr_accessor :limited
  attr_accessor :limit
  attr_accessor :condition_type
  attr_accessor :condition_id
  attr_reader :item
  attr_reader :buy
  attr_reader :success
  attr_reader :error
  attr_reader :condition
  attr_reader :receive
  def initialize(event)
    @event_id = event.id
    @id = 0
    @type = 0
    @amount = 1
    @price = 0
    @limit = 0
    @limited = false
    @condition_type = 0
    @condition_id = 0
    @item = []
    @buy = []
    @success = []
    @error = []
    @condition = []
    @receive = []
    #setup sublists of the main list
    ['item','buy','success','error','condition','receive'].each do |string| 
      eval("@#{string} = SHOP.setup_sublist(event.list, string)")
    end
  end
  
  def shop_item
    #return the item based on type
    case @type
    when 1 then return $data_items[@id]
    when 2 then return $data_weapons[@id]
    when 3 then return $data_armors[@id]
    end
  end
  
  def price
    return @price if @price != 0
    return shop_item.price
  end
  
  def decrease_limit
    #decreases the item limit if limited and checks for item removal
    return unless @limited
    @limit -= 1
    $game_system.shop_item_limits[[$game_map.map_id, @event_id]] -= 1
    $game_map.events[@event_id].transparent = true if @limit <= 0
  end
  
  def condition?
    #determine if the item can be bought
    case @condition_type
    when 0 then return true
    when 1 then return $game_party.item_number(@condition_id) > 0
    when 2 then return $game_party.weapon_number(@condition_id) > 0
    when 3 then return $game_party.armor_number(@condition_id) > 0
    when 4 then return $game_switches[@condition_id]
    end
  end
  
  def condition_name
    #return the name of the conditional item
    case @condition_type
    when 1 then return $data_items[@condition_id].name
    when 2 then return $data_weapons[@condition_id].name
    when 3 then return $data_armors[@condition_id].name
    end
    return ''
  end
end

end

#===============================================================================
# Game_System
#===============================================================================

class Game_System
  attr_accessor :shop_item_limits
  alias max_shop_initialize_later initialize
  def initialize
    max_shop_initialize_later
    @shop_item_limits = {}
  end
end

#===============================================================================
# Game_Map
#===============================================================================

class Game_Map
  alias max_shop_setup_later setup
  def setup(*args)
    max_shop_setup_later(*args)
    #setup the shop if there is a shop keeper
    @events.each_value do |event| 
      event.shop_keeper.setup(event.id) unless event.shop_keeper.nil?
    end
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_accessor :shop_keeper
  attr_accessor :shop_item
  alias max_shop_initialize_later initialize
  def initialize(*args)
    max_shop_initialize_later(*args)
    #setup shop item if the event's name is <Item>
    name = @event.name.downcase
    @shop_keeper = SHOP::Shop.new if name == '<shop>'
    setup_shop_item if name == '<item>'
  end

  def setup_shop_item
    #skip setup if there is no list
    return if @list.nil?
    #deactivate the trigger
    @trigger = -1
    #disable transparency
    @transparent = false
    #setup a new shop item
    @shop_item = SHOP::Item.new(self)
    #loop through each command
    @list.each do |command|
      #skip iteration if the command isn't a comment
      next unless [108,408].include?(command.code)
      #if the comment follows the format( PARAMETER: VALUE )
      if command.parameters[0] =~ /(\w*)\:\s*(\w*)/
        case $1.downcase
        when 'id' #set the id in the database
          @shop_item.id = $2.to_i
        when 'type' #set the type
          case $2.downcase
          when 'item' then @shop_item.type = 1
          when 'weapon' then @shop_item.type = 2
          when 'armor' then @shop_item.type = 3
          end
        when 'amount' #get the amount
          @shop_item.amount = $2.to_i
        when 'price' #get the price
          @shop_item.price = $2.to_i
        when 'limit' #set the limit
          next if $2.to_i == 0
          @shop_item.limited = true
          key = [$game_map.map_id, @id]
          #create a limit if it doesn't exist
          if $game_system.shop_item_limits[key].nil?
            $game_system.shop_item_limits[key] = $2.to_i
            @shop_item.limit = $2.to_i
            #if the limit has run out, remove the item
            if @shop_item.limit == 0
              @transparent = true
              @shop_item = nil
              return
            end
          else #else set the stored limit
            @shop_item.limit = $game_system.shop_item_limits[key]
          end
        when 'condition' #set the condition type
          case $2.downcase
          when 'item' then @shop_item.condition_type = 1
          when 'weapon' then @shop_item.condition_type = 2
          when 'armor' then @shop_item.condition_type = 3
          when 'switch' then @shop_item.condition_type = 4
          end
        when 'condition_id' #set the condition id
          @shop_item.condition_id = $2.to_i
        end
      end
    end
  end
end

#===============================================================================
# Sprite_Shop_Hud
#===============================================================================

class Sprite_Shop_Hud
  def initialize
    #down sprite
    @down = Sprite.new
    @down.bitmap = RPG::Cache.picture(SHOP::DOWN)
    @down.x = SHOP::DOWN_X - @down.bitmap.width / 2
    @down.y = SHOP::DOWN_Y - @down.bitmap.height / 2
    #left sprite
    @left = Sprite.new
    @left.bitmap = RPG::Cache.picture(SHOP::LEFT)
    @left.x = SHOP::LEFT_X - @left.bitmap.width / 2
    @left.y = SHOP::LEFT_Y - @left.bitmap.height / 2
    #right sprite
    @right = Sprite.new
    @right.bitmap = RPG::Cache.picture(SHOP::RIGHT)
    @right.x = SHOP::RIGHT_X - @right.bitmap.width / 2
    @right.y = SHOP::RIGHT_Y - @right.bitmap.height / 2
    #up sprite
    @up = Sprite.new
    @up.bitmap = RPG::Cache.picture(SHOP::UP)
    @up.x = SHOP::UP_X - @up.bitmap.width / 2
    @up.y = SHOP::UP_Y - @up.bitmap.height / 2
    #store all sprites in an array and initialize some data
    @sprites = [@down, @left, @right, @up]
    @sprites.each do |sprite| 
      sprite.z = 10000
      sprite.visible = false
    end
    @count = 0
    @speed = SHOP::SPEED
    @distance = SHOP::DISTANCE
    @bouncing = SHOP::BOUNCING_ARROWS
    @arrows_follow_pze_cursor = SHOP::ARROWS_FOLLOW_CURSOR
    @hide_cursor = SHOP::HIDE_DEFAULT_CURSOR
    # Move the sprites to the correct position
    update_arrow_pos
  end
  
  def dispose
    #dispose all sprites
    @sprites.each {|sprite| sprite.dispose}
  end
  
  def update(visible, directions)
    #disable visibillity of all sprites if not visible
    if visible
      if @hide_cursor and @arrows_follow_pze_cursor
        $scene.spriteset.set_invisible_map_cursor
      end
    else
      $scene.spriteset.set_visible_map_cursor
      return @sprites.each {|sprite| sprite.visible = false}
    end
    #else make visible the sprites that are included in the directions
    @down.visible = directions.include?(2)
    @left.visible = directions.include?(4)
    @right.visible = directions.include?(6)
    @up.visible = directions.include?(8)
    # Move to the new base position
    update_arrow_pos
    #if bouncing
    if @bouncing
      #increment the count
      @count = (@count += @speed) % 360
      #get the absolute value of the sine wave
      sin = Math.sin(@count * Math::PI / 180).abs
      #make the sprites bounce
      @down.oy = -sin * @distance
      @left.ox = sin * @distance
      @right.ox = -sin * @distance
      @up.oy = sin * @distance
    end
  end
  
  def update_arrow_pos
    # If we are following the cursor
    if $pze_cursor and @arrows_follow_pze_cursor
      cursor = $scene.spriteset.map_cursor
      return if cursor.nil?
      x, y = cursor.x, cursor.y
      cw, ch = cursor.width * 2, cursor.height * 2
      @left.x = x - @left.bitmap.width
      @right.x = x + cw
      @up.x = x + cw / 2 - @up.bitmap.width / 2
      @down.x = x + cw / 2 - @down.bitmap.width / 2
      @left.y = y + ch / 2 - @left.bitmap.height / 2
      @right.y = y + ch / 2 - @right.bitmap.height / 2
      @up.y = y - @up.bitmap.height
      @down.y = y + ch
    end
  end
end

#===============================================================================
# Interpreter
#===============================================================================

class Interpreter
  alias max_shop_update_later update
  alias max_shop_setup_later setup
  def update
    #update the shop if needed
    update_shop
    max_shop_update_later
  end
  
  def setup(*args)
    max_shop_setup_later(*args)
    #setup shop if the event is a shop keeper and autoshop
    if SHOP::AUTOSHOP && $game_map.events.include?(@event_id) &&
       !$game_map.events[@event_id].shop_keeper.nil? && @shop.nil?
      setup_shop
    end
  end
  
  def setup_shop
    #create a new shop
    @shop = $game_map.events[@event_id].shop_keeper.clone
    @shop.shop_keeper_index
    #create the shop hud
    @shop_hud = Sprite_Shop_Hud.new
    #show the cursor if it exists
    CURSOR.show(@event_id) if $pze_cursor
    #set the hud action text if it exists
    $game_temp.hud_action_text = 'Talk' if $nr_zelda_hud
    #setup the introduction list
    shop_keeper
  end
  
  def event_command(code = 0, parameters = [], indent = 0)
    #returns a new event command with specified code, parameters and indent
    command = RPG::EventCommand.new
    command.code = code
    command.parameters = parameters
    command.indent = indent
    return command
  end
  
  def update_shop
    #return if the shop doesn't exist
    return if @shop.nil?
    #update the shop hud
    @shop_hud.update(@shop.input, @shop.directions)
    #return if the shop isn't inputtable
    return unless @shop.input
    #exit if the cancel button is pressed
    if Input.trigger?(Input::B)
      shop_exit
      return
    end
    #get the current index of the shop
    index = @shop.index
    #if a direction is triggered, change the index
    @shop.change_index(2) if Input.trigger?(Input::DOWN)
    @shop.change_index(4) if Input.trigger?(Input::LEFT)
    @shop.change_index(6) if Input.trigger?(Input::RIGHT)
    @shop.change_index(8) if Input.trigger?(Input::UP)
    #return if the index hasn't changed
    return if index == @shop.index
    #play the cursor sound effect
    $game_system.se_play($data_system.cursor_se)
    #show the introduction if the event is the shop keeper
    if @shop.shop_keeper?
      shop_keeper
    else #else show the item
      shop_item
    end
    #refresh the message window
    $scene.message_window.dispose
    $scene.message_window = Window_Message.new
    #move the cursor if it exists
    CURSOR.move(@shop.event.id, 10) if $pze_cursor
  end
  
  def format_shop_message(message)
    #get the shop item
    item = @shop.shop_item
    #get the event
    event = @shop.event
    #format the string
    string = message.clone
    string.gsub!(/\/name/) {|s| s = item.name}
    string.gsub!(/\/description/) {|s| s = item.description}
    string.gsub!(/\/price/) {|s| s = event.shop_item.price}
    string.gsub!(/\/amount/) {|s| s = event.shop_item.amount}
    string.gsub!(/\/limit/) {|s| s = event.shop_item.limit}
    string.gsub!(/\/condition/) {|s| s = event.shop_item.condition_name}
    string.gsub!(/\/gold/) do |s| 
      if !SHOP::PLURAL || item.price == 1
        s = $data_system.words.gold
      else
        s = $data_system.words.gold + 's'
      end
    end
    #return the string
    return string
  end
  
  def shop_keeper
    #set the hud action text if it exists
    $game_temp.hud_action_text = 'Talk' if $nr_zelda_hud
    #initialize a blank list
    list = []
    #add the shop introduction
    list.push event_command(118, ['start'])
    list.push *@shop.tags
    list.push *@shop.introduction
    list.push event_command(355, ['@shop.input = false;return true'])
    list.push event_command(355, ['CURSOR.hide']) if $pze_cursor
    list.push *@shop.tags
    list.push *@shop.talk
    list.push event_command(355, ['CURSOR.show(@event_id)'])
    list.push event_command(355, ['@shop.input = true'])
    list.push event_command(119, ['start'])
    list.push event_command
    #setup the list 
    setup(list, @event_id)
    return false
  end
  
  def shop_exit
    #set the hud action text if it exists
    $game_temp.hud_action_text = 'Talk' if $nr_zelda_hud
    #refresh the window
    $scene.message_window.dispose
    $scene.message_window = Window_Message.new
    #play the cancel sound effect
    $game_system.se_play($data_system.cancel_se)
    #disable shop input
    @shop.input = false
    #hide the cursor if it exists
    CURSOR.hide if $pze_cursor
    #initialize a blank list
    list = []
    #add the shop leave commands
    list.push *@shop.tags
    list.push *@shop.exit
    list.push event_command(355, ['shop_dispose;return true'])
    list.push event_command
    #setup the list 
    setup(list, @event_id)
    return false
  end
  
  def shop_item
    #Set the Hud action text if it exists
    $game_temp.hud_action_text = 'Buy' if $nr_zelda_hud
    #initialize a blank list
    list = []
    #get the event
    event = @shop.event
    #create the item message
    list.push event_command(118, ['start'])
    list.push *@shop.tags
    if event.shop_item.item.empty?
      if @shop.item.empty?
        list.push event_command(101, [format_shop_message(SHOP::ITEM)])
      else
        list.push *@shop.item
      end      
    else
      list.push *event.shop_item.item
    end
    list.push event_command(355, ['@shop.input = false;return true'])
    list.push event_command(250, [$data_system.decision_se])
    list.push *@shop.tags
    if event.shop_item.buy.empty?
      if @shop.buy.empty?
        list.push event_command(101, [format_shop_message(SHOP::BUY)])
      else
        list.push *@shop.buy
      end
    else
      list.push *event.shop_item.buy
    end
    list.push event_command(102, [[SHOP::ACCEPT, SHOP::CANCEL], 2])
    list.push event_command(402, [0, SHOP::ACCEPT])
    list.push event_command(355, ['shop_purchase'], 1)
    list.push event_command(0, [], 1)
    list.push event_command(402, [1, SHOP::CANCEL])
    list.push event_command(355, ['@shop.input = true'])
    list.push event_command(119, ['start'], 1)
    list.push event_command(0, [], 1)
    list.push event_command(404)
    list.push event_command
    #setup the list 
    setup(list, @event_id)
    return false
  end
  
  def shop_purchase
    #initialize a blank list
    list = []
    #get the event
    event = @shop.event
    #get the shop item
    item = @shop.shop_item
    list.push *@shop.tags
    #if you don't have enough gold, show the error message
    if event.shop_item.price > $game_party.gold
      if event.shop_item.error.empty?
        list.push *@shop.error
      else
        list.push *event.shop_item.error
      end       
      list.push event_command(355, ['@shop.input = true'])
      list.push event_command(355, ['shop_item'])
    #if you don't meet the requirements, show the condition message
    elsif !event.shop_item.condition?
      if event.shop_item.condition.empty?
        if @shop.condition.empty?
          if event.shop_item.condition_type == 4
            message = format_shop_message(SHOP::CONDITION_SWITCH)
          else
            message = format_shop_message(SHOP::CONDITION_ITEM)
          end
          list.push event_command(101, [message])
        else
          list.push *@shop.condition
        end
      else
        list.push *event.shop_item.condition
      end
      list.push event_command(355, ['@shop.input = true'])
      list.push event_command(355, ['shop_item'])
    #else buy the item
    else
      #hide the cursor
      CURSOR.hide if $pze_cursor
      #decrement gold
      $game_party.lose_gold(event.shop_item.price)
      #get the amount of the item
      amount = event.shop_item.amount
      #gain the item
      case item
      when RPG::Item then $game_party.gain_item(item.id, amount)
      when RPG::Weapon then $game_party.gain_weapon(item.id, amount)
      when RPG::Armor then $game_party.gain_armor(item.id, amount)
      end
      #add the sucess commands
      if event.shop_item.success.empty?
        list.push *@shop.success
      else
        list.push *event.shop_item.success
      end
      list.push event_command(249, [SHOP::FANFARE])
      discover = "DISCOVER.show(\"#{item.icon_name}\")"
      list.push event_command(355, [discover]) if $pze_discover
      list.push *@shop.tags
      if event.shop_item.receive.empty?
        if @shop.receive.empty?
          list.push event_command(101, [format_shop_message(SHOP::RECEIVE)])
        else
          list.push *@shop.receive
        end
      else
        list.push *event.shop_item.receive
      end
      list.push event_command(355, ['DISCOVER.hide'])
      list.push event_command(355, ['CURSOR.show(@event_id)']) if $pze_cursor
      list.push event_command(355, ['@shop.shop_keeper_index'])
      list.push event_command(355, ['@shop.input = true'])
      list.push event_command(355, ['shop_keeper'])
      #decrement the shop item
      event.shop_item.decrease_limit
      #remove the event from the shop if needed
      @shop.remove_event(event)
    end
    list.push event_command
    #setup the list 
    setup(list, @event_id)
    return false
  end
  
  def shop_dispose
    #dispose the shop
    @shop = nil
    #dispose the overlay
    @shop_hud.dispose
    #clear the hud action text
    $game_temp.hud_action_text = '' if $nr_zelda_hud
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  attr_accessor :message_window
end