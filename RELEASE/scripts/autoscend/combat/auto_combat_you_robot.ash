string auto_combat_robot_stage5(int round, monster enemy, string text)
{
	// stage 5 = kill
	if(!in_robot())
	{
		return "";
	}
	
	boolean enemy_physical_immune = enemy.physical_resistance > 99;
	boolean enemy_hot_immune = monster_element(enemy) == $element[hot] || enemy == $monster[Protector S. P. E. C. T. R. E.];
	float enemy_physical_res = 1 - (enemy.physical_resistance * 0.01);	//convert % into float
	float dmg;
	
	//scrap using attacks. reserved for beefier monsters with at least 40 HP
	if(canUse($skill[Snipe], false) && !enemy_physical_immune)
	{
		//Spend 1 Scrap to deal 100% of your Mysticality in damage
		boolean better_than_crotch_burn = (monster_hp() > 40 || enemy_hot_immune);
		dmg = my_buffedstat($stat[mysticality]) * enemy_physical_res;
		if(canSurvive(turns_to_kill(dmg)) && better_than_crotch_burn)
		{
			return useSkill($skill[Snipe], false);
		}
	}
	
	//blow snow is an energy using attack. normally we do not want to use it. But it is important in the blech house
	if(canUse($skill[Blow Snow], false) &&
	$monsters[smut orc jacker, smut orc nailer, smut orc pipelayer, smut orc screwer] contains enemy)
	{
		if(canSurvive(turns_to_kill(my_buffedstat($stat[muscle]))))
		{
			return useSkill($skill[Blow Snow], false);
		}
	}
	
	//basic attacks as a robot which are free.
	if(canUse($skill[Swing Pound-O-Tron], false) && !enemy_physical_immune)
	{
		//20 + 0.1*mus damage
		dmg = ( 20 + 0.1*my_buffedstat($stat[muscle]) )* enemy_physical_res;
		if(canSurvive(turns_to_kill(dmg)))
		{
			return useSkill($skill[Swing Pound-O-Tron], false);
		}
	}
	if(canUse($skill[Crotch Burn], false) && !enemy_hot_immune)
	{
		//20 + 0.1*mys fire damage
		dmg = 20 + 0.1*my_buffedstat($stat[mysticality]);
		if(canSurvive(turns_to_kill(dmg)))
		{
			return useSkill($skill[Crotch Burn], false);
		}
	}
	if(canUse($skill[Shoot Pea], false) && !enemy_physical_immune)
	{
		//20 + 0.1*mox damage
		dmg = ( 20 + 0.1*my_buffedstat($stat[moxie]) )* enemy_physical_res;
		if(canSurvive(turns_to_kill(dmg)))
		{
			return useSkill($skill[Shoot Pea], false);
		}
	}
	
	if(equipped_item($slot[weapon]) == $item[none])
	{
		abort("Robot does not know how to fight this enemy. Beep Boop.");
	}
	return "";
}
