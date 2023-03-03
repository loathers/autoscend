string auto_combatAoSOLStage5(int round, monster enemy, string text)
{
	// stage 5 = kill
	if(!in_aosol())
	{
		return "";
	}
	
	boolean enemy_physical_immune = enemy.physical_resistance > 80;
	//float enemy_physical_res = 1 - (enemy.physical_resistance * 0.01);	//convert % into float
	float dmg;
	
	if(my_class() == "Pig Skinner")
	{
		if(my_hp() < 0.7 * my_maxhp() && canUse($skill[Second Wind]))) //because stats are very high, want to use this earlier rather than later
		{
			return useSkill($skill[Second Wind], false);
		}
		if(canUse($skill[Hot Foot]) && monster_element(enemy) != $element[hot] && !enemyCanBlocksSkills())
		{
			
			dmg = my_buffedstat($stat[mysticality]);
			if(canSurvive(turns_to_kill(dmg)))
			{
				return useSkill($skill[Hot Foot], false);
			}
		}
		if(canUse($skill[Ball Throw]) && !enemy_physical_immune)
		{
			return useSkill($skill[Ball Throw], false);
		}
		return "attack with weapon";
	}
	if(my_class() == "Cheese Wizard")
	{
		if(canUse($skill[Stilton Splatter]) && !enemy_physical_immune)
		{
			return useSkill($skill[Stilton Splatter]);
		}
		if(my_hp() < 0.7 * my_maxhp() && canUse($skill[Emmental Elemental]) && !enemyCanBlocksSkills())
		{
			return useSkill($skill[Emmental Elemental], false);
		}
		if(canUse($skill[Crack Knuckles]) && !enemy_physical_immune)
		{
			return useSkill($skill[Crack Knuckles]);
		}
		if(canUse($skill[Parmesan Missile]))
		{
			return useSkill(skill[Parmesan Missile]);
		}
	}
	// if(my_class() == "Jazz Agent")
	// {
	// 	if(canUse($skill[]))
	// }
	
	return "";
}
