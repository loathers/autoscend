script "auto_island_war.ash"

boolean warOutfit(boolean immediate)
{
	boolean reallyWarOutfit(string toWear)
	{
		if(immediate)
		{
			return outfit(toWear);
		}
		else
		{
			return autoOutfit(toWear);
		}
	}

	if(!get_property("auto_hippyInstead").to_boolean())
	{
		if(!reallyWarOutfit("frat warrior fatigues"));
		{
			foreach it in $items[Beer Helmet, Distressed Denim Pants, Bejeweled Pledge Pin]
			{
				take_closet(closet_amount(it), it);
			}
			if(!reallyWarOutfit("frat warrior fatigues"))
			{
				abort("Do not have frat warrior fatigues and don't know why....");
				return false;
			}
		}
	}
	if(get_property("auto_hippyInstead").to_boolean())
	{
		if(!reallyWarOutfit("war hippy fatigues"))
		{
			foreach it in $items[Reinforced Beaded Headband, Bullet-proof Corduroys, Round Purple Sunglasses]
			{
				take_closet(closet_amount(it), it);
			}
			if(!reallyWarOutfit("war hippy fatigues"))
			{
				abort("Do not have war hippy fatigues and don't know why....");
				return false;
			}
		}
	}
	return true;
}

boolean haveWarOutfit()
{
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		foreach it in $items[Beer Helmet, Distressed Denim Pants, Bejeweled Pledge Pin]
		{
			if(available_amount(it) == 0)
			{
				return false;
			}
		}
	}
	else
	{
		foreach it in $items[Reinforced Beaded Headband, Bullet-proof Corduroys, Round Purple Sunglasses]
		{
			if(available_amount(it) == 0)
			{
				return false;
			}
		}
	}
	return true;
}

boolean warAdventure()
{
	if(auto_have_familiar($familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 3))
	{
		handleFamiliar($familiar[Space Jellyfish]);
	}

	if(!get_property("auto_hippyInstead").to_boolean())
	{
		if(!autoAdv(1, $location[The Battlefield (Frat Uniform)]))
		{
			set_property("hippiesDefeated", get_property("hippiesDefeated").to_int() + 1);
			string temp = visit_url("island.php");
		}
	}
	else
	{
		if(!autoAdv(1, $location[The Battlefield (Hippy Uniform)]))
		{
			set_property("fratboysDefeated", get_property("fratboysDefeated").to_int() + 1);
			string temp = visit_url("island.php");
		}
	}
	return true;
}

boolean L12_getOutfit()
{
	if (internalQuestStatus("questL12War") != 0)
	{
		return false;
	}

	// noncombat when adventuring at The Hippy Camp (Verge of War)
	set_property("choiceAdventure139", "3");	//fight a War Hippy (space) cadet for outfit pieces
	set_property("choiceAdventure140", "3");	//fight a War Hippy drill sergeant for outfit pieces
	set_property("choiceAdventure141", "1");	//if wearing [Frat Boy Ensemble] get 50 mysticality
	set_property("choiceAdventure142", "3");	//if wearing [Frat Warrior Fatigues] start the war or skip adventure
	
	// noncombat when adventuring at Orcish Frat House (Verge of War)
	set_property("choiceAdventure143", "3");	//fight a War Pledgefor outfit pieces
	set_property("choiceAdventure144", "3");	//fight a Frat Warrior drill sergeant for outfit pieces
	set_property("choiceAdventure145", "1");	//if wearing [Filthy Hippy Disguise] get 50 muscle
	set_property("choiceAdventure146", "3");	//if wearing [War Hippy Fatigues] start the war or skip adventure

	// if you already have the war outfit we don't need to do anything now
	if (haveWarOutfit())
	{
		return false;
	}
	
	//heavy rains softcore pull handling
	if(!in_hardcore() && (auto_my_path() == "Heavy Rains"))
	{
		//TODO add hippies support here and in heavy rains file for copying hippy spy instead.
		if(get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Reinforced Beaded Headband], 1, 0);
			pullXWhenHaveY($item[Round Purple Sunglasses], 1, 0);
			pullXWhenHaveY($item[Bullet-proof Corduroys], 1, 0);			
		}
		// auto_orcishfratboyspy indicates that rainman was already used to copy an orcish frat boy in heavy rains. if it failed to YR pull missing items
		if((get_property("auto_orcishfratboyspy") == "done") && !get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Beer Helmet], 1, 0);
			pullXWhenHaveY($item[Bejeweled Pledge Pin], 1, 0);
			pullXWhenHaveY($item[Distressed Denim Pants], 1, 0);
		}
	}

	//softcore pull handling for all other paths
	if(!in_hardcore() && (auto_my_path() != "Heavy Rains"))
	{
		if(get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Reinforced Beaded Headband], 1, 0);
			pullXWhenHaveY($item[Round Purple Sunglasses], 1, 0);
			pullXWhenHaveY($item[Bullet-proof Corduroys], 1, 0);			
		}
		if(!get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Beer Helmet], 1, 0);
			pullXWhenHaveY($item[Bejeweled Pledge Pin], 1, 0);
			pullXWhenHaveY($item[Distressed Denim Pants], 1, 0);
		}
	}

	// if you have war outfit now then you just pulled it. so this time we return true as something changed
	if(haveWarOutfit())
	{
		return true;
	}
	// if you reached this point you are either in hardcore or are in softcore but ran out of pulls
	// if really in softcore and out of pulls then returning false here lets you skip it until tomorrow
	if(!in_hardcore())
	{
		return false;
	}
	
	// if outfit could not be pulled and have a [Filthy Hippy Disguise] outfit then wear it and adventure in Frat House to get war outfit
	if (!get_property("auto_hippyInstead").to_boolean() && possessEquipment($item[filthy knitted dread sack]) && possessEquipment($item[filthy corduroys]))
	{
		autoOutfit("filthy hippy disguise");
		autoAdv(1, $location[Wartime Frat House]);
		return true;
	}
	
	// if outfit could not be pulled and have a [Frat Boy Ensemble] outfit then wear it and adventure in Hippy Camp to get war outfit
	if (get_property("auto_hippyInstead").to_boolean() && possessEquipment($item[orcish baseball cap]) && possessEquipment($item[orcish frat-paddle]) && possessEquipment($item[orcish cargo shorts]))
	{
		autoOutfit("frat Boy Ensemble");
		autoAdv(1, $location[Wartime Hippy Camp]);
		return true;
	}
	
	if(L12_preOutfit())
	{
		return true;
	}
	return false;
}

