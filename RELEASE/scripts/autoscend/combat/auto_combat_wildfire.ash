//Path specific combat handling for wildfire

string auto_combatWildfireStage1(int round, monster enemy, string text)
{
	// stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	if(!in_wildfire())
	{
		return "";
	}
	
	if($monster[Groar\, Except Hot] == enemy)
	{
		if(canUse($skill[Stuffed Mortar Shell]))
		{
			return useSkill($skill[Stuffed Mortar Shell]);
		}
		if($elements[sleaze, stench] contains currentFlavour() && canUse($skill[Weapon of the Pastalord]))
		{
			return useSkill($skill[Weapon of the Pastalord], false);
		}
		if(canUse($skill[Saucegeyser], false))
		{
			return useSkill($skill[Saucegeyser], false);
		}
		abort("We do not know what to do next in combat");
	}
	
	if($monster[wall of meat] == enemy)
	{
		if(canUse($skill[Stuffed Mortar Shell]))
		{
			return useSkill($skill[Stuffed Mortar Shell]);
		}
		if(my_class() == $class[pastamancer] && canUse($skill[Weapon of the Pastalord]))
		{
			return useSkill($skill[Weapon of the Pastalord], false);
		}
		if(canUse($skill[Saucegeyser], false))
		{
			return useSkill($skill[Saucegeyser], false);
		}
		abort("We do not know what to do next in combat");
	}
	
	return "";
}
