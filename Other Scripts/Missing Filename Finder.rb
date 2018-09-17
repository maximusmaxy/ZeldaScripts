#===============================================================================
# Missing Filename Finder
#===============================================================================
# Author: Maximusmaxy
# Version 1.0: 29/12/11
#===============================================================================
#
# Introduction:
# Finds references to missing files and saves them in a text document.
#
# Instructions:
# Use the script call:
# MFF.find
#
#===============================================================================

module MFF
  
#===============================================================================
# Configuration
#===============================================================================
  #Set to true to activate the filename finder
  ENABLE = false
#===============================================================================
# End Configuration
#===============================================================================
  
  #-----------------------------------------------------------------------------
  # Find
  #-----------------------------------------------------------------------------
  def self.find
    @text = []
    @line = ''
    @title = []
    @sub = []
    @cache = {}
    @edit1 = @edit2 = @edit3 = false
    @time = Time.now
    self.scene_initialize
    self.test_database
    self.test_maps
    self.test_common_events
    self.test_troops
    self.scene_update('Complete')
    if @edit3
      file = File.open("Missing Filename Log.txt",'w')
      @text.each {|line| file.write("#{line}\n")}
      file.close
      p "Missing Filenames Found, Missing Filename Log created"
    else
      p "No Missing Filenames Found"
    end
    self.scene_dispose
  end
  #-----------------------------------------------------------------------------
  # Test Database
  #-----------------------------------------------------------------------------
  def self.test_database
    self.scene_update('Testing Database')
    self.title('Database')
    @title.shift
    self.sub('Actors')
    $data_actors.each do |actor|
      next if actor.nil?
      @line = "Actor #{actor.id}: #{actor.name}"
      self.test(actor.character_name,5)
      self.test(actor.battler_name,4)
    end
    self.sub('Skills')
    $data_skills.each do |skill|
      next if skill.nil?
      @line = "Skill #{skill.id}: #{skill.name}"
      self.test(skill.menu_se,18)
      self.test(skill.icon_name,8)
    end
    self.sub('Items')
    $data_items.each do |item|
      next if item.nil?
      @line = "Item #{item.id}: #{item.name}"
      self.test(item.menu_se,18)
      self.test(item.icon_name,8)
    end
    self.sub('Weapons')
    $data_weapons.each do |weapon|
      next if weapon.nil?
      @line = "Weapon #{weapon.id}: #{weapon.name}"
      self.test(weapon.icon_name,8)
    end    
    self.sub('Armors')
    $data_armors.each do |armor|
      next if armor.nil?
      @line = "Armor #{armor.id}: #{armor.name}"
      self.test(armor.icon_name,8)
    end
    self.sub('Enemies')
    $data_enemies.each do |enemy|
      next if enemy.nil?
      @line = "Enemy #{enemy.id}: #{enemy.name}"
      self.test(enemy.battler_name,4)
    end
    self.sub('Animations')
    $data_animations.each do |animation|
      next if animation.nil?
      @line = "Animation #{animation.id}: #{animation.name}"
      self.test(animation.animation_name,1)
      animation.timings.each do |timing|
        self.test(timing.se,18)
      end
    end
    self.sub('Tilesets')
    $data_tilesets.each do |tileset|
      next if tileset.nil?
      @line = "Tileset #{tileset.id}: #{tileset.name}"
      self.test(tileset.tileset_name,11)
      self.test(tileset.panorama_name,9)
      self.test(tileset.fog_name,6)
      self.test(tileset.battleback_name,3)
      tileset.autotile_names.each do |autotile|
        self.test(autotile,2)
      end
    end
    self.sub('System')
    @line = 'System'
    self.test($data_system.windowskin_name,14)
    self.test($data_system.title_name,12)
    self.test($data_system.gameover_name,7)
    self.test($data_system.battle_transition,13)
    self.test($data_system.title_bgm,15)
    self.test($data_system.battle_bgm,15)
    self.test($data_system.battle_end_me,17)
    self.test($data_system.gameover_me,17)
    self.test($data_system.cursor_se,18)
    self.test($data_system.decision_se,18)
    self.test($data_system.cancel_se,18)
    self.test($data_system.buzzer_se,18)
    self.test($data_system.equip_se,18)
    self.test($data_system.shop_se,18)
    self.test($data_system.save_se,18)
    self.test($data_system.load_se,18)
    self.test($data_system.battle_start_se,18)
    self.test($data_system.escape_se,18)
    self.test($data_system.actor_collapse_se,18)
    self.test($data_system.enemy_collapse_se,18)
  end
  #-----------------------------------------------------------------------------
  # Test Maps
  #-----------------------------------------------------------------------------
  def self.test_maps
    $data_map_infos.keys.sort.each do |key|
      m = "Map #{key}: #{$data_map_infos[key].name}"
      self.scene_update("Testing #{m}")
      self.title(m)
      map = load_data(sprintf("Data/Map%03d.rxdata", key))
      @line = 'Map'
      self.test(map.bgm,15) if map.autoplay_bgm
      self.test(map.bgs,16) if map.autoplay_bgs
      map.events.keys.sort.each do |event_key|
        event = map.events[event_key]
        event.pages.each_with_index do |page, i|
          self.sub("Event #{event.id}: #{event.name}, Page #{i + 1}")
          @line = 'Page Graphic'
          self.test(page.graphic.character_name,5)
          if page.move_type == 3
            @line = 'Custom Move Route'
            page.move_route.list.each do |move|
              self.test_move(move)
            end
          end
          page.list.each_with_index do |command, j|
            @line = "Line #{j + 1}"
            self.test_command(command)
          end
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Test Common Events
  #-----------------------------------------------------------------------------
  def self.test_common_events
    self.scene_update('Testing Common Events')
    self.title('Common Events')
    $data_common_events.each do |ce|
      next if ce.nil?
      self.sub("Common Event #{ce.id}: #{ce.name}")
      ce.list.each_with_index do |command,i|
        @line = "Line #{i + 1}"
        self.test_command(command)
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Test Troops
  #-----------------------------------------------------------------------------
  def self.test_troops
    self.scene_update('Testing Troops')
    self.title('troops')
    $data_troops.each do |troop|
      next if troop.nil?
      troop.pages.each_with_index do |page, i|
        self.sub("Troop #{troop.id}: #{troop.name}, Page #{i + 1}")
        page.list.each_with_index do |command, j|
          @line = "Line #{j + 1}"
          self.test_command(command)
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Test Command
  #-----------------------------------------------------------------------------
  def self.test_command(command)
    case command.code
    when 131
      self.test(command.parameters[0],14)
    when 132
      self.test(command.parameters[0],15)
    when 133
      self.test(command.parameters[0],17)
    when 204
      case command.parameters[0]
      when 0
        self.test(command.parameters[1],9)
      when 1
        self.test(command.parameters[1],6)
      when 2
        self.test(command.parameters[1],3)
      end
    when 209
      command.parameters[1].list.each do |move|
        self.test_move(move)
      end
    when 222
      self.test(command.parameters[0],13)
    when 231
      self.test(command.parameters[1],10)
    when 241
      self.test(command.parameters[0],15)
    when 245
      self.test(command.parameters[0],16)
    when 249
      self.test(command.parameters[0],17)
    when 250
      self.test(command.parameters[0],18)
    when 322
      self.test(command.parameters[1],5)
      self.test(command.parmaeters[3],4)
    end
  end
  #-----------------------------------------------------------------------------
  # Test Move
  #-----------------------------------------------------------------------------
  def self.test_move(move)
    if move.code == 41
      self.test(move.parameters[0],5)
    elsif move.code == 44
      self.test(move.parameters[0],18)
    end
  end
  #-----------------------------------------------------------------------------
  # Title
  #-----------------------------------------------------------------------------
  def self.title(text)
    @edit1 = false
    @title = '', '#' + '=' * 50, '# ' + text, '#' + '=' * 50, ''
  end
  #-----------------------------------------------------------------------------
  # Subtitle
  #-----------------------------------------------------------------------------
  def self.sub(text)
    @edit2 = false
    @sub = '', '#' + '-' * 50, '# ' + text, '#' + '-' * 50, ''
  end
  #-----------------------------------------------------------------------------
  # Test
  #-----------------------------------------------------------------------------
  def self.test(file,type)
    file = file.name if type > 14
    return if file == ''
    unless self.filetest(file,type)
      @text.push *@title unless @edit1
      @text.push *@sub unless @edit2
      @edit1 = @edit2 = @edit3 = true
      @text.push "#{@line}, #{self.folder(type,false)} '#{file}'"
    end
  end
  #-----------------------------------------------------------------------------
  # Filetest
  #-----------------------------------------------------------------------------
  def self.filetest(file,type)
    if type <= 14
      folder = 'Graphics'
      extensions = ['png','jpg','bmp']
    else
      folder = 'Audio'
      extensions = ['ogg','aac','wma','mp3','wav','it',
                    'xm','mod','s3m','mid','midi','flac']
    end
    name = "#{folder}/#{self.folder(type)}/#{file}"
    return @cache[name] unless @cache[name].nil?
    if Time.now - @time > 9
      Graphics.update
      @time = Time.now
    end
    return true if FileTest.exist?(name)
    extensions.each do |ext| 
      return true if FileTest.exist?("#{name}.#{ext}")
    end
    case type
    when 1..14
      begin
        bitmap = Bitmap.new(name)
      rescue
        @cache[name] = false
        return false
      end
      bitmap.dispose
      @cache[name] = true
      return true
    when 15
      begin
        Audio.bgm_play(name)
      rescue
        @cache[name] = false
        return false
      end
      Audio.bgm_stop
      @cache[name] = true
      return true
    when 16
      begin
       Audio.bgs_play(name) 
     rescue 
       @cache[name] = false
       return false
      end
      Audio.bgs_stop
      @cache[name] = true
      return true
    when 17
      begin
        Audio.me_play(name)
      rescue
        @cache[name] = false
        return false
      end
      Audio.me_stop
      @cache[name] = true
      return true
    when 18
      begin
        Audio.se_play(name) 
      rescue
        @cache[name] = false
        return false
      end
      Audio.se_stop
      @cache[name] = true
      return true
    end
  end
  #-----------------------------------------------------------------------------
  # Folder
  #-----------------------------------------------------------------------------
  def self.folder(type,s = true)
    case type
    when 1 then text = 'Animation'
    when 2 then text = 'Autotile'
    when 3 then text = 'Battleback'
    when 4 then text = 'Battler'
    when 5 then text = 'Character'
    when 6 then text = 'Fog'
    when 7 then text = 'Gameover'
    when 8 then text = 'Icon'
    when 9 then text = 'Panorama'
    when 10 then text = 'Picture'
    when 11 then text = 'Tileset'
    when 12 then text = 'Title'
    when 13 then text = 'Transition'
    when 14 then text = 'Windowskin'
    when 15 then text = 'BGM'
    when 16 then text = 'BGS'
    when 17 then text = 'ME'
    when 18 then text = 'SE'
    end
    text += 's' if s && type <= 14
    return text
  end
  #-----------------------------------------------------------------------------
  # Initialize
  #-----------------------------------------------------------------------------
  def self.scene_initialize
    @rate = 0
    @mask = Sprite.new
    @mask.z = 100000
    @mask.bitmap = Bitmap.new(640,480)
    @mask.bitmap.fill_rect(0,0,640,480,Color.new(0,0,0,100))
    @main = Sprite.new
    @main.y, @main.z = 100, 100000
    @main.bitmap = Bitmap.new(640,24)
    @main.bitmap.draw_text(0,0,640,24,'Finding Missing Filenames',1)
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
    rate = @rate.to_f / ($data_map_infos.size + 4).to_f
    @bar.bitmap.fill_rect(8, 8, 240 * rate, 48, Color.new(0,0,255,255))
    Graphics.update
  end
  #-----------------------------------------------------------------------------
  # Dispose
  #-----------------------------------------------------------------------------
  def self.scene_dispose
    [@mask,@main,@message,@bar].each do |sprite|
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
    self.find
    exit
  end
end