script "auto_adventure.ash"

// just a wrapper around https://svn.code.sf.net/p/therazekolmafia/canadv/code/ for now, but gives a single point of change if we need to change how we determine this
boolean autoCanAdv(location loc){

	static boolean[item] craftable_shirts = $items[barskin cloak, bat-ass leather jacket, clownskin harness, demonskin jacket, gnauga hide vest, hipposkin poncho, lynyrdskin tunic, tuxedo shirt, white snakeskin duster, yak anorak];

	boolean acquire_a_shirt(){
		if(isjanuaryToteAvailable() && januaryToteAcquire($item[Makeshift Garbage Shirt])){
			return true;
		}
		if(auto_have_skill($skill[Torso Awaregness]) && auto_have_skill($skill[Armorcraftiness])){
			foreach shirt in craftable_shirts{
				if(creatable_amount(shirt) > 0 && create(1, shirt)){
					return true;
				}
			}
		}
		return false;
	}

	if(!can_adv(loc)){
		if(loc == $location[The Thinknerd Warehouse] && !acquire_a_shirt()){
			print("Wasnt able to acquire a shirt to open " + loc, "red");
		}
		return can_adv(loc);
	} else{
		return true;
	}
}

# num is not handled properly anyway, so we'll just reject it.
boolean autoAdv(location loc, string option)
{
	return autoAdv(1, loc, option);
}

