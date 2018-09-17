#==============================================================================
#  Night_Runner's Zelda Style CMS
#------------------------------------------------------------------------------
# History
#  Date Created 16Oct11
#  Created for Project Zelda Game Engine
#
# Description
#  This script allows the changing of CMS.
#
# How to Install
#  In your game, go Tools  Script Editor. In the left panel, scroll down
#  to the bottom, right click on Main, and select Insert. Paste this script
#  in the Main Window on the right.
#
# Customization
#  Make the items you want to show in the menu in the database.
#  To customize the positions of the items in the menu, edit the cvs files
#   in the DataMenuSetup folder
# 
# Script Calls
#  - soaring_transfer
#  Transfers you to the soaring transfer scene
#
# Changelog
#   Created a seperate sprite for the cursor and made it animated -Max
#   Added the mapmaks windows, added a seperate scene for the soaring
#     point transitions -Max
#   Created a sepereate sprite for the itemname display and animated it to
#     phase between two messages -Max
#   Rewrote methods to only draw on scene initialization -Max
#   Added HUD display -Max
#   Added a pop up description when you press the A input (keyboard Z) -Max
#   Added arrangment customization using symbols instead of integers -Max
#   Added Dungeon Menu -Max
#   Added Pop Up Minimenu -Max
#
#==============================================================================

$nr_zelda_cms = true

module NR_Zelda_CMS
  
#==============================================================================
#  Customization
#==============================================================================
  #--------------------------------------------------------------------------
  #  Menu Customization
  # The menu's will loop from left to right as defined in the array. Not all 
  # menu's are necessary so rearrangeremove the menu's you don't need.
  # EG. Menus = [inventory, equipment, quest, save]
  #
  # The default menu's follow this format
  # Inventory = inventory
  # Equipment = equipment
  # Masks = mask
  # QuestStatus = quest
  # MapDungeon Map = map
  # Save = save
  #--------------------------------------------------------------------------
  Menus = [inventory, save, map, quest, equipment, mask]
  #--------------------------------------------------------------------------
  #  Cursor Customization
  #--------------------------------------------------------------------------
  CursorImage= 'Menu_Cursor'
  CursorSpeed = 5
  CursorMin = 20
  CursorMax = 30
  #--------------------------------------------------------------------------
  #  Font Customization
  #--------------------------------------------------------------------------
  ItemNameFont = 'T'
  MapFont = 'M'
  DescriptionFont = 'S'
  AmmoFont = 'HUD'
  KeyFont = 'HUD'
  FloorFont = 'S'
  #--------------------------------------------------------------------------
  #  Map Icon Customization
  #--------------------------------------------------------------------------
  MapIcon = 'hdrmapscreenoot_maplocationmark'
  SoaringIcon = 'hdrmapscreenoot_soaringmark'
  #--------------------------------------------------------------------------
  #  Description Customization
  #--------------------------------------------------------------------------
  #Location Format =   [X, Y, Width, Height] 
  DescriptionLocation = [80, 304, 480, 125]
  DescriptionWindowskin = 'Windowskin - PZE - Menu - Description'
  DescriptionInput = InputA
  #--------------------------------------------------------------------------
  #  Dungeon Customization
  #--------------------------------------------------------------------------
  #Icons
  PlayerBig = 'I_Dungeon_Link_Location'
  PlayerSmall = 'I_Dungeon_Link_Location_(Small)'
  MapBig = 'I_Dungeon_Map_Tan'
  MapSmall = 'I_Dungeon_Map_Tan_(Small)'
  CompassBig = 'I_Dungeon_Compass_Orange'
  CompassSmall = 'I_Dungeon_Compass_Orange_(Small)'
  BossKeyBig = 'I_Dungeon_Key_Big_Golden'
  BossKeySmall = 'I_Dungeon_Key_Big_Golden_(Small)'
  BossBig = 'I_Dungeon_Boss_Location'
  BossSmall = 'I_Dungeon_Boss_Location_(Small)'
  SomethingIcon = 'I_Dungeon_StoneSlab_Fragment'
  KeysIcon = 'I_Dungeon_Key_Small_Golden_Scr'
  #Location Format = [X, Y]
  MapLocation = [560, 125]
  CompassLocation = [560, 192]
  SomethingLocation = [560, 260]
  BossKeyLocation = [560, 325]
  KeysLocation = [565, 392]
  #Rectangle Format = [X, Y, Width, Height]
  DungeonRectangle = [127, 75, 383, 360]
  FloorsRectangle = [35, 95, 85, 320]
  #Colors Format = Color.new(Red, Green, Blue)
  Visited = Color.new(56,120,244)
  Unvisited = Color.new(124,129,137)
  Current = Color.new(0,192,255)
  Border = Color.new(56,56,56)
  Door = Color.new(255,255,255)
  FloorInner = Color.new(90,90,90)
  FloorOuter = Color.new(220,220,255)
  #--------------------------------------------------------------------------
  #  Position Customization
  #--------------------------------------------------------------------------
  # LastNext Page Toggle Positions ( [xLeft, yLeft], [xRight, yRight] )
  ToggleCoords = [ [20, 245], [618, 245] ]
  # Item Name Y Coordinate
  ItemNameY = 440        
  #--------------------------------------------------------------------------
  #  Quick Menu Input Customization
  #--------------------------------------------------------------------------
  InventoryInput = InputLETTERS['I']
  EquipmentInput = InputLETTERS['E']
  QuestStatusInput = InputLETTERS['J'] #J for journal
  MapInput = InputLETTERS['M']
  SaveInput = nil
  MaskInput = nil
  #--------------------------------------------------------------------------
  #  Sound Customization
  #--------------------------------------------------------------------------
  MenuVolume = 30
  # Sound Format = RPGAudioFile.new('Name', Volume, Pitch)
  OpenSound = RPGAudioFile.new('System - Menu - Open', 80, 100)
  CloseSound = RPGAudioFile.new('System - Menu - Close', 80, 100)
  ChangeScreenSound = RPGAudioFile.new('System - Menu - Change screen', 100, 100)
  #--------------------------------------------------------------------------
  #  Disabled Items Customization
  #--------------------------------------------------------------------------
  DisableAccessory = true
  DisabledOpacity = 100
  #Actor ID = [ID1, ID2, ID3...]
  DisabledActorItems = {
  #Deku Link
  13 = [4,5,7,8,9,10,11,12,13,14,15,16,18,19,21,22,24,25,26,27,28,30,39,40,
  42,44,45,50,52,54,56,58,60,62,63,64,65,67,68,70,71,72,74,75,76,78,84,91,97,102,104,
  106,107,108,110,114,115,116,123,127,128,129,131,132,133,135,137],
  #Zora Link
  14 = [4,5,7,8,9,10,11,12,13,14,15,16,18,19,21,22,24,25,26,27,28,30,39,40,
  42,44,45,50,52,54,56,58,60,62,63,64,65,67,68,70,71,72,74,75,76,78,84,91,97,102,104,
  106,107,108,110,114,115,116,123,127,128,129,131,132,133,135,137],
  #Goron Link
  15 = [4,5,7,8,9,10,11,12,13,14,15,16,18,19,21,22,24,25,26,27,28,30,39,40,
  42,44,45,50,52,54,56,58,60,62,63,64,65,67,68,70,71,72,74,75,76,78,84,91,97,102,104,
  106,107,108,110,114,115,116,123,127,128,129,131,132,133,135,137],
  } 
  #--------------------------------------------------------------------------
  #  Paper Doll Customization
  #--------------------------------------------------------------------------
  #Location Format = [X, Y]
  EquipmentPaperDoll = [203, 268]
  MasksPaperDoll = [128, 268]
  #ID = Image Name
  Weapon = {
  6 = 'Paperdoll - Weapon - Kokiri Sword',
  7 = 'Paperdoll - Weapon - Ordon Sword',
  12 = 'Paperdoll - Weapon - Master Sword',
  27 = 'Paperdoll - Weapon - Biggoron's Sword',
  }
  Shield = {
  6 = 'Paperdoll - Armor - Deku Shield',
  12 = 'Paperdoll - Armor - Hylian Shield',
  17 = 'Paperdoll - Armor - Mirror Shield',
  }
  Helmet = {
  
  }
  Body = {
  23 = 'Paperdoll - Body - Green',
  24 = 'Paperdoll - Body - Red',
  25 = 'Paperdoll - Body - Blue',
  27 = 'Paperdoll - Body - Green',
  28 = 'Paperdoll - Body - Red',
  29 = 'Paperdoll - Body - Blue',
  31 = 'Paperdoll - Body - Green',
  32 = 'Paperdoll - Body - Red',
  33 = 'Paperdoll - Body - Blue',
  171 = 'Paperdoll - Body - Deku',
  }
  #--------------------------------------------------------------------------
  #  Mini Menu Customization
  #--------------------------------------------------------------------------
  MiniMenuWindowskin = 'hdrinventoryscreenoot_minimenu'
  MiniMenuMaxRows = 3
  #Item ID = [[id1, icon1], [id2, icon2], [id3, icon3]...]
  MiniMenuItems = {
  32 = [[33,'I_Song_BalladOfTheWindFish'], [34,'I_Song_ManbosMamboSong'], [35,'I_Song_FrogsSongOfSoul']],
  97 = [[98,'I_Song_TuneOfEchoes'], [99,'I_Song_TuneOfCurrents'], [100,'I_Song_TuneOfAges']],
  78 = [[79,'I_Weapon_Seed_EmberSeed'], [80,'I_Weapon_Seed_MysterySeed'], [81,'I_Weapon_Seed_ScentSeed'], [82,'I_Weapon_Seed_PegasusSeed'], [83,'I_Weapon_Seed_GaleSeed']],
  84 = [[85,'I_Weapon_Seed_EmberSeed'], [86,'I_Weapon_Seed_MysterySeed'], [87,'I_Weapon_Seed_ScentSeed'], [88,'I_Weapon_Seed_PegasusSeed'], [89,'I_Weapon_Seed_GaleSeed']],
  } 
#==============================================================================
#  End of Customization
#==============================================================================
  
#==============================================================================
#  Dungeon
#------------------------------------------------------------------------------
#  A class which holds dungeon data
#==============================================================================

#--------------------------------------------------------------------------
#  Constants
#--------------------------------------------------------------------------
  Down = 0x01
  Left = 0x02
  Right = 0x04
  Up = 0x08
  Compass = 0x10
  Map = 0x20
  Key = 0x40
  Boss = 0x80

