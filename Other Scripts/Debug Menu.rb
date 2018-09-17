#===============================================================================
# ¦ Maximusmaxy's Debug Menu
#-------------------------------------------------------------------------------
# New options in the debug menu
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 1.0: 18/1/12
#===============================================================================
# 
# Note: To open the debug menu press F9 whilst playing.
#
# Overides the default debug menu with the following options:
#
# - edit switches
# - edit variables
# - edit self switches
# - change gold
# - add/remove items
# - add/remove weapons
# - add/remove armor
# - add/remove actors
# - edit actors
# - tranfer
# - activate common events
# - max all
#
#===============================================================================

#===============================================================================
# Window_Selectable
#===============================================================================

class Window_Selectable
  def resize_bitmap(size)
    self.contents = Bitmap.new(32, 32) if self.contents.nil?
    if @item_max != size
      self.contents.dispose
      self.contents = Bitmap.new(width - 32, (size == 0 ? 1 : size) * 32)
    else
      self.contents.clear
    end  
    @item_max = size
  end
end

#===============================================================================
# Window_DebugLeft
#===============================================================================

class Window_DebugLeft < Window_Selectable
  attr_accessor :phase
  attr_accessor :phase9
  attr_accessor :input_window
  attr_accessor :right_window
  attr_reader :actor
  def initialize
    super(0,64,192,416)
    @item_max = -1
    @phase = 0
    @phase9 = 0
    @index = 0
    draw_main
  end
  
  def dispose
    self.contents.dispose unless self.contents.nil?
    super
  end
  
  def move_repeat?
    #return true if a movement key is repeated
    return true if Input.repeat?(Input::DOWN)
    return true if Input.repeat?(Input::UP)
    return true if Input.repeat?(Input::L)
    return true if Input.repeat?(Input::R)
    return false
  end
  
  def draw_main
    resize_bitmap(12)
    ['Switches', 'Variables', 'Self Switches', 'Gold', 'Items', 
    'Weapons', 'Armor', 'Party', 'Actors', 'Transfer',
    'Common Events','Max All'].each_with_index do |text, i|
      self.contents.draw_text(4, i * 32, 160, 32, text)
    end
  end
  
  def draw_range(data)
    resize_bitmap((data.size - 1) / 10)
    (0..@item_max).each do |i|
      text = sprintf("[%04d-%04d]", i * 10 + 1, i * 10 + 10)
      self.contents.draw_text(4, i * 32, 160, 32, text)
    end
  end
  
  def draw_switches
    draw_range($data_system.switches)
  end
  
  def draw_variables
    draw_range($data_system.variables)
  end
  
  def draw_maps
    resize_bitmap($data_map_infos.size)
    $data_map_infos.keys.sort.each_with_index do |key, i|
      text = "#{key}: #{$data_map_infos[key].name}"
      self.contents.draw_text(4, i * 32, 160, 32, text)
    end      
  end
  
  def draw_gold
    resize_bitmap(2)
    self.contents.draw_text(4, 0, 160, 32, 'Change Gold')
    self.contents.draw_text(4, 32, 160, 32, 'Max Gold')
  end
  
  def draw_items
    draw_range($data_items)
  end
  
  def draw_weapons
    draw_range($data_weapons)
  end
  
  def draw_armor
    draw_range($data_armors)
  end
  
  def draw_party
    resize_bitmap($data_actors.size - 1)
    (1...$data_actors.size).each do |i|
      self.contents.draw_text(4, (i - 1) * 32, 160, 32, $data_actors[i].name)
    end
  end
  
  def draw_actors
    resize_bitmap($game_party.actors.size)
    $game_party.actors.each_with_index do |actor, i|
      self.contents.draw_text(4, i * 32, 160, 32, actor.name)
    end
  end
  
  def draw_parameters
    resize_bitmap(9)
    ['Level', 'HP', 'SP', 'STR', 'DEX', 'AGI', 'INT',
    'Class', 'Skills'].each_with_index do |text, i|
      self.contents.draw_text(4, i * 32, width - 32, 32, text)
    end
  end
  
  def draw_skills
    draw_range($data_skills)
  end
  
  def draw_ce
    draw_range($data_common_events)
  end
  
  def swap_to_right
    @right_window.index = 0
    self.active = false
    @right_window.active = true
  end
  
  def update
    super
    #update cancel
    if Input.trigger?(Input::B) && @phase9 == 0
      if @phase > 0
        #go back to the main phase
        @index = @phase - 1
        #dispose map content if transfer phase
        if @phase == 10
          @right_window.tilemap.dispose
          @right_window.map_port.dispose
          @right_window.player.bitmap.dispose
          @right_window.player.dispose
        end
        @right_window.contents.clear rescue nil
        @help_window.set_text2('')
        draw_main
        @phase = @right_window.phase = 0
      else #else go mack to the map scene
        $scene = Scene_Map.new
      end
      return
    end 
    #update phase
    case @phase
    when 0 then update_main
    when 1 then update_switches
    when 2 then update_variables
    when 3 then update_self_switches
    when 4 then update_gold
    when 5 then update_items
    when 6 then update_weapons
    when 7 then update_armors
    when 8 then update_party
    when 9 then update_actors
    when 10 then update_transfer
    when 11 then update_ce
    end
  end
  
  def update_main
    if Input.trigger?(Input::C)
      i = @index
      @phase = @right_window.phase = @index + 1
      @index = 0
      case i
      when 0 #switches
        draw_switches
        @right_window.draw_switches(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 1 #variables
        draw_variables
        @right_window.draw_variables(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 2 #self switches
        draw_maps
        @right_window.draw_self_switches(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 3 #gold
        draw_gold
        @right_window.draw_gold
      when 4 #items
        draw_items
        @right_window.draw_items(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 5 #weapons
        draw_weapons
        @right_window.draw_weapons(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 6 #armor
        draw_armor
        @right_window.draw_armors(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 7 #party
        draw_party
        @right_window.draw_party
        @help_window.set_text2('C = Add/Remove')
      when 8 #actors
        @actor = $game_party.actors[0]
        return if @actor.nil?
        draw_actors
        @right_window.draw_actor
        @help_window.set_text2('Choose an Actor')
      when 9 #transfer
        draw_maps
        @right_window.draw_map(@index)
        @help_window.set_text2('C = Accept Location')
      when 10 #common events
        draw_ce
        @right_window.draw_ces(@index)
        @help_window.set_text2('Q = Page Up, W = Page Down')
      when 11 #max all
        max_all
      end
      if @phase == 12
        @phase = @right_window.phase = 0
        @index = 11
      else
        update_help
      end
    end
  end
  
  def update_switches
    @right_window.draw_switches(@index) if move_repeat?
    swap_to_right if Input.trigger?(Input::C)
  end
  
  def update_variables
    @right_window.draw_variables(@index) if move_repeat?
    swap_to_right if Input.trigger?(Input::C)
  end
  
  def update_self_switches
    @right_window.draw_self_switches(@index) if move_repeat?
    if Input.trigger?(Input::C)
      swap_to_right unless @right_window.map.events.empty?
    end
  end
  
  def update_gold
    if Input.trigger?(Input::C)
      case @index
      when 0
        number = @input_window.get_number(7, $game_party.gold)
        $game_party.gain_gold(number - $game_party.gold)
      when 1 then $game_party.gain_gold(9999999 - $game_party.gold)
      end
      @right_window.draw_gold
    end
  end
  
  def update_items
    @right_window.draw_items(@index) if move_repeat?
    swap_to_right if Input.trigger?(Input::C)
  end
  
  def update_weapons
    @right_window.draw_weapons(@index) if move_repeat?
    swap_to_right if Input.trigger?(Input::C)
  end
  
  def update_armors
    @right_window.draw_armors(@index) if move_repeat?
    swap_to_right if Input.trigger?(Input::C)
  end
  
  def update_party
    @right_window.draw_party if move_repeat?
    if Input.trigger?(Input::C)
      if $game_party.actors.include?($game_actors[@index + 1])
        $game_party.remove_actor(@index + 1)
      else
        $game_party.add_actor(@index + 1)
      end
      @right_window.draw_party
    end
  end
  
  def update_actors
    case @phase9
    when 0 #choose actor
      if move_repeat?
        @actor = $game_party.actors[@index]
        @right_window.draw_actor 
      elsif Input.trigger?(Input::C)
        @help_window.set_text2('Edit Parameters')
        @actor = $game_party.actors[@index]
        @index = 0
        draw_parameters
        @right_window.draw_actor
        @phase9 = 1
      end
    when 1 #choose parameter
      if Input.trigger?(Input::C)
        case @index
        when 0 then @actor.level = @input_window.get_number(2, @actor.level)
        when 1
          @actor.maxhp = @input_window.get_number(4, @actor.maxhp)
          @actor.hp = @actor.maxhp
        when 2 
          @actor.maxsp = @input_window.get_number(4, @actor.maxsp)
          @actor.sp = @actor.maxsp
        when 3 then @actor.str = @input_window.get_number(3, @actor.str)
        when 4 then @actor.dex = @input_window.get_number(3, @actor.dex)
        when 5 then @actor.agi = @input_window.get_number(3, @actor.agi)
        when 6 then @actor.int = @input_window.get_number(3, @actor.int)
        when 7
          @right_window.draw_classes
          @help_window.set_text2('Choose Class')
          @phase9 = 2
          swap_to_right
        when 8 
          @index = 0
          @phase9 = 3
          draw_skills
          @right_window.draw_skills(@index)
          @help_window.set_text2('Q = Page Up, W = Page Down')
        end
        @right_window.draw_actor if @phase9 < 2
      elsif Input.trigger?(Input::B)
        @index = 0
        @phase9 = 0
        draw_actors
        @right_window.contents.clear
        @help_window.set_text2('Choose an Actor')
      end
    when 3 #choose skill
      @right_window.draw_skills(@index) if move_repeat?
      if Input.trigger?(Input::C)
        swap_to_right
      elsif Input.trigger?(Input::B)
        @index = 0
        @phase9 = 1
        draw_parameters
        @right_window.draw_actor
        @help_window.set_text2('Edit Parameters')
      end
    end
  end
  
  def update_transfer
    @right_window.draw_map(@index) if move_repeat?
    if Input.trigger?(Input::C)
      swap_to_right
      @right_window.cursor_rect.empty
    end
  end
  
  def update_ce
    @right_window.draw_ces(@index) if move_repeat?
    swap_to_right if Input.trigger?(Input::C)
  end
  
  def max_all
    $game_party.gain_gold(9999999)
    (1...$data_items.size).each do |item|
      $game_party.gain_item(item, 99)
    end
    (1...$data_weapons.size).each do |weapon|
      $game_party.gain_weapon(weapon, 99)
    end
    (1...$data_armors.size).each do |armor|
      $game_party.gain_armor(armor, 99)
    end
    $game_party.actors.each do |actor|
      data = $data_actors[actor.id]
      actor.level = data.final_level
      actor.maxhp = data.parameters[0, data.final_level]
      actor.hp = actor.maxhp
      actor.maxsp = data.parameters[1, data.final_level]
      actor.sp = actor.maxsp
      actor.str = data.parameters[2, data.final_level]
      actor.dex = data.parameters[3, data.final_level]
      actor.agi = data.parameters[4, data.final_level]
      actor.int = data.parameters[5, data.final_level]
      $data_classes[actor.class_id].learnings.each do |learning|
        actor.learn_skill(learning.skill_id)
      end
    end
    @help_window.set_text2('Maxed!')
  end
  
  def update_help
    if @phase == 0
      @help_window.set_text(get_phase_text(@index + 1))
    else 
      @help_window.set_text1(get_phase_text(@phase))
    end
  end
  
  def get_phase_text(id)
    case id
    when 1 then return 'Edit Switches' 
    when 2 then return 'Edit Variables'
    when 3 then return 'Edit Self Switches'
    when 4 then return 'Edit Gold'
    when 5 then return 'Edit Items'
    when 6 then return 'Edit Weapons'
    when 7 then return 'Edit Armor'
    when 8 then return 'Change Party Members'
    when 9 then return 'Edit Actor Stats'
    when 10 then return 'Transfer to a new map'
    when 11 then return 'Activate a common event'
    when 12 then return 'Max Gold, Items, Weapons, Armor, Actor Stats'
    end
  end
end

#===============================================================================
# Window_DebugRight
#===============================================================================

class Window_DebugRight < Window_Selectable
  attr_accessor :phase
  attr_accessor :input_window
  attr_accessor :left_window
  attr_reader :map
  attr_reader :tilemap
  attr_reader :map_port
  attr_reader :player
  def initialize
    super(192, 64, 448, 352)
    @item_max = -1
    @phase = 0
    @top_index = 0
    self.active = false
  end
  
  def dispose
    self.contents.dispose unless self.contents.nil?
    super
  end
  
  def draw_range(sym, i)
    resize_bitmap(10)
    @top_index = i * 10 + 1 if !i.nil?
    eval("(0..@item_max).each {|item| #{sym}(item)}")
  end
  
  def draw_switches(i = nil)
    draw_range(:draw_switch, i)
  end
  
  def draw_switch(i)
    text = "#{@top_index + i}: #{$data_system.switches[@top_index + i]}"
    bool = $game_switches[@top_index + i] ? '[ON]' : '[OFF]'
    self.contents.draw_text(4, i * 32, width - 40, 32, text)
    self.contents.draw_text(4, i * 32, width - 40, 32, bool, 2)
  end
  
  def draw_variables(i = nil)
    draw_range(:draw_variable, i)
  end
  
  def draw_variable(i)
    text = "#{@top_index + i}: #{$data_system.variables[@top_index + i]}"
    value = $game_variables[@top_index + i]
    self.contents.draw_text(4, i * 32, width - 40, 32, text)
    self.contents.draw_text(4, i * 32, width - 40, 32, value.to_s, 2)
  end
  
  def draw_self_switches(i = nil)
    @top_index = $data_map_infos.keys.sort[i] if !i.nil?
    @map = load_data(sprintf("Data/Map%03d.rxdata",@top_index))
    resize_bitmap(@map.events.size)
    (0...@item_max).each {|switch| draw_self_switch(switch)}
  end
  
  def draw_self_switch(i)
    event = @map.events[@map.events.keys.sort[i]]
    text = "#{event.id}: #{event.name}"
    self.contents.draw_text(4, i * 32, width - 40, 32, text)
  end
  
  def draw_gold
    resize_bitmap(1)
    text = "#{$data_system.words.gold}: #{$game_party.gold}"
    self.contents.draw_text(4, 0, width - 40, 32, text)
  end
  
  def draw_inventory(sym, i)
    data = eval("$data_#{sym}s[@top_index + i].name")
    text = "#{@top_index + i}: #{data}"
    value = eval("$game_party.#{sym}_number(@top_index + i)")
    self.contents.draw_text(4, i * 32, width - 40, 32, text)
    self.contents.draw_text(4, i * 32, width - 40, 32, value.to_s, 2) 
  end
  
  def draw_items(i = nil)
    draw_range(:draw_item, i)
  end
  
  def draw_item(i)
    draw_inventory(:item, i)
  end
  
  def draw_weapons(i = nil)
    draw_range(:draw_weapon, i)
  end
  
  def draw_weapon(i)
    draw_inventory(:weapon, i)
  end
  
  def draw_armors(i = nil)
    draw_range(:draw_armor, i)
  end
  
  def draw_armor(i)
    draw_inventory(:armor, i)
  end
  
  def draw_party
    resize_bitmap(10)
    $game_party.actors.each_with_index do |actor, i|
      draw_actor_graphic(actor, 40, i * 80 + 40)
      draw_actor_name(actor, 80, i * 80)
    end
  end
  
  def draw_actor
    actor = @left_window.actor
    resize_bitmap(9)
    class_name = $data_classes[actor.class_id].name
    ["Name: #{actor.name}","Class: #{class_name}","LVL: #{actor.level}",
    "HP: #{actor.maxhp}","SP: #{actor.maxsp}","STR: #{actor.str}",
    "DEX: #{actor.dex}","AGI: #{actor.agi}",
    "INT: #{actor.int}"].each_with_index do |text, i|
      self.contents.draw_text(4, i * 32, width - 40, 32, text)
    end
  end
  
  def draw_classes
    resize_bitmap($data_classes.size - 1)
    (1...$data_classes.size).each do |i|
      text = "#{i}: #{$data_classes[i].name}"
      self.contents.draw_text(4, (i - 1) * 32, width - 40, 32, text)
      if @left_window.actor.class_id == i
        self.contents.draw_text(4, (i-1) * 32, width - 40, 32, '[Selected]', 2)
      end
    end
  end
  
  def draw_skills(i = nil)
    resize_bitmap(10)
    @top_index = i * 10 + 1 if !i.nil?
    (0..@item_max).each {|skill| draw_skill(skill)}
  end
    
  def draw_skill(i)
    return if $data_skills[@top_index + i].nil?
    text = "#{@top_index + i}: #{$data_skills[@top_index + i].name}"
    self.contents.draw_text(4, i * 32, width - 40, 32, text)
    if @left_window.actor.skill_learn?(@top_index + i)
      self.contents.draw_text(4, i * 32, width - 40, 32, '[Known]', 2)
    end
  end
  
  def draw_map(i)
    if @map_port.nil?
      @map_port = Viewport.new(self.x + 16, self.y + 16,width - 32,height - 32)
      @map_port.z = 101
    end
    if @player.nil?
      @player = Sprite.new(@map_port)
      @player.bitmap = Bitmap.new(32, 32)
      @player.bitmap.fill_rect(0,0,32,32,Color.new(255,0,0))
      @player.z = 1000
    end
    @tilemap.dispose unless @tilemap.nil?
    @top_index = $data_map_infos.keys.sort[i] if !i.nil?
    @map = load_data(sprintf("Data/Map%03d.rxdata",@top_index))
    @tilemap = Tilemap.new(@map_port)
    tileset = $data_tilesets[@map.tileset_id]
    @tilemap.tileset = RPG::Cache.tileset(tileset.tileset_name)
    (0..6).each do |i|
      autotile_name = tileset.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = @map.data
    @tilemap.priorities = tileset.priorities
    @player.visible = (@top_index == $game_map.map_id)
    @player.x = $game_player.x * 32
    @player.y = $game_player.y * 32
  end
  
  def draw_ces(i = nil)
    resize_bitmap(10)
    @top_index = i * 10 + 1 if !i.nil?
    (0..@item_max).each {|ce| draw_ce(ce)}
  end
    
  def draw_ce(i)
    text = "#{@top_index + i}: #{$data_common_events[@top_index + i].name}"
    self.contents.draw_text(4, i * 32, width - 40, 32, text)
    if $game_temp.common_event_id == @top_index + i
      self.contents.draw_text(4, i * 32, width - 40, 32, '[Activated]', 2)
    end
  end
  
  def update
    @phase == 10 ? update_map : super
    if Input.trigger?(Input::B)
      self.cursor_rect.empty
      self.active = false
      @left_window.active = true
      if @left_window.phase9 == 2
        @left_window.phase9 = 1
        @help_window.set_text2('Edit Parameters') 
        @left_window.index = 7
        draw_actor
      end
      return
    end
    case @phase
    when 1 then update_switches
    when 2 then update_variables
    when 3 then update_self_switches
    when 4 then update_gold
    when 5 then update_items
    when 6 then update_weapons
    when 7 then update_armor
    when 9 then update_party
    when 11 then update_ce
    end
  end
  
  def update_switches
    if Input.trigger?(Input::C)
      id = @top_index + @index
      $game_switches[id] = !$game_switches[id]
      draw_switches
    end
  end
  
  def update_variables
    if Input.trigger?(Input::C)
      id = @top_index + @index
      $game_variables[id] = @input_window.get_number(9, $game_variables[id])
      draw_variables
    end
  end
  
  def update_self_switches
    if Input.trigger?(Input::C)
      map = $data_map_infos.keys.sort[@left_window.index]
      event = @map.events.keys.sort[@index]
      @input_window.get_self_switch(map, event)
    end
  end
  
  def update_items
    if Input.trigger?(Input::C)
      i = @top_index + @index
      number = @input_window.get_number(2, $game_party.item_number(i))
      $game_party.gain_item(i, number - $game_party.item_number(i))
      draw_items
    end
  end
  
  def update_weapons
    if Input.trigger?(Input::C)
      i = @top_index + @index
      number = @input_window.get_number(2, $game_party.weapon_number(i))
      $game_party.gain_weapon(i, number - $game_party.weapon_number(i))
      draw_weapons
    end
  end
  
  def update_armor
    if Input.trigger?(Input::C)
      i = @top_index + @index
      number = @input_window.get_number(2, $game_party.armor_number(i))
      $game_party.gain_armor(i, number - $game_party.armor_number(i))
      draw_armors
    end
  end
  
  def update_party
    case @left_window.phase9
    when 2 #class
      if Input.trigger?(Input::C)
        @left_window.actor.class_id = @index + 1
        draw_classes
      end
    when 3 #skill
      if Input.trigger?(Input::C)
        i = @top_index + @index
        if @left_window.actor.skill_learn?(i)
          @left_window.actor.forget_skill(i)
        else
          @left_window.actor.learn_skill(i)
        end
        draw_skills
      end
    end
  end
  
  def update_map
    #update input
    if Input.trigger?(Input::C)
      $game_map.setup($data_map_infos.keys.sort[@left_window.index])
      $game_player.moveto(@index % @map.width, @index / @map.width)
      @player.visible = true
      @player.x = $game_player.x * 32
      @player.y = $game_player.y * 32
    elsif Input.repeat?(Input::RIGHT)
      width = @map.width - 1
      @index % @map.width == width ? @index -= width : @index += 1
    elsif Input.repeat?(Input::LEFT)
      @index % @map.width == 0 ? @index += @map.width - 1 : @index -= 1
    elsif Input.repeat?(Input::DOWN)
      if @index / @map.width == @map.height - 1
        @index -= @map.width * (@map.height - 1)
      else
        @index += @map.width
      end
    elsif Input.repeat?(Input::UP)
      if @index / @map.width == 0
        @index += @map.width * (@map.height - 1)
      else
        @index -= @map.width
      end
    end
    #update scroll
    x = self.width / 2 - @index % @map.width * 32 - 16
    @tilemap.ox = [[-x, @map.width * 32 - self.width + 32].min, 0].max
    y = self.height / 2 - @index / @map.width * 32 - 16
    @tilemap.oy = [[-y, @map.height * 32 - self.height + 32].min, 0].max
    #update_player
    @player.ox = @tilemap.ox
    @player.oy = @tilemap.oy
    #update cursor
    cx = @index % @map.width * 32 - @tilemap.ox
    cy = @index / @map.width * 32 - @tilemap.oy
    self.cursor_rect.set(cx, cy, 32, 32)
  end
  
  def update_ce
    if Input.trigger?(Input::C)
      if $game_temp.common_event_id == @top_index + @index
        $game_temp.common_event_id = 0
      else
        $game_temp.common_event_id = @top_index + @index
      end
      draw_ces
    end
  end
  
  def update_help
  end
end

#===============================================================================
# Window_InputNumber
#===============================================================================

class Window_InputNumber
  attr_writer :index
end

#===============================================================================
# Window_DebugInput
#===============================================================================

class Window_DebugInput < Window_Base
  attr_accessor :help_window
  def initialize
    super(192, 416, 448, 64)
  end
  
  def get_number(digits, old_number)
    #create a number input window
    number_window = Window_InputNumber.new(digits)
    number_window.x, number_window.y = self.x, self.y
    number_window.number = old_number
    number_window.index = digits - 1
    number_window.update
    @help_window.set_text2('C = Accept, X = Cancel')
    #loop until input is complete
    loop do
      Graphics.update
      Input.update
      number_window.update
      break if Input.trigger?(Input::C) || Input.trigger?(Input::B)
    end
    @help_window.set_text2('Q = Page Up, W = Page Down')
    number = number_window.number
    number_window.dispose
    #return new number if C, old number if B
    return (Input.trigger?(Input::C) ? number : old_number)
  end
  
  def get_self_switch(map, event)
    #create a switches window
    switches_window = Window_DebugSwitch.new(map, event)
    switches_window.x, switches_window.y = self.x, self.y
    @help_window.set_text2('C = Change, X = Cancel')
    #loop until switch edit is complete
    loop do 
      Graphics.update
      Input.update
      switches_window.update
      break if Input.trigger?(Input::B)
    end
    @help_window.set_text2('Q = Page Up, W = Page Down')
    switches_window.dispose
  end
end

#===============================================================================
# Window_DebugSwitch
#===============================================================================

class Window_DebugSwitch < Window_Base
  CHARS = ['A','B','C','D']
  def initialize(map, event)
    super(0, 0, 448, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    @map = map
    @event = event
    @index = 0
    self.cursor_rect.set(0, 0, 104, 32)
    refresh
  end

  def dispose
    self.contents.dispose
    super
  end
  
  def refresh
    self.contents.clear
    CHARS.each_with_index do |char, i|
      switch = $game_self_switches[[@map, @event, char]] ? '[ON]' : '[OFF]'
      self.contents.draw_text(4 + i * 104, 0, 100, 32, "#{char} = #{switch}")
    end
  end
  
  def update
    super
    #move left
    if Input.repeat?(Input::LEFT)
      @index -= 1
      @index = 3 if @index == -1
    #move right
    elsif Input.repeat?(Input::RIGHT)
      @index += 1
      @index = 0 if @index == 4
    #change self switch
    elsif Input.trigger?(Input::C)
      key = [@map, @event, CHARS[@index]]
      $game_self_switches[key] = !$game_self_switches[key]
      refresh
    end
    #update cursor rect
    self.cursor_rect.set(@index * 104, 0, 104, 32)
  end
end

#===============================================================================
# Window_DebugHelp
#===============================================================================

class Window_DebugHelp < Window_Help
  def initialize
    super
    @text2 = ''
  end
  
  def set_text1(text)
    #sets the left text
    if text != @text
      self.contents.clear
      self.contents.draw_text(4, 0, width - 36, 32, text, 0)
      self.contents.draw_text(4, 0, width - 36, 32, @text2, 2)
      @text = text
    end
  end
  
  def set_text2(text2)
    #sets the right text
    if text2 != @text2
      self.contents.clear
      self.contents.draw_text(4, 0, width - 36, 32, @text, 0)
      self.contents.draw_text(4, 0, width - 36, 32, text2, 2)
      @text2 = text2
    end
  end
  
  def set_texts(text, text2)
    #sets both left and right text
    if text != @text && text2 != @text2
      self.contents.clear
      self.contents.draw_text(4, 0, width - 36, 32, text, 0)
      self.contents.draw_text(4, 0, width - 36, 32, text2, 2)
      @text = text
      @text2 = text2
    end
  end
end

#===============================================================================
# Scene_Debug
#===============================================================================

class Scene_Debug
  def main
    #initialize windows
    @left = Window_DebugLeft.new
    @right = Window_DebugRight.new
    @help = Window_DebugHelp.new
    @input = Window_DebugInput.new
    #link windows
    @left.help_window = @help
    @left.input_window = @input
    @left.right_window = @right
    @right.help_window = @help
    @right.input_window = @input
    @right.left_window = @left
    @input.help_window = @help
    #main loop
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    #refresh globals
    $game_map.refresh
    $game_player.refresh
    #dispose all windows
    [@left,@right,@help,@input].each {|window| window.dispose}
  end
  
  def update
    #update the active window
    if @left.active
      @left.update
    elsif @right.active
      @right.update
    end
  end
end

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title
  alias max_debug_main_later main
  def main
    $data_map_infos = load_data('Data/MapInfos.rxdata') if $data_map_infos.nil?
    max_debug_main_later
  end
end