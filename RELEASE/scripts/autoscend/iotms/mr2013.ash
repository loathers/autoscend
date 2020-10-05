#	This is meant for items that have a date of 2013

void handleJar()
{
	if(item_amount($item[psychoanalytic jar]) > 0)
	{
		if(item_amount($item[jar of psychoses (The Crackpot Mystic)]) == 0)
		{
			visit_url("shop.php?whichshop=mystic&action=jung&whichperson=mystic", true);
		}
		else
		{
			put_closet(1, $item[psychoanalytic jar]);
		}
	}
}

void makeStartingSmiths()
{
	if(!auto_have_skill($skill[Summon Smithsness]))
	{
		return;
	}

	if(item_amount($item[Lump of Brituminous Coal]) == 0)
	{
		if(my_mp() < (3 * mp_cost($skill[Summon Smithsness])))
		{
			auto_log_warning("You don't have enough MP for initialization, it might be ok but probably not.", "red");
		}
		use_skill(3, $skill[Summon Smithsness]);
	}

	if(knoll_available())
	{
		buyUpTo(1, $item[maiden wig]);
	}

	switch(my_class())
	{
	case $class[Seal Clubber]:
		if(!possessEquipment($item[Meat Tenderizer is Murder]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[seal-clubbing club]);
		}
		if(!possessEquipment($item[Vicar\'s Tutu]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && knoll_available())
		{
			buy(1, $item[Frilly Skirt]);
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Frilly Skirt]);
		}
		break;
	case $class[Turtle Tamer]:
		if(!possessEquipment($item[Work is a Four Letter Sword]))
		{
			buyUpTo(1, $item[Sword Hilt]);
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[sword hilt]);
		}
		if(!possessEquipment($item[Ouija Board\, Ouija Board]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[turtle totem]);
		}
		break;
	case $class[Sauceror]:
		if(!possessEquipment($item[Saucepanic]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Saucepan]);
		}
		if(!possessEquipment($item[A Light that Never Goes Out]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
		{
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Third-hand Lantern]);
		}
		break;
	case $class[Pastamancer]:
		if(!possessEquipment($item[Hand That Rocks the Ladle]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Pasta Spoon]);
		}
		break;
	case $class[Disco Bandit]:
		if(!possessEquipment($item[Frankly Mr. Shank]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Disco Ball]);
		}
		break;
	case $class[Accordion Thief]:
		if(!possessEquipment($item[Shakespeare\'s Sister\'s Accordion]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Stolen Accordion]);
		}
		break;
	}

	if(knoll_available() && !possessEquipment($item[Hairpiece on Fire]) && (item_amount($item[lump of Brituminous Coal]) > 0))
	{
		autoCraft("smith", 1, $item[lump of Brituminous coal], $item[maiden wig]);
	}
	buffMaintain($effect[Merry Smithsness], 0, 1, 10);
}

boolean didWePlantHere(location loc)
{
	string [location, 3] places = get_florist_plants();
	foreach place in places
	{
		if(loc == place)
		{
			return true;
		}
	}
	return false;
}

void trickMafiaAboutFlorist()
{
	// This only works if you actually have the Florist Friar but it isn\'t detected by Mafia
	// This may not be the most optimal way to do it.
	visit_url("choice.php?whichchoice=720&pwd=&option=4");
	visit_url("place.php?whichplace=forestvillage&action=fv_friar");
	visit_url("choice.php?whichchoice=720&pwd=&option=4");
	//We might not need to do this last one...
	visit_url("choice.php?whichchoice=720&pwd=&option=4");
}

