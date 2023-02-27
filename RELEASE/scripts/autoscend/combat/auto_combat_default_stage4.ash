string auto_combatDefaultStage4(int round, monster enemy, string text)
{
	// stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	string retval;
	
	// Path = The Source
	retval = auto_combatTheSourceStage4(round, enemy, text);
	if(retval != "") return retval;
	
	// Path = license to adventure
	retval = auto_combatLicenseToAdventureStage4(round, enemy, text);
	if(retval != "") return retval;

	// Path = The Source
	retval = auto_combatZombieSlayerStage4(round, enemy, text);
	if(retval != "") return retval;
	
	//sniffers are skills that increase the odds of encountering this same monster again in the current zone.
	if(auto_wantToSniff(enemy, my_location()))
	{
		skill sniffer = getSniffer(enemy);
		if(sniffer != $skill[none])
		{
			if(sniffer == $skill[Perceive Soul])		//mafia does not track the target of this skill so we must do so.
			{
				set_property("auto_bat_soulmonster", enemy);
			}
			handleTracker(enemy, sniffer, "auto_sniffs");
			combat_status_add("sniffed");
			return useSkill(sniffer);
		}
	}
	
	if(enemy == $monster[animated ornate nightstand] && my_familiar() == $familiar[Nosy Nose] && !is100FamRun() && 
	canUse($skill[Get a Good Whiff of This Guy]) && !isSniffed(enemy,$skill[Get a Good Whiff of This Guy]))
	{
		//this is a special case, if Nosy Nose is used in the bedroom in a non 100 fam run it is to whiff this monster
		//and use only this sniffer because the elegant monster must be found next and this one gets turned off easily by using a different familiar
		handleTracker(enemy, $skill[Get a Good Whiff of This Guy], "auto_sniffs");
		return useSkill($skill[Get a Good Whiff of This Guy]);
	}
	
	//TODO auto_doCombatCopy property is silly. get rid of it
	if(!haveUsed($item[Rain-Doh black box]) && (!in_heavyrains()) && (get_property("_raindohCopiesMade").to_int() < 5))
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
		boolean shouldFlyer = false;
		boolean staggeringFlyer = false;
		item flyerWith;
		if(my_class() == $class[Disco Bandit] && auto_have_skill($skill[Deft Hands]) && !combat_status_check("(it"))
		{
			//first item throw in the fight staggers
			staggeringFlyer = true;
		}
		if(auto_have_skill($skill[Ambidextrous Funkslinging]))
		{
			if (canUse($item[Time-Spinner]))
			{
				flyerWith = $item[Time-Spinner];
				staggeringFlyer = true;
			}
			else if (canUse($item[beehive]))
			{
				if(my_class() == $class[Sauceror] && haveUsed($skill[Curse Of Weaksauce]))
				{
					//don't miss MP by killing weak monsters with beehive
					int beehiveDamage = ceil(30*combatItemDamageMultiplier()*MLDamageToMonsterMultiplier());
					if(monster_hp() > beehiveDamage)
					{
						flyerWith = $item[beehive];
						staggeringFlyer = true;
					}
				}
				else
				{
					flyerWith = $item[beehive];
					staggeringFlyer = true;
				}
			}
		}
		if(staggeringFlyer && (!stunnable(enemy) || monster_level_adjustment() > 150))
		{
			staggeringFlyer = false;
		}
		boolean stunned;
		if(!staggeringFlyer && stunnable(enemy))
		{
			skill stunner = getStunner(enemy);
			stunned = combat_status_check("stunned");
			if(stunner != $skill[none] && !stunned)
			{
				combat_status_add("stunned");
				return useSkill(stunner);
			}
		}
		if(canSurvive(3.0) || stunned || staggeringFlyer)
		{
			shouldFlyer = true;
		}
		if(shouldFlyer)
		{
			if(flyerWith != $item[none])
			{
				return useItems(flyer, flyerWith);
			}
			else
			{
				return useItem(flyer);
			}
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
	// consumeStuff fills liver first up to 10 or 15 before eating, pending if billiards room if completed. Gives confidence that we will eat within 100 turns.
	boolean billiards_check = my_inebriety() >= 10 || !can_drink() || hasSpookyravenLibraryKey();
	if(canUse($item[red rocket]) && have_effect($effect[Everything Looks Red]) <= 0 && have_effect($effect[Ready to Eat]) <= 0 && canSurvive(5.0) && my_adventures() < 100 && billiards_check)
	{
		if(in_plumber())
		{
			return useItem($item[red rocket]);
		}
		//use if next food is large in size. Currently autoConsume doesn't analyze stat gain, which would be better
		//disabled until fix: https://github.com/Loathing-Associates-Scripting-Society/autoscend/issues/1053
		//item simulationOutput = auto_autoConsumeOneSimulation("eat");
		//if (simulationOutput != $item[none] && simulationOutput.fullness > 3)
		//{
			return useItem($item[red rocket]);
		//}
	}

	// use cosmic bowling ball iotm
	if(auto_bowlingBallCombatString(my_location(), true) != "")
	{
		return auto_bowlingBallCombatString(my_location(), false);
	}

	// prep parka NC forcing if requested
	if(canUse($skill[Launch spikolodon spikes]) && get_property("auto_forceNonCombatSource") == "jurassic parka"
		&& !get_property("auto_parkaSpikesDeployed").to_boolean())
	{
		set_property("auto_parkaSpikesDeployed", true);
		return useSkill($skill[Launch spikolodon spikes]);
	}
	
	return "";
}
