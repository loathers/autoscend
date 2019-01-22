script "cc_deprecation.ash"

/****

Functions in here are defined in cc_ascend/cc_ascend_header.ash

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
	trackingSplitterFixer("cc_banishes_day1", 1, "cc_banishes");
	trackingSplitterFixer("cc_banishes_day2", 2, "cc_banishes");
	trackingSplitterFixer("cc_banishes_day3", 3, "cc_banishes");
	trackingSplitterFixer("cc_banishes_day4", 4, "cc_banishes");
	trackingSplitterFixer("cc_yellowRay_day1", 1, "cc_yellowRays");
	trackingSplitterFixer("cc_yellowRay_day2", 2, "cc_yellowRays");
	trackingSplitterFixer("cc_yellowRay_day3", 3, "cc_yellowRays");
	trackingSplitterFixer("cc_yellowRay_day4", 4, "cc_yellowRays");
	trackingSplitterFixer("cc_lashes_day1", 1, "cc_lashes");
	trackingSplitterFixer("cc_lashes_day2", 2, "cc_lashes");
	trackingSplitterFixer("cc_lashes_day3", 3, "cc_lashes");
	trackingSplitterFixer("cc_lashes_day4", 4, "cc_lashes");
	trackingSplitterFixer("cc_renenutet_day1", 1, "cc_renenutet");
	trackingSplitterFixer("cc_renenutet_day2", 2, "cc_renenutet");
	trackingSplitterFixer("cc_renenutet_day3", 3, "cc_renenutet");
	trackingSplitterFixer("cc_renenutet_day4", 4, "cc_renenutet");

	if(get_property("cc_delayTimer") == "")
	{
		set_property("cc_delayTimer", 1);
	}
	if(get_property("cc_100familiar") == "yes")
	{
		set_property("cc_100familiar", true);
	}
	if(get_property("cc_100familiar") == "no")
	{
		set_property("cc_100familiar", false);
	}
	if(get_property("cc_100familiar") == "true")
	{
		set_property("cc_100familiar", $familiar[Egg Benedict]);
	}
	if(get_property("cc_100familiar") == "false")
	{
		set_property("cc_100familiar", $familiar[none]);
	}
	if(get_property("cc_ballroomsong") == "set")
	{
		set_property("cc_ballroomsong", "finished");
	}
	if(get_property("cc_killingjar") == "done")
	{
		set_property("cc_killingjar", "finished");
	}
	if(get_property("cc_castleground") == "done")
	{
		set_property("cc_castleground", "finished");
	}
	if(get_property("cc_useCubeling") == "yes")
	{
		set_property("cc_useCubeling", true);
	}
	if((get_property("cc_gremlinclap") == "used") && !contains_text("cc_gremlinBanishes", "(" + $skill[Thunder Clap] + ")"))
	{
		set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + $skill[Thunder Clap] + ")");
		set_property("cc_gremlinclap", "");
	}
	if((get_property("cc_gremlinbatter") == "used") && !contains_text("cc_gremlinBanishes", "(" + $skill[Batter Up!] + ")"))
	{
		set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + $skill[Batter Up!] + ")");
		set_property("cc_gremlinbatter", "");
	}
	if((get_property("cc_gremlinlouder") == "used") && !contains_text("cc_gremlinBanishes", "(" + $item[Louder Than Bomb] + ")"))
	{
		set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + $item[Louder Than Bomb] + ")");
		set_property("cc_gremlinlouder", "");
	}
	if((get_property("cc_gremlinpants") == "used") && !contains_text("cc_gremlinBanishes", "(" + $skill[Talk About Politics] + ")"))
	{
		set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + $skill[Talk About Politics] + ")");
		set_property("cc_gremlinpants", "");
	}
	if((get_property("cc_gremlintennis") == "used") && !contains_text("cc_gremlinBanishes", "(" + $item[Tennis Ball] + ")"))
	{
		set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + $item[Tennis Ball] + ")");
		set_property("cc_gremlintennis", "");
	}
	if(get_property("cc_sonata") == "finished")
	{
		set_property("cc_sonofa", "finished");
		set_property("cc_sonata", "");
	}

	if(get_property("cc_useCubeling") == "no")
	{
		set_property("cc_useCubeling", false);
	}
	if(get_property("cc_wandOfNagamar") == "yes")
	{
		set_property("cc_wandOfNagamar", true);
	}
	if(get_property("cc_wandOfNagamar") == "no")
	{
		set_property("cc_wandOfNagamar", false);
	}
	if(get_property("cc_chasmBusted") == "yes")
	{
		set_property("cc_chasmBusted", true);
	}
	if(get_property("cc_chasmBusted") == "no")
	{
		set_property("cc_chasmBusted", false);
	}
	if(get_property("cc_ballroomflat") == "organ")
	{
		set_property("cc_ballroomflat", "finished");
	}
	if(get_property("cc_edDelayTimer") != "")
	{
		set_property("cc_delayTimer", get_property("cc_edDelayTimer"));
		set_property("cc_edDelayTimer", "");
	}
	if(get_property("cc_grimstoneFancyOilPainting") == "need")
	{
		set_property("cc_grimstoneFancyOilPainting", true);
	}
	if(get_property("cc_grimstoneFancyOilPainting") == "no")
	{
		set_property("cc_grimstoneFancyOilPainting", false);
	}
	if(get_property("cc_grimstoneOrnateDowsingRod") == "need")
	{
		set_property("cc_grimstoneOrnateDowsingRod", true);
	}
	if(get_property("cc_grimstoneOrnateDowsingRod") == "no")
	{
		set_property("cc_grimstoneOrnateDowsingRod", false);
	}

	if(get_property("kingLiberatedScript") == "scripts/kingLiberated.ash")
	{
		set_property("kingLiberatedScript", "kingcheese.ash");
	}
	if(get_property("afterAdventureScript") == "scripts/postadventure.ash")
	{
		set_property("afterAdventureScript", "postcheese.ash");
	}
	if(get_property("betweenAdventureScript") == "scripts/preadventure.ash")
	{
		set_property("betweenAdventureScript", "precheese.ash");
	}
	if(get_property("betweenBattleScript") == "scripts/preadventure.ash")
	{
		set_property("betweenBattleScript", "precheese.ash");
	}

	if(get_property("cc_abooclover") == "")
	{
		set_property("cc_abooclover", true);
	}
	if(get_property("cc_abooclover") == "used")
	{
		set_property("cc_abooclover", false);
	}
	if(get_property("cc_aftercore") == "")
	{
		set_property("cc_aftercore", false);
	}
	if(get_property("cc_aftercore") == "done")
	{
		set_property("cc_aftercore", true);
	}
	if(get_property("cc_bean") == "")
	{
		set_property("cc_bean", false);
	}
	if(get_property("cc_bean") == "plant")
	{
		set_property("cc_bean", true);
	}


	if(get_property("cc_cubeItems") == "")
	{
		set_property("cc_cubeItems", true);
	}
	if(get_property("cc_cubeItems") == "done")
	{
		set_property("cc_cubeItems", false);
	}

	if(get_property("cc_gunpowder") == "done")
	{
		set_property("cc_gunpowder", "finished");
	}

	if(get_property("cc_mistypeak") == "done")
	{
		set_property("cc_mistypeak", "finished");
	}

	if(get_property("cc_xiblaxianChoice") == "")
	{
		set_property("cc_xiblaxianChoice", $item[Xiblaxian Ultraburrito]);
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

	return true;
}
