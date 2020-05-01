script "auto_quest_level_5.ash"

boolean L5_getEncryptionKey()
{
	if (internalQuestStatus("questL05Goblin") > 0 || item_amount($item[Knob Goblin Encryption Key]) > 0)
	{
		return false;
	}

	if(item_amount($item[11-inch knob sausage]) == 1)
	{
		visit_url("guild.php?place=challenge");
		return true;
	}

	if((my_class() == $class[Gelatinous Noob]) && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Retractable Toes]) && (item_amount($item[Cocktail Mushroom]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}

	auto_log_info("Looking for the knob.", "blue");
	return autoAdv($location[The Outskirts of Cobb\'s Knob]);
}

boolean L5_findKnob()
{
	if (internalQuestStatus("questL05Goblin") < 0 || internalQuestStatus("questL05Goblin") > 0)
	{
		return false;
	}
	if (item_amount($item[Knob Goblin Encryption Key]) == 1)
	{
		if(item_amount($item[Cobb\'s Knob Map]) == 0)
		{
			council();
		}
		use(1, $item[Cobb\'s Knob Map]);
		return true;
	}
	return false;
}

boolean L5_haremOutfit()
{
	if (internalQuestStatus("questL05Goblin") < 0 || internalQuestStatus("questL05Goblin") > 1)
	{
		return false;
	}
	if (possessOutfit("Knob Goblin Harem Girl Disguise"))
	{
		return false;
	}

	if(!adjustForYellowRayIfPossible($monster[Knob Goblin Harem Girl]))
	{
		if(my_level() != get_property("auto_powerLevelLastLevel").to_int())
		{
			return false;
		}
	}

	if(auto_my_path() == "Heavy Rains")
	{
		buffMaintain($effect[Fishy Whiskers], 0, 1, 1);
	}
	bat_formBats();

	auto_log_info("Looking for some sexy lingerie!", "blue");
	return autoAdv($location[Cobb\'s Knob Harem]);
}

boolean L5_goblinKing()
{
	if (internalQuestStatus("questL05Goblin") < 0 || internalQuestStatus("questL05Goblin") > 1)
	{
		return false;
	}
	if (my_level() < 8 && get_property("auto_powerLevelAdvCount").to_int() < 9)
	{
		return false;
	}
	if(my_adventures() <= 2)
	{
		return false;
	}
	if(get_counters("Fortune Cookie", 0, 3) == "Fortune Cookie")
	{
		return false;
	}
	if(!possessOutfit("Knob Goblin Harem Girl Disguise"))
	{
		return false;
	}

	auto_log_info("Death to the gobbo!!", "blue");
	if(!autoOutfit("Knob Goblin Harem Girl Disguise"))
	{
		abort("Could not put on Knob Goblin Harem Girl Disguise, aborting");
	}
	buffMaintain($effect[Knob Goblin Perfume], 0, 1, 1);
	if(have_effect($effect[Knob Goblin Perfume]) == 0)
	{
		autoAdv($location[Cobb\'s Knob Harem]);
		if(contains_text(get_property("lastEncounter"), "Cobb's Knob lab key"))
		{
			autoAdv($location[Cobb\'s Knob Harem]);
		}
		return true;
	}

	if(my_primestat() == $stat[Muscle])
	{
		buyUpTo(1, $item[Ben-Gal&trade; Balm]);
		buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
	}
	buyUpTo(1, $item[Hair Spray]);
	buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);

	if((my_class() == $class[Seal Clubber]) || (my_class() == $class[Turtle Tamer]))
	{
		buyUpTo(1, $item[Blood of the Wereseal]);
		buffMaintain($effect[Temporary Lycanthropy], 0, 1, 1);
	}

	if(monster_level_adjustment() > 150)
	{
		autoEquip($slot[acc2], $item[none]);
	}

	// TODO: I died here, maybe we should heal a bit?
	if (!in_zelda())
	{
		auto_change_mcd(10); // get the Crown from the Goblin King.
	}
	autoAdv($location[Throne Room]);

	if((item_amount($item[Crown of the Goblin King]) > 0) || (item_amount($item[Glass Balls of the Goblin King]) > 0) || (item_amount($item[Codpiece of the Goblin King]) > 0) || (get_property("questL05Goblin") == "finished") || in_zelda())
	{
		council();
	}
	return true;
}