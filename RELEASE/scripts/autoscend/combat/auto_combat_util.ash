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

string getStallString(monster enemy)
{
	// if you call this without actually doing what it returns it'll make me sad :(
	
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

boolean registerCombat(string action)
{
	set_property("auto_combatHandler", get_property("auto_combatHandler") + "(" + to_lower_case(action) + ")");
	return true;
}

boolean registerCombat(skill sk)
{
	return registerCombat(to_string(sk));
}

boolean registerCombat(item it)
{
	return registerCombat(to_string(it));
}

boolean containsCombat(string action)
{
	action = "(" + to_lower_case(action) + ")";
	return contains_text(get_property("auto_combatHandler"), action);
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
