#===============================================================================
# ¦ Maximusmaxy's Animated Scenes
#-------------------------------------------------------------------------------
# Animated Intro Scenes, Cutscene's and Credits.
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.4: 5/3/2012
#===============================================================================
# 
# Introduction:
# This script allows you to play animated scenes using a simplified ruby 
# syntax to create your cutscenes. You can have your cutscenes displayed
# before the title screen or at the start of a new game. You can even call
# for scenes to be shown with a script call.
#
# The instructions for how to setup your scenes are in the config.
#
#===============================================================================

$max_scene = 0.4

module SCENE
  
#===============================================================================
# Cutscene Setup
#-------------------------------------------------------------------------------
# To create a new cutscene you use the following format:
# NAME=<<end
# CODE
# end
#
# NAME is the name of the cutscene
# CODE is the cutscenes code
#
# You use the exact same format to create credits text:
# NAME=<<end
# CREDITS
# end
# 
# To then call that cutscene you would use the following in a script call:
# $scene = Scene_Cutscene.new(   <- make sure to break the line there if there
# SCENE::NAME)                      is not enough room to fit it on one line
#
# NAME is the name of the cutscene
#
#-------------------------------------------------------------------------------
# Syntax (How and when to use the code)
#-------------------------------------------------------------------------------
#
# NOTE: All text for filenames must be enclosed in "quotes"
#
# NOTE: If no Z value is set for a picture,panorama,text they will be displayed
# on top of each other in the order they were created. If a picture or sprite
# can't be seen it may be because it's behind another picture or sprite.
#
# NOTE: The code is white space sensitive, so don't leave any space between
# anything at all, unless its part of a file name or enclosed in "quotes"
#
#                             --Wait--
#
# Use the following code to delay the cutscene:
# 
# wait(FRAMES)
# FRAMES is the amount of time the delay takes.
#
# credits_wait
# waits for the credits to finish.
#
# keypress_wait
# waits for the decision key to be pressed.
#
#                             --Skip--
#
# The skip code enables/disables skipping of the cutscene:
#
# skip(SKIP)
# SKIP can either be true or false
#
#                             --Scene--
#
# By default, when the scenes end they transfer you to Scene_Map. To specify
# a different scene to transfer to use the following code.
#
# scene(NAME)
# NAME is the name of the scene. EG. scene(Scene_Menu)
# 
#                   --Pictures, Titles and Sprites--
#
# To create a picture you use the following code:
#
# NAME.FOLDER(PICTURE,X,Y,Z)
# 
# NAME is the name you are giving the picture
# FOLDER is the folder you are getting the picture from (picture or title)
# PICTURE is the filename of the picture
# X,Y,Z is the center location of the picture on the screen. Z can be ommitted.
#
# NOTE: picture names must begin with an @ symbol
# EG. @flower.picture('flower-01')
# 
# The following code may be appended to the end of the name you have given
# your picture to move, effect it.
# EG. @flower.x(50) sets the flowers x coordinate to 50
# 
# NAME.x(VALUE)
# NAME.y(VALUE)
# NAME.z(VALUE)
# VALUE is the x,y,z coordinate you are setting
#
# NAME.set(X,Y,Z)
# set X,Y,Z all at the same time. Z can be ommited
# 
# NAME.visible(VISIBLE)
# VISIBLE can be true or false
# 
# NAME.erase
# erases the picture
#
# For longer cutscenes it is recomended to erase pictures instead of just
# setting there visibility to false. Once a picture is erased it needs to be
# created again to show it again.
#
# The DURATION for the following code can be ommitted if the change is instant.
# DURATION is the amount of frames the selected transition takes.
# 
# NAME.move(X,Y,DURATION)
# X,Y are the coordinates you are moving to
#
# NAME.opacity(VALUE,DURATION)
# VALUE is the new opacity value
#
# NAME.fade_in(DURATION)
# fades in the sprite
#
# NAME.fade_out(DURATION)
# fades out the sprite
#
# NAME.color(R,G,B,A,DURATION)
# R,G,B,A is the color blended into the sprite
#
# NAME.flash(R,G,B,A,DURATION)
# R,G,B,A is the color of the flash 
#
# NAME.tone(R,G,B,GREY,DURATION)
# R,G,B,GREY is the tone blended into the sprite
#
# NAME.zoom(RATIO,DURATION)
# RATIO is the zoom ratio in percentage. Default percentage is 100.
#
# NAME.zoom_x(RATIO,DURATION)
# NAME.zoom_y(RATIO,DURATION)
# Same as above but it adjusts the x and y ratio's separetly
#
# NAME.blend(TYPE)
# TYPE can be 0,1,2. Normal = 0, Addition = 1, Subtraction = 2 
#
# NAME.angle(DEGREES)
# DEGREES is the angle of rotation
#
# NAME.mirror(MIRROR)
# MIRROR can be true or false, it flips the picture horizontally.
#
# NAME.phase(PHASE,SPEED)
# This function phases the sprite opacity in and out smoothly
# PHASE can be true or false for enabling and disabling
# SPEED is the amount of frames 1 phase takes
#
# NAME.animation(ID)
# NAME.animation_loop(ID)       loops the animation endlessly
# NAME.animation_stop           stops the animation loop
# ID is the id of the animation in the database.
#
#                     --Panorama's, Fogs and Planes--
#
# To create a panorama/fog you use the following code:
#
# NAME.FOLDER(PICTURE)
# 
# NAME is the name you are giving the panorama/fog
# FOLDER is the folder you are getting the picture from
# You can specify panorama, fog or plane(plane searches the pictures folder)
# PICTURE is the filename of the picture
#
# NOTE: panorama/fog names must begin with an @ symbol
# EG. @sky.panorama('sky-01')
# 
# The following code may be appended to the end of the name you have given
# your picture to move, effect it.
# EG. @flower.scroll(2,0) scrolls the panorama to the right
#
# NAME.scroll(X,Y)
# X,Y is the scrolling direction and speed
# if X is positive it scrolls to the right, left if negative.
# if Y is positive it scrolls down, up if negative.
#
# NAME.z(VALUE)
# NAME.visible(VISIBLE)
# NAME.erase
# NAME.opacity(VALUE)
# NAME.color(R,G,B,A,DURATION)
# NAME.tone(R,G,B,GREY,DURATION)
# NAME.zoom(RATIO,DURATION)
# NAME.blend(TYPE)
# Same as the effects in pictures and sprites, durations can be ommitted
#
#                             --Screen--
#
# Screen methods effect all the pictures, panoramas, fogs, text.
#
# weather(TYPE,STRENGTH,DURATION)
# TYPE is the type of weather. none = 0, rain = 1, storm = 2, snow = 3.
# STRENGTH is the strength of the weather. Can be 0-40.
# DURATION is how long the transition takes, it can be ommitted.
#
# fade_in(DURATION)
# fade_out(DURATION)
# flash(R,G,B,A,DURATION)
# color(R,G,B,A,DURATION)
# tone(R,G,B,GREY,DURATION)
# blend(TYPE)
# Same as the Sprite methods, but applied to the whole screen.
#
#                             --Text--
#
# To set the font name, size ect. use the following code.
# NOTE: The font name, size ect. must be set before creating the text if not 
# using default values.
#
# font_name(NAME)
# NAME of the font, must be enclosed in "quotes"
#
# font_size(VALUE)
# VALUE is the size of the font
#
# font_color(R,G,B,A)
# R,G,B,A is the color of the font
#
# font_bold(BOLD)
# BOLD can either be true or false 
#
# font_italic(ITALIC)
# ITALIC can either be true or false
#
# font_outline(OUTLINE)
# OUTLINE can either be true or false
# 
# font_shadow(SHADOW)
# SHADOW can either be true or false
#
# To then create text you use the following code.
# 
# NAME.text(TEXT,X,Y,Z)
# NAME is the name you are giving the text (Must start with an @ symbol)
# TEXT is the text displayed, must be enclosed in "quotes"
# X,Y,Z is the center location of the text on the screen. Z can be ommitted.
#
# You can use all the picture methods to move, effect the text.
#
#                            --Credits--
#
# Credits are created from a setup very similar to the way in which cutscenes
# are created, but instead of code it is just text.
#
# To create a credits picture use the following code:
# 
# NAME.credits(CREDITS, SPEED)
# NAME is the name you are giving the credits (Must start with an @ symbol)
# CREDITS is the name of the credits text in the setup.
# SPEED is the speed at which the credits scroll
# 
# To adjust the font you can use the font_name, font_size, font_color,
# font_bold, font_italic methods.
#
# You can use all the picture methods to move, effect the credits however it
# is not recomended to change the y value as it may interupt the scroll.
#
#                         --Subcutscene--
#
# You are able to run a cutscene within your cutscene by using one of the
# following codes. You can run as many subcutscenes as you need.
# Subcutscenes are not effected by keypress waiting. 
#
# NAME.run(SCENE)
# NAME is the name you are giving the subcutscene
# SCENE is the name of the cutscene specified in the setup
#
# NAME.loop(LOOP)
# LOOP can be true or false, determines wether the scene is replayed.
#
# NAME.stop
# stops the subcutscene
#
# NAME.fade_in(DURATION)
# NAME.fade_out(DURATION)
# fades in / fades out the subcutscene.
#
#                            --Audio--
#
# To play, stop or fade audio use one of the following codes:
# NOTE: Both Volume and Pitch can be ommitted to use the default values.
#
# bgm(NAME,VOLUME,PITCH)
# bgs(NAME,VOLUME,PITCH)
# me(NAME,VOLUME,PITCH)
# se(NAME,VOLUME,PITCH)
# NAME is the filename of the audio to be played
# VOLUME is the volume of the audio
# PITCH is the pitch of the audio
# 
# bgm_stop
# bgs_stop
# me_stop
# se_stop
# Stops the audio type
#
# bgm_fade(FRAMES)
# bgs_fade(FRAMES)
# me_fade(FRAMES)
# FRAMES is the amount of frames it takes for audio to fade out
# 
#-------------------------------------------------------------------------------

