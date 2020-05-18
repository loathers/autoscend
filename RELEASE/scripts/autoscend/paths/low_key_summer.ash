script "low_key_summer.ash"

location[item] lowKeys;
lowKeys[$item[Clown car key]] = $location[The \"Fun\" House];
lowKeys[$item[Peg key]] = $location[The Obligatory Pirate\'s Cove];
lowKeys[$item[Ice Key]] = $location[The Icy Peak];
lowKeys[$item[Demonic key]] = $location[Pandamonium Slums];
lowKeys[$item[Rabbit\'s foot key]] = $location[The Dire Warren];
lowKeys[$item[Weremoose key]] = $location[Cobb\'s Knob Menagerie, Level 2];
lowKeys[$item[Deep-fried key]] = $location[Madness Bakery];
lowkeys[$item[Kekekey]] = $location[The Valley of Rof L\'m Fao];
lowKeys[$item[Treasure chest key]] = $location[Belowdecks];
lowKeys[$item[Music Box Key]] = $location[The Haunted Nursery];
lowKeys[$item[Actual skeleton key]] = $location[The Skeleton Store];
lowKeys[$item[Batting cage key]] = $location[The Bat Hole Entrance];
lowKeys[$item[Anchovy can key]] = $location[The Haunted Pantry];
lowKeys[$item[F\'c\'le sh\'c\'le k\'y]] = $location[The F\'c\'le];
lowKeys[$item[cactus key]] = $location[The Arid\, Extra-Dry Desert];
lowKeys[$item[Key sausage]] = $location[Cobb\'s Knob Kitchens];
lowKeys[$item[knob shaft skate key]] = $location[The Knob Shaft];
lowKeys[$item[Black rose key]] = $location[The Haunted Conservatory];
lowKeys[$item[scrap metal key]] = $location[The Old Landfill];
lowKeys[$item[Discarded bike lock key]] = $location[The Overgrown Lot];
lowKeys[$item[aqu&iacute;]] = $location[South of the Border];
lowKeys[$item[Knob labinet key]] = $location[Cobb\'s Knob Laboratory];
lowKeys[$item[Knob treasury key]] = $location[Cobb\'s Knob Treasury];

boolean in_lowkeysummer()
{
	return auto_my_path() == "Low Key Summer";
}

void lowkey_initializeSettings()
{
	if (!in_lowkeysummer())
	{
		return;
	}

	// TODO?
}

int lowkey_keyDelayRemaining(location loc)
{
	if (!in_lowkeysummer())
	{
		return 0;
	}

	return max(11 - loc.turns_spent, 0);
}

int lowkey_keysRemaining()
{
	if (!in_lowkeysummer())
	{
		return 0;
	}

	int found = 0;
	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (key.available_amount() > 0)
		{
			found++;
		}
	}

	return 23 - found;
}

int lowkey_keyLocationsAvailable()
{
	if (!in_lowkeysummer())
	{
		return 0;
	}

	int available = 0;
	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (key.available_amount() == 0 && zone_isAvailable(loc))
		{
			available++;
		}
	}

	return available;
}

// TODO: Unaware if a key has been used and lost
// order is subjective
location lowkey_nextKeyLocation(boolean checkAvailable)
{
	if (!in_lowkeysummer())
	{
		return $location[none];
	}

	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (key.available_amount() == 0)
		{
			if (!checkAvailable || zone_isAvailable(loc))
			{
				return lowKeys[key];
			}
		}
	}

	return $location[none];
}

location lowkey_nextKeyLocation()
{
	return lowkey_nextKeyLocation(false);
}

location lowkey_nextAvailableKeyLocation()
{
	return lowkey_nextKeyLocation(true);
}

location lowkey_nextAvailableKeyDelayLocation()
{
	if (!in_lowkeysummer())
	{
		return $location[none];
	}

	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (key.available_amount() == 0 && zone_isAvailable(loc) && lowkey_keyDelayRemaining(loc) > 0)
		{
			return lowKeys[key];
		}
	}

	return $location[none];
}

boolean lowkey_keyAdv(item key)
{
	if (key.available_amount() > 0)
	{
		return false;
	}

	location loc = lowKeys[key];
	if (!zone_isAvailable(loc))
	{
		return false;
	}

	return autoAdv(1, loc);
}

boolean lowkey_zoneUnlocks()
{
	if(my_basestat(my_primestat()) >= 25 && get_property("questM19Hippy") == "unstarted")
	{
		string temp = visit_url("place.php?whichplace=woods&action=woods_smokesignals");
		temp = visit_url("choice.php?pwd=&whichchoice=798&option=1");
		temp = visit_url("choice.php?pwd=&whichchoice=798&option=2");
		temp = visit_url("woods.php");

		if(get_property("questM19Hippy") == "unstarted")
		{
			abort("Failed to unlock The Old Landfill. Not sure what to do now...");
		}
		return true;
	}

	if (startArmorySubQuest())
	{
		return true;
	}

	return false;
}

boolean LX_findHelpfulLowKey()
{
	if (lowkey_zoneUnlocks())
	{
		return true;
	}

	// mainstat
	if (my_level() < 13)
	{
		// needs knob lab access
		if (my_primestat() == $stat[Muscle] && lowkey_keyAdv($item[Knob labinet key])) { return true; }
		// needs accept landfil quest
		if (my_primestat() == $stat[Moxie] && lowkey_keyAdv($item[scrap metal key])) { return true; }
		// Needs Pandamonium access
		if (my_primestat() == $stat[Mysticality] && lowkey_keyAdv($item[Demonic key])) { return true; }
	}

	// -combat
	if (lowkey_keyAdv($item[Key sausage])) { return true; }

	// +item
	// needs pirate quest ugh
	if (lowkey_keyAdv($item[Treasure chest key])) { return true; }

	// +meat
	if (lowkey_keyAdv($item[Knob treasury key])) { return true; }
	if (lowkey_keyAdv($item[Kekekey])) { return true; }

	// Knob key to unlock shaft for +adv
	if (lowkey_keyAdv($item[Knob labinet key])) { return true; }

	// +adv
	if (lowkey_keyAdv($item[Knob shaft skate key])) { return true; }

	if (internalQuestStatus("questL09Topping") == 3)
	{
		// +ml (before oil peak)
		// needs pirate quest ugh
		if (lowkey_keyAdv($item[F\'c\'le sh\'c\'le k\'y])) { return true; }
		// needs accept nemesis quest
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
		// cold res before aboo
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
		// spooky res before aboo
		if (lowkey_keyAdv($item[Weremoose key])) { return true; }
	}

	// sleaze damage before red zeppelin
	if (internalQuestStatus("questL11Ron") > 1 && internalQuestStatus("questL11Ron") < 5)
	{
		if (lowkey_keyAdv($item[Deep-fried key])) { return true; }
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
	}

	// cold spell damage before orcs
	if (internalQuestStatus("questL09Topping") == 0 && get_property("chasmBridgeProgress").to_int() < 30)
	{
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
	}

	// +combat before sonofa
	if (internalQuestStatus("questL12War") == 1 && get_property("sidequestLighthouseCompleted") == "none")
	{
		if (lowkey_keyAdv($item[Music Box Key])) { return true; }
	}

	// Attributes?
	//if (lowkey_keyAdv($item[Rabbit\'s foot key])) { return true; }

	// familiar weight?
	//if (lowkey_keyAdv($item[Black rose key])) { return true; }

	// food drops?
	//if (lowkey_keyAdv($item[Anchovy can key])) { return true; }

	return false;
}

boolean L13_sorceressDoorLowKey()
{
	if (!in_lowkeysummer())
	{
		return false;
	}

	// TODO: Check door for unlocked locks to prevent infinite loops
	// https://kolmafia.us/showthread.php?25001-Low-Key-path&p=157469&viewfull=1#post157469

	// TODO: Handle the standard keys

	location loc = lowkey_nextAvailableKeyLocation();

	if (loc == $location[none])
	{
		int remaining = lowkey_keysRemaining();
		// TODO: Unlock required zones
		if (remaining > 0)
		{
			auto_log_warning("Unable to adventure for remaining low keys");
			foreach key in lowKeys
			{
				if (key.available_amount() == 0)
				{
					auto_log_warning(lowKeys[key] + " " + key);
				}
			}
			abort("Please unlock zones manually and try again.");
		}
		// TODO: Unlock doors
		abort("All low keys found, please unlock door manually.");
		return false;
	}

	return autoAdv(1, loc);
}