string auto_combatDefaultStage2(int round, monster enemy, string text)
{
	##stage 2 = delevel & stun
	
	//shape of a mole when using Llama lama gong. delevel by 5
	if(canUse($skill[Tunnel Downwards]) && (have_effect($effect[Shape of...Mole!]) > 0) && (my_location() == $location[Mt. Molehill]))
	{
		return useSkill($skill[Tunnel Downwards]);
	}
	
	return "";
}
