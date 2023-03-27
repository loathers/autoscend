boolean auto_tavern()
{
	if(internalQuestStatus("questL03Rat") != 1)
	{
		return false;
	}

	string temp = visit_url("cellar.php");
	if(contains_text(temp, "You should probably talk to the bartender before you go poking around in the cellar."))
	{
		abort("Quest not yet started, talk to Bart Ender and re-run.");
	}

	auto_log_info("In the tavern! Layout: " + get_property("tavernLayout"), "blue");
	boolean [int] locations = $ints[3, 2, 1, 0, 5, 10, 15, 20, 16, 21];

	// infrequent compounding issue, reset maximizer
	resetMaximize();

	boolean maximized = false;
	// sleaze is the only one we don't care about
	if(possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
		if(contains_text(mod, "Weapon Damage Percent"))
		{
			string page = visit_url("place.php?whichplace=kgb");
			boolean flipped = false;
			if(contains_text(page, "handleup"))
			{
				page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
				flipped = true;
			}

			page = visit_url("place.php?whichplace=kgb&action=kgb_button1", false);
			page = visit_url("place.php?whichplace=kgb&action=kgb_button1", false);
			if(flipped)
			{
				page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
			}
		}
	}

	if(numeric_modifier("Hot Damage") < 20.0)
	{
		buffMaintain($effect[Pyromania], 20, 1, 1);
	}
	if(numeric_modifier("Cold Damage") < 20.0)
	{
		buffMaintain($effect[Frostbeard], 20, 1, 1);
	}
	if(numeric_modifier("Stench Damage") < 20.0)
	{
		buffMaintain($effect[Rotten Memories], 20, 1, 1);
	}
	if(numeric_modifier("Spooky Damage") < 20.0)
	{
		if(auto_have_skill($skill[Intimidating Mien]))
		{
			buffMaintain($effect[Intimidating Mien], 20, 1, 1);
		}
		else
		{
			buffMaintain($effect[Dirge of Dreadfulness (Remastered)]);
			buffMaintain($effect[Dirge of Dreadfulness], 20, 1, 1);
			buffMaintain($effect[Snarl of Three Timberwolves]);
			buffMaintain($effect[Snarl of the Timberwolf], 20, 1, 1);
		}
	}

	if(!isActuallyEd() && monster_level_adjustment() <= 299)
	{
		auto_MaxMLToCap(auto_convertDesiredML(150), true);
	}
	else
	{
		auto_MaxMLToCap(auto_convertDesiredML(150), false);
	}

	foreach element_type in $strings[Hot, Cold, Stench, Sleaze, Spooky]
	{
		if(numeric_modifier(element_type + " Damage") < 20.0)
		{
			if(in_glover() && element_type != "Stench") // the only one that works in g-lover
			{
				continue;
			}
			auto_beachCombHead(element_type);
		}
	}

	if(!maximized)
	{
		// Tails are a better time saving investment. Add -combat to ensure sim and real maximizer results match
		simMaximizeWith("80cold damage 20max,80hot damage 20max,80spooky damage 20max,80stench damage 20max,500ml " + auto_convertDesiredML(150) + "max,-200combat 25max");
		maximized = true;
	}
	int [string] eleChoiceCombos =
	{
		"Cold": 513,
		"Hot": 496,
		"Spooky": 515,
		"Stench": 514
	};
	int capped = 0;
	foreach ele, choicenum in eleChoiceCombos
	{
		boolean passed = simValue(ele + " Damage") >= 20.0;
		set_property("choiceAdventure" + choicenum, passed ? "2" : "1");
		if(passed)
		{
			++capped;
			//adding a 20min argument does not yield better combinations nor avoid giving value to failed elements
			addToMaximize("80" + ele + " Damage 20max");	//only give value to elements that will pass
		}
	}
	addToMaximize("500ml " + auto_convertDesiredML(150) + "max");
	
	if(capped >= 3)
	{
		providePlusNonCombat(25, $location[Noob Cave]);
	}
	else
	{
		providePlusCombat(25, $location[Noob Cave]);
	}

	string tavern = get_property("tavernLayout");
	if(tavern == "0000000000000000000000000")
	{
		// visit cellar then refresh layout property
		string temp = visit_url("cellar.php");
		tavern = get_property("tavernLayout");
		if(tavern == "0000000000000000000000000")
		{
			abort("Invalid Tavern Configuration, could not visit cellar and repair. Uh oh...");
		}
	}

	foreach loc in locations
	{
		if(char_at(tavern, loc) == "0")
		{
			int actual = loc + 1;
			boolean needReset = false;

			if(autoAdvBypass("cellar.php?action=explore&whichspot=" + actual, $location[The Typical Tavern Cellar]))
			{
				return true;
			}

			string page = visit_url("main.php");
			if(contains_text(page, "You've already explored that spot."))
			{
				needReset = true;
				auto_log_warning("tavernLayout is not reporting places we've been to.", "red");
			}
			if(contains_text(page, "Darkness (5,5)"))
			{
				needReset = true;
				auto_log_warning("tavernLayout is reporting too many places as visited.", "red");
			}

			if(contains_text(page, "whichchoice value=") || contains_text(page, "whichchoice="))
			{
				auto_log_warning("Tavern handler: You are RL drunk, you should not be here.", "red");
				autoAdv(1, $location[Noob Cave]);
			}
			if(last_monster() == $monster[Crate])
			{
				if(get_property("auto_newbieOverride").to_boolean())
				{
					set_property("auto_newbieOverride", false);
				}
				else
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}
			}
			if(get_property("lastEncounter") == "Like a Bat Into Hell")
			{
				abort("Got stuck undying while trying to do the tavern. Must handle manualy and then resume.");
			}

			if(needReset)
			{
				auto_log_warning("We attempted a tavern adventure but the tavern layout was not maintained properly.", "red");
				auto_log_warning("Attempting to reset this issue...", "red");
				set_property("tavernLayout", "0000100000000000000000000");
				visit_url("cellar.php");
			}
			return true;
		}
	}
	auto_log_warning("We found no valid location to tavern, something went wrong...", "red");
	auto_log_warning("Attempting to reset this issue...", "red");
	set_property("tavernLayout", "0000100000000000000000000");
	wait(5);
	return true;
}

