script "heavyrains.ash"

import<cc_util.ash>

# Code here is supplementary handlers and specialized handlers

void hr_dnaPotions()
{
	if(my_path() != "Heavy Rains")
	{
		return;
	}
	if(get_property("dnaSyringe") == "construct")
	{
		if((get_property("_dnaPotionsMade").to_int() == 0) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
		if((get_property("_dnaPotionsMade").to_int() == 1) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "fish")
	{
		if((get_property("_dnaPotionsMade").to_int() == 2) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
		if((get_property("_dnaPotionsMade").to_int() == 0) && (my_daycount() == 2))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "constellation")
	{
		if((get_property("_dnaPotionsMade").to_int() == 1) && (my_daycount() == 2))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "dude")
	{
		if((get_property("_dnaPotionsMade").to_int() == 2) && (my_daycount() == 2))
		{
			cli_execute("camp dnapotion");
		}
	}
}

boolean rainManSummon(string monsterName, boolean copy, boolean wink);

void hr_initializeSettings()
{
	if(my_path() == "Heavy Rains")
	{
		#Rain Man (Heavy Rains) Related settings
		set_property("cc_gaudypirate", "");
		set_property("cc_lobsterfrogman", "");
		set_property("cc_knobplant", "");
		set_property("cc_mountainmen", "");
		set_property("cc_ninjasnowmanassassin", "");
		set_property("cc_orcishfratboyspy", "");

		set_property("cc_lastthunder", "100");
		set_property("cc_lastthunderturn", "0");

		set_property("cc_writingDeskSummon", true);

		set_property("cc_day1_desk", "");
		set_property("cc_day1_skills", "");
	}
	else
	{
		set_property("cc_hasrainman", "no");
		set_property("cc_haslightningbolt", "no");
	}
}

boolean hr_handleFamiliar(familiar fam)
{
	if(my_path() == "Heavy Rains")
	{
		equip($item[miniature life preserver]);
		return true;
	}
	return false;
}

boolean routineRainManHandler()
{
#	if(my_rain() > (92 - (12 * my_daycount())))
	if((my_rain() > (92 - (7 * (my_daycount() - 1)))) && (have_effect($effect[ultrahydrated]) == 0) && (get_property("cc_nunsTrickReady") != "yes") && (get_property("cc_nunsTrickActive") != "yes"))
	{
#		abort("Need to rain man something, do it manually and come back to me! Weee");
#		if(item_amount($item[evilometer]) > 0)
#		{
#			if((get_property("cyrptCrannyEvilness").to_int() > 0) && (get_property("cc_hugeghuol") == ""))
#			{
#				set_property("cc_hugeghuol", "1");
#				rainManSummon("huge swarm of ghuol whelps", true, false);
#				return true;
#			}
#		}

		if(get_property("cc_mountainmen") == "")
		{
			set_property("cc_mountainmen", "1");
			rainManSummon("mountain man", true, false);
			return true;
		}

		if(get_property("cc_gaudypirate") == "")
		{
			set_property("cc_gaudypirate", "1");
			rainManSummon("gaudy pirate", true, false);
			return true;
		}

		if(get_property("cc_trapper") == "start")
		{
			rainManSummon("mountain man", false, false);
			return true;
		}

		if(get_property("cc_ninjasnowmanassassin") == "")
		{
			rainManSummon("ninja snowman assassin", true, false);
			return true;
		}

		if((have_effect($effect[Everything Looks Yellow]) == 0) && (get_property("cc_orcishfratboyspy") == ""))
		{
			rainManSummon("orcish frat boy spy", false, false);
			return true;
		}

		if(!contains_text(get_property("nsTowerDoorKeysUsed"),"star key"))
		{
			if(!rainManSummon("skinflute", true, false))
			{
				if((item_amount($item[star chart]) == 0) && (item_amount($item[richard\'s star key]) == 0))
				{
					rainManSummon("the astronomer", false, false);
				}
			}
		}
		if(!contains_text(get_property("nsTowerDoorKeysUsed"),"digital key"))
		{
			if((get_property("cc_nuns") == "done") || (my_rain() == 100))
			{
				if((item_amount($item[white pixel]) < 30) && (item_amount($item[digital key]) == 0))
				{
					rainManSummon("ghost", false, false);
				}
			}
		}

		if(my_daycount() < 3)
		{
			print("I have nothing left to rain man, maybe we are getting ready for make it rain?");
		}
	}
	return false;
}



void hr_initializeDay(int day)
{
	if(my_path() == "Heavy Rains")
	{
		if((day == 1) && (get_property("cc_day1_skills") != "finished"))
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
				set_property("cc_hasrainman", "true");
			}

			if(item_amount($item[lightning milk]) > 0)
			{
				visit_url("inv_use.php?which=3&whichitem=7646&pwd");
				visit_url("choice.php?pwd&whichchoice=969&option=3", true);
				visit_url("choice.php?pwd&whichchoice=969&option=1", true);
				visit_url("choice.php?pwd&whichchoice=969&option=7", true);
				set_property("choiceAdventure969", "2");
				set_property("cc_haslightningbolt", "true");
			}

			if(item_amount($item[miniature life preserver]) == 0)
			{
				buyUpTo(1, $item[miniature life preserver]);
			}
			set_property("cc_day1_skills", "finished");
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
			print("Trying to use a thunder thigh", "blue");
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
			print("Trying to use a aquaconda brain", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7647&pwd");
			runChoice(page);
			if(get_property("choiceAdventure968") == "1")
			{
				set_property("cc_hasrainman", "true");
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
			print("Trying to use a lightning milk", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7646&pwd");
			runChoice(page);
			if(get_property("choiceAdventure969") == "3")
			{
				set_property("choiceAdventure969", "1");
			}
			else if(get_property("choiceAdventure969") == "1")
			{
				set_property("cc_haslightningbolt", "true");
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


boolean rainManSummon(string monsterName, boolean copy, boolean wink)
{
	if(my_path() != "Heavy Rains")
	{
		return false;
	}

	# Some of the logic here has been lost due to cc_combat.ash
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
	if(monsterName == "gaudy pirate")
	{
		mId = 633;
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
	if((item_amount($item[Talisman O\' Namsilat]) == 1) && (monsterName == "gaudy pirate"))
	{
		#already have the goal, don't summon
		return false;
	}
	if((item_amount($item[gaudy key]) >= 2) && (monsterName == "gaudy pirate"))
	{
		#already have the subgoal, don't summon
		return false;
	}
	if((item_amount($item[gaudy key]) == 1) && (monsterName == "gaudy pirate"))
	{
		#stops copying me!!
		copy = false;
		wink = false;
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
	if((item_amount($item[white pixel]) >= 29) && (monsterName == "ghost"))
	{
		#already have the subgoal, don't summon
		return false;
	}
	if(((get_property("cc_gunpowder") == "done") || (item_amount($item[barrel of gunpowder]) >= 5)) && (monsterName == "lobsterfrogman"))
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
			set_property("cc_ninjasnowmanassassin", "1");
			#already have all ninja gear
			return false;
		}
		if(count == 2)
		{
			set_property("cc_ninjasnowmanassassin", "1");
			copy = false;
		}
		wink = false;
	}

	if(monsterName == "orcish frat boy spy")
	{
		set_property("cc_orcishfratboyspy", "done");
		if((item_amount($item[beer helmet]) > 0) || (item_amount($item[bejeweled pledge pin]) > 0) || (item_amount($item[distressed denim pants]) > 0))
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


	if((get_property("_raindohCopiesMade") == "5") || (item_amount($item[Rain-doh box full of monster]) > 0))
	{
		copy = false;
	}

	set_property("choiceAdventure970", "0");

	if(get_property("cc_100familiar").to_boolean())
	{
		wink = false;
	}
	else
	{
		if(have_familiar($familiar[Adventurous Spelunker]))
		{
			use_familiar($familiar[Adventurous Spelunker]);
		}
		else if(have_familiar($familiar[Angry Jung Man]))
		{
			use_familiar($familiar[Angry Jung Man]);
		}
		else if(have_familiar($familiar[Piano Cat]))
		{
			use_familiar($familiar[Piano Cat]);
		}

	}

	if(wink == true)
	{
		if(get_property("_badlyRomanticArrows") == "1")
		{
			abort("Trying to arrow/wink a monster but we've already done so today.");
		}
		use_familiar($familiar[Reanimated Reanimator]);
#		handleFamiliar($familiar[Reanimated Reanimator]);
	}

	if(copy)
	{
		set_property("cc_doCombatCopy", "yes");
	}
	print("Looking to summon: " + monsterName, "blue");

	visit_url("runskillz.php?pwd&action=Skillz&whichskill=16011&quantity=1", true);
	visit_url("choice.php?pwd&whichchoice=970&whichmonster=" + mId + "&option=1&choice2=and+Fight%21");
	adv1($location[Noob Cave], 1, "cc_combatHandler");

	if(wink == true)
	{
		if(have_familiar($familiar[Adventurous Spelunker]))
		{
			use_familiar($familiar[Adventurous Spelunker]);
		}
		else if(have_familiar($familiar[Angry Jung Man]))
		{
			use_familiar($familiar[Angry Jung Man]);
		}
		else
		{
			use_familiar($familiar[Piano Cat]);
		}
	}
	if(copy && (item_amount($item[Rain-doh box full of monster]) == 0))
	{
		abort("Tried to make a copy but failed");
	}

	return true;
}
