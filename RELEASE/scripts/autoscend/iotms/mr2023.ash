# This is meant for items that have a date of 2023

boolean auto_haveRockGarden()
{
	static item rockGarden = $item[Packet Of Rock Seeds];
	return auto_is_valid(rockGarden) && auto_get_campground() contains rockGarden;
}
boolean canUseMolehill()
{
	if(get_property("_molehillMountainUsed").to_boolean) return;
}
void pickRocks()
{
	//Pick rocks everyday
	//If we manage to get a lodestone, will not use it, because it is a one-a-day and user may want to use it in specific places
	//
    if (!auto_haveRockGarden()) return;
	visit_url(campground.php?action=rgarden1);
	visit_url(campground.php?action=rgarden2);
	visit_url(campground.php?action=rgarden3);

	if (!canUseMolehill()){
		use(1,$item[Molehill Mountain]);
	}

	if(item_amount($item[strange stalagmite] > 0) && !get_property("_strangeStalagmiteUsed").to_boolean) //while we will probably never get here, should handle it anyway
	{
		auto_run_choice(1491);
	}
	return;
}

boolean auto_haveSITCourse()
{
	static item sitCourse = $item[S.I.T. Course Completion Certificate];
	return auto_is_valid(sitCourse) && item_amount(sitCourse) > 0;
}

void auto_SITCourse()
{
	if (!auto_haveSITCourse()) return;
	if (get_property("_sitCourseCompleted").to_boolean) return; //return if already have used it for the day
	//Best choice seems to be insectologist
	if (!has_skill($skill[insectologist])){
		use(1,$item[S.I.T. Course Completion Certificate]);
		auto_run_choice(1484);
		return;
	}
	//Use items as we get them
	if(item_amount($item[filled mosquito] > 0 && (my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean())))
	{
		use(1,$item[filled mosquito]); //6 substats per turn
	}
	return;
}