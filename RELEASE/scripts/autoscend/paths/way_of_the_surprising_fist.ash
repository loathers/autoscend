boolean in_wotsf()
{
	return my_path() == "Way of the Surprising Fist";
}

boolean L11_wotsfForgedDocuments()
{
	if(!in_wotsf())
	{
		return false;
	}

	if(canChangeToFamiliar($familiar[warbear drone])) // old event item. still farmable. up to 6 attacks per round
	{
		use_familiar($familiar[Warbear Drone]);
	}
	else if(canChangeToFamiliar($familiar[Sludgepuppy])) // IOTM derivative, infinitely farmable. attacks 3 times per round
	{
		use_familiar($familiar[Sludgepuppy]);
	}
	else if(canChangeToFamiliar($familiar[Imitation Crab])) // cheap, easily acquired. attacks 2 times per round
	{
		use_familiar($familiar[Imitation Crab]);
	}
	else if(canChangeToFamiliar($familiar[Angry Goat]))	 // super cheap. high chance to attack each round.
	{
		use_familiar($familiar[Angry Goat]);
	}

	if(possessEquipment($item[Powerful Glove]) && !have_equipped($item[Powerful Glove]))
	{
		return autoEquip($slot[acc3], $item[Powerful Glove]);
	}

	string[int] pages;
	pages[0] = "shop.php?whichshop=blackmarket";
	pages[1] = "shop.php?whichshop=blackmarket&action=fightbmguy";
	return autoAdvBypass(0, pages, $location[Noob Cave], "");
}
