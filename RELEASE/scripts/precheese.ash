script "precheese.ash";
import<cc_ascend.ash>

void handlePreAdventure()
{
	handlePreAdventure(my_location());
}

void handlePreAdventure(location place)
{
	if((equipped_item($slot[familiar]) == $item[none]) && (my_familiar() != $familiar[none]) && (cc_my_path() == "Heavy Rains"))
	{
		abort("Familiar has no equipment, WTF");
	}

#	set_location doesn't help us to resolve this, just let it infinite and fail in that exotic case that was propbably due to a bad user.
#	if((place == $location[The Deep Machine Tunnels]) && (my_familiar() != $familiar[Machine Elf]))
#	{
#		if(!cc_have_familiar($familiar[Machine Elf]))
#		{
#			abort("Massive failure, we don't use snowglobes.");
#		}
#		print("Somehow we are considering the DMT without a Machine Elf...", "red");
#	}

	if(get_property("cc_disableAdventureHandling").to_boolean())
	{
		print("Preadventure skipped by standard adventure handler.", "green");
		return;
	}

	if(last_monster().random_modifiers["clingy"])
	{
		print("Preadventure skipped by clingy modifier.", "green");
		return;
	}

	if(place == $location[The Lower Chambers])
	{
		print("Preadventure skipped by Ed the Undying!", "green");
		return;
	}

	print("Starting preadventure script...", "green");

	familiar famChoice = to_familiar(get_property("cc_familiarChoice"));
	if(cc_my_path() == "Pocket Familiars")
	{
		famChoice = $familiar[none];
	}

	if((famChoice != $familiar[none]) && !is100FamiliarRun() && (internalQuestStatus("questL13Final") < 13))
	{
		if((famChoice != my_familiar()) && !get_property("kingLiberated").to_boolean())
		{
#			print("FAMILIAR DIRECTIVE ERROR: Selected " + famChoice + " but have " + my_familiar(), "red");
			use_familiar(famChoice);
		}
	}

	if((place == $location[The Deep Machine Tunnels]) && (my_familiar() != $familiar[Machine Elf]))
	{
		if(!cc_have_familiar($familiar[Machine Elf]))
		{
			abort("Massive failure, we don't use snowglobes.");
		}
		print("Somehow we are going to the DMT without a Machine Elf...", "red");
		use_familiar($familiar[Machine Elf]);
	}

	if(my_familiar() == $familiar[Trick-Or-Treating Tot])
	{
		if($locations[A-Boo Peak, The Haunted Kitchen] contains place)
		{
			if(equipped_item($slot[Familiar]) != $item[Li\'l Candy Corn Costume])
			{
				if(item_amount($item[Li\'l Candy Corn Costume]) > 0)
				{
					equip($slot[Familiar], $item[Li\'l Candy Corn Costume]);
				}
			}
		}
	}

	preAdvXiblaxian(place);

	if(get_floundry_locations() contains place)
	{
		buffMaintain($effect[Baited Hook], 0, 1, 1);
	}

	if((my_mp() < 30) && ((my_mp()+20) < my_maxmp()) && (item_amount($item[Psychokinetic Energy Blob]) > 0))
	{
		use(1, $item[Psychokinetic Energy Blob]);
	}

	if((get_property("_bittycar") == "") && (item_amount($item[Bittycar Meatcar]) > 0))
	{
		use(1, $item[Bittycar Meatcar]);
	}

	if((have_effect($effect[Coated in Slime]) > 0) && (place != $location[The Slime Tube]))
	{
		visit_url("clan_slimetube.php?action=chamois&pwd");
	}

	if((place == $location[The Broodling Grounds]) && (my_class() == $class[Seal Clubber]))
	{
		uneffect($effect[Spiky Shell]);
		uneffect($effect[Scarysauce]);
	}

	if(my_path() == $class[Avatar of Boris])
	{
		if((have_effect($effect[Song of Solitude]) == 0) && (have_effect($effect[Song of Battle]) == 0))
		{
			//When do we consider Song of Cockiness?
			buffMaintain($effect[Song of Fortune], 10, 1, 1);
			if(have_effect($effect[Song of Fortune]) == 0)
			{
				buffMaintain($effect[Song of Accompaniment], 10, 1, 1);
			}
		}
		else if((place.turns_spent > 1) && (place != get_property("cc_priorLocation").to_location()))
		{
			//When do we consider Song of Cockiness?
			buffMaintain($effect[Song of Fortune], 10, 1, 1);
			if(have_effect($effect[Song of Fortune]) == 0)
			{
				buffMaintain($effect[Song of Accompaniment], 10, 1, 1);
			}
		}
	}

	if(my_class() == $class[Ed])
	{
		if((zone_combatMod(place)._int < combat_rate_modifier()) && (have_effect($effect[Shelter Of Shed]) == 0) && cc_have_skill($skill[Shelter Of Shed]))
		{
			acquireMP(25, false);
		}
		acquireMP(20, false);
		if(my_meat() > 1000)
		{
			acquireMP(20, true);
		}
	}

	if(!get_property("kingLiberated").to_boolean())
	{
		if(($locations[Barrrney\'s Barrr, The Black Forest, The F\'c\'le, Monorail Work Site, Sonofa Beach] contains place))
		{
			acquireCombatMods(zone_combatMod(place)._int, false);
		}

		if($locations[Whitey\'s Grove] contains place)
		{
			acquireCombatMods(zone_combatMod(place)._int, true);
		}

		if($locations[A Maze of Sewer Tunnels, The Castle in the Clouds in the Sky (Basement), The Castle in the Clouds in the Sky (Ground Floor), The Castle in the Clouds in the Sky (Top Floor), The Dark Elbow of the Woods, The Dark Heart of the Woods, The Dark Neck of the Woods, The Defiled Alcove, The Defiled Cranny, The Extreme Slope, The Haunted Ballroom, The Haunted Bathroom, The Haunted Billiards Room, The Haunted Gallery, The Hidden Hospital, The Hidden Park, The Ice Hotel, Inside the Palindome, The Obligatory Pirate\'s Cove, The Penultimate Fantasy Airship, The Poop Deck, The Spooky Forest, Super Villain\'s Lair, Twin Peak, The Upper Chamber, Wartime Hippy Camp, Wartime Hippy Camp (Frat Disguise)] contains place)
		{
			acquireCombatMods(zone_combatMod(place)._int, false);
		}
	}
	else
	{
		if((get_property("questL11Spare") == "finished") && (place == $location[The Hidden Bowling Alley]) && (item_amount($item[Bowling Ball]) > 0))
		{
			put_closet(item_amount($item[Bowling Ball]), $item[Bowling Ball]);
		}
	}

	if((monster_level_adjustment() > 120) && ((my_hp() * 10) < (my_maxhp() * 8)) && (my_mp() >= 20))
	{
		useCocoon();
	}

	if(in_hardcore() && (my_class() == $class[Sauceror]) && (my_mp() < 32) && (my_maxmp() >= 32) && (my_meat() > 2500))
	{
		acquireMP(32, true);
	}

	if((place == $location[8-Bit Realm]) && !have_equipped($item[Continuum Transfunctioner]) && (my_turncount() != 0))
	{
		if(!possessEquipment($item[Continuum Transfunctioner]))
		{
			abort("Tried to be retro but lacking the Continuum Transfunctioner.");
		}
		equip($slot[acc3], $item[Continuum Transfunctioner]);
	}

	if((place == $location[Inside The Palindome]) && !have_equipped($item[Talisman O\' Namsilat]) && (my_turncount() != 0))
	{
		if(!possessEquipment($item[Talisman O\' Namsilat]))
		{
			abort("Tried to go to The Palindome but don't have the Namsilat");
		}
		equip($slot[acc3], $item[Talisman O\' Namsilat]);
	}

	if((place == $location[The Black Forest]) && !have_equipped($item[Blackberry Galoshes]))
	{
		if(possessEquipment($item[Blackberry Galoshes]) && can_equip($item[Blackberry Galoshes]))
		{
			equip($slot[acc3], $item[Blackberry Galoshes]);
		}
	}

	generic_t itemNeed = zone_needItem(place);
	if(itemNeed._boolean && (item_drop_modifier() < itemNeed._float))
	{
		buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 20, 1, 10);
		buffMaintain($effect[Singer\'s Faithful Ocelot], 35, 1, 10);
	}
	if(itemNeed._boolean && (item_drop_modifier() < itemNeed._float))
	{
		print("We can't cap this drop bear!", "purple");
	}

	if(in_hardcore() && (my_class() == $class[Sauceror]) && (my_mp() < 32))
	{
		print("Warning, we don't have a lot of MP but we are chugging along anyway", "red");
	}
	groundhogAbort(place);
	set_property("cc_priorLocation", place);
	print("Pre Adventure at " + place + " done, beep.", "blue");
}

void main()
{
	handlePreAdventure();
}
