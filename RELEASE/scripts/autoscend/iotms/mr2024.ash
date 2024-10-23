# This is meant for items that have a date of 2024

import <c2t_apron.ash>// used in consumeBlackAndWhiteApronKit()

boolean consumeBlackAndWhiteApronKit()
{
	item apronKit = $item[Black and White Apron Meal Kit];
	if(fullness_left() < 3)
	{
		return false;
	}
	if(item_amount(apronKit) < 1)
	{
		return false;
	}

	if(!git_exists("C2Talon-c2t_apron-master"))
	{
		abort("script c2t_apron didn't install properly. Fix and run autoscend again.");
	}
	
	// default ingredient allow list. Allow all but:
	// Potentially quest relevant: Blackberry, Bubblin' crude, enchanted bean
	// Extra cold damage: grapefruit
	// 20ml: dill
	string allowList = "3489,1356,1560,2525,3490,748,1562,1557,1561,3491,\
	1122,1559,2094,183,182,2338,237,787,1004,238,328,1005,2583,1006,589,672,2524,304,6724,\
	1462,161,158,358,2589,55,302,332,170,2532,187,357,245,242,4956,830,165,1003,8,786,1558,\
	246,4,159,209";

	// allow quest items if no longer needed
	if(possessEquipment($item[Blackberry Galoshes]) || item_amount($item[Blackberry]) > 3)
	{
		allowList += ",2063";
	}
	int oilProgress = get_property("twinPeakProgress").to_int();
	if(((oilProgress & 4) == 1) || item_amount($item[Jar Of Oil]) > 0 || item_amount($item[Bubblin\' Crude]) > 12)
	{
		allowList += ",5789";
	}
	if(item_amount($item[Enchanted Bean]) > 1 || internalQuestStatus("questL10Garbage") >= 1)
	{
		allowList += ",186";
	}
	set_property("c2t_apron_allowlist",allowList);
	
	// consume the apron kit using c2t's script
	// this will default to consuming food for our current mainstat
	// https://github.com/C2Talon/c2t_apron
	return c2t_apron();
}

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

boolean dartEleDmg()
{
	string perks = get_property("everfullDartPerks").to_string().to_lower_case();
	if(contains_text(perks, "add ")) // Only ele dmg perks have "add " in their perk description so as long as we have 1, we are good
	{
		return true;
	}	
	return false;
}

boolean auto_haveMayamCalendar()
{
	if(auto_is_valid($item[Mayam Calendar]) && available_amount($item[Mayam Calendar]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_MayamIsUsed(string glyph)
{
	string[int] used = split_string(get_property("_mayamSymbolsUsed"),",");
	foreach idx,str in used
	{
		if (glyph==str)
		{
			return true;
		}
	}
	return false;
}

boolean auto_MayamAllUsed()
{
	// mayam is currently fully used if all 3 ring1 symbols have been used
	return auto_MayamIsUsed("yam4") && auto_MayamIsUsed("clock") && auto_MayamIsUsed("explosion");
}

boolean auto_MayamClaimStinkBomb()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	if(auto_MayamIsUsed("vessel") ||
	   auto_MayamIsUsed("yam2")   ||
	   auto_MayamIsUsed("cheese") ||
	   auto_MayamIsUsed("explosion") )
	{
		return false;
	}
	cli_execute("mayam rings vessel yam cheese explosion");
	return true;
}

boolean auto_MayamClaimBelt()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	if(auto_MayamIsUsed("yam1") ||
	   auto_MayamIsUsed("meat")   ||
	   auto_MayamIsUsed("eyepatch") ||
	   auto_MayamIsUsed("yam4") )
	{
		return false;
	}
	cli_execute("mayam rings yam meat eyepatch yam");
	return true;
}

boolean auto_MayamClaimWhatever()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	string ring1 = "BAD_VALUE";
	string ring2 = "BAD_VALUE";
	string ring3 = "BAD_VALUE";
	string ring4 = "BAD_VALUE";
	boolean failure = false;
	
	if      (!auto_MayamIsUsed("chair") && auto_haveCincho())   { ring1 = "chair"; }
	// todo: add support for giving appropriate fam 100xp with fur option
	else if (!auto_MayamIsUsed("eye"))    { ring1 = "eye"; }
	else if (!auto_MayamIsUsed("vessel")) { ring1 = "vessel"; }
	else { failure = true; }
	
	if      (!auto_MayamIsUsed("wood") && (lumberCount() < 30 || fastenerCount() < 30))   { ring2 = "wood"; }
	else if (!auto_MayamIsUsed("lightning"))   { ring2 = "lightning"; }
	else if (!auto_MayamIsUsed("meat"))   { ring2 = "meat"; }
	else { failure = true; }
	
	if      (!auto_MayamIsUsed("yam3"))   { ring3 = "yam"; }
	else if (!auto_MayamIsUsed("cheese")) { ring3 = "cheese"; }
	else if (!auto_MayamIsUsed("wall"))   { ring3 = "wall"; }
	else { failure = true; }
	
	if      (!auto_MayamIsUsed("yam4"))      { ring4 = "yam"; }
	else if (!auto_MayamIsUsed("clock"))     { ring4 = "clock"; }
	else if (!auto_MayamIsUsed("explosion")) { ring4 = "explosion"; }
	else { failure = true; }
	if (failure)
	{
		return false;
	}
	
	cli_execute("mayam rings "+ring1+" "+ring2+" "+ring3+" "+ring4);
	return true;
}

boolean auto_MayamClaimAll()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	if(auto_MayamAllUsed())
	{
		return false;
	}
	auto_log_info("Claiming mayam calendar items");
	auto_MayamClaimStinkBomb();
	auto_MayamClaimBelt();
	auto_MayamClaimWhatever();
	auto_MayamClaimWhatever();
	auto_MayamClaimWhatever();
	return true;
}

boolean auto_haveRoman()
{
	if(auto_is_valid($item[Roman Candelabra]) && possessEquipment($item[Roman Candelabra]))
	{
		return true;
	}
	return false;
}

boolean auto_haveBatWings()
{
	if(auto_is_valid($item[Bat Wings]) && possessEquipment($item[Bat Wings]))
	{
		return true;
	}
	return false;
}

boolean auto_canLeapBridge()
{
	// bat wings allow for us to leap bridge at 5/6 progress (25 of 30)
	if(!auto_haveBatWings())
	{
		return false;
	}
	if(fastenerCount() < 25 || lumberCount() < 25)
	{
		return false;
	}
	return true;
}

boolean auto_haveSeptEmberCenser()
{
	if(auto_is_valid($item[Sept-Ember Censer]) && available_amount($item[Sept-Ember Censer]) > 0 )
	{
		return true;
	}
	return false;
}

int remainingEmbers()
{
	if(!auto_haveSeptEmberCenser())
	{
		return 0;
	}
	if(!get_property("_septEmberBalanceChecked").to_boolean())
	{
		// go to ember shop to check our balance
		use($item[Sept-Ember Censer]);
	}
	return get_property("availableSeptEmbers").to_int();
}

void auto_buyFromSeptEmberStore()
{
	if(remainingEmbers() == 0)
	{
		return;
	}
	auto_log_debug("Have " + remainingEmbers() + " embers(s) to buy from Sept-Ember Censer. Let's spend them!");
	// get structural ember if can't cross bridge
	item itemConsidering = $item[Structural ember];
	if(remainingEmbers() >= 4 && get_property("chasmBridgeProgress").to_int() < bridgeGoal() && 
		!get_property("_structuralEmberUsed").to_boolean() && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Sept-Ember Censer], 1, itemConsidering);
		use(itemConsidering);
	}
	// get 1 bembershoot to support mouthwash leveling or general quest help
	itemConsidering = $item[bembershoot];
	if(remainingEmbers() >= 1 && !possessEquipment(itemConsidering) && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Sept-Ember Censer], 1, itemConsidering);
	}
	// mouthwash for leveling
	itemConsidering = $item[Mmm-brr! brand mouthwash];
	if(remainingEmbers() >= 2 && (my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean()) && auto_is_valid(itemConsidering))
	{
		// get as much cold res as possible
		int [element] resGoal;
		resGoal[$element[cold]] = 100;
		// get cold res. Use noob cave as generic place holder
		auto_wishForEffect($effect[Fever From the Flavor]);
		provideResistances(resGoal, $location[noob cave], true);
		equipMaximizedGear();
		// buy mouthwash and use it
		buy($coinmaster[Sept-Ember Censer], 1, itemConsidering);
		auto_log_debug(`Using mouthwash with {numeric_modifier("cold Resistance")} cold resistance`);
		use(itemConsidering);
	}
	// if still have embers, get hat for mp regen
	itemConsidering = $item[Hat of remembering];
	if(remainingEmbers() >= 1 && !possessEquipment(itemConsidering) && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Sept-Ember Censer], 1, itemConsidering);
	}
	// consider throwin' ember for banish or summoning charm for pickpocket in future PR
}
