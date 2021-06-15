//Path specific combat handling for license to adventure

string auto_combatLicenseToAdventureStage4(int round, monster enemy, string text)
{
	##stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	
	//each of the 3 items reduces minion count by 3. does NOT auto defeat current minion you are fighting
	if((my_location() == $location[Super Villain\'s Lair]) && (auto_my_path() == "License to Adventure") && canSurvive(2.0) && (enemy == $monster[Villainous Minion]))
	{
		if(!get_property("_villainLairCanLidUsed").to_boolean() && (item_amount($item[Razor-Sharp Can Lid]) > 0))
		{
			return "item " + $item[Razor-Sharp Can Lid];
		}
		if(!get_property("_villainLairWebUsed").to_boolean() && (item_amount($item[Spider Web]) > 0))
		{
			return "item " + $item[Spider Web];
		}
		if(!get_property("_villainLairFirecrackerUsed").to_boolean() && (item_amount($item[Knob Goblin Firecracker]) > 0))
		{
			return "item " + $item[Knob Goblin Firecracker];
		}
	}
	
	return "";
}
