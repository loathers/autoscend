# This is meant for items that have a date of 2026

boolean auto_haveLegendarySealClubbingClub()
{
	if(auto_is_valid($item[legendary seal-clubbing club]) && available_amount($item[legendary seal-clubbing club]) > 0 )
	{
		return true;
	}
	return false;
}

int auto_clubEmBackInTimesRemaining()
{
	if (!auto_haveLegendarySealClubbingClub()) return 0;
	
	return 5-to_int(get_property("_clubEmTimeUsed"));
}

int auto_clubEmAcrossTheBattlefieldsRemaining()
{
	if (!auto_haveLegendarySealClubbingClub()) return 0;
	
	return 5-to_int(get_property("_clubEmBattlefieldUsed"));
}

int auto_clubEmIntoNextWeeksRemaining()
{
	if (!auto_haveLegendarySealClubbingClub()) return 0;
	
	return 5-to_int(get_property("_clubEmNextWeekUsed"));
}

boolean wantToClubEmBackInTime(location loc, monster enemy)
{
	// returns true if we want to use Club Em Back In Time, based off wantToThrowGravel

	if (auto_clubEmBackInTimesRemaining()==0) return false;

	if (isFreeMonster(enemy, loc)) { return false; } // don't use free kills against inherently free fights

	if(can_interact()) return false;
	
	return auto_wantToFreeKillWithNoDrops(loc, enemy);
}
