# This is meant for items that have a date of 2024

boolean auto_haveSpringShoes()
{
	if(auto_is_valid($item[spring shoes]) && available_amount($item[spring shoes]) > 0 )
	{
		return true;
	}
	return false;
	
}

boolean auto_haveAprilingBandHelmet()
{
	if(auto_is_valid($item[Apriling band helmet]) && available_amount($item[Apriling band helmet]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_getAprilingBandItems()
{
	if(!auto_haveAprilingBandHelmet()) {return false;}
	boolean have_sax  = available_amount($item[Apriling band saxophone]) > 0;
	boolean have_tuba = available_amount($item[Apriling band tuba]     ) > 0;
	if (!have_tuba) { cli_execute("aprilband item tuba"); }
	if (!have_sax ) { cli_execute("aprilband item saxophone"); }
	
	have_sax  = available_amount($item[Apriling band saxophone]) > 0;
	have_tuba = available_amount($item[Apriling band tuba]     ) > 0;
	
	return have_sax && have_tuba;
}

boolean auto_playAprilSax()
{
	cli_execute("aprilband play saxophone");
	return have_effect($effect[Lucky!]).to_boolean();
}

boolean auto_playAprilTuba()
{
	cli_execute("aprilband play tuba");
	return get_property("noncombatForcerActive").to_boolean();
}

boolean auto_setAprilBandNonCombat()
{
	if(have_effect($effect[Apriling Band Patrol Beat]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect nc");
	return have_effect($effect[Apriling Band Patrol Beat]).to_boolean();
}

boolean auto_setAprilBandCombat()
{
	if(have_effect($effect[Apriling Band Battle Cadence]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect c");
	return have_effect($effect[Apriling Band Battle Cadence]).to_boolean();
}

boolean auto_setAprilBandDrops()
{
	if(have_effect($effect[Apriling Band Celebration Bop]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect drop");
	return have_effect($effect[Apriling Band Celebration Bop]).to_boolean();
}

int auto_AprilSaxLuckyLeft()
{
	if(!auto_haveAprilingBandHelmet()) return 0;
	return 3-get_property("_aprilBandSaxophoneUses").to_int();
}

int auto_AprilTubaForcesLeft()
{
	if(!auto_haveAprilingBandHelmet()) return 0;
	return 3-get_property("_aprilBandTubaUses").to_int();
}
