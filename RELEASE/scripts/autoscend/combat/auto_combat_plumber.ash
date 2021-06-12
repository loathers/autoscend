//Path specific combat handling for path of the plumber

string auto_combatPlumberStage4(int round, monster enemy, string text)
{
	//stage 4 killing the enemy. plumber specific
	
	if(my_class() != $class[Plumber])
	{
		return "";
	}

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
		{
			return useSkill($skill[[7333]Fireball Barrage]);
		}
	return useSkill($skill[Fireball Toss], false);
	}
	
	return "";
}
