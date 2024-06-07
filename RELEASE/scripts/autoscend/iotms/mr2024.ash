# This is meant for items that have a date of 2024

boolean auto_haveSpringShoes()
{
	if(auto_is_valid($item[spring shoes]) && available_amount($item[spring shoes]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_haveAprilingBandHelmet()
{
	if(auto_is_valid($item[Apriling band helmet]) && available_amount($item[Apriling band helmet]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_getAprilingBandItems()
{
	if(!auto_haveAprilingBandHelmet()) {return false;}
	boolean have_sax  = available_amount($item[Apriling band saxophone]) > 0;
	boolean have_tuba = available_amount($item[Apriling band tuba]     ) > 0;
	int instruments_so_far = get_property("_aprilBandInstruments").to_int();
	if (!have_tuba && instruments_so_far < 2) { cli_execute("aprilband item tuba"); }
	instruments_so_far = get_property("_aprilBandInstruments").to_int();
	if (!have_sax && instruments_so_far < 2) { cli_execute("aprilband item saxophone"); }
	
	have_sax  = available_amount($item[Apriling band saxophone]) > 0;
	have_tuba = available_amount($item[Apriling band tuba]     ) > 0;
	
	return have_sax && have_tuba;
}

boolean auto_playAprilSax()
{
	cli_execute("aprilband play saxophone");
	return have_effect($effect[Lucky!]).to_boolean();
}

boolean auto_playAprilTuba()
{
	cli_execute("aprilband play tuba");
	return get_property("noncombatForcerActive").to_boolean();
}

boolean auto_setAprilBandNonCombat()
{
	if(have_effect($effect[Apriling Band Patrol Beat]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect nc");
	return have_effect($effect[Apriling Band Patrol Beat]).to_boolean();
}

boolean auto_setAprilBandCombat()
{
	if(have_effect($effect[Apriling Band Battle Cadence]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect c");
	return have_effect($effect[Apriling Band Battle Cadence]).to_boolean();
}

boolean auto_setAprilBandDrops()
{
	if(have_effect($effect[Apriling Band Celebration Bop]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect drop");
	return have_effect($effect[Apriling Band Celebration Bop]).to_boolean();
}

int auto_AprilSaxLuckyLeft()
{
	if(!auto_haveAprilingBandHelmet()) {return 0;}
	if(available_amount($item[Apriling band saxophone]) == 0) {return 0;}
	return 3-get_property("_aprilBandSaxophoneUses").to_int();
}

int auto_AprilTubaForcesLeft()
{
	if(!auto_haveAprilingBandHelmet()) {return 0;}
	if(available_amount($item[Apriling band tuba]) == 0) {return 0;}
	return 3-get_property("_aprilBandTubaUses").to_int();
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
