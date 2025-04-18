//this file is utility functions that are only used for combat file.

boolean haveUsed(skill sk)
{
	return get_property("_auto_combatState").contains_text("(sk" + sk.to_int().to_string() + ")");
}

boolean haveUsed(item it)
{
	return get_property("_auto_combatState").contains_text("(it" + it.to_int().to_string() + ")");
}

int usedCount(skill sk)
{
	matcher m = create_matcher("(sk" + sk.to_int().to_string() + ")", get_property("_auto_combatState"));
	int count = 0;
	while(m.find())
	{
		++count;
	}
	return count;
}

int usedCount(item it)
{
	matcher m = create_matcher("(it" + it.to_int().to_string() + ")", get_property("_auto_combatState"));
	int count = 0;
	while(m.find())
	{
		++count;
	}
	return count;
}

void markAsUsed(skill sk)
{
	set_property("_auto_combatState", get_property("_auto_combatState") + "(sk" + sk.to_int().to_string() + ")");
}

void markAsUsed(item it)
{
	if(it != $item[none])
	{
		set_property("_auto_combatState", get_property("_auto_combatState") + "(it" + it.to_int().to_string() + ")");
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
		if(my_mp() < mp_cost(sk) ||	// + combat_mana_cost_modifier() (negative value that we would add) is already included by mp_cost()
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
		if(my_maxmp() < mp_cost(sk) || 
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
		exclusives[exclusives.count()] = new SkillSet(equipped_amount(wrap_item($item[haiku katana])), $skills[The 17 Cuts, Falling Leaf Whirlwind, Spring Raindrop Attack, Summer Siesta, Winter\'s Bite Technique]);
		exclusives[exclusives.count()] = new SkillSet(equipped_amount($item[bottle-rocket crossbow])  + equipped_amount($item[replica bottle-rocket crossbow]), $skills[Fire Red Bottle-Rocket, Fire Blue Bottle-Rocket, Fire Orange Bottle-Rocket, Fire Purple Bottle-Rocket, Fire Black Bottle-Rocket]);
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
	if(auto_have_skill($skill[Ambidextrous Funkslinging]))
		return "item " + it + ", none";	//don't double use
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

boolean isSniffed(monster enemy, skill sk)
{
	string search;
	if (sk == $skill[Get a Good Whiff of This Guy]) {
		search = "Nosy Nose";
	} else {
		search = sk.to_string();
	}
	string[0] tracked = tracked_by(enemy);
	foreach n in tracked {
		if (tracked[n] == search) {
			return true;
		}
	}
	return false;
}

boolean isSniffed(monster enemy)
{
	//checks if the monster enemy is currently sniffed using any of the sniff skills
	foreach sk in $skills[Transcendent Olfaction, Make Friends, Long Con, Perceive Soul, Gallapagosian Mating Call, Monkey Point, Offer Latte to Opponent, Motif, Hunt, McHugeLarge Slash]
	{
		if(isSniffed(enemy, sk)) return true;
	}
	//nosyNoseMonster is conditional on familiar [Nosy Nose], should it ever return true for this general check?
	return false;
}

skill getSniffer(monster enemy, boolean inCombat)
{
	//returns the skill we want to use to sniff the enemy
	//sniffers are skills that increase the odds of encountering this same monster again in the current zone.
	if(canUse($skill[Transcendent Olfaction], true , inCombat) && get_property("_olfactionsUsed").to_int() < 3 && !isSniffed(enemy, $skill[Transcendent Olfaction]))
	{
		return $skill[Transcendent Olfaction];
	}
	if(canUse($skill[Make Friends], true , inCombat) && my_audience() >= 20 && !isSniffed(enemy, $skill[Make Friends]))
	{
		return $skill[Make Friends];		//avatar of sneaky pete specific skill
	}
	if(canUse($skill[Hunt], true, inCombat) && have_effect($effect[Everything Looks Red]) == 0 && !isSniffed(enemy, $skill[Hunt]))
	{
		return $skill[Hunt];				//WereProfessor Werewolf specific skill
	}
	if(canUse($skill[Long Con], true , inCombat) && get_property("_longConUsed").to_int() < 5 && !isSniffed(enemy, $skill[Long Con]))
	{
		return $skill[Long Con];
	}
	if(canUse($skill[Perceive Soul], true , inCombat) && !isSniffed(enemy, $skill[Perceive Soul]))
	{
		return $skill[Perceive Soul];
	}
	if(canUse($skill[Motif], true , inCombat) && !isSniffed(enemy, $skill[Motif]) && (have_effect($effect[Everything Looks Blue]) == 0))
	{
		return $skill[Motif];
	}
	if (inCombat)
	{
		if(canUse($skill[Monkey Point], true , inCombat) && !isSniffed(enemy, $skill[Monkey Point]))
		{
			return $skill[Monkey Point];
		}
		if(canUse($skill[McHugeLarge Slash], true , inCombat) && !isSniffed(enemy, $skill[McHugeLarge Slash]) && auto_McLargeHugeSniffsLeft()>0)
		{
			return $skill[McHugeLarge Slash];
		}
	}
	else
	{
		if (auto_monkeyPawWishesLeft()==1 && !isSniffed(enemy, $skill[Monkey Point]))
		{
			return $skill[Monkey Point];
		}
		if (possessEquipment($item[McHugeLarge left pole]) && !isSniffed(enemy, $skill[McHugeLarge Slash]) && auto_McLargeHugeSniffsLeft()>0)
		{
			return $skill[McHugeLarge Slash];
		}
	}
	if(canUse($skill[Gallapagosian Mating Call], true , inCombat) && !isSniffed(enemy, $skill[Gallapagosian Mating Call]))
	{
		return $skill[Gallapagosian Mating Call];
	}
	if(my_familiar() == $familiar[Nosy Nose] && canUse($skill[Get a Good Whiff of This Guy]) && !isSniffed(enemy,$skill[Get a Good Whiff of This Guy]))
	{
		return $skill[Get a Good Whiff of This Guy];
	}
	if(canUse($skill[Offer Latte to Opponent], true , inCombat) && !get_property("_latteCopyUsed").to_boolean() && !isSniffed(enemy, $skill[Offer Latte to Opponent]))
	{
		return $skill[Offer Latte to Opponent];
	}	
	return $skill[none];
}

skill getSniffer(monster enemy)
{
	return getSniffer(enemy, true);
}

boolean isCopied(monster enemy, skill sk)
{
	//checks if the monster enemy is currently copied using the specific skill sk
	boolean retval = false;
	switch(sk)
	{
		case $skill[Blow the Purple Candle\!]:
			retval = contains_text(get_property("auto_purple_candled"), enemy);
			break;
		default:
			abort("isCopied was asked to check an unidentified skill: " +sk);
	}
	return retval;
}

boolean isCopied(monster enemy)
{
	//checks if the monster enemy is currently copied using any of the copy skills
	foreach sk in $skills[Blow the Purple Candle\!]
	{
		if(isCopied(enemy, sk)) return true;
	}
	return false;
}

skill getCopier(monster enemy, boolean inCombat)
{
	if((auto_haveRoman() && have_effect($effect[Everything Looks Purple]) == 0) || (have_equipped($item[Roman Candelabra]) && canUse($skill[Blow the Purple Candle\!], true, inCombat) && have_effect($effect[Everything Looks Purple]) == 0))
	{
		return $skill[Blow the Purple Candle\!];
	}
	return $skill[none];
}

skill getCopier(monster enemy)
{
	return getCopier(enemy, true);
}

skill getStunner(monster enemy)
{
	if(canUse($skill[Blow the Blue Candle\!]) && have_effect($effect[Everything Looks Blue]) == 0)
	{
		return $skill[Blow the Blue Candle\!]; //20 Turns
	}
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
	case $class[Pig Skinner]:
		if(canUse($skill[Noogie]))
		{
			return $skill[Noogie];
		}
		break;
	case $class[Cheese Wizard]:
		if(canUse($skill[Gather Cheese-Chi]))
		{
			return $skill[Gather Cheese-Chi];
		}
		break;
	case $class[Jazz Agent]:
		if(canUse($skill[Drum Roll], true))
		{
			return $skill[Drum Roll];
		}
		break;
	}
	
	// From Designer Sweatpants. Use when have nearly full sweat or when losing combat
	if(canUse($skill[Sweat Flood]) && (getSweat() > 98 || contains_text(get_property("_auto_combatState"), "last attempt")))
	{
		return $skill[Sweat Flood];
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
	if(canUse($skill[Use the Force]) && auto_saberChargesAvailable() > 0 && auto_have_skill($skill[Meteor Lore]))
	{
		if(canUse($skill[Meteor Shower]))
		{
			return useSkill($skill[Meteor Shower]);
		}
		else
		{
			return auto_combatSaberYR();
		}
	}
	abort("Unable to perform saber trick (meteor shower)");
	return "abort";	//must have a return
}

string findPhylumBanisher(int round, monster enemy, string text)
{
	string banishAction = banisherCombatString(monster_phylum(enemy), my_location(), true);
	if(banishAction != "")
	{
		auto_log_info("Looking at banishAction: " + banishAction, "green");
		if(index_of(banishAction, "skill") == 0)
		{
			handleTracker(monster_phylum(enemy), to_skill(substring(banishAction, 6)), "auto_banishes");
		}
		else if(index_of(banishAction, "item") == 0)
		{
			handleTracker(monster_phylum(enemy), to_item(substring(banishAction, 5)), "auto_banishes");
		}
		else
		{
			auto_log_warning("Unable to track banisher behavior: " + banishAction, "red");
		}
		return banishAction;
	}
	return auto_combatHandler(round, enemy, text);
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
	if(canUse($skill[Storm of the Scarab], false))
	{
		return useSkill($skill[Storm of the Scarab], false);
	}
	return auto_combatHandler(round, enemy, text);
}

string banisherCombatString(phylum enemyPhylum, location loc, boolean inCombat)
{
	if(inAftercore())
	{
		return "";
	}

	if(in_pokefam())
	{
		return "";
	}

	//Check that we actually want to banish this thing.
	if(!auto_wantToBanish(enemyPhylum, loc))
		return "";

	if(inCombat)
		auto_log_info("Finding a phylum banisher to use on " + enemyPhylum + " at " + loc, "green");

	if(inCombat ? (my_familiar() == $familiar[Patriotic Eagle] && get_property("screechCombats").to_int() == 0) : (auto_have_familiar($familiar[Patriotic Eagle]) && (get_property("screechCombats").to_int() == 0)))
	{
		return "skill" + $skill[%fn\, Release the Patriotic Screech!];
	}

	return "";
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

	boolean useFree = true; // use banisher that is a freerun
	if(is_werewolf())
	{
		useFree = false; // werewolves don't run
	}

	//src/net/sourceforge/kolmafia/session/BanishManager.java
	boolean[string] used = auto_banishesUsedAt(loc);

	/*	If we have banished anything else in this zone, make sure we do not undo the banishing.
		mad wino:batter up!:378:skeletal sommelier:KGB tranquilizer dart:381
		We are not going to worry about turn costs, it probably only matters for older paths anyway.
		//TODO - find a way to track banishes that have queues and can banish multiple things at once (Banishing Shout and Howl of the Alpha for example)

		Thunder Clap: no limit, no turn limit
		Batter Up!: no limit, no turn limit
		Asdon Martin: Spring-Loaded Front Bumper: no limit
		Curse of Vacation: no limit? No turn limit?
		Walk Away Explosion: no limit, turn limited irrelavant.

		Howl of the Alpha: no limit, no turn limit, can banish up to 3 monsters simultaneously

		Banishing Shout: no turn limit
		Talk About Politics: no turn limit
		KGB Tranquilizer Dart: no turn limit
		Snokebomb: no turn limit

		Louder Than Bomb: item, no turn limit
		Beancannon: item, no turn limit, no limit
		Tennis Ball: item, no turn limit

		anchor bomb: item, 30 turns

		Breathe Out: per hot jelly usage
	*/

	//Spring Kick is at the top because it is not turn ending. If a replacer is used the replaced monster can then have unspeakable things done to it (like another banish)
	if((inCombat ? auto_have_skill($skill[Spring Kick]) : possessEquipment($item[spring shoes])) && auto_is_valid($skill[Spring Kick]) && !(used contains "Spring Kick"))
	{
		return "skill " + $skill[Spring Kick];
	}

	if(auto_have_skill($skill[Peel Out]) && pete_peelOutRemaining() > 0 && get_property("peteMotorbikeMuffler") == "Extra-Smelly Muffler" && !(used contains "Peel Out") && useFree)
	{
		return "skill " + $skill[Peel Out];
	}

	if(auto_have_skill($skill[Howl of the Alpha]) && (my_mp() > mp_cost($skill[Howl of the Alpha])) &&!(used contains "Howl of the Alpha"))
	{
		return "skill " + $skill[Howl of the Alpha];
	}

	if(inCombat ? item_amount($item[Handful of split pea soup]) > 0 && (!(used contains "Handful of split pea soup")) && auto_is_valid($item[Handful of split pea soup]) && useFree : (item_amount($item[Handful of split pea soup]) > 0 || item_amount($item[Whirled peas]) >= 2))
	{
		return "item " + $item[Handful of split pea soup];
	}
	if((inCombat ? auto_have_skill($skill[Throw Latte on Opponent]) : possessEquipment($item[latte lovers member\'s mug])) && auto_is_valid($skill[Throw Latte On Opponent]) && !get_property("_latteBanishUsed").to_boolean() && !(used contains "Throw Latte on Opponent") && useFree)
	{
		return "skill " + $skill[Throw Latte on Opponent];
	}

	if((inCombat ? auto_have_skill($skill[Give Your Opponent The Stinkeye]) : possessEquipment($item[stinky cheese eye])) && auto_is_valid($skill[Give Your Opponent The Stinkeye]) && !get_property("_stinkyCheeseBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Give Your Opponent The Stinkeye])) && useFree)
	{
		return "skill " + $skill[Give Your Opponent The Stinkeye];
	}

	if((inCombat ? auto_have_skill($skill[Creepy Grin]) : possessEquipment($item[V for Vivala mask])) && auto_is_valid($skill[Creepy Grin]) && !get_property("_vmaskBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Creepy Grin])) && useFree)
	{
		return "skill " + $skill[Creepy Grin];
	}

	if(auto_have_skill($skill[Baleful Howl]) && my_hp() > hp_cost($skill[Baleful Howl]) && get_property("_balefulHowlUses").to_int() < 10 && !(used contains "baleful howl") && useFree)
	{
		loopHandlerDelayAll();
		return "skill " + $skill[Baleful Howl];
	}

	if(auto_have_skill($skill[Thunder Clap]) && (my_thunder() >= thunder_cost($skill[Thunder Clap])) && (!(used contains "thunder clap")))
	{
		return "skill " + $skill[Thunder Clap];
	}
	if(auto_have_skill($skill[Asdon Martin: Spring-Loaded Front Bumper]) && auto_is_valid($skill[Asdon Martin: Spring-Loaded Front Bumper]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Spring-Loaded Front Bumper])) && (!(used contains "Spring-Loaded Front Bumper")) && useFree)
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

	if((inCombat ? auto_have_skill($skill[Show Them Your Ring]) : possessEquipment($item[Mafia middle finger ring])) && auto_is_valid($skill[Show Them Your Ring]) && can_equip($item[Mafia middle finger ring]) && !get_property("_mafiaMiddleFingerRingUsed").to_boolean() && (my_mp() >= mp_cost($skill[Show Them Your Ring])) && useFree)
	{
		return "skill " + $skill[Show Them Your Ring];
	}
	if(auto_have_skill($skill[Breathe Out]) && auto_is_valid($skill[Breathe Out]) && (!(used contains "breathe out")) && useFree)
	{
		return "skill " + $skill[Breathe Out];
	}
	if(auto_have_skill($skill[Batter Up!]) && (my_fury() >= 5) && (inCombat ? hasClubEquipped() : true) && auto_is_valid($skill[Batter Up!]) && (!(used contains "batter up!")))
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

	if((inCombat ? auto_have_skill($skill[Talk About Politics]) : possessEquipment($item[Pantsgiving])) && auto_is_valid($skill[Talk About Politics]) && (get_property("_pantsgivingBanish").to_int() < 5) && have_equipped($item[Pantsgiving]) && (!(used contains "pantsgiving")))
	{
		return "skill " + $skill[Talk About Politics];
	}
	if((inCombat ? auto_have_skill($skill[Reflex Hammer]) : possessEquipment($item[Lil\' Doctor&trade; bag])) && auto_is_valid($skill[Reflex Hammer]) && get_property("_reflexHammerUsed").to_int() < 3 && !(used contains "Reflex Hammer") && useFree)
	{
		return "skill " + $skill[Reflex Hammer];
	}
	if((inCombat ? auto_have_skill($skill[Show Your Boring Familiar Pictures]) : possessEquipment($item[familiar scrapbook])) && auto_is_valid($skill[Show Your Boring Familiar Pictures]) && (get_property("scrapbookCharges").to_int() >= 200 || (get_property("scrapbookCharges").to_int() >= 100 && my_level() >= 13)) && !(used contains "Show Your Boring Familiar Pictures") && useFree)
	{
		return "skill " + $skill[Show Your Boring Familiar Pictures];
	}

	// bowling ball is only in inventory if it is available to use in combat. While on cooldown, it is not in inventory
	if((inCombat ? auto_have_skill($skill[Bowl a Curveball]) : item_amount($item[Cosmic Bowling Ball]) > 0) && auto_is_valid($skill[Bowl a Curveball]) && !(used contains "Bowl a Curveball") && useFree)
	{
		return "skill " + $skill[Bowl a Curveball];
	}

	if(auto_canFeelHatred() && auto_is_valid($skill[Feel Hatred]) && !(used contains "Feel Hatred") && useFree)
	{
		return "skill " + $skill[Feel Hatred];
	}

	if(auto_have_skill($skill[[7510]Punt]) && !(used contains "Punt"))
	{
		return "skill " + $skill[[7510]Punt];
	}
	
	if((item_amount($item[stuffed yam stinkbomb]) > 0) && (!(used contains "stuffed yam stinkbomb")) && auto_is_valid($item[stuffed yam stinkbomb]))
	{
		return "item " + $item[stuffed yam stinkbomb];
	}

	if(auto_have_skill($skill[[28021]Punt]) && (my_mp() > mp_cost($skill[[28021]Punt])) && !(used contains "Punt"))
	{
		return "skill " + $skill[[28021]Punt];
	}

	item saber = wrap_item($item[Fourth of May cosplay saber]);
	if((inCombat ? have_equipped(saber) : possessEquipment(saber)) && auto_is_valid($skill[Use the Force]) && auto_saberChargesAvailable() > 0 && !(used contains "Saber Force"))
	{
		// can't use the force on uncopyable monsters
		if(enemy == $monster[none] || enemy.copyable)
		{
			return auto_combatSaberBanish();
		}
	}

	if((inCombat ? auto_have_skill($skill[KGB Tranquilizer Dart]) : possessEquipment($item[Kremlin\'s Greatest Briefcase])) && auto_is_valid($skill[KGB Tranquilizer Dart]) && (get_property("_kgbTranquilizerDartUses").to_int() < 3) && (my_mp() >= mp_cost($skill[KGB Tranquilizer Dart])) && (!(used contains "KGB tranquilizer dart")) && useFree)
	{
		boolean useIt = true;
		if(get_property("sidequestJunkyardCompleted") != "none" && my_daycount() >= 2 && get_property("_kgbTranquilizerDartUses").to_int() >= 2)
		{
			useIt = false;
		}

		if(useIt)
		{
			return "skill " + $skill[KGB Tranquilizer Dart];
		}
	}
	if(auto_have_skill($skill[Snokebomb]) && auto_is_valid($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])) && (!(used contains "snokebomb")) && useFree)
	{
		return "skill " + $skill[Snokebomb];
	}

	if((inCombat ? auto_have_skill($skill[Monkey Slap]) : possessEquipment($item[cursed monkey\'s paw])) && auto_is_valid($skill[Monkey Slap]) && get_property("_monkeyPawWishesUsed").to_int() == 0 && !(used contains "Monkey Slap"))
	{
		return "skill " + $skill[Monkey Slap];
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

	if(item_amount($item[human musk]) > 0 && (!(used contains "human musk")) && auto_is_valid($item[human musk]) && (get_property("_humanMuskUses").to_int() < 3 && useFree)) //first 3 are free
	{
		return "item " + $item[human musk];
	}

	//We want to limit usage of these much more than the others.
	if(!($monsters[Natural Spider, Tan Gnat, Tomb Servant, Upgraded Ram] contains enemy))
	{
		return "";
	}

	int keep = 1;
	if(get_property("sidequestJunkyardCompleted") != "none")
	{
		keep = 0;
	}

	if((item_amount($item[Louder Than Bomb]) > keep) && (!(used contains "louder than bomb")) && auto_is_valid($item[Louder Than Bomb]) && useFree)
	{
		return "item " + $item[Louder Than Bomb];
	}
	if((item_amount($item[Tennis Ball]) > keep) && (!(used contains "tennis ball")) && auto_is_valid($item[Tennis Ball]) && useFree)
	{
		return "item " + $item[Tennis Ball];
	}
	if((item_amount($item[Deathchucks]) > keep) && (!(used contains "deathchucks"))&& auto_is_valid($item[Deathchucks]) && useFree)
	{
		return "item " + $item[Deathchucks];
	}
	if((item_amount($item[divine champagne popper]) > keep) && (!(used contains "divine champagne popper"))&& auto_is_valid($item[divine champagne popper]) && useFree)
	{
		return "item " + $item[divine champagne popper];
	}
	if((item_amount($item[anchor bomb]) > keep) && (!(used contains "anchor bomb"))&& auto_is_valid($item[anchor bomb]) && useFree)
	{
		return "item " + $item[anchor bomb];
	}

	return "";
}

string banisherCombatString(phylum enemyPhylum, location loc)
{
	return banisherCombatString(enemyPhylum, loc, false);
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
		if(have_equipped(wrap_item($item[Fourth of May cosplay saber])) && auto_saberChargesAvailable() > 0)
		{
			// can't use the force on uncopyable monsters
			if(target == $monster[none] || (target.copyable && !noForceDrop))
			{
				return auto_combatSaberYR();
			}
		}
		else return "";
	}

	boolean free_monster = (isFreeMonster(target, my_location()) || (get_property("breathitinCharges").to_int() > 0 && my_location().environment == "outdoor"));
	
	if(have_effect($effect[Everything Looks Yellow]) <= 0)
	{

		if(auto_have_skill($skill[Fondeluge]) && (my_mp() >= mp_cost($skill[Fondeluge])))
		{
			return "skill " + $skill[Fondeluge]; // 50 turns
		}
		if((item_amount($item[Yellowcake Bomb]) > 0) && auto_is_valid($item[Yellowcake Bomb]))
		{
			return "item " + $item[Yellowcake Bomb]; // 75 turns + quest item
		}
		if(free_monster && (item_amount($item[yellow rocket]) > 0) && auto_is_valid($item[yellow rocket]))
		{
			return "item " + $item[yellow rocket]; // 75 turns & 250 meat - better than wasting a freekill on an already free monster
		}
		if(inCombat ? have_skill($skill[Spit jurassic acid]) : auto_hasParka() && auto_is_valid($skill[Spit jurassic acid]) && hasTorso())
		{
			return "skill " + $skill[Spit jurassic acid]; //100 Turns and free kill
		}
		if((item_amount($item[yellow rocket]) > 0) && auto_is_valid($item[yellow rocket]))
		{
			return "item " + $item[yellow rocket]; // 75 turns & 250 meat
		}
		if(inCombat ? have_skill($skill[Blow the Yellow Candle\!]) : auto_haveRoman() && auto_is_valid($skill[Blow the Yellow Candle\!]))
		{
			return "skill " + $skill[Blow the Yellow Candle\!]; //75 Turns
		}
		if(inCombat ? have_skill($skill[Unleash the Devil\'s Kiss]) : auto_hasRetrocape() && auto_is_valid($skill[Unleash the Devil\'s Kiss]))
		{
			return "skill " + $skill[Unleash the Devil\'s Kiss]; // 99 turns
		}
		if(auto_have_skill($skill[Disintegrate]) && auto_is_valid($skill[Disintegrate]) && (my_mp() >= mp_cost($skill[Disintegrate])))
		{
			return "skill " + $skill[Disintegrate]; // 100 trurns
		}
		if(auto_have_skill($skill[Ball Lightning]) && (my_lightning() >= lightning_cost($skill[Ball Lightning])))
		{
			return "skill " + $skill[Ball Lightning]; // 99 turns + 5 lightning
		}
		if(auto_have_skill($skill[Wrath of Ra]) && (my_mp() >= mp_cost($skill[Wrath of Ra])))
		{
			return "skill " + $skill[Wrath of Ra]; // 100 turns
		}
		if((item_amount($item[Mayo Lance]) > 0) && auto_is_valid($item[Mayo Lance]) && (get_property("mayoLevel").to_int() > 0) && auto_is_valid($item[Mayo Lance]))
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
		if((inCombat ? my_familiar() == $familiar[Crimbo Shrub] : auto_have_familiar($familiar[Crimbo Shrub])) && auto_is_valid($skill[Open a Big Yellow Present]) && (get_property("shrubGifts") == "yellow"))
		{
			return "skill " + $skill[Open a Big Yellow Present]; // 149 turns
		}
	}

	if(asdonCanMissile())
	{
		return "skill " + $skill[Asdon Martin: Missile Launcher];
	}

	if(auto_canFeelEnvy())
	{
		return "skill " + $skill[Feel Envy];
	}
	
	item saber = wrap_item($item[Fourth of May cosplay saber]);
	if((inCombat ? have_equipped(saber) : possessEquipment(saber)) && (auto_saberChargesAvailable() > 0))
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
	if(auto_macrometeoritesAvailable() > 0 && auto_is_valid($skill[Macrometeorite]))
	{
		return "skill " + $skill[Macrometeorite];
	}
	if(auto_powerfulGloveReplacesAvailable(inCombat) > 0 && auto_is_valid($skill[CHEAT CODE: Replace Enemy]))
	{
		return "skill " + $skill[CHEAT CODE: Replace Enemy];
	}
	if (canUse($item[waffle]) && !in_avantGuard())
	{
		return useItems($item[waffle], $item[none]);
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

boolean combat_status_check(string mark)
{
	return contains_text(get_property("_auto_combatState"), mark);
}

void combat_status_add(string mark)
{
	string st = get_property("_auto_combatState");
	if(!combat_status_check(mark))
	{
		st = st+ "(" +mark+ ")";
	}
	set_property("_auto_combatState", st);
}

boolean wantToForceDrop(monster enemy)
{
	//skills that can be used on any combat round, repeatedly until an item is stolen
	//take into account if a yellow ray has been used. Must have been one that doesn't insta-kill
	boolean mildEvilAvailable = canUse($skill[Perpetrate Mild Evil],false) && get_property("_mildEvilPerpetrated").to_int() < 3;
	boolean swoopAvailable = canUse($skill[Swoop like a Bat], true) && get_property("_batWingsSwoopUsed").to_int() < 11;

	boolean forceDrop = false;

	//only force 1 scent gland from each filthworm
	if(!combat_status_check("yellowray"))
	{
		if(enemy == $monster[Larval Filthworm] && item_amount($item[filthworm hatchling scent gland]) < 1)
		{
			forceDrop = true;
		}
		if(enemy == $monster[Filthworm Drone] && item_amount($item[filthworm drone scent gland]) < 1)
		{
			forceDrop = true;
		}
		if(enemy == $monster[Filthworm Royal Guard] && item_amount($item[filthworm royal guard scent gland]) < 1)
		{
			forceDrop = true;
		}
	}
	

	// polar vortex/mild evil is more likely to pocket an item the higher the drop rate. Unlike XO which has equal chance for all drops
	// reserve extinguisher 30 charge for filth worms
	if(auto_fireExtinguisherCharges() > 20 || mildEvilAvailable || swoopAvailable)
	{
		int dropsFromYR = 0;
		if(combat_status_check("yellowray"))
		{
			dropsFromYR = 1;
		}

		if($monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal] contains enemy)
		{
			if(hedgeTrimmersNeeded() + dropsFromYR > 0)
			{
				forceDrop = true;
			}
		}

		// Number of times bowled is 1 less than hiddenBowlingAlleyProgress. Need 5 bowling balls total, 5+1 = 6 needed in this conditional
		if(enemy == $monster[Pygmy bowler] && (get_property("hiddenBowlingAlleyProgress").to_int() + item_amount($item[Bowling Ball]) + dropsFromYR) < 6)
		{
			forceDrop = true;
		}

		if(enemy == $monster[Dairy Goat] && (item_amount($item[Goat Cheese]) + dropsFromYR) < 3)
		{
			forceDrop = true;
		}

		if((item_drops(enemy) contains $item[shadow brick]) && (auto_neededShadowBricks() + dropsFromYR) > 0)
		{
			forceDrop = true;
		}
	}
	
	if(isActuallyEd() && my_location() == $location[The Secret Council Warehouse])
	{
		int progress = get_property("warehouseProgress").to_int();
		if(enemy == $monster[Warehouse Guard])
		{
			int n_pages = item_amount($item[warehouse map page]);
			int progress_with_pages = progress+n_pages*8;
			if (progress_with_pages<39) // need 40 to "win", will get +1 for this combat
			{
				forceDrop = true;
			}
		}
		else if(enemy == $monster[Warehouse Clerk])
		{
			int n_pages = item_amount($item[warehouse inventory page]);
			int progress_with_pages = progress+n_pages*8;
			if (progress_with_pages<39) // need 40 to "win", will get +1 for this combat
			{
				forceDrop = true;
			}
		}
	} // ed warehouse

	return forceDrop;
}

boolean wantToDouse(monster enemy)
{
	switch (enemy)
	{
		case $monster[larval filthworm]:
			return item_amount($item[filthworm hatchling scent gland  ]) == 0;
		case $monster[filthworm drone]:
			return item_amount($item[filthworm drone scent gland      ]) == 0;
		case $monster[filthworm royal guard]:
			return item_amount($item[filthworm royal guard scent gland]) == 0;
	}
	return false;
}

boolean canSurviveShootGhost(monster enemy, int shots) {
	int damage;
	switch(enemy)
	{
		case $monster[the ghost of Oily McBindle]:
			damage = my_maxhp() * 0.4 * elemental_resistance($element[sleaze]) / 100;
			break;
		case $monster[boneless blobghost]:
			damage = my_maxhp() * 0.45 * elemental_resistance($element[spooky]) / 100;
			break;
		case $monster[the ghost of Monsieur Baguelle]:
			damage = my_maxhp() * 0.5 * elemental_resistance($element[hot]) / 100;
			break;
		case $monster[The Headless Horseman]:
			damage = my_maxhp() * 0.55 * elemental_resistance($element[spooky]) / 100;
			break;
		case $monster[The Icewoman]:
			damage = my_maxhp() * 0.6 * elemental_resistance($element[cold]) / 100;
			break;
		case $monster[The ghost of Ebenoozer Screege]:
			damage = my_maxhp() * 0.65 * elemental_resistance($element[spooky]) / 100;
			break;
		case $monster[The ghost of Lord Montague Spookyraven]:
			damage = my_maxhp() * 0.7 * elemental_resistance($element[stench]) / 100;
			break;
		case $monster[The ghost of Vanillica "Trashblossom" Gorton]:
			damage = my_maxhp() * 0.75 * elemental_resistance($element[stench]) / 100;
			break;
		case $monster[The ghost of Sam McGee]:
			damage = my_maxhp() * 0.8 * elemental_resistance($element[hot]) / 100;
			break;
		case $monster[The ghost of Richard Cockingham]:
			damage = my_maxhp() * 0.85 * elemental_resistance($element[spooky]) / 100;
			break;
		case $monster[The ghost of Waldo the Carpathian]:
			damage = my_maxhp() * 0.9 * elemental_resistance($element[hot]) / 100;
			break;
		case $monster[Emily Koops, a spooky lime]:
			damage = my_maxhp() * 0.95 * elemental_resistance($element[spooky]) / 100;
			break;
		case $monster[The ghost of Jim Unfortunato]:
			damage = my_maxhp() * elemental_resistance($element[sleaze]) / 100;
			break;
		default:
			damage = my_maxhp() * 0.3;
	}
	return my_hp() > damage * shots;
}
