string auto_combatDefaultStage1(int round, monster enemy, string text)
{
	##stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
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
	
	#Path = Bees Hate You
	retval = auto_combatBHYStage1(round, enemy, text);
	if(retval != "") return retval;
	
	#Path = disguises delimit
	retval = auto_combatDisguisesStage1(round, enemy, text);
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
	
	//saber copy (iotm) is different from other copies in that it comes with a free escape
	//technically it is an ender. but one that should be run before duplications.
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
	
	return "";
}
