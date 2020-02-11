script "auto_mr2020.ash"

# This is meant for items that have a date of 2020

boolean auto_birdIsValid()
{
	// can't seek a bird if you can't use the calendar
	if(!auto_is_valid($item[Bird-a-Day calendar]))
	{
		return false;
	}

	// can't seek a bird if you don't own the calendar
	if(item_amount($item[Bird-a-Day calendar]) < 1)
	{
		return false;
	}

	// don't want to overwrite favorite bird automatically
	// however, if they already overwrote favorite bird manually today
	// and we somehow have enough mp to continue casting
	// it might as well be an option
	// hence == 0 and not <= 0
	if(auto_birdsLeftToday() == 0)
	{
		return false;
	}

	if(!get_property("_canSeekBirds").to_boolean())
	{
		use(1, $item[Bird-a-Day calendar]);
	}

	return true;
}

float auto_birdModifier(string mod)
{
	if(!auto_birdIsValid())
	{
		return 0;
	}

	return numeric_modifier($effect[Blessing of the Bird], mod);
}

float auto_favoriteBirdModifier(string mod)
{
	return numeric_modifier($effect[Blessing of Your Favorite Bird], mod);
}

int auto_birdsSought()
{
	return get_property("_birdsSoughtToday").to_int();
}

int auto_birdsLeftToday()
{
	return 6 - auto_birdsSought();
}

boolean auto_birdCanSeek()
{
	if(!auto_birdIsValid())
	{
		return false;
	}

	return auto_have_skill($skill[Seek Out a Bird]);
}

boolean auto_favoriteBirdCanSeek()
{
	// can't seek out your favorite if you already did today
	if(get_property("_favoriteBirdVisited").to_boolean())
	{
		return false;
	}

	return auto_have_skill($skill[Visit Your Favorite Bird]);
}
