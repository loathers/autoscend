script "heavy_rains.ash"

boolean rainManSummon(string monsterName, boolean copy, boolean wink);

void hr_initializeSettings()
{
	if(my_path() == "Heavy Rains")
	{
		#Rain Man (Heavy Rains) Related settings
		set_property("auto_holeinthesky", false);
		set_property("auto_mountainmen", "");
		set_property("auto_ninjasnowmanassassin", "");
		set_property("auto_orcishfratboyspy", "");
		set_property("auto_warhippyspy", "");

		set_property("auto_lastthunder", "100");
		set_property("auto_lastthunderturn", "0");

		set_property("auto_wandOfNagamar", false);
		set_property("auto_writingDeskSummon", true);

		set_property("auto_day1_desk", "");
		set_property("auto_day1_skills", "");
	}
}

boolean routineRainManHandler()
{
	if(!have_skill($skill[Rain Man]) || (auto_my_path() != "Heavy Rains"))
	{
		return false;
	}
	
	boolean want_to_rainman = false;
	if((my_rain() > (92 - (7 * (my_daycount() - 1)))) && (have_effect($effect[ultrahydrated]) == 0))
	{
		want_to_rainman = true;
	}
	//stomach and liver are full, and 1 adv is left before we are done for the day
	if(my_adventures() == (1 + auto_advToReserve()) && my_rain() >= 50 && my_fullness() == fullness_limit() && my_inebriety() == inebriety_limit())
	{
		want_to_rainman = true;
	}
	
	if(want_to_rainman)
	{
		if(get_property("auto_mountainmen") == "")
		{
			set_property("auto_mountainmen", "1");
			return rainManSummon("mountain man", true, false);
		}

		if (internalQuestStatus("questL08Trapper") < 2)
		{
			return rainManSummon("mountain man", false, false);
		}

		if(get_property("auto_ninjasnowmanassassin") == "")
		{
			return rainManSummon("ninja snowman assassin", true, false);
		}

		if((have_effect($effect[Everything Looks Yellow]) == 0) && (get_property("auto_orcishfratboyspy") == "") && !get_property("auto_hippyInstead").to_boolean())
		{
			return rainManSummon("orcish frat boy spy", false, false);
		}
		
		if((have_effect($effect[Everything Looks Yellow]) == 0) && (get_property("auto_warhippyspy") == "") && get_property("auto_hippyInstead").to_boolean())
		{
			return rainManSummon("war hippy spy", false, false);
		}
		
		if(needStarKey())
		{
			if(item_amount($item[star]) < 8 && item_amount($item[line]) < 7)
			{
				return rainManSummon("skinflute", true, false);
			}
			else if((item_amount($item[star chart]) == 0))
			{
				return rainManSummon("the astronomer", false, false);
			}
		}
		if(needDigitalKey())
		{
			if (get_property("sidequestNunsCompleted") != "none" && my_rain() > 92)
			{
				if(whitePixelCount() < 30 && item_amount($item[digital key]) == 0)
				{
					return rainManSummon("ghost", false, false);
				}
			}
		}

		if(my_daycount() < 3)
		{
			auto_log_info("I have nothing left to rain man, maybe we are getting ready for make it rain?");
		}
	}
	return false;
}



