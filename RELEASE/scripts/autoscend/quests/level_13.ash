boolean needStarKey()
{
	if(contains_text(get_property("nsTowerDoorKeysUsed"),"star key"))
	{
		return false;
	}
	if(item_amount($item[Richard\'s Star Key]) > 0 || creatable_amount($item[Richard\'s Star Key]) > 0)
	{
		return false;
	}
	return true;
}

boolean needDigitalKey()
{
	if(isActuallyEd())
	{
		return false;
	}
	if(contains_text(get_property("nsTowerDoorKeysUsed"),"digital key"))
	{
		return false;
	}
	if(item_amount($item[Digital Key]) > 0)
	{
		return false;
	}
	
	return true;
}

boolean need8BitPoints()
{
	if(get_property("8BitScore").to_int() >= 10000)
	{
		return false;
	}
	return needDigitalKey();
}

int towerKeyCount()
{
	return towerKeyCount(true);
}

int towerKeyCount(boolean effective)
{
	//Returns how many Hero Keys and Fat Loot tokens we have.
	//effective count (with malware) vs true count.
	
	if (isActuallyEd())
	{
		return 3;
	}

	int tokens = item_amount($item[Fat Loot Token]);
	if((item_amount($item[Boris\'s Key]) > 0) || contains_text(get_property("nsTowerDoorKeysUsed"), $item[Boris\'s Key]))
	{
		tokens = tokens + 1;
	}
	if((item_amount($item[Jarlsberg\'s Key]) > 0) || contains_text(get_property("nsTowerDoorKeysUsed"), $item[Jarlsberg\'s Key]))
	{
		tokens = tokens + 1;
	}
	if((item_amount($item[Sneaky Pete\'s Key]) > 0) || contains_text(get_property("nsTowerDoorKeysUsed"), $item[Sneaky Pete\'s Key]))
	{
		tokens = tokens + 1;
	}
	if(effective && (item_amount($item[Daily Dungeon Malware]) > 0) && !get_property("_dailyDungeonMalwareUsed").to_boolean() && !get_property("dailyDungeonDone").to_boolean() && (get_property("_lastDailyDungeonRoom").to_int() < 14) && (!in_pokefam()))
	{
		tokens = tokens + 1;
	}
	return tokens;
}

int EightBitScore()
{
	int score = get_property("8BitScore").to_int();
	return score;
}

boolean EightBitRealmHandler()
{
	//Spend adventures to get the digital key
	//Preparing for each zone is handled in auto_pre_adv.ash
	boolean adv_spent = false;

	string color = get_property("8BitColor");
	if((internalQuestStatus("questL02Larva") < 0 && internalQuestStatus("questG02Whitecastle") < 0) && available_amount($item[Continuum Transfunctioner]) == 0)
	{
		// need distant woods and continuum transfunctioner
		return false;
	}
	switch(color)
	{
		case "black":
			// limited buff that is helpful for 3 of 4 8-bit zones
			buffMaintain($effect[shadow waters]);
			adv_spent = autoAdv($location[Vanya\'s Castle]);
			break;
		case "red":
			// limited buff that is helpful for 3 of 4 8-bit zones
			buffMaintain($effect[shadow waters]);
			adv_spent = autoAdv($location[The Fungus Plains]);
			break;
		case "blue":
			adv_spent = autoAdv($location[Megalo-City]);
			break;
		case "green":
			// limited buff that is helpful for 3 of 4 8-bit zones
			buffMaintain($effect[shadow waters]);
			adv_spent = autoAdv($location[Hero\'s Field]);
			break;
		default:
			abort("Property 8BitColor not set to a valid value");
			break;
	}
	auto_log_info("Current 8bit score: " + EightBitScore() + "/10000");

	return adv_spent;
}

boolean get8BitFatLootToken()
{
	//Acquire the [Fat Loot Token] from 8 bit realm
	
	// start quest and equip to refresh mafia's prefs
	woods_questStart();
	autoForceEquip($slot[acc3], $item[Continuum Transfunctioner]);

	// buy fat loot token if you can
	if(EightBitScore() >= 20000)
	{
		equip($slot[Acc3], $item[continuum transfunctioner]);
		visit_url("place.php?whichplace=8bit&action=8treasure");
		if(available_choice_options() contains 2)
		{
			run_choice(2);
			return true;
		}
		else
		{
			auto_log_warning("Thought we could buy fat loot token in 8-Bit Realm but was unable.");
			auto_log_warning("Current score = " + EightBitScore());
			return false;
		}
	}
	
	return EightBitRealmHandler();
}

boolean LX_getDigitalKey()
{
	//Acquire the [Digital Key]
	
	if(!needDigitalKey())
	{
		return false;
	}
	if(item_amount($item[Digital Key]) > 0)
	{
		if(have_effect($effect[Consumed By Fear]) > 0)
		{
			uneffect($effect[Consumed By Fear]);
			council();
		}
		return false;
	}
	if(in_koe())
	{
		if(item_amount($item[Digital Key]) == 0 && internalQuestStatus("questL13Final") == 5)
		{
			return buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Digital Key]);
		}
		else
		{
			return false;
		}
	}
	
	// start quest and equip to refresh mafia's prefs
	woods_questStart();
	autoForceEquip($slot[acc3], $item[Continuum Transfunctioner]);

	// buy key if you can
	if(EightBitScore() >= 10000)
	{
		equip($slot[Acc3], $item[continuum transfunctioner]);
		visit_url("place.php?whichplace=8bit&action=8treasure");
		run_choice(1);
		if(!needDigitalKey())
		{
			return true;
		}
	}
	
	return EightBitRealmHandler();
}

void LX_buyStarKeyParts()
{
	if(item_amount($item[Richard\'s Star Key]) > 0 || get_property("nsTowerDoorKeysUsed").contains_text("Richard's star key"))
	{
		return;	//already have it
	}
	if(!can_interact())
	{
		return;	//no unrestricted mall access
	}
	auto_buyUpTo(1, $item[Star Chart]);
	auto_buyUpTo(8, $item[Star]);
	auto_buyUpTo(7, $item[line]);
}

boolean LX_getStarKey()
{
	if(!get_property("auto_getStarKey").to_boolean())
	{
		return false;
	}

	//needStarKey() checks if you own or have used the star key
	if(!needStarKey())
	{
		set_property("auto_getStarKey", false);
		return false;
	}
	
	boolean hole_in_sky_unreachable = internalQuestStatus("questL10Garbage") < 9;
	boolean shen_might_request_hole = shenShouldDelayZone($location[The Hole in the Sky]);
	if (hole_in_sky_unreachable || shen_might_request_hole)
	{
		return false;
	}
	
	//kingdom of exploathing does not need rocketship to reach hole in the sky
	if(item_amount($item[Steam-Powered Model Rocketship]) == 0 && !in_koe())
	{
		return false;
	}
	
	LX_buyStarKeyParts();

	// summon Skinflute or Camel's Toe to get both stars and lines. We can copy them into delay zones like the 8-bit realm.
	int copiesNeeded = max((8 - item_amount($item[star])) / 2, (7 - item_amount($item[line])) / 2);
	if (needStarKey() && item_amount($item[star]) < 8 && item_amount($item[line]) < 7 && auto_haveBackupCamera() && auto_backupUsesLeft() >= copiesNeeded)
	{
		// in case it matters later, summon only the monster we can naturally encounter in this ascension.
		if(my_ascensions() % 2 == 1 && !summonedMonsterToday($monster[Skinflute]) && canSummonMonster($monster[Skinflute]) && summonMonster($monster[Skinflute])) return true;
		if(my_ascensions() % 2 == 0 && !summonedMonsterToday($monster[Camel's Toe]) && canSummonMonster($monster[Camel's Toe]) && summonMonster($monster[Camel's Toe])) return true;
	}

	boolean at_tower_door = internalQuestStatus("questL13Final") == 5;
	if (!in_hardcore() && at_tower_door && needStarKey() && item_amount($item[Star Chart]) == 0 && item_amount($item[Star]) >= 8 && item_amount($item[Line]) >= 7)
	{
		pullXWhenHaveY($item[Star Chart], 1, 0);
	}
	
	if (item_amount($item[Richard\'s Star Key]) == 0 && creatable_amount($item[Richard\'s Star Key]) > 0 && !get_property("nsTowerDoorKeysUsed").contains_text("Richard's star key"))
	{
		return create(1, $item[Richard\'s Star Key]);
	}
	
	//if only star chart is missing and you will pull it at tower door, then you are done for now.
	if((item_amount($item[Star]) >= 8) && (item_amount($item[Line]) >= 7) && !in_hardcore() && !at_tower_door)
	{
		return false;
	}
	
	if(!zone_isAvailable($location[The Hole In The Sky]))
	{
		auto_log_warning("The Hole In The Sky is not available, we have to do something else...", "red");
		return false;
	}

	if(auto_have_familiar($familiar[Space Jellyfish]))
	{
		handleFamiliar($familiar[Space Jellyfish]);
		if(item_amount($item[Star Chart]) == 0)
		{
			set_property("choiceAdventure1221", 1);
		}
		else
		{
			set_property("choiceAdventure1221", 2 + (my_ascensions() % 2));
		}
	}
	if(auto_haveGreyGoose()){
		auto_log_info("Bringing the Grey Goose to emit some drones at some Constellations.");
		handleFamiliar($familiar[Grey Goose]);
	}
	return autoAdv(1, $location[The Hole In The Sky]);
}

boolean beehiveConsider(boolean at_tower)
{
	int damage_sources = 1; // basic hit
	
	// Familiars
	if (have_familiar($familiar[shorter-order cook]) && auto_is_valid($familiar[shorter-order cook]))
	{
		damage_sources += 6;
	}
	else if (have_familiar($familiar[mu]) && auto_is_valid($familiar[mu]))
	{
		damage_sources += 5;
	}
	else if (have_familiar($familiar[imitation crab]) && auto_is_valid($familiar[imitation crab]))
	{
		damage_sources += 4;
	}
	
	// Combat skill to use
	if (have_skill($skill[kneebutt]) || have_skill($skill[headbutt]))
	{
		damage_sources += 1;
	}
	
	// Retatiatory skills
	foreach sk in $skills[the psalm of pointiness, spiky shell, scarysauce, Jalape&ntilde;o Saucesphere]
	{
		if (have_skill(sk))
		{
			damage_sources += 1;
		}
	}
	
	// Damage skills
	foreach sk in $skills[dirge of dreadfulness, icy glare]
	{
		if (have_skill(sk))
		{
			damage_sources += 1;
		}
	}
	// Sleaze and stench will be taken care of war gear.
	damage_sources += 2;
	
	// Now check stuff we get in run.
	// Hot and another retaliation will be taken care of by hot plate (guaranteed from friars)
	if (!at_tower || (available_amount($item[hot plate])>0))
	{
		damage_sources += 2;
	}
	else // or maybe we just have hot damage already
	{
		if (numeric_modifier($modifier[hot damage])>0)
		{
			damage_sources += 1;
		}
	}
	
	// Tiny bowler gives familiar damage
	if (available_amount($item[tiny bowler])>0)
	{
		damage_sources += 1;
	}
	
	// We can't assume we get this, so don't count it speculatively.
	if (available_amount($item[hippy protest button])>0)
	{
		damage_sources += 1;
	}
	
	#~ auto_log_info("Investigating chance of towerkilling wall of skin, need 13 damage, expecting to have "+to_string(damage_sources), "blue");
	
	if (damage_sources >= 13)
	{
		set_property("auto_getBeehive", false);
		return true;
	}
	set_property("auto_getBeehive", true);
	return false;
}

int ns_crowd1()
{
	if(get_property("nsContestants1").to_int() != 0)
	{
		auto_log_info("Default Test: Initiative", "red");
	}
	return 1;
}

stat ns_crowd2()
{
	if(get_property("nsContestants2").to_int() != 0)
	{
		auto_log_info("Off-Stat Test: " + get_property("nsChallenge1"), "red");
	}
	return to_stat(get_property("nsChallenge1"));
}

element ns_crowd3()
{
	if(get_property("nsContestants3").to_int() != 0)
	{
		auto_log_info("Elemental Test: " + get_property("nsChallenge2"), "red");
	}
	return to_element(get_property("nsChallenge2"));
}

element ns_hedge1()
{
	auto_log_info("Hedge Maze 1: " + get_property("nsChallenge3"), "red");
	return to_element(get_property("nsChallenge3"));
}

element ns_hedge2()
{
	auto_log_info("Hedge Maze 2: " + get_property("nsChallenge4"), "red");
	return to_element(get_property("nsChallenge4"));
}

element ns_hedge3()
{
	auto_log_info("Hedge Maze 3: " + get_property("nsChallenge5"), "red");
	return to_element(get_property("nsChallenge5"));
}

boolean L13_towerNSContests()
{
	if (internalQuestStatus("questL13Final") < 0 || internalQuestStatus("questL13Final") > 3)
	{
		return false;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_02_coronation"))
	{
		set_property("choiceAdventure1020", "1");
		set_property("choiceAdventure1021", "1");
		set_property("choiceAdventure1022", "1");
		visit_url("place.php?whichplace=nstower&action=ns_02_coronation");
		visit_url("choice.php?pwd=&whichchoice=1020&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1021&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1022&option=1", true);
		return true;
	}
	
	//if you do not have a telescope you need to actually visit the contest booth once to find out what element and offstat is needed
	if(get_property("nsChallenge1") == "none" || get_property("nsChallenge2") == "none")
	{
		visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
	}

	boolean crowd1Insufficient()
	{
		return numeric_modifier("Initiative") < 400.0;
	}

	stat crowd_stat = ns_crowd2();

	boolean crowd2Insufficient()
	{
		return my_buffedstat(crowd_stat) < 600;
	}

	element challenge = ns_crowd3();
	boolean crowd3Insufficient()
	{
		return numeric_modifier(challenge + " Damage") + numeric_modifier(challenge + " Spell Damage") < 100;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_contestbooth"))
	{
		if(in_wereprof() && get_property("wereProfessorTransformTurns").to_int() < 48)
		{
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=5", true); //want as many turns of werewolf as possible at the contest booth so refresh with this choice
			visit_url("main.php");
		}
		if(get_property("nsContestants1").to_int() == -1)
		{
			resetMaximize();
			if(!get_property("_grimBuff").to_boolean() && auto_have_familiar($familiar[Grim Brother]))
			{
				cli_execute("grim init");
			}
			if((get_property("telescopeUpgrades").to_int() > 0) && (!get_property("telescopeLookedHigh").to_boolean()) && auto_is_valid($effect[Starry-Eyed]))
			{
				cli_execute("telescope high");
			}
			switch(ns_crowd1())
			{
			case 1:
				acquireMP(160); // only uses free rests or items on hand by default


				autoMaximize("initiative -equip snow suit", 1500, 0, false);

				provideInitiative(400, $location[Noob Cave], true);

				if(crowd1Insufficient() && (get_property("sidequestArenaCompleted") == "fratboy"))
				{
					cli_execute("concert White-boy Angst");
				}

			if(crowd1Insufficient())
			{
				if (have_effect($effect[New and Improved])==0)
				{
					auto_wishForEffect($effect[New and Improved]);
				}
			}

				if(crowd1Insufficient())
				{
					if(get_property("auto_secondPlaceOrBust").to_boolean())
						abort("Not enough initiative for the initiative test, aborting since auto_secondPlaceOrBust=true");
					else
						auto_log_warning("Not enough initiative for the initiative test, but continuing since auto_secondPlaceOrBust=false", "red");
				}
				break;
			}

			// Adjust us to the initiative familiar selected in provideInitiative().
			preAdvUpdateFamiliar($location[None]);

			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=1", true);
			visit_url("main.php");
		}
		if(get_property("nsContestants2").to_int() == -1)
		{
			resetMaximize();
			if(!get_property("_lyleFavored").to_boolean() && auto_is_valid($effect[Favored by Lyle]))
			{
				string temp = visit_url("place.php?whichplace=monorail&action=monorail_lyle");
			}
			acquireMP(150); // only uses free rests or items on hand by default
			if (in_darkGyffte())
			{
				if(crowd_stat == $stat[muscle] && !have_skill($skill[Preternatural Strength]))
				{
					boolean[skill] requirements;
					requirements[$skill[Preternatural Strength]] = true;
					auto_log_info("Torporing, since we want to get Preternatural Strength.", "blue");
					bat_reallyPickSkills(20, requirements);
				}
				// This could be generalized for stat equalizer potions, but that seems marginal
				if (crowd_stat == $stat[muscle] && have_skill($skill[Preternatural Strength]))
					crowd_stat = $stat[mysticality];
				if (crowd_stat == $stat[moxie] && have_skill($skill[Sinister Charm]))
					crowd_stat = $stat[mysticality];
			}
			int [stat] statGoal;
			statGoal[crowd_stat] = 600;
			provideStats(statGoal, $location[Noob Cave], true);
			switch(crowd_stat)
			{
			case $stat[moxie]:
				autoMaximize("moxie -equip snow suit", 1500, 0, false);

				if(have_effect($effect[Ten out of Ten]) == 0 && auto_is_valid($effect[Ten out of Ten]))
				{
					if(crowd2Insufficient()) fightClubSpa($effect[Ten out of Ten]);
				}

				if(in_small() && crowd2Insufficient() && have_effect($effect[Piratastic])==0)
				{
					auto_wishForEffect($effect[Piratastic]);
				}
				break;
			case $stat[muscle]:
				autoMaximize("muscle -equip snow suit", 1500, 0, false);

				if(have_effect($effect[Muddled]) == 0 && auto_is_valid($effect[Muddled]))
				{
					if(crowd2Insufficient()) fightClubSpa($effect[Muddled]);
				}

				if(in_small() && crowd2Insufficient() && have_effect($effect[\'Roids of the Rhinoceros])==0)
				{
					auto_wishForEffect($effect[\'Roids of the Rhinoceros]);
				}
				break;
			case $stat[mysticality]:
				autoMaximize("myst -equip snow suit", 1500, 0, false);

				if(have_effect($effect[Uncucumbered]) == 0 && auto_is_valid($effect[Uncucumbered]))
				{
					if(crowd2Insufficient()) fightClubSpa($effect[Uncucumbered]);
				}

				if(in_small() && crowd2Insufficient() && have_effect($effect[Happy Trails])==0)
				{
					auto_wishForEffect($effect[Happy Trails]);
				}
				break;
			}
			
			if(crowd2Insufficient() && !in_small())
			{
				if (have_effect($effect[New and Improved])==0 && !in_small())
				{
					auto_wishForEffect($effect[New and Improved]);
				}
			}

			if(crowd2Insufficient())
			{
				if(get_property("auto_secondPlaceOrBust").to_boolean())
					abort("Not enough " + crowd_stat + " for the stat test, aborting since auto_secondPlaceOrBust=true");
				else
					auto_log_warning("Not enough " + crowd_stat + " for the stat test, but continuing since auto_secondPlaceOrBust=false", "red");
			}
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=2", true);
			visit_url("main.php");
		}
		if(get_property("nsContestants3").to_int() == -1)
		{
			resetMaximize();
			acquireMP(125); // only uses free rests or items on hand by default

			if(challenge != $element[none])
			{
				autoMaximize(challenge + " dmg, " + challenge + " spell dmg -equip snow suit", 1500, 0, false);
			}

			if(crowd3Insufficient()) buffMaintain($effect[All Glory To the Toad]);
			if(crowd3Insufficient()) buffMaintain($effect[Bendin\' Hell], 120, 1, 1);
			switch(challenge)
			{
			case $element[cold]:
				if(crowd3Insufficient()) auto_beachCombHead("cold");
				if(crowd3Insufficient()) buffMaintain($effect[Cold Hard Skin]);
				if(crowd3Insufficient()) buffMaintain($effect[Frostbeard], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Icy Glare], 10, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Song of the North], 100, 1, 1);
				break;
			case $element[hot]:
				if(crowd3Insufficient()) auto_beachCombHead("hot");
				if(crowd3Insufficient()) buffMaintain($effect[Song of Sauce], 100, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Flamibili Tea]);
				if(crowd3Insufficient()) buffMaintain($effect[Flaming Weapon]);
				if(crowd3Insufficient()) buffMaintain($effect[Human-Demon Hybrid]);
				if(crowd3Insufficient()) buffMaintain($effect[Lit Up]);
				if(crowd3Insufficient()) buffMaintain($effect[Fire Inside]);
				if(crowd3Insufficient()) buffMaintain($effect[Pyromania], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Your Fifteen Minutes], 50, 1, 1);
				break;
			case $element[sleaze]:
				if(crowd3Insufficient()) auto_beachCombHead("sleaze");
				if(crowd3Insufficient()) buffMaintain($effect[Takin\' It Greasy], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Blood-Gorged]);
				if(crowd3Insufficient()) buffMaintain($effect[Greasy Peasy]);
				break;
			case $element[stench]:
				if(crowd3Insufficient()) auto_beachCombHead("stench");
				if(crowd3Insufficient()) buffMaintain($effect[Drenched With Filth]);
				if(crowd3Insufficient()) buffMaintain($effect[Musky]);
				if(crowd3Insufficient()) buffMaintain($effect[Stinky Hands]);
				if(crowd3Insufficient()) buffMaintain($effect[Stinky Weapon]);
				if(crowd3Insufficient()) buffMaintain($effect[Rotten Memories], 15, 1, 1);
				if(canPull($item[Halibut]) && auto_can_equip($item[Halibut]))
				{
					pullXWhenHaveY($item[Halibut], 1, 0);
					autoMaximize(challenge + " dmg, " + challenge + " spell dmg -equip snow suit", 1500, 0, false);
				}
				break;
			case $element[spooky]:
				if(crowd3Insufficient()) auto_beachCombHead("spooky");
				if(crowd3Insufficient()) buffMaintain($effect[Spooky Hands]);
				if(crowd3Insufficient()) buffMaintain($effect[Spooky Weapon]);
				// at this point, an example list of songs is phat loot / polka / celerity / madrigal
				if(crowd3Insufficient()) {
					// specify normal effect to avoid failing the skill check
					shrugAT($effect[Dirge of Dreadfulness]);
					buffMaintain($effect[Dirge of Dreadfulness (Remastered)]);
				}
				if(crowd3Insufficient()) {
					shrugAT($effect[Dirge of Dreadfulness]);
					buffMaintain($effect[Dirge of Dreadfulness], 10, 1, 1);
				}
				if(crowd3Insufficient()) buffMaintain($effect[Intimidating Mien], 15, 1, 1);
				if(crowd3Insufficient()) buffMaintain($effect[Snarl of Three Timberwolves]);
				if(crowd3Insufficient()) buffMaintain($effect[Snarl of the Timberwolf], 10, 1, 1);
				break;
			}

			float score = numeric_modifier(challenge + " damage");
			score += numeric_modifier(challenge + " spell damage");
			if((score > 20.0) && (score < 85.0))
			{
				buffMaintain($effect[Bendin\' Hell], 100, 1, 1);
			}

			score = numeric_modifier(challenge + " damage");
			score += numeric_modifier(challenge + " spell damage");
			if((score < 80))
			{
				switch(challenge)
				{
				case $element[cold]:
					auto_wishForEffect($effect[Staying Frosty]);
					break;
				case $element[hot]:
					auto_wishForEffect($effect[Dragged Through the Coals]);
					break;
				case $element[sleaze]:
					auto_wishForEffect($effect[Fifty Ways to Bereave your Lover]);
					break;
				case $element[stench]:
					auto_wishForEffect($effect[Sewer-Drenched]);
					break;
				case $element[spooky]:
					auto_wishForEffect($effect[You\'re Back...]);
					break;
				}
			}

			if(crowd3Insufficient())
			{
				if(get_property("auto_secondPlaceOrBust").to_boolean())
					abort("Not enough " + challenge + " for the elemental test, aborting since auto_secondPlaceOrBust=true");
				else
					auto_log_warning("Not enough " + challenge + " for the elemental test, but continuing since auto_secondPlaceOrBust=false", "red");
			}

			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=3", true);
			visit_url("main.php");
		}

		set_property("choiceAdventure1003",  4);
		if((get_property("nsContestants1").to_int() == 0) && (get_property("nsContestants2").to_int() == 0) && (get_property("nsContestants3").to_int() == 0))
		{
			auto_log_info("The NS Challenges are over! Victory is ours!", "blue");
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			visit_url("choice.php?pwd=&whichchoice=1003&option=4", true);
			visit_url("main.php");
			if((get_property("nsContestants1").to_int() != 0) || (get_property("nsContestants2").to_int() != 0) || (get_property("nsContestants3").to_int() != 0))
			{
				if(internalQuestStatus("questL13Final") == 2)
				{
					if(in_theSource())
					{
						//As of r17048, encountering a Source Agent on the Challenge line results in nsContestants being decremented twice.
						//Since we were using Mafia\'s tracking here, we have to compensate for when it fails...
						auto_log_warning("Probably encountered a Source Agent during the NS Contestants and Mafia's tracking fails on this. Let's try to correct it...", "red");
						set_property("questL13Final", "step1");
					}
					else
					{
						auto_log_error("Error not recoverable (as not antipicipated) outside of The Source (Source Agents during NS Challenges), aborting.");
						abort("questL13Final error in unexpected path.");
					}
				}
				else
				{
					auto_log_error("Unresolvable error: Mafia thinks the NS challenges are complete but something is very wrong.");
					abort("Unknown questL13Final state.");
				}
			}
			return true;
		}
	}

	equipBaseline();

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_crowd1"))
	{
		autoAdv(1, $location[Fastest Adventurer Contest]);
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_crowd2"))
	{
		location toCompete = $location[none];
		switch(get_property("nsChallenge1"))
		{
		case "Mysticality":	toCompete = $location[Smartest Adventurer Contest];		break;
		case "Moxie":		toCompete = $location[Smoothest Adventurer Contest];	break;
		case "Muscle":		toCompete = $location[Strongest Adventurer Contest];	break;
		}
		if(toCompete == $location[none])
		{
			abort("nsChallenge1 is invalid. This is a severe error.");
		}
		autoAdv(1, toCompete);
		return true;
	}

	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_01_crowd3"))
	{
		location toCompete = $location[none];
		switch(get_property("nsChallenge2"))
		{
		case "cold":		toCompete = $location[Coldest Adventurer Contest];		break;
		case "hot":			toCompete = $location[Hottest Adventurer Contest];		break;
		case "sleaze":		toCompete = $location[Sleaziest Adventurer Contest];	break;
		case "spooky":		toCompete = $location[Spookiest Adventurer Contest];	break;
		case "stench":		toCompete = $location[Stinkiest Adventurer Contest];	break;
		}
		if(toCompete == $location[none])
		{
			abort("nsChallenge1 is invalid. This is a severe error.");
		}
		autoAdv(1, toCompete);
		return true;
	}
	auto_log_info("No challenges left!", "green");
	if(in_pokefam())
	{
		if(get_property("nsContestants1").to_int() == 0)
		{
			return false;
		}
		set_property("nsContestants1", 0);
		set_property("nsContestants2", 0);
		set_property("nsContestants3", 0);
		return true;
	}
	return false;
}

void maximize_hedge()
{
	string data = visit_url("campground.php?action=telescopelow");

	element first = ns_hedge1();
	element second = ns_hedge2();
	element third = ns_hedge3();
	int [element] resGoal;
	if((first == $element[none]) || (second == $element[none]) || (third == $element[none]))
	{
		foreach ele in $elements[hot, cold, stench, sleaze, spooky]
		{
			resGoal[ele] = 9;
		}
	}
	else
	{
		resGoal[first] = 9;
		resGoal[second] = 9;
		resGoal[third] = 9;
	}

	provideResistances(resGoal, $location[Noob Cave], true);
}

boolean L13_towerNSHedge()
{
	if(internalQuestStatus("questL13Final") == 5 && contains_text(visit_url("place.php?whichplace=nstower"), "hedgemaze"))
	{
		//If we got beaten up by the last hedgemaze, mafia might set questL13Final to step5 anyway. Fix that.
		set_property("questL13Final", "step4");
		if(have_effect($effect[Beaten Up]) > 0 || my_hp() < 150)
		{
			auto_log_error("Hedge maze not solved, the mysteries are still there (correcting step5 -> step4)");
			abort("Heal yourself and try again...");
		}
	}
	if(internalQuestStatus("questL13Final") != 4)
	{
		return false;
	}

	# Set this so it aborts if not enough adventures. Otherwise, well, we end up in a loop.
	set_property("choiceAdventure1004", "3");
	set_property("choiceAdventure1005", "2");			# 'Allo
	set_property("choiceAdventure1006", "2");			# One Small Step For Adventurer
	set_property("choiceAdventure1007", "2");			# Twisty Little Passages, All Hedge
	set_property("choiceAdventure1008", "2");			# Pooling Your Resources
	set_property("choiceAdventure1009", "2");			# Gold Ol' 44% Duck
	set_property("choiceAdventure1010", "2");			# Another Day, Another Fork
	set_property("choiceAdventure1011", "2");			# Of Mouseholes and Manholes
	set_property("choiceAdventure1012", "2");			# The Last Temptation
	set_property("choiceAdventure1013", "1");			# Masel Tov!

	maximize_hedge();
	cli_execute("auto_pre_adv");
	if(!acquireHP())
	{
		// couldn't heal so do slow route. May die to fast route
		set_property("auto_hedge", "slow");
	}
	visit_url("place.php?whichplace=nstower&action=ns_03_hedgemaze");
	if(get_property("lastEncounter") == "This Maze is... Mazelike...")
	{
		run_choice(2);
		abort("May not have enough adventures for the hedge maze. Failing");
	}

	if(get_property("auto_hedge") == "slow")
	{
		visit_url("choice.php?pwd=&whichchoice=1005&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1006&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1007&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1008&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1009&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1010&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1011&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1012&option=1", true);
		visit_url("choice.php?pwd=&whichchoice=1013&option=1", true);
	}
	else if(get_property("auto_hedge") == "fast")
	{
		visit_url("choice.php?pwd=&whichchoice=1005&option=2", true);
		visit_url("choice.php?pwd=&whichchoice=1008&option=2", true);
		visit_url("choice.php?pwd=&whichchoice=1011&option=2", true);
		visit_url("choice.php?pwd=&whichchoice=1013&option=1", true);
	}
	else
	{
		abort("auto_hedge not set properly (slow/fast), assuming manual handling desired");
	}
	if(have_effect($effect[Beaten Up]) > 0)
	{
		abort("Failed the hedge maze, may want to do this manually...");
	}
	return true;
}

boolean L13_sorceressDoor()
{
	if(internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	if (LX_getStarKey() || LX_getDigitalKey()) { // should attempt Star Key first as 8-bit zones can be progressed with backups etc.
		return true;
	}

	// Low Key Summer has an entirely different door.
	if(in_lowkeysummer())
	{
		return L13_sorceressDoorLowKey();
	}

	string page = visit_url("place.php?whichplace=nstower_door");
	if(contains_text(page, "ns_lock6"))
	{
		if(item_amount($item[Skeleton Key]) == 0)
		{
			cli_execute("make skeleton key");
		}
		if(item_amount($item[Skeleton Key]) == 0)
		{
			abort("Need Skeleton Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock6");
	}

	if(towerKeyCount() < 3)
	{
		abort("Do not have enough hero keys");
	}

	if(contains_text(page, "ns_lock1"))
	{
		if(item_amount($item[Boris\'s Key]) == 0)
		{
			if(in_koe() && item_amount($item[fat loot token]) > 0)
			{
				buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Boris\'s Key]);
			}
			else {
				cli_execute("make Boris's Key");
			}
		}
		if(item_amount($item[Boris\'s Key]) == 0)
		{
			abort("Need Boris's Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock1");
	}
	if(contains_text(page, "ns_lock2"))
	{
		if(item_amount($item[Jarlsberg\'s Key]) == 0)
		{
			if(in_koe() && item_amount($item[fat loot token]) > 0)
			{
				buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Jarlsberg\'s Key]);
			}
			else
			{
				cli_execute("make Jarlsberg's Key");
			}
		}
		if(item_amount($item[Jarlsberg\'s Key]) == 0)
		{
			abort("Need Jarlsberg's Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock2");
	}
	if(contains_text(page, "ns_lock3"))
	{
		if(item_amount($item[Sneaky Pete\'s Key]) == 0)
		{
			if(in_koe() && item_amount($item[fat loot token]) > 0)
			{
				buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Sneaky Pete\'s Key]);
			}
			else
			{
				cli_execute("make Sneaky Pete's Key");
			}
		}
		if(item_amount($item[Sneaky Pete\'s Key]) == 0)
		{
			abort("Need Sneaky Pete's Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock3");
	}

	if(contains_text(page, "ns_lock4"))
	{
		if(item_amount($item[Richard\'s Star Key]) == 0)
		{
			boolean temp = cli_execute("make richard's star key");
		}
		if(item_amount($item[Richard\'s Star Key]) == 0)
		{
			if(!get_property("auto_getStarKey").to_boolean())
			{
				abort("Need Richard's Star Key for the Sorceress door. Perhaps set auto_getStarKey=true ?");
			}
			else
			{
				abort("Need Richard's Star Key for the Sorceress door, but auto_getStarKey=true so I'm not sure why we haven't gotten it already. :(");
			}
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock4");
	}

	if(contains_text(page, "ns_lock5"))
	{
		if(item_amount($item[Digital Key]) == 0)
		{
			abort("Need Digital Key for the Sorceress door :(");
		}
		visit_url("place.php?whichplace=nstower_door&action=ns_lock5");
	}

	visit_url("place.php?whichplace=nstower_door&action=ns_doorknob");
	return true;
}

boolean L13_towerNSTower()
{
	if(internalQuestStatus("questL13Final") < 6 || internalQuestStatus("questL13Final") > 11)
	{
		return false;
	}

	auto_log_info("Scaling the mighty NStower...", "green");

	if (L13_towerNSTowerSkin())
	{
		return true;
	}
	if(L13_towerNSTowerMeat())
	{
		return true;
	}
	if(L13_towerNSTowerBones())
	{
		return true;
	}
	if(L13_towerNSTowerMirror())
	{
		return true;
	}
	if(L13_towerNSTowerShadow())
	{
		return true;
	}
	
	return false;
}

boolean L13_towerNSTowerSkin()
{
	if(!contains_text(visit_url("place.php?whichplace=nstower"), "ns_05_monster1"))
	{
		return false;
	}
	auto_log_info("Time to fight the Wall of Skins!", "blue");
	if (get_property("auto_towerBreak").to_lower_case() == "wall of skin" || get_property("auto_towerBreak").to_lower_case() == "wallofskin" || get_property("auto_towerBreak").to_lower_case() == "skin" || get_property("auto_towerBreak").to_lower_case() == "level 1")
	{
		abort("auto_towerBreak set to abort here.");
	}
	if (item_amount($item[Beehive]) > 0)
	{
		return autoAdvBypass("place.php?whichplace=nstower&action=ns_05_monster1", $location[Tower Level 1]);
	}
	// Can we kill the tower without a beehive?
	beehiveConsider(true);
	if(get_property("auto_getBeehive").to_boolean())
	{
		return false;
	}
	
	int damage = 2; // base attack damage plus TT attack skill (kneebutt, headbutt)
	
	boolean fam_set = false;
	foreach fam in $familiars[shorter-order cook, mu, imitation crab] // crab is evergreen, buy one
	{
		if (have_familiar(fam) && auto_is_valid(fam))
		{
			handleFamiliar(fam);
			use_familiar(fam);
			damage += (fam == $familiar[imitation crab] ? 4 : 5);
			fam_set = true;
			break;
		}
	}
	if (!fam_set) // just use some trash that does damage that we will have
	{
		foreach fam in $familiars[angry goat, MagiMechTech MicroMechaMech, star starfish, mosquito]
		{
			if (have_familiar(fam) && auto_is_valid(fam))
			{
				handleFamiliar(fam);
				use_familiar(fam);
				break;
			}
		}
	}
		
	// We've probably got a tiny bowler, that'll help.
	if (available_amount($item[tiny bowler]) > 0 && can_equip($item[tiny bowler]))
	{
		autoEquip($item[tiny bowler]);
		damage += 1; //familiar attack
	}
	
	// apply skills
	// start by shrugging unnecessary AT skills
	// These ones should be safe to just remove simply
	uneffect($effect[Aloysius' Antiphon of Aptitude]);
	uneffect($effect[Ode to Booze]);
	uneffect($effect[The Sonata of Sneakiness]);
	uneffect($effect[Carlweather\'s Cantata of Confrontation]);
	uneffect($effect[Cletus\'s Canticle of Celerity]);
	
	// TODO: These need to be handled so they're not recast
	uneffect($effect[Ur-Kel\'s Aria of Annoyance]);
	uneffect($effect[Polka of Plenty]);
	
	// We want retaliation for light hits, so remove blood bubble if possible
	uneffect($effect[blood bubble]);
	
	// damage skills
	foreach sk in $skills[dirge of dreadfulness, icy glare]
	{
		if (have_skill(sk))
		{
			use_skill(sk);
			damage += 1;
		}
	}
	
	// Stinging skills
	foreach sk in $skills[the psalm of pointiness, spiky shell, scarysauce, Jalape&ntilde;o Saucesphere]
	{
		if (have_skill(sk))
		{
			use_skill(sk);
			damage += 1;
		}
	}
	
	// Skills took care of cold and spooky damage, hot plate can take care of hot (and sting), guaranteed from level 6
	if (available_amount($item[hot plate]) > 0 && can_equip($item[hot plate]))
	{
		autoForceEquip($item[hot plate]);
		damage += 2; // hot damage, sting point
	}
	
	// sleaze/stench damage from war outfit and acccessory drops
	boolean acc1_occupied = false;
	boolean acc2_occupied = false;
	// War outfit will occupy acc3
	equipWarOutfit();
	
	// Frats need stench
	boolean[item] damage_accs = $items[longhaired hippy wig, lockenstock&trade; sandals, gaia beads];
	if(auto_warSide() == "hippy") // hippies need sleaze
	{
		damage_accs = $items[kick-ass kicks,  Jefferson wings, ghost of a necklace];
	}
	foreach it in damage_accs
	{
		if (available_amount(it) > 0 && can_equip(it))
		{
			if(!acc1_occupied)
			{
				autoEquip($slot[acc1], it);
				acc1_occupied = true;
				damage += 1;
				break;
			}
			else if(!acc2_occupied)
			{
				autoEquip($slot[acc2], it);
				acc2_occupied = true;
				damage += 1;
				break;
			}
		} // available/can_equip
	} // elemental damage accessory loop
	
	// Extra stinging accessories
	foreach it in $items[Hippy protest button,  Bottle opener belt buckle]
	{
		if (available_amount(it) > 0 && can_equip(it))
		{
			if(!acc1_occupied)
			{
				autoEquip($slot[acc1], it);
				acc1_occupied = true;
				break;
			}
			else if(!acc2_occupied)
			{
				autoEquip($slot[acc2], it);
				acc2_occupied = true;
				damage += 1;
			}
		} // available/can_equip
	} // stinging accessories loop
	
	if (damage < 13)
	{
		auto_log_info("I'm trying to towerkill the Wall of Skin, but I don't think I've got enough damage sources. I have "+to_int(damage), "red");
		set_property("auto_getBeehive", true);
		auto_log_info("Exiting. Either investigate, or just re-run and we'll get the Beehive.", "red");
		abort("Failed at Wall of Skin");
	}
	auto_log_info("I think I have " + damage + " points of damage per turn, time to towerkill the Wall of Skin", "blue");
	
	// Should we be casting shell up here? I do not understand it. If we got this far we should win regardless.
	
	acquireHP();
	autoAdvBypass("place.php?whichplace=nstower&action=ns_05_monster1", $location[Tower Level 1]);
	if(internalQuestStatus("questL13Final") < 7)
	{
		set_property("auto_getBeehive", true);
		auto_log_warning("I probably failed the Wall of Skin, I assume that I tried without a beehive. Well, I'm going back to get it.", "red");
	}
	return true;
}

boolean L13_towerNSTowerMeat()
{
	if(!contains_text(visit_url("place.php?whichplace=nstower"), "ns_06_monster2"))
	{
		return false;
	}
	if (get_property("auto_towerBreak").to_lower_case() == "wall of meat" || get_property("auto_towerBreak").to_lower_case() == "wallofmeat" || get_property("auto_towerBreak").to_lower_case() == "meat" || get_property("auto_towerBreak").to_lower_case() == "level 2")
	{
		abort("auto_towerBreak set to abort here.");
	}
	equipBaseline();
	provideMeat(626, true, false);

	if(in_zombieSlayer())
	{
		acquireMP(30,0);
	}

	acquireHP();
	autoAdvBypass("place.php?whichplace=nstower&action=ns_06_monster2", $location[Noob Cave]);
	return true;
}

boolean L13_towerNSTowerBones()
{
	if(!contains_text(visit_url("place.php?whichplace=nstower"), "ns_07_monster3"))
	{
		return false;
	}
	if (get_property("auto_towerBreak").to_lower_case() == "wall of bones" || get_property("auto_towerBreak").to_lower_case() == "wallofbones" || get_property("auto_towerBreak").to_lower_case() == "bones" || get_property("auto_towerBreak").to_lower_case() == "level 3")
	{
		abort("auto_towerBreak set to abort here.");
	}
	familiar hundred_fam = to_familiar(get_property("auto_100familiar"));
	boolean has_boning_knife = item_amount($item[Electric Boning Knife]) > 0;
	
	if(has_boning_knife || in_pokefam() || (in_wereprof() && canUse($skill[Slaughter]) && have_effect($effect[Everything Looks Red]) == 0))		//I have everything I need. just go fight
	{
		return autoAdvBypass("place.php?whichplace=nstower&action=ns_07_monster3", $location[Noob Cave]);
	}
	
	//should I grab an electric boning knife?
	if(hundred_fam != $familiar[none] && isAttackFamiliar(hundred_fam))
	{
		set_property("auto_getBoningKnife", true);		//in 100% familiar run with attack familiar we must acquire boning knife
	}
	if(my_class() != $class[Sauceror] && !have_skill($skill[Garbage Nova]))
	{
		set_property("auto_getBoningKnife", true);		//can not towerkill. get boning knife instead
	}
	if(!uneffect($effect[Scariersauce]))
	{
		//passive dmg prevents tower kill. we can not uneffect it so get boning knife instead
		set_property("auto_getBoningKnife", true);
	}
	
	if(get_property("auto_getBoningKnife").to_boolean())	//grab boning knife if we deemed it necessary
	{
		if(lar_repeat($location[The Castle in the Clouds in the Sky (Ground Floor)]))
		{
			auto_log_info("Backfarming an Electric Boning Knife", "green");
			return autoAdv($location[The Castle in the Clouds in the Sky (Ground Floor)]);
		}
		else abort("I determined I must get [Electric Boning Knife] to proceed but I can not get one");
	}
	
	//if we reached this spot we decided that we do not need a boning knife and intend to try to towerkill the wall of bones.
	uneffect($effect[Scarysauce]);
	uneffect($effect[Jalape&ntilde;o Saucesphere]);
	uneffect($effect[Spiky Shell]);
	if(in_aosol()){
		uneffect($effect[Queso Fustulento]);
		uneffect($effect[Tricky Timpani]);
	}
	uneffect($effect[Psalm of Pointiness]);
	uneffect($effect[Mayeaugh]);
	uneffect($effect[Feeling Nervous]);
	buffMaintain($effect[Tomato Power]);
	buffMaintain($effect[Seeing Colors]);
	buffMaintain($effect[Glittering Eyelashes]);
	buffMaintain($effect[OMG WTF]);
	buffMaintain($effect[There is a Spoon]);
	buffMaintain($effect[Song of Sauce]);
	buffMaintain($effect[Carol of the Hells]);
	
	// Maximizer tries to force familiar equipment. and prefers passive dmg a that. Avoid dealing damage from familiar and losing
	if(canChangeFamiliar())
	{
		use_familiar(lookupFamiliarDatafile("gremlins"));		//delevel with no damage. fallback to none if unavailable
		set_property("auto_disableFamiliarChanging", true);
	}
	if(my_familiar() != $familiar[none])
	{
		addToMaximize("-familiar");
		equip($slot[familiar], $item[none]);
	}

	addToMaximize("100myst,60spell damage percent,20spell damage,-20ml");
	equipMaximizedGear();
	foreach s in $slots[acc1, acc2, acc3]
	{
		if(equipped_item(s) == $item[hand in glove])
		{
			equip(s, $item[none]);
		}
	}
	
	//Wall Of Bones combat uses Unleash The Greash, Garbage Nova, or Saucegeyser
	if(!auto_have_skill($skill[Garbage Nova]) && have_effect($effect[Takin\' It Greasy]) == 0)
	{
		float saucegeyserDamage = MLDamageToMonsterMultiplier()*ceil((numeric_modifier("Spell Damage Percent")/100.0)*(60 + numeric_modifier("Spell Damage") + max(numeric_modifier("Hot Spell Damage"),numeric_modifier("Cold Spell Damage")) + 0.4*my_buffedstat($stat[mysticality])));
		if(saucegeyserDamage < 1667)
		{
			//counting on Saucegeyser and its damage will be too low
			auto_log_warning("Estimate would fail to towerkill Wall of Bones. Reverting to Boning Knife", "red");
			set_property("auto_getBoningKnife", true);
			return true;
		}
	}
	
	acquireMP(216, 0);
	acquireHP();
	autoAdvBypass("place.php?whichplace=nstower&action=ns_07_monster3", $location[Noob Cave]);
	if(internalQuestStatus("questL13Final") < 9)
	{
		auto_log_warning("Failed to towerkill Wall of Bones. Reverting to Boning Knife", "red");
		set_property("auto_getBoningKnife", true);
	}
	return true;
}

boolean L13_towerNSTowerMirror()
{
	if(!contains_text(visit_url("place.php?whichplace=nstower"), "ns_08_monster4"))
	{
		return false;
	}
	if (get_property("auto_towerBreak").to_lower_case() == "mirror" || get_property("auto_towerBreak").to_lower_case() == "level 4")
	{
		abort("auto_towerBreak set to abort here.");
	}
	boolean confidence = get_property("auto_confidence").to_boolean();
	// confidence really just means take the first choice, so necessary in vampyre
	if(in_darkGyffte())
		confidence = true;
	string choicenum = (confidence ? "1" : "2");
	set_property("choiceAdventure1015", choicenum);
	visit_url("place.php?whichplace=nstower&action=ns_08_monster4");
	visit_url("choice.php?pwd=&whichchoice=1015&option=" + choicenum, true);
	return true;
}

boolean L13_towerNSTowerShadow()
{
	if(!contains_text(visit_url("place.php?whichplace=nstower"), "ns_09_monster5"))
	{
		return false;
	}
	
	if(in_robot())
	{
		abort("Robot shadow not currently automated. Pleasae kill your shadow manually then run me again");
	}
	if (get_property("auto_towerBreak").to_lower_case() == "shadow" || get_property("auto_towerBreak").to_lower_case() == "the shadow" || get_property("auto_towerBreak").to_lower_case() == "level 5")
	{
		abort("auto_towerBreak set to abort here.");
	}
	if(my_maxhp() < 800)
	{
		buffMaintain($effect[Industrial Strength Starch]);
		buffMaintain($effect[Truly Gritty]);
		buffMaintain($effect[Superheroic]);
		buffMaintain($effect[Strong Grip]);
		buffMaintain($effect[Spiky Hair]);
	}
	cli_execute("scripts/autoscend/auto_post_adv.ash");
	acquireHP();

	int n_healing_items = item_amount($item[gauze garter]) + item_amount($item[filthy poultice]) + item_amount($item[red pixel potion]) + item_amount($item[scented massage oil]);
	if(in_plumber())
	{
		n_healing_items = item_amount($item[super deluxe mushroom]);
		if(n_healing_items < 5)
		{
			retrieve_item(5, $item[super deluxe mushroom]);
			n_healing_items = item_amount($item[super deluxe mushroom]);
		}
	}
	if(n_healing_items < 5)
	{
		int pull_target = 5 - n_healing_items; //pull healing items if we have any pulls left because its not like we need pulls for anything else at this point
		int pulled_items = 0;
		foreach it in $items[gauze garter, filthy poultice, red pixel potion]
		{
			pullXWhenHaveY(it,1,item_amount(it));
		}
		
		// If we're in Kingdom of Exploathing, there's no realm . Let's try clovering for massage oil instead
		if (in_koe())
		{
			cloverUsageInit();
			autoAdv($location[Cobb\'s Knob Harem]);
			if(cloverUsageRestart()) autoAdv($location[Cobb\'s Knob Harem]);
			cloverUsageFinish();
		}
		else {
			int create_target = min(creatable_amount($item[red pixel potion]), pull_target - pulled_items);
			if(create_target > 0)
			{
				if(create(create_target, $item[red pixel potion]))
				{
					return true;
				}
				abort("I tried to create [red pixel potions] for the shadow and mysteriously failed");
			}
			return autoAdv($location[8-bit Realm]);
		}
	}
	autoAdvBypass("place.php?whichplace=nstower&action=ns_09_monster5", $location[Noob Cave]);
	return true;
}

boolean L13_towerNSFinal()
{
	if (get_property("auto_towerBreak").to_lower_case() == "naughty sorceress" || get_property("auto_towerBreak").to_lower_case() == "the naughty sorceress" || get_property("auto_towerBreak").to_lower_case() == "ns" || get_property("auto_towerBreak").to_lower_case() == "sorceress" || get_property("auto_towerBreak").to_lower_case() == "level 6" || get_property("auto_towerBreak").to_lower_case() == "chamber")
	{
		abort("auto_towerBreak set to abort here.");
	}
	//state 11 means ready to fight sorceress. state 12 means lost to her due to lack of wand thus unlocking bear verb orgy
	if (internalQuestStatus("questL13Final") < 11 || internalQuestStatus("questL13Final") > 12)
	{
		return false;
	}
	if(in_robot())
	{
		abort("Automatic killing of nautomatic sauceress not implemented. Please kill her manually");
	}
	
	//wand acquisition function is called before this function, it turns this propery to false once a wand is acquired.
	//it is also false on all paths that don't want a wand. Thus if it is true it means we do want a wand but didn't get one yet.
	if(get_property("auto_wandOfNagamar").to_boolean() && internalQuestStatus("questL13Final") == 11)
	{
		auto_log_warning("We do not have a Wand of Nagamar but appear to need one. We must lose to the Sausage first...", "red");
	}

	if(in_heavyrains())
	{
		return L13_heavyrains_towerFinal();
	}
	
	if(in_bhy())
	{
		return L13_bhy_towerFinal();
	}
	
	if(in_theSource())
	{
		acquireMP(200, 0);
	}
	
	if(!(isActuallyEd() || is_boris() || is_jarlsberg() || is_pete() || in_bhy() || in_bugbear() || in_theSource() || in_wotsf() || in_zombieSlayer() || in_aosol()))
	{
		//Only if the final boss does not unbuff us...
		cli_execute("scripts/autoscend/auto_post_adv.ash");
	}
	
	if(my_class() == $class[Turtle Tamer])
	{
		autoEquip($item[Ouija Board\, Ouija Board]);
	}

	if(auto_can_equip($item[Oscus\'s Garbage Can Lid]))
	{
		pullXWhenHaveY($item[Oscus\'s Garbage Can Lid], 1, 0);
	}

	autoEquip($slot[Off-Hand], $item[Oscus\'s Garbage Can Lid]);

	handleFamiliar("boss");

	addToMaximize("10dr,3moxie,0.5da 1000max,-5ml,1.5hp,0item,0meat");
	autoEquip($slot[acc2], $item[Attorney\'s Badge]);
	//AoSOL buffs
	if(in_aosol())
	{
		buffMaintain($effect[Queso Fustulento], 10, 1, 10);
		buffMaintain($effect[Tricky Timpani], 30, 1, 10);
	}

	if(internalQuestStatus("questL13Final") < 13)
	{
		cli_execute("scripts/autoscend/auto_pre_adv.ash");
		set_property("auto_disableAdventureHandling", true);
		autoAdvBypass("place.php?whichplace=nstower&action=ns_10_sorcfight", $location[Noob Cave]);
		if(have_effect($effect[Beaten Up]) > 0)
		{
			auto_log_warning("Sorceress beat us up. Wahhh.", "red");
			set_property("auto_disableAdventureHandling", false);
			return true;
		}
		if(last_monster() == $monster[Naughty Sorceress])
		{
			autoAdv(1, $location[Noob Cave]);
			if(have_effect($effect[Beaten Up]) > 0)
			{
				auto_log_warning("Blobbage Sorceress beat us up. Wahhh.", "red");
				set_property("auto_disableAdventureHandling", true);
				return true;
			}
			autoAdv(1, $location[Noob Cave]);
			if(have_effect($effect[Beaten Up]) > 0)
			{
				if(get_property("lastEncounter") == "The Naughty Sorceress (3)")
				{
					string page = visit_url("choice.php");
					if(last_choice() == 1016)
					{
						run_choice(1);
						set_property("auto_wandOfNagamar", true);
					}
					else
					{
						abort("Expected to start Nagamar side-quest but unable to");
					}
					return true;
				}
				auto_log_warning("We got beat up by a sausage....", "red");
				set_property("auto_disableAdventureHandling", false);
				return true;
			}
			set_property("auto_disableAdventureHandling", false);
		}
	}

	// restore ML Safety Limit if this run changed it
	if(property_exists("auto_MLSafetyLimitBackup"))
	{
		string MLSafetyLimitBackup = get_property("auto_MLSafetyLimitBackup");
		if(MLSafetyLimitBackup == "empty") set_property("auto_MLSafetyLimit","");
		else set_property("auto_MLSafetyLimit", MLSafetyLimitBackup);
		remove_property("auto_MLSafetyLimitBackup");
	}
	// restore disregard karma if this run changed it
	if(property_exists("auto_disregardInstantKarmaBackup"))
	{
		set_property("auto_disregardInstantKarma",get_property("auto_disregardInstantKarmaBackup"));
		remove_property("auto_disregardInstantKarmaBackup");
	}

	if(auto_turbo())
	{
		set_property("auto_turbo", "false");
	}


	if(get_property("auto_stayInRun").to_boolean())
	{
		abort("User wanted to stay in run (auto_stayInRun), we are done.");
	}

	if(my_class() == $class[Vampyre] && (0 < item_amount($item[Thwaitgold mosquito statuette])))
	{
		abort("Freeing the king will result in a path change. Enjoy your immortality.");
	}

	if(my_class() == $class[Plumber] && (0 < item_amount($item[Thwaitgold buzzy beetle statuette])))
	{
		abort("Freeing the king will lose your extra stomach space. Enjoy the rest of your video game.");
	}

	if($classes[Pig Skinner, Cheese Wizard, Jazz Agent] contains my_class() && (0 < item_amount($item[Thwaitgold anti-moth statuette])))
	{
		visit_url("place.php?whichplace=nstower&action=ns_11_prism");
		return true;
	}

	if(in_lol())
	{
		abort("Freeing the king will result in losing all your replica IOTM. Enjoy them while you have them!");
	}

	if(in_wereprof() && (0 < item_amount($item[Thwaitgold wolf spider statuette])))
	{
		abort("Freeing the king will result in a path change. Go howl at the moon some more if you want.");
	}

	// It is possible to keep your Yearbook Club Camera in KOLHS by having it equipped before breaking the prism
	if (in_kolhs() && !have_equipped($item[Yearbook Club Camera]) && (item_amount($item[Yearbook Club Camera]) > 0))
	{
		equip($slot[acc3], $item[Yearbook Club Camera]);
	}

	if(!($classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief] contains my_class()))
	{
		abort("Freeing the king will result in a path change and we can barely handle The Sleazy Back Alley. Aborting, run the script again after selecting your aftercore path in order for it to clean up.");
	}

	visit_url("place.php?whichplace=nstower&action=ns_11_prism");
	if(!inAftercore())
	{
		abort("Yeah, so, I'm done. You might be stuck at the shadow, or at the final boss, or just with a king in a prism. I don't know and quite frankly, after the last " + my_daycount() + " days, I don't give a damn. That's right, I said it. Bitches.");
	}
	return true;
}

boolean L13_towerNSNagamar()
{
	// the first if check will skip getting a wand if autoscend configuration says we don't want one AND you are not on step12 of the quest
	// if you are on step12 it will override the configuration and proceed to get a wand anyways
	// quest step12 means you fought the sorceress and lost due to not having a wand.
	// autoscend only reaches step12 of the quest if autoscend was incapable of acquiring a wand before the sorceress
	// it then has to fallback to bear verb orgy, which itself cannot be done until step12
	if(in_koe())
	{
		return L13_koe_towerNSNagamar();
	}
	if (!get_property("auto_wandOfNagamar").to_boolean() || internalQuestStatus("questL13Final") < 11 || internalQuestStatus("questL13Final") > 12)
	{
		return false;
	}
	if(item_amount($item[Wand of Nagamar]) > 0)
	{
		set_property("auto_wandOfNagamar", false);
		return false;
	}
	
	if(in_disguises() && internalQuestStatus("questL13Final") == 12)
	{
		cli_execute("refresh quests");
		if(internalQuestStatus("questL13Final") != 12)
		{
			abort("In this specific ascension [naughty sorceress \(3\)] is wearing a mask that makes kol base game fail to advance the quest to step 12. Which means that bear verb orgy is impossible for this specific run. Manually get the [Lucky!] effect then use it to get a [Wand of Nagamar] manually and run me again");
		}
	}
	
	if(creatable_amount($item[Wand Of Nagamar]) == 0 && pulls_remaining() > 0)
	{
		boolean haveW = item_amount($item[ruby W]) != 0;
		boolean haveA = item_amount($item[metallic A]) != 0;
		boolean haveN = item_amount($item[lowercase N]) != 0;
		boolean haveD = item_amount($item[heavy D]) != 0;
		if(!haveW || !haveA)
		{
			if((haveN && haveD) || item_amount($item[ND]) > 0 || pulls_remaining() > 1)	//if no ND, need 2 pulls
			{
				pullXWhenHaveY($item[WA], 1, 0);
			}
		}
		if((!haveN || !haveD) && ((haveA && haveW) || item_amount($item[WA]) > 0))	//if no WA, should not pull
		{
			pullXWhenHaveY($item[ND], 1, 0);
		}
	}
	
	if(creatable_amount($item[Wand Of Nagamar]) > 0)
	{
		return create(1, $item[Wand Of Nagamar]);
	}
	
	//hunt for bear verb orgy
	if (item_amount($item[Wand of Nagamar]) == 0 && internalQuestStatus("questL13Final") == 12 && !in_koe())
	{
		return autoAdv($location[The VERY Unquiet Garves]);
	}
	
	if (autoLuckyAdv($location[The Castle in the Clouds in the Sky (Basement)], true)) {
		if (creatable_amount($item[Wand Of Nagamar]) > 0)
		{
			return create(1, $item[Wand Of Nagamar]);
		}
		else
		{
			auto_log_warning("Clovering [The Castle in the Clouds in the Sky (Basement)] for wand parts failed for some reason", "red");
		}
	}
	return false;
}

boolean L13_towerAscent()
{
	if (L13_towerNSContests() || L13_towerNSHedge()|| L13_sorceressDoor() || L13_towerNSTower() || L13_towerNSNagamar() || L13_towerNSFinal())
	{
		return true;
	}
	return false;
}
