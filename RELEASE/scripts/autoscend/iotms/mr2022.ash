# This is meant for items that have a date of 2022

string bowlingBallCombatString(location place)
{
	// determine if we want more stats
	if((inCombat ? auto_have_skill($skill[Bowl Sideways]) : item_amount($item[Cosmic Bowling Ball]) > 0) && canUse($skill[Bowl Sideways]))
	{
		//increase stats if we are power leveling
		if(isAboutToPowerlevel())
		{
			return useSkill($skill[Bowl Sideways]);
		}
		//increase stats if we are farming Ka as Ed
		if(get_property("auto_farmingKaAsEd").to_boolean())
		{
			return useSkill($skill[Bowl Sideways]);
		}
	}

	// determine if we want more item or meat bonus
	if((inCombat ? auto_have_skill($skill[Bowl Straight Up]) : item_amount($item[Cosmic Bowling Ball]) > 0) && canUse($skill[Bowl Straight Up]))
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