#this is an example of a simple pre title company name display

PZE=<<end
skip(false) #disable skip
bgm("Title Screen - Loading Music",70) #play the titlescreen BGM
@pze.title("Loading Screen",320,240) #draw a title screen
fade_in(40) #fade in
wait(40) #wait for fade in
skip(true) #enable skip
wait(80) #wait 80 frames
bgm_fade(40) #fade out the background music
fade_out(40) #fade out everything
wait(40) #wait for fade out
end

#This is the main Majora's Mask Intro scene

MM_MAIN=<<end
skip(false) #disable skipping
@subscene.run(MM_SUB) #run the subscene
@subscene.loop(true) #set the subscene loop to true
keypress_wait #wait for keypress
se("Title Screen - Press Start") #play the decision sound
@mask.picture("Majora's Mask (small)",205,200,1000) #create the mask
font_color(180,0,255,255) #change font to purple
font_size(28) #make font size larger
font_outline(true) #set the font outline to true
@text1.text("The Legend of",380,170,1000) #write the text
font_size(92) #make font big
font_name("T") #change font to triforce
@text2.text("Zelda",380,215,1000) #write text
font_size(28) #make font smaller
font_name("Arial") #change back to arial
@text3.text("Majora's Mask",380,265,1000) #write text
font_color(255,0,0,255) #change font to red
font_size(22) #make font small
@text4.text("Press Start",320,400,100) #write text
font_color(255,255,255,255) #change font to white
@text5.text("Project Zelda Engine",320,450,1000) #write text
font_size(40) #make font bigger
font_name("P") #change font to signpost font
@text6.text("Demo Version",520,80,1000) #write text
fade_in(10) #fade all the text in
wait(10) #wait for fade in
@text4.phase(true,60) #make text4's opacity phase in and out
keypress_wait #wait for key press
se("Title Screen - Press Start") #play decision sound
fade_out(20) #fade out the scene
@subscene.fade_out(20) #fade out the subscene
wait(20) #wait for fade out
end