boolean L12_preOutfit()
{
	if(get_property("lastIslandUnlock").to_int() != my_ascensions())
	{
		return false;
	}
	
	// in softcore you will pull the war outfit, no need to get pre outfit
	if(!in_hardcore())
	{
		return false;
	}
	
	if(my_level() < 9)
	{
		return false;
	}
	
	if(haveWarOutfit())
	{
		return false;
	}
	
	// if siding with frat and already own [filthy hippy disguise] outfit needed to get the frat boy war outfit
	if (!get_property("auto_hippyInstead").to_boolean() && possessEquipment($item[filthy knitted dread sack]) && possessEquipment($item[filthy corduroys]))
	{
		return false;
	}
	
	// if siding with hippies and already own [frat boy ensemble] outfit needed to get the hippy war outfit
	if (get_property("auto_hippyInstead").to_boolean() && possessEquipment($item[orcish baseball cap]) && possessEquipment($item[orcish frat-paddle]) && possessEquipment($item[orcish cargo shorts]))
	{
		return false;
	}
	
	if (isActuallyEd())
	{
		if(!canYellowRay() && (my_level() < 12))
		{
			return false;
		}
	}

	if(have_skill($skill[Calculate the Universe]) && (my_daycount() == 1))
	{
		return false;
	}

	if((my_class() == $class[Gelatinous Noob]) && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Ink Gland]) && (item_amount($item[Shot of Granola Liqueur]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}

	// if we want to do war on the fratboy side, then we need to adventure in hippy camp for [filthy hippy disguise] outfit to then adventure in frat house for frat war outfit
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		auto_log_info("Trying to acquire a filthy hippy outfit", "blue");
		if(my_level() < 12)
		{
			autoAdv(1, $location[Hippy Camp]);
		}
		else
		{
			autoAdv(1, $location[Wartime Hippy Camp]);
		}
	}

	// if we want to do war on the hippy side, then we need to adventure in orcish frat house for [frat boy ensemble] outfit to then adventure in hippy camp for hippy war outfit
	if(get_property("auto_hippyInstead").to_boolean())
	{
		auto_log_info("Trying to acquire a frat boy ensemble", "blue");
		if(my_level() < 12)
		{
			autoAdv(1, $location[Frat House]);
		}
		else
		{
			autoAdv(1, $location[Wartime Frat House]);
		}
	}
	
	return true;	//the above ifs cover all possibilities so we had to have adventured somewhere just now. either frat house or hippy camp
}

boolean L12_startWar()
{
	if (internalQuestStatus("questL12War") != 0)
	{
		return false;
	}

	if (in_koe())
	{
		return false;
	}

	if (!haveWarOutfit() || my_basestat($stat[Mysticality]) < 70 || my_basestat($stat[Moxie]) < 70)
	{
		return false;
	}

	if(get_property("lastIslandUnlock").to_int() < my_ascensions())
	{
		return false;
	}

	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	
	buffMaintain($effect[Snow Shoes], 0, 1, 1);
	buffMaintain($effect[Become Superficially Interested], 0, 1, 1);
	providePlusNonCombat(25);

	if((my_path() != "Dark Gyffte") && (my_mp() > 50) && have_skill($skill[Incredible Self-Esteem]) && !get_property("_incredibleSelfEsteemCast").to_boolean())
	{
		use_skill(1, $skill[Incredible Self-Esteem]);
	}

	// set noncombats to value needed to start the war
	set_property("choiceAdventure142", "3");	//if wearing [Frat Warrior Fatigues] start the war or skip adventure
	set_property("choiceAdventure146", "3");	//if wearing [War Hippy Fatigues] start the war or skip adventure

	// wear the appropriate war outfit based on auto_hippyInstead
	warOutfit(false);

	// start the war when siding with frat boys
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		auto_log_info("Must save the ferret!!", "blue");
		autoAdv(1, $location[Wartime Hippy Camp]);
		
		//if war started accept side quests for junkyard, concert, and lighthouse
		if(contains_text(get_property("lastEncounter"), "Blockin\' Out the Scenery"))
		{
			visit_url("bigisland.php?action=junkman&pwd");
			visit_url("bigisland.php?place=concert&pwd");
			visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
			visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
		}
	}
	
	// start the war when siding with hippies
	if(get_property("auto_hippyInstead").to_boolean())
	{
		auto_log_info("Must save the goldfish!!", "blue");
		autoAdv(1, $location[Wartime Frat House]);
		
		//if war started accept side quests for farm, nuns, and orchard
		if(contains_text(get_property("lastEncounter"), "Fratacombs"))
		{
			visit_url("bigisland.php?place=farm&action=farmer&pwd=");
			visit_url("bigisland.php?place=nunnery");
			visit_url("bigisland.php?place=orchard&action=stand&pwd=");
		}
	}
		
	return true;
}

boolean L12_orchardStart()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestOrchardCompleted") != "none")
	{
		return false;
	}
	if (in_tcrs() || in_koe())
	{
		return false;
	}
	if((get_property("hippiesDefeated").to_int() < 64) && !get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}

	warOutfit(true);
	visit_url("bigisland.php?place=orchard&action=stand&pwd=");
	return true;
}

