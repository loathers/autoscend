boolean isActuallyEd()
{
	return (my_class() == $class[Ed] || my_path() == "Actually Ed the Undying");
}

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
	return limit;
}

void ed_initializeSettings()
{
	if (isActuallyEd())
	{
		set_property("auto_crackpotjar", "done");
		set_property("auto_day1_dna", "finished");
		set_property("auto_getBeehive", false);
		set_property("auto_getStarKey", false);
		set_property("auto_grimstoneFancyOilPainting", false);
		set_property("auto_holeinthesky", false);
		set_property("auto_lashes", "");
		set_property("auto_needLegs", false);
		set_property("auto_renenutet", "");
		set_property("auto_servantChoice", "");
		set_property("auto_wandOfNagamar", false);

		set_property("auto_edSkills", -1);
		set_property("auto_chasmBusted", false);
		set_property("auto_renenutetBought", 0);

		set_property("auto_edCombatCount", 0);
		set_property("auto_edCombatRoundCount", 0);

		set_property("desertExploration", 100);
		set_property("nsTowerDoorKeysUsed", "Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key");
		set_property("auto_edServantBugCount", 0);
	}
}

void ed_initializeSession()
{
	if (isActuallyEd())
	{
		// the following settings will affect combat automation
		// see edUnderworldChoiceHandler() for where and how they are used.
		backupSetting("choiceAdventure1023", "");
		backupSetting("choiceAdventure1024", "");
		backupSetting("edDefeatAbort", "3");
	}
}

void ed_terminateSession()
{
	if (isActuallyEd())
	{
		// do nothing.
	}
}

void ed_initializeDay(int day)
{
	if (!isActuallyEd())
	{
		return;
	}

	set_property("auto_renenutetBought", 0);

	if (!get_property("breakfastCompleted").to_boolean() && day != 1)
	{
		cli_execute("breakfast");
	}

	if(day == 1)
	{
		if(get_property("auto_day_init").to_int() < 1)
		{
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}
			tootGetMeat();
			equipBaseline();
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("auto_day_init").to_int() < 2)
		{
			if(get_property("auto_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				acquireHermitItem($item[Seal Tooth]);
			}
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);
		}
	}

	// ed overrides normal day initialization
	set_property("auto_day_init", day);
}

boolean L13_ed_towerHandler()
{
	if (!isActuallyEd())
	{
		return false;
	}

	council(); //Visit prior to checking the quest status to ensure we have correct quest status

	if (internalQuestStatus("questL13Final") < 0 || internalQuestStatus("questL13Final") > 11)
	{
		return false;
	}
	if(item_amount($item[Thwaitgold Scarab Beetle Statuette]) > 0)
	{
		council();
		return true;
	}


	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_10_sorcfight"))
	{
		auto_log_info("We found the jerkwad!! Revenge!!!!!", "blue");

		string page = "place.php?whichplace=nstower&action=ns_10_sorcfight";
		autoAdvBypass(page, $location[Noob Cave]);

		if(item_amount($item[Thwaitgold Scarab Beetle Statuette]) > 0)
		{
			council();
		}
		return true;
	}
	return false;
}

boolean L13_ed_councilWarehouse()
{
	if (!isActuallyEd())
	{
		return false;
	}
	if (internalQuestStatus("questL13Warehouse") != 0)
	{
		return false;
	}

	if(item_amount($item[7965]) == 0)
	{
		autoAdv($location[The Secret Council Warehouse]);
	}
	else
	{
		//Complete: Should not get here though.
		abort("Tried to adventure in the Council Warehouse after finding theMcMuffin.");
		return false;
	}
	while((item_amount($item[Warehouse Map Page]) > 0) && (item_amount($item[Warehouse Inventory Page]) > 0))
	{
		use(item_amount($item[Warehouse Inventory Page]), $item[Warehouse Inventory Page]);
	}
	if(get_property("lastEncounter") == "You Found It!")
	{
		council();
		auto_log_info("McMuffin is found!", "blue");
		auto_log_info("Ed Combats: " + get_property("auto_edCombatCount"), "blue");
		auto_log_info("Ed Combat Rounds: " + get_property("auto_edCombatRoundCount"), "blue");

		cli_execute("refresh quests");
		if (internalQuestStatus("questL13Warehouse") > 0)
		{
			abort("The holy macguffin has been found. Once you replace it you will have to choose a regular class to switch to and end your hiatus as the Undying Ed. Choose wisely or your face will melt off or something.");
		}
	}
	return true;
}

