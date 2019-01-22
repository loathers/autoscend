script "cc_edTheUndying.ash"

int ed_spleen_limit()
{
	int limit = 5;
	foreach sk in $skills[Extra Spleen, Another Extra Spleen, Yet Another Extra Spleen, Still Another Extra Spleen, Just One More Extra Spleen, Okay Seriously\, This is the Last Spleen]
	{
		if(have_skill(sk))
		{
			limit += 5;
		}
	}
	if(spleen_limit() == limit)
	{
		print("Correct spleen limit obtained", "green");
	}
	else
	{
		print("Incorrect spleen limit (" + spleen_limit() + ") but actually: " + limit + " overriding.", "red");
	}
	return limit;
}

void ed_initializeSettings()
{
	if(my_path() == "Actually Ed the Undying")
	{
		set_property("cc_100familiar", $familiar[Egg Benedict]);
		set_property("cc_crackpotjar", "done");
		set_property("cc_cubeItems", false);
		set_property("cc_day1_dna", "finished");
		set_property("cc_getBeehive", false);
		set_property("cc_getStarKey", false);
		set_property("cc_grimstoneFancyOilPainting", false);
		set_property("cc_grimstoneOrnateDowsingRod", false);
		set_property("cc_holeinthesky", false);
		set_property("cc_lashes", "");
		set_property("cc_needLegs", false);
		set_property("cc_renenutet", "");
		set_property("cc_servantChoice", "");
		set_property("cc_useCubeling", false);
		set_property("cc_wandOfNagamar", false);

		set_property("cc_edSkills", -1);
		set_property("cc_chasmBusted", false);
		set_property("cc_renenutetBought", 0);

		set_property("cc_edCombatCount", 0);
		set_property("cc_edCombatRoundCount", 0);

		set_property("choiceAdventure1002", 1);
		set_property("choiceAdventure1023", "");
		set_property("desertExploration", 100);
		set_property("nsTowerDoorKeysUsed", "Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key");
	}
}

void ed_initializeSession()
{
	if(my_class() == $class[Ed])
	{
		if(get_property("hpAutoRecoveryItems") != "linen bandages")
		{
			set_property("cc_hpAutoRecoveryItems", get_property("hpAutoRecoveryItems"));
			set_property("cc_hpAutoRecovery", get_property("hpAutoRecovery"));
			set_property("cc_hpAutoRecoveryTarget", get_property("hpAutoRecoveryTarget"));
			set_property("hpAutoRecoveryItems", "linen bandages");
			set_property("hpAutoRecovery", 0.0);
			set_property("hpAutoRecoveryTarget", 0.0);
		}
	}
}

void ed_terminateSession()
{
	if(my_class() == $class[Ed])
	{
		if(get_property("hpAutoRecoveryItems") == "linen bandages")
		{
			set_property("hpAutoRecoveryItems", get_property("cc_hpAutoRecoveryItems"));
			set_property("hpAutoRecovery", get_property("cc_hpAutoRecovery"));
			set_property("hpAutoRecoveryTarget", get_property("cc_hpAutoRecoveryTarget"));
			set_property("cc_hpAutoRecoveryItems", "");
			set_property("cc_hpAutoRecovery", 0.0);
			set_property("cc_hpAutoRecoveryTarget", 0.0);
		}
	}
}

void ed_initializeDay(int day)
{
	if(my_path() != "Actually Ed the Undying")
	{
		return;
	}
	if(day == 1)
	{
		if(get_property("cc_day1_init") != "finished")
		{
			set_property("cc_renenutetBought", 0);
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}

			visit_url("tutorial.php?action=toot");
			use(item_amount($item[Letter to Ed the Undying]), $item[Letter to Ed the Undying]);
			use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
			tootGetMeat();

			equipBaseline();

			set_property("cc_day1_init", "finished");
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("cc_day2_init") == "")
		{

			if(get_property("cc_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			set_property("cc_renenutetBought", 0);
			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				acquireHermitItem($item[Seal Tooth]);
			}
			while(acquireHermitItem($item[Ten-leaf Clover]));
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);

			set_property("cc_day2_init", "finished");
		}
	}
	else if(day == 3)
	{
		if(get_property("cc_day3_init") == "")
		{
			set_property("cc_renenutetBought", 0);
			while(acquireHermitItem($item[Ten-leaf Clover]));
			set_property("cc_day3_init", "finished");
		}
	}
	else if(day == 4)
	{
		if(get_property("cc_day4_init") == "")
		{
			set_property("cc_renenutetBought", 0);
			while(acquireHermitItem($item[Ten-leaf Clover]));
			set_property("cc_day4_init", "finished");
		}
	}
}

boolean L13_ed_towerHandler()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(get_property("cc_sorceress") != "")
	{
		return false;
	}
	if(item_amount($item[Thwaitgold Scarab Beetle Statuette]) > 0)
	{
		set_property("cc_sorceress", "finished");
		council();
		return true;
	}

	council();
	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_10_sorcfight"))
	{
		print("We found the jerkwad!! Revenge!!!!!", "blue");

		string page = "place.php?whichplace=nstower&action=ns_10_sorcfight";
		ccAdvBypass(page, $location[Noob Cave]);

		if(item_amount($item[Thwaitgold Scarab Beetle Statuette]) > 0)
		{
			set_property("cc_sorceress", "finished");
			council();
		}
		return true;
	}
	else
	{
		if((get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
		{
			doRest();
			cli_execute("scripts/postcheese.ash");
			return true;
		}
		print("Please check your quests, but you might just not be at level 13 yet in order to continue.", "red");
		if((my_level() < 13) && elementalPlanes_access($element[spooky]))
		{
			boolean tryJungle = false;
			if(have_effect($effect[Jungle Juiced]) > 0)
			{
				tryJungle = true;
			}

			if(((my_inebriety() + 1) < inebriety_limit()) && (item_amount($item[Coinspiracy]) > 0) && (have_effect($effect[Jungle Juiced]) == 0))
			{
				buyUpTo(1, $item[Jungle Juice]);
				drink(1, $item[Jungle Juice]);
				tryJungle = true;
			}

			buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
			if(my_primestat() == $stat[Mysticality])
			{
				buffMaintain($effect[Perspicacious Pressure], 0, 1, 1);
				buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
				buffMaintain($effect[Erudite], 0, 1, 1);
			}

			if(tryJungle)
			{
				ccAdv(1, $location[The Deep Dark Jungle]);
			}
			else
			{
				if(item_amount($item[Personal Ventilation Unit]) > 0)
				{
					equip($slot[acc2], $item[Personal Ventilation Unit]);
				}
				ccAdv(1, $location[The Secret Government Laboratory]);
			}
			return true;
		}
		else if((my_level() < 13) && elementalPlanes_access($element[stench]))
		{
			ccAdv(1, $location[Pirates of the Garbage Barges]);
			return true;
		}
		else
		{
			print("We must be missing a sidequest. We can't find the jerk adventurer. Must pretend we are alive...", "blue");
		}
	}

	return false;
}

boolean L13_ed_councilWarehouse()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(get_property("cc_sorceress") != "finished")
	{
		return false;
	}

#	if(item_amount($item[Holy MacGuffin]) == 0)
	if(item_amount($item[7965]) == 0)
	{
		ccAdv(1, $location[The Secret Council Warehouse]);
	}
	else
	{
		//Complete: Should not get here though.
		abort("Tried to adventure in the Council Warehouse after finding theMcMuffin.");
		return false;
	}
	while((item_amount($item[Warehouse Map Page]) > 0) && (item_amount($item[Warehouse Inventory Page]) > 0))
	{
		#use(item_amount($item[Warehouse Map Page]), $item[Warehouse Map Page]);
		use(item_amount($item[Warehouse Inventory Page]), $item[Warehouse Inventory Page]);
	}
	if(get_property("lastEncounter") == "You Found It!")
	{
		council();
		print("McMuffin is found!", "blue");
		print("Ed Combats: " + get_property("cc_edCombatCount"), "blue");
		print("Ed Combat Rounds: " + get_property("cc_edCombatRoundCount"), "blue");

		return false;
	}
	return true;
}

