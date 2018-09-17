#===============================================================================
# Event to Text
#===============================================================================
# Author: Maximusmaxy
# Version 1.0: 21/12/11
#===============================================================================
#
# Instructions:
# To create an event text document use one of the following script calls:
#
# ETT.print(ID)
# ID is the event ID on the current map
# The ID can be ommitted to reference the running event
#
# ETT.print_troop(ID)
# ID is the troop ID in the database
#
# ETT.print_common_event(ID)
# ID is the common event ID in the database
#
#===============================================================================

module ETT
#===============================================================================
# Configuration
#===============================================================================
  #Add the BBC Color Tags for forums
  COLOR = true
  #Display the confirmation message on completion
  MESSAGE = true
#===============================================================================
# End Configuration
#===============================================================================
  def self.print(id = nil, troop = false)
    text = []
    line = '#' + '=' * 50
    if $scene.is_a?(Scene_Map) && !troop
      id = $game_system.map_interpreter.event_id if id.nil?
      map_id = $game_map.map_id
      map = "Map #{map_id}: #{$data_map_infos[map_id].name}"
      event = "Event #{id}: #{$game_map.events[id].event.name}"
      text.push line, "# #{map}, #{event}", line
      $game_map.events[id].event.pages.each_with_index do |page, i|
        text.push '', line, "# Page #{i + 1}", line, ''
        text.push *self.make_list(page.list)
      end
      file = File.open("Map - #{$game_map.map_id}, Event - #{id}.txt",'w')
      text.each {|line| file.write("#{line}\n")}
      file.close
      p "Event to text for '#{event}' is Complete." if MESSAGE
    else
      id = $game_temp.battle_troop_id if id.nil?
      troop = "Troop #{id}: #{$data_troops[id].name}"
      text.push line, "# #{troop}", line
      $data_troops[id].pages.each_with_index do |page, i|
        text.push '', line, "# Page #{i + 1}", line, ''
        text.push *self.make_list(page.list)
      end
      file = File.open("Troop - #{id}.txt",'w')
      text.each {|line| file.write("#{line}\n")}
      file.close
      p "Event to text for '#{troop}' is Complete." if MESSAGE
    end
  end
  
  def self.print_troop(id = nil)
    Scene.is_a?(Scene_Map) ? self.print(id, true) : self.print
  end
  
  def self.print_common_event(id)
    text = []
    line = '#' + '=' * 50
    ce = "Common Event #{id}: #{$data_common_events[id].name}"
    text.push line, "# #{ce}", line, ''
    text.push *self.make_list($data_common_events[id].list)
    file = File.open("Common Event - #{id}.txt",'w')
    text.each {|line| file.write("#{line}\n")}
    file.close
    p "Event to text for '#{ce}' is Complete." if MESSAGE
  end
  
  def self.make_list(list)
    text = []
    list.each do |command|
      params = command.parameters
      line = ''
      case command.code
      when 101  # Show Text
        line += "Text: #{params[0]}"
      when 401  # Show Text
        line += "    : #{params[0]}"
      when 102  # Show Choices
        @choices = command.parameters[0]
        line += 'Show Choices: '
        @choices.each{|choice| line += "#{choice},"}
        line[-1,1] = ''
      when 402  # When [**]
        line += "When [#{@choices[params[0]]}]"
      when 403  # When Cancel
        line += 'When Cancel'
      when 404  # When Branch End
        line += 'Branch End'
      when 103  # Input Number
        line += "Input Number: [#{self.sprint(params[0])}]"
        line += ", #{params[1]} digit(s)"
      when 104  # Change Text Options
        case params[0]
        when 0 then position = 'Top'
        when 1 then position = 'Middle'
        when 2 then position = 'Bottom'
        end
        case params[1]
        when 0 then window = 'Show'
        when 1 then window = 'Hide'
        end
        line += "Change Text Options: #{position}, #{window}"
      when 105  # Button Input Processing
        line += "Button Input Processing: [#{self.sprint(params[0])}]"
      when 106  # Wait
        line += "Wait: #{params[0]} frame(s)"
      when 108  # Comment
        line += "Comment: #{params[0]}"
      when 408  # Comment
        line += "       : #{params[0]}"
      when 111  # Conditional Branch
        line += 'Conditional Branch: '
        case params[0]
        when 0  # switch
          bool = params[2] == 0 ? 'ON' : 'OFF' 
          line += "Switch [#{self.sprint(params[1])}] == #{bool}"
        when 1  # variable
          line += "Variable [#{self.sprint(params[1])}] "
          case params[4]
          when 0 then line += '== '
          when 1 then line += '>= '
          when 2 then line += '<= '
          when 3 then line += '> '
          when 4 then line += '< '
          when 5 then line += '!= '
          end
          case params[2]
          when 0 then line += "#{params[3]}"
          when 1 then line += "Variable [#{self.sprint(params[3])}]"
          end
        when 2  # self switch
          bool = params[2] == 0 ? 'ON' : 'OFF'
          line += "Self Switch #{params[1]} == #{bool}"
        when 3  # timer
          min = params[1] / 60 
          sec = params[1] % 60
          bool = params[2] == 0 ? 'or more' : 'or less'
          line += "Timer #{min} min #{sec} sec #{bool}"
        when 4  # actor
          line += "[#{$data_actors[params[1]].name}] is "
          case params[2]
          when 0 then line += 'in the party'
          when 1 then line += "name '#{params[3]}' applied"
          when 2 then line += "[#{$data_skills[params[3]].name}] learned"
          when 3 then line += "[#{$data_weapons[params[3]].name}] equipped"
          when 4 then line += "[#{$data_armors[params[3]].name}] equipped"
          when 5 then line += "[#{$data_states[params[3]].name}] inflicted"
          end
        when 5  # enemy
          line += self.enemy(params[1])
          case params[2]
          when 0 then line += ' is appeared'
          when 1 then line += " is [#{$data_states[params[3]].name}] inflicted"
          end
        when 6  # character
          direction = self.direction(params[2])
          line += "#{self.character(params[1])} is facing #{direction}"
        when 7  # gold
          bool = params[2] == 0 ? 'or more' : 'or less'
          line += "Gold #{params[1]} #{bool}"
        when 8  # item
          line += "[#{$data_items[params[1]].name}] in Inventory"
        when 9  # weapon
          line += "[#{$data_weapons[params[1]].name}] in Inventory"
        when 10  # armor
          line += "[#{$data_armors[params[1]].name}] in Inventory"
        when 11  # button
          case params[1]
          when 2 then button = 'Down'
          when 4 then button = 'Left'
          when 6 then button = 'Right'
          when 8 then button = 'Up'
          when 11 then button = 'A'
          when 12 then button = 'B'
          when 13 then button = 'C'
          when 14 then button = 'X'
          when 15 then button = 'Y'
          when 16 then button = 'Z'
          when 17 then button = 'L'
          when 18 then button = 'R'
          end
          line += "The #{button} button is being pressed"
        when 12  # script
          line += "Script: #{params[1]}"
        end
      when 411  # Else
        line += 'Else'
      when 412  # Branch End
        line += 'Branch End'
      when 112  # Loop
        line += 'Loop'
      when 413  # Repeat Above
        line += 'Repeat Above'
      when 113  # Break Loop
        line += 'Break Loop'
      when 115  # Exit Event Processing
        line += 'Exit Event Processing'
      when 116  # Erase Event
        line += 'Erase Event'
      when 117  # Call Common Event
        line += "Call Common Event: #{$data_common_events[params[0]].name}"
      when 118  # Label
        line += "Label: #{params[0]}"
      when 119  # Jump to Label
        line += "Jump to Label: #{params[0]}"
      when 121  # Control Switches
        line += "Control Switches: [#{self.sprint(params[0])}"
        line += "..#{self.sprint(params[1])}" if params[0] != params[1]
        bool = params[2] == 0 ? 'ON' : 'OFF'
        line += "] = #{bool}"
      when 122  # Control Variables
        line += "Control Variables: [#{self.sprint(params[1])}"
        line += "..#{self.sprint(params[1])}" if params[0] != params[1]
        case params[2]
        when 0 then operation = '='
        when 1 then operation = '+='
        when 2 then operation = '-='
        when 3 then operation = '*='
        when 4 then operation = '/='
        when 5 then operation = '%='
        end
        case params[3]
        when 0 then operand = params[4]
        when 1 then operand = "Variable [#{self.sprint(params[4])}]"
        when 2 then operand = "Random No. (#{params[4]}...#{params[5]})"
        when 3 then operand = "[#{$data_items[params[4]].name}] In Inventory"
        when 4, 5
          if params[3] == 4
            operand = "[#{$data_actors[params[4]].name}]'s "
          elsif params[3] == 5
            operand = "[#{params[4] + 1}."
            unless $game_troop.enemies[params[4]].nil?
              operand += "#{$game_troop.enemies[params[4]].name}"
            end
            operand += "]'s "
            params[5] += 2
          end
          case params[5]
          when 0 then operand += 'Level'
          when 1 then operand += 'EXP'
          when 2 then operand += 'HP'
          when 3 then operand += 'SP'
          when 4 then operand += 'MaxHP'
          when 5 then operand += 'MaxSP'
          when 6 then operand += 'STR'
          when 7 then operand += 'DEX'
          when 8 then operand += 'AGI'
          when 9 then operand += 'INT'
          when 10 then operand += 'ATL'
          when 11 then operand += 'PDEF'
          when 12 then operand += 'MDEF'
          when 13 then operand += 'EVA'
          end
        when 6
          operand = "#{self.character(params[4])}'s "
          case params[5]
          when 0 then operand += 'Map X'
          when 1 then operand += 'Map Y'
          when 2 then operand += 'Direction'
          when 3 then operand += 'Screen X'
          when 4 then operand += 'Screen Y'
          when 5 then operand += 'Terrain Tag'
          end
        when 7
          case params[4]
          when 0 then operand = 'Map ID' 
          when 1 then operand = 'Party Members'
          when 2 then operand = 'Gold'
          when 3 then operand = 'Steps'
          when 4 then operand = 'Play Time'
          when 5 then operand = 'Timer'
          when 6 then operand = 'Save Count'
          end
        end
        line += "] #{operation} #{operand}"
      when 123  # Control Self Switch
        bool = params[1] == 0 ? 'ON' : 'OFF'
        line += "Control Self Switch: #{params[0]} =#{bool}"
      when 124  # Control Timer
        line += "Control Timer: "
        case params[0]
        when 0
          min = params[1] / 60
          sec = params[1] % 60
          line += "Startup (#{min} min. #{sec} sec.)"
        when 1 then line += 'Stop'
        end
      when 125  # Change Gold
        operation = (params[0] == 0 ? '+' : '-')
        case params[1]
        when 0 then operand = params[2]
        when 1 then operand = "Variable [#{self.sprint(params[2])}]"
        end
        line += "Change Gold: #{operation} #{operand}"
      when 126, 127, 128  # Change Items, Weapons, Armor
        case command.code
        when 126; code = 'Items'; name = "[#{$data_items[params[0]].name}],"
        when 127; code = 'Weapons'; name = "[#{$data_weapons[params[0]].name}]"
        when 128; code = 'Armor'; name = "[#{$data_armors[params[0]].name}]"
        end
        operation = (params[1] == 0 ? '+' : '-')
        case params[2]
        when 0 then operand = params[3]
        when 1 then operand = "Variable [#{self.sprint(params[3])}]"
        end
        line += "Change #{code}: #{name} #{operation} #{operand}"
      when 129  # Change Party Member
        operation = (params[1] == 0 ? 'Add' : 'Remove')
        actor = $data_actors[params[0]].name
        line += "Change Party Member: #{operation} [#{actor}]"
        line += ', Initialize' if params[2] == 1 && params[1] == 0
      when 131  # Change Windowskin
        line += "Change Windowskin: '#{params[0]}'"
      when 132, 133  # Change Battle BGM, End ME
        case command.code
        when 132 then type = 'BGM'
        when 133 then type = 'End ME'
        end
        line += "Change Battle #{type}: #{self.audio(params[0])}"
      when 134, 135, 136  # Change Save Access
        case command.code
        when 134 then type = 'Save Access'
        when 135 then type = 'Menu Access'
        when 136 then type = 'Encounter'
        end
        bool = (params[0] == 0 ? 'Disable' : 'Enable')
        line += "Change #{type}: #{bool}"
      when 201  # Transfer Player
        case params[0]
        when 0
          map = "[#{self.sprint(params[1],3)}: "
          map += "#{$data_map_infos[params[1]].name}]"
          x = ", (#{self.sprint(params[2],3)}"
          y = ",#{self.sprint(params[3],3)})"
        when 1
          map = "Variable [#{self.sprint(params[1])}]"
          x = "[#{self.sprint(params[2])}]"
          y = "[#{self.sprint(params[3])}]"
        end
        line += "Transfer Player:#{map}#{x}#{y}"
        line += ", #{self.direction(params[4])}" if params[4] != 0
        line += ', No Fade' if params[5] == 1
      when 202  # Set Event Location
        line += "Set Event Location: #{self.character(params[0])},"
        case params[1]
        when 0 
          line += "(#{self.sprint(params[2],3)},"
          line += "#{self.sprint(params[3],3)})"
        when 1 
          line += "Variable [#{self.sprint(params[2])}]"
          line += "[#{self.sprint(params[3])}]"
        when 2 then line += "Switch with #{self.character(params[2])}"
        end
        line += ", #{self.direction(params[-1])}" if params[-1] != 0
      when 203  # Scroll Map
        direction = self.direction(params[0])
        line += "Scroll Map: #{direction}, #{params[1]}, #{params[2]}"
      when 204  # Change Map Settings
        line += 'Change Map Settings:'
        case params[0]
        when 0 then line += "Panorama = '#{params[1]}', #{params[2]}"
        when 1
          na, f, h, o, b, z, x, y = *params
          b = self.blend(b)         
          line += "Fog = '#{f}', #{h}, #{o}, #{b}, #{z}, #{x}, #{y}"
        when 2 then line += "Battleback = '#{params[1]}'"
        end
      when 205  # Change Fog Color Tone
        line += "Change Fog Color Tone: #{self.tone(params[0])}, @#{params[1]}"
      when 206  # Change Fog Opacity
        line += "Change Fog Opacity: #{params[0]}, @#{params[1]}"
      when 207  # Show Animation
        animation = $data_animations[params[1]].name
        line += "Show Animation: #{self.character(params[0])}, [#{animation}]"
      when 208  # Change Transparent Flag
        transparent = (params[0] == 0 ? 'Transparency' : 'Normal')
        line += "Change Transparent Flag: #{transparent}"
      when 209  # Set Move Route
        line += "Set Move Route: #{self.character(params[0])}"
        if params[1].repeat && !params[1].skippable
          line += ' (Repeat Action)'
        elsif params[1].skippable && !params[1].repeat
          line += " (Ignore If Can't Move)"
        elsif params[1].repeat && params[1].skippable
          line += " (Repeat Action, Ignore If Can't Move)"
        end
      when 509  # Move Command
        line += '              : $>'
        p = params[0].parameters
        case params[0].code
        when 1 then line += 'Move Down'
        when 2 then line += 'Move Left'
        when 3 then line += 'Move Right'
        when 4 then line += 'Move Up'
        when 5 then line += 'Move Lower Left'
        when 6 then line += 'Move Lower Right'
        when 7 then line += 'Move Upper Left'
        when 8 then line += 'Move Upper Right'
        when 9 then line += 'Move at Random'
        when 10 then line += 'Move toward Player'
        when 11 then line += 'Move away from Player'
        when 12 then line += '1 Step Forward'
        when 13 then line += '1 Step Backward'
        when 14 then line += "Jump: +#{p[0]}, +#{p[1]}"
        when 15 then line += "Wait: #{p[0]} frame(s)"
        when 16 then line += 'Turn Down'
        when 17 then line += 'Turn Left'
        when 18 then line += 'Turn Right'
        when 19 then line += 'Turn Up'
        when 20 then line += 'Turn 90° Right'
        when 21 then line += 'Turn 90° Left'
        when 22 then line += 'Turn 180°'
        when 23 then line += 'Turn 90° Right or Left'
        when 24 then line += 'Turn at Random'
        when 25 then line += 'Turn toward player'
        when 26 then line += 'Turn away from Player'
        when 27 then line += "Switch ON: #{self.sprint(p[0])}"
        when 28 then line += "Switch OFF: #{self.sprint(p[0])}"
        when 29 then line += "Change Speed: #{p[0]}"
        when 30 then line += "Change Freq: #{p[0]}"
        when 31 then line += 'Move Animation ON'
        when 32 then line += 'Move Animation OFF'
        when 33 then line += 'Stop Animation ON'
        when 34 then line += 'Stop Animation OFF'
        when 35 then line += 'Direction Fix ON'
        when 36 then line += 'Direction Fix OFF'
        when 37 then line += 'Through ON'
        when 38 then line += 'Through OFF'
        when 39 then line += 'Always on Top ON'
        when 40 then line += 'Always on Top OFF'
        when 41
          f, h, d, a = *p
          line += "Change Graphic: '#{f}', #{h}, #{d}, #{a}"
        when 42 then line += "Change Opacity: #{p[0]}"
        when 43 then line += "Change Blending: #{self.blend(p[0])}"
        when 44 then line += "Play SE: #{self.audio(p[0])}"
        when 45 then line += "Script: #{p[0]}"
        end
      when 210  # Wait for Move's Completion
        line += "Wait for Move's Completion"
      when 221  # Prepare for Transition
        line += "Prepare for Transition"
      when 222  # Execute Transition
        line += "Execute Transition: '#{params[0]}'"
      when 223  # Change Screen Color Tone
        tone = self.tone(params[0])
        line += "Change Sceen Color Tone: #{tone}, @#{params[1]}"
      when 224  # Screen Flash
        line += "Screen Flash: #{self.color(params[0])}, @#{params[1]}"
      when 225  # Screen Shake
        line += "Screen Shake: #{params[0]}, #{params[1]}, @#{params[2]}"
      when 231, 232  # Show, Move Picture
        case command.code
        when 231; t = 'Show'; f = "'#{params[1]}'";
        when 232; t = 'Move'; f = "@{params[1]}";
        end
        i = params[0]
        l = params[2] == 0 ? 'Upper Left' : 'Center'
        case params[3]
        when 0 then xy = "#{params[4]},#{params[5]}"
        when 1 
          x, y = self.sprint(params[4]), self.sprint(params[5])
          xy = "Variable [#{x}][#{y}]"
        end
        z = "#{params[6]}%,#{params[7]}%"
        o = params[8]
        b = self.blend(params[9])
        line += "#{t} Picture: #{i}, #{f}, #{l}(#{xy}), (#{z}), #{o}, #{b}" 
      when 233  # Rotate Picture
        line += "Rotate Picture: #{params[0]}, +#{params[1]}"
      when 234  # Change Picture Color Tone
        picture, tone, frames = params[0], self.tone(params[1]), params[2]
        line += "Change Picture Color Tone: #{picture}, #{tone}, @#{frames}"
      when 235  # Erase Picture
        line += "Erase Picture: #{params[0]}"
      when 236  # Set Weather Effects
        case params[0]
        when 0 then weather = 'None'
        when 1 then weather = 'Rain'
        when 2 then weather = 'Storm'
        when 3 then weather = 'Snow'
        end
        strength = (params[0] == 0 ? '' : ", #{params[1]}")
        line += "Set Weather Effects: #{weather}#{strength}, @#{params[2]}"
      when 241  # Play BGM
        line += "Play BGM: #{self.audio(params[0])}"
      when 242  # Fade Out BGM
        line += "Fade Out BGM: #{params[0]} sec."
      when 245  # Play BGS
        line += "Play BGS: #{self.audio(params[0])}"
      when 246  # Fade Out BGS
        line += "Fade Out BGS: #{params[0]} sec."
      when 247  # Memorize BGM/BGS
        line += 'Memorize BGM/BGS'
      when 248  # Restore BGM/BGS
        line += 'Restore BGM/BGS'
      when 249  # Play ME
        line += "Play ME: #{self.audio(params[0])}"
      when 250  # Play SE
        line += "Play SE: #{self.audio(params[0])}"
      when 251  # Stop SE
        line += 'Stop SE'
      when 301  # Battle Processing
        line += "Battle Processing: #{$data_troops[params[0]].name}"
      when 601  # If Win
        line += 'If win'
      when 602  # If Escape
        line += 'If Escape'
      when 603  # If Lose
        line += 'If Lose'
      when 604  # Branch End
        line += 'Branch End'
      when 302, 605  # Shop Processing
        case command.code
        when 302 then type = 'Shop Processing:'
        when 605 then type = '               :'
        end
        case params[0]
        when 0 then item = $data_items[params[1]].name
        when 1 then item = $data_weapons[params[1]].name
        when 2 then item = $data_armors[params[1]].name
        end
        line += "#{type} [#{item}]"
      when 303  # Name Input Processing
        name = $data_actors[params[0]].name
        line += "Name Input Processing: #{name}, #{params[1]} characters"
      when 311, 312, 315, 316, 331, 332  # Change HP, SP, EXP, Level
        case command.code
        when 311 then type = 'HP'
        when 312 then type = 'SP'
        when 315 then type = 'EXP'
        when 316 then type = 'Level'
        when 331 then type = 'Enemy HP'
        when 332 then type = 'Enemy SP'
        end
        battler = self.battler(params[0],command)
        operation = (params[1] == 0 ? '+' : '-')
        case params[2]
        when 0 then operand = params[3]
        when 1 then operand = "Variable [#{self.sprint(params[3])}]"
        end
        line += "Change #{type}: #{battler}, #{operation} #{operand}"
      when 313, 333  # Change State
        case command.code
        when 313 then type = 'State'
        when 333 then type = 'Enemy State'
        end
        battler = self.battler(params[0],command)
        operation = (params[1] == 0 ? '+' : '-')
        state = $data_states[params[2]].name
        line += "Change #{type}: #{battler} #{operation} [#{state}]"
      when 314, 334  # Recover All
        type = (command.code == 314 ? '' : 'Enemy ') 
        line += "#{type}Recover All: #{self.battler(params[0],command)}"
      when 317  # Change Parameters
        actor = self.actor(params[0])
        case params[1]
        when 0 then p = 'MaxHP' 
        when 1 then p = 'MaxSP'
        when 2 then p = 'STR'
        when 3 then p = 'DEX'
        when 4 then p = 'AG'
        when 5 then p = 'INT'
        end
        operation = (params[2] == 0 ? '+' : '-')
        case params[3]
        when 0 then operand = params[4]
        when 1 then operand = "Variable [#{self.sprint(params[3])}]"
        end
        line += "Change Parameters: #{actor}, #{p} #{operation} #{operand}"
      when 318  # Change Skills
        actor = self.actor(params[0])
        operation = (params[1] == 0 ? '+' : '-')
        skill = $data_skills[params[2]].name
        line += "Change Skills: #{actor}, #{operation} [#{skill}]"
      when 319  # Change Equipment
        actor = self.actor(params[0])
        case params[1]
        when 0 then type = 'Weapon'
        when 1 then type = 'Shiled'
        when 2 then type = 'Helmet'
        when 3 then type = 'Body Armor'
        when 4 then type = 'Accessory'
        end
        if params[2] == 0
          item = '(None)'
        else
          if params[1] == 0
            item = "[#{$data_weapons[params[2]].name}]"
          else
            item = "[#{$data_armors[params[2]].name}]"
          end
        end
        line += "Change Equipment: #{actor}, #{type} = #{item}"
      when 320  # Change Actor Name
        line += "Change Actor Name: #{self.actor(params[0])}, '#{params[1]}'"
      when 321  # Change Actor Class
        actor = self.actor(params[0])
        klass = $data_classes[params[1]].name
        line += "Change Actor Class: #{actor}, [#{klass}]"
      when 322  # Change Actor Graphic
        actor = self.actor(params[0])
        na, f1, h1, f2, h2 = *params
        line += "Change Actor Graphic: #{actor}, #{f1}, #{h1}, #{f2}, #{h2}"
      when 335  # Enemy Appearance
        line += "Enemy Appearance: #{self.enemy(params[0])}"
      when 336  # Enemy Transform
        enemy = $data_enemies[params[1]].name
        line += "Enemy Transform: #{self.enemy(params[0])}, [#{enemy}]"
      when 337  # Show Battle Animation
        case params[0]
        when 0 then battler = self.enemy(params[1])
        when 1 then battler = self.actor(params[1], true)
        end
        animation = $data_animations[params[2]].name
        line += "Show Battle Animation: #{battler}, [#{animation}]"
      when 338  # Deal Damage
        case params[0]
        when 0 then battler = self.enemy(params[1])
        when 1 then battler = self.actor(params[1], true)
        end
        case params[2]
        when 0 then operand = params[3]
        when 1 then operand = "Variable [#{self.sprint(params[3])}]"
        end
        line += "Deal Damage: #{battler}, #{operand}"
      when 339  # Force Action
        case params[0]
        when 0 then battler = self.enemy(params[1])
        when 1 then battler = self.actor(params[1], true)
        end
        case params[2]
        when 0
          case params[3]
          when 0 then action = 'Attack'
          when 1 then action = 'Defend'
          when 2 then action = 'Escape'
          when 3 then action = 'Do Nothing'
          end
        when 1 then action = "[#{$data_skills[params[3]].name}]"
        end
        case params[4]
        when -2 then target = 'Last Target'
        when -1 then target = 'Random'
        else target = "Index #{params[4] + 1}"
        end
        line += "Force Action: #{battler}, #{action}, #{target}"
        line += ', Execute Now' if params[5] == 1
      when 340  # Abort Battle
        line += 'Abort Battle'
      when 351  # Call Menu Screen
        line += 'Call Menu Screen'
      when 352  # Call Save Screen
        line += 'Call Save Screen'
      when 353  # Game Over
        line += 'Game Over'
      when 354  # Return to Title Screen
        line += 'Return to Title Screen'
      when 355  # Script
        line += "Script: #{params[0]}"
      when 655  # Script
        line += "      : #{params[0]}"
      end
      line = self.add_color(line, command.code) if COLOR
      command.code < 400 ? line = '@>' + line : line = ': ' + line
      line = '  ' * command.indent + line
      text.push(line) 
    end
    return text
  end
  
  def self.sprint(number, d = 4)
    return sprintf("%0#{d}d",number)
  end
  
  def self.character(id)
    case id
    when -1 then return 'Player'
    when 0 then return 'This Event'
    else return "[#{$game_map.events[id].event.name}]"
    end
  end
  
  def self.actor(id, in_battle = false)
    id += 1 if in_battle
    if id == 0
      return 'Entire Party'
    else 
      if in_battle
        return "Actor No.#{id}"
      else
        return "[#{$data_actors[id].name}]"
      end
    end
  end
  
  def self.enemy(id)
    if id == -1
      return 'Entire Troop'
    else 
      if $game_troop.enemies[id].nil?
        enemy = ''
      else
        enemy = $game_troop.enemies[id].name
      end
      return "[#{id + 1}. #{enemy}]"
    end
  end
  
  def self.battler(id,command)
    return command.code < 330 ? self.actor(id) : self.enemy(id)
  end
  
  def self.direction(d)
    case d
    when 2 then return 'Down'
    when 4 then return 'Left'
    when 6 then return 'Right'
    when 8 then return 'Up'
    else return ''
    end
  end
  
  def self.blend(type)
    case type
    when 0 then return 'Normal'
    when 1 then return 'Add'
    when 2 then return 'Sub'
    else return ''
    end
  end
  
  def self.tone(tone)
    r = tone.red.truncate 
    g = tone.green.truncate
    b = tone.blue.truncate
    gray = tone.gray.truncate
    return "(#{r},#{g},#{b},#{gray})"
  end
  
  def self.color(color)
    r = color.red.truncate
    g = color.green.truncate
    b = color.blue.truncate
    a = color.alpha.truncate
    return "(#{r},#{g},#{b},#{a})"
  end
    
  def self.audio(file)
    return "'#{file.name}', #{file.volume}, #{file.pitch}"
  end
  
  def self.add_color(line, id)
    id -= 300 if id > 400
    case id
    when 101..106 then tag = '#000000'
    when 108 then tag = '#007F0E'
    when 111..119 then tag = '#0000FF'
    when 121..129 then tag = '#FF0000'
    when 131..136 then tag = '#FF00FF'
    when 201..210 then tag = '#A0522D'
    when 221..225 then tag = '#808000'
    when 231..236 then tag = '#800080'
    when 241..251 then tag = '#008080'
    when 301..305 then tag = '#FFA500'
    when 311..322 then tag = '#00BFFF'
    when 331..340 then tag = '#9932CC'
    when 351..355 then tag = '#808080'
    else return line
    end
    return "[color=#{tag}]#{line}[/color]"
  end
end

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event
  attr_reader :event
end

#===============================================================================
# Interpreter
#===============================================================================

class Interpreter
  attr_reader :event_id
end

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title
  alias max_ett_main_later main
  def main
    $data_map_infos = load_data('Data\MapInfos.rxdata') if $data_map_infos.nil?
    max_ett_main_later
  end
end