void hr_initializeDay(int day)
{
	if(my_path() == "Heavy Rains")
	{
		if((day == 1) && (get_property("auto_day1_skills") != "finished"))
		{
			set_property("choiceAdventure967", "1");
			set_property("choiceAdventure968", "1");
			set_property("choiceAdventure969", "3");

			if(item_amount($item[thunder thigh]) > 0)
			{
				visit_url("inv_use.php?which=3&whichitem=7648&pwd");
				visit_url("choice.php?pwd&whichchoice=967&option=1", true);
				visit_url("choice.php?pwd&whichchoice=967&option=3", true);
				visit_url("choice.php?pwd&whichchoice=967&option=5", true);
				set_property("choiceAdventure967", "7");
			}

			if(item_amount($item[aquaconda brain]) > 0)
			{
				visit_url("inv_use.php?which=3&whichitem=7647&pwd");
				visit_url("choice.php?pwd&whichchoice=968&option=1", true);
				visit_url("choice.php?pwd&whichchoice=968&option=3", true);
				visit_url("choice.php?pwd&whichchoice=968&option=4", true);
				set_property("choiceAdventure968", "2");
			}

			if(item_amount($item[lightning milk]) > 0)
			{
				visit_url("inv_use.php?which=3&whichitem=7646&pwd");
				visit_url("choice.php?pwd&whichchoice=969&option=3", true);
				visit_url("choice.php?pwd&whichchoice=969&option=1", true);
				visit_url("choice.php?pwd&whichchoice=969&option=7", true);
				set_property("choiceAdventure969", "2");
			}

			if(item_amount($item[miniature life preserver]) == 0)
			{
				buyUpTo(1, $item[miniature life preserver]);
			}
			set_property("auto_day1_skills", "finished");
			visit_url("main.php");
		}
		else if((day == 2) && (my_rain() > 80))
		{
			if((get_property("chateauAvailable").to_boolean() == false) || (get_property("chateauMonster") != "lobsterfrogman"))
			{
				rainManSummon("lobsterfrogman", true, true);
			}
		}
	}
}

void hr_doBedtime()
{
	if(my_inebriety() > inebriety_limit())
	{
		while((have_skill($skill[Rain Dance])) && (my_rain() >= 10))
		{
			use_skill(1, $skill[Rain Dance]);
		}
		while((have_skill($skill[thunderheart])) && (my_thunder() >= 20))
		{
			use_skill(1, $skill[thunderheart]);
		}
		while((have_skill($skill[Clean-Hair Lightning])) && (my_lightning() >= 10))
		{
			use_skill(1, $skill[Clean-Hair Lightning]);
		}
	}
}

