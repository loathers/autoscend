script "auto_quest_level_2.ash"

boolean L2_treeCoin()
{
	if (hidden_temple_unlocked())
	{
		return false;
	}
	if (item_amount($item[Tree-Holed Coin]) > 0 || item_amount($item[spooky temple map]) > 0)
	{
		return false;
	}

	auto_log_info("Time for a tree-holed coin", "blue");
	set_property("choiceAdventure502", "2");
	set_property("choiceAdventure505", "2");
	autoAdv(1, $location[The Spooky Forest]);
	return true;
}

boolean L2_spookyMap()
{
	if (hidden_temple_unlocked())
	{
		return false;
	}
	if (item_amount($item[spooky temple map]) > 0)
	{
		return false;
	}

	auto_log_info("Need a spooky map now", "blue");
	set_property("choiceAdventure502", "3");
	set_property("choiceAdventure506", "3");
	set_property("choiceAdventure507", "1");
	autoAdv(1, $location[The Spooky Forest]);
	return true;
}

boolean L2_spookyFertilizer()
{
	if (hidden_temple_unlocked())
	{
		return false;
	}
	pullXWhenHaveY($item[Spooky-Gro Fertilizer], 1, 0);
	if(item_amount($item[Spooky-Gro Fertilizer]) > 0)
	{
		return false;
	}
	auto_log_info("Need some poop, I mean fertilizer now", "blue");
	set_property("choiceAdventure502", "3");
	set_property("choiceAdventure506", "2");
	autoAdv(1, $location[The Spooky Forest]);
	return true;
}

boolean L2_spookySapling()
{
	if (hidden_temple_unlocked())
	{
		return false;
	}
	if(my_meat() < 100)
	{
		return false;
	}
	auto_log_info("And a spooky sapling!", "blue");
	set_property("choiceAdventure502", "1");
	set_property("choiceAdventure503", "3");
	set_property("choiceAdventure504", "3");

	if(!autoAdvBypass("adventure.php?snarfblat=15", $location[The Spooky Forest]))
	{
		if(contains_text(get_property("lastEncounter"), "Hoom Hah"))
		{
			return true;
		}
		if(contains_text(get_property("lastEncounter"), "Blaaargh! Blaaargh!"))
		{
			auto_log_warning("Ewww, fake blood semirare. Worst. Day. Ever.", "red");
			return true;
		}
		if(lastAdventureSpecialNC())
		{
			auto_log_info("Special Non-combat interrupted us, no worries...", "green");
			return true;
		}
		visit_url("choice.php?whichchoice=502&option=1&pwd");
		visit_url("choice.php?whichchoice=503&option=3&pwd");
		if(item_amount($item[bar skin]) > 0)
		{
			visit_url("choice.php?whichchoice=504&option=2&pwd");
		}
		visit_url("choice.php?whichchoice=504&option=3&pwd");
		visit_url("choice.php?whichchoice=504&option=4&pwd");
		if(item_amount($item[Spooky Sapling]) > 0)
		{
			use(1, $item[Spooky Temple Map]);
		}
		else
		{
			abort("Supposedly bought a spooky sapling, but failed :( (Did the semi-rare window just expire, just run me again, sorry)");
		}
	}
	return true;
}

boolean L2_mosquito()
{
	if (internalQuestStatus("questL02Larva") < 0 || internalQuestStatus("questL02Larva") > 1)
	{
		return false;
	}

	buffMaintain($effect[Snow Shoes], 0, 1, 1);
	providePlusNonCombat(25);

	auto_log_info("Trying to find a mosquito.", "blue");
	set_property("choiceAdventure502", "2"); // Arboreal Respite: go to Consciousness of a Stream
	set_property("choiceAdventure505", "1"); // Consciousness of a Stream: Acquire Mosquito Larva
	autoAdv(1, $location[The Spooky Forest]);
	if (internalQuestStatus("questL02Larva") > 0 || item_amount($item[mosquito larva]) > 0)
	{
		council();
		if (in_koe())
		{
			cli_execute("refresh quests");
		}
	}
	return true;
}