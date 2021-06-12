//Path specific combat handling for Bees Hate You

string auto_combatBHYStage1(int round, monster enemy, string text)
{
	##stage 1 = 1st round actions: puzzle boss, pickpocket, banish, escape, instakill, etc. things that need to be done before debuff
	
	//Bees Hate You path final boss instakill.
	//technically also a hidden boss in all paths but we never want to fight it in other paths
	if(enemy == $monster[Guy Made Of Bees])
	{
		if(canUse($item[antique hand mirror]))
		{
			return useItem($item[antique hand mirror]);
		}
		else
		{
			abort("We attacked [Guy Made Of Bees] without an [antique hand mirror]. Report this then get the mirror before running autoscend again");
		}
	}
	
	return "";
}