boolean doHRSkills()
{
	if(my_path() != "Heavy Rains")
	{
		return false;
	}
	else
	{
		if(item_amount($item[thunder thigh]) > 0)
		{
			auto_log_info("Trying to use a thunder thigh", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7648&pwd");
			runChoice(page);
			if(get_property("choiceAdventure967") == "1")
			{
				set_property("choiceAdventure967", "3");
			}
			else if(get_property("choiceAdventure967") == "3")
			{
				set_property("choiceAdventure967", "5");
			}
			else if(get_property("choiceAdventure967") == "5")
			{
				set_property("choiceAdventure967", "7");
			}
			else if(get_property("choiceAdventure967") == "7")
			{
				set_property("choiceAdventure967", "4");
			}
			else if(get_property("choiceAdventure967") == "4")
			{
				set_property("choiceAdventure967", "2");
			}
			else if(get_property("choiceAdventure967") == "2")
			{
				set_property("choiceAdventure967", "6");
			}
			else if(get_property("choiceAdventure967") == "6")
			{
				set_property("choiceAdventure967", "8");
			}
			visit_url("main.php");
			return true;
		}

		if(item_amount($item[aquaconda brain]) > 0)
		{
			auto_log_info("Trying to use a aquaconda brain", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7647&pwd");
			runChoice(page);
			if(get_property("choiceAdventure968") == "1")
			{
				set_property("choiceAdventure968", "3");
			}
			else if(get_property("choiceAdventure968") == "3")
			{
				set_property("choiceAdventure968", "4");
			}
			else if(get_property("choiceAdventure968") == "4")
			{
				set_property("choiceAdventure968", "2");
			}
			else if(get_property("choiceAdventure968") == "2")
			{
				set_property("choiceAdventure968", "5");
			}
			else if(get_property("choiceAdventure968") == "5")
			{
				set_property("choiceAdventure968", "6");
			}
			else if(get_property("choiceAdventure968") == "6")
			{
				set_property("choiceAdventure968", "7");
			}
			else if(get_property("choiceAdventure968") == "7")
			{
				set_property("choiceAdventure968", "8");
			}
			visit_url("main.php");
			return true;
		}

		if(item_amount($item[lightning milk]) > 0)
		{
			auto_log_info("Trying to use a lightning milk", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7646&pwd");
			runChoice(page);
			if(get_property("choiceAdventure969") == "3")
			{
				set_property("choiceAdventure969", "1");
			}
			else if(get_property("choiceAdventure969") == "1")
			{
				set_property("choiceAdventure969", "7");
			}
			else if(get_property("choiceAdventure969") == "7")
			{
				set_property("choiceAdventure969", "2");
			}
			else if(get_property("choiceAdventure969") == "2")
			{
				set_property("choiceAdventure969", "4");
			}
			else if(get_property("choiceAdventure969") == "4")
			{
				set_property("choiceAdventure969", "5");
			}
			else if(get_property("choiceAdventure969") == "5")
			{
				set_property("choiceAdventure969", "6");
			}
			else if(get_property("choiceAdventure969") == "6")
			{
				set_property("choiceAdventure969", "8");
			}
			visit_url("main.php");
			return true;
		}
	}
	return false;
}

boolean rainManSummon(string monsterName, boolean copy, boolean wink, string option)
{
	if(my_path() != "Heavy Rains")
	{
		return false;
	}

	if(!have_skill($skill[Rain Man]))
	{
		return false;
	}

	# Some of the logic here has been lost due to auto_combat.ash
	# It will probably never be updated since it just slows down the script and has no actual damage.

	if(my_rain() < 50)
	{
		return false;
	}
	string mId = 0;
	if((monsterName == "astronomer") || (monsterName == "the astronomer"))
	{
		mId = 184;
	}
	if(monsterName == "huge swarm of ghuol whelps")
	{
		mId = 1072;
	}
	if(monsterName == "trouser snake")
	{
		mId = 179;
	}
	if(monsterName == "family jewels")
	{
		mId = 180;
	}
	if(monsterName == "orcish frat boy spy")
	{
		mId = 409;
	}
	if(monsterName == "war hippy spy")
	{
		mId = 419;
	}
	if(monsterName == "morbid skull")
	{
		mId = 1269;
	}
	if(monsterName == "skinflute")
	{
		mId = 353;
	}
	if(monsterName == "writing desk")
	{
		mId = 405;
	}
	if(monsterName == "dirty thieving brigand")
	{
		mId = 475;
	}
	if(monsterName == "lobsterfrogman")
	{
		mId = 529;
	}
	if(monsterName == "ghost")
	{
		mId = 950;
	}
	if(monsterName == "mountain man")
	{
		mId = 1153;
	}
	if(monsterName == "ninja snowman assassin")
	{
		mId = 1185;
	}

	if(mId == 0)
	{
		return false;
	}

	if((item_amount($item[ghost of a necklace]) == 1) && (monsterName == "writing desk"))
	{
		#No more writing desks please.
		return false;
	}
	if((item_amount($item[richard\'s star key]) == 1) && (monsterName == "skinflute"))
	{
		#already have the goal, don't summon
		return false;
	}
	if((item_amount($item[richard\'s star key]) == 1) && (mId == 184))
	{
		#already have the goal, don't summon
		return false;
	}
	if((item_amount($item[star chart]) > 0) && (mId == 184))
	{
		#already have the goal, don't summon
		return false;
	}

	if((item_amount($item[star]) >= 8) && (item_amount($item[line]) >= 7) && (monsterName == "skinflute"))
	{
		#already have the subgoal, don't summon
		return false;
	}
	if((item_amount($item[digital key]) == 1) && (monsterName == "ghost"))
	{
		#already have the goal, don't summon
		return false;
	}
	if(whitePixelCount() > 29 && monsterName == "ghost")
	{
		#already have the subgoal, don't summon
		return false;
	}
	if ((get_property("sidequestLighthouseCompleted") != "none" || item_amount($item[barrel of gunpowder]) >= 5) && monsterName == "lobsterfrogman")
	{
		#already have the subgoal, don't summon
		return false;
	}
	##Handle reject after we satisfy the lobsterfrogman
	if(monsterName == "ninja snowman assassin")
	{
		int count = min(item_amount($item[ninja rope]), 1);
		count = count + min(item_amount($item[ninja crampons]), 1);
		count = count + min(item_amount($item[ninja carabiner]), 1);
		if(count == 3)
		{
			set_property("auto_ninjasnowmanassassin", "1");
			#already have all ninja gear
			return false;
		}
		if(count == 2)
		{
			set_property("auto_ninjasnowmanassassin", "1");
			copy = false;
		}
		wink = false;
	}

	if(monsterName == "orcish frat boy spy")
	{
		set_property("auto_orcishfratboyspy", "done");
		if((item_amount($item[beer helmet]) > 0) || (item_amount($item[bejeweled pledge pin]) > 0) || (item_amount($item[distressed denim pants]) > 0))
		{
			return false;
		}
		if((have_effect($effect[everything looks yellow]) > 0) || (my_lightning() < 5))
		{
			return false;
		}
	}
	
	if(monsterName == "war hippy spy")
	{
		set_property("auto_warhippyspy", "done");
		if((item_amount($item[reinforced beaded headband]) > 0) || (item_amount($item[round purple sunglasses]) > 0) || (item_amount($item[bullet-proof corduroys]) > 0))
		{
			return false;
		}
		if((have_effect($effect[everything looks yellow]) > 0) || (my_lightning() < 5))
		{
			return false;
		}
	}

	if(monsterName == "skinflute")
	{
		if(item_amount($item[star]) >= 8)
		{
			monsterName = "trouser snake";
			mId = 179;
			copy = false;
			wink = false;
		}
		else if(item_amount($item[line]) >= 7)
		{
			monsterName = "family jewels";
			mId = 180;
			copy = false;
			wink = false;
		}
	}


	if((get_property("_raindohCopiesMade").to_int() >= 5) || (item_amount($item[Rain-doh box full of monster]) > 0))
	{
		copy = false;
	}

	set_property("choiceAdventure970", "0");

	if(!canChangeToFamiliar($familiar[Reanimated Reanimator]))
	{
		wink = false;
	}
	else
	{
		handleFamiliar("item");
	}

	if((wink == true) && have_familiar($familiar[Reanimated Reanimator]))
	{
		if(get_property("_badlyRomanticArrows") == "1")
		{
			abort("Trying to arrow/wink a monster but we've already done so today.");
		}
#		use_familiar($familiar[Reanimated Reanimator]);
		handleFamiliar($familiar[Reanimated Reanimator]);
	}

	if(copy)
	{
		set_property("auto_doCombatCopy", "yes");
	}
	auto_log_info("Looking to summon: " + monsterName, "blue");

	string[int] pages;
	pages[0] = "runskillz.php?pwd&action=Skillz&whichskill=16011&quantity=1";
	pages[1] = "choice.php?pwd&whichchoice=970&whichmonster=" + mId + "&option=1&choice2=and+Fight%21";
	autoAdvBypass(0, pages, $location[Noob Cave], option);

#	handlePreAdventure($location[Noob Cave]);
#	visit_url("runskillz.php?pwd&action=Skillz&whichskill=16011&quantity=1", true);
#	visit_url("choice.php?pwd&whichchoice=970&whichmonster=" + mId + "&option=1&choice2=and+Fight%21");
#	autoAdv(1, $location[Noob Cave]);

	if(wink == true)
	{
		handleFamiliar("item");
	}
	if(copy && (item_amount($item[Rain-doh box full of monster]) == 0))
	{
		abort("Tried to make a copy but failed");
	}

	return true;
}


boolean rainManSummon(string monsterName, boolean copy, boolean wink)
{
	return rainManSummon(monsterName, copy, wink, "");
}

boolean L13_towerFinalHeavyRains()
{
	//Prepare for and defeat the final boss for Heavy Rains run. Which has special rules for engagement.
	if (internalQuestStatus("questL13Final") != 11)
	{
		return false;
	}
	
	//use a damage dealing familiar
	if(canChangeToFamiliar($familiar[warbear drone]))			//old event item. still farmable. up to 6 attacks per round
	{
		use_familiar($familiar[Warbear Drone]);
		//TODO does rain king stripping at begining of combat remove familiar equipment? if yes remove the part below
		pullXWhenHaveY($item[warbear drone codes], 1, 0);
		if(possessEquipment($item[warbear drone codes]))
		{
			equip($item[warbear drone codes]);
		}
	}
	else if(canChangeToFamiliar($familiar[Sludgepuppy]))		//IOTM derivative, infinitely farmable. attacks 3 times per round
	{
		use_familiar($familiar[Sludgepuppy]);
	}
	else if(canChangeToFamiliar($familiar[Imitation Crab]))		//cheap, easily acquired. attacks 2 times per round
	{
		use_familiar($familiar[Imitation Crab]);
	}
	else if(canChangeToFamiliar($familiar[Angry Goat]))			//super cheap. high chance to attack each round.
	{
		use_familiar($familiar[Angry Goat]);
	}
	
	//buff up before the boss
	buffMaintain($effect[Benetton's Medley of Diversity], 0, 1, 1);			//15 prismatic weapon dmg.
	buffMaintain($effect[Dirge of Dreadfulness], 0, 1, 1);					//12 spooky weapon dmg
	buffMaintain($effect[Boner Battalion], 0, 1, 1);						//32-33 sleaze and spooky passive dmg
	buffMaintain($effect[Frigidalmatian], 0, 1, 1);							//40 (due to cap) cold passive dmg
	effectAblativeArmor(true);					//Unimportant effects protect your important one from being removed.
	
	//Calculate melee/ranged damage. Each element is capped at 40. assume you will be able to deal 40 physical damage.
	cli_execute("outfit Birthday Suit");			//Need to get naked so we can check our stats properly.
	maximize("prismatic damage, +weapon, +offhand", false);

	int hot_dmg = min(40,numeric_modifier("hot damage"));
	int cold_dmg = min(40,numeric_modifier("cold damage"));
	int stench_dmg = min(40,numeric_modifier("stench damage"));
	int sleaze_dmg = min(40,numeric_modifier("sleaze damage"));
	int spooky_dmg = min(40,numeric_modifier("spooky damage"));
	if(auto_have_skill($skill[Cold Shoulder]))
	{
		cold_dmg = min(40, (5+cold_dmg));
	}
	
	//lunging thrust smack as a seal clubber with a club triples elemental damage. this applies to damage that does not come from weapon, excluding cold shoulder.
	boolean want_club = false;
	if(my_class() == $class[Seal Clubber] && auto_have_skill($skill[Lunging Thrust-Smack]))
	{
		maximize("prismatic damage, +weapon, +offhand, +club", false);
		int club_hot_dmg = min(40,(3*numeric_modifier("hot damage")));
		int club_cold_dmg = min(40,(3*numeric_modifier("cold damage")));
		int club_stench_dmg = min(40,(3*numeric_modifier("stench damage")));
		int club_sleaze_dmg = min(40,(3*numeric_modifier("sleaze damage")));
		int club_spooky_dmg = min(40,(3*numeric_modifier("spooky damage")));
		
		if(auto_have_skill($skill[Cold Shoulder]))
		{
			club_cold_dmg = min(40, (5+club_cold_dmg));
		}

		if((hot_dmg + cold_dmg + stench_dmg + sleaze_dmg + spooky_dmg) < (club_hot_dmg + club_cold_dmg + club_stench_dmg + club_sleaze_dmg + club_spooky_dmg))
		{
			want_club = true;
			hot_dmg = club_hot_dmg;
			cold_dmg = club_cold_dmg;
			stench_dmg = club_stench_dmg;
			sleaze_dmg = club_sleaze_dmg;
			spooky_dmg = club_spooky_dmg;
		}
	}
	
	int attack_dmg = 40 + min(40,hot_dmg) + min(40,cold_dmg) + min(40,stench_dmg) + min(40,sleaze_dmg) + min(40,spooky_dmg);
	
	//check magic damage
	boolean spell_extra_element = false;
	if(item_amount($item[Rain-Doh green lantern]) > 0 || item_amount($item[meteorb]) > 0 || item_amount($item[snow mobile]) > 0)
	{
		spell_extra_element = true;
	}
	else foreach it in $items[Rain-Doh green lantern, meteorb, snow mobile]
	{
		if(acquireOrPull(it))
		{
			spell_extra_element = true;
			break;
		}
	}

	int	spell_dmg = 0;
	string best_spell = "";
	if(auto_have_skill($skill[Saucestorm]))
	{
		if(80>spell_dmg)
		{
			best_spell = "saucestorm";
			spell_dmg = max(80,spell_dmg);
		}
		//IIRC hot and cold extra elements don't work for saucestorm, so only want green lantern. TODO verify
		if(item_amount($item[Rain-Doh green lantern]) > 0 && 120>spell_dmg)
		{
			best_spell = "saucestorm";
			spell_dmg = max(120,spell_dmg);
		}
	}
	if(auto_have_skill($skill[Weapon of the Pastalord]) && auto_have_skill($skill[Flavour of Magic]))
	{
		if(80>spell_dmg)
		{
			best_spell = "weapon_of_the_pastalord";
			spell_dmg = max(80,spell_dmg);
		}
		if(spell_extra_element && 120>spell_dmg)
		{
			best_spell = "weapon_of_the_pastalord";
			spell_dmg = max(120,spell_dmg);
		}
	}
	if(auto_have_skill($skill[Turtleini]))
	{
		if(120>spell_dmg)
		{
			best_spell = "turtleini";
			spell_dmg = max(120,spell_dmg);
		}
		if(spell_extra_element && 160>spell_dmg)
		{
			//how does [Turtleini] get affected by extra elements? I am guessing it increases it to 160. TODO verify
			best_spell = "turtleini";
			spell_dmg = max(160,spell_dmg);
		}
	}
	
	boolean plan_on_spells = false;
	if(attack_dmg < spell_dmg)
	{
		plan_on_spells = true;
	}
	
	//final dressup for the boss
	if(plan_on_spells)
	{
		set_property("auto_rain_king_combat", best_spell);
		setFlavour($element[sleaze]);		//a safe element that does not conflict with offhand items.
		executeFlavour();
		if(spell_extra_element)
		{
			maximize("spell damage percent, +weapon", false);
			if(item_amount($item[Rain-Doh green lantern]) > 0)
			{
				equip($slot[off-hand], $item[Rain-Doh green lantern]);
			}
			else if(item_amount($item[meteorb]) > 0)
			{
				equip($slot[off-hand], $item[meteorb]);
			}
			else if(item_amount($item[snow mobile]) > 0)
			{
				equip($slot[off-hand], $item[snow mobile]);
			}
		}
		else
		{
			maximize("spell damage percent, +weapon, +offhand", false);
		}
	}
	else
	{
		set_property("auto_rain_king_combat", "attack");
		if(want_club)
		{
			maximize("prismatic damage, +weapon, +offhand, +club", false);
		}
		else
		{
			maximize("prismatic damage, +weapon, +offhand", false);
		}
	}
	
	//Rain King strips all equipment other than weapon and offhand.
	//Stripped equipment can only provide you with -ML which is applied before the stripping
	buyUpTo(3, $item[water wings for babies]);
	maximize("-ml, -weapon, -offhand", false);
	
	//Fight!
	//auto_disableAdventureHandling because we don't want maximize, switch familiar, change buffs, or anything else that might break our specific prepwork.
	acquireHP();
	acquireMP();
	set_property("auto_disableAdventureHandling", true);		
	autoAdvBypass("place.php?whichplace=nstower&action=ns_10_sorcfight", $location[Noob Cave]);
	set_property("auto_disableAdventureHandling", false);
	if(last_monster() != $monster[The Rain King])
	{
		abort("Failed to start the battle with The Rain King");
	}
	if(have_effect($effect[Beaten Up]) > 0)
	{
		abort("The Rain King beat me up! please finish him off manually");
	}
	if(get_property("auto_stayInRun").to_boolean())
	{
		abort("User wanted to stay in run (auto_stayInRun), we are done.");
	}
	else
	{
		visit_url("place.php?whichplace=nstower&action=ns_11_prism");
		if(inAftercore())
		{
			abort("All done. King Ralph has been freed");
		}
		abort("Tried to break prism but failed");
	}
	abort("How did I reach this line? I should have fought [The Rain King]");
	return false;
}
