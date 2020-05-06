script "auto_quest_level_9.ash"

boolean L9_leafletQuest()
{
	if((my_level() < 9) || possessEquipment($item[Giant Pinky Ring]))
	{
		return false;
	}
	if (isActuallyEd() || in_koe())
	{
		return false;
	}
	if(auto_get_campground() contains $item[Frobozz Real-Estate Company Instant House (TM)])
	{
		return false;
	}
	if(item_amount($item[Frobozz Real-Estate Company Instant House (TM)]) > 0)
	{
		return false;
	}
	auto_log_info("Got a leaflet to do", "blue");
	council();
	cli_execute("leaflet");
	use(1, $item[Frobozz Real-Estate Company Instant House (TM)]);
	return true;
}

void L9_chasmMaximizeForNoncombat()
{
	auto_log_info("Let's assess our scores for blech house", "blue");
	string best = "mus";
	string mustry = "100muscle,100weapon damage,1000weapon damage percent";
	string mystry = "100mysticality,100spell damage,1000 spell damage percent";
	string moxtry = "100moxie,1000sleaze resistance";
	simMaximizeWith(mustry);
	float musmus = simValue("Buffed Muscle");
	float musflat = simValue("Weapon Damage");
	float musperc = simValue("Weapon Damage Percent");
	int musscore = floor(square_root((musmus + musflat)/15*(1+musperc/100)));
	auto_log_info("Muscle score: " + musscore, "blue");
	simMaximizeWith(mystry);
	float mysmys = simValue("Buffed Mysticality");
	float mysflat = simValue("Spell Damage");
	float mysperc = simValue("Spell Damage Percent");
	int mysscore = floor(square_root((mysmys + mysflat)/15*(1+mysperc/100)));
	auto_log_info("Mysticality score: " + mysscore, "blue");
	if(mysscore > musscore)
	{
		best = "mys";
	}
	simMaximizeWith(moxtry);
	float moxmox = simValue("Buffed Moxie");
	float moxres = simValue("Sleaze Resistance");
	int moxscore = floor(square_root(moxmox/30*(1+moxres*0.69)));
	auto_log_info("Moxie score: " + moxscore, "blue");
	if(moxscore > mysscore && moxscore > musscore)
	{
		best = "mox";
	}
	switch(best)
	{
		case "mus":
			addToMaximize(mustry);
			set_property("choiceAdventure1345", 1);
			break;
		case "mys":
			addToMaximize(mystry);
			set_property("choiceAdventure1345", 2);
			break;
		case "mox":
			addToMaximize(moxtry);
			set_property("choiceAdventure1345", 3);
			break;
	}
}