boolean adjustEdHat(string goal)
{
	if(!possessEquipment($item[The Crown of Ed the Undying]))
	{
		return false;
	}
	int option = -1;
	goal = to_lower_case(goal);
	if(((goal == "muscle") || (goal == "bear")) && (get_property("edPiece") != "bear"))
	{
		option = 1;
	}
	else if(((goal == "myst") || (goal == "mysticality") || (goal == "owl")) && (get_property("edPiece") != "owl"))
	{
		option = 2;
	}
	else if(((goal == "moxie") || (goal == "puma")) && (get_property("edPiece") != "puma"))
	{
		option = 3;
	}
	else if(((goal == "ml") || (goal == "hyena")) && (get_property("edPiece") != "hyena"))
	{
		option = 4;
	}
	else if(((goal == "meat") || (goal == "item") || (goal == "items") || (goal == "drops") || (goal == "mouse")) && (get_property("edPiece") != "mouse"))
	{
		option = 5;
	}
	else if(((goal == "regen") || (goal == "regenerate") || (goal == "miss") || (goal == "dodge") || (goal == "weasel")) && (get_property("edPiece") != "weasel"))
	{
		option = 6;
	}
	else if(((goal == "breathe") || (goal == "underwater") || (goal == "fish")) && (get_property("edPiece") != "fish"))
	{
		option = 7;
	}

	item oldHat = equipped_item($slot[hat]);

	if(option != -1)
	{
		if(oldHat != $item[The Crown of Ed the Undying])
		{
			equip($slot[hat], $item[The Crown of Ed the Undying]);
		}
		visit_url("inventory.php?action=activateedhat");
		visit_url("choice.php?pwd=&whichchoice=1063&option=" + option, true);
		if(oldHat != $item[The Crown of Ed the Undying])
		{
			equip($slot[hat], oldHat);
		}
		return true;
	}
	return false;
}

float edMeatBonus()
{
	if(my_class() != $class[Ed])
	{
		return 0.0;
	}
	if(have_skill($skill[Curse of Fortune]) && (item_amount($item[Ka Coin]) > 0))
	{
		return 200.0;
	}
	return 0.0;
}

boolean handleServant(servant who)
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(who == $servant[none])
	{
		#use_servant($servant[none]);
		return false;
	}
	if(!have_servant(who))
	{
		return false;
	}
	if(my_servant() != who)
	{
		return use_servant(who);
	}
	return true;
}

