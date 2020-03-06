script "auto_mclargehuge.ash"

boolean L8_trapperStart()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 0)
	{
		return false;
	}

	auto_log_info("Let's meet the trapper.", "blue");

	visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	return true;
}

boolean L8_trapperGround()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 1)
	{
		return false;
	}

	item oreGoal = to_item(get_property("trapperOre"));

	if((item_amount(oreGoal) >= 3) && (item_amount($item[Goat Cheese]) >= 3))
	{
		auto_log_info("Giving Trapper goat cheese and " + oreGoal, "blue");
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		return true;
	}

	if(item_amount($item[Goat Cheese]) < 3)
	{
		auto_log_info("Yay for goat cheese!", "blue");
		handleFamiliar("item");
		if(get_property("_sourceTerminalDuplicateUses").to_int() == 0)
		{
			auto_sourceTerminalEducate($skill[Extract], $skill[Duplicate]);
		}
		autoAdv(1, $location[The Goatlet]);
		auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
		return true;
	}

	if(item_amount(oreGoal) >= 3)
	{
		if(item_amount($item[Goat Cheese]) >= 3)
		{
			auto_log_info("Giving Trapper goat cheese and " + oreGoal, "blue");
			visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			return true;
		}
		auto_log_info("Yay for goat cheese!", "blue");
		handleFamiliar("item");
		if(get_property("_sourceTerminalDuplicateUses").to_int() == 0)
		{
			auto_sourceTerminalEducate($skill[Extract], $skill[Duplicate]);
		}
		autoAdv(1, $location[The Goatlet]);
		auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
		return true;
	}
	else if((my_rain() > 50) && (have_effect($effect[Ultrahydrated]) == 0) && (auto_my_path() == "Heavy Rains") && have_skill($skill[Rain Man]))
	{
		auto_log_info("Trying to summon a mountain man", "blue");
		set_property("auto_mountainmen", "1");
		return rainManSummon("mountain man", false, false);
	}
	else if(auto_my_path() == "Heavy Rains")
	{
		#Do pulls instead if we don't possess rain man?
		auto_log_info("Need Ore but not enough rain", "blue");
		return false;
	}
	else if(!in_hardcore())
	{
		if(pulls_remaining() >= (3 - item_amount(oreGoal)))
		{
			pullXWhenHaveY(oreGoal, 3 - item_amount(oreGoal), item_amount(oreGoal));
			return true;
		}
	}
	else if (canGenieCombat() && (get_property("auto_useWishes").to_boolean()) && (catBurglarHeistsLeft() >= 2))
	{
		auto_log_info("Trying to wish for a mountain man, which the cat will then burgle, hopefully.");
		handleFamiliar("item");
		handleFamiliar($familiar[cat burglar]);
		return makeGenieCombat($monster[mountain man]);
	}
	else if((my_level() >= 12) && in_hardcore())
	{
		int numCloversKeep = 0;
		if(get_property("auto_wandOfNagamar").to_boolean())
		{
			numCloversKeep = 1;
			if(get_property("auto_powerLevelLastLevel").to_int() == my_level())
			{
				numCloversKeep = 0;
			}
		}
		if(auto_my_path() == "Nuclear Autumn")
		{
			if(cloversAvailable() <= numCloversKeep)
			{
				handleBarrelFullOfBarrels(false);
				string temp = visit_url("barrel.php");
				temp = visit_url("choice.php?whichchoice=1099&pwd=&option=2");
				handleBarrelFullOfBarrels(false);
				return true;
			}
		}
		if(cloversAvailable() > numCloversKeep)
		{
			cloverUsageInit();
			autoAdvBypass(270, $location[Itznotyerzitz Mine]);
			cloverUsageFinish();
			return true;
		}
	}
	return false;
}

