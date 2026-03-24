boolean amw_wanttoPP(monster enemy)
{
	if(!in_amw() || !auto_have_skill($skill[Chicken Fingers]))
	{
		return false;
	}
	// cannot autosell for meat so pickpocketing is less profitable,
	// so higher survive requirement than default. maybe exempt certain monsters from higher req?
	if(!canSurvive(8.0))
	{
		return false;
	}
	return true;
}

string auto_combatMeatGolemStage3(int round, monster enemy, string text)
{
	if(!in_amw()){
		return "";
	}

	// this delevel also might deal lots of damage
	// Skip if monster would die quickly, before stage 4 might finish
	if((monster_hp() - my_buffedstat($stat[muscle]))/monster_hp()<0.55){return "";}
	// since meat = adv, don't want to delevel if not necessary
	// also skipping if we might die after delevel, because we may be able to stun instead
	if((!canSurvive(8.0) || monster_hp() >= 500) && canSurvive(0.7) && canUse($skill[Meat Cleaver], true, true))
	{
		return useSkill($skill[Meat Cleaver]);
	}

	return "";
}

string auto_combatMeatGolemStage5(int round, monster enemy, string text)
{
	if(!in_amw())
	{
		return "";
	}

	// make sure to heal if possible and necessary
	if((!canSurvive(1.4) || my_hp() < 0.5*my_maxhp()) && canUse($skill[Chew the Fat], false) && my_hp() < my_maxhp() * 0.95){
		return useSkill($skill[Chew the Fat], false);
	}
	
	// make sure high HP combats conclude in a timely fashion
	// only if needed; these skills cost 4-10x more than a regular combat skill
	if (canUse($skill[Steak Through the Heart], true) && round > 12)
	{
		return useSkill($skill[Steak Through the Heart], true);
	}
	if (canUse($skill[Wet Rub], true) && monster_hp() >= 400)
	{
		return useSkill($skill[Wet Rub], true);
	}

	// Darts always welcome
	if(have_equipped($item[Everfull Dart Holster]) && get_property("_dartsLeft").to_int() > 0)
	{
		return useSkill(dartSkill());
	}

	// Step 1: get base values for each spell
	int beef_shank_value = my_buffedstat($stat[muscle]);
	int spicy_meatball_value = my_buffedstat($stat[mysticality]);
	int bacon_ray_value = 0.55*my_buffedstat($stat[moxie]); // deals base dmg equal to half moxie, but it's a little cheaper

	// Step 2: apply disqualifications
	// the physical resistance bit is entirely arbitrary, maybe should be tweaked
	if (!canUse($skill[Beef Shank], false) || enemy.physical_resistance > 70)
	{
		beef_shank_value = 0;
	}
	if (!canUse($skill[Spicy Meatball], false) || enemy.defense_element == $element[hot])
	{
		spicy_meatball_value = 0;
	}
	if (!canUse($skill[Bacon Ray], false) || enemy.defense_element == $element[sleaze])
	{
		bacon_ray_value = 0;
	}
	
	// Step 3: apply vulnerability multipliers
	if (enemy.defense_element == $element[cold] || enemy.defense_element == $element[spooky])
	{
		spicy_meatball_value = 2*spicy_meatball_value;
	}
	else if (enemy.defense_element == $element[stench] || enemy.defense_element == $element[hot])
	{
		bacon_ray_value = 2*bacon_ray_value;
	}

	// Step 4: return the spell with the highest value, or none if none qualified
	if (spicy_meatball_value > bacon_ray_value && spicy_meatball_value > beef_shank_value)
	{
		return useSkill($skill[Spicy Meatball], false);
	}
	else if (bacon_ray_value > beef_shank_value)
	{
		return useSkill($skill[Bacon Ray], false);
	}
	else if (beef_shank_value != 0)
	{
		return useSkill($skill[Beef Shank], false);
	}
	return "";
}