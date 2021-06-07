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
	return 11 + (my_path() == "You, Robot" ? 5 : 0) - get_property("_backUpUses").to_int();
}

boolean auto_havePowerPlant()
{
	return possessEquipment($item[potted power plant]) && auto_is_valid($item[potted power plant]);
}

void auto_harvestBatteries()
{
	if (auto_havePowerPlant())
	{
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
	}
}

// These points the value of a battery represented in AAAs.
int batteryPoints(item battery)
{
	int points = 0;
	switch (battery)
	{
		case $item[battery (AAA)]:
			points = 1;
			break;
		case $item[battery (AA)]:
			points = 2;
			break;
		case $item[battery (D)]:
			points = 3;
			break;
		case $item[battery (9-Volt)]:
			points = 4;
			break;
		case $item[battery (lantern)]:
			points = 5;
			break;
		case $item[battery (car)]:
			points = 6;
			break;
	}
	return points;
}

// These points represent a quantity of AAAs if all batteries were untinkered.
int totalBatteryPoints()
{
	// If the untinker function can't be used, there's effectively no points.
	if (get_property("questM01Untinker") != "finished")
	{
		return 0;
	}

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
		// Every multi step case with recusion.
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
		// Every multi step case with recusion.
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
		// Every other multi step case with recusion.
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

	// We need to check that we can untinker (handled by totalBatteryPoints), 
	// then make sure we have enough AAA value to craft the target battery.
	if (totalBatteryPoints() > batteryPoints(battery))
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
