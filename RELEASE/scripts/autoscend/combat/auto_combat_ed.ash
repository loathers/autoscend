//Path specific combat handling for Actually Ed the Undying

string auto_edCombatHandler(int round, monster enemy, string text)
{
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	int damageReceived = 0;
	if (!isActuallyEd())
	{
		abort("Not in Actually Ed the Undying, this combat filter will result in massive suckage.");
	}

	if (round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
		if (get_property("_edDefeats").to_int() == 0)
		{
			set_property("auto_edCombatCount", 1 + get_property("auto_edCombatCount").to_int());
		}
		if (!ed_needShop())
		{
			set_property("auto_edStatus", "dying"); // dying means kill the monster
		}
		else
		{
			set_property("auto_edStatus", "UNDYING!"); //  Undying means ressurect until it's not free any more
		}
	}
	else
	{
		damageReceived = get_property("auto_combatHP").to_int() - my_hp();
		set_property("auto_combatHP", my_hp());
	}

	set_property("auto_edCombatRoundCount", 1 + get_property("auto_edCombatRoundCount").to_int());

	if ($locations[Hippy Camp, The Outskirts Of Cobb\'s Knob, The Spooky Forest] contains my_location())
	{
		if (my_mp() < mp_cost($skill[Fist Of The Mummy]) && get_property("_edDefeats").to_int() < 2)
		{
			foreach it in $items[Holy Spring Water, Spirit Beer, Sacramental Wine]
			{
				if (canUse(it))
				{
					return useItem(it, false);
				}
			}
		}
	}

	if (get_property("_edDefeats").to_int() >= 2)
	{
		set_property("auto_edStatus", "dying");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	string combatState = get_property("auto_combatHandler");
	string edCombatState = get_property("auto_edCombatHandler");

	if($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy)
	{
		set_property("auto_edStatus", "dying");
	}

	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}

	if (canUse($skill[Pocket Crumbs]))
	{
		return useSkill($skill[Pocket Crumbs]);
	}

	if (canUse($skill[Micrometeorite]))
	{
		return useSkill($skill[Micrometeorite]);
	}

	if (canUse($skill[Air Dirty Laundry]))
	{
		return useSkill($skill[Air Dirty Laundry]);
	}

	if (canUse($skill[Summon Love Scarabs]))
	{
		return useSkill($skill[Summon Love Scarabs]);
	}

	if (canUse($item[Time-Spinner]))
	{
		return useItem($item[Time-Spinner]);
	}

	if (canUse($skill[Sing Along]))
	{
		//ed can easily survive singing along thanks to undying. and healing him is essentially free.
		if((get_property("boomBoxSong") == "Remainin\' Alive") || ((get_property("boomBoxSong") == "Total Eclipse of Your Meat") && canSurvive(2.0)))
		{
			return useSkill($skill[Sing Along]);
		}
	}

	if(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy))
	{
		if(canUse($skill[Summon Love Gnats]))
		{
			return useSkill($skill[Summon Love Gnats]);
		}

		if(auto_have_skill($skill[Shoot Ghost]) && (my_mp() > mp_cost($skill[Shoot Ghost])) && !contains_text(edCombatState, "shootghost3") && !contains_text(edCombatState, "trapghost"))
		{
			boolean shootGhost = true;
			if(contains_text(edCombatState, "shootghost2"))
			{
				if((damageReceived * 1.075) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("auto_edCombatHandler", edCombatState + "(shootghost3)");
				}
			}
			else if(contains_text(edCombatState, "shootghost1"))
			{
				if((damageReceived * 2.05) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("auto_edCombatHandler", edCombatState + "(shootghost2)");
				}
			}
			else
			{
				set_property("auto_edCombatHandler", edCombatState + "(shootghost1)");
			}

			if(shootGhost)
			{
				return "skill " + $skill[Shoot Ghost];
			}
			else
			{
				edCombatState += "(trapghost)(love stinkbug)";
				set_property("auto_edCombatHandler", edCombatState);
			}
		}
		if(!contains_text(edCombatState, "trapghost") && auto_have_skill($skill[Trap Ghost]) && (my_mp() > mp_cost($skill[Trap Ghost])) && contains_text(edCombatState, "shootghost3"))
		{
			auto_log_info("Busting makes me feel good!!", "green");
			set_property("auto_edCombatHandler", edCombatState + "(trapghost)");
			return "skill " + $skill[Trap Ghost];
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
		if(!contains_text(combatState, "batoomerang") && (item_amount($item[Replica Bat-oomerang]) > 0))
		{
			if(get_property("auto_batoomerangDay").to_int() != my_daycount())
			{
				set_property("auto_batoomerangDay", my_daycount());
				set_property("auto_batoomerangUse", 0);
			}
			if(get_property("auto_batoomerangUse").to_int() < 3)
			{
				set_property("auto_batoomerangUse", get_property("auto_batoomerangUse").to_int() + 1);
				set_property("auto_combatHandler", combatState + "(batoomerang)");
				handleTracker(enemy, $item[Replica Bat-oomerang], "auto_instakill");
				loopHandlerDelayAll();
				return "item " + $item[Replica Bat-oomerang];
			}
		}

		if(!contains_text(combatState, "jokesterGun") && (equipped_item($slot[Weapon]) == $item[The Jokester\'s Gun]) && !get_property("_firedJokestersGun").to_boolean() && auto_have_skill($skill[Fire the Jokester\'s Gun]))
		{
			set_property("auto_combatHandler", combatState + "(jokesterGun)");
			handleTracker(enemy, $skill[Fire the Jokester\'s Gun], "auto_instakill");
			loopHandlerDelayAll();
			return "skill" + $skill[Fire the Jokester\'s Gun];
		}
	}


	if(get_property("auto_edStatus") == "UNDYING!")
	{
		if (canUse($skill[Summon Love Gnats]))
		{
			return useSkill($skill[Summon Love Gnats]);
		}
	}
	else if(get_property("auto_edStatus") == "dying")
	{
		boolean doStunner = true;

		if(monster_level_adjustment() > 50 && canSurvive(1.15))
		{
			doStunner = false;
		}

		if(doStunner)
		{
			if (canUse($skill[Summon Love Gnats]))
			{
				return useSkill($skill[Summon Love Gnats]);
			}
		}
	}
	else
	{
		auto_log_warning("Ed combat state does not exist, winging it....", "red");
	}

	if (canUse($skill[Fire Sewage Pistol]))
	{
		return useSkill($skill[Fire Sewage Pistol]);
	}

	if(enemy == $monster[Protagonist])
	{
		set_property("auto_edStatus", "dying");
	}

	if (my_location() != $location[The Battlefield (Frat Uniform)] && my_location() != $location[The Battlefield (Hippy Uniform)] && !get_property("auto_ignoreFlyer").to_boolean())
	{
		if (canUse($item[Rock Band Flyers]) && get_property("flyeredML").to_int() < 10000)
		{
			if (get_property("_edDefeats").to_int() < 2 && get_property("auto_edStatus") == "dying")
			{
				set_property("auto_edStatus", "UNDYING!");
				// abuse the ability to flyer the same monster multiple times (optimal!)
			}
			return useItem($item[Rock Band Flyers]);
		}
		if (canUse($item[Jam Band Flyers]) && get_property("flyeredML").to_int() < 10000)
		{
			if (get_property("_edDefeats").to_int() < 2 && get_property("auto_edStatus") == "dying")
			{
				set_property("auto_edStatus", "UNDYING!");
				// abuse the ability to flyer the same monster multiple times (optimal!)
			}
			return useItem($item[Jam Band Flyers]);
		}
	}
	
	if(canUse($item[chaos butterfly]) && !get_property("chaosButterflyThrown").to_boolean() && !get_property("auto_skipL12Farm").to_boolean())
	{
		return useItem($item[chaos butterfly]);
	}

	if(enemy == $monster[dirty thieving brigand] && !contains_text(edCombatState, "curse of fortune")) {
		if (item_amount($item[Ka Coin]) > 0 && canUse($skill[Curse Of Fortune]) && my_hp() > expected_damage() + 15) {
			// need to kill the monster without resurrecting to get the bonus meat drop so only use it if we have enough HP to survive a hit
			set_property("auto_edCombatHandler", edCombatState + "(curse of fortune)");
			set_property("auto_edStatus", "dying");
			return useSkill($skill[Curse Of Fortune]);
		} else {
			// get a full heal, maybe we can Curse and kill after resurrection
			set_property("auto_edStatus", "UNDYING!");
		}
	}

	if (!contains_text(edCombatState, "curseofstench") && canUse($skill[Curse Of Stench]) && get_property("stenchCursedMonster").to_monster() != enemy && get_property("_edDefeats").to_int() < 3)
	{
		if(auto_wantToSniff(enemy, my_location()))
		{
			set_property("auto_edCombatHandler", combatState + "(curseofstench)");
			handleTracker(enemy, $skill[Curse Of Stench], "auto_sniffs");
			return useSkill($skill[Curse Of Stench]);
		}
	}

	if(my_location() == $location[The Secret Council Warehouse])
	{
		if (!contains_text(edCombatState, "curseofstench") && canUse($skill[Curse Of Stench]) && get_property("stenchCursedMonster").to_monster() != enemy && get_property("_edDefeats").to_int() < 3)
		{
			boolean doStench = false;
			#	Rememeber, we are looking to see if we have enough of the opposite item here.
			if(enemy == $monster[Warehouse Guard])
			{
				int progress = get_property("warehouseProgress").to_int();
				progress = progress + (8 * item_amount($item[Warehouse Inventory Page]));
				if(progress >= 50)
				{
					doStench = true;
				}
			}

			if(enemy == $monster[Warehouse Clerk])
			{
				int progress = get_property("warehouseProgress").to_int();
				progress = progress + (8 * item_amount($item[Warehouse Map Page]));
				if(progress >= 50)
				{
					doStench = true;
				}
			}
			if(doStench)
			{
				set_property("auto_edCombatHandler", combatState + "(curseofstench)");
				handleTracker(enemy, $skill[Curse of Stench], "auto_sniffs");
				return useSkill($skill[Curse Of Stench]);
			}
		}
	}

	if(my_location() == $location[The Smut Orc Logging Camp])
	{
		if (!contains_text(edCombatState, "curseofstench") && canUse($skill[Curse Of Stench]) && get_property("stenchCursedMonster").to_monster() != enemy && get_property("_edDefeats").to_int() < 3)
		{
			boolean doStench = false;
			string stenched = to_lower_case(get_property("stenchCursedMonster"));

			if((fastenerCount() >= 30) && (stenched != "smut orc pipelayer") && (stenched != "smut orc jacker"))
			{
				#	Sniff 100% lumber
				if((enemy == $monster[Smut Orc Pipelayer]) || (enemy == $monster[Smut Orc Jacker]))
				{
					doStench = true;
				}
			}
			if((lumberCount() >= 30) && (stenched != "smut orc screwer") && (stenched != "smut orc nailer"))
			{
				#	Sniff 100% fastener
				if((enemy == $monster[Smut Orc Screwer]) || (enemy == $monster[Smut Orc Nailer]))
				{
					doStench = true;
				}
			}

			if(doStench)
			{
				set_property("auto_edCombatHandler", combatState + "(curseofstench)");
				handleTracker(enemy, $skill[Curse of Stench], "auto_sniffs");
				return useSkill($skill[Curse Of Stench]);
			}
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

	if(!contains_text(combatState, "banishercheck") && auto_wantToBanish(enemy, my_location()))
	{
		string combatAction = banisherCombatString(enemy, my_location(), true);
		if(combatAction != "")
		{
			set_property("auto_combatHandler", combatState + "(banisher)");
			if(index_of(combatAction, "skill") == 0)
			{
				handleTracker(enemy, to_skill(substring(combatAction, 6)), "auto_banishes");
			}
			else if(index_of(combatAction, "item") == 0)
			{
				handleTracker(enemy, to_item(substring(combatAction, 5)), "auto_banishes");
			}
			else
			{
				auto_log_warning("Unable to track banisher behavior: " + combatAction, "red");
			}
			return combatAction;
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

	if (canUse($item[Disposable Instant Camera]) && $monsters[Bob Racecar, Racecar Bob] contains enemy)
	{
		return useItem($item[Disposable Instant Camera]);
	}

	if (my_location() == $location[Oil Peak] && canUse($item[Duskwalker Syringe]))
	{
		int oilProgress = get_property("twinPeakProgress").to_int();
		boolean wantCrude = ((oilProgress & 4) == 0);
		if(item_amount($item[Bubblin\' Crude]) > 11 || item_amount($item[Jar Of Oil]) > 0)
		{
			wantCrude = false;
		}

		if(wantCrude)
		{
			return useItem($item[Duskwalker Syringe]);
		}
	}

	if (canUse($item[Cigarette Lighter]) && my_location() == $location[A Mob Of Zeppelin Protesters] && internalQuestStatus("questL11Ron") == 1 && get_property("auto_edStatus") == "dying")
	{
		return useItem($item[Cigarette Lighter]);
		// insta-kills protestors and removes an additional 5-7 (optimal!)
	}

	if (canUse($item[Glark Cable]) && my_location() == $location[The Red Zeppelin] && internalQuestStatus("questL11Ron") == 3 && get_property("_glarkCableUses").to_int() < 5 && get_property("auto_edStatus") == "dying")
	{
		if($monsters[Man With The Red Buttons, Red Butler, Red Fox, Red Skeleton] contains enemy)
		{
			return useItem($item[Glark Cable]);
			// free insta-kill (optimal!)
		}
	}

	if (!get_property("edUsedLash").to_boolean() && canUse($skill[Lash of the Cobra]) && get_property("_edLashCount").to_int() < 30)
	{
		boolean doLash = false;

		if((enemy == $monster[Big Wheelin\' Twins]) && !possessEquipment($item[Badge Of Authority]))
		{
			doLash = true;
		}
		if((enemy == $monster[Fishy Pirate]) && !possessEquipment($item[Perfume-Soaked Bandana]))
		{
			doLash = true;
		}
		if((enemy == $monster[Funky Pirate]) && !possessEquipment($item[Sewage-Clogged Pistol]) && elementalPlanes_access($element[spooky]))
		{
			doLash = true;
		}
		if((enemy == $monster[Garbage Tourist]) && (item_amount($item[Bag of Park Garbage]) == 0))
		{
			doLash = true;
		}
		if (enemy == $monster[Dairy Goat] && item_amount($item[Goat Cheese]) < 3)
		{
			doLash = true;
		}
		if (enemy == $monster[Monstrous Boiler] && item_amount($item[Red-Hot Boilermaker]) < 1 && get_property("booPeakProgress").to_int() > 0)
		{
			doLash = true;
		}
		if (enemy == $monster[Fitness Giant] && item_amount($item[Pec Oil]) < 1 && get_property("booPeakProgress").to_int() > 0)
		{
			doLash = true;
		}
		if (enemy == $monster[Renaissance Giant] && item_amount($item[Ye Olde Meade]) < 1)
		{
			doLash = true;
		}
		if($monsters[Bearpig Topiary Animal, Elephant (Meatcar?) Topiary Animal, Spider (Duck?) Topiary Animal] contains enemy)
		{
			doLash = true;
		}
		if($monsters[Beanbat, Bookbat] contains enemy)
		{
			doLash = true;
		}
		if(((enemy == $monster[Toothy Sklelton]) || (enemy == $monster[Spiny Skelelton])) && (get_property("cyrptNookEvilness").to_int() > 26))
		{
			doLash = true;
		}
		if((enemy == $monster[Oil Baron]) && (item_amount($item[Bubblin\' Crude]) < 12) && (item_amount($item[Jar of Oil]) == 0))
		{
			doLash = true;
		}
		if((enemy == $monster[Blackberry Bush]) && (item_amount($item[Blackberry]) < 3) && !possessEquipment($item[Blackberry Galoshes]))
		{
			doLash = true;
		}
		if((enemy == $monster[Pygmy Bowler]) && (get_property("_edLashCount").to_int() < 26))
		{
			doLash = true;
		}
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			doLash = true;
		}
		if(enemy == $monster[Knob Goblin Madam])
		{
			if(item_amount($item[Knob Goblin Perfume]) == 0)
			{
				doLash = true;
			}
		}
		if(enemy == $monster[Knob Goblin Harem Girl])
		{
			if(!possessEquipment($item[Knob Goblin Harem Veil]) || !possessEquipment($item[Knob Goblin Harem Pants]))
			{
				doLash = true;
			}
		}
		if ((my_location() == $location[Hippy Camp] || my_location() == $location[Wartime Hippy Camp]) && contains_text(enemy, "hippy") && my_level() >= 12)
		{
			if(!possessEquipment($item[Filthy Knitted Dread Sack]) || !possessEquipment($item[Filthy Corduroys]))
			{
				if(get_property("auto_edStatus") != "dying")
				{
					doLash = true;
				}
			}
		}
		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doLash = true;
			}
		}
		if((enemy == $monster[Dopey 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Helmet]))
		{
			doLash = true;
		}
		if((enemy == $monster[Grumpy 7-Foot Dwarf]) && !possessEquipment($item[7-Foot Dwarven Mattock]))
		{
			doLash = true;
		}
		if((enemy == $monster[Sleepy 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Pants]))
		{
			doLash = true;
		}
		if((enemy == $monster[Burly Sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doLash = true;
		}
		if((enemy == $monster[Spunky Princess]) && !possessEquipment($item[Titanium Assault Umbrella]))
		{
			doLash = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doLash = true;
		}
		if(enemy == $monster[Warehouse Clerk])
		{
			int progress = get_property("warehouseProgress").to_int();
			progress = progress + (8 * item_amount($item[Warehouse Inventory Page]));
			if(progress < 50)
			{
				doLash = true;
			}
		}
		if(enemy == $monster[Warehouse Guard])
		{
			int progress = get_property("warehouseProgress").to_int();
			progress = progress + (8 * item_amount($item[Warehouse Map Page]));
			if(progress < 50)
			{
				doLash = true;
			}
		}
		if (enemy == $monster[Copperhead Club bartender] && internalQuestStatus("questL11Ron") < 2)
		{
			doLash = true;
		}

		if (doLash)
		{
			handleTracker(enemy, "auto_lashes");
			return useSkill($skill[Lash Of The Cobra]);
		}
	}

	if (canUse($item[Tattered Scrap of Paper], false))
	{
		if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, W imp] contains enemy)
		{
			return useItem($item[Tattered Scrap Of Paper], false);
		}
	}

	if (!contains_text(edCombatState, "talismanofrenenutet") && canUse($item[Talisman of Renenutet]))
	{
		boolean doRenenutet = false;
		if((enemy == $monster[Cabinet of Dr. Limpieza]) && ($location[The Haunted Laundry Room].turns_spent > 2))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Possessed Wine Rack]) && ($location[The Haunted Wine Cellar].turns_spent > 2))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Baa\'baa\'bu\'ran]) && (item_amount($item[Stone Wool]) < 2))
		{
			doRenenutet = true;
		}
		if ($monsters[Mountain Man, Warehouse Clerk, Warehouse Guard, waiter dressed as a ninja, ninja dressed as a waiter] contains enemy)
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Pygmy Janitor]) && (item_amount($item[Book of Matches]) == 0) && (get_property("hiddenTavernUnlock").to_int() != my_ascensions()))
		{
			doRenenutet = true;
		}
		if(enemy == $monster[Blackberry Bush])
		{
			if(!possessEquipment($item[Blackberry Galoshes]) && (item_amount($item[Blackberry]) < 3))
			{
				doRenenutet = true;
			}
		}
		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doRenenutet = true;
			}
		}
		if(doRenenutet)
		{
			if (!contains_text(edCombatState, "curseofindecision") && canUse($skill[Curse Of Indecision]))
			{
				set_property("auto_edCombatHandler", edCombatState + "(curseofindecision)");
				return useSkill($skill[Curse Of Indecision]);
			}
			set_property("auto_edCombatHandler", edCombatState + "(talismanofrenenutet)");
			handleTracker(enemy, "auto_renenutet");
			set_property("auto_edStatus", "dying");
			return useItem($item[Talisman Of Renenutet]);
		}
	}

	if(enemy == $monster[Pygmy Orderlies] && canUse($item[Short Writ of Habeas Corpus], false))
	{
		return useItem($item[Short Writ of Habeas Corpus]);
	}

	if(get_property("auto_edStatus") == "UNDYING!")
	{
		// We're taking a trip to the underworld. Either we want to abuse resurrection or we want to go shopping
		if(my_location() == $location[The Secret Government Laboratory])
		{
			if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
			{
				if((!contains_text(combatState, "love stinkbug")) && get_property("lovebugsUnlocked").to_boolean())
				{
					set_property("auto_combatHandler", combatState + "(love stinkbug2)");
					return "skill " + $skill[Summon Love Stinkbug];
				}
			}
		}

		if (canUse($item[Seal Tooth], false))
		{
			return useItem($item[Seal Tooth], false);
		}

		return useSkill($skill[Mild Curse], false);
	}

	// Actually killing stuff starts here
	if (my_location() == $location[The Secret Government Laboratory] && canUse($skill[Roar of the Lion], false))
	{
		if (canUse($skill[Storm Of The Scarab], false) && my_buffedstat($stat[Mysticality]) >= 60)
		{
			return useSkill($skill[Storm Of The Scarab], false);
		}
		return useSkill($skill[Roar Of The Lion], false);
	}

	if ($locations[Pirates of the Garbage Barges, The SMOOCH Army HQ, VYKEA] contains my_location() && canUse($skill[Storm of the Scarab], false))
	{
		return useSkill($skill[Storm Of The Scarab], false);
	}

	if ($locations[Hippy Camp, The Outskirts Of Cobb\'s Knob, The Spooky Forest, The Batrat and Ratbat Burrow, The Boss Bat\'s Lair, Cobb\'s Knob Harem] contains my_location() && canUse($skill[Fist Of The Mummy], false))
	{
		return useSkill($skill[Fist Of The Mummy], false);
	}

	int fightStat = my_buffedstat(weapon_type(equipped_item($slot[weapon]))) - 20;
	if((fightStat > monster_defense()) && (round < 20) && canSurvive(1.1) && (get_property("auto_edStatus") == "UNDYING!"))
	{
		return "attack with weapon";
	}

	if (canUse($skill[Cowboy Kick]))
	{
		return useSkill($skill[Cowboy Kick]);
	}

	if (canUse($item[Ice-Cold Cloaca Zero]) && my_mp() < 15 && my_maxmp() > 200)
	{
		return useItem($item[Ice-Cold Cloaca Zero]);
	}

	if (canUse($skill[Storm Of The Scarab], false) && my_buffedstat($stat[Mysticality]) > 35)
	{
		return useSkill($skill[Storm Of The Scarab], false);
	}

	if((enemy.physical_resistance >= 100) || (round >= 25) || canSurvive(1.25))
	{
		if (canUse($skill[Fist Of The Mummy], false))
		{
			return useSkill($skill[Fist Of The Mummy], false);
		}
	}

	if (my_mp() < mp_cost($skill[Storm Of The Scarab]))
	{
		foreach it in $items[Holy Spring Water, Spirit Beer, Sacramental Wine]
		{
			if(canUse(it))
			{
				return useItem(it, false);
			}
		}
	}

	if(round >= 29)
	{
		auto_log_error("About to UNDYING too much but have no other combat resolution. Please report this.", "red");
	}

	if((fightStat > monster_defense()) && (round < 20) && canSurvive(1.1) && (get_property("auto_edStatus") == "dying"))
	{
		auto_log_warning("Attacking with weapon because we don't have enough MP. Expected damage: " + expected_damage() + ", current hp: " + my_hp(), "red");
		return "attack with weapon";
	}

	return useSkill($skill[Mild Curse], false);
}
