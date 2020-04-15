script "auto_summerfun.ash"

boolean ocrs_postHelper()
{
	if(my_path() != "One Crazy Random Summer")
	{
		return false;
	}

	set_property("auto_useCleesh", false);
	return true;
}

boolean ocrs_postCombatResolve()
{
	if((have_effect($effect[Beaten Up]) > 0) && (auto_my_path() == "One Crazy Random Summer"))
	{
		if(contains_text(get_property("auto_funPrefix"), "annoying") ||
			contains_text(get_property("auto_funPrefix"), "phase-shifting") ||
			contains_text(get_property("auto_funPrefix"), "restless") ||
			contains_text(get_property("auto_funPrefix"), "ticking"))
		{
			auto_log_warning("Probably beaten up by FUN! Trying to recover instead of aborting", "red");
			handleTracker(last_monster(), get_property("auto_funPrefix"), "auto_funTracker");
			acquireHP();
		}
	}


	return false;
}