#This is a subscene of the Majora's Mask Intro Scene

MM_SUB=<<end
@mask1.picture("Majora's Mask (large)",320,230)
@mask1.zoom(10)
@mask1.zoom_y(100,200)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(25,20)
@mask1.mirror(true)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(45,20)
@mask1.mirror(false)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(65,20)
@mask1.mirror(true)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(85,20)
@mask1.mirror(false)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(100,20)
@mask1.mirror(true)
wait(20)
@mask1.zoom_y(10,200)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(85,20)
@mask1.mirror(false)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(65,20)
@mask1.mirror(true)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(45,20)
@mask1.mirror(false)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(25,20)
@mask1.mirror(true)
wait(20)
@mask1.zoom_x(0,20)
wait(20)
@mask1.zoom_x(10,20)
@mask1.mirror(false)
wait(20)
end

#===============================================================================
# Configuration
#===============================================================================
  #Set the intro and title display type. Always = 1, Not Debug = 2, Never = 3
  TYPE = 2
  #Choose which scene to show at the start of a new game.
  INTRO_SCENE = nil                           #set to nil if not applicable
  #Choose which scenes to show before the title screen.
  TITLE_SCENES = [PZE,MM_MAIN]                #set to [] if not applicable
  #Choose which scene index to jump back to when the cancel button is pressed
  #at the title screen or after a gameover/quit. 0 is the first scene.
  TITLE_INDEX = 1
#===============================================================================
# End Configuration
#===============================================================================

end

#===============================================================================
# Bitmap
#===============================================================================

class Bitmap
  #draws outlined text for cutscenes
  def draw_text_co(x, y, w, h, t, a = 0)
    original_color = self.font.color.clone
    self.font.color = Color.new(0,0,0,255)
    draw_text(x - 1, y - 1, w, h, t, a)
    draw_text(x - 1, y + 1, w, h, t, a)
    draw_text(x + 1, y - 1, w, h, t, a)
    draw_text(x + 1, y + 1, w, h, t, a)
    self.font.color = original_color
    draw_text(x, y, w, h, t, a)    
  end
  #draws shadowed text for cutscenes
  def draw_text_cs(x, y, w, h, t, a = 0)
    original_color = self.font.color.clone
    self.font.color = Color.new(0,0,0,100)
    draw_text(x + 2, y + 2, w, h, t, a)
    self.font.color = original_color
    draw_text(x, y, w, h, t, a)   
  end
end

#===============================================================================
# Cutscene_Module
#===============================================================================

