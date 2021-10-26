boolean L10_plantThatBean()
{
	if(internalQuestStatus("questL10Garbage") != 0)
	{
		return false;
	}

	auto_log_info("Planting me magic bean!", "blue");
	string page = visit_url("place.php?whichplace=plains");
	if(contains_text(page, "place.php?whichplace=beanstalk"))
	{
		auto_log_warning("I see the beanstalk has already been planted. fixing questL10Garbage to step1", "blue");
		set_property("questL10Garbage", "step1");
		return true;
	}
	if(item_amount($item[Enchanted Bean]) > 0)
	{
		visit_url("place.php?whichplace=plains&action=garbage_grounds");
		return true;
	}
	else
	{
		// make sure we can get an enchanted bean to open the beanstalk with if we can't open it.
		if(L4_batCave())
		{
			return true;
		}
		else
		{
			auto_log_info("I don't have a magic bean! Travesty!!", "blue");
			return autoAdv($location[The Beanbat Chamber]);
		}
	}
	return false;
}

boolean L10_airship()
{
	if(internalQuestStatus("questL10Garbage") < 1 || internalQuestStatus("questL10Garbage") > 6)
	{
		return false;
	}

	if(my_turncount() == get_property("_LAR_skipNC178").to_int())
	{
		auto_log_info("In LAR path NC178 is forced to reoccur if we skip it. Go do something else.");
		return false;
	}

	auto_log_info("Fantasy Airship Fly Fly time", "blue");
	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}

	if((my_daycount() == 1) && (get_property("_hipsterAdv").to_int() < 7) && is_unrestricted($familiar[Artistic Goth Kid]) && auto_have_familiar($familiar[Artistic Goth Kid]))
	{
		auto_log_info("Hipster Adv: " + get_property("_hipsterAdv"), "blue");
		handleFamiliar($familiar[Artistic Goth Kid]);
	}

	if($location[The Penultimate Fantasy Airship].turns_spent < 10)
	{
		bat_formBats();
	}

	if(isActuallyEd() && $location[The Penultimate Fantasy Airship].turns_spent < 1)	
	{	
		// temp workaround for mafia bug.	
		// see https://kolmafia.us/showthread.php?24767-Quest-tracking-preferences-change-request(s)&p=156733&viewfull=1#post156733
		// still not fixed as of r19986
		visit_url("place.php?whichplace=beanstalk");	
	}

	if(handleFamiliar($familiar[Red-Nosed Snapper]))
	{
		auto_changeSnapperPhylum($phylum[dude]);
	}
	autoAdv($location[The Penultimate Fantasy Airship]);
	return true;
}

boolean L10_basement()
{
	if(internalQuestStatus("questL10Garbage") != 7)
	{
		return false;
	}

	if(possessEquipment($item[Titanium Assault Umbrella]) && !auto_can_equip($item[Titanium Assault Umbrella]))
	{
		return false;
	}

	if(possessEquipment($item[Amulet of Extreme Plot Significance]) && !auto_can_equip($item[Amulet of Extreme Plot Significance]))
	{
		return false;
	}

	auto_log_info("Basement Search", "blue");
	
	if(!possessEquipment($item[Titanium Assault Umbrella]) && auto_can_equip($item[Titanium Assault Umbrella]) && !in_hardcore())
	{
		pullXWhenHaveY($item[Titanium Assault Umbrella], 1, 0);
	}

	if(!possessEquipment($item[Amulet of Extreme Plot Significance]) && auto_can_equip($item[Amulet of Extreme Plot Significance]) && !in_hardcore())
	{
		pullXWhenHaveY($item[Amulet of Extreme Plot Significance], 1, 0);
	}

	if(my_primestat() == $stat[Muscle])
	{
		buyUpTo(1, $item[Ben-Gal&trade; Balm]);
		buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
	}
	buyUpTo(1, $item[Hair Spray]);
	buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
	
	if(in_gnoob() && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Bendable Knees]) && (item_amount($item[Bottle of Gregnadigne]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}

	auto_forceNextNoncombat();
	autoEquip($item[Titanium Assault Umbrella]);
	autoEquip($item[Amulet of Extreme Plot Significance]);
	autoAdv($location[The Castle in the Clouds in the Sky (Basement)]);
	resetMaximize();
	
	return true;
}

