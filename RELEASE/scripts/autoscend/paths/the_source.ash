boolean in_theSource()
{
	return my_path() == "The Source";
}

boolean theSource_initializeSettings()
{
	if(in_theSource())
	{
#		set_property("auto_lastSpoon", 0);
		set_property("auto_getBeehive", true);
		set_property("auto_wandOfNagamar", false);
	}
	return false;
}

boolean theSource_buySkills()
{
	if(get_property("sourceEnlightenment").to_int() == 0)
	{
		return false;
	}

	string temp = visit_url("place.php?whichplace=manor1&action=manor1_sourcephone_ring");
	int enlightenment = get_property("sourceEnlightenment").to_int();
	while(enlightenment > 0)
	{
		int option = 0;
		if(!have_skill($skill[Restore]))
		{
			option = 10;
		}
		if(!have_skill($skill[Overclocked]))
		{
			option = 1;
		}
		if(!have_skill($skill[Reboot]))
		{
			option = 9;
		}
		if(!have_skill($skill[Bullet Time]))
		{
			option = 2;
		}
		if(!have_skill($skill[True Disbeliever]))
		{
			option = 3;
		}
		if(!have_skill($skill[Code Block]))
		{
			option = 4;
		}
		if(!have_skill($skill[Disarmament]))
		{
			option = 5;
		}
		if(!have_skill($skill[Humiliating Hack]))
		{
			option = 7;
		}
		if(!have_skill($skill[Big Guns]))
		{
			option = 6;
		}
		if(!have_skill($skill[Data Siphon]))
		{
			option = 11;
		}
		if(!have_skill($skill[Source Kick]))
		{
			option = 8;
		}

		if(option != 0)
		{
			temp = visit_url("choice.php?pwd=&whichchoice=1188&option=1&skid=" + option);
		}
		enlightenment -= 1;
	}
	return false;
}

boolean L8_theSourceNinjaOracle()
{
	//handles the scenario where we want do the oracle quest and the target is the ninja snowmen lair
	//in this case we do not mind if we can not beat the assassins. but if we can we would rather not waste adventures.
	if(internalQuestStatus("questL08Trapper") == -1)	//quest not even started. zone not accessible
	{
		return false;
	}
	if(internalQuestStatus("questL08Trapper") > 2)		//done with the slope this ascension so just adventure in the lair
	{
		return autoAdv($location[Lair of the Ninja Snowmen]);
	}
	if(internalQuestStatus("questL08Trapper") < 2)		//try to advance quest to step2 to unlock the ninja snowman lair
	{
		return L8_trapperQuest();		//if we fail to advance quest we want to go do something else. we are probably delaying
	}
	
	if(have_effect($effect[Thrice-Cursed]) > 0 || have_effect($effect[Twice-Cursed]) > 0 || have_effect($effect[Once-Cursed]) > 0)
	{
		return false;									//delaying to not disrupt hidden city
	}
	if(shenShouldDelayZone($location[Lair of the Ninja Snowmen]))
	{
		auto_log_debug("Delaying Lair of the Ninja Snowmen in case of Shen.");
		return false;
	}
	
	return autoAdv($location[Lair of the Ninja Snowmen]);
}

