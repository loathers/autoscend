script "auto_adventure.ash"

# num is not handled properly anyway, so we'll just reject it.
boolean autoAdv(location loc, string option)
{
	return autoAdv(1, loc, option);
}

# num is not handled properly anyway, so we'll just reject it.
boolean autoAdv(int num, location loc, string option)
{
	if(!zone_isAvailable(loc, true)){
		auto_log_warning("Cant get to " + loc + " right now.", "red");
		return false;
	}

	remove_property("auto_combatHandler");
	set_property("auto_diag_round", 0);
	set_property("nextAdventure", loc);
	if(option == "")
	{
		if (isActuallyEd())
		{
			option = "auto_edCombatHandler";
			remove_property("auto_edCombatHandler");
		} else {
			option = "auto_combatHandler";
		}
	}

	if(auto_my_path() == "Pocket Familiars")
	{
		return digimon_autoAdv(num, loc, option);
	}

	return adv1(loc, -1, option);
}

boolean autoAdv(int num, location loc)
{
	return autoAdv(num, loc, "");
}

boolean autoAdv(location loc)
{
	return autoAdv(1, loc, "");
}

boolean autoAdvBypass(string url, location loc)
{
	return autoAdvBypass(url, loc, "");
}

boolean autoAdvBypass(string url, location loc, string option)
{
	string[int] urlConvert;
	urlConvert[0] = url;
	return autoAdvBypass(0, urlConvert, loc, option);
}

boolean autoAdvBypass(int urlGetFlags, string[int] url, location loc, string option)
{
	if(!zone_isAvailable(loc, true))
	{
		// reinstate this check for now. Didn't fix the War boss fight outside of Ed & KoE,
		// will work around that by passing Noob Cave as location until this is refactored.
		auto_log_warning("Cant get to " + loc + " right now.", "red");	
		return false;	
	}
	
	set_property("nextAdventure", loc);
	cli_execute("auto_pre_adv");
	remove_property("auto_combatHandler");
	set_property("auto_diag_round", 0);

	if(option == "")
	{
		if (isActuallyEd())
		{
			option = "auto_edCombatHandler";
			remove_property("auto_edCombatHandler");
		} else {
			option = "auto_combatHandler";
		}
	}

	if (isActuallyEd())
	{
		ed_handleAdventureServant(loc);
	}

	auto_log_info("About to start a combat indirectly at " + loc + "... (" + count(url) + ") accesses required.", "blue");
	string page;
	foreach idx, it in url
	{
		if((urlGetFlags & 1) == 1)
		{
			page = visit_url(it, false);
		}
		else
		{
			page = visit_url(it);
		}
		urlGetFlags /= 2;
	}

	// handle the initial combat or choice the easy way.
	string combatPage = "<b>Combat";
	if (auto_my_path() == "Pocket Familiars") {
		combatPage = "<b>Fight!";
	}
	if (contains_text(page, combatPage)) {
		auto_log_info("autoAdvBypass has encountered a combat! (param: '" + option + "')", "green");
		run_combat(option);
	} else {
		auto_log_info("autoAdvBypass has encountered a choice!", "green");
		run_choice(-1);
	}

	if (get_property("lastEncounter") == "Using the Force") {
		// because of course this fucking thing needs special handling.
		// Why can this just not be handled like every other post-combat choice in mafia?
		// It's not that fucking special. If we can handle the doc bag, Ed's resurrection and a bunch of other stuff, WHY IS THIS SO HARD?
		// https://kolmafia.us/showthread.php?25235-Using-the-Force-doesn-t-set-choice_follows_fight()-(in-certain-conditions-)
		run_choice(-1);
	}

	// this should handle stuff like Ed's resurrect/fight loop
	// and anything else that chains combats & choices in any order
	while (fight_follows_choice() || choice_follows_fight() || in_multi_fight()) {
		if (fight_follows_choice() || in_multi_fight()) {
			auto_log_info("autoAdvBypass has encountered a combat! (param: '" + option + "')", "green");
			run_combat(option);
		}
		if (choice_follows_fight()) {
			auto_log_info("autoAdvBypass has encountered a choice!", "green");
			run_choice(-1);
		}
	}

	cli_execute("auto_post_adv");

	// Encounters that need to generate a false so we handle them manually should go here.
	if(get_property("lastEncounter") == "Travel to a Recent Fight")
	{
		return false;
	}
	if(get_property("lastEncounter") == "Rationing out Destruction")
	{
		return false;
	}
	return true;
}

boolean autoAdvBypass(int snarfblat, location loc)
{
	string page = "adventure.php?snarfblat=" + snarfblat;
	return autoAdvBypass(page, loc);
}
boolean autoAdvBypass(int snarfblat, location loc, string option)
{
	string page = "adventure.php?snarfblat=" + snarfblat;
	return autoAdvBypass(page, loc, option);
}

boolean autoAdvBypass(int snarfblat)
{
	return autoAdvBypass(snarfblat, $location[Noob Cave]);
}
boolean autoAdvBypass(string url)
{
	return autoAdvBypass(url, $location[Noob Cave]);
}
#boolean autoAdvBypass(string[int] url)
#{
#	return autoAdvBypass(url, $location[Noob Cave]);
#}
boolean autoAdvBypass(int snarfblat, string option)
{
	return autoAdvBypass(snarfblat, $location[Noob Cave], option);
}
boolean autoAdvBypass(string url, string option)
{
	return autoAdvBypass(url, $location[Noob Cave], option);
}
#boolean autoAdvBypass(string[int] url, string option)
#{
#	return autoAdvBypass(url, $location[Noob Cave], option);
#}


