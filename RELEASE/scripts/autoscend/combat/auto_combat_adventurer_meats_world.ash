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
