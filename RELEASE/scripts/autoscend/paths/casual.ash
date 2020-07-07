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

boolean LM_canInteract()
{
	//this function is called early once every loop of doTasks() in autoscend.ash to do things when we have unlimited mall access
	//which indicates postronin or casual or aftercore. currently won't get called in aftercore
	
	if(!can_interact())
	{
		return false;
	}
	
	if(get_property("lastEmptiedStorage").to_int() != my_ascensions())
	{
		cli_execute("pull all");
	}
	
	return false;
}