#this module is a mixin for cutscene sprites, planes and viewports
module Cutscene_Module
  def initialize(*args)
    super(*args)
    #additional instance variables for the classes
    @opacity_duration = 0
    @opacity_target = 255
    @color_duration = 0
    @color_target = self.color
    @tone_duration = 0
    @tone_target = self.tone
    @zoom_x_duration = 0
    @zoom_y_duration = 0
    @zoom_target_x = 1.0
    @zoom_target_y = 1.0
  end
  
  def update(*args)
    super(*args)
    #update opacity
    if @opacity_duration > 0
      d = @opacity_duration
      self.opacity = (self.opacity * (d - 1) + @opacity_target) / d
      @opacity_duration -= 1
    end
    #update duration
    if @color_duration > 0
      d = @color_duration
      self.color.red = (self.color.red * (d - 1) + @color_target.red) / d
      self.color.green = (self.color.green * (d - 1) + @color_target.green) / d
      self.color.blue = (self.color.blue * (d - 1) + @color_target.blue) / d
      self.color.alpha = (self.color.alpha * (d - 1) + @color_target.alpha) / d
      @color_duration -= 1
    end
    #update tone
    if @tone_duration > 0
      d = @tone_duration
      self.tone.red = (self.tone.red * (d - 1) + @tone_target.red) / d
      self.tone.green = (self.tone.green * (d - 1) + @tone_target.green) / d
      self.tone.blue = (self.tone.blue * (d - 1) + @tone_target.blue) / d
      self.tone.grey = (self.tone.grey * (d - 1) + @tone_target.grey) / d
      @tone_duration -= 1
    end
    #update zoom ratios
    if @zoom_x_duration > 0
      d = @zoom_x_duration
      self.zoom_x = (self.zoom_x * (d - 1) + @zoom_target_x) / d
      @zoom_x_duration -= 1
    end
    if @zoom_y_duration > 0
      d = @zoom_y_duration
      self.zoom_y = (self.zoom_y * (d - 1) + @zoom_target_y) / d
      @zoom_y_duration -= 1
    end
  end
  #change opacity
  def change_opacity(target, duration)
    @opacity_target = target
    @opacity_duration = duration
  end
  #change color
  def change_color(color, duration)
    @color_target = color
    @color_duration = duration
  end
  #change tone
  def change_tone(tone, duration)
    @tone_target = tone
    @tone_duration = duration
  end
  #change zoom ratios
  def change_zoom(xy, duration)
    @zoom_target_x = xy / 100.0
    @zoom_target_y = xy / 100.0
    @zoom_x_duration = duration
    @zoom_y_duration = duration
  end
  
  def change_zoom_x(x, duration)
    @zoom_target_x = x / 100.0
    @zoom_x_duration = duration
  end
  
  def change_zoom_y(y, duration)
    @zoom_target_y = y / 100.0
    @zoom_y_duration = duration
  end
end

#===============================================================================
# Sprite_Cutscene
#===============================================================================

