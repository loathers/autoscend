import<autoscend.ash>

//Calculates MP to acquire at low max mp levels
//At low max MP, important to keep MP near max, since every saucestorm (etc.) counts
void low_mp_handler()
{
	auto_log_debug("Low max MP detected.", "red");
	int MIN_USEFUL_MP = 6; //Saucestorm
	int TARGET_MP = my_maxmp() - (my_maxmp() % MIN_USEFUL_MP);
	acquireMP(TARGET_MP, 0);
}

void print_footer()
{
	auto_log_info("[" +my_class()+ "] @ path of [" +my_path().name+ "]", "blue");
	
	string next_line = "HP: " +my_hp()+ "/" +my_maxhp()+ ", MP: " +my_mp()+ "/" +my_maxmp()+ ", Meat: " +my_meat();
	switch(my_class())
	{
		case $class[Seal Clubber]:
			next_line += ", Fury: " +my_fury()+ "/" +my_maxfury();
			break;
		case $class[Turtle Tamer]:
			foreach ttbless in $effects[Blessing of the War Snapper, Grand Blessing of the War Snapper, Glorious Blessing of the War Snapper, Blessing of She-Who-Was, Grand Blessing of She-Who-Was, Glorious Blessing of She-Who-Was, Blessing of the Storm Tortoise, Grand Blessing of the Storm Tortoise, Glorious Blessing of the Storm Tortoise]
			{
				if(have_effect(ttbless) > 0)
				{
					next_line += ", Blessing: " +ttbless;
				}
			}
			break;	
		case $class[Sauceror]:
			next_line += ", Soulsauce: " +my_soulsauce();
			break;
	}
	auto_log_info(next_line, "blue");
	
	string stat_sign(int s)
	{
		if(s >= 0) return "+" +s;
		else return s;
	}
	
	int bonus_mus = my_buffedstat($stat[muscle]) - my_basestat($stat[muscle]);
	int bonus_mys = my_buffedstat($stat[mysticality]) - my_basestat($stat[mysticality]);
	int bonus_mox = my_buffedstat($stat[moxie]) - my_basestat($stat[moxie]);
	auto_log_info("mus: " +my_basestat($stat[muscle])+stat_sign(bonus_mus)+
	". mys: " +my_basestat($stat[mysticality])+stat_sign(bonus_mys)+
	". mox: " +my_basestat($stat[moxie])+stat_sign(bonus_mox), "blue");
	
	next_line = "";
	if(pathHasFamiliar())
	{
		next_line += "Familiar: " +my_familiar()+ " @ " + familiar_weight(my_familiar()) + " + " + weight_adjustment() + "lbs. ";
	}
	if(my_class() == $class[Pastamancer])
	{
		next_line += "Thrall: [" +my_thrall()+ "] @ level " +my_thrall().level;
	}
	if(isActuallyEd())
	{
		next_line += "Servant: [" +my_servant()+ "] @ level " +my_servant().level;
	}
	if(my_class() == $class[Avatar of Jarlsberg])
	{
		next_line += "Companion: [" +my_companion();
	}
	auto_log_info(next_line, "blue");
	
	auto_log_info("ML: " + monster_level_adjustment() + " Encounter: " + combat_rate_modifier() + " Init: " + initiative_modifier(), "blue");
	auto_log_info("Exp Bonus: " + experience_bonus() + " Meat Drop: " + meat_drop_modifier() + " Item Drop: " + item_drop_modifier(), "blue");
	auto_log_info("Resists: " + numeric_modifier("Hot Resistance") + "/" + numeric_modifier("Cold Resistance") + "/" + numeric_modifier("Stench Resistance") + "/" + numeric_modifier("Spooky Resistance") + "/" + numeric_modifier("Sleaze Resistance"), "blue");
	
	//current equipment
	next_line = "equipment: ";
	foreach sl in $slots[]
	{
		if($slots[hat, weapon, off-hand, back, shirt, pants, acc1, acc2, acc3, familiar] contains sl)		//we always want to print the core slots
		{
			next_line += sl+ "=[" +equipped_item(sl)+ "]. ";
		}
		else if(equipped_item(sl) != $item[none])		//other slots should only be printed if they contain something
		{
			next_line += sl+ "=[" +equipped_item(sl)+ "]. ";
		}
	}
	auto_log_info(next_line, "blue");
}