boolean L12_filthworms()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestOrchardCompleted") != "none")
	{
		return false;
	}
	if (in_tcrs() || in_koe())
	{
		return false;
	}
	if(item_amount($item[Heart of the Filthworm Queen]) > 0)
	{
		return false;
	}

	auto_log_info("Doing the orchard.", "blue");

	if(item_amount($item[Filthworm Hatchling Scent Gland]) > 0)
	{
		use(1, $item[Filthworm Hatchling Scent Gland]);
	}
	if(item_amount($item[Filthworm Drone Scent Gland]) > 0)
	{
		use(1, $item[Filthworm Drone Scent Gland]);
	}
	if(item_amount($item[Filthworm Royal Guard Scent Gland]) > 0)
	{
		use(1, $item[Filthworm Royal Guard Scent Gland]);
	}

	if(have_effect($effect[Filthworm Guard Stench]) > 0)
	{
		handleFamiliar("meat");
		autoAdv(1, $location[The Filthworm Queen\'s Chamber]);
		return true;
	}

	if(!have_skill($skill[Lash of the Cobra]))
	{
		buffMaintain($effect[Joyful Resolve], 0, 1, 1);
		buffMaintain($effect[Kindly Resolve], 0, 1, 1);
		buffMaintain($effect[Fortunate Resolve], 0, 1, 1);
		buffMaintain($effect[One Very Clear Eye], 0, 1, 1);
		buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
		buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
		buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
		buffMaintain($effect[Unusual Perspective], 0, 1, 1);
		buffMaintain($effect[Eagle Eyes], 0, 1, 1);
		asdonBuff($effect[Driving Observantly]);
		bat_formBats();

		if(get_property("auto_dickstab").to_boolean())
		{
			buffMaintain($effect[Wet and Greedy], 0, 1, 1);
		}
		buffMaintain($effect[Frosty], 0, 1, 1);
	}

	if((!possessEquipment($item[A Light That Never Goes Out])) && (item_amount($item[Lump of Brituminous Coal]) > 0))
	{
		buyUpTo(1, $item[third-hand lantern]);
		autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[third-hand lantern]);
	}

	if(possessEquipment($item[A Light That Never Goes Out]) && can_equip($item[A Light That Never Goes Out]))
	{
		if(weapon_hands(equipped_item($slot[weapon])) != 1)
		{
			equip($slot[weapon], $item[none]);
		}
		equip($item[A Light That Never Goes Out]);
	}

	handleFamiliar("item");
	if(item_amount($item[Training Helmet]) > 0)
	{
		equip($slot[hat], $item[Training Helmet]);
	}

	januaryToteAcquire($item[Broken Champagne Bottle]);
	if(item_amount($item[Broken Champagne Bottle]) > 0)
	{
		equip($item[Broken Champagne Bottle]);
	}

	if(auto_my_path() == "Live. Ascend. Repeat.")
	{
		if(item_drop_modifier() < 400.0)
		{
			abort("Can not handle item drop amount for the Filthworms, deja vu!! Either get us to +400% and rerun or do it yourself.");
		}
	}

	if(have_effect($effect[Filthworm Drone Stench]) > 0)
	{
		if(auto_have_familiar($familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() <= 10) && !is100FamiliarRun($familiar[XO Skeleton]))
		{
			handleFamiliar($familiar[XO Skeleton]);
		}
		autoAdv(1, $location[The Royal Guard Chamber]);
	}
	else if(have_effect($effect[Filthworm Larva Stench]) > 0)
	{
		if(auto_have_familiar($familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() <= 10) && !is100FamiliarRun($familiar[XO Skeleton]))
		{
			handleFamiliar($familiar[XO Skeleton]);
		}
		autoAdv(1, $location[The Feeding Chamber]);
	}
	else
	{
		if(auto_have_familiar($familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() <= 10) && !is100FamiliarRun($familiar[XO Skeleton]))
		{
			handleFamiliar($familiar[XO Skeleton]);
		}
		autoAdv(1, $location[The Hatching Chamber]);
	}
	handleFamiliar("item");
	return true;
}

boolean L12_orchardFinalize()
{
	if (get_property("hippiesDefeated").to_int() < 64 && !get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}
	if (get_property("sidequestOrchardCompleted") != "none" || item_amount($item[Heart of the Filthworm Queen]) == 0)
	{
		return false;
	}
	if(item_amount($item[A Light that Never Goes Out]) == 1)
	{
		pulverizeThing($item[A Light that Never Goes Out]);
	}
	warOutfit(true);
	visit_url("bigisland.php?place=orchard&action=stand&pwd=");
	visit_url("shop.php?whichshop=hippy");
	return true;
}

