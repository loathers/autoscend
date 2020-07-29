script "bees_hate_you.ash"

boolean in_bhy()
{
	return (auto_my_path() == "Bees Hate You");
}


void bhy_initializeSettings()
{
	if(in_bhy())
	{
		set_property("auto_abooclover", false);
		set_property("auto_wandOfNagamar", false);
		set_property("auto_hippyInstead", true);
		set_property("auto_getBeehive", true);
		set_property("auto_getBoningKnife", true);
		set_property("auto_ignoreFlyer", true);
	}
}

boolean bees_hate_usable(string str)
{
	if(in_bhy())
	{
		return true;
	}

	switch(str)
	{
	case "Cobb's Knob map":
	case "ball polish":
	case "black market map":
	case "boring binder clip":
	case "beehive":
	case "electric boning knife":
	case "ninja carabiner":
	case "Orcish baseball cap":
	case "reinforced beaded headband":
	case "bullet-proof corduroys":
	case "blackberry galoshes":
	case "titanium assault umbrella":
	case "Knob Goblin harem pants":
	case "Knob Goblin harem veil":
		return true;
	}

	if(contains_text(str, "b"))
	{
		return false;
	}
	if(contains_text(str, "B"))
	{
		return false;
	}
	return true;
}

boolean LM_bhy()
{
	if(in_bhy())
	{
		return false;
	}
	// pension check keeps trying to be used
	// we can't turn disassembled clovers back into ten-leaf ones
	foreach it in $items[black pension check,ten-leaf clover]
	{
		if(item_amount(it) > 0)
		{
			put_closet(item_amount(it), it);
		}
	}

	return false;
}

boolean L13_bhy_towerFinal()
{
	//Prepare for and defeat the final boss for a Bees hate You run. Which has special rules for engagement.
	if (internalQuestStatus("questL13Final") != 11)
	{
		return false;
	}
	
	if (item_amount($item[antique hand mirror]) < 1 )
	{
		abort("Need the [antique hand mirror] to defeat the guy made of bees. Please get one from the jewelry of the animated rustic nightstand and try again.");
	}
	
	cli_execute("scripts/autoscend/auto_pre_adv.ash");
	set_property("auto_disableAdventureHandling", true);
	autoAdvBypass("place.php?whichplace=nstower&action=ns_10_sorcfight", $location[Noob Cave]);
	
	if(last_monster() != $monster[Guy Made Of Bees])
	{
		abort("Failed to start the battle with Guy Made Of Bees");
	}
	if(have_effect($effect[Beaten Up]) > 0)
	{
		abort("The Guy Made Of Bees beat me up! Please finish him off manually");
	}
	if(get_property("auto_stayInRun").to_boolean())
	{
		abort("User wanted to stay in run (auto_stayInRun), we are done.");
	}
	else
	{
		visit_url("place.php?whichplace=nstower&action=ns_11_prism");
		if(inAftercore())
		{
			abort("All done. King Ralph has been freed");
		}
		abort("Tried to break prism but failed");
	}
	abort("How did I reach this line? I should have fought [Guy Made Of Bees]");
	return false;
	
}