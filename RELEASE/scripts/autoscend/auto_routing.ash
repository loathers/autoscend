
location solveDelayZone(boolean skipOutdoorZones)
{
	int[location] delayableZones = zone_delayable();
	location burnZone = $location[none];
	if (count(delayableZones) > 0)
	{
		// find the delayable zone with the lowest delay left.
		foreach loc, delay in delayableZones
		{
			if (skipOutdoorZones && loc.environment == "outdoor")
			{
				continue;
			}
			if (burnZone == $location[none] || delay < delayableZones[burnZone])
			{
				burnZone = loc;
			}
			if (loc == $location[The Spooky Forest] && delay == delayableZones[burnZone])
			{
				// prioritise the Spooky Forest when its delay remaining equals the lowest delay zone
				burnZone = loc;
			}
		}
	}

	if (burnZone != $location[none])
	{
		return burnZone;
	}

	// These are locations that aren't 1:1 turn savings, but can still be useful

	// Shorten the time before finding Gnasir, so that we can start acquiring desert pages sooner
	if (!skipOutdoorZones && zone_isAvailable($location[The Arid\, Extra-Dry Desert]) && $location[The Arid\, Extra-Dry Desert].turns_spent >= 1 && $location[The Arid\, Extra-Dry Desert].turns_spent < 10)
	{
		burnZone = $location[The Arid\, Extra-Dry Desert];
	}

	// Shorten the time until the first "burn a food or drink" noncombat
	// There's some opportunity to be clever here, but this is probably good enough.
	// If we didn't check turns_spent we'd have to be careful to equip the war outfit,
	// just in case the noncombat shows up.
	if (in_koe() && $location[The Exploaded Battlefield].turns_spent < 5)
	{
		burnZone = $location[The Exploaded Battlefield];
	}

	if (in_lowkeysummer())
	{
		burnZone = lowkey_nextAvailableKeyDelayLocation();
	}

	return burnZone;
}

location solveDelayZone()
{
	return solveDelayZone(false);
}

boolean allowSoftblockDelay()
{
	return get_property("auto_delayLastLevel").to_int() < my_level();
}

boolean canBurnDelay(location loc)
{
	// TODO: Add Digitize (Portscan?) & LOV Enamorang
	if (!zone_delay(loc)._boolean || !allowSoftblockDelay())
	{
		return false;
	}
	if (auto_haveBackupCamera() && auto_backupUsesLeft() > 0)
	{
		return true;
	}
	else if (auto_haveKramcoSausageOMatic() && auto_sausageFightsToday() < 9)
	{
		return true;
	}
	else if (auto_haveVotingBooth() && get_property("_voteFreeFights").to_int() < 3)
	{
		return true;
	}
	else if (my_daycount() < 2 && (auto_haveVotingBooth() || auto_haveKramcoSausageOMatic() || auto_haveBackupCamera() || auto_haveCursedMagnifyingGlass()))
	{
		return true;
	}
	return false;
}

boolean allowSoftblockUndergroundAdvs()
{
	return get_property("auto_cmcConsultLastLevel").to_int() < my_level();
}

int[string] getLastCombatEnvironmentCounts(int offset)
{
	// mafia has no char type. string will have to do.
	int[string] counts = {"i" : 0, "o" : 0, "u" : 0, "x" : 0, "?" : 0};
	string[int] environments = split_string(substring(get_property("lastCombatEnvironments"), max(offset, 0), 20), "");
	// property is always 20 characters long. Uses a queue (FIFO).
	// lastCombatEnvironments = xxxxxxxxxxxxxxxxxxxx
	// i = indoor, o = outdoor, u = underground, x = underwater, ? = unknown/none
	foreach _, env in environments
	{
		counts[env]++;
	}
	return counts;
}

