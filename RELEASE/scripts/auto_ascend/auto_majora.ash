script "sl_majora.ash"


void majora_initializeSettings()
{
	if(sl_my_path() == "Disguises Delimit")
	{
		set_property("sl_getBeehive", true);
		set_property("sl_getBoningKnife", true);
		set_property("sl_cubeItems", true);
		set_property("sl_getStarKey", true);
		set_property("sl_grimstoneOrnateDowsingRod", false);
		set_property("sl_holeinthesky", true);
		set_property("sl_useCubeling", true);
		set_property("sl_wandOfNagamar", true);
	}
}

void majora_initializeDay(int day)
{

}

boolean LM_majora()
{
	if(sl_my_path() == "Disguises Delimit")
	{
	}
	return false;
}

