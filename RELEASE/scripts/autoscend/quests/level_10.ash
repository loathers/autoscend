boolean L10_plantThatBean()
{
	if(internalQuestStatus("questL10Garbage") != 0)
	{
		return false;
	}

	auto_log_info("Planting enchanted bean to open the beanstalk and start L10 quest.", "blue");
	string page = visit_url("place.php?whichplace=plains");
	if(contains_text(page, "place.php?whichplace=beanstalk"))
	{
		auto_log_warning("I see the beanstalk has already been planted. Fixing questL10Garbage to step1.", "blue");
		set_property("questL10Garbage", "step1");
		return true;
	}
	if(item_amount($item[Enchanted Bean]) > 0)
	{
		if(auto_haveSpringShoes())
		{
			// shoes gives stats when planting bean, but must be equipped
			equip($slot[acc3], $item[spring shoes]); //free stats
		}
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
			auto_log_info("No enchanted bean. Getting one from The Beanbat Chamber.", "blue");
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

	auto_log_info("The Penultimate Fantasy Airship - unlocking Castle.", "blue");
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

	if (auto_canHabitat() && get_property("breathitinCharges").to_int() < 1)
	{
		// save turns in the airship with inherently free combats.
		set_property("auto_habitatMonster", $monster[eldritch tentacle].to_string());
		if (fightScienceTentacle())
		{
			return true;
		}
		else
		{
			set_property("auto_habitatMonster", "");
		}
	}

	if(handleFamiliar($familiar[Red-Nosed Snapper]))
	{
		auto_changeSnapperPhylum($phylum[dude]);
	}
	autoAdv($location[The Penultimate Fantasy Airship]);
	return true;
}

void castleBasementChoiceHandler(int choice)
{
	if(choice == 669) // The Fast and the Furry-ous (The Castle in the Clouds in the Sky (Basement))
	{
		run_choice(1); // if umbrella equipped finish quest. without, go to Out in the Open Source (#671)
	}
	else if(choice == 670) // You Don't Mess Around with Gym (The Castle in the Clouds in the Sky (Basement))
	{
		if(internalQuestStatus("questL10Garbage") < 8 && equipped_amount($item[Amulet of Extreme Plot Significance]) > 0)
		{
			run_choice(4); // with amulet equipped, open the ground floor
		}
		else
		{
			run_choice(1); // with no amulet, grab the dumbbell. will skip if already have dumbbell
		}
	}
	else if(choice == 671) // Out in the Open Source (The Castle in the Clouds in the Sky (Basement))
	{
		if(item_amount($item[Massive Dumbbell]) > 0)
		{
			run_choice(1); // with dumbbell, open the ground floor
		}
		else
		{
			run_choice(4); // without dumbbell, go to You Don't Mess Around with Gym (#670)
		}
	}
	else
	{
		abort("unhandled choice in castleBasementChoiceHandler");
	}
}	

boolean L10_basement()
{
	if(internalQuestStatus("questL10Garbage") != 7)
	{
		return false;
	}

	if(possessEquipment($item[Amulet of Extreme Plot Significance]))
	{
		if(!auto_can_equip($item[Amulet of Extreme Plot Significance]))
		{
			return false;
		}
	}
	else if(possessEquipment($item[Titanium Assault Umbrella]) && !auto_can_equip($item[Titanium Assault Umbrella]))
	{
		return false;
	}

	if (auto_reserveUndergroundAdventures())
	{
		return false;
	}

	auto_log_info("Castle (Basement) - Unlocking Ground Floor.", "blue");

	if(!in_hardcore())
	{
		item amulet = $item[Amulet of Extreme Plot Significance];
		if(!possessEquipment(amulet) && auto_can_equip(amulet) && canPull(amulet))
		{
			pullXWhenHaveY(amulet, 1, 0);
		}
		
		if(!possessEquipment(amulet))			//only consider umbrella if getting amulet fails somehow
		{
			item umbrella = $item[Titanium Assault Umbrella];
			if(!possessEquipment(umbrella) && auto_can_equip(umbrella) && canPull(umbrella) && !possessEquipment($item[unbreakable umbrella]))
			{
				pullXWhenHaveY(umbrella, 1, 0);
			}
		}
	}

	if(my_primestat() == $stat[Muscle])
	{
		auto_buyUpTo(1, $item[Ben-Gal&trade; Balm]);
		buffMaintain($effect[Go Get \'Em\, Tiger!]);
	}
	auto_buyUpTo(1, $item[Hair Spray]);
	buffMaintain($effect[Butt-Rock Hair]);
	
	if(in_gnoob() && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Bendable Knees]) && (item_amount($item[Bottle of Gregnadigne]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}

	boolean NCForced = auto_forceNextNoncombat($location[The Castle in the Clouds in the Sky (Basement)]);
	// delay to day 2 if we are out of NC forcers and haven't run out of things to do
	if(!NCForced && my_daycount() == 1 && !isAboutToPowerlevel()) return false;
	if(!autoEquip($item[Amulet of Extreme Plot Significance]))
	{
		if(!autoEquip($item[unbreakable umbrella]))
		{
			autoEquip($item[Titanium Assault Umbrella]);
		}	
	}
	autoAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
	
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

	auto_log_info("Castle (Ground Floor) - Unlocking Top Floor.", "blue");

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
		auto_log_debug("Delaying Castle (Top Floor) in case of Shen.");
		return false;
	}

	auto_log_info("Castle (Top Floor) - Finishing L10 Quest.", "blue");
	
	if(!possessEquipment($item[Mohawk wig]) && auto_can_equip($item[Mohawk wig]) && canPull($item[Mohawk wig]))
	{
		pullXWhenHaveY($item[Mohawk wig], 1, 0);
	}

	boolean NCForced = auto_forceNextNoncombat($location[The Castle in the Clouds in the Sky (Top Floor)]);
	// delay to day 2 if we are out of NC forcers and haven't run out of things to do
	if(!NCForced && my_daycount() == 1 && !isAboutToPowerlevel()) return false;
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

void castleTopFloorChoiceHandler(int choice)
{
	if(choice == 675) // Melon Collie and the Infinite Lameness (The Castle in the Clouds in the Sky (Top Floor))
	{
		if(internalQuestStatus("questL10Garbage") < 10 && item_amount($item[Drum \'n\' Bass \'n\' Drum \'n\' Bass Record]) > 0)
		{
			run_choice(2); // if quest not done and have the record, complete the quest
		}
		else if(in_koe() && item_amount($item[Model airship]) == 0)
		{
			run_choice(1); // if we're in koe we only want to go to Copper Feel if we can complete the quest, so fight a goth giant otherwise
		}
		else
		{
			run_choice(4); // moves to Copper Feel (#677) in all other scenarios
		}
	}
	else if(choice == 676) // Flavor of a Raver (The Castle in the Clouds in the Sky (Top Floor))
	{	
		if(equipped_amount($item[Mohawk wig]) > 0 || internalQuestStatus("questL10Garbage") >= 10)
		{
			run_choice(4); // if quest not done and have mohawk wig on, or quest is done, move to Yeah, You're for Me (#678)
		}	
		else
		{
			run_choice(3); // if no mohawk wig and quest not done, grab the drum n bass record. will skip if already have record
		}
	}
	else if(choice == 677) // Copper Feel (The Castle in the Clouds in the Sky (Top Floor))
	{
		if(internalQuestStatus("questL10Garbage") < 10 && item_amount($item[Model airship]) > 0)
		{
			run_choice(1); // if quest not done and have model airship, complete quest
		}
		else if((internalQuestStatus("questL10Garbage") < 10 && item_amount($item[Drum \'n\' Bass \'n\' Drum \'n\' Bass Record]) > 0) || in_koe())
		{
			run_choice(4); // if quest not done and have the record, move to Melon Collie (#675). HITS is open in KoE so no need to grab rocket
		}
		else
		{
			run_choice(2); // grab steam-powered rocket ship. will skip if already have rocket
		}
	}
	else if(choice == 678) // Yeah, You're for Me, Punk Rock Giant (The Castle in the Clouds in the Sky (Top Floor))
	{
		if(internalQuestStatus("questL10Garbage") < 10 && equipped_amount($item[Mohawk wig]) > 0)
		{
			run_choice(1); // if quest not done and mohawk wig equipped, finish quest
		}
		else if(internalQuestStatus("questL10Garbage") < 10)
		{
			run_choice(4); // if wig not equipped and quest not done, go to Flavor of a Raver (#676)
		}
		else
		{
			run_choice(3); // if quest is done, go to Copper Feel (#677) to get rocket ship or skip
		}
	}
	else if(choice == 679) // Keep On Turnin' the Wheel in the Sky (The Castle in the Clouds in the Sky (Top Floor))
	{
		if(isActuallyEd())
		{
			run_choice(2); // ed advances via choice 2
		}
		else
		{
			run_choice(1); // everyone else advances via choice 1
		}
	}
	else if(choice == 680) // Are you a Man or a Mouse? (The Castle in the Clouds in the Sky (Top Floor))
	{
		run_choice(1); // go to finish quest the long way
	}
	else
	{
		abort("unhandled choice in castleTopFloorChoiceHandler");
	}
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
	LX_buyStarKeyParts();
	int day = get_property("shenInitiationDay").to_int();
	boolean[location] shenLocs = shenSnakeLocations(day, 0);
	if(!needStarKey() && !(shenLocs contains $location[The Hole in the Sky]))
	{
		// we force auto_holeinthesky to true in L11_shenCopperhead() as Ed if Shen sends us to the Hole in the Sky
		// as otherwise the zone isn't required at all for Ed.
		// Should also handle situations where the player manually got the star key before unlocking Shen.
		// or can buy the star key ingredients out of ronin.
		set_property("auto_holeinthesky", false);
		return false;
	}

	if(shenShouldDelayZone($location[The Castle in the Clouds in the Sky (Top Floor)]))
	{
		auto_log_debug("Delaying unlocking Hole in the Sky in case of Shen.");
		return false;
	}

	auto_log_info("Castle (Top Floor) - Opening the Hole in the Sky.", "blue");
	
	// set location "wrong" so that LX_ForceNC can properly direct back to this function (L10_holeInTheSkyUnlock)
	boolean NCForced = auto_forceNextNoncombat($location[The Hole in the Sky]);
	// delay to day 2 if we are out of NC forcers and haven't run out of things to do
	if(!NCForced && my_daycount() == 1 && !isAboutToPowerlevel()) return false;

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
