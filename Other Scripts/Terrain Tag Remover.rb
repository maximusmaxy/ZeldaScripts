#===============================================================================
# Terrain Tag Remover (Resets Terrain Tags in Tilesets back to 0)
#===============================================================================
# Author: Maximusmaxy
# Version 1.0: 31/12/12
#===============================================================================

module TTR
  #just put any ID's of tilesets you want the terrain tags removed
  REMOVE_IDS = []
  #set to to true to actually do it
  REMOVE = false
  
  def self.begin
    tilesets = load_data('Data/Tilesets.rxdata')
    REMOVE_IDS.each do |i|
      tileset = tilesets[i]
      next if tileset.nil?
      (0...tileset.terrain_tags.xsize).each {|j| tileset.terrain_tags[j] = 0}
    end
    save_data(tilesets,'Data/Tilesets.rxdata')
    p 'Please close the RMXP Editor without saving to complete the update'
    exit
  end  
  
  self.begin if REMOVE
end