boolean LX_loggingHatchet()
{
	if (!canadia_available())
	{
		return false;
	}
	if(kolhs_mandatorySchool())
	{
		return false;	//avoid infinite loop in kolhs. we can not get the hatchet until we finish mandatory school for the day
	}
	if (available_amount($item[logging hatchet]) > 0)
	{
		return false;
	}

	if ($location[Camp Logging Camp].turns_spent > 0 ||
		$location[Camp Logging Camp].combat_queue != "" ||
		$location[Camp Logging Camp].noncombat_queue != "")
	{
		return false;
	}

	auto_log_info("Acquiring the logging hatchet from Camp Logging Camp", "blue");
	autoAdv(1, $location[Camp Logging Camp]);
	return true;
}

boolean L9_leafletQuest()
{
	if(my_level() < 9)
	{
		return false;
	}
	if(isActuallyEd() || in_koe())
	{
		return false;
	}
	if(get_property("leafletCompleted").to_boolean())
	{
		return false;
	}
	
	//get a [strange leaflet]
	if(closet_amount($item[strange leaflet]) > 0)
	{
		take_closet(1, $item[strange leaflet]);
	}
	if(available_amount($item[strange leaflet]) == 0)
	{
		council();
		if(item_amount($item[strange leaflet]) == 0)
		{
			auto_log_debug("Tried to grab a [strange leaflet] from the council and it did not work... This needs fixing. skipping for now.");
			return false;
		}
	}
	
	auto_log_info("Got a leaflet to do", "blue");
	if(disregardInstantKarma())		//checks a user setting as well as current level
	{
		equipStatgainIncreasers();
		cli_execute("leaflet");		//also gain +200 substats for each stat
	}
	else
	{
		//in plumber you eat manually and can jump from level 8 to 13 via food.
		cli_execute("leaflet nomagic");		//no substat gains
	}
	
	return get_property("leafletCompleted").to_boolean();
}