class Sprite_Cutscene < RPG::Sprite
  include Cutscene_Module
  attr_accessor :text_flag
  def initialize(viewport = nil)
    super(viewport)
    @move_x = 0
    @move_y = 0
    @move_duration = 0
    @text_flag = false
    @text_x = 0
    @text_y = 0
    @phase = false
    @phase_count = 0
    @phase_speed = 0
    @spin = false
    @spin_count = 0
    @spin_speed = 0
    @scroll_speed = 0
    @outline = false
    @shadow = false
  end
  
  def dispose
    #dispose bitmap if the bitmap is a text bitmap
    if @text_flag
      self.bitmap.dispose
    end
    super
  end
  
  def update
    super
    #move to the specified location
    if @move_duration > 0
      self.x = (self.x * (@move_duration - 1) + @move_x) / @move_duration
      self.y = (self.y * (@move_duration - 1) + @move_y) / @move_duration
      @move_duration -= 1
    end
    #phase opacity in and out
    if @phase
      if @phase_count < @phase_speed / 2
        self.opacity -= 300 / @phase_speed * 2
      else
        self.opacity += 300 / @phase_speed * 2
      end
      @phase_count += 1
      @phase_count = 0 if @phase_count == @phase_speed
    end
    #scroll
    self.y -= @scroll_speed
  end
  
  def bitmap=(bitmap)
    super(bitmap)
    #center the bitmap
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end

  #set the move to location
  def move(x, y, duration)
    @move_duration = duration
    @move_x = x - @text_x
    @move_y = y - @text_y
  end
  #set phase opacity settings
  def phase(phase, speed)
    @phase = phase
    @phase_speed = speed
    @phase_count = 0
    self.opacity = 255
  end
  #set the text to be drawn outlined
  def outline=(bool)
    @outline = bool
    @shadow = false if bool
  end
  #set the text to be drawn shadowed
  def shadow=(bool)
    @shadow = bool
    @outline = false if bool
  end
  #draw text normal, outlined or shadowed
  def draw_text(*args)
    if @outline
      self.bitmap.draw_text_co(*args)
    elsif @shadow
      self.bitmap.draw_text_cs(*args)
    else
      self.bitmap.draw_text(*args)
    end
  end
  #set up the bitmap to display credits
  def credits(text, speed, name, size, color, bold, italic, outline, shadow)
    #reset original position
    self.ox = self.oy = 0
    #flag bitmap for disposal
    @text_flag = true
    #get the text array
    text = text.split("\n")
    #setup the bitmap
    bitmap_size = 0
    font_size = size
    #check each line
    text.each do |line|
      #if it is a font changing line
      if line =~ /font_(\w*)\((.*)\)/
        #change font size if needed
        font_size = $2.to_i if $1 == 'size'
        #skip bitmap size increment
        next
      end
      #increase the bitmap size by the font size
      bitmap_size += (font_size + 10)
    end
    self.bitmap = Bitmap.new(640, bitmap_size)
    #setup font
    self.bitmap.font.name = name
    self.bitmap.font.size = size
    self.bitmap.font.color = color
    self.bitmap.font.bold = bold
    self.bitmap.font.italic = italic
    @outline = outline
    @shadow = shadow
    #location to draw the text
    y = 0
    #loop through each line of text
    text.each do |line|
      #adjust the font if needed
      if line =~ /font_(\w*)\(['"]?(\w*)['"]?,?(\d*),?(\d*),?(\d*)\)/
        case $1
        when 'name'
          self.bitmap.font.name = $2
        when 'size'
          self.bitmap.font.size = $2.to_i
        when 'color'
          self.bitmap.font.color = Color.new($2.to_i,$3.to_i,$4.to_i,$5.to_i)
        when 'bold'
          eval("self.bitmap.font.bold = #{$2}")
        when'italic'
          eval("self.bitmap.font.italic = #{$2}")
        when 'outline'
          eval("@outline = #{$2}")
        when 'shadow'
          eval("@shadow = #{$2}")
        end
        next
      end
      #draw the text
      draw_text(0, y, 640, self.bitmap.font.size, line, 1)
      #increment the next drawing location
      y += (self.bitmap.font.size + 10)
    end
    #move to the bottom of the screen and set the scrolling speed
    self.y = 480
    @scroll_speed = speed
    #return the time taken to scroll to the end
    return (bitmap_size + 480) / speed
  end
end

#===============================================================================
# Plane_Cutscene
#===============================================================================

class Plane_Cutscene < Plane
  include Cutscene_Module
  def initialize(viewport = nil)
    super(viewport)
    @scroll_x = 0
    @scroll_y = 0
  end
  
  def update
    #scroll the plane
    self.ox += @scroll_x
    self.oy += @scroll_y
  end
  #set the scroll speed
  def scroll(x, y)
    @scroll_x = x
    @scroll_y = y
  end
end

#===============================================================================
# Viewport_Cutscene
#===============================================================================

class Viewport_Cutscene < Viewport
  include Cutscene_Module
end

#===============================================================================
# Weather_Cutscene
#===============================================================================

class Weather_Cutscene < RPG::Weather
  def initialize(viewport = nil)
    super(viewport)
    @target_max = 0
    @target_duration = 0
    @target_type = 0
  end
  
  def update
    super
    #change the maximum number of bitmaps
    if @target_duration > 0
      d = @target_duration
      self.max = (self.max * (d - 1) + @target_max) / d
      @target_duration -= 1
      self.type = @target_type if @target_duration == 0
    end
  end
  #change weather
  def change_weather(new_type, strength, duration)
    if duration == 0
      self.type = new_type
      self.max = strength
    else
      @target_max = strength
      @target_duration = duration
      @target_type = new_type
      self.type = new_type if @type == 0
    end
  end
end

#===============================================================================
# Scene_Cutscene
#===============================================================================
  
class Scene_Cutscene
  #Subclass for the cutscene code
  class Code
    attr_accessor :index
    attr_accessor :wait
    attr_accessor :loop
    attr_accessor :main
    attr_accessor :sprites
    def initialize(code)
      #get the code array
      @code = code.split("\n")
      @index = 0
      @wait = 0
      @loop = false
      @main = false
      @sprites = []
      pre_cache_images
    end
    #retruns the code at the current index
    def code
      return @code[@index]
    end
    #returns the size of the code array
    def size
      return @code.size
    end
    #precache the images for less lag
    def pre_cache_images
      @code.each do |line|
        if line =~ /.*\.(\w*)\((['"].*['"]),?(\d*)\)/
          case $1
          when 'picture', 'title'
            eval("RPG::Cache.#{$1}(#{$2})")
          when 'panorama', 'fog', 'plane'
            folder = $1 == 'plane' ? 'picture' : $1
            eval("RPG::Cache.#{folder}(#{$2},#{$3.to_i})")
          end        
        end
      end
    end
  end
  
  def initialize(code)
    #make the main code object
    @code = Code.new(code)
    @code.main = true
    #initialize missing globals
    $data_animations = load_data("Data/Animations.rxdata") if $data_animations.nil?
    $game_system = Game_System.new if $game_system.nil?
    $game_temp = Game_Temp.new if $game_temp.nil?
    #initialize variables
    @skip = true
    @wait = 0
    @count = 0
    @credits_wait = 0
    @keypress_wait = false
    @fading = false
    @font_name = Font.default_name
    @font_size = Font.default_size
    @font_color = Color.new(255,255,255,255)
    @font_bold = false
    @font_italic = false
    @font_outline = false
    @font_shadow = false
    @scene_name = 'Scene_Map'
    @childs = []
  end
  
  def main
    #initialize the sprites, viewport and weather
    @viewport = Viewport_Cutscene.new(0,0,640,480)
    @weather = Weather_Cutscene.new(@viewport)
    #end all audio
    Audio.bgm_stop
    Audio.bgs_stop
    Audio.me_stop
    Audio.se_stop
    #update once to get everything in the correct position
    evaluate_code(@code)
    @childs.each{|child| evaluate_code(child)}
    #transition
    Graphics.transition
    #main loop
    loop do
      Graphics.update
      Input.update
      update
      #break if the code has reached the end and code isn't waiting or fading
      break if (@code.index >= @code.size && @code.wait == 0) || @fading
    end
    #wait for everything to fade
    if @fading
      20.times do
        Graphics.update
        @code.sprites.each {|sprite| sprite.update}
        @childs.each{|child| child.sprites.each{|sprite| sprite.update}}
        @weather.update
      end
    end
    #freeze
    Graphics.freeze
    #dispose everything
    @code.sprites.each {|sprite| sprite.dispose}
    @childs.each{|child| child.sprites.each{|sprite| sprite.dispose}}
    @viewport.dispose
    @weather.dispose
    #end all audio
    Audio.bgm_stop
    Audio.bgs_stop
    Audio.me_stop
    Audio.se_stop
    #change to title scene if showing pretitle cutscenes
    if $cutscenes_shown < SCENE::TITLE_SCENES.size
      $cutscenes_shown += 1
      $scene = Scene_Title.new
    else
      #else transfer to the specified scene
      eval("$scene = #{@scene_name}.new")
      #autoplay music if scene is a map
      $game_map.autoplay if $scene.is_a?(Scene_Map)
      #play the title scenes again if the scene is a title
      $cutscenes_shown = SCENE::TITLE_INDEX if $scene.is_a?(Scene_Title)
    end
    #clear the cache
    RPG::Cache.clear
  end
  
  def update
    #update the sprites, planes, viewport and weather
    @code.sprites.each{|sprite| sprite.update}
    @childs.each{|child| child.sprites.each{|sprite| sprite.update}}
    @viewport.update
    @weather.update
    #increment the count
    @count += 1
    #break if cutscene is skipped
    if (Input.trigger?(Input::B) || Input.trigger?(Input::C)) && @skip
      @code.sprites.each {|sprite| sprite.change_opacity(0,20)}
      @childs.each{|child| child.sprites.each{|sprite| sprite.change_opacity(0,20)}}
      @weather.change_weather(0, 0, 20)
      Audio.bgm_fade(500)
      Audio.bgs_fade(500)
      Audio.me_fade(500)
      @fading = true
      return
    end
    #update the child code
    @childs.each{|child| evaluate_code(child)}
    #wait for keypress
    if @keypress_wait
      if Input.trigger?(Input::C)
        @keypress_wait = false
      else
        return
      end
    end
    #update the main code
    evaluate_code(@code)
  end
  
  def evaluate_code(code)
    #wait if there is a wait count
    if code.wait > 0
      code.wait -= 1
      return
    end
    #loop until the index has reached the end of the code array
    loop do
      #check the regexp
      if code.code =~ /(@?\w*)\.?(\w*)\(?(".*")?,?(-?\w*),?(-?\d*),?(-?\d*),?(\d*),?(\d*)\)?/
        #locals
        w1, w2, w3 = $1, $2, $3
        v1, v2, v3, v4, v5 = $4, $5, $6, $7, $8
        d1, d2, d3, d4, d5 = $4.to_i, $5.to_i, $6.to_i, $7.to_i, $8.to_i
        text = w3.gsub(/['"]/, '') unless w3.nil?
        volume = v1 == '' ? 100 : d1
        pitch = v2 == '' ? 100 : d2
        case w1
        #wait
        when 'wait'
          code.wait = d1
          code.index += 1
          return
        when 'credits_wait'
          code.wait = @credits_wait - @count
          code.index += 1
          return
        when 'keypress_wait'
          next unless code.main
          @keypress_wait = true
          code.index += 1
          return
        #skip
        when 'skip'
          eval("@skip = #{v1}")
        #scene
        when 'scene'
          @scene_name = v1
        #audio
        when 'bgm'
          Audio.bgm_play("Audio/BGM/#{text}", volume, pitch)
        when 'bgm_stop'
          Audio.bgm_stop
        when 'bgm_fade'
          Audio.bgm_fade(d1 * 25) 
        when 'bgs'
          Audio.bgs_play("Audio/BGS/#{text}", volume, pitch)
        when 'bgs_stop'
          Audio.bgs_stop
        when 'bgs_fade'
          Audio.bgs_fade(d1 * 25) 
        when 'me'
          Audio.me_play("Audio/ME/#{text}", volume, pitch)
        when 'me_stop'
          Audio.me_stop
        when 'me_fade'
          Audio.me_fade(d1 * 25) 
        when 'se'
          Audio.se_play("Audio/SE/#{text}", volume, pitch)
        when 'se_stop'
          Audio.se_stop
        #viewport
        when 'flash'
          @viewport.flash(Color.new(d1,d2,d3,d4),d5)
        when 'color'
          if v5 == ''
            @viewport.color = Color.new(d1,d2,d3,d4)
          else
            @viewport.change_color(Color.new(d1,d2,d3,d4),d5) 
          end
        when 'tone'
          if v5 == ''
            @viewport.tone = Tone.new(d1,d2,d3,d4)
          else
            @viewport.change_tone(Tone.new(d1,d2,d3,d4),d5) 
          end
        #screen
        when 'weather'
          @weather.change_weather(d1,d2,d3)
        when 'fade_in'
          code.sprites.each do |sprite|
            opacity = sprite.opacity
            sprite.opacity = 0
            sprite.change_opacity(opacity,d1)
          end
        when 'fade_out'
          code.sprites.each do |sprite|
            sprite.phase(false,0) if sprite.is_a?(Sprite_Cutscene)
            sprite.change_opacity(0,d1)
          end
          @weather.change_weather(0, 0, d1)
        when 'blend'
          code.sprites.each {|sprite| sprite.blend_type = d1}
        #font
        when 'font_name'
          @font_name = text
        when 'font_size'
          @font_size = d1
        when 'font_color'
          @font_color = Color.new(d1,d2,d3,d4)
        when 'font_bold'
          eval("@font_bold = #{v1}")
        when 'font_italic'
          eval("@font_italic = #{v1}")
        when 'font_outline'
          eval("@font_outline = #{v1}")
        when 'font_shadow'
          eval("@font_shadow = #{v1}")
        #error
        else
          if w1 != '' && w1[0,1] != '@'
            print "Error with code: #{@code[@index]}\n'#{w1}' is invalid code"
          end
        end
        #sprite
        case w2
        when 'picture', 'title'
          eval("#{w1} = Sprite_Cutscene.new(@viewport)")
          eval("#{w1}.bitmap = RPG::Cache.#{w2}(#{w3})")
          eval("#{w1}.x = #{d1}\n#{w1}.y = #{d2}")
          eval("#{w1}.z = #{d3}") if v3 != ''
          eval("code.sprites << #{w1}")
        when 'x'
          eval("#{w1}.x = #{d1}")
        when 'y'
          eval("#{w1}.y = #{d1}")
        when 'set'
          eval("#{w1}.x = #{d1}\n#{w1}.y = #{d2}")
          eval("#{w1}.z = #{d3}") if v3 != ''
        when 'move'
          eval("#{w1}.move(#{d1},#{d2},#{d3})")
        when 'flash'
          eval("#{w1}.flash(Color.new(#{d1},#{d2},#{d3},#{d4}),#{d5})")
        when 'angle'
          eval("#{w1}.angle = #{d1}")
        when 'mirror'
          eval("#{w1}.mirror = #{v1}")
        when 'animation'
          eval("#{w1}.animation($data_animations[#{d1}], false)")
        when 'animation_loop'
          eval("#{w1}.loop_animation($data_animations[#{d1}])")
        when 'animation_stop'
          eval("#{w1}.dispose_animation")
        when 'phase'
          eval("#{w1}.phase(#{v1},#{d2})")
        #plane
        when 'panorama', 'fog', 'plane'
          folder = w2 == 'plane' ? 'picture' : w2
          eval("#{w1} = Plane_Cutscene.new(@viewport)")
          eval("#{w1}.bitmap = RPG::Cache.#{folder}(#{w3},#{d1})")
          eval("code.sprites << #{w1}")
        when 'scroll'
          eval("#{w1}.scroll(#{d1},#{d2})")
        #sprite and plane
        when 'z'
          eval("#{w1}.z = #{d1}")
        when 'visible'
          eval("#{w1}.visible = #{v1}")
        when 'erase'
          index = eval("code.sprites.index(#{w1})")
          eval("code.sprites[#{index}].dispose")
          eval("code.sprites.delete_at(#{index})")
        when 'opacity'
          if v2 == ''
            eval("#{w1}.opacity = #{d1}")
          else
            eval("#{w1}.change_opacity(#{d1},#{d2})")
          end
        when 'fade_in'
          opacity = eval("#{w1}.opacity")
          if eval("#{w1}").is_a?(Code)
            eval("#{w1}.sprites.each do |sprite|;" +
                 'sprite.opacity = 0;' +
                 "sprite.change_opacity(255,#{d1});end")
          else    
            eval("#{w1}.opacity = 0")
            eval("#{w1}.change_opacity(255,#{d1})")
          end
        when 'fade_out'
          if eval("#{w1}").is_a?(Code)
            eval("#{w1}.sprites.each{|sprite| sprite.change_opacity(0,#{d1})}")
          else
            eval("#{w1}.phase(false,0) if #{w1}.is_a?(Sprite_Cutscene)")
            eval("#{w1}.change_opacity(0,#{d1})")
          end
        when 'color'
          if v5 == ''
            eval("#{w1}.color = Color.new(#{d1},#{d2},#{d3},#{d4})")
          else
            eval("#{w1}.change_color(Color.new(#{d1},#{d2},#{d3},#{d4}),#{d5})")
          end
        when 'tone'
          if v5 == ''
            eval("#{w1}.tone = Tone.new(#{d1},#{d2},#{d3},#{d4})")
          else
            eval("#{w1}.change_tone(Tone.new(#{d1},#{d2},#{d3},#{d4}),#{d5})")
          end
        when 'zoom'
          if v2 == ''
            eval("#{w1}.zoom_x = #{d1} / 100.0")
            eval("#{w1}.zoom_y = #{d1} / 100.0")
          else
            eval("#{w1}.change_zoom(#{d1},#{d2})")
          end
        when 'zoom_x'
          if v2 == ''
            eval("#{w1}.zoom_x = #{d1} / 100.0")
          else
            eval("#{w1}.change_zoom_x(#{d1},#{d2})")
          end
        when 'zoom_y'
          if v2 == ''
            eval("#{w1}.zoom_y = #{d1} / 100.0")
          else
            eval("#{w1}.change_zoom_y(#{d1},#{d2})")
          end
        when 'blend'
          eval("#{w1}.blend_type = #{d1}")
        #text
        when 'text'
          eval("#{w1} = Sprite_Cutscene.new(@viewport)")
          eval("#{w1}.bitmap = Bitmap.new(640,@font_size + 10)")
          eval("#{w1}.bitmap.font.name = @font_name")
          eval("#{w1}.bitmap.font.size = @font_size")
          eval("#{w1}.bitmap.font.color = @font_color")
          eval("#{w1}.bitmap.font.bold = @font_bold")
          eval("#{w1}.bitmap.font.italic = @font_italic")
          eval("#{w1}.outline = @font_outline")
          eval("#{w1}.shadow = @font_shadow")
          eval("#{w1}.draw_text(0,0,640,@font_size,#{w3},1)")
          eval("#{w1}.text_flag = true")
          eval("#{w1}.x = #{d1}\n#{w1}.y = #{d2}")
          eval("#{w1}.z = #{d3}") if v3 != ''
          eval("code.sprites << #{w1}")
        #credits
        when 'credits'
          font = [@font_name, @font_size, @font_color, @font_bold, 
                  @font_italic, @font_outline, @font_shadow]
          eval("#{w1} = Sprite_Cutscene.new(@viewport)")
          eval("@credits_wait = #{w1}.credits(SCENE::#{v1},#{d2},*font)")
          eval("#{w1}.text_flag = true")
          eval("code.sprites << #{w1}")
          @credits_wait += @count
        #sub cutscene
        when 'run'
          unless eval("#{w1}.nil?")
            eval("#{w1}.sprites.each {|sprite| sprite.dispose}")
            eval("#{w1}.sprites.clear")
          end
          eval("#{w1} = Code.new(SCENE::#{v1})")
          eval("@childs << #{w1}")
        when 'loop'
          eval("#{w1}.loop = #{v1}")
        when 'stop'
          unless eval("#{w1}.nil?")
            eval("#{w1}.sprites.each {|sprite| sprite.dispose}")
            eval("#{w1}.sprites.clear")
          end
        #error
        else
          if w2 != ''
            print "Error with code: #{@code[@index]}\n'.#{w2}' is invalid code"
          end
        end
      end
      #increment the index
      code.index += 1
      #if code has reached the end
      if code.index >= code.size
        #loop to beginning if the code is looped
        if code.loop
          code.sprites.each {|sprite| sprite.dispose }
          code.sprites.clear
          code.index = 0
        #else break
        else
          break
        end
      end
    end
  end
end

#===============================================================================
# Scene_Title
#===============================================================================

$cutscenes_shown = 0

class Scene_Title
  alias max_cutscene_main_later main
  alias max_cutscene_update_later update
  alias max_cutscene_new_later command_new_game
  def main
    #display the intro cutscene
    if $cutscenes_shown < SCENE::TITLE_SCENES.size
      if (SCENE::TYPE == 1 || (SCENE::TYPE == 2 && !$DEBUG))
        $scene = Scene_Cutscene.new(SCENE::TITLE_SCENES[$cutscenes_shown])
        return
      else
        $cutscenes_shown = SCENE::TITLE_SCENES.size
      end
    end
    #display the title
    max_cutscene_main_later
    #repeat scene if showing an intro scene
    $scene = self if $cutscenes_shown < SCENE::TITLE_SCENES.size
  end
  
  def update
    #if cancel is pressed, show the intro scenes again
    if Input.trigger?(Input::B)
      if (SCENE::TYPE == 1 || (SCENE::TYPE == 2 && !$DEBUG))
        if $cutscenes_shown >= SCENE::TITLE_SCENES.size &&
           SCENE::TITLE_INDEX < SCENE::TITLE_SCENES.size
          #compatibility for zelda title
          if (!$pze_ztitle.nil? && $pze_ztitle >= 0.2 && @scene == 1) ||
             $pze_ztitle.nil?
            $cutscenes_shown = SCENE::TITLE_INDEX
            Audio.bgm_stop
            $scene = nil
          end
        end
      end
    end
    max_cutscene_update_later
  end
  
  def command_new_game
    max_cutscene_new_later
    #change scene to the intro scene if it exists 
    unless SCENE::INTRO_SCENE.nil?
      if (SCENE::TYPE == 1 || (SCENE::TYPE == 2 && !$DEBUG))
        $scene = Scene_Cutscene.new(SCENE::INTRO_SCENE)
      end
    end
  end
end

#===============================================================================
# Scene_End
#===============================================================================

class Scene_End
  alias max_cutscene_title_later command_to_title
  def command_to_title
    max_cutscene_title_later
    #show the cutscenes again
    $cutscenes_shown = SCENE::TITLE_INDEX
  end
end

#===============================================================================
# Scene_Gameover
#===============================================================================

class Scene_Gameover
  alias max_cutscene_main_later main
  def main
    max_cutscene_main_later
    #show the cutscenes again
    $cutscenes_shown = SCENE::TITLE_INDEX
  end
end