boolean L3_tavern()
{
	if(internalQuestStatus("questL03Rat") < 0 || internalQuestStatus("questL03Rat") > 2)
	{
		return false;
	}

	if(internalQuestStatus("questL03Rat") < 1)
	{
		visit_url("tavern.php?place=barkeep");
	}

	int mpNeed = 0;
	if(have_skill($skill[The Sonata of Sneakiness]) && (have_effect($effect[The Sonata of Sneakiness]) == 0))
	{
		mpNeed = mpNeed + 20;
	}
	if(have_skill($skill[Smooth Movement]) && (have_effect($effect[Smooth Movements]) == 0))
	{
		mpNeed = mpNeed + 10;
	}

	boolean enoughElement = (numeric_modifier("cold damage") >= 20) && (numeric_modifier("hot damage") >= 20) && (numeric_modifier("spooky damage") >= 20) && (numeric_modifier("stench damage") >= 20);

	boolean delayTavern = false;

	if(!enoughElement || (my_mp() < mpNeed))
	{
		if((my_daycount() <= 2) && (my_level() <= 11))
		{
			delayTavern = true;
		}
	}

	if(isAboutToPowerlevel())
	{
		delayTavern = false;
	}

	if(get_property("auto_forceTavern").to_boolean())
	{
		delayTavern = false;
	}

	if(delayTavern)
	{
		return false;
	}

	auto_log_info("Doing Tavern", "blue");

	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}

	auto_setMCDToCap();

	if(auto_tavern())
	{
		return true;
	}

	if(internalQuestStatus("questL03Rat") > 1)
	{
		visit_url("tavern.php?place=barkeep");
		council();
		return true;
	}
	return false;
}
