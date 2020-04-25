script "auto_quest_level_13.ash"

boolean needStarKey()
{
	if(contains_text(get_property("nsTowerDoorKeysUsed"),"star key"))
	{
		return false;
	}
	if(item_amount($item[Richard\'s Star Key]) > 0)
	{
		return false;
	}
	return true;
}

boolean needDigitalKey()
{
	if(contains_text(get_property("nsTowerDoorKeysUsed"),"digital key"))
	{
		return false;
	}
	if(item_amount($item[Digital Key]) > 0)
	{
		return false;
	}
	if(whitePixelCount() >= 30)
	{
		return false;
	}

	return true;
}

int whitePixelCount()
{
	int count = item_amount($item[White Pixel]);

	int extra = min(item_amount($item[Red Pixel]), item_amount($item[Blue Pixel]));
	extra = min(extra, item_amount($item[Green Pixel]));
	return count + extra;
}

boolean L13_powerLevel()
{
	// this function is exceptionally badly named. It powerlevels to 13 and nothing else. Should be refactored.
	if(internalQuestStatus("questL13Final") < 0)
	{
		if(my_level() < 13)
		{
			auto_log_warning("I seem to need to power level, or something... waaaa.", "red");
			# lx_attemptPowerLevel is before. We need to merge all of this into that....
			set_property("auto_newbieOverride", true);

			if(needDigitalKey())
			{
				woods_questStart();
				if(LX_getDigitalKey())
				{
					return true;
				}
			}
			if(needStarKey())
			{
				if(zone_isAvailable($location[The Hole In The Sky]))
				{
					if(LX_getStarKey())
					{
						return true;
					}
				}
			}
			if(!hasTorso())
			{
				if(LX_melvignShirt())
				{
					return true;
				}
			}

			int delay = get_property("auto_powerLevelTimer").to_int();
			if(delay == 0)
			{
				delay = 10;
			}
			wait(delay);

			if(haveAnyIotmAlternativeRestSiteAvailable() && haveFreeRestAvailable() && auto_my_path() != "The Source")
			{
				doFreeRest();
				cli_execute("scripts/autoscend/auto_post_adv.ash");
				loopHandlerDelayAll();
				return true;
			}

			if(!LX_attemptPowerLevel())
			{
				if(get_property("auto_powerLevelAdvCount").to_int() >= 10)
				{
					auto_log_warning("The following error message is probably wrong, you just need to powerlevel to 13 most likely.", "red");
					if((item_amount($item[Rock Band Flyers]) > 0) || (item_amount($item[Jam Band Flyers]) > 0))
					{
						abort("Need more flyer ML but don't know where to go :(");
					}
					else
					{
						abort("I am lost, please forgive me. I feel underleveled.");
					}
				}
			}
			return true;
		}
		else
		{
			if(my_level() != get_property("auto_powerLevelLastLevel").to_int())
			{
				auto_log_warning("Hmmm, we need to stop being so feisty about quests...", "red");
				set_property("auto_powerLevelLastLevel", my_level());
				return true;
			}
			council(); // Log council output
			abort("Some sidequest is not done for some raisin. Some sidequest is missing, or something is missing, or something is not not something. We don't know what to do.");
		}
	}
	return false;
}

boolean L13_towerNSContests()
{
	if (internalQuestStatus("questL13Final") < 0 || internalQuestStatus("questL13Final") > 3)
	{
		return false;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_02_coronation"))
	{
		set_property("choiceAdventure1020", "1");
		set_property("choiceAdventure1021", "1");
		set_property("choiceAdventure1022", "1");
		visit_url("place.php?whichplace=nstower&action=ns_02_coronation");
		visit_url("choice.php?pwd=&whichchoice=1020&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1021&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1022&option=1", true);
		return true;
	}

	boolean crowd1Insufficient()
	{
		return numeric_modifier("Initiative") < 400.0;
	}

	stat crowd_stat = ns_crowd2();

	boolean crowd2Insufficient()
	{
		return my_buffedstat(crowd_stat) < 600;
	}

	element challenge = ns_crowd3();
	boolean crowd3Insufficient()
	{
		return numeric_modifier(challenge + " Damage") + numeric_modifier(challenge + " Spell Damage") < 100;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_contestbooth"))
	{
		if(get_property("nsContestants1").to_int() == -1)
		{
			resetMaximize();
			if(!get_property("_grimBuff").to_boolean() && auto_have_familiar($familiar[Grim Brother]))
			{
				cli_execute("grim init");
			}
			if((get_property("telescopeUpgrades").to_int() > 0) && (!get_property("telescopeLookedHigh").to_boolean()))
			{
				cli_execute("telescope high");
			}
			switch(ns_crowd1())
			{
			case 1:
				acquireMP(160); // only uses free rests or items on hand by default


				autoMaximize("initiative -equip snow suit", 1500, 0, false);

				provideInitiative(400, true);

				if(crowd1Insufficient() && (get_property("sidequestArenaCompleted") == "fratboy"))
				{
					cli_execute("concert White-boy Angst");
				}

				if(crowd1Insufficient())
				{
					if(get_property("auto_secondPlaceOrBust").to_boolean())
						abort("Not enough initiative for the initiative test, aborting since auto_secondPlaceOrBust=true");
					else
						auto_log_warning("Not enough initiative for the initiative test, but continuing since auto_secondPlaceOrBust=false", "red");
				}
				break;
			}

			// Adjust us to the initiative familiar selected in provideInitiative().
			preAdvUpdateFamiliar($location[None]);

			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=1", true);
			visit_url("main.php");
		}
		if(get_property("nsContestants2").to_int() == -1)
		{
			resetMaximize();
			if(!get_property("_lyleFavored").to_boolean())
			{
				string temp = visit_url("place.php?whichplace=monorail&action=monorail_lyle");
			}
			acquireMP(150); // only uses free rests or items on hand by default
			if (my_class() == $class[Vampyre])
			{
				if(crowd_stat == $stat[muscle] && !have_skill($skill[Preternatural Strength]))
				{
					boolean[skill] requirements;
					requirements[$skill[Preternatural Strength]] = true;
					auto_log_info("Torporing, since we want to get Preternatural Strength.", "blue");
					bat_reallyPickSkills(20, requirements);
				}
				// This could be generalized for stat equalizer potions, but that seems marginal
				if (crowd_stat == $stat[muscle] && have_skill($skill[Preternatural Strength]))
					crowd_stat = $stat[mysticality];
				if (crowd_stat == $stat[moxie] && have_skill($skill[Sinister Charm]))
					crowd_stat = $stat[mysticality];
			}
			int [stat] statGoal;
			statGoal[crowd_stat] = 600;
			provideStats(statGoal, true);
			switch(crowd_stat)
			{
			case $stat[moxie]:
				autoMaximize("moxie -equip snow suit", 1500, 0, false);

				if(have_effect($effect[Ten out of Ten]) == 0)
				{
					if(crowd2Insufficient()) fightClubSpa($effect[Ten out of Ten]);
				}
				break;
			case $stat[muscle]:
				autoMaximize("muscle -equip snow suit", 1500, 0, false);

				if(have_effect($effect[Muddled]) == 0)
				{
					if(crowd2Insufficient()) fightClubSpa($effect[Muddled]);
				}
				break;
			case $stat[mysticality]:
				autoMaximize("myst -equip snow suit", 1500, 0, false);

				if(have_effect($effect[Uncucumbered]) == 0)
				{
					if(crowd2Insufficient()) fightClubSpa($effect[Uncucumbered]);
				}
				break;
			}

			if(crowd2Insufficient())
			{
				if(get_property("auto_secondPlaceOrBust").to_boolean())
					abort("Not enough " + crowd_stat + " for the stat test, aborting since auto_secondPlaceOrBust=true");
				else
					auto_log_warning("Not enough " + crowd_stat + " for the stat test, but continuing since auto_secondPlaceOrBust=false", "red");
			}
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=2", true);
			visit_url("main.php");
		}
		if(get_property("nsContestants3").to_int() == -1)
		{
			resetMaximize();
			acquireMP(125); // only uses free rests or items on hand by default

			if(challenge != $element[none])
			{
				autoMaximize(challenge + " dmg, " + challenge + " spell dmg -equip snow suit", 1500, 0, false);
			}

			if(crowd3Insufficient()) buffMaintain($effect[All Glory To the Toad], 0, 1, 1);
			if(crowd3Insufficient()) buffMaintain($effect[Bendin\' Hell], 120, 1, 1);
			switch(challenge)
			{
			case $element[cold]:
				if(crowd3Insufficient()) auto_beachCombHead("cold");
				if(crowd3Insufficient()) buffMaintain($effect[Cold Hard Skin], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Frostbeard], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Icy Glare], 10, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Song of the North], 100, 1, 1);
				break;
			case $element[hot]:
				if(crowd3Insufficient()) auto_beachCombHead("hot");
				if(crowd3Insufficient()) buffMaintain($effect[Song of Sauce], 100, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Flamibili Tea], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Flaming Weapon], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Human-Demon Hybrid], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Lit Up], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Fire Inside], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Pyromania], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Your Fifteen Minutes], 50, 1, 1);
				break;
			case $element[sleaze]:
				if(crowd3Insufficient()) auto_beachCombHead("sleaze");
				if(crowd3Insufficient()) buffMaintain($effect[Takin\' It Greasy], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Blood-Gorged], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Greasy Peasy], 0, 1, 1);
				break;
			case $element[stench]:
				if(crowd3Insufficient()) auto_beachCombHead("stench");
				if(crowd3Insufficient()) buffMaintain($effect[Drenched With Filth], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Musky], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Stinky Hands], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Stinky Weapon], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Rotten Memories], 15, 1, 1);
				break;
			case $element[spooky]:
				if(crowd3Insufficient()) auto_beachCombHead("spooky");
				if(crowd3Insufficient()) buffMaintain($effect[Spooky Hands], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Spooky Weapon], 0, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Dirge of Dreadfulness], 10, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Intimidating Mien], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Snarl of the Timberwolf], 10, 1, 1);
				break;
			}

			float score = numeric_modifier(challenge + " damage");
			score += numeric_modifier(challenge + " spell damage");
			if((score > 20.0) && (score < 85.0))
			{
				buffMaintain($effect[Bendin\' Hell], 100, 1, 1);
			}

			score = numeric_modifier(challenge + " damage");
			score += numeric_modifier(challenge + " spell damage");
			if((score < 80) && get_property("auto_useWishes").to_boolean())
			{
				switch(challenge)
				{
				case $element[cold]:
					makeGenieWish($effect[Staying Frosty]);
					break;
				case $element[hot]:
					makeGenieWish($effect[Dragged Through the Coals]);
					break;
				case $element[sleaze]:
					makeGenieWish($effect[Fifty Ways to Bereave your Lover]);
					break;
				case $element[stench]:
					makeGenieWish($effect[Sewer-Drenched]);
					break;
				case $element[spooky]:
					makeGenieWish($effect[You\'re Back...]);
					break;
				}
			}

			if(crowd3Insufficient())
			{
				if(get_property("auto_secondPlaceOrBust").to_boolean())
					abort("Not enough " + challenge + " for the elemental test, aborting since auto_secondPlaceOrBust=true");
				else
					auto_log_warning("Not enough " + challenge + " for the elemental test, but continuing since auto_secondPlaceOrBust=false", "red");
			}

			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=3", true);
			visit_url("main.php");
		}

		set_property("choiceAdventure1003",  4);
		if((get_property("nsContestants1").to_int() == 0) && (get_property("nsContestants2").to_int() == 0) && (get_property("nsContestants3").to_int() == 0))
		{
			auto_log_info("The NS Challenges are over! Victory is ours!", "blue");
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=4", true);
			visit_url("main.php");
			if((get_property("nsContestants1").to_int() != 0) || (get_property("nsContestants2").to_int() != 0) || (get_property("nsContestants3").to_int() != 0))
			{
				if(internalQuestStatus("questL13Final") == 2)
				{
					if(auto_my_path() == "The Source")
					{
						//As of r17048, encountering a Source Agent on the Challenge line results in nsContestants being decremented twice.
						//Since we were using Mafia\'s tracking here, we have to compensate for when it fails...
						auto_log_warning("Probably encountered a Source Agent during the NS Contestants and Mafia's tracking fails on this. Let's try to correct it...", "red");
						set_property("questL13Final", "step1");
					}
					else
					{
						auto_log_critical("Error not recoverable (as not antipicipated) outside of The Source (Source Agents during NS Challenges), aborting.", "red");
						abort("questL13Final error in unexpected path.");
					}
				}
				else
				{
					auto_log_critical("Unresolvable error: Mafia thinks the NS challenges are complete but something is very wrong.", "red");
					abort("Unknown questL13Final state.");
				}
			}
			return true;
		}
	}

	handleFamiliar("item");
	equipBaseline();

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_crowd1"))
	{
		autoAdv(1, $location[Fastest Adventurer Contest]);
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_crowd2"))
	{
		location toCompete = $location[none];
		switch(get_property("nsChallenge1"))
		{
		case "Mysticality":	toCompete = $location[Smartest Adventurer Contest];		break;
		case "Moxie":		toCompete = $location[Smoothest Adventurer Contest];	break;
		case "Muscle":		toCompete = $location[Strongest Adventurer Contest];	break;
		}
		if(toCompete == $location[none])
		{
			abort("nsChallenge1 is invalid. This is a severe error.");
		}
		autoAdv(1, toCompete);
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_crowd3"))
	{
		location toCompete = $location[none];
		switch(get_property("nsChallenge2"))
		{
		case "cold":		toCompete = $location[Coldest Adventurer Contest];		break;
		case "hot":			toCompete = $location[Hottest Adventurer Contest];		break;
		case "sleaze":		toCompete = $location[Sleaziest Adventurer Contest];	break;
		case "spooky":		toCompete = $location[Spookiest Adventurer Contest];	break;
		case "stench":		toCompete = $location[Stinkiest Adventurer Contest];	break;
		}
		if(toCompete == $location[none])
		{
			abort("nsChallenge1 is invalid. This is a severe error.");
		}
		autoAdv(1, toCompete);
		return true;
	}
	auto_log_info("No challenges left!", "green");
	if(auto_my_path() == "Pocket Familiars")
	{
		if(get_property("nsContestants1").to_int() == 0)
		{
			return false;
		}
		set_property("nsContestants1", 0);
		set_property("nsContestants2", 0);
		set_property("nsContestants3", 0);
		return true;
	}
	return false;
}

boolean L13_towerNSHedge()
{
	if(internalQuestStatus("questL13Final") < 4 || internalQuestStatus("questL13Final") > 4)
	{
		return false;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "hedgemaze"))
	{
		//If we got beaten up by the last hedgemaze, mafia might set questL13Final to step5 anyway. Fix that.
		set_property("questL13Final", "step4");
		if((have_effect($effect[Beaten Up]) > 0) || (my_hp() < 150))
		{
			auto_log_critical("Hedge maze not solved, the mysteries are still there (correcting step5 -> step4)", "red");
			abort("Heal yourself and try again...");
		}
	}

	# Set this so it aborts if not enough adventures. Otherwise, well, we end up in a loop.
	set_property("choiceAdventure1004", "3");
	set_property("choiceAdventure1005", "2");			# 'Allo
	set_property("choiceAdventure1006", "2");			# One Small Step For Adventurer
	set_property("choiceAdventure1007", "2");			# Twisty Little Passages, All Hedge
	set_property("choiceAdventure1008", "2");			# Pooling Your Resources
	set_property("choiceAdventure1009", "2");			# Gold Ol' 44% Duck
	set_property("choiceAdventure1010", "2");			# Another Day, Another Fork
	set_property("choiceAdventure1011", "2");			# Of Mouseholes and Manholes
	set_property("choiceAdventure1012", "2");			# The Last Temptation
	set_property("choiceAdventure1013", "1");			# Masel Tov!

	maximize_hedge();
	cli_execute("auto_pre_adv");
	acquireHP();
	visit_url("place.php?whichplace=nstower&action=ns_03_hedgemaze");
	if(get_property("lastEncounter") == "This Maze is... Mazelike...")
	{
		run_choice(2);
		abort("May not have enough adventures for the hedge maze. Failing");
	}

	if(get_property("auto_hedge") == "slow")
	{
		visit_url("choice.php?pwd=&whichchoice=1005&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1006&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1007&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1008&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1009&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1010&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1011&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1012&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1013&option=1", true);
	}
	else if(get_property("auto_hedge") == "fast")
	{
		visit_url("choice.php?pwd=&whichchoice=1005&option=2", true);
		visit_url("choice.php?pwd=&whichchoice=1008&option=2", true);
		visit_url("choice.php?pwd=&whichchoice=1011&option=2", true);
		visit_url("choice.php?pwd=&whichchoice=1013&option=1", true);
	}
	else
	{
		abort("auto_hedge not set properly (slow/fast), assuming manual handling desired");
	}
	if(have_effect($effect[Beaten Up]) > 0)
	{
		abort("Failed the hedge maze, may want to do this manually...");
	}
	return true;
}

boolean L13_sorceressDoor()
{
	if(internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	if(LX_getDigitalKey()) return true;

	string page = visit_url("place.php?whichplace=nstower_door");
	if(contains_text(page, "ns_lock6"))
	{
		if(item_amount($item[Skeleton Key]) == 0)
		{
			cli_execute("make skeleton key");
		}
		if(item_amount($item[Skeleton Key]) == 0)
		{
			abort("Need Skeleton Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock6");
	}

	if(towerKeyCount() < 3)
	{
		while(useMalware());
		if(towerKeyCount() < 3)
		{
			abort("Do not have enough hero keys");
		}
	}

	if(contains_text(page, "ns_lock1"))
	{
		if(item_amount($item[Boris\'s Key]) == 0)
		{
			if(in_koe() && item_amount($item[fat loot token]) > 0)
			{
				buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Boris\'s Key]);
			}
			else {
				cli_execute("make Boris's Key");
			}
		}
		if(item_amount($item[Boris\'s Key]) == 0)
		{
			abort("Need Boris's Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock1");
	}
	if(contains_text(page, "ns_lock2"))
	{
		if(item_amount($item[Jarlsberg\'s Key]) == 0)
		{
			if(in_koe() && item_amount($item[fat loot token]) > 0)
			{
				buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Jarlsberg\'s Key]);
			}
			else
			{
				cli_execute("make Jarlsberg's Key");
			}
		}
		if(item_amount($item[Jarlsberg\'s Key]) == 0)
		{
			abort("Need Jarlsberg's Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock2");
	}
	if(contains_text(page, "ns_lock3"))
	{
		if(item_amount($item[Sneaky Pete\'s Key]) == 0)
		{
			if(in_koe() && item_amount($item[fat loot token]) > 0)
			{
				buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Sneaky Pete\'s Key]);
			}
			else
			{
				cli_execute("make Sneaky Pete's Key");
			}
		}
		if(item_amount($item[Sneaky Pete\'s Key]) == 0)
		{
			abort("Need Sneaky Pete's Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock3");
	}

	if(contains_text(page, "ns_lock4"))
	{
		if(item_amount($item[Richard\'s Star Key]) == 0)
		{
			boolean temp = cli_execute("make richard's star key");
		}
		if(item_amount($item[Richard\'s Star Key]) == 0)
		{
			if(!get_property("auto_getStarKey").to_boolean())
			{
				abort("Need Richard's Star Key for the Sorceress door. Perhaps set auto_getStarKey=true ?");
			}
			else
			{
				abort("Need Richard's Star Key for the Sorceress door, but auto_getStarKey=true so I'm not sure why we haven't gotten it already. :(");
			}
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock4");
	}

	if(contains_text(page, "ns_lock5"))
	{
		if(item_amount($item[Digital Key]) == 0)
		{
			abort("Need Digital Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock5");
	}

	visit_url("place.php?whichplace=nstower_door&action=ns_doorknob");
	return true;
}

boolean L13_towerNSTower()
{
	if(internalQuestStatus("questL13Final") < 6 || internalQuestStatus("questL13Final") > 11)
	{
		return false;
	}

	auto_log_info("Scaling the mighty NStower...", "green");

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_05_monster1"))
	{
		auto_log_info("Time to fight the Wall of Skins!", "blue");
		auto_change_mcd(0);
		acquireMP(120, 0);

		int sources = 0;
		if(autoEquip($item[astral shirt]))
		{
			// nothing, just for else
		}
		else if (autoEquip($item[Unfortunato\'s foolscap]))
		{
			// nothing, just for else
		}
		else if(item_amount($item[cigar box turtle]) > 0)
		{
			use(1, $item[cigar box turtle]);
		}
		else if(have_effect($effect[damage.enh]) == 0)
		{
			int enhances = auto_sourceTerminalEnhanceLeft();
			if(enhances > 0)
			{
				auto_sourceTerminalEnhance("damage");
			}
		}

		if(my_class() == $class[Turtle Tamer])
		{
			autoEquip($slot[shirt], $item[Shocked Shell]);
		}
		if(have_skill($skill[Belch the Rainbow]))
		{
			sources = 6;
		}
		else
		{
			foreach damage in $strings[Cold Damage, Hot Damage, Sleaze Damage, Spooky Damage, Stench Damage]
			{
				if(numeric_modifier(damage) > 0)
				{
					sources += 1;
				}
			}
		}
		if(have_skill($skill[headbutt]))
		{
			sources = sources + 1;
		}
		if(canChangeToFamiliar($familiar[warbear drone]))
		{
			sources = sources + 2;
			handleFamiliar($familiar[Warbear Drone]);
			use_familiar($familiar[Warbear Drone]);
			cli_execute("auto_pre_adv"); // TODO: can we remove this?
			if(!possessEquipment($item[Warbear Drone Codes]))
			{
				pullXWhenHaveY($item[warbear drone codes], 1, 0);
			}
			if(possessEquipment($item[warbear drone codes]))
			{
				autoEquip($item[warbear drone codes]);
				sources = sources + 2;
			}
		}
		else if(canChangeToFamiliar($familiar[Sludgepuppy]))
		{
			handleFamiliar($familiar[Sludgepuppy]);
			sources = sources + 3;
		}
		else if(canChangeToFamiliar($familiar[Imitation Crab]))
		{
			handleFamiliar($familiar[Imitation Crab]);
			sources = sources + 2;
		}
		if(autoEquip($slot[acc1], $item[hippy protest button]))
		{
			sources = sources + 1;
		}
		if(item_amount($item[glob of spoiled mayo]) > 0)
		{
			buffMaintain($effect[Mayeaugh], 0, 1, 1);
			sources = sources + 1;
		}
		if(autoEquip($item[smirking shrunken head]))
		{
			sources = sources + 1;
		}
		else if(autoEquip($item[hot plate]))
		{
			sources = sources + 1;
		}
		if(have_skill($skill[Scarysauce]))
		{
			buffMaintain($effect[Scarysauce], 0, 1, 1);
			sources = sources + 1;
		}
		if(have_skill($skill[Spiky Shell]))
		{
			buffMaintain($effect[Spiky Shell], 0, 1, 1);
			sources = sources + 1;
		}
		if(have_skill($skill[Jalape&ntilde;o Saucesphere]))
		{
			sources = sources + 1;
			buffMaintain($effect[Jalape&ntilde;o Saucesphere], 0, 1, 1);
		}
		handleBjornify($familiar[Hobo Monkey]);
		autoEquip($slot[acc2], $item[world\'s best adventurer sash]);
		autoEquip($slot[acc3], $item[Groll Doll]);
		autoEquip($slot[acc3], $item[old school calculator watch]);
		autoEquip($slot[acc3], $item[Bottle Opener Belt Buckle]);
		autoEquip($slot[acc3], $item[acid-squirting flower]);
		if(have_skill($skill[Frigidalmatian]) && (my_mp() > 300))
		{
			sources = sources + 1;
		}
		int sourceNeed = 13;
		if(have_skill($skill[Shell Up]))
		{
			if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0))
			{
				if(have_skill($skill[Blessing of the War Snapper]) && (my_mp() > (2 * mp_cost($skill[Blessing of the War Snapper]))))
				{
					use_skill(1, $skill[Blessing of the War Snapper]);
				}
			}
			if((have_effect($effect[Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Grand Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Glorious Blessing of the Storm Tortoise]) == 0))
			{
				sourceNeed -= 2;
			}
		}
		if(have_skill($skill[Sauceshell]))
		{
			sourceNeed -= 2;
		}
		auto_log_info("I think I have " + sources + " sources of damage, let's do this!", "blue");
		if(auto_my_path() == "Pocket Familiars")
		{
			sources = 9999;
		}
		if((item_amount($item[Beehive]) > 0) || (sources > sourceNeed))
		{
			if(item_amount($item[Beehive]) == 0)
			{
				acquireHP();
			}
			autoAdvBypass("place.php?whichplace=nstower&action=ns_05_monster1", $location[Tower Level 1]);
			if(internalQuestStatus("questL13Final") < 7)
			{
				set_property("auto_getBeehive", true);
				auto_log_warning("I probably failed the Wall of Skin, I assume that I tried without a beehive. Well, I'm going back to get it.", "red");
			}
			else
			{
				handleFamiliar("item");
			}
		}
		else
		{
			set_property("auto_getBeehive", true);
			auto_log_warning("Need a beehive, buzz buzz. Only have " + sources + " damage sources and we want " + sourceNeed, "red");
		}
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_06_monster2"))
	{
		equipBaseline();
		shrugAT($effect[Polka of Plenty]);
		buffMaintain($effect[Disco Leer], 0, 1, 1);
		buffMaintain($effect[Polka of Plenty], 0, 1, 1);
		buffMaintain($effect[Cranberry Cordiality], 0, 1, 1);
		buffMaintain($effect[Big Meat Big Prizes], 0, 1, 1);
		buffMaintain($effect[Patent Avarice], 0, 1, 1);
		bat_formWolf();
		if((get_property("sidequestArenaCompleted") == "fratboy") && !get_property("concertVisited").to_boolean() && (have_effect($effect[Winklered]) == 0))
		{
			cli_execute("concert 2");
		}
		if(!canChangeFamiliar())
		{
			addToMaximize("200meat drop");
		}
		else
		{
			addToMaximize("200meat drop,switch hobo monkey,switch rockin' robin,switch adventurous spelunker,switch grimstone golem,switch fist turkey,switch unconscious collective,switch golden monkey,switch angry jung man,switch leprechaun,switch cat burglar");
		}
		if(my_class() == $class[Seal Clubber])
		{
			autoEquip($item[Meat Tenderizer is Murder]);
		}

		acquireHP();
		autoAdvBypass("place.php?whichplace=nstower&action=ns_06_monster2", $location[Noob Cave]);
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_07_monster3"))
	{
		if((item_amount($item[Electric Boning Knife]) > 0) || (auto_my_path() == "Pocket Familiars"))
		{
			set_property("auto_getBoningKnife", false);
		}

		if(!get_property("auto_getBoningKnife").to_boolean() && ((my_class() == $class[Sauceror]) || have_skill($skill[Garbage Nova])))
		{
			uneffect($effect[Scarysauce]);
			uneffect($effect[Jalape&ntilde;o Saucesphere]);
			uneffect($effect[Mayeaugh]);
			uneffect($effect[Spiky Shell]);
			handleFamiliar($familiar[none]);
			buffMaintain($effect[Tomato Power], 0, 1, 1);
			buffMaintain($effect[Seeing Colors], 0, 1, 1);
			buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
			buffMaintain($effect[OMG WTF], 0, 1, 1);
			buffMaintain($effect[There is a Spoon], 0, 1, 1);
			boolean keepTrying = true;
			acquireMP(216, 0);

			buffMaintain($effect[Song of Sauce], 0, 1, 1);
			buffMaintain($effect[Carol of the Hells], 0, 1, 1);
			if(item_amount($item[Electric Boning Knife]) == 0)
			{
				addToMaximize("100myst,60spell damage percent,20spell damage,-20ml");
			}
			foreach s in $slots[acc1, acc2, acc3]
			{
				if(equipped_item(s) == $item[hand in glove])
				{
					equip(s, $item[none]);
				}
			}

			acquireHP();

			// Go into the fight with No Familiar Equips since maximizer wants to force an equip
			// this keeps us from accidentally dealing damage and killing ourselves
			addToMaximize("-familiar");

			autoAdvBypass("place.php?whichplace=nstower&action=ns_07_monster3", $location[Noob Cave]);
			if(internalQuestStatus("questL13Final") < 9)
			{
				auto_log_warning("Could not towerkill Wall of Bones, reverting to Boning Knife", "red");
				acquireHP();
				set_property("auto_getBoningKnife", true);
			}
			else
			{
				handleFamiliar("item");
			}
		}
		else if((item_amount($item[Electric Boning Knife]) > 0) || (auto_my_path() == "Pocket Familiars"))
		{
			return autoAdvBypass("place.php?whichplace=nstower&action=ns_07_monster3", $location[Noob Cave]);
		}
		else if(canGroundhog($location[The Castle in the Clouds in the Sky (Ground Floor)]))
		{
			auto_log_info("Backfarming an Electric Boning Knife", "green");
			set_property("choiceAdventure1026", "2");
			autoAdv(1, $location[The Castle in the Clouds in the Sky (Ground Floor)]);
		}
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_08_monster4"))
	{
		boolean confidence = get_property("auto_confidence").to_boolean();
		// confidence really just means take the first choice, so it's necessary in vampyre
		if(my_class() == $class[Vampyre])
			confidence = true;
		string choicenum = (confidence ? "1" : "2");
		set_property("choiceAdventure1015", choicenum);
		visit_url("place.php?whichplace=nstower&action=ns_08_monster4");
		visit_url("choice.php?pwd=&whichchoice=1015&option=" + choicenum, true);
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_09_monster5"))
	{
		if(my_maxhp() < 800)
		{
			buffMaintain($effect[Industrial Strength Starch], 0, 1, 1);
			buffMaintain($effect[Truly Gritty], 0, 1, 1);
			buffMaintain($effect[Superheroic], 0, 1, 1);
			buffMaintain($effect[Strong Grip], 0, 1, 1);
			buffMaintain($effect[Spiky Hair], 0, 1, 1);
		}
		cli_execute("scripts/autoscend/auto_post_adv.ash");
		acquireHP();

		int n_healing_items = item_amount($item[gauze garter]) + item_amount($item[filthy poultice]);
		if(in_zelda())
		{
			n_healing_items = item_amount($item[super deluxe mushroom]);
			if(n_healing_items < 5)
			{
				retrieve_item(5, $item[super deluxe mushroom]);
				n_healing_items = item_amount($item[super deluxe mushroom]);
			}
		}
		if(n_healing_items < 5)
		{
			abort("We only have " + n_healing_items + " healing items, I'm not sure we can do the shadow.");
		}
		autoAdvBypass("place.php?whichplace=nstower&action=ns_09_monster5", $location[Noob Cave]);
		return true;
	}
	return false;
}

boolean L13_towerNSFinal()
{
	//state 11 means ready to fight sorceress. state 12 means lost to her due to lack of wand thus unlocking bear verb orgy
	if (internalQuestStatus("questL13Final") < 11 || internalQuestStatus("questL13Final") > 12)
	{
		return false;
	}
	
	//wand acquisition function is called before this function, it turns this propery to false once a wand is acquired.
	//it is also false on all paths that don't want a wand. Thus if it is true it means we do want a wand but didn't get one yet.
	if(get_property("auto_wandOfNagamar").to_boolean() && internalQuestStatus("questL13Final") == 11)
	{
		auto_log_warning("We do not have a Wand of Nagamar but appear to need one. We must lose to the Sausage first...", "red");
	}

	if(auto_my_path() == "Heavy Rains")
	{
		return L13_towerFinalHeavyRains();
	}
	
	if(auto_my_path() == "The Source")
	{
		acquireMP(200, 0);
	}
	
	if(!($strings[Actually Ed the Undying, Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Bees Hate You, Bugbear Invasion, Community Service, The Source, Way of the Surprising Fist, Zombie Slayer] contains auto_my_path()))
	{
		//Only if the final boss does not unbuff us...
		cli_execute("scripts/autoscend/auto_post_adv.ash");
	}
	
	if(my_class() == $class[Turtle Tamer])
	{
		autoEquip($item[Ouija Board\, Ouija Board]);
	}

	if((pulls_remaining() == -1) || (pulls_remaining() > 0))
	{
		if(can_equip($item[Oscus\'s Garbage Can Lid]))
		{
			pullXWhenHaveY($item[Oscus\'s Garbage Can Lid], 1, 0);
		}
	}

	autoEquip($slot[Off-Hand], $item[Oscus\'s Garbage Can Lid]);

	handleFamiliar("boss");

	addToMaximize("10dr,3moxie,0.5da 1000max,-5ml,1.5hp,0item,0meat");
	autoEquip($slot[acc2], $item[Attorney\'s Badge]);

	if(internalQuestStatus("questL13Final") < 13)
	{
		cli_execute("scripts/autoscend/auto_pre_adv.ash");
		set_property("auto_disableAdventureHandling", true);
		autoAdvBypass("place.php?whichplace=nstower&action=ns_10_sorcfight", $location[Noob Cave]);
		if(have_effect($effect[Beaten Up]) > 0)
		{
			auto_log_warning("Sorceress beat us up. Wahhh.", "red");
			set_property("auto_disableAdventureHandling", false);
			return true;
		}
		if(last_monster() == $monster[Naughty Sorceress])
		{
			autoAdv(1, $location[Noob Cave]);
			if(have_effect($effect[Beaten Up]) > 0)
			{
				auto_log_warning("Blobbage Sorceress beat us up. Wahhh.", "red");
				set_property("auto_disableAdventureHandling", true);
				return true;
			}
			autoAdv(1, $location[Noob Cave]);
			if(have_effect($effect[Beaten Up]) > 0)
			{
				if(get_property("lastEncounter") == "The Naughty Sorceress (3)")
				{
					string page = visit_url("choice.php");
					if(last_choice() == 1016)
					{
						run_choice(1);
						set_property("auto_wandOfNagamar", true);
					}
					else
					{
						abort("Expected to start Nagamar side-quest but unable to");
					}
					return true;
				}
				auto_log_warning("We got beat up by a sausage....", "red");
				set_property("auto_disableAdventureHandling", false);
				return true;
			}
			if(get_property("auto_stayInRun").to_boolean())
			{
				set_property("auto_disableAdventureHandling", false);
				abort("User wanted to stay in run (auto_stayInRun), we are done.");
			}

			if(!($classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief] contains my_class()))
			{
				set_property("auto_disableAdventureHandling", false);
				cli_execute("refresh quests");
				if(internalQuestStatus("questL13Final") > 12)
				{
					abort("Freeing the king will result in a path change and we can barely handle The Sleazy Back Alley. Aborting, run the script again after selecting your aftercore path in order for it to clean up.");
				}
				return true;
			}
			visit_url("place.php?whichplace=nstower&action=ns_11_prism");
		}
		set_property("auto_disableAdventureHandling", false);
	}
	else
	{
		visit_url("place.php?whichplace=nstower&action=ns_11_prism");
	}

	if(get_property("auto_stayInRun").to_boolean())
	{
		abort("User wanted to stay in run (auto_stayInRun), we are done.");
	}

	if(my_class() == $class[Vampyre] && (0 < item_amount($item[Thwaitgold mosquito statuette])))
	{
		abort("Freeing the king will result in a path change. Enjoy your immortality.");
	}

	if(my_class() == $class[Plumber] && (0 < item_amount($item[Thwaitgold buzzy beetle statuette])))
	{
		abort("Freeing the king will lose your extra stomach space. Enjoy the rest of your video game.");
	}

	visit_url("place.php?whichplace=nstower&action=ns_11_prism");
	if(get_property("kingLiberated") == "false")
	{
		abort("Yeah, so, I'm done. You might be stuck at the shadow, or at the final boss, or just with a king in a prism. I don't know and quite frankly, after the last " + my_daycount() + " days, I don't give a damn. That's right, I said it. Bitches.");
	}
	return true;
}

boolean L13_towerNSNagamar()
{
	// the first if check will skip getting a wand if autoscend configuration says we don't want one AND you are not on step12 of the quest
	// if you are on step12 it will override the configuration and proceed to get a wand anyways
	// quest step12 means you fought the sorceress and lost due to not having a wand.
	// autoscend only reaches step12 of the quest if autoscend was incapable of acquiring a wand before the sorceress
	// it then has to fallback to bear verb orgy, which itself cannot be done until step12
	
	if (!get_property("auto_wandOfNagamar").to_boolean() && internalQuestStatus("questL13Final") != 12)
	{
		return false;
	}
	
	if(item_amount($item[Wand of Nagamar]) > 0)
	{
		set_property("auto_wandOfNagamar", false);
		return false;
	}
	
	if(in_koe() && item_amount($item[rare Meat Isotope]) >= 30)
	{
		buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Wand of Nagamar]);
		if(item_amount($item[Wand of Nagamar]) > 0)
		{
			return true;
		}
		else
		{
			auto_log_warning("Buying [Wand of Nagamar] using rare Meat Isotopes failed even thought we had 30 isotopes... trying alternatives", "red");
		}
	}
	
	if(creatable_amount($item[Wand Of Nagamar]) == 0 && (creatable_amount($item[WA]) > 0 || item_amount($item[WA]) > 0))
	{	
		pullXWhenHaveY($item[ND], 1, 0);
	}
	if(creatable_amount($item[Wand Of Nagamar]) > 0)
	{
		return create(1, $item[Wand Of Nagamar]);
	}
	
	//hunt for bear verb orgy
	if (item_amount($item[Wand of Nagamar]) == 0 && internalQuestStatus("questL13Final") == 12 && !in_koe())
	{
		return autoAdv($location[The VERY Unquiet Garves]);
	}
	
	if(auto_my_path() == "G-Lover")
	{
		pullXWhenHaveY($item[Ten-Leaf Clover], 1, 0);
	}
	else
	{
		pullXWhenHaveY($item[Disassembled Clover], 1, 0);
	}
	
	if(cloversAvailable() > 0)
	{
		cloverUsageInit();
		autoAdv($location[The Castle in the Clouds in the Sky (Basement)]);
		cloverUsageFinish();
		if(creatable_amount($item[Wand Of Nagamar]) > 0)
		{
			return create(1, $item[Wand Of Nagamar]);
		}
		else
		{
			auto_log_warning("Clovering [The Castle in the Clouds in the Sky (Basement)] for wand parts failed for some reason", "red");
		}
	}
	return false;
}