boolean handleServant(servant who)
{
	if (!isActuallyEd())
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
	if (!isActuallyEd())
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
	if (isActuallyEd())
	{
		int maxBuff = 675 - my_turncount();
		while(haveAnyIotmAlternativeRestSiteAvailable() && doFreeRest())
		{
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
	if (!isActuallyEd())
	{
		return false;
	}
	if(my_level() <= get_property("auto_edSkills").to_int())
	{
		return false;
	}
	int possEdPoints = 0;

	string page = visit_url("place.php?whichplace=edbase&action=edbase_book");
	matcher my_skillPoints = create_matcher("You may memorize (\\d\+) more page", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		auto_log_info("Skill points found: " + skillPoints);
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

	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_imbuePoints = create_matcher("Impart Wisdom unto Current Servant ..100xp, (\\d\+) remain.", page);
	int imbuePoints = 0;
	if(my_imbuePoints.find())
	{
		imbuePoints = to_int(my_imbuePoints.group(1));
		auto_log_info("Imbuement points found: " + imbuePoints);
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
		auto_log_info("Servants points found: " + servantPoints);
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
				if((my_level() >= 9) && (imbuePoints > 4) && !have_servant($servant[Scribe]))
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

			if(get_property("auto_dickstab").to_boolean())
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
					if((my_level() >= 9) && (my_level() <= 12))
					{
						// got scribe early. Imbue to level 21 for passive stat gain
						if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441))
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
					auto_log_info("Trying to imbue " + tryImbue + " with glorious wisdom!!", "green");
					visit_url("choice.php?whichchoice=1053&option=5&pwd=");
				}
			}
			imbuePoints = imbuePoints - 1;
		}
		handleServant(current);
	}

	set_property("auto_edSkills", my_level());
	return true;
}

boolean ed_eatStuff()
{
	if (!isActuallyEd())
	{
		return false;
	}

	// fill up on Mummified Beef Haunches as they are Ed's main source of turn-gen
	int canEat = min((spleen_left() / 5), item_amount($item[Mummified Beef Haunch]));
	if (canEat > 0 && autoChew(canEat, $item[Mummified Beef Haunch]))
	{
		return true;
	}
	return false;
}

skill ed_nextUpgrade()
{
	int coins = item_amount($item[Ka Coin]);
	int canEat = (spleen_limit() - my_spleen_use()) / 5;

	if (!have_skill($skill[Upgraded Legs]) && get_property("auto_needLegs").to_boolean())
	{
		return $skill[Upgraded Legs]; // 10 Ka
	}
	else if (!have_skill($skill[Extra Spleen]) && canEat < 1)
	{
		return $skill[Extra Spleen]; // 5 Ka
	}
	else if (!have_skill($skill[Another Extra Spleen]) && canEat < 1)
	{
		return $skill[Another Extra Spleen]; // 10 Ka
	}
	else if (!have_skill($skill[Replacement Stomach]))
	{
		return $skill[Replacement Stomach]; // 30 Ka
	}
	else if (!have_skill($skill[Upgraded Legs]))
	{
		return $skill[Upgraded Legs]; // 10 Ka
	}
	else if (!have_skill($skill[More Legs]))
	{
		return $skill[More Legs]; // 20 Ka
	}
	else if (!have_skill($skill[Yet Another Extra Spleen]) && have_skill($skill[Another Extra Spleen]))
	{
		return $skill[Yet Another Extra Spleen]; // 15 Ka
	}
	else if (!have_skill($skill[Still Another Extra Spleen]))
	{
		return $skill[Still Another Extra Spleen]; // 20 Ka
	}
	else if (!have_skill($skill[Just One More Extra Spleen]))
	{
		return $skill[Just One More Extra Spleen]; // 25 Ka
	}
	else if (!have_skill($skill[Replacement Liver]))
	{
		return $skill[Replacement Liver]; // 30 Ka
	}
	else if (!have_skill($skill[Elemental Wards]))
	{
		return $skill[Elemental Wards]; // 10 Ka
	}
	else if (!have_skill($skill[Okay Seriously, This is the Last Spleen]))
	{
		return $skill[Okay Seriously, This is the Last Spleen];  // 30 Ka
	}
	else if (!possessEquipment($item[The Crown of Ed the Undying]) && !have_skill($skill[Tougher Skin]))
	{
		return $skill[Tougher Skin];  // 10 Ka
	}
	else if (!have_skill($skill[More Elemental Wards]))
	{
		return $skill[More Elemental Wards]; // 20 Ka
	}
	else if (!have_skill($skill[Even More Elemental Wards]))
	{
		return $skill[Even More Elemental Wards]; // 30 Ka
	}
	else if (!have_skill($skill[Healing Scarabs]) && my_daycount() >= 2)
	{
		return $skill[Healing Scarabs]; // 10 Ka
	}
	else if (!have_skill($skill[Tougher Skin]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Tougher Skin]; // 10 Ka
	}
	else if (!have_skill($skill[Armor Plating]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Armor Plating]; // 10 Ka
	}
	else if (!have_skill($skill[Upgraded Spine]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Upgraded Spine]; // 20 Ka
	}
	else if (!have_skill($skill[Upgraded Arms]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Upgraded Arms]; // 20 Ka
	}
	else if (!have_skill($skill[Arm Blade]) && my_daycount() >= 4 && coins >= 100)
	{
		return $skill[Arm Blade]; // 20 Ka
	}
	else if (!have_skill($skill[Bone Spikes]) && my_daycount() >= 4 && coins >= 100)
	{
		return $skill[Bone Spikes]; // 20 Ka
	}
	return $skill[none];
}

