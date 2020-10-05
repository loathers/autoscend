//Path specific combat handling functions for Community Service

string cs_combatNormal(int round, monster enemy, string text)
{
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	string combatState = get_property("auto_combatHandler");

	phylum current = to_phylum(get_property("dnaSyringe"));
	phylum type = monster_phylum(enemy);

	if(!contains_text(combatState, "lattegulp") && !have_skill($skill[Turbo]) && ((3 * my_mp()) < my_maxmp()) && (my_maxmp() >= 300) && !get_property("_latteDrinkUsed").to_boolean() && have_skill($skill[Gulp Latte]) && !($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy))
	{
		set_property("auto_combatHandler", combatState + "(lattegulp)");
		return "skill " + $skill[Gulp Latte];
	}

	if(!contains_text(combatState, "snokebomb") && have_skill($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])))
	{
		if($monsters[Flame-Broiled Meat Blob, Overdone Flame-Broiled Meat Blob, Swarm of Skulls] contains enemy)
		{
			set_property("auto_combatHandler", combatState + "(Snokebomb)");
			handleTracker(enemy, $skill[Snokebomb], "auto_banishes");
			return "skill " + $skill[Snokebomb];
		}
	}

	if(!contains_text(combatState, "throwlatte") && have_skill($skill[Throw Latte On Opponent]) && !get_property("_latteBanishUsed").to_boolean() && (my_mp() >= mp_cost($skill[Throw Latte On Opponent])))
	{
		if($monsters[Undead Elbow Macaroni, Factory-Irregular Skeleton, Octorok] contains enemy)
		{
			set_property("auto_combatHandler", combatState + "(throwlatte)");
			handleTracker(enemy, $skill[Throw Latte On Opponent], "auto_banishes");
			return "skill " + $skill[Throw Latte On Opponent];
		}
	}

	if(!contains_text(combatState, $skill[KGB Tranquilizer Dart]) && have_skill($skill[KGB Tranquilizer Dart]) && (get_property("_kgbTranquilizerDartUses").to_int() < 3))
	{
		if($monsters[Flame-Broiled Meat Blob, Keese, Overdone Flame-Broiled Meat Blob, Remaindered Skeleton] contains enemy)
		{
			set_property("auto_combatHandler", combatState + "(" + $skill[KGB Tranquilizer Dart] + ")");
			handleTracker(enemy, $skill[KGB Tranquilizer Dart], "auto_banishes");
			return "skill " + $skill[KGB Tranquilizer Dart];
		}
	}

	if((my_location() == $location[The Skeleton Store]) && have_skill($skill[Meteor Lore]) &&(get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Factory-Irregular Skeleton, Remaindered Skeleton, Swarm of Skulls] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
	}

	if((my_familiar() == $familiar[Pair of Stomping Boots]) && ($monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains enemy))
	{
		return "runaway";
	}

	if((my_location() == $location[The Haiku Dungeon]) && have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
	{
		if($monsters[Ancient Insane Monk, Ferocious Bugbear, Gelatinous Cube, Knob Goblin Poseur] contains enemy)
		{
			auto_log_info("Macrometeoring: " + enemy, "green");
			set_property("_macrometeoriteUses", 1 + get_property("_macrometeoriteUses").to_int());
			return "skill " + $skill[Macrometeorite];
		}
	}


	if((my_location() == $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]) && !contains_text(combatState, "love gnats"))
	{
		combatState = combatState + "(love gnats)(love stinkbug)(love mosquito)";
		set_property("auto_combatHandler", combatState);
	}

	if((enemy == $monster[LOV Enforcer]) && (my_familiar() == $familiar[Nosy Nose]))
	{
		if(my_hp() > (2*expected_damage()))
		{
			return "attack with weapon";
		}
	}
	if(enemy == $monster[LOV Engineer])
	{
		if(!contains_text(combatState, "(candyblast)") && have_skill($skill[Candyblast]) && (my_mp() > (mp_cost($skill[Candyblast]) * 3)) && (my_class() != $class[Sauceror]))
		{
			set_property("auto_combatHandler", combatState + "(candyblast)");
			return "skill " + $skill[Candyblast];
		}

		if(have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
		{
			return "skill " + $skill[Saucestorm];
		}
	}

	if(!contains_text(combatState, "love gnats") && have_skill($skill[Summon Love Gnats]))
	{
		set_property("auto_combatHandler", combatState + "(love gnats)");
		return "skill " + $skill[Summon Love Gnats];
	}

	if((have_effect($effect[On The Trail]) == 0) && have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])))
	{
		boolean doOlfaction = false;
		if((item_amount($item[Time-Spinner]) == 0) || (get_property("_timeSpinnerMinutesUsed").to_int() >= 8))
		{
			if($monsters[Novelty Tropical Skeleton, Possessed Can of Tomatoes] contains enemy)
			{
				doOlfaction = true;
			}
		}

		if(($monster[Government Scientist] == enemy) && (item_amount($item[Experimental Serum G-9]) < 2))
		{
			doOlfaction = true;
		}

		if(doOlfaction)
		{
			if(!contains_text(combatState, "weaksauce") && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				set_property("auto_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}
			if(!contains_text(combatState, "soulbubble") && have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
			{
				set_property("auto_combatHandler", combatState + "(soulbubble)");
				return "skill " + $skill[Soul Bubble];
			}

			set_property("auto_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "auto_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
	}

	if(!contains_text(combatState, "(lattesniff)") && have_skill($skill[Offer Latte To Opponent]) && (my_mp() >= mp_cost($skill[Offer Latte To Opponent])) && !get_property("_latteCopyUsed").to_boolean())
	{
		if(($monster[Government Scientist] == enemy) && (get_property("_latteMonster") != enemy))
		{
			if((!contains_text(combatState, "weaksauce")) && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				set_property("auto_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}
			if(!contains_text(combatState, "soulbubble") && have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
			{
				set_property("auto_combatHandler", combatState + "(soulbubble)");
				return "skill " + $skill[Soul Bubble];
			}

			set_property("auto_combatHandler", combatState + "(lattesniff)");
			handleTracker(enemy, $skill[Offer Latte To Opponent], "auto_sniffs");
			return "skill " + $skill[Offer Latte To Opponent];
		}
	}

	if(((have_effect($effect[On The Trail]) < 40) || (contains_text(combatState, "(lattesniff)"))) && have_skill($skill[Gallapagosian Mating Call]) && (my_mp() >= mp_cost($skill[Gallapagosian Mating Call])) && !contains_text(combatState, "(matingcall)"))
	{
		if(($monster[Government Scientist] == enemy) && (get_property("_gallapagosMonster") != enemy))
		{
			if((!contains_text(combatState, "weaksauce")) && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 72))
			{
				set_property("auto_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}
			if(!contains_text(combatState, "soulbubble") && have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
			{
				set_property("auto_combatHandler", combatState + "(soulbubble)");
				return "skill " + $skill[Soul Bubble];
			}

			set_property("auto_combatHandler", combatState + "(matingcall)");
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "auto_sniffs");
			return "skill " + $skill[Gallapagosian Mating Call];
		}
	}


	if(!contains_text(combatState, "cleesh") && have_skill($skill[Cleesh]) && (my_mp() > mp_cost($skill[Cleesh])) && ((enemy == $monster[creepy little girl]) || (enemy == $monster[lab monkey]) || (enemy == $monster[super-sized cola wars soldier])) && (item_amount($item[Experimental Serum G-9]) < 2))
	{
		set_property("auto_combatHandler", combatState + "(cleesh)");
		return "skill " + $skill[CLEESH];
	}

	if(!contains_text(combatState, "DNA") && (item_amount($item[DNA Extraction Syringe]) > 0))
	{
		if(type != current)
		{
			set_property("auto_combatHandler", combatState + "(DNA)");
			return "item " + $item[DNA Extraction Syringe];
		}
	}

	if(!contains_text(combatState, "winkat") && (my_familiar() == $familiar[Reanimated Reanimator]))
	{
		if($monsters[Witchess Bishop, Witchess Knight] contains enemy)
		{
			set_property("auto_combatHandler", combatState + "(winkat)");
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have animator out but can not arrow");
			}
			return "skill " + $skill[Wink At];
		}
	}

	if(!contains_text(combatState, "badlyromanticarrow") && (my_familiar() == $familiar[Obtuse Angel]))
	{
		if($monsters[Witchess Bishop, Witchess Knight] contains enemy)
		{
			set_property("auto_combatHandler", combatState + "(badlyromanticarrow)");
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have angel out but can not arrow");
			}
			return "skill " + $skill[Fire a Badly Romantic Arrow];
		}
	}

	boolean danger = false;
	if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod"))
	{
		danger = true;
	}
	if((my_location() == $location[The Secret Government Laboratory]) && get_property("controlPanel9").to_boolean())
	{
		if(!contains_text(combatState, "weaksauce") && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 32))
		{
			set_property("auto_combatHandler", combatState + "(weaksauce)");
			return "skill " + $skill[Curse Of Weaksauce];
		}

		if((!contains_text(combatState, "conspiratorialwhispers")) && (have_skill($skill[Conspiratorial Whispers])) && (my_mp() >= 49))
		{
			set_property("auto_combatHandler", combatState + "(conspiratorialwhispers)");
			return "skill " + $skill[Conspiratorial Whispers];
		}
		danger = true;
	}

	if(!contains_text(combatState, "love stinkbug") && get_property("lovebugsUnlocked").to_boolean() && !danger)
	{
		set_property("auto_combatHandler", combatState + "(love stinkbug)");
		return "skill " + $skill[Summon Love Stinkbug];
	}

	if(!contains_text(combatState, "(digitize)") && have_skill($skill[Digitize]) && (my_mp() > (mp_cost($skill[Digitize]) * 2)) && ($monsters[Witchess Bishop, Witchess Knight] contains enemy))
	{
		set_property("auto_combatHandler", combatState + "(digitize)");
		return "skill " + $skill[Digitize];
	}

	if(!contains_text(combatState, "(extract)") && have_skill($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && !danger)
	{
		set_property("auto_combatHandler", combatState + "(extract)");
		return "skill " + $skill[Extract];
	}

	if((!contains_text(combatState, "shattering punch")) && have_skill($skill[Shattering Punch]) && ((my_mp() / 2) > mp_cost($skill[Shattering Punch])) && !isFreeMonster(enemy) && !enemy.boss && (get_property("_shatteringPunchUsed").to_int() < 3))
	{
		set_property("auto_combatHandler", combatState + "(shattering punch)");
		handleTracker(enemy, $skill[shattering punch], "auto_instakill");
		return "skill " + $skill[shattering punch];
	}

	if(!contains_text(combatState, "gingerbread mob hit") && have_skill($skill[Gingerbread Mob Hit]) && ((my_mp() / 2) > mp_cost($skill[Gingerbread Mob Hit])) && !isFreeMonster(enemy) && !enemy.boss && !get_property("_gingerbreadMobHitUsed").to_boolean())
	{
		set_property("auto_combatHandler", combatState + "(gingerbread mob hit)");
		handleTracker(enemy, $skill[Gingerbread Mob Hit], "auto_instakill");
		return "skill " + $skill[Gingerbread Mob Hit];
	}

	if(!contains_text(combatState, "weaksauce") && have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 32))
	{
		set_property("auto_combatHandler", combatState + "(weaksauce)");
		return "skill " + $skill[Curse Of Weaksauce];
	}

	if(!contains_text(combatState, "(candyblast)") && have_skill($skill[Candyblast]) && (my_mp() > (mp_cost($skill[Candyblast]) * 3)) && !danger && (my_class() != $class[Sauceror]))
	{
		set_property("auto_combatHandler", combatState + "(candyblast)");
		return "skill " + $skill[Candyblast];
	}

	if(!contains_text(combatState, "love mosquito") && get_property("lovebugsUnlocked").to_boolean())
	{
		set_property("auto_combatHandler", combatState + "(love mosquito)");
		return "skill " + $skill[Summon Love Mosquito];
	}

	if(!contains_text(combatState, "cowboy kick") && have_skill($skill[Cowboy Kick]) && (monster_level_adjustment() <= 150))
	{
		set_property("auto_combatHandler", combatState + "(cowboy kick)");
		return "skill " + $skill[Cowboy Kick];
	}

	if(!contains_text(combatState, "(time-spinner)") && (item_amount($item[Time-Spinner]) > 0))
	{
		set_property("auto_combatHandler", combatState + "(time-spinner)");
		return "item " + $item[Time-Spinner];
	}

	if(have_skill($skill[Saucegeyser]) && (my_mp() >= mp_cost($skill[Saucegeyser])) && (my_class() == $class[Sauceror]))
	{
		return "skill " + $skill[Saucegeyser];
	}

	if(!contains_text(combatState, "entangling noodles") && have_skill($skill[Entangling Noodles]) && (my_mp() >= (mp_cost($skill[Entangling Noodles]) + (2 * mp_cost($skill[Saucestorm])))) && (monster_level_adjustment() <= 150))
	{
		set_property("auto_combatHandler", combatState + "(entangling noodles)");
		return "skill " + $skill[Entangling Noodles];
	}

	if(have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
	{
		return "skill " + $skill[Saucestorm];
	}

	if(have_skill($skill[Salsaball]) && (my_mp() >= mp_cost($skill[Salsaball])))
	{
		return "skill " + $skill[salsaball];
	}
	return "attack with weapon";
}

string cs_combatXO(int round, monster enemy, string text)
{
	# This assumes we have Volcano Charter, Meteor Love [sic], Snokebomb, XO Skeleton (not blocked by 100% run), and 50 MP, anything else and it probably fails
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	if(my_familiar() != $familiar[XO Skeleton])
	{
		abort("In cs_combatXO without an XO to XOXO with");
	}

	string combatState = get_property("auto_combatHandler");


	if(my_location() == $location[LavaCo&trade; Lamp Factory])
	{
		if(!possessEquipment($item[Heat-Resistant Necktie]) || !possessEquipment($item[Heat-Resistant Gloves]) || !possessEquipment($item[Lava-Proof Pants]))
		{
			if(!contains_text(combatState, "hugpocket") && (get_property("_xoHugsUsed").to_int() < 11))
			{
				set_property("auto_combatHandler", combatState + "(hugpocket)");
				return "skill " + $skill[Hugs And Kisses!];
			}
			if(contains_text(combatState, "hugpocket") && (get_property("_macrometeoriteUses").to_int() < 10))
			{
				set_property("auto_combatHandler", "");
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(my_location() == $location[The Velvet / Gold Mine])
	{
		if((!possessEquipment($item[Fireproof Megaphone]) && !possessEquipment($item[Meteorite Guard])) || !possessEquipment($item[High-Temperature Mining Mask]))
		{
			if(!contains_text(combatState, "hugpocket") && (get_property("_xoHugsUsed").to_int() < 11))
			{
				set_property("auto_combatHandler", combatState + "(hugpocket)");
				return "skill " + $skill[Hugs And Kisses!];
			}
			if(contains_text(combatState, "hugpocket") && (get_property("_macrometeoriteUses").to_int() < 10))
			{
				set_property("auto_combatHandler", "");
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(!have_skill($skill[Snokebomb]) || (my_mp() < mp_cost($skill[Snokebomb])) || (get_property("_snokebombUsed").to_int() >= 3))
	{
		abort("Can not snoke that fire thing. We should probably smoke it instead.");
	}

	handleTracker(enemy, $skill[Snokebomb], "auto_banishes");
	return "skill " + $skill[Snokebomb];
}

string cs_combatYR(int round, monster enemy, string text)
{
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	string combatState = get_property("auto_combatHandler");

	phylum current = to_phylum(get_property("dnaSyringe"));
	phylum type = monster_phylum(enemy);

	if(have_skill($skill[Duplicate]) && (enemy == $monster[Sk8 Gnome]))
	{
		foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Summon Love Mosquito, Shell Up, Silent Slam, Summon Love Stinkbug, Extract, Duplicate]
		{
			if((!contains_text(combatState, "(" + action + ")")) && have_skill(action) && (my_mp() > mp_cost(action)))
			{
				set_property("auto_combatHandler", combatState + "(" + action + ")");
				return "skill " + action;
			}
		}
	}

	if((!contains_text(combatState, "summon love gnats")) && have_skill($skill[Summon Love Gnats]))
	{
		set_property("auto_combatHandler", combatState + "(summon love gnats)");
		return "skill summon love gnats";
	}
	if((!contains_text(combatState, "DNA")) && (item_amount($item[DNA Extraction Syringe]) > 0))
	{
		if(type != current)
		{
			set_property("auto_combatHandler", combatState + "(DNA)");
			return "item DNA extraction syringe";
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
		if(!contains_text(combatState, "lattegulp") && !get_property("_latteDrinkUsed").to_boolean() && have_skill($skill[Gulp Latte]) && (my_mp() > mp_cost($skill[Gulp Latte])))
		{
			set_property("auto_combatHandler", combatState + "(lattegulp)");
			return "skill " + $skill[Gulp Latte];
		}
		if(!contains_text(combatState, "turbo") && have_skill($skill[Turbo]) && (my_mp() > mp_cost($skill[Turbo])))
		{
			set_property("auto_combatHandler", combatState + "(turbo)");
			return "skill " + $skill[Turbo];
		}
	}

	boolean [monster] lookFor = $monsters[Dairy Goat, Factory Overseer (female), Factory Overseer (male), Factory Worker (female), Factory Worker (male), Mine Overseer (male), Mine Overseer (female), Mine Worker (male), Mine Worker (female), sk8 Gnome];
	if((have_effect($effect[Everything Looks Yellow]) == 0) && (lookFor contains enemy))
	{
		if(!contains_text(combatState, "yellowray"))
		{
			if(have_skill($skill[Disintegrate]) && (my_mp() > mp_cost($skill[Disintegrate])) && (have_effect($effect[Everything Looks Yellow]) == 0))
			{
				set_property("auto_combatHandler", combatState + "(yellowray)");
				handleTracker(enemy, $skill[Disintegrate], "auto_yellowRays");
				return "skill " + $skill[Disintegrate];
			}
			string combatAction = yellowRayCombatString();
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
				return combatAction;
			}
			else
			{
				abort("Wanted a yellow ray but we can not find one.");
			}
		}
	}

	if((!contains_text(combatState, "summon love stinkbug")) && get_property("lovebugsUnlocked").to_boolean())
	{
		set_property("auto_combatHandler", combatState + "(summon love stinkbug)");
		return "skill summon love stinkbug";
	}
	if((!contains_text(combatState, "(extract)")) && have_skill($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)))
	{
		set_property("auto_combatHandler", combatState + "(extract)");
		return "skill " + $skill[Extract];
	}
	if((!contains_text(combatState, "(time-spinner)")) && (item_amount($item[Time-Spinner]) > 0))
	{
		set_property("auto_combatHandler", combatState + "(time-spinner)");
		return "item " + $item[Time-Spinner];
	}
	if((!contains_text(combatState, "summon love mosquito")) && get_property("lovebugsUnlocked").to_boolean())
	{
		set_property("auto_combatHandler", combatState + "(summon love mosquito)");
		return "skill summon love mosquito";
	}
	if(have_skill($skill[Salsaball]) && (my_mp() >= mp_cost($skill[Salsaball])))
	{
		return "skill " + $skill[Salsaball];
	}
	return "attack with weapon";
}

string cs_combatKing(int round, monster enemy, string text)
{
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	string combatState = get_property("auto_combatHandler");

	if(enemy != $monster[Witchess King])
	{
		abort("Wrong combat script called");
	}

	foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Tattle, Micrometeorite, Summon Love Mosquito, Shell Up, Silent Slam, Sauceshell, Summon Love Stinkbug, Extract, Turbo, Meteor Shower]
	{
		if((!contains_text(combatState, "(" + action + ")")) && have_skill(action) && (my_mp() > mp_cost(action)))
		{
			set_property("auto_combatHandler", combatState + "(" + action + ")");
			return "skill " + action;
		}
	}

	return "action with weapon";
}

string cs_combatWitch(int round, monster enemy, string text)
{
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	string combatState = get_property("auto_combatHandler");

	if(enemy != $monster[Witchess Witch])
	{
		abort("Wrong combat script called");
	}
	foreach action in $skills[Curse of Weaksauce, Conspiratorial Whispers, Compress, Micrometeorite, Summon Love Mosquito, Summon Love Stinkbug, Meteor Shower]
	{
		if((!contains_text(combatState, "(" + action + ")")) && have_skill(action) && (my_mp() > mp_cost(action)))
		{
			set_property("auto_combatHandler", combatState + "(" + action + ")");
			return "skill " + action;
		}
	}

	foreach action in $skills[Lunging Thrust-Smack, Thrust-Smack, Lunge Smack]
	{
		if(have_skill(action) && (my_mp() > mp_cost(action)))
		{
			return "skill " + action;
		}
	}

	return "action with weapon";
}

string cs_combatLTB(int round, monster enemy, string text)
{
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");
		set_property("auto_combatHandler", "");
	}

	if(round > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	string combatState = get_property("auto_combatHandler");
	if(!contains_text(combatState, "giant growth") && have_skill($skill[Giant Growth]))
	{
		if(item_amount($item[Green Mana]) == 0)
		{
			abort("We do not have a Green Mana, we should not have gotten here!");
		}
		set_property("auto_combatHandler", combatState + "(giant growth)");
		return "skill " + $skill[Giant Growth];
	}

	if(!contains_text(combatState, "giant growth"))
	{
		auto_log_warning("In cs_combatLTB handler, should have used giant growth but didn't!! WTF!! (" + have_skill($skill[Giant Growth]) + ")", "red");
	}


	if(isFreeMonster(enemy))
	{
		return cs_combatNormal(round, enemy, text);
	}

	if(!contains_text(combatState, "shattering punch") && have_skill($skill[Shattering Punch]) && (my_mp() >= mp_cost($skill[Shattering Punch])) && !isFreeMonster(enemy) && !enemy.boss && (get_property("_shatteringPunchUsed").to_int() < 3))
	{
		set_property("auto_combatHandler", combatState + "(shattering punch)");
		handleTracker(enemy, $skill[shattering punch], "auto_instakill");
		return "skill " + $skill[shattering punch];
	}

	if(!contains_text(combatState, "louder than bomb") && (item_amount($item[Louder Than Bomb]) > 0))
	{
		set_property("auto_combatHandler", combatState + "(louder than bomb)");

		if((item_amount($item[Seal Tooth]) > 0) && have_skill($skill[Ambidextrous Funkslinging]))
		{
			return "item louder than bomb, seal tooth";
		}
		return "item " + $item[Louder Than Bomb];
	}
	if(!contains_text(combatState, "tennis ball") && (item_amount($item[Tennis Ball]) > 0))
	{
		set_property("auto_combatHandler", combatState + "(tennis ball)");

		if((item_amount($item[Seal Tooth]) > 0) && have_skill($skill[Ambidextrous Funkslinging]))
		{
			return "item tennis ball, seal tooth";
		}
		return "item " + $item[Tennis Ball];
	}


	if(!contains_text(combatState, "power pill") && (item_amount($item[Power Pill]) > 0))
	{
		set_property("auto_combatHandler", combatState + "(power pill)");

		if((item_amount($item[Seal Tooth]) > 0) && have_skill($skill[Ambidextrous Funkslinging]))
		{
			return "item power pill, seal tooth";
		}
		return "item " + $item[Power Pill];
	}

	abort("Could not free kill our Giant Growth, uh oh.");
	return "fail";
}
