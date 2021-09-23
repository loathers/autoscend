boolean in_wildfire()
{
	return auto_my_path() == "Wildfire";
}

void wildfire_initializeSettings()
{
	if(!in_wildfire())
	{
		return;
	}
	set_property("auto_wandOfNagamar", false);		//wand not used in this path
	set_property("auto_getBeehive", true);			//fire cannot be reduced from 5 in tower making the fight too difficult without beehive
}

boolean LX_wildfire_calculateTheUniverse()
{
	//in wildfire calculate the universe always summons in a fire 5 zone which 100% burns all dropped items. unless conditional drops
	//yellow ray items still burn up. the only exception is [use the force] because it brings you to a noncombat to give you the items
	if(!in_wildfire())
	{
		return false;
	}
	if(my_mp() < mp_cost($skill[Calculate the Universe]))
	{
		return false;
	}
	
	if(!possessOutfit("Frat Warrior Fatigues") && auto_warSide() == "fratboy")
	{
		if(doNumberology("battlefield", false) != -1 && auto_saberChargesAvailable() > 0)
		{
			autoEquip($slot[weapon], $item[Fourth of May cosplay saber]);
			return (doNumberology("battlefield") != -1);
		}
		return false;	//we want 151 and can get it in general. but not right now. so save it for later
	}
	
	doNumberology("adventures3");
	return false;	//we do not want to restart the loop as all we're doing is generating 3 adventures
}

void wildfire_rainbarrel()
{
	//collect rainwater from barrel daily
	if(!in_wildfire())
	{
		return;
	}
	if(get_property("_wildfireBarrelHarvested").to_boolean())
	{
		return;		//already collected today
	}
	visit_url("place.php?whichplace=wildfire_camp&action=wildfire_rainbarrel");
}

int wildfire_water_cost(string target)
{
	//return the cost in water to perform watering operations.
	if(!in_wildfire())
	{
		return 0;
	}
	if(!($strings[dust,frack,sprinkle,hose] contains target))
	{
		abort("an invalid target was passed to int wildfire_water_cost(string target)");
	}
	int count = 0;
	boolean dusted = get_property("wildfireDusted").to_boolean();
	boolean fracked = get_property("wildfireFracked").to_boolean();
	boolean sprinkled = get_property("wildfireSprinkled").to_boolean();
	switch(target)
	{
		case "hose":
			//how much does having cpt hangk send firefighers to hose down an area cost.
			return 10 + (10 * get_property("_auto_wildfire_hosed_today").to_int());
		case "dust":
			if(dusted) return 0;
			if(fracked) count++;
			if(sprinkled) count++;
			break;
		case "frack":
			if(fracked) return 0;
			if(dusted) count++;
			if(sprinkled) count++;
			break;
		case "sprinkle":
			if(sprinkled) return 0;
			if(dusted) count++;
			if(fracked) count++;
			break;
	}
	return 1000+(count*1000);
}

boolean LX_wildfire_grease_pump()
{
	if(!in_wildfire())
	{
		return false;
	}
	if(get_property("wildfirePumpGreased").to_boolean())
	{
		return false;		//already greased
	}
	if(item_amount($item[pump grease]) == 0 && npc_price($item[pump grease]) == 0)
	{
		abort("We are showing you did not grease the pump & do not have [pump grease] & cannot buy pump grease. Something is wrong. please fix it");
	}
	
	if(item_amount($item[pump grease]) == 0)
	{
		//buy the grease
		pull_meat(npc_price($item[pump grease]));
		if(my_meat() >= npc_price($item[pump grease]))
		{
			buyUpTo(1, $item[pump grease]);
		}
		else
		{
			if(get_property("lastSecondFloorUnlock").to_int() < my_ascensions())
			{
				return false;	//go do other stuff until spookyraven second floor is unlocked
			}
			return autoAdv($location[The Haunted Bedroom]);		//get enough meat to grease the pump
		}
	}
	
	if(item_amount($item[pump grease]) > 0)
	{
		//use the grease
		use(1, $item[pump grease]);
		if(!get_property("wildfirePumpGreased").to_boolean())
		{
			abort("Failed to use [pump grease] or mafia is tracking it incorrectly. please resolve the issue and run me again");
		}
		return true;
	}
	return false;
}

