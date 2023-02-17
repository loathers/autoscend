string auto_combatAoSOLStage5(int round, monster enemy, string text)
{
	// stage 5 = kill
	if(!in_aosol())
	{
		return "";
	}
	
	boolean enemy_physical_immune = enemy.physical_resistance > 99;
	boolean enemy_hot_immune = monster_element(enemy) == $element[hot] || enemy == $monster[Protector S. P. E. C. T. R. E.];
	float enemy_physical_res = 1 - (enemy.physical_resistance * 0.01);	//convert % into float
	float dmg;
	
	//scrap using attacks. reserved for beefier monsters with at least 40 HP
	if(canUse($skill[Ball Throw], false) && !enemy_physical_immune)
	{
		if(canSurvive(turns_to_kill(dmg)))
		{
			return useSkill($skill[Ball Throw], false);
		}
	}
	if(canUse($skill[Tackle], false) && !enemy_physical_immune)
	{
		if(canSurvive(turns_to_kill(dmg)))
		{
			return useSkill($skill[Tackle], false);
		}
	}
	
	return "";
}
