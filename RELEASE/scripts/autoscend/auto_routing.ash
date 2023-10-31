
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
	if (zone_isAvailable($location[The Arid\, Extra-Dry Desert]) && $location[The Arid\, Extra-Dry Desert].turns_spent >= 1 && $location[The Arid\, Extra-Dry Desert].turns_spent < 10)
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
	else if (my_daycount() < 2 && (auto_haveVotingBooth() || auto_haveKramcoSausageOMatic() || auto_haveBackupCamera()))
	{
		return true;
	}
	return false;
}
