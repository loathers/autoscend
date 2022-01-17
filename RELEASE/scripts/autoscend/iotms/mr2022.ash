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
		return useItem($item[Cosmic Bowling Ball]);
	}

	// determine if we want more stats
	if(canUse($skill[Bowl Sideways], false))
	{
		//increase stats if we are power leveling
		if(isAboutToPowerlevel())
		{
			return useSkill($skill[Bowl Sideways]);
		}
		//increase stats if we are farming Ka as Ed
		if(get_property("_auto_farmingKaAsEd").to_boolean())
		{
			return useSkill($skill[Bowl Sideways]);
		}
	}

	// determine if we want more item or meat bonus
	if(canUse($skill[Bowl Straight Up], false))
	{
		//increase item bonus if not item capped in current zone
		generic_t itemNeed = zone_needItem(place);
		if(itemNeed._boolean)
		{
			if(item_drop_modifier() < itemNeed._float)
			{
				return useSkill($skill[Bowl Straight Up]);
			}
		}

		//increase meat bonus if doing nuns
		if(place == $location[The Themthar Hills])
		{
			return useSkill($skill[Bowl Straight Up]);
		}	
	}

	return "";
}
