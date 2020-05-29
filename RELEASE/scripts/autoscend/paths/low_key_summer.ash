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

boolean lowkey_needKey(item key)
{
	if (internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	return key.available_amount() == 0 && !contains_text(get_property("nsTowerDoorKeysUsed"), key);
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
		if (!lowkey_needKey(key))
		{
			found++;
		}
	}

	return 23 - found;
}

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
		if (lowkey_needKey(key))
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
		if (lowkey_needKey(key) && zone_isAvailable(loc) && lowkey_keyDelayRemaining(loc) > 0)
		{
			return lowKeys[key];
		}
	}

	return $location[none];
}

boolean lowkey_keyAdv(item key)
{
	if (!lowkey_needKey(key))
	{
		return false;
	}

	location loc = lowKeys[key];
	if (!zone_isAvailable(loc))
	{
		return false;
	}

	// Pirate equipment
	if ($locations[The F\'c\'le, Belowdecks] contains loc)
	{
		if (possessEquipment($item[pirate fledges]))
		{
			autoEquip($item[pirate fledges]);
		}
		else if (have_outfit("swashbuckling getup"))
		{
			autoEquip($item[eyepatch]);
			autoEquip($item[swashbuckling pants]);
			autoEquip($item[stuffed shoulder parrot]);
		}
		else
		{
			// Shouldn't get here due to zone_isAvailable check
			return false;
		}
	}

	return autoAdv(1, loc);
}

boolean lowkey_zoneUnlocks()
{
	if(startHippyBoatmanSubQuest())
	{
		// opens The Old Landfill for scrap metal key (+20% to all Moxie Gains)
		return true;
	}

	if (startArmorySubQuest())
	{
		// opens Madness Bakery for deep-fried key (+3 sleaze res, +15 sleaze dmg, +30 sleaze spell dmg)
		return true;
	}

	if (startGalaktikSubQuest())
	{
		// opens The Overgrown Lot for discarded bike lock key (+10 MP,  4-5 MP regen)
		return true;
	}

	if (startMeatsmithSubQuest()) {
		// opens The Skeleton Store for actual skeleton key (100 DA, 10 DR)
		return true;
	}

	return false;
}

boolean LX_findHelpfulLowKey()
{
	if (!in_lowkeysummer())
	{
		return false;
	}

	if (internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

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
		if (my_primestat() == $stat[Moxie] && (LX_hippyBoatman() || lowkey_keyAdv($item[scrap metal key]))) { return true; }
		// Needs Pandamonium access
		if (my_primestat() == $stat[Mysticality] && lowkey_keyAdv($item[Demonic key])) { return true; }
	}

	// familiar weight
	if (lowkey_keyAdv($item[Black rose key])) { return true; }

	// -combat. Key sausage needs Cobb's Knob Access
	if (lowkey_keyAdv($item[Key sausage])) { return true; }

	// +item
	// Treasure chest key needs Belowdecks access
	if (lowkey_keyAdv($item[Treasure chest key])) { return true; }

	// +meat. Knob treasury key needs Cobb's Knob Access. Kekekey needs The Valley of Rof L'm Fao access.
	if (lowkey_keyAdv($item[Knob treasury key])) { return true; }
	if (lowkey_keyAdv($item[Kekekey])) { return true; }

	// Knob key to unlock shaft for +adv. needs Cobb's Knob Access
	if (item_amount($item[Cobb\'s Knob lab key]) < 1 && lowkey_keyAdv($item[Knob labinet key])) { return true; }

	// +adv. Knob shaft skate key needs Cobb's Knob lab key for access to Knob Shaft
	if (lowkey_keyAdv($item[Knob shaft skate key])) { return true; }

	if (internalQuestStatus("questM20Necklace") < 1) {
		// hot res for the Haunted Kitchen. aquí needs Desert Beach Access
		if (lowkey_keyAdv($item[aqu&iacute;])) { return true; }
		// stench res for the Haunted Kitchen
		if (lowkey_keyAdv($item[batting cage key])) { return true; }
	}

	if (internalQuestStatus("questL09Topping") > 0 && internalQuestStatus("questL09Topping") < 3) {
		// +ml (before oil peak)
		// F'c'le sh'c'le k'y needs F'c'le access
		if (lowkey_keyAdv($item[F\'c\'le sh\'c\'le k\'y])) { return true; }
		// Clown car key needs "Fun" house access
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
		// cold res before aboo. Needs Icy Peak Access
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
		// spooky res before aboo. Needs Menagerie access.
		if (lowkey_keyAdv($item[Weremoose key])) { return true; }
	}

	// sleaze damage before red zeppelin
	if (internalQuestStatus("questL11Ron") > -1 && internalQuestStatus("questL11Ron") < 2) {
		if (lowkey_keyAdv($item[Deep-fried key])) { return true; }
		// Clown car key needs "Fun" house access
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
	}

	// cold spell damage before orcs. Ice Key needs The Icy Peak access
	if (internalQuestStatus("questL09Topping") == 0 && get_property("chasmBridgeProgress").to_int() < 30)
	{
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
	}

	// +combat before sonofa. Music Box Key needs Spookyraven Manor third floor access
	if (internalQuestStatus("questL12War") == 1 && get_property("sidequestLighthouseCompleted") == "none")
	{
		if (lowkey_keyAdv($item[Music Box Key])) { return true; }
	}

	// Attributes. This is a nowander zone so burning delay here is unlikely.
	//if (lowkey_keyAdv($item[Rabbit\'s foot key])) { return true; }

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

	if (internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	// TODO: Handle the standard keys

	location loc = lowkey_nextAvailableKeyLocation();

	if (loc == $location[none])
	{
		int remaining = lowkey_keysRemaining();
		if (remaining > 0)
		{
			auto_log_warning("Unable to adventure for remaining low keys");
			foreach key in lowKeys
			{
				if (lowkey_needKey(key))
				{
					auto_log_warning(lowKeys[key] + ": " + key);
				}
			}
			abort("Please unlock zones manually and try again.");
		}
		// Unlock door
		if (tower_door()) {
			return true;
		}
		return false;
	}

	return autoAdv(1, loc);
}

boolean LX_lowkeySummer() {
	if (!in_lowkeysummer()) {
		return false;
	}

	// Stuff we need to do in this path to unlock key zones.
	if (LX_pirateQuest()) {
		return true;
	}
	if (LX_acquireLegendaryEpicWeapon()) {
		return true;
	}
	return false;
}