void oldPeoplePlantStuff()
{
	if(!florist_available())
	{
		return;
	}

	if(didWePlantHere(my_location()))
	{
		return;
	}

	if(my_path() == "Community Service")
	{
		if(my_location() == $location[The Velvet / Gold Mine])
		{
			cli_execute("florist plant horn of plenty");
			cli_execute("florist plant max headshroom");
			cli_execute("florist plant foul toadstool");
		}
		else if(my_location() == $location[The Secret Government Laboratory])
		{
			cli_execute("florist plant pitcher plant");
			cli_execute("florist plant spider plant");
			cli_execute("florist plant stealing magnolia");
		}
		else if(my_location() == $location[The Bubblin\' Caldera])
		{
			cli_execute("florist plant seltzer watercress");
			cli_execute("florist plant lettuce spray");
			cli_execute("florist plant skunk cabbage");
		}
		else if(my_location() == $location[The Skeleton Store])
		{
			cli_execute("florist plant canned spinach");
			cli_execute("florist plant aloe guv'nor");
		}
		else if(my_location() == $location[LavaCo&trade; Lamp Factory])
		{
			cli_execute("florist plant impatiens");
			cli_execute("florist plant red fern");
			cli_execute("florist plant bamboo!");
		}
		else if(my_location() == $location[8-bit realm])
		{
			cli_execute("florist plant rad-ish radish");
			cli_execute("florist plant smoke-ra");
			cli_execute("florist plant deadly cinnamon");
		}
		else if(my_location() == $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice])
		{
			cli_execute("florist plant war lily");
			cli_execute("florist plant arctic moss");
		}
		else if(my_location() == $location[The Deep Machine Tunnels])
		{
			cli_execute("florist plant blustery puffball");
			cli_execute("florist plant dis lichen");
			cli_execute("florist plant loose morels");
		}
		else if((my_location() == $location[The X-32-F Combat Training Snowman]) && (my_daycount() == 2))
		{
			cli_execute("florist plant canned spinach");
			cli_execute("florist plant red fern");
			cli_execute("florist plant spider plant");
		}
		return;
	}

	if((my_location() == $location[The Outskirts of Cobb\'s Knob]))
	{
		cli_execute("florist plant rad-ish radish");
		cli_execute("florist plant celery stalker");
	}
	else if((my_location() == $location[The Spooky Forest]))
	{
		cli_execute("florist plant seltzer watercress");
		cli_execute("florist plant lettuce spray");
		cli_execute("florist plant deadly cinnamon");
	}
	else if((my_location() == $location[The Haunted Bathroom]))
	{
		cli_execute("florist plant war lily");
		cli_execute("florist plant Impatiens");
		cli_execute("florist plant arctic moss");
	}
	else if((my_location() == $location[The Haunted Ballroom]))
	{
		cli_execute("florist plant stealing magnolia");
		cli_execute("florist plant aloe guv'nor");
		cli_execute("florist plant pitcher plant");
	}
	else if((my_location() == $location[The Defiled Nook]))
	{
		cli_execute("florist plant horn of plenty");
	}
	else if((my_location() == $location[The Defiled Alcove]))
	{
		cli_execute("florist plant shuffle truffle");
	}
	else if((my_location() == $location[The Defiled Niche]))
	{
		cli_execute("florist plant wizard's wig");
	}
	else if((my_location() == $location[The Obligatory Pirate\'s Cove]))
	{
		cli_execute("florist plant rabid dogwood");
		cli_execute("florist plant artichoker");
	}
	else if((my_location() == $location[Barrrney\'s Barrr]) && (my_class() != $class[Ed]))
	{
		cli_execute("florist plant spider plant");
		cli_execute("florist plant red fern");
		cli_execute("florist plant bamboo!");
	}
	else if((my_location() == $location[The Penultimate Fantasy Airship]))
	{
		cli_execute("florist plant rutabeggar");
		cli_execute("florist plant smoke-ra");
		cli_execute("florist plant skunk cabbage");
	}
	else if((my_location() == $location[The Castle in the Clouds in the Sky (Basement)]) && (my_daycount() == 1))
	{
		cli_execute("florist plant blustery puffball");
		cli_execute("florist plant dis lichen");
		cli_execute("florist plant max headshroom");
	}
	else if((my_location() == $location[The Castle in the Clouds in the Sky (Ground Floor)]))
	{
		cli_execute("florist plant canned spinach");
	}
	else if((my_location() == $location[Oil Peak]))
	{
		cli_execute("florist plant rabid dogwood");
		cli_execute("florist plant artichoker");
		cli_execute("florist plant celery stalker");
	}
	else if((my_location() == $location[The Haunted Boiler Room]))
	{
		cli_execute("florist plant war lily");
		cli_execute("florist plant red fern");
		cli_execute("florist plant arctic moss");
	}
	else if((my_location() == $location[A Massive Ziggurat]))
	{
		cli_execute("florist plant skunk cabbage");
		cli_execute("florist plant deadly cinnamon");
	}
	else if((my_location() == $location[The Arid\, Extra-Dry Desert]))
	{
		cli_execute("florist plant rad-ish radish");
		cli_execute("florist plant lettuce spray");
	}
	else if((my_location() == $location[The Hidden Apartment Building]))
	{
		cli_execute("florist plant impatiens");
		cli_execute("florist plant spider plant");
		cli_execute("florist plant pitcher plant");
	}
	else if((my_location() == $location[The Hidden Office Building]))
	{
		cli_execute("florist plant canned spinach");
	}
	else if((my_location() == $location[The Hidden Bowling Alley]))
	{
		cli_execute("florist plant Stealing Magnolia");
	}
	else if((my_location() == $location[The Hidden Hospital]))
	{
		cli_execute("florist plant bamboo!");
		cli_execute("florist plant aloe guv'nor");
	}
	else if((my_location() == $location[The Upper Chamber]))
	{
		cli_execute("florist plant Blustery Puffball");
		cli_execute("florist plant Loose Morels");
		cli_execute("florist plant Foul Toadstool");
	}
	else if((my_location() == $location[The Middle Chamber]))
	{
		cli_execute("florist plant Horn of Plenty");
		cli_execute("florist plant max headshroom");
		cli_execute("florist plant Dis Lichen");
	}
	else if((my_location() == $location[The Battlefield (Frat Uniform)]))
	{
		cli_execute("florist plant Seltzer Watercress");
		cli_execute("florist plant Smoke-ra");
		cli_execute("florist plant Rutabeggar");
	}
	else if((my_location() == $location[The Secret Government Laboratory]) && (my_daycount() == 1))
	{
		cli_execute("florist plant Pitcher Plant");
		cli_execute("florist plant Canned Spinach");
	}
	else if((my_location() == $location[Hippy Camp]) && (my_daycount() == 1))
	{
		cli_execute("florist plant Seltzer Watercress");
		cli_execute("florist plant Rad-ish Radish");
	}
	else if((my_location() == $location[Pirates of the Garbage Barges]) && (my_daycount() == 1))
	{
		cli_execute("florist plant Pitcher Plant");
		cli_execute("florist plant Canned Spinach");
	}
	else if((my_location() == $location[The Battlefield (Hippy Uniform)]))
	{
		cli_execute("florist plant Seltzer Watercress");
		cli_execute("florist plant Smoke-ra");
		cli_execute("florist plant Rutabeggar");
	}
}
