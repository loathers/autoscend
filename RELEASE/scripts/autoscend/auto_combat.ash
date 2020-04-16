script "auto_combat.ash"

monster ocrs_helper(string page);
void awol_helper(string page);
string auto_edCombatHandler(int round, string opp, string text);
string auto_combatHandler(int round, string opp, string text);

boolean registerCombat(string action);
boolean registerCombat(skill sk);
boolean registerCombat(item it);
boolean containsCombat(string action);
boolean containsCombat(skill sk);
boolean containsCombat(item it);

/*
*	Advance combat round, nothing happens.
*	/goto fight.php?action=useitem&whichitem=1
*
*	Advance combat round, stuff happens: No longer works 21/5/2018
*	/goto fight.php?action=skill&whichskill=$1
*/

// private prototypes
boolean haveUsed(skill sk)
{
	return get_property("auto_combatHandler").contains_text("(sk" + sk.to_int().to_string() + ")");
}

boolean haveUsed(item it)
{
	return get_property("auto_combatHandler").contains_text("(it" + it.to_int().to_string() + ")");
}

int usedCount(skill sk)
{
	matcher m = create_matcher("(sk" + sk.to_int().to_string() + ")", get_property("auto_combatHandler"));
	int count = 0;
	while(m.find())
	{
		++count;
	}
	return count;
}

int usedCount(item it)
{
	matcher m = create_matcher("(it" + it.to_int().to_string() + ")", get_property("auto_combatHandler"));
	int count = 0;
	while(m.find())
	{
		++count;
	}
	return count;
}

void markAsUsed(skill sk)
{
	set_property("auto_combatHandler", get_property("auto_combatHandler") + "(sk" + sk.to_int().to_string() + ")");
}

void markAsUsed(item it)
{
	if(it != $item[none])
	{
		set_property("auto_combatHandler", get_property("auto_combatHandler") + "(it" + it.to_int().to_string() + ")");
	}
}