# num is not handled properly anyway, so we'll just reject it.
boolean autoAdv(int num, location loc, string option)
{
	if(!autoCanAdv(loc)){
		print("Cant get to " + loc + " right now.", "red");
		return false;
	}

	set_property("auto_combatHandler", "");
	set_property("auto_diag_round", 0);
	set_property("nextAdventure", loc);
	if(option == "")
	{
		option = "auto_combatHandler";
	}
	if(auto_my_path() == "Actually Ed the Undying")
	{
		return ed_autoAdv(num, loc, option);
	}
	if(auto_my_path() == "Pocket Familiars")
	{
		return digimon_autoAdv(num, loc, option);
	}


	boolean retval = false;

	if((my_adventures() == 0) || ((inebriety_left() < 0) && (equipped_item($slot[off-hand]) != $item[Drunkula\'s Wineglass])))
	{
		string page = visit_url("fight.php");
		if(contains_text(page, "Combat"))
		{
			run_combat(option);
			retval = true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		retval = adv1(loc, 0, option);
	}
	if(auto_my_path() == "One Crazy Random Summer")
	{
		if(last_monster().random_modifiers["clingy"])
		{
			int oldDesert = get_property("desertExploration").to_int();
			retval = autoAdv(num, loc, option);
			if(my_location() == $location[The Arid\, Extra-Dry Desert])
			{
				set_property("desertExploration", oldDesert);
			}
		}
	}
	if(get_property("lastEncounter") == "Using the Force")
	{
		run_choice(get_property("_auto_saberChoice").to_int());
	}
	return retval;
}

boolean autoAdv(int num, location loc)
{
	return autoAdv(num, loc, "");
}

boolean autoAdv()
{
	if(my_location() == $location[none])
	{
		return autoAdv(1, $location[Noob Cave], "");
	}
	return autoAdv(1, my_location(), "");
}

boolean autoAdv(location loc)
{
	return autoAdv(1, loc, "");
}

boolean autoAdvBypass(string url, location loc)
{
	return autoAdvBypass(url, loc, "");
}

#boolean autoAdvBypass(string[int] url, location loc)
#{
#	return autoAdvBypass(url, loc, "");
#}

boolean autoAdvBypass(string url, location loc, string option)
{
	string[int] urlConvert;
	urlConvert[0] = url;
	return autoAdvBypass(0, urlConvert, loc, option);
}

# Preserved to remind us of this issue.
#boolean autoAdvBypass(int becauseStringIntIsSomehowJustString, string[int] url, location loc, string option)
#
#	urlGetFlags allows us to force visit_url(X, false). It is a bit field.
#
boolean autoAdvBypass(int urlGetFlags, string[int] url, location loc, string option)
{
	if(!autoCanAdv(loc)){
		print("Cant get to " + loc + " right now.", "red");
		return false;
	}

	set_property("nextAdventure", loc);
	cli_execute("auto_pre_adv");
  #	handlePreAdventure(loc);
	if(option == "")
	{
		option = "auto_combatHandler";
	}
	if(my_class() == $class[Ed])
	{
		ed_preAdv(1, loc, option);
	}

	auto_log_info("About to start a combat indirectly at " + loc + "... (" + count(url) + ") accesses required.", "blue");
	string page;
	foreach idx, it in url
	{
		if((urlGetFlags & 1) == 1)
		{
			#auto_log_warning("Visit_url(" + it + ") override to false", "red");
			//When using this, you may have to add my_hash yourself.
			//We can probably do this (but is it possible that a search for "pwd" can cause false positives?)
			page = visit_url(it, false);
		}
		else
		{
			page = visit_url(it);
		}
		urlGetFlags /= 2;
	}
	if((my_hp() == 0) || (get_property("_edDefeats").to_int() == 1) || (have_effect($effect[Beaten Up]) > 0))
	{
		auto_log_warning("Uh oh! Died when starting a combat indirectly.", "red");
		if(my_class() == $class[Ed])
		{
			return ed_autoAdv(1, loc, option, true);
		}
		#Can we just return true here?
		abort("autoAdvBypass override abort");
	}

	string combatPage = "<b>Combat";
	if(auto_my_path() == "Pocket Familiars")
	{
		combatPage = "<b>Fight!";
	}
	if(contains_text(page, combatPage))
	{
		auto_log_info("autoAdvBypass has encountered a combat! (param: '" + option + "')", "green");

		if(option != "autoscend_null") // && (option != ""))
		{
			if(get_auto_attack() == 0)
			{
				if((inebriety_left() >= 0) || (equipped_item($slot[off-hand]) == $item[Drunkula\'s Wineglass]))
				{
					return autoAdv(1, loc, option);
				}
				else
				{
					string temp = run_combat(option);
					cli_execute("auto_post_adv");
					return true;
				}
			}
			else
			{
				string temp = run_combat();
				cli_execute("auto_post_adv");
				return true;
			}
		}
		else
		{
			string temp = run_combat();
			cli_execute("auto_post_adv");
			return true;
		}
	}

	# Encounters that need to generate a false so we handle them manually should go here.
	if(get_property("lastEncounter") == "Fitting In")
	{
		return false;
	}
	if(get_property("lastEncounter") == "Arboreal Respite")
	{
		return false;
	}
	if(get_property("lastEncounter") == "Travel to a Recent Fight")
	{
		return false;
	}
	if(get_property("lastEncounter") == "Rationing out Destruction")
	{
		return false;
	}
	if(auto_my_path() == "G-Lover")
	{
		if(get_property("lastEncounter") == "The Hidden Heart of the Hidden Temple")
		{
			return false;
		}
	}



	boolean inChoice = false;
	if(contains_text(page, "whichchoice value=") || contains_text(page, "whichchoice="))
	{
		auto_log_warning("Override hit a choice adventure (" + loc + "), trying....", "red");
		inChoice = true;
	}

	matcher choice_matcher = create_matcher("(?:whichchoice value=(\\d+))|(?:whichchoice=(\\d+))", page);
	if(choice_matcher.find())
	{
		//If we come in from an unknown adventure type, mafia does not handle the choice adventure properly
		int choice = choice_matcher.group(1).to_int();
		if(choice == 0)
		{
			choice = choice_matcher.group(2).to_int();
		}

		boolean retval = false;
		if(!retval)
		{
			run_choice(get_property("choiceAdventure" + choice).to_int());
			cli_execute("auto_post_adv");
			//We can no longer return an adventure return value here... is false acceptable?
		}
		else
		{
			set_property("auto_disableAdventureHandling", true);
			boolean retval = true;
			if((inebriety_left() >= 0) || (equipped_item($slot[off-hand]) == $item[Drunkula\'s Wineglass]))
			{
				retval = autoAdv(1, loc, option);
			}
			else
			{
				run_combat(option);
			}
			set_property("auto_disableAdventureHandling", false);
			cli_execute("auto_post_adv");
		}
		return retval;
	}

	if(inChoice)
	{
		abort("Detected we are in a choice adventure but the matcher was done incorrectly.");
	}

	return false;
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