boolean auto_reserveUndergroundAdventures()
{
	// this function should return true when we *don't* want to spend adventures in underground zones.

	if (!allowSoftblockUndergroundAdvs() || (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() == 0 && my_daycount() > 1) || !auto_is_valid($item[cold medicine cabinet]))
	{
		// softblock has been released or we have no more Breathitins to collect.
		return false;
	}
	if (get_workshed() != $item[cold medicine cabinet] && auto_is_valid($item[cold medicine cabinet]) && item_amount($item[cold medicine cabinet]) > 0 &&
	!get_property("_workshedItemUsed").to_boolean() && (LX_getDesiredWorkshed() == $item[cold medicine cabinet] || LX_getDesiredWorkshed() == $item[none]))
	{
		auto_log_debug("Reserving underground adventures as we will be switching to the CMC.");
		// Don't have the CMC installed yet but we can still switch today and want to switch to it so save underground zones until then.
		return true;
	}
	if (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() > 0 && my_daycount() < 3)
	{
		int turns_until_next_consult = get_property("_nextColdMedicineConsult").to_int() - total_turns_played();
		int[string] envs = getLastCombatEnvironmentCounts(turns_until_next_consult);
		if (turns_until_next_consult < 12 && envs["u"] > 10)
		{
			auto_log_debug("Reserving underground adventures as we can still get more Breathitins today.");
			// have the CMC installed & still have consults to use today.
			// we only need 11 underground adventures in the queue for Breathitin to show up.
			// auto_CMCconsult() will (should) grab a Breathitin as soon as it's available
			// so we only need to care about setting the conditions for it to do so
			return true;
		}
	}
	return false;
}

boolean allowSoftblockOutdoorAdvs()
{
	return get_property("auto_breathitinLastLevel").to_int() < my_level();
}

boolean auto_reserveOutdoorAdventures()
{
	// this function should return true when we *don't* want to spend adventures in outdoor zones.
	if (!allowSoftblockOutdoorAdvs() || (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() == 0 && my_daycount() > 1) || !auto_is_valid($item[cold medicine cabinet]) || get_property("breathitinCharges").to_int() > 0)
	{
		// softblock has been released or we have no more Breathitins to collect (or we have Breathitin charges to use).
		return false;
	}
	if (get_workshed() != $item[cold medicine cabinet] && auto_is_valid($item[cold medicine cabinet]) && item_amount($item[cold medicine cabinet]) > 0 &&
	!get_property("_workshedItemUsed").to_boolean() && (LX_getDesiredWorkshed() == $item[cold medicine cabinet] || LX_getDesiredWorkshed() == $item[none]))
	{
		auto_log_debug("Reserving outdoor adventures as we will be switching to the CMC.");
		// Don't have the CMC installed yet but we can still switch today and want to switch to it so save outdoor zones until then.
		return true;
	}
	if (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() > 0 && my_daycount() < 3) {
		auto_log_debug("Reserving outdoor adventures as we can still get more Breathitins today.");
		// have the CMC installed and still have consults left to grab on day 1
		return true;
	}
	return false;
}

