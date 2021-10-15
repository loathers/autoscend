boolean in_disguises()
{
	return my_path() == "Disguises Delimit";
}

void disguises_initializeSettings()
{
	if(in_disguises())
	{
		set_property("auto_getBeehive", true);
		set_property("auto_getBoningKnife", true);
	}
}
