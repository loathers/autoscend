boolean in_lta()
{
	return my_path() == $path[License to Adventure];
}

void bond_initializeSettings()
{
	if(in_lta())
	{
		set_property("auto_getBeehive", true);
		set_property("auto_wandOfNagamar", false);
		set_property("auto_familiarChoice", "");
	}
}

boolean bond_buySkills()
{
	if(!in_lta())
	{
		return false;
	}
	string page = visit_url("place.php?whichplace=town_right&action=town_bondhq", false);
	matcher bondPoints = create_matcher("You have (\\d+) pound", page);
	int points = 0;
	if(bondPoints.find())
	{
		points = to_int(bondPoints.group(1));
		auto_log_info("Found " + points + " pound(s) of social capital husks.", "green");
	}

	while(points > 0)
	{
		int start = points;
		if(!get_property("bondSymbols").to_boolean())
		{
			if(points >= 3)
			{
				auto_log_info("Getting bondSymbols", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=10&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondJetpack").to_boolean())
		{
			if(points >= 3)
			{
				auto_log_info("Getting bondJetpack", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=12&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondDrunk2").to_boolean())
		{
			if(points >= 3)
			{
				auto_log_info("Getting bondDrunk2", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=11&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondDrunk1").to_boolean())
		{
			if(points >= 2)
			{
				auto_log_info("Getting bondDrunk1", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=8&w=s");
				points -= 2;
			}
		}
		else if(!get_property("bondMartiniPlus").to_boolean())
		{
			if(points >= 3)
			{
				auto_log_info("Getting bondMartiniPlus", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=13&w=p");
				points -= 3;
			}
		}
		else if(!get_property("bondMartiniTurn").to_boolean())
		{
			if(points >= 1)
			{
				auto_log_info("Getting bondMartiniTurn", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=1&w=p");
				points -= 1;
			}
		}
		else if(!get_property("bondAdv").to_boolean())
		{
			if(points >= 1)
			{
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=1&w=s");
				points -= 1;
			}
		}
		else if(!get_property("bondBridge").to_boolean() && (get_property("chasmBridgeProgress").to_int() < (bridgeGoal() - 2)))
		{
			if(points >= 3)
			{
				auto_log_info("Getting bondBridge", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=14&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondDesert").to_boolean() && (get_property("desertExploration").to_int() < 100))
		{
			if(points >= 5)
			{
				auto_log_info("Getting bondDesert", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=18&w=s");
				points -= 5;
			}
		}
		else if(!get_property("bondMeat").to_boolean())
		{
			if(points >= 1)
			{
				auto_log_info("Getting bondMeat", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=2&w=p");
				points -= 1;
			}
		}
		else if(!get_property("bondItem1").to_boolean())
		{
			if(points >= 1)
			{
				auto_log_info("Getting bondItem1", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=3&w=p");
				points -= 1;
			}
		}
		else if(!get_property("bondItem2").to_boolean())
		{
			if(points >= 2)
			{
				auto_log_info("Getting bondItem2", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=6&w=s");
				points -= 2;
			}
		}
		if(start == points)
		{
			break;
		}
	}
	return true;
}


boolean LM_bond()
{
	if(!in_lta())
	{
		return false;
	}

	if((item_amount($item[Victor\'s Spoils]) > 0) && !get_property("_victorSpoilsUsed").to_boolean() && (my_adventures() < 10))
	{
		use(1, $item[Victor\'s Spoils]);
	}

	if(have_effect($effect[Disavowed]) > 0)
	{
		if(have_skill($skill[Disco Nap]) && (my_mp() > mp_cost($skill[Disco Nap])))
		{
			use_skill(1, $skill[Disco Nap]);
		}
		set_property("_auto_bondBriefing", "started");
	}

	if((get_property("_auto_bondBriefing") == "started") && (get_property("_villainLairProgress").to_int() >= 999))
	{
		set_property("_auto_bondBriefing", "finished");
	}

	if(get_property("_auto_bondBriefing") == "started")
	{
		boolean retval = autoAdv($location[Super Villain\'s Lair]);
		if(!retval)
		{
			set_property("_auto_bondBriefing", "finished");
			bond_buySkills();
		}
		return retval;
	}

	if(get_property("_auto_bondLevel").to_int() < my_level())
	{
		set_property("_auto_bondLevel", my_level());
		bond_buySkills();
	}

	if(get_property("_auto_bondBriefing") == "finished")
	{
		return false;
	}

	return false;
}

item[int] bondDrinks()
{
	item[int] retval = itemList();

	foreach it in $items[]
	{
		if((it.smallimage == "martini.gif") && is_unrestricted(it))
		{
			retval = retval.ListInsert(it);
		}
	}
	return retval;

}