boolean handleServant(string name)
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	name = to_lower_case(name);
	if((name == "priest") || (name == "ka"))
	{
		return handleServant($servant[Priest]);
	}
	if((name == "maid") || (name == "meat"))
	{
		return handleServant($servant[Maid]);
	}
	if((name == "belly-dancer") || (name == "belly") || (name == "dancer") || (name == "bellydancer") || (name == "pickpocket") || (name == "steal"))
	{
		return handleServant($servant[Belly-Dancer]);
	}
	if((name == "cat") || (name == "item") || (name == "itemdrop"))
	{
		return handleServant($servant[Cat]);
	}
	if((name == "bodyguard") || (name == "block"))
	{
		return handleServant($servant[Bodyguard]);
	}
	if((name == "scribe") || (name == "stats") || (name == "stat"))
	{
		return handleServant($servant[Scribe]);
	}
	if((name == "assassin") || (name == "stagger"))
	{
		return handleServant($servant[Assassin]);
	}
	if(name == "none")
	{
		return handleServant($servant[None]);
	}
	return false;
}
boolean ed_doResting()
{
	if(my_class() == $class[Ed])
	{
		int maxBuff = 675 - my_turncount();
		while((get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
		{
			doRest();
			buffMaintain($effect[Purr of the Feline], 30, 3, maxBuff);
			buffMaintain($effect[Hide of Sobek], 30, 3, maxBuff);
			buffMaintain($effect[Bounty of Renenutet], 30, 3, maxBuff);
			buffMaintain($effect[Prayer of Seshat], 15, 3, maxBuff);
			buffMaintain($effect[Wisdom of Thoth], 15, 3, maxBuff);
			buffMaintain($effect[Power of Heka], 15, 3, maxBuff);
		}
		return true;
	}
	return false;
}

boolean ed_buySkills()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(my_level() <= get_property("cc_edSkills").to_int())
	{
		return false;
	}
	int possEdPoints = 0;

	string page = visit_url("place.php?whichplace=edbase&action=edbase_book");
	matcher my_skillPoints = create_matcher("You may memorize (\\d\+) more page", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		print("Skill points found: " + skillPoints);
		possEdPoints = skillPoints - 1;
		if(have_skill($skill[Bounty of Renenutet]) && have_skill($skill[Wrath of Ra]) && have_skill($skill[Curse of Stench]))
		{
			skillPoints = 0;
		}
		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int skillid = 20;
			if(!have_skill($skill[Curse of Vacation]))
			{
				skillid = 19;
			}
			if(!have_skill($skill[Curse of Fortune]))
			{
				skillid = 18;
			}
			if(!have_skill($skill[Curse of Heredity]))
			{
				skillid = 17;
			}
			if(!have_skill($skill[Curse of Yuck]))
			{
				skillid = 16;
			}
			if(!have_skill($skill[Curse of Indecision]))
			{
				skillid = 15;
			}
			if(!have_skill($skill[Curse of the Marshmallow]))
			{
				skillid = 14;
			}
			if(!have_skill($skill[Wrath of Ra]))
			{
				skillid = 13;
			}
			if(!have_skill($skill[Bounty of Renenutet]))
			{
				skillid = 6;
			}
			if(!have_skill($skill[Shelter of Shed]))
			{
				skillid = 5;
			}
			if(!have_skill($skill[Blessing of Serqet]))
			{
				skillid = 4;
			}
			if(!have_skill($skill[Hide of Sobek]))
			{
				skillid = 3;
			}
			if(!have_skill($skill[Power of Heka]))
			{
				skillid = 2;
			}
			if(!have_skill($skill[Lash of the Cobra]))
			{
				skillid = 12;
			}
			if(!have_skill($skill[Purr of the Feline]))
			{
				skillid = 11;
			}
			if(!have_skill($skill[Storm of the Scarab]))
			{
				skillid = 10;
			}
			if(!have_skill($skill[Roar of the Lion]))
			{
				skillid = 9;
			}
			if(!have_skill($skill[Howl of the Jackal]))
			{
				skillid = 8;
			}
			if(!have_skill($skill[Wisdom of Thoth]))
			{
				skillid = 1;
			}
			if(!have_skill($skill[Fist of the Mummy]))
			{
				skillid = 7;
			}
			if(!have_skill($skill[Prayer of Seshat]))
			{
				skillid = 0;
			}

			visit_url("choice.php?pwd&skillid=" + skillid + "&option=1&whichchoice=1051");
		}
	}

	#adding this after skill purchase, is mafia not detecting our skills?
	//visit_url("charsheet.php");


	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_imbuePoints = create_matcher("Impart Wisdom unto Current Servant ..100xp, (\\d\+) remain.", page);
	int imbuePoints = 0;
	if(my_imbuePoints.find())
	{
		imbuePoints = to_int(my_imbuePoints.group(1));
		print("Imbuement points found: " + imbuePoints);
	}
	possEdPoints += imbuePoints;

	if(possEdPoints > get_property("edPoints").to_int())
	{
		set_property("edPoints", possEdPoints);
	}

	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_servantPoints = create_matcher("You may release (\\d\+) more servant", page);
	if(my_servantPoints.find())
	{
		int servantPoints = to_int(my_servantPoints.group(1));
		print("Servants points found: " + servantPoints);
		while(servantPoints > 0)
		{
			servantPoints -= 1;
			int sid = -1;
			if(!have_servant($servant[Assassin]))
			{
				sid = 7;
			}
			if(!have_servant($servant[Bodyguard]))
			{
				sid = 4;
			}
			if(!have_servant($servant[Belly-Dancer]))
			{
				sid = 2;
			}
			if(!have_servant($servant[Scribe]))
			{
				sid = 5;
			}
			if(!have_servant($servant[Maid]))
			{
				sid = 3;
				if((my_level() >= 9) && (imbuePoints > 5) && !have_servant($servant[Scribe]))
				{
					#If we are at the third servant and have enough imbues, get the Scribe instead.
					sid = 5;
				}
			}
			if(!have_servant($servant[Cat]))
			{
				sid = 1;
			}
			if(!have_servant($servant[Priest]))
			{
				sid = 6;
			}
			if(sid != -1)
			{
				visit_url("choice.php?whichchoice=1053&option=3&pwd&sid=" + sid);
			}
		}
	}

	if((imbuePoints > 0) && (my_level() >= 3))
	{
		visit_url("charsheet.php");

		servant current = my_servant();
		while(imbuePoints > 0)
		{
			servant tryImbue = $servant[none];

			if(get_property("cc_dickstab").to_boolean())
			{
				if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
				{
					tryImbue = $servant[Priest];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441))
				{
					tryImbue = $servant[Scribe];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Maid];
				}
			}
			else
			{
				if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
				{
					tryImbue = $servant[Priest];
				}
				else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 199))
				{
					tryImbue = $servant[Cat];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 199))
				{
					tryImbue = $servant[Maid];
				}
				else if(have_servant($servant[Belly-Dancer]) && ($servant[Belly-Dancer].experience < 341))
				{
					tryImbue = $servant[Belly-Dancer];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 99))
				{
					tryImbue = $servant[Scribe];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Maid];
				}
				else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Cat];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Scribe];
				}
				else
				{
					if((imbuePoints > 4) && (my_level() >= 9))
					{
						if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 341))
						{
							tryImbue = $servant[Scribe];
						}
					}
				}
			}

			if(tryImbue != $servant[none])
			{
				if(handleServant(tryImbue))
				{
					print("Trying to imbue " + tryImbue + " with glorious wisdom!!", "green");
					visit_url("choice.php?whichchoice=1053&option=5&pwd=");
				}
			}
			imbuePoints = imbuePoints - 1;
		}
		handleServant(current);
	}

	set_property("cc_edSkills", my_level());
	return true;
}

boolean ed_eatStuff()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	canEat = min(canEat, item_amount($item[Mummified Beef Haunch]));
	if(canEat > 0)
	{
		chew(canEat, $item[Mummified Beef Haunch]);
	}
	xiblaxian_makeStuff();