boolean auto_earlyRoutingHandling()
{
	// wrapper function for "early" adventure choices depending on state.
	// updating this will be less 'scary' than updating n task order files any time we make a change
	// this function should go very high in task orders, potentially the first thing that spends adventures.
	// ideally nothing called before this should spend an adventure, only update state or use turn free resources.

	// force forcing non-combats.
	if (auto_canForceNextNoncombat()) {
		auto_log_debug("Forcing a non-combat somewhere. Strap yourselves in, kids.");
		if (L6_friarsGetParts() || L10_basement() || L10_topFloor() || L10_holeInTheSkyUnlock())
		{
			// quests where we want to force non-combats
			return true;
		}
	}

	// CMC routing for Breathitins
	if (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() > 0)
	{
		if (get_property("_nextColdMedicineConsult").to_int() - total_turns_played() < 12)
		{
			auto_log_debug("Have a CMC consult coming up in 11 or fewer adventures. Calling a quest function with underground zones.");
			// we have a CMC consult coming up in 11 turns or less
			if (L4_batCave() || L10_basement() || L12_filthworms() || L11_mauriceSpookyraven() || L11_unlockEd() || L7_crypt() || L5_haremOutfit())
			{
				// quests with adventures in underground zones in some sort of priority order here.
				return true;
			}
		}
		else
		{
			// 12 or more turns until the next CMC consult
			if (getLastCombatEnvironmentCounts(9)["u"] > 0)
			{
				auto_log_debug("Have a CMC consult coming up in 12 or more adventures. Calling a quest function with zoneless encounters.");
				// some of the last 11 adventures were underground, lets try to "push" the CMC counter & preserve our underground combats
				// while burning down the counter until the next consult by spending adventures in non-adventure.php locations.
				if (LX_fatLootToken() || L11_defeatEd() || L8_trapperGroar() || L3_tavern())
				{
					return true;
				}
			}
		}
	}
	
	// Using up Breathitin charges if we have them
	if (get_property("breathitinCharges").to_int() > 0)
	{
		auto_log_debug("Have Breathitin Charges to burn. Calling a quest function with outdoor zones.");
		if (LX_unlockHiddenTemple() || L11_hiddenCityZones() || L5_getEncryptionKey() || L10_airship() || 
			L9_chasmBuild() || (get_property("_auto_lastABooCycleFix").to_int() < 5 && L9_highLandlord()) || L6_friarsGetParts())
		{
			// quests with adventures in outdoor zones in some sort of priority order here.
			// LX_unlockHiddenTemple unlocks the Hidden Temple by adventuring in the Spooky Forest. High priority as Hidden City has a lot of delay
			// L11_hiddenCityZones is where we adventure in the Hidden Park which is a needed step to unlock the Hidden City zones.
			// L5_getEncryptionKey unlocks Cobb's Knob (underground zones) by adventuring in Outskirts. It's a delay zone by it has 10 delay so we will adventure here at some point.
			// L10_airship unlocks Castle Basement (underground zone)
			// L9_chasmBuild builds the bridge over the Orc Chasm which unlocks the peaks (also outdoor zones)
			// the rest just finish quests so there's no urgency on getting them done.
			return true;
		}
	}
	else
	{
		if (L11_hiddenCityZones())
		{
			// Should do these ASAP when we don't have Breathitin to open up the rest of the Hidden City.
			return true;
		}
	}
	return false;
}

boolean auto_softBlockHandler()
{
	// "catch all" function to release softblocks one by one.
	// updating this will be less 'scary' than updating n task order files any time we make a change
	// this function should go in task orders after the call to L13_towerAscent
	if (allowSoftblockDelay())
	{
		// Delay goes first as it applies to everyone and is our "OG" softblock
		auto_log_warning("I was trying to avoid delay zones, but I've run out of stuff to do. Releasing softblock.", "red");
		set_property("auto_delayLastLevel", my_level());
		return true;
	}
	if (allowSoftblockUndergroundAdvs())
	{
		// Underground is next. Currently only applies to people who have and can use the CMC.
		auto_log_warning("I was trying to avoid underground zones, but I've run out of stuff to do. Releasing softblock.", "red");
		set_property("auto_cmcConsultLastLevel", my_level());
		return true;
	}
	if (allowSoftblockOutdoorAdvs())
	{
		// Outdoor goes last. Not currently used but lets add it just in case we do implement it before CMC rotates out.
		auto_log_warning("I was trying to avoid outdoor zones, but I've run out of stuff to do. Releasing softblock.", "red");
		set_property("auto_breathitinLastLevel", my_level());
		return true;
	}
	return false;
}

item[int] auto_workshedStrategy()
{
	// return the worksheds, in order, that we want to use today.
	item[int] strat;
	if (get_property("_workshedItemUsed").to_boolean()) {
		// we already changed workshed today. Just return whatever is in our workshed currently.
		strat[0] = get_workshed();
	}
	return strat;
}
