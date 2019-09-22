script "sl_summerfun.ash"
boolean ocrs_initializeSettings()
{
	if(my_path() == "One Crazy Random Summer")
	{
		set_property("sl_spookyfertilizer", "");
		set_property("sl_getStarKey", true);
		set_property("sl_holeinthesky", true);
		set_property("sl_wandOfNagamar", true);
	}
	return true;
}

boolean ocrs_postHelper()
{
	if(my_path() != "One Crazy Random Summer")
	{
		return false;
	}

	set_property("sl_useCleesh", false);
	return true;
}

boolean ocrs_postCombatResolve()
{
	if((have_effect($effect[Beaten Up]) > 0) && (sl_my_path() == "One Crazy Random Summer"))
	{
		if(contains_text(get_property("sl_funPrefix"), "annoying") ||
			contains_text(get_property("sl_funPrefix"), "phase-shifting") ||
			contains_text(get_property("sl_funPrefix"), "restless") ||
			contains_text(get_property("sl_funPrefix"), "ticking"))
		{
			print("Probably beaten up by FUN! Trying to recover instead of aborting", "red");
			handleTracker(last_monster(), get_property("sl_funPrefix"), "sl_funTracker");
			if(have_skill($skill[Tongue of the Walrus]) && have_skill($skill[Cannelloni Cocoon]) && (my_mp() >= 30))
			{
				use_skill(1, $skill[Tongue of the Walrus]);
				useCocoon();
			}
			else
			{
				doHottub();
			}
		}
	}


	return false;
}
