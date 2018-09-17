#===============================================================================
# Filename/Database Swap
#===============================================================================
# Author: Maximusmaxy
# Version 1.0: 28/12/11
#===============================================================================
#
# Note: After a Swap is complete you will need to close your RMXP editor
#       WITHOUT SAVING to update the maps/database. A warning will be shown
#       to remind you, which can be disabled in the configuration.
# Note: The filenames of the RTP cannot be changed.
#
# Introduction:
# Ever wanted to change a filename, or simply move a database name without
# having to go through the  grueling task of going through every event and 
# changing it's information. This script allows you to change filenames and
# adjust database positions with a simple script call. You can also adjust 
# switch/variable/map ID's.
#
# Instructions:
# To change a filename or swap an ID position, setup your type, previous and 
# new filenames or ID's in the configuration, then set the enable switch to 
# true. Remember to set the enable switch to false after you are complete.
#        
# Type List:
# ----Graphics----
# 1 = Animations
# 2 = Autotiles
# 3 = Battlebacks
# 4 = Battlers
# 5 = Characters
# 6 = Fogs
# 7 = Gameovers
# 8 = Icons
# 9 = Panoramas
# 10 = Pictures
# 11 = Tilesets
# 12 = Titles
# 13 = Transitions
# 14 = Windowskins
# ----Audio----
# 15 = BGM
# 16 = BGS
# 17 = ME
# 18 = SE
# ----Database----
# 19 = Actors
# 20 = Classes
# 21 = Skills
# 22 = Items
# 23 = Weapons
# 24 = Armors
# 25 = Enemies
# 26 = Troops
# 27 = States
# 28 = Animations
# 29 = Tilesets
# 30 = Common Events
# 31 = Element Names
# ----Other----
# 32 = Switch
# 33 = Variable
# 34 = Map
#
#===============================================================================

module FDS

#===============================================================================
# Configuration
#===============================================================================
  #Use the filename database swap
  ENABLE = false
  #Type of swap (see the type list)
  TYPE = 32
  #previous file name/id
  PREVIOUS = 365
  #new file name/id
  NEW = 113
  #If false only event and database information is changed and there's no swap. 
  #If true the filenames are changed aswell and information is swapped.
  CHANGE = true
  
  #Overwrite existing files with the new filename
  OVERWRITE_FILENAME = true
  #Show the close RMXP message on completion
  MESSAGE = true
