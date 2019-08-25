script "sl_koe.ash"

boolean in_koe()
{
	return my_path() == "37" || my_path() == "Kingdom of Exploathing";
}

boolean koe_initializeSettings()
{
	if(in_koe())
	{
		set_property("sl_day1_cobb", "finished");
		set_property("sl_bean", true);
		set_property("sl_airship", "finished");
		set_property("sl_grimstoneOrnateDowsingRod", "false");
	}
	return false;
}
