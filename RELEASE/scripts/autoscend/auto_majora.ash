script "auto_majora.ash"


void majora_initializeSettings()
{
	if(auto_my_path() == "Disguises Delimit")
	{
		set_property("auto_getBeehive", true);
		set_property("auto_getBoningKnife", true);
		set_property("auto_cubeItems", true);
		set_property("auto_getStarKey", true);
		set_property("auto_grimstoneOrnateDowsingRod", false);
		set_property("auto_holeinthesky", true);
		set_property("auto_useCubeling", true);
		set_property("auto_wandOfNagamar", true);
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