boolean L10_ground()
{
	if(internalQuestStatus("questL10Garbage") != 8)
	{
		return false;
	}

	if(!lar_repeat($location[The Castle in the Clouds in the Sky (Ground Floor)]))
	{
		return false;
	}

	if(canBurnDelay($location[The Castle in the Clouds in the Sky (Ground Floor)]))
	{
		return false;
	}

	auto_log_info("Castle Ground Floor, boring!", "blue");

	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);

	if(in_gnoob() && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Bendable Knees]) && (item_amount($item[Bottle of Gregnadigne]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}

	return autoAdv($location[The Castle in the Clouds in the Sky (Ground Floor)]);
}

boolean L10_topFloor()
{
	if(internalQuestStatus("questL10Garbage") < 9 || internalQuestStatus("questL10Garbage") > 10)
	{
		return false;
	}

	if(possessEquipment($item[Mohawk wig]) && !auto_can_equip($item[Mohawk wig]))
	{
		return false;
	}

	if(shenShouldDelayZone($location[The Castle in the Clouds in the Sky (Top Floor)]))
	{
		auto_log_debug("Delaying Top Floor in case of Shen.");
		return false;
	}

	auto_log_info("Castle Top Floor", "blue");
	
	if(!possessEquipment($item[Mohawk wig]) && auto_can_equip($item[Mohawk wig]) && !in_hardcore())
	{
		pullXWhenHaveY($item[Mohawk wig], 1, 0);
	}

	auto_forceNextNoncombat();
	autoEquip($item[Mohawk wig]);
	autoAdv(1, $location[The Castle in the Clouds in the Sky (Top Floor)]);

	if(internalQuestStatus("questL10Garbage") > 9)
	{
		council();
		if(in_koe())
		{
			cli_execute("refresh quests");
		}
	}

	return true;
}

boolean L10_holeInTheSkyUnlock()
{
	if(internalQuestStatus("questL10Garbage") < 11)
	{
		//top floor opens at step9. but we want to finish the giant trash quest first before we do hole in the sky.
		return false;
	}
	if(!get_property("auto_holeinthesky").to_boolean())
	{
		return false;
	}
	if(item_amount($item[Steam-Powered Model Rocketship]) > 0)
	{
		set_property("auto_holeinthesky", false);
		return false;
	}
	int day = get_property("shenInitiationDay").to_int();
	boolean[location] shenLocs = shenSnakeLocations(day, 0);
	if(!needStarKey() && !(shenLocs contains $location[The Hole in the Sky]))
	{
		// we force auto_holeinthesky to true in L11_shenCopperhead() as Ed if Shen sends us to the Hole in the Sky
		// as otherwise the zone isn't required at all for Ed.
		// Should also handle situations where the player manually got the star key before unlocking Shen.
		set_property("auto_holeinthesky", false);
		return false;
	}

	if(shenShouldDelayZone($location[The Castle in the Clouds in the Sky (Top Floor)]))
	{
		auto_log_debug("Delaying unlocking Hole in the Sky in case of Shen.");
		return false;
	}

	auto_log_info("Castle Top Floor - Opening the Hole in the Sky", "blue");
	
	auto_forceNextNoncombat();
	autoAdv(1, $location[The Castle in the Clouds in the Sky (Top Floor)]);

	return true;
}

boolean L10_rainOnThePlains()
{
	if(L10_plantThatBean() || L10_airship() || L10_basement() || L10_ground() || L10_topFloor() || L10_holeInTheSkyUnlock())
	{
		return true;
	}
	return false;
}
