# This is meant for items that have a date of 2021

boolean auto_haveEmotionChipSkills()
{
	return auto_is_valid($skill[Emotionally Chipped]) && have_skill($skill[Emotionally Chipped]);
}

boolean auto_canFeelEnvy()
{
	// Combat Skill - Forces drops like Spooky Jelly (doesn't insta-kill though, still need to win combat)
	if(!auto_is_valid($skill[Feel Envy]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelEnvyUsed") < 3;
}

boolean auto_canFeelHatred()
{
	// Combat Skill - 50 turn banish (doesn't cost a turn)
	if(!auto_is_valid($skill[Feel Hatred]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelHatredUsed") < 3;
}

boolean auto_canFeelNostalgic()
{
	// Combat Skill - adds drop table from last copyable monster to the current (see lastCopyableMonster property)
	if(!auto_is_valid($skill[Feel Nostalgic]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelNostalgicUsed") < 3;
}

boolean auto_canFeelPride()
{
	// Combat Skill - Triples stat gain from the current fight.
	if(!auto_is_valid($skill[Feel Pride]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelPrideUsed") < 3;
}

boolean auto_canFeelSuperior()
{
	// Combat Skill - Does 20% of monsters max HP as damage and gives +1 PvP fight if it kills the monster.
	if(!auto_is_valid($skill[Feel Superior]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelSuperiorUsed") < 3;
}

boolean auto_canFeelLonely()
{
	// Non-Combat Skill - -5% combat rate (20 adventures)
	if(!auto_is_valid($skill[Feel Lonely]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelLonelyUsed") < 3;
}

boolean auto_canFeelExcitement()
{
	// Non-Combat Skill - +25 to all stats (20 adventures)
	if(!auto_is_valid($skill[Feel Excitement]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelExcitementUsed") < 3;
}

boolean auto_canFeelNervous()
{
	// Non-Combat Skill - deals passive damage on hit starting at 20 decrementing by 1 every proc (20 adventures)
	if(!auto_is_valid($skill[Feel Nervous]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelNervousUsed") < 3;
}

boolean auto_canFeelPeaceful()
{
	// Non-Combat Skill - +2 all res, +10 DR, +100 DA (20 adventures)
	if(!auto_is_valid($skill[Feel Peaceful]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelPeacefulUsed") < 3;
}

boolean auto_haveBackupCamera()
{
	return possessEquipment($item[backup camera]) && auto_is_valid($item[backup camera]);
}

void auto_enableBackupCameraReverser()
{
	if (auto_haveBackupCamera() && !get_property("backupCameraReverserEnabled").to_boolean())
	{
		cli_execute("backupcamera reverser on");
	}
}

int auto_backupUsesLeft()
{
	return 11 + (in_robot() ? 5 : 0) - get_property("_backUpUses").to_int();
}

boolean auto_backupTarget()
{
	// can't backup if we don't have camera or it isn't available
    if (!auto_haveBackupCamera()) 
	{
        return false;
    }

	// can't backup if no more charges left
	if (auto_backupUsesLeft() < 1) 
	{
        return false;
    }

	// don't backup into a fight we just lost. Prevent continuously getting beaten up
	if(get_property("auto_beatenUpLastAdv").to_boolean())
	{
		return false;
	}

	// determine if we want to backup
	boolean wantBackupLFM = item_amount($item[barrel of gunpowder]) < 5 && get_property("sidequestLighthouseCompleted") == "none" && my_level() >= 12;
	boolean wantBackupNSA = (item_amount($item[ninja rope]) < 1 || item_amount($item[ninja carabiner]) < 1 || item_amount($item[ninja crampons]) < 1) && my_level() >= 8 && !get_property("auto_L8_extremeInstead").to_boolean();
	boolean wantBackupZmobie = get_property("cyrptAlcoveEvilness").to_int() > 25 && my_level() >= 6;

	switch (get_property("lastCopyableMonster").to_monster()) {
		case $monster[lobsterfrogman]:
			if(wantBackupLFM)
				return true; 
			break;
		case $monster[ninja snowman assassin]:
			if(wantBackupNSA)
				return true;
			break;
		case $monster[modern zmobie]:
			if(wantBackupZmobie) 
				return true;
			break;
		case $monster[sausage goblin]:
			if(!wantBackupLFM && !wantBackupNSA && !wantBackupZmobie)
				return true;
			break;
		case $monster[eldritch tentacle]:
			//backup tentacles if power leveling or use all remaining charges if at end of day
			if(isAboutToPowerlevel() && auto_backupUsesLeft() > 5)
				return true;
			if (my_adventures() <= (1 + auto_advToReserve()) && inebriety_left() == 0 && stomach_left() < 1)
				return true;
			break;
		default: break;
    }

	return false;
}

boolean auto_havePowerPlant()
{
	return item_amount($item[potted power plant]) > 0 && auto_is_valid($item[potted power plant]);
}

boolean auto_harvestBatteries()
{
	if(!auto_havePowerPlant() || get_property("_pottedPowerPlant") == "0,0,0,0,0,0,0")
	{
  		return false;
	}

	// Stolen straight from mafia's breakfast handling.
	cli_execute("inv_use.php?pwd&whichitem=" + $item[potted power plant].to_int());
	
	string [int] status = split_string(get_property("_pottedPowerPlant"), ",");

	for ( int pp = 0; pp < status.count(); pp++ )
	{
		if ( status[pp] > 0)
		{
			cli_execute("choice.php?pwd&whichchoice=1448&option=1&pp=" + ( pp + 1 ));
		}
	}
	return true;
}

// These points the value of a battery represented in AAAs.
int batteryPoints(item battery)
{
	static int[item] points = {
		$item[battery (AAA)]: 1,
		$item[battery (AA)]: 2,
		$item[battery (D)]: 3,
		$item[battery (9-Volt)]: 4,
		$item[battery (lantern)]: 5,
		$item[battery (car)]: 6
	};
	return points[battery];
}

// These points represent a quantity of AAAs if all batteries were untinkered.
int totalBatteryPoints()
{
	int totalPoints = 0;

	foreach it in $items[battery (AAA), battery (AA), battery (D), battery (9-Volt), battery (lantern), battery (car)]
	{
		totalPoints += available_amount(it) * batteryPoints(it);
	}

	return totalPoints;
}

boolean batteryCombine(item battery)
{
	return batteryCombine(battery, false);
}

boolean batteryCombine(item battery, boolean simulate)
{
	// Mafia's create() function only allows one single recipe for crafting batteries. This can result in situations where you can in fact craft a battery but it fails due to it not being the singular recipe supported by it.
	// Mafia's can_create() has the same issue. use simulate in this function to determine if we can actually create a battery (or already have it).
	// To get batteries use can_get_battery() and auto_getBattery(), which will be calling this function and untinker as necessary
	// This is very dense, apologies.
	if(batteryPoints(battery) == 0)	//0 means it is not a battery
	{
  		return false;
	}

	// We already have this battery, no need to make more yet.
	if (available_amount(battery) >= 1)
	{
		return true;
	}
	
	// We're targetting a AA.
	if (battery == $item[battery (AA)])
	{
		// There's only one way to craft a AA.
		if (available_amount($item[battery (AAA)]) >= 2)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (AAA)], $item[battery (AAA)]);
			return (available_amount($item[battery (AA)]) >= 1);
		}
		return false;
	}

	else if (battery == $item[battery (D)])
	{
		// From here on out, we try to resolve the crafting in a single step if possible, starting with largest battery + smallest battery.
		if (available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 1)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (AA)], $item[battery (AAA)]);
			return (available_amount($item[battery (D)]) >= 1);
		}
		// If crafting requires multiple steps, we rely on recursion.
		else if (available_amount($item[battery (AAA)]) >= 3)
		{
			if(simulate) return true;
			batteryCombine($item[battery (AA)]);
			craft("combine", 1, $item[battery (AA)], $item[battery (AAA)]);
			return (available_amount($item[battery (D)]) >= 1);
		}
		return false;
	}

	else if (battery == $item[battery (9-Volt)])
	{
		// Single step.
		if (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AAA)]) >= 1)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (D)], $item[battery (AAA)]);
			return (available_amount($item[battery (9-Volt)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (AA)]) >= 2)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (AA)], $item[battery (AA)]);
			return (available_amount($item[battery (9-Volt)]) >= 1);
		}
		// Every multi step case with recursion.
		else if (available_amount($item[battery (AAA)]) >= 4 ||
		 (available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 2))
		{
			if(simulate) return true;
			batteryCombine($item[battery (D)]);
			craft("combine", 1, $item[battery (D)], $item[battery (AAA)]);
			return (available_amount($item[battery (9-Volt)]) >= 1);
		}
		return false;
	}

	else if (battery == $item[battery (lantern)])
	{
		// Single step.
		if (available_amount($item[battery (9-Volt)]) >= 1 && available_amount($item[battery (AAA)]) >= 1)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (9-Volt)], $item[battery (AAA)]);
			return (available_amount($item[battery (lantern)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AA)]) >= 1)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (D)], $item[battery (AA)]);
			return (available_amount($item[battery (lantern)]) >= 1);
		}
		// Every multi step case with recursion.
		else if (available_amount($item[battery (AAA)]) >= 5 ||
		 (available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 3) ||
		 (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AAA)]) >= 2) ||
		 (available_amount($item[battery (AA)]) >= 2 && available_amount($item[battery (AAA)]) >= 1))
		{
			if(simulate) return true;
			batteryCombine($item[battery (9-Volt)]);
			craft("combine", 1, $item[battery (9-Volt)], $item[battery (AAA)]);
			return (available_amount($item[battery (lantern)]) >= 1);
		}
		return false;
	}

	else if (battery == $item[battery (car)])
	{
		// Single step.
		if (available_amount($item[battery (lantern)]) >= 1 && available_amount($item[battery (AAA)]) >= 1)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (lantern)], $item[battery (AAA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (9-Volt)]) >= 1 && available_amount($item[battery (AA)]) >= 1)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (9-Volt)], $item[battery (AA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (D)]) >= 2)
		{
			if(simulate) return true;
			craft("combine", 1, $item[battery (D)], $item[battery (D)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// The only multi-step case that can't be resolved by the same function (can't turn AAs into a lantern without a AA or D)
		else if (available_amount($item[battery (AA)]) >= 3)
		{
			if(simulate) return true;
			batteryCombine($item[battery (9-volt)]);
			craft("combine", 1, $item[battery (9-Volt)], $item[battery (AA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// Every other multi step case with recursion.
		else if (available_amount($item[battery (AAA)]) >= 6 ||
		 (available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 4) ||
		 (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AAA)]) >= 3) ||
		 (available_amount($item[battery (9-Volt)]) >= 1 && available_amount($item[battery (AAA)]) >= 2) ||
		 (available_amount($item[battery (AA)]) >= 2 && available_amount($item[battery (AAA)]) >= 2) ||
		 (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 1))
		{
			if(simulate) return true;
			batteryCombine($item[battery (lantern)]);
			craft("combine", 1, $item[battery (lantern)], $item[battery (AAA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
	}
	return false;
}

boolean can_get_battery(item target)
{
	if(batteryPoints(target) == 0)		//0 means target is not a battery
	{
  		return false;
	}
	if (available_amount(target) > 0)		//already have it
	{
		return true;
	}
	if(canUntinker())
	{
		return totalBatteryPoints() >= batteryPoints(target);	//we can untinker. so just count battery points
	}
	return batteryCombine(target, true);	//can not untinker. only check meatpasting by simulating batteryCombine
}

boolean auto_getBattery(item target)
{
	// This function will ensure target battery is available before use, if possible.
	if(batteryPoints(target) == 0)		//0 means target is not a battery
	{
  		return false;
	}
	if (available_amount(target) >= 1)
	{
		return true;		//we already have the target. we are done here
	}
		
	//try to create target
	if (batteryCombine(target))
	{
		return true;
	}

	//try to use untinkering to get target or enough AAA to make target
	if (totalBatteryPoints() >= batteryPoints(target) && canUntinker())
	{
		foreach it in $items[battery (car), battery (lantern), battery (9-Volt), battery (D), battery (AA)]
		{
			if(my_meat() < 10)
			{
				break;		//we ran out of meat and can no longer meatpaste
			}
			//Batteries always untinker into an [AAA] and an [X-1] battery. where X was previous battery value.
			//so if we have a higher value battery just walk it down to the target.
			if(batteryPoints(it) > batteryPoints(target))		//we have a higher tier battery we can untinker down to target
			{
				untinker(it);
				if (batteryCombine(target))		//either we untinkered down to target. or we got enough AAA to make target now.
				{
					return true;
				}
			}
			//all the batteries we had to begin with were smaller than target. They were just the wrong values to merge.
			//so just break them apart until you are able to make target
			else for i from 1 to min(6, item_amount(it))
			{
				untinker(it);
				if (batteryCombine(target))
				{
					return true;
				}
			}
		}
	}
	return false;
}

boolean have_fireworks_shop()
{
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(!auto_is_valid($item[clan underground fireworks shop]))
	{
		return false;
	}
	return get_property("_fireworksShop").to_boolean();
}

boolean auto_buyFireworksHat()
{
	if(!have_fireworks_shop())
	{
		return false;
	}

	if(get_property("_fireworksShopHatBought"))
	{
		return false;
	}

	if(my_meat() < npc_price($item[porkpie-mounted popper]) + meatReserve())
	{
		auto_log_info("Want to buy a hat from the fireworks shop, but don't have enough meat. Will try again later.");
		return false;
	}

	// noncombat is most valuable hat
	float simNonCombat = providePlusNonCombat(25, $location[noob cave], true, true);
	if(simNonCombat < (float) 25.0)
	{
		retrieve_item(1, $item[porkpie-mounted popper]);
		return true;
	}

	// +combat hat is second most usefull
	float simComabt = providePlusCombat(25, $location[noob cave], true, true);
	if(simCombat < (float) 25.0)
	{
		retrieve_item(1, $item[sombrero-mounted sparkler]);
		return true;
	}

	// buy ML hat if have enough -com and +com
	retrieve_item(1, $item[fedora-mounted fountain]);
	return true;
}

boolean auto_haveFireExtinguisher()
{
	return possessEquipment($item[industrial fire extinguisher]) && auto_is_valid($item[industrial fire extinguisher]);
}

int auto_fireExtinguisherCharges()
{
	if (!auto_haveFireExtinguisher()) return 0;
	return get_property("_fireExtinguisherCharge").to_int();
}

// returns zone specific skill if in usable zone and hasn't been used yet there this acension. Otherwise returns empty string
string auto_FireExtinguisherCombatString(location place)
{
	if(auto_fireExtinguisherCharges() < 20)
	{
		return "";
	}

	// once per acension uses
	if($locations[Guano Junction, The Batrat and Ratbat Burrow, The Beanbat Chamber] contains place && !get_property("fireExtinguisherBatHoleUsed").to_boolean())
	{
		//sonar-in-a-biscuits are used before combat, if available. Knock a wall down if any are still standing
		if(internalQuestStatus("questL04Bat") < 3)
		{
			return "skill " + $skill[Fire Extinguisher: Zone Specific];
		}
		
	}

	if(place == $location[Cobb\'s Knob Harem] && !get_property("fireExtinguisherHaremUsed").to_boolean() && !possessOutfit("Knob Goblin Harem Girl Disguise"))
	{
		return "skill " + $skill[Fire Extinguisher: Zone Specific];
	}

	if(place == $location[The Defiled Niche] && !get_property("fireExtinguisherCyrptUsed").to_boolean())
	{
		return "skill " + $skill[Fire Extinguisher: Zone Specific];
	}

	if(place == $location[The Smut Orc Logging Camp] && !get_property("fireExtinguisherChasmUsed").to_boolean() && get_property("chasmBridgeProgress").to_int() < 30)
	{
		return "skill " + $skill[Fire Extinguisher: Zone Specific];
	}

	if(place == $location[The Arid\, Extra-Dry Desert] && $location[The Arid\, Extra-Dry Desert].turns_spent > 0 && !get_property("fireExtinguisherDesertUsed").to_boolean())
	{
		return "skill " + $skill[Fire Extinguisher: Zone Specific];
	}


	return "";
	
}

boolean auto_canExtinguisherBeRefilled()
{
	return auto_haveFireExtinguisher() && in_wildfire() && !get_property("_fireExtinguisherRefilled").to_boolean();
}