void auto_ghost_prep(location place)
{
	//if place contains physically immune enemies then we need to be prepared to deal non physical damage.
	if(!is_ghost_in_zone(place))
	{
		return;		//no ghosts no problem
	}
	if(in_plumber())
	{
		return;		//these paths either have their own ghost handling. or can always kill ghosts
	}
	if(get_property("youRobotBottom").to_int() == 2)
	{
		return;		//you robot with a rocket crotch. deals fire damage to kill ghosts.
	}
	//a few iconic spells per avatar is ok. no need to be too exhaustive
	foreach sk in $skills[
		Saucestorm, saucegeyser,	//base classes
		Fist of the Mummy,		    //actually ed the undying
		Boil,						//avatar of jarlsberg
		Bilious Burst,				//zombie slayer
		Heroic Belch,				//avatar of boris
		Smoke Break,				//avatar of sneaky pete
		Fireball Toss,				//path of the plumber
		Chill of the Tomb,			//dark gyffte
		Lavafava, Pungent Mung, Beanstorm,			  //avatar of west of loathing
		Hot Foot, Emmental Elemental, Sax of Violence //avatar of shadow over loathing
		]
	{
		if(auto_have_skill(sk))
		{
			if(my_maxmp() >= 32)
				acquireMP(32, 0);		//make sure we actually have the MP to cast spells
			else low_mp_handler();
		}
		if(canUse(sk)) return;	//we can kill them with a spell
	}
	if(auto_haveDarts() && dartEleDmg())
	{
		addToMaximize("+equip " + $item[Everfull Dart Holster]); //If we have darts and an elemental damage buff, might as well use that
		return;
	}
	
	int m_hot = 1;
	int m_cold = 1;
	int m_spooky = 1;
	int m_sleaze = 1;
	int m_stench = 1;
	foreach idx, mob in get_monsters(place)
	{
		if(mob.physical_resistance >= 80)
		{
			switch(monster_element(mob))
			{
			case $element[hot]:
				m_hot = 0;
				m_sleaze = 2;
				m_stench = 2;
				break;
			case $element[cold]:
				m_cold = 0;
				m_hot = 2;
				m_spooky = 2;
				break;
			case $element[spooky]:
				m_spooky = 0;
				m_hot = 2;
				m_stench = 2;
				break;
			case $element[sleaze]:
				m_sleaze = 0;
				m_cold = 2;
				m_spooky = 2;
				break;
			case $element[stench]:
				m_stench = 0;
				m_sleaze = 2;
				m_cold = 2;
				break;
			}
		}
	}
	
	string max_with;
	int bonus;
	if(m_hot != 0) max_with += "," +10*m_hot+ "hot dmg";
	if(m_cold != 0) max_with += "," +10*m_cold+ "cold dmg";
	if(m_spooky != 0) max_with += "," +10*m_spooky+ "spooky dmg";
	if(m_sleaze != 0) max_with += "," +10*m_sleaze+ "sleaze dmg";
	if(m_stench != 0) max_with += "," +10*m_stench+ "stench dmg";
	
	simMaximizeWith(max_with);
	if(m_hot != 0) bonus += simValue("hot damage");
	if(m_cold != 0) bonus += simValue("cold damage");
	if(m_spooky != 0) bonus += simValue("spooky damage");
	if(m_sleaze != 0) bonus += simValue("sleaze damage");
	if(m_stench != 0) bonus += simValue("stench damage");
	
	if(bonus > 9)
	{
		addToMaximize(max_with);
		return;
	}

	abort("I was about to head into [" +place+ "] which contains ghosts. I can not damage those");
}

