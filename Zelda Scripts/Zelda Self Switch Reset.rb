#===============================================================================
# ¦ Maximusmaxy's Self Switch Reset
#-------------------------------------------------------------------------------
# Resets self switches when changing maps
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.1: 14/3/12
#===============================================================================
# 
# Introduction:
# Resets self switches when changing maps
#
# Instructions:
# Use the following comment flag to reset self switches:
#
# \reset
# 
# If you want to specify only certain switches to be refreshed you may put
# the letters in brackets on the end like so:
#
# \reset(A,B,C,D)
#
#===============================================================================

#===============================================================================
# Game_Event
#===============================================================================

class Game_Event < Game_Character
  attr_reader :reset_switches
  alias max_reset_refresh_later refresh
  def refresh
    max_reset_refresh_later
    @reset_switches = []
    unless @list.nil? || @erased
      @list.each do |command|
        if command.code == 108
          if command.parameters[0] =~ /\\reset\(?(.*)/
            if $1 == ''
              @reset_switches = ['A','B','C','D']
            else
              switches = $1.split(',')
              switches.each do |switch| 
                switch.gsub!(/'|"|\)/) {|s| s = ''}
                @reset_switches << switch.upcase
              end
            end
          end
        else
          break
        end
      end
    end
  end
end

#===============================================================================
# Scene_Map
#===============================================================================

class Scene_Map
  alias max_reset_transfer_later transfer_player
  def transfer_player
    if $game_map.map_id != $game_temp.player_new_map_id
      $game_map.events.each do |id, event|
        event.reset_switches.each do |switch|
          $game_self_switches[[$game_map.map_id, id, switch]] = false
        end
      end
    end     
    max_reset_transfer_later
  end
end