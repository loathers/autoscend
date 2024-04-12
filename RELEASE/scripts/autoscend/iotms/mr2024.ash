# This is meant for items that have a date of 2024

boolean auto_haveSpringShoes()
{
	if(auto_is_valid($item[spring shoes]) && available_amount($item[spring shoes]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_haveDarts()
{
	if(auto_is_valid($item[Everfull Dart Holster]) && possessEquipment($item[Everfull Dart Holster]))
	{
		return true;
	}
	return false;
}

void dartChoiceHandler(int choice, string[int] options)
{
	auto_log_info("dartChoiceHandler Running choice " + choice, "blue");
	
	int dcchoice = 0;
	foreach idx, str in options
	{
		if(contains_text(str,"25%") && dcchoice == 0) //Higher chance of getting a Bullseye
		{
			dcchoice = idx;
			break;
		}
		else if(contains_text(str,"impress") && dcchoice == 0) //Shorter CD on ELR after Bullseye
		{
			dcchoice = idx;
			break;
		}
		else if(contains_text(str,"Butt") && dcchoice == 0) //Get all that junk in the trunk (butt)
		{
			dcchoice = idx;
			break;
		}
		else
		{
			dcchoice = 1;
			break;
		}
	}
	run_choice(dcchoice);
}

int dartBullseyeChance()
{
	string[int] perks;
	int chance = 25; // base bullseye chance is 25%
	perks = split_string(get_property("everfullDartPerks").to_string(), ",");
	foreach perk in perks
	{
		if (contains_text(perks[perk], "25%"))
		{
			chance += 25;
		}	
	}
	return chance;
}

skill dartSkill()
{
	string[int] curDartboard;
	curDartboard = split_string(get_property("_currentDartboard").to_string(), ",");
	foreach sk in curDartboard
	{
		if(contains_text(curDartboard[sk], "butt")) // get more items
		{
			auto_log_info("Going for the butt", "blue");
			return to_skill(substring(curDartboard[sk],0,4).to_int());
		}
		else if(contains_text(curDartboard[sk], "torso") || contains_text(sk, "pseudopod")) //get more meat
		{
			auto_log_info("Going for the chest", "blue");
			return to_skill(substring(curDartboard[sk],0,4).to_int());
		}
	}
	return to_skill(7513); // If there aren't any darts available return the Darts: Throw at %PART1
}