void L9_chasmMaximizeForNoncombat()
{
	auto_log_info("Let's assess our scores for blech house", "blue");
	string best = "mus";
	location loc = $location[The Smut Orc Logging Camp];
	string mustry = "1000muscle,1000weapon damage,10000weapon damage percent";
	string mystry = "1000mysticality,1000spell damage,10000 spell damage percent";
	string moxtry = "1000moxie,10000sleaze resistance";
	simMaximizeWith(loc, mustry);
	float musmus = simValue("Buffed Muscle");
	float musflat = simValue("Weapon Damage");	//incorrectly includes 15% weapon power
	float musperc = simValue("Weapon Damage Percent");
	int musscore = floor(square_root((musmus + musflat)/15*(1+musperc/100)));
	auto_log_info("Muscle score: " + musscore, "blue");
	simMaximizeWith(loc, mystry);
	float mysmys = simValue("Buffed Mysticality");
	float mysflat = simValue("Spell Damage");
	float mysperc = simValue("Spell Damage Percent");
	int mysscore = floor(square_root((mysmys + mysflat)/15*(1+mysperc/100)));
	auto_log_info("Mysticality score: " + mysscore, "blue");
	if(mysscore >= musscore)	//overwrite equal muscle score if possible because it may be 1 lower than predicted due to the above weapon damage issue
	{
		best = "mys";
	}
	simMaximizeWith(loc, moxtry);
	float moxmox = simValue("Buffed Moxie");
	float moxres = simValue("Sleaze Resistance");
	int moxscore = floor(square_root(moxmox/30*(1+moxres*0.69)));
	auto_log_info("Moxie score: " + moxscore, "blue");
	if(moxscore >= mysscore && moxscore >= musscore)
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

int fastenerCount()
{
	int base = get_property("chasmBridgeProgress").to_int();
	base = base + item_amount($item[Thick Caulk]);
	base = base + item_amount($item[Long Hard Screw]);
	base = base + item_amount($item[Messy Butt Joint]);

	return base;
}

int lumberCount()
{
	int base = get_property("chasmBridgeProgress").to_int();
	base = base + item_amount($item[Morningwood Plank]);
	base = base + item_amount($item[Raging Hardwood Plank]);
	base = base + item_amount($item[Weirdwood Plank]);

	return base;
}

void prepareForSmutOrcs()
{

	if(lumberCount() >= 30 && fastenerCount() >= 30)
	{
		// must be here for shen snake and quest objective is already done
		// set blech NC and don't bother prepping for the zone
		auto_log_info("Adventuring at Smut Orc Logging Camp when quest is done. Skipping preparing to maximize zone progress.", "blue");
		set_property("choiceAdventure1345", 1);
		return;
	}

	// -Combat is useless here since NC is triggered by killing Orcs...So we kill orcs better!
	// -ML helps us deal more cold damage and trigger the NC faster.
	asdonBuff($effect[Driving Intimidatingly]);

	// Check our Load out to see if spells are the best option for Orc-Thumping
	if (isGuildClass()) {
		// This only applies to classes which can use perm'd skills,
		// so let's not waste time and console spam when we're a class or path that can't do any of this.
		boolean useSpellsInOrcCamp = false;
		
		acquireMP(32, 1000);	//pre_adv will always do this later, but waiting for it may fail checks of ability to cast spells here
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
	}
	
	// This adds a tonne of damage and NC progress
	buffMaintain($effect[Triple-Sized]);
	
	if(get_property("smutOrcNoncombatProgress").to_int() == 15)
	{
		// If we think the non-com will hit NOW we clear maximizer to keep previous settings from carrying forward
		resetMaximize();

		auto_log_info("The smut orc noncombat is about to hit...");
		// This is a hardcoded patch for Dark Gyffte
		// TODO: once explicit formulas are spaded, use simulated maximizer
		// to determine best approach.
		L9_chasmMaximizeForNoncombat();
		return;
	}

	if(in_plumber() && possessEquipment($item[frosty button]))
	{
		autoEquip($item[frosty button]);
	}

	if(in_hardcore())
	{

		if(in_gnoob() && auto_have_familiar($familiar[Robortender]))
		{
			if(!have_skill($skill[Powerful Vocal Chords]) && (item_amount($item[Baby Oil Shooter]) == 0))
			{
				handleFamiliar($familiar[Robortender]);
			}
		}

		if(fastenerCount() < 30)
		{
			autoEquip($item[Loadstone]);
		}
		if(lumberCount() < 30)
		{
			autoEquip($item[Logging Hatchet]);
		}

		return;
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
		if(fastenerCount() < 30)
		{
			autoEquip($item[Loadstone]);
		}
		if(lumberCount() < 30)
		{
			autoEquip($item[Logging Hatchet]);
		}

		return;
	}
}

boolean L9_chasmBuild()
{
	if (internalQuestStatus("questL09Topping") != 0 || get_property("chasmBridgeProgress").to_int() >= 30)
	{
		return false;
	}

	if (shenShouldDelayZone($location[The Smut Orc Logging Camp]))
	{
		auto_log_debug("Delaying Logging Camp in case of Shen.");
		return false;
	}
	if(robot_delay("chasm"))
	{
		return false;	//delay for You, Robot path
	}
	if(auto_hasAutumnaton() && !isAboutToPowerlevel() && $location[The Smut Orc Logging Camp].turns_spent > 0 
		&& (fastenerCount() < 30 || lumberCount() < 30))
	{
		// delay zone to allow autumnaton to grab bridge parts
		// unless we have ran out of other stuff to do
		return false;
	}

	if (LX_loggingHatchet()) { return true; } // turn free, might save some adventures. May as well get it if we can.

	auto_log_info("Chasm time", "blue");
	
	// make sure our progress count is correct before we do anything.
	visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));

	// use any keepsake boxes we have
	if(item_amount($item[Smut Orc Keepsake Box]) > 0 && auto_is_valid($item[Smut Orc Keepsake Box]))
	{
		use(1, $item[Smut Orc Keepsake Box]);
	}

	// finish chasm if we can
	if(get_property("chasmBridgeProgress").to_int() >= 30)
	{
		visit_url("place.php?whichplace=highlands&action=highlands_dude");
		return true;
	}

	// prepareForSmutOrcs() called in pre-adv
	autoAdv(1, $location[The Smut Orc Logging Camp]);

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
	if(in_glover())
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

		if (clueAmt < 3)
		{
			januaryToteAcquire($item[Broken Champagne Bottle]);
		}

		return autoAdv(1, $location[A-Boo Peak]);
	}

	boolean booCloversOk = false;
	if(cloversAvailable() > 0)
	{
		if(in_glover())
		{
			if(item_amount($item[A-Boo Glue]) > 0)
			{
				booCloversOk = true;
			}
		}
		else if(in_bhy())
		{
			// bees hate clues, don't waste clovers on them
			booCloversOk = false;
		}
		else
		{
			booCloversOk = true;
		}
	}

	if (get_property("auto_abooclover").to_boolean() && clueAmt >= get_property("booPeakProgress").to_int()/30) {
		// if you get lucky/have enough item drop to get 3 clues while getting to 90% haunted, don't waste a clover getting more.
		auto_log_info("We have enough A-boo clues to clear the peak, lets not waste a clover");
		set_property("auto_abooclover", false);
	}

	auto_log_info("A-Boo Peak: " + get_property("booPeakProgress"), "blue");
	boolean clueCheck = ((clueAmt > 0) || (get_property("auto_aboopending").to_int() != 0));
	if (get_property("auto_abooclover").to_boolean() && get_property("booPeakProgress").to_int() >= 30 && booCloversOk)
	{
		cloverUsageInit();
		autoAdvBypass(296, $location[A-Boo Peak]);
		if(cloverUsageRestart())
		{
			autoAdvBypass(296, $location[A-Boo Peak]);
		}
		if(cloverUsageFinish())
		{
			set_property("auto_abooclover", false);
		}
		return true;
	}
	else if (clueCheck && (get_property("booPeakProgress").to_int() > 2))
	{
		boolean doThisBoo = false;

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
		//assume min bandage HP resotred to ensure we can heal enough
		if((considerHP >= totalDamage) && isActuallyEd() && ((item_amount($item[Linen Bandages])*20 + my_hp()) >= totalDamage))
		{
			doThisBoo = true;
		}
		//do clue if it is one of the last things to do
		if(isAboutToPowerlevel() && my_level() >= 13)
		{
			doThisBoo = true;
		}

		if(doThisBoo)
		{
			buffMaintain($effect[Go Get \'Em\, Tiger!]);
			bat_formMist();
			if(0 == have_effect($effect[Mist Form]))
			{
				buffMaintain($effect[Spectral Awareness], 10, 1, 1);
			}
			addToMaximize("1000spooky res,1000cold res,10hp" + parrot);
			adjustEdHat("ml");

			buffMaintain($effect[Astral Shell], 10, 1, 1);
			buffMaintain($effect[Elemental Saucesphere], 10, 1, 1);
			buffMaintain($effect[Scariersauce], 10, 1, 1);
			buffMaintain($effect[Scarysauce], 10, 1, 1);
			buffMaintain($effect[Spookypants]);
			buffMaintain($effect[Hyphemariffic]);
			buffMaintain($effect[Insulated Trousers]);
			buffMaintain($effect[Balls of Ectoplasm]);
			buffMaintain($effect[Red Door Syndrome]);
			buffMaintain($effect[Well-Oiled]);

			if(auto_is_valid($effect[Cold as Nice]))
			{
				auto_beachCombHead("cold");
			}
			if(auto_is_valid($effect[Does It Have a Skull In There??]))			
			{
				auto_beachCombHead("spooky");
			}

			set_property("choiceAdventure611", "1");
			
			if(get_property("auto_aboopending").to_int() == 0)
			{
				if(item_amount(clue) > 0 && use(1, clue))
				{
					set_property("auto_aboopending", my_turncount());
				}
			}
			if(canChangeToFamiliar($familiar[Trick-or-Treating Tot]))
			{
				handleFamiliar($familiar[Trick-or-Treating Tot]);
			}
			else if(canChangeToFamiliar($familiar[Mu]))
			{
				handleFamiliar($familiar[Mu]);
			}
			else if(canChangeToFamiliar($familiar[Exotic Parrot]))
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
					if($strings[Battlie Knight Ghost,Claybender Sorcerer Ghost,Dusken Raider Ghost,Space Tourist Explorer Ghost,Whatsian Commando Ghost] 
					contains get_property("lastEncounter"))	//clue usage probably failed somehow
					{
						catch use(1, clue);		//will not be consumed if a clue is already active
					}
				}
				else
				{
					set_property("auto_aboopending", 0);
				}
			}
			acquireHP();
			if ((my_hp() * 4) < my_maxhp() && item_amount($item[Scroll of Drastic Healing]) > 0 && (!isActuallyEd() || !in_darkGyffte()))
			{
				use(1, $item[Scroll of Drastic Healing]);
			}
			handleBjornify(priorBjorn);
			return true;
		}

		auto_log_info("Nevermind, that peak is too scary!", "green");
		resetState();
		handleBjornify(priorBjorn);
	}
	else
	{
		if ($location[A-Boo Peak].turns_spent < 10)
		{
			januaryToteAcquire($item[Broken Champagne Bottle]);
		}

		autoAdv(1, $location[A-Boo Peak]);
		set_property("auto_aboopending", 0);

		return true;
	}
	return false;
}

