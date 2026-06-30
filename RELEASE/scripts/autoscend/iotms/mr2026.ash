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

boolean auto_spadeDigItem()
{
	item SPADE = $item[Archaeologist's Spade];
	int choice_adv_num = 1596;
	int choice_num = 1;
	string choice_url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
	string use_url = "inv_use.php?pwd&which=3&whichitem="+SPADE.id;
	
	int n_digs = auto_spadeDigsRemaining();
	if (n_digs > 0)
	{
		visit_url(use_url);
		buffer result = visit_url(choice_url);
		int[item] drops = extract_items(result);
		item my_drop = $item[none];
		int total_items_dropped = 0;
		foreach it,n in drops
		{
			my_drop = it;
			total_items_dropped += n;
		}
		if (total_items_dropped!=1)
		{
			auto_log_error("Seem to have got "+total_items_dropped+" from spade dig nearby, expecting 1.");
			handleTracker(SPADE, my_location(), "Dig up something nearby reported "+total_items_dropped+" drops", "auto_otherstuff");
			return total_items_dropped != 0;
		}
		if (n_digs > auto_spadeDigsRemaining()) // check we actually have fewer digs left now before returning
		{
			handleTracker(SPADE, "Dig up something nearby - "+my_location(), my_drop, "auto_otherstuff");
			return true;
		}
		handleTracker(SPADE, "FAILED: Dig up something nearby", "auto_otherstuff");
	}
	return false;
}

boolean auto_spadeDigAncient()
{
	item SPADE = $item[Archaeologist's Spade];
	int choice_adv_num = 1596;
	int choice_num = 2;
	string choice_url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
	string use_url = "inv_use.php?pwd&which=3&whichitem="+SPADE.id;
	int n_digs = auto_spadeDigsRemaining();
	if (n_digs > 0)
	{
		visit_url(use_url);
		visit_url(choice_url);
		if (n_digs > auto_spadeDigsRemaining()) // check we actually have fewer digs left now before returning
		{
			handleTracker(SPADE, "Dig up something ancient", "auto_otherstuff");
			return true;
		}
	}
	return false;
}

boolean auto_spadeDigSkeleton()
{
	item SPADE = $item[Archaeologist's Spade];
	int choice_adv_num = 1596;
	int choice_num = 3;
	string choice_url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
	string use_url = "inv_use.php?pwd&which=3&whichitem="+SPADE.id;
	
	int n_digs = auto_spadeDigsRemaining();
	if (n_digs > 0)
	{
		string[int] pages;
		pages[0] = use_url;
		pages[1] = choice_url;
		location loc = my_location();
		if (autoAdvBypass(0, pages, $location[Noob Cave], "")){
			handleTracker(SPADE, "Dig up a skeleton - "+loc, "auto_otherstuff");
			return true;
		}
		handleTracker(SPADE, "FAILED: Dig up a skeleton", "auto_otherstuff");
	}
	return false;
}

boolean auto_wantToSpadeDigSkeleton(location loc) {
	// haunted kitchen is the only zone that calls auto_spadeDigSkeleton() and does not call this function
	// (because it's the only non-delay zone currently supported)
	boolean valid_loc = spadeDelayZones() contains loc;
	boolean have_digs = auto_spadeDigsRemaining() > 0;
	boolean delay_left = zone_delay(loc)._boolean;
	boolean zone_set = get_property("lastAdventure").to_location() == loc;
	if (valid_loc && have_digs && delay_left && zone_set) {
		return true;
	}
	return false;
}

boolean[location] spadeDelayZones() {
	boolean[location] desired_zones;
	desired_zones[$location[The Unquiet Garves]] = true;
	desired_zones[$location[The Haunted Ballroom]] = true;
	return desired_zones;
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

void legendaryNoodlesChoiceHandler() {
	int target_choice;
	// force combats if requested
	if (get_property("auto_forceCombatWithLegendaryNoodles").to_boolean()) { 
			target_choice = 2;
			set_property("auto_forceCombatWithLegendaryNoodles", false);
	}
	// or use a spleen instead of a stomach
	else if (!get_property("_legendaryNoodlesSpleen").to_boolean() && spleen_left() > 0){ target_choice = 1; }
	// take famxp if nothing else
	else { target_choice = 4; }

	// sometimes options 1 and 4 aren't available, so fallback to 5 (double food effects) which always is and shouldn't ever? be detrimental
	if (available_choice_options() contains target_choice) {
		run_choice(target_choice);
	}
	else {run_choice(5);}
}