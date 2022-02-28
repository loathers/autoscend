# This is meant for items that have a date of 2022

boolean auto_haveCosmicBowlingBall()
{
	// returns true if CBB is available for use, not necessarily if the user has the CBB
	return item_amount($item[Cosmic Bowling Ball]) > 0;
}

string auto_bowlingBallCombatString(location place, boolean speculation)
{
	if(!auto_haveCosmicBowlingBall())
	{
		return "";
	}

	if(auto_is_valid($item[Cosmic Bowling Ball]) && place == $location[The Hidden Bowling Alley] && get_property("auto_bowledAtAlley").to_int() != my_ascensions())
	{
		if(!speculation)
		{
			set_property("auto_bowledAtAlley", my_ascensions());
			auto_log_info("Cosmic Bowling Ball used at Hidden Bowling Alley to adavnce quest.");
		}	
		return useItem($item[Cosmic Bowling Ball],!speculation);
	}

	// determine if we want more stats
	if(canUse($skill[Bowl Sideways]))
	{
		// increase stats if we are power leveling
		if(isAboutToPowerlevel())
		{
			return useSkill($skill[Bowl Sideways],!speculation);
		}
		// increase stats if we are farming Ka as Ed
		if(get_property("_auto_farmingKaAsEd").to_boolean())
		{
			return useSkill($skill[Bowl Sideways],!speculation);
		}
	}

	// determine if we want more item or meat bonus
	if(canUse($skill[Bowl Straight Up]))
	{
		// increase item bonus if not item capped in current zone
		generic_t itemNeed = zone_needItem(place);
		if(itemNeed._boolean)
		{
			if(item_drop_modifier() < itemNeed._float)
			{
				return useSkill($skill[Bowl Straight Up],!speculation);
			}
		}

		// increase meat bonus if doing nuns
		if(place == $location[The Themthar Hills])
		{
			return useSkill($skill[Bowl Straight Up],!speculation);
		}	
	}

	return "";
}

boolean auto_haveCombatLoversLocket()
{
	return possessEquipment($item[combat lover\'s locket]) && auto_is_valid($item[combat lover\'s locket]);
}

int auto_CombatLoversLocketCharges()
{
	// can fight up to 3 unique monsters by reminiscing with the locket
	if (!auto_haveCombatLoversLocket())
	{
		return 0;
	}

	string locketMonstersFought = get_property("_locketMonstersFought");

	// check if we haven't found any yet
	if(locketMonstersFought == "")
	{
		return 3;
	}

	return 3 - count(split_string(locketMonstersFought, ","));
}

boolean auto_haveReminiscedMonster(monster mon)
{
	string[int] idList = split_string(get_property("_locketMonstersFought"),",");
	foreach index, id in idList
	{
		if(to_monster(id) == mon)
		{
			return true;
		}
	}
	return false;
}

boolean auto_monsterInLocket(monster mon)
{
	boolean[monster] captured = get_locket_monsters();
	return captured contains mon;
}

boolean auto_fightLocketMonster(monster mon)
{
	if(auto_CombatLoversLocketCharges() < 1)
	{
		return false;
	}

	if(!auto_monsterInLocket(mon))
	{
		return false;
	}

	if(auto_haveReminiscedMonster(mon))
	{
		return false;
	}

	string[int] pages;
	pages[0] = "inventory.php?reminisce=1";
	pages[1] = "choice.php?whichchoice=1463&pwd&option=1&mid=" + mon.id;
	if(autoAdvBypass(1, pages, $location[Noob Cave], ""))
	{
		handleTracker(mon, $item[combat lover\'s locket], "auto_copies");
	}

	if(!auto_haveReminiscedMonster(mon))
	{
		auto_log_error("Attempted to fight " + mon.name + " by reminiscing with Combat Lover's Locket, but failed.");
		return false;
	}

	return true;

}
