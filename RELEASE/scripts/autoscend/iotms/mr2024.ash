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
		auto_log_info("choice " + idx + " is " + str, "blue");
	}
	foreach perk in $strings[impress,better,targeting,butt] //Ranked as 1. Shorter ELR CD, 2. bullseye chance, 3. Butt Awareness, 4. Everything else
	{
		foreach idx, str in options
		{
			if(contains_text(str.to_lower_case(),perk))
			{
				dcchoice = idx;
				break;
			}
		}
		if(dcchoice != 0) break;
	}
	if(dcchoice == 0) dcchoice = 1; //if choice is not set, just choose the 1st option
	run_choice(dcchoice);
}

int dartBullseyeChance()
{
	string[int] perks;
	int chance = 25; // base bullseye chance is 25%
	perks = split_string(get_property("everfullDartPerks").to_string().to_lower_case(), ",");
	foreach perk in perks
	{
		if (contains_text(perks[perk], "better") || contains_text(perks[perk], "targeting"))
		{
			chance += 25;
		}	
	}
	return chance;
}

int dartELRcd()
{
	string[int] perks;
	int cd = 50; // base cd is 50 turns
	perks = split_string(get_property("everfullDartPerks").to_string().to_lower_case(), ",");
	foreach perk in perks
	{
		if (contains_text(perks[perk], "impress"))
		{
			cd -= 10;
		}	
	}
	return cd;
}

skill dartSkill()
{
	string[int] curDartboard;
	curDartboard = split_string(get_property("_currentDartboard").to_string().to_lower_case(), ",");
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