boolean LX_wildfire_pump(int target)
{
	//use the pump until we reach target water or run low on adv
	//returns true if adv were spent. regardless of whether target was reached or not
	if(!in_wildfire())
	{
		return false;
	}
	int start_water = my_wildfire_water();
	int start_adv = my_adventures();
	while(my_adventures() > 1+auto_advToReserve() && target > my_wildfire_water() && get_counters("", 0, 0) == "")
	{
		visit_url("place.php?whichplace=wildfire_camp&action=wildfire_oldpump");
		visit_url("charpane.php");		//r20942 must refresh charpane to update water
		if(start_water == my_wildfire_water())
		{
			abort("Mafia failed to update your water level. Are you using the compact char pane? as of r20944 you must be using the full char pane for wildfire to work");
		}
	}
	return start_adv != my_adventures();
}

boolean LX_wildfire_dust()
{
	//cropdusting is a priority.
	if(!in_wildfire())
	{
		return false;
	}
	if(get_property("wildfireDusted").to_boolean())
	{
		return false;	//already done
	}

	//pump water. restart loop if adv were spent
	if(LX_wildfire_pump(wildfire_water_cost("dust"))) return true;
	
	if(wildfire_water_cost("dust") >= my_wildfire_water())
	{
		visit_url("place.php?whichplace=wildfire_camp&action=wildfire_cropster");
		run_choice(1);
		if(!get_property("wildfireDusted").to_boolean())
		{
			abort("Mysteriously failed to Dust with Cropduster Dusty. fix it and run me again");
		}
	}
	return false;
}

boolean LX_wildfire_frack()
{
	//cropdusting is a priority.
	if(!in_wildfire())
	{
		return false;
	}
	if(get_property("wildfireFracked").to_boolean())
	{
		return false;	//already done
	}
	
	//pump water. restart loop if adv were spent
	if(LX_wildfire_pump(wildfire_water_cost("frack"))) return true;

	if(wildfire_water_cost("frack") >= my_wildfire_water())
	{
		visit_url("place.php?whichplace=wildfire_camp&action=wildfire_fracker");
		run_choice(1);
		if(!get_property("wildfireFracked").to_boolean())
		{
			abort("Mysteriously failed to Frack with Fracker Dan. fix it and run me again");
		}
	}
	return false;
}

boolean LX_wildfire_sprinkle()
{
	//cropdusting is a priority.
	if(!in_wildfire())
	{
		return false;
	}
	if(get_property("wildfireSprinkled").to_boolean())
	{
		return false;	//already done
	}
	
	//pump water. restart loop if adv were spent
	if(LX_wildfire_pump(wildfire_water_cost("sprinkle"))) return true;

	if(wildfire_water_cost("sprinkle") >= my_wildfire_water())
	{
		visit_url("place.php?whichplace=wildfire_camp&action=wildfire_sprinklerjoe");
		run_choice(1);
		if(!get_property("wildfireSprinkled").to_boolean())
		{
			abort("Mysteriously failed to Sprinkle with Sprinkler Joe. fix it and run me again");
		}
	}
	return false;
}

boolean LX_wildfire_hose_once(location place)
{
	if(!in_wildfire())
	{
		return false;
	}
	if(place.fire_level == 0)
	{
		auto_log_warning("I can not Hose down [" +place+ "] with fire captain hangk as it is already at fire level 0");
		return false;
	}
	boolean retval = false;

	int start_level = place.fire_level;
	if(wildfire_water_cost("hose") >= my_wildfire_water())
	{
		visit_url("place.php?whichplace=wildfire_camp&action=wildfire_captain");
		visit_url("choice.php?option=1&whichchoice=1451&pwd=&zid=" +place.to_url().split_string("=")[1]);
		if((start_level - 1) == place.fire_level)
		{
			set_property("_auto_wildfire_hosed_today", 1+get_property("_auto_wildfire_hosed_today").to_int());
			retval = true;	//success
		}
		else
		{
			abort("Mysteriously failed to Hose down [" +place+ "] with fire captain hangk. fix it and run me again");
		}
	}
	else
	{
		abort("LX_wildfire_hose_once() did not have enough water to Hose down [" +place+ "]. Report and run me again");
	}
	
	return retval;
}

