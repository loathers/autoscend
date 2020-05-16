script "low_key_summer.ash"

location[item] lowKeys;
lowKeys[$item[Clown car key]] = $location[The \"Fun\" House];
lowKeys[$item[Peg key]] = $location[The Obligatory Pirate\'s Cove];
lowKeys[$item[Ice Key]] = $location[The Icy Peak];
lowKeys[$item[Demonic key]] = $location[Pandemonium Slums];
lowKeys[$item[Rabbit\'s foot key]] = $location[The Dire Warren];
lowKeys[$item[Weremoose key]] = $location[Cobb\'s Knob Menagerie, Level 2];
lowKeys[$item[Deep-fried key]] = $location[Madness Bakery];
//The Valley of Rof L'm Fao(?) OR The Enormous Greater-Than Sign(?);
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
lowKeys[$item[Aquí]] = $location[South of the Border];
lowKeys[$item[Knob labinet key]] = $location[Cobb\'s Knob Laboratory];
lowKeys[$item[Knob treasury key]] = $location[Cobb\'s Knob Treasury];

item[stat] lowKeyStats;
lowKeyStats[$stat[muscle]] = $item[Knob labinet key];
lowKeyStats[$stat[moxie]] = $item[scrap metal key];
lowKeyStats[$stat[muscle]] = $item[Demonic key];

// TODO Order
boolean[item] lowKeyPriority = $items[
	Treasure chest key,			// +30 item, +30 meat
	Knob treasury key,			// +50 meat, +20 pickpocket
	Key sausage,				// -10 combat?
	Music Box Key,				// +10 combat?
	F\'c\'le sh\'c\'le k\'y,	// +20 ml
	Clown car key,				// +10 ml, +10 prismatic damage
	knob shaft skate key,		// +adv
	Peg key,					// +5 stats
];

void lowkey_initializeSettings()
{
	if (auto_my_path() == "Low Key Summer")
	{
		// TODO?
	}
}

int lowkey_keyDelayRemaining(location loc)
{
	return max(11 - loc.turns_spent, 0);
}

int lowkey_keysRemaining()
{
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
	int available = 0;
	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (key.available_amount() == 0 && zone_isAvailable(primstatLocation))
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
	if (auto_my_path() == "Low Key Summer")
	{
		return $location[none];
	}

	// Get primestat gains key first?
	if (my_level() < 13)
	{
		item primestatkey = lowKeyStats[my_primestat()];
		location primstatLocation = lowKeys[primestatkey];
		if (primestatkey.available_amount() == 0 && zone_isAvailable(primstatLocation))
		{
			return primstatLocation;
		}
	}

	// Get high priority keys
	foreach key in lowKeyPriority
	{
		location loc = lowKeys[key];
		if (key.available_amount() == 0)
		{
			if (checkAvailable || zone_isAvailable(loc))
			{
				return lowKeys[key];
			}
		}
	}

	// The rest, I'm not ordering all the keys some are garbage
	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (key.available_amount() == 0 && zone_isAvailable(loc))
		{
			return lowKeys[key];
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