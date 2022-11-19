/* TODO - banishing chickens prior to Nuns
		- wearing chicken hat (and ensuring chickens arent banished) for tower
		- obtaining chicken hat and dino banishing items
		- pheromoning kachungasaurs for nuns
*/


boolean in_fotd()
{
	return my_path() == $path[Fall of the Dinosaurs];
}

void fotd_initializeSettings()
{
	if(in_fotd())
	{
		set_property("auto_getBeehive", false); // can birdseed hat the tower monsters
		set_property("auto_getBoningKnife", false); // can birdseed hat the tower monsters
		set_property("auto_wandOfNagamar", false); // naughty saursaurus does not need the wand
	}
}

boolean fotd_gameWarden()
{
	if(!in_fotd())
	{
		return false;
	}
	string warden = visit_url("place.php?whichplace=dinorf&action=dinorf_hunter");
	matcher target = create_matcher("what I need is ([0-9])+ ([A-Za-z ])+\"", warden); // TODO add some logic meaning we only check at start of day and then once we know we have enough of the target item?
	matcher can_collect = create_matcher("Looks like you have [0-9]+\. Want", warden);

	while(can_collect.find())
	{
		warden = run_choice(1);
	}

	run_choice(2);
	return true;
}

