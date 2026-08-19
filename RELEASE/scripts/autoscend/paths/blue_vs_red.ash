boolean in_bluevsred()
{
	return my_path() == $path[Blue vs. Red];
}

boolean bluevsred_isBlue()
{
	return in_bluevsred() && get_property("blueVsRedTeam") == "blue";
}

boolean bluevsred_isRed()
{
	return in_bluevsred() && get_property("blueVsRedTeam") == "red";
}

void bluevsred_initializeSettings()
{
	if(!in_bluevsred())
	{
		return;
	}
	set_property("auto_wandOfNagamar", false);		//wand not used in this path

	if (bluevsred_isRed())
	{
		set_property("auto_hippyInstead", true);
		set_property("auto_skipNuns", true);
		set_property("auto_skipL12Farm", true); // can softlock
	}
}