boolean L8_trapperExtreme()
{
	if(get_property("currentExtremity").to_int() >= 3)
	{
		return false;
	}
	if (internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}
	if(get_property("_sourceTerminalDigitizeMonster") == $monster[Ninja Snowman Assassin])
	{
		return false;
	}

	//If choice 2 exists, we might want to take it, not that it is good in-run
	//What are the choices now (13/06/2018)?
	//Jar of frostigkraut:	"Dig deeper" (2?)
	//Free:	"Scram"
	//Lucky Pill:	"Look in the side Pocket"
	//set_property("choiceAdventure575", "2");

	if (possessEquipment($item[extreme mittens]) && possessEquipment($item[extreme scarf]) && possessEquipment($item[snowboarder pants]))
	{
		if (my_basestat($stat[moxie]) >= 35 && my_basestat($stat[mysticality]) >= 35 && autoOutfit("eXtreme Cold-Weather Gear"))
		{
			set_property("choiceAdventure575", "3");
			autoAdv(1, $location[The eXtreme Slope]);
			return true;
		}
		else
		{
			auto_log_warning("I can not wear the eXtreme Gear, I'm just not awesome enough :(", "red");
			return false;
		}
	}

	auto_log_info("Penguin Tony Hawk time. Extreme!! SSX Tricky!!", "blue");
	if(possessEquipment($item[extreme mittens]))
	{
		set_property("choiceAdventure15", "2");
		if(possessEquipment($item[extreme scarf]))
		{
			set_property("choiceAdventure15", "3");
		}
	}
	else
	{
		set_property("choiceAdventure15", "1");
	}

	if(possessEquipment($item[snowboarder pants]))
	{
		set_property("choiceAdventure16", "2");
		if(possessEquipment($item[extreme scarf]))
		{
			set_property("choiceAdventure16", "3");
		}
	}
	else
	{
		set_property("choiceAdventure16", "1");
	}

	if(possessEquipment($item[extreme mittens]))
	{
		set_property("choiceAdventure17", "2");
		if(possessEquipment($item[snowboarder pants]))
		{
			set_property("choiceAdventure17", "3");
		}
	}
	else
	{
		set_property("choiceAdventure17", "1");
	}

	set_property("choiceAdventure575", "1");

	autoAdv(1, $location[The eXtreme Slope]);
	return true;
}

boolean L8_trapperNinjaLair()
{
	if (internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}

	if(!have_skill($skill[Rain Man]) && (pulls_remaining() >= 3) && (internalQuestStatus("questL08Trapper") < 3))
	{
		foreach it in $items[Ninja Carabiner, Ninja Crampons, Ninja Rope]
		{
			pullXWhenHaveY(it, 1, 0);
		}
	}

	if((item_amount($item[Ninja Rope]) >= 1) && (item_amount($item[Ninja Carabiner]) >= 1) && (item_amount($item[Ninja Crampons]) >= 1))
	{
		return false;
	}

	if(get_property("_sourceTerminalDigitizeMonster") == $monster[Ninja Snowman Assassin])
	{
		if(loopHandler("_auto_digitizeAssassinTurn", "_auto_digitizeAssassinCounter", "Potentially unable to do anything while waiting on digitized Ninja Snowman Assassin.", 10))
		{
			auto_log_info("Have a digitized Ninja Snowman Assassin, let's put off the Ninja Snowman Lair", "blue");
		}
		return false;
	}

	if(in_hardcore())
	{
		if (isActuallyEd())
		{
			if(item_amount($item[Talisman of Horus]) == 0)
			{
				return false;
			}
			if((have_effect($effect[Taunt of Horus]) == 0) && (item_amount($item[Talisman of Horus]) == 0))
			{
				return false;
			}
		}
		if((have_effect($effect[Thrice-Cursed]) > 0) || (have_effect($effect[Twice-Cursed]) > 0) || (have_effect($effect[Once-Cursed]) > 0))
		{
			return false;
		}

		handleFamiliar("item");
		asdonBuff($effect[Driving Obnoxiously]);
		if(!providePlusCombat(25))
		{
			auto_log_warning("Could not uneffect for ninja snowmen, delaying", "red");
			return false;
		}

		if (isActuallyEd() && !elementalPlanes_access($element[spooky]))
		{
			adjustEdHat("myst");
		}

		if(numeric_modifier("Combat Rate") <= 9.0)
		{
			autoEquip($slot[Back], $item[Carpe]);
		}

		if(numeric_modifier("Combat Rate") <= 0.0)
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Ninja Snowmen.", "red");
			equipBaseline();
			return false;
		}

		if(!autoAdv(1, $location[Lair of the Ninja Snowmen]))
		{
			auto_log_warning("Seems like we failed the Ninja Snowmen unlock, reverting trapper setting", "red");
		}
		return true;
	}
	return false;
}

