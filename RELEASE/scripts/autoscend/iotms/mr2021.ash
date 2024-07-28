# This is meant for items that have a date of 2021

boolean auto_haveCrystalBall()
{
	item crystal_ball = wrap_item($item[miniature crystal ball]);
	return possessEquipment(crystal_ball) && auto_is_valid(crystal_ball) && pathHasFamiliar();
}

monster crystalBallMonster(location loc)
{
	// returns a monster if the crystal ball predicts one in the location

	string [int] crystalBallPredictions = get_property("crystalBallPredictions").split_string("[|]");
	if(crystalBallPredictions[0] == "")
	{
		return $monster[none];	// no prediction
	}
	foreach i in crystalBallPredictions
	{
        string [int] thisPrediction = crystalBallPredictions[i].split_string(":"); // turn:location:monster
		// turn: thisPrediction[0].to_int() is useless unless mafia fails to update the property
		if(thisPrediction[1].to_location() != loc)
		{
			continue;
		}
		return thisPrediction[2].to_monster();
	}
	return $monster[none];	// no prediction in the location
}

boolean auto_allowCrystalBall(monster predicted_monster, location loc)
{	
	// blacklisted locations
	if($locations[Next to that barrel with something burning in it, Out by that rusted-out car, over where the old tires are, near an abandoned refrigerator] contains loc)
	{
		//predictions can't tell tool gremlins apart from non tool gremlins
		return false;
	}
	
	// allowed elsewhere if no prediction
	if(predicted_monster == $monster[none])
	{
		return true;
	}

	// next monster forced by mapping overrides any prediction so no need to forbid equipping crystal ball 
	if(get_property("mappingMonsters").to_boolean())
	{
		return true;
	}

	// next monster forced by clover so no need to forbid equipping crystal ball
	if(have_effect($effect[Lucky!]) > 0)
	{
		if(loc == $location[The Hidden Temple])
		{
			// the only lucky adventure with a fight that could use the chance of item drop bonus
			return true;
		}
	}

	//if already forced by something else, no need to handle your ball
	//pre_adv, or simulatePreAdvForCrystalBall, handles this as it already tracks burningDelay and forced encounters
	
	if(is_banished(predicted_monster) || auto_wantToReplace(predicted_monster,loc) || auto_wantToBanish(predicted_monster,loc))
	{
		// next prediction is unwanted, do not allow
		return false;
	}
	
	return true;
}

boolean auto_forceHandleCrystalBall(location loc)
{
	//full support would need changing how autoscend chooses tasks to move between zones and reset predictions
	//instead just allow it to make unwanted monsters less likely and confirm wanted monsters

	monster predicted_monster = crystalBallMonster(loc);

	boolean shouldForceEquip;
	if(predicted_monster != $monster[none])
	{
		if((auto_wantToSniff(predicted_monster,loc) || 	//sniff targets are wanted monsters TODO it's not exhaustive, neither is careAboutDrops()
		isSniffed(predicted_monster) ||	//ball will likely be forbidden before getting to last monster, but last wanted one isn't sniff target
		$monsters[Monstrous Boiler, beanbat] contains predicted_monster)	//some wanted monsters are not sniff targets
		&& auto_combat_appearance_rates(loc,false)[predicted_monster] < 100)		//other monsters possible
		{
			shouldForceEquip = true;	// should not waste the prediction entered in queue
		}
	}
	
	item crystal_ball = wrap_item($item[miniature crystal ball]);
	if(shouldForceEquip)
	{
		addToMaximize(`+equip {crystal_ball.to_string()}`);
		set_property("auto_nextEncounter",to_string(predicted_monster));
		return true;	//handled
	}
	else if(!auto_allowCrystalBall(predicted_monster, loc))
	{
		addToMaximize(`-equip {crystal_ball.to_string()}`);
		return true;	//handled
	}

	//equipping the crystal ball can't hurt but it is neither forced nor forbidden
	//pre_adv will consider giving it a maximizer bonus after checking if monster queue control is wanted
	//removeFromMaximize(`-equip {crystal_ball.to_string()}`);	//this should already get reset after every loop or maximizer simulation
	return false;
}

