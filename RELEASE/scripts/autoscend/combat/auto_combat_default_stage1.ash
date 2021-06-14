string auto_combatDefaultStage1(int round, monster enemy, string text)
{
	##stage 1 = 1st round actions: puzzle boss, pickpocket, banish, escape, instakill, etc. things that need to be done before delevel
	string retval;
	
	#Path = Heavy Rains
	retval = auto_combatHeavyRainsStage1(round, enemy, text);
	if(retval != "") return retval;
	
	#Path = The Source
	retval = auto_combatTheSourceStage1(round, enemy, text);
	if(retval != "") return retval;
	
	#Path = Kingdom of Exploathing
	retval = auto_combatExploathingStage1(round, enemy, text);
	if(retval != "") return retval;
	
	#Path = Avatar of Sneaky Pete
	retval = auto_combatPeteStage1(round, enemy, text);
	if(retval != "") return retval;
	
	#Path = Beest Hate You
	retval = auto_combatBHYStage1(round, enemy, text);
	if(retval != "") return retval;
	
	string combatState = get_property("auto_combatHandler");
	
	if(enemy == $monster[Your Shadow])
	{
		if(in_zelda())
		{
			if(item_amount($item[super deluxe mushroom]) > 0)
			{
				return "item " + $item[super deluxe mushroom];
			}
			abort("Oh no, I don't have any super deluxe mushrooms to deal with this shadow plumber :(");
		}
		boolean ambi = auto_have_skill($skill[Ambidextrous Funkslinging]);
		item hand_1 = $item[none];
		item hand_2 = $item[none];
		item icup = $item[Rain-Doh Indigo Cup];		//restore 20% of max HP. only once per combat
		if(canUse(icup))
		{
			if(my_maxhp() > 500 && hand_1 == $item[none])
			{
				markAsUsed(icup);
				hand_1 = icup;
			}
			else if(ambi && my_maxhp() > 250 && hand_1 == $item[none])
			{
				markAsUsed(icup);
				hand_1 = icup;
			}
		}
		//items which can be used multiple times per combat
		foreach it in $items[Gauze Garter, filthy Poultice, red pixel potion]
		{
			if(hand_1 == $item[none] && item_amount(it) > 0)
			{
				hand_1 = it;
			}
			if(hand_2 == $item[none])
			{
				if(item_amount(it) > 1)
				{
					hand_2 = it;
				}
				else if(item_amount(it) > 0 && hand_1 != it)
				{
					hand_2 = it;
				}
			}
		}
		
		if(ambi && hand_1 != $item[none] && hand_2 != $item[none])
		{
			return "item " +hand_1+ ", " +hand_2;
		}
		if(hand_1 != $item[none])
		{
			return "item " +hand_1;
		}
		abort("Uh oh, I ran out of healing items to use against your shadow");
	}

	if(enemy == $monster[Wall Of Meat])
	{
		if(canUse($skill[Make It Rain]))
		{
			return useSkill($skill[Make It Rain]);
		}
	}

	if(enemy == $monster[Wall Of Skin])
	{
		if(item_amount($item[Beehive]) > 0)
		{
			return "item " + $item[Beehive];
		}

		if(canUse($skill[Shell Up]) && (round >= 3))
		{
			return useSkill($skill[Shell Up]);
		}

		if(canUse($skill[Sauceshell]) && (round >= 4))
		{
			return useSkill($skill[Sauceshell]);
		}

		if(canUse($skill[Belch the Rainbow], false))
		{
			return useSkill($skill[Belch the Rainbow], false);
		}

		int sources = 0;
		foreach damage in $strings[Cold Damage, Hot Damage, Sleaze Damage, Spooky Damage, Stench Damage] {
			if(numeric_modifier(damage) > 0) {
				sources += 1;
			}
		}

		if (sources >= 4) {
			if(canUse($skill[Headbutt], false))
			{
				return useSkill($skill[Headbutt], false);
			}
			if(canUse($skill[Clobber], false))
			{
				return useSkill($skill[Clobber], false);
			}
		}
		return "attack with weapon";
	}

	if(enemy == $monster[Wall Of Bones])
	{
		if(item_amount($item[Electric Boning Knife]) > 0)
		{
			return "item " + $item[Electric Boning Knife];
		}
		if(((my_hp() * 4) < my_maxhp()) && (have_effect($effect[Takin\' It Greasy]) > 0))
		{
			return useSkill($skill[Unleash The Greash], false);
		}

		if(canUse($skill[Garbage Nova], false))
		{
			return useSkill($skill[Garbage Nova], false);
		}

		if(canUse($skill[Saucegeyser], false))
		{
			return useSkill($skill[Saucegeyser]);
		}
	}
	
	//pickpocket. do this after puzzle bosses but before escapes/instakills
	if(!contains_text(combatState, "pickpocket") && ($classes[Accordion Thief, Avatar of Sneaky Pete, Disco Bandit, Gelatinous Noob] contains my_class()) && contains_text(text, "value=\"Pick") && canSurvive(2.0))
	{
		boolean tryIt = false;
		foreach i, drop in item_drops_array(enemy)
		{
			if(drop.type == "0")
			{
				tryIt = true;
			}
			if((drop.rate > 0) && (drop.type != "n") && (drop.type != "c") && (drop.type != "b"))
			{
				tryIt = true;
			}
		}
		if(tryIt)
		{
			set_property("auto_combatHandler", combatState + "(pickpocket)");
			string attemptSteal = steal();
			return "pickpocket";
		}
	}
	
	//saber copy is different from other copies in that it comes with a free escape
	if(canUse($skill[Use the Force]) && (auto_saberChargesAvailable() > 0) && (enemy != auto_saberCurrentMonster()))
	{
		if(enemy == $monster[Blooper] && needDigitalKey())
		{
			handleTracker(enemy, $skill[Use the Force], "auto_copies");
			return auto_combatSaberCopy();
		}
	}
	
	//[Melodramedary] familiar skill which turns monster into a group of 2. Should be done before deleveling.
	if ($monsters[pygmy bowler, bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, red butler] contains enemy && canUse($skill[%fn\, spit on them!]))
	{
		handleTracker($skill[%fn\, spit on them!], enemy, "auto_otherstuff");
		return useSkill($skill[%fn\, spit on them!], true);
	}
	
	//duplicate turns the enemy from a single enemy into a mob containing 2 copies of this enemy. Doubling their stats and doubling their drops
	if(canUse($skill[Duplicate]) && (get_property("_sourceTerminalDuplicateUses").to_int() == 0) && !inAftercore() && (auto_my_path() != "Nuclear Autumn"))
	{
		if($monsters[Dairy Goat] contains enemy)
		{
			return useSkill($skill[Duplicate]);
		}
	}
	
	//these special conditions make it impossible to do anything but attack with weapon.
	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}
	if(have_equipped($item[Drunkula\'s Wineglass]))
	{
		return "attack with weapon";
	}
		
	//instakill enemies in [The Red Zeppelin]
	if(canUse($item[Glark Cable], true) && (my_location() == $location[The Red Zeppelin]) && (get_property("questL11Ron") == "step3") && (get_property("_glarkCableUses").to_int() < 5))
	{
		if($monsters[Man With The Red Buttons, Red Butler, Red Fox, Red Skeleton] contains enemy)
		{
			return useItem($item[Glark Cable]);
		}
	}
	
	//instakill enemies in [A Mob Of Zeppelin Protesters]
	if(canUse($item[Cigarette Lighter]) && (my_location() == $location[A Mob Of Zeppelin Protesters]) && (get_property("questL11Ron") == "step1"))
	{
		return useItems($item[Cigarette Lighter], $item[none]);
	}
	
	//instakill using [Power Pill] which is iotm familiar derivative
	if((get_property("auto_usePowerPill").to_boolean()) && (get_property("_powerPillUses").to_int() < 20) && instakillable(enemy))
	{
		if(item_amount($item[Power Pill]) > 0)
		{
			return "item " + $item[Power Pill];
		}
	}
	
	//instakill using [Pair of Stomping Boots] iotm familiar which will produce spleen consumables
	if((my_familiar() == $familiar[Pair of Stomping Boots]) && (get_property("_bootStomps").to_int()) < 7 && instakillable(enemy) && get_property("bootsCharged").to_boolean())
	{
		if(!($monsters[Dairy Goat, Lobsterfrogman, Writing Desk] contains enemy) && !($locations[The Laugh Floor, Infernal Rackets Backstage] contains my_location()) && canUse($skill[Release the boots]))
		{
			return useSkill($skill[Release the boots]);
		}
	}
	
	//yellowray instantly kills the enemy and makes them drop all items they can drop.
	if(!contains_text(combatState, "yellowray") && auto_wantToYellowRay(enemy, my_location()))
	{
		string combatAction = yellowRayCombatString(enemy, true);
		if(combatAction != "")
		{
			set_property("auto_combatHandler", combatState + "(yellowray)");
			if(index_of(combatAction, "skill") == 0)
			{
				handleTracker(enemy, to_skill(substring(combatAction, 6)), "auto_yellowRays");
			}
			else if(index_of(combatAction, "item") == 0)
			{
				handleTracker(enemy, to_item(substring(combatAction, 5)), "auto_yellowRays");
			}
			else
			{
				auto_log_warning("Unable to track yellow ray behavior: " + combatAction, "red");
			}
			if(combatAction == useSkill($skill[Asdon Martin: Missile Launcher], false))
			{
				set_property("_missileLauncherUsed", true);
			}
			return combatAction;
		}
		else
		{
			auto_log_warning("Wanted a yellow ray but we can not find one.", "red");
		}
	}

	//convert enemy into a helpless frog/newt/lizard
	if(get_property("auto_useCleesh").to_boolean())
	{
		if(canUse($skill[CLEESH]))
		{
			set_property("auto_useCleesh", false);
			return useSkill($skill[CLEESH]);
		}
	}
	
	//chance for a free runaway
	if((enemy == $monster[Plaid Ghost]) && (item_amount($item[T.U.R.D.S. Key]) > 0))
	{
		return "item " + $item[T.U.R.D.S. Key];
	}

	//free runaway against pygmies. accelerates hidden city quest
	if(item_amount($item[short writ of habeas corpus]) > 0 && canUse($item[short writ of habeas corpus]) && !inAftercore())
	{
		if($monsters[Pygmy Orderlies, Pygmy Witch Lawyer, Pygmy Witch Nurse] contains enemy)
		{
			return "item " + $item[Short Writ Of Habeas Corpus];
		}
	}
	
	//TODO use $item[Tattered Scrap Of Paper] as a free runaway.

	if(!contains_text(combatState, "banishercheck"))
	{
		string banishAction = banisherCombatString(enemy, my_location(), true);
		if(banishAction != "")
		{
			auto_log_info("Looking at banishAction: " + banishAction, "green");
			set_property("auto_combatHandler", combatState + "(banisher)");
			if(index_of(banishAction, "skill") == 0)
			{
				handleTracker(enemy, to_skill(substring(banishAction, 6)), "auto_banishes");
			}
			else if(index_of(banishAction, "item") == 0)
			{
				handleTracker(enemy, to_item(substring(banishAction, 5)), "auto_banishes");
			}
			else
			{
				auto_log_warning("Unable to track banisher behavior: " + banishAction, "red");
			}
			return banishAction;
		}
		set_property("auto_combatHandler", combatState + "(banishercheck)");
		combatState += "(banishercheck)";
	}

	if (!contains_text(combatState, "replacercheck") && canReplace(enemy) && auto_wantToReplace(enemy, my_location()))
	{
		string combatAction = replaceMonsterCombatString(enemy, true);
		if(combatAction != "")
		{
			set_property("auto_combatHandler", combatState + "(replacer)");
			if(index_of(combatAction, "skill") == 0)
			{
				if (to_skill(substring(combatAction, 6)) == $skill[CHEAT CODE: Replace Enemy])
				{
					handleTracker($skill[CHEAT CODE: Replace Enemy], "auto_powerfulglove");
				}
				handleTracker(enemy, to_skill(substring(combatAction, 6)), "auto_replaces");
			}
			else if(index_of(combatAction, "item") == 0)
			{
				handleTracker(enemy, to_item(substring(combatAction, 5)), "auto_replaces");
			}
			else
			{
				auto_log_warning("Unable to track replacer behavior: " + combatAction, "red");
			}
			return combatAction;
		}
		else
		{
			auto_log_warning("Wanted a replacer but we can not find one.", "red");
		}
		set_property("auto_combatHandler", combatState + "(replacercheck)");
		combatState += "(replacercheck)";
	}
	
	//convert enemy [Tomb rat] into [Tomb rat king]
	if((enemy == $monster[Tomb Rat]) && (item_amount($item[Tangle Of Rat Tails]) > 0))
	{
		if((item_amount($item[Tomb Ratchet]) + item_amount($item[Crumbling Wooden Wheel])) < 10)
		{
			string res = "item " + $item[Tangle of Rat Tails];
			if(auto_have_skill($skill[Ambidextrous Funkslinging]))
			{
				res += ", none";
			}
			return res;
		}
	}
	
	# Instakill handler
	boolean doInstaKill = true;
	if($monsters[Lobsterfrogman, Ninja Snowman Assassin] contains enemy)
	{
		if(auto_have_skill($skill[Digitize]) && (get_property("_sourceTerminalDigitizeMonster") != enemy))
		{
			doInstaKill = false;
		}
	}

	if(instakillable(enemy) && !isFreeMonster(enemy) && doInstaKill)
	{
		if(canUse($skill[lightning strike]))
		{
			handleTracker(enemy, $skill[lightning strike], "auto_instakill");
			loopHandlerDelayAll();
			return useSkill($skill[lightning strike]);
		}

		if(canUse($skill[Chest X-Ray]) && equipped_amount($item[Lil\' Doctor&trade; bag]) > 0 && (get_property("_chestXRayUsed").to_int() < 3))
		{
			if((my_adventures() < 20) || inAftercore() || (my_daycount() >= 3))
			{
				handleTracker(enemy, $skill[Chest X-Ray], "auto_instakill");
				loopHandlerDelayAll();
				return useSkill($skill[Chest X-Ray]);
			}
		}
		if(canUse($skill[shattering punch]) && (get_property("_shatteringPunchUsed").to_int() < 3))
		{
			if((my_adventures() < 20) || inAftercore() || (my_daycount() >= 3))
			{
				handleTracker(enemy, $skill[shattering punch], "auto_instakill");
				loopHandlerDelayAll();
				return useSkill($skill[shattering punch]);
			}
		}
		if(canUse($skill[Gingerbread Mob Hit]) && !get_property("_gingerbreadMobHitUsed").to_boolean())
		{
			if((my_adventures() < 20) || inAftercore() || (my_daycount() >= 3))
			{
				handleTracker(enemy, $skill[Gingerbread Mob Hit], "auto_instakill");
				loopHandlerDelayAll();
				return useSkill($skill[Gingerbread Mob Hit]);
			}
		}

	//		Can not use _usedReplicaBatoomerang if we have more than 1 because of the double item use issue...
	//		Sure, we can try to use a second item (if we have it or are forced to buy it... ugh).
	//		if(!contains_text(combatState, "batoomerang") && (item_amount($item[Replica Bat-oomerang]) > 0) && (get_property("_usedReplicaBatoomerang").to_int() < 3))
	//		THIS IS COPIED TO THE ED SECTION, IF IT IS FIXED, FIX IT THERE TOO!
		if(canUse($item[Replica Bat-oomerang]))
		{
			if(get_property("auto_batoomerangDay").to_int() != my_daycount())
			{
				set_property("auto_batoomerangDay", my_daycount());
				set_property("auto_batoomerangUse", 0);
			}
			if(get_property("auto_batoomerangUse").to_int() < 3)
			{
				set_property("auto_batoomerangUse", get_property("auto_batoomerangUse").to_int() + 1);
				handleTracker(enemy, $item[Replica Bat-oomerang], "auto_instakill");
				loopHandlerDelayAll();
				return useItem($item[Replica Bat-oomerang]);
			}
		}

		if(canUse($skill[Fire the Jokester\'s Gun]) && !get_property("_firedJokestersGun").to_boolean())
		{
			handleTracker(enemy, $skill[Fire the Jokester\'s Gun], "auto_instakill");
			loopHandlerDelayAll();
			return useSkill($skill[Fire the Jokester\'s Gun]);
		}
	}

	//wearing [retro superhero cape] iotm set to vampire slicer mode instakills Undead and reduces evilness in Cyrpt zones.
	if (canUse($skill[Slay the Dead]) && enemy.phylum == $phylum[undead])
	{
		return useSkill($skill[Slay the Dead]);
	}
	
	//autokill duplicated enemies. this still costs a turn
	if(canUse($item[Exploding Cigar]) && haveUsed($skill[Duplicate]))
	{
		return useItem($item[Exploding Cigar]);
	}
	
	return "";
}
