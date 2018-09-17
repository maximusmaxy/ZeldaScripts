#===============================================================================
# Search
#===============================================================================
# Author: Maximusmaxy
# Version 1.0: 2/1/12
#===============================================================================
#
# Introduction:
# Allows you to search for event commands with specific parameters and creates
# a text document with the results.
#
# Instructions:
# Use the script call:
# SEARCH.begin(TYPE,PARAMETER)
# TYPE is the type specified in the type list
# PARAMETER is the text or ID of the type
#
# Type List
# 1 = Text
# 2 = Comment
# 3 = Script
# MORE TO BE ADDED LATER
#
#===============================================================================

module SEARCH
  
#===============================================================================
# Configuration
#===============================================================================
  #Set to true to activate the search
  ENABLE = false
  #Set the type of search (refer to the type list)
  TYPE = 1
  #Set your search parameter (text or number)
  PARAMETER = ''
#===============================================================================
# End Configuration
#===============================================================================

  #-----------------------------------------------------------------------------
  # Begin
  #-----------------------------------------------------------------------------
  def self.begin(type, parameter)
    @type = type
    @parameter = parameter
    @text = []
    @title = []
    @sub = []
    @line = ''
    @edit1 = @edit2 = @edit3 = false
    self.scene_initialize
    $data_map_infos.keys.sort.each do |key|
      m = "Map #{key}: #{$data_map_infos[key].name}"
      self.scene_update("Seaching #{m}")
      self.title(m)
      map = load_data(sprintf("Data/Map%03d.rxdata",key))
      map.events.keys.sort.each do |event_key|
        event = map.events[event_key]
        event.pages.each_with_index do |page, i|
          self.sub("Event #{event_key}: #{event.name}, Page #{i + 1}")
          if @type == 3 && page.move_type == 3
            page.move_route.list.each do |move|
              @line = 'Custom Move Route'
              self.check_text(move.parameters[0]) if move.code == 45
            end
          end
          page.list.each_with_index do |command, j|
            @line = "Line #{j + 1}"
            self.check(command)
          end
        end
      end        
    end
    self.scene_update('Searching Common Events')
    self.title("Common Events")
    $data_common_events.each do |ce|
      next if ce.nil?
      self.sub("Common Event #{ce.id}: #{ce.name}")
      ce.list.each_with_index do |command, i|
        @line = "Line #{i + 1}"
        self.check(command)
      end
    end
    self.scene_update('Searching Troops')
    self.title("Troops")
    $data_troops.each do |troop|
      next if troop.nil?
      troop.pages.each do |page|
        self.sub("Troop #{troop.id}: #{troop.name}")
        page.list.each_with_index do |command, i|
          @line = "Line #{i + 1}"
          self.check(command)
        end
      end
    end
    self.scene_update('Complete')
    if @edit3
      title = "Search for '#{@parameter}'"
      @text.unshift '#' + '=' * 50, '# ' + title, '#' + '=' * 50
      file = File.open('Search Results Log.txt', 'w')
      @text.each {|line| file.write("#{line}\n")}
      file.close
      p 'Matches found, Search Results Log created'
    else
      p 'No matches found'
    end
    self.scene_dispose
  end
  #-----------------------------------------------------------------------------
  # Check
  #-----------------------------------------------------------------------------
  def self.check(command)
    if (@type == 1 && [101,401].include?(command.code)) ||
       (@type == 2 && [108,408].include?(command.code)) ||
       (@type == 3 && [355,655].include?(command.code))
      self.check_text(command.parameters[0])
    end
    if @type == 3
      if command.code == 209
        command.parameters[1].list.each do |move|
          self.check_text(move.parameters[0]) if move.code == 45
        end
      elsif command.code == 111 && command.parameters[0] == 12
        self.check_text(command.parameters[1])
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Check Text
  #-----------------------------------------------------------------------------
  def self.check_text(text)
    if text.downcase.include?(@parameter.downcase)
      @text.push *@title unless @edit1
      @text.push *@sub unless @edit2
      @edit1 = @edit2 = @edit3 = true
      @text.push "#{@line}, '#{text}'"
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
    @main.bitmap.draw_text(0,0,640,24,"Searching for '#{@parameter}'",1)
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
    rate = @rate.to_f / ($data_map_infos.size + 3).to_f
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
    $data_troops        = load_data('Data/Troops.rxdata')
    $data_common_events = load_data('Data/CommonEvents.rxdata')
    $data_map_infos     = load_data('Data\MapInfos.rxdata')
    self.begin
    exit
  end
end