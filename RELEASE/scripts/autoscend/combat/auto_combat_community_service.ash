//Path specific combat handling functions for Community Service

string cs_combatNormal(int round, monster enemy, string text)
{
	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}
	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat

	if(canUse($skill[Gulp Latte]) && !have_skill($skill[Turbo]) && ((3 * my_mp()) < my_maxmp()) && (my_maxmp() >= 300) && !get_property("_latteDrinkUsed").to_boolean() && !($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy))
	{
		return useSkill($skill[Gulp Latte]);
	}

	if(canUse($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])))
	{
		if($monsters[Flame-Broiled Meat Blob, Overdone Flame-Broiled Meat Blob, Swarm of Skulls] contains enemy)
		{
			handleTracker(enemy, $skill[Snokebomb], "auto_banishes");
			return useSkill($skill[Snokebomb]);
		}
	}

	if(canUse($skill[Throw Latte On Opponent]) && !get_property("_latteBanishUsed").to_boolean())
	{
		if($monsters[Undead Elbow Macaroni, Factory-Irregular Skeleton, Octorok] contains enemy)
		{
			handleTracker(enemy, $skill[Throw Latte On Opponent], "auto_banishes");
			return useSkill($skill[Throw Latte On Opponent]);
		}
	}

	if(canUse($skill[KGB Tranquilizer Dart]) && (get_property("_kgbTranquilizerDartUses").to_int() < 3))
	{
		if($monsters[Flame-Broiled Meat Blob, Keese, Overdone Flame-Broiled Meat Blob, Remaindered Skeleton] contains enemy)
		{
			handleTracker(enemy, $skill[KGB Tranquilizer Dart], "auto_banishes");
			return useSkill($skill[KGB Tranquilizer Dart]);
		}
	}

	if((my_familiar() == $familiar[Pair of Stomping Boots]) && ($monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains enemy))
	{
		return "runaway";
	}

	if(auto_macrometeoritesAvailable() > 0 && canUse($skill[Macrometeorite], false))
	{
		if(my_location() == $location[The Haiku Dungeon] &&
		$monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains enemy)
		{
			return useSkill($skill[Macrometeorite], false);
		}
		if(my_location() == $location[The Skeleton Store] &&
		$monsters[Factory-Irregular Skeleton, Remaindered Skeleton, Swarm of Skulls] contains enemy)
		{
			return useSkill($skill[Macrometeorite], false);
		}
	}


	if(my_location() == $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice])
	{
		foreach sk in $skills[Summon Love Gnats,Summon Love Stinkbug, Summon Love Mosquito]
		{
			if(!haveUsed(sk))
			{
				markAsUsed(sk);
			}
		}
	}

	if(enemy == $monster[LOV Enforcer] && my_familiar() == $familiar[Nosy Nose] && canSurvive(2.0))
	{
		return "attack with weapon";
	}
	if(enemy == $monster[LOV Engineer])
	{
		if(canUse($skill[Candyblast]) && (my_mp() > (mp_cost($skill[Candyblast]) * 3)) && (my_class() != $class[Sauceror]))
		{
			return useSkill($skill[Candyblast]);
		}

		if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}

	if(canUse($skill[Summon Love Gnats]))
	{
		return useSkill($skill[Summon Love Gnats]);
	}

	skill sniffer = getSniffer(enemy);
	if(sniffer != $skill[none] && !isSniffed(enemy))
	{
		boolean doSniff = false;
		boolean noTimeSpinner = item_amount($item[Time-Spinner]) == 0 || get_property("_timeSpinnerMinutesUsed").to_int() >= 8;
		if($monsters[Novelty Tropical Skeleton, Possessed Can of Tomatoes] contains enemy && noTimeSpinner)
		{
			doSniff = true;
		}
		if(($monster[Government Scientist] == enemy) && (item_amount($item[Experimental Serum G-9]) < 2))
		{
			doSniff = true;
		}

		if(doSniff)
		{
			if(canUse($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				return useSkill($skill[Curse Of Weaksauce]);
			}
			if(canUse($skill[Soul Bubble]))
			{
				return useSkill($skill[Soul Bubble]);
			}
			handleTracker(enemy, sniffer, "auto_sniffs");
			return useSkill(sniffer);
		}
	}

	if($monsters[creepy little girl, lab monkey, super-sized cola wars soldier] contains enemy && canUse($skill[CLEESH]) && item_amount($item[Experimental Serum G-9]) < 2)
	{
		return useSkill($skill[CLEESH]);
	}

	//used by [Little Geneticist DNA-Splicing Lab] iotm
	if(canUse($item[DNA extraction syringe]) && monster_level_adjustment() < 150)
	{
		if(monster_phylum(enemy) != to_phylum(get_property("dnaSyringe")))
		{
			return useItem($item[DNA extraction syringe]);
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
		if($monsters[Witchess Bishop, Witchess Knight] contains enemy)
		{
			return useSkill(wink_skill);
		}
	}

	boolean danger = false;
	if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod"))
	{
		danger = true;
	}
	if((my_location() == $location[The Secret Government Laboratory]) && get_property("controlPanel9").to_boolean())
	{
		if(canUse($skill[Curse Of Weaksauce]) && (my_mp() >= 32))
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}

		if(canUse($skill[Conspiratorial Whispers]) && (my_mp() >= 49))
		{
			return useSkill($skill[Conspiratorial Whispers]);
		}
		danger = true;
	}

	if(canUse($skill[Summon Love Stinkbug]) && get_property("lovebugsUnlocked").to_boolean() && !danger)
	{
		return useSkill($skill[Summon Love Stinkbug]);
	}

	if(canUse($skill[Digitize]) && (my_mp() > (mp_cost($skill[Digitize]) * 2)) && ($monsters[Witchess Bishop, Witchess Knight] contains enemy))
	{
		return useSkill($skill[Digitize]);
	}

	if(canUse($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && !danger)
	{
		return useSkill($skill[Extract]);
	}

	if(canUse($skill[Shattering Punch]) && ((my_mp() / 2) > mp_cost($skill[Shattering Punch])) && !isFreeMonster(enemy) && !enemy.boss && (get_property("_shatteringPunchUsed").to_int() < 3))
	{
		handleTracker(enemy, $skill[shattering punch], "auto_instakill");
		return useSkill($skill[Shattering Punch]);
	}

	if(canUse($skill[Gingerbread Mob Hit]) && ((my_mp() / 2) > mp_cost($skill[Gingerbread Mob Hit])) && !isFreeMonster(enemy) && !enemy.boss && !get_property("_gingerbreadMobHitUsed").to_boolean())
	{
		handleTracker(enemy, $skill[Gingerbread Mob Hit], "auto_instakill");
		return useSkill($skill[Gingerbread Mob Hit]);
	}

	if(canUse($skill[Curse Of Weaksauce]) && (my_mp() >= 32))
	{
		return useSkill($skill[Curse Of Weaksauce]);
	}

	if(canUse($skill[Candyblast]) && (my_mp() > (mp_cost($skill[Candyblast]) * 3)) && !danger && (my_class() != $class[Sauceror]))
	{
		return useSkill($skill[Candyblast]);
	}

	if(canUse($skill[Summon Love Mosquito]) && get_property("lovebugsUnlocked").to_boolean())
	{
		return useSkill($skill[Summon Love Mosquito]);
	}

	if(canUse($skill[Cowboy Kick]) && (monster_level_adjustment() <= 150))
	{
		return useSkill($skill[Cowboy Kick]);
	}

	if(canUse($item[Time-Spinner]))
	{
		return useItem($item[Time-Spinner]);
	}

	if(canUse($skill[Saucegeyser], false) && my_class() == $class[Sauceror])
	{
		return useSkill($skill[Saucegeyser], false);
	}

	if(canUse($skill[Entangling Noodles]) && (my_mp() >= (mp_cost($skill[Entangling Noodles]) + (2 * mp_cost($skill[Saucestorm])))) && (monster_level_adjustment() <= 150))
	{
		return useSkill($skill[Entangling Noodles]);
	}

	if(canUse($skill[Saucestorm], false))
	{
		return useSkill($skill[Saucestorm], false);
	}

	if(canUse($skill[salsaball], false))
	{
		return useSkill($skill[salsaball], false);
	}
	return "attack with weapon";
}

string cs_combatXO(int round, monster enemy, string text)
{
	# This assumes we have Volcano Charter, Meteor Love [sic], Snokebomb, XO Skeleton (not blocked by 100% run), and 50 MP, anything else and it probably fails
	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}
	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat

	if(my_familiar() != $familiar[XO Skeleton])
	{
		abort("In cs_combatXO without an XO to XOXO with");
	}

	if(my_location() == $location[LavaCo&trade; Lamp Factory])
	{
		if(!possessEquipment($item[Heat-Resistant Necktie]) || !possessEquipment($item[Heat-Resistant Gloves]) || !possessEquipment($item[Lava-Proof Pants]))
		{
			if(!combat_status_check("hugpocket") && (get_property("_xoHugsUsed").to_int() < 11))
			{
				combat_status_add("hugpocket");
				return useSkill($skill[Hugs And Kisses!], false);
			}
			if(combat_status_check("hugpocket") && auto_macrometeoritesAvailable() > 0 && canUse($skill[Macrometeorite], false))
			{
				remove_property("_auto_combatState");
				return useSkill($skill[Macrometeorite], false);
			}
		}
	}

	if(my_location() == $location[The Velvet / Gold Mine])
	{
		if((!possessEquipment($item[Fireproof Megaphone]) && !possessEquipment($item[Meteorite Guard])) || !possessEquipment($item[High-Temperature Mining Mask]))
		{
			if(!combat_status_check("hugpocket") && (get_property("_xoHugsUsed").to_int() < 11))
			{
				combat_status_add("hugpocket");
				return useSkill($skill[Hugs And Kisses!], false);
			}
			if(combat_status_check("hugpocket") && auto_macrometeoritesAvailable() > 0 && canUse($skill[Macrometeorite], false))
			{
				remove_property("_auto_combatState");
				return useSkill($skill[Macrometeorite], false);
			}
		}
	}

	if(!canUse($skill[Snokebomb]) || (get_property("_snokebombUsed").to_int() >= 3))
	{
		abort("Can not snoke that fire thing. We should probably smoke it instead.");
	}

	handleTracker(enemy, $skill[Snokebomb], "auto_banishes");
	return "skill " + $skill[Snokebomb];
}