void simulatePreAdvForCrystalBall(location place)
{
	// used only when simulating maximizer equipment
	// replicates most of pre_adv monster queue checks in order to know if miniature crystal ball will be allowed
	
	boolean burningDelay = ((auto_voteMonster(true) || isOverdueDigitize() || auto_sausageGoblin() || auto_backupTarget()) && place == solveDelayZone());
	boolean gettingLucky = (have_effect($effect[Lucky!]) > 0 && zone_hasLuckyAdventure(place));
	boolean forcedNonCombat = auto_haveQueuedForcedNonCombat();
	boolean zoneQueueIgnored = (burningDelay || gettingLucky || forcedNonCombat);

	boolean considerCrystalBallBonus;
	if(!zoneQueueIgnored && get_property("auto_nextEncounter").to_monster() == $monster[none] && 
	!auto_forceHandleCrystalBall(place))
	{
		//equipping the crystal ball can't hurt but it is neither forced nor forbidden
		//will consider giving it a maximizer bonus after checking if monster queue control is wanted
		considerCrystalBallBonus = true;
	}
	
	monster [int] possible_monsters;
	if(get_property("auto_nextEncounter").to_monster() != $monster[none])
	{
		//next monster is forced by zone mechanics or by now locked-in miniature crystal ball
		possible_monsters[count(possible_monsters)] = get_property("auto_nextEncounter").to_monster();
	}
	else
	{
		foreach i,mon in get_monsters(place)
		{
			if(appearance_rates(place)[mon] > 0)
			{
				possible_monsters[count(possible_monsters)] = mon;
			}
		}
	}
	
	boolean zoneHasUnwantedMonsters;
	boolean zoneHasWantedMonsters;
	if (!zoneQueueIgnored)	//next encounter is a monster from the zone
	{
		foreach i,mon in possible_monsters
		{
			if(auto_wantToYellowRay(mon, place))
			{
				zoneHasWantedMonsters = true;
			}
			if(auto_wantToBanish(mon, place))
			{
				zoneHasUnwantedMonsters = true;
			}
			if(auto_wantToReplace(mon, place))
			{
				zoneHasUnwantedMonsters = true;
			}
			if(auto_wantToSniff(mon, place))
			{
				zoneHasWantedMonsters = true;
			}
		}
	}
	if(considerCrystalBallBonus)
	{
		//give miniature crystal ball a maximizer bonus only if the location has monsters to avoid or target
		int crystalBallMaximizerBonus = 0 + (zoneHasUnwantedMonsters ? 300 : 0) + (zoneHasWantedMonsters ? 300 : 0);
		if(crystalBallMaximizerBonus != 0)
		{
			item crystal_ball = wrap_item($item[miniature crystal ball]);
			addToMaximize("+" + crystalBallMaximizerBonus + "bonus "+crystal_ball.to_string());
		}
	}
}

boolean auto_haveEmotionChipSkills()
{
	return (auto_is_valid($skill[Emotionally Chipped]) && have_skill($skill[Emotionally Chipped])) || 
	  (auto_is_valid($skill[Replica Emotionally Chipped]) && have_skill($skill[Replica Emotionally Chipped]));
}