boolean L8_trapperGroar()
{
	if (internalQuestStatus("questL08Trapper") < 2 || internalQuestStatus("questL08Trapper") > 5)
	{
		// if we haven't returned the goat cheese and ore
		// to the trapper yet, don't try to ascend the peak.
		return false;
	}

	boolean canGroar = false;

	if((item_amount($item[Ninja Rope]) >= 1) && (item_amount($item[Ninja Carabiner]) >= 1) && (item_amount($item[Ninja Crampons]) >= 1))
	{
		canGroar = true;
		//If we can not get enough cold resistance, maybe we need to do extreme path.
	}
	if((internalQuestStatus("questL08Trapper") == 2) && (get_property("currentExtremity").to_int() == 3))
	{
		// TODO: There are some reports of this breaking in TCRS, when cold-weather
		// gear is not sufficient to have 5 cold resistance. Use a maximizer statement?
		if(outfit("eXtreme Cold-Weather Gear"))
		{
			string temp = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			return true;
		}
	}
	if((internalQuestStatus("questL08Trapper") >= 3) && (get_property("currentExtremity").to_int() == 0))
	{
		canGroar = true;
	}

	// Just in case
	cli_execute("refresh quests");

	//What is our potential +Combat score.
	//TODO: Use that instead of the Avatar/Hound Dog checks.

	if(!canGroar && in_hardcore() && ((auto_my_path() == "Avatar of Sneaky Pete") || !auto_have_familiar($familiar[Jumpsuited Hound Dog]) || autoForbidFamiliarChange($familiar[Jumpsuited Hound Dog])))
	{
		if(L8_trapperExtreme())
		{
			return true;
		}
	}
	if(get_property("auto_powerLevelAdvCount").to_int() > 8)
	{
		if(L8_trapperExtreme())
		{
			return true;
		}
	}

	if((item_amount($item[Groar\'s Fur]) > 0) || (item_amount($item[Winged Yeti Fur]) > 0) || (internalQuestStatus("questL08Trapper") == 5))
	{
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		if(item_amount($item[Dense Meat Stack]) >= 5)
		{
			auto_autosell(5, $item[Dense Meat Stack]);
		}
		council();
		return true;
	}

	if(canGroar)
	{
		int [element] resGoal;
		resGoal[$element[cold]] = 5;
		// try getting resistance without equipment before bothering to change gear
		if(provideResistances(resGoal, false) || provideResistances(resGoal, true))
		{
			if (internalQuestStatus("questL08Trapper") == 2)
			{
				set_property("auto_ninjasnowmanassassin", "1");
				visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			}

			auto_log_info("Time to take out Gargle, sure, Gargle (Groar)", "blue");
			if (item_amount($item[Groar\'s Fur]) == 0 && item_amount($item[Winged Yeti Fur]) == 0)
			{
				addToMaximize("5meat");
				//If this returns false, we might have finished already, can we check this?
				autoAdv(1, $location[Mist-shrouded Peak]);
			}
			else
			{
				visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
				auto_autosell(5, $item[dense meat stack]);
				council();
			}
			return true;
		}
	}
	return false;
}
