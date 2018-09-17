=begin






NOTE:UNDER CONSTUCTION - DONT HATE ME IF IT DOESN'T WORK

I still need to add a mask swap transition (kind of like MM)
Also disable certain items that certain actors can't equip






=end

#===============================================================================
# ¦ PZE Masks
#-------------------------------------------------------------------------------
# Swaps between masks
#-------------------------------------------------------------------------------
# Author: Maximusmaxy
# Version 0.1: 19/3/12
#===============================================================================
#
# Introduction:
# This script allows you to swap between masks and actors keeping similar
# attributes, showing animations and stuff.
#
# Instructions:
# Setup is in the configuration.
#
# Call Scripts:
# MASK.swap(ID)
# Swaps your leading actor with the specified actor ID in the database.
#
#===============================================================================

module MASK
  
#===============================================================================
# Configuration
#===============================================================================
  #Which attributes are transfered to the new character
  NAME = true
  MAXHP = true
  MAXSP = true
  HP = true
  SP = true
  EXP = true
  LEVEL = true
  STR = false
  DEX = false
  AGI = false
  INT = false
  SKILLS = false
  STATES = false
  WEAPON = false
  SHIELD = false
  HELMET = false
  BODY = false
  ACCESSORY = false
#===============================================================================
# End Configuration
#===============================================================================

  def self.swap(id)
    #get the old actor
    old_actor = $game_party.actors[0].clone
    #get the new actor
    new_actor = $game_actors[id]
    #return if the new actor doesn't exist
    return true if new_actor.nil?
    #set the main actor
    $game_party.actors[0] = new_actor
    #get the new actor
    actor = $game_party.actors[0]
    #set the attributes
    actor.name = old_actor.name if NAME
    actor.level = old_actor.level if LEVEL
    actor.exp = old_actor.exp if EXP
    actor.maxhp = old_actor.maxhp if MAXHP
    actor.maxsp = old_actor.maxsp if MAXSP
    actor.hp = old_actor.hp if HP
    actor.sp = old_actor.sp if SP
    actor.str = old_actor.str if STR
    actor.dex = old_actor.dex if DEX
    actor.agi = old_actor.agi if AGI
    actor.int = old_actor.int if INT
    if SKILLS
      actor.skills.clear
      old_actor.skills.each_key {|id| actor.learn_skill(id) }
    end
    if STATES
      actor.states.clear
      old_actor.states.each_key {|id| actor.add_state(id) }
    end
    actor.equip(0, old_actor.weapon_id) if WEAPON
    actor.equip(1, old_actor.armor1_id) if SHIELD
    actor.equip(2, old_actor.armor2_id) if HELMET
    actor.equip(3, old_actor.armor3_id) if BODY
    actor.equip(4, old_actor.armor4_id) if ACCESSORY
    #refresh the player
    $game_player.refresh
    #update the hud if needed
    if $nr_zelda_cms && $nr_zelda_hud && $xrxs_xas
      #get the actors item list
      items = NR_Zelda_CMS::DisabledActorItems[actor.id]
      #return if there is no list
      return true if items.nil?
      #loop through each equipped item
      $game_system.xas_item_id.each_with_index do |id, i|
        #next if there is no id
        next if id.nil?
        #unequip the item if it is disabled
        $game_system.xas_item_id[i] = nil if items.include?(id)
      end
      #refresh the hud
      $game_temp.refresh_hud = true
    end
    return true
  end
end