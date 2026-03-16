# This is meant for items that have a date of 2026

boolean auto_haveEternityCodpiece()
{
	if(auto_is_valid($item[the eternity codpiece]) && available_amount($item[the eternity codpiece]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_isInEternityCodpiece(item it)
{
	foreach s,b in $slots[codpiece1,codpiece2,codpiece3,codpiece4,codpiece5]
	{
		if (equipped_item(s)==it)
		{
			return true;
		}
	}
	return false;
}

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

boolean auto_haveHeartstone()
{
	if(!auto_is_valid($item[heartstone]))
	{
		return false;
	}
	if (available_amount($item[heartstone]) > 0 )
	{
		return true;
	}
	if (auto_isInEternityCodpiece($item[heartstone]))
	{
		return true;
	}
	return false;
}

int auto_heartstoneBanishRemaining()
{
	if (!auto_haveHeartstone()) return 0;
	if (get_property("heartstoneBanishUnlocked") != "true") return 0;
	
	return 5-to_int(get_property("_heartstoneBanishUsed"));
}

int auto_heartstoneBuffsRemaining()
{
	if (!auto_haveHeartstone()) return 0;
	if (get_property("heartstoneBuffUnlocked") != "true") return 0;
	
	return 5-to_int(get_property("_heartstoneBuffUsed"));
}

int auto_heartstoneKillRemaining()
{
	if (!auto_haveHeartstone()) return 0;
	if (get_property("heartstoneKillUnlocked") != "true") return 0;
	
	return 5-to_int(get_property("_heartstoneKillUsed"));
}

int auto_heartstoneLuckRemaining()
{
	if (!auto_haveHeartstone()) return 0;
	if (get_property("heartstoneLuckUnlocked") != "true") return 0;
	
	if (to_boolean(get_property("_heartstoneLuckUsed")))
	{
		return 0;
	}
	return 1;
}

int auto_heartstonePalsRemaining()
{
	if (!auto_haveHeartstone()) return 0;
	if (get_property("heartstonePalsUnlocked") != "true") return 0;
	
	return 5-to_int(get_property("_heartstonePalsUsed"));
}

int auto_heartstoneStunRemaining()
{
	if (!auto_haveHeartstone()) return 0;
	if (get_property("heartstoneStunUnlocked") != "true") return 0;
	
	return 5-to_int(get_property("_heartstoneStunUsed"));
}

boolean auto_haveArchaeologistSpade()
{
	if(auto_is_valid($item[Archaeologist's Spade]) && available_amount($item[Archaeologist's Spade]) > 0 )
	{
		return true;
	}
	return false;
}

int auto_spadeDigsRemaining()
{
	if (!auto_haveArchaeologistSpade()) { return 0;}
	
	return 11-to_int(get_property("_archSpadeDigs"));
}

boolean auto_spadeDigAncient()
{
	int choice_adv_num = 1596;
	int choice_num = 2;
	string choice_url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
	string use_url = "inv_use.php?pwd&which=3&whichitem="+$item[Archaeologist's Spade].id;
	int n_digs = auto_spadeDigsRemaining();
	if (n_digs > 0)
	{
		visit_url(use_url);
		visit_url(choice_url);
		if (n_digs > auto_spadeDigsRemaining()) // check we actually have fewer digs left now before returning
		{
			return true;
		}
	}
	return false;
}

boolean auto_burnRemainingSpadeDigs()
{
	int n_digs = auto_spadeDigsRemaining();
	for (int ii = 0 ; ii < n_digs ; ii++)
	{
		auto_spadeDigAncient();
	}
	return auto_spadeDigsRemaining()==0;
}
