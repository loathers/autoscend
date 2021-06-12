string auto_combatDefaultStage3(int round, monster enemy, string text)
{
	##stage 3 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	
	//TODO auto_doCombatCopy property is silly. get rid of it
	if(!haveUsed($item[Rain-Doh black box]) && (my_path() != "Heavy Rains") && (get_property("_raindohCopiesMade").to_int() < 5))
	{
		if((enemy == $monster[Modern Zmobie]) && (get_property("auto_modernzmobiecount").to_int() < 3))
		{
			set_property("auto_doCombatCopy", "yes");
		}
	}
	if(canUse($item[Rain-Doh black box]) && (get_property("auto_doCombatCopy") == "yes") && (enemy != $monster[gourmet gourami]))
	{
		set_property("auto_doCombatCopy", "no");
		markAsUsed($item[Rain-Doh black box]); // mark even if not used so we don't spam the error message
		if(get_property("_raindohCopiesMade").to_int() < 5)
		{
			handleTracker(enemy, $item[Rain-Doh black box], "auto_copies");
			return "item " + $item[Rain-Doh black box];
		}
		auto_log_warning("Can not issue copy directive because we have no copies left", "red");
	}
	if(get_property("auto_doCombatCopy") == "yes")
	{
		set_property("auto_doCombatCopy", "no");
	}
	
	//get 1 additional [fat loot token] per day
	if(my_location() == $location[The Daily Dungeon])
	{
		# If we are in The Daily Dungeon, assume we get 1 token, so only if we need more than 1.
		if((towerKeyCount(false) < 2) && !get_property("_dailyDungeonMalwareUsed").to_boolean() && (item_amount($item[Daily Dungeon Malware]) > 0))
		{
			if($monsters[Apathetic Lizardman, Dairy Ooze, Dodecapede, Giant Giant Moth, Mayonnaise Wasp, Pencil Golem, Sabre-Toothed Lime, Tonic Water Elemental, Vampire Clam] contains enemy)
			{
				return "item " + $item[Daily Dungeon Malware];
			}
		}
	}
	
	//accordion thief mechanic. unlike pickpocket it can be done at any round
	if(canUse($skill[Steal Accordion]) && (my_class() == $class[Accordion Thief]) && canSurvive(2.0))
	{
		return useSkill($skill[Steal Accordion]);
	}
	
	//in [The Deep Machine Tunnels] will stagger enemy and grants another abstraction
	if(canUse($item[Abstraction: Sensation]) && (enemy == $monster[Performer of Actions]))
	{
		#	Change +100% Moxie to +100% Init
		return useItem($item[Abstraction: Sensation]);
	}
	if(canUse($item[Abstraction: Thought]) && (enemy == $monster[Perceiver of Sensations]))
	{
		# Change +100% Myst to +100% Items
		return useItem($item[Abstraction: Thought]);
	}
	if(canUse($item[Abstraction: Action]) && (enemy == $monster[Thinker of Thoughts]))
	{
		# Change +100% Muscle to +10 Familiar Weight
		return useItem($item[Abstraction: Action]);
	}
	
	//stocking mimic can produce meat until round 10.
	if((my_familiar() == $familiar[Stocking Mimic]) && (round < 12) && canSurvive(1.5))
	{
		if (item_amount($item[Seal Tooth]) > 0)
		{
			return "item " + $item[Seal Tooth];
		}
	}
	
	//nanorhino familiar stuff
	#Do not accidentally charge the nanorhino with a non-banisher
	if(my_familiar() == $familiar[Nanorhino] && have_effect($effect[Nanobrawny]) == 0)
	{
		foreach it in $skills[Toss, Clobber, Shell Up, Lunge Smack, Thrust-Smack, Headbutt, Kneebutt, Lunging Thrust-Smack, Club Foot, Shieldbutt, Spirit Snap, Cavalcade Of Fury, Northern Explosion, Spectral Snapper, Harpoon!, Summon Leviatuga]
		{
			if((it == $skill[Shieldbutt]) && !hasShieldEquipped())
			{
				continue;
			}
			if(canUse(it, false))
			{
				return useSkill(it, false);
			}
		}
	}
	if(canUse($skill[Unleash Nanites]) && (have_effect($effect[Nanobrawny]) >= 40))
	{
		#if appropriate enemy, then banish
		if(enemy == $monster[Pygmy Janitor])
		{
			return useSkill($skill[Unleash Nanites]);
		}
	}

	//winking is a monster copier familiar skill. they share a daily counter
	skill wink_skill = $skill[none];
	if(canUse($skill[Wink At]))
	{
		wink_skill = $skill[Wink At];
	}
	if(canUse($skill[Fire a badly romantic arrow]))
	{
		wink_skill = $skill[Fire a badly romantic arrow];
	}
	if(wink_skill != $skill[none])		//we can wink / romatic arrow
	{
		if($monsters[Lobsterfrogman, Modern Zmobie, Ninja Snowman Assassin] contains enemy)
		{
			if(enemy == $monster[modern zmobie])
			{
				set_property("auto_waitingArrowAlcove", get_property("cyrptAlcoveEvilness").to_int() - 20);
			}
			return useSkill(wink_skill);
		}
	}
	
	//[Conspiracy Island] iotm specific. clip the fingernails of [One of Doctor Weirdeaux's creations]
	int fingernailClippersLeft = get_property("auto_combatHandlerFingernailClippers").to_int();
	if(fingernailClippersLeft > 0)
	{
		fingernailClippersLeft = fingernailClippersLeft - 1;
		if(fingernailClippersLeft == 0)
		{
			markAsUsed($item[military-grade fingernail clippers]);
		}
		set_property("auto_combatHandlerFingernailClippers", "" + fingernailClippersLeft);
		return "item " + $item[military-grade fingernail clippers];
	}

	if((item_amount($item[military-grade fingernail clippers]) > 0)  && (enemy == $monster[one of Doctor Weirdeaux\'s creations]))
	{
		if(!haveUsed($item[military-grade fingernail clippers]))
		{
			fingernailClippersLeft = 3;
			set_property("auto_combatHandlerFingernailClippers", "3");
		}
	}
	
	//use latte iotm to restore 50% of max MP
	if((!in_zelda() && my_class() != $class[Vampyre] && my_path() != "Zombie Slayer") &&	//paths that do not use MP
	canUse($skill[Gulp Latte]) &&
	my_mp() * 2 < my_maxmp())		//gulp latte restores 50% of your MP. do not waste it.
	{
		return useSkill($skill[Gulp Latte]);
	}
	
	return "";
}