boolean auto_canFeelEnvy()
{
	// Combat Skill - Forces drops like Spooky Jelly (doesn't insta-kill though, still need to win combat)
	if(!auto_is_valid($skill[Feel Envy]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelEnvyUsed").to_int() < 3;
}

boolean auto_canFeelHatred()
{
	// Combat Skill - 50 turn banish (doesn't cost a turn)
	if(!auto_is_valid($skill[Feel Hatred]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelHatredUsed").to_int() < 3;
}

boolean auto_canFeelNostalgic()
{
	// Combat Skill - adds drop table from last copyable monster to the current (see lastCopyableMonster property)
	if(!auto_is_valid($skill[Feel Nostalgic]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelNostalgicUsed").to_int() < 3;
}

boolean auto_canFeelPride()
{
	// Combat Skill - Triples stat gain from the current fight.
	if(!auto_is_valid($skill[Feel Pride]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelPrideUsed").to_int() < 3;
}

boolean auto_canFeelSuperior()
{
	// Combat Skill - Does 20% of monsters max HP as damage and gives +1 PvP fight if it kills the monster.
	if(!auto_is_valid($skill[Feel Superior]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelSuperiorUsed").to_int() < 3;
}

boolean auto_canFeelLonely()
{
	// Non-Combat Skill - -5% combat rate (20 adventures)
	if(!auto_is_valid($skill[Feel Lonely]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelLonelyUsed").to_int() < 3;
}

boolean auto_canFeelExcitement()
{
	// Non-Combat Skill - +25 to all stats (20 adventures)
	if(!auto_is_valid($skill[Feel Excitement]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelExcitementUsed").to_int() < 3;
}

boolean auto_canFeelNervous()
{
	// Non-Combat Skill - deals passive damage on hit starting at 20 decrementing by 1 every proc (20 adventures)
	if(!auto_is_valid($skill[Feel Nervous]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelNervousUsed").to_int() < 3;
}

boolean auto_canFeelPeaceful()
{
	// Non-Combat Skill - +2 all res, +10 DR, +100 DA (20 adventures)
	if(!auto_is_valid($skill[Feel Peaceful]))
	{
		return false;
	}
	return auto_haveEmotionChipSkills() && get_property("_feelPeacefulUsed").to_int() < 3;
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
	if (auto_haveBackupCamera()) 
	{
		return 11 + (in_robot() ? 5 : 0) - get_property("_backUpUses").to_int();
	}
	return 0;
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

	// don't backup if nextAdventure is None as a combat was somewhere that is not a zone
	if (get_property("nextAdventure").to_location() == $location[None])
	{
		return false;
	}

	// don't backup into oliver's (it won't be free and will waste a free fight and currently also mess up tracking)
	if (get_property("nextAdventure").to_location() == $location[An Unusually Quiet Barroom Brawl])
	{
		return false;
	}

	// determine if we want to backup
	boolean wantBackupLFM = item_amount($item[barrel of gunpowder]) < 5 && get_property("sidequestLighthouseCompleted") == "none" && internalQuestStatus("questL12War") == 1 && !auto_hasAutumnaton() && !in_koe();
	boolean wantBackupNSA = (item_amount($item[ninja rope]) < 1 || item_amount($item[ninja carabiner]) < 1 || item_amount($item[ninja crampons]) < 1) && internalQuestStatus("questL08Trapper") < 3 && !get_property("auto_L8_extremeInstead").to_boolean();
	int habitatZombieEvil = (auto_habitatMonster() == $monster[modern zmobie] ? (auto_habitatFightsLeft() * (5 + cyrptEvilBonus())) : 0);
	boolean wantBackupZmobie = get_property("cyrptAlcoveEvilness").to_int() > (14 + cyrptEvilBonus() + habitatZombieEvil) && internalQuestStatus("questL07Cyrptic") == 0;

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
			if(!wantBackupLFM && !wantBackupNSA && !wantBackupZmobie && auto_backupUsesLeft() > 5)
				return true;
			break;
		case $monster[eldritch tentacle]:
			//backup tentacles if lots of backups remaining or use all remaining charges if at end of day
			if(auto_backupUsesLeft() > 6)
				return true;
			if (my_adventures() <= (1 + auto_advToReserve()) && inebriety_left() == 0 && stomach_left() < 1)
				return true;
			break;
		case $monster[fantasy bandit]:
			if(!acquiredFantasyRealmToken() && auto_backupUsesLeft() >= (5 - fantasyBanditsFought()) && auto_habitatMonster() != $monster[fantasy bandit])
				return true;
			break;
		case $monster[Green Ops Soldier]:
			if(get_property("hippiesDefeated").to_int() > 399 && get_property("hippiesDefeated").to_int() < 1000 && !in_koe())
				return true;
			break;
		case $monster[Skinflute]:
		case $monster[Camel's Toe]:
			if (needStarKey() && item_amount($item[star]) < 8 && item_amount($item[line]) < 7)
				return true;
			break;
		default: break;
    }

	return false;
}

boolean auto_backupToYourLastEnemy(location loc)
{
	// can't backup if we don't have the camera or no charges left or no valid target/location
	if (!auto_haveBackupCamera() || auto_backupUsesLeft() == 0 || !auto_backupTarget() || loc == $location[none])
	{
		return false;
	}

	if (autoEquip($slot[acc3], $item[backup camera]))
	{
		set_property("auto_nextEncounter", get_property("lastCopyableMonster"));
		return autoAdv(loc);
	}
	set_property("auto_nextEncounter","");
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
	if(in_koe())
	{
		// can't access fireworks shop in kindom of exploathing
		return false;
	}
	if(is_werewolf())
	{
		return false; //can't access fireworks shop as a werewolf
	}
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
	// equipment doesn't give buffs in these paths
	if(in_gnoob() || in_tcrs())
	{
		return false;
	}

	if(!have_fireworks_shop())
	{
		return false;
	}

	if(get_property("_fireworksShopHatBought").to_boolean())
	{
		return false;
	}

	if(my_meat() < npc_price($item[porkpie-mounted popper]) + meatReserve() && auto_is_valid($item[porkpie-mounted popper]))
	{
		auto_log_info("Want to buy a hat from the fireworks shop, but don't have enough meat. Will try again later.");
		return false;
	}

	// noncombat is most valuable hat but has no effect in LAR
	if(auto_can_equip($item[porkpie-mounted popper]) && !in_lar())
	{
		float simNonCombat = providePlusNonCombat(25, $location[noob cave], true, true);
		if(simNonCombat < 25.0)
		{
			retrieve_item(1, $item[porkpie-mounted popper]);
			return true;
		}
	}

	// +combat hat is second most useful but has no effect in LAR and kills the professor
	if(auto_can_equip($item[sombrero-mounted sparkler]) && !(in_lar() || in_wereprof()))
	{
		float simCombat = providePlusCombat(25, $location[noob cave], true, true);
		if(simCombat < 25.0)
		{
			retrieve_item(1, $item[sombrero-mounted sparkler]);
			return true;
		}
	}

	// ML hat is least useful
	// todo: add functionality to simulate acquiring ML instead of just looking at current ML
	if(auto_can_equip($item[fedora-mounted fountain]))
	{
		if(monster_level_adjustment() < get_property("auto_MLSafetyLimit").to_int())
		{
			retrieve_item(1, $item[fedora-mounted fountain]);
			return true;
		}
	}
	
	return false;
}

boolean auto_haveFireExtinguisher()
{
	item exting = wrap_item($item[industrial fire extinguisher]);
	return possessEquipment(exting) && auto_is_valid(exting);
}

int auto_fireExtinguisherCharges()
{
	if (!auto_haveFireExtinguisher()) return 0;
	return get_property("_fireExtinguisherCharge").to_int();
}

// returns zone specific skill if in usable zone and hasn't been used yet there this ascension. Otherwise returns empty string
string auto_FireExtinguisherCombatString(location place)
{
	if(auto_fireExtinguisherCharges() < 20 || !auto_is_valid($skill[Fire Extinguisher: Zone Specific]))
	{
		return "";
	}

	if(in_wereprof())
	{
		return "";
	}

	// once per ascension uses
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

	if(place == $location[The Smut Orc Logging Camp] && !get_property("fireExtinguisherChasmUsed").to_boolean() && get_property("chasmBridgeProgress").to_int() < 30 && !auto_hasAutumnaton())
	{
		return "skill " + $skill[Fire Extinguisher: Zone Specific];
	}

	if(place == $location[The Arid\, Extra-Dry Desert] && $location[The Arid\, Extra-Dry Desert].turns_spent > 0 && !get_property("fireExtinguisherDesertUsed").to_boolean() && !auto_haveBofa())
	{
		return "skill " + $skill[Fire Extinguisher: Zone Specific];
	}


	return "";
	
}

boolean auto_canExtinguisherBeRefilled()
{
	return auto_haveFireExtinguisher() && in_wildfire() && !get_property("_fireExtinguisherRefilled").to_boolean();
}

boolean auto_haveColdMedCabinet()
{
	return auto_get_campground() contains $item[cold medicine cabinet] && auto_is_valid($item[cold medicine cabinet]);
}

int auto_CMCconsultsLeft()
{
	if(!auto_haveColdMedCabinet())
	{
		return 0;
	}
	int consultsUsed = get_property("_coldMedicineConsults").to_int();
	if(consultsUsed > 5)
	{
		auto_log_warning("Mafia's tracking of Cold Medicine Cabinet consults today errored (reported > 5 uses today). Reseting to 5.", "red");
		consultsUsed = 5;
	}
	return 5 - consultsUsed;
}

boolean auto_CMCconsultAvailable()
{
	if(auto_CMCconsultsLeft() == 0)
	{
		return false;
	}

	int nextConsult = get_property("_nextColdMedicineConsult").to_int();
	//prior to first use each day, prop value is 0
	if(nextConsult == 0)
	{
		return true;
	}
	return total_turns_played() >= nextConsult;
}

void auto_CMCconsult()
{
	//consume previously bought items if conditions are right
	//perhaps pill was bought yesterday with full spleen
	boolean notAboutToDoNuns()
	{
		//should avoid getting more free kill charges when about to do nuns because the fights would be capped to 1000 meat
		if(my_level() >= 12)
		{
			if(my_location() == $location[The Themthar Hills])
			{
				return false;
			}
			if(my_location() == $location[the battlefield (frat uniform)] && get_property("sidequestNunsCompleted") == "none")
			{
				int hippiesDefeated = get_property("hippiesDefeated").to_int();
				if(hippiesDefeated <= 208 && auto_bestWarPlan().do_nuns)
				{	
					int turnsUntilNuns = min(16,ceil(max(0,191.0 - hippiesDefeated)/auto_warKillsPerBattle()));
					if(get_property("breathitinCharges").to_int() + 5 >= turnsUntilNuns)
					{
						return false;	//may do nuns before breathitin charges get used up
					}
				}
			}
			if(get_property("auto_hippyInstead").to_boolean() && internalQuestStatus("questL12War") == 1 && get_property("sidequestNunsCompleted") == "none")
			{
				if(auto_bestWarPlan().do_nuns && (get_property("sidequestOrchardCompleted") != "none" || !auto_bestWarPlan().do_orchard))
				{
					return false;	//war started and about to start nuns as hippy anytime?
				}
			}
		}
		return true;
	}
	boolean shouldChewBreathitin()
	{
		if(my_location() == $location[The Hidden Park])
		{
			//already free [dense liana] should come right after and would waste charges
			//can't know how many combats will remain in the park which is ideally noncombats
			return false;
		}
		return notAboutToDoNuns();
	}
	if(shouldChewBreathitin() && !isActuallyEd() && !haveSpleenFamiliar() && !can_interact())
	{
		pullXWhenHaveY($item[Breathitin&trade;],1,0);
	}
	if(item_amount($item[Breathitin&trade;]) > 0 && shouldChewBreathitin() && !can_interact())
	{
		autoChew(1,$item[Breathitin&trade;]);
	}
	if(item_amount($item[Homebodyl&trade;]) > 0 && freeCrafts() < 5)
	{
		autoChew(1,$item[Homebodyl&trade;]);
	}
	//use fleshazole if we don't have much meat
	if(item_amount($item[Fleshazole&trade;]) > 0 && my_meat() + 2000 < meatReserve() && my_level() >= 5)
	{
		autoChew(1,$item[Fleshazole&trade;]);
	}
	
	if(!auto_CMCconsultAvailable())
	{
		return;
	}

	if(get_property("_auto_coldMedicineLocked").to_boolean())
	{
		//haven't visited yet since it was last locked so always visit to update available consults
		set_property("_auto_coldMedicineLocked","false");
	}
	else if(auto_CMCconsultsLeft() <= 2 && freeCrafts() >= 5 && possessEquipment($item[ice crown]) && my_meat() >= meatReserve())
	{
		//only looking for Breathitin from at least 11 fights spent underground
		if(my_location().environment != "underground")
		{
			//if Breathitin was not available last turn and last location was not underground it will still not be available now so no visit needed
			return;
		}
	}

	int bestOption = -1;
	item consumableBought = $item[none];
	string page = visit_url("campground.php?action=workshed");
	if(contains_text(page, "Breathitin"))
	{
		auto_log_info("Buying Breathitin pill from CMC", "blue");
		bestOption = 5;
		consumableBought = $item[Breathitin&trade;];
	}
	else if (!(auto_is_valid($familiar[cookbookbat]) && have_familiar($familiar[cookbookbat]) && knoll_available()) && contains_text(page, "Homebodyl") && freeCrafts() < 5)
	{
		// don't need free crafts if we have the Cookbookbat in knoll signs.
		// Cookbookbat gives us 5 free cooks every day & we only use free crafting on cooking in knoll signs
		auto_log_info("Buying Homebodyl pill from CMC", "blue");
		bestOption = 5;
		consumableBought = $item[Homebodyl&trade;];
	}
	else if ((!in_small() || in_hardcore()) && contains_text(page, "ice crown"))
	{
		// don't need the ice crown in Normal Small as we pull hats.
		auto_log_info("Buying ice crown from CMC", "blue");
		bestOption = 1;
	}
	else if(contains_text(page, "Fleshazole") && my_meat() + 2000 < meatReserve())
	{
		auto_log_info("Buying Fleshazole pill from CMC", "blue");
		bestOption = 5;
		consumableBought = $item[Fleshazole&trade;];
	}
	else if (auto_CMCconsultsLeft() > 2 && !can_interact() && !in_small() && !in_kolhs())

	{
		//reserve the last 2 consults for something more valuable than booze/food
		//consume logic will drink/eat later
		if(inebriety_left() > 0)
		{
			auto_log_info("Buying booze from CMC", "blue");
			bestOption = 3;
		}
		else if(fullness_left() > 0)
		{
			auto_log_info("Buying food from CMC", "blue");
			bestOption = 2;
		}
	}

	if(bestOption != -1)
	{
		set_property("_auto_coldMedicineLocked","true");	//when taking a consultation, set property as a reminder to always check again next time consultations are unlocked
		run_choice(bestOption);
	}

	if(consumableBought == $item[Homebodyl&trade;] || (consumableBought == $item[Breathitin&trade;] && shouldChewBreathitin()))
	{
		autoChew(1,consumableBought);
	}

	if(consumableBought == $item[Fleshazole&trade;] && my_meat() < meatReserve() && my_level() >= 5)
	{
		autoChew(1,consumableBought);
	}	
}
