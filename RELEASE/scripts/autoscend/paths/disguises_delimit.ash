script "auto_majora.ash"


void majora_initializeSettings()
{
	if(auto_my_path() == "Disguises Delimit")
	{
		set_property("auto_getBeehive", true);
		set_property("auto_getBoningKnife", true);
		set_property("auto_grimstoneOrnateDowsingRod", false);
	}
}

void majora_initializeDay(int day)
{

}

boolean LM_majora()
{
	if(auto_my_path() == "Disguises Delimit")
	{
	}
	return false;
}