boolean L12_gremlins()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestJunkyardCompleted") != "none")
	{
		return false;
	}
	if (in_koe() || auto_my_path() == "Pocket Familiars")
	{
		return false;
	}
	if(get_property("auto_hippyInstead").to_boolean() && (get_property("fratboysDefeated").to_int() < 192))
	{
		return false;
	}
	if(auto_my_path() == "G-Lover")
	{
		int need = 30 - item_amount($item[Doc Galaktik\'s Pungent Unguent]);
		if((need > 0) && (item_amount($item[Molybdenum Pliers]) == 0))
		{
			int meatNeed = need * npc_price($item[Doc Galaktik\'s Pungent Unguent]);
			if(my_meat() < meatNeed)
			{
				return false;
			}
			buyUpTo(30, $item[Doc Galaktik\'s Pungent Unguent]);
		}
	}

	if(0 < have_effect($effect[Curse of the Black Pearl Onion])) {
		uneffect($effect[Curse of the Black Pearl Onion]);
	}

	if(item_amount($item[molybdenum magnet]) == 0)
	{
		abort("We don't have the molybdenum magnet but should... please get it and rerun the script");
	}

	if(auto_my_path() == "Disguises Delimit")
	{
		abort("Do gremlins manually, sorry. Or set sidequestJunkyardCompleted=fratboy and we will just skip them");
	}

	// Go into the fight with No Familiar Equips since maximizer wants to force an equip
	// this keeps us from accidentally killing gremlins
	addToMaximize("-familiar");

	#Put a different shield in here.
	auto_log_info("Doing them gremlins", "blue");
	addToMaximize("20dr,1da 1000max,3hp,-3ml");
	acquireHP();
	if(!bat_wantHowl($location[over where the old tires are]))
	{
		bat_formMist();
	}
	handleFamiliar("gremlins");
	songboomSetting("dr");
	if(item_amount($item[molybdenum hammer]) == 0)
	{
		autoAdv(1, $location[Next to that barrel with something burning in it], "auto_JunkyardCombatHandler");
		return true;
	}

	if(item_amount($item[molybdenum screwdriver]) == 0)
	{
		autoAdv(1, $location[Out by that rusted-out car], "auto_JunkyardCombatHandler");
		return true;
	}

	if(item_amount($item[molybdenum crescent wrench]) == 0)
	{
		autoAdv(1, $location[over where the old tires are], "auto_JunkyardCombatHandler");
		return true;
	}

	if(item_amount($item[Molybdenum Pliers]) == 0)
	{
		autoAdv(1, $location[near an abandoned refrigerator], "auto_JunkyardCombatHandler");
		return true;
	}
	handleFamiliar("item");
	warOutfit(true);
	visit_url("bigisland.php?action=junkman&pwd");
	return true;
}

boolean L12_sonofaBeach()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestLighthouseCompleted") != "none")
	{
		return false;
	}
	if (in_koe())
	{
		return false;
	}
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		if (get_property("sidequestJunkyardCompleted") == "none")
		{
			return false;
		}
	}
	if((get_property("fratboysDefeated").to_int() < 64) && get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) >= 5)
	{
		return false;
	}

	if(auto_my_path() == "Pocket Familiars")
	{
		if(contains_text($location[Sonofa Beach].combat_queue, to_string($monster[Lobsterfrogman])))
		{
			if(timeSpinnerCombat($monster[Lobsterfrogman], ""))
			{
				return true;
			}
		}
	}

	if(chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && (get_property("chateauMonster") == $monster[Lobsterfrogman]))
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(chateaumantegna_usePainting())
		{
			handleFamiliar("item");
			return true;
		}
	}

	if (isActuallyEd() && item_amount($item[Talisman of Horus]) == 0 && have_effect($effect[Taunt of Horus]) == 0)
	{
		return false;
	}

	//Seriously? http://alliancefromhell.com/viewtopic.php?t=1338
	if(item_amount($item[Wool Hat]) == 1)
	{
		pulverizeThing($item[Wool Hat]);
	}
	if(item_amount($item[Goatskin Umbrella]) == 1)
	{
		pulverizeThing($item[Goatskin Umbrella]);
	}

	if(auto_my_path() != "Live. Ascend. Repeat.")
	{
		if(!providePlusCombat(25, true))
		{
			auto_log_warning("Failure in +Combat acquisition or -Combat shrugging (lobsterfrogman), delaying", "red");
			equipBaseline();
			return false;
		}

		if(equipped_item($slot[acc1]) == $item[over-the-shoulder folder holder])
		{
			if((item_amount($item[Ass-Stompers of Violence]) > 0) && (equipped_item($slot[acc1]) != $item[Ass-Stompers of Violence]) && can_equip($item[Ass-Stompers of Violence]))
			{
				equip($slot[acc1], $item[Ass-Stompers of Violence]);
			}
			else
			{
				equip($slot[acc1], $item[bejeweled pledge pin]);
			}
		}
		if(item_amount($item[portable cassette player]) > 0)
		{
			equip($slot[acc2], $item[portable cassette player]);
		}
		if(numeric_modifier("Combat Rate") <= 9.0)
		{
			if(possessEquipment($item[Carpe]))
			{
				equip($slot[Back], $item[Carpe]);
			}
		}
		asdonBuff($effect[Driving Obnoxiously]);

		if(numeric_modifier("Combat Rate") < 0.0)
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Lobsterfrogmen.", "red");
			equipBaseline();
			return false;
		}
	}

	if(item_amount($item[barrel of gunpowder]) < 4)
	{
		set_property("auto_doCombatCopy", "yes");
	}

	autoAdv(1, $location[Sonofa Beach]);
	set_property("auto_doCombatCopy", "no");
	handleFamiliar("item");

	if (isActuallyEd() && my_hp() == 0)
	{
		use(1, $item[Linen Bandages]);
	}
	return true;
}

