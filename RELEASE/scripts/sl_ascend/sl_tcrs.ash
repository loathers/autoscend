script "sl_tcrs.ash"

boolean in_tcrs()
{
	return my_path() == "36" || my_path() == "Two Crazy Random Summer";
}

boolean tcrs_initializeSettings()
{
	if(in_tcrs())
	{
		set_property("sl_spookyfertilizer", "");
		set_property("sl_getStarKey", true);
		set_property("sl_holeinthesky", true);
		set_property("sl_wandOfNagamar", true);
		set_property("sl_paranoia", 2);
	}
	return true;
}

boolean tcrs_consumption()
{
	if(!in_tcrs())
		return false;

	print("Not eating or drinking anything, since we don't know what's good...");
	return true;
}
