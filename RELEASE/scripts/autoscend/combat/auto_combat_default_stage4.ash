string auto_combatDefaultStage4(int round, monster enemy, string text)
{
	// stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	string retval;
	string combatState = get_property("auto_combatHandler");
	
	// Path = The Source
	retval = auto_combatTheSourceStage4(round, enemy, text);
	if(retval != "") return retval;
	
	// Path = license to adventure
	retval = auto_combatLicenseToAdventureStage4(round, enemy, text);
	if(retval != "") return retval;

	if (!auto_hasPendingCopy(enemy) && auto_wantToCopy(enemy, my_location()))
	{
		int rainPuttyMade = get_property("spookyPuttyCopiesMade").to_int() + get_property("_raindohCopiesMade").to_int();
		// TODO: remaining bugbears
		if(in_bugbear() && canUse($item[crayon shavings]) && bugbear_IsWanderer(enemy))
		{
			handleTracker(enemy, $item[crayon shavings], "auto_copies");
			return "item " + $item[crayon shavings];
		}
		else if(canUse($item[spooky putty sheet]) && auto_spookyPuttyCanCopy())
		{
			handleTracker(enemy, $item[spooky putty sheet], "auto_copies");
			return "item " + $item[spooky putty sheet];
		}
		else if(canUse($item[Rain-Doh black box]) && auto_rainDohCanCopy())
		{
			handleTracker(enemy, $item[Rain-Doh black box], "auto_copies");
			return "item " + $item[Rain-Doh black box];
		}
		else if(canUse($item[4-D Camera]) && !get_property("_cameraUsed").to_boolean())
		{
			handleTracker(enemy, $item[4-D Camera], "auto_copies");
			return "item " + $item[4-D Camera];
		}
		else if(canUse($item[ice sculpture]) && !get_property("_iceSculptureUsed").to_boolean())
		{
			handleTracker(enemy, $item[ice sculpture], "auto_copies");
			return "item " + $item[ice sculpture];
		}
		else if(canUse($item[print screen button]))
		{
			handleTracker(enemy, $item[print screen button], "auto_copies");
			return "item " + $item[print screen button];
		}
		else if(canUse($skill[Digitize]) && (get_property("_sourceTerminalDigitizeUses").to_int() == 0))
		{
			handleTracker(enemy, $skill[Digitize], "auto_copies");
			return useSkill($skill[Digitize]);
		}
		// Duplicate needs special handling (no assassins)
		else if (!($monsters[ninja snowman assassin] contains enemy) && !bugbear_IsWanderer(enemy))
		{
			if (canUse($skill[Duplicate]) && get_property("_sourceTerminalDuplicateUses").to_int() == 0)
			{
				handleTracker(enemy, $skill[Duplicate], "auto_copies");
				return useSkill($skill[Duplicate]);
			}
		}
	}

	if (canUse($skill[Feel Nostalgic]) && auto_canFeelNostalgic(enemy))
	{
		monster lastCopyableMonster = get_property("lastCopyableMonster").to_monster();
		if (!auto_hasPendingCopy(lastCopyableMonster) && auto_wantToCopy(lastCopyableMonster, my_location()))
		{
			handleTracker(enemy, $skill[Feel Nostalgic], "auto_copies");
			return useSkill($skill[Feel Nostalgic]);
		}
	}

	//olfaction is used to spawn 2 more copies of the target at current location.
	//as well as eliminate the special rule that reduces the odds of encountering the same enemy twice in a row.
	if(!auto_hasPendingCopy(enemy) && auto_wantToSniff(enemy, my_location()))
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
	//kol tracks each band flyering separately. mafia tracks them in a singular property as it assumes the player will not flyer for the wrong band. make sure to only flyer for the side we want to flyer for
	item flyer = $item[Rock Band Flyers];
	if(auto_warSide() == "hippy")
	{
		flyer = $item[Jam Band Flyers];
	}
	if(canUse(flyer) && get_property("flyeredML").to_int() < 10000 && my_location() != $location[The Battlefield (Frat Uniform)] && my_location() != $location[The Battlefield (Hippy Uniform)] && !get_property("auto_ignoreFlyer").to_boolean())
	{
		skill stunner = getStunner(enemy);
		boolean stunned = contains_text(combatState, "stunned");
		if(stunner != $skill[none] && !stunned)
		{
			set_property("auto_combatHandler", get_property("auto_combatHandler")+",stunned");
			return useSkill(stunner);
		}
		if(canUse($item[Time-Spinner]) && auto_have_skill($skill[Ambidextrous Funkslinging]))
		{
			return useItems(flyer, $item[Time-Spinner]);
		}
		if(canSurvive(3.0) || stunned)
		{
			return useItem(flyer);
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
	if((!in_plumber() && !in_darkGyffte() && !in_zombieSlayer()) &&	//paths that do not use MP
	canUse($skill[Gulp Latte]) &&
	my_mp() * 2 < my_maxmp())		//gulp latte restores 50% of your MP. do not waste it.
	{
		return useSkill($skill[Gulp Latte]);
	}

	//stinkbug physically resistant monsters
	if(!(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy)))
	{
		if(canUse($skill[Summon Love Stinkbug]) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
	}

	// use red rocket from Clan VIP Lounge to get 5x stats from next food item consumed. Does not stagger on use
	if(canUse($item[red rocket]) && have_effect($effect[Everything Looks Red]) <= 0 && have_effect($effect[Ready to Eat]) <= 0 && canSurvive(5.0) &&
		// consumeStuff fills liver first up to 10 or 15 before eating, pending if billiards room if completed. Gives confidence that we will eat within 100 turns.
		my_inebriety() >= 10 && my_adventures() < 100)
	{
		//use if next food is large in size. Currently autoConsume doesn't analyze stat gain, which would be better
		item simulationOutput = auto_autoConsumeOneSimulation("eat");
		if (simulationOutput != $item[none] && simulationOutput.fullness > 3)
		{
			return useItem($item[red rocket]);
		}
		
	}
	
	return "";
}
