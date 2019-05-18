script "sl_adventure.ash"

# num is not handled properly anyway, so we'll just reject it.
boolean slAdv(location loc, string option)
{
	return slAdv(1, loc, option);
}

# num is not handled properly anyway, so we'll just reject it.
boolean slAdv(int num, location loc, string option)
{
	set_property("sl_combatHandler", "");
	set_property("sl_diag_round", 0);
	if(option == "")
	{
		option = "sl_combatHandler";
	}
	if(sl_my_path() == "Actually Ed the Undying")
	{
		return ed_slAdv(num, loc, option);
	}
	if(sl_my_path() == "Pocket Familiars")
	{
		return digimon_slAdv(num, loc, option);
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
	if(sl_my_path() == "One Crazy Random Summer")
	{
		if(last_monster().random_modifiers["clingy"])
		{
			int oldDesert = get_property("desertExploration").to_int();
			retval = slAdv(num, loc, option);
			if(my_location() == $location[The Arid\, Extra-Dry Desert])
			{
				set_property("desertExploration", oldDesert);
			}
		}
	}
	return retval;
}

boolean slAdv(int num, location loc)
{
	return slAdv(num, loc, "");
}

boolean slAdv()
{
	if(my_location() == $location[none])
	{
		return slAdv(1, $location[Noob Cave], "");
	}
	return slAdv(1, my_location(), "");
}

boolean slAdv(location loc)
{
	return slAdv(1, loc, "");
}

boolean slAdvBypass(string url, location loc)
{
	return slAdvBypass(url, loc, "");
}

#boolean slAdvBypass(string[int] url, location loc)
#{
#	return slAdvBypass(url, loc, "");
#}

boolean slAdvBypass(string url, location loc, string option)
{
	string[int] urlConvert;
	urlConvert[0] = url;
	return slAdvBypass(0, urlConvert, loc, option);
}

# Preserved to remind us of this issue.
#boolean slAdvBypass(int becauseStringIntIsSomehowJustString, string[int] url, location loc, string option)
#
#	urlGetFlags allows us to force visit_url(X, false). It is a bit field.
#
boolean slAdvBypass(int urlGetFlags, string[int] url, location loc, string option)
{
	set_property("nextAdventure", loc);
	cli_execute("presool");
#	handlePreAdventure(loc);
	if(option == "")
	{
		option = "sl_combatHandler";
	}
	if(my_class() == $class[Ed])
	{
		ed_preAdv(1, loc, option);
	}

	print("About to start a combat indirectly at " + loc + "... (" + count(url) + ") accesses required.", "blue");
	string page;
	foreach idx, it in url
	{
		if((urlGetFlags & 1) == 1)
		{
			#print("Visit_url(" + it + ") override to false", "red");
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
		print("Uh oh! Died when starting a combat indirectly.", "red");
		if(my_class() == $class[Ed])
		{
			return ed_slAdv(1, loc, option, true);
		}
		#Can we just return true here?
		abort("slAdvBypass override abort");
	}

	string combatPage = "<b>Combat";
	if(sl_my_path() == "Pocket Familiars")
	{
		combatPage = "<b>Fight!";
	}
	if(contains_text(page, combatPage))
	{
		print("slAdvBypass has encountered a combat! (param: '" + option + "')", "green");

		if(option != "null") // && (option != ""))
		{
			if(get_auto_attack() == 0)
			{
				if((inebriety_left() >= 0) || (equipped_item($slot[off-hand]) == $item[Drunkula\'s Wineglass]))
				{
					return slAdv(1, loc, option);
				}
				else
				{
					string temp = run_combat(option);
					cli_execute("postsool");
					return true;
				}
			}
			else
			{
				string temp = run_combat();
				cli_execute("postsool");
				return true;
			}
		}
		else
		{
			string temp = run_combat();
			cli_execute("postsool");
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
	if(sl_my_path() == "G-Lover")
	{
		if(get_property("lastEncounter") == "The Hidden Heart of the Hidden Temple")
		{
			return false;
		}
	}



	boolean inChoice = false;
	if(contains_text(page, "whichchoice value=") || contains_text(page, "whichchoice="))
	{
		print("Override hit a choice adventure (" + loc + "), trying....", "red");
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
			cli_execute("postsool");
			//We can no longer return an adventure return value here... is false acceptable?
		}
		else
		{
			set_property("sl_disableAdventureHandling", true);
			boolean retval = true;
			if((inebriety_left() >= 0) || (equipped_item($slot[off-hand]) == $item[Drunkula\'s Wineglass]))
			{
				retval = slAdv(1, loc, option);
			}
			else
			{
				run_combat(option);
			}
			set_property("sl_disableAdventureHandling", false);
			cli_execute("postsool");
		}
		return retval;
	}

	if(inChoice)
	{
		abort("Detected we are in a choice adventure but the matcher was done incorrectly.");
	}

	return false;
}

boolean slAdvBypass(int snarfblat, location loc)
{
	string page = "adventure.php?snarfblat=" + snarfblat;
	return slAdvBypass(page, loc);
}
boolean slAdvBypass(int snarfblat, location loc, string option)
{
	string page = "adventure.php?snarfblat=" + snarfblat;
	return slAdvBypass(page, loc, option);
}

boolean slAdvBypass(int snarfblat)
{
	return slAdvBypass(snarfblat, $location[Noob Cave]);
}
boolean slAdvBypass(string url)
{
	return slAdvBypass(url, $location[Noob Cave]);
}
#boolean slAdvBypass(string[int] url)
#{
#	return slAdvBypass(url, $location[Noob Cave]);
#}
boolean slAdvBypass(int snarfblat, string option)
{
	return slAdvBypass(snarfblat, $location[Noob Cave], option);
}
boolean slAdvBypass(string url, string option)
{
	return slAdvBypass(url, $location[Noob Cave], option);
}
#boolean slAdvBypass(string[int] url, string option)
#{
#	return slAdvBypass(url, $location[Noob Cave], option);
#}





boolean preAdvXiblaxian(location loc)
{
	if((equipped_item($slot[acc3]) == $item[Xiblaxian Holo-Wrist-Puter]) && (howLongBeforeHoloWristDrop() <= 1))
	{
		string area = loc.environment;
		# This is an attempt to farm Xiblaxian food/booze stuff.
		item toMake = to_item(get_property("sl_xiblaxianChoice"));
		if(toMake == $item[none])
		{
			toMake = $item[Xiblaxian Ultraburrito];
		}

		# If we migrate all Ed workaround combats to the bypasser, we don't need to check main.php
		if(my_class() == $class[Ed])
		{
			if(contains_text(visit_url("main.php"), "Combat"))
			{
				print("As Ed, I was not bypassed into this combat correctly (but it'll be ok)", "red");
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
				print("We should be getting a Xiblaxian wotsit this combat. Beep boop.", "green");
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
				print("We should be getting a Xiblaxian wotsit this combat. Beep boop.", "green");
			}
		}
	}
	return true;
}