class Dungeon
  #--------------------------------------------------------------------------
  #  Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor maps
  attr_accessor data
  attr_accessor extras
  attr_accessor floor_names
  attr_accessor floors
  attr_accessor width
  attr_accessor height
  attr_accessor map
  attr_accessor compass
  attr_accessor key
  attr_accessor boss_key
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize(data)
    #initialize data
    @floors, @width, @height, @map, @compass, @key, @boss_key = data.shift
    @maps = Table.new(@floors, @width, @height)
    @data = Table.new(@floors, @width, @height)
    @floor_names = []
    @extras = []
    #read each floors data
    (0...@floors).each {floor (0...@width).each {x (0..@height).each {y
      #add the floor name if a floor name row
      if y == 0
        next if x != 0
        @floor_names  data[y + floor  (@height + 1)][0]
        next
      end
      #split each
      strings = data[y + floor  (@height + 1)][x].split('') rescue next
      #downcase all strings
      strings.each {string string.downcase!}
      #store the map id
      map = strings[0].to_i
      next if map == 0
      @maps[floor, x, y - 1] = map
      #store the data
      @data[floor, x, y - 1] = Down if strings.include('down')
      @data[floor, x, y - 1] = Left if strings.include('left')
      @data[floor, x, y - 1] = Right if strings.include('right')
      @data[floor, x, y - 1] = Up if strings.include('up')
      @data[floor, x, y - 1] = Compass if strings.include('compass')
      @data[floor, x, y - 1] = Map if strings.include('map')
      @data[floor, x, y - 1] = Key if strings.include('key')
      @data[floor, x, y - 1] = Boss if strings.include('boss')
    }}}
    #load all the extra data
    ((@floors  (@height + 1))...data.size).each {i @extras  data[i]}
  end
  #--------------------------------------------------------------------------
  #  Include Map
  #--------------------------------------------------------------------------
  def include_map(map_id)
    @maps.xsize.times {floor @maps.ysize.times {x @maps.zsize.times {y
      return true if @maps[floor, x, y] == map_id
    }}}
    return false
  end
  #--------------------------------------------------------------------------
  #  Floor Include Map
  #--------------------------------------------------------------------------
  def floor_include_map(floor, map_id)
    @maps.ysize.times {x @maps.zsize.times {y
      return true if @maps[floor, x, y] == map_id
    }}
    return false
  end
  #--------------------------------------------------------------------------
  #  Current Floor
  #--------------------------------------------------------------------------
  def current_floor
    @maps.xsize.times {floor @maps.ysize.times {x @maps.zsize.times {y
      return floor if @maps[floor, x, y] == $game_map.map_id
    }}}
    return 0 
  end
  #--------------------------------------------------------------------------
  #  Boss Floor
  #--------------------------------------------------------------------------
  def boss_floor
    @data.xsize.times {floor @data.ysize.times {x @data.zsize.times {y
      return floor if @data[floor, x, y] & Boss == Boss
    }}}
    return nil
  end
