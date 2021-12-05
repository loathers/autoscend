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

	handleFamiliar("boss");
	if(possessEquipment($item[Powerful Glove]) && !have_equipped($item[Powerful Glove]))
	{
		return autoEquip($slot[acc3], $item[Powerful Glove]);
	}
	string[int] pages;
	pages[0] = "shop.php?whichshop=blackmarket";
	pages[1] = "shop.php?whichshop=blackmarket&action=fightbmguy";
	return autoAdvBypass(0, pages, $location[Noob Cave], "");
}
