script "cc_majora.ash"


void majora_initializeSettings()
{
	if(cc_my_path() == "Disguises Delimit")
	{
		set_property("cc_getBeehive", true);
		set_property("cc_getBoningKnife", true);
		set_property("cc_cubeItems", true);
		set_property("cc_getStarKey", true);
		set_property("cc_grimstoneOrnateDowsingRod", false);
		set_property("cc_holeinthesky", true);
		set_property("cc_useCubeling", true);
		set_property("cc_wandOfNagamar", true);
	}
}

void majora_initializeDay(int day)
{

}

boolean LM_majora()
{
	if(cc_my_path() == "Disguises Delimit")
	{
	}
	return false;
}