boolean LX_theSource()
{
	if(!in_theSource())
	{
		return false;
	}

	if((my_daycount() <= 2) && (have_effect($effect[Substats.enh]) == 0) && (my_level() < 13))
	{
		auto_sourceTerminalEnhance("substats");
	}

	location goal = get_property("sourceOracleTarget").to_location();
	if((goal != $location[none]) && (item_amount($item[No Spoon]) == 0))
	{
		if((goal == $location[The Batrat and Ratbat Burrow]) && (internalQuestStatus("questL04Bat") < 1))
		{
			return false;
		}
		if((goal == $location[Cobb\'s Knob Laboratory]) && (item_amount($item[Cobb\'s Knob Lab Key]) == 0))
		{
			return false;
		}

		if (goal == $location[Lair of the Ninja Snowmen] && internalQuestStatus("questL08Trapper") < 2)
		{
			return false;
		}
		if (goal == $location[The VERY Unquiet Garves] && get_property("questL07Cyrptic") != "finished")
		{
			return false;
		}
		if(goal == $location[The Castle in the Clouds in the Sky (Top Floor)])
		{
			if (internalQuestStatus("questL10Garbage") < 9)
			{
				return false;
			}
			if(L10_topFloor() || L10_holeInTheSkyUnlock())
			{
				return true;
			}
		}
		if(goal == $location[Lair of the Ninja Snowmen])
		{
			return L8_theSourceNinjaOracle();
		}

		if((goal == $location[The Red Zeppelin]) && (internalQuestStatus("questL11Ron") < 3))
		{
			return false;
		}
		if (goal == $location[The Hidden Park] && internalQuestStatus("questL11Worship") > 2)
		{
			return false;
		}

		auto_log_info("Not searching for a spoon, not at all...", "green");
		return autoAdv(goal);
	}
	return false;
}

boolean theSource_oracle()
{
	if(!in_theSource())
	{
		return false;
	}

	if(have_skill($skill[Restore]))
	{
		return false;
	}

	if(get_property("sourceOracleTarget").to_location() == $location[none])
	{
		string temp = visit_url("place.php?whichplace=town_wrong&action=townwrong_oracle");
		temp = visit_url("choice.php?pwd=&whichchoice=1190&option=1");

		switch(get_property("sourceOracleTarget").to_location())
		{
		case $location[The Skeleton Store]:			startMeatsmithSubQuest();		break;
		case $location[Madness Bakery]:				startArmorySubQuest();			break;
		case $location[The Overgrown Lot]:			startGalaktikSubQuest();		break;
		}

	}
	else if(item_amount($item[No Spoon]) > 0)
	{
		string temp = visit_url("place.php?whichplace=town_wrong&action=townwrong_oracle");
		temp = visit_url("choice.php?pwd=&whichchoice=1190&option=2");
		return true;
	}

	return false;
}

boolean LX_attemptPowerLevelTheSource()
{
	if(!in_theSource())
	{
		return false;
	}
	if (get_property("lastSecondFloorUnlock").to_int() != my_ascensions())
	{
		return false;
	}

	if(get_property("barrelShrineUnlocked").to_boolean())
	{
		if(cloversAvailable() == 0)
		{
			handleBarrelFullOfBarrels(false);
			string temp = visit_url("barrel.php");
			temp = visit_url("choice.php?whichchoice=1099&pwd=&option=2");
			handleBarrelFullOfBarrels(false);
			return true;
		}
		stat myStat = my_primestat();
		if(my_basestat(myStat) >= 148)
		{
			return false;
		}
		else if(my_basestat(myStat) >= 125)
		{
			//Should probably prefer to check what equipment failures we may be having.
			if((my_basestat($stat[Muscle]) < my_basestat(myStat)) && (my_basestat($stat[Muscle]) < 70))
			{
				myStat = $stat[Muscle];
			}
			if((my_basestat($stat[Mysticality]) < my_basestat(myStat)) && (my_basestat($stat[Mysticality]) < 70))
			{
				myStat = $stat[Mysticality];
			}
			if((my_basestat($stat[Moxie]) < my_basestat(myStat)) && (my_basestat($stat[Moxie]) < 70))
			{
				myStat = $stat[Moxie];
			}
		}
		//Else, default to mainstat.

		//Determine where to go for clover stats, do not worry about clover failures
		location whereTo = $location[none];
		switch(myStat)
		{
			case $stat[Muscle]:			whereTo = $location[The Haunted Gallery];				break;
			case $stat[Mysticality]:	whereTo = $location[The Haunted Bathroom];				break;
			case $stat[Moxie]:			whereTo = $location[The Haunted Ballroom];				break;
		}
		
		if (whereTo == $location[The Haunted Ballroom] && internalQuestStatus("questM21Dance") > 3)
		{
			use(item_amount($item[ten-leaf clover]), $item[ten-leaf clover]);
			autoAdv($location[The Haunted Bedroom]);
			return true;
		}
		if(cloversAvailable() > 0)
		{
			cloverUsageInit();
		}
		autoAdv(1, whereTo);
		cloverUsageFinish();
		return true;
	}
	//Banish mahogant, elegant after gown only. (Harold\'s Bell?)
	return autoAdv($location[The Haunted Bedroom]);
}