boolean L12_sonofaPrefix()
{
	// this appears to be a copy & paste of L12_sonofaBeach() with some small changes
	// for Vote Monster/Macrometeor shenanigans. Refactor this so only the relevant code remains.

	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestLighthouseCompleted") != "none")
	{
		return false;
	}
	if(L12_sonofaFinish())
	{
		return true;
	}

	if(in_koe())
	{
		return false;
	}

	if(get_property("_sourceTerminalDigitizeMonster") == $monster[Lobsterfrogman])
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) >= 4 && !auto_voteMonster())
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) >= 5)
	{
		return false;
	}

	if(chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && (get_property("chateauMonster") == $monster[Lobsterfrogman]))
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(chateaumantegna_usePainting())
		{
			handleFamiliar("stat");
			return true;
		}
	}

	if(!(auto_get_campground() contains $item[Source Terminal]))
	{
		if((auto_voteMonster() || auto_sausageGoblin()) && adjustForReplaceIfPossible())
		{
			try
			{
				if(item_amount($item[barrel of gunpowder]) < 4)
				{
					set_property("auto_doCombatCopy", "yes");
				}
				if (auto_voteMonster())
				{
					auto_voteMonster(false, $location[Sonofa Beach], "");
					return true;
				}
				else if (auto_sausageGoblin())
				{
					auto_sausageGoblin($location[Sonofa Beach], "");
					return true;
				}
			}
			finally
			{
				set_property("auto_combatDirective", "");
				set_property("auto_doCombatCopy", "no");
			}
		}
		return false;
	}

	if (isActuallyEd() && item_amount($item[Talisman of Horus]) == 0 && have_effect($effect[Taunt of Horus]) == 0)
	{
		return false;
	}

	if(in_koe())
	{
		return false;
	}

	//Seriously? http://alliancefromhell.com/viewtopic.php?t=1338
	if(item_amount($item[Wool Hat]) == 1)
	{
		pulverizeThing($item[Wool Hat]);
	}
	if(item_amount($item[Goatskin Umbrella]) == 1)
	{
		pulverizeThing($item[Goatskin Umbrella]);
	}

	if(auto_my_path() != "Live. Ascend. Repeat.")
	{
		if(!providePlusCombat(25))
		{
			auto_log_warning("Failure in +Combat acquisition or -Combat shrugging (lobsterfrogman), delaying", "red");
			return false;
		}

		if(equipped_item($slot[acc1]) == $item[over-the-shoulder folder holder])
		{
			if((item_amount($item[Ass-Stompers of Violence]) > 0) && (equipped_item($slot[acc1]) != $item[Ass-Stompers of Violence]) && can_equip($item[Ass-Stompers of Violence]))
			{
				equip($slot[acc1], $item[Ass-Stompers of Violence]);
			}
			else
			{
				equip($slot[acc1], $item[bejeweled pledge pin]);
			}
		}
		if(item_amount($item[portable cassette player]) > 0)
		{
			equip($slot[acc2], $item[portable cassette player]);
		}
		if(numeric_modifier("Combat Rate") <= 9.0)
		{
			if(possessEquipment($item[Carpe]))
			{
				equip($slot[Back], $item[Carpe]);
			}
		}
		if(numeric_modifier("Combat Rate") < 0.0)
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Lobsterfrogmen.", "red");
			equipBaseline();
			return false;
		}
	}

	if(item_amount($item[barrel of gunpowder]) < 4)
	{
		set_property("auto_doCombatCopy", "yes");
	}

	if((my_mp() < mp_cost($skill[Digitize])) && (auto_get_campground() contains $item[Source Terminal]) && is_unrestricted($item[Source Terminal]) && (get_property("_sourceTerminalDigitizeMonster") != $monster[Lobsterfrogman]) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3))
	{
		equipBaseline();
		return false;
	}

	if(possessEquipment($item[&quot;I voted!&quot; sticker]) && (my_adventures() > 15))
	{
		if(have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
		{
			if(auto_voteMonster())
			{
				set_property("auto_combatDirective", "start;skill macrometeorite");
				autoEquip($slot[acc3], $item[&quot;I voted!&quot; sticker]);
			}
			else
			{
				return false;
			}
		}
	}

	auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);

	autoAdv(1, $location[Sonofa Beach]);
	set_property("auto_combatDirective", "");
	set_property("auto_doCombatCopy", "no");
	handleFamiliar("item");

	if (isActuallyEd() && my_hp() == 0)
	{
		use(1, $item[Linen Bandages]);
	}
	return true;
}

boolean L12_sonofaFinish()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestLighthouseCompleted") != "none")
	{
		return false;
	}
	if (in_koe())
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) < 5)
	{
		return false;
	}
	if(!haveWarOutfit())
	{
		return false;
	}
	if((get_property("fratboysDefeated").to_int() < 64) && get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}

	warOutfit(true);
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	return true;
}

boolean L12_flyerBackup()
{
	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}
	if(get_property("flyeredML").to_int() >= 10000)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}
	if(get_property("choiceAdventure1003").to_int() >= 3)
	{
		return false;
	}
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}

	return LX_freeCombats();
}

boolean L12_lastDitchFlyer()
{
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestArenaCompleted") != "none" || get_property("flyeredML").to_int() >= 10000)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}

	auto_log_info("Not enough flyer ML but we are ready for the war... uh oh", "blue");

	if (needStarKey())
	{
		if (!zone_isAvailable($location[The Hole in the Sky]))
		{
			return (L10_topFloor() || L10_holeInTheSkyUnlock());
		}
		else
		{
			handleFamiliar("item");
			if(LX_getStarKey())
			{
				return true;
			}
		}
		return true;
	}
	else
	{
		auto_log_warning("Should not have so little flyer ML at this point", "red");
		wait(1);
		if(!LX_attemptFlyering())
		{
			abort("Need more flyer ML but don't know where to go :(");
		}
		return true;
	}
}

boolean LX_attemptFlyering()
{
	if(elementalPlanes_access($element[stench]) && auto_have_skill($skill[Summon Smithsness]))
	{
		return autoAdv(1, $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]);
	}
	else if(elementalPlanes_access($element[spooky]))
	{
		return autoAdv(1, $location[The Deep Dark Jungle]);
	}
	else if(elementalPlanes_access($element[cold]))
	{
		return autoAdv(1, $location[VYKEA]);
	}
	else if(elementalPlanes_access($element[stench]))
	{
		return autoAdv(1, $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]);
	}
	else if(elementalPlanes_access($element[sleaze]))
	{
		return autoAdv(1, $location[Sloppy Seconds Diner]);
	}
	else if(neverendingPartyAvailable())
	{
		return neverendingPartyPowerlevel();
	}
	else
	{
		int flyer = get_property("flyeredML").to_int();
		boolean retval = autoAdv($location[Near an Abandoned Refrigerator]);
		if (flyer == get_property("flyeredML").to_int())
		{
			abort("Trying to flyer but failed to flyer");
		}
		set_property("auto_newbieOverride", true);
		return retval;
	}
	return false;
}

boolean L12_flyerFinish()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}
	if(get_property("flyeredML").to_int() < 10000)
	{
		if(get_property("sidequestArenaCompleted") != "none")
		{
			auto_log_warning("Sidequest Arena detected as completed but flyeredML is not appropriate, fixing.", "red");
			set_property("flyeredML", 10000);
		}
		else
		{
			return false;
		}
	}
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}
	auto_log_info("Done with this Flyer crap", "blue");
	warOutfit(true);
	visit_url("bigisland.php?place=concert&pwd");

	cli_execute("refresh inv");
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return true;
	}
	auto_log_warning("We thought we had enough flyeredML, but we don't. Big sadness, let's try that again.", "red");
	set_property("flyeredML", 9999);
	return false;
}