end

  # Format the csv file to a rxdata file
  def self.formatData(inputData, types)
    # Store the broken up strings in an array
    output_s = []
    # Store the actual output in an array
    output = []
    # Break up each line
    strings = inputData.split(n)
    # Break up at each comma or t
    strings.each { line output_s  line.split((t),)}
    # Delete the metadata (the first row)
    output_s.delete_at(0)
    # Loop through each line in the output
    for line in output_s
      # Store the output in an array
      line_data = []
      # Loop through each item in the line
      for i in 0...line.size
        # Store the data in the appropriate form
        case types[i]
        when str
          line_data  line[i].to_s
        when int
          line_data  line[i].to_i
        when comm
          next
        when sym
          line_data  line[i].to_sym
        when bool
          line_data  ((line[i] =~ [Tt].) != nil)
        end
      end
      output  line_data
    end
    return output
  end
  # Format the csv file to a rxdata file
  def self.formatDungeon(inputData)
    # Store the broken up strings in an array
    output_s = []
    # Store the actual output in an array
    output = []
    # Break up each line
    strings = inputData.split(n)
    # Break up at each comma or t
    strings.each { line output_s  line.split((t),)}
    # Delete the metadata (the first row)
    output_s.delete_at(0)
    # Collect the map data row
    output  output_s.shift
    # Convert data into integers
    output[0].each_index {i output[0][i] = output[0][i].to_i}
    # Delete the other metadata row (after the dungeon floors)
    output_s.delete_at(output[0][0]  (output[0][2] + 1))
    # Loop through each line in the output
    output_s.each do line
      # Store the output in an array
      line_data = []
      # Add each floor line to the output
      line.each {i line_data  i.to_s}
      # Add the array to the output
      output  line_data
    end
    # Return the formatted output
    return output
  end
  
  # If the designer is testing, then relaod the inventory, etc csv data.
  if $DEBUG
    # Have a default setup for the menu screens with items
    ItemsFormat = [comm, sym, str, int, int, int, int, int]
    # Loading the Inventory.csv, and save as a rxdata file
    file = File.open(DataMenuSetupInventory.csv, r)     # Load
    inventory = self.formatData(file.read, ItemsFormat)       # Convert
    save_data(inventory, DataMenuSetupInventory.rxdata)   # Save
    file.close                                                # Close
    # Loading the Equipment.csv, and save as a rxdata file
    file = File.open(DataMenuSetupEquipment.csv, r)     # Load
    equipment = self.formatData(file.read, ItemsFormat)       # Convert
    save_data(equipment, DataMenuSetupEquipment.rxdata)   # Save
    file.close                                                # Close
    # Loading the QuestStatus.csv, and save as a rxdata file
    file = File.open(DataMenuSetupQuestStatus.csv, r)   # Load
    equipment = self.formatData(file.read, ItemsFormat)       # Convert
    save_data(equipment, DataMenuSetupQuestStatus.rxdata) # Save
    file.close                                                # Close
    # Loading the Masks.csv, and save as a rxdata file
    file = File.open(DataMenuSetupMasks.csv, r)         # Load
    masks = self.formatData(file.read, ItemsFormat)           # Convert
    save_data(masks, DataMenuSetupMasks.rxdata)           # Save
    file.close                                                # Close
    # Loading the Maps.csv, and save as a rxdata file
    file = File.open(DataMenuSetupMaps.csv, r)          # Load
    MapsFormat = [str, int, int, int, str, str]         # The format
    maps = self.formatData(file.read, MapsFormat)             # Convert
    save_data(maps, DataMenuSetupMaps.rxdata)             # Save
    file.close                                                # Close
    # Load Dungeon Maps
    dungeons = {}
    Dir.entries('DataMenuSetup').each do entry
      name = File.basename(entry, '.csv')
      if File.extname(entry) == '.csv' && 
         !['Inventory','Equipment','QuestStatus','Masks','Maps'].include(name)
        file = File.open(DataMenuSetup#{name}.csv)
        dungeons[name] = Dungeon.new(self.formatDungeon(file.read))
        file.close
      end
    end
    save_data(dungeons, DataMenuSetupDungeons.rxdata)
  end
  
  # Make the data for the CMS available
  InventoryData   = load_data(DataMenuSetupInventory.rxdata)
  EquipmentData   = load_data(DataMenuSetupEquipment.rxdata)
  QuestStatusData = load_data(DataMenuSetupQuestStatus.rxdata)
  MasksData       = load_data(DataMenuSetupMasks.rxdata)
  MapsData        = load_data(DataMenuSetupMaps.rxdata)
  DungeonsData    = load_data(DataMenuSetupDungeons.rxdata)
end

#==============================================================================
#  Game_Temp
#------------------------------------------------------------------------------
#  Added Temp Data for the soaring point
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  #  Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor soaring_key
  #--------------------------------------------------------------------------
  #  Aliases
  #--------------------------------------------------------------------------
  alias max_zcms_initialize_later initialize
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    max_zcms_initialize_later
    @soaring_key = ''
  end
end

#==============================================================================
#  Game_System
#------------------------------------------------------------------------------
#  Added Save Data for the maps visited
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  #  Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor maps_visited
  attr_reader playing_bgm
  attr_reader playing_bgs
  #--------------------------------------------------------------------------
  #  Aliases
  #--------------------------------------------------------------------------
  alias max_zcms_initialize_later initialize
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    max_zcms_initialize_later
    @maps_visited = []
  end
end

#==============================================================================
#  Game_Party
#------------------------------------------------------------------------------
#  Made the item, weapon and armor hash readable
#==============================================================================

class Game_Party
  attr_reader items
  attr_reader weapons
  attr_reader armors
end

#==============================================================================
#  Game_Map
#------------------------------------------------------------------------------
#  Added function to store the maps visited
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  #  Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader dungeon_name
  #--------------------------------------------------------------------------
  #  Aliases
  #--------------------------------------------------------------------------
  alias max_zcms_setup_later setup
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def setup(args)
    max_zcms_setup_later(args)
    #Store the map id in the maps visited array
    $game_system.maps_visited = [@map_id]
    #Loop through each dungeon
    NR_Zelda_CMSDungeonsData.each do key, dungeon
      #if the dungeon includes the current map id
      if dungeon.include_map(@map_id)
        #set the dungeon name
        @dungeon_name = key
        break
      end
      #if no dungeon is found clear the name
      @dungeon_name = ''
    end
  end
end

#==============================================================================
#  Sprite_ZeldaCMS_Cursor
#------------------------------------------------------------------------------
#  The animated cursor
#==============================================================================

class Sprite_ZeldaCMS_Cursor
  #--------------------------------------------------------------------------
  #  Include Modules
  #--------------------------------------------------------------------------
  include NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    #create an arry for the sprite
    @sprites = []
    #create each sprite
    4.times do
      sprite = Sprite.new
      sprite.z = 10000000
      sprite.bitmap = RPGCache.windowskin(CursorImage)
      sprite.color.set(255,255,255,0)
      @sprites  sprite
    end
    #get the widthheight
    @width = @sprites[0].bitmap.width  2
    @height = @sprites[0].bitmap.height  2
    @count = 0
    @min = CursorMin
    @max = CursorMax
    update
  end
  #--------------------------------------------------------------------------
  #  Location
  #--------------------------------------------------------------------------
  def location
    return @sprites[0].x, @sprites[0].y
  end
  #--------------------------------------------------------------------------
  #  X
  #--------------------------------------------------------------------------
  def x=(x)
    @sprites.each {sprite sprite.x = x - @width}
  end
  #--------------------------------------------------------------------------
  #  Y
  #--------------------------------------------------------------------------
  def y=(y)
    @sprites.each {sprite sprite.y = y - @height}
  end
  #--------------------------------------------------------------------------
  #  Visible
  #--------------------------------------------------------------------------
  def visible=(bool)
    @sprites.each{sprite sprite.visible = bool}
  end
  #--------------------------------------------------------------------------
  #  Dispose
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each{sprite sprite.dispose}
  end
  #--------------------------------------------------------------------------
  #  Frame Update
  #--------------------------------------------------------------------------
  def update
    #update the count
    @count = (@count + CursorSpeed) % 360
    #get the sincos wave
    sin = Math.sin(@count  MathPI  180)
    cos = Math.cos(@count  MathPI  180)
    #get the offset
    offset = @min + (@max - @min)  2 + (@max - @min)  2  sin
    #update each sprites offset
    @sprites[0].ox = sin  offset
    @sprites[0].oy = cos  -offset
    @sprites[1].ox = sin  -offset
    @sprites[1].oy = cos  offset
    @sprites[2].ox = cos  offset
    @sprites[2].oy = sin  offset
    @sprites[3].ox = cos  -offset
    @sprites[3].oy = sin  -offset
    #update the glow effect
    alpha = (0.5 + sin)  100
    @sprites.each {sprite sprite.color.alpha = alpha}
  end
end

#==============================================================================
#  Sprite_ZeldaCMS_ItemName
#------------------------------------------------------------------------------
#  The animated item name
#==============================================================================

class Sprite_ZeldaCMS_ItemName  Sprite
  #--------------------------------------------------------------------------
  #  Include Modules
  #--------------------------------------------------------------------------
  include NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    #setup the bitmap
    self.bitmap = Bitmap.new(640,32)
    self.bitmap.font.name = ItemNameFont
    self.bitmap.font.size = 25
    #setup the second sprite
    @content = Sprite.new
    @content.bitmap = self.bitmap.clone
    @content.opacity = 0
    #move into place
    self.y, self.z = ItemNameY, 10000000
    #initilize text and count
    @text = @text2 = ''
    @count = 0
  end
  #--------------------------------------------------------------------------
  #  X
  #--------------------------------------------------------------------------
  def x=(x)
    super(x)
    @content.x = x
  end
  #--------------------------------------------------------------------------
  #  Y
  #--------------------------------------------------------------------------
  def y=(y)
    super(y)
    @content.y = y
  end
  #--------------------------------------------------------------------------
  #  Z
  #--------------------------------------------------------------------------
  def z=(z)
    super(z)
    @content.z = z
  end
  #--------------------------------------------------------------------------
  #  Visible
  #--------------------------------------------------------------------------
  def visible=(bool)
    super(bool)
    @content.visible = bool
  end
  #--------------------------------------------------------------------------
  #  Text
  #--------------------------------------------------------------------------
  def text=(text)
    #memorize the text
    @text = text
    #draw the content
    self.bitmap.clear
    self.bitmap.draw_text(0, 0, 640, 32, text, 1)
    #reset opacity and count
    self.opacity = 255
    @content.opacity = 0
    @count = 0
  end
  #--------------------------------------------------------------------------
  #  Text2
  #--------------------------------------------------------------------------
  def text2=(text)
    #memorize the text
    @text2 = text
    #draw the content
    @content.bitmap.clear
    @content.bitmap.draw_text(0, 0, 640, 32, text, 1)
  end
  #--------------------------------------------------------------------------
  #  Dispose
  #--------------------------------------------------------------------------
  def dispose
    #dispose all bitmaps and sprites
    @content.bitmap.dispose
    @content.dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  #  Frame Update
  #--------------------------------------------------------------------------
  def update
    #skip if text1 does not exist
    return if @text == ''
    #if text2 doesn't exist
    if @text2 == ''
      #reset everything and return
      @count = 0
      self.opacity = 255
      @content.opacity = 0
      return
    end
    #update the count
    @count += 1
    @count = 0 if @count == 200
    #fade out to second text
    if @count.between(70,100)
      self.opacity -= 10
      @content.opacity += 10
    #fade back to first text
    elsif @count.between(170,200)
      self.opacity += 10
      @content.opacity -= 10
    end
  end
end

#==============================================================================
#  Sprite_ZeldaCMS_Minimenu
#------------------------------------------------------------------------------
#  The pop up mini menu displayed for items with multiple options
#==============================================================================

class Sprite_ZeldaCMS_Minimenu  Sprite
  #--------------------------------------------------------------------------
  #  Include Modules
  #--------------------------------------------------------------------------
  include NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize(items, cursor)
    #run the super method
    super()
    self.z = 9999999
    #initialize instance variables
    @cursor = cursor
    @items = items
    @index = 0
    #get the rows and columns
    @rows = [@items.size, MiniMenuMaxRows].min
    @columns = (@items.size - 1)  MiniMenuMaxRows + 1
    #determine the width and height
    width = @columns  32
    height = @rows  32
    #get the windowskin
    windowskin = RPGCache.windowskin(MiniMenuWindowskin)
    #create the bitmap
    self.bitmap = Bitmap.new(width, height)
    #draw corners
    self.bitmap.blt(0, 0, windowskin, Rect.new(0, 0, 7, 7))
    self.bitmap.blt(width - 7, 0, windowskin, Rect.new(25, 0, 7, 7))
    self.bitmap.blt(0, height - 7, windowskin, Rect.new(0, 25, 7, 7))
    self.bitmap.blt(width - 7, height - 7, windowskin, Rect.new(25, 25, 7, 7))
    #stretch sides
    dest = Rect.new(0, 7, 7, height - 14)
    self.bitmap.stretch_blt(dest, windowskin, Rect.new(0, 7, 7, 18))
    dest.set(7, 0, width - 14, 7)
    self.bitmap.stretch_blt(dest, windowskin, Rect.new(7, 0, 18, 7))
    dest.set(width - 7, 7, 7, height - 14)
    self.bitmap.stretch_blt(dest, windowskin, Rect.new(25, 7, 7, 18))
    dest.set(7, height - 7, width - 14, 7)
    self.bitmap.stretch_blt(dest, windowskin, Rect.new(7, 25, 18, 7))
    #stretch center
    dest.set(7, 7, width - 14, height - 14)
    self.bitmap.stretch_blt(dest, windowskin, Rect.new(7, 7, 18, 18))
    #draw the items
    @items.each_with_index do item, i
      icon = RPGCache.icon(item[1])
      x = i  @rows  32 + 16 - icon.width  2
      y = i % @rows  32 + 16 - icon.height  2
      self.bitmap.blt(x, y, icon, icon.rect)
    end
  end
  #--------------------------------------------------------------------------
  #  Dispose
  #--------------------------------------------------------------------------
  def dispose
    #dispose the bitmap aswell
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  #  Update
  #--------------------------------------------------------------------------
  def update
    #update the cursor
    @cursor.update
    #get current cursor position
    location = @cursor.location
    if Input.repeat(InputDOWN) #move down
      @index += 1 if @index + 1  @items.size && (@index + 1) % @rows != 0
    elsif Input.repeat(InputUP) #move up
      @index -= 1 if @index - 1 = 0 && (@index - 1) % @rows != @rows - 1
    elsif Input.repeat(InputRIGHT) #move right
      @index += @rows if @index + @rows  @items.size && @index + @rows
    elsif Input.repeat(InputLEFT) #move left
      @index -= @rows if @index - @rows = 0
    end
    #move the cursor into position
    @cursor.x = self.x + @index  @rows  32 + 16
    @cursor.y = self.y + @index % @rows  32 + 16
    #if the cursor has moved play the sound effect
    $game_system.se_play($data_system.cursor_se) if @cursor.location != location
  end
  #--------------------------------------------------------------------------
  #  Item
  #--------------------------------------------------------------------------
  def item
    #return the item at the current index
    return $data_items[@items[@index][0]]
  end
end

#==============================================================================
#  Window_ZeldaCMS_Description
#------------------------------------------------------------------------------
#  Displays the pop up itemweapon description
#==============================================================================

class Window_ZeldaCMS_Description  Window_Base
  #--------------------------------------------------------------------------   
  #  Include Modules
  #--------------------------------------------------------------------------
  include NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize(name, description)
    #get the name and description
    #setup the window
    super(DescriptionLocation)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = DescriptionFont
    self.windowskin = RPGCache.windowskin(DescriptionWindowskin)
    self.contents_opacity = 0
    self.opacity = 0
    self.z = 10000000
    #draw the item name
    self.contents.font.color = Color.new(218,83,56)
    self.contents.draw_text(4, 0, width - 40, 32, name) 
    self.contents.font.color = Font.default_color
    #split the description into seperate words
    description = description.split(' ')
    #initialize the current line of text
    text = description.shift
    #initialize which line you are on
    line = 1
    #loop for each word
    description.each_with_index do word, i
      #if the current line of text + word exceeds the window
      if self.contents.text_size(#{text} #{word}).width  width - 40
        #draw the current line of text
        self.contents.draw_text(4, line  32, width - 40, 32, text)
        #increment the line
        line += 1
        #reset the current line of text
        text = word
      else 
        #else add the word to the text
        text = #{text} #{word}
      end
      #draw the last line if needed
      if i = description.size - 1
        self.contents.draw_text(4, line  32, width - 40, 32, text)
      end
    end
  end
  #--------------------------------------------------------------------------
  #  Dispose
  #--------------------------------------------------------------------------
  def dispose
    #dispose the content aswell
    self.contents.dispose
    super
  end
end

#==============================================================================
#  Window_NR_Zelda_CMS
#------------------------------------------------------------------------------
#  The base for the CMS Windows
#==============================================================================

class Window_NR_Zelda_CMS  Window_Base
  #--------------------------------------------------------------------------
  #  Include Modules
  #--------------------------------------------------------------------------
  include NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader symbol
  attr_reader waiting
  #--------------------------------------------------------------------------
  #  Class Variables
  #--------------------------------------------------------------------------
  @@last_indicies = {}
  #--------------------------------------------------------------------------
  #  Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(-16, -16, 672, 512)
    self.z = 999999
    # Recall the index from the last time the inventory was called
    @index = @@last_indicies[self.class.to_s].to_i
    # Draw the bitmap
    self.contents = Bitmap.new(width - 32, height - 32)
    # Hide the window background
    self.opacity = 0
    # Create the cursor
    @cursor = Sprite_ZeldaCMS_Cursor.new
    # Create the item name sprite
    @itemname = Sprite_ZeldaCMS_ItemName.new
    #initialize waiting flag
    @waiting = false
    # Refresh, defined by subclasses
    refresh
  end
  #--------------------------------------------------------------------------
  #  Draw the Background for the window
  #--------------------------------------------------------------------------
  def draw_background(windowskin)
    self.contents.clear
    bitmap = RPGCache.windowskin(windowskin)
    self.contents.blt(0, 0, bitmap, bitmap.rect)
  end
  #--------------------------------------------------------------------------
  #  Reload the items being shown
  #--------------------------------------------------------------------------
  def reload_data(inputData)
    # Initialise the list of items being shown, the coordinates to show
    # them at, and what do do if the item is selected.
    @items = [ ]
    @xy_pos = [ ]
    @selected_data = []
    # Check the inputData, when it is items
    # Read the items input
    for data in inputData
      # If there is already an item at the XY position
      if @xy_pos.include(data[2..3])
        # Get the array's index where the item exists
        index = @xy_pos.index(data[2..3])
        # Delete the alraeady existing item
        @items.delete_at(index)
        @xy_pos.delete_at(index)
        @selected_data.delete_at(index)
      end
      case data[0]
      when item
        @items  $data_items[eval(data[1]).to_i]
      when weapon
        @items  $data_weapons[eval(data[1]).to_i]
      when armor
        @items  $data_armors[eval(data[1]).to_i]
      when sym
        @items  data[1]
      else
        raise('Sorry, the item type ' + data[0].to_s + ' is not recognised')
      end
      # Store the x & y for the items separately (for speed)
      @xy_pos  data[2..3]
      # Store what to do with the item if selected
      @selected_data  data[4..5]
    end
    # Add the toggles
    @items += [ left_toggle, right_toggle ]
    @xy_pos += ToggleCoords
    # Draw the data, item name and move the cursor
    draw_data
    draw_item_name
    @cursor.x, @cursor.y = @xy_pos[@index][0], @xy_pos[@index][1]
  end
  #--------------------------------------------------------------------------
  #  Draw the Items for the window
  #--------------------------------------------------------------------------
  def draw_data
    self.contents.font.name = AmmoFont
    # Loop through every item
    for i in 0...[@items.size, @xy_pos.size].min
      # Skip drawing the icon if the item is diabled
      next if item_disabled(i)
      next if not @items[i].methods.include( 'icon_name' )
      # Get the bitmap
      bitmap = RPGCache.icon(@items[i].icon_name)
      # If COG - Extra Frames is being used
      if defined(COG_ExtraFrames)
        # If the icon name includes the regexp, restrict to the first frame
        if @items[i].icon_name[COG_ExtraFramesREGEXP]
          rect = Rect.new(0, 0, bitmap.width  $1.to_i, bitmap.height)
        # If it's a normal item, use its size
        else
          rect = bitmap.rect
        end
      else
        # Make the graphic's size the icon's size
        rect = bitmap.rect
      end
      x, y = @xy_pos[i][0] - rect.width  2, @xy_pos[i][1] - rect.height  2
      #set opacity depending on whether the item is usable
      opacity = (item_usable(@items[i])  255  DisabledOpacity)
      # copy the bitmap onto the window
      self.contents.blt(x, y, bitmap, rect, opacity)
      #if the data is an item
      if @items[i].is_a(RPGItem)
        #get the id of the consumable used by the item
        id = XASITEM_COST[XASXASITEM_ID[@items[i].id]] rescue next
        #skip if there is no consumable
        next if id.nil
        #get the amount of that item
        ammount = $game_party.item_number(id)
        #check if the amount is capped
        if defined(ZeldaHUD_Customization) && 
           !ZeldaHUD_CustomizationItemCapVar[id].nil
          value = $game_variables[ZeldaHUD_CustomizationItemCapVar[id]]
          cap = (ammount == value)
        else
          cap = (ammount == 99)
        end
        #get the font color
        color = cap  Color.new(0,255,0,opacity)  Color.new(255,255,255,opacity)
        self.contents.font.color = color
        #draw the ammount of the consumable
        self.contents.draw_text(x, y + 16, bitmap.width,
                                bitmap.height, ammount.to_s, 0)
      end
    end
    #Reset the font details
    self.contents.font.name = Font.default_name
    self.contents.font.color = Font.default_color
  end
  #--------------------------------------------------------------------------
  #  Move Cursor
  #--------------------------------------------------------------------------
	def move_cursor
    #play the sound effect
    $game_system.se_play($data_system.cursor_se)
    #move the cursor
		@cursor.x, @cursor.y = @xy_pos[@index][0], @xy_pos[@index][1]
	end
  #--------------------------------------------------------------------------
  #  Draw Item Name
  #--------------------------------------------------------------------------
  def draw_item_name
    # If the item isn't disable and the item includes the method 'name'
    if !item_disabled(@index) && @items[@index].methods.include('name')
      # set the item name
      @itemname.text = @items[@index].name
    else
      @itemname.text = ''
    end
  end
  #--------------------------------------------------------------------------
	#  Frame Update
	#--------------------------------------------------------------------------
	def update
		# Call Window_Base's update
		super
		# If the window is active
		if self.active
      # Update the cursor
      @cursor.update
      # Update the item name
      @itemname.update
      # Initialize variables for the weightings on the vertical and horizontal
      # directions
			wv, wh = 0, 0
      # The weightings for the secondary and primary axis relative to input
			w1, w2 = 1, 2
      # Initialize a variable for the direction and get the direction
      # pressed by the user
      input_dir = 0
      input_dir = 2 if Input.repeat(InputDOWN)
      input_dir = 4 if Input.repeat(InputLEFT)
      input_dir = 6 if Input.repeat(InputRIGHT)
      input_dir = 8 if Input.repeat(InputUP)
      # Do nothing if no button was pressed
      return if input_dir == 0
      #get the item
      item = self.item
      #if the item is left toggle and the input direction is left
      if item == left_toggle && input_dir == 4
        #move to the left window
        return $scene.move_window(6)
      #elsif the item is right toggle and the input direction is right
      elsif item == right_toggle && input_dir == 6
        #move to the right window
        return $scene.move_window(4) 
      end
      # Setup the weightings for each direction
			if  (input_dir == 2 or input_dir == 8)
				wv, wh = w1, w2
			elsif (input_dir == 4 or input_dir == 6)
				wv, wh = w2, w1
			end
      # Get the xy position of the current item
			cxy = @xy_pos[@index]
      # Create default value for the closest item's distance (absurdly large)
      closest_index = -1
			closest_distance = 9999999
      # Loop through every item
			for i in 0...@xy_pos.size
				# Skip if it is the old item or is in the opposite direction
				if @index == i or
				   (input_dir == 2 and @xy_pos[i][1]  cxy[1]) or
				   (input_dir == 4 and @xy_pos[i][0]  cxy[0]) or
				   (input_dir == 6 and @xy_pos[i][0]  cxy[0]) or
				   (input_dir == 8 and @xy_pos[i][1]  cxy[1])
					next
				end
        # Get the distance from the last highlighted item to this tested one
				dist_h = (@xy_pos[i][0] - cxy[0]).abs
				dist_v = (@xy_pos[i][1] - cxy[1]).abs
        # If it is really against the primary axis
        if (wh == w1 and w2  dist_h  dist_v) or
            (wv == w1 and w2  dist_v  dist_h)
          next
        end
        # Get the distance multiplied with their weightings
				dist = dist_h  wh + dist_v  wv
        # Set at closest item if appropriate
				if (dist  closest_distance)
					closest_distance = dist
					closest_index = i
				end
			end
      # Do nothing if nothin was selected
      return if closest_index == -1
      @index = closest_index
      #move cursor
      move_cursor
      #draw the item name
      draw_item_name
		end
	end
  #--------------------------------------------------------------------------
  #  Item Disabled
  #--------------------------------------------------------------------------
  def item_disabled(index)
    # For the item in question, it is disabled if the player doesn't have one.
    case @items[index]
    when RPGItem          # If it is an item
      return true if $game_party.item_number(@items[index].id) == 0
      return true if not ((1..($data_items.size-1)).include(@items[index].id))
    when RPGWeapon        # If it is a weapon
      $game_party.actors.each { actor return false if actor.weapon_id == @items[index].id }
      return true if $game_party.weapon_number(@items[index].id) == 0
      return true if not (1..($data_weapons.size-1)).include(@items[index].id)
    when RPGArmor         # If it is an armor
      return true if $game_party.armor_number(@items[index].id) == 0
      return true if not (1..($data_armors.size-1)).include(@items[index].id)
    # If it's a toggle for the nexlast page
    when left_toggle, right_toggle
      return false
    # If it's none of the above, it's unusable
    else
      return true
    end
    # It passes all the tests
    return false
  end
  #--------------------------------------------------------------------------
  #  Item Usable
  #--------------------------------------------------------------------------
  def item_usable(item)
    #get the actor
    actor = $game_party.actors[0]
    #return false if there is no actor
    return false if actor.nil
    #if it is an item
    if item.is_a(RPGItem)
      #get the list of disabled items
      items = DisabledActorItems[actor.id]
      #return true if there is no disabled item list
      return true if items == nil
      #return false if the list include the item id
      return false if items.include(item.id)
    elsif item.is_a(RPGWeapon)  item.is_a(RPGArmor)
      #return false if the weapon or armor isn't equippable
      return false if !actor.equippable(item)
    end
    #return true if other
    return true
  end
  #--------------------------------------------------------------------------
  #  Item Highlighted
  #--------------------------------------------------------------------------
  def item
    # If the item is disabled
    if item_disabled(@index)
      # Return nil
      return nil
    # If the item is available
    else
      return @items[@index]
    end
  end
  #--------------------------------------------------------------------------
  #  Select Highlighted Item
  #--------------------------------------------------------------------------
  def select_item
    # Get the item to be selected
    item = self.item
    # Do nothing if the item doesn't exist or isn't usable
    if item.nil  !item_usable(item)
      return $game_system.se_play($data_system.buzzer_se)
    end
    # Get the data on the item (and its group)
    selected_switchID, selected_group= @selected_data[@index]
    # Loop through every item in the selected_data
    for (switchID, group) in @selected_data
      # If the item is in the same group
      if group == selected_group
        # Turn the switch off
        $game_switches[switchID] = false
      end
    end
    # Activate the switch
    $game_switches[@selected_data[@index][0]] = true
    # If the item is an item
    case item
    when RPGItem
      use_item(item)
    when RPGWeapon, RPGArmor
      equip_item(item)
    else
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
    end
  end
  #--------------------------------------------------------------------------
  #  Use Item
  #--------------------------------------------------------------------------
  def use_item(item)
    # Store the item
    @item = item
    # If it can't be used
    unless $game_party.item_can_use(@item.id)
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # If effect scope is an ally
    if @item.scope = 3
      # If target is all
      if @item.scope == 4  @item.scope == 6
        # Apply item effects to entire party
        used = false
        for i in $game_party.actors
          used = i.item_effect(@item)
        end
      else
        # Apply item use effects to target actor
        used = $game_party.actors[0].target.item_effect(@item)
      end
      # If an item was used
      if used
        # Play item use SE
        $game_system.se_play(@item.menu_se)
        # If consumable
        if @item.consumable
          # Decrease used items by 1
          $game_party.lose_item(@item.id, 1)
          # Redraw item window item
          refresh
        end
        # If all party members are dead
        if $game_party.all_dead
          # Switch to game over screen
          $scene = Scene_Gameover.new
          return
        end
        # If common event ID is valid
        if @item.common_event_id  0
          # Common event call reservation
          $game_temp.common_event_id = @item.common_event_id
          # Switch to map screen
          $scene = Scene_Map.new
          return
        end
      else
      # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
      end
    # If effect scope is other than an ally
    else
      # If command event ID is valid
      if @item.common_event_id  0
        # Command event call reservation
        $game_temp.common_event_id = @item.common_event_id
        # Play item use SE
        $game_system.se_play(@item.menu_se)
        # If consumable
        if @item.consumable
          # Decrease used items by 1
          $game_party.lose_item(@item.id, 1)
          refresh
        end
        # Switch to map screen
        $scene = Scene_Map.new
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  #  Equip Item
  #--------------------------------------------------------------------------
  def equip_item(item)
    # Do nothing if there's no actor or weapon isn't equippable
    if $game_party.actors.empty
      # Play buzzer SE
      return $game_system.se_play($data_system.buzzer_se)
    end
    # Play equip SE
    $game_system.se_play($data_system.equip_se)
    type = item.is_a(RPGWeapon)  0  item.kind + 1
    id = item.id
    #equip the item
    $game_party.actors[0].equip(type, id)
  end
  #--------------------------------------------------------------------------
  #  Get Description
  #--------------------------------------------------------------------------
  def get_description
    #get the item
    item = self.item
    #return if the item doesn't have a name
    return nil unless item.methods.include('name')
    #return if the item doesn't have a description
    return nil unless item.methods.include('description')
    #return if the description is empty
    return nil if item.description == ''
    #return the name and description
    return item.name, item.description
  end
  #--------------------------------------------------------------------------
  #  Draw_Paper_Doll
  #--------------------------------------------------------------------------
  def draw_paper_doll(x, y)
    #get the actor
    actor = $game_party.actors[0]
    #return if the actor doesn't exist
    return if actor.nil
    #draw the body
    body = Body[actor.armor3_id]
    unless body.nil
      bitmap = RPGCache.windowskin(body)
      width, height = bitmap.width  2, bitmap.height  2
      self.contents.blt(x - width, y - height, bitmap, bitmap.rect)
    end
    #draw the weapon
    weapon = Weapon[actor.weapon_id]
    unless weapon.nil
      bitmap = RPGCache.windowskin(weapon)
      width, height = bitmap.width  2, bitmap.height  2
      self.contents.blt(x - width, y - height, bitmap, bitmap.rect)
    end
    #draw the helmet
    helmet = Helmet[actor.armor2_id]
    unless helmet.nil
      bitmap = RPGCache.windowskin(helmet)
      width, height = bitmap.width  2, bitmap.height  2
      self.contents.blt(x - width, y - height, bitmap, bitmap.rect)
    end
    #draw the shield
    shield = Shield[actor.armor1_id]
    unless shield.nil
      bitmap = RPGCache.windowskin(shield)
      width, height = bitmap.width  2, bitmap.height  2
      self.contents.blt(x - width, y - height, bitmap, bitmap.rect)
    end
  end
  #--------------------------------------------------------------------------
  #  Set X
  #--------------------------------------------------------------------------
  def x=(x)
    super(x) 
    #if you can move the cursor
    unless @cursor.nil  @xy_pos.empty
      #move the cursor
      @cursor.x = @xy_pos[@index][0] + x + 16 
    end
    #move the itemname
    @itemname.x = x + 16 unless @itemname.nil
  end
  #--------------------------------------------------------------------------
  #  Set Y
  #--------------------------------------------------------------------------
  def y=(y)
    super(y)
    #if you can move the cursor
    unless @cursor.nil  @xy_pos.empty
      #move the cursor
      @cursor.y = @xy_pos[@index][1] + y + 16
    end
    #move the itemname
    @itemname.y = ItemNameY + y + 16 unless @itemname.nil
  end
  #--------------------------------------------------------------------------
  #  Visible
  #--------------------------------------------------------------------------
  def visible=(bool)
    super(bool)
    #change the visibillity of the cursor
    @cursor.visible = bool
    #change the visibillity of the itemname
    @itemname.visible = bool
  end
  #--------------------------------------------------------------------------
  #  Dispose
  #--------------------------------------------------------------------------
  def dispose
    # Backup the last item highlighted
    @@last_indicies[self.class.to_s] = @index
    #dispose cursor
    @cursor.dispose
    #dispose the itemname
    @itemname.dispose
    #dispose content
    self.contents.dispose
    # Run the original dispose
    super
  end
end



#==============================================================================
#  Window_Inventory
#------------------------------------------------------------------------------
#  This window is designed to show the inventory window of the pause menu.
#==============================================================================

class Window_Inventory  Window_NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = inventory
  end    
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrinventoryscreenoot (in Windowskins folder)
    draw_background('hdrinventoryscreenoot')
    # Load the rxdata file called InventoryData
    reload_data(InventoryData)
  end
  #--------------------------------------------------------------------------
  #  draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name
    super
    # If the item isn't disable and the item includes the method 'name'
    if !item_usable(@index) && !@items[@index].is_a(Symbol)
      # If input script exists
      if $max_input
        l = Input.string(XAS_COMMANDITEM_ACTION[0])
        u = Input.string(XAS_COMMANDITEM_ACTION[1])
        r = Input.string(XAS_COMMANDITEM_ACTION[2])
        @itemname.text2 = Press #{l}, #{u} or #{r} to equip
      else
        @itemname.text2 = 'Press A, S or D to equip'
      end
    else
      @itemname.text2 = ''
    end
  end
  #--------------------------------------------------------------------------
  #  Select Highlighted Item
  #--------------------------------------------------------------------------
  def select_item(selection_type = nil)
    # Only run the super if XAS is absent
    return super() if $xrxs_xas != true
    item = self.item
    # If the selection type was nil or the highlighted object was not an item
    if (!selection_type.is_a(Integer)  !item.is_a(RPGItem) 
        !item_usable(item)) && !MiniMenuItems.include(item.id) 
      # Play buzzer SE
      return $game_system.se_play($data_system.buzzer_se)
    end
    #check for minimenu
    item, selection_type = minimenu_check(item, selection_type)
    #return if there is no longer an item
    return if item.nil
    # Set the item
    item_tool_id = XASXASITEM_ID[item.id]
    if item_tool_id != nil
      $game_system.se_play($data_system.equip_se)
      #swap if possible
      index = $game_system.xas_item_id.index(item.id)
      unless index.nil
        id = $game_system.xas_item_id[selection_type]
        $game_system.xas_item_id[index] = id
      else #else delete the old item
        $game_system.xas_item_id.delete(item.id)
      end
      #set the new item
      $game_system.xas_item_id[selection_type] = item.id
    # If the item isn't selectable
    else
      # Play buzzer SE
      return $game_system.se_play($data_system.buzzer_se)
    end
  end
  #--------------------------------------------------------------------------
  #  Minimenu Check
  #--------------------------------------------------------------------------
  def minimenu_check(item, selection_type = nil)
    #return if the item is disabled
    items = DisabledActorItems[$game_party.actors[0].id]
    return item, selection_type if !items.nil && items.include(item.id)
    #check if a mini menu exists
    minimenu = MiniMenuItems[item.id]
    #return if there is no minimenu
    return item, selection_type if minimenu.nil
    #remove the items from the minimenu which haven't been obtained
    minimenu.each_index do i
      minimenu[i] = nil if $game_party.item_number(minimenu[i][0]) == 0
    end
    minimenu.compact!
    #return if the minimenu no longer has any content
    return item, selection_type if minimenu.empty
    #play decision sound effect
    $game_system.se_play($data_system.decision_se)
    #get the item
    item, selection_type = get_minimenu_item(minimenu, selection_type)
    #player buzzer sound if no item exists
    if item.nil
      $game_system.se_play($data_system.buzzer_se)
      return nil, nil
    end
    #return the item and selection type
    return item, selection_type
  end
  #--------------------------------------------------------------------------
  #  Get Mini Menu Item
  #--------------------------------------------------------------------------
  def get_minimenu_item(minimenu, selection_type = nil)
    #initialize selection_type if needed
    selection_type = 0 if selection_type == nil
    #flag window as waiting
    @waiting = true
    #create the minimenu sprite
    menu = Sprite_ZeldaCMS_Minimenu.new(minimenu, @cursor)
    menu.x, menu.y = @xy_pos[@index]
    #loop until an item has been selected or cancelled
    loop do
      Graphics.update
      Input.update
      menu.update
      break if Input.trigger(InputC)  Input.trigger(InputB) 
      Input.trigger(XAS_COMMANDITEM_ACTION[0]) 
      Input.trigger(XAS_COMMANDITEM_ACTION[1]) 
      Input.trigger(XAS_COMMANDITEM_ACTION[2])
    end
    #get the item
    item = menu.item
    item = nil if Input.trigger(InputB)
    selection_type = 0 if Input.trigger(XAS_COMMANDITEM_ACTION[0])
    selection_type = 1 if Input.trigger(XAS_COMMANDITEM_ACTION[1])
    selection_type = 2 if Input.trigger(XAS_COMMANDITEM_ACTION[2])
    #dispose the menu
    menu.dispose
    #move menu cursor
    @cursor.x, @cursor.y = @xy_pos[@index][0], @xy_pos[@index][1]
    #return the item
    return item, selection_type
  end
  #--------------------------------------------------------------------------
  #  Frame Update
  #--------------------------------------------------------------------------
  def update
    #unflag waiting
    @waiting = false
    #run super method
    super
    # Only run the super if XAS is absent
    return if $xrxs_xas != true
    # If this window is active
    if self.active
      # If one of the c direction keys were pressed
      button_pressed = nil
      button_pressed = 0 if Input.trigger(XAS_COMMANDITEM_ACTION[0])
      button_pressed = 1 if Input.trigger(XAS_COMMANDITEM_ACTION[1])
      button_pressed = 2 if Input.trigger(XAS_COMMANDITEM_ACTION[2])
      # Run the code for an item to be selected
      select_item(button_pressed) unless button_pressed == nil
      #check for minimenu if decision key is pressed
    end
  end
end

#==============================================================================
#  Window_Equipment
#------------------------------------------------------------------------------
#  This window is designed to show the equipment window of the pause menu.
#==============================================================================

class Window_Equipment  Window_NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = equipment
  end    
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrequipmentscreenoot (in Windowskins folder)
    draw_background('hdrequipmentscreenoot')
    # Load the rxdata file called InventoryData
    reload_data(EquipmentData)
    # Draw the paperdoll
    draw_paper_doll(EquipmentPaperDoll)
  end
  #--------------------------------------------------------------------------
  #  Draw Item Name
  #--------------------------------------------------------------------------
  def draw_item_name
    super
    # If the item isn't disable and the item includes the method 'name'
    if !item_usable(@index) && !@items[@index].is_a(Symbol)
      #check if accessory is disabled
      if DisableAccessory
        if @items[@index].is_a(RPGArmor) && @items[@index].kind == 3
          return @itemname.text2 = ''
        end
      end
      # If input script exists
      if $max_input
        c = Input.string(InputC)
        @itemname.text2 = Press #{c} to equip
      else
        @itemname.text2 = 'Press C to equip'
      end
    else
      @itemname.text2 = ''
    end
  end
  #-------------------------------------------------------------------------
  # Equip_Item
  #-------------------------------------------------------------------------
  def equip_item(item)
    #check if accessory is disabled
    if DisableAccessory
      if @items[@index].is_a(RPGArmor) && @items[@index].kind == 3
        return $game_system.se_play($data_system.buzzer_se)
      end
    end
    #run original method
    super(item)
    #redraw the screen
    draw_background('hdrequipmentscreenoot')
    draw_data
    draw_paper_doll(EquipmentPaperDoll)
  end
end

#==============================================================================
#  Window_Masks 
#------------------------------------------------------------------------------
#  This window is designed to display the masks available
#==============================================================================

class Window_Masks  Window_Inventory
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = mask
  end    
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrequipmentscreenoot (in Windowskins folder)
    draw_background('hdrmaskscreenoot')
    # Load the rxdata file called MasksData
    reload_data(MasksData)
    # Draw the paperdoll
    draw_paper_doll(MasksPaperDoll)
  end
end

#==============================================================================
#  Window_QuestStatus
#------------------------------------------------------------------------------
#  This window is designed to show the quest & status window of the pause menu.
#==============================================================================

class Window_QuestStatus  Window_NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = quest
  end    
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrqueststatusscreenoot (in Windowskins folder)
    draw_background('hdrqueststatusscreenoot')
    # Load the rxdata file called InventoryData
    reload_data(QuestStatusData)
  end
end



#==============================================================================
#  Window_Map
#------------------------------------------------------------------------------
#  Displays the map in the pause menu.
#==============================================================================

class Window_Map  Window_NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = map
  end    
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrmapscreenoot (in Windowskins folder)
    draw_background('hdrmapscreenoot','hdrmapscreenoot_map')
    # Load the rxdata file called InventoryData
    reload_data(MapsData)
  end
  #--------------------------------------------------------------------------
  #  Draw Background
  #--------------------------------------------------------------------------
  def draw_background(backdrop, map)
    #draw the backdrop
    super(backdrop)
    # Draw the map
    bitmap = RPGCache.windowskin(map)
    self.contents.blt(0,0,bitmap,bitmap.rect)
  end
  #--------------------------------------------------------------------------
  #  Reload Data
  #--------------------------------------------------------------------------
  def reload_data(inputData)
    # Initialise the data arrays
    @items = []
    @xy_pos = []
    @descriptions = []
    @keys = []
    # Check the inputData, when it is items
    # Read the items input
    for data in inputData
      # If there is already an item at the XY position
      if @xy_pos.include(data[2..3])
        # Get the array's index where the item exists
        index = @xy_pos.index(data[2..3])
        # Delete the alraeady existing item
        @items.delete_at(index)
        @xy_pos.delete_at(index)
        @descriptions.delete_at(index)
        @keys.delete_at(index)
      end
      #if scene is the soaring scene and you have the soaring key
      if ($scene.is_a(Scene_Soaring) &&
         $game_system.soaring_points.has_key(data[5])) 
         #or if the scene isn't the soaring scene and you have visited the map
         (!$scene.is_a(Scene_Soaring) &&
         $game_system.maps_visited.include(data[1]))
        #store the map name data
        @items  data[0]
        # Store the x & y for the items separately (for speed)
        @xy_pos  data[2..3]
        #store the description
        @descriptions  data[4]
        #store the soaring key
        @keys  data[5]
      end
    end
    # Add the toggles if scene isn't the soaring scene
    if !$scene.is_a(Scene_Soaring)
      @items += [ left_toggle, right_toggle ]
      @xy_pos += ToggleCoords
    end
    # Draw the data and move the cursor if there are any items
    draw_data
    draw_item_name
    #disable cursors visibillity if there are no xy positions
    if @xy_pos.empty
      @cursor.visible = false 
    else
      #else move into position
      @cursor.x, @cursor.y = @xy_pos[@index][0], @xy_pos[@index][1]
    end
  end
  #--------------------------------------------------------------------------
  #  Draw Data
  #--------------------------------------------------------------------------
  def draw_data
    # Get the icon bitmap
    icon = ($scene.is_a(Scene_Soaring)  SoaringIcon  MapIcon)
    bitmap = RPGCache.windowskin(icon)
    rect = bitmap.rect
    #get the windowskin sections
    left = RPGCache.windowskin('hdrmapscreenoot_maptagleftend')
    middle = RPGCache.windowskin('hdrmapscreenoot_maptagmiddle')
    right = RPGCache.windowskin('hdrmapscreenoot_maptagrightend')
    # Get the font details
    self.contents.font.name = MapFont
    self.contents.font.size = middle.height + 2
    self.contents.font.color.set(80,40,0)
    # Loop through every item
    for i in 0...[@items.size, @xy_pos.size].min
      # Skip if a toggle
      next if [left_toggle, right_toggle].include(@items[i])
      x, y = @xy_pos[i][0] - rect.width  2, @xy_pos[i][1] - rect.height  2
      # copy the bitmap onto the window
      self.contents.blt(x, y, bitmap, rect)
      #get the name
      text = @items[i]
      #get the width
      width = self.contents.text_size(text).width
      #draw the background
      x += rect.width  2
      y -= middle.height  2
      self.contents.blt(x - width  2 - left.width, y, left, left.rect)
      dest = Rect.new(x - width  2, y, width, middle.height)
      self.contents.stretch_blt(dest, middle, middle.rect)
      self.contents.blt(x + width  2, y, right, right.rect)
      #draw the text
      begin #compatibillity with hermes
        te = TextEffect.new(0)
        self.contents.draw_text(dest, text, 1, te, te)
      rescue
        self.contents.draw_text(dest, text, 1)
      end
    end
    # Reset the font
    self.contents.font.name = Font.default_name
    self.contents.font.size = Font.default_size
    self.contents.font.color = Font.default_color
  end
  #--------------------------------------------------------------------------
  #  Move Cursor
  #--------------------------------------------------------------------------
  def move_cursor
    #return if there are no xy positions
    return if @xy_pos.empty
    super
  end
  #--------------------------------------------------------------------------
  #  Draw Item Name
  #--------------------------------------------------------------------------
  def draw_item_name
    #return if there are no xy positions
    return if @xy_pos.empty
    #if a toggle
    if @items[@index].is_a(Symbol)
      @itemname.text = ''
    else
      @itemname.text = @items[@index]
    end
  end
  #--------------------------------------------------------------------------
  #  Get Description
  #--------------------------------------------------------------------------
  def get_description
    #return if the item is a toggle
    return nil if [left_toggle, right_toggle].include(@items[@index])
    #return the name and description
    return @items[@index], @descriptions[@index]
  end
  #--------------------------------------------------------------------------
  #  Frame Update
  #--------------------------------------------------------------------------
  def update
    #if on soaring scene
    if $scene.is_a(Scene_Soaring)
      #save the soaring key
      if Input.trigger(InputC)
        return $game_temp.soaring_key = @keys[@index]
      #cancel the soaring key
      elsif Input.trigger(InputB)
        return $game_temp.soaring_key = ''
      end
    end
    super
  end
end

#==============================================================================
#  Window_Dungeon
#------------------------------------------------------------------------------
#  Displays the dungeon map
#==============================================================================

class Window_Dungeon  Window_NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = map
  end
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrmapscreenoot (in Windowskins folder)
    draw_background('hdrdungeonmapscreenoot')
    # Load the rxdata file called DungeonsData
    reload_data(DungeonsData[$game_map.dungeon_name])
  end
  #--------------------------------------------------------------------------
  #  Reload the items being shown
  #--------------------------------------------------------------------------
  def reload_data(dungeon)
    #store the dungeon
    @dungeon = dungeon
    #Tables to hold dungeon floor data
    @maps = @dungeon.maps
    @data = @dungeon.data
    #Load the base data of the floors
    @floors = @dungeon.floors
    @width = @dungeon.width
    @height = @dungeon.height
    @ids = [@dungeon.map, @dungeon.compass, @dungeon.key, @dungeon.boss_key]
    @floor_names = @dungeon.floor_names
    @extras = @dungeon.extras
    #initialize cursor data
    @items = [ ]
    @xy_pos = [ ]
    #get the floor rectangle
    rect = Rect.new(FloorsRectangle)
    #store the cursor position item data
    @floors.times do i
      #store the floor number
      @items  i
      #store the x and y position of the floors
      x = rect.x + rect.width  2
      h = 30
      y = rect.y + rect.height  2 + @floors  h  2 - i  h - h  2
      @xy_pos  [x,y]
    end
    # Add the other cursor positions for the dungeon items
    @ids.each {id @items  $data_items[id]}
    @xy_pos.push MapLocation, CompassLocation, KeysLocation, BossKeyLocation
    # Add the toggles
    @items += [ left_toggle, right_toggle ]
    @xy_pos += ToggleCoords
    # Get the current floor
    @current_floor = @dungeon.current_floor
    # Make cursor index the current floor
    @index = @items.index(@current_floor)
    # Draw the dungeon, floors, items and floor name
    draw_background('hdrdungeonmapscreenoot')
    draw_dungeon(@current_floor)
    draw_floors
    draw_items
    # Move the cursor to the correct position
    @cursor.x, @cursor.y = @xy_pos[@index][0], @xy_pos[@index][1]
  end
  #--------------------------------------------------------------------------
  #  Move Cursor
  #--------------------------------------------------------------------------
  def move_cursor
    #return if there are no xy positions
    return if @xy_pos.empty
    # Draw the dungeon, floors, items and floor name if item is a floor number
    if @items[@index].is_a(Numeric)
      self.contents.clear
      draw_background('hdrdungeonmapscreenoot')
      draw_dungeon(@items[@index])
      draw_floors
      draw_items
    end
    super
  end
  #--------------------------------------------------------------------------
  #  Draw Dungeon
  #--------------------------------------------------------------------------
  def draw_dungeon(floor)
    #get the dungeon rect
    rect = Rect.new(DungeonRectangle)
    #determine if the player has the dungeon map and compass
    map = $game_party.item_number(@ids[0])  0
    compass = $game_party.item_number(@ids[1])  0
    #initialize some bitmaps to prioritise certain layers
    bottom = Bitmap.new(640, 480)
    top = Bitmap.new(640, 480)
    #flag for the player to be drawn
    player, player_x, player_y = false, [], []
    #loop for each cell
    (0...@maps.ysize).each {a (0...@maps.zsize).each {b
      #xy coords for the cell
      x = rect.x + rect.width  2 - 27  @maps.ysize  2 + a  27
      y = rect.y + rect.height  2 - 27  @maps.zsize  2 + b  27
      #determine if the current map
      current = @maps[floor, a, b] == $game_map.map_id 
      #determine if the map has been visited
      visited = $game_system.maps_visited.include(@maps[floor, a, b])
      #get the cell data
      data = @data[floor, a, b]
      #draw the cell if the player has the dungeon map or it's been visited
      if @maps[floor, a, b] != 0 && (map  visited)
        #draw the border
        self.contents.fill_rect(x, y, 30, 30, Border)
        #determine whether the map is current, visited or unvisited
        color = current  Current  visited  Visited  Unvisited
        #draw the room color
        bottom.fill_rect(x + 3, y + 3, 24, 24, color)
        #draw the connections to the surrounding rooms
        down = @maps[floor, a, b] == @maps[floor, a, b + 1]
        left = @maps[floor, a, b] == @maps[floor, a - 1, b]
        right = @maps[floor, a, b] == @maps[floor, a + 1, b]
        up = @maps[floor, a, b] == @maps[floor, a, b - 1]
        upleft = @maps[floor, a, b] == @maps[floor, a - 1, b - 1]
        bottom.fill_rect(x + 3, y + 27, 24, 3, color) if down
        bottom.fill_rect(x, y + 3, 3, 24, color) if left
        bottom.fill_rect(x + 27, y + 3, 3, 24, color) if right
        bottom.fill_rect(x + 3, y, 24, 3, color) if up
        bottom.fill_rect(x, y, 3, 3, color) if up && left && upleft
        #draw the doors
        bottom.fill_rect(x + 11, y + 27, 8, 3, Door) if data & Down == Down
        bottom.fill_rect(x, y + 11, 3, 8, Door) if data & Left == Left
        bottom.fill_rect(x + 27, y + 11, 3, 8, Door) if data & Right == Right
        bottom.fill_rect(x + 11, y, 8, 3, Door) if data & Up == Up
      end
      #if you have the compass
      if compass
        #draw map
        if (data & Map == Map) && $game_party.item_number(@ids[0]) == 0
          bitmap = RPGCache.icon(MapSmall)
          dx, dy = x + 15 - bitmap.width  2, y + 15 - bitmap.height  2
          top.blt(dx, dy, bitmap, bitmap.rect)
        end
        #draw compass
        if (data & Compass == Compass) && $game_party.item_number(@ids[1]) == 0
          bitmap = RPGCache.icon(CompassSmall)
          dx, dy = x + 15 - bitmap.width  2, y + 15 - bitmap.height  2
          top.blt(dx, dy, bitmap, bitmap.rect)
        end
        #draw boss key
        if (data & Key == Key) && $game_party.item_number(@ids[3]) == 0
          bitmap = RPGCache.icon(BossKeySmall)
          dx, dy = x + 15 - bitmap.width  2, y + 15 - bitmap.height  2
          top.blt(dx, dy, bitmap, bitmap.rect)
        end
        #draw boss
        if (data & Boss == Boss)
          bitmap = RPGCache.icon(BossSmall)
          dx, dy = x + 15 - bitmap.width  2, y + 15 - bitmap.height  2
          top.blt(dx, dy, bitmap, bitmap.rect)
        end
      end
      #set the player location if the map is current
      if current
        #add to the player location arrays
        player_x  x
        player_y  y
        #flag the player to be drawn
        player = true
      end      
    }}
    #copy the bottom bitmaps data to the screen and dispose
    self.contents.blt(0, 0, bottom, bottom.rect)
    bottom.dispose
    #draw the extra data if you have the compass
    if compass
      @extras.each do data
        #skip if not the correct floor
        next unless @dungeon.floor_include_map(floor, data[3].to_i)
        #skip if the self switch has been activated
        next if $game_self_switches[[data[3].to_i,data[4].to_i,data[5].upcase]]
        #draw the data
        bitmap = RPGCache.icon(data[0])
        self.contents.blt(data[1].to_i - bitmap.width  2,
        data[2].to_i - bitmap.height  2, bitmap, bitmap.rect)
      end
    end
    #copy the top bitmaps data to the screen and dispose
    self.contents.blt(0, 0, top, top.rect)
    top.dispose
    #draw the player if it exists
    if player
      #initialize the location of the player
      px = py = 0
      #work out the average x and y value
      player_x.each {x px += x}; px = player_x.size
      player_y.each {y py += y}; py = player_y.size
      #draw the icon
      bitmap = RPGCache.icon(PlayerSmall)
      dx, dy = px - bitmap.width  2 + 15, py - bitmap.height  2 + 15
      self.contents.blt(dx, dy, bitmap, bitmap.rect)
    end
  end
  #--------------------------------------------------------------------------
  #  Draw Floors
  #--------------------------------------------------------------------------
  def draw_floors
    #set the font name
    self.contents.font.name = FloorFont
    #create a bitmap for the backdrop of the floors
    back = Bitmap.new(60,30)
    back.fill_rect(back.rect, FloorInner)
    back.fill_rect(2, 2, 56, 2, FloorOuter)
    back.fill_rect(2, 2, 2, 26, FloorOuter)
    back.fill_rect(2, 26, 56, 2, FloorOuter)
    back.fill_rect(56, 2, 2, 26, FloorOuter)
    #get the floor rectangle
    rect = Rect.new(FloorsRectangle)
    #get the boss floor
    boss_floor = @dungeon.boss_floor
    #loop through each floor
    @floors.times do i
      #get the location and text of the floor
      x = rect.x + (rect.width - back.width)  2
      h = back.height
      y = rect.y + rect.height  2 + @floors  h  2 - i  h - h
      #draw the floor
      self.contents.blt(x, y, back, back.rect)
      self.contents.draw_text(x, y, back.width, back.height, @floor_names[i], 1)
      #draw the player icon if current floor
      if @current_floor == i 
        bitmap = RPGCache.icon(PlayerBig)
        self.contents.blt(x - bitmap.width  2,
        y + h  2 - bitmap.height  2, bitmap, bitmap.rect)
      end
      #draw boss icon if boss floor and you have the compass
      if boss_floor == i && $game_party.item_number(@ids[1])  0
        bitmap = RPGCache.icon(BossBig)
        self.contents.blt(x + back.width - bitmap.width  2,
        y + h  2 - bitmap.height  2, bitmap, bitmap.rect)
      end
    end
    #dispose the backdrop
    back.dispose
    #reset font
    self.contents.font.name = Font.default_name
  end
  #--------------------------------------------------------------------------
  #  Draw Items
  #--------------------------------------------------------------------------
  def draw_items
    #set the font name
    self.contents.font.name = KeyFont
    #Map
    if $game_party.item_number(@ids[0])  0 
      bitmap = RPGCache.icon(MapBig)
      self.contents.blt(MapLocation[0] - bitmap.width  2,
      MapLocation[1] - bitmap.height  2, bitmap, bitmap.rect)
    end
    #Compass
    if $game_party.item_number(@ids[1])  0 
      bitmap = RPGCache.icon(CompassBig) 
      self.contents.blt(CompassLocation[0] - bitmap.width  2,
      CompassLocation[1] - bitmap.height  2, bitmap, bitmap.rect)
    end
    #Something
    bitmap = RPGCache.icon(SomethingIcon) 
    self.contents.blt(SomethingLocation[0] - bitmap.width  2,
    SomethingLocation[1] - bitmap.height  2, bitmap, bitmap.rect)
    #Boss Key
    if $game_party.item_number(@ids[3])  0 
      bitmap = RPGCache.icon(BossKeyBig)
      self.contents.blt(BossKeyLocation[0] - bitmap.width  2,
      BossKeyLocation[1] - bitmap.height  2, bitmap, bitmap.rect)
    end
    #Keys
    unless $game_party.items[@ids[2]].nil
      item = $game_party.item_number(@ids[2])
      keys = item.to_s
      bitmap = RPGCache.icon(KeysIcon)
      x, y = KeysLocation
      rect = bitmap.text_size(keys)
      self.contents.blt(x - bitmap.width, y - bitmap.height  2, 
                        bitmap, bitmap.rect)
      #check if the amount is capped
      if defined(ZeldaHUD_Customization) && 
                 !ZeldaHUD_CustomizationItemCapVar[id].nil
        cap = (item == $game_variables[ZeldaHUD_CustomizationItemCapVar[id]])
      else
        cap = (item == 99)
      end
      #set the color to green if capped
      color = cap  Color.new(0,255,0)  Color.new(255,255,255)
      self.contents.font.color = color
      #draw the text
      self.contents.draw_text(x, y - rect.height  2,
                              rect.width, rect.height, keys)
    end
    #reset font
    self.contents.font.name = Font.default_name
    self.contents.font.color = Font.default_color
  end
  #--------------------------------------------------------------------------
  #  Draw Item Name
  #--------------------------------------------------------------------------
  def draw_item_name
    #draw the dungeon map name
    @itemname.text = $game_map.dungeon_name
  end
  #--------------------------------------------------------------------------
  #  Select Highlighted Item
  #--------------------------------------------------------------------------
  def select_item
    #clear this method as it is not needed for the dungeon map
  end
end

#==============================================================================
#  Window_SaveGame
#------------------------------------------------------------------------------
#  Displays the options to save & continuequit
#==============================================================================

class Window_SaveGame  Window_NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    # Run original method
    super
    #initialize the symbol
    @symbol = save
  end    
  #--------------------------------------------------------------------------
  #  Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Load the backdrop labeled hdrequipmentscreenoot (in Windowskins folder)
    draw_background('hdrsavegamescreenoot')
    # Load the rxdata file called InventoryData
    data = [ [sym, save_and_cont, 235, 277, 0, 0],
             [sym, save_and_quit, 409, 276, 0, 0],
           ]
    reload_data(data)
  end
  #--------------------------------------------------------------------------
  #  Item Disabled
  #--------------------------------------------------------------------------
  def item_disabled(index)
    # If the item is to continue or quit
    case @items[index]
    when save_and_cont, save_and_quit
      return false
    end
    # Run the default item_disabled
    super
  end
  #--------------------------------------------------------------------------
  #  Select Item
  #--------------------------------------------------------------------------
  def select_item
    # If it is save
    case @items[@index]
    when save_and_cont
      $scene = Scene_Save.new
    when save_and_quit
      $scene = Scene_Save.new
    end
  end
end

#==============================================================================
#  Interpreter
#------------------------------------------------------------------------------
#  Added transfer to soaring scene
#==============================================================================

class Interpreter
  #---------------------------------------------------------------------------
  # Soaring Scene
  #---------------------------------------------------------------------------
  def soaring_scene
    #return if ocarina doesn't exist
    return true if $pze_ocarina.nil
    #change to soaring scene
    $scene = Scene_Soaring.new
    #increment index
    @index += 1
    #return
    return false    
  end
end

#==============================================================================
#  Scene_Item
#------------------------------------------------------------------------------
#  Edited to go to the pause menu's items
#==============================================================================

class Scene_Item
  #--------------------------------------------------------------------------
  #  Main Processing
  #--------------------------------------------------------------------------
  def main
    $scene = Scene_Menu.new(inventory)
  end
end

#==============================================================================
#  Scene_Equip
#------------------------------------------------------------------------------
#  Edited to go tp the pause menu's equipment
#==============================================================================

class Scene_Equip
  #--------------------------------------------------------------------------
  #  Main Processing
  #--------------------------------------------------------------------------
  def main
    $scene = Scene_Menu.new(equipment)
  end
end

#==============================================================================
#  Scene_Menu
#------------------------------------------------------------------------------
#  Where the magic happens.
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  #  Include Modules
  #--------------------------------------------------------------------------
  include NR_Zelda_CMS
  #--------------------------------------------------------------------------
  #  Class Variables
  #--------------------------------------------------------------------------
  @@class_sym = Menus[0]
  #--------------------------------------------------------------------------
  #  Invariables
  #--------------------------------------------------------------------------
  WindowMovementSpeed = 60
  #--------------------------------------------------------------------------
  #  Object Initialization
  #--------------------------------------------------------------------------
  def initialize(window_sym = nil)
    # Adjust class index based on initialized symbol
    @@class_sym = window_sym if window_sym.is_a(Symbol)
    # If the symbol doesn't exist just use the first menu symbol
    @@class_sym = Menus[0] unless Menus.include(@@class_sym)
  end
  #--------------------------------------------------------------------------
  #  Main Processing
  #--------------------------------------------------------------------------
  def main
    # Initialize an array to put the windows in
    @windows = []
    # Create the backdrop
    @spritemap = Spriteset_Map.new
    # Create the windows
    Menus.each do menu
      case menu
      when inventory then @windows  Window_Inventory.new #inventory
      when save then @windows  Window_SaveGame.new       #save
      when quest then @windows  Window_QuestStatus.new   #queststatus
      when equipment then @windows  Window_Equipment.new #equipment
      when mask then @windows  Window_Masks.new          #masks
      when map                                             #map
        @windows  Window_Map.new if $game_map.dungeon_name == ''
        @windows  Window_Dungeon.new if $game_map.dungeon_name != ''
      end
    end
    # Hide the windows
    @windows.each { window window.visible = window.active = false }
    # Reorder the windows
    @windows  @windows.shift until @windows[0].symbol == @@class_sym
    # Show the main window
    @windows[0].visible = true
    @windows[0].active = true
    @windows[0].y = 480
    # Store and dim the audio
    bgm = $game_system.playing_bgm
    bgs = $game_system.playing_bgs
    Audio.bgm_play('AudioBGM' + bgm.name, MenuVolume, bgm.pitch) if !bgm.nil && bgm.name != ''
    Audio.bgs_play('AudioBGS' + bgs.name, MenuVolume, bgs.pitch) if !bgs.nil && bgs.name != ''
    # Transition 
    Graphics.transition(0)
    # Play the opening sound effect
    $game_system.se_play(OpenSound)
    # Move the window up
    move_window(8)
    # Main Processing
    begin
      Graphics.update
      Input.update
      update
    end while $scene == self
    # Play the closing sound effect
    $game_system.se_play(CloseSound)
    # Move the window down
    move_window(2)
    # Restore Audio
    $game_system.bgm_play(bgm)
    $game_system.bgs_play(bgs)
    # Freeze the graphics
    Graphics.freeze
    # Store the window symbol
    @@class_sym = @windows[0].symbol
    # Dispose the windows
    @windows.each { window window.dispose }
    # Dispose the map
    @spritemap.dispose
  end
  #--------------------------------------------------------------------------
  #  Move Window
  #--------------------------------------------------------------------------
  def move_window(dir)
    case dir
    when 2      # Moving Down
      while @windows[0].y  480
        Graphics.update
        @windows[0].y += WindowMovementSpeed
      end
      @windows[0].y = 480
    when 4      # Moving Left
      # Skip if there is only 1 menu
      return if @windows.size = 1
      # Play the sound
      $game_system.se_play(ChangeScreenSound)
      # Move the second window to place and make visible
      @windows[1].x = 640+16
      @windows[1].y = -16
      @windows[1].visible = @windows[1].active = true
      # Move the window
      while @windows[1].x  -16
        Graphics.update
        @windows[0].x -= WindowMovementSpeed
        @windows[1].x -= WindowMovementSpeed
      end
      # Hide & rotate the last active window
      @windows[0].visible = @windows[0].active = false
      @windows.push(@windows.shift)
      # Force the x position of the active window
      @windows[0].x = -16
    when 6      # Moving Right
      # Skip if there is only 1 menu
      return if @windows.size = 1
      # Play the sound
      $game_system.se_play(ChangeScreenSound)
      # Move the last window to place and make visible
      last_window_index = @windows.size-1
      @windows[last_window_index].x = -640-32
      @windows[last_window_index].y = -16
      @windows[last_window_index].visible = true
      @windows[last_window_index].active = true
      # Move the window
      while @windows[last_window_index].x  -16
        Graphics.update
        @windows[0].x += WindowMovementSpeed
        @windows[last_window_index].x += WindowMovementSpeed
      end
      # Force the positon of the window
      @windows[last_window_index].x = -16
      # Deactivate, hide and rotate the last window
      @windows[0].visible = @windows[0].active = false
      @windows.unshift(@windows.pop)
    when 8      # Moving Up
      while @windows[0].y  -16
        Graphics.update
        @windows[0].y -= WindowMovementSpeed
      end
      @windows[0].y = -16
    end
  end
  #--------------------------------------------------------------------------
  #  Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update each window
    @windows.each { window window.update }
     # If C was pressed
    if Input.trigger(InputC)
      # Do nothing if the window doesn't have an item
      return if not @windows[0].methods.include( 'item' )
      #get the item
      item = @windows[0].item
      # If the item is a toggle
      if item == left_toggle
        move_window(6)
      elsif item == right_toggle
        move_window(4)
      # If the item is an item
      elsif not item.nil
        # Tell the window to run the cose to equip the item
        @windows[0].select_item unless @windows[0].waiting
        @spritemap.update
        #if the window is the equipment window
        if @windows[0].symbol == equipment
          #get the mask window
          index = nil
          @windows.each_index do i
            index = i if @windows[i].symbol == mask
          end
          #return if there is no Mask window
          return if index.nil
          #redraw the masks window
          @windows[index].refresh
        end
      end
    end  
    #return if the window is waiting
    return if @windows[0].waiting
    # Break if cancelled
    if Input.trigger(InputB)  
       ($xrxs_xas && Input.trigger(XAS_COMMANDMENU_BUTTON))
      return $scene = Scene_Map.new 
    end
    # If the L number was triggered, move the windows
    if Input.trigger(InputL)
      move_window(6)
    end
    # if the R bumper was triggered
    if Input.trigger(InputR)
      move_window(4)
    end
    # If Description Input was pressed
    if Input.trigger(DescriptionInput)
      # Get the description
      description = @windows[0].get_description
      # Return if there is no description
      return if description.nil
      # Call the description
      call_description(description)
    end
    # If a quick input was pressed, move to selected window
    if Input.trigger(InventoryInput)
      move_window(4) until @windows[0].symbol == inventory
    elsif Input.trigger(EquipmentInput)
      move_window(4) until @windows[0].symbol == equipment
    elsif Input.trigger(QuestStatusInput)
      move_window(4) until @windows[0].symbol == quest
    elsif Input.trigger(MapInput)
      move_window(4) until @windows[0].symbol == map
    elsif Input.trigger(SaveInput)
      move_window(4) until @windows[0].symbol == save
    elsif Input.trigger(MaskInput)
      move_window(4) until @windows[0].symbol == mask
    end
  end
  #--------------------------------------------------------------------------
  #  Call Description
  #--------------------------------------------------------------------------
  def call_description(description)
    #play the se
    $game_system.se_play($data_system.decision_se)
    #create the description window
    window = Window_ZeldaCMS_Description.new(description)
    #fade it in
    until window.opacity == 255
      Graphics.update
      window.opacity += 24
      window.contents_opacity += 24
    end
    #activate the pause graphic
    window.pause = true
    #wait for an input
    until Input.trigger(InputC)  Input.trigger(InputB)
      Graphics.update
      window.update
    end
    #deactivate the graphic
    window.pause = false
    #play the se
    $game_system.se_play($data_system.cancel_se)
    #fade it out
    until window.opacity == 0
      Graphics.update
      window.opacity -= 24
      window.contents_opacity -= 24
    end
    #dispose the window
    window.dispose
  end
end

#==============================================================================
#  Scene_Soaring
#------------------------------------------------------------------------------
#  Menu scene used to choose your soaring point
#==============================================================================

class Scene_Soaring  Scene_Menu
  #--------------------------------------------------------------------------
  #  Main
  #--------------------------------------------------------------------------
  def main
    #create the spritemap backdrop
    @spritemap = Spriteset_Map.new
    #create the map window
    @windows = [Window_Map.new]
    @windows[0].y = 480
    # Store and dim the audio
    bgm = $game_system.playing_bgm
    bgs = $game_system.playing_bgs
    Audio.bgm_play('AudioBGM' + bgm.name, MenuVolume, bgm.pitch) if !bgm.nil
    Audio.bgs_play('AudioBGS' + bgs.name, MenuVolume, bgs.pitch) if !bgs.nil
    #transition
    Graphics.transition(0)
    #move the map into place
    move_window(8)
    # Play the opening sound effect
    $game_system.se_play(OpenSound)
    #main loop
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    # Play the closing sound effect
    $game_system.se_play(CloseSound)
    #move the map out
    move_window(2)
    # Restore Audio
    $game_system.bgm_play(bgm)
    $game_system.bgs_play(bgs)
    #freeze
    Graphics.freeze
    #dispose everything
    @spritemap.dispose
    @windows[0].dispose
  end
  #--------------------------------------------------------------------------
  #  Update
  #--------------------------------------------------------------------------
  def update
    #update the window
    @windows[0].update
    #transfer to map
    if Input.trigger(InputC)  Input.trigger(InputB)
      $scene = Scene_Map.new
    end
  end
end

#==============================================================================
#  Scene_Map
#------------------------------------------------------------------------------
#  Added quick menu Inputs
#==============================================================================

class Scene_Map
  #--------------------------------------------------------------------------
  #  Aliases
  #--------------------------------------------------------------------------
  alias max_menu_update_later update
  #--------------------------------------------------------------------------
  #  Update
  #--------------------------------------------------------------------------
  def update
    max_menu_update_later
    #if the player isn't moving, interpreter not running or menu not disabled
    unless $game_player.moving  $game_system.map_interpreter.running 
           $game_system.menu_disabled
      #Go to Inventory screen
      if Input.press(NR_Zelda_CMSInventoryInput)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Menu.new(inventory)
        return
      #Go to Save screen
      elsif Input.press(NR_Zelda_CMSSaveInput)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Menu.new(save)
        return
      #Go to Map screen
      elsif Input.press(NR_Zelda_CMSMapInput)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Menu.new(map)
        return
      #Go to QuestStatus screen
      elsif Input.press(NR_Zelda_CMSQuestStatusInput)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Menu.new(quest)
        return
      #Go to Equipment screen
      elsif Input.press(NR_Zelda_CMSEquipmentInput)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Menu.new(equipment)
        return
      #Go to Mask Screen
      elsif Input.press(NR_Zelda_CMSMaskInput)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Menu.new(mask)
        return
      end
    end
  end
end

#==============================================================================
#  Sprite_ZeldaCMS_HUD
#------------------------------------------------------------------------------
#  Displays the weaponitem elements of the hud
#==============================================================================

#if the zelda hud exists
if defined(Sprite_ZeldaHUD)
  
class Sprite_ZeldaCMS_HUD  Sprite_ZeldaHUD
  #--------------------------------------------------------------------------
  #  Initialize
  #--------------------------------------------------------------------------
  def initialize
    #run super method
    super
    #bring the viewport forward
    viewport.z = 10000000
    #hide the unneccesary sprites
    @heartSprite.visible = false
    @magicSprite.visible = false
    @goldSprite.visible = false
    #hide the navi sprite if it exists
    @navi_sprite.visible = false if instance_variables.include('@navi_sprite')
  end
  #--------------------------------------------------------------------------
  #  Update
  #--------------------------------------------------------------------------
  def update
    #update the actions, sword and sheild
    update_act_sword_cancel
    #update equipped if needed
    update_equipped
  end
end
  
#==============================================================================
#  Scene_Menu
#------------------------------------------------------------------------------
#  Displays the weaponitem elements of the hud
#==============================================================================

class Scene_Menu
  #--------------------------------------------------------------------------
  #  Aliases
  #--------------------------------------------------------------------------
  alias max_zcms_main_later main
  alias max_zcms_update_later update
  #--------------------------------------------------------------------------
  #  Main
  #--------------------------------------------------------------------------
  def main
    @hud = Sprite_ZeldaCMS_HUD.new
    max_zcms_main_later
    @hud.dispose
  end
  #--------------------------------------------------------------------------
  #  Update
  #--------------------------------------------------------------------------
  def update
    max_zcms_update_later
    @hud.update
  end
end

end