# This is meant for items that have a date of 2022

boolean auto_haveCosmicBowlingBall()
{
	return get_property("hasCosmicBowlingBall").to_boolean();
}

string auto_bowlingBallCombatString(location place, boolean speculation)
{
	if(!auto_haveCosmicBowlingBall())
	{
		return "";
	}

	if(auto_is_valid($item[Cosmic Bowling Ball]) && place == $location[The Hidden Bowling Alley] && get_property("auto_bowledAtAlley").to_int() != my_ascensions())
	{
		if(!speculation)
		{
			set_property("auto_bowledAtAlley", my_ascensions());
			auto_log_info("Cosmic Bowling Ball used at Hidden Bowling Alley to adavnce quest.");
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

boolean auto_fightLocketMonster(monster mon)
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
			} else if(get_property("_juneCleaverSkips") < 5) {
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
			} else if(get_property("_juneCleaverSkips") < 5) {
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
			} else if(get_property("_juneCleaverSkips") < 5) {
				run_choice(4); // skip
			} else {
				run_choice(3); // effect, 30 turns of +3 hot res, +50% init
			}
			break;			
		case 1474: // Delicious Sprouts
			// if (can_eat() && my_fullness() < fullness_limit() && my_level() < 13) // requires more support
			//	run_choice(2); // guilty sprout is level 8+ good size 1 food but it gives big stats, would want to use a red rocket
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

void sweatpantsPreAdventure() {
	if (!possessEquipment($item[designer sweatpants]) || !can_equip($item[designer sweatpants])) {
		return;
	}

	int sweat = get_property("sweat").to_int();
	int liverCleaned = get_property("_sweatOutSomeBoozeUsed").to_int();

	if (sweat >= 25 && liverCleaned < 3 && my_inebriety() > 0) {
		use_skill($skill[Sweat Out Some Booze]);
	}

	// This is just opportunistic use of sweat. This skill should be used in auto_restore.ash.
	if (sweat >= 95 && my_mp() < my_maxmp()) {
		use_skill($skill[Sip Some Sweat]);
	}
}
