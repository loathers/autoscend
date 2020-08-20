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
		set_property("auto_combatHandler", "");
	}

	string combatState = get_property("auto_combatHandler");
	string edCombatState = get_property("auto_edCombatHandler");

	if ($monsters[batwinged gremlin (tool), erudite gremlin (tool), spider gremlin (tool), vegetable gremlin (tool)] contains enemy) {
		set_property("auto_gremlinMoly", true);
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
