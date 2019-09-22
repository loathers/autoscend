script "auto_deprecation.ash"

/****

Functions in here are defined in auto_ascend/auto_ascend_header.ash

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
	trackingSplitterFixer("auto_banishes_day1", 1, "auto_banishes");
	trackingSplitterFixer("auto_banishes_day2", 2, "auto_banishes");
	trackingSplitterFixer("auto_banishes_day3", 3, "auto_banishes");
	trackingSplitterFixer("auto_banishes_day4", 4, "auto_banishes");
	trackingSplitterFixer("auto_yellowRay_day1", 1, "auto_yellowRays");
	trackingSplitterFixer("auto_yellowRay_day2", 2, "auto_yellowRays");
	trackingSplitterFixer("auto_yellowRay_day3", 3, "auto_yellowRays");
	trackingSplitterFixer("auto_yellowRay_day4", 4, "auto_yellowRays");
	trackingSplitterFixer("auto_lashes_day1", 1, "auto_lashes");
	trackingSplitterFixer("auto_lashes_day2", 2, "auto_lashes");
	trackingSplitterFixer("auto_lashes_day3", 3, "auto_lashes");
	trackingSplitterFixer("auto_lashes_day4", 4, "auto_lashes");
	trackingSplitterFixer("auto_renenutet_day1", 1, "auto_renenutet");
	trackingSplitterFixer("auto_renenutet_day2", 2, "auto_renenutet");
	trackingSplitterFixer("auto_renenutet_day3", 3, "auto_renenutet");
	trackingSplitterFixer("auto_renenutet_day4", 4, "auto_renenutet");

	if(get_property("auto_delayTimer") == "")
	{
		set_property("auto_delayTimer", 1);
	}
	if(get_property("auto_100familiar") == "yes")
	{
		set_property("auto_100familiar", true);
	}
	if(get_property("auto_100familiar") == "no")
	{
		set_property("auto_100familiar", false);
	}
	if(get_property("auto_100familiar") == "true")
	{
		set_property("auto_100familiar", $familiar[Egg Benedict]);
	}
	if(get_property("auto_100familiar") == "false")
	{
		set_property("auto_100familiar", $familiar[none]);
	}
	if(get_property("auto_ballroomsong") == "set")
	{
		set_property("auto_ballroomsong", "finished");
	}
	if(get_property("auto_killingjar") == "done")
	{
		set_property("auto_killingjar", "finished");
	}
	if(get_property("auto_castleground") == "done")
	{
		set_property("auto_castleground", "finished");
	}
	if(get_property("auto_useCubeling") == "yes")
	{
		set_property("auto_useCubeling", true);
	}
	if((get_property("auto_gremlinclap") == "used") && !contains_text("auto_gremlinBanishes", "(" + $skill[Thunder Clap] + ")"))
	{
		set_property("auto_gremlinBanishes", get_property("auto_gremlinBanishes") + "(" + $skill[Thunder Clap] + ")");
		set_property("auto_gremlinclap", "");
	}
	if((get_property("auto_gremlinbatter") == "used") && !contains_text("auto_gremlinBanishes", "(" + $skill[Batter Up!] + ")"))
	{
		set_property("auto_gremlinBanishes", get_property("auto_gremlinBanishes") + "(" + $skill[Batter Up!] + ")");
		set_property("auto_gremlinbatter", "");
	}
	if((get_property("auto_gremlinlouder") == "used") && !contains_text("auto_gremlinBanishes", "(" + $item[Louder Than Bomb] + ")"))
	{
		set_property("auto_gremlinBanishes", get_property("auto_gremlinBanishes") + "(" + $item[Louder Than Bomb] + ")");
		set_property("auto_gremlinlouder", "");
	}
	if((get_property("auto_gremlinpants") == "used") && !contains_text("auto_gremlinBanishes", "(" + $skill[Talk About Politics] + ")"))
	{
		set_property("auto_gremlinBanishes", get_property("auto_gremlinBanishes") + "(" + $skill[Talk About Politics] + ")");
		set_property("auto_gremlinpants", "");
	}
	if((get_property("auto_gremlintennis") == "used") && !contains_text("auto_gremlinBanishes", "(" + $item[Tennis Ball] + ")"))
	{
		set_property("auto_gremlinBanishes", get_property("auto_gremlinBanishes") + "(" + $item[Tennis Ball] + ")");
		set_property("auto_gremlintennis", "");
	}
	if(get_property("auto_sonata") == "finished")
	{
		set_property("auto_sonofa", "finished");
		set_property("auto_sonata", "");
	}

	if(get_property("auto_useCubeling") == "no")
	{
		set_property("auto_useCubeling", false);
	}
	if(get_property("auto_wandOfNagamar") == "yes")
	{
		set_property("auto_wandOfNagamar", true);
	}
	if(get_property("auto_wandOfNagamar") == "no")
	{
		set_property("auto_wandOfNagamar", false);
	}
	if(get_property("auto_chasmBusted") == "yes")
	{
		set_property("auto_chasmBusted", true);
	}
	if(get_property("auto_chasmBusted") == "no")
	{
		set_property("auto_chasmBusted", false);
	}
	if(get_property("auto_ballroomflat") == "organ")
	{
		set_property("auto_ballroomflat", "finished");
	}
	if(get_property("auto_edDelayTimer") != "")
	{
		set_property("auto_delayTimer", get_property("auto_edDelayTimer"));
		set_property("auto_edDelayTimer", "");
	}
	if(get_property("auto_grimstoneFancyOilPainting") == "need")
	{
		set_property("auto_grimstoneFancyOilPainting", true);
	}
	if(get_property("auto_grimstoneFancyOilPainting") == "no")
	{
		set_property("auto_grimstoneFancyOilPainting", false);
	}
	if(get_property("auto_grimstoneOrnateDowsingRod") == "need")
	{
		set_property("auto_grimstoneOrnateDowsingRod", true);
	}
	if(get_property("auto_grimstoneOrnateDowsingRod") == "no")
	{
		set_property("auto_grimstoneOrnateDowsingRod", false);
	}

	if(get_property("kingLiberatedScript") == "scripts/kingLiberated.ash")
	{
		set_property("kingLiberatedScript", "auto_king.ash");
	}
	if(get_property("afterAdventureScript") == "scripts/postadventure.ash")
	{
		set_property("afterAdventureScript", "auto_post_adv.ash");
	}
	if(get_property("betweenAdventureScript") == "scripts/preadventure.ash")
	{
		set_property("betweenAdventureScript", "auto_pre_adv.ash");
	}
	if(get_property("betweenBattleScript") == "scripts/preadventure.ash")
	{
		set_property("betweenBattleScript", "auto_pre_adv.ash");
	}

	if(get_property("auto_abooclover") == "")
	{
		set_property("auto_abooclover", true);
	}
	if(get_property("auto_abooclover") == "used")
	{
		set_property("auto_abooclover", false);
	}
	if(get_property("auto_aftercore") == "")
	{
		set_property("auto_aftercore", false);
	}
	if(get_property("auto_aftercore") == "done")
	{
		set_property("auto_aftercore", true);
	}
	if(get_property("auto_bean") == "")
	{
		set_property("auto_bean", false);
	}
	if(get_property("auto_bean") == "plant")
	{
		set_property("auto_bean", true);
	}


	if(get_property("auto_cubeItems") == "")
	{
		set_property("auto_cubeItems", true);
	}
	if(get_property("auto_cubeItems") == "done")
	{
		set_property("auto_cubeItems", false);
	}

	if(get_property("auto_gunpowder") == "done")
	{
		set_property("auto_gunpowder", "finished");
	}

	if(get_property("auto_mistypeak") == "done")
	{
		set_property("auto_mistypeak", "finished");
	}

	if(get_property("auto_xiblaxianChoice") == "")
	{
		set_property("auto_xiblaxianChoice", $item[Xiblaxian Ultraburrito]);
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

	if(property_exists("auto_day1_init"))
	{
		print("Found old day initialization trackers, removing...", "red");
		remove_property("auto_day1_init");
		remove_property("auto_day2_init");
		remove_property("auto_day3_init");
		remove_property("auto_day4_init");
	}

	if(property_exists("auto_gaudy"))
	{
		print("Some lingering stuff from when gaudy pirates mattered is still here, let's get rid of it...", "red");
		remove_property("auto_gaudy");
	}

	if(get_property("auto_paranoia") == "")
	{
		print("No paranoia value, we probably don't want to be paranoid...", "red");
		set_property("auto_paranoia", -1);
	}

	if(get_property("auto_helpMeMafiaIsSuperBrokenAaah") == "")
	{
		print("Mafia probably isn't super broken, so let's set it that way...", "red");
		set_property("auto_helpMeMafiaIsSuperBrokenAaah", false);
	}

	return true;
}
