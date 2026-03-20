boolean amw_wanttoPP(monster enemy)
{
	if(!in_amw()){
		return false;
	}
	if(!auto_have_skill($skill[Chicken Fingers]))
	{
		return false;
	}
	// cannot autosell for meat so pickpocketing is less profitable
	// maybe exempt certain monsters?
	if(!canSurvive(8.0)
	{
		return false;
	}
	return true;
}

string auto_combatMeatGolemStage3(int round, monster enemy, string text)
{
	// this delevel also might deal lots of damage
	// Skip if monster would die quickly, before stage 4 might finish
	if((monster_hp() - my_buffedstat($stat[muscle]))/monster_hp()<0.55){return "";}
	// since meat = adv, don't want to delevel if not necessary
	// also skipping if we might die after delevel
	if(!canSurvive(8.0) && canSurvive(0.7) && canUse($skill[Meat Cleaver], true, true))
	{
		return useSkill($skill[Meat Cleaver]);
	}

	return "";
}
