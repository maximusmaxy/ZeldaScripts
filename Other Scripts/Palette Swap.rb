#===============================================================================
# Palette Swap
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.1: 1/1/12
# Thanks to:
# http://www.66rpg.com/htm/news624.htm - Bitmap to PNG module
#===============================================================================
# 
# Introduction:
# A lazy persons script which recolors your sprites so you don't have to!
#
# Instructions:
# You will need to make two sprites which will act as dummies for the script
# to calculate the color differences. One sprite will be your existing colored
# sprites, the other will be the new color. It is important that you make the
# dummy sprites the exact same dimensions as each other, and also that the
# gradients in color diference are the same. After you have made your dummy
# sprites, add them to the configuration, place them in your characters folder,
# then just type the names of characters you want converted and your read to go.
#
#===============================================================================

module Palette_Swap
#===============================================================================
# Configuration
#===============================================================================
  #Set this switch to true to enable the script
  ENABLED = false
  #Precision of the color check (0 = exact, 100 = not very accurate at all)
  PRECISION = 0
  #Type: 1 = prefix, 2 = suffix
  TYPE = 1
  #Name of the prefix/suffix
  NAME = 'Blue_'
  #Old dummy character
  OLD = 'Link[1]'
  #New dummy character
  NEW = 'Link[1] (Blue) - Darker'
  #Add the names of any characters you want converted
  SPRITES = [
  'Link[7]_DISCOVER[1]',
  'Link[7]',
  'Link[7]_BALLCHAIN(16)[1]',
  'Link[7]_BOTTLE[1]',
  'Link[7]_BOW[3]',
  'Link[7]_BUGNET(32)[6]',
  'Link[7]_CANE_BYRNA(16)[1]',
  'Link[7]_CANE_PACCI(16)[1]',
  'Link[7]_CANE_SOMARIA(16)[1]',
  'Link[7]_CARRY[6]',
  'Link[7]_DEFEATED[1]',
  'Link[7]_DEKUNUT[1]',
  'Link[7]_DROP[1]',
  'Link[7]_FIREROD[1]',
  'Link[7]_HAMMER[3]',
  'Link[7]_HIT',
  'Link[7]_HOOKSHOT(16)[1]',
  'Link[7]_HSLINGSHOT[1]',
  'Link[7]_ICEROD[1]',
  'Link[7]_Jump[1]',
  'Link[7]_LANTERN(16)',
  'Link[7]_LONGSHOT(16)[1]',
  'Link[7]_MAGICBEAN[1]',
  'Link[7]_MHAMMER1(16)[3]',
  'Link[7]_MHAMMER2(16)[1]',
  'Link[7]_MHAMMER(16)[3]',
  'Link[7]_MPOWDER[1]',
  'Link[7]_MUDORABOOK[1]',
  'Link[7]_MUSHROOM[1]',
  'Link[7]_OCARINA',
  'Link[7]_PICKUP[2]',
  'Link[7]_RODOFSEASONS[1]',
  'Link[7]_RODOFSEASONS_SWING(16)[3]',
  'Link[7]_SEEDSHOOTER(16)[1]',
  'Link[7]_SHLD_DEKUSHIELD(16)[1]',
  'Link[7]_SHLD_FIGHTERSHIELD(16)[1]',
  'Link[7]_SHLD_HEROSHIELD(16)[1]',
  'Link[7]_SHLD_HYLIANSHIELD(16)[1]',
  'Link[7]_SHLD_KNIGHTSHIELD(16)[1]',
  'Link[7]_SHLD_MIRRORSHIELD(16)[1]',
  'Link[7]_SHLD_ORDONSHIELD(16)[1]',
  'Link[7]_SHOVEL[1]',
  'Link[7]_SLINGSHOT[1]',
  'Link[7]_SWORD(16)[6]',
  'Link[7]_Throw[1]'
  ]
#===============================================================================
# End Configuration
#===============================================================================
end

#============================================================================== 
# Bitmap     
#==============================================================================

class Bitmap
  #-------------------------------------------------------------------------
  # * Name      : Make PNG
  #   Info      : Saves Bitmap to File
  #   Author    : ??? - http://www.66rpg.com/htm/news624.htm
  #   Call Info : Zero to Three Arguments
  #               Name : Name of filenam
  #               Path : Directory in Game Folder
  #               Mode : Mode of Writing
  #-------------------------------------------------------------------------
  def make_png(name = 'like', path = '', mode = 0)
    Dir.mkdir(path) if path != '' && !FileTest.directory?(path)
    Zlib::Png_File.open('temp.gz')   { |gz| gz.make_png(self, mode) }
    Zlib::GzipReader.open('temp.gz') { |gz| $read = gz.read }
    f = File.open(path + '/' + name + '.png', 'wb')
    f.write($read)
    f.close
    File.delete('temp.gz')
  end
end

#============================================================================== 
# Zlib     
#==============================================================================

