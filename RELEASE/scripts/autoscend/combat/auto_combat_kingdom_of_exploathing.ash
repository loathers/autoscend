//Path specific combat handling for Kingdom of Exploathing

string auto_combatExploathingStage1(int round, monster enemy, string text)
{
	##stage1 = 1st round actions: puzzle boss, banish, escape, pickpocket, etc. things that need to be done before debuff
	
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
	
	return "";
}
