string auto_combatAoSOLStage5(int round, monster enemy, string text)
{
	// stage 5 = kill
	if(!in_aosol())
	{
		return "";
	}
	
	boolean enemy_physical_immune = enemy.physical_resistance > 80;
	float enemy_physical_res = 1 - (enemy.physical_resistance * 0.01);	//convert % into float
	float dmg;
	
	//scrap using attacks. reserved for beefier monsters with at least 40 HP
	if(canUse($skill[Ball Throw]) && !enemy_physical_immune)
	{
		dmg = my_buffedstat($stat[muscle]) * enemy_physical_res;
		if(canSurvive(turns_to_kill(dmg)))
		{
			return useSkill($skill[Ball Throw], false);
		}
	}
	// if(canUse($skill[Tackle], false) && !enemy_physical_immune)
	// {
	// 	return useSkill($skill[Tackle], false);
	// }
	
	return "";
}
