# This is meant for items that have a date of 2022

boolean auto_haveCosmicBowlingBall()
{
	// ensure we not only own one but it's in allowed in path and also in inventory for us to do stuff with.
	return (get_property("hasCosmicBowlingBall").to_boolean() && auto_is_valid($item[Cosmic Bowling Ball]) && available_amount($item[Cosmic Bowling Ball]) > 0);
}

string auto_bowlingBallCombatString(location place, boolean speculation)
{
	if(!auto_haveCosmicBowlingBall())
	{
		return "";
	}

	if(place == $location[The Hidden Bowling Alley] && get_property("auto_bowledAtAlley").to_int() != my_ascensions())
	{
		if(!speculation)
		{
			set_property("auto_bowledAtAlley", my_ascensions());
			auto_log_info("Cosmic Bowling Ball used at Hidden Bowling Alley to advance quest.");
		}	
		return useItem($item[Cosmic Bowling Ball],!speculation);
	}

	// determine if we want more stats
	if(canUse($skill[Bowl Sideways]))
	{
		// increase stats if we are power leveling
		if(isAboutToPowerlevel())
		{
			return useSkill($skill[Bowl Sideways],!speculation);
		}
		// increase stats if we are farming Ka as Ed
		if(get_property("_auto_farmingKaAsEd").to_boolean())
		{
			return useSkill($skill[Bowl Sideways],!speculation);
		}
	}

	// determine if we want more item or meat bonus
	if(canUse($skill[Bowl Straight Up]))
	{
		// increase item bonus if not item capped in current zone
		generic_t itemNeed = zone_needItem(place);
		if(itemNeed._boolean)
		{
			if(item_drop_modifier() < itemNeed._float)
			{
				return useSkill($skill[Bowl Straight Up],!speculation);
			}
		}

		// increase meat bonus if doing nuns
		if(place == $location[The Themthar Hills])
		{
			return useSkill($skill[Bowl Straight Up],!speculation);
		}	
	}

	return "";
}

