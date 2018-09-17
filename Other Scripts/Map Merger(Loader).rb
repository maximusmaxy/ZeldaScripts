#===============================================================================
# Map Merger (Loader)
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
  #Load Map Info, Only required if using scripts that require Map Info data
  LOAD = true
  #ID's to load, numbers are the same as the conversion ID's
  LOAD_IDS = [] #Add ID's separeted with a comma eg.[1,2,3]
#===============================================================================
# End Configuration
#===============================================================================

  def self.load
    return if LOAD_IDS.empty?
    info = load_data('Data/MapInfos.rxdata')
    LOAD_IDS.each do |i|
      new_info = load_data(sprintf("Data/MapInfos%03d.rxdata", i)) rescue next
      new_info.each{|key,value| info[key] = value}
    end
    save_data(info, 'Data/MapInfos.rxdata')
  end
  
  self.load if LOAD
  
  def self.transfer(map,x,y, direction = 0, fade = true)
    $game_temp.player_new_map_id = map
    $game_temp.player_new_x = x
    $game_temp.player_new_y = y
    $game_temp.player_new_direction = direction
    if fade && $scene.is_a?(Scene_Map)
      Graphics.freeze
      $game_temp.transition_processing = true
      $game_temp.transition_name = ""
      $scene.transfer_player
    else
      $game_temp.player_transferring = true
    end
    return
  end
end