string cs_combatYR(int round, monster enemy, string text)
{
	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}
	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat

	if(canUse($skill[Duplicate]) && (enemy == $monster[Sk8 Gnome]))
	{
		foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Summon Love Mosquito, Shell Up, Silent Slam, Summon Love Stinkbug, Extract, Duplicate]
		{
			if(canUse(action))
			{
				return useSkill(action);
			}
		}
	}

	if(canUse($skill[Summon Love Gnats]))
	{
		return useSkill($skill[Summon Love Gnats]);
	}
	
	//used by [Little Geneticist DNA-Splicing Lab] iotm
	if(canUse($item[DNA extraction syringe]) && monster_level_adjustment() < 150)
	{
		if(monster_phylum(enemy) != to_phylum(get_property("dnaSyringe")))
		{
			return useItem($item[DNA extraction syringe]);
		}
	}

	if((my_location() == $location[LavaCo&trade; Lamp Factory]) && have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Lava Golem] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
	}

	if((my_location() == $location[The Velvet / Gold Mine]) && have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Healing Crystal Golem] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
		if(possessEquipment($item[High-Temperature Mining Mask]))
		{
			if($monsters[Mine Worker (female), Mine Worker (male)] contains enemy)
			{
				return "skill " + $skill[Macrometeorite];
			}
		}
		else
		{
			if($monsters[Mine Overseer (female), Mine Overseer (male)] contains enemy)
			{
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(have_skill($skill[Disintegrate]) && (my_mp() < 150) && (have_effect($effect[Everything Looks Yellow]) == 0))
	{
		if(canUse($skill[Gulp Latte]) && !get_property("_latteDrinkUsed").to_boolean())
		{
			return useSkill($skill[Gulp Latte]);
		}
		if(canUse($skill[Turbo]))
		{
			return useSkill($skill[Turbo]);
		}
	}

	boolean [monster] lookFor = $monsters[Dairy Goat, Factory Overseer (female), Factory Overseer (male), Factory Worker (female), Factory Worker (male), Mine Overseer (male), Mine Overseer (female), Mine Worker (male), Mine Worker (female), sk8 Gnome];
	if((have_effect($effect[Everything Looks Yellow]) == 0) && (lookFor contains enemy))
	{
		if(!combat_status_check("yellowray"))
		{
			string combatAction = yellowRayCombatString(enemy, true);
			if(combatAction != "")
			{
				combat_status_add("yellowray");
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
				return combatAction;
			}
			else
			{
				abort("Wanted a yellow ray but we can not find one.");
			}
		}
	}

	if(canUse($skill[Summon Love Stinkbug]))
	{
		return useSkill($skill[Summon Love Stinkbug]);
	}
	if(canUse($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)))
	{
		return useSkill($skill[Extract]);
	}
	if(canUse($item[Time-Spinner]))
	{
		return useItem($item[Time-Spinner]);
	}
	if(canUse($skill[Summon Love Mosquito]))
	{
		return useSkill($skill[Summon Love Mosquito]);
	}
	if(canUse($skill[Salsaball], false))
	{
		return useSkill($skill[Salsaball], false);
	}
	return "attack with weapon";
}

