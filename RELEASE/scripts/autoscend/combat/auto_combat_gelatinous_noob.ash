string auto_combatGelatinousNoobStage4(int round, monster enemy, string text)
{
	##stage 4 = kill
	if(!in_gnoob())
	{
		return "";
	}
	
	//3x elemental damage bonuses attack against duplicated [goat]. duplicated means double stats and double drops
	if(canUse($skill[Gelatinous Kick], false) && haveUsed($skill[Duplicate]))
	{
		if($monsters[Dairy Goat] contains enemy)
		{
			return useSkill($skill[Gelatinous Kick], false);
		}
	}
	
	return "";
}
