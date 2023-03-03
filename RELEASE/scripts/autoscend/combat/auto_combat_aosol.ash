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
	
	if(my_class() == $class[Pig Skinner])
	{
		if(my_hp() < 0.7 * my_maxhp() && canUse($skill[Second Wind])) return useSkill($skill[Second Wind], true); //because stats are very high, want to use this earlier rather than later
		if(canUse($skill[Stop Hitting Yourself], true)) return useSkill($skill[Stop Hitting Yourself], true);
		if(canUse($skill[Hot Foot], true) && (enemy.defense_element != $element[hot]) && !enemyCanBlocksSkills()) return useSkill($skill[Hot Foot], true);
		if(canUse($skill[Ball Throw], true) && !enemy_physical_immune) return useSkill($skill[Ball Throw], true);
		return "attack with weapon";
	}
	/*if(my_class() == "Cheese Wizard")
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
	}*/
	// if(my_class() == "Jazz Agent")
	// {
	// 	if(canUse($skill[]))
	// }
	
	return "";
}
