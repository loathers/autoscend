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
		}
		else if(contains_text(str,"impress") && dcchoice == 0) //Shorter CD on ELR after Bullseye
		{
			dcchoice = idx;
		}
		else if(contains_text(str,"Butt") && dcchoice == 0) //Get all that junk in the trunk (butt)
		{
			dcchoice = idx;
		}
		else
		{
			dcchoice = 1;
		}
	}
	run_choice(dcchoice);
}

int dartBullseyeChance()
{
	string[int] perks;
	int chance = 25;
	perks = split_string(get_property("everfullDartPerks").to_string(), ",");
	foreach perk in perks
	{
		if (contains_text(perk, "25%"))
		{
			chance += 25;
		}
	}
	return chance;
}

skill dartSkill()
{
	//from c2t
	/*skill[string] c2t_parts(string page) {
		skill[string] out;
		matcher m = create_matcher('<option\\s+value="(\\d+)"\\s+picurl="nicedart"\\s*>Darts:\\s+Throw\\s+at\\s+([^\\(]+)\\s+\\(',page);
		while (m.find())
			out[m.group(2)] = m.group(1).to_skill();
		return out;
	}*/
	/*skill[string] out;
	string page = visit_url('fight.php');
	matcher m = create_matcher('<option\\s+value="(\\d+)"\\s+picurl="nicedart"\\s*>Darts:\\s+Throw\\s+at\\s+([^\\(]+)\\s+\\(',page);
	while (m.find())
		out[m.group(2)] = m.group(1).to_skill();

	foreach skst, sk in out
	{
		if(contains_text(skst, "Bullseye")) //Free-kill that wasn't taken care of in stage2
		{
			return sk;
		}
		else if(contains_text(skst, "butt")) //More items
		{
			return sk;
		}
		else if(contains_text(skst, "torso") || contains_text(skst, "pseudopod")) //More meat
		{
			return sk;
		}
		else return to_skill(7513); // Darts: throw at %part1;
	}
	return $skill[none]; // If there aren't any darts available return the none skill*/
	string[int] curDartboard;
	curDartboard = split_string(get_property("_currentDartboard").to_string(), ",");
	foreach sk in curDartboard
	{
		//auto_log_info("Searching for parts in " + curDartboard[sk], "blue");
		//set_property("auto_interrupt", true);
		if(contains_text(curDartboard[sk], "butt"))
		{
			//set_property("auto_interrupt", true);
			auto_log_info("Going for the butt", "blue");
			return to_skill(substring(curDartboard[sk],0,4).to_int());
		}
		else if(contains_text(curDartboard[sk], "torso") || contains_text(sk, "pseudopod"))
		{
			//set_property("auto_interrupt", true);
			auto_log_info("Going for the chest", "blue");
			return to_skill(substring(curDartboard[sk],0,4).to_int());
		}
	}
	return to_skill(7513); // If there aren't any darts available return the Darts: Throw at %PART1
}