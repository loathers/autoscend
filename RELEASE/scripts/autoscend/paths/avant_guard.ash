boolean in_avantGuard()
{
	return my_path() == $path[Avant Guard];
}

void ag_initializeSettings()
{
	if (in_avantGuard())
	{
		if (!auto_have_familiar($familiar[Burly Bodyguard]) && item_amount($item[baby bodyguard]) > 0) {
			// Add the familiar to the terrarium since we need it to do anything in this path.
			// No I don't care about that guy who never binds familiars for <reasons>. He can write & maintain his own ascension script.
			visit_url("inv_familiar.php?pwd=&which=3&whichitem=11631");
		}
		set_property("auto_skipUnlockGuild", true);
		set_property("auto_nonAdvLoc", false);
		if(auto_turbo())
		{
			set_property("auto_skipNuns", "true");
		}
	}
}

void ag_pulls()
{
	if (in_avantGuard())
	{
		if(auto_is_valid($item[waffle]) && auto_haveAugustScepter() && !(auto_turbo())) //Only want waffles if we can summon them and not going for a 1 day
		{
			pullXWhenHaveY($item[waffle],1,(my_daycount() - 1) * (3 + (my_daycount() > 1 ? 1 : 0))); //pull waffles everyday
		}
	}
}

void ag_bgChat()
{
	if (!in_avantGuard())
	{
		return;
	}

	if (ag_bgToChat() == $monster[none])
	{
		return;
	}

	// go to page to determine if bodyguard is ready to chat
	string bgChat = visit_url("main.php?talktobg=1", false);
	matcher title = create_matcher("Chatting with your Burly Bodyguard", bgChat);
	if(title.find())
	{
		auto_log_info("Trying to chat with your Bodyguard", "blue");
		monster mon = ag_bgToChat();
		string url = visit_url("choice.php?pwd=&whichchoice=1532&option=1&bgid=" + mon.id, true);
		auto_log_info("Making the next bodyguard a " + mon.to_string(), "blue");
		handleTracker($familiar[Burly Bodyguard], mon.to_string(), "auto_copies");
	}
	return;
}

