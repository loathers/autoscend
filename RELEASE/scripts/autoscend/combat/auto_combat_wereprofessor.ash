string auto_combatWereProfessorStage1(int round, monster enemy, string text)
{
	if(!in_wereprof())
	{
		return "";
	}

	if(is_professor())
	{
		set_property("auto_skipStage3", true); //Don't even want to try Stage 3 as a Professor
	}

	if(enemy == $monster[Wall Of Bones])
	{
		if(canUse($skill[Slaughter]) && have_effect($effect[Everything Looks Red]) == 0)
		{
			return useSkill($skill[Slaughter]);
		}
	}

	return "";
}

string auto_combatWereProfessorStage4(int round, monster enemy, string text)
{
	//only care about Advanced Research as a Professor
	if(!in_wereprof())
	{
		return "";
	}

	foreach str in split_string(get_property("wereProfessorAdvancedResearch").to_string(),",")
	{
		if(str == enemy.id)
		{
			return "";
		}
	}

	if(is_professor() && wereprof_oculus() && !haveUsed(to_skill(7512)))
	{
		markAsUsed(to_skill(7512));
		return(to_skill(7512));
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
		if(enemy_physical_immune && canUse($skill[Bite], true))
		{
			return(useSkill($skill[Bite], true)); // elemental damage skill
		}
		else if(have_equipped($item[Everfull Dart Holster]) && get_property("_dartsLeft").to_int() > 0) //want dart skill as high as possible for Professor
		{
			return useSkill(dartSkill());
		}
		if(!enemy_physical_immune && canUse($skill[Rend], false))
		{
			return useSkill($skill[Rend], true);
		}
		return "attack with weapon"; //worst case scenario just use this
	}
	if(is_professor())
	{
		if(have_equipped($item[Everfull Dart Holster]) && get_property("_dartsLeft").to_int() > 0) //want dart skill as high as possible for Professor
		{
			return useSkill(dartSkill());
		}
		else if(auto_haveCosmicBowlingBall() && canUse($item[cosmic bowling ball]) && !enemy_physical_immune && monster_hp() < 100)
		{
			return useItem($item[cosmic bowling ball]); // 100 physical damage
		}
		else
		{
			return "runaway"; //Can't do anything further as Professor other than using items/running away
		}
	}
	return "";
}