#===============================================================================
# Map Merger (Converter)
#===============================================================================
# Author: Maximusmaxy
# Version 1.0: 31/12/12
#===============================================================================
#
# NOTE: This script consists of 2 parts. 
#       The Loader script belongs on your MAIN PROJECT.
#       The Converter script belongs on your ADDITIONAL PROJECTS.
#
# Introduction:
# This script allows you to break the 999 map limit by merging the maps of
# multiple projects into 1 project. 
#
# Instructions:
# To use this script follow this step by step guide. It is assumed that you
# have reached your map limit of 999 maps.
#
# Step 1:
# Copy your project to another folder, delete all the maps and copy the
# converter script on the new project
#
# Step 2:
# Continue your project as normal, until you want to playtest 
#
# Step 3:
# Set the conversion switch to true and run the project. When the conversion
# Is complete a confirmation message will pop up and the game will close.
#
# Step 4:
# Copy all the files from the conversions folder into your main projects Data
# Folder, overwrite if neccesary.
#
# Step 5:
# Copy the loader script on the main project and add the Conversion ID of the
# converted project into the LOAD_IDS array on the loader script.
#
# Step 6:
# Repeat this process every time you need more maps. Remember to change the
# Conversion ID for each new project, and make sure the ID is greater then 0.
# 
# Transferring:
# To transfer your player between maps from different projects use the call
# script:
#
# MM.transfer(MAP_ID,X,Y,DIRECTION,FADE)
# MAP_ID is the ID of the new map
# XY is the location on that map
# DIRECTION is the direction you will face (Defaults as retain)
# 0 = Retain, 2 = Down, 4 = Left, 6 = Right, 8 = Up
# FADE is true for fading, false for no fade. (Defaults as true)
#
# The ID's follow this format:
# ID = Map_ID + Converison_ID * 1000
#
# EG. to transfer between map 500 on your main project to map 500 on your
# conversion ID 1 project you would use MAP_ID = 500 + 1 * 1000 = 1500
# ie. MM.transfer(1500,X,Y)
# 
# Inversely you would use MM.transfer(500,X,Y) to get back to map 500 on 
# your main project.
#
#===============================================================================

module MM

#===============================================================================
# Configuration
#===============================================================================
  #Convert the new map data
  CONVERT = false
  #Conversion ID
  ID = 1
#===============================================================================
# End Configuration
#===============================================================================

  def self.convert
    if ID < 1
      p 'Conversion Abborted.', 'ID must be 1 or greater'
      exit
    end
    Dir.mkdir('Conversions') if !FileTest.directory?('Conversions')
    title = Sprite.new
    title.y = 200
    title.bitmap = Bitmap.new(640,32)
    title.bitmap.draw_text(0,0,640,32,'Converting Maps',1)
    message = Sprite.new
    message.y = 240
    message.bitmap = Bitmap.new(640,32)
    time = Time.now
    info = load_data("Data/MapInfos.rxdata")
    info.keys.sort.each do |key|
      map = load_data(sprintf("Data/Map%03d.rxdata",key)) rescue next
      message.bitmap.clear
      message.bitmap.draw_text(0,0,640,32,"Map #{key}: #{info[key].name}",1)
      Graphics.update
      map.events.each_value do |event|
        if Time.now - time > 9
          time = Time.now
          Graphics.update
        end
        event.pages.each do |page|
          page.list.each do |command|
            if command.code == 201 && command.parameters[0] == 0
              command.parameters[1] += ID * 1000
            end
          end
        end
      end
      save_data(map,sprintf("Conversions/Map%03d.rxdata",key + ID * 1000))
      info[key + ID * 1000] = info[key]
      info.delete(key)
    end
    save_data(info,sprintf("Conversions/MapInfos%03d.rxdata",ID))
    p 'Conversion complete.', 
      'Copy the all the files from your Conversions folder into the Data ' +
      "folder from your main project and add #{ID} to the LOAD_IDS of the " +
      'loader script.',
      'Remember to set CONVERT to false on the converter script'
    [title,message].each{|sprite| sprite.bitmap.dispose; sprite.dispose}
    exit
  end
  
  self.convert if CONVERT
end