int hedgeTrimmersNeeded()
{
	int twinPeakProgress = get_property("twinPeakProgress").to_int();
	boolean needStench = ((twinPeakProgress & 1) == 0);
	boolean needFood = ((twinPeakProgress & 2) == 0);
	boolean needJar = ((twinPeakProgress & 4) == 0);
	boolean needInit = (needStench || needFood || needJar || (twinPeakProgress == 7));
	int neededTrimmers = -(item_amount($item[rusty hedge trimmers]));
	if(needStench) neededTrimmers++;
	if(needFood) neededTrimmers++;
	if(needJar) neededTrimmers++;
	if(needInit) neededTrimmers++;

	return neededTrimmers;
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

	if(hedgeTrimmersNeeded() > 0 && auto_autumnatonCanAdv($location[Twin Peak]) && !isAboutToPowerlevel() && $location[Twin Peak].turns_spent > 0)
	{
		// delay zone to allow autumnaton to grab rusty hedge trimmers
		// unless we have ran out of other stuff to do
		return false;
	}
		
	//main lodge NC. we swap around this value multiple times. initially set to 0 to prevent mistakes.
	set_property("choiceAdventure606", "0");	

	//-combat via combining 2 IOTMs. Needs to be moved to providePlusNonCombat
	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	
	buffMaintain($effect[Fishy Whiskers]);		//heavy rains specific reduce item drop penalty by 10%
	//BHY specific prevent wandering bees from skipping the burning the hotel down choice and wasting turns
	buffMaintain($effect[Float Like a Butterfly, Smell Like a Bee]);
	
	if(in_bhy())
	{
		// we can't make an oil jar to solve the quest, just adventure until the hotel is burned down
		set_property("choiceAdventure606", "6"); // and flee the music NC
		return autoAdv($location[Twin Peak]);
	}

	int progress = get_property("twinPeakProgress").to_int();
	boolean needStench = ((progress & 1) == 0);
	boolean needFood = ((progress & 2) == 0);
	boolean needJar = ((progress & 4) == 0);
	boolean needInit = (progress == 7);

	boolean attempt = false;
	if(!attempt && needInit)
	{
		if(provideInitiative(40, $location[Twin Peak], true))
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
		float food_drop = item_drop_modifier() + numeric_modifier("Food Drop");
		food_drop -= numeric_modifier(my_familiar(), "Item Drop", familiar_weight(my_familiar()) + weight_adjustment() - numeric_modifier(equipped_item($slot[familiar]), "Familiar Weight"), equipped_item($slot[familiar]));
		
		if(my_servant() == $servant[Cat])
		{
			food_drop -= numeric_modifier($familiar[Baby Gravy Fairy], "Item Drop", $servant[Cat].level, $item[none]);
		}
		if((food_drop < 50) && (food_drop >= 20) && have_effect($effect[Brother Flying Burrito\'s Blessing]) == 0)
		{
			if(friars_available() && (!get_property("friarsBlessingReceived").to_boolean()))
			{
				cli_execute("friars food");
			}
			if(have_effect($effect[Brother Flying Burrito\'s Blessing]) > 0)
			{
				food_drop = food_drop + 30;
			}
		}
		if((food_drop < 50.0) && (item_amount($item[Eagle Feather]) > 0) && (have_effect($effect[Eagle Eyes]) == 0))
		{
			use(1, $item[Eagle Feather]);
			food_drop = food_drop + 20;
		}
		if((food_drop < 50.0) && (item_amount($item[resolution: be happier]) > 0) && (have_effect($effect[Joyful Resolve]) == 0))
		{
			buffMaintain($effect[Joyful Resolve]);
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
		int [element] resPossible = provideResistances(resGoal, $location[Twin Peak], true, true);
		if(resPossible[$element[stench]] >= 4)
		{
			provideResistances(resGoal, $location[Twin Peak], true);
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
		equipMaximizedGear();
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

	if (get_property("auto_shinningStarted").to_boolean() && auto_canCamelSpit() && auto_canMapTheMonsters())
	{
		// Shh! You want to get sued?
		if (adjustForYellowRayIfPossible($monster[bearpig topiary animal]))
		{
			if (auto_mapTheMonsters())
			{
				handleFamiliar($familiar[Melodramedary]);
				auto_log_info("Attemping to use Map the Monsters to Yellow Ray a Camel Spitted bearpig topiary animal. Yes that is a mouthful but lets hope it works and we get 4 rusty hedge trimmers!");
			}
		}
		else
		{
			return false;
		}
	}
	if(auto_haveGreyGoose()){
		auto_log_info("Bringing the Grey Goose to emit some drones to get some hedge trimmers.");
		handleFamiliar($familiar[Grey Goose]);
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

	if(monster_level_adjustment() < 50 && my_level() < 12 && !isAboutToPowerlevel())
	{
		return false;
	}

	if(contains_text(visit_url("place.php?whichplace=highlands"), "fire3.gif"))
	{
		int oilProgress = get_property("twinPeakProgress").to_int();
		boolean needJar = ((oilProgress & 4) == 0) && item_amount($item[Jar Of Oil]) == 0;
		if(!needJar || in_bhy())
		{
			return false;
		}
		else if(item_amount($item[Bubblin' Crude]) >= 12)
		{
			if(in_glover())
			{
				if(item_amount($item[Crude Oil Congealer]) < 1 && item_amount($item[G]) > 2)
				{
					buy($coinmaster[G-Mart], 1, $item[Crude Oil Congealer]);
				}
				if(item_amount($item[Crude Oil Congealer]) > 0)
				{
					use(1, $item[Crude Oil Congealer]);
				}
			}
			else if(auto_is_valid($item[Bubblin' Crude]) && creatable_amount($item[Jar Of Oil]) > 0)
			{
				create(1, $item[Jar Of Oil]);
			}
			if(item_amount($item[Jar Of Oil]) > 0)
			{
				return true;
			}
		}
		auto_log_info("Oil Peak is finished but we need more crude!", "blue");
	}

	buffMaintain($effect[Fishy Whiskers]);

	auto_MaxMLToCap(auto_convertDesiredML(100), true);

	if (isActuallyEd() && get_property("auto_dickstab").to_boolean())
	{
		buffMaintain($effect[The Dinsey Look]);
	}
	if(monster_level_adjustment() < 50)
	{
		buffMaintain($effect[The Dinsey Look]);
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
		location loc = $location[Oil Peak];
		if((((simMaximizeWith(loc, "1000ml 75min")) && (!simMaximizeWith(loc, "1000ml 100min"))) || ((simMaximizeWith(loc, "1000ml 25min")) && (!simMaximizeWith(loc, "1000ml 50min"))) || (!simMaximizeWith(loc, "1000ml 11min"))) && (have_effect($effect[Driving Wastefully]) == 0))
		{
			asdonBuff($effect[Driving Recklessly]);
		}
		else if(have_effect($effect[Driving Recklessly]) == 0)
		{
			asdonBuff($effect[Driving Wastefully]);
		}
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

	if(L9_aBooPeak())			return true;
	if(L9_oilPeak())			return true;
	if(L9_twinPeak())			return true;

	if (internalQuestStatus("questL09Topping") == 3)
	{
		auto_log_info("Aw, sweet, dude! You totally lit all the signal fires!", "blue");
		visit_url("place.php?whichplace=highlands&action=highlands_dude");
		council();
		return true;
	}

	return false;
}