module Zlib
  #============================================================================ 
  # ** Png_File     
  #============================================================================

  class Png_File < GzipWriter
    #--------------------------------------------------------------------------
    # * Make PNG
    #--------------------------------------------------------------------------
    def make_png(bitmap, mode = 0)
      # Save Bitmap & Mode
      @bitmap, @mode = bitmap, mode
      # Create & Save PNG
      self.write(make_header)
      self.write(make_ihdr)
      self.write(make_idat)
      self.write(make_iend)
    end
    #--------------------------------------------------------------------------
    # * Make Header
    #--------------------------------------------------------------------------
    def make_header
      return [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a].pack('C*')
    end
    #--------------------------------------------------------------------------
    # * Make IHDR
    #--------------------------------------------------------------------------
    def make_ihdr
      ih_size               = [13].pack("N")
      ih_sign               = 'IHDR'
      ih_width              = [@bitmap.width].pack('N')
      ih_height             = [@bitmap.height].pack('N')
      ih_bit_depth          = [8].pack('C')
      ih_color_type         = [6].pack('C')
      ih_compression_method = [0].pack('C')
      ih_filter_method      = [0].pack('C')
      ih_interlace_method   = [0].pack('C')
      string = ih_sign + ih_width + ih_height + ih_bit_depth + ih_color_type +
               ih_compression_method + ih_filter_method + ih_interlace_method
      ih_crc = [Zlib.crc32(string)].pack('N')
      return ih_size + string + ih_crc
    end
    #--------------------------------------------------------------------------
    # * Make IDAT
    #--------------------------------------------------------------------------
    def make_idat
      header  = "\x49\x44\x41\x54"
      data    = @mode == 0 ? make_bitmap_data0 : make_bitmap_data1
      data    = Zlib::Deflate.deflate(data, 8)
      crc     = [Zlib.crc32(header + data)].pack('N')
      size    = [data.length].pack('N')
      return size + header + data + crc
    end
    #--------------------------------------------------------------------------
    # * Make Bitmap Data 0
    #--------------------------------------------------------------------------
    def make_bitmap_data0
      gz = Zlib::GzipWriter.open('hoge.gz')
      t_Fx = 0
      w = @bitmap.width
      h = @bitmap.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          t_Fx += 1
          if t_Fx % 10000 == 0
            Graphics.update
          end
          if t_Fx % 100000 == 0
            s = data.pack("C*")
            gz.write(s)
            data.clear
          end
          color = @bitmap.get_pixel(x, y)
          red = color.red
          green = color.green
          blue = color.blue
          alpha = color.alpha
          data.push(red)
          data.push(green)
          data.push(blue)
          data.push(alpha)
        end
      end
      s = data.pack("C*")
      gz.write(s)
      gz.close   
      data.clear
      gz = Zlib::GzipReader.open('hoge.gz')
      data = gz.read
      gz.close
      File.delete('hoge.gz')
      return data
    end
    #--------------------------------------------------------------------------
    # * Make Bitmap Data Mode 1
    #--------------------------------------------------------------------------
    def make_bitmap_data1
      w = @bitmap.width
      h = @bitmap.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          color = @bitmap.get_pixel(x, y)
          red = color.red
          green = color.green
          blue = color.blue
          alpha = color.alpha
          data.push(red)
          data.push(green)
          data.push(blue)
          data.push(alpha)
        end
      end
      return data.pack("C*")
    end
    #--------------------------------------------------------------------------
    # * Make IEND
    #--------------------------------------------------------------------------
    def make_iend
      ie_size = [0].pack('N')
      ie_sign = 'IEND'
      ie_crc  = [Zlib.crc32(ie_sign)].pack('N')
      return ie_size + ie_sign + ie_crc
    end
  end
end

#===============================================================================
# Palette_Swap
#===============================================================================

module Palette_Swap
  def self.start
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(640,480)
    sprite.bitmap.draw_text(0, 200, 640, 32, 'Making color chart', 1)
    Graphics.update
    @colors = {}
    self.make_color_chart
    SPRITES.each do |name|
      filename = TYPE == 1 ? NAME + name : name + NAME
      sprite.bitmap.clear
      sprite.bitmap.draw_text(0, 200, 640, 32, "Converting #{name}", 1)
      Graphics.update
      bitmap = RPG::Cache.character(name, 0).clone rescue next
      self.color_swap(bitmap)
      bitmap.make_png(filename, 'Palette Swaps')
    end
    p 'Palette Swap Complete'
    exit
  end
  
  def self.make_color_chart
    old = RPG::Cache.character(OLD, 0).clone
    new = RPG::Cache.character(NEW, 0).clone
    old.width.times {|x| old.height.times {|y|
      c1 = old.get_pixel(x, y)
      c2 = new.get_pixel(x, y)
      next if [c1.alpha, c2.alpha].include?(0)
      differance = 0
      differance += (c1.red - c2.red).abs
      differance += (c1.green - c2.green).abs
      differance += (c1.blue - c2.blue).abs
      next unless differance > PRECISION
      @colors[[c1.red,c1.green,c1.blue]] = c2
    }}
  end
  
  def self.color_swap(bitmap)
    bitmap.width.times {|x| bitmap.height.times {|y|
      pixel = bitmap.get_pixel(x, y)
      next if pixel.alpha == 0
      key = [pixel.red, pixel.green, pixel.blue]
      if @colors.include?(key)
        bitmap.set_pixel(x, y, @colors[key])
      end
    }}
  end
  
  self.start if ENABLED
end