monster ag_bgToChat()
{
	int surgeonGearWanted;
	monster mon = $monster[none];

	foreach it in $items[bloodied surgical dungarees,half-size scalpel,surgical apron,head mirror,surgical mask]
	{
		if(!possessEquipment(it) && auto_can_equip(it))
		{
			surgeonGearWanted += 1;
		}
	}
	if(item_amount($item[Wet Stunt Nut Stew]) == 0 && !(internalQuestStatus("questL11Palindome") > 4))
	{
		if(item_amount($item[Bird Rib]) == 0)
		{
			mon = $monster[whitesnake];
		}
		else if(item_amount($item[Lion Oil]) == 0)
		{
			mon = $monster[White Lion];
		}
	}
	else if(needStarKey() && item_amount($item[star]) < 8 && item_amount($item[line]) < 7)
	{
		if(my_ascensions() % 2 == 1)
		{
			mon = $monster[Skinflute];
		}
		else
		{
			mon = $monster[Camel\'s Toe];
		}
	}
	else if(needStarKey() && item_amount($item[Star chart]) < 1)
	{
		mon = $monster[Astronomer];
	}
	else if(item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 2 && !auto_haveBatWings())
	{
		mon = $monster[beanbat];
	}
	else if(item_amount($item[molybdenum magnet]) > 0 && get_property("sidequestJunkyardCompleted") == "none")
	{
		if(item_amount($item[molybdenum hammer]) == 0)
		{
			mon = $monster[batwinged gremlin (tool)];
		}
		if(item_amount($item[molybdenum crescent wrench]) == 0)
		{
			mon = $monster[erudite gremlin (tool)];
		}
		if(item_amount($item[molybdenum pliers]) == 0)
		{
			mon = $monster[spider gremlin (tool)];
		}
		if(item_amount($item[molybdenum screwdriver]) == 0)
		{
			mon = $monster[vegetable gremlin (tool)];
		}
	}
	else if((item_amount($item[McClusky file (complete)]) == 0 && item_amount($item[McClusky file (page 5)]) == 0) && get_property("hiddenOfficeProgress").to_int() < 6)
	{
		mon = $monster[pygmy witch accountant];
	}
	else if(surgeonGearWanted > 0 && internalQuestStatus("questL11Doctor") < 2)
	{
		mon = $monster[pygmy witch surgeon];
	}
	else if(needOre())
	{
		mon = $monster[Mountain man];
	}
	else if(item_amount($item[drum machine]) == 0 && get_property("questL11Desert") != "finished")
	{
		mon = $monster[blur];
	}
	else if(hedgeTrimmersNeeded() > 0)
	{
		mon = $monster[bearpig topiary animal];
	}
	else if(!possessEquipment($item[Unstable Fulminate]) && internalQuestStatus("questL11Manor") < 3)
	{
		if(item_amount($item[bottle of Chateau de Vinegar]) == 0)
		{
			mon = $monster[possessed wine rack];
		}
		else if(item_amount($item[blasting soda]) == 0)
		{
			mon = $monster[cabinet of Dr. Limpieza];
		}
	}
	else if((item_amount($item[Crumbling Wooden Wheel]) + item_amount($item[Tomb Ratchet])) < 10 && !get_property("pyramidBombUsed").to_boolean())
	{
		mon = $monster[tomb rat];
	}
	else if((!possessEquipment($item[Lord Spookyraven\'s Spectacles]) && internalQuestStatus("questL11Manor") < 2) || (item_amount($item[disposable instant camera]) == 0 && internalQuestStatus("questL11Palindome") < 1))
	{
		mon = $monster[animated ornate nightstand];
	}
	else if(!have_outfit("Knob Goblin Harem Girl Disguise") && get_property("questL05Goblin") != "finished")
	{
		mon = $monster[Knob Goblin Harem Girl];
	}
	else if(item_amount($item[Goat Cheese]) < 3 && internalQuestStatus("questL08Trapper") < 2)
	{
		mon = $monster[Dairy Goat];
	}
	else if(item_amount($item[bowling ball]) < 5 && internalQuestStatus("hiddenBowlingAlleyProgress") < 5)
	{
		mon = $monster[pygmy bowler];
	}
	else if(internalQuestStatus("questL12War") == 1 && !get_property("auto_hippyInstead").to_boolean())
	{
		mon = $monster[Green Ops Soldier];
	}
	else if(!get_property("auto_hippyInstead").to_boolean() && !have_outfit("frat warrior fatigures") && internalQuestStatus("questL12War") < 1)
	{
		{
			mon = $monster[War Frat 151st Infantryman];
		}
	}
	else if(get_property("auto_hippyInstead").to_boolean() && !have_outfit("war hippy fatigues") && internalQuestStatus("questL12War") < 1)
	{
		{
			mon = $monster[War Hippy Airborne Commander];
		}
	}
	
	return mon;
}

boolean LM_avantGuard()
{
	if (!in_avantGuard())
	{
		return false;
	}

	if (LX_summonMonster() || L3_tavern() || L5_goblinKing() || L7_crypt() || L8_trapperGroar() || L11_defeatEd())
	{
		// functions which spend adventures in non-adv.php locations.
		// Do these with high priority so we get the cubeling drops in HC and/or farm consumables with CBB/Mini Kiwi
		// these require auto_nonAdvLoc to be set appropriately before adventuring.
		// TODO: separate out Bonerdagon handling from L7_crypt()
		return true;
	}

	return false;
}

boolean ag_is_bodyguard()
{
	if(contains_text(get_property("lastEncounter"), "bodyguard to"))
	{
		return true;
	}

	return false;
}