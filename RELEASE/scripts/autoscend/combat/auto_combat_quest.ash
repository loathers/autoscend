// This file is for quest specific combat handling.

// the junkyard gremlin quest
string auto_JunkyardCombatHandler(int round, monster enemy, string text)
{
	if(!($monsters[A.M.C. gremlin, batwinged gremlin, batwinged gremlin (tool), erudite gremlin, erudite gremlin (tool),
	spider gremlin, spider gremlin (tool), vegetable gremlin, vegetable gremlin (tool)] contains enemy))
	{
		if (isActuallyEd())
		{
			return auto_edCombatHandler(round, enemy, text);
		}
		return auto_combatHandler(round, enemy, text);
	}

	auto_log_info("auto_JunkyardCombatHandler: " + round, "brown");
	if(round == 0)
	{
		set_property("auto_gremlinMoly", false);
		remove_property("_auto_combatState");
	}

	if ($monsters[batwinged gremlin (tool), erudite gremlin (tool), spider gremlin (tool), vegetable gremlin (tool)] contains enemy) {
		set_property("auto_gremlinMoly", true);
	}

	if (!combat_status_check("gremlinNeedBanish") && !get_property("auto_gremlinMoly").to_boolean() && isActuallyEd())
	{
		combat_status_add("gremlinNeedBanish");
	}

	if (in_fotd())
	{
		// In Fall of the Dinosaurs just use the magnet without waiting for a message
		if (canUse($item[Molybdenum Magnet]) && $monsters[batwinged gremlin (tool), erudite gremlin (tool), spider gremlin (tool), vegetable gremlin (tool)] contains enemy)
		{
			return useItem($item[Molybdenum Magnet]);
		}
		return auto_combatHandler(round, enemy, text);
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

	if(contains_text(text, "<!--moly1-->") || contains_text(text, "<!--moly2-->") || contains_text(text, "<!--moly3-->") || contains_text(text, "<!--moly4-->"))
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
	
	if(canUse($skill[Beanscreen]))
	{
		return useSkill($skill[Beanscreen]);
	}

	if(canUse($skill[Bad Medicine]))
	{
		return useSkill($skill[Bad Medicine]);
	}

	if(canUse($skill[Good Medicine]) && canSurvive(2.1))
	{
		return useSkill($skill[Good Medicine]);
	}

	item flyer = $item[Rock Band Flyers];
	if(auto_warSide() == "hippy")
	{
		flyer = $item[Jam Band Flyers];
	}
	skill stunner = getStunner(enemy);
	boolean stunned = combat_status_check("stunned");
	boolean gremlinTakesDamage = (isAttackFamiliar(my_familiar()) || (monster_hp() < (0.8*monster_hp(enemy))));
	boolean shouldFlyer = false;
	boolean staggeringFlyer = false;
	item flyerWith;
	
	if(my_class() == $class[Disco Bandit] && auto_have_skill($skill[Deft Hands]) && !combat_status_check("(it"))
	{
		//first item throw in the fight staggers
		staggeringFlyer = true;
	}
	if(auto_have_skill($skill[Ambidextrous Funkslinging]))
	{	
		if (canUse($item[Time-Spinner]))
		{
			flyerWith = $item[Time-Spinner];
			staggeringFlyer = true;
		}
		else if (canUse($item[beehive]))
		{
			boolean canBeehiveGremlin;
			int beehiveDamage = ceil(30*combatItemDamageMultiplier()*MLDamageToMonsterMultiplier());
			if (get_property("auto_gremlinMoly").to_boolean())
			{
				//don't kill tool gremlin with beehive
				canBeehiveGremlin = !gremlinTakesDamage && monster_hp() > (beehiveDamage + 30 - round) && canUse($item[Seal Tooth], false);
			}
			else
			{
				//don't miss MP by killing weak monsters with beehive
				canBeehiveGremlin = !(monster_hp() <= beehiveDamage && my_class() == $class[Sauceror] && haveUsed($skill[Curse Of Weaksauce]));
			}
			if (canBeehiveGremlin)
			{
				flyerWith = $item[beehive];
				staggeringFlyer = true;
			}
		}
		if(staggeringFlyer && monster_level_adjustment() > 150)	//gremlins only, no need to check stunnable
		{
			staggeringFlyer = false;
		}
	}
	
	if (get_property("auto_gremlinMoly").to_boolean() && !canSurvive(20) && !stunned && !staggeringFlyer)	//don't flyer tool gremlins if it's dangerous to survive them for long
	{
		if(monster_attack() > ( my_buffedstat($stat[moxie]) + 10) && !canSurvive(10) && haveUsed($skill[Curse Of Weaksauce]))
		{
			//if after all deleveling it's still too strong to safely stasis let weaksauce delevel it more in exchange for a few turns
			//except if stuck with an attack familiar or unforeseen passive damage effects that can kill the gremlin
			if(!gremlinTakesDamage && round < 10 && stunner != $skill[none])
			{
				combat_status_add("stunned");
				return useSkill(stunner);
			}
		}
	}
	else if (canUse(flyer) && get_property("flyeredML").to_int() < 10000 && !get_property("auto_ignoreFlyer").to_boolean())
	{
		if(!staggeringFlyer && stunner != $skill[none] && !stunned)
		{
			combat_status_add("stunned");
			return useSkill(stunner);
		}
		if (isActuallyEd())
		{
			set_property("auto_edStatus", "UNDYING!");
		}
		if(canSurvive(3.0) || stunned || staggeringFlyer)
		{
			shouldFlyer = true;
		}
		if(shouldFlyer)
		{
			if(flyerWith != $item[none])
			{
				return useItems(flyer, flyerWith);
			}
			else
			{
				return useItem(flyer);
			}
		}
	}

	if(!get_property("auto_gremlinMoly").to_boolean())
	{
		if (isActuallyEd())
		{
			if (get_property("_edDefeats").to_int() >= 2)
			{
				return findBanisher(round, enemy, text);
			}
			else if (canUse($item[Seal Tooth], false) && get_property("auto_edStatus") == "UNDYING!")
			{
				return useItem($item[Seal Tooth], false);
			}
		}
		else
		{
			return findBanisher(round, enemy, text);
		}
	}
	
	if(!canSurvive(1.5))
	{
		if(!isActuallyEd() || get_property("_edDefeats").to_int() >= 2)
		{
			abort("I am too weak to safely stasis this gremlin");
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