boolean L9_chasmBuild()
{
	if (internalQuestStatus("questL09Topping") < 0 || get_property("chasmBridgeProgress").to_int() >= 30 || internalQuestStatus("questL09Topping") > 0)
	{
		return false;
	}

	if (shenShouldDelayZone($location[The Smut Orc Logging Camp]))
	{
		auto_log_debug("Delaying Logging Camp in case of Shen.");
		return false;
	}


	auto_log_info("Chasm time", "blue");

	if(item_amount($item[fancy oil painting]) > 0)
	{
		visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
	}

	// -Combat is useless here since NC is triggered by killing Orcs...So we kill orcs better!
	// -ML helps us deal more cold damage and trigger the NC faster.
	asdonBuff($effect[Driving Intimidatingly]);

	// Check our Load out to see if spells are the best option for Orc-Thumping
	boolean useSpellsInOrcCamp = false;
	if(setFlavour($element[cold]) && canUse($skill[Stuffed Mortar Shell]))
	{
		useSpellsInOrcCamp = true;
	}

	if(setFlavour($element[cold]) && canUse($skill[Cannelloni Cannon], false))
	{
		useSpellsInOrcCamp = true;
	}

	if(canUse($skill[Saucegeyser], false))
	{
		useSpellsInOrcCamp = true;
	}

	if(canUse($skill[Saucecicle], false))
	{
		useSpellsInOrcCamp = true;
	}

	// Always Maximize and choose our default Non-Com First, in case we are wrong about the non-com we MAY have some gear still equipped to help us.
	if(useSpellsInOrcCamp == true)
	{
		auto_log_info("Preparing to Blast Orcs with Cold Spells!", "blue");
		addToMaximize("myst,40spell damage,80spell damage percent,40cold spell damage,-1000 ml");
		buffMaintain($effect[Carol of the Hells], 50, 1, 1);
		buffMaintain($effect[Song of Sauce], 150, 1, 1);

		auto_log_info("If we encounter Blech House when we are not expecting it we will stop.", "blue");
		auto_log_info("Currently setup for Myst/Spell Damage, option 2: Blast it down with a spell", "blue");
		set_property("choiceAdventure1345", 0);
	}
	else
	{
		auto_log_info("Preparing to Ice-Punch Orcs!", "blue");
		addToMaximize("muscle,40weapon damage,60weapon damage percent,40cold damage,-1000 ml");
		buffMaintain($effect[Carol of the Bulls], 50, 1, 1);
		buffMaintain($effect[Song of The North], 150, 1, 1);

		auto_log_info("If we encounter Blech House when we are not expecting it we will stop.", "blue");
		auto_log_info("Currently setup for Muscle/Weapon Damage, option 1: Kick it down", "blue");
		set_property("choiceAdventure1345", 0);
	}

	if(get_property("smutOrcNoncombatProgress").to_int() == 15)
	{
		// If we think the non-com will hit NOW we clear maximizer to keep previous settings from carrying forward
		resetMaximize();

		auto_log_info("The smut orc noncombat is about to hit...");
		// This is a hardcoded patch for Dark Gyffte
		// TODO: once explicit formulas are spaded, use simulated maximizer
		// to determine best approach.
		L9_chasmMaximizeForNoncombat();
		autoAdv(1, $location[The Smut Orc Logging Camp]);
		return true;
	}

	if (in_zelda() && possessEquipment($item[frosty button]))
	{
		autoEquip($item[frosty button]);
	}

	if(in_hardcore())
	{
		int need = (30 - get_property("chasmBridgeProgress").to_int());
		if(L9_ed_chasmBuildClover(need))
		{
			return true;
		}

		if((my_class() == $class[Gelatinous Noob]) && auto_have_familiar($familiar[Robortender]))
		{
			if(!have_skill($skill[Powerful Vocal Chords]) && (item_amount($item[Baby Oil Shooter]) == 0))
			{
				handleFamiliar($familiar[Robortender]);
			}
		}

		foreach it in $items[Loadstone, Logging Hatchet]
		{
			autoEquip(it);
		}

		autoAdv(1, $location[The Smut Orc Logging Camp]);

		if(item_amount($item[Smut Orc Keepsake Box]) > 0)
		{
			if(auto_my_path() != "G-Lover")
			{
				use(1, $item[Smut Orc Keepsake Box]);
			}
		}
		visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		if(get_property("chasmBridgeProgress").to_int() >= 30)
		{
			visit_url("place.php?whichplace=highlands&action=highlands_dude");
		}
		return true;
	}

	int need = (30 - get_property("chasmBridgeProgress").to_int()) / 5;
	if(need > 0)
	{
		while((need > 0) && (item_amount($item[Snow Berries]) >= 2))
		{
			cli_execute("make 1 snow boards");
			need = need - 1;
			visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		}
	}

	if (get_property("chasmBridgeProgress").to_int() < 30)
	{
		foreach it in $items[Loadstone, Logging Hatchet]
		{
			autoEquip(it);
		}

		autoAdv(1, $location[The Smut Orc Logging Camp]);
		if(item_amount($item[Smut Orc Keepsake Box]) > 0)
		{
			if(auto_my_path() != "G-Lover")
			{
				use(1, $item[Smut Orc Keepsake Box]);
			}
		}
		visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		return true;
	}
	visit_url("place.php?whichplace=highlands&action=highlands_dude");
	return true;
}

