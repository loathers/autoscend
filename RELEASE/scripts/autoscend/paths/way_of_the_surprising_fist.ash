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

	string[int] pages;
	pages[0] = "shop.php?whichshop=blackmarket";
	pages[1] = "shop.php?whichshop=blackmarket&action=fightbmguy";
	return autoAdvBypass(0, pages, $location[Noob Cave], "");
}
