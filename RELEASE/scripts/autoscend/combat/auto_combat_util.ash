//this file is utility functions that are only used for combat file.

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

boolean canUse(skill sk, boolean onlyOnce, boolean inCombat)
{
	if(onlyOnce && haveUsed(sk))
	{
		return false;
	}

	if(!auto_have_skill(sk))
	{
		return false;
	}

	if(inCombat)
	{
		if(my_mp() < mp_cost(sk) - combat_mana_cost_modifier() ||
		my_hp() <= hp_cost(sk) ||
		get_fuel() < fuel_cost(sk) ||
		my_lightning() < lightning_cost(sk) ||
		my_thunder() < thunder_cost(sk) ||
		my_rain() < rain_cost(sk) ||
		my_soulsauce() < soulsauce_cost(sk) ||
		my_pp() < plumber_ppCost(sk))
		{
			return false;
		}
	}
	else
	{
		if(my_maxmp() < mp_cost(sk) - combat_mana_cost_modifier() ||
		my_maxhp() <= hp_cost(sk) ||
		get_fuel() < fuel_cost(sk) ||
		my_lightning() < lightning_cost(sk) ||
		my_thunder() < thunder_cost(sk) ||
		my_rain() < rain_cost(sk) ||
		my_soulsauce() < soulsauce_cost(sk))
		{
			return false;
		}
	}
	
	if(sk == $skill[Shieldbutt] && !hasShieldEquipped())
	{
		return false;
	}

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

boolean canUse(skill sk, boolean onlyOnce)	//assume we are in combat unless specified otherwise
{
	return canUse(sk, onlyOnce, true);
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

skill getSniffer(monster enemy, boolean inCombat)
{
	//returns the skill we want to use to sniff the enemy
	//sniffers are skills that increase the odds of encountering this same monster again in the current zone.
	if(canUse($skill[Transcendent Olfaction], true , inCombat) && get_property("_olfactionsUsed").to_int() < 3 &&
	!contains_text(get_property("olfactedMonster"), enemy))
	{
		return $skill[Transcendent Olfaction];
	}
	if(canUse($skill[Make Friends], true , inCombat) && get_property("makeFriendsMonster") != enemy && my_audience() >= 20)
	{
		return $skill[Make Friends];
	}
	if(!contains_text(get_property("longConMonster"), enemy) && canUse($skill[Long Con], true , inCombat) && get_property("_longConUsed").to_int() < 5)
	{
		return $skill[Long Con];
	}
	if(canUse($skill[Perceive Soul], true , inCombat) && enemy != get_property("auto_bat_soulmonster").to_monster())
	{
		return $skill[Perceive Soul];
	}
	if(canUse($skill[Gallapagosian Mating Call], true , inCombat) && enemy != get_property("_gallapagosMonster").to_monster())
	{
		return $skill[Gallapagosian Mating Call];
	}
	if(canUse($skill[Offer Latte to Opponent], true , inCombat) && enemy != get_property("_latteMonster").to_monster() && !get_property("_latteCopyUsed").to_boolean())
	{
		return $skill[Offer Latte to Opponent];
	}	
	return $skill[none];
}

skill getSniffer(monster enemy)
{
	return getSniffer(enemy, true);
}

skill getStunner(monster enemy)
{
	// Class specific
	switch(my_class())
	{
	case $class[Seal Clubber]:
		if(canUse($skill[Club Foot]) && (my_fury() > 0 || hasClubEquipped()))
		{
			return $skill[Club Foot];
		}
		break;
	case $class[Turtle Tamer]:
		if(canUse($skill[Shell Up]))
		{
			//storm turtle blessings makes shell up a multi-round stun, otherwise it's just a (special) stagger
			if(have_effect($effect[Blessing of the Storm Tortoise]) > 0 || have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0 || have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0)
			{
				return $skill[Shell Up];
			}
		}
		break;
	case $class[Accordion Thief]:
		if(canUse($skill[Accordion Bash]) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			return $skill[Accordion Bash];
		}
		break;
	case $class[Pastamancer]:
		if(canUse($skill[Entangling Noodles]))
		{
			return $skill[Entangling Noodles];
		}
		break;
	case $class[Sauceror]:
		if(canUse($skill[Soul Bubble]))
		{
			return $skill[Soul Bubble];
		}
		break;
	case $class[Avatar of Boris]:
		if(canUse($skill[Broadside]))
		{
			return $skill[Broadside];
		}
		break;
	case $class[Avatar of Sneaky Pete]:
		if(canUse($skill[Snap Fingers]))
		{
			return $skill[Snap Fingers];
		}
		break;
	case $class[Avatar of Jarlsberg]:
		if(canUse($skill[Blend]))
		{
			return $skill[Blend];
		}
		break;
	case $class[Cow Puncher]:
	case $class[Beanslinger]:
	case $class[Snake Oiler]:
		if(canUse($skill[Beanscreen]))
		{
			return $skill[Beanscreen];
		}
		if(canUse($skill[Hogtie]) && !haveUsed($skill[Beanscreen]) && hasLeg(enemy))
		{
			return $skill[Hogtie];
		}
		break;
	case $class[Vampyre]:
		if(canUse($skill[Blood Chains]) && my_hp() > 3 * hp_cost($skill[Blood Chains]))
		{
			return $skill[Blood Chains];
		}
		break;
	}
	
	// Decreases in stun duration the more it's used
	if(canUse($skill[Summon Love Gnats]))
	{
		return $skill[Summon Love Gnats];
	}

	// Nuclear Autum
	if(canUse($skill[Mind Bullets]))
	{
		return $skill[Mind Bullets];
	}

	return $skill[none];
}

boolean enemyCanBlocksSkills()
{
	//we want to know if enemy can sometimes block a skill. For such enemies skills should be used only if absolutely necessary
	//for enemies that always block a skill a seperate function should be made... if we ever fight any in run.
	
	monster enemy = last_monster();
	
	if($monsters[
	Bonerdagon,
	Naughty Sorceress,
	Naughty Sorceress (2)
	] contains enemy)
	{
		return true;
	}
	
	return false;
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

boolean hasClubEquipped()
{
	return item_type(equipped_item($slot[weapon])) == "club" || (item_type(equipped_item($slot[weapon])) == "sword" && have_effect($effect[iron palms]) > 0);
}

string auto_saberTrickMeteorShowerCombatHandler(int round, monster enemy, string text)
{
	if(canUse($skill[Use the Force]) && auto_saberChargesAvailable() > 0 && auto_have_skill($skill[Meteor Lore])){
		if(canUse($skill[Meteor Shower])){
			return useSkill($skill[Meteor Shower]);
		} else {
			return auto_combatSaberYR();
		}
	}
	abort("Unable to perform saber trick (meteor shower)");
	return "abort";	//must have a return
}

string findBanisher(int round, monster enemy, string text)
{
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
	return auto_combatHandler(round, enemy, text);
}

string banisherCombatString(monster enemy, location loc, boolean inCombat)
{
	if(inAftercore())
	{
		return "";
	}

	if(in_pokefam())
	{
		return "";
	}

	//If it's already banished, banishing it again isn't going to do much.
	if(is_banished(enemy))
	{
		return "";
	}

	//Check that we actually want to banish this thing.
	if(!auto_wantToBanish(enemy, loc))
		return "";

	if(inCombat)
		auto_log_info("Finding a banisher to use on " + enemy + " at " + loc, "green");

	//src/net/sourceforge/kolmafia/session/BanishManager.java
	boolean[string] used = auto_banishesUsedAt(loc);

	/*	If we have banished anything else in this zone, make sure we do not undo the banishing.
		mad wino:batter up!:378:skeletal sommelier:KGB tranquilizer dart:381
		We are not going to worry about turn costs, it probably only matters for older paths anyway.

		Thunder Clap: no limit, no turn limit
		Batter Up!: no limit, no turn limit
		Asdon Martin: Spring-Loaded Front Bumper: no limit
		Curse of Vacation: no limit? No turn limit?
		Walk Away Explosion: no limit, turn limited irrelavant.

		Banishing Shout: no turn limit
		Talk About Politics: no turn limit
		KGB Tranquilizer Dart: no turn limit
		Snokebomb: no turn limit

		Louder Than Bomb: item, no turn limit
		Beancannon: item, no turn limit, no limit
		Tennis Ball: item, no turn limit

		Breathe Out: per hot jelly usage
	*/

	if (auto_have_skill($skill[Peel Out]) && pete_peelOutRemaining() > 0 && get_property("peteMotorbikeMuffler") == "Extra-Smelly Muffler" && !(used contains "Peel Out"))
	{
		return "skill " + $skill[Peel Out];
	}

	if((inCombat ? auto_have_skill($skill[Throw Latte on Opponent]) : possessEquipment($item[latte lovers member\'s mug])) && !get_property("_latteBanishUsed").to_boolean() && !(used contains "Throw Latte on Opponent"))
	{
		return "skill " + $skill[Throw Latte on Opponent];
	}

	if((inCombat ? auto_have_skill($skill[Give Your Opponent The Stinkeye]) : possessEquipment($item[stinky cheese eye])) && !get_property("_stinkyCheeseBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Give Your Opponent The Stinkeye])))
	{
		return "skill " + $skill[Give Your Opponent The Stinkeye];
	}

	if((inCombat ? auto_have_skill($skill[Creepy Grin]) : possessEquipment($item[V for Vivala mask])) && !get_property("_vmaskBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Creepy Grin])))
	{
		return "skill " + $skill[Creepy Grin];
	}

	if(auto_have_skill($skill[Baleful Howl]) && my_hp() > hp_cost($skill[Baleful Howl]) && get_property("_balefulHowlUses").to_int() < 10 && !(used contains "baleful howl"))
	{
		loopHandlerDelayAll();
		return "skill " + $skill[Baleful Howl];
	}

	if(auto_have_skill($skill[Thunder Clap]) && (my_thunder() >= thunder_cost($skill[Thunder Clap])) && (!(used contains "thunder clap")))
	{
		return "skill " + $skill[Thunder Clap];
	}
	if(auto_have_skill($skill[Asdon Martin: Spring-Loaded Front Bumper]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Spring-Loaded Front Bumper])) && (!(used contains "Spring-Loaded Front Bumper")))
	{
		if(!contains_text(get_property("banishedMonsters"), "Spring-Loaded Front Bumper"))
		{
			return "skill " + $skill[Asdon Martin: Spring-Loaded Front Bumper];
		}
	}
	if(auto_have_skill($skill[Curse Of Vacation]) && (my_mp() > mp_cost($skill[Curse Of Vacation])) && (!(used contains "curse of vacation")))
	{
		return "skill " + $skill[Curse Of Vacation];
	}

	if((inCombat ? auto_have_skill($skill[Show Them Your Ring]) : possessEquipment($item[Mafia middle finger ring])) && !get_property("_mafiaMiddleFingerRingUsed").to_boolean() && (my_mp() >= mp_cost($skill[Show Them Your Ring])))
	{
		return "skill " + $skill[Show Them Your Ring];
	}
	if(auto_have_skill($skill[Breathe Out]) && (my_mp() >= mp_cost($skill[Breathe Out])) && (!(used contains "breathe out")))
	{
		return "skill " + $skill[Breathe Out];
	}
	if(auto_have_skill($skill[Batter Up!]) && (my_fury() >= 5) && (inCombat ? hasClubEquipped() : true) && (!(used contains "batter up!")))
	{
		return "skill " + $skill[Batter Up!];
	}

	if(auto_have_skill($skill[Banishing Shout]) && (my_mp() > mp_cost($skill[Banishing Shout])) && (!(used contains "banishing shout")))
	{
		return "skill " + $skill[Banishing Shout];
	}
	if(auto_have_skill($skill[Walk Away From Explosion]) && (my_mp() > mp_cost($skill[Walk Away From Explosion])) && (have_effect($effect[Bored With Explosions]) == 0) && (!(used contains "walk away from explosion")))
	{
		return "skill " + $skill[Walk Away From Explosion];
	}

	if((inCombat ? auto_have_skill($skill[Talk About Politics]) : possessEquipment($item[Pantsgiving])) && (get_property("_pantsgivingBanish").to_int() < 5) && have_equipped($item[Pantsgiving]) && (!(used contains "pantsgiving")))
	{
		return "skill " + $skill[Talk About Politics];
	}
	if((inCombat ? auto_have_skill($skill[Reflex Hammer]) : possessEquipment($item[Lil\' Doctor&trade; bag])) && get_property("_reflexHammerUsed").to_int() < 3 && !(used contains "Reflex Hammer"))
	{
		return "skill " + $skill[Reflex Hammer];
	}
	if((inCombat ? auto_have_skill($skill[Show Your Boring Familiar Pictures]) : possessEquipment($item[familiar scrapbook])) && (get_property("scrapbookCharges").to_int() >= 200 || (get_property("scrapbookCharges").to_int() >= 100 && my_level() >= 13)) && !(used contains "Show Your Boring Familiar Pictures"))
	{
		return "skill " + $skill[Show Your Boring Familiar Pictures];
	}
	
	if (auto_canFeelHatred() && !(used contains "Feel Hatred"))
	{
		return "skill " + $skill[Feel Hatred];
	}

	if ((inCombat ? have_equipped($item[Fourth of May cosplay saber]) : possessEquipment($item[Fourth of May cosplay saber])) && auto_saberChargesAvailable() > 0 && !(used contains "Saber Force")) {
		// can't use the force on uncopyable monsters
		if (enemy == $monster[none] || enemy.copyable) {
			return auto_combatSaberBanish();
		}
	}

	if((inCombat ? auto_have_skill($skill[KGB Tranquilizer Dart]) : possessEquipment($item[Kremlin\'s Greatest Briefcase])) && (get_property("_kgbTranquilizerDartUses").to_int() < 3) && (my_mp() >= mp_cost($skill[KGB Tranquilizer Dart])) && (!(used contains "KGB tranquilizer dart")))
	{
		boolean useIt = true;
		if (get_property("sidequestJunkyardCompleted") != "none" && my_daycount() >= 2 && get_property("_kgbTranquilizerDartUses").to_int() >= 2)
		{
			useIt = false;
		}

		if(useIt)
		{
			return "skill " + $skill[KGB Tranquilizer Dart];
		}
	}
	if(auto_have_skill($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])) && (!(used contains "snokebomb")))
	{
		return "skill " + $skill[Snokebomb];
	}
	
	//[Nanorhino] familiar specific banish. fairly low priority as it consumes 40 to 50 adv worth of a decent buff.
	if(canUse($skill[Unleash Nanites]) && have_effect($effect[Nanobrawny]) >= 40)
	{
		return "skill " + $skill[Unleash Nanites];
	}
	
	if(auto_have_skill($skill[Beancannon]) && (get_property("_beancannonUses").to_int() < 5) && ((my_mp() - 20) >= mp_cost($skill[Beancannon])) && (!(used contains "beancannon")))
	{
		boolean haveBeans = false;
		foreach beancan in $items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas]
		{
			if(inCombat ? equipped_item($slot[off-hand]) == beancan : possessEquipment(beancan))
			{
				haveBeans = true;
				break;
			}
		}
		if(haveBeans)
		{
			return "skill " + $skill[Beancannon];
		}
	}
	if(auto_have_skill($skill[Breathe Out]) && (!(used contains "breathe out")))
	{
		return "skill " + $skill[Breathe Out];
	}

	if (item_amount($item[human musk]) > 0 && (!(used contains "human musk")) && auto_is_valid($item[human musk]) && get_property("_humanMuskUses").to_int() < 3)
	{
		return "item " + $item[human musk];
	}

	//We want to limit usage of these much more than the others.
	if(!($monsters[Natural Spider, Tan Gnat, Tomb Servant, Upgraded Ram] contains enemy))
	{
		return "";
	}

	int keep = 1;
	if (get_property("sidequestJunkyardCompleted") != "none")
	{
		keep = 0;
	}

	if((item_amount($item[Louder Than Bomb]) > keep) && (!(used contains "louder than bomb")) && auto_is_valid($item[Louder Than Bomb]))
	{
		return "item " + $item[Louder Than Bomb];
	}
	if((item_amount($item[Tennis Ball]) > keep) && (!(used contains "tennis ball")) && auto_is_valid($item[Tennis Ball]))
	{
		return "item " + $item[Tennis Ball];
	}
	if((item_amount($item[Deathchucks]) > keep) && (!(used contains "deathchucks")))
	{
		return "item " + $item[Deathchucks];
	}

	return "";
}

string banisherCombatString(monster enemy, location loc)
{
	return banisherCombatString(enemy, loc, false);
}

string yellowRayCombatString(monster target, boolean inCombat, boolean noForceDrop)
{
	if(in_wildfire() && inCombat && my_location().fire_level > 2)
	{
		//high fire level burns yellow ray items. except for saber's [use the force] as it leads to a noncombat
		//we only want special handling if fire level is high. otherwise we can proceed to yellowray as per normal
		if(have_equipped($item[Fourth of May cosplay saber]) && auto_saberChargesAvailable() > 0)
		{
			// can't use the force on uncopyable monsters
			if(target == $monster[none] || (target.copyable && !noForceDrop))
			{
				return auto_combatSaberYR();
			}
		}
		else return "";
	}
	
	if(have_effect($effect[Everything Looks Yellow]) <= 0)
	{
		if((item_amount($item[Yellowcake Bomb]) > 0) && auto_is_valid($item[Yellowcake Bomb]))
		{
			return "item " + $item[Yellowcake Bomb]; // 75 turns
		}
		if((item_amount($item[yellow rocket]) > 0) && auto_is_valid($item[yellow rocket]))
		{
			return "item " + $item[yellow rocket]; // 75 turns
		}
		if(inCombat ? have_skill($skill[Unleash the Devil's Kiss]) : possessEquipment($item[unwrapped knock-off retro superhero cape]))
		{
			return "skill " + $skill[Unleash the Devil's Kiss]; // 99 turns
		}
		if(auto_have_skill($skill[Disintegrate]) && (my_mp() >= mp_cost($skill[Disintegrate])))
		{
			return "skill " + $skill[Disintegrate]; // 100 trurns
		}
		if(auto_have_skill($skill[Ball Lightning]) && (my_lightning() >= lightning_cost($skill[Ball Lightning])))
		{
			return "skill " + $skill[Ball Lightning]; // 99 turns
		}
		if(auto_have_skill($skill[Wrath of Ra]) && (my_mp() >= mp_cost($skill[Wrath of Ra])))
		{
			return "skill " + $skill[Wrath of Ra]; // 100 turns
		}
		if((item_amount($item[Mayo Lance]) > 0) && (get_property("mayoLevel").to_int() > 0) && auto_is_valid($item[Mayo Lance]))
		{
			return "item " + $item[Mayo Lance]; // 0 - 145 turns
		}
		if((get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb") && auto_have_skill($skill[Flash Headlight]) && (my_mp() >= mp_cost($skill[Flash Headlight])))
		{
			return "skill " + $skill[Flash Headlight]; // 100 turns
		}
		foreach it in $items[Golden Light, Pumpkin Bomb, Unbearable Light, Viral Video, micronova]
		{
			if((item_amount(it) > 0) && auto_is_valid(it))
			{
				return "item " + it; // ~150 turns
			}
		}
		if(auto_have_skill($skill[Unleash Cowrruption]) && (have_effect($effect[Cowrruption]) >= 30))
		{
			return "skill " + $skill[Unleash Cowrruption]; // 149 turns
		}
		if((inCombat ? my_familiar() == $familiar[Crimbo Shrub] : auto_have_familiar($familiar[Crimbo Shrub])) && (get_property("shrubGifts") == "yellow"))
		{
			return "skill " + $skill[Open a Big Yellow Present]; // 149 turns
		}
	}

	if(asdonCanMissile())
	{
		return "skill " + $skill[Asdon Martin: Missile Launcher];
	}

	if (auto_canFeelEnvy())
	{
		return "skill " + $skill[Feel Envy];
	}

	if((inCombat ? have_equipped($item[Fourth of May cosplay saber]) : possessEquipment($item[Fourth of May cosplay saber])) && (auto_saberChargesAvailable() > 0))
	{
		// can't use the force on uncopyable monsters
		if(target == $monster[none] || (target.copyable && !noForceDrop))
		{
			return auto_combatSaberYR();
		}
	}
	
	// shocking lick doesn't cause everything looks yellow effect and limited only by how many batteries you have. Use all other sources first.
	if(inCombat ? have_skill($skill[Shocking Lick]) : (get_property("shockingLickCharges").to_int() > 0 || can_get_battery($item[battery (9-Volt)])))
	{
		return "skill " + $skill[Shocking Lick];
	}

	return "";
}

string yellowRayCombatString(monster target, boolean inCombat)
{
	return yellowRayCombatString(target, inCombat, false);
}

string yellowRayCombatString(monster target)
{
	return yellowRayCombatString(target, false);
}

string yellowRayCombatString()
{
	return yellowRayCombatString($monster[none]);
}

string replaceMonsterCombatString(monster target, boolean inCombat)
{
	if (auto_macrometeoritesAvailable() > 0 && auto_is_valid($skill[Macrometeorite]))
	{
		return "skill " + $skill[Macrometeorite];
	}
	if (auto_powerfulGloveReplacesAvailable(inCombat) > 0 && auto_is_valid($skill[CHEAT CODE: Replace Enemy]))
	{
		return "skill " + $skill[CHEAT CODE: Replace Enemy];
	}
	return "";
}

string replaceMonsterCombatString(monster target)
{
	return replaceMonsterCombatString(target, false);
}

string replaceMonsterCombatString()
{
	return replaceMonsterCombatString($monster[none]);
}

float turns_to_kill(float dmg)
{
	//how long will it take us to kill the current enemy if we are able to deal dmg to it each round
	return monster_hp().to_float() / dmg;
}
