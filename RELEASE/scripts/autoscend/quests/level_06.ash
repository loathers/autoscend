boolean L6_friarsGetParts_condition_hardcore()
{
	return in_hardcore() && isGuildClass();
}

boolean L6_friarsGetParts()
{
	if(internalQuestStatus("questL06Friar") < 0 || internalQuestStatus("questL06Friar") > 2)
	{
		return false;
	}
	if((my_mp() > 50) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}

	if($location[The Dark Heart of the Woods].turns_spent == 0)
	{
		visit_url("friars.php?action=friars&pwd");
		if(isActuallyEd())
		{
			// mafia bug doesn't update the quest property when visiting the Friars as Ed
			// see https://kolmafia.us/showthread.php?24912-minor-questL06Friar-isn-t-changed-to-step1-when-talking-to-the-Friars-as-Ed
			// not that it matters at all, the items we need and locations they're in are the same regardless.
			// but we can force it to update from the quest log
			cli_execute("refresh quests");
		}
	}

	if(equipped_item($slot[Shirt]) == $item[Tunac])
	{
		autoEquip($slot[Shirt], $item[none]);
	}

	if(auto_have_familiar($familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 2))
	{
		handleFamiliar($familiar[Space Jellyfish]);
	}

	if(in_gnoob() && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Frown Muscles]) && (item_amount($item[Bottle of Novelty Hot Sauce]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}
	
	// Don't burn all our NC forces early on d1 unless we are running low on turns.
	if(my_daycount() == 1 && !isAboutToPowerlevel() && !get_property("auto_getSteelOrgan").to_boolean())
	{
		location forced_loc = to_location(get_property("auto_forceNonCombatLocation"));
		boolean forced_here = $locations[The Dark Neck of the Woods, The Dark Elbow of the Woods, The Dark Heart of the Woods] contains forced_loc;
		boolean running_low_on_turns = auto_roughExpectedTurnsLeftToday() < 10 + turnsUsedByRemainingNCForcesToday();
		// Probably need to make sure we still have other stuff to do? Softblock?
		// Could probably then make this run every day.
		int total_daily_forces = baseNCForcesToday();
		if(!forced_here && total_daily_forces > 0 && !running_low_on_turns)
		{
			auto_log_debug("Friars: delaying to save NC forces for later today.", "blue");
			return false;
		}
	}

	if(item_amount($item[dodecagram]) == 0)
	{
		auto_log_info("Getting Dodecagram", "blue");
		boolean NCForced = auto_forceNextNoncombat($location[The Dark Neck of the Woods]);
		// delay to day 2 if we are out of NC forcers and haven't run out of things to do
		if(!NCForced && my_daycount() == 1 && !isAboutToPowerlevel() && !get_property("auto_getSteelOrgan").to_boolean()) return false;
		return autoAdv($location[The Dark Neck of the Woods]);
	}
	if(item_amount($item[eldritch butterknife]) == 0)
	{
		auto_log_info("Getting Eldritch Butterknife", "blue");
		boolean NCForced = auto_forceNextNoncombat($location[The Dark Elbow of the Woods]);
		// delay to day 2 if we are out of NC forcers and haven't run out of things to do
		if(!NCForced && my_daycount() == 1 && !isAboutToPowerlevel() && !get_property("auto_getSteelOrgan").to_boolean()) return false;
		return autoAdv($location[The Dark Elbow of the Woods]);
	}
	if(item_amount($item[box of birthday candles]) == 0)
	{
		if(get_property("auto_dakotaFanning").to_boolean() && internalQuestStatus("questM16Temple") < 0)
		{
			// if we have to do the "Dakota" Fanning quest to unlock the Hidden Temple,
			// delay adventuring in The Dark Heart of the Woods until the quest is started.
			return false;
		}
		auto_log_info("Getting Box of Birthday Candles", "blue");
		boolean NCForced = auto_forceNextNoncombat($location[The Dark Heart of the Woods]);
		// delay to day 2 if we are out of NC forcers and haven't run out of things to do
		if(!NCForced && my_daycount() == 1 && !isAboutToPowerlevel() && !get_property("auto_getSteelOrgan").to_boolean()) return false;
		return autoAdv($location[The Dark Heart of the Woods]);
	}

	auto_log_info("Finishing friars", "blue");
	visit_url("friars.php?action=ritual&pwd");
	council();
	return internalQuestStatus("questL06Friar") > 2;
}

boolean L6_dakotaFanning()
{
	if(!get_property("auto_dakotaFanning").to_boolean() || hidden_temple_unlocked())
	{
		return false;
	}
	if(internalQuestStatus("questM16Temple") < 0)
	{
		if(my_basestat(my_primestat()) < 35)
		{
			return false;
		}
		visit_url("place.php?whichplace=woods&action=woods_dakota_anim");
		return true;
	}

	if(item_amount($item[Pellet Of Plant Food]) == 0)
	{
		autoAdv(1, $location[The Haunted Conservatory]);
		return true;
	}

	if(item_amount($item[Heavy-Duty Bendy Straw]) == 0)
	{
		if(get_property("questL06Friar") != "finished")
		{
			autoAdv(1, $location[The Dark Heart of the Woods]);
		}
		else
		{
			autoAdv(1, $location[Pandamonium Slums]);
		}
		return true;
	}

	if(item_amount($item[Sewing Kit]) == 0)
	{
		if(item_amount($item[Fat Loot Token]) > 0)
		{
			cli_execute("make " + $item[Sewing Kit]);
		}
		else
		{
			return fantasyRealmToken();
		}
		return true;
	}

	visit_url("place.php?whichplace=woods&action=woods_dakota");
	if(get_property("questM16Temple") != "finished")
	{
		abort("Could not finish Dakota Fanning quest, aborting.");
	}
	return true;
}
