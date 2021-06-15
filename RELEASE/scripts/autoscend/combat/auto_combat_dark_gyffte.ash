//Path specific combat handling for dark gyffte

string auto_combatDarkGyffteStage2(int round, monster enemy, string text)
{
	##stage 2 = enders: escape, replace, instakill, yellowray and other actions that instantly end combat

	//Ensorcel is a Dark Gyffte specific skill that lets you mind control an enemy to becoming a minion 3/day.
	//mechanically it is a free runaway that also gives you a vampyre specific pet based on the phylum of the monster you are facing.
	if(bat_shouldEnsorcel(enemy) && canUse($skill[Ensorcel]) && get_property("auto_bat_ensorcels").to_int() < 3)
	{
		set_property("auto_bat_ensorcels", get_property("auto_bat_ensorcels").to_int() + 1);
		handleTracker(enemy, $skill[Ensorcel], "auto_otherstuff");
		return useSkill($skill[Ensorcel]);
	}

	return "";
}
