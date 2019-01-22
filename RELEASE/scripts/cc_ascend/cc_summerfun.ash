script "cc_summerfun.ash"
boolean ocrs_initializeSettings()
{
	if(my_path() == "One Crazy Random Summer")
	{
		set_property("cc_spookyfertilizer", "");
		set_property("cc_getStarKey", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_wandOfNagamar", true);
	}
	return true;
}

boolean ocrs_postHelper()
{
	if(my_path() != "One Crazy Random Summer")
	{
		return false;
	}

	set_property("cc_useCleesh", false);
	return true;
}

boolean ocrs_postCombatResolve()
{
	if((have_effect($effect[Beaten Up]) > 0) && (cc_my_path() == "One Crazy Random Summer"))
	{
		if(contains_text(get_property("cc_funPrefix"), "annoying") ||
			contains_text(get_property("cc_funPrefix"), "phase-shifting") ||
			contains_text(get_property("cc_funPrefix"), "restless") ||
			contains_text(get_property("cc_funPrefix"), "ticking"))
		{
			print("Probably beaten up by FUN! Trying to recover instead of aborting", "red");
			handleTracker(last_monster(), get_property("cc_funPrefix"), "cc_funTracker");
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