#	if((my_daycount() == 2) && (eudora_current() == $item[Xi Receiver Unit]) && possessEquipment($item[Xiblaxian holo-wrist-puter]) && ((my_fullness() + 4) <= fullness_limit()) && (item_amount($item[Xiblaxian Circuitry]) >= 1) && (item_amount($item[Xiblaxian Polymer]) >= 1) && (item_amount($item[Xiblaxian Alloy]) >= 3))
#	{
#		if(item_amount($item[Xiblaxian 5D Printer]) == 0)
#		{
#			if(item_amount($item[transmission from planet Xi]) > 0)
#			{
#				use(1, $item[transmission from planet xi]);
#				use(1, $item[Xiblaxian Cache Locator Simcode]);
#			}
#		}
#		if(item_amount($item[Xiblaxian 5D Printer]) > 0)
#		{
#			int[item] canMake = eudora_xiblaxian();
#			if((canMake contains $item[Xiblaxian Ultraburrito]) && (canMake[$item[Xiblaxian Ultraburrito]] > 0))
#			{
#				visit_url("shop.php?pwd=&whichshop=5dprinter&action=buyitem&quantity=1&whichrow=339", true);
#			}
#		}
#	}

	if((item_amount($item[Limp Broccoli]) > 0) && (my_level() >= 5) && ((my_fullness() == 0) || (my_fullness() == 3)) && (fullness_limit() >= 2))
	{
		ccEat(1, $item[Limp Broccoli]);
	}
	if((item_amount($item[Limp Broccoli]) > 0) && (my_level() >= 5) && (my_fullness() == 2) && (fullness_limit() >= 5) && (item_amount($item[Astral Hot Dog]) == 0))
	{
		ccEat(1, $item[Limp Broccoli]);
	}
	if((item_amount($item[Xiblaxian Ultraburrito]) > 0) && (my_fullness() == 0) && (fullness_limit() >= 4) && (item_amount($item[Astral Hot Dog]) == 0))
	{
		ccEat(1, $item[Xiblaxian Ultraburrito]);
	}
	if((my_level() >= 11) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) > 0))
	{
		ccEat(1, $item[Astral Hot Dog]);
	}
	if((my_level() >= 9) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) > 0) && (my_adventures() < 4))
	{
		ccEat(1, $item[Astral Hot Dog]);
	}
	if(!get_property("_fancyHotDogEaten").to_boolean() && (my_daycount() == 1) && (my_level() >= 9) && ((my_fullness() + 3) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) == 0) && (my_adventures() < 10) && (item_amount($item[Clan VIP Lounge Key]) > 0))
	{
		eatFancyDog("video games hot dog");
	}

	if(get_property("cc_dickstab").to_boolean() && !get_property("_fancyHotDogEaten").to_boolean() && (my_daycount() == 1) && ((my_fullness() + 2) <= fullness_limit()) && (item_amount($item[Astral Hot Dog]) == 0) && (item_amount($item[Clan VIP Lounge Key]) > 0) && chateaumantegna_available())
	{
		eatFancyDog("sleeping dog");
	}


	if((my_daycount() >= 3) && (my_inebriety() == 0) && (inebriety_limit() == 4) && (item_amount($item[Xiblaxian Space-Whiskey]) > 0) && (my_adventures() < 10))
	{
		drink(1, $item[Xiblaxian Space-Whiskey]);
	}
	if((item_amount($item[Astral Pilsner]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && (my_level() >= 11))
	{
		drink(1, $item[Astral Pilsner]);
	}
	if((item_amount($item[Astral Pilsner]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && (my_level() >= 10) && (my_adventures() < 3))
	{
		drink(1, $item[Astral Pilsner]);
	}
	if((item_amount($item[Astral Pilsner]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && (my_level() >= 9) && (my_adventures() < 3) && (my_fullness() >= fullness_limit()))
	{
		drink(1, $item[Astral Pilsner]);
	}
	if((item_amount($item[Coinspiracy]) >= 6) && ((my_inebriety() + 3) <= inebriety_limit()) && (my_adventures() < 3) && (item_amount($item[Astral Pilsner]) == 0))
	{
		buyUpTo(1, $item[Highest Bitter]);
		drink(1, $item[Highest Bitter]);
	}

	if((!contains_text(get_counters("Fortune Cookie", 0, 200), "Fortune Cookie")) && (get_property("semirareLocation") != $location[The Castle in the Clouds in the Sky (Top Floor)]))
	{
		if((item_amount($item[Clan VIP Lounge Key]) > 0) && (my_meat() >= 500) && (inebriety_limit() == 4) && ((my_inebriety() == 0) || (my_inebriety() == 3)) && (cc_get_clan_lounge() contains $item[Clan Speakeasy]))
		{
			drinkSpeakeasyDrink($item[Lucky Lindy]);
			#cli_execute("drink 1 lucky lindy");
		}
		else if((my_meat() >= npc_price($item[Fortune Cookie])) && (fullness_left() > 0) && (my_fullness() >= 4))
		{
			buyUpTo(1, $item[Fortune Cookie], npc_price($item[Fortune Cookie]));
			ccEat(1, $item[Fortune Cookie]);
		}
	}
	return true;
}

boolean ed_needShop()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}

	if(have_skill($skill[Upgraded Legs]) && get_property("cc_needLegs").to_boolean())
	{
		set_property("cc_needLegs", false);
	}

	if(get_property("cc_needLegs").to_boolean() && (item_amount($item[Ka Coin]) >= 10))
	{
		return true;
	}

#	if(!get_property("lovebugsUnlocked").to_boolean() && (item_amount($item[Ka Coin]) >= 2) && (item_amount($item[Spirit Beer]) == 0) && (ed_spleen_limit() >= 35))
	if(!get_property("lovebugsUnlocked").to_boolean() && (item_amount($item[Ka Coin]) >= 2) && (item_amount($item[Spirit Beer]) == 0) && (my_mp() < 100))
	{
		return true;
	}

	if(item_amount($item[Ka Coin]) < 15)
	{
		return false;
	}
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	canEat = max(0, canEat - item_amount($item[Mummified Beef Haunch]));

	skill limiter = $skill[Even More Elemental Wards];
	if(my_daycount() >= 2)
	{
		limiter = $skill[Healing Scarabs];
	}

#	else if(my_daycount() > 2)
#	{
#		limiter = $skill[Upgraded Spine];
#	}

	if((canEat == 0) && have_skill(limiter) && (item_amount($item[Linen Bandages]) >= 4) && (get_property("cc_renenutetBought").to_int() >= 7) && (item_amount($item[Holy Spring Water]) >= 1) && (item_amount($item[Talisman of Horus]) >= 2))
	{
		if((item_amount($item[Ka Coin]) > 30) && (item_amount($item[Spirit Beer]) == 0))
		{
			return true;
		}
		if((item_amount($item[Ka Coin]) > 35) && !have_skill($skill[Upgraded Spine]))
		{
			return true;
		}
		if(((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2) && (item_amount($item[Ka Coin]) > 30))
		{
			return true;
		}
		return false;
	}
	return true;
}


boolean ed_shopping()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(!ed_needShop())
	{
		if((my_mp() < 8) && (item_amount($item[Ka Coin]) > 0) && (item_amount($item[Holy Spring Water]) == 0))
		{
		}
		else
		{
			return false;
		}
	}
	print("Time to shop!", "red");
	wait(1);
	visit_url("choice.php?pwd=&whichchoice=1023&option=1", true);


	if(get_property("cc_breakstone").to_boolean())
	{
		string temp = visit_url("peevpee.php?action=smashstone&pwd&confirm=on", true);
		temp = visit_url("place.php?whichplace=edunder&action=edunder_hippy");
		temp = visit_url("choice.php?pwd&whichchoice=1057&option=1", true);
//		temp = visit_url("peevpee.php?place=fight");
		set_property("cc_breakstone", false);
	}

	int skillBuy = 0;
	int coins = item_amount($item[Ka Coin]);
	//Handler for low-powered accounts
	if(!have_skill($skill[Upgraded Legs]) && get_property("cc_needLegs").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			set_property("cc_needLegs", false);
			skillBuy = 36;
		}
		//Prevent other purchases from interrupting us.
		coins = 0;
	}

	//Limit mode: edunder
	int canEat = 0;
	if((my_spleen_use() + 5) <= ed_spleen_limit())
	{
		canEat = (ed_spleen_limit() - my_spleen_use()) / 5;
		canEat = canEat - item_amount($item[Mummified Beef Haunch]);
		while((coins >= 15) && (canEat > 0))
		{
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=428", true);
			print("Buying a mummified beef haunch!", "green");
			coins = coins - 15;
			canEat = canEat - 1;
		}
	}

#	if(!get_property("lovebugsUnlocked").to_boolean() && (item_amount($item[Ka Coin]) >= 2) && (item_amount($item[Spirit Beer]) == 0) && (ed_spleen_limit() >= 35))
#	if(!get_property("lovebugsUnlocked").to_boolean() && (item_amount($item[Ka Coin]) >= 2) && (item_amount($item[Spirit Beer]) == 0) && (my_mp() < 100))
	if(!get_property("lovebugsUnlocked").to_boolean() && (coins >= 2) && (item_amount($item[Holy Spring Water]) == 0) && (my_mp() < 15))
	{
#		print("Buying Spirit Beer", "green");
#		visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=432", true);
		print("Buying Holy Spring Water", "green");
		visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
		coins -= 1;
	}

	if(!have_skill($skill[Extra Spleen]) && (canEat < 1))
	{
		if(coins >= 5)
		{
			print("Buying Extra Spleen", "green");
			skillBuy = 30;
		}
	}
	else if(!have_skill($skill[Another Extra Spleen]) && (canEat < 1))
	{
		if(coins >= 10)
		{
			print("Buying Another Extra Spleen", "green");
			skillBuy = 31;
		}
	}
	else if(!have_skill($skill[Replacement Stomach]))
	{
		if(coins >= 30)
		{
			print("Buying Replacement Stomach", "green");
			skillBuy = 28;
		}
	}
	else if(!have_skill($skill[Upgraded Legs]) && !get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
		}
	}
	else if(!have_skill($skill[More Legs]) && !get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	}
	else if(!have_skill($skill[Yet Another Extra Spleen]) && have_skill($skill[Another Extra Spleen]))
	{
		if(coins >= 15)
		{
			print("Buying Yet Another Extra Spleen", "green");
			skillBuy = 32;
		}
	}
	else if(!have_skill($skill[Replacement Liver]) && get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 30)
		{
			print("Buying Replacement Liver", "green");
			skillBuy = 29;
		}
	}
	else if(!have_skill($skill[Still Another Extra Spleen]))
	{
		if(coins >= 20)
		{
			print("Buying Still Another Extra Spleen", "green");
			skillBuy = 33;
		}
	}
	else if(!have_skill($skill[Just One More Extra Spleen]))
	{
		if(coins >= 25)
		{
			print("Buying Just One More Extra Spleen", "green");
			skillBuy = 34;
		}
	}
	else if(!have_skill($skill[Replacement Liver]))
	{
		if(coins >= 30)
		{
			print("Buying Replacement Liver", "green");
			skillBuy = 29;
		}
	}
	else if(!have_skill($skill[Elemental Wards]) && !get_property("cc_dickstab").to_boolean())
	{
		if(coins >= 10)
		{
			print("Buying Elemental Wards", "green");
			skillBuy = 44;
		}
	}
	else if(!have_skill($skill[Okay Seriously, This is the Last Spleen]))
	{
		if(coins >= 30)
		{
			print("Buying Okay Seriously, This is the Last Spleen", "green");
			skillBuy = 35;
		}
	}
	else if((get_property("cc_renenutetBought").to_int() < 7) && (coins > 1))
	{
		while((get_property("cc_renenutetBought").to_int() < 7) && (coins > 1))
		{
			print("Buying Talisman of Renenutet", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
			set_property("cc_renenutetBought", 1 + get_property("cc_renenutetBought").to_int());
			coins = coins - 1;
			if(!have_skill($skill[Okay Seriously, This is the Last Spleen]))
			{
				break;
			}
		}
	}
	else if(!have_skill($skill[Upgraded Legs]))
	{
		if(coins >= 10)
		{
			print("Buying Upgraded Legs", "green");
			skillBuy = 36;
		}
	}
	else if(!possessEquipment($item[The Crown of Ed the Undying]) && !have_skill($skill[Tougher Skin]) && (coins >= 10))
	{
		print("Buying Tougher Skin (10)", "green");
		skillBuy = 39;
	}
	else if(!have_skill($skill[More Legs]))
	{
		if(coins >= 20)
		{
			print("Buying More Legs", "green");
			skillBuy = 48;
		}
	}
	else if(!have_skill($skill[Elemental Wards]))
	{
		if(coins >= 10)
		{
			print("Buying Elemental Wards", "green");
			skillBuy = 44;
		}
	}
	else if(!have_skill($skill[More Elemental Wards]))
	{
		if(coins >= 20)
		{
			print("Buying More Elemental Wards", "green");
			skillBuy = 45;
		}
	}
	else if(!have_skill($skill[Even More Elemental Wards]))
	{
		if(coins >= 30)
		{
			print("Buying Even More Elemental Wards", "green");
			skillBuy = 46;
		}
	}
	else if((!have_skill($skill[Healing Scarabs])) && (my_daycount() >= 2))
	{
		if(coins >= 10)
		{
			print("Buying Healing Scarabs", "green");
			skillBuy = 43;
		}
	}
	else if((!have_skill($skill[Arm Blade])) && (my_daycount() >= 2) && (coins >= 100))
	{
		print("Buying Arm Blade (20)", "green");
		skillBuy = 42;
	}
	else if(!have_skill($skill[Upgraded Arms]) && (my_daycount() >= 2) && (coins >= 100))
	{
		print("Buying Upgraded Arms (20)", "green");
		skillBuy = 37;
	}
	else if(!have_skill($skill[Tougher Skin]) && (my_daycount() >= 2) && (coins >= 50))
	{
		print("Buying Tougher Skin (10)", "green");
		skillBuy = 39;
	}
	else if(!have_skill($skill[Armor Plating]) && (my_daycount() >= 2) && (coins >= 50))
	{
		print("Buying Armor Plating (10)", "green");
		skillBuy = 40;
	}
	else if(!have_skill($skill[Upgraded Spine]) && (my_daycount() >= 2) && (coins >= 50))
	{
		print("Buying Upgraded Spine (20)", "green");
		skillBuy = 38;
	}
	else if(!have_skill($skill[Bone Spikes]) && (my_daycount() >= 4) && (coins >= 100))
	{
		print("Buying Bone Spikes (20)", "green");
		skillBuy = 41;
	}
	else if(have_skill($skill[Okay Seriously, This is the Last Spleen]) && (canEat < 1))
	{	//437 438?
		while((coins >= 1) && (get_property("cc_renenutetBought").to_int() < 7))
		{
			print("Buying Talisman of Renenutet", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
			set_property("cc_renenutetBought", 1 + get_property("cc_renenutetBought").to_int());
			coins = coins - 1;
		}
		while((item_amount($item[Linen Bandages]) < 4) && (coins >= 4))
		{
			print("Buying Linen Bandages", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=429", true);
			coins -= 1;
		}
		while((item_amount($item[Holy Spring Water]) < 1) && (coins >= 2))
		{
			print("Buying Holy Spring Water", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
			coins -= 1;
		}
		while((item_amount($item[Talisman of Horus]) < 3) && (coins >= 5))
		{
			print("Buying Talisman of Horus", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=693", true);
			coins -= 5;
		}
		while((item_amount($item[Spirit Beer]) == 0) && (coins >= 30))
		{
			print("Buying Spirit Beer", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=432", true);
			coins -= 2;
		}
		if(((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2) && (coins >= 30))
		{
			print("Buying Ancient Cure-all", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=435", true);
			coins -= 3;
		}
		while((item_amount($item[Holy Spring Water]) < 1) && (coins >= 1) && (my_mp() < 8))
		{
			print("Buying Holy Spring Water", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
			coins -= 1;
		}
	}


	if(skillBuy != 0)
	{
		visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
		visit_url("choice.php?pwd&skillid=" + skillBuy + "&option=1&whichchoice=1052", true);
		visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
	}
	visit_url("place.php?whichplace=edunder&action=edunder_leave");
	visit_url("choice.php?pwd=&whichchoice=1024&option=1", true);
	return true;
}

boolean ed_handleAdventureServant(int num, location loc, string option)
{
	handleServant($servant[Priest]);
	boolean reassign = false;
	if((!ed_needShop() && (my_spleen_use() == 35)) && (item_amount($item[Ka Coin]) > 15))
	{
		reassign = true;
	}
	if((my_daycount() >= 3) && (my_adventures() >= 20) && (my_level() >= 12))
	{
		reassign = true;
	}

	if(reassign)
	{
		if(!have_skill($skill[Gift of the Maid]) && have_servant($servant[Maid]) && (get_property("cc_nuns") != "finished") && (get_property("cc_nuns") != "done"))
		{
			handleServant($servant[Maid]);
		}
		else if((!have_skill($skill[Gift of the Scribe]) || (my_level() < 13)) && have_servant($servant[Scribe]))
		{
			handleServant($servant[Scribe]);
		}
		else if(!have_skill($skill[Gift of the Cat]) && have_servant($servant[Cat]))
		{
			handleServant($servant[Cat]);
		}
		else if((my_mp() < 20) && have_servant($servant[Belly-Dancer]))
		{
			handleServant($servant[Belly-Dancer]);
		}
		else
		{
			if(my_level() >= 13)
			{
				if(!handleServant($servant[Cat]))
				{
					if(!handleServant($servant[Maid]))
					{
						handleServant($servant[Scribe]);
					}
				}
			}
			else
			{
				if(!handleServant($servant[Scribe]))
				{
					if(!handleServant($servant[Cat]))
					{
						handleServant($servant[Maid]);
					}
				}
			}
		}
	}
	if(($locations[Hippy Camp, The Neverending Party, The Secret Government Laboratory, The SMOOCH Army HQ, VYKEA] contains loc) && (my_daycount() == 1))
	{
		handleServant($servant[Priest]);
	}

	if($locations[A-Boo Peak, The Defiled Nook, The Haunted Laundry Room, The Haunted Library, The Haunted Wine Cellar, The Hidden Bowling Alley, Oil Peak] contains loc)
	{
		if(!handleServant($servant[Cat]))
		{
			if(!handleServant($servant[Scribe]))
			{
				handleServant($servant[Maid]);
			}
		}
	}

	if((loc == $location[The Dark Neck of the Woods]) ||
		(loc == $location[The Dark Heart of the Woods]) ||
		(loc == $location[The Dark Elbow of the Woods]))
	{
		if((get_property("cc_pirateoutfit") != "finished") && (get_property("cc_pirateoutfit") != "almost") && (item_amount($item[Hot Wing]) < 3))
		{
			if(!handleServant($servant[Cat]))
			{
				if(!handleServant($servant[Scribe]))
				{
					handleServant($servant[Maid]);
				}
			}
		}
		else
		{
			if(!handleServant($servant[Scribe]))
			{
				if(!handleServant($servant[Cat]))
				{
					handleServant($servant[Maid]);
				}
			}
		}
	}

	if((loc == $location[The Defiled Alcove]) ||
		(loc == $location[The Defiled Cranny]) ||
		(loc == $location[The Defiled Niche]) ||
		(loc == $location[The Haunted Bedroom]) ||
		(loc == $location[The Haunted Ballroom]) ||
		(loc == $location[The Haunted Billiards Room]) ||
		(loc == $location[The Haunted Kitchen]) ||
		(loc == $location[The Haunted Bathroom]))
	{
		if(!have_skill($skill[Gift of the Maid]) && !handleServant($servant[Maid]))
		{
			if(!handleServant($servant[Scribe]))
			{
				handleServant($servant[Cat]);
			}
		}
	}

	if(loc == $location[The Themthar Hills])
	{
		handleServant($servant[Maid]);
	}

	if((loc == $location[Next To That Barrel With Something Burning In It]) ||
		(loc == $location[Out By That Rusted-Out Car]) ||
		(loc == $location[Over Where The Old Tires Are]) ||
		(loc == $location[Near an Abandoned Refrigerator]))
	{
		handleServant($servant[Cat]);
	}

	return false;
}

boolean ed_preAdv(int num, location loc, string option)
{
	ed_handleAdventureServant(num, loc, option);
	return preAdvXiblaxian(loc);
}

boolean ed_ccAdv(int num, location loc, string option, boolean skipFirstLife)
{
	if((option == "") || (option == "cc_combatHandler"))
	{
		option = "cc_edCombatHandler";
	}

	if(!skipFirstLife)
	{
		ed_preAdv(num, loc, option);
	}

	if((my_hp() == 0) || (get_property("_edDefeats").to_int() > get_property("edDefeatAbort").to_int()))
	{
		print("Defeats detected: " + get_property("_edDefeats") + ", Defeat threshold: " + get_property("edDefeatAbort"), "green");
		abort("How are you here? You can't be here. Bloody Limit Mode (probably, maybe?)!!");
	}

	boolean status = false;
	while(num > 0)
	{
		set_property("autoAbortThreshold", "-10.0");
		num = num - 1;
		if(num > 1)
		{
			print("This fight and " + num + " more left.", "blue");
		}
		cli_execute("precheese");
		set_property("cc_disableAdventureHandling", true);
		set_property("cc_edCombatHandler", "");

		if(!skipFirstLife)
		{
			set_property("cc_edCombatStage", 0);
			print("Starting Ed Battle at " + loc, "blue");
			status = adv1(loc, 0, option);
			if(!status && (get_property("lastEncounter") == "Like a Bat Into Hell"))
			{
				set_property("cc_disableAdventureHandling", false);
				abort("Either a) We had a connection problem and lost track of the battle, or we were defeated multiple times beyond our usual UNDYING. Manually handle the fight and rerun.");
			}
		}
		if(last_monster() == $monster[Crate])
		{
			abort("We went to the Noob Cave for reals... uh oh");
		}

		string page = visit_url("main.php");
		if(contains_text(page, "whichchoice value=1023"))
		{
			print("Ed has UNDYING once!" , "blue");
			if(!ed_shopping())
			{
				#If this visit_url results in the enemy dying, we don't want to continue
				visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
			}
			set_property("cc_edCombatStage", 1);
			print("Ed returning to battle Stage 1", "blue");

			if(get_property("_edDefeats").to_int() == 0)
			{
				print("Monster defeated in initialization, aborting attempt.", "red");
				set_property("cc_edCombatStage", 0);
				set_property("cc_disableAdventureHandling", false);
				cli_execute("postcheese.ash");
				return true;
			}

			#Catch if we lose the jump after first revival.
			if(get_property("_edDefeats").to_int() != 2)
			{
				status = adv1(loc, 0, option);
				if(last_monster() == $monster[Crate])
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}
			}

			page = visit_url("main.php");
			if(contains_text(page, "whichchoice value=1023"))
			{
				print("Ed has UNDYING twice! Time to kick ass!" , "blue");
				if(!ed_shopping())
				{
					#If this visit_url results in the enemy dying, we don't want to continue
					visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
				}
				set_property("cc_edCombatStage", 2);
				print("Ed returning to battle Stage 2", "blue");

				if(get_property("_edDefeats").to_int() == 0)
				{
					print("Monster defeated in initialization, aborting attempt.", "red");
					set_property("cc_edCombatStage", 0);
					set_property("cc_disableAdventureHandling", false);
					cli_execute("postcheese.ash");
					return true;
				}

				status = adv1(loc, 0, option);
				if(last_monster() == $monster[Crate])
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}
			}
		}
		set_property("cc_edCombatStage", 0);
		set_property("cc_disableAdventureHandling", false);

		if(get_property("_edDefeats").to_int() > get_property("edDefeatAbort").to_int())
		{
			abort("Manually forcing edDefeatAborts. We can't handle the battle.");
		}

		cli_execute("postcheese.ash");
	}
	return status;
}

boolean ed_ccAdv(int num, location loc, string option)
{
	return ed_ccAdv(num, loc, option, false);
}


boolean L1_ed_island()
{
	return L1_ed_island(0);
}

boolean L1_ed_dinsey()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(!elementalPlanes_access($element[stench]))
	{
		return false;
	}
	if(my_level() < 6)
	{
		return false;
	}
	if(!get_property("cc_dickstab").to_boolean())
	{
		return false;
	}
	if(possessEquipment($item[Sewage-Clogged Pistol]) && possessEquipment($item[Perfume-Soaked Bandana]))
	{
		return false;
	}
	ccAdv(1, $location[Pirates of the Garbage Barges]);
	return true;
}

boolean L1_ed_island(int dickstabOverride)
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(!elementalPlanes_access($element[spooky]))
	{
		return false;
	}

	skill blocker = $skill[Still Another Extra Spleen];
	if(get_property("cc_dickstab").to_boolean())
	{
		if(turns_played() > 22)
		{
			blocker = $skill[Replacement Liver];
			blocker = $skill[Okay Seriously, This is the Last Spleen];
			if((dickstabOverride == 0) || (my_level() >= dickstabOverride))
			{
				return false;
			}
		}
	}

	if((my_level() >= 10) || ((my_level() >= 8) && have_skill(blocker)))
	{
		return false;
	}
	if((my_level() >= 3) && (my_turncount() >= 2) && !get_property("controlPanel9").to_boolean())
	{
		visit_url("place.php?whichplace=airport_spooky_bunker&action=si_controlpanel");
		visit_url("choice.php?pwd=&whichchoice=986&option=9",true);
	}
	if((my_level() >= 3) && !get_property("controlPanel9").to_boolean() && (my_turncount() >= 2))
	{
		abort("Damn control panel is not set, WTF!!!");
	}

	#If we get some other CI quest, this might keep triggering, should we flag this?
	if((my_hp() > 20) && !possessEquipment($item[Gore Bucket]) && !possessEquipment($item[Encrypted Micro-Cassette Recorder]) && !possessEquipment($item[Military-Grade Fingernail Clippers]))
	{
		elementalPlanes_takeJob($element[spooky]);
		set_property("choiceAdventure988", 2);
	}

	if(item_amount($item[Gore Bucket]) > 0)
	{
		equip($item[Gore Bucket]);
	}

	if(item_amount($item[Personal Ventilation Unit]) > 0)
	{
		equip($slot[acc2], $item[Personal Ventilation Unit]);
	}
	if(possessEquipment($item[Gore Bucket]) && (get_property("goreCollected").to_int() >= 100))
	{
		visit_url("place.php?whichplace=airport_spooky&action=airport2_radio");
		visit_url("choice.php?pwd&whichchoice=984&option=1", true);
	}

	if((my_turncount() <= 1) && (my_meat() > 10000))
	{
		int need = min(4, (my_maxmp() - my_mp()) / 10);
		buyUpTo(need, $item[Doc Galaktik\'s Invigorating Tonic]);
		use(need, $item[Doc Galaktik\'s Invigorating Tonic]);
		cli_execute("postcheese");
	}

	buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
	ccAdv(1, $location[The Secret Government Laboratory]);
	if(item_amount($item[Bottle-Opener Keycard]) > 0)
	{
		use(1, $item[Bottle-Opener Keycard]);
	}
	set_property("choiceAdventure988", 1);
	return true;
}


boolean L1_ed_islandFallback()
{
	if(my_class() != $class[Ed])
	{
		return false;
	}
	if(elementalPlanes_access($element[spooky]))
	{
		return false;
	}

	if((my_level() >= 10) || ((my_level() >= 8) && have_skill($skill[Still Another Extra Spleen])) || ((my_level() >= 6) && have_skill($skill[Okay Seriously\, This Is The Last Spleen])))
	{
		if((spleen_left() < 5) || (my_adventures() > 10))
		{
			return false;
		}
#		if((my_daycount() > 2) || (my_spleen_use() > 20))
#		{
#			return false;
#		}
	}

	if(!get_property("lovebugsUnlocked").to_boolean())
	{
		if(my_turncount() == 0)
		{
			while((my_mp() < mp_cost($skill[Storm of the Scarab])) && (my_mp() < my_maxmp()) && (my_meat() > 1500))
			{
				buyUpTo(1, $item[Doc Galaktik\'s Invigorating Tonic], 90);
				use(1, $item[Doc Galaktik\'s Invigorating Tonic]);
			}
		}
		else if(my_turncount() == 1)
		{
			if((is_unrestricted($item[Clan Pool Table])) && (get_property("_poolGames").to_int() < 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
			{
				visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
				visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
				visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
			}
		}
	}

	if(get_property("neverendingPartyAlways").to_boolean() || get_property("_neverendingPartyToday").to_boolean())
	{
		backupSetting("choiceAdventure1322", 2);
		if(have_effect($effect[Spiced Up]) == 0)
		{
			backupSetting("choiceAdventure1324", 2);
			backupSetting("choiceAdventure1326", 2);
		}
		else
		{
			backupSetting("choiceAdventure1324", 5);
		}

		ccAdv(1, $location[The Neverending Party]);
		restoreSetting("choiceAdventure1322");
		restoreSetting("choiceAdventure1324");
		restoreSetting("choiceAdventure1326");
		return true;
	}
	if(elementalPlanes_access($element[stench]))
	{
		ccAdv(1, $location[Pirates of the Garbage Barges]);
		return true;
	}
	if(elementalPlanes_access($element[cold]))
	{
		if(get_property("_VYKEALoungeRaided").to_boolean())
		{
			if(get_property("_VYKEACafeteriaRaided").to_boolean())
			{
				set_property("choiceAdventure1115", 6);
			}
			else
			{
				set_property("choiceAdventure1115", 1);
			}
		}
		else
		{
			set_property("choiceAdventure1115", 9);
		}
		ccAdv(1, $location[VYKEA]);
		return true;
	}
	if(elementalPlanes_access($element[hot]))
	{
		//Maybe this is a good choice?
		set_property("choiceAdventure1094", 5);
		ccAdv(1, $location[The SMOOCH Army HQ]);
		set_property("choiceAdventure1094", 2);
		return true;
	}


	if(LX_islandAccess())
	{
		return true;
	}

	boolean haveLegs = have_skill($skill[Upgraded Legs]);
	#Consider trying to get Upgraded legs first

	change_mcd(max(2, my_level()-1));
	if(haveLegs)
	{
		if(have_outfit("Filthy Hippy Disguise") && is_wearing_outfit("Filthy Hippy Disguise"))
		{
			equip($slot[Pants], $item[None]);
			put_closet(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
			equipBaseline();
		}
		buffMaintain($effect[Wisdom Of Thoth], 20, 1, 1);
		return ccAdv(1, $location[Hippy Camp]);
	}
	set_property("cc_needLegs", true);
	return ccAdv(1, $location[The Outskirts of Cobb\'s Knob]);
}

boolean L9_ed_chasmStart()
{
	if((my_class() == $class[Ed]) && !get_property("cc_chasmBusted").to_boolean())
	{
		print("It's a troll on a bridge!!!!", "blue");

		string page = visit_url("place.php?whichplace=orc_chasm&action=bridge_done");
		ccAdvBypass("place.php?whichplace=orc_chasm&action=bridge_done", $location[The Smut Orc Logging Camp]);

		set_property("cc_chasmBusted", true);
		set_property("chasmBridgeProgress", 0);
		return true;
	}
	return false;
}

boolean L9_ed_chasmBuild()
{
	if((my_class() == $class[Ed]) && !get_property("cc_chasmBusted").to_boolean())
	{
		print("What a nice bridge over here...." , "green");

		string page = visit_url("place.php?whichplace=orc_chasm&action=bridge_done");
		ccAdvBypass("place.php?whichplace=orc_chasm&action=bridge_done", $location[The Smut Orc Logging Camp]);

		set_property("cc_chasmBusted", true);
		set_property("chasmBridgeProgress", 0);
		return true;
	}
	return false;
}

boolean L9_ed_chasmBuildClover(int need)
{
	if((my_class() == $class[Ed]) && (need > 3) && (item_amount($item[Disassembled Clover]) > 2))
	{
		use(1, $item[disassembled clover]);
		backupSetting("cloverProtectActive", false);
		ccAdvBypass("adventure.php?snarfblat=295", $location[The Smut Orc Logging Camp]);
		if(item_amount($item[Ten-Leaf Clover]) > 0)
		{
			print("Wandering adventure in The Smut Orc Logging Camp, boo. Gonna have to do this again.");
			use(item_amount($item[Ten-Leaf Clover]), $item[Ten-Leaf Clover]);
			restoreSetting("cloverProtectActive");
			return true;
		}
		restoreSetting("cloverProtectActive");
		visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		return true;
	}
	return false;
}

boolean L11_ed_mauriceSpookyraven()
{
	if(my_class() == $class[Ed])
	{
		if(item_amount($item[7962]) == 0)
		{
			set_property("cc_ballroom", "finished");
			return true;
		}
	}
	return false;
}

boolean LM_edTheUndying()
{
	if(my_path() != "Actually Ed the Undying")
	{
		return false;
	}

	ed_buySkills();

	if(get_property("edPiece") != "hyena")
	{
		if(elementalPlanes_access($element[spooky]) || (my_level() >= 5))
		{
			adjustEdHat("ml");
		}
		else
		{
			adjustEdHat("myst");
		}
	}
	if(L1_ed_island() || l1_ed_islandFallback())
	{
		return true;
	}

	if(L5_getEncryptionKey())
	{
		return true;
	}

	if(LX_islandAccess())
	{
		return true;
	}
	if(item_amount($item[Seal Tooth]) == 0)
	{
		acquireHermitItem($item[Seal Tooth]);
	}

	if(my_level() >= 9)
	{
		if((get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
		{
			doRest();
			cli_execute("scripts/postcheese.ash");
			return true;
		}
	}

	if(L10_plantThatBean() || L10_airship() || L10_basement() || L10_ground() || L10_topFloor())
	{
		return true;
	}

	if(L12_preOutfit())
	{
		return true;
	}

	if(get_property("cc_dickstab").to_boolean())
	{
		if((my_level() >= 5) && (chateaumantegna_havePainting()) && (my_daycount() <= 2) && (my_class() != $class[Ed]))
		{
			if(chateaumantegna_usePainting())
			{
				ccAdv(1, $location[Noob Cave]);
				return true;
			}
		}
		if(L1_ed_dinsey())
		{
			return true;
		}
		if(L2_mosquito() || L2_treeCoin() || L2_spookyMap() || L2_spookyFertilizer() || L2_spookySapling())
		{
			return true;
		}
		if(L8_trapperStart() || L8_trapperGround() || L8_trapperYeti())
		{
			return true;
		}
		if(L4_batCave())
		{
			return true;
		}
		if(L5_getEncryptionKey())
		{
			return true;
		}
		if(L5_goblinKing())
		{
			return true;
		}
		if(L9_chasmStart() || L9_chasmBuild())
		{
			return true;
		}
		if(LX_pirateOutfit() || LX_pirateInsults() || LX_pirateBlueprint() || LX_pirateBeerPong() || LX_fcle())
		{
			return true;
		}
		if(LX_dinseylandfillFunbucks())
		{
			return true;
		}

		if(my_level() < 9)
		{
			if((get_property("timesRested").to_int() < total_free_rests()) && chateaumantegna_available())
			{
				doRest();
				cli_execute("scripts/postcheese.ash");
				return true;
			}
		}

		if(L1_ed_island(10))
		{
			return true;
		}

		buffMaintain($effect[The Dinsey Look], 0, 1, 1);

		if(L7_crypt())
		{
			if(item_amount($item[FunFunds&trade;]) > 4)
			{
				buyUpTo(1, $item[Dinsey Face Paint]);
			}
			return true;
		}


	}


	if(LX_pirateOutfit() || LX_pirateInsults() || LX_pirateBlueprint() || LX_pirateBeerPong() || LX_fcle())
	{
		return true;
	}
	if(L2_mosquito() || L2_treeCoin() || L2_spookyMap() || L2_spookyFertilizer() || L2_spookySapling())
	{
		return true;
	}
	if(L8_trapperStart() || L8_trapperGround() || L8_trapperYeti())
	{
		return true;
	}
	if(L4_batCave())
	{
		return true;
	}
	if(L5_goblinKing())
	{
		return true;
	}
	if(!get_property("cc_dickstab").to_boolean() || (my_daycount() >= 2))
	{
		if(L3_tavern())
		{
			return true;
		}
	}

	if(L9_chasmStart() || L9_chasmBuild())
	{
		return true;
	}

	if(L6_friarsGetParts() || L6_friarsHotWing())
	{
		return true;
	}
	if(L11_blackMarket() || L11_forgedDocuments() || L11_mcmuffinDiary() || L11_talismanOfNam())
	{
		return true;
	}

	if(my_spleen_use() == 35)
	{
		if(my_daycount() >= 2)
		{
			if(my_mp() < 40)
			{
				buffMaintain($effect[Spiritually Awake], 0, 1, 1);
				buffMaintain($effect[Spiritually Aware], 0, 1, 1);
				buffMaintain($effect[Spiritually Awash], 0, 1, 1);
			}
		}
	}



	return false;
}
