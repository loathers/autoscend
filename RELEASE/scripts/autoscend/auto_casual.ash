script "auto_casual.ash"

boolean inCasual()
{
	if(get_property("_casualAscension").to_int() >= my_ascensions())
	{
		return true;
	}
	return false;
}

boolean inAftercore()
{
	return get_property("kingLiberated").to_boolean();
}

boolean inPostRonin()
{
	//can interact means you are not in ronin and not in hardcore. It returns true in casual, aftercore, and postronin
	if(can_interact() && !inCasual() && !inAftercore())
	{
		return true;
	}
	return false;
}