script "sl_deprecation.ash"

/****

Functions in here are defined in sl_ascend/sl_ascend_header.ash

These functions exist to handle outdated configuartions of the script. These would have been removed but we might as well keep them (in case we need to do any new configuration mangling) and they might actually help recover a long-forgotten ascension.

****/


boolean trackingSplitterFixer(string oldSetting, int day, string newSetting)
{
	string setting = get_property(oldSetting);
	if(setting == "")
	{
		return false;
	}

	matcher cleanSpaces = create_matcher(", ", setting);
	setting = replace_all(cleanSpaces, ",");
	string[int] retval = split_string(setting, ",");
	foreach x in retval
	{
		if(retval[x] == "")
		{
			continue;
		}
		matcher dayAdder = create_matcher("[(]", retval[x]);
		retval[x] = replace_all(dayAdder, "(" + day + ":");
		if(get_property(newSetting) != "")
		{
			set_property(newSetting, get_property(newSetting) + "," + retval[x]);
		}
		else
		{
			set_property(newSetting, retval[x]);
		}
	}
	set_property(oldSetting, "");
	return true;
}

boolean settingFixer()
{
	/***
		This will be removed at some point once a reasonable amount of time has
		passed such that anyone who used the script before a conversion in here
		should have had it fix them.

		Maybe it won\t. It doesn't really need to be I guess.
		Backwards compatibility forever!!!
	***/
	trackingSplitterFixer("sl_banishes_day1", 1, "sl_banishes");
	trackingSplitterFixer("sl_banishes_day2", 2, "sl_banishes");
	trackingSplitterFixer("sl_banishes_day3", 3, "sl_banishes");
	trackingSplitterFixer("sl_banishes_day4", 4, "sl_banishes");
	trackingSplitterFixer("sl_yellowRay_day1", 1, "sl_yellowRays");
	trackingSplitterFixer("sl_yellowRay_day2", 2, "sl_yellowRays");
	trackingSplitterFixer("sl_yellowRay_day3", 3, "sl_yellowRays");
	trackingSplitterFixer("sl_yellowRay_day4", 4, "sl_yellowRays");
	trackingSplitterFixer("sl_lashes_day1", 1, "sl_lashes");
	trackingSplitterFixer("sl_lashes_day2", 2, "sl_lashes");
	trackingSplitterFixer("sl_lashes_day3", 3, "sl_lashes");
	trackingSplitterFixer("sl_lashes_day4", 4, "sl_lashes");
	trackingSplitterFixer("sl_renenutet_day1", 1, "sl_renenutet");
	trackingSplitterFixer("sl_renenutet_day2", 2, "sl_renenutet");
	trackingSplitterFixer("sl_renenutet_day3", 3, "sl_renenutet");
	trackingSplitterFixer("sl_renenutet_day4", 4, "sl_renenutet");

	if(get_property("sl_delayTimer") == "")
	{
		set_property("sl_delayTimer", 1);
	}
	if(get_property("sl_100familiar") == "yes")
	{
		set_property("sl_100familiar", true);
	}
	if(get_property("sl_100familiar") == "no")
	{
		set_property("sl_100familiar", false);
	}
	if(get_property("sl_100familiar") == "true")
	{
		set_property("sl_100familiar", $familiar[Egg Benedict]);
	}
	if(get_property("sl_100familiar") == "false")
	{
		set_property("sl_100familiar", $familiar[none]);
	}
	if(get_property("sl_ballroomsong") == "set")
	{
		set_property("sl_ballroomsong", "finished");
	}
	if(get_property("sl_killingjar") == "done")
	{
		set_property("sl_killingjar", "finished");
	}
	if(get_property("sl_castleground") == "done")
	{
		set_property("sl_castleground", "finished");
	}
	if(get_property("sl_useCubeling") == "yes")
	{
		set_property("sl_useCubeling", true);
	}
	if((get_property("sl_gremlinclap") == "used") && !contains_text("sl_gremlinBanishes", "(" + $skill[Thunder Clap] + ")"))
	{
		set_property("sl_gremlinBanishes", get_property("sl_gremlinBanishes") + "(" + $skill[Thunder Clap] + ")");
		set_property("sl_gremlinclap", "");
	}
	if((get_property("sl_gremlinbatter") == "used") && !contains_text("sl_gremlinBanishes", "(" + $skill[Batter Up!] + ")"))
	{
		set_property("sl_gremlinBanishes", get_property("sl_gremlinBanishes") + "(" + $skill[Batter Up!] + ")");
		set_property("sl_gremlinbatter", "");
	}
	if((get_property("sl_gremlinlouder") == "used") && !contains_text("sl_gremlinBanishes", "(" + $item[Louder Than Bomb] + ")"))
	{
		set_property("sl_gremlinBanishes", get_property("sl_gremlinBanishes") + "(" + $item[Louder Than Bomb] + ")");
		set_property("sl_gremlinlouder", "");
	}
	if((get_property("sl_gremlinpants") == "used") && !contains_text("sl_gremlinBanishes", "(" + $skill[Talk About Politics] + ")"))
	{
		set_property("sl_gremlinBanishes", get_property("sl_gremlinBanishes") + "(" + $skill[Talk About Politics] + ")");
		set_property("sl_gremlinpants", "");
	}
	if((get_property("sl_gremlintennis") == "used") && !contains_text("sl_gremlinBanishes", "(" + $item[Tennis Ball] + ")"))
	{
		set_property("sl_gremlinBanishes", get_property("sl_gremlinBanishes") + "(" + $item[Tennis Ball] + ")");
		set_property("sl_gremlintennis", "");
	}
	if(get_property("sl_sonata") == "finished")
	{
		set_property("sl_sonofa", "finished");
		set_property("sl_sonata", "");
	}

	if(get_property("sl_useCubeling") == "no")
	{
		set_property("sl_useCubeling", false);
	}
	if(get_property("sl_wandOfNagamar") == "yes")
	{
		set_property("sl_wandOfNagamar", true);
	}
	if(get_property("sl_wandOfNagamar") == "no")
	{
		set_property("sl_wandOfNagamar", false);
	}
	if(get_property("sl_chasmBusted") == "yes")
	{
		set_property("sl_chasmBusted", true);
	}
	if(get_property("sl_chasmBusted") == "no")
	{
		set_property("sl_chasmBusted", false);
	}
	if(get_property("sl_ballroomflat") == "organ")
	{
		set_property("sl_ballroomflat", "finished");
	}
	if(get_property("sl_edDelayTimer") != "")
	{
		set_property("sl_delayTimer", get_property("sl_edDelayTimer"));
		set_property("sl_edDelayTimer", "");
	}
	if(get_property("sl_grimstoneFancyOilPainting") == "need")
	{
		set_property("sl_grimstoneFancyOilPainting", true);
	}
	if(get_property("sl_grimstoneFancyOilPainting") == "no")
	{
		set_property("sl_grimstoneFancyOilPainting", false);
	}
	if(get_property("sl_grimstoneOrnateDowsingRod") == "need")
	{
		set_property("sl_grimstoneOrnateDowsingRod", true);
	}
	if(get_property("sl_grimstoneOrnateDowsingRod") == "no")
	{
		set_property("sl_grimstoneOrnateDowsingRod", false);
	}

	if(get_property("kingLiberatedScript") == "scripts/kingLiberated.ash")
	{
		set_property("kingLiberatedScript", "kingsool.ash");
	}
	if(get_property("afterAdventureScript") == "scripts/postadventure.ash")
	{
		set_property("afterAdventureScript", "postsool.ash");
	}
	if(get_property("betweenAdventureScript") == "scripts/preadventure.ash")
	{
		set_property("betweenAdventureScript", "presool.ash");
	}
	if(get_property("betweenBattleScript") == "scripts/preadventure.ash")
	{
		set_property("betweenBattleScript", "presool.ash");
	}

	if(get_property("sl_abooclover") == "")
	{
		set_property("sl_abooclover", true);
	}
	if(get_property("sl_abooclover") == "used")
	{
		set_property("sl_abooclover", false);
	}
	if(get_property("sl_aftercore") == "")
	{
		set_property("sl_aftercore", false);
	}
	if(get_property("sl_aftercore") == "done")
	{
		set_property("sl_aftercore", true);
	}
	if(get_property("sl_bean") == "")
	{
		set_property("sl_bean", false);
	}
	if(get_property("sl_bean") == "plant")
	{
		set_property("sl_bean", true);
	}


	if(get_property("sl_cubeItems") == "")
	{
		set_property("sl_cubeItems", true);
	}
	if(get_property("sl_cubeItems") == "done")
	{
		set_property("sl_cubeItems", false);
	}

	if(get_property("sl_gunpowder") == "done")
	{
		set_property("sl_gunpowder", "finished");
	}

	if(get_property("sl_mistypeak") == "done")
	{
		set_property("sl_mistypeak", "finished");
	}

	if(get_property("sl_xiblaxianChoice") == "")
	{
		set_property("sl_xiblaxianChoice", $item[Xiblaxian Ultraburrito]);
	}

	if(get_property("lastPlusSignUnlock") == "true")
	{
		print("lastPlusSignUnlock was changed to a boolean, fixing...", "red");
		set_property("lastPlusSignUnlock", my_ascensions());
	}
	if(get_property("lastTempleUnlock") == "true")
	{
		print("lastTempleUnlock was changed to a boolean, fixing...", "red");
		set_property("lastTempleUnlock", my_ascensions());
	}

	if(property_exists("sl_day1_init"))
	{
		print("Found old day initialization trackers, removing...", "red");
		remove_property("sl_day1_init");
		remove_property("sl_day2_init");
		remove_property("sl_day3_init");
		remove_property("sl_day4_init");
	}

	if(property_exists("sl_gaudy"))
	{
		print("Some lingering stuff from when gaudy pirates mattered is still here, let's get rid of it...", "red");
		remove_property("sl_gaudy");
	}

	if(get_property("sl_paranoia") == "")
	{
		print("No paranoia value, we probably don't want to be paranoid...", "red");
		set_property("sl_paranoia", -1);
	}

	if(get_property("sl_helpMeMafiaIsSuperBrokenAaah") == "")
	{
		print("Mafia probably isn't super broken, so let's set it that way...", "red");
		set_property("sl_helpMeMafiaIsSuperBrokenAaah", false);
	}

	return true;
}