int ed_KaCost(skill upgrade)
{
	static int[skill] kaNeeded = {
		$skill[Extra Spleen]: 5,
		$skill[Another Extra Spleen]: 10,
		$skill[Upgraded Legs]: 10,
		$skill[Tougher Skin]: 10,
		$skill[Armor Plating]: 10,
		$skill[Healing Scarabs]: 10,
		$skill[Elemental Wards]: 10,
		$skill[Yet Another Extra Spleen]: 15,
		$skill[Still Another Extra Spleen]: 20,
		$skill[More Legs]: 20,
		$skill[Upgraded Arms]: 20,
		$skill[Upgraded Spine]: 20,
		$skill[Bone Spikes]: 20,
		$skill[Arm Blade]: 20,
		$skill[More Elemental Wards]: 20,
		$skill[Just One More Extra Spleen]: 25,
		$skill[Replacement Stomach]: 30,
		$skill[Replacement Liver]: 30,
		$skill[Okay Seriously, This is the Last Spleen]: 30,
		$skill[Even More Elemental Wards]: 30
	};
	if (kaNeeded contains upgrade)
	{
		return kaNeeded[upgrade];
	} else {
		return -1;
	}
}

boolean ed_needShop()
{
	if (!isActuallyEd())
	{
		return false;
	}

	if (have_skill($skill[Upgraded Legs]) && get_property("auto_needLegs").to_boolean())
	{
		set_property("auto_needLegs", false);
	}

	int coins = item_amount($item[Ka Coin]);

	if (get_property("auto_needLegs").to_boolean() && coins >= ed_KaCost($skill[Upgraded Legs]))
	{
		auto_log_info("Ed needs legs (and can afford them)! UNDYING for a free trip to the Underworld!");
		return true;
	}

	// check if we need mummified beef haunches
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	canEat = max(0, canEat - item_amount($item[Mummified Beef Haunch]));
	if (canEat > 0 && coins >= 15)
	{
		auto_log_info("Ed needs beef haunches (and can afford them)! UNDYING for a free trip to the Underworld!");
		return true;
	}

	// check if we need emergency MP
	if (coins >= 1 && my_mp() < mp_cost($skill[Storm Of The Scarab]))
	{
		if (item_amount($item[Holy Spring Water]) < 1 && item_amount($item[Spirit Beer]) < 1 && item_amount($item[Sacramental Wine]) < 1)
		{
			auto_log_info("Ed needs MP restores! UNDYING for a free trip to the Underworld!");
			return true;
		}
	}

	// check if we have skills or consumables to buy
	skill nextUpgrade = ed_nextUpgrade();
	int requiredKa = ed_KaCost(nextUpgrade);
	if (canEat < 1 && requiredKa != -1 && coins >= requiredKa)
	{
		auto_log_info(`Ed needs {nextUpgrade.to_string()} (and can afford it)! UNDYING for a free trip to the Underworld!`);
		return true;
	}
	else if (have_skill($skill[Okay Seriously, This is the Last Spleen]) && canEat < 1)
	{
		if (item_amount($item[Talisman of Renenutet]) < 1 && get_property("auto_renenutetBought").to_int() < 7 && coins >= (7 - get_property("auto_renenutetBought").to_int()))
		{
			auto_log_info("Ed needs Talismens of Renenutet! UNDYING for a free trip to the Underworld!");
			return true;
		}
		else if (item_amount($item[Linen Bandages]) < 1 && coins >= 4)
		{
			auto_log_info("Ed needs Linen Bandages! UNDYING for a free trip to the Underworld!");
			return true;
		}
		else if (item_amount($item[Holy Spring Water]) < 1 && coins >= 1 && (my_maxmp() - my_mp() < 50))
		{
			auto_log_info("Ed needs Holy Spring Water! UNDYING for a free trip to the Underworld!");
			return true;
		}
		else if (item_amount($item[Talisman of Horus]) < 1 && coins >= 5)
		{
			auto_log_info("Ed needs Talismens of Horus! UNDYING for a free trip to the Underworld!");
			return true;
		}
		else if (item_amount($item[Spirit Beer]) < 1 && coins >= 30)
		{
			auto_log_info("Ed needs Spirit Beer! UNDYING for a free trip to the Underworld!");
			return true;
		}
		else if ((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 1 && coins >= 30)
		{
			auto_log_info("Ed needs Ancient Cure-All! UNDYING for a free trip to the Underworld!");
			return true;
		}
		else if (item_amount($item[Sacramental Wine]) < 1 && coins >= 30)
		{
			auto_log_info("Ed needs Sacramental Wine! UNDYING for a free trip to the Underworld!");
			return true;
		}
	}

	return false;
}

boolean ed_shopping()
{

	int ed_skillID(skill upgrade)
	{
		static int[skill] skillIDs = {
			$skill[Replacement Stomach]: 28,
			$skill[Replacement Liver]: 29,
			$skill[Extra Spleen]: 30,
			$skill[Another Extra Spleen]: 31,
			$skill[Yet Another Extra Spleen]: 32,
			$skill[Still Another Extra Spleen]: 33,
			$skill[Just One More Extra Spleen]: 34,
			$skill[Okay Seriously, This is the Last Spleen]: 35,
			$skill[Upgraded Legs]: 36,
			$skill[Upgraded Arms]: 37,
			$skill[Upgraded Spine]: 38,
			$skill[Tougher Skin]:  39,
			$skill[Armor Plating]: 40,
			$skill[Bone Spikes]: 41,
			$skill[Arm Blade]: 42,
			$skill[Healing Scarabs]: 43,
			$skill[Elemental Wards]: 44,
			$skill[More Elemental Wards]: 45,
			$skill[Even More Elemental Wards]: 46,
			$skill[More Legs]: 48
		};
		if (skillIDs contains upgrade)
		{
			return skillIDs[upgrade];
		} else {
			return -1;
		}
	}

	auto_log_info("Time to shop!", "red");

	if (get_property("auto_pvpEnable").to_boolean() && !hippy_stone_broken())
	{
		visit_url("peevpee.php?action=smashstone&pwd&confirm=on", true);
		visit_url("place.php?whichplace=edunder&action=edunder_hippy");
		visit_url("choice.php?pwd&whichchoice=1057&option=1", true);
	}

	int coins = item_amount($item[Ka Coin]);
	//Handler for low-powered accounts
	if (!have_skill($skill[Upgraded Legs]) && get_property("auto_needLegs").to_boolean())
	{
		if (coins >= 10)
		{
			auto_log_info("Buying Upgraded Legs", "green");
			set_property("auto_needLegs", false);
			visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
			visit_url("choice.php?pwd&skillid=36&option=1&whichchoice=1052", true);
			visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
			coins -= 10;
		}
		else
		{
			//Prevent other purchases from interrupting us.
			coins = 0;
		}
	}

	// fill spleen with mummified beef haunches.
	int canEat = (ed_spleen_limit() - my_spleen_use()) / 5;
	canEat -= item_amount($item[Mummified Beef Haunch]);
	while (coins >= 15 && canEat > 0)
	{
		visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=428", true);
		auto_log_info("Buying a mummified beef haunch!", "green");
		coins -= 15;
		canEat--;
	}

	// buy emergency MP restores.
	if (!get_property("lovebugsUnlocked").to_boolean() && coins >= 1 && item_amount($item[Holy Spring Water]) == 0 && my_mp() < mp_cost($skill[Storm Of The Scarab]))
	{
		auto_log_info("Buying Holy Spring Water", "green");
		visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
		coins -= 1;
	}

	// buy skills
	if (canEat < 1)
	{
		skill nextUpgrade = ed_nextUpgrade();
		int requiredKa = ed_KaCost(nextUpgrade);
		if (requiredKa != -1 && coins >= requiredKa)
		{
			auto_log_info("Buying " + nextUpgrade.to_string() + " (" + requiredKa.to_string() + " Ka).", "green");
			int skillBuy = ed_skillID(nextUpgrade);
			if (skillBuy != 0)
			{
				visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
				visit_url("choice.php?pwd&skillid=" + skillBuy + "&option=1&whichchoice=1052", true);
				visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
				coins -= requiredKa;
			}
		}
		else if (have_skill($skill[Okay Seriously, This is the Last Spleen]) && canEat < 1)
		{
			while (item_amount($item[Talisman of Renenutet]) < 7 && get_property("auto_renenutetBought").to_int() < 7 && coins >= 1)
			{
				auto_log_info("Buying Talisman of Renenutet", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
				set_property("auto_renenutetBought", 1 + get_property("auto_renenutetBought").to_int());
				coins -= 1;
			}
			while (item_amount($item[Linen Bandages]) < 8 && coins >= 1)
			{
				auto_log_info("Buying Linen Bandages", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=429", true);
				coins -= 1;
			}
			if (item_amount($item[Holy Spring Water]) == 0 && coins >= 1)
			{
				auto_log_info("Buying Holy Spring Water", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
				coins -= 1;
			}
			while (item_amount($item[Talisman of Horus]) < 2 && coins >= 5)
			{
				auto_log_info("Buying Talisman of Horus", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=693", true);
				coins -= 5;
			}
			if (item_amount($item[Spirit Beer]) == 0 && coins >= 30)
			{
				auto_log_info("Buying Spirit Beer", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=432", true);
				coins -= 2;
			}
			if ((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2 && coins >= 30)
			{
				auto_log_info("Buying Ancient Cure-all", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=435", true);
				coins -= 3;
			}
			if (item_amount($item[Sacramental Wine]) == 0 && coins >= 30)
			{
				auto_log_info("Buying Sacramental Wine", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=433", true);
				coins -= 3;
			}
		}
	}
	return true;
}

void ed_handleAdventureServant(location loc)
{
	if (loc == $location[Noob Cave] || !isActuallyEd())
	{
		return;
	}
	
	// the order servants are unlocked is
	// level 3 - Priest (extra Ka)
	// level 6 - Cat (item drops)
	// level 9 - Scribe (stats)
	// level 12 - Maid (meat drops)

	// Default to the Priest as we need Ka to get upgrades and fill spleen (and other miscellanea)
	servant myServant = $servant[Priest];

	if (my_spleen_use() == 35 && have_skill($skill[Even More Elemental Wards]) && my_level() < 13 && have_servant($servant[Scribe]))
	{
		// Ka is less important when we have a full spleen and all the skills we need
		// so default to getting stats if we're not level 13 yet.
		myServant = $servant[Scribe];
	}
	else if (my_level() > 12)
	{
		if (!have_skill($skill[Gift of the Maid]) && have_servant($servant[Maid]) && get_property("sidequestNunsCompleted") == "none")
		{
			myServant = $servant[Maid];
		}
		else if (!have_skill($skill[Gift of the Cat]) && have_servant($servant[Cat]))
		{
			myServant = $servant[Cat];
		}
	}

	// Initial Ka farming to get Spleen & Legs upgrades.
	if ($locations[Hippy Camp, The Neverending Party, The Secret Government Laboratory, The SMOOCH Army HQ, VYKEA] contains loc && my_daycount() == 1)
	{
		myServant = $servant[Priest];
	}

	// Locations where item drop is required for quest furthering purposes but we don't want to miss out on Ka if needed.
	if ($locations[The Goatlet, The eXtreme Slope, The Batrat and Ratbat Burrow, Cobb's Knob Harem, Twin Peak, The Black Forest, The Hidden Bowling Alley, The Copperhead Club, A Mob of Zeppelin Protesters, The Red Zeppelin] contains loc)
	{
		if (my_spleen_use() == 35 && have_skill($skill[Even More Elemental Wards]))
		{
			myServant = $servant[Cat];
		}
	}

	// Locations where item drop is required for quest furthering purposes and we won't get Ka regardless
	if ($locations[The Defiled Nook, Oil Peak, A-Boo Peak, The Haunted Laundry Room, The Haunted Wine Cellar] contains loc)
	{
		myServant = $servant[Cat];
	}

	// Locations where we won't get Ka and don't need item drop.
	if ($locations[The Dark Neck of the Woods, The Dark Heart of the Woods, The Dark Elbow of the Woods, The Defiled Alcove, The Defiled Cranny, The Defiled Niche, The Haunted Kitchen, The Haunted Billiards Room, The Haunted Library, The Haunted Bedroom, The Haunted Ballroom, The Haunted Bathroom, The Haunted Boiler Room] contains loc)
	{
		if (have_servant($servant[Scribe]))
		{
			myServant = $servant[Scribe];
		}
		else
		{
			if (have_servant($servant[Cat]))
			{
				myServant = $servant[Cat];
			}
		}
	}

	// Locations where meat drop is required for quest furthering purposes (or just nice to have)
	if ($locations[The Themthar Hills, The Filthworm Queen\'s Chamber] contains loc && have_servant($servant[Maid]))
	{
		myServant = $servant[Maid];
	}

	// Special case for The Penultimate Fantasy Airship as we want to farm some items for quest furthering purposes
	// but it's also an excellent Ka farming zone and we have to spend a bunch of adventures there
	if (loc == $location[The Penultimate Fantasy Airship])
	{
		if (!possessEquipment($item[Mohawk wig]) || !possessEquipment($item[amulet of extreme plot significance]) || !possessEquipment($item[titanium assault umbrella]))
		{
			myServant = $servant[Cat];
		}
		else if (my_spleen_use() == 35 && have_skill($skill[Even More Elemental Wards]) && my_level() < 13 && have_servant($servant[Scribe]))
		{
			myServant = $servant[Scribe];
		}
	}

	handleServant(myServant);
}

boolean L1_ed_island()
{
	if(!elementalPlanes_access($element[spooky]))
	{
		return false;
	}

	if (!have_skill($skill[Roar of the Lion]))
	{
		// combat handling only uses this so it's essential
		return false;
	}

	skill blocker = $skill[Still Another Extra Spleen];
	if(get_property("auto_dickstab").to_boolean())
	{
		if(turns_played() > 22)
		{
			return false;
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
		autoEquip($item[Gore Bucket]);
	}

	if(item_amount($item[Personal Ventilation Unit]) > 0)
	{
		autoEquip($slot[acc2], $item[Personal Ventilation Unit]);
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
		cli_execute("auto_post_adv");
	}

	buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
	autoAdv($location[The Secret Government Laboratory]);
	if(item_amount($item[Bottle-Opener Keycard]) > 0)
	{
		use(1, $item[Bottle-Opener Keycard]);
	}
	set_property("choiceAdventure988", 1);
	return true;
}

boolean L1_ed_islandFallback()
{
	if(elementalPlanes_access($element[spooky]))
	{
		return false;
	}

	if (my_level() >= 10 || have_skill($skill[Okay Seriously\, This Is The Last Spleen]))
	{
		if (spleen_left() < 5 || my_adventures() > 10)
		{
			return false;
		}
	}

	if (neverendingPartyAvailable())
	{
		return neverendingPartyCombat();
	}
	if(elementalPlanes_access($element[stench]))
	{
		return autoAdv($location[Pirates of the Garbage Barges]);
	}
	if(elementalPlanes_access($element[cold]))
	{
		return autoAdv($location[VYKEA]);
	}
	if(elementalPlanes_access($element[hot]))
	{
		//Maybe this is a good choice?
		set_property("choiceAdventure1094", 5);
		autoAdv($location[The SMOOCH Army HQ]);
		set_property("choiceAdventure1094", 2);
		return true;
	}

	if (my_session_adv() == 0 && my_mp() >= mp_cost($skill[Wisdom Of Thoth]) && have_skill($skill[Wisdom Of Thoth]))
	{
		// use our free starting 5 mp to get Wisdom of Thoth to increase our max MP 
		// as we'll regen some when adventuring at the shore.
		use_skill(1, $skill[Wisdom Of Thoth]);
	}

	if(LX_islandAccess())
	{
		return true;
	}
	if(get_property("lastIslandUnlock").to_int() != my_ascensions())	//somehow island was not unlocked!
	{
		//if we fail to unlock the island at this stage our run will be crippled. normally this does not occur.
		//but if initialization fails or if user played some turns before running autoscend this can happen.
		if(my_meat() < 1900)
		{
			abort("Island failed to unlock because you do not have enough meat. This is a critical problem for ed pathing. Have at least 1900 meat then run autoscend again");
		}
		if(my_adventures() <= 9)
		{
			abort("Island failed to unlock because you do not have enough adventures. This is a critical problem for ed pathing. Have at least 10 adv then run autoscend again");
		}
		abort("Island failed to unlock for an unknown reason. This is a critical problem for ed pathing. Please unlock the island then run autoscend again");
	}

	if (my_servant() == $servant[Priest] && my_servant().experience < 196)
	{
		// make sure we have a level 15 Priest if possible
		// so we get the extra Ka from Hippies and Goblins.
		buffMaintain($effect[Purr of the Feline], 10, 1, 10);
	}
	
	if (have_skill($skill[Upgraded Legs]) || item_amount($item[Ka coin]) >= 10)
	{
		auto_change_mcd(11);
		boolean retVal = autoAdv($location[Hippy Camp]);
		if (item_amount($item[Filthy Corduroys]) > 0)
		{
			if (closet_amount($item[Filthy Corduroys]) > 0)
			{
				autosell(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
			}
			else
			{
				put_closet(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
			}
		}

		// TODO: Malibu Stacey - move all this to a more central location after refactor
		if (item_amount($item[filthy knitted dread sack]) > 1 && equipped_amount($item[filthy knitted dread sack]) == 0) {
			// keep one for starting the war (and general wearing until we have something better)
			auto_autosell(item_amount($item[filthy knitted dread sack]) - 1, $item[filthy knitted dread sack]);
		} else if (item_amount($item[filthy knitted dread sack]) > 0 && equipped_amount($item[filthy knitted dread sack]) == 1) {
			// have one equipped, just sell any others.
			auto_autosell(item_amount($item[filthy knitted dread sack]), $item[filthy knitted dread sack]);
		}

		if (item_amount($item[hemp string]) > 1 && equipped_amount($item[hemp string]) == 0) {
			// keep one for the Bonerdagon necklace.
			auto_autosell(item_amount($item[hemp string]) - 1, $item[hemp string]);
		} else if (item_amount($item[hemp string]) > 0 && equipped_amount($item[hemp string]) == 1) {
			// have one equipped, just sell any others.
			auto_autosell(item_amount($item[hemp string]), $item[hemp string]);
		}

		// autosell some other useless stuff as we can use the meat to buy MP from doc galaktik.
		// Ed doesn't need any of this stuff as he starts with the Staff of Ed and can use it until the level 11 quest
		foreach it in $items[hippy bongo, filthy pestle, double-barreled sling] {
			auto_autosell(item_amount(it), it);
		}

		return retVal;
	}
	set_property("auto_needLegs", true);
	addToMaximize("-10ml");
	auto_change_mcd(0);
	return autoAdv($location[The Outskirts of Cobb\'s Knob]);
}

boolean L9_ed_chasmStart()
{
	if (internalQuestStatus("questL09Topping") < 0)
	{
		return false;
	}

	if (isActuallyEd() && !get_property("auto_chasmBusted").to_boolean())
	{
		auto_log_info("It's a troll on a bridge!!!!", "blue");

		string page = visit_url("place.php?whichplace=orc_chasm&action=bridge_done");
		autoAdvBypass("place.php?whichplace=orc_chasm&action=bridge_done", $location[The Smut Orc Logging Camp]);

		set_property("auto_chasmBusted", true);
		return true;
	}
	return false;
}

boolean L9_ed_chasmBuildClover(int need)
{
	if (isActuallyEd() && (need > 3) && (item_amount($item[Disassembled Clover]) > 2))
	{
		use(1, $item[disassembled clover]);
		backupSetting("cloverProtectActive", false);
		autoAdvBypass("adventure.php?snarfblat=295", $location[The Smut Orc Logging Camp]);
		if(item_amount($item[Ten-Leaf Clover]) > 0)
		{
			auto_log_info("Wandering adventure in The Smut Orc Logging Camp, boo. Gonna have to do this again.");
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

boolean ed_DelayNC_DailyDungeon()
{
	//Ed will be doing daily dungeon if auto_forceFatLootToken == true
	//return true if we should delay daily dungeon as Ed because we cannot handle the NCs
	if(!isActuallyEd())
	{
		return false;
	}
	
	boolean has_pole = item_amount($item[Eleven-Foot Pole]) > 0;
	boolean has_picks = item_amount($item[Platinum Yendorian Express Card]) > 0 || item_amount($item[Pick-O-Matic Lockpicks]) > 0;
	if(has_pole && has_picks)
	{
		return false;		//will not take any damage from NCs.
	}
	
	return item_amount($item[Linen Bandages]) == 0;
}

boolean ed_DelayNC(int potential_dmg)
{
	//return true if we should delay NC as ed because it might kill us and cause us to waste an adv on restoring
	if(!isActuallyEd())
	{
		return false;
	}
	if(my_hp() > potential_dmg)
	{
		return false;	//not enough dmg to kill us
	}
	if(isAboutToPowerlevel())
	{
		return false;	//take the risk if we have nothing left to do.
	}
	
	//if we have no restorers then return true to delay
	return item_amount($item[Linen Bandages]) == 0;
}

boolean ed_DelayNC(float potential_dmg_percent)
{
	float multi = 0.01 * potential_dmg_percent;
	int potential_dmg = ceil(multi * my_maxhp());
	return ed_DelayNC(potential_dmg);
}

boolean edUnderworldAdv()
{
	//This function is used to spend 1 adv "resting" as ed by entering the underworld via the gate at his pyramid, shopping, then leaving.
	//Does not check our current HP to see if it should run. only call it if necessary.
	if(!isActuallyEd())
	{
		abort("edUnderworldAdv() should not have been called as not ed.");
	}
	if(my_adventures() == 0)
	{
		abort("Tried to spend 1 adv as ed visiting the underworld when we have no adv left");
	}
	auto_log_info("Visiting the underworld via the pyramid gate", "blue");
	int initial_turncount = my_turncount();

	visit_url("place.php?whichplace=edbase&action=edbase_portal");		//click on portal in base
	run_choice(1);														//Enter the Underworld
	run_choice(1);														//Need to click through another window
	ed_shopping();														//Shop while there
	visit_url("place.php?whichplace=edunder&action=edunder_leave");		//click on portal in underworld
	run_choice(1);														//Exit the Underworld
	
	return my_turncount() == 1 + initial_turncount;
}

boolean edAcquireHP()
{
	//Ed only needs 1 HP to adventure. goal = my_maxhp() is exceptionally wasteful for ed as it will burn all his linen bandages and then all his Ka replacing his linen bandages.
	if(!isActuallyEd())
	{
		return false;
	}
	if(my_hp() > 0)
	{
		return true;	// Ed doesn't need to heal outside of combat unless on 0 hp
	}
	foreach it in $items[linen bandages,cotton bandages,silk bandages]
	{
		if(item_amount(it) > 0)
		{
			use(1,$item[Linen Bandages]);
			break;
		}
	}
	if(my_hp() == 0)		//could not restore via items
	{
		edUnderworldAdv();
	}
	if(my_hp() == 0)
	{
		abort("Ed somehow failed to restore HP and can not continue");		//prevent infinite loop of failing to adventure due to 0 HP.
	}
	return true;
}

boolean edAcquireHP(int goal)
{
	//function forces Ed to heal to a goal HP. Based on acquireHP function
	boolean isMax = (goal == my_maxhp());

	__cure_bad_stuff();

	if(isMax)
	{
		goal = my_maxhp(); //in case max rose after curing the bad stuff
	}
	else if(goal > my_maxhp())
	{
		return false;
	}

	while (my_hp() < goal && my_hp() < my_maxhp() && item_amount($item[Linen Bandages]) > 0)
	{
		use(1,$item[Linen Bandages]);
	}

	return my_hp() >= goal;
}

boolean LM_edTheUndying()
{
	if (!isActuallyEd())
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

	if (auto_campawayAvailable())
	{
		// keep enough firewood on hand to fill stomach and liver with campfire food
		if (!possessEquipment($item[whittled tiara]) && item_amount($item[Stick of Firewood]) > 14)
		{
			buy($coinmaster[Your Campfire], 1, $item[whittled tiara]);
		}
		if (!possessEquipment($item[whittled shorts]) && item_amount($item[Stick of Firewood]) > 14)
		{
			buy($coinmaster[Your Campfire], 1, $item[whittled shorts]);
		}
		if (!possessEquipment($item[whittled owl figurine]) && item_amount($item[Stick of Firewood]) > 19)
		{
			buy($coinmaster[Your Campfire], 1, $item[whittled owl figurine]);
		}
	}

	if (item_amount($item[Seal Tooth]) == 0 && my_meat() > 2500) {
		// people with lots of IotMs are too survivable and kill stuff when trying to UNDYING
		// if they have to use Mild Curse.
		acquireHermitItem($item[Seal Tooth]);
	}

	if(L1_ed_island() || L1_ed_islandFallback())
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

	if (closet_amount($item[Filthy Corduroys]) > 0)
	{
		take_closet(closet_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
	}

	if (!get_property("breakfastCompleted").to_boolean())
	{
		cli_execute("breakfast");
	}

	if (item_amount($item[Seal Tooth]) == 0)
	{
		acquireHermitItem($item[Seal Tooth]);
	}

	if (my_level() >= 9)
	{
		if(haveAnyIotmAlternativeRestSiteAvailable() && doFreeRest())
		{
			cli_execute("scripts/autoscend/auto_post_adv.ash");
			return true;
		}
	}

	// we should open the manor second floor sooner rather than later as starting the level 11 quest
	// ruins our pool skill and having delay burning zones open is nice.
	if (LX_unlockManorSecondFloor() || LX_unlockHauntedLibrary() || LX_unlockHauntedBilliardsRoom(true)) {
		return true;
	}
	// as we do hippy side, the war is a 2 Ka quest (excluding sidequests but that shouldn't matter)
	if (L12_islandWar())
	{
		return true;
	}
	// start the macguffin quest, conveniently the black forest is a 1.4 Ka zone.
	if (L11_blackMarket() || L11_forgedDocuments() || L11_mcmuffinDiary() || L11_shenStartQuest())
	{
		return true;
	}
	// The hidden city is mostly 2 Ka monsters so do it ASAP.
	if (L11_unlockHiddenCity() || L11_hiddenCityZones() || L11_hiddenCity())
	{
		return true;
	}
	// Airship is 1.5 Ka or 1.8 Ka with the construct banished so third highest priorty after the war
	// Castle zones are all 1 Ka so may as well finish it off
	if (L10_plantThatBean() || L10_airship() || L10_basement() || L10_ground() || L10_topFloor())
	{
		return true;
	}
	// Smut Orcs are 1 Ka so build the bridge.
	if (L9_ed_chasmStart() || L9_chasmBuild())
	{
		return true;
	}
	// L8 quest is all 1 Ka zones for Ed (unlikely to survive Ninja Snowmen Assassins so they don't count)
	if (L8_trapperQuest())
	{
		return true;
	}
	// Goblins are 1 Ka and the rewards are useful
	if (L5_haremOutfit() || L5_goblinKing())
	{
		return true;
	}
	// Bats are 1 Ka and the rewards are useful
	if (L4_batCave())
	{
		return true;
	}
	// need to do L2 quest to unlock the L3. 0.83 Ka zone or 1/1.25/1.67 with 1/2/3 banishes
	if (L2_mosquito() || LX_unlockHiddenTemple())
	{
		return true;
	}
	// should probably complete the tavern for drinking purposes (and rats are 1 Ka).
	if (L3_tavern())
	{
		return true;
	}
	// Copperhead Club & Mob of Zeppelin Protestors are 2 Ka zones (with a banish use) but we want to delay them so we can semi-rare Copperhead
	if (LX_spookyravenManorSecondFloor() || L11_mauriceSpookyraven() || L11_talismanOfNam() || L11_palindome())
	{
		return true;
	}

	if (!have_skill($skill[Even More Elemental Wards])) { 
		// if we don't have the last Elemental Resistance Upgrade, we still need Ka
		// Thus we shouldn't block quests that Shen might request as almost all of them are Ka zones.
		if(allowSoftblockShen()) {
			auto_log_warning("I was trying to avoid zones that Shen might need, but I still need Ka for upgrades.", "red");
			set_property("auto_shenSkipLastLevel", my_level());
			return true;
		}
	}

	// Crush the jackass adventurer!
	if (L13_ed_towerHandler())
	{
		return true;
	}
	// Back to square frigging one, I guess.
	if (L13_ed_councilWarehouse())
	{
		return true;
	}
	return false;
}

void edUnderworldChoiceHandler(int choice) {
	auto_log_debug(`edUnderworldChoiceHandler Running choice {choice}`, "blue");
	if (choice == 1023) { // Like a Bat Into Hell
		run_choice(1); // Enter the Underworld
		auto_log_info("Ed died in combat " + get_property("_edDefeats").to_int() + " time(s)", "blue");
		ed_shopping(); // "free" trip to the Underworld, may as well go shopping!
		visit_url("place.php?whichplace=edunder&action=edunder_leave");
	} else if (choice == 1024) { // Like a Bat out of Hell
		if (get_property("_edDefeats").to_int() < get_property("edDefeatAbort").to_int()) {
			// resurrecting is still free.
			run_choice(1, false); // UNDYING!
		} else {
			// resurrecting will cost Ka
			run_choice(2); // Accept the cold embrace of death (Return to the Pyramid)
			auto_log_info("Ed died in combat for reals!");
			set_property("auto_beatenUpCount", get_property("auto_beatenUpCount").to_int() + 1);
		}
	} else {
		abort("unhandled choice in edUnderworldChoiceHandler");
	}
}
