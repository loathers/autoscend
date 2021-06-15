string auto_combatDefaultStage4(int round, monster enemy, string text)
{
	##stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	string retval;
	
	#Path = The Source
	retval = auto_combatTheSourceStage4(round, enemy, text);
	if(retval != "") return retval;
	
	//olfaction is used to spawn 2 more copies of the target at current location.
	//as well as eliminate the special rule that reduces the odds of encountering the same enemy twice in a row.
	if(auto_wantToSniff(enemy, my_location()))
	{
		if(canUse($skill[Transcendent Olfaction]) && (have_effect($effect[On The Trail]) == 0))
		{
			handleTracker(enemy, $skill[Transcendent Olfaction], "auto_sniffs");
			return useSkill($skill[Transcendent Olfaction]);
		}

		if(canUse($skill[Make Friends]) && get_property("makeFriendsMonster") != enemy && my_audience() >= 20)
		{
			handleTracker(enemy, $skill[Make Friends], "auto_sniffs");
			return useSkill($skill[Make Friends]);
		}

		if(!contains_text(get_property("longConMonster"), enemy) && canUse($skill[Long Con]) && (get_property("_longConUsed").to_int() < 5))
		{
			handleTracker(enemy, $skill[Long Con], "auto_sniffs");
			return useSkill($skill[Long Con]);
		}

		if(canUse($skill[Perceive Soul]) && enemy != get_property("auto_bat_soulmonster").to_monster())
		{
			handleTracker(enemy, $skill[Perceive Soul], "auto_sniffs");
			set_property("auto_bat_soulmonster", enemy);
			return useSkill($skill[Perceive Soul]);
		}

		if(canUse($skill[Gallapagosian Mating Call]) && enemy != get_property("_gallapagosMonster").to_monster())
		{
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "auto_sniffs");
			return useSkill($skill[Gallapagosian Mating Call]);
		}

		if(canUse($skill[Offer Latte to Opponent]) && enemy != get_property("_latteMonster").to_monster() && !get_property("_latteCopyUsed").to_boolean())
		{
			handleTracker(enemy, $skill[Offer Latte to Opponent], "auto_sniffs");
			return useSkill($skill[Offer Latte to Opponent]);
		}
	}
	
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
	
	//iotm monster copier that works by creating wandering copies of the targetted monster
	if(canUse($skill[Digitize]) && (get_property("_sourceTerminalDigitizeUses").to_int() == 0) && !inAftercore())
	{
		if($monsters[Ninja Snowman Assassin, Lobsterfrogman] contains enemy)
		{
			if(get_property("_sourceTerminalDigitizeMonster") != enemy)
			{
				handleTracker(enemy, $skill[Digitize], "auto_copies");
				return useSkill($skill[Digitize]);
			}
		}
	}
	if(canUse($skill[Digitize]) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3) && !inAftercore())
	{
		if(get_property("auto_digitizeDirective") == enemy)
		{
			if(get_property("_sourceTerminalDigitizeMonster") != enemy)
			{
				handleTracker(enemy, $skill[Digitize], "auto_copies");
				return useSkill($skill[Digitize]);
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
	
	//insults are used as part of the pirates quest
	if(canUse($item[The Big Book of Pirate Insults]) && (numPirateInsults() < 8) && (internalQuestStatus("questM12Pirate") < 5))
	{
		// this should only be applicable in Low-Key Summer (for now)
		if ($locations[Barrrney\'s Barrr, The Obligatory Pirate\'s Cove] contains my_location())
		{
			return useItem($item[The Big Book Of Pirate Insults]);
		}
	}
	
	//cocktail napkin can banish clingy pirates (only them and no other monster). this accelerates the pirates quest
	if(item_amount($item[Cocktail Napkin]) > 0)
	{
		if($monsters[Clingy Pirate (Female), Clingy Pirate (Male)] contains enemy)
		{
			return "item " + $item[Cocktail Napkin];
		}
	}
	
	//this completes the quest Advertise for the Mysterious Island Arena which is a sidequest which accelerates the L12 frat-hippy war quest
	if((canUse($item[Rock Band Flyers]) || canUse($item[Jam Band Flyers])) && (my_location() != $location[The Battlefield (Frat Uniform)]) && (my_location() != $location[The Battlefield (Hippy Uniform)]) && !get_property("auto_ignoreFlyer").to_boolean())
	{
		string stall = getStallString(enemy);
		if(stall != "")
		{
			return stall;
		}

		if(canUse($item[Rock Band Flyers]) && (get_property("flyeredML").to_int() < 10000))
		{
			if(canUse($item[Time-Spinner]) && auto_have_skill($skill[Ambidextrous Funkslinging]))
			{
				return useItems($item[Rock Band Flyers], $item[Time-Spinner]);
			}
			return useItem($item[Rock Band Flyers]);
		}
		if(canUse($item[Jam Band Flyers]) && (get_property("flyeredML").to_int() < 10000))
		{
			if(canUse($item[Time-Spinner]) && auto_have_skill($skill[Ambidextrous Funkslinging]))
			{
				return useItems($item[Jam Band Flyers], $item[Time-Spinner]);
			}
			return useItem($item[Jam Band Flyers]);
		}
	}
	
	//chaos butterfly if thrown in combat once per ascension will accelerate the dooks farm sidequest for the frat-hippy war.
	if(canUse($item[chaos butterfly]) && !get_property("chaosButterflyThrown").to_boolean() && !get_property("auto_skipL12Farm").to_boolean())
	{
		if(canUse($item[Time-Spinner]) && auto_have_skill($skill[Ambidextrous Funkslinging]))
		{
			return useItems($item[chaos butterfly], $item[Time-Spinner]);
		}
		return useItem($item[chaos butterfly]);
	}
	
	//accelerate palindrome quest
	if(canUse($item[Disposable Instant Camera]))
	{
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			return useItem($item[Disposable Instant Camera]);
		}
	}
	
	//accelerate oil peak in highlands quest
	if(item_amount($item[Duskwalker Syringe]) > 0)
	{
		if($monsters[Oil Baron, Oil Cartel, Oil Slick, Oil Tycoon] contains enemy)
		{
			return "item " + $item[Duskwalker Syringe];
		}
	}
	
	//used by [Little Geneticist DNA-Splicing Lab] iotm
	if(canUse($item[DNA extraction syringe]) && monster_level_adjustment() < 150)
	{
		if(monster_phylum(enemy) != to_phylum(get_property("dnaSyringe")))
		{
			return useItem($item[DNA extraction syringe]);
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