boolean auto_pre_adventure()
{
	location place = my_location();
	if(get_property("auto_disableAdventureHandling").to_boolean())
	{
		auto_log_info("Preadventure skipped by standard adventure handler.", "green");
		return true;
	}
	auto_log_info("Starting preadventure script...", "green");
	auto_log_debug("Adventuring at " +place, "green");
	
	preAdvUpdateFamiliar(place);
	ed_handleAdventureServant(place);

	if(get_floundry_locations() contains place)
	{
		buffMaintain($effect[Baited Hook]);
	}

	// be ready to use red rocket if we don't have one
	if(have_fireworks_shop() &&							// in a clan that has the Underground Fireworks Shop
		item_amount($item[red rocket]) == 0 &&			// Don't buy if we already have one
		auto_is_valid($item[red rocket]) &&				// or if it's not valid
		can_eat() &&									// be in a path that can eat
		my_class() != $class[Pig Skinner] &&			// don't want to use a red rocket in Pig Skinner
		!in_wereprof() &&								// don't use if we are in WereProf
		!auto_haveDarts() &&							// don't want to use a red rocket if we have darts
		my_meat() > npc_price($item[red rocket]) + meatReserve())
	{
		retrieve_item(1, $item[red rocket]);
	}

	if((get_property("_bittycar") == "") && (item_amount($item[Bittycar Meatcar]) > 0))
	{
		use(1, $item[Bittycar Meatcar]);
	}

	if((place == $location[The Broodling Grounds]) && (my_class() == $class[Seal Clubber]))
	{
		uneffect($effect[Spiky Shell]);
		uneffect($effect[Scarysauce]);
		if(!uneffect($effect[Scariersauce])) abort("Could not uneffect [Scariersauce]");
	}
	
	if(my_class() == $class[Pastamancer] && my_thrall() == $thrall[Vampieroghi] && place == $location[The Hidden Apartment Building]
		&& auto_have_skill($skill[Dismiss Pasta Thrall]))
	{
		// vampieroghi can dispell the shaman curse, preventing us from making quest progress
		use_skill($skill[Dismiss Pasta Thrall]);
	}

	if(place == $location[The Smut Orc Logging Camp])
	{
		prepareForSmutOrcs();
	}

	if(place == $location[Twin Peak])
	{
		prepareForTwinPeak(false);
	}

	if(place == $location[Vanya\'s Castle])
	{
		provideInitiative(600, $location[Vanya\'s Castle], true);	
		addToMaximize("200initiative 800max");
	}
	if(place == $location[The Fungus Plains])
	{
		buffMaintain($effect[Polka of Plenty], 30, 1, 1);
		addToMaximize("200meat drop 550max");
	}
	if(place == $location[Megalo-City])
	{
		buffMaintain($effect[Ghostly Shell], 30, 1, 1);			//+80 DA. 6 MP
		buffMaintain($effect[Astral Shell], 30, 1, 1);			//+80 DA, 10 MP
		buffMaintain($effect[Feeling Peaceful], 0, 1, 1);
		addToMaximize("200DA 600max");
	}
	if(place == $location[Hero\'s Field])
	{
		buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 30, 1, 1);
		buffMaintain($effect[Singer\'s Faithful Ocelot], 30, 1, 1);
		addToMaximize("200item 500max");
	}

	boolean junkyardML;
	if($locations[Next to that Barrel with something Burning In It, Near an Abandoned Refrigerator, Over where the Old Tires Are, Out by that Rusted-Out Car] contains place)
	{
		junkyardML = true;
		uneffect($effect[Spiky Shell]);
		uneffect($effect[Scarysauce]);
		if(in_aosol()){
			uneffect($effect[Queso Fustulento]);
		}
		if(!uneffect($effect[Scariersauce])) abort("Could not uneffect [Scariersauce]");
	}

	if(is_boris())
	{
		if((have_effect($effect[Song of Solitude]) == 0) && (have_effect($effect[Song of Battle]) == 0))
		{
			//When do we consider Song of Cockiness?
			buffMaintain($effect[Song of Fortune], 10, 1, 1);
			if(have_effect($effect[Song of Fortune]) == 0)
			{
				buffMaintain($effect[Song of Accompaniment], 10, 1, 1);
			}
		}
		else if((place.turns_spent > 1) && (place != get_property("auto_priorLocation").to_location()))
		{
			//When do we consider Song of Cockiness?
			buffMaintain($effect[Song of Fortune], 10, 1, 1);
			if(have_effect($effect[Song of Fortune]) == 0)
			{
				buffMaintain($effect[Song of Accompaniment], 10, 1, 1);
			}
		}
	}

	if (isActuallyEd())
	{
		// make sure we have enough MP to cast our most expensive spells
		// Wrath of Ra (yellow ray) is 40 MP, Curse of Stench (sniff) is 35 MP & Curse of Vacation (banish) is 30 MP.
		if (place != $location[The Shore, Inc. Travel Agency])
		{
			acquireMP(40, 1000);
			// ensure we can cast at least Fist of the Mummy or Storm of the Scarab.
			// so we don't waste adventures when we can't actually kill a monster.
			acquireMP(8, 0);
		}

		if (my_hp() == 0)
		{
			// the game doesn't let you adventure if you have no HP even though Ed
			// gets a full heal when he goes to the underworld
			// only necessary if a non-combat puts you on 0 HP.
			edAcquireHP();
		}
	}

	if(in_tcrs())
	{
		if(my_class() == $class[Sauceror] && my_sign() == "Blender")
		{
			if (0 == have_effect($effect[Uncucumbered]))
			{
				auto_buyUpTo(1, $item[hair spray]);
				use(1, $item[hair spray]);
			}
			// below no longer applicable due to current seed, will find new source
			//	if (0 == have_effect($effect[Minerva\'s Zen]))
			//	{
			//		auto_buyUpTo(1, $item[glittery mascara]);
			//		use(1, $item[glittery mascara]);
			//	}
		}
	}

	// this calls the appropriate provider for +combat or -combat depending on the zone we are about to adventure in..
	boolean burningDelay = ((auto_voteMonster(true) || isOverdueDigitize() || auto_sausageGoblin() || auto_backupTarget() || auto_voidMonster()) && place == solveDelayZone());
	boolean gettingLucky = (have_effect($effect[Lucky!]) > 0 && zone_hasLuckyAdventure(place));
	boolean forcedNonCombat = auto_haveQueuedForcedNonCombat();
	boolean zoneQueueIgnored = (burningDelay || gettingLucky || forcedNonCombat);
	generic_t combatModifier = zone_combatMod(place);
	if (combatModifier._boolean && !zoneQueueIgnored) {
		acquireCombatMods(combatModifier._int, true);
	}

	boolean considerCrystalBallBonus = false;
	if(auto_haveCrystalBall())
	{
		if(zoneQueueIgnored || get_property("auto_nextEncounter").to_monster() != $monster[none])
		{
			//if already forced by something else, no need to handle your ball
		}
		else if(!auto_forceHandleCrystalBall(place))
		{
			//equipping the crystal ball can't hurt but it is neither forced nor forbidden
			//will consider giving it a maximizer bonus after checking if monster queue control is wanted
			considerCrystalBallBonus = true;
		}
	}
	
	monster [int] possible_monsters;
	if(get_property("auto_nextEncounter").to_monster() != $monster[none])
	{
		//next monster is forced by zone mechanics or by now locked-in miniature crystal ball
		possible_monsters[count(possible_monsters)] = get_property("auto_nextEncounter").to_monster();
	}
	else
	{
		foreach i,mon in get_monsters(place)
		{
			//consider all possible monsters, with queue effects argument false
			//	queue argument true would return only crystal ball prediction if there is one and equipped,
			//	but here keeping ball equipped will be either not guaranteed if monsters don't matter, or forbidden
			if(appearance_rates(place)[mon] > 0)
			{
				possible_monsters[count(possible_monsters)] = mon;
			}
		}
	}
	
	boolean zoneHasUnwantedMonsters;
	boolean zoneHasWantedMonsters;
	if (!zoneQueueIgnored)	//next encounter is a monster from the zone
	{
		foreach i,mon in possible_monsters
		{
			if(auto_wantToYellowRay(mon, place))
			{
				adjustForYellowRayIfPossible(mon);
				zoneHasWantedMonsters = true;
			}
			boolean wantToBanish  = auto_wantToBanish(mon, place);
			boolean wantToFreeRun = auto_wantToFreeRun(mon, place);
			if(wantToBanish || wantToFreeRun)
			{
				// attempt to prepare for banishing, but if we can not try free running
				boolean willBanish = false;
				if (wantToBanish)
				{
					willBanish = adjustForBanishIfPossible(mon, place);
				}
				if(!willBanish)
				{
					adjustForFreeRunIfPossible(mon,place);
				}
				zoneHasUnwantedMonsters = true;
			}
			if(auto_wantToReplace(mon, place))
			{
				adjustForReplaceIfPossible(mon);
				zoneHasUnwantedMonsters = true;
			}
			if(auto_wantToSniff(mon, place))
			{
				adjustForSniffingIfPossible(mon);
				zoneHasWantedMonsters = true;
			}
		}
	}
	if(considerCrystalBallBonus)
	{
		//give miniature crystal ball a maximizer bonus only if the location has monsters to avoid or target
		//TODO give 0 if tally of available banishes and no sniff makes trying to avoid unwanted monsters with ball not worthwhile?
		int crystalBallMaximizerBonus = 0 + (zoneHasUnwantedMonsters ? 300 : 0) + (zoneHasWantedMonsters ? 300 : 0);
		if(crystalBallMaximizerBonus != 0)
		{
			addToMaximize("+" + crystalBallMaximizerBonus + "bonus "+wrap_item($item[miniature crystal ball]).to_string());
		}
	}

	// Equip the combat lover's locket if we're missing a monster in the zone
	if (auto_haveCombatLoversLocket())
	{
		foreach mon,rate in appearance_rates(place)
		{
			if (rate > 0 && mon.id > 0 && mon.copyable && !mon.boss && !auto_monsterInLocket(mon) && place != $location[Noob Cave])
			{
				// We use Noob Cave as the placeholder location for zoneless encounters so lets not equip it when we're not actually going there.
				auto_log_info('We want to get the "' + mon + '" monster into the combat lover\'s locket from ' + place + ", so we're bringing it along.", "blue");
				autoEquip($item[combat lover\'s locket]);
				break;
			}
		}
	}

	if(in_koe() && possessEquipment($item[low-pressure oxygen tank]))
	{
		autoEquip($item[low-pressure oxygen tank]);
	}

	// Latte may conflict with certain quests. Ignore latte drops for the greater good.
	boolean[location] IgnoreLatteDrop = $locations[The Haunted Boiler Room];
	if(auto_latteDropWanted(place) && !(IgnoreLatteDrop contains place) && !is_boris())
	// boris has no way to equip latte mug or Kramco (no offhand or familiar)
	{
		if(auto_sausageGoblin() && place == solveDelayZone())
		{
			// Burning delay using a Sausage Goblin. Can't hold both the Kramco and the Latte, we only have one off-hand!
			if(canChangeToFamiliar($familiar[Left-Hand Man]))
			{
				// If we can use the Left-Hand man, we can get a two-fer with both the Kramco and Latte
				// Hurrah! We found an actual use for it, it's not useless after all!
				auto_log_info('We want to get the "' + auto_latteDropName(place) + '" ingredient for our Latte from ' + place + ", and we're buring delay using the Kramco so your Left-Hand Man will be bringing your Latte along!", "blue");				handleFamiliar($familiar[Left-Hand Man]);
				handleFamiliar($familiar[Left-Hand Man]);
				use_familiar($familiar[Left-Hand Man]); // update familiar already called so have to force.
				autoEquip($slot[familiar], $item[latte lovers member\'s mug]);
			}
		}
		else
		{
			auto_log_info('We want to get the "' + auto_latteDropName(place) + '" ingredient for our Latte from ' + place + ", so we're bringing it along.", "blue");
			autoEquip($item[latte lovers member\'s mug]);
		}
	}

	if(get_property("auto_forceNonCombatSource") == "jurassic parka" && !get_property("auto_parkaSpikesDeployed").to_boolean())
	{
		autoForceEquip(wrap_item($item[jurassic parka])); //equips parka and forbids maximizer tampering with shirt slot
		//not using auto_configureParka("spikes") so maximizer stays aware of ML from shirt, instead of maximizing with another shirt or no shirt before changing to parka
		set_property("auto_parkaSetting","spikes"); 
		if (get_property("parkaMode") != "spikolodon")
		{
			cli_execute(`parka spikolodon`);
		}
	}
	
	item exting = wrap_item($item[industrial fire extinguisher]);
	if(auto_FireExtinguisherCombatString(place) != "" || $locations[The Goatlet, Twin Peak, The Hidden Bowling Alley, The Hatching Chamber, The Feeding Chamber, The Royal Guard Chamber] contains place)
	{
		autoEquip(exting);
	}
	else if(auto_availableBrickRift() == place)
	{
		autoEquip(exting); // polar vortex for shadow bricks
	}
	else if(in_wildfire() && auto_haveFireExtinguisher() && place.fire_level > 3)
	{
		addBonusToMaximize(exting, 200); // extinguisher prevents per-round hot damage in wildfire path 
	}


	if(in_plumber())
	{
		int pool_skill = speculative_pool_skill();
		if (possessEquipment($item[Pool Cue]))
		{
			pool_skill += 3;
		}
		// Even though there are ghosts in the Billiards Room, we want to equip
		// the pool cue to finish up the quest.
		boolean skip_equipping_flower = place == $location[The Haunted Billiards Room] && 18 <= pool_skill;

		// Ziggurat has a ghost BUT when clearing out lianas, we want to equip
		// machete in mainhand and use boots.
		if(place == $location[A Massive Ziggurat])
		{
			int lianaFought = 0;
			foreach i,s in place.combat_queue.split_string("; ")
			{
				if(s == "dense liana")
				{
					++lianaFought;
				}
			}
			if(lianaFought < 3)
			{
				skip_equipping_flower = true;
			}
		}
		if ((is_ghost_in_zone(place) && !skip_equipping_flower)
			|| (place == $location[The Smut Orc Logging Camp] && possessEquipment($item[frosty button])))
		{
			if(!plumber_equipTool($stat[mysticality]))
			{
				abort("I'm scared to adventure in a zone with ghosts without a fire flower. Please fight a bit and buy me a fire flower.");
			}
		}
		else
		{
			plumber_equipTool($stat[moxie]);
		}

		// It is dangerous out there! Take this!
		int flyeredML = get_property("flyeredML").to_int();
		boolean have_pill_keeper = (possessEquipment($item[Eight Days a Week Pill Keeper])) &&
			(is_unrestricted($item[Unopened Eight Days a Week Pill Keeper]));

		if(0 < flyeredML && flyeredML < 10000 && in_plumber() && have_pill_keeper)
		{
			auto_log_debug("I expect to be flyering, equipping Pill Keeper to skip the first hit.");
			autoEquip($slot[acc3], $item[Eight Days a Week Pill Keeper]);
		}
	}

	// Use some instakills. Can't use Chest X-Ray in Pocket Familiars.
	item DOCTOR_BAG = $item[Lil\' Doctor&trade; Bag];
	if(auto_is_valid(DOCTOR_BAG) && possessEquipment(DOCTOR_BAG) && auto_is_valid($skill[Chest X-Ray]) && (get_property("_chestXRayUsed").to_int() < 3) && my_adventures() <= 19 && !in_pokefam())
	{
		auto_log_info("We still haven't used Chest X-Ray, so let's equip the doctor bag.");
		autoEquip($slot[acc3], DOCTOR_BAG);
	}

	item dartHolster = $item[Everfull Dart Holster];
	if(auto_haveDarts() && have_effect($effect[Everything Looks Red]) == 0 && !in_ag())
	{
		auto_log_info("We don't have ELR so let's hit a bullseye");
		autoEquip($slot[acc3], dartHolster);
	}


	equipOverrides();
	kolhs_preadv(place);
	ag_bgChat();

	if (is100FamRun() && my_familiar() == $familiar[none])
	{
		// re-equip a familiar if it's a 100% run just in case something unequipped it
		// looking at you auto_maximizedConsumeStuff()...
		// and L12_themtharHills()...
		use_familiar(get_property("auto_100familiar").to_familiar());
		auto_log_debug("Re-equipped your " + get_property("auto_100familiar") + " as something had unequipped it. This is bad and should be investigated.");
	}

	if($locations[Vanya's Castle, The Fungus Plains, Megalo-City, Hero's Field] contains place && (my_turncount() != 0))
	{
		if(!possessEquipment($item[Continuum Transfunctioner]))
		{
			abort("Tried to be retro but lacking the Continuum Transfunctioner.");
		}
		autoEquip($slot[acc3], $item[Continuum Transfunctioner]);
	}

	if((place == $location[Inside The Palindome]) && (my_turncount() != 0))
	{
		if(!possessEquipment($item[Talisman O\' Namsilat]))
		{
			abort("Tried to go to The Palindome but don't have the Namsilat");
		}
		autoEquip($slot[acc3], $item[Talisman O\' Namsilat]);
	}

	if((place == $location[The Haunted Boiler Room]) && (my_turncount() != 0) && internalQuestStatus("questL11Manor") < 3)
	{
		if(!possessEquipment($item[Unstable Fulminate]))
		{
			abort("Tried to charge a WineBomb but don't have one.");
		}
		if(equipped_amount($item[Unstable Fulminate]) == 0)
		{
			auto_log_warning("Tried to adventure in [The Haunted Boiler Room] without an [Unstable Fulminate]... correcting", "red");
			autoForceEquip($slot[off-hand], $item[Unstable Fulminate]);
			if(equipped_amount($item[Unstable Fulminate]) == 0)
			{
				abort("Correction failed, please report this. Manually get the [wine bomb] then run me again");
			}
		}
	}
	
	if(place == $location[The Black Forest])
	{
		autoEquip($slot[acc3], $item[Blackberry Galoshes]);
	}

	if ($locations[Barrrney\'s Barrr, The F\'c\'le, The Poop Deck, Belowdecks] contains place) {
		if (possessEquipment($item[pirate fledges])) {
			autoEquip($slot[acc3], $item[pirate fledges]);
		} else if (possessOutfit("Swashbuckling Getup")) {
			autoOutfit("Swashbuckling Getup");
		} else {
			abort("Trying to be a pirate without being able to dress like a pirate.");
		}
	}

	bat_formPreAdventure();
	horsePreAdventure();
	auto_snapperPreAdventure(place);
	sweatpantsPreAdventure();

	boolean mayNeedItem = true;
	if (burningDelay || forcedNonCombat) {
		//when delay burning if the monster wants item drop it would not be the zone based value that follows
		//none of the uses of auto_forceNextNoncombat() will need item drop
		mayNeedItem = false;
	}
	else if (gettingLucky && !($locations[The Hidden Temple, The Red Zeppelin, A Maze of Sewer Tunnels] contains place)) {
		//Baa'baa'bu'ran is probably the only Lucky adventure that will need item drop
		mayNeedItem = false;
	}
	generic_t itemNeed = zone_needItem(place);
	if(mayNeedItem && itemNeed._boolean)
	{
		addToMaximize("50item " + (ceil(itemNeed._float) + 100.0) + "max"); // maximizer treats item drop as 100 higher than it actually is for some reason.
		simMaximize();
		float itemDrop = simValue("Item Drop");
		if(itemDrop < itemNeed._float)
		{
			if (buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 20, 1, 10))
			{
				itemDrop += 20.0;
			}
			if (buffMaintain($effect[Singer\'s Faithful Ocelot], 35, 1, 10))
			{
				itemDrop += 10.0;
			}
		}
		if(itemDrop < itemNeed._float && !haveAsdonBuff())
		{
			asdonAutoFeed(37);
			if(asdonBuff($effect[Driving Observantly]))
			{
				itemDrop += 50.0;
			}
		}
		if(itemDrop < itemNeed._float)
		{
			//if general item modifier isn't enough check specific item drop bonus
			generic_t itemFoodNeed = zone_needItemFood(place);
			generic_t itemBoozeNeed = zone_needItemBooze(place);
			float itemDropFood = itemDrop + simValue("Food Drop");
			float itemDropBooze = itemDrop + simValue("Booze Drop");
			if(itemFoodNeed._boolean && itemDropFood < itemFoodNeed._float)
			{
				auto_log_debug("Trying food drop supplements");
				//max at start of an expression with item and food drop is ineffective in combining them, have to let the maximizer try to add on top
				addToMaximize("49food drop " + ceil(itemFoodNeed._float) + "max");
				simMaximize();
				itemDropFood = simValue("Item Drop") + simValue("Food Drop");
			}
			if(itemBoozeNeed._boolean && itemDropBooze < itemBoozeNeed._float)
			{
				auto_log_debug("Trying booze drop supplements");
				addToMaximize("49booze drop " + ceil(itemBoozeNeed._float) + "max");
				simMaximize();
				itemDropBooze = simValue("Item Drop") + simValue("Booze Drop");
				//no zone item yet needs both food and booze, bottle of Chateau de Vinegar exception is a cooking ingredient but doesn't use food drop bonus
			}
			if((itemFoodNeed._boolean && itemDropFood >= itemFoodNeed._float) ||
			(itemBoozeNeed._boolean && itemDropBooze >= itemBoozeNeed._float))
			{
				//the needed item was Food/Booze and need has been met with specific bonus
			}
			else
			{
				auto_log_debug("We can't cap this drop bear!", "purple");
			}
		}
	}


	// Only cast Paul's pop song if we expect it to more than pay for its own casting.
	//	Casting before ML variation ensures that this, the more important buff, is cast before ML.
	if(auto_predictAccordionTurns() >= 8)
	{
		buffMaintain($effect[Paul\'s Passionate Pop Song]);
	}

	// ML adjustment zone section
	boolean doML = true;
	boolean removeML = false;
		// removeML MUST be true for purgeML to be used. This is only used for -ML locations like Smut Orc, and you must have 5+ SGEAs to use.
		boolean purgeML = false;

	boolean[location] highMLZones = $locations[Oil Peak, The Typical Tavern Cellar, The Haunted Boiler Room, The Defiled Cranny];
	boolean[location] lowMLZones = $locations[The Smut Orc Logging Camp, Fight in the Dirt, Fight in the Tall Grass, Fight in the Very Tall Grass];

	// Generic Conditions
	if(inAftercore())
	{
		doML = false;
		removeML = false;
		purgeML = false;
	}

		// NOTE: If we aren't quits before we pass L13, let us gain stats.
	if ((get_property("flyeredML").to_int() > 9999 || internalQuestStatus("questL12War") > 1 || get_property("sidequestArenaCompleted") != "none") && my_level() > 12)
	{
		doML = false;
		removeML = true;
		purgeML = false;
	}

	// Allow user settable option to override the above settings to not slack off ML
	if (my_level() > 12 && get_property("auto_disregardInstantKarma").to_boolean())
	{
		doML = true;
		removeML = false;
		purgeML = false;
	}

	// Backup Camera copies have double ML applied. Reduce ML to avoid getting beaten up
	if(auto_backupTarget())
	{
		doML = false;
		removeML = true;
		purgeML = false;
	}
	
	// Gremlins specific. need to let them hit so avoid ML unless defense is very high
	if(junkyardML && my_buffedstat($stat[moxie]) < (2*monster_attack($monster[erudite gremlin])))
	{
		doML = false;
		removeML = true;
		purgeML = false;
	}

	// monster level increases zone damage. don't re apply ML buff shrugged by level_11.ash
	if(place == $location[The Copperhead Club])
	{
		doML = false;
		removeML = true;
		purgeML = false;
	}

	// Location Specific Conditions
	if(lowMLZones contains place)
	{
		doML = false;
		removeML = true;
		purgeML = true;
	}
	if(highMLZones contains place)
	{
		doML = true;
		removeML = false;
		purgeML = false;
	}

	// Path Specific Conditions
	if(is_professor())  //WereProfessor professor doesn't like ML
	{
		doML = false;
		removeML = true;
		purgeML = true;
	}

	// Act on ML settings
	if(doML)
	{
		// Catch when we leave lowMLZone, allow for being "side tracked" by delay burning
		if((have_effect($effect[Driving Intimidatingly]) > 0) && (get_property("auto_debuffAsdonDelay").to_int() >= 2))
		{
			auto_log_debug("No Reason to delay Asdon Usage");
			uneffect($effect[Driving Intimidatingly]);
			set_property("auto_debuffAsdonDelay", 0);
		}
		else if((have_effect($effect[Driving Intimidatingly]).to_int() == 0)  && (get_property("auto_debuffAsdonDelay").to_int() >= 0))
		{
			set_property("auto_debuffAsdonDelay", 0);
		}
		else
		{
			set_property("auto_debuffAsdonDelay", get_property("auto_debuffAsdonDelay").to_int() + 1);
			auto_log_debug("Delaying debuffing Asdon: " + get_property("auto_debuffAsdonDelay"));
		}

		auto_MaxMLToCap(auto_convertDesiredML(150), false);
	}

	// If we are in some state where we do not want +ML (Level 13 or Smut Orc) make sure ML is removed
	if(removeML)
	{
		auto_change_mcd(0);
		addToMaximize("-10ml");
		uneffect($effect[Driving Recklessly]);
		uneffect($effect[Ur-Kel\'s Aria of Annoyance]);

		if(purgeML && item_amount($item[soft green echo eyedrop antidote]) > 5)
		{
			uneffect($effect[Drescher\'s Annoying Noise]);
			uneffect($effect[Pride of the Puffin]);
			uneffect($effect[Ceaseless Snarling]);
			uneffect($effect[Blessing of Serqet]);
		}
		else if (purgeML && isActuallyEd() && (item_amount($item[ancient cure-all]) > 0 || item_amount($item[soft green echo eyedrop antidote]) > 0))
		{
			uneffect($effect[Blessing of Serqet]);
		}
	}
	
	// Here we give a limited value to ML if +/-ML is not specifically called in the current maximizer string. This does not enforce the limit.
	// if the limit setting has no value then ML has already been given a value indirectly by "exp" in the default maximizer statement
	if((get_property("auto_MLSafetyLimit") != "") && (!contains_text(get_property("auto_maximize_current"), "ml")))
	{
		if(get_property("auto_MLSafetyLimit").to_int() == -1)
		{
			// prevent all ML being equiped if limit is -1 and equip lowest possible ML including going negative
			addToMaximize("-1000ml");
		}
		else if(get_property("auto_MLSafetyLimit").to_int() <= highest_available_mcd())
		{
			//mcd can already fill all allowed ML without using equipment slots
			//if the value is 0 adding ML with 0max is useless, it does not stop the maximizer from picking equipment with ML,
			//0max would just tell the maximizer to add +0 value to ML over 0 which is the same as not giving any value for ML
		}
		else
		{
			// note: maximizer will allow to go above the max value, ML just won't contribute to the total score after the max value
			addToMaximize("ml " + get_property("auto_MLSafetyLimit").to_int() + "max");
		}
	}
	
	// Last minute switching for garbage tote. But only if nothing called on januaryToteAcquire this turn.
	if(!get_property("auto_januaryToteAcquireCalledThisTurn").to_boolean() && auto_is_valid($item[Wad of Used Tape]))
	{
		januaryToteAcquire($item[Wad Of Used Tape]);
	}

	// EQUIP MAXIMIZED GEAR
	auto_ghost_prep(place);
	equipMaximizedGear();
	auto_handleRetrocape(); // has to be done after equipMaximizedGear otherwise the maximizer reconfigures it
	auto_handleParka(); //same as retrocape above
	if(auto_handleCCSC() && !have_equipped($item[Candy Cane Sword Cane]))
	{
		autoForceEquip($item[Candy Cane Sword Cane]); // Force the candy cane sword cane if June cleaver has been buffed beyond the 1000 bonus boost
	}
	cli_execute("checkpoint clear");

	//before guaranteed non combats that give stats, overrule maximized equipment to increase stat gains
	if(place == $location[The Hidden Bowling Alley] && item_amount($item[Bowling Ball]) > 0 && get_property("hiddenBowlingAlleyProgress").to_int() < 5)
	{
		equipStatgainIncreasers();
		plumber_forceEquipTool();
	}
	else if(place == $location[The Haunted Ballroom] && internalQuestStatus("questM21Dance") == 3)
	{
		equipStatgainIncreasers();
		plumber_forceEquipTool();
	}
	else if(place == $location[The Shore\, Inc. Travel Agency] && item_amount($item[Forged Identification Documents]) == 0)
	{
		equipStatgainIncreasers(my_primestat(),true);	//The Shore, Inc. Travel Agency choice 793 is configured to pick main stat or all stats
		plumber_forceEquipTool();
	}

	if (isActuallyEd() && is_wearing_outfit("Filthy Hippy Disguise") && place == $location[Hippy Camp]) {
		equip($slot[Pants], $item[None]);
		put_closet(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
		if (is_wearing_outfit("Filthy Hippy Disguise")) {
			abort("Tried to adventure in the Hippy Camp as Actually Ed the Undying wearing the Filthy Hippy Disguise (this is bad).");
		} else {
			auto_log_info("Took off the Filthy Hippy Disguise before adventuring in the Hippy Camp so we don't waste adventures on non-combats.");
		}
	}

	// Last minute debug logging and a final MCD tweak just in case Maximizer did silly stuff
	if(lowMLZones contains place)
	{
		auto_log_debug("Going into a LOW ML ZONE with ML: " + monster_level_adjustment());
	}
	else
	{
		// Last minute MCD alterations if Limit set, otherwise trust maximizer
		if(get_property("auto_MLSafetyLimit") != "" && !removeML)
		{
			auto_setMCDToCap();
		}

		auto_log_debug("Going into High or Standard ML Zone with ML: " + monster_level_adjustment());
	}	

	executeFlavour();

	// After maximizing equipment, we might not be at full HP
	if ($locations[Tower Level 1, The Invader] contains place)
	{
		acquireHP();
	}

	if (my_hp() <= (my_maxhp() * 0.75)) {
		acquireHP();
	}

	// always heal to full HP for Boo Clues
	if(($locations[A-Boo Peak] contains place) && (get_property("auto_aboopending").to_int() != 0))
	{
		acquireHP();
		if(isActuallyEd())
		{
			//force Ed to heal
			edAcquireHP(my_maxhp());
		}
	}

	//my_mp is broken in Dark Gyffte
	if (!in_darkGyffte())
	{
		int wasted_mp = my_mp() + mp_regen() - my_maxmp();
		if(wasted_mp > 0 && my_mp() > 400)
		{
			auto_log_info("Burning " + wasted_mp + " MP...");
			auto_burnMP(wasted_mp);
		}
	}
	borisWastedMP();
	borisTrusty();

	int mpNeeded = 32; // enough for 5 casts of Saucestorm. Usually this should be fine for most combats
	switch (my_class())
	{
		// expand this for other cases where we need more MP for combat.
		// ideally we could ask the combat function to tell us how much MP it will need for an example encounter in the zone we are going to.
		case $class[Disco Bandit]:
			if ($locations[Shadow Rift (The Ancient Buried Pyramid), Shadow Rift (The Hidden City), Shadow Rift (The Misspelled Cemetary)] contains place)
			{
				// DB aborts in the Shadow Rifts because it runs out of MP trying to use Saucestorm against physically immune monsters when it has Extingo equipped.
				foreach sk in $skills[Disco Dance of Doom, Disco Dance II: Electric Boogaloo, Disco Dance 3: Back in the Habit]
				{
					// yes it casts all 3 of those first then tries to repeat Saucestorm. On 32 or so MP.
					if (auto_have_skill(sk))
					{
						mpNeeded += mp_cost(sk);
					}
				}
			}
			break;
		default:
			break;
	}
	acquireMP(mpNeeded, 0);
                       
  //acquireMP won't do anything if the maxMP isn't big enough,
  //so we'll use this to ensure we have MP in low max scenarios
  if(my_maxmp() < mpNeeded)
	{
		low_mp_handler();
	}

	if(in_hardcore() && (my_class() == $class[Sauceror]) && (my_mp() < 32))
	{
		auto_log_warning("We don't have a lot of MP but we are chugging along anyway", "red");
	}
	lar_abort(place);
	if (my_inebriety() > inebriety_limit())
	{
		if($locations[The Tunnel of L.O.V.E.] contains place)
		{
			auto_log_info("Trying to adv in [" +place+ "] while overdrunk... is actually permitted", "blue");
		}
		else abort("Trying to adv in [" +place+ "] while overdrunk... Stop it.");
	}
		
	if(in_pokefam())
	{
		// Build the team at the beginning of each adventure.
		pokefam_makeTeam();
	}

	utilizeStillsuit();

	set_property("auto_priorLocation", place);
	auto_log_info("Pre Adventure at " + place + " done, beep.", "blue");
	
	//try to catch infinite loop where we repeatedly try to do the same thing.
	//works with code found in auto_post_adv.ash
	set_property("_auto_inf_session_adv", my_session_adv());
	
	//to avoid constant flipping on the MCD. change it right before adventuring
	int mcd_target = get_property("auto_mcd_target").to_int();
	if(current_mcd() != mcd_target)
	{
		change_mcd(mcd_target);
	}

	print_footer();
	return true;
}

void main()
{
	boolean ret = false;
	try
	{
		ret = auto_pre_adventure();
	}
	finally
	{
		if (!ret)
		{
			auto_log_error("Error running auto_pre_adv.ash, setting auto_interrupt=true");
			set_property("auto_interrupt", true);
		}
		auto_interruptCheck();
	}
}