#===============================================================================
# End Configuration
#===============================================================================

  #-----------------------------------------------------------------------------
  # Swap
  #-----------------------------------------------------------------------------
  def self.swap(type, prev, new, change = true)
    if prev == new
      p "Error with swap, '#{@prev}' is equal to '#{@new}'"
      return
    end
    if type <= 18
      prev,new = prev.to_s, new,to_s
      if prev == ''
        p "Error with swap, '#{prev}' is an invalid Filename"
        return
      end
      if new == ''
        p "Error with swap, '#{new}' is an invalid Filename"
        return
      end
    else
      prev, new = prev.to_i, new.to_i
      if prev < 1
        p "Error with swap, '#{prev}' is an invalid ID"
        return
      end
      if new < 1
        p "Error with swap, '#{new}' is an invalid ID"
        return
      end
    end
    unless type.between?(1,34)
      p 'Error with swap, type must be between 1 and 34' 
      return
    end
    @type = type
    @prev = prev
    @new = new
    @change = change
    @error = false
    @edit = false
    @edits = []
    @rate = 0
    self.scene_initialize
    if @change 
      if @type <= 18 
        self.change_file
      else
        self.change_data
      end
      if @error
        self.scene_dispose
        return 
      end
    end
    self.change_database
    self.change_maps_events
    self.change_troops
    self.change_common_events
    @edits.each do |edit|
      save_data(self.data(true,edit),"Data/#{self.string(false,edit)}.rxdata")
    end
    self.scene_update('Complete')
    if MESSAGE
      p 'To complete the update close the RMXP editor without saving',
      'Remember to set the ENABLE switch to false in the script configuration'
    end
    self.scene_dispose
  end
  #-----------------------------------------------------------------------------
  # Change File
  #-----------------------------------------------------------------------------
  def self.change_file
    self.scene_update('Changing Filename')
    prev = "#{self.folder}/#{self.string}/#{@prev}"
    new = "#{self.folder}/#{self.string}/#{@new}"
    if self.filetest(prev)
      prev_ext = @ext
      if self.filetest(new)
        if !OVERWRITE_FILENAME
          p "Error with swap, '#{new}' already exists.",
          'Either Enable the Overwrite Filename function or delete the file.'
          @error = true
          return
        end
      end
      File.rename("#{prev}#{prev_ext}","#{new}#{prev_ext}")
    else
      p "Error with swap, '#{prev}' could not be found."
      @error = true
    end
  end
  #-----------------------------------------------------------------------------
  # Change Data
  #-----------------------------------------------------------------------------
  def self.change_data
    self.scene_update('Swapping Database ID')
    if self.data[@prev].nil?
      p "Error with swap, Previous ID '#{@prev}' could not be found."
      @error = true
      return
    end
    if @type == 34
      prev = sprintf("Data/Map%03d.rxdata", @prev)
      new = sprintf("Data/Map%03d.rxdata", @new)
      if FileTest.exist?(new)
        File.rename(prev,"temp.rxdata")
        File.rename(new,prev)
        File.rename("temp.rxdata",new)
      else
        File.rename(prev,new)
      end
    elsif @new > self.data.size - 1
      (self.data.size..@new).each do |i|
        self.data[i] = self.object
        self.data[i].id = i if @type < 31
      end
    end
    self.data[@new], self.data[@prev] = self.data[@prev], self.data[@new]
    self.data.delete(@prev) if @type == 34 && self.data[@prev].nil?
    self.data[@prev].id, self.data[@new].id = @new, @prev if @type < 31
    @edits |= [@type]
  end
  #-----------------------------------------------------------------------------
  # Change Maps/Events
  #-----------------------------------------------------------------------------
  def self.change_maps_events
    $data_map_infos.keys.sort.each do |key|
      self.scene_update("Updating Map #{key}: #{$data_map_infos[key].name}")
      @edit = false
      map = load_data(sprintf("Data/Map%03d.rxdata", key))
      case @type
      when 15
        map.bgm = self.audio(map.bgm) if map.autoplay_bgm
      when 16
        map.bgs = self.audio(map.bgs) if map.autoplay_bgs
      when 26
        map.encounter_list.each do |id|
          id = self.change(id)
        end
      when 29
        map.tileset_id = self.change(map.tileset_id)
      end
      map.events.each_value do |event|
        event.pages.each do |page|
          if page.move_type == 3
            page.move_route.list.each do |move|
              move = self.move(move)
            end
          end
          case @type
          when 5
            page.graphic.character_name = self.change(
            page.graphic.character_name)
          when 32
            if page.condition.switch1_valid
              page.condition.switch1_id = self.change(
              page.condition.switch1_id)  
            end
            if page.condition.switch2_valid
              page.condition.switch2_id = self.change(
              page.condition.switch2_id)
            end
          when 33
            if page.condition.variable_valid
              page.condition.variable_id = self.change(
              page.condition.variable_id)
            end
          end
          page.list.each do |command|
            command = self.command(command)
          end
        end
      end
      save_data(map, sprintf("Data/Map%03d.rxdata", key)) if @edit
    end
  end
  #-----------------------------------------------------------------------------
  # Change Common Events
  #-----------------------------------------------------------------------------
  def self.change_common_events
    self.scene_update("Updating Common Events")
    @edit = false
    $data_common_events.each do |ce|
      next if ce.nil?
      ce.list.each do |command|
        command = self.command(command)
      end
    end
    @edits |= [30] if @edit
  end
  #-----------------------------------------------------------------------------
  # Change Troops
  #----------------------------------------------------------------------------- 
  def self.change_troops
    self.scene_update("Updating Troops")
    @edit = false
    $data_troops.each do |troop|
      next if troop.nil?
      troop.pages.each do |page|
        page.list.each do |command|
          command = self.command(command)
        end
      end
    end
    @edits |= [26] if @edit
  end
  #-----------------------------------------------------------------------------
  # Command
  #-----------------------------------------------------------------------------
  def self.command(command)
    command_array(command).each do |c|
      if command.code == c[0]
        case command.parameters[c[1]]
        when Numeric
          command.parameters[c[1]] = self.change(command.parameters[c[1]])
        when RPG::AudioFile
          command.parameters[c[1]] = self.audio(command.parameters[c[1]])
        when RPG::MoveRoute
          command.parameters[c[1]].list.each do |move|
            move = self.move(move)
          end
        when RPG::MoveCommand
          command.parameters[c[1]] = self.move(command.parameters[c[1]])
        end
      end
    end
    return command
  end
  #-----------------------------------------------------------------------------
  # Move
  #-----------------------------------------------------------------------------
  def self.move(command)
    case @type
    when 5 
      if command.code == 41
        command.parameters[0] = self.change(command.parameters[0])
      end
    when 18
      if command.code == 44
        command.parameters[0] = self.audio(command.parameters[0])
      end
    when 32
      if command.code == 27 || command.code == 28
        command.parameters[0] = self.change(command.parameters[0])
      end
    end
    return command
  end
  #-----------------------------------------------------------------------------
  # Command Array
  #-----------------------------------------------------------------------------
  def self.command_array(command)
    check = []
    return check if [205,223,224,234].include?(command.code)
    case @type
    when 3 then check.push [204,1] if command.parameters[0] == 2
    when 4 then check.push [322,3]
    when 5 then check.push [322,1], [209,1]
    when 6 then check.push [204,1] if command.parameters[0] == 1
    when 9 then check.push [204,1] if command.parameters[0] == 0
    when 10 then check.push [231,1]
    when 13 then check.push [222,0]
    when 14 then check.push [131,0]
    when 15 then check.push [241,0], [132,0]
    when 16 then check.push [245,0]
    when 17 then check.push [249,0], [133,0]
    when 18 then check.push [250,0], [209,1]
    when 19
      check.push [111,1] if command.parameters[0] == 4
      check.push [122,4] if command.parameters[3] == 4
      check.push [129,0], [303,0]
      (311..322).each{|i| check.push [i,0]} if command.parameters[0] != 0
    when 20 then check.push [321,1]
    when 21
      if command.parameters[0] == 4 && command.parameters[2] == 2
        check.push [111,3]
      end
      check.push [318,2]
      check.push [339,3] if command.parameters[2] == 1
    when 22
      check.push [111,1] if command.parameters[0] == 8
      check.push [122,4] if command.parameters[3] == 3
      check.push [126,0]
      check.push [302,1] if command.parameters[0] == 0
      check.push [605,1] if command.parameters[0] == 0
    when 23
      if command.parameters[0] == 4 && command.parameters[2] == 3
        check.push [111,3]
      end
      check.push [111,1] if command.parameters[0] == 9
      check.push [127,0]
    when 24
      if command.parameters[0] == 4 && command.parameters[2] == 4
        check.push [111,3]
      end
      check.push [111,1] if command.parameters[0] == 10
      check.push [128,0]
    when 25 then check.push [336,1]
    when 26 then check.push [301,0]
    when 27
      if command.parameters[0] == 4 && command.parameters[2] == 5
        check.push [111,3]
      end
      check.push [313,2], [333,2]
    when 28 then check.push [207,1], [337,2]
    when 30 then check.push [117,0]
    when 32
      check.push [111,1] if command.parameters[0] == 0
      check.push [121,0], [121,1], [209,1]
    when 33
      if command.parameters[0] == 1
        check.push [111,1], [201,1], [201,2], [201,3]
        check.push [111,3] if command.parameters[2] != 0
      end
      if command.parameters[1] == 1
        check.push [202,2], [202,3]
      end
      if command.parameters[2] == 1
        check.push [311,3], [312,3], [315,3], [316,3], [331,3], [332,3]
      end
      if command.parameters[3] == 1
        check.push [122,4], [231,4], [231,5], [232,4], [232,5], [317,3]
      end
      check.push [122,0], [122,1]
    when 34 then check.push [201,1] if command.parameters[0] == 0
    end
    return check
  end
  #-----------------------------------------------------------------------------
  # Change Database
  #-----------------------------------------------------------------------------
  def self.change_database
    self.scene_update("Updating Databse")
    case @type
    when 1 #animations
      $data_animations.each do |animation|
        next if animation.nil?
        animation.animation_name = self.change(animation.animation_name,28)
      end
    when 2 #autotiles
      $data_tilesets.each do |tileset|
        next if tileset.nil?
        tileset.autotile_names.each do |autotile|
          autotile = self.change(autotile,29)
        end
      end
    when 3 #battlebacks
      $data_tilesets.each do |tileset|
        next if tileset.nil?
        tileset.battleback_name = self.change(tileset.battleback_name,29)
      end
      $data_system.battleback_name = self.change(
      $data_system.battleback_name,31)
    when 4 #battlers
      $data_actors.each do |actor|
        next if actor.nil?
        actor.battler_name = self.change(actor.battler_name,19)
      end
      $data_enemies.each do |enemy|
        next if enemy.nil?
        enemy.battler_name = self.change(enemy.battler_name,25)
      end
      $data_system.battler_name = self.change($data_system.battler_name,31)
    when 5 #characters
      $data_actors.each do |actor|
        next if actor.nil?
        actor.character_name = self.change(actor.character_name,19)
      end
    when 6 #fogs
      $data_tilesets.each do |tileset|
        next if tileset.nil?
        tileset.fog_name = self.change(tileset.fog_name,29)
      end
    when 7 #gameovers
      $data_system.gameover_name = self.change(
      $data_system.gameover_name,31)
    when 8 #icons
      [$data_skills,$data_items,$data_weapons,
       $data_armors].each_with_index do |data,i|
        data.each do |d|
          next if d.nil?
          d.icon_name = self.change(icon_name,21 + i)
        end
      end
    when 9 #panoramas
      $data_tilesets.each do |tileset|
        next if tileset.nil?
        tileset.panorama_name = self.change(tileset.panorama_name,29)
      end
    when 12 #titles
      $data_system.title_name = self.change(
      $data_system.title_name,31)
    when 13 #transitions
      $data_system.battle_transition = self.change(
      $data_system.battle_transition,31)
    when 14 #windowskins
      $data_system.windowskin_name = self.change(
      $data_system.windowskin_name,31)
    when 15 #bgm
      $data_system.title_bgm = self.audio($data_system.title_bgm,31)
      $data_system.battle_bgm = self.audio($data_system.battle_bgm,31)
    when 17 #me
      $data_system.battle_end_me = self.audio($data_system.battle_end_me,31)
      $data_system.gameover_me = self.audio($data_system.gameover_me,31)
    when 18 #se
      $data_system.cursor_se = self.audio($data_system.cursor_se,31)
      $data_system.decision_se = self.audio($data_system.decision_se,31)
      $data_system.cancel_se = self.audio($data_system.cancel_se,31)
      $data_system.buzzer_se = self.audio($data_system.buzzer_se,31)
      $data_system.equip_se = self.audio($data_system.equip_se,31)
      $data_system.shop_se = self.audio($data_system.shop_se,31)
      $data_system.save_se = self.audio($data_system.save_se,31)
      $data_system.load_se = self.audio($data_system.load_se,31)
      $data_system.battle_start_se = self.audio($data_system.battle_start_se,31)
      $data_system.escape_se = self.audio($data_system.escape_se,31)
      $data_system.actor_collapse_se = self.audio(
      $data_system.actor_collapse_se,31)
      $data_system.enemy_collapse_se = self.audio(
      $data_system.enemy_collapse_se,31)
      [$data_skills,$data_items].each_with_index do |data,i|
        data.each do |d|
          next if d.nil?
          d.menu_se = self.audio(d.menu_se,21 + i)
        end
      end
      $data_animations.each do |animation|
        next if animation.nil?
        animation.timings.each do |timing|
          timing.se = self.audio(timing.se,28)
        end
      end
    when 19 #actors
      $data_system.party_members.each do |id|
        id = self.change(id,31)
      end
      $data_troops.each do |troop|
        next if troop.nil?
        troop.pages.each do |page|
          if page.condition.actor_valid
            page.condition.actor_id = self.change(
            page.condition.actor_id,26)
          end
        end
      end
      $data_system.test_battlers.each do |battler|
        battler.actor_id = self.change(battler.actor_id,31)
      end
    when 20 #classes
      $data_actors.each do |actor|
        next if actor.nil?
        actor.class_id = self.change(actor.class_id,31)
      end
    when 21 #skills
      $data.classes.each do |klass|
        next if klass.nil?
        klass.learnings.each do |learning|
          learning.skill_id = self.change(learning.skill_id,20)
        end
      end
      $data_enemies.each do |enemy|
        next if enemy.nil?
        enemy.actions.each do |action|
          if action.kind == 1
            action.skill_id = self.change(action.skill_id,25)
          end
        end
      end
    when 22 #items
      $data_enemies.each do |enemy|
        next if enemy.nil?
        if enemy.item_id != 0
          enemy.item_id - self.change(enemy.item_id,25)
        end
      end
    when 23 #weapons
      $data_actors.each do |actor|
        next if actor.nil?
        actor.weapon_id = self.change(actor.weapon_id,19)
      end
      $data_classes.each do |klass|
        next if klass.nil?
        klass.weapon_set = self.include(klass.weapon_set,20)
      end
      $data_enemies.each do |enemy|
        next if enemy.nil?
        if enemy.weapon_id != 0
          enemy.weapon_id = self.change(enemy.weapon_id,25)
        end
      end
    when 24 #armors
      $data_actors.each do |actor|
        next if actor.nil?
        actor.armor1_id = self.change(actor.armor1_id,19)
        actor.armor2_id = self.change(actor.armor2_id,19)
        actor.armor3_id = self.change(actor.armor3_id,19)
        actor.armor4_id = self.change(actor.armor4_id,19)
      end
      $data_classes.each do |klass|
        next if klass.nil?
        klass.armor_set = self.include(klass.armor_set,20)
      end
      $data_enemies.each do |enemy|
        next if enemy.nil?
        if enemy.armor_id != 0
          enemy.armor_id = self.change(enemy.armor_id,25)
        end
      end
    when 25 #enemies
      $data_troops.each do |troop|
        next if troop.nil?
        troop.members.each do |member|
          member.enemy_id = self.change(member.enemy_id,26)
        end
      end
    when 26 #troops
      $data_system.test_troop_id = self.change(
      $data_system.test_troop_id,31)
    when 27 #states
      [$data_classes,$data_enemies].each_with_index do |data, i|
        edit = (i == 0 ? 20 : 25)
        data.each do |d|
          next if d.nil?
          d.state_ranks = self.table(d.state_ranks,edit)
        end
      end
      [$data_skills,$data_items,$data_weapons,
       $data_states].each_with_index do |data,i|
        edit = (i < 3 ? 21 + i : 27)
        data.each do |d|
          next if d.nil?
          d.plus_state_set = self.include(d.plus_state_set,edit)
          d.minus_state_set = self.include(d.minus_state_set,edit)
        end
      end
      $data_armors.each do |armor|
        next if armor.nil?
        armor.guard_state_set = self.include(armor.guard_state_set,24)
        armor.auto_state_id = self.change(armor.auto_state_id,24)
      end
    when 28 #animations
      [$data_skills,$data_items,$data_weapons,
       $data_enemies].each_with_index do |data,i|
        edit = (i < 3 ? 21 + i : 25)
        data.each do |d|
          next if d.nil?
          d.animation1_id = self.change(d.animation1_id,edit)
          d.animation2_id = self.change(d.animation2_id,edit)
        end
      end
      $data_states.each do |state|
        next if state.nil?
        state.animation_id = self.change(state.animation_id,27)
      end
    when 30 #common events
      [$data_skills,$data_items].each_with_index do |data,i|
        data.each do |d|
          next if d.nil?
          d.common_event_id = self.change(d.common_event_id,21 + i)
        end
      end
    when 31 #elements
      [$data_classes,$data_enemies].each_with_index do |data, i|
        edit = (i == 0 ? 20 : 25)
        data.each do |d|
          next if d.nil?
          d.element_ranks = self.table(d.element_ranks,edit)
        end
      end
      [$data_skills,$data_items,$data_weapons].each_with_index do |data,i|
        data.each do |d|
          next if d.nil?
          d.element_set = self.include(d.element_set,21  + i)
        end
      end
      [$data_armors,$data_states].each_with_index do |data,i|
        edit = (i == 0 ?  24 : 27)
        data.each do |d|
          next if d.nil?
          d.guard_element_set = self.include(d.guard_element_set,edit)
        end
      end
    when 32 #switches
      $data_common_events.each do |ce|
        next if ce.nil?
        if ce.trigger != 0
          ce.switch_id = self.change(ce.switch_id,30)
        end
      end
      $data_enemies.each do |enemy|
        next if enemy.nil?
        enemy.actions.each do |action|
          action.condition_switch_id = self.change(
          action.condition_switch_id,25)
        end
      end
      $data_troops.each do |troop|
        next if troop.nil?
        troop.pages.each do |page|
          if page.condition.switch_valid
            page.condition.switch_id = self.change(
            page.condition.switch_id,26)
          end
        end
      end
    when 34 #map infos
      $data_system.start_map_id = self.change($data_system.start_map_id,31)
      $data_system.edit_map_id = self.change($data_system.edit_map_id,31)
    end
  end
  #-----------------------------------------------------------------------------
  # Change
  #-----------------------------------------------------------------------------
  def self.change(data, id = 0)
    if data == @prev
      data = @new
      id == 0 ? @edit = true : @edits |= [id]
    elsif @change && data == @new
      data = @prev
      id == 0 ? @edit = true : @edits |= [id]
    end
    return data
  end
  #-----------------------------------------------------------------------------
  # Audio
  #-----------------------------------------------------------------------------
  def self.audio(audio, id = 0)
    audio.name = self.change(audio.name, id)
    return audio
  end
  #-----------------------------------------------------------------------------
  # Table
  #-----------------------------------------------------------------------------
  def self.table(table, id = 0)
    if @change
      if table[@prev] != table[@new]
        temp = table[@prev]
        table[@prev] = table[@new]
        table[@new] = temp
        id == 0 ? @edit = true : @edits |= [id]
      end
    else
      unless table[@new] == 3 && table[@prev] == 3
        table[@new] = table[@prev]
        table[@prev] = 3
        id == 0 ? @edit = true : @edits |= [id]
      end
    end
    return table
  end
  #-----------------------------------------------------------------------------
  # Include
  #-----------------------------------------------------------------------------
  def self.include(array, id = 0)
    if array.include?(@prev)
      if (@change && !array.include?(@new)) || !@change
        array.delete(@prev) 
        id == 0 ? @edit = true : @edits |= [id]
      end
      if !array.include?(@new)
        array.push(@new)
        id == 0 ? @edit = true : @edits |= [id]
      end      
    elsif @change && array.include?(@new)
      array.delete(@new)
      array.push(@prev)
      id == 0 ? @edit = true : @edits |= [id]
    end
    return array
  end
  #-----------------------------------------------------------------------------
  # Data
  #-----------------------------------------------------------------------------
  def self.data(data = false,type = 0)
    type = @type if type == 0
    case type
    when 19 then return $data_actors
    when 20 then return $data_classes
    when 21 then return $data_skills
    when 22 then return $data_items
    when 23 then return $data_weapons
    when 24 then return $data_armors
    when 25 then return $data_enemies
    when 26 then return $data_troops
    when 27 then return $data_states
    when 28 then return $data_animations
    when 29 then return $data_tilesets
    when 30 then return $data_common_events
    when 31 then return data ? $data_system : $data_system.elements
    when 32 then return data ? $data_system : $data_system.switches
    when 33 then return data ? $data_system : $data_system.variables
    when 34 then return $data_map_infos
    end
  end
  #-----------------------------------------------------------------------------
  # Object
  #-----------------------------------------------------------------------------
  def self.object
    case @type
    when 19 then return RPG::Actor.new
    when 20 then return RPG::Class.new
    when 21 then return RPG::Skill.new
    when 22 then return RPG::Item.new
    when 23 then return RPG::Weapon.new
    when 24 then return RPG::Armor.new
    when 25 then return RPG::Enemy.new
    when 26 then return RPG::Troop.new
    when 27 then return RPG::State.new
    when 28 then return RPG::Animation.new
    when 29 then return RPG::Tileset.new
    when 30 then return RPG::CommonEvent.new
    when 31,32,33 then return ''
    end
  end
  #-----------------------------------------------------------------------------
  # Folder
  #-----------------------------------------------------------------------------
  def self.folder
    return (@type <= 15 ? 'Graphics' : 'Audio')
  end
  #-----------------------------------------------------------------------------
  # String
  #-----------------------------------------------------------------------------
  def self.string(data = true, type = 0)
    type = @type if type == 0
    case type
    when 1 then return 'Animations'
    when 2 then return 'Autotiles'
    when 3 then return 'Battlebacks'
    when 4 then return 'Battlers'
    when 5 then return 'Characters'
    when 6 then return 'Fogs'
    when 7 then return 'Gameovers'
    when 8 then return 'Icons'
    when 9 then return 'Panoramas'
    when 10 then return 'Pictures'
    when 11 then return 'Tilesets'
    when 12 then return 'Titles'
    when 13 then return 'Transitions'
    when 14 then return 'Windowskins'
    when 15 then return 'BGM'
    when 16 then return 'BGS'
    when 17 then return 'ME'
    when 18 then return 'SE'
    when 19 then return 'Actors'
    when 20 then return 'Classes'
    when 21 then return 'Skills'
    when 22 then return 'Items'
    when 23 then return 'Weapons'
    when 24 then return 'Armors'
    when 25 then return 'Enemies'
    when 26 then return 'Troops'
    when 27 then return 'States'
    when 28 then return 'Animations'
    when 29 then return 'Tilesets'
    when 30 then return 'CommonEvents'
    when 31 then return (data ? 'ElementNames' : 'System') 
    when 32 then return (data ? 'Switches' : 'System')
    when 33 then return (data ? 'Variables' : 'System')
    when 34 then return 'MapInfos'
    end
  end
  #-----------------------------------------------------------------------------
  # Filetest
  #-----------------------------------------------------------------------------
  def self.filetest(file)
    @ext = ''
    return true if FileTest.exist?(file)
    extensions = (@type <= 14 ? GRAPHIC : AUDIO)
    extensions.each do |ext|
      if FileTest.exist?("#{file}.#{ext}")
        @ext = ".#{ext}"
        return true
      end
    end
    return false
  end
  
  GRAPHIC = ['png','jpg','bmp']
  AUDIO = ['ogg','aac','wma','mp3','wav','it',
           'xm','mod','s3m','mid','midi','flac']
  #-----------------------------------------------------------------------------
  # Initialize
  #-----------------------------------------------------------------------------
  def self.scene_initialize
    @mask = Sprite.new
    @mask.z = 100000
    @mask.bitmap = Bitmap.new(640,480)
    @mask.bitmap.fill_rect(0,0,640,480,Color.new(0,0,0,100))
    @title = Sprite.new
    @title.y, @title.z = 100, 100000
    @title.bitmap = Bitmap.new(640,24)
    text = "Swapping #{self.string} '#{@prev}' to '#{@new}'"
    @title.bitmap.draw_text(0,0,640,24,text,1)
    @message = Sprite.new
    @message.y, @message.z = 150, 100000
    @message.bitmap = Bitmap.new(640,24)
    @bar = Sprite.new
    @bar.x, @bar.y, @bar.z = 192, 300, 100000
    @bar.bitmap = Bitmap.new(256,64)
    @bar.bitmap.fill_rect(0,0,256,64,Color.new(0,0,0,255))
    @bar.bitmap.fill_rect(8,8,240,48,Color.new(255,2555,255,255))
  end
  #-----------------------------------------------------------------------------
  # Update
  #-----------------------------------------------------------------------------
  def self.scene_update(text)
    @message.bitmap.clear
    @message.bitmap.draw_text(0,0,640,24,text,1)
    @rate += 1
    rate = @rate.to_f / ($data_map_infos.size + (@change ? 5 : 4)).to_f
    @bar.bitmap.fill_rect(8, 8, 240 * rate, 48, Color.new(0,0,255,255))
    Graphics.update
  end
  #-----------------------------------------------------------------------------
  # Dispose
  #-----------------------------------------------------------------------------
  def self.scene_dispose
    [@mask,@title,@message,@bar].each do |sprite|
      sprite.bitmap.dispose
      sprite.dispose
    end
  end
  
  #Activate if enabled
  if ENABLE
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
    $data_map_infos     = load_data('Data\MapInfos.rxdata')
    self.swap(TYPE,PREVIOUS,NEW,CHANGE)
    exit
  end
end