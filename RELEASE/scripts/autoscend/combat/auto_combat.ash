import <autoscend/combat/auto_combat_header.ash>					//header file for combat
import <autoscend/combat/auto_combat_util.ash>						//combat utilities
import <autoscend/combat/auto_combat_default_stage4.ash>			//default stage 4 is killing the enemy
import <autoscend/combat/auto_combat_awol.ash>						//path = avatar of west of loathing
import <autoscend/combat/auto_combat_community_service.ash>			//path = community service
import <autoscend/combat/auto_combat_jarlsberg.ash>					//path = avatar of jarlsberg
import <autoscend/combat/auto_combat_disguises_delimit.ash>			//path = disguises delimit
import <autoscend/combat/auto_combat_ed.ash>						//path = actually ed the undying
import <autoscend/combat/auto_combat_ocrs.ash>						//path = one crazy random summer
import <autoscend/combat/auto_combat_plumber.ash>					//path = path of the plumber
import <autoscend/combat/auto_combat_quest.ash>						//quest specific handling

//	Advance combat round, nothing happens.
//	/goto fight.php?action=useitem&whichitem=1

string auto_combatHandler(int round, monster enemy, string text)
{
	if(round > 25)
	{
		abort("Some sort of problem occurred, it is past round 25 but we are still in non-gremlin combat...");
	}
	string retval;
	
	#Yes, round 0, really.
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	int damageReceived = 0;
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");

		switch(enemy)
		{
			case $monster[Government Agent]:
				set_property("_portscanPending", false);
				break;
			case $monster[possessed wine rack]:
				set_property("auto_wineracksencountered", get_property("auto_wineracksencountered").to_int() + 1);
				break;
			case $monster[cabinet of Dr. Limpieza]:
				set_property("auto_cabinetsencountered", get_property("auto_cabinetsencountered").to_int() + 1);
				break;
			case $monster[junksprite bender]:
			case $monster[junksprite melter]:
			case $monster[junksprite sharpener]:
				set_property("auto_junkspritesencountered", get_property("auto_junkspritesencountered").to_int() + 1);
				break;
		}

		set_property("auto_combatHandler", "");
		set_property("auto_funCombatHandler", "");
		set_property("auto_funPrefix", "");
		set_property("auto_combatHandlerThunderBird", "0");
		set_property("auto_combatHandlerFingernailClippers", "0");
		set_property("auto_combatHP", my_hp());
	}
	else
	{
		damageReceived = get_property("auto_combatHP").to_int() - my_hp();
		set_property("auto_combatHP", my_hp());
	}

	set_property("auto_diag_round", round);

	if(my_path() == "One Crazy Random Summer")
	{
		enemy = ocrs_combat_helper(text);
		enemy = last_monster();
	}
	if(my_path() == "Avatar of West of Loathing")
	{
		awol_combat_helper(text);
	}

	phylum type = monster_phylum(enemy);
	phylum current = to_phylum(get_property("dnaSyringe"));

	string combatState = get_property("auto_combatHandler");
	int fingernailClippersLeft = get_property("auto_combatHandlerFingernailClippers").to_int();

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int enemy_la = monster_level_adjustment();

	boolean doBanisher = !inAftercore();

	int majora = -1;
	if(my_path() == "Disguises Delimit")
	{
		matcher maskMatch = create_matcher("mask(\\d+).png", text);
		if(maskMatch.find())
		{
			majora = maskMatch.group(1).to_int();
			if(round == 0)
			{
				auto_log_info("Found mask: " + majora, "green");
			}
		}
		else if(enemy == $monster[Your Shadow])	//matcher fails on your shadow and it always wears mask 1.
		{
			majora = 1;
			auto_log_info("Found mask: 1", "green");
		}
		else
		{
			abort("Failed to identify the mask worn by the monster [" + enemy + "]. Finish this combat manually then run me again");
		}
		set_property("_auto_combatDisguisesDelimitMask", majora);
		
		if((majora == 7) && canUse($skill[Swap Mask]))
		{
			return useSkill($skill[Swap Mask]);
		}
		if(majora == 3)
		{
			if(canSurvive(1.5))
			{
				return "attack with weapon";
			}
			abort("May not be able to survive combat. Is swapping protest mask still not allowing us to do anything?");
		}
		if(my_mask() == "protest mask" && canUse($skill[Swap Mask]))
		{
			return useSkill($skill[Swap Mask]);
		}
	}

	if(get_property("auto_combatDirective") != "")
	{
		string[int] actions = split_string(get_property("auto_combatDirective"), ";");
		int idx = 0;
		if(round == 0)
		{
			if(actions[0] != "start")
			{
				set_property("auto_combatDirective", "");
				idx = -1;
			}
			else
			{
				idx = 1;
			}
		}
		if(idx >= 0)
		{
			string doThis = actions[idx];
			while(contains_text(doThis, "(") && contains_text(doThis, ")") && (idx < count(actions)))
			{
				set_property("auto_combatHandler", get_property("auto_combatHandler") + doThis);
				idx++;
				if(idx >= count(actions))
				{
					break;
				}
				doThis = actions[idx];
			}
			string restore = "";
			for(int i=idx+1; i<count(actions); i++)
			{
				restore += actions[i];
				if((i+1) < count(actions))
				{
					restore += ";";
				}
			}
			set_property("auto_combatDirective", restore);
			if(idx < count(actions))
			{
				return doThis;
			}
		}
	}

	if($monsters[One Thousand Source Agents, Source Agent] contains enemy)
	{
		if(auto_have_skill($skill[Data Siphon]))
		{
			if(my_mp() < 50)
			{
				if(auto_have_skill($skill[Source Punch]) && (my_mp() >= mp_cost($skill[Source Punch])))
				{
					return useSkill($skill[Source Punch], false);
				}
			}
			else if(my_mp() > 125)
			{
				if(canUse($skill[Reboot]) && ((have_effect($effect[Latency]) > 0) || ((my_hp() * 2) < my_maxhp())))
				{
					return useSkill($skill[Reboot]);
				}
				if(canUse($skill[Humiliating Hack]))
				{
					return useSkill($skill[Humiliating Hack]);
				}
				if(canUse($skill[Disarmament]))
				{
					return useSkill($skill[Disarmament]);
				}
				if(canUse($skill[Big Guns]) && (my_hp() < 100))
				{
					return useSkill($skill[Big Guns]);
				}

			}
			else if(my_mp() > 100)
			{
				if(canUse($skill[Humiliating Hack]))
				{
					return useSkill($skill[Humiliating Hack]);
				}
				if(canUse($skill[Disarmament]))
				{
					return useSkill($skill[Disarmament]);
				}
			}

			if(canUse($skill[Source Kick], false))
			{
				return useSkill($skill[Source Kick], false);
			}
		}

		if(canUse($skill[Big Guns]))
		{
			return useSkill($skill[Big Guns]);
		}
		if(canUse($skill[Source Punch], false))
		{
			return useSkill($skill[Source Punch], false);
		}
		return "runaway";
	}

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

	if (enemy == $monster[The Invader] && canUse($skill[Weapon of the Pastalord], false))
	{
		return useSkill($skill[Weapon of the Pastalord], false);
	}

	if (enemy == $monster[Skeleton astronaut])
	{
		if(my_daycount() == 1 && canUse($item[Exploding cigar], false))
		{
			return useItem($item[Exploding cigar]);
		}
		int dmg = 0;
		foreach el in $elements[hot, cold, sleaze, spooky, stench]
		{
			dmg += min(10, numeric_modifier(el.to_string() + " Damage"));
		}
		// 10 physical + 10 prismatic is enough to be better than Saucestorm.
		// Otherwise, saucestorm deals 20 damage/round.
		if(dmg >= 10 && buffed_hit_stat() >= 120 + monster_level_adjustment())
		{
			return "attack with weapon";
		}
		else if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}

	if(canUse($skill[Use the Force]) && (auto_saberChargesAvailable() > 0) && (enemy != auto_saberCurrentMonster()))
	{
		if(enemy == $monster[Blooper] && needDigitalKey())
		{
			handleTracker(enemy, $skill[Use the Force], "auto_copies");
			return auto_combatSaberCopy();
		}
	}


	if(!haveUsed($item[Rain-Doh black box]) && (my_path() != "Heavy Rains") && (get_property("_raindohCopiesMade").to_int() < 5))
	{
		if((enemy == $monster[Modern Zmobie]) && (get_property("auto_modernzmobiecount").to_int() < 3))
		{
			set_property("auto_doCombatCopy", "yes");
		}
	}

	if ($monsters[pygmy bowler, bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, red butler] contains enemy && canUse($skill[%fn\, spit on them!]))
	{
		handleTracker($skill[%fn\, spit on them!], enemy, "auto_otherstuff");
		return useSkill($skill[%fn\, spit on them!], true);
	}

	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}
	if(have_equipped($item[Drunkula\'s Wineglass]))
	{
		return "attack with weapon";
	}
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

	if(canUse($skill[Tunnel Downwards]) && (have_effect($effect[Shape of...Mole!]) > 0) && (my_location() == $location[Mt. Molehill]))
	{
		return useSkill($skill[Tunnel Downwards]);
	}

	if((my_familiar() == $familiar[Stocking Mimic]) && (round < 12) && canSurvive(1.5))
	{
		if (item_amount($item[Seal Tooth]) > 0)
		{
			return "item " + $item[Seal Tooth];
		}
	}

	if(canUse($item[Glark Cable], true) && (my_location() == $location[The Red Zeppelin]) && (get_property("questL11Ron") == "step3") && (get_property("_glarkCableUses").to_int() < 5))
	{
		if($monsters[Man With The Red Buttons, Red Butler, Red Fox, Red Skeleton] contains enemy)
		{
			return useItem($item[Glark Cable]);
		}
	}

	if(canUse($item[Cigarette Lighter]) && (my_location() == $location[A Mob Of Zeppelin Protesters]) && (get_property("questL11Ron") == "step1"))
	{
		return useItems($item[Cigarette Lighter], $item[none]);
	}

	if((my_class() == $class[Avatar of Sneaky Pete]) && canSurvive(2.0))
	{
		int maxAudience = 30;
		if($items[Sneaky Pete\'s Leather Jacket, Sneaky Pete\'s Leather Jacket (Collar Popped)] contains equipped_item($slot[shirt]))
		{
			maxAudience = 50;
		}
		if(canUse($skill[Mug for the Audience]) && (my_audience() < maxAudience))
		{
			return useSkill($skill[Mug for the Audience]);
		}
	}

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

	if((my_class() == $class[Avatar of Sneaky Pete]) && canSurvive(2.0) && (my_level() < 13))
	{
		if(canUse($skill[Mug for the Audience]))
		{
			return useSkill($skill[Mug for the Audience]);
		}
	}

	if(canUse($skill[Steal Accordion]) && (my_class() == $class[Accordion Thief]) && canSurvive(2.0))
	{
		return useSkill($skill[Steal Accordion]);
	}

	if(get_property("auto_useTatter").to_boolean())
	{
		if(item_amount($item[Tattered Scrap Of Paper]) > 0)
		{
			return "item " + $item[Tattered Scrap Of Paper];
		}
	}

	if((get_property("auto_usePowerPill").to_boolean()) && (get_property("_powerPillUses").to_int() < 20) && instakillable(enemy))
	{
		if(item_amount($item[Power Pill]) > 0)
		{
			return "item " + $item[Power Pill];
		}
	}

	if((my_familiar() == $familiar[Pair of Stomping Boots]) && (get_property("_bootStomps").to_int()) < 7 && instakillable(enemy) && get_property("bootsCharged").to_boolean())
	{
		if(!($monsters[Dairy Goat, Lobsterfrogman, Writing Desk] contains enemy) && !($locations[The Laugh Floor, Infernal Rackets Backstage] contains my_location()) && canUse($skill[Release the boots]))
		{
			return useSkill($skill[Release the boots]);
		}
	}

	if(get_property("auto_useCleesh").to_boolean())
	{
		if(canUse($skill[CLEESH]))
		{
			set_property("auto_useCleesh", false);
			return useSkill($skill[CLEESH]);
		}
	}
	
	//Bees Hate You final boss
	if(canUse($item[antique hand mirror]) && (enemy == $monster[Guy Made Of Bees]))
	{
		return useItem($item[antique hand mirror]);
	}

	//Heavy Rain boss debuff & Stunning
	if($monsters[Big Wisnaqua, The Aquaman, The Rain King] contains enemy)
	{
		//During round 1 against late bosses set how many [Thunder Bird] we plan to cast during this combat
		if(round == 1 && get_property("auto_combatHandlerThunderBird").to_int() == 0)
		{
			int targetThunderBird = 3;
			if(monster_level_adjustment() > 80)
			{
				targetThunderBird++;
			}
			if(monster_level_adjustment() > 110)
			{
				targetThunderBird++;
			}
			if(monster_level_adjustment() > 150)
			{
				targetThunderBird++;
			}
			set_property("auto_combatHandlerThunderBird", targetThunderBird);
		}
	
		//These bosses are actually stunable. unless their ML is over 150
		if(monster_level_adjustment() > 150)		//not stunable
		{
			//30% debuff each crayon shavings, making each 1 superior to 2 casts of [Thunder Bird]
			if(item_amount($item[crayon shavings]) > 1 && auto_have_skill($skill[Ambidextrous Funkslinging]))
			{
				set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 4);
				return "item " + $item[crayon shavings] + ", " + $item[crayon shavings];
			}
			if(item_amount($item[crayon shavings]) > 0)
			{
				set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 2);
				return "item " + $item[crayon shavings];
			}
		}
		else		//stunable
		{
			if(canUse($skill[Micrometeorite]))
			{
				//stun and delevel 10% (or theoretically up to 25% if it was not used constantly)
				set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 1);
				return useSkill($skill[Micrometeorite]);
			}
			if(canUse($skill[Curse Of Weaksauce]) && my_mp() >= 50 && auto_have_skill($skill[Itchy Curse Finger]))
			{
				//every round delevel 3% of original attack value
				return useSkill($skill[Curse Of Weaksauce]);
			}
			if(canUse($skill[Thunderstrike]) && my_thunder() >= 5)
			{
				//Once per combat multiround stun ability that does not delevel
				return useSkill($skill[Thunderstrike]);
			}
			if(canUse($skill[Curse Of Weaksauce]) && my_mp() >= 50)
			{
				//rely on thunderstrike stun if you do not have [Itchy Curse Finger]
				return useSkill($skill[Curse Of Weaksauce]);
			}
		}
		
		//once done with stunnning, use [Thunder Bird] which debuffs but does not stun.
		if(my_thunder() == 0 && get_property("auto_combatHandlerThunderBird").to_int() > 0)
		{
			set_property("auto_combatHandlerThunderBird", 0);
		}
		if(get_property("auto_combatHandlerThunderBird").to_int() > 0 && canUse($skill[Thunder Bird], false))
		{
			set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 1);
			return useSkill($skill[Thunder Bird], false);
		}
	}

	// Heavy Rains Final Boss. strips you of positive effects every time it hits you. Capped at 40 damage per source per element.
	if(enemy.to_string() == "The Rain King")
	{
		if(get_property("auto_rain_king_combat") == "attack")
		{
			if(canUse($skill[Lunging Thrust-Smack], false))
			{
				return useSkill($skill[Lunging Thrust-Smack], false);
			}
			if(canUse($skill[Thrust-Smack], false))
			{
				return useSkill($skill[Thrust-Smack], false);
			}
			if(canUse($skill[Lunge Smack], false))
			{
				return useSkill($skill[Lunge Smack], false);
			}
			return "attack with weapon";
		}
		if(get_property("auto_rain_king_combat") == "saucestorm" && canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
		if(get_property("auto_rain_king_combat") == "weapon_of_the_pastalord" && canUse($skill[Weapon of the Pastalord], false))
		{
			return useSkill($skill[Weapon of the Pastalord], false);
		}
		if(get_property("auto_rain_king_combat") == "turtleini" && canUse($skill[Turtleini], false))
		{
			return useSkill($skill[Turtleini], false);
		}
		abort("I am not sure how to finish this battle");
	}
	
	// Unique Heavy Rains Enemy that Reflects Spells.
	if(enemy.to_string() == "Gurgle")
	{
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
		return "attack with weapon";
	}
	
	// Unique Heavy Rains Enemy that reduces Spells damage to 1 and caps non spell damage at 39 per source and type
	// Has low enough HP it can be defeated in 10 combat turns using simple melee attacks that deal only physical damage
	if(enemy.to_string() == "Dr. Aquard")
	{
		if(canUse($skill[Curse of Weaksauce]))
		{
			return useSkill($skill[Curse of Weaksauce]);
		}
		if(canUse($skill[Micrometeorite]))
		{
			return useSkill($skill[Micrometeorite]);
		}
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
		return "attack with weapon";
	}

	if((my_location() == $location[The Battlefield (Frat Uniform)]) && (enemy == $monster[gourmet gourami]))
	{
		if (item_amount($item[Louder Than Bomb]) > 0 && get_property("sidequestJunkyardCompleted") != "none")
		{
			handleTracker(enemy, $item[Louder Than Bomb], "auto_banishes");
			return "item " + $item[Louder Than Bomb];
		}
	}

	if(my_class() == $class[Seal Clubber])
	{
		if(enemy == $monster[Hellseal Pup])
		{
			return useSkill($skill[Clobber], false);
		}
		if(enemy == $monster[Mother Hellseal])
		{
			if(canUse($item[Rain-Doh Indigo Cup]))
			{
				return useItem($item[Rain-Doh Indigo Cup]);
			}
			return useSkill($skill[Lunging Thrust-Smack], false);
		}
	}

	if((enemy == $monster[French Guard Turtle]) && have_equipped($item[Fouet de tortue-dressage]) && (my_mp() >= mp_cost($skill[Apprivoisez La Tortue])))
	{
		return useSkill($skill[Apprivoisez La Tortue], false);
	}

	if((!in_zelda() && my_class() != $class[Vampyre] && my_path() != "Zombie Slayer") &&	//paths that do not use MP
	canUse($skill[Gulp Latte]) &&
	my_mp() * 2 < my_maxmp())		//gulp latte restores 50% of your MP. do not waste it.
	{
		return useSkill($skill[Gulp Latte]);
	}

	#Do not accidentally charge the nanorhino with a non-banisher
	if((my_familiar() == $familiar[Nanorhino]) && (have_effect($effect[Nanobrawny]) == 0))
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

	if((enemy == $monster[Plaid Ghost]) && (item_amount($item[T.U.R.D.S. Key]) > 0))
	{
		return "item " + $item[T.U.R.D.S. Key];
	}

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

	if((enemy == $monster[Storm Cow]) && (auto_have_skill($skill[Unleash The Greash])))
	{
		return useSkill($skill[Unleash The Greash], false);
	}

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

	if(canUse($skill[Extract]) && inAftercore())
	{
		return useSkill($skill[Extract]);
	}


	if(canUse($skill[Summon Mayfly Swarm]))
	{
		if(have_equipped($item[Mayfly Bait Necklace]))
		{
			if($locations[Dreadsylvanian Village, Dreadsylvanian Woods, The Ice Hole, The Ice Hotel, Sloppy Seconds Diner, VYKEA] contains my_location())
			{
				return useSkill($skill[Summon Mayfly Swarm]);
			}
		}
	}

	if(canUse($item[The Big Book of Pirate Insults]) && (numPirateInsults() < 8) && (internalQuestStatus("questM12Pirate") < 5))
	{
		if ($locations[Barrrney\'s Barrr, The Obligatory Pirate\'s Cove] contains my_location())
		{
			return useItem($item[The Big Book Of Pirate Insults]);
		}
	}

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
	
	if(canUse($item[chaos butterfly]) && !get_property("chaosButterflyThrown").to_boolean() && !get_property("auto_skipL12Farm").to_boolean())
	{
		if(canUse($item[Time-Spinner]) && auto_have_skill($skill[Ambidextrous Funkslinging]))
		{
			return useItems($item[chaos butterfly], $item[Time-Spinner]);
		}
		return useItem($item[chaos butterfly]);
	}

	if(item_amount($item[Cocktail Napkin]) > 0)
	{
		if($monsters[Clingy Pirate (Female), Clingy Pirate (Male)] contains enemy)
		{
			return "item " + $item[Cocktail Napkin];
		}
	}

	if(canUse($item[DNA extraction syringe]) && (monster_level_adjustment() < 150))
	{
		if(type != current)
		{
			return useItem($item[DNA extraction syringe]);
		}
	}

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

	if(canUse($skill[Hugs and Kisses!]) && (my_familiar() == $familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() < 11))
	{
		boolean dohug = false;
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			dohug = true;
		}

		if(get_property("_xoHugsUsed").to_int() < 8)
		{
			// snatch a wig if we're lucky
			if(enemy == $monster[Burly Sidekick] && !possessEquipment($item[Mohawk wig]))
				dohug = true;

			// snatch a hedge trimmer if we're lucky
			if($monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal] contains enemy)
				dohug = true;

			// snatch a killing jar if we're lucky
			if(enemy == $monster[banshee librarian] && (0 == item_amount($item[Killing jar])))
				dohug = true;

			// snatch a sonar-in-a-biscuit if we're lucky
			if((item_drops(enemy) contains $item[sonar-in-a-biscuit]) && (count(item_drops(enemy)) <= 2) && (get_property("questL04Bat")) != "finished")
				dohug = true;
		}

		if(dohug)
		{
			handleTracker(enemy, $skill[Hugs and Kisses!], "auto_otherstuff");
			return useSkill($skill[Hugs and Kisses!]);
		}
	}

	if(item_amount($item[Green Smoke Bomb]) > 0)
	{
		if($monsters[Animated Possessions, Natural Spider] contains enemy)
		{
			return "item " + $item[Green Smoke Bomb];
		}
	}

	if(!inAftercore())
	{
		if(item_amount($item[short writ of habeas corpus]) > 0 && canUse($item[short writ of habeas corpus]))
		{
			if($monsters[Pygmy Orderlies, Pygmy Witch Lawyer, Pygmy Witch Nurse] contains enemy)
			{
				return "item " + $item[Short Writ Of Habeas Corpus];
			}
		}
	}

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

	if(canUse($item[Disposable Instant Camera]))
	{
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			return useItem($item[Disposable Instant Camera]);
		}
	}

	if(item_amount($item[Duskwalker Syringe]) > 0)
	{
		if($monsters[Oil Baron, Oil Cartel, Oil Slick, Oil Tycoon] contains enemy)
		{
			return "item " + $item[Duskwalker Syringe];
		}
	}

	if(canUse($item[opium grenade]) && enemy == $monster[pair of burnouts])
	{
		return useItem($item[opium grenade]);
	}

	if(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy))
	{
		string stall = getStallString(enemy);
		if(stall != "")
		{
			return stall;
		}

		if(canUse($skill[Shoot Ghost], false) && (my_mp() > mp_cost($skill[Shoot Ghost])) && !contains_text(combatState, "shootghost3") && !contains_text(combatState, "trapghost"))
		{
			boolean shootGhost = true;
			if(contains_text(combatState, "shootghost2"))
			{
				if((damageReceived * 1.075) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("auto_combatHandler", combatState + "(shootghost3)");
				}
			}
			else if(contains_text(combatState, "shootghost1"))
			{
				if((damageReceived * 2.05) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("auto_combatHandler", combatState + "(shootghost2)");
				}
			}
			else
			{
				set_property("auto_combatHandler", combatState + "(shootghost1)");
			}

			if(shootGhost)
			{
				return useSkill($skill[Shoot Ghost], false);
			}
			else
			{
				combatState += "(trapghost)(love stinkbug)";
				set_property("auto_combatHandler", combatState);
			}
		}
		if(!contains_text(combatState, "trapghost") && auto_have_skill($skill[Trap Ghost]) && (my_mp() > mp_cost($skill[Trap Ghost])) && contains_text(combatState, "shootghost3"))
		{
			auto_log_info("Busting makes me feel good!!", "green");
			set_property("auto_combatHandler", combatState + "(trapghost)");
			return useSkill($skill[Trap Ghost], false);
		}
	}

	# Ensorcel handler
	if(bat_shouldEnsorcel(enemy) && canUse($skill[Ensorcel]) && get_property("auto_bat_ensorcels").to_int() < 3)
	{
		set_property("auto_bat_ensorcels", get_property("auto_bat_ensorcels").to_int() + 1);
		handleTracker(enemy, $skill[Ensorcel], "auto_otherstuff");
		return useSkill($skill[Ensorcel]);
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

	if (canUse($skill[Slay the Dead]) && enemy.phylum == $phylum[undead])
	{
		// instakills Undead and reduces evilness in Cyrpt zones.
		return useSkill($skill[Slay the Dead]);
	}

	if(canUse($skill[Bad Medicine]) && (my_mp() >= (3 * mp_cost($skill[Bad Medicine]))))
	{
		return useSkill($skill[Bad Medicine]);
	}

	boolean doWeaksauce = true;
	if((buffed_hit_stat() - 20) > monster_defense())
	{
		doWeaksauce = false;
	}
	if(my_class() == $class[Sauceror])
	{
		doWeaksauce = true;
	}
	// if(enemy == $monster[invader bullet]) // TODO: on version bump
	if(enemy.to_string().to_lower_case() == "invader bullet")
	{
		doWeaksauce = false;
	}

	if(canUse($skill[Curse of Weaksauce]) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
	{
		return useSkill($skill[Curse of Weaksauce]);
	}

	//boris specific 3MP skill that delevels by 15%, with an upgrade it delevels 30% and stuns.
	//even without the upgrade it it is worth it. actually without upgrade you need it more due to low skill.
	if(canUse($skill[Intimidating Bellow]) && expected_damage() > 0 && !enemyCanBlocksSkills())
	{
		return useSkill($skill[Intimidating Bellow]);
	}

	if(enemy == $monster[Eldritch Tentacle])
	{
		enemy_la = 151;
	}

	// if(enemy == $monster[invader bullet]) // TODO: on version bump
	if(enemy.to_string().to_lower_case() == "invader bullet")
	{
		enemy_la = 151;
	}

	if($monsters[Naughty Sorceress, Naughty Sorceress (2)] contains enemy && !get_property("auto_confidence").to_boolean())
	{
		enemy_la = 151;
	}

	#Default behaviors:
	if(enemy_la <= 150)
	{
		if(canUse($skill[Curse of Weaksauce]) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}

		if($item[Daily Affirmation: Keep Free Hate In Your Heart].combat)
		{
			if(canUse($item[Daily Affirmation: Keep Free Hate In Your Heart]) && inAftercore() && hippy_stone_broken() && !get_property("_affirmationHateUsed").to_boolean())
			{
				return useItem($item[Daily Affirmation: Keep Free Hate In Your Heart]);
			}
		}

		if(canUse($skill[Canhandle]))
		{
			if($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand]))
			{
				return useSkill($skill[Canhandle]);
			}
		}

		if (canUse($skill[Curse Of Weaksauce]) && my_class() == $class[Sauceror] && doWeaksauce)
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}

		if(canUse($skill[Detect Weakness]))
		{
			return useSkill($skill[Detect Weakness]);
		}

		if(canUse($skill[Deploy Robo-Handcuffs]))
		{
			return useSkill($skill[Deploy Robo-Handcuffs]);
		}

		if(canUse($skill[Pocket Crumbs]))
		{
			return useSkill($skill[Pocket Crumbs]);
		}

		if(canUse($skill[Micrometeorite]))
		{
			return useSkill($skill[Micrometeorite]);
		}

		if(canUse($item[Cow Poker]))
		{
			if($monsters[Caugr, Moomy, Pharaoh Amoon-Ra Cowtep, Pyrobove, Spidercow] contains enemy)
			{
				return useItem($item[Cow Poker]);
			}
		}

		if(canUse($item[Western-Style Skinning Knife]))
		{
			if($monsters[Caugr, Coal Snake, Diamondback Rattler, Frontwinder, Grizzled Bear, Mountain Lion] contains enemy)
			{
				return useItem($item[Western-Style Skinning Knife]);
			}
		}

		if(my_location() == $location[The Smut Orc Logging Camp] && canSurvive(1.0))
		{
			// Listed from Most to Least Damaging to hopefully cause Death on the turn when the Shell hits.
			if(canUse($skill[Stuffed Mortar Shell]) && have_effect($effect[Spirit of Peppermint]) != 0)
			{
				return useSkill($skill[Stuffed Mortar Shell]);
			}
			else if(canUse($skill[Saucegeyser], false))
			{
				return useSkill($skill[Saucegeyser], false);
			}
			else if(canUse($skill[Saucecicle], false))
			{
				return useSkill($skill[Saucecicle], false);
			}
			else if(canUse($skill[Cannelloni Cannon], false) && have_effect($effect[Spirit of Peppermint]) != 0)
			{
				return useSkill($skill[Cannelloni Cannon], false);
			}
			else if(canUse($skill[Northern Explosion], false))
			{
				return useSkill($skill[Northern Explosion], false);
			}
			else if($classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief] contains my_class())
			{
				auto_log_warning("None of our preferred [cold] skills available against smut orcs. Engaging in Fisticuffs.", "red");
			}
		}

		if(my_location() == $location[The Haunted Kitchen] && canUse($skill[Become a Cloud of Mist]) && get_property("_vampyreCloakeFormUses").to_int() < 10)
		{
			int hot = to_int(numeric_modifier("Hot Resistance"));
			int stench = to_int(numeric_modifier("Stench Resistance"));

			if(((hot < 9 && hot % 3 != 0) || (stench < 9 && stench % 3 != 0)) && canUse($skill[Become a Cloud of Mist]))
			{
				return useSkill($skill[Become a Cloud of Mist]);
			}
		}

		if (enemy == $monster[dirty thieving brigand] && canUse($skill[Become a Wolf]) && get_property("_vampyreCloakeFormUses").to_int() < 10)
		{
			return useSkill($skill[Become a Wolf]);
		}

		if(canUse($skill[Air Dirty Laundry]))
		{
			return useSkill($skill[Air Dirty Laundry]);
		}

		if(canUse($skill[Cowboy Kick]))
		{
			return useSkill($skill[Cowboy Kick]);
		}

		if(canUse($skill[Fire Death Ray]))
		{
			return useSkill($skill[Fire Death Ray]);
		}

		if(canUse($skill[ply reality]))
		{
			return useSkill($skill[Ply Reality]);
		}

		if(canUse($item[Rain-Doh indigo cup]))
		{
			return useItem($item[Rain-Doh Indigo Cup]);
		}

		if(canUse($skill[Summon Love Mosquito]))
		{
			return useSkill($skill[Summon Love Mosquito]);
		}

		if(canUse($item[Tomayohawk-Style Reflex Hammer]))
		{
			return useItem($item[Tomayohawk-Style Reflex Hammer]);
		}

		// skills from Lathe weapons
		// Ebony Epee
		if(canUse($skill[Disarming Thrust]))
		{
			return useSkill($skill[Disarming Thrust]);
		}
		// Weeping Willow Wand
		if(canUse($skill[Barrage of Tears]))
		{
			return useSkill($skill[Barrage of Tears]);
		}
		// Poison Dart (from beechwood blowgun) is not used here
		// because it does not stagger the enemy like the others

		if(canUse($skill[Cadenza]) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			if($items[Accordion of Jordion, Accordionoid Rocca, non-Euclidean non-accordion, Shakespeare\'s Sister\'s Accordion, zombie accordion] contains equipped_item($slot[weapon]))
			{
				return useSkill($skill[Cadenza]);
			}
		}

		if(canUse($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && (item_amount($item[Source Essence]) <= 60) && stunnable(enemy))
		{
			return useSkill($skill[Extract]);
		}

		if(canUse($skill[Extract Jelly]) && (my_mp() > (mp_cost($skill[Extract Jelly]) * 3)) && canSurvive(2.0) && (my_familiar() == $familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 3) && ($elements[hot, spooky, stench] contains monster_element(enemy)))
		{
			return useSkill($skill[Extract Jelly]);
		}

		if(canUse($skill[Science! Fight With Medicine]) && ((my_hp() * 2) < my_maxhp()))
		{
			return useSkill($skill[Science! Fight With Medicine]);
		}
		if(canUse($skill[Science! Fight With Rational Thought]) && (have_effect($effect[Rational Thought]) < 10))
		{
			return useSkill($skill[Science! Fight With Rational Thought]);
		}

		if(canUse($item[Time-Spinner]))
		{
			return useItem($item[Time-Spinner]);
		}
		
		if(canUse($skill[Sing Along]))
		{
			//15% devel, but no stun. 
			
			if(canSurvive(2.0) && (get_property("boomBoxSong") == "Remainin\' Alive"))
			{
				return useSkill($skill[Sing Along]);
			}
		
			//this is for increasing meat income. gain +25 meat per monster, at the cost of letting it act once. If healing is too costly this can be a net loss of meat. until a full cost calculator is made, limit to under 10 HP damage and no more than 20% of your remaining HP.
			
			if(canSurvive(5.0) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat") && (expected_damage() < 10) && (auto_my_path() != "Way of the Surprising Fist"))
			{
				return useSkill($skill[Sing Along]);
			}
		
			//if doing nuns quest or wall of meat, disregard profit and only check if you can survive using sing along.
			
			if(canSurvive(3.0) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat") && $monsters[dirty thieving brigand, wall of meat] contains enemy)
			{
				return useSkill($skill[Sing Along]);
			}
		}
	}

	#Default behaviors, multi-staggers when chance is 50% or greater
	if(enemy_la < 100 && stunnable(enemy))
	{
		if(canUse($item[Rain-Doh blue balls]))
		{
			return useItem($item[Rain-Doh blue balls]);
		}

		if(canUse($skill[Summon Love Gnats]))
		{
			return useSkill($skill[Summon Love Gnats]);
		}

		if(canUse($skill[Summon Love Stinkbug]) && haveUsed($skill[Summon Love Gnats]) && !contains_text(text, "STUN RESIST"))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
	}

	if((my_location() == $location[Super Villain\'s Lair]) && (auto_my_path() == "License to Adventure") && canSurvive(2.0) && (enemy == $monster[Villainous Minion]))
	{
		if(!get_property("_villainLairCanLidUsed").to_boolean() && (item_amount($item[Razor-Sharp Can Lid]) > 0))
		{
			return "item " + $item[Razor-Sharp Can Lid];
		}
		if(!get_property("_villainLairWebUsed").to_boolean() && (item_amount($item[Spider Web]) > 0))
		{
			return "item " + $item[Spider Web];
		}
		if(!get_property("_villainLairFirecrackerUsed").to_boolean() && (item_amount($item[Knob Goblin Firecracker]) > 0))
		{
			return "item " + $item[Knob Goblin Firecracker];
		}
	}

	if(canUse($skill[Portscan]) && (my_location().turns_spent < 8) && (get_property("_sourceTerminalPortscanUses").to_int() < 3) && !get_property("_portscanPending").to_boolean())
	{
		if($locations[The Castle in the Clouds in the Sky (Ground Floor), The Haunted Bathroom, The Haunted Gallery] contains my_location())
		{
			set_property("_portscanPending", true);
			return useSkill($skill[Portscan]);
		}
	}

	if(canUse($skill[Candyblast]) && (my_mp() > 60) && inAftercore())
	{
		# We can get only one candy and we can detect it, if so desired:
		# "Hey, some of it is even intact afterwards!"
		return useSkill($skill[Candyblast]);
	}



	if((my_class() == $class[Turtle Tamer]) && (canUse($skill[Spirit Snap]) && (my_mp() > 80)))
	{
		if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
		{
			return useSkill($skill[Spirit Snap]);
		}
	}

	if(canUse($skill[Stuffed Mortar Shell]) && (my_class() == $class[Sauceror]) && canSurvive(2.0) && (currentFlavour() != monster_element(enemy) || currentFlavour() == $element[none]))
	{
		return useSkill($skill[Stuffed Mortar Shell]);
	}

	if(canUse($skill[Duplicate]) && (get_property("_sourceTerminalDuplicateUses").to_int() == 0) && !inAftercore() && (auto_my_path() != "Nuclear Autumn"))
	{
		if($monsters[Dairy Goat] contains enemy)
		{
			return useSkill($skill[Duplicate]);
		}
	}

	if(canUse($item[Exploding Cigar]) && haveUsed($skill[Duplicate]))
	{
		return useItem($item[Exploding Cigar]);
	}

	if(canUse($skill[Gelatinous Kick], false) && haveUsed($skill[Duplicate]))
	{
		if($monsters[Dairy Goat] contains enemy)
		{
			return useSkill($skill[Gelatinous Kick], false);
		}
	}

	if(canUse($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 32 || haveUsed($skill[Stuffed Mortar Shell])) && doWeaksauce)
	{
		return useSkill($skill[Curse Of Weaksauce]);
	}

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

	if((enemy == $monster[LOV Enforcer]) && canUse($skill[Saucestorm], false))
	{
		return useSkill($skill[Saucestorm], false);
	}

	##stage4 = kill
	
	//path of the plumber path
	retval = auto_combatPlumberStage4(round, enemy, text);
	if(retval != "") return retval;
	
	//disguises deliimt path
	retval = auto_combatDisguisesStage4(round, enemy, text);
	if(retval != "") return retval;
	
	retval = auto_combatJarlsbergStage4(round, enemy, text);
	if(retval != "") return retval;
	
	retval = auto_combatDefaultStage4(round, enemy, text);
	if(retval != "") return retval;
	
	abort("We reached the end of combat script without finding anything to do");
	return "";
}
