// This uses Ezandora's wonderful Helix Fossil script to handle building a team and combat.
boolean in_pokefam()
{
	return my_path() == $path[Pocket Familiars];
}

void pokefam_initializeSettings()
{
	if(in_pokefam())
	{
		// No need to restore HP or MP in Pocket Familiars.
		set_property("auto_ignoreRestoreFailure", true);
		// No need for a beehive as combat is different.
		set_property("auto_getBeehive", false);
		// We can't flyer, but all the sidequests are unlocked, so we can still war as frat
		set_property("auto_ignoreFlyer", true);
		// No Naughty Sorceress so no need for a wand.
		set_property("auto_wandOfNagamar", false);
		// runs are probably going to take at least 3 days, maybe 4 in hardcore
		set_property("auto_runDayCount", 3);
	}
}

string pokefam_defaultMaximizeStatement()
{
	// Combat is completely different in pokefam, so most stuff doesn't matter there
	string res = "5item,meat";
	if(my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean())
	{
		res += ",10exp,5" + my_primestat() + " experience percent";
	}
	return res;
}

void pokefam_getHats()
{
	if (!in_pokefam()) {
		return;
	}
	visit_url("shop.php?whichshop=pokefam");
	if (item_amount($item[1,960 pok&eacute;dollar bill]) < 50) {
		return;
	}
	foreach it in $items[Team Avarice cap, Team Sloth cap, Team Wrath cap, Mu cap]
	{
		if(!possessEquipment(it) && item_amount($item[1,960 pok&eacute;dollar bill]) >= 50)
		{
			retrieve_item(1, it);
		}
	}
}

boolean pokefam_makeTeam()
{
	if(in_pokefam())
	{
		// Choose "strongest 2" in order to allow a middle spot for a pocket familiar to level up and earn pokebucks.
		if(git_exists("Ezandora-Helix-Fossil"))
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
