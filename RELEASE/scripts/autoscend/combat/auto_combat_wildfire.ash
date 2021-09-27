//Path specific combat handling for wildfire

string auto_combatWildfireStage1(int round, monster enemy, string text)
{
	// stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	if(!in_wildfire())
	{
		return "";
	}
	
	//always 5 fire. can not be reduced.
	if($monster[Groar\, Except Hot] == enemy)
	{
		//weaksauce will recover 50 MP. Only use it if you have industrial fire extinguisher equipped to prevent passive damage
		if(have_equipped($item[industrial fire extinguisher]) && canUse($skill[Curse of Weaksauce]) && have_skill($skill[Itchy Curse Finger]))
		{
			return useSkill($skill[Curse of Weaksauce]);
		}
		if(canUse($skill[Stuffed Mortar Shell]))		//very cheap for massive damage. tuneable too for extra dmg.
		{
			return useSkill($skill[Stuffed Mortar Shell]);
		}
		if($elements[sleaze, stench] contains currentFlavour() && canUse($skill[Weapon of the Pastalord]))		//extra dmg dealt
		{
			return useSkill($skill[Weapon of the Pastalord], false);
		}
		if(canUse($skill[Saucegeyser], false))
		{
			return useSkill($skill[Saucegeyser], false);
		}
		abort("We do not know what to do next against [" +enemy+ "].");
	}
	
	//always 5 fire. can not be reduced.
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
		abort("We do not know what to do next against [" +enemy+ "].");
	}
	
	return "";
}
