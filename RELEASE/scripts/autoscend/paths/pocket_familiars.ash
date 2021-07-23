// This uses Ezandora's wonderful Helix Fossil script to handle building a team and combat.
boolean in_pokefam()
{
	return auto_my_path() == "Pocket Familiars";
}

void pokefam_initializeSettings()
{
	if(in_pokefam())
	{
		// No need to restore HP or MP in Pocket Familiars.
		set_property("auto_ignoreRestoreFailure", true);
		// No need for a beehive as combat is different.
		set_property("auto_getBeehive", false);
		// We can't flyer, so better to do the war as a hippy.
		set_property("auto_hippyInstead", true);
		set_property("auto_ignoreFlyer", true);
		// No Naughty Sorceress so no need for a wand.
		set_property("auto_wandOfNagamar", false);
	}
}

boolean pokefam_makeTeam()
{
	if(in_pokefam())
	{
		// Choose "strongest 2" in order to allow a middle spot for a pocket familiar to level up and earn pokebucks.
		if(svn_info("Ezandora-Helix-Fossil-branches-Release").revision > 0)
		{
		auto_log_info("Setting our team via Ezandora:", "green");
		boolean ignore = cli_execute("PocketFamiliarsAutoSelect Strongest 2;");
		return true;
		}
	}	
	return true;
}

boolean L12_pokefam_clearBattlefield()
{
	// Pocket Familiars specific handling for clearing the battlefield.
	if(!in_pokefam())
	{
		return false;
	}

	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}

	if (get_property("hippiesDefeated").to_int() < 1000 && get_property("fratboysDefeated").to_int() < 1000)
	{
		auto_log_info("Doing the wars.", "blue");
		equipWarOutfit();
		return warAdventure();
	}
	return false;
}