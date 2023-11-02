
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

boolean setSoftblockDelay()
{
	auto_log_warning("I was trying to avoid delay zones, but I've run out of stuff to do. Releasing softblock.", "red");
	set_property("auto_delayLastLevel", my_level());
	return true;
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

boolean setSoftblockUndergroundAdvs()
{
	auto_log_warning("I was trying to avoid underground zones, but I've run out of stuff to do. Releasing softblock.", "red");
	set_property("auto_cmcConsultLastLevel", my_level());
	return true;
}

boolean auto_reserveUndergroundAdventures()
{
	// this function should return true when we *don't* want to spend adventures in underground zones.

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

	if (!allowSoftblockUndergroundAdvs() || (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() == 0 && my_daycount() > 1) || !auto_is_valid($item[cold medicine cabinet]))
	{
		// softblock has been released or we have no more Breathitins to collect.
		return false;
	}
	if (get_workshed() != $item[cold medicine cabinet] && auto_is_valid($item[cold medicine cabinet]) && item_amount($item[cold medicine cabinet]) > 0 &&
	!get_property("_workshedItemUsed").to_boolean() && (LX_getDesiredWorkshed() == $item[cold medicine cabinet] || LX_getDesiredWorkshed() == $item[none]))
	{
		// Don't have the CMC installed yet but we can still switch today and want to switch to it so save underground zones until then.
		return true;
	}
	if (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() > 0)
	{
		int turns_until_next_consult = get_property("_nextColdMedicineConsult").to_int() - total_turns_played();
		int[string] envs = getLastCombatEnvironmentCounts(turns_until_next_consult);
		if (turns_until_next_consult < 12 && envs["u"] > 10)
		{
			// have the CMC installed & still have consults to use today.
			// we only need 11 underground adventures in the queue for Breathitin to show up.
			// auto_CMCconsult() will (should) grab a Breathitin as soon as it's available
			// so we only need to care about setting the conditions for it to do so
			return true;
		}
	}
	return false;
}

boolean LX_goingUnderground()
{
	if (auto_haveColdMedCabinet() && auto_CMCconsultsLeft() > 0 && get_property("_nextColdMedicineConsult").to_int() - total_turns_played() < 12)
	{
		if (LX_fatLootToken() || L4_batCave() || L10_basement() || L12_filthworms() || L11_mauriceSpookyraven() || L11_unlockEd() || L7_crypt() || L5_haremOutfit())
		{
			// quests with adventures in underground zones in some sort of priority order here.
			return true;
		}
	}
	return false;
}

boolean auto_reserveOutdoorAdventures()
{
	// this function should return true when we *don't* want to spend adventures in outdoor zones.
	return false;
}