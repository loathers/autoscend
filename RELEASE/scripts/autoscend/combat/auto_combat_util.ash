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
