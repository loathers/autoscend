# This is meant for items that have a date of 2023

boolean isRockGardenAvailable()
{
	static item rockGarden = $item[Packet Of Rock Seeds];
	return auto_is_valid(rockGarden) && auto_get_campground() contains rockGarden;
}
void pickRocks()
{
    if (!isRockGardenAvailable()) return;
    
}