boolean canUse(skill sk, boolean onlyOnce)
{
	if(onlyOnce && haveUsed(sk))
		return false;

	if(!auto_have_skill(sk))
		return false;

	if(my_mp() < mp_cost(sk) - combat_mana_cost_modifier() ||
		my_hp() <= hp_cost(sk) ||
		get_fuel() < fuel_cost(sk) ||
		my_lightning() < lightning_cost(sk) ||
		my_thunder() < thunder_cost(sk) ||
		my_rain() < rain_cost(sk) ||
		my_soulsauce() < soulsauce_cost(sk) ||
		my_pp() < zelda_ppCost(sk)
	)
		return false;

	record SkillSet
	{
		int count;
		boolean [skill] skills;
	};
	static SkillSet [int] exclusives;
	static
	{
		exclusives[exclusives.count()] = new SkillSet(1, $skills[Curse of Vichyssoise, Curse of Marinara, Curse of the Thousand Islands, Curse of Weaksauce]);
		exclusives[exclusives.count()] = new SkillSet(equipped_amount($item[Vampyric Cloake]), $skills[Become a Wolf, Become a Cloud of Mist, Become a Bat]);
		exclusives[exclusives.count()] = new SkillSet(1, $skills[Shadow Noodles, Entangling Noodles]);
		exclusives[exclusives.count()] = new SkillSet(1, $skills[Silent Slam, Silent Squirt, Silent Slice]);
		exclusives[exclusives.count()] = new SkillSet(equipped_amount($item[haiku katana]), $skills[The 17 Cuts, Falling Leaf Whirlwind, Spring Raindrop Attack, Summer Siesta, Winter\'s Bite Technique]);
		exclusives[exclusives.count()] = new SkillSet(equipped_amount($item[bottle-rocket crossbow]), $skills[Fire Red Bottle-Rocket, Fire Blue Bottle-Rocket, Fire Orange Bottle-Rocket, Fire Purple Bottle-Rocket, Fire Black Bottle-Rocket]);
		exclusives[exclusives.count()] = new SkillSet(1, $skills[Kodiak Moment, Grizzly Scene, Bear-Backrub, Bear-ly Legal, Bear Hug]);
	}

	foreach i, set in exclusives
	{
		if(set.skills contains sk)
		{
			int total = 0;
			foreach check in set.skills
			{
				total += usedCount(check);
			}
			if(total >= set.count)
			{
				return false;
			}
		}
	}

	return true;
}

boolean canUse(skill sk) // assume onlyOnce unless specified otherwise
{
	return canUse(sk, true);
}

boolean canUse(item it, boolean onlyOnce)
{
	if(onlyOnce && haveUsed(it))
		return false;

	if(item_amount(it) == 0)
		return false;

	if(!auto_is_valid(it))
		return false;

	return true;
}

boolean canUse(item it) // assume onlyOnce unless specified otherwise
{
	return canUse(it, true);
}

string useSkill(skill sk, boolean mark)
{
	if(mark)
		markAsUsed(sk);

	return "skill " + sk.name;
}

string useSkill(skill sk)
{
	return useSkill(sk, true);
}

string useItem(item it, boolean mark)
{
	if(mark)
		markAsUsed(it);
	return "item " + it;
}

string useItem(item it)
{
	return useItem(it, true);
}

string useItems(item it1, item it2, boolean mark)
{
	if(mark)
	{
		markAsUsed(it1);
		markAsUsed(it2);
	}
	return "item " + it1 + ", " + it2;
}

string useItems(item it1, item it2)
{
	return useItems(it1, it2, true);
}

// if you call this without actually doing what it returns it'll make me sad :(
string getStallString(monster enemy)
{
	if(canUse($skill[Summon Love Gnats]))
	{
		return useSkill($skill[Summon Love Gnats]);
	}

	if(canUse($skill[Beanscreen]))
	{
		return useSkill($skill[Beanscreen]);
	}

	if(canUse($skill[Broadside]))
	{
		return useSkill($skill[Broadside]);
	}

	if(canUse($skill[Mind Bullets]))
	{
		return useSkill($skill[Mind Bullets]);
	}

	if(canUse($skill[Snap Fingers]))
	{
		return useSkill($skill[Snap Fingers]);
	}

	if(canUse($skill[Soul Bubble]))
	{
		return useSkill($skill[Soul Bubble]);
	}

	if(canUse($skill[Blood Chains]))
	{
		return useSkill($skill[Blood Chains]);
	}

	if(canUse($skill[Hogtie]) && !haveUsed($skill[Beanscreen]) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
	{
		return useSkill($skill[Hogtie]);
	}

	return "";
}


string auto_combatHandler(int round, string opp, string text)
{
	#Yes, round 0, really.
	monster enemy = to_monster(opp);
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

	if(get_property("auto_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	if(my_path() == "One Crazy Random Summer")
	{
		enemy = ocrs_helper(text);
		enemy = last_monster();
	}
	if(my_path() == "Avatar of West of Loathing")
	{
		awol_helper(text);
	}

	phylum type = monster_phylum(enemy);
	phylum current = to_phylum(get_property("dnaSyringe"));

	string combatState = get_property("auto_combatHandler");
	int fingernailClippersLeft = get_property("auto_combatHandlerFingernailClippers").to_int();

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int mcd = monster_level_adjustment();

	boolean doBanisher = !get_property("kingLiberated").to_boolean();

	if(my_path() == "Disguises Delimit")
	{
		int majora = -1;
		matcher maskMatch = create_matcher("mask(\\d+).png", text);
		if(maskMatch.find())
		{
			majora = maskMatch.group(1).to_int();
			if(round == 0)
			{
				auto_log_info("Found mask: " + majora, "green");
			}
		}
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

	if((enemy == $monster[Your Shadow]) || (opp == "shadow cow puncher") || (opp == "shadow snake oiler") || (opp == "shadow beanslinger") || (opp == "shadow gelatinous noob") || (opp == "Shadow Plumber"))
	{
		if(in_zelda())
		{
			if(item_amount($item[super deluxe mushroom]) > 0)
			{
				return "item " + $item[super deluxe mushroom];
			}
			abort("Oh no, I don't have any super deluxe mushrooms to deal with this shadow plumber :(");
		}
		if(auto_have_skill($skill[Ambidextrous Funkslinging]))
		{
			if(item_amount($item[Gauze Garter]) >= 2)
			{
				return "item " + $item[Gauze Garter] + ", " + $item[Gauze Garter];
			}
			if(item_amount($item[Filthy Poultice]) >= 2)
			{
				return "item " + $item[filthy Poultice] + ", " + $item[Filthy Poultice];
			}
			if((item_amount($item[Gauze Garter]) > 0) && (item_amount($item[Filthy Poultice]) > 0))
			{
				return "item " + $item[Gauze Garter] + ", " + $item[Filthy Poultice];
			}
		}
		if(item_amount($item[Gauze Garter]) > 0)
		{
			return "item " + $item[Gauze Garter];
		}
		if(item_amount($item[Filthy Poultice]) > 0)
		{
			return "item " + $item[Filthy Poultice];
		}
		if(item_amount($item[Rain-Doh Indigo Cup]) > 0)
		{
			return "item " + $item[Rain-Doh Indigo Cup];
		}
		abort("Uh oh, I ran out of gauze garters and filthy poultices");
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
		if(!($monsters[Dairy Goat, Lobsterfrogman, Writing Desk] contains enemy) && !($locations[The Laugh Floor, Infernal Rackets Backstage] contains my_location())  )
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

	//Heavy Rain Boss debuffing
	if($monsters[Big Wisnaqua, The Aquaman, The Big Wisniewski, The Man, The Rain King] contains enemy)
	{
		//Against bosses set how many [Thunder Bird] we want to cast during round 1
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
			targetThunderBird = min(my_thunder(), targetThunderBird);
			set_property("auto_combatHandlerThunderBird", targetThunderBird);
		}
	
		//if enemy ML is too high then they cannot be staggered, and at that point curse of weaksauce is less useful as it reduces by a fixed amount.
		if(canUse($skill[Curse Of Weaksauce]) && my_mp() >= 30 && auto_have_skill($skill[Itchy Curse Finger]) && monster_level_adjustment() <= 150)
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}
	}
	
	// Heavy rain repeated debuffing over multiple combat rounds using [Thunder Bird] skill.
	if(get_property("auto_combatHandlerThunderBird").to_int() > 0 && canUse($skill[Thunder Bird], false))
	{
		set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 1);
		return useSkill($skill[Thunder Bird], false);
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

	if(!in_zelda() && canUse($skill[Gulp Latte]) && (get_property("_latteRefillsUsed").to_int() == 0) && !get_property("_latteDrinkUsed").to_boolean())
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

	if(canUse($skill[Wink At]) && (my_familiar() == $familiar[Reanimated Reanimator]))
	{
		if($monsters[Lobsterfrogman, Modern Zmobie, Ninja Snowman Assassin] contains enemy)
		{
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (round <= 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have animator out but can not arrow");
			}
			if(enemy == $monster[modern zmobie])
			{
				set_property("auto_waitingArrowAlcove", get_property("cyrptAlcoveEvilness").to_int() - 20);
			}
			return useSkill($skill[Wink At]);
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

	if(canUse($skill[Extract]) && get_property("kingLiberated").to_boolean())
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
		if(($locations[Barrrney\'s Barrr, The Obligatory Pirate\'s Cove] contains my_location()) || ((enemy == $monster[Gaudy Pirate]) && (my_location() != $location[Belowdecks])))
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

	if(contains_text(combatState, "yellowray"))
	{
		abort("Ugh, where is my damn yellowray!!!");
	}

	if(item_amount($item[Green Smoke Bomb]) > 0)
	{
		if($monsters[Animated Possessions, Natural Spider] contains enemy)
		{
			return "item " + $item[Green Smoke Bomb];
		}
	}

	if(!get_property("kingLiberated").to_boolean())
	{
		if(item_amount($item[short writ of habeas corpus]) > 0)
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
			#abort("Banisher considered here. Weee");
			#wait(10);
			#banishAction = "";
		}
		if(banishAction != "")
		{
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
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
			{
				handleTracker(enemy, $skill[Chest X-Ray], "auto_instakill");
				loopHandlerDelayAll();
				return useSkill($skill[Chest X-Ray]);
			}
		}
		if(canUse($skill[shattering punch]) && (get_property("_shatteringPunchUsed").to_int() < 3))
		{
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
			{
				handleTracker(enemy, $skill[shattering punch], "auto_instakill");
				loopHandlerDelayAll();
				return useSkill($skill[shattering punch]);
			}
		}
		if(canUse($skill[Gingerbread Mob Hit]) && !get_property("_gingerbreadMobHitUsed").to_boolean())
		{
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
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

	if(canUse($skill[Intimidating Bellow]) && (my_mp() >= 25) && auto_have_skill($skill[Louder Bellows]))
	{
		return useSkill($skill[Intimidating Bellow]);
	}

	if(enemy == $monster[Eldritch Tentacle])
	{
		mcd = 151;
	}

	// if(enemy == $monster[invader bullet]) // TODO: on version bump
	if(enemy.to_string().to_lower_case() == "invader bullet")
	{
		mcd = 151;
	}

	if($monsters[Naughty Sorceress, Naughty Sorceress (2)] contains enemy && !get_property("auto_confidence").to_boolean())
	{
		mcd = 151;
	}

	#Default behaviors:
	if(mcd <= 150)
	{
		if(canUse($skill[Curse of Weaksauce]) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}

		if($item[Daily Affirmation: Keep Free Hate In Your Heart].combat)
		{
			if(canUse($item[Daily Affirmation: Keep Free Hate In Your Heart]) && get_property("kingLiberated").to_boolean() && hippy_stone_broken() && !get_property("_affirmationHateUsed").to_boolean())
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

		if(canUse($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 20) && doWeaksauce)
		{
			return useSkill($skill[Curse Of Weaksauce]);
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

		if(my_location() == $location[The Haunted Kitchen] && equipped_amount($item[vampyric cloake]) > 0 && get_property("_vampyreCloakeFormUses").to_int() < 10)
		{
			int hot = to_int(numeric_modifier("Hot Resistance"));
			int stench = to_int(numeric_modifier("Stench Resistance"));

			if(((hot < 9 && hot % 3 != 0) || (stench < 9 && stench % 3 != 0)) && canUse($skill[Become a Cloud of Mist]))
			{
				return useSkill($skill[Become a Cloud of Mist]);
			}
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
	if(mcd < 100 && stunnable(enemy))
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

	if(canUse($skill[Candyblast]) && (my_mp() > 60) && get_property("kingLiberated").to_boolean())
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

	if(canUse($skill[Duplicate]) && (get_property("_sourceTerminalDuplicateUses").to_int() == 0) && !get_property("kingLiberated").to_boolean() && (auto_my_path() != "Nuclear Autumn"))
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

	if(canUse($skill[Digitize]) && (get_property("_sourceTerminalDigitizeUses").to_int() == 0) && !get_property("kingLiberated").to_boolean())
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

	if(canUse($skill[Digitize]) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3) && !get_property("kingLiberated").to_boolean())
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

	if (my_class() == $class[Plumber])
	{
		// note: Juggle Fireballs CAN be used multiple times, but it is only
		// useful if you have level 3 fire and therefore get healed

		if(my_pp() > 2 && canUse($skill[[7332]Juggle Fireballs], true))
		{
			return useSkill($skill[[7332]Juggle Fireballs]);
		}

		if ((enemy.physical_resistance >= 80) ||
		    (my_location() == $location[The Smut Orc Logging Camp] && (0 < equipped_amount($item[frosty button]))))
		{
			if (canUse($skill[[7333]Fireball Barrage], false))
			{
				return useSkill($skill[[7333]Fireball Barrage]);
			}
			//this skill comes from the IOTM Beach Comb
			if (canUse($skill[Beach Combo], true))
			{
				return useSkill($skill[Beach Combo]);
			}
			if (canUse($skill[Fireball Toss], false))
			{
				return useSkill($skill[Fireball Toss], false);
			}
		}

		if (canUse($skill[[7336]Multi-Bounce], false))
		{
			return useSkill($skill[[7336]Multi-Bounce]);
		}
		//this skill comes from the IOTM Beach Comb
		if (canUse($skill[Beach Combo], true))
		{
			return useSkill($skill[Beach Combo]);
		}
		if (canUse($skill[Jump Attack], false))
		{
			return useSkill($skill[Jump Attack], false);
		}

		// Fallback, since maybe we only have fire flower equipped.
		if (canUse($skill[[7333]Fireball Barrage], false))
		{
			return useSkill($skill[[7333]Fireball Barrage]);
		}
		return useSkill($skill[Fireball Toss], false);
	}

	string attackMinor = "attack with weapon";
	string attackMajor = "attack with weapon";
	int costMinor = 0;
	int costMajor = 0;
	string stunner = "";
	int costStunner = 0;

	switch(my_class())
	{
	case $class[Seal Clubber]:
		attackMinor = "attack with weapon";
		if(canUse($skill[Lunge Smack], false) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMinor = useSkill($skill[Lunge Smack], false);
			costMinor = mp_cost($skill[Lunge Smack]);
		}
		if(canUse($skill[Lunging Thrust-Smack], false) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMajor = useSkill($skill[Lunging Thrust-Smack], false);
			costMajor = mp_cost($skill[Lunging Thrust-Smack]);
		}
		if(canUse($skill[Club Foot], false))
		{
			stunner = useSkill($skill[Club Foot], false);
			costStunner = mp_cost($skill[Club Foot]);
		}
		break;
	case $class[Turtle Tamer]:
		attackMinor = "attack with weapon";
		if((my_mp() > 150) && canUse($skill[Shieldbutt], false) && hasShieldEquipped())
		{
			attackMinor = useSkill($skill[Shieldbutt], false);
			costMinor = mp_cost($skill[Shieldbutt]);
		}
		else if((my_mp() > 80) && ((my_hp() * 2) < my_maxhp()) && canUse($skill[Kneebutt], false))
		{
			attackMinor = useSkill($skill[Kneebutt], false);
			costMinor = mp_cost($skill[Kneebutt]);
		}
		if(((round > 15) || ((my_hp() * 2) < my_maxhp())) && canUse($skill[Kneebutt], false))
		{
			attackMajor = useSkill($skill[Kneebutt], false);
			costMajor = mp_cost($skill[Kneebutt]);
		}
		if(canUse($skill[Shieldbutt], false) && hasShieldEquipped())
		{
			attackMajor = useSkill($skill[Shieldbutt], false);
			costMajor = mp_cost($skill[Shieldbutt]);
		}
		if(canUse($skill[Shell Up], false)) // can't mark it when using it as the generic stunner
		{
			stunner = useSkill($skill[Shell Up], false);
			costStunner = mp_cost($skill[Shell Up]);
		}

		if(((monster_defense() - my_buffedstat(weapon_type(equipped_item($slot[Weapon])))) > 20) && canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;
	case $class[Pastamancer]:
		if(canUse($skill[Cannelloni Cannon], false))
		{
			attackMinor = useSkill($skill[Cannelloni Cannon], false);
			costMinor = mp_cost($skill[Cannelloni Cannon]);
		}
		if(canUse($skill[Weapon of the Pastalord], false))
		{
			attackMajor = useSkill($skill[Weapon of the Pastalord]);
			costMajor = mp_cost($skill[Weapon of the Pastalord]);
		}
		if(canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			attackMinor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		if(canUse($skill[Utensil Twist], false) && (item_type(equipped_item($slot[weapon])) == "utensil"))
		{
			if(equipped_item($slot[weapon]) == $item[Hand That Rocks the Ladle])
			{
				attackMajor = useSkill($skill[Utensil Twist], false);
				attackMinor = useSkill($skill[Utensil Twist], false);
				costMinor = mp_cost($skill[Utensil Twist]);
				costMajor = mp_cost($skill[Utensil Twist]);
			}
			else if((enemy.physical_resistance <= 80) && (attackMinor != useSkill($skill[Saucestorm], false)))
			{
				attackMinor = useSkill($skill[Utensil Twist], false);
				costMinor = mp_cost($skill[Utensil Twist]);
			}
		}
		if(canUse($skill[Entangling Noodles], false))
		{
			stunner = useSkill($skill[Entangling Noodles], false);
			costStunner = mp_cost($skill[Entangling Noodles]);
		}
		break;
	case $class[Sauceror]:
		if(canUse($skill[Saucegeyser], false))
		{
			attackMinor = useSkill($skill[Saucegeyser], false);
			attackMajor = useSkill($skill[Saucegeyser], false);
			costMinor = mp_cost($skill[Saucegeyser]);
			costMajor = mp_cost($skill[Saucegeyser]);
		}
		else if(canUse($skill[Saucecicle], false) && (monster_element(enemy) != $element[cold]))
		{
			attackMinor = useSkill($skill[Saucecicle], false);
			attackMajor = useSkill($skill[Saucecicle], false);
			costMinor = mp_cost($skill[Saucecicle]);
			costMajor = mp_cost($skill[Saucecicle]);
		}
		else if(canUse($skill[Saucestorm], false))
		{
			attackMinor = useSkill($skill[Saucestorm], false);
			attackMajor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		else if(canUse($skill[Wave of Sauce], false) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = useSkill($skill[Wave of Sauce], false);
			attackMajor = useSkill($skill[Wave of Sauce], false);
			costMinor = mp_cost($skill[Wave of Sauce]);
			costMajor = mp_cost($skill[Wave of Sauce]);
		}
		else if(canUse($skill[Stream of Sauce], false) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = useSkill($skill[Stream of Sauce], false);
			attackMajor = useSkill($skill[Stream of Sauce], false);
			costMinor = mp_cost($skill[Stream of Sauce]);
			costMajor = mp_cost($skill[Stream of Sauce]);
		}

		if(my_soulsauce() >= 5)
		{
			stunner = useSkill($skill[Soul Bubble]);
			costStunner = mp_cost($skill[Soul Bubble]);
		}

		if(!contains_text(combatState, "delaymortarshell") && canSurvive(2.0) && haveUsed($skill[Stuffed Mortar Shell]) && canUse($skill[Salsaball], false))
		{
			set_property("auto_combatHandler", combatState + "(delaymortarshell)");
			return useSkill($skill[Salsaball], false);
		}

		break;

	case $class[Avatar of Boris]:
		if(canUse($skill[Heroic Belch], false) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && (my_fullness() >= 5))
		{
			attackMinor = useSkill($skill[Heroic Belch], false);
			attackMajor = useSkill($skill[Heroic Belch], false);
			costMinor = mp_cost($skill[Heroic Belch]);
			costMajor = mp_cost($skill[Heroic Belch]);
		}

		if(canUse($skill[Broadside], false))
		{
			stunner = useSkill($skill[Broadside], false);
			costStunner = mp_cost($skill[Broadside]);
		}
		break;

	case $class[Avatar of Sneaky Pete]:
		if(canUse($skill[Peel Out]))
		{
			if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, Tomb Asp, Tomb Servant,  W imp] contains enemy)
			{
				return useSkill($skill[Peel Out]);
			}
		}


		if(canUse($item[Firebomb], false) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]))
		{
			return useItem($item[Firebomb], false);
		}

		if(canUse($skill[Pop Wheelie]) && (my_mp() > 40))
		{
			return useSkill($skill[Pop Wheelie]);
		}

		if(canUse($skill[Snap Fingers], false))
		{
			stunner = useSkill($skill[Snap Fingers], false);
			costStunner = mp_cost($skill[Snap Fingers]);
		}

		break;

	case $class[Accordion Thief]:

		if(canUse($skill[Cadenza]) && (item_type(equipped_item($slot[weapon])) == "accordion") && canSurvive(2.0))
		{
			if($items[accordion file, alarm accordion, autocalliope, bal-musette accordion, baritone accordion, cajun accordion, ghost accordion, peace accordion, pentatonic accordion, pygmy concertinette, skipper\'s accordion, squeezebox of the ages, the trickster\'s trikitixa] contains equipped_item($slot[weapon]))
			{
				return useSkill($skill[Cadenza]);
			}
		}

		if(canUse($skill[Accordion Bash], false) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			stunner = useSkill($skill[Accordion Bash], false);
			costStunner = mp_cost($skill[Accordion Bash]);
		}

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		if(enemy.physical_resistance > 80 && canUse($skill[Saucestorm], false))
		{
			attackMinor = useSkill($skill[Saucestorm], false);
			attackMinor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;

	case $class[Disco Bandit]:

		if(auto_have_skill($skill[Disco State of Mind]) && auto_have_skill($skill[Flashy Dancer]) && auto_have_skill($skill[Disco Greed]) && auto_have_skill($skill[Disco Bravado]) && monster_level_adjustment() < 150)
		{
			float mpRegen = (numeric_modifier("MP Regen Min") + numeric_modifier("MP Regen Max")) / 2;
			int netCost = 0;

			foreach dance in $skills[Disco Dance of Doom, Disco Dance II: Electric Boogaloo, Disco Dance 3: Back in the Habit]
			{
				netCost += mp_cost(dance);
				if(canUse(dance) && mpRegen > netCost * 2)
				{
					return useSkill(dance);
				}
			}
		}

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		if(enemy.physical_resistance > 80 && canUse($skill[Saucestorm], false))
		{
			attackMinor = useSkill($skill[Saucestorm], false);
			attackMinor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;

	case $class[Cow Puncher]:
	case $class[Beanslinger]:
	case $class[Snake Oiler]:
		if(canUse($skill[Extract Oil]) && (my_hp() > 80) && (my_mp() >= (3 * mp_cost($skill[Extract Oil]))))
		{
			if($monsters[Aggressive grass snake, Bacon snake, Batsnake, Black adder, Burning Snake of Fire, Coal snake, Diamondback rattler, Frontwinder, Frozen Solid Snake, King snake, Licorice snake, Mutant rattlesnake, Prince snake, Sewer snake with a sewer snake in it, Snakeleton, The Snake with Like Ten Heads, Tomb asp, Trouser Snake, Whitesnake] contains enemy && (item_amount($item[Snake Oil]) < 4))
			{
				return useSkill($skill[Extract Oil]);
			}
			else if(($phylums[beast, dude, hippy, humanoid, orc, pirate] contains type) && (item_amount($item[Skin Oil]) < 3))
			{
				return useSkill($skill[Extract Oil]);
			}
			else if(($phylums[bug, construct, constellation, demon, elemental, elf, fish, goblin, hobo, horror, mer-kin, penguin, plant, slime, weird] contains type) && (item_amount($item[Unusual Oil]) < 4))
			{
				return useSkill($skill[Extract Oil]);
			}
			else if(($phylums[undead] contains type) && (item_amount($item[Skin Oil]) < 5))
			{
				return useSkill($skill[Extract Oil]);
			}
		}
		if(canUse($skill[Good Medicine]) && (my_mp() >= (3 * mp_cost($skill[Good Medicine]))))
		{
			return useSkill($skill[Good Medicine]);
		}

		if(canUse($skill[Hogtie]) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			return useSkill($skill[Hogtie]);
		}

		if(canUse($skill[Lavafava], false) && (enemy.defense_element != $element[hot]))
		{
			attackMajor = useSkill($skill[Lavafava], false);
			attackMinor = useSkill($skill[Lavafava], false);
			costMajor = mp_cost($skill[Lavafava]);
			costMinor = mp_cost($skill[Lavafava]);
		}
		if(canUse($skill[Beanstorm], false))
		{
			attackMajor = useSkill($skill[Beanstorm], false);
			attackMinor = useSkill($skill[Beanstorm], false);
			costMajor = mp_cost($skill[Beanstorm]);
			costMinor = mp_cost($skill[Beanstorm]);
		}

		if(canUse($skill[Fan Hammer], false))
		{
			attackMajor = useSkill($skill[Fan Hammer], false);
			attackMinor = useSkill($skill[Fan Hammer], false);
			costMajor = mp_cost($skill[Fan Hammer]);
			costMinor = mp_cost($skill[Fan Hammer]);
		}
		if(canUse($skill[Snakewhip], false) && (enemy.physical_resistance < 80))
		{
			attackMajor = useSkill($skill[Snakewhip], false);
			attackMinor = useSkill($skill[Snakewhip], false);
			costMajor = mp_cost($skill[Snakewhip]);
			costMinor = mp_cost($skill[Snakewhip]);
		}

		if(canUse($skill[Pungent Mung], false) && (enemy.defense_element != $element[stench]))
		{
			attackMajor = useSkill($skill[Pungent Mung], false);
			attackMinor = useSkill($skill[Pungent Mung], false);
			costMajor = mp_cost($skill[Pungent Mung]);
			costMinor = mp_cost($skill[Pungent Mung]);
		}

		if(canUse($skill[Cowcall], false) && (type != $phylum[undead]) && (enemy.defense_element != $element[spooky]) && (have_effect($effect[Cowrruption]) >= 60 || my_class() == $class[Cow Puncher]))
		{
			attackMajor = useSkill($skill[Cowcall], false);
			attackMinor = useSkill($skill[Cowcall], false);
			costMajor = mp_cost($skill[Cowcall]);
			costMinor = mp_cost($skill[Cowcall]);
		}

		if(canUse($skill[Beanscreen], false) && canSurvive(2.0))
		{
			stunner = useSkill($skill[Beanscreen], false);
			costStunner = mp_cost($skill[Beanscreen]);
		}

		if(canUse($skill[Hogtie], false) && (my_mp() >= (3 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			stunner = useSkill($skill[Hogtie], false);
			costStunner = mp_cost($skill[Hogtie]);
		}
		break;

	case $class[Vampyre]:
		foreach sk in $skills[Chill of the Tomb, Blood Spike, Piercing Gaze, Savage Bite]
		{
			if(sk == $skill[Chill of the Tomb] && enemy.monster_element() == $element[cold])
				continue;
			if(canUse(sk, false) && my_hp() > 3 * hp_cost(sk))
			{
				attackMajor = useSkill(sk, false);
				attackMinor = useSkill(sk, false);
				break;
			}
		}
		// Hack for Logging Camp: deprioritize Dark Feast, use Chill of the Tomb aggressively
		if(my_hp() > 0.5 * my_maxhp() && attackMajor == useSkill($skill[Chill of the Tomb], false) && my_location() == $location[The Smut Orc Logging Camp])
		{
			break;
		}
		if(my_hp() < my_maxhp() && (monster_hp() <= 30 || (monster_hp() <= 100 && auto_have_skill($skill[Hypnotic Eyes]))) && canUse($skill[Dark Feast]))
		{
			return useSkill($skill[Dark Feast]);
		}
		if(canUse($skill[Blood Chains], false) && my_hp() > 3 * hp_cost($skill[Blood Chains]))
			stunner = useSkill($skill[Blood Chains], false);
		// intentionally not setting costMinor or costMajor since they don't cost mp...

		// If we're in a form or something, a beehive is probably better than just attacking
		if(attackMajor == "attack with weapon" && !have_skill($skill[Preternatural Strength]) && canUse($item[beehive]) && ($stat[moxie] != weapon_type(equipped_item($slot[Weapon]))))
		{
			attackMajor = useItem($item[beehive], false);
			attackMinor = useItem($item[beehive], false);
		}
		break;
	}

	if(round <= 25)
	{
		if(((my_hp() * 10)/3) < my_maxhp())
		{
			if(canUse($skill[Thunderstrike]) && (monster_level_adjustment() <= 150))
			{
				return useSkill($skill[Thunderstrike]);
			}

			if(!contains_text(combatState, "stunner") && (stunner != "") && (monster_level_adjustment() <= 100) && (my_mp() >= costStunner) && stunnable(enemy))
			{
				set_property("auto_combatHandler", combatState + "(stunner)");
				return stunner;
			}

			if(canUse($skill[Unleash The Greash]) && (monster_element(enemy) != $element[sleaze]) && (have_effect($effect[Takin\' It Greasy]) > 100))
			{
				return useSkill($skill[Unleash The Greash]);
			}
			if(canUse($skill[Thousand-Yard Stare]) && (monster_element(enemy) != $element[spooky]) && (have_effect($effect[Intimidating Mien]) > 100))
			{
				return useSkill($skill[Thousand-Yard Stare]);
			}
			if($monsters[Aquagoblin, Lord Soggyraven] contains enemy)
			{
				return attackMajor;
			}
			if((my_class() == $class[Turtle Tamer]) && canUse($skill[Spirit Snap]))
			{
				if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
				{
					return useSkill($skill[Spirit Snap]);
				}
			}
			if(canUse($skill[Northern Explosion]) && (my_class() == $class[Seal Clubber]) && (monster_element(enemy) != $element[cold]))
			{
				return useSkill($skill[Northern Explosion]);
			}
			if((!contains_text(combatState, "last attempt")) && (my_mp() >= costMajor))
			{
				if(canSurvive(1.4))
				{
					set_property("auto_combatHandler", combatState + "(last attempt)");
					auto_log_warning("Uh oh, I'm having trouble in combat.", "red");
				}
				return attackMajor;
			}
			if(canSurvive(2.5))
			{
				auto_log_warning("Hmmm, I don't really know what to do in this combat but it looks like I'll live.", "red");
				if(my_mp() >= costMajor)
				{
					return attackMajor;
				}
				else if(my_mp() >= costMinor)
				{
					return attackMinor;
				}
				return "attack with weapon";
			}
			if(my_location() != $location[The Slime Tube])
			{
				abort("Could not handle monster, sorry");
			}
		}
		if((monster_level_adjustment() > 150) && (my_mp() >= 45) && canUse($skill[Shell Up]) && (my_class() == $class[Turtle Tamer]))
		{
			return useSkill($skill[Shell Up]);
		}

		if(attackMinor == "attack with weapon")
		{
			if(canUse($skill[Summon Love Stinkbug]))
			{
				return useSkill($skill[Summon Love Stinkbug]);
			}
			if(canUse($skill[Mighty Axing], false) && (equipped_item($slot[Weapon]) != $item[none]))
			{
				return useSkill($skill[Mighty Axing], false);
			}
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[cold]) && canUse($skill[Throat Refrigerant], false))
		{
			return useSkill($skill[Throat Refrigerant], false);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]) && canUse($skill[Boiling Tear Ducts], false))
		{
			return useSkill($skill[Boiling Tear Ducts], false);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[sleaze]) && canUse($skill[Projectile Salivary Glands]))
		{
			return useSkill($skill[Projectile Salivary Glands]);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[spooky]) && canUse($skill[Translucent Skin], false))
		{
			return useSkill($skill[Translucent Skin], false);
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && canUse($skill[Skunk Glands], false))
		{
			return useSkill($skill[Skunk Glands], false);
		}

		if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod") && (my_mp() >= costMajor))
		{
			return attackMajor;
		}

		if((monster_level_adjustment() > 150) && (my_mp() >= costMajor) && (attackMajor != "attack with weapon"))
		{
			return attackMajor;
		}
		if(canUse($skill[Lunge Smack], false) && (attackMinor != "attack with weapon") && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			return attackMinor;
		}
		if((my_mp() >= costMinor) && (attackMinor != "attack with weapon"))
		{
			return attackMinor;
		}

		if((round > 20) && canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}

		return "attack with weapon";
	}
	else
	{
		abort("Some sort of problem occurred, it is past round 25 but we are still in non-gremlin combat...");
	}

	if(attackMinor == "attack with weapon")
	{
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
	}

	return attackMinor;
}

string findBanisher(int round, string opp, string text)
{
	monster enemy = to_monster(opp);

	string banishAction = banisherCombatString(enemy, my_location(), true);
	if(banishAction != "")
	{
		auto_log_info("Looking at banishAction: " + banishAction, "green");
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
	if (canUse($skill[Storm of the Scarab], false))
	{
		return useSkill($skill[Storm of the Scarab], false);
	}
	return auto_combatHandler(round, opp, text);
}

string auto_JunkyardCombatHandler(int round, string opp, string text)
{
	monster enemy = to_monster(opp);

	if(!($monsters[A.M.C. gremlin, batwinged gremlin, erudite gremlin, spider gremlin, vegetable gremlin] contains enemy))
	{
		if (isActuallyEd())
		{
			return auto_edCombatHandler(round, opp, text);
		}
		return auto_combatHandler(round, opp, text);
	}

	auto_log_info("auto_JunkyardCombatHandler: " + round, "brown");
	if(round == 0)
	{
		set_property("auto_gremlinMoly", true);
		set_property("auto_combatHandler", "");
	}

	string combatState = get_property("auto_combatHandler");
	string edCombatState = get_property("auto_edCombatHandler");

	if (isActuallyEd())
	{
		if(contains_text(edCombatState, "gremlinNeedBanish"))
		{
			set_property("auto_gremlinMoly", false);
		}
	}

	if(enemy == $monster[A.M.C. gremlin])
	{
		set_property("auto_gremlinMoly", false);
	}

	if(my_location() == $location[Next To That Barrel With Something Burning In It])
	{
		if(enemy == $monster[vegetable gremlin])
		{
			set_property("auto_gremlinMoly", false);
		}
		else if(contains_text(text, "It does a bombing run over your head"))
		{
			set_property("auto_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Out By That Rusted-Out Car])
	{
		if(enemy == $monster[erudite gremlin])
		{
			set_property("auto_gremlinMoly", false);
		}
		else if(contains_text(text, "It picks a beet off of itself and beats you with it"))
		{
			set_property("auto_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Over Where The Old Tires Are])
	{
		if(enemy == $monster[spider gremlin])
		{
			set_property("auto_gremlinMoly", false);
		}
		else if(contains_text(text, "He uses the random junk around him"))
		{
			set_property("auto_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Near an Abandoned Refrigerator])
	{
		if(enemy == $monster[batwinged gremlin])
		{
			set_property("auto_gremlinMoly", false);
		}
		else if(contains_text(text, "It bites you in the fibula with its mandibles"))
		{
			set_property("auto_gremlinMoly", false);
		}
	}

	if (!contains_text(edCombatState, "gremlinNeedBanish") && !get_property("auto_gremlinMoly").to_boolean() && isActuallyEd())
	{
		set_property("auto_edCombatHandler", "(gremlinNeedBanish)");
	}

	if(round >= 28)
	{
		if (canUse($skill[Storm of the Scarab], false))
		{
			return useSkill($skill[Storm of the Scarab], false);
		}
		else if (canUse($skill[Lunging Thrust-Smack], false))
		{
			return useSkill($skill[Lunging Thrust-Smack], false);
		}
		return "attack with weapon";
	}

	if(contains_text(text, "It whips out a hammer") || contains_text(text, "He whips out a crescent") || contains_text(text, "It whips out a pair") || contains_text(text, "It whips out a screwdriver"))
	{
		return useItem($item[Molybdenum Magnet]);
	}

	if (canUse($skill[Curse Of Weaksauce]))
	{
		return useSkill($skill[Curse Of Weaksauce]);
	}

	if (canUse($skill[Curse Of The Marshmallow]))
	{
		return useSkill($skill[Curse Of The Marshmallow]);
	}

	if (canUse($skill[Summon Love Scarabs]))
	{
		return useSkill($skill[Summon Love Scarabs]);
	}

	if (canUse($skill[Summon Love Gnats]))
	{
		return useSkill($skill[Summon Love Gnats]);
	}

	if(canUse($skill[Bad Medicine]))
	{
		return useSkill($skill[Bad Medicine]);
	}

	if(canUse($skill[Good Medicine]) && canSurvive(2.1))
	{
		return useSkill($skill[Good Medicine]);
	}

	if (my_location() != $location[The Battlefield (Frat Uniform)] && my_location() != $location[The Battlefield (Hippy Uniform)] && !get_property("auto_ignoreFlyer").to_boolean())
	{
		if (canUse($item[Rock Band Flyers]) && get_property("flyeredML").to_int() < 10000)
		{
			if (isActuallyEd())
			{
				set_property("auto_edStatus", "UNDYING!");
			}
			return useItem($item[Rock Band Flyers]);
		}
		if(canUse($item[Jam Band Flyers]) && get_property("flyeredML").to_int() < 10000)
		{
			if (isActuallyEd())
			{
				set_property("auto_edStatus", "UNDYING!");
			}
			return useItem($item[Jam Band Flyers]);
		}
	}

	if(!get_property("auto_gremlinMoly").to_boolean())
	{
		if (isActuallyEd())
		{
			if (get_property("_edDefeats").to_int() >= 2)
			{
				return findBanisher(round, opp, text);
			}
			else if (canUse($item[Seal Tooth], false) && get_property("auto_edStatus") == "UNDYING!")
			{
				return useItem($item[Seal Tooth], false);
			}
		}
		else
		{
			return findBanisher(round, opp, text);
		}
	}

	foreach it in $items[Seal Tooth, Spectre Scepter, Doc Galaktik\'s Pungent Unguent]
	{
		if(canUse(it, false) && glover_usable(it))
		{
			return useItem(it, false);
		}
	}

	if (canUse($skill[Toss], false))
	{
		return useSkill($skill[Toss], false);
	}
	return "attack with weapon";
}

string auto_edCombatHandler(int round, string opp, string text)
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
	set_property("auto_diag_round", round);

	if(get_property("auto_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	phylum type = monster_phylum(enemy);
	string combatState = get_property("auto_combatHandler");
	string edCombatState = get_property("auto_edCombatHandler");

	if($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy)
	{
		set_property("auto_edStatus", "dying");
	}

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int mcd = monster_level_adjustment();

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

		if (item_amount($item[Ka Coin]) > 200 && canUse($skill[Curse of Fortune]))
		{
			return useSkill($skill[Curse of Fortune]);
		}
	}
	else if(get_property("auto_edStatus") == "dying")
	{
		boolean doStunner = true;

		if((mcd > 50) && canSurvive(1.15))
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

	if((enemy == $monster[dirty thieving brigand]) && !contains_text(edCombatState, "curse of fortune"))
	{
		if (item_amount($item[Ka Coin]) > 0 && canUse($skill[Curse Of Fortune]))
		{
			set_property("auto_edCombatHandler", edCombatState + "(curse of fortune)");
			set_property("auto_edStatus", "dying");
			return useSkill($skill[Curse Of Fortune]);
		}
	}

	if (!contains_text(edCombatState, "curseofstench") && canUse($skill[Curse Of Stench]) && get_property("stenchCursedMonster") != opp && get_property("_edDefeats").to_int() < 3)
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
		if (!contains_text(edCombatState, "curseofstench") && canUse($skill[Curse Of Stench]) && get_property("stenchCursedMonster") != opp && get_property("_edDefeats").to_int() < 3)
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
		if (!contains_text(edCombatState, "curseofstench") && canUse($skill[Curse Of Stench]) && get_property("stenchCursedMonster") != opp && get_property("_edDefeats").to_int() < 3)
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

	if (!contains_text(combatState, "yellowray") && canYellowRay(enemy) && auto_wantToYellowRay(enemy, my_location()))
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
			if(combatAction == ("skill " + $skill[Asdon Martin: Missile Launcher]))
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

	if (canUse($skill[Curse Of Vacation]) && get_property("auto_edStatus") == "dying")
	{
		if (auto_wantToBanish(enemy, my_location()) && !(auto_banishesUsedAt(my_location()) contains "curse of vacation"))
		{
			handleTracker(enemy, $skill[Curse of Vacation], "auto_banishes");
			return useSkill($skill[Curse Of Vacation]);
		}
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
		if((enemy == $monster[Pygmy Janitor]) && (item_amount($item[Book of Matches]) == 0) && (get_property("relocatePygmyJanitor").to_int() != my_ascensions()))
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

		if (item_amount($item[Ka Coin]) > 200 && canUse($skill[Curse of Fortune]))
		{
			return useSkill($skill[Curse of Fortune]);
		}

		if (canUse($item[Seal Tooth], false))
		{
			return useItem($item[Seal Tooth], false);
		}

		return useSkill($skill[Mild Curse], false);
	}

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

string auto_saberTrickMeteorShowerCombatHandler(int round, string opp, string text){
	if(canUse($skill[Use the Force]) && auto_saberChargesAvailable() > 0 && auto_have_skill($skill[Meteor Lore])){
		if(canUse($skill[Meteor Shower])){
			return useSkill($skill[Meteor Shower]);
		} else {
			return auto_combatSaberYR();
		}
	}
	abort("Unable to perform saber trick (meteor shower)");
	return "";
}

monster ocrs_helper(string page)
{
	if(my_path() != "One Crazy Random Summer")
	{
		abort("Should not be in ocrs_helper if not on the path!");
	}

	string combatState = get_property("auto_combatHandler");

	//	ghostly				physical resistance
	//	untouchable			damage reduced to 5, instant kills still good (much less of an issue now

	/*
		For no staggers, don\'t use staggers
		For blocks skills/combat items, we can probably set them all to used as well.
	*/

	if(isFreeMonster(last_monster()))
	{
		if((!contains_text(combatState, "cleesh")) && auto_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("auto_useCleesh", false);
			set_property("auto_combatHandler", combatState + "(cleesh)");
		}
	}

	if(last_monster().random_modifiers["unstoppable"])
	{
		if(!contains_text(combatState, "unstoppable"))
		{
			set_property("auto_combatHandler", combatState + "(DNA)(air dirty laundry)(ply reality)(indigo cup)(love mosquito)(blue balls)(love gnats)(unstoppable)(micrometeorite)");
			#Block weaksauce and pocket crumbs?
		}
	}

	if(last_monster().random_modifiers["annoying"])
	{
		if(contains_text(page, "makes the most annoying noise you've ever heard, stopping you in your tracks."))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	if(last_monster().random_modifiers["restless"])
	{
		if(contains_text(page, "moves out of the way"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		if(contains_text(page, "quickly moves out of the way"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		if(contains_text(page, "will have moved by the time"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}

		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	if(last_monster().random_modifiers["phase-shifting"])
	{
		if(contains_text(page, "blinks out of existence before"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	if(last_monster().random_modifiers["cartwheeling"])
	{
		if(contains_text(page, "cartwheels out of the way"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	set_property("auto_useCleesh", false);
	if(last_monster().random_modifiers["ticking"])
	{
		if((!contains_text(combatState, "cleesh")) && auto_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("auto_useCleesh", true);
		}
	}
	if(last_monster().random_modifiers["untouchable"])
	{
		if((!contains_text(combatState, "cleesh")) && auto_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("auto_useCleesh", true);
		}
	}
	return last_monster();
}

void awol_helper(string page)
{
	//Let us self-contain this so it is quick to remove later.
	if((my_daycount() == 1) && (my_turncount() < 10))
	{
		set_property("auto_noSnakeOil", 0);
	}

	string combatState = get_property("auto_combatHandler");
	if(contains_text(page, "Your oil extractor is completely clogged up at this point"))
	{
		set_property("auto_noSnakeOil", my_daycount());
	}
	if(get_property("_oilExtracted").to_int() >= 100)
	{
		set_property("auto_noSnakeOil", my_daycount());
	}

	if((!contains_text(combatState, "extractSnakeOil")) && (get_property("auto_noSnakeOil").to_int() == my_daycount()))
	{
		set_property("auto_combatHandler", combatState + "(extractSnakeOil)");
	}
}


boolean registerCombat(string action)
{
	set_property("auto_combatHandler", get_property("auto_combatHandler") + "(" + to_lower_case(action) + ")");
	return true;
}
boolean containsCombat(string action)
{
	action = "(" + to_lower_case(action) + ")";
	return contains_text(get_property("auto_combatHandler"), action);
}

boolean registerCombat(skill sk)
{
	return registerCombat(to_string(sk));
}
boolean registerCombat(item it)
{
	return registerCombat(to_string(it));
}

boolean containsCombat(skill sk)
{
	return containsCombat(to_string(sk));
}
boolean containsCombat(item it)
{
	return containsCombat(to_string(it));
}


boolean canSurvive(float mult, int add)
{
	int damage = expected_damage();
	damage *= mult;
	damage += add;
	return (damage < my_hp());
}

boolean canSurvive(float mult)
{
	return canSurvive(mult, 0);
}
