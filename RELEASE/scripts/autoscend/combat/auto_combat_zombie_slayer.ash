//Path specific combat handling for Zombie Slayer

boolean wantBearHug(monster enemy)
{
	return canUse($skill[Bear Hug]) && get_property("_bearHugs").to_int() < 10 && !enemy.boss;
}

boolean wantKodiakMoment(monster enemy)
{
	return canUse($skill[Kodiak Moment]) && enemy.physical_resistance >= 80;
} 

string auto_combatZombieSlayerStage1(int round, monster enemy, string text)
{
	if (!in_zombieSlayer())
	{
		return "";
	}

	return "";
}

string auto_combatZombieSlayerStage2(int round, monster enemy, string text)
{
	if (!in_zombieSlayer())
	{
		return "";
	}

	return "";
}

string auto_combatZombieSlayerStage3(int round, monster enemy, string text)
{
	if (!in_zombieSlayer())
	{
		return "";
	}

	if(canUse($skill[Infectious Bite]))
	{
		return useSkill($skill[Infectious Bite]);
	}

	// Just always use Bear-ly Legal for the delevel + meat, unless we want to Bear Hug or Kodiak Moment
	if (canUse($skill[Bear-ly Legal]) && !wantBearHug(enemy) && !wantKodiakMoment(enemy))
	{
		return useSkill($skill[Bear-ly Legal]);
	}

	return "";
}

string auto_combatZombieSlayerStage4(int round, monster enemy, string text)
{
	if (!in_zombieSlayer())
	{
		return "";
	}

	return "";
}

string auto_combatZombieSlayerStage5(int round, monster enemy, string text)
{
	if (!in_zombieSlayer())
	{
		return "";
	}

	if (wantBearHug(enemy))
	{
		// TODO: Prefer group monsters
		// TODO: Ignore free monsters
		return useSkill($skill[Bear Hug]);
	}

	// Spam plague claws if we won't die
	if(round < 20 && canSurvive(5.0) && auto_have_skill($skill[Plague Claws]) && enemy.physical_resistance < 80)
	{
		return useSkill($skill[Plague Claws]);
	}

	if (wantKodiakMoment(enemy))
	{
		return useSkill($skill[Kodiak Moment]);
	}

	if (canUse($skill[Bilious Burst]) && enemy.physical_resistance >= 80)
	{
		return useSkill($skill[Bilious Burst]);
	}

	return "";
}