string cs_combatKing(int round, monster enemy, string text)
{
	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}
	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat

	if(enemy != $monster[Witchess King])
	{
		abort("Wrong combat script called");
	}

	foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Tattle, Micrometeorite, Summon Love Mosquito, Shell Up, Silent Slam, Sauceshell, Summon Love Stinkbug, Extract, Turbo, Meteor Shower]
	{
		if(canUse(action))
		{
			return useSkill(action);
		}
	}

	return "attack with weapon";
}

string cs_combatWitch(int round, monster enemy, string text)
{
	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}
	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat

	if(enemy != $monster[Witchess Witch])
	{
		abort("Wrong combat script called");
	}
	foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Compress, Micrometeorite, Summon Love Mosquito, Summon Love Stinkbug, Meteor Shower]
	{
		if(canUse(action))
		{
			return useSkill(action);
		}
	}

	foreach action in $skills[Lunging Thrust-Smack, Thrust-Smack, Lunge Smack]
	{
		if(canUse(action, false))
		{
			return useSkill(action, false);
		}
	}

	return "attack with weapon";
}

string cs_combatLTB(int round, monster enemy, string text)
{
	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}
	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat

	if(canUse($skill[Giant Growth]))
	{
		if(item_amount($item[Green Mana]) == 0)
		{
			abort("We do not have a Green Mana, we should not have gotten here!");
		}
		return useSkill($skill[Giant Growth]);
	}
	if(!combat_status_check("giant growth"))
	{
		auto_log_warning("In cs_combatLTB handler, should have used giant growth but didn't!! WTF!! (" + have_skill($skill[Giant Growth]) + ")", "red");
	}

	if(isFreeMonster(enemy))
	{
		return cs_combatNormal(round, enemy, text);
	}

	if(canUse($skill[Shattering Punch]) && !isFreeMonster(enemy) && !enemy.boss && (get_property("_shatteringPunchUsed").to_int() < 3))
	{
		handleTracker(enemy, $skill[shattering punch], "auto_instakill");
		return useSkill($skill[Shattering Punch]);
	}

	foreach it in $items[Louder Than Bomb, Tennis Ball, Power Pill]
	{
		if(canUse(it))
		{
			if(item_amount($item[Seal Tooth]) > 0 && have_skill($skill[Ambidextrous Funkslinging]))
			{
				markAsUsed(it);
				return useItems(it, $item[Seal Tooth], false);
			}
			return useItem(it);
		}
	}

	abort("Could not free kill our Giant Growth, uh oh.");
	return "fail";
}
