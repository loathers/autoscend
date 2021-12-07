//Path specific combat handling for Way of the Surprising Fist

string auto_combatWOTSFStage1(int round, monster enemy, string text)
{
	// stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	if(!in_wotsf())
	{
		return "";
	}
    
    // handling for Wu Tang the Betrayer at Black Market
	if(enemy == $monster[Wu Tang the Betrayer]) // puzzle boss in WOTSF
	{
		if(canUse($skill[CHEAT CODE: Shrink Enemy]))
		{
			return useSkill($skill[CHEAT CODE: Shrink Enemy]); // delevel and hit HP by ~50%
		}
		if(canUse($skill[Curse of Vichyssoise]))
		{
			return useSkill($skill[Curse Of Vichyssoise]); // persistent cold damage
		}
		if(canUse($skill[CHEAT CODE: Shrink Enemy]))
		{
			return useSkill($skill[CHEAT CODE: Shrink Enemy]); // hit them again with big HP knock
		}
		if(canUse($skill[Micrometeorite]))
		{
			return useSkill($skill[Micrometeorite]); // delevel by ~25%
		}
		if(canUse($item[Rain-Doh indigo cup]))
		{
			return useItem($item[Rain-Doh Indigo Cup]); // delevel and restore HP
		}
		if(canUse($skill[Summon Love Mosquito]))
		{
			return useSkill($skill[Summon Love Mosquito]); // one-time deals damage
		}
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]); // persistent damage
		}
		if(canUse($skill[Unleash The Greash]) && (have_effect($effect[Takin\' It Greasy]) > 100))
		{
			return useSkill($skill[Unleash The Greash]); // if available, strong sleaze damage
		}
		if(canUse($skill[Tango of Terror]))
		{
			return useSkill($skill[Tango of Terror]); // delevel and damage
		}
		if(canUse($skill[Saucestorm]))
		{
			return useSkill($skill[Saucestorm]); // default attacking
		}
	}
	
	return "";
}
