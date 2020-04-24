script "auto_casual.ash"

boolean inCasual()
{
	if(get_property("_casualAscension").to_int() >= my_ascensions())
	{
		return true;
	}
	return false;
}

boolean inPostRonin()
{
	//can interact means you are not in ronin and not in hardcore, but it does not mean you are not in casual.
	if(can_interact() && !inCasual())
	{
		return true;
	}
	return false;
}