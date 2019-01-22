script "cc_bondmember.ash"

void bond_initializeSettings()
{
	if(my_path() == "License to Adventure")
	{
		set_property("cc_100familiar", $familiar[Egg Benedict]);
		set_property("cc_getBeehive", true);
		set_property("cc_cubeItems", true);
		set_property("cc_getStarKey", true);
		set_property("cc_grimstoneOrnateDowsingRod", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_useCubeling", true);
		set_property("cc_wandOfNagamar", false);
		set_property("choiceAdventure1258", 2);
		set_property("choiceAdventure1261", 1);
		set_property("cc_familiarChoice", "");
	}
	else
	{
		return;
	}

	if(get_property("cc_dickstab").to_boolean())
	{
		int have = item_amount($item[Improved Martini]) + item_amount($item[Splendid Martini]);
		if((my_inebriety() == 0) && (have == 0))
		{
			if(storage_amount($item[Improved Martini]) >= 10)
			{
				pullXWhenHaveY($item[Improved Martini], 10, 0);
				pullXWhenHaveY($item[Splendid Martini], 3, 0);
			}
			else
			{
				pullXWhenHaveY($item[Splendid Martini], 13, 0);
			}
		}
		pullXWhenHaveY($item[The Crown of Ed the Undying], 1, 0);
		pullXWhenHaveY($item[Infinite BACON Machine], 1, 0);
		pullXWhenHaveY($item[Stuffed Shoulder Parrot], 1, 0);
		pullXWhenHaveY($item[Eyepatch], 1, 0);
		pullXWhenHaveY($item[Swashbuckling Pants], 1, 0);
		pullXWhenHaveY($item[Gravy Boat], 1, 0);
		pullXWhenHaveY($item[Blackberry Galoshes], 1, 0);
		bond_buySkills();
		if(get_property("_deckCardsDrawn").to_int() == 0)
		{
			deck_cheat("tower");
			deck_cheat("mine");
			deck_cheat("sheep");
		}
		kgbSetup();
		if((item_amount($item[Infinite BACON Machine]) > 0) && !get_property("_baconMachineUsed").to_boolean())
		{
			use(1, $item[Infinite BACON Machine]);
		}
		if(!get_property("_internetViralVideoBought").to_boolean() && (item_amount($item[BACON]) >= 20))
		{
			cli_execute("make 1 " + $item[Viral Video]);
		}
		if(!get_property("_pottedTeaTreeUsed").to_boolean() && (cc_get_campground() contains $item[Potted Tea Tree]))
		{
			cli_execute("teatree " + $item[Cuppa Sobrie Tea]);
		}
		if(equipped_item($slot[Hat]) != $item[The Crown of Ed the Undying])
		{
			equip($slot[Hat], $item[The Crown of Ed the Undying]);
			adjustEdHat("weasel");
		}
		if(get_property("_universeCalculated").to_int() == 0)
		{
			while((my_mp() < 150) && (my_maxmp() >= 150) && (my_adventures() > 0))
			{
				doRest();
			}
			doNumberology("battlefield");
		}
		adjustEdHat("hyena");
	}
}

boolean bond_initializeDay(int day)
{
	if(my_path() != "License to Adventure")
	{
		return false;
	}
	if(day == 2)
	{
		if(get_property("cc_dickstab").to_boolean())
		{
			if(chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			if(possessEquipment($item[Kremlin\'s Greatest Briefcase]))
			{
				string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
				if(contains_text(mod, "Adventures"))
				{
					string page = visit_url("place.php?whichplace=kgb");
					boolean flipped = false;
					if(contains_text(page, "handleup"))
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handleup", false);
						flipped = true;
					}

					page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
					page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
					if(flipped)
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
					}
				}
			}

			if(item_amount($item[Hacked Gibson]) > 0)
			{
				put_closet(item_amount($item[Hacked Gibson]), $item[Hacked Gibson]);
			}
			if(get_property("_deckCardsDrawn").to_int() == 0)
			{
				deck_cheat("tower");
				deck_cheat("mine");
			}
			if(!get_property("_cc_kgbSetup").to_boolean())
			{
				set_property("_cc_kgbSetup", true);
				kgb_getMartini();
			}
			int have = item_amount($item[Improved Martini]) + item_amount($item[Splendid Martini]);
			if((my_inebriety() == 0) && (have <= 3))
			{
				if(storage_amount($item[Improved Martini]) < 13)
				{
					pullXWhenHaveY($item[Splendid Martini], 13, 3);
				}
				else
				{
					pullXWhenHaveY($item[Improved Martini], 13, 0);
				}
			}
			if((item_amount($item[Infinite BACON Machine]) > 0) && !get_property("_baconMachineUsed").to_boolean())
			{
				use(1, $item[Infinite BACON Machine]);
			}

			if(!get_property("_internetDailyDungeonMalwareBought").to_boolean() && (item_amount($item[BACON]) >= 150))
			{
				cli_execute("make 1 " + $item[Daily Dungeon Malware]);
			}
			if(!get_property("_internetViralVideoBought").to_boolean() && (item_amount($item[BACON]) >= 20))
			{
				cli_execute("make 1 " + $item[Viral Video]);
			}
			if(!get_property("_pottedTeaTreeUsed").to_boolean() && (cc_get_campground() contains $item[Potted Tea Tree]))
			{
				cli_execute("teatree " + $item[Cuppa Sobrie Tea]);
			}
			L8_trapperGround();
			//Digitize a blooper? Time spin it?
			equipBaseline();

			if(get_property("cc_dickstab").to_boolean() && !possessEquipment($item[Dented Scepter]) && is_unrestricted($item[Witchess Set]) && get_property("lovebugsUnlocked").to_boolean() && possessEquipment($item[Your Cowboy Boots]) && have_skills($skills[Curse of Weaksauce, Shell Up, Lunging Thrust-Smack, Sauceshell, Itchy Curse Finger]) && is_unrestricted($item[Source Terminal]) && (cc_get_campground() contains $item[Witchess Set]) && (cc_get_campground() contains $item[Source Terminal]) && (get_property("_witchessFights").to_int() < 5))
			{
				cc_sourceTerminalEducate($skill[Turbo], $skill[Compress]);
				if(my_mp() < 55)
				{
					doRest();
				}
				buffMaintain($effect[Pyromania], 15, 1, 1);
				buffMaintain($effect[Frostbeard], 15, 1, 1);
				buffMaintain($effect[Power Ballad of the Arrowsmith], 5, 1, 1);
				set_property("cc_combatDirective", "start;skill weaksauce;skill cowboy kick;item time-spinner;skill love stinkbug;skill love mosquito;skill compress;skill turbo;skill shell up;skill sauceshell;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack");
				boolean retval = cc_advWitchess("king");
				set_property("cc_combatDirective", "");

				cc_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
				if(!possessEquipment($item[Dented Scepter]))
				{
					abort("Dickstab failed");
				}
			}
			cli_execute("garden pick");
			if(item_amount($item[Cornucopia]) >= 3)
			{
				use(3, $item[Cornucopia]);
				cli_execute("make 3 " + $item[Stuffing Fluffer]);
				if(get_property("nsChallenge2") == $element[sleaze])
				{
					cli_execute("make 1 " + $item[Glass Casserole Dish]);
				}
			}
			set_property("_cc_bondBriefing", "started");

		}
	}
	return false;
}

boolean bond_buySkills()
{
	if(my_path() != "License to Adventure")
	{
		return false;
	}
	string page = visit_url("place.php?whichplace=town_right&action=town_bondhq", false);
	matcher bondPoints = create_matcher("You have (\\d+) pound", page);
	int points = 0;
	if(bondPoints.find())
	{
		points = to_int(bondPoints.group(1));
		print("Found " + points + " pound(s) of social capital husks.", "green");
	}

	while(points > 0)
	{
		int start = points;
		if(!get_property("bondSymbols").to_boolean())
		{
			if(points >= 3)
			{
				print("Getting bondSymbols", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=10&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondJetpack").to_boolean())
		{
			if(points >= 3)
			{
				print("Getting bondJetpack", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=12&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondDrunk2").to_boolean())
		{
			if(points >= 3)
			{
				print("Getting bondDrunk2", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=11&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondDrunk1").to_boolean())
		{
			if(points >= 2)
			{
				print("Getting bondDrunk1", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=8&w=s");
				points -= 2;
			}
		}
		else if(!get_property("bondMartiniPlus").to_boolean())
		{
			if(points >= 3)
			{
				print("Getting bondMartiniPlus", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=13&w=p");
				points -= 3;
			}
		}
		else if(!get_property("bondMartiniTurn").to_boolean())
		{
			if(points >= 1)
			{
				print("Getting bondMartiniTurn", "blue");
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
		else if(!get_property("bondBridge").to_boolean() && (get_property("chasmBridgeProgress").to_int() < 28))
		{
			if(points >= 3)
			{
				print("Getting bondBridge", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=14&w=s");
				points -= 3;
			}
		}
		else if(!get_property("bondSpleen").to_boolean() && ((item_amount($item[Astral Energy Drink]) >= 1) || (item_amount($item[Carton Of Astral Energy Drinks]) > 0)))
		{
			if(points >= 4)
			{
				print("Getting bondSpleen", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=17&w=s");
				points -= 4;
			}
		}
		else if(!get_property("bondDesert").to_boolean() && (get_property("desertExploration").to_int() < 100))
		{
			if(points >= 5)
			{
				print("Getting bondDesert", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=18&w=s");
				points -= 5;
			}
		}
		else if(!get_property("bondMeat").to_boolean())
		{
			if(points >= 1)
			{
				print("Getting bondMeat", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=2&w=p");
				points -= 1;
			}
		}
		else if(!get_property("bondItem1").to_boolean())
		{
			if(points >= 1)
			{
				print("Getting bondItem1", "blue");
				page = visit_url("choice.php?whichchoice=1259&pwd=&option=1&k=3&w=p");
				points -= 1;
			}
		}
		else if(!get_property("bondItem2").to_boolean())
		{
			if(points >= 2)
			{
				print("Getting bondItem2", "blue");
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
	if(my_path() != "License to Adventure")
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
		set_property("_cc_bondBriefing", "started");
	}

	if((get_property("_cc_bondBriefing") == "started") && (get_property("_villainLairProgress").to_int() >= 999))
	{
		set_property("_cc_bondBriefing", "finished");
	}

	if(get_property("_cc_bondBriefing") == "started")
	{
		if(get_property("cc_dickstab").to_boolean() && !possessEquipment($item[Dented Scepter]) && is_unrestricted($item[Witchess Set]) && get_property("lovebugsUnlocked").to_boolean() && possessEquipment($item[Your Cowboy Boots]) && have_skills($skills[Curse of Weaksauce, Shell Up, Lunging Thrust-Smack, Sauceshell, Itchy Curse Finger]) && is_unrestricted($item[Source Terminal]) && (cc_get_campground() contains $item[Witchess Set]) && (cc_get_campground() contains $item[Source Terminal]) && (get_property("_witchessFights").to_int() < 5))
		{
			cc_sourceTerminalEducate($skill[Turbo], $skill[Compress]);
			if(my_mp() < 55)
			{
				doRest();
			}
			buffMaintain($effect[Pyromania], 15, 1, 1);
			buffMaintain($effect[Frostbeard], 15, 1, 1);
			buffMaintain($effect[Power Ballad of the Arrowsmith], 5, 1, 1);
			set_property("cc_combatDirective", "start;skill weaksauce;skill cowboy kick;item time-spinner;skill love stinkbug;skill love mosquito;skill compress;skill turbo;skill shell up;skill sauceshell;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack;skill lunging thrust-smack");
			boolean retval = cc_advWitchess("king");
			set_property("cc_combatDirective", "");

			cc_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
			if(!possessEquipment($item[Dented Scepter]))
			{
				abort("Dickstab failed");
			}
			return retval;
		}

		if(my_meat() < 1000)
		{
			set_property("choiceAdventure1261", 4);
		}
		else
		{
			set_property("choiceAdventure1261", 1);
		}
		boolean retval = ccAdv($location[Super Villain\'s Lair]);
		if(!retval)
		{
			set_property("_cc_bondBriefing", "finished");
			bond_buySkills();
		}
		return retval;
	}

	if(get_property("_cc_bondLevel").to_int() < my_level())
	{
		set_property("_cc_bondLevel", my_level());
		bond_buySkills();
	}

	if(get_property("cc_dickstab").to_boolean())
	{
		if((inebriety_left() == 0) && (my_adventures() <= 2) && (my_daycount() == 1))
		{
			if(item_amount($item[Disposable Instant Camera]) == 0)
			{
				print("Can you time spin an Animated Ornate Nightstand?", "red");
			}
			if(item_amount($item[Knob Goblin Firecracker]) == 0)
			{
				print("Can you time spin a Sub-Assistant Knob Mad Scientist?", "red");
			}
			if(item_amount($item[Knob Goblin Harem Veil]) == 0)
			{
				print("Can you YR (or equivalent) a Knob Goblin Harem Girl?", "red");
			}
		}

		if((internalQuestStatus("questL12War") >= 1) && (item_amount($item[Stuffing Fluffer]) == 3))
		{
			use(3, $item[Stuffing Fluffer]);
		}
		if((get_property("_cc_bondBriefing") == "finished") && get_property("gingerbreadCityAvailable").to_boolean() && (get_property("_gingerbreadCityTurns").to_int() < 5))
		{
			if(!get_property("_gingerbreadClockAdvanced").to_boolean())
			{
				if((item_amount($item[Greek Fire]) >= 4) && (have_effect($effect[Sweetbreads Flamb&eacute;]) == 0))
				{
					use(3, $item[Greek Fire]);
				}
				string old = get_property("choiceAdventure1215");
				set_property("choiceAdventure1215", 1);
				ccAdv($location[Gingerbread Civic Center]);
				set_property("choiceAdventure1215", old);
				return true;
			}
			if(get_property("_gingerbreadCityTurns").to_int() < 4)
			{
				return ccAdV($location[Gingerbread Upscale Retail District]);
			}
			if(get_property("_gingerbreadCityTurns").to_int() == 4)
			{
				string old = get_property("choiceAdventure1204");
				set_property("choiceAdventure1204", 1);
				ccAdv($location[Gingerbread Train Station]);
				set_property("choiceAdventure1204", old);
				if(item_amount($item[Ultra Mega Sour Ball]) > 0)
				{
					put_closet(item_amount($item[Ultra Mega Sour Ball]), $item[Ultra Mega Sour Ball]);
				}
				return true;
			}
			abort("Gingerdickstab error");
		}

		if(get_property("_cc_bondBriefing") == "finished")
		{
			if(my_daycount() == 1)
			{
				if((my_level() > 8) && (my_adventures() < 10) && (my_mp() <= 60) && (inebriety_left() > 0))
				{
					acquireMP(61, true);
				}
			}

			if(get_property("lastDesertUnlock").to_int() < my_ascensions())
			{
				if(my_meat() > 5000)
				{
					return LX_bitchinMeatcar();
				}
			}
			else if(!possessEquipment($item[Antique Accordion]))
			{
				if(my_meat() > 6000)
				{
					buyUpTo(1, $item[Antique Accordion]);
				}
			}
			else if((my_mp() > 60) && (my_level() > 8) && (my_adventures() < 10))
			{
				if((inebriety_left() < 3) && (inebriety_left() >= 1))
				{
					buffMaintain($effect[Ode to Booze], 50, 1, inebriety_left());
					if(item_amount($item[Splendid Martini]) >= inebriety_left())
					{
						ccDrink(inebriety_left(), $item[Splendid Martini]);
					}
					else
					{
						ccDrink(inebriety_left(), $item[Improved Martini]);
					}
				}
			}
			else if((my_mp() > 60) && (my_level() > 6) && (my_adventures() < 10))
			{
				if(inebriety_left() >= 10)
				{
					buffMaintain($effect[Ode to Booze], 50, 1, 10);
					if(item_amount($item[Splendid Martini]) >= 10)
					{
						ccDrink(10, $item[Splendid Martini]);
					}
					else
					{
						ccDrink(10, $item[Improved Martini]);
					}
				}
				else if(inebriety_left() >= 3)
				{
					buffMaintain($effect[Ode to Booze], 50, 1, 3);
					if(item_amount($item[Splendid Martini]) >= 3)
					{
						ccDrink(3, $item[Splendid Martini]);
					}
					else
					{
						ccDrink(3, $item[Improved Martini]);
					}
				}
			}
		}

		if((internalQuestStatus("questL08Trapper") < 2) && (my_level() >= 8))
		{
			if(item_amount($item[Goat Cheese]) == 0)
			{
				L8_trapperStart();
				set_property("cc_combatDirective", "start;(olfaction)");
				if((get_property("_kgbTranquilizerDartUses").to_int() < 3) && (item_amount($item[Kremlin\'s Greatest Briefcase]) > 0))
				{
					equip($slot[acc3], $item[Kremlin\'s Greatest Briefcase]);
				}
				if(L8_trapperGround())
				{
					set_property("cc_combatDirective", "");
					return true;
				}
				set_property("cc_combatDirective", "");
			}
			else if(item_amount($item[Goat Cheese]) == 2)
			{
				cc_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
				return timeSpinnerCombat($monster[Dairy Goat]);
			}
			else if(item_amount(to_item(get_property("trapperOre"))) == 1)
			{
				while(acquireHermitItem($item[Ten-Leaf Clover]));
				use(1, $item[Disassembled Clover]);
				backupSetting("cloverProtectActive", false);
				ccAdvBypass(270, $location[Itznotyerzitz Mine]);
				restoreSetting("cloverProtectActive");
				return true;
			}
			else if(item_amount(to_item(get_property("trapperOre"))) == 3)
			{
				return L8_trapperGround();
			}
		}
		if(my_level() >= 9)
		{
			if(my_daycount() == 1)
			{
				if((item_amount($item[Victor\'s Spoils]) > 0) && !get_property("_victorSpoilsUsed").to_boolean())
				{
					use(1, $item[Victor\'s Spoils]);
				}
				if(LX_freeCombats())
				{
					return true;
				}
			}
			else
			{
				if((item_amount($item[Victor\'s Spoils]) > 0) && !get_property("_victorSpoilsUsed").to_boolean())
				{
					use(1, $item[Victor\'s Spoils]);
				}
			}
		}
		if(get_property("questM20Necklace") == "finished")
		{
			if(get_property("_sourceTerminalDigitizeMonster") == $monster[Writing Desk])
			{
				if((get_property("_sourceTerminalDigitizeUses").to_int() == 1) && (item_amount($item[White Pixel]) < 30) && (item_amount($item[Richard\'s Star Key]) == 0) && !contains_text(get_property("nsTowerDoorKeysUsed"), $item[Richard\'s Star Key]))
				{
					woods_questStart();
					equip($slot[acc2], $item[Continuum Transfunctioner]);
					cc_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
					set_property("cc_digitizeDirective", $monster[Blooper]);
					ccAdv(1, $location[8-bit Realm]);
					set_property("cc_digitizeDirective", "");
					return true;
				}
			}
		}

		if(get_property("sidequestLighthouseCompleted") != "none")
		{
			if(get_property("_sourceTerminalDigitizeMonster") == $monster[Lobsterfrogman])
			{
				if((get_property("_sourceTerminalDigitizeUses").to_int() == 1) && (get_property("_timeSpinnerMinutesUsed").to_int() < 7) && (item_amount($item[White Pixel]) < 30) && (item_amount($item[Richard\'s Star Key]) == 0) && !contains_text(get_property("nsTowerDoorKeysUsed"), $item[Richard\'s Star Key]))
				{
					cc_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
					set_property("cc_combatDirective", "start;skill digitize");
					timeSpinnerCombat($monster[Blooper]);
					set_property("cc_combatDirective", "");
					return true;
				}
			}
		}

		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none"))
		{
			if((item_amount($item[Filthworm Royal Guard Scent Gland]) == 0) && (item_amount($item[Heart Of The Filthworm Queen]) == 0) && canYellowRay())
			{
				while((get_property("timesRested").to_int() < total_free_rests()) && (my_mp() < mp_cost($skill[Disintegrate])))
				{
					doRest();
				}
				location loc = $location[The Hatching Chamber];
				if(item_amount($item[Filthworm Hatchling Scent Gland]) > 0)
				{
					use(1, $item[Filthworm Hatchling Scent Gland]);
					loc = $location[The Feeding Chamber];
				}
				else if(item_amount($item[Filthworm Drone Scent Gland]) > 0)
				{
					use(1, $item[Filthworm Drone Scent Gland]);
					loc = $location[The Royal Guard Chamber];
				}
				else if(have_effect($effect[Filthworm Drone Stench]) > 0)
				{
					loc = $location[The Royal Guard Chamber];
				}
				else if(have_effect($effect[Filthworm Larva Stench]) > 0)
				{
					loc = $location[The Feeding Chamber];
				}

				if(!acquireMP(150, true))
				{
					abort("Can not restore MP in order to disintegrate a filthworm. Please YR the filthworm we can access next. Thank you.");
				}
				set_property("cc_combatDirective", "start;" + yellowRayCombatString());
				boolean retval = ccAdv(loc);
				set_property("cc_combatDirective", "");
				return retval;
			}
		}


		if(my_level() >= 10)
		{
			if(!get_property("_incredibleSelfEsteemCast").to_boolean() && (my_mp() > 20) && have_skill($skill[Incredible Self-Esteem]))
			{
				use_skill(1, $skill[Incredible Self-Esteem]);
			}
			if(L10_airship() || L10_basement() || L10_ground())
			{
				return true;
			}
			if(possessEquipment($item[Mohawk Wig]))
			{
				if(L10_topFloor())
				{
					return true;
				}
			}
			if(!get_property("cc_getStarKey").to_boolean())
			{
				if((item_amount($item[Richard\'s Star Key]) == 0) && !contains_text(get_property("nsTowerDoorKeysUsed"), $item[Richard\'s Star Key]))
				{
					if(item_amount($item[Star Chart]) == 0)
					{
						return ccAdv($location[The Hole In The Sky]);
					}
				}
			}
		}

		if(get_property("middleChamberUnlock").to_boolean() && (get_property("_kgbClicksUsed").to_int() <= 10) && possessEquipment($item[Kremlin\'s Greatest Briefcase]))
		{
			string temp = visit_url("place.php?whichplace=kgb&action=kgb_tab1", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab2", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab3", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab4", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab5", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab6", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab1", false);
			temp = visit_url("place.php?whichplace=kgb&action=kgb_tab2", false);
			asdonBuff($effect[Driving Observantly]);
		}

		if(internalQuestStatus("questM21Dance") >= 4)
		{
			if((get_property("cc_swordfish") != "finished") && (item_amount($item[Disposable Instant Camera]) == 0))
			{
				if(contains_text($location[The Haunted Bedroom], $monster[Animated Ornate Nightstand]))
				{
					set_property("choiceAdventure878", 4);
					set_property("cc_disableAdventureHandling", true);
					timeSpinnerCombat($monster[Animated Ornate Nightstand]);
					if(contains_text(visit_url("main.php"), "choice.php"))
					{
						ccAdv($location[The Haunted Bedroom]);
					}
					if(contains_text(visit_url("main.php"), "Combat"))
					{
						ccAdv($location[The Haunted Bedroom]);
					}
					set_property("cc_disableAdventureHandling", false);
				}
			}
		}
		if(my_daycount() == 1)
		{
			if(((my_inebriety() == 16) && (spleen_left() < 8) && (my_adventures() < 4)) || (get_property("cc_gaudy") == "start"))
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
					page = visit_url("place.php?whichplace=kgb&action=kgb_button5", false);
					if(flipped)
					{
						page = visit_url("place.php?whichplace=kgb&action=kgb_handledown", false);
					}
				}
				else if(contains_text(mod, "Adventures") && (get_property("_kgbClicksUsed").to_int() <= 22))
				{
					string temp = visit_url("place.php?whichplace=kgb&action=kgb_tab1", false);
					temp = visit_url("place.php?whichplace=kgb&action=kgb_tab2", false);
					temp = visit_url("place.php?whichplace=kgb&action=kgb_tab3", false);
					temp = visit_url("place.php?whichplace=kgb&action=kgb_tab4", false);
				}

				if(!have_outfit("Knob Goblin Harem Girl Disguise"))
				{
					while((my_mp() < 160) && (get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
					{
						doRest();
					}
					if(!acquireMP(160, true))
					{
						abort("Can not restore MP for a Harem Girl disintegrate. Her whorish ways shall continue unabated!");
					}

					set_property("cc_disableAdventureHandling", true);
					boolean result = L5_haremOutfit();
					set_property("cc_disableAdventureHandling", false);
					if(!result)
					{
						abort("Some restrictive event is preventing us from going to the Harem. This is serious. You might have an STD. Please report this.");
					}
					return result;
				}
				if((item_amount($item[Disposable Instant Camera]) == 0) && (get_property("_timeSpinnerMinutesUsed").to_int() <= 7))
				{
					if(contains_text($location[The Haunted Bedroom].combat_queue, $monster[Animated Ornate Nightstand]))
					{
						set_property("choiceAdventure878", "4");
						set_property("cc_disableAdventureHandling", true);
						boolean result = timeSpinnerCombat($monster[Animated Ornate Nightstand]);
						set_property("cc_disableAdventureHandling", false);
						string page = visit_url("main.php");
						page = run_choice(4);
						return result;
					}
				}
				if((item_amount($item[Knob Goblin Firecracker]) == 0) && (get_property("_timeSpinnerMinutesUsed").to_int() <= 7))
				{
					if(contains_text($location[The Outskirts of Cobb\'s Knob].combat_queue, $monster[Sub-Assistant Knob Mad Scientist]))
					{
						return timeSpinnerCombat($monster[Sub-Assistant Knob Mad Scientist]);
					}
				}
			}
			if(get_property("cc_gaudy") == "start")
			{
				if((item_amount($item[Perforated Battle Paddle]) > 0) && (spleen_left() > 0))
				{
					pulverizeThing($item[Perforated Battle Paddle]);
					if((spleen_left() == 1) && (item_amount($item[Twinkly Wad]) > 0))
					{
						chew(1, $item[Twinkly Wad]);
					}
				}
				if(!have_outfit("Knob Goblin Harem Girl Disguise"))
				{
					print("Need Harem Girl Disguise", "red");
				}
				if(item_amount($item[Disposable Instant Camera]) == 0)
				{
					print("Need Disposable Instant Camera", "red");
				}
				if(item_amount($item[Knob Goblin Firecracker]) == 0)
				{
					print("Need Knob Goblin Firecracker", "red");
				}
				abort("Made it too far. Done with BondStab Day 1");

			}
		}
	}

	if(get_property("_cc_bondBriefing") == "finished")
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
