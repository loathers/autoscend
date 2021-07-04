# This is meant for items that have a date of 2021

boolean auto_haveCrystalBall()
{
	return possessEquipment($item[miniature crystal ball]) && auto_is_valid($item[miniature crystal ball]);
}

void auto_handleCrystalBall(location loc)
{
	if(!auto_haveCrystalBall())
	{
		return;
	}
	
	if(!pathHasFamiliar())
	{
		return;
	}
	
	if (auto_allowCrystalBall(loc))
	{
		// if equipping the crystal ball can't hurt
		removeFromMaximize(`-equip {$item[miniature crystal ball].to_string()}`);
	}
	else
	{
		// until we add support for this, we shouldn't allow the maximizer to equip it
		// "I noticed it being worn in preference to the astral pet sweater which is a waste": is that because of base maximizer 0.5 score to initiative?
		
		// exception for the string used for the tower initative test (has no location)
		if (maximizeContains("500initiative 400max"))
		{
			removeFromMaximize(`-equip {$item[miniature crystal ball].to_string()}`);
		}
		else
		{
			addToMaximize(`-equip {$item[miniature crystal ball].to_string()}`);
		}
	}
}

boolean auto_allowCrystalBall(location loc)
{	
	// track zone changes every adventure
	boolean AllGoodSinceEnteringZone = false;
	if(loc.turns_spent == 0)
	{
		AllGoodSinceEnteringZone = true;
	}
	else if(get_property("auto_crystalBall_AllGoodSinceEnteringZone").to_boolean())
	{
		if(loc == get_property("lastAdventure").to_location())
		{
			AllGoodSinceEnteringZone = true;
		}
		else	// when changing locations at all, predicted monster on display is no longer reliable
		{
			AllGoodSinceEnteringZone = false;
		}
	}
	// only update the real tracking property if it's not a different location being simulated
	if(loc == my_location())
	{
		// it's either the preadventure script calling this with the next location,
		// or simulating the same location it was in so updating the property is fine
		set_property("auto_crystalBall_AllGoodSinceEnteringZone",AllGoodSinceEnteringZone);
	}
	
	// next monster forced by mapping overrides any prediction so no need to forbid equipping crystal ball 
	if(get_property("mappingMonsters").to_boolean())
	{
		return true;
	}

	// next monster forced by semi rare so no need to forbid equipping crystal ball
	if(get_counters("Fortune Cookie", 0, 0) == "Fortune Cookie")
	{
		if(loc == $location[The Hidden Temple])
		{
			return true;
		}
	}
	
	boolean burningDelay = ((auto_voteMonster(true) || isOverdueDigitize() || auto_sausageGoblin()) && loc == solveDelayZone());
	if (burningDelay)
	{
		// if the next monster is forced anyway, no need to forbid the ball
		removeFromMaximize(`-equip {$item[miniature crystal ball].to_string()}`);
	}
	
	// probably not worth taking it on and off whenever auto_haveQueuedForcedNonCombat()
	// since most forced noncombats won't lead to fights, will specify the ones that do
	
	
	monster predicted_monster = get_property("crystalBallMonster").to_monster();
	boolean prediction_is_unwanted = false;
	if(auto_wantToReplace(predicted_monster,loc) || auto_wantToBanish(predicted_monster,loc))
	{
		prediction_is_unwanted = true;
	}

	switch(loc)
	{
	
	// BLACKLISTED LOCATIONS where it's not harmless to ever equip it for now
	
	case $location[The Hidden Hospital]:
	case $location[The Hidden Park]:
		return false;	//shares pygmy monsters with other zones?

	case $location[Next to that barrel with something burning in it]:
	case $location[Out by that rusted-out car]:
	case $location[over where the old tires are]:
	case $location[near an abandoned refrigerator]:
		return false;	//shares gremlin monsters with other zones?
		//also predictions can't tell gremlins apart... just don't...
	
	// hidden city locations only allowed for noncombat fights
	case $location[The Hidden Apartment Building]:
		if((!zone_delay(loc)._boolean || auto_haveQueuedForcedNonCombat()) && have_effect($effect[Thrice-Cursed]) > 0)
		{
			return true;	//ancient protector spirit fight
		}
		else
		{
			return false;	//shares pygmy monsters with other zones?
		}
	case $location[The Hidden Office Building]:
		if((!zone_delay(loc)._boolean || auto_haveQueuedForcedNonCombat()) && item_amount($item[McClusky file (complete)]) > 0)
		{
			return true;	//ancient protector spirit fight
		}
		else
		{
			return false;	//shares pygmy monsters with other zones?
		}
	case $location[The Hidden Bowling Alley]:
		if(get_property("hiddenBowlingAlleyProgress").to_int() == 5 && item_amount($item[bowling ball]) > 0)
		{
			return true;	//ancient protector spirit fight
		}
		else
		{
			return false;	//shares pygmy monsters with other zones?
		}


	// WHITELISTED LOCATIONS where it's ok to equip the ball
	
	//Any
	// no monster is wanted more enough than the others to care
	case $location[The Daily Dungeon]:
	case $location[The Haunted Kitchen]:
	case $location[The Sleazy Back Alley]:
	case $location[The Old Landfill]:
		return true;
	case $location[The Haunted Pantry]:
		// autoscend only wants a tomato in Community Service
		if(!((auto_my_path() == "Community Service") && (item_amount($item[Tomato]) < 2) && have_skill($skill[Advanced Saucecrafting])))
		{
			return true;
		}
		break;
	
	//Level 2
	case $location[The Spooky Forest]:
		return true;
	
	//Level 4
	case $location[Guano Junction]:
	case $location[The Batrat and Ratbat Burrow]:
		return true;
	case $location[The Boss Bat\'s Lair]:
		// ok to equip while boss bat is still delayed even if it's after changing zones
		if(zone_delay(loc)._boolean)
		{
			return true;
		}
		else
		{
			return false;
		}
	
	//Level 5
	case $location[The Outskirts of Cobb\'s Knob]:
		return true;
	
	//Level 6
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
		return true;
	
	//Level 7
	case $location[The Defiled Cranny]:
	case $location[The Defiled Alcove]:
		return true;
	
	//Level 8
	case $location[Lair of the Ninja Snowmen]:
		return true;
	
	//Level 9
	case $location[The Smut Orc Logging Camp]:
	case $location[A-Boo Peak]:
	case $location[Oil Peak]:
		return true;
	
	//Level 10
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
	case $location[The Castle in the Clouds in the Sky (Basement)]:		//autoscend doesn't try to get a heavy D from Alphabet Giant, it either uses a clover or Unquiet Garves
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:	//autoscend doesn't try to get thin black candles from Goth Giant
		return true;
	
	//Level 11
	case $location[The Arid\, Extra-Dry Desert]:
	case $location[A Massive Ziggurat]:
		return true;
	
	//Level 12
	case $location[Frat House]:
	case $location[Hippy Camp]:
	case $location[Wartime Frat House]:
	case $location[Wartime Hippy Camp]:
	case $location[Sonofa Beach]:
	case $location[The Themthar Hills]:
	case $location[The Hatching Chamber]:
	case $location[The Feeding Chamber]:
	case $location[The Royal Guard Chamber]:
	case $location[The Filthworm Queen\'s Chamber]:
	case $location[McMillicancuddy's Barn]:
	case $location[McMillicancuddy's Pond]:
	case $location[McMillicancuddy's Back 40]:
	case $location[McMillicancuddy's Other Back 40]:
		return true;
	case $location[The Battlefield (Frat Uniform)]:
		// there is only one monster autoscend wants on the frat battlefield that can't appear before 400 hippies defeated
		// but it would probably be beneficial to allow even when that monster is tracked because there are so many turns and monsters and on average predictions won't reduce chances?
		if(have_effect($effect[On The Trail]) > 0 && get_property("olfactedMonster").to_monster() == $monster[Green Ops Soldier] && get_property("hippiesDefeated").to_int() >= 400 &&  predicted_monster != $monster[Green Ops Soldier])
		{
			return false;
		}
		else
		{
			return true;
		}
	case $location[The Battlefield (Hippy Uniform)]:
		// there is only one monster autoscend wants on the hippy battlefield under certain path and item conditions
		foreach m in $monsters[War Hippy Homeopath,War Hippy Naturopathic Homeopath]
		{	
			if(auto_wantToSniff(m,loc) && have_effect($effect[On The Trail]) > 0 && get_property("olfactedMonster").to_monster() == m && predicted_monster != m)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
	
	//Level 13
	case $location[Fastest Adventurer Contest]:
	case $location[Smartest Adventurer Contest]:
	case $location[Strongest Adventurer Contest]:
	case $location[Smoothest Adventurer Contest]:
	case $location[Coldest Adventurer Contest]:
	case $location[Hottest Adventurer Contest]:
	case $location[Sleaziest Adventurer Contest]:
	case $location[Spookiest Adventurer Contest]:
	case $location[Stinkiest Adventurer Contest]:
		return true;
	
	// several non-adv.php combats like tavern cellar and tower levels also set location to Noob Cave, by property "nextAdventure", passed to my_location()
	case $location[Noob Cave]:
		return true;
	}
	
	// if not in a blacklisted or whitelisted location:
	// safe to allow crystal ball from the first turn ever into a zone until either an unwanted prediction has appeared or zone is changed
	// ideally it would be allowed again when predictions get removed but crystalBallMonster doesn't show when predictions get truly cleared for now
	
	// the zone hasn't become unallowed or been left since the first turn spent in it
	if(AllGoodSinceEnteringZone)
	{
		// if a bad prediction ever happens, stop allowing the crystal ball in the location
		if(prediction_is_unwanted)
		{
			set_property("auto_crystalBall_AllGoodSinceEnteringZone","false");
			return false;
		}
		else
		{
			return true;
		}
	}
	if(auto_wantToSniff(predicted_monster,loc))
	{
		// if the prediction after changing zones is an olfaction target for the next zone
		// either it's a real prediction and that's good
		// or it's not a real prediction and it can't hurt at least outside of the blacklisted zones
		return true;
	}
	// when changing locations at all, predited monster is no longer reliable
	// so do not allow by default even if predicted monster isn't in the next zone
	
	return false;
}

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
	return 11 + (my_path() == "You, Robot" ? 5 : 0) - get_property("_backUpUses").to_int();
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

// Mafia's handling of the create() function is currently not flexible enough for crafting batteries.
// This is very dense, apologies.
boolean batteryCombine(item battery)
{
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
			craft("combine", 1, $item[battery (AA)], $item[battery (AAA)]);
			return (available_amount($item[battery (D)]) >= 1);
		}
		// If crafting requires multiple steps, we rely on recursion.
		else if (available_amount($item[battery (AAA)]) >= 3)
		{
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
			craft("combine", 1, $item[battery (D)], $item[battery (AAA)]);
			return (available_amount($item[battery (9-Volt)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (AA)]) >= 2)
		{
			craft("combine", 1, $item[battery (AA)], $item[battery (AA)]);
			return (available_amount($item[battery (9-Volt)]) >= 1);
		}
		// Every multi step case with recursion.
		else if (available_amount($item[battery (AAA)]) >= 4 ||
		 (available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 2))
		{
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
			craft("combine", 1, $item[battery (9-Volt)], $item[battery (AAA)]);
			return (available_amount($item[battery (lantern)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AA)]) >= 1)
		{
			craft("combine", 1, $item[battery (D)], $item[battery (AA)]);
			return (available_amount($item[battery (lantern)]) >= 1);
		}
		// Every multi step case with recursion.
		else if (available_amount($item[battery (AAA)]) >= 5 ||
		 (available_amount($item[battery (AA)]) >= 1 && available_amount($item[battery (AAA)]) >= 3) ||
		 (available_amount($item[battery (D)]) >= 1 && available_amount($item[battery (AAA)]) >= 2) ||
		 (available_amount($item[battery (AA)]) >= 2 && available_amount($item[battery (AAA)]) >= 1))
		{
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
			craft("combine", 1, $item[battery (lantern)], $item[battery (AAA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (9-Volt)]) >= 1 && available_amount($item[battery (AA)]) >= 1)
		{
			craft("combine", 1, $item[battery (9-Volt)], $item[battery (AA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// Single step.
		else if (available_amount($item[battery (D)]) >= 2)
		{
			craft("combine", 1, $item[battery (D)], $item[battery (D)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
		// The only multi-step case that can't be resolved by the same function (can't turn AAs into a lantern without a AA or D)
		else if (available_amount($item[battery (AA)]) >= 3)
		{
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
			batteryCombine($item[battery (lantern)]);
			craft("combine", 1, $item[battery (lantern)], $item[battery (AAA)]);
			return (available_amount($item[battery (car)]) >= 1);
		}
	}
	return false;
}

// This function will ensure a battery is available before use, if possible.
boolean auto_getBattery(item battery)
{
	if(batteryPoints(battery) == 0)	//0 means it is not a battery
	{
  		return false;
	}

	// If we have the desired battery then we're done here.
	if (available_amount(battery) >= 1)
	{
		return true;
	}
		
	// We'll try to create the battery, if it works then great, if not, we keep going.
	if (batteryCombine(battery))
	{
		return true;
	}

	// Make sure we have enough AAA value to craft the target battery, and that we can untinker.
	if (totalBatteryPoints() > batteryPoints(battery) && canUntinker())
	{
		// We're going to break down each battery one at a time from largest to smallest, and attempt to craft.
		foreach it in $items[battery (car), battery (lantern), battery (9-Volt), battery (D), battery (AA)]
		{
			for i from 1 to available_amount(it)
			{
				visit_url("place.php?whichplace=forestvillage&action=fv_untinker&pwd=&preaction=untinker&whichitem=" + it.to_int().to_string());
				
				if (batteryCombine(battery))
				{
					return true;
				}
			}
		}
	}
	return false;
}