void preAdvUpdateFamiliar(location place)
{
	if(get_property("auto_disableFamiliarChanging").to_boolean())
	{
		return;
	}
	if(!pathAllowsFamiliar())
	{
		return;		//will just error in those paths
	}
	if(is100FamRun())
	{
		handleFamiliar(get_property("auto_100familiar").to_familiar());			//do not break 100 familiar runs
	}
	
	//familiar requirement to adventure in a zone, override everything else.
	if(place == $location[The Deep Machine Tunnels])
	{
		handleFamiliar($familiar[Machine Elf]);
	}
	// Can't take familiars with you to FantasyRealm
	if (place == $location[The Bandit Crossroads])
	{
		if(my_familiar() == $familiar[none]) return;		//avoid mafia error from trying to change none into none.
		use_familiar($familiar[none]);
		return;		//no familiar means no equipment, we are done.
	}
	
	//if familiar not set yet, first check stealing familiar
	if(!get_property("_auto_thisLoopHandleFamiliar").to_boolean() && canChangeToFamiliar($familiar[cat burglar]) && catBurglarHeistsLeft() > 0)
	{
		//Stealing with familiar. TODO add XO Skelton here too
		
		item[monster] heistDesires = catBurglarHeistDesires();
		boolean wannaHeist = false;
		foreach mon, it in heistDesires
		{
			foreach i, mmon in get_monsters(place)
			{
				if(mmon == mon)
				{
					auto_log_debug("Using cat burglar because we want to burgle a " + it + " from " + mon);
					wannaHeist = true;
				}
			}
		}
		if(wannaHeist)
		{
			handleFamiliar($familiar[cat burglar]);
		}
	}
	
	//if familiar not set choose a familiar using general logic
	if(!get_property("_auto_thisLoopHandleFamiliar").to_boolean())		//check that we didn't already set familiar target this loop
	{
		autoChooseFamiliar(place);
	}
	
	familiar famChoice = to_familiar(get_property("auto_familiarChoice"));
	if(famChoice == $familiar[none])
	{
		if(get_property("auto_familiarChoice") == "")
		{
			abort("void preAdvUpdateFamiliar failed because property auto_familiarChoice is empty for some reason");
		}
		abort("void preAdvUpdateFamiliar failed to convert auto_familiarChoice of [" + get_property("auto_familiarChoice") + "] into a $familiar");
	}
	
	if(famChoice != my_familiar() && canChangeToFamiliar(famChoice))
	{
		use_familiar(famChoice);
	}
	
	//familiar equipment overrides
	if(my_path() == "Heavy Rains")
	{
		autoEquip($slot[familiar], $item[miniature life preserver]);
	}

	if(my_familiar() == $familiar[Trick-Or-Treating Tot])
	{
		if($locations[A-Boo Peak, The Haunted Kitchen] contains place)
		{
			if(equipped_item($slot[Familiar]) != $item[Li\'l Candy Corn Costume])
			{
				if(item_amount($item[Li\'l Candy Corn Costume]) > 0)
				{
					equip($slot[Familiar], $item[Li\'l Candy Corn Costume]);
				}
			}
		}
	}
}


boolean preAdvXiblaxian(location loc)
{
	if((equipped_item($slot[acc3]) == $item[Xiblaxian Holo-Wrist-Puter]) && (howLongBeforeHoloWristDrop() <= 1))
	{
		string area = loc.environment;
		# This is an attempt to farm Xiblaxian food/booze stuff.
		item toMake = to_item(get_property("auto_xiblaxianChoice"));
		if(toMake == $item[none])
		{
			toMake = $item[Xiblaxian Ultraburrito];
		}

		# If we migrate all Ed workaround combats to the bypasser, we don't need to check main.php
		if(my_class() == $class[Ed])
		{
			if(contains_text(visit_url("main.php"), "Combat"))
			{
				auto_log_warning("As Ed, I was not bypassed into this combat correctly (but it'll be ok)", "red");
				return false;
			}
		}

		# For overriden adventures, we should use a place with a similar location profile.
		# However, that means we\'d lose the Noob Cave canaray
		if(loc == $location[Noob Cave])
		{
			#replaceBaselineAcc3();
			return true;
		}

		if(toMake == $item[Xiblaxian Ultraburrito])
		{
			if((area == "indoor") && (item_amount($item[Xiblaxian Circuitry]) > 0))
			{
				#replaceBaselineAcc3();
			}
			else if((area == "outdoor") && (item_amount($item[Xiblaxian Polymer]) > 0))
			{
				#replaceBaselineAcc3();
			}
			else if((area == "underground") && (item_amount($item[Xiblaxian Alloy]) > 2))
			{
				#replaceBaselineAcc3();
			}
			else
			{
				auto_log_info("We should be getting a Xiblaxian wotsit this combat. Beep boop.", "green");
			}
		}
		else if(toMake == $item[Xiblaxian Space-Whiskey])
		{
			if((area == "indoor") && (item_amount($item[Xiblaxian Circuitry]) > 2))
			{
				#replaceBaselineAcc3();
			}
			else if((area == "outdoor") && (item_amount($item[Xiblaxian Polymer]) > 0))
			{
				#replaceBaselineAcc3();
			}
			else if((area == "underground") && (item_amount($item[Xiblaxian Alloy]) > 0))
			{
				#replaceBaselineAcc3();
			}
			else
			{
				auto_log_info("We should be getting a Xiblaxian wotsit this combat. Beep boop.", "green");
			}
		}
	}
	return true;
}