boolean LX_wildfire_hose(location place, int target_fire)
{
	//have cpt hangk send water hosers to hose loc down until fire level reaches target_fire
	//only return true if the loop needs to be restarted. which only occurs if we adv were spent on pumping water
	if(!in_wildfire())
	{
		return false;
	}
	if(!zone_available(place))
	{
		return false;
	}
	if(place.fire_level <= target_fire)
	{
		return false;		//already done
	}
	
	int hoses_needed = place.fire_level - target_fire;
	int water_needed = wildfire_water_cost("hose");
	switch(hoses_needed)
	{
		case 1:
			break;
		case 2:
			water_needed = water_needed*2 +10;
			break;
		case 3:
			water_needed = water_needed*3 +30;
			break;
		case 4:
			water_needed = water_needed*4 +60;
			break;
		case 5:
			water_needed = water_needed*5 +100;
			break;
	}
	
	//pump water. restart loop if adv were spent
	if(LX_wildfire_pump(water_needed)) return true;
	
	for(int i=0; i<5; i++)		//loop a max of 5 times. the max number of times fire can be reduced
	{
		if(place.fire_level > target_fire)		//we are not done
		{
			if(!LX_wildfire_hose_once(place))	//attempt to hose. if it fails do below
			{
				break;	//hosing failed so stop the loop. LX_wildfire_hose_once should print an explanation on why it failed
			}
		}
		else break;		//we are done
	}
	return false;	//we only return true during water pumping if adv was used
}

boolean LX_wildfire_hose(location place)
{
	return LX_wildfire_hose(place, 2);
}

boolean LX_wildfire_water()
{
	//use water in a variety of ways to reduce fire levels. putting it in pre-adv is problematic since we need to spend adventures here
	//individual location watering first
	
	//for stone wool. needed at level 11 but we acquire it early using [Baa'baa'bu'ran]. no qualifiers since this is always needed
	if(LX_wildfire_hose($location[The Hidden Temple])) return true;
	
	if(!inKnollSign())		//knoll sign does not need to farm components for bitchin meatcar
	{
		if(LX_wildfire_hose($location[The Degrassi Knoll Garage])) return true;
	}
	
	if(get_property("auto_getSteelOrgan").to_boolean() &&		//we want steel margarita
	get_property("questM10Azazel") != "finished" &&				//we do not yet have it
	internalQuestStatus("questL06Friar") > 2)					//we can reach it
	{
		if(LX_wildfire_hose($location[The Laugh Floor])) return true;		//need [imp air]
		if(LX_wildfire_hose($location[Infernal Rackets Backstage])) return true;		//need [bus pass]
	}

	if(my_level() > 10 && zone_available($location[The Hidden Bowling Alley]))
	{
		LX_wildfire_hose($location[The Hidden Bowling Alley]);		//part of level 11 quest. potentially might want to go after NC instead
	}
	
	//mass watering. waters all areas of a certain type (outdoor, indoor, underground) reducing fire from 5 to 2
	if(my_level() > 3 && get_property("wildfirePumpGreased").to_boolean())		//only pump and mass water if you greased the pump
	{
		if(get_property("auto_getSteelOrgan").to_boolean() && get_property("questM10Azazel") != "finished")
		{
			return false;		//delay dust and frack until after steel organ quest is finished
		}
		if(LX_wildfire_dust()) return true;
		if(LX_wildfire_frack()) return true;
	}
	
	return false;
}

boolean LA_wildfire()
{
	if(!in_wildfire())
	{
		return false;
	}
	
	wildfire_rainbarrel();			//collect rainwater from barrel daily
	if(LX_wildfire_grease_pump()) return true;		//improves pump water from 30/adv to 50/adv
	if(LX_wildfire_water()) return true;		//use water to reduce fire levels.
	
	return false;
}