boolean auto_haveCombatLoversLocket()
{
	return possessEquipment($item[combat lover\'s locket]) && auto_is_valid($item[combat lover\'s locket]);
}

int auto_CombatLoversLocketCharges()
{
	// can fight up to 3 unique monsters by reminiscing with the locket
	if (!auto_haveCombatLoversLocket())
	{
		return 0;
	}

	string locketMonstersFought = get_property("_locketMonstersFought");

	// check if we haven't found any yet
	if(locketMonstersFought == "")
	{
		return 3;
	}

	return 3 - count(split_string(locketMonstersFought, ","));
}

boolean auto_haveReminiscedMonster(monster mon)
{
	string[int] idList = split_string(get_property("_locketMonstersFought"),",");
	foreach index, id in idList
	{
		if(to_monster(id) == mon)
		{
			return true;
		}
	}
	return false;
}

boolean auto_monsterInLocket(monster mon)
{
	boolean[monster] captured = get_locket_monsters();
	return captured contains mon;
}

boolean auto_fightLocketMonster(monster mon, boolean speculative)
{
	if(auto_CombatLoversLocketCharges() < 1)
	{
		return false;
	}

	if(!auto_monsterInLocket(mon))
	{
		return false;
	}

	if(auto_haveReminiscedMonster(mon))
	{
		return false;
	}

	if(speculative)
	{
		return true;
	}

	auto_log_info("Using locket to summon " + mon.name, "blue");
	string[int] pages;
	pages[0] = "inventory.php?reminisce=1";
	pages[1] = "choice.php?whichchoice=1463&pwd&option=1&mid=" + mon.id;
	if(autoAdvBypass(1, pages, $location[Noob Cave], ""))
	{
		handleTracker(mon, $item[combat lover\'s locket], "auto_copies");
	}

	if(!auto_haveReminiscedMonster(mon))
	{
		auto_log_error("Attempted to fight " + mon.name + " by reminiscing with Combat Lover's Locket, but failed.");
		return false;
	}

	return true;

}

boolean auto_haveGreyGoose()
{
	if(auto_have_familiar($familiar[Grey Goose]))
	{
		return true;
	}
	return false;
}

int gooseExpectedDrones()
{
	if(!auto_haveGreyGoose()) return 0;
	if(my_familiar() == $familiar[Grey Goose])
	{
		set_property("auto_gooseExpectedDrones", familiar_weight($familiar[Grey Goose]) - 5);
	}
	return get_property("auto_gooseExpectedDrones").to_int();
}

boolean dronesOut() //want a function to override the task order if we have drones out so as not to waste them
{
	if(!auto_haveGreyGoose()) return false;
	if(get_property("gooseDronesRemaining").to_int() > 0)
	{
		return true;
	}
	return false;
}

void prioritizeGoose() //prioritize Goose only if we still have things to get
{
	if(!auto_haveGreyGoose()) return;
	if(	internalQuestStatus("questL04Bat") <= 1 ||
		(item_amount($item[Stone Wool]) == 0 && have_effect($effect[Stone-Faced]) == 0 && internalQuestStatus("questL11Worship") <= 2) ||
		internalQuestStatus("questL08Trapper") <= 1 ||
		((internalQuestStatus("questL09Topping") >= 2 && internalQuestStatus("questL09Topping") <= 3) && get_property("twinPeakProgress").to_int() < 15) ||
		(needStarKey() && (item_amount($item[star]) < 8 && item_amount($item[line]) < 7)) ||
		internalQuestStatus("questL11Ron") < 5 ||
		(get_property("hiddenBowlingAlleyProgress").to_int() + item_amount($item[Bowling Ball])) < 6 ||
		((item_amount($item[Crumbling Wooden Wheel]) + item_amount($item[Tomb Ratchet])) < 10))
	{
		set_property("auto_prioritizeGoose", true);
	}
	set_property("auto_prioritizeGoose", false);
}

boolean canUseCleaver() {
	if (possessEquipment($item[June cleaver]) && can_equip($item[June cleaver]) && auto_is_valid($item[June cleaver])) {
		return true;
	}
	return false;
}

void juneCleaverChoiceHandler(int choice)
{
	switch(choice) {
		case 1467: // Poetic Justice
			if (have_skill($skill[Tongue of the Walrus]) || item_amount($item[personal massager]) > 0) {
				run_choice(3); // +5 adventures, get beaten up
			} else if ((my_primestat() == $stat[mysticality] && (my_level() < 13 || disregardInstantKarma())) || (my_primestat() == $stat[moxie] && my_level() > 12 && disregardInstantKarma() == false)) {
				run_choice(2); // 137 myst substat
			}
			else {
				run_choice(1); // 250 moxie substat
			}
			break;
		case 1468: // Aunts not Ants
			if ((my_primestat() == $stat[moxie] && (my_level() < 13 || disregardInstantKarma())) || (my_primestat() == $stat[muscle] && my_level() > 12 && disregardInstantKarma() == false)) {
				run_choice(1); // 150 moxie substat
			} else if(get_property("_juneCleaverSkips").to_int() < 5) {
				run_choice(4); // skip
			} else {
				run_choice(2); // 250 muscle substat
			}
			break;
		case 1469: // Beware of Alligators
			if (my_meat() < meatReserve()) {
				run_choice(3); // 1500 meat
			} else if (can_drink() && my_inebriety() < inebriety_limit()) {
				run_choice(2); // size 1 awesome booze
			} else {
				run_choice(3); // 1500 meat
			}
			break;
		case 1470: // Teacher's Pet
			if (can_equip($item[teacher\'s pen]) && available_amount($item[teacher\'s pen]) < 1) {
				run_choice(2); // accessory, +2 fam exp, +3 stats per fight
			} else if (my_primestat() == $stat[muscle] && (my_level() < 13 || disregardInstantKarma())) {
				run_choice(3);
			} else if(get_property("_juneCleaverSkips").to_int() < 5) {
				run_choice(4); // skip
			} else {
				run_choice(2); // accessory, +2 fam exp, +3 stats per fight
			}
			break;
		case 1471: // Lost and Found
			if ((get_property("sidequestNunsCompleted") == "none") && (get_property("auto_skipNuns") == "false") && (item_amount($item[savings bond]) == 0)) {
				run_choice(1); // potion, 30 turns of 50% meat
			} else if (my_primestat() == $stat[mysticality] && (my_level() < 13 || disregardInstantKarma())) {
				run_choice(3); // 250 myst substat
			} else {
				run_choice(1); // potion, 30 turns of 50% meat
			}
			break;
		case 1472: // Summer Days
			run_choice(1); // potion, -5 combat rate, 30 turns
			break;
		case 1473: // Bath Time
			if(my_primestat() == $stat[muscle] && (my_level() < 13 || disregardInstantKarma())) {
				run_choice(1); // 250 muscle substat
			} else if(get_property("_juneCleaverSkips").to_int() < 5) {
				run_choice(4); // skip
			} else {
				run_choice(3); // effect, 30 turns of +3 hot res, +50% init
			}
			break;			
		case 1474: // Delicious Sprouts
			if (can_eat() && my_level() < 13 && 
			have_fireworks_shop() && auto_is_valid($item[red rocket]) &&
			auto_is_valid($item[guilty sprout]) && item_amount($item[guilty sprout]) == 0)
				run_choice(2); // guilty sprout is level 8+ good size 1 food but it gives big stats, would want to use a red rocket
			if (my_primestat() == $stat[mysticality] && (my_level() < 13 || disregardInstantKarma())) {
				run_choice(1); // 250 myst substat
			} else if (my_primestat() == $stat[muscle] && (my_level() < 13 || disregardInstantKarma())) {
				run_choice(3); // 138 muscle substat
			} else {
				run_choice(2); // guilty sprout is level 8+ good size 1 food but it gives big stats
			}
			break;
		case 1475: // Hypnotic Master
			if (available_amount($item[mother\'s necklace]) < 1) {
				run_choice(1); // 3 RO adventures, 5 free rests (doesn't even need to be equipped), never fumble
			} else if (my_primestat() == $stat[muscle] && (my_level() < 13 || disregardInstantKarma())) {
				run_choice(2); // 250 muscle substat
			} else {
				run_choice(1); // autosells for 1000 meat
			}
			break;
		default:
			abort("unhandled choice in juneCleaverChoiceHandler");
	}
}

boolean canUseSweatpants() {
	if (possessEquipment($item[designer sweatpants]) && can_equip($item[designer sweatpants]) && auto_is_valid($item[designer sweatpants])) {
		return true;
	}
	return false;
}

int getSweat() {
	return get_property("sweat").to_int();
}

void sweatpantsPreAdventure() {
	if (!canUseSweatpants()) {
		return;
	}

	if (my_location() == $location[A Mob of Zeppelin Protesters] && equipped_item($slot[pants]) != $item[lynyrdskin breeches]) {
		return;	//want to keep all the sleaze damage bonus in this location
	}

	int sweat = getSweat();
	int liverCleaned = get_property("_sweatOutSomeBoozeUsed").to_int();

	if (sweat >= 25 && liverCleaned < 3 && my_inebriety() > 0) {
		if (my_location() == $location[The Haunted Billiards Room] && my_inebriety() <= 10) {
			//want to keep inebriety for pool skill
		}
		else {
			use_skill($skill[Sweat Out Some Booze]);
		}
	}

	// This is just opportunistic use of sweat. This skill should be used in auto_restore.ash.
	if (sweat >= 95 && my_mp() < my_maxmp()) {
		use_skill($skill[Sip Some Sweat]);
	}
}

boolean auto_hasStillSuit()
{
	return possessEquipment($item[tiny stillsuit]) && auto_is_valid($item[tiny stillsuit]);
}

int auto_expectedStillsuitAdvs()
{
	if(!auto_hasStillSuit()) return 0;
	int sweat = get_property("familiarSweat").to_int();
	// can't consume until at least 10 sweat has been accumulated
	if(sweat < 10) return 0;

	return(round(sweat**0.4));
}

void utilizeStillsuit() {
	//called at the end of pre adv to make sure stillsuit is at least kept equipped on a familiar in the terrarium
	if(!auto_hasStillSuit())
	{
		return;
	}

	//if there is a tiny stillsuit in inventory then unless there was a tracking error it is not worn by any familiar
	if(!pathAllowsChangingFamiliar())
	{
		return;
	}

	//make sure all this nice familiar sweat doesn't go uncollected when current familiar is wearing something else
	if(familiar_equipped_equipment(my_familiar()) == $item[tiny stillsuit])
	{
		return;
	}

	familiar sweetestSweatFamiliar()
	{
		familiar currentFamiliar = my_familiar();
		
		//todo better choice of best familiar effects
		foreach sweetSweatFamiliar in $familiars[Grinning Turtle,Grouper Groupie,Star Starfish,Cat Burglar,Slimeling,Sleazy Gravy Fairy]	//these give item and sleaze
		{
			if(have_familiar(sweetSweatFamiliar) && auto_is_valid(sweetSweatFamiliar) && sweetSweatFamiliar != currentFamiliar)
			{
				return sweetSweatFamiliar;
			}
		}
		foreach commonFamiliar in $familiars[Baby Gravy Fairy,Smiling Rat,Mosquito,Reassembled Blackbird]		//default fall back, you probably have one of these
		{
			if(have_familiar(commonFamiliar) && auto_is_valid(commonFamiliar) && commonFamiliar != currentFamiliar)
			{
				return commonFamiliar;
			}
		}
		foreach anyFamiliar in $familiars[]		//if all else failed just pick any available familiar that can wear equipment
		{
			if(have_familiar(anyFamiliar) && auto_is_valid(anyFamiliar) && anyFamiliar != currentFamiliar && 
			!($familiars[Comma Chameleon,Mad Hatrack,Fancypants Scarecrow,Disembodied Hand,Ghost of Crimbo Carols,Ghost of Crimbo Cheer,Ghost of Crimbo Commerce] contains anyFamiliar))
			{
				return anyFamiliar;
			}
		}
		return $familiar[none];
	}
	familiar chosenStillsuitFamiliar = sweetestSweatFamiliar();
	if(familiar_equipped_equipment(chosenStillsuitFamiliar) != $item[tiny stillsuit])
	{
		if(item_amount($item[tiny stillsuit]) == 0)
		{
			retrieve_item($item[tiny stillsuit]);
		}
		if(item_amount($item[tiny stillsuit]) > 0)
		{
			equip(chosenStillsuitFamiliar,$item[tiny stillsuit]);
		}
		else
		{
			auto_log_warning("Failed to recover tiny stillsuit from the familiar mafia thinks is wearing it");
		}
		if(is100FamRun())
		{
			handleFamiliar(get_property("auto_100familiar").to_familiar());	//just make extra sure this didnt break 100 familiar runs but familiar should not have been swapped
		}
	}
}

boolean auto_hasParka()
{
	return possessEquipment($item[Jurassic Parka]) && auto_is_valid($item[Jurassic Parka]);
}

boolean auto_configureParka(string tag)
{
	if (!auto_hasParka() || !hasTorso())
	{
		return false;
	}

	// store the requested setting in a property so we can handle them later
	set_property("auto_parkaSetting", tag);

	// cut down potential server hits by telling the maximizer to not consider it.
	addToMaximize("-equip jurassic parka");
	return true;
}

boolean auto_handleParka()
{
	if (!auto_hasParka() || !hasTorso())
	{
		return false;
	}
	string dino =  get_property("auto_parkaSetting");
	string tempDino = dino;
	if (dino == "")
	{
		if (get_property("parkaMode") == "")
		{
			// if currently configured for stats and have been getting beaten up, change to stun
			tempDino = "kachungasaur";
		}
		else
		{
			return false;
		}	
	}
	if (!contains_text("kachungasaur | cold | hp | meat | dilophosaur | stench | acid | ghostasaurus | spooky | mp | dr | spikolodon | sleaze | ml | spikes | pterodactyl | hot | init | nc", dino))
	{
		return false;
	}
	if (dino == "cold" || dino == "meat" || dino == "hp")
	{
		tempDino = "kachungasaur";
	}
	else if(dino == "stench" || dino == "acid")
	{
		tempDino = "dilophosaur";
	}
	else if(dino == "spooky" || dino == "mp" || dino == "dr")
	{
		tempDino = "ghostsaurus";
	}
	else if(dino == "sleaze" || dino == "ml" || dino == "spikes")
	{
		tempDino = "spikolodon";
	}
	else if(dino == "hot" || dino == "init" || dino == "nc")
	{
		tempDino = "pterodactyl";
	}

	// avoid uselessly reconfiguring the parka
	if (get_property("parkaMode") != tempDino)
	{
		cli_execute(`parka {tempDino}`);
	}
	equip($item[jurassic parka]); // already configured, just equip

	return get_property("parkaMode") == tempDino && have_equipped($item[jurassic parka]);
}

boolean auto_hasAutumnaton()
{
	return get_property("hasAutumnaton").to_boolean() && auto_is_valid($item[autumn-aton]) && !in_pokefam();
}

// only valid when autumnaton is not current out on a quest
boolean auto_autumnatonCanAdv(location canAdventureInloc)
{
	if(!auto_hasAutumnaton())
	{
		return false;
	}

	if(canAdventureInloc.turns_spent == 0 && !($locations[Noob Cave, The Haunted Pantry, The Sleazy Back Alley] contains canAdventureInloc))
	{
		//zones have turn spent requirement except initial three
		return false;
	}

	if(canAdventureInloc == $location[8-bit realm] && possessEquipment($item[continuum transfunctioner]) && auto_is_valid($item[continuum transfunctioner]))
	{
		equip($item[continuum transfunctioner]);
	}

	foreach index,loc in get_autumnaton_locations()
	{
		if(loc == canAdventureInloc)
		{
			return true;
		}
	}
	return false;
}

boolean auto_autumnatonReadyToQuest()
{
	if(!auto_hasAutumnaton())
	{
		return false;
	}

	return item_amount($item[autumn-aton]) != 0;
}

location auto_autumnatonQuestingIn()
{
	return to_location(get_property("autumnatonQuestLocation"));
}

boolean auto_autumnatonCheckForUpgrade(string upgrade)
{
	string currentUpgrades = get_property("autumnatonUpgrades");
	if(contains_text(currentUpgrades,upgrade))
	{
		return true;
	}
	return false;
}

boolean auto_sendAutumnaton(location loc)
{
	if(auto_autumnatonCanAdv(loc))
	{
		cli_execute("autumnaton send " + loc);
		handleTracker("Autumnaton sent to " + loc, "auto_otherstuff");
		return true;
	}
	return false;
}

boolean auto_autumnatonQuest()
{
	if(!auto_autumnatonReadyToQuest()) return false;

	// complete any pending upgrades if haven't checked since last return
	// both of these props reset to 0 at start of day or new life due to "_" at start of them
	int completedQuestsToday = get_property("_autumnatonQuests").to_int();
	int lastQuestUpgradesChecked = get_property("_auto_lastAutumnatonUpgrade").to_int();
	if(completedQuestsToday > lastQuestUpgradesChecked)
	{
		catch cli_execute("autumnaton upgrade");
		set_property("_auto_lastAutumnatonUpgrade",completedQuestsToday);
	}

	// prioritize getting important upgrades
	if(!auto_autumnatonCheckForUpgrade("leftarm1"))
	{
		if(auto_sendAutumnaton($location[The Haunted Pantry]))
		{
			return false;
		}
		else
		{
			abort("Haunted pantry should always be available for autumnaton, but autoscend determined it is not. Report issue.");
		}
	}

	if(!auto_autumnatonCheckForUpgrade("leftleg1"))
	{
		// some bat zones may not be adventured in, so try them all
		if(auto_sendAutumnaton($location[Guano Junction])) return false;
		if(auto_sendAutumnaton($location[The Batrat And Ratbat Burrow])) return false;
		if(auto_sendAutumnaton($location[The Beanbat Chamber])) return false;
		if(auto_sendAutumnaton($location[Noob Cave])) return false;
	}

	if(!auto_autumnatonCheckForUpgrade("rightleg1"))
	{
		if(auto_sendAutumnaton($location[The Haunted Library])) return false;
		if(auto_sendAutumnaton($location[The Neverending Party])) return false;
		if(auto_sendAutumnaton($location[The Haunted Kitchen])) return false;
	}

	if(!auto_autumnatonCheckForUpgrade("rightarm1"))
	{
		if(auto_sendAutumnaton($location[The Overgrown Lot])) return false;
	}

	// should we go regardless of if we have arm upgrades?
	if(auto_autumnatonCheckForUpgrade("leftarm1") &&
	 auto_autumnatonCheckForUpgrade("rightarm1") &&
	 item_amount($item[barrel of gunpowder]) < 5 && 
	 get_property("sidequestLighthouseCompleted") == "none")
	{
		location targetLocation = $location[Sonofa Beach];
		if(!auto_autumnatonCanAdv(targetLocation) && zone_available(targetLocation))
		{
			// force one turn in zone to unlock it for bot
			return autoAdv(1, targetLocation);
		}
		if(auto_sendAutumnaton(targetLocation)) return false;
	}

	// acquire items to help quests
	if(fastenerCount() < 30 && lumberCount() < 30)
	{
		location targetLocation = $location[The Smut Orc Logging Camp];
		if(!auto_autumnatonCanAdv(targetLocation) && zone_available(targetLocation))
		{
			// force one turn in zone to unlock it for bot
			return autoAdv(1, targetLocation);
		}
		if(auto_sendAutumnaton(targetLocation)) return false;
	}

	if(hedgeTrimmersNeeded() > 0)
	{
		location targetLocation = $location[Twin Peak];
		if(!auto_autumnatonCanAdv(targetLocation) && zone_available(targetLocation))
		{
			// force one turn in zone to unlock it for bot
			// twin peak requires NC setup, call function instead of directly adventuring there
			return L9_twinPeak();
		}
		if(auto_sendAutumnaton(targetLocation)) return false;
	}

	return false;
}

boolean auto_hasSpeakEasy()
{
	return auto_is_valid($item[deed to Oliver\'s Place]) && get_property("ownsSpeakeasy").to_boolean();
}

int auto_remainingSpeakeasyFreeFights()
{
	if(!auto_hasSpeakEasy()) return 0;
	return max(3 - get_property("_speakeasyFreeFights").to_int(), 0);
}

boolean auto_haveTrainSet()
{
	return auto_get_campground() contains $item[model train set] && auto_is_valid($item[model train set]); //check if the model train set is in the campground
}

void auto_modifyTrainSet(int one, int two, int three, int four, int five, int six, int seven, int eight)
{
	string page = `choice.php?pwd&whichchoice=1485&option=1&slot[0]={one}&slot[1]={two}&slot[2]={three}&slot[3]={four}&slot[4]={five}&slot[5]={six}&slot[6]={seven}&slot[7]={eight}`;
	visit_url(page,true,true);
	visit_url("main.php");
	return;
}

void auto_checkTrainSet()
{
	int lastTrainsetConfiguration = get_property("lastTrainsetConfiguration").to_int();
	int trainsetPosition = get_property("trainsetPosition").to_int();
	string trainsetConfiguration = get_property("trainsetConfiguration");
	if(!auto_haveTrainSet()) return;
	/* A list of what the station numbers are (thanks Zdrvst for compiling this list for your CS script)
	1: meat
	2: mp regen
	3: all stats
	4: hot res, cold dmg
	5: stench res, spooky dmg
	6: wood, joiners, or stats (orc chasm bridge stuff)
	7: candy
	8: double next stop
	9: cold res, stench dmg
	11: spooky res, sleaze dmg
	12: sleaze res, hot dmg
	13: monster level
	14: mox stats
	15: basic booze
	16: mys stats
	17: mus stats
	18: food drop buff
	19: copy last food drop
	20: ore
	*/
	string[int] stationInts;
	stationInts[1] = "meat_mine";
	stationInts[2] = "tower_fizzy";
	stationInts[3] = "viewing_platform";
	stationInts[4] = "tower_frozen";
	stationInts[5] = "spooky_graveyard";
	stationInts[6] = "logging_mill";
	stationInts[7] = "candy_factory";
	stationInts[8] = "coal_hopper";
	stationInts[9] = "tower_sewage";
	stationInts[11] = "oil_refinery";
	stationInts[12] = "oil_bridge";
	stationInts[13] = "water_bridge";
	stationInts[14] = "groin_silo";
	stationInts[15] = "grain_silo";
	stationInts[16] = "brain_silo";
	stationInts[17] = "brawn_silo";
	stationInts[18] = "prawn_silo";
	stationInts[19] = "trackside_diner";
	stationInts[20] = "ore_hopper";
	int one = 8; //doubler
	int two;
	int three;
	int four;
	if(my_level() < 13) //check if we need more stats. There is no check for disregard instant karma because
	//if we do check, we will never double lumber mill, which is more beneficial than continuing to double mainstat.
	//Do we want the next line's if statement instead because this will still generate so many stats
	//if(my_level() < 12) //Double mainstat until we reach L12
	{
		if(my_primestat() == $stat[Muscle])
		{
			two = 17;
		}
		else if(my_primestat() == $stat[Mysticality])
		{
			two = 16;
		}
		else
		{
			two = 14;
		}
		three = 3; //all stats
		four = 6; //lumber mill
	}
	else if(fastenerCount() < 30 || lumberCount() < 30)//Double lumber mill to clear orc bridge faster
	{
		two = 6; //lumber mill
		if(my_primestat() == $stat[Muscle])
		{
			three = 17;
		}
		else if(my_primestat() == $stat[Mysticality])
		{
			three = 16;
		}
		else
		{
			three = 14;
		}
		four = 3; //all stats
	}
	else //no need for main stats or bridge parts so lets do resistances and offstats
	{
		two = 11; //spooky res, sleaze dmg
		three = 4; //hot res, cold dmg
		if(my_primestat() == $stat[Muscle])
		{
			four = 14; //Moxie for Muscle peeps
		}
		else if(my_primestat() == $stat[Mysticality])
		{
			four = 14; //Moxie for Mysticality peeps
		}
		else
		{
			four = 17; //Muscle for Moxie peeps
		}
	}
	int five = 1; //meat
	int six = 2; //mp regen
	int seven;
	//Initialize trapper to know whether we have enough ore or not
	int L8Step = internalQuestStatus("questL08Trapper");
	if (my_level()>=8 && L8Step==0){
		L8_trapperTalk();
	}
	if (needOre()){
		seven = 20; //ore
	} 
	else
	{
		if(my_primestat() == $stat[Muscle])
		{
			seven = 16; //Mysticality for Muscle peeps
		}
		else if(my_primestat() == $stat[Mysticality])
		{
			seven = 17; //Muscle for Mysticality peeps
		}
		else
		{
			seven = 16; //Mysticality for Moxie peeps
		}
	}
	int eight = 13; //monster level
	if((monster_level_adjustment() > get_property("auto_MLSafetyLimit").to_int() && get_property("auto_MLSafetyLimit") != "") || get_property("auto_MLSafetyLimit").to_int() == -1){
		eight = 9; //cold res, stench dmg
	}
	int turnsSinceTSConfigured = min(trainsetPosition - lastTrainsetConfiguration, 40);
	string expectedConfig = stationInts[one] + "," + stationInts[two] + "," + stationInts[three] + "," + stationInts[four] + "," + stationInts[five] + "," + stationInts[six] + "," + stationInts[seven] + "," + stationInts[eight];

	boolean changedTSConfig;
	if(expectedConfig != trainsetConfiguration)
	{
		changedTSConfig = true;
	}
	else
	{
		changedTSConfig = false;
	}

	//only check for the page if it has been 0 turns or 40 turns since last configured and the configuration has changed
	if ((turnsSinceTSConfigured == 0) || ((turnsSinceTSConfigured == 40) && changedTSConfig))
	{
		string page = visit_url("campground.php?action=workshed"); //once it is available, still double check that we can actually change the config
		if (contains_text(page,'value="Save Train Set Configuration"')){
			auto_modifyTrainSet(one, two, three, four, five, six, seven, eight);
		}
		return;
	}
}
