string auto_combatWereProfessorStage1(int round, monster enemy, string text)
{
	if(!in_wereprof())
	{
		return "";
	}

	if(!is_werewolf())
	{
		set_property("auto_skipStage2", true); //Don't even want to try Stage 2 as a Professor
		set_property("auto_skipStage3", true); //Don't even want to try Stage 3 as a Professor
	}

	return "";
}

string auto_combatWereProfessorStage4(int round, monster enemy, string text)
{
	if(!in_wereprof())
	{
		return "";
	}
	if(!is_werewolf() && wereprof_oculus())
	{
		if(canUse(to_skill(7512))) //Advanced Research
		{
			return(to_skill(7512));
		}
	}
	return "";
}

string auto_combatWereProfessorStage5(int round, monster enemy, string text)
{
	if(!in_wereprof())
	{
		return "";
	}

	boolean enemy_physical_immune = enemy.physical_resistance > 99;
	float enemy_physical_res = 1 - (enemy.physical_resistance * 0.01);	//convert % into float
	float dmg;

	if(is_werewolf())
	{
		if(enemy_physical_immune && canUse($skill[Bite]))
		{
			return(use_skill($skill[Bite]));
		}
		else if(have_equipped($item[Everfull Dart Holster]) && get_property("_dartsLeft").to_int() > 0) //want dart skill as high as possible for Professor
		{
			return useSkill(dartSkill());
		}
		if(canUse($skill[Rend]))
		{
			return useSkill($skill[Rend]);
		}
	}
	if(!is_werewolf())
	{
		if(have_equipped($item[Everfull Dart Holster]) && get_property("_dartsLeft").to_int() > 0) //want dart skill as high as possible for Professor
		{
			return useSkill(dartSkill());
		}
		else if(auto_haveCosmicBowlingBall() && canUse($item[cosmic bowling ball]) && monster_hp() < 100)
		{
			return useItem($item[cosmic bowling ball]);
		}
		else
		{
			return "runaway"; //Can't do anything further as Professor other than using items/running away
		}
	}
	return "";
}