boolean L12_themtharHills()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1 || get_property("sidequestNunsCompleted") != "none")
	{
		return false;
	}

	if (in_tcrs() || in_koe() || auto_my_path() == "Way of the Surprising Fist")
	{
		return false;
	}

	if ((get_property("hippiesDefeated").to_int() < 192 && !get_property("auto_hippyInstead").to_boolean()) || get_property("auto_skipNuns").to_boolean())
	{
		return false;
	}
	else
	{
		auto_log_info("Themthar Nuns!", "blue");
	}

	if((get_property("sidequestArenaCompleted") == "fratboy") && !get_property("concertVisited").to_boolean() && (have_effect($effect[Winklered]) == 0))
	{
		outfit("frat warrior fatigues");
		cli_execute("concert 2");
	}

	handleBjornify($familiar[Hobo Monkey]);
	if((equipped_item($slot[off-hand]) != $item[Half a Purse]) && !possessEquipment($item[Half a Purse]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
	{
		buyUpTo(1, $item[Loose Purse Strings]);
		autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Loose purse strings]);
	}

	autoEquip($item[Half a Purse]);
	if(auto_my_path() == "Heavy Rains")
	{
		autoEquip($item[Thor\'s Pliers]);
	}
	autoEquip($item[Miracle Whip]);

	shrugAT($effect[Polka of Plenty]);
	if (isActuallyEd())
	{
		if(!have_skill($skill[Gift of the Maid]) && ($servant[Maid].experience >= 441))
		{
			visit_url("charsheet.php");
			if(have_skill($skill[Gift of the Maid]))
			{
				auto_log_warning("Gift of the Maid not properly detected until charsheet refresh.", "red");
			}
		}
	}
	buffMaintain($effect[Purr of the Feline], 10, 1, 1);
	songboomSetting("meat");

	if(is100FamiliarRun())
	{
		addToMaximize("200meat drop");
	}
	else
	{
		addToMaximize("200meat drop,switch Hobo Monkey,switch rockin' robin,switch adventurous spelunker,switch Grimstone Golem,switch Fist Turkey,switch Unconscious Collective,switch Golden Monkey,switch Angry Jung Man,switch Leprechaun,switch cat burglar");
		handleFamiliar(my_familiar());
	}
	int expectedMeat = simValue("Meat Drop");


	if(get_property("auto_useWishes").to_boolean())
	{
		makeGenieWish($effect[Frosty]);
	}
	buffMaintain($effect[Greedy Resolve], 0, 1, 1);
	buffMaintain($effect[Disco Leer], 10, 1, 1);
	buffMaintain($effect[Polka of Plenty], 8, 1, 1);
	#Handle for familiar weight change.
	buffMaintain($effect[Kindly Resolve], 0, 1, 1);
	buffMaintain($effect[Heightened Senses], 0, 1, 1);
	buffMaintain($effect[Big Meat Big Prizes], 0, 1, 1);
	buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Constellation Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
	buffMaintain($effect[Cranberry Cordiality], 0, 1, 1);
	buffMaintain($effect[Patent Avarice], 0, 1, 1);
	if(item_amount($item[body spradium]) > 0 && !in_tcrs() && have_effect($effect[Boxing Day Glow]) == 0)
	{
		autoChew(1, $item[body spradium]);
	}
	if(have_effect($effect[meat.enh]) == 0)
	{
		if(auto_sourceTerminalEnhanceLeft() > 0)
		{
			auto_sourceTerminalEnhance("meat");
		}
	}
	if(have_effect($effect[Synthesis: Greed]) == 0)
	{
		rethinkingCandy($effect[Synthesis: Greed]);
	}
	asdonBuff($effect[Driving Observantly]);



	handleFamiliar("meat");
	if(auto_have_familiar($familiar[Trick-or-Treating Tot]) && (available_amount($item[Li\'l Pirate Costume]) > 0) && !is100FamiliarRun($familiar[Trick-or-Treating Tot]) && (auto_my_path() != "Heavy Rains"))
	{
		use_familiar($familiar[Trick-or-Treating Tot]);
		autoEquip($item[Li\'l Pirate Costume]);
		handleFamiliar($familiar[Trick-or-Treating Tot]);
	}

	if(auto_my_path() == "Heavy Rains")
	{
		buffMaintain($effect[Sinuses For Miles], 0, 1, 1);
	}
	// Target 1000 + 400% = 5000 meat per brigand. Of course we want more, but don\'t bother unless we can get this.
	float meat_need = 400.00;
	if(item_amount($item[Mick\'s IcyVapoHotness Inhaler]) > 0)
	{
		meat_need = meat_need - 200;
	}
	if((my_class() == $class[Vampyre]) && have_skill($skill[Wolf Form]) && (0 == have_effect($effect[Wolf Form])))
	{
		meat_need = meat_need - 150;
	}
	if(zataraAvailable() && (0 == have_effect($effect[Meet the Meat])))
	{
		meat_need = meat_need - 100;
	}

	use_familiar(to_familiar(get_property("auto_familiarChoice")));
	float meatDropHave = meat_drop_modifier();

	if (isActuallyEd() && have_skill($skill[Curse of Fortune]) && item_amount($item[Ka Coin]) > 0)
	{
		meatDropHave = meatDropHave + 200;
	}
	if(meatDropHave < meat_need)
	{
		auto_log_warning("Meat drop (" + meatDropHave+ ") is pretty low, (we want: " + meat_need + ") probably not worth it to try this.", "red");

		float minget = 800.00 * (meatDropHave / 100.0);
		int meatneed = 100000 - get_property("currentNunneryMeat").to_int();
		auto_log_info("The min we expect is: " + minget + " and we need: " + meatneed, "blue");

		if(minget < meatneed)
		{
			int curMeat = get_property("currentNunneryMeat").to_int();
			int advs = $location[The Themthar Hills].turns_spent;
			int needMeat = 100000 - curMeat;

			boolean failNuns = true;
			if(advs < 25)
			{
				int advLeft = 25 - $location[The Themthar Hills].turns_spent;
				float needPerAdv = needMeat / advLeft;
				if(minget > needPerAdv)
				{
					auto_log_info("We don't have the desired +meat but should be able to complete the nuns to our advantage", "green");
					failNuns = false;
				}
			}

			if(failNuns)
			{
				handleFamiliar("item");
				set_property("auto_skipNuns", "true");
				return false;
			}
		}
		else
		{
			auto_log_info("The min should be enough! Doing it!!", "purple");
		}
	}


	buffMaintain($effect[Disco Leer], 10, 1, 1);
	buffMaintain($effect[Polka of Plenty], 8, 1, 1);
	buffMaintain($effect[Sinuses For Miles], 0, 1, 1);
	buffMaintain($effect[Greedy Resolve], 0, 1, 1);
	buffMaintain($effect[Kindly Resolve], 0, 1, 1);
	buffMaintain($effect[Heightened Senses], 0, 1, 1);
	buffMaintain($effect[Big Meat Big Prizes], 0, 1, 1);
	buffMaintain($effect[Fortunate Resolve], 0, 1, 1);
	buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Constellation Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
	buffMaintain($effect[Cranberry Cordiality], 0, 1, 1);
	bat_formWolf();
	zataraSeaside("meat");

	{
		warOutfit(false);

		int lastMeat = get_property("currentNunneryMeat").to_int();
		int myLastMeat = my_meat();
		auto_log_info("Meat drop to start: " + meat_drop_modifier(), "blue");
		if(!autoAdv(1, $location[The Themthar Hills]))
		{
			//Maybe we passed it!
			string temp = visit_url("bigisland.php?place=nunnery");
		}
		if(last_monster() != $monster[dirty thieving brigand])
		{
			return true;
		}
		if(get_property("lastEncounter") != $monster[Dirty Thieving Brigand])
		{
			return true;
		}

		int curMeat = get_property("currentNunneryMeat").to_int();
		if(lastMeat == curMeat)
		{
			int diffMeat = my_meat() - myLastMeat;
			set_property("currentNunneryMeat", diffMeat);
		}

		int advs = $location[The Themthar Hills].turns_spent + 1;

		int diffMeat = curMeat - lastMeat;
		int needMeat = 100000 - curMeat;
		int average = curMeat / advs;
		auto_log_info("Cur Meat: " + curMeat + " Average: " + average, "blue");

		diffMeat = diffMeat * 1.2;
		average = average * 1.2;
	}
	handleFamiliar("item");
	return true;
}

boolean L12_clearBattlefield()
{
	if(in_koe())
	{
		if (internalQuestStatus("questL12HippyFrat") < 2 && get_property("hippiedDefeated").to_int() < 333 && get_property("fratboysDefeated").to_int() < 333 && can_equip($item[Distressed denim pants]) && can_equip($item[beer helmet]) && can_equip($item[bejeweled pledge pin]))
		{
			handleFamiliar("item");
			if(haveWarOutfit())
			{
				warOutfit(false);
			}

			item warKillDoubler = my_primestat() == $stat[mysticality] ? $item[Jacob\'s rung] : $item[Haunted paddle-ball];
			pullXWhenHaveY(warKillDoubler, 1, 0);
			if(possessEquipment(warKillDoubler))
			{
				autoEquip($slot[weapon], warKillDoubler);
			}

			item food_item = $item[none];
			foreach it in $items[pie man was not meant to eat, spaghetti with Skullheads, gnocchetti di Nietzsche, Spaghetti con calaveras, space chowder, Spaghetti with ghost balls, Crudles, Agnolotti arboli, Shells a la shellfish, Linguini immondizia bianco, Fettucini Inconnu, ghuol guolash, suggestive strozzapreti, Fusilli marrownarrow]
			{
				if(item_amount(it) > 0)
				{
					food_item = it;
					break;
				}
			}
			if(food_item == $item[none])
			{
				if(creatable_amount($item[space chowder]) > 6)
				{
					create(1, $item[space chowder]);
					food_item = $item[space chowder];
				}
				else
				{
					abort("Couldn't find a good food item for the war.");
				}
			}

			// TODO: Mafia should really be tracking this.
			if(!autoAdvBypass("adventure.php?snarfblat=533", $location[The Exploaded Battlefield]))
			{
				if(get_property("lastEncounter") == "Rationing out Destruction")
				{
					visit_url("choice.php?whichchoice=1391&option=1&tossid=" + food_item.to_int() + "&pwd=" + my_hash(), true);
				}
			}

			if(item_amount($item[solid gold bowling ball]) > 0)
			{
				council();
			}
			return true;
		}
		return false;
	}
	else
	{
		if (get_property("hippiesDefeated").to_int() < 64 && get_property("fratboysDefeated").to_int() < 64 && internalQuestStatus("questL12War") == 1)
		{
			auto_log_info("First 64 combats. To orchard/lighthouse", "blue");
			if((item_amount($item[Stuffing Fluffer]) == 0) && (item_amount($item[Cashew]) >= 3))
			{
				cli_execute("make 1 stuffing fluffer");
			}
			if((item_amount($item[Stuffing Fluffer]) == 0) && (item_amount($item[Cornucopia]) > 0) && glover_usable($item[Cornucopia]))
			{
				use(1, $item[Cornucopia]);
				if((item_amount($item[Stuffing Fluffer]) == 0) && (item_amount($item[Cashew]) >= 3))
				{
					cli_execute("make 1 stuffing fluffer");
				}
				return true;
			}
			if(item_amount($item[Stuffing Fluffer]) > 0)
			{
				use(1, $item[Stuffing Fluffer]);
				return true;
			}
			handleFamiliar("item");
			warOutfit(false);
			return warAdventure();
		}

		if (get_property("hippiesDefeated").to_int() < 192 && get_property("fratboysDefeated").to_int() < 192 && internalQuestStatus("questL12War") == 1)
		{
			auto_log_info("Getting to the nunnery/junkyard", "blue");
			handleFamiliar("item");
			warOutfit(false);
			return warAdventure();
		}

		if ((get_property("sidequestNunsCompleted") != "none" || get_property("auto_skipNuns").to_boolean()) && (get_property("hippiesDefeated").to_int() < 1000 && get_property("fratboysDefeated").to_int() < 1000) && internalQuestStatus("questL12War") == 1)
		{
			auto_log_info("Doing the wars.", "blue");
			handleFamiliar("item");
			warOutfit(false);
			return warAdventure();
		}
	}
	return false;
}

boolean L12_finalizeWar()
{
	if (internalQuestStatus("questL12War") < 1 || internalQuestStatus("questL12War") > 1)
	{
		return false;
	}

	if (get_property("hippiesDefeated").to_int() < 1000 && get_property("fratsDefeated").to_int() < 1000)
	{
		return false;
	}

	if(have_outfit("War Hippy Fatigues"))
	{
		auto_log_info("Getting dimes.", "blue");
		foreach it in $items[padl phone, red class ring, blue class ring, white class ring]
		{
			sell(it.buyer, item_amount(it), it);
		}
		foreach it in $items[beer helmet, distressed denim pants, bejeweled pledge pin]
		{
			sell(it.buyer, item_amount(it) - 1, it);
		}
		if (isActuallyEd())
		{
			foreach it in $items[kick-ass kicks, perforated battle paddle, bottle opener belt buckle, keg shield, giant foam finger, war tongs, energy drink IV, Elmley shades, beer bong]
			{
				sell(it.buyer, item_amount(it), it);
			}
		}
	}
	if(have_outfit("Frat Warrior Fatigues"))
	{
		auto_log_info("Getting quarters.", "blue");
		foreach it in $items[pink clay bead, purple clay bead, green clay bead, communications windchimes]
		{
			sell(it.buyer, item_amount(it), it);
		}
		foreach it in $items[bullet-proof corduroys, round purple sunglasses, reinforced beaded headband]
		{
			sell(it.buyer, item_amount(it) - 1, it);
		}
		if (isActuallyEd())
		{
			foreach it in $items[hippy protest button, Lockenstock&trade; sandals, didgeridooka, wicker shield, oversized pipe, fire poi, Gaia beads, hippy medical kit, flowing hippy skirt, round green sunglasses]
			{
				sell(it.buyer, item_amount(it), it);
			}
		}
	}

	// Just in case we need the extra turngen to complete this day
	if (my_class() == $class[Vampyre])
	{
		int have = item_amount($item[monstar energy beverage]) + item_amount($item[carbonated soy milk]);
		if(have < 5)
		{
			int need = 5 - have;
			if(!get_property("auto_hippyInstead").to_boolean())
			{
				need = min(need, $coinmaster[Quartersmaster].available_tokens / 3);
				cli_execute("make " + need + " Monstar energy beverage");
			}
			else
			{
				need = min(need, $coinmaster[Dimemaster].available_tokens / 3);
				cli_execute("make " + need + " carbonated soy milk");
			}
		}
	}

	int have = item_amount($item[filthy poultice]) + item_amount($item[gauze garter]);
	if (have < 10 && !isActuallyEd())
	{
		int need = 10 - have;
		if(!get_property("auto_hippyInstead").to_boolean())
		{
			need = min(need, $coinmaster[Quartersmaster].available_tokens / 2);
			cli_execute("make " + need + " gauze garter");
		}
		else
		{
			need = min(need, $coinmaster[Dimemaster].available_tokens / 2);
			cli_execute("make " + need + " filthy poultice");
		}
	}

	if(have_outfit("War Hippy Fatigues"))
	{
		while($coinmaster[Dimemaster].available_tokens >= 5)
		{
			cli_execute("make " + $coinmaster[Dimemaster].available_tokens/5 + " fancy seashell necklace");
		}
		while($coinmaster[Dimemaster].available_tokens >= 2)
		{
			cli_execute("make " + $coinmaster[Dimemaster].available_tokens/2 + " filthy poultice");
		}
		while($coinmaster[Dimemaster].available_tokens >= 1)
		{
			cli_execute("make " + $coinmaster[Dimemaster].available_tokens + " water pipe bomb");
		}
	}

	if(have_outfit("Frat Warrior Fatigues"))
	{
		while($coinmaster[Quartersmaster].available_tokens >= 5)
		{
			cli_execute("make " + $coinmaster[Quartersmaster].available_tokens/5 + " commemorative war stein");
		}
		while($coinmaster[Quartersmaster].available_tokens >= 2)
		{
			cli_execute("make " + $coinmaster[Quartersmaster].available_tokens/2 + " gauze garter");
		}
		while($coinmaster[Quartersmaster].available_tokens >= 1)
		{
			cli_execute("make " + $coinmaster[Quartersmaster].available_tokens + " beer bomb");
		}
	}

	if(my_mp() < 40)
	{
		// fyi https://kol.coldfront.net/thekolwiki/index.php/Chateau_Mantegna states you wont get pantsgiving benefits resting there (presumably campsite as well)
		// so not sure this is doing much
		if(possessEquipment($item[Pantsgiving]))
		{
			equip($item[pantsgiving]);
		}
		doRest();
	}
	warOutfit(false);
	acquireHP();
	auto_log_info("Let's fight the boss!", "blue");

	location bossFight = $location[Noob Cave];

	if (in_koe())
	{
		bossFight = 533.to_location();
	}

	if(auto_have_familiar($familiar[Machine Elf]))
	{
		handleFamiliar($familiar[Machine Elf]);
	}
	string[int] pages;
	if (!in_koe())
	{
		pages[0] = "bigisland.php?place=camp&whichcamp=1";
		pages[1] = "bigisland.php?place=camp&whichcamp=2";
		pages[2] = "bigisland.php?action=bossfight&pwd";
	}
	if(!autoAdvBypass(0, pages, bossFight, ""))
	{
		auto_log_warning("Boss already defeated, ignoring", "red");
	}

	if(auto_my_path() == "Pocket Familiars")
	{
		string temp = visit_url("island.php");
		council();
	}

	cli_execute("refresh quests");
	if (internalQuestStatus("questL12War") == 1)
	{
		abort("Failing to complete the war.");
	}
	council();
	return true;
}