boolean L9_aBooPeak()
{
	if (internalQuestStatus("questL09Topping") < 2 || internalQuestStatus("questL09Topping") > 3)
	{
		return false;
	}
	
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire1.gif"))
	{
		return false;
	}

	item clue = $item[A-Boo Clue];
	if(auto_my_path() == "G-Lover")
	{
		if((item_amount($item[A-Boo Glue]) > 0) && (item_amount(clue) > 0))
		{
			use(1, $item[A-Boo Glue]);
		}
		clue = $item[Glued A-Boo Clue];
	}
	int clueAmt = item_amount(clue);

	if (get_property("booPeakProgress").to_int() > 90)
	{
		auto_log_info("A-Boo Peak (initial): " + get_property("booPeakProgress"), "blue");

		if (clueAmt < 3 && item_amount($item[January\'s Garbage Tote]) > 0)
		{
			januaryToteAcquire($item[Broken Champagne Bottle]);
			removeFromMaximize("-equip " + $item[Broken Champagne Bottle]);
		}

		autoAdv(1, $location[A-Boo Peak]);
		return true;
	}

	boolean booCloversOk = false;
	if(cloversAvailable() > 0)
	{
		if(auto_my_path() == "G-Lover")
		{
			if(item_amount($item[A-Boo Glue]) > 0)
			{
				booCloversOk = true;
			}
		}
		else
		{
			booCloversOk = true;
		}
	}

	auto_log_info("A-Boo Peak: " + get_property("booPeakProgress"), "blue");
	boolean clueCheck = ((clueAmt > 0) || (get_property("auto_aboopending").to_int() != 0));
	if (get_property("auto_abooclover").to_boolean() && get_property("booPeakProgress").to_int() >= 30 && booCloversOk)
	{
		cloverUsageInit();
		autoAdvBypass(296, $location[A-Boo Peak]);
		if(cloverUsageFinish())
		{
			set_property("auto_abooclover", false);
		}
		return true;
	}
	else if (clueCheck && (get_property("booPeakProgress").to_int() > 2))
	{
		boolean doThisBoo = false;

		if (isActuallyEd())
		{
			if(item_amount($item[Linen Bandages]) == 0)
			{
				return false;
			}
		}
		familiar priorBjorn = my_bjorned_familiar();

		string lihcface = "";
		if (isActuallyEd() && possessEquipment($item[The Crown of Ed the Undying]))
		{
			lihcface = "-equip lihc face";
		}
		string parrot = ", switch exotic parrot, switch mu, switch trick-or-treating tot";
		if(!canChangeFamiliar())
		{
			parrot = "";
		}

		autoMaximize("spooky res, cold res, 0.01hp " + lihcface + " -equip snow suit" + parrot, 0, 0, true);
		int coldResist = simValue("Cold Resistance");
		int spookyResist = simValue("Spooky Resistance");
		int hpDifference = simValue("Maximum HP") - numeric_modifier("Maximum HP");
		int effectiveCurrentHP = my_hp();

		//	Do we need to manually adjust for the parrot?

		if(black_market_available() && (item_amount($item[Can of Black Paint]) == 0) && (have_effect($effect[Red Door Syndrome]) == 0) && (my_meat() >= npc_price($item[Can of Black Paint])))
		{
			buyUpTo(1, $item[Can of Black Paint]);
			coldResist += 2;
			spookyResist += 2;
		}
		else if (item_amount($item[Can of Black Paint]) > 0 && have_effect($effect[Red Door Syndrome]) == 0)
		{
			coldResist += 2;
			spookyResist += 2;
		}

		if(0 == have_effect($effect[Mist Form]))
		{
			if(have_skill($skill[Mist Form]))
			{
				coldResist += 4;
				spookyResist += 4;
				effectiveCurrentHP -= 10;
			}
			else if(have_skill($skill[Spectral Awareness]) && (0 == have_effect($effect[Spectral Awareness])))
			{
				coldResist += 2;
				spookyResist += 2;
				effectiveCurrentHP -= 10;
			}
		}

		if((item_amount($item[Spooky Powder]) > 0) && (have_effect($effect[Spookypants]) == 0))
		{
			spookyResist = spookyResist + 1;
		}
		if((item_amount($item[Ectoplasmic Orbs]) > 0) && (have_effect($effect[Balls of Ectoplasm]) == 0))
		{
			spookyResist = spookyResist + 1;
		}
		if((item_amount($item[Black Eyedrops]) > 0) && (have_effect($effect[Hyphemariffic]) == 0))
		{
			spookyResist = spookyResist + 9;
		}
		if((item_amount($item[Cold Powder]) > 0) && (have_effect($effect[Insulated Trousers]) == 0))
		{
			coldResist = coldResist + 1;
		}
		if(auto_canBeachCombHead("cold")) {
			coldResist = coldResist + 3;
		}
		if (auto_canBeachCombHead("spooky")) {
			spookyResist = spookyResist + 3;
		}

		#Calculate how much boo peak damage does per unit resistance.
		int estimatedCold = (13+25+50+125+250) * ((100.0 - elemental_resist_value(coldResist)) / 100.0);
		int estimatedSpooky = (13+25+50+125+250) * ((100.0 - elemental_resist_value(spookyResist)) / 100.0);
		auto_log_info("Current HP: " + my_hp() + "/" + my_maxhp(), "blue");
		auto_log_info("Expected cold damage: " + estimatedCold + " Expected spooky damage: " + estimatedSpooky, "blue");
		auto_log_info("Expected Cold Resist: " + coldResist + " Expected Spooky Resist: " + spookyResist + " Expected HP Difference: " + hpDifference, "blue");
		int totalDamage = estimatedCold + estimatedSpooky;

		if(get_property("booPeakProgress").to_int() <= 6)
		{
			estimatedCold = ((estimatedCold * 38) / 463) + 1;
			estimatedSpooky = ((estimatedSpooky * 38) / 463) + 1;
			totalDamage = estimatedCold + estimatedSpooky;
		}
		else if(get_property("booPeakProgress").to_int() <= 12)
		{
			estimatedCold = ((estimatedCold * 88) / 463) + 1;
			estimatedSpooky = ((estimatedSpooky * 88) / 463) + 1;
			totalDamage = estimatedCold + estimatedSpooky;
		}
		else if(get_property("booPeakProgress").to_int() <= 20)
		{
			estimatedCold = ((estimatedCold * 213) / 463) + 1;
			estimatedSpooky = ((estimatedSpooky * 213) / 463) + 1;
			totalDamage = estimatedCold + estimatedSpooky;
		}

		if(get_property("booPeakProgress").to_int() <= 20)
		{
			auto_log_info("Don't need a full A-Boo Clue, adjusting values:", "blue");
			auto_log_info("Expected cold damage: " + estimatedCold + " Expected spooky damage: " + estimatedSpooky, "blue");
			auto_log_info("Expected Cold Resist: " + coldResist + " Expected Spooky Resist: " + spookyResist + " Expected HP Difference: " + hpDifference, "blue");
		}

		int considerHP = my_maxhp() + hpDifference;

		int mp_need = 20 + simValue("Mana Cost");
		if((my_hp() - totalDamage) > 50)
		{
			mp_need = mp_need - 20;
		}

		loopHandler("_auto_lastABooConsider", "_auto_lastABooCycleFix", "We are in an A-Boo Peak cycle and can't find anything else to do. Aborting. If you have actual other quests left, please report this. Otherwise, complete A-Boo peak manually",15);

		if(get_property("booPeakProgress").to_int() == 0)
		{
			doThisBoo = true;
		}
		if((min(effectiveCurrentHP, my_maxhp() + hpDifference) > totalDamage) && (my_mp() >= mp_need))
		{
			doThisBoo = true;
		}
		if((considerHP >= totalDamage) && (my_mp() >= mp_need) && have_skill($skill[Cannelloni Cocoon]))
		{
			doThisBoo = true;
		}

		if(doThisBoo)
		{
			buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
			bat_formMist();
			if(0 == have_effect($effect[Mist Form]))
			{
				buffMaintain($effect[Spectral Awareness], 10, 1, 1);
			}
			addToMaximize("1000spooky res,1000cold res,10hp" + parrot);
			adjustEdHat("ml");

			buffMaintain($effect[Astral Shell], 10, 1, 1);
			buffMaintain($effect[Elemental Saucesphere], 10, 1, 1);
			buffMaintain($effect[Scarysauce], 10, 1, 1);
			buffMaintain($effect[Spookypants], 0, 1, 1);
			buffMaintain($effect[Hyphemariffic], 0, 1, 1);
			buffMaintain($effect[Insulated Trousers], 0, 1, 1);
			buffMaintain($effect[Balls of Ectoplasm], 0, 1, 1);
			buffMaintain($effect[Red Door Syndrome], 0, 1, 1);
			buffMaintain($effect[Well-Oiled], 0, 1, 1);

			auto_beachCombHead("cold");
			auto_beachCombHead("spooky");

			set_property("choiceAdventure611", "1");
			if((my_hp() - 50) < totalDamage)
			{
				acquireHP();
			}
			if(get_property("auto_aboopending").to_int() == 0)
			{
				if(item_amount(clue) > 0)
				{
					use(1, clue);
				}
				set_property("auto_aboopending", my_turncount());
			}
			if(auto_have_familiar($familiar[Mu]))
			{
				handleFamiliar($familiar[Mu]);
			}
			else if(auto_have_familiar($familiar[Exotic Parrot]))
			{
				handleFamiliar($familiar[Exotic Parrot]);
			}

			# When booPeakProgress <= 0, we want to leave this adventure. Can we?
			# I can not figure out how to do this via ASH since the adventure completes itself?
			# However, in mafia, (src/net/sourceforge/kolmafia/session/ChoiceManager.java)
			# upon case 611, if booPeakProgress <= 0, set choiceAdventure611 to 2
			# If lastDecision was 2, revert choiceAdventure611 to 1 (or perhaps unset it?)
			try
			{
				autoAdv(1, $location[A-Boo Peak]);
			}
			finally
			{
				if(get_property("lastEncounter") != "The Horror...")
				{
					auto_log_warning("Wandering adventure interrupt of A-Boo Peak, refreshing inventory.", "red");
					cli_execute("refresh inv");
				}
				else
				{
					set_property("auto_aboopending", 0);
				}
			}
			acquireHP();
			if ((my_hp() * 4) < my_maxhp() && item_amount($item[Scroll of Drastic Healing]) > 0 && (!isActuallyEd() || my_class() != $class[Vampyre]))
			{
				use(1, $item[Scroll of Drastic Healing]);
			}
			handleFamiliar("item");
			handleBjornify(priorBjorn);
			return true;
		}

		auto_log_info("Nevermind, that peak is too scary!", "green");
		equipBaseline();
		handleFamiliar("item");
		handleBjornify(priorBjorn);
	}
	else
	{
		if ($location[A-Boo Peak].turns_spent < 10 && item_amount($item[January\'s Garbage Tote]) > 0)
		{
			januaryToteAcquire($item[Broken Champagne Bottle]);
			removeFromMaximize("-equip " + $item[Broken Champagne Bottle]);
		}

		autoAdv(1, $location[A-Boo Peak]);
		set_property("auto_aboopending", 0);

		return true;
	}
	return false;
}

boolean L9_twinPeak()
{
	if (internalQuestStatus("questL09Topping") < 2 || internalQuestStatus("questL09Topping") > 3)
	{
		return false;
	}

	if (get_property("twinPeakProgress").to_int() >= 15)
	{
		return false;
	}
	
	//set fixed NC values
	set_property("choiceAdventure604", "1");	//welcome NC to twin peak step 1 = "continue"
	set_property("choiceAdventure605", "1");	//welcome NC to twin peak step 2 = "everything goes black"
	set_property("choiceAdventure607", "1");	//finish stench / room 237
	set_property("choiceAdventure608", "1");	//finish food drop / pantry
	set_property("choiceAdventure609", "1");	//do jar of oil / sound of music... goto 616
	set_property("choiceAdventure616", "1");	//finish jar of oil / sound of music
	set_property("choiceAdventure610", "1");	//do init / "who's that" / "to catch a killer"... goto 1056
	set_property("choiceAdventure1056", "1");	//finish init / "now it's dark"
	set_property("choiceAdventure618", "2");	//burn this hotel pity NC to skip the zone if you spent over 50 adventures there.
	
	//main lodge NC. we swap around this value multiple times. initially set to 0 to prevent mistakes.
	set_property("choiceAdventure606", "0");	

	//-combat via combining 2 IOTMs. Needs to be moved to providePlusNonCombat
	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	providePlusNonCombat(25);
	
	buffMaintain($effect[Fishy Whiskers], 0, 1, 1);		//heavy rains specific reduce item drop penalty by 10%

	int progress = get_property("twinPeakProgress").to_int();
	boolean needStench = ((progress & 1) == 0);
	boolean needFood = ((progress & 2) == 0);
	boolean needJar = ((progress & 4) == 0);
	boolean needInit = (progress == 7);

	boolean attempt = false;
	if(!attempt && needInit)
	{
		if(provideInitiative(40,true))
		{
			set_property("choiceAdventure606", "4");
			attempt = true;
		}
		else
		{
			return false;			//init test shows up last. if we can't do it there is no point in checking rest of function.
		}
	}

	if(!attempt && needJar)
	{
		if(item_amount($item[Jar of Oil]) == 1)
		{
			set_property("choiceAdventure606", "3");
			attempt = true;
		}
	}

	if(!attempt && needFood)
	{
		float food_drop = item_drop_modifier();
		food_drop -= numeric_modifier(my_familiar(), "Item Drop", familiar_weight(my_familiar()), equipped_item($slot[familiar]));
		
		if(my_servant() == $servant[Cat])
		{
			food_drop -= numeric_modifier($familiar[Baby Gravy Fairy], "Item Drop", $servant[Cat].level, $item[none]);
		}
		if((food_drop < 50) && (food_drop >= 20))
		{
			if(friars_available() && (!get_property("friarsBlessingReceived").to_boolean()))
			{
				cli_execute("friars food");
			}
		}
		if(have_effect($effect[Brother Flying Burrito\'s Blessing]) > 0)
		{
			food_drop = food_drop + 30;
		}
		if((food_drop < 50.0) && (item_amount($item[Eagle Feather]) > 0) && (have_effect($effect[Eagle Eyes]) == 0))
		{
			use(1, $item[Eagle Feather]);
			food_drop = food_drop + 20;
		}
		if((food_drop < 50.0) && (item_amount($item[resolution: be happier]) > 0) && (have_effect($effect[Joyful Resolve]) == 0))
		{
			buffMaintain($effect[Joyful Resolve], 0, 1, 1);
			food_drop = food_drop + 15;
		}
		if(food_drop >= 50.0)
		{
			set_property("choiceAdventure606", "2");
			attempt = true;
		}
	}

	if(!attempt && needStench)
	{
		int [element] resGoal;
		resGoal[$element[stench]] = 4;
		// check if we can get enough stench res before we start applying anything
		int [element] resPossible = provideResistances(resGoal, true, true);
		if(resPossible[$element[stench]] >= 4)
		{
			provideResistances(resGoal, true);
			set_property("choiceAdventure606", "1");
			attempt = true;
		}
	}

	if(!attempt)
	{
		return false;
	}
	auto_log_info("Twin Peak", "blue");

	int starting_trimmers = item_amount($item[Rusty Hedge Trimmers]);
	if(starting_trimmers > 0)
	{
		use(1, $item[rusty hedge trimmers]);
		cli_execute("refresh inv");
		if(item_amount($item[rusty hedge trimmers]) == starting_trimmers)
		{
			abort("Tried using a rusty hedge trimmer but that didn't seem to work");
		}
		auto_log_info("Hedge trimming situation: " + get_property("choiceAdventure606").to_int(), "green");
		string page = visit_url("main.php");
		if((contains_text(page, "choice.php")) && (!contains_text(page, "Really Sticking Her Neck Out")) && (!contains_text(page, "It Came from Beneath the Sewer?")))
		{
			auto_log_info("Inside of a Rusty Hedge Trimmer sequence.", "blue");
		}
		else
		{
			auto_log_info("Rusty Hedge Trimmer Sequence completed itself.", "blue");
			return true;
		}
	}

	return autoAdv($location[Twin Peak]);
}

boolean L9_oilPeak()
{
	if (internalQuestStatus("questL09Topping") < 2 || internalQuestStatus("questL09Topping") > 3)
	{
		return false;
	}

	auto_MaxMLToCap(auto_convertDesiredML(100), false);

	if(monster_level_adjustment() < 50 && my_level() < 12 && my_level() != get_property("auto_powerLevelLastLevel").to_int())
	{
		return false;
	}

	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire3.gif"))
	{
		int oilProgress = get_property("twinPeakProgress").to_int();
		boolean needJar = ((oilProgress & 4) == 0);

		if((item_amount($item[Bubblin\' Crude]) >= 12) && needJar)
		{
			if(auto_my_path() == "G-Lover")
			{
				if(item_amount($item[Crude Oil Congealer]) == 0)
				{
					cli_execute("make " + $item[Crude Oil Congealer]);
				}
				use(1, $item[Crude Oil Congealer]);
			}
			else
			{
				cli_execute("make " + $item[Jar Of Oil]);
			}
			return true;
		}

		if((item_amount($item[Jar Of Oil]) > 0) || !needJar)
		{
			return false;
		}
		auto_log_info("Oil Peak is finished but we need more crude!", "blue");
	}

	buffMaintain($effect[Fishy Whiskers], 0, 1, 1);
	handleFamiliar("initSuggest");

	auto_MaxMLToCap(auto_convertDesiredML(100), true);

	if (isActuallyEd() && get_property("auto_dickstab").to_boolean())
	{
		buffMaintain($effect[The Dinsey Look], 0, 1, 1);
	}
	if(monster_level_adjustment() < 50)
	{
		buffMaintain($effect[The Dinsey Look], 0, 1, 1);
	}
	if((monster_level_adjustment() < 60))
	{
		if (item_amount($item[Dress Pants]) > 0)
		{
			autoEquip($slot[Pants], $item[Dress Pants]);
		}
		else
		{
			januaryToteAcquire($item[tinsel tights]);
		}
	}

	// Maximize Asdon usage
	if((have_effect($effect[Driving Recklessly]) == 0) && (have_effect($effect[Driving Wastefully]) == 0))
	{
		if((((simMaximizeWith("1000ml 75min")) && (!simMaximizeWith("1000ml 100min"))) || ((simMaximizeWith("1000ml 25min")) && (!simMaximizeWith("1000ml 50min"))) || (!simMaximizeWith("1000ml 11min"))) && (have_effect($effect[Driving Wastefully]) == 0))
		{
			asdonBuff($effect[Driving Recklessly]);
		}
		else if(have_effect($effect[Driving Recklessly]) == 0)
		{
			asdonBuff($effect[Driving Wastefully]);
		}
	}

	// Help protect ourselves against not getting enough crudes if tackling cartels
	if(simMaximizeWith("1000ml 100min"))
	{
		addToMaximize("120item");
	}

	addToMaximize("1000ml " + auto_convertDesiredML(100) + "max");

	auto_log_info("Oil Peak with ML: " + monster_level_adjustment(), "blue");

	autoAdv(1, $location[Oil Peak]);
	if(get_property("lastEncounter") == "Unimpressed with Pressure")
	{
		set_property("oilPeakProgress", 0.0);

		// Brute Force grouping with tavern (if not done) to maximize tangles while we have a high ML.
		auto_log_info("Checking to see if we should do the tavern while we are running high ML.", "green");
		set_property("auto_forceTavern", true);
		// Remove Driving Wastefully if we had it
		if (0 < have_effect($effect[Driving Wastefully]))
		{
			uneffect($effect[Driving Wastefully]);
		}
	}
	handleFamiliar("item");
	return true;
}

boolean L9_highLandlord()
{
	if (internalQuestStatus("questL09Topping") < 1 || internalQuestStatus("questL09Topping") > 3)
	{
		return false;
	}
	if(get_property("chasmBridgeProgress").to_int() < 30)
	{
		return false;
	}
	if (isActuallyEd() && !get_property("auto_chasmBusted").to_boolean())
	{
		return false;
	}

	if (internalQuestStatus("questL09Topping") == 1)
	{
		auto_log_info("Visiting the Highland Lord's tower <ominous music plays>", "blue");
		visit_url("place.php?whichplace=highlands&action=highlands_dude");
		set_property("auto_grimstoneFancyOilPainting", false);
		return true;
	}

	if(L9_twinPeak())			return true;
	if(L9_aBooPeak())			return true;
	if(L9_oilPeak())			return true;

	if (internalQuestStatus("questL09Topping") == 3)
	{
		auto_log_info("Aw, sweet, dude! You totally lit all the signal fires!", "blue");
		visit_url("place.php?whichplace=highlands&action=highlands_dude");
		council();
		return true;
	}

	return false;
}
