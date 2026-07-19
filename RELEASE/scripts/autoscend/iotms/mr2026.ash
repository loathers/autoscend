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

boolean auto_havePastaWand()
{
	if(auto_is_valid($item[legendary pasta wand]) && available_amount($item[legendary pasta wand]) > 0 ) {
		return true;
	}
	return false;
}

// keys are the legendary dishes, values are their respective base dishes
item[item] legendaryNoodleDishes() {
	item[item] dishes;
	dishes[$item[Tubetto Gelatto]] = $item[tomb aspic];
	dishes[$item[Formica e Pepe]] = $item[hot honey ant];
	dishes[$item[Gnocci Domani]] = $item[later tots];
	dishes[$item[Linguini Ubriacapa]] = $item[sauced mutton];
	dishes[$item[Pasta Grimavera]] = $item[haunted crudit&eacute;s];
	dishes[$item[Orzo di Riso]] = $item[spicy onigiri];
	dishes[$item[Arrattabbattabiata]] = $item[ratbatatouille];
	dishes[$item[Pesto alla Marziano]] = $item[alien salad];
	dishes[$item[Frutti di Scatoletta]] = $item[can of tuna];
	return dishes;
}

int numPreparedLegendaryNoodleDishes() {
	int num = 0;
	foreach dish in legendaryNoodleDishes(){
		if (canEat(dish)) {
			num += item_amount(dish);
		}
	}
	return num;
}

// pick a legendary noodle to consume (or to check that we have one avail. to consume)
item auto_findPreparedLegendaryNoods() {
	foreach it in legendaryNoodleDishes() {
		if (canEat(it) && item_amount(it) > 0) {return it; }
	}
	return $item[none];
}

int numBaseLegendaryNoodleDishes() {
	int num = 0;
	foreach preparedDish in legendaryNoodleDishes(){
		if (canEat(preparedDish)) {
			num += item_amount(legendaryNoodleDishes()[preparedDish]);
		}
	}
	return num;
}

// pick a base noodle to consume, to be crafted into legendary (or to check that we have one avail. to consume)
// returns the legendary dish the noods are crafted into
item auto_findBaseLegendaryNoods() {
	if (item_amount($item[legendary noodles]) < 1) {
		return $item[none];
	}
	foreach it in legendaryNoodleDishes() {
		if (item_amount(legendaryNoodleDishes()[it]) > 0 && canEat(it)) {
			return it;
		}
	}
	return $item[none];
}

boolean canEatSomeLegNoods() {
	// testing Gnocci Domani first because it satisfies all three of the "current" letter-restricted paths (BHY, 11TIHAU, G-lover)
	if (canEat($item[Gnocci Domani])) {return true;}
	// all other paths "currently" must not be able to eat legendary noodles. 57 is Thrifty.
	else if (my_path().id < 58) {return false;}
	// heuristics not good enough here, we need to test each dish
	foreach it in legendaryNoodleDishes() {
		if(canEat(it)) {return true;}
	}
	return false;
}

boolean auto_willEatLegendaryNoodles() {
	// We exclude small because we want to be careful about maximizing the quality of our food when we only have two space, and we exclude plumber because plumber consumption is weird
	// Min adv per full filter is set to four because we don't differentiate between the quality of the noodles when we force-eat them, and the "worst" ones average 4 per full (others are 5)
	return canEatSomeLegNoods() && !get_property("auto_limitConsume").to_boolean() && get_property("auto_consumeMinAdvPerFill").to_float() <= 4.0 && !in_small() && !in_plumber();
}

boolean auto_legendaryNoodlesAvailable() {
	if (stomach_left() < 1 || !auto_willEatLegendaryNoodles()) { return false;}
	if(auto_findPreparedLegendaryNoods() != $item[none]){ return true;}
	if(auto_findBaseLegendaryNoods() != $item[none]){ return true;}
	return false;
}


boolean auto_forceCombatLegendaryNoodles() {
	// we are overriding the normal consumption loop due to the nature of the food's effect (eating when we are ready to force)
	// so we make a ConsumeAction record to record what we want to eat and then feed it into auto_autoConsumeOne()
	// values taken from auto_consume.ash
	int AUTO_ORGAN_STOMACH = 1;
	int AUTO_OBTAIN_NULL  = 100;
	int AUTO_OBTAIN_CRAFT = 101;
	ConsumeAction action;

	// select a dish and then create a record, prioritizing dishes that are already crafted first
	item prospective_dish = auto_findPreparedLegendaryNoods();
	if (prospective_dish != $item[none]) {
		action = new ConsumeAction(prospective_dish, 0, 1, 5, 10, AUTO_ORGAN_STOMACH, AUTO_OBTAIN_NULL);
	}
	else {
		item prospective_dish = auto_findBaseLegendaryNoods();
		if (prospective_dish != $item[none]) {
			action = new ConsumeAction(prospective_dish, 0, 1, 4, 10, AUTO_ORGAN_STOMACH, AUTO_OBTAIN_CRAFT);
		}
		else { return false;}
	}
	
	// we communicate via the pref to the ChoiceHandler below to take the amygdala force-combat option
	set_property("auto_forceCombatWithLegendaryNoodles", true);
	if (auto_autoConsumeOne(action)) {
		return true;
	}
	return false;
}

void legendaryNoodlesChoiceHandler() {
	int target_choice;
	// force combats if requested
	if (get_property("auto_forceCombatWithLegendaryNoodles").to_boolean()) { 
			target_choice = 2;
			set_property("auto_forceCombatWithLegendaryNoodles", false);
	}
	// or use a spleen instead of a stomach
	else if (!get_property("_legendaryNoodlesSpleen").to_boolean() && spleen_left() > 0 && !isActuallyEd()) { 
		target_choice = 1;
	}
	// take famxp if nothing else
	else {
		target_choice = 4;
	}

	// sometimes options 1 and 4 aren't available, so fallback to 5 (double food effects) which always is and shouldn't ever? be detrimental
	if (available_choice_options() contains target_choice) {
		run_choice(target_choice);
	}
	else {run_choice(5);}
}

// currently supported sword options:
// shadow slabs for shadow bricks
// bowling balls
// bridge parts
// evil eyes

boolean auto_haveSwordFam()
{
	if(auto_have_familiar($familiar[Sword of S Words]))
	{
		return true;
	}
	return false;
}

boolean auto_isSworded(location loc) {
	// return true if sword monster is from loc. Used to delay zones.
	monster sword_monster = get_property("swordOfSWordsMonster").to_monster();
	if (sword_monster == $monster[none]) {return false;}
	// even if sword monster is set, we should check that we want its drops
	if (!get_property("auto_preferSwordFam").to_boolean()) {return false;}

	switch (sword_monster) {
		case $monster[spiny skelelton]:
		case $monster[toothy sklelton]:
			if (loc == $location[The Defiled Nook]) {
				return true;
			}
			else {return false;}
		case $monster[pygmy bowler]:
			if (loc == $location[The Hidden Bowling Alley]) {
				return true;
			}
			else {return false;}
		case $monster[smut orc jacker]:
		case $monster[smut orc nailer]:
		case $monster[smut orc pipelayer]:
		case $monster[smut orc screwer]:
			if (loc == $location[The Smut Orc Logging Camp]) {
				return true;
			}
			else {return false;}
	}
	return false;

}

// diff than the one in the mr2023 file because we don't need shadow rift access
int auto_neededShadowBricksSword() {
	int currentBricks = item_amount($item[shadow brick]);
	int bricksUsedToday = get_property("_shadowBricksUsed").to_int();
	boolean slab_is_sword_mon = get_property("swordOfSWordsMonster").to_monster() == $monster[shadow slab];
	// auto_runDayCount can be incorrect, but it's still better to consider it here than not
	// at worst we'll overfarm 13 bricks
	if (my_daycount() < get_property("auto_runDayCount").to_int() && slab_is_sword_mon) {
		return max(0, 26 - currentBricks - bricksUsedToday);
	}
	return max(0, 13 - currentBricks - bricksUsedToday);
}

// returns true if we want to keep the current sworded monster, false if not
boolean auto_wantCurrentSwordMonster(monster speculative_current_mon, boolean in_combat) {
	monster sword_monster;
	if (speculative_current_mon != $monster[none]) {
		sword_monster = speculative_current_mon;
	}
	else {
		sword_monster = get_property("swordOfSWordsMonster").to_monster();
	}

	// not having a set monster is functionally equivalent to being done with the current one
	if (sword_monster == $monster[none]) {return false;}
	int threshold;
	switch (sword_monster) {
		case $monster[shadow slab]:
			if (auto_neededShadowBricksSword() > 0) {
				return true;
			}
			else {return false;}
		case $monster[spiny skelelton]:
		case $monster[toothy sklelton]:
			if (!in_combat) {L7_useEvilEyes();}
			if (get_property("cyrptNookEvilness").to_int() > 13) {
				return true;
			}
			else {return false;}
		case $monster[pygmy bowler]:
			// left hand side of the boolean computes to the number of bowling balls obtained, including ones used already
			if (get_property("hiddenBowlingAlleyProgress").to_int() - 1 + item_amount($item[Bowling Ball]) < 5) {
				return true;
			}
			else {return false;}
		case $monster[smut orc jacker]:
		case $monster[smut orc nailer]:
		case $monster[smut orc pipelayer]:
		case $monster[smut orc screwer]:
			if (internalQuestStatus("questL09Topping") != 0  || (fastenerCount() >= bridgeGoal() && lumberCount() >= bridgeGoal())) {
				return false;
			}
			else {return true;}
	}
	return false;
}

boolean auto_wantCurrentSwordMonster() {
	return auto_wantCurrentSwordMonster($monster[none], false);
}

// called from combat, where we've already intentionally adventured to prep sword
boolean auto_wantToSword(monster enemy, boolean in_combat)  {
	return auto_wantCurrentSwordMonster(enemy, in_combat);
}

boolean auto_wantToSwitchSwordToDifferentSmutOrc() {
	// supporting function for auto_prepSwordOfSwords; we can assume that bridge isn't built yet.
	monster sword_monster = get_property("swordOfSWordsMonster").to_monster();

	// handle case where we have wood sworded
	if (sword_monster == $monster[smut orc jacker] || sword_monster == $monster[smut orc pipelayer]){
		// switch if we have enough wood and we are at least four fasteners short of our goal
		if (lumberCount() >= bridgeGoal() && fastenerCount() + 3 < bridgeGoal()) {
			return true;
		}
		else {
			return false;
		}
	}
	// handle case where we have fasteners sworded
	else if (sword_monster == $monster[smut orc nailer] || sword_monster == $monster[smut orc screwer]){
		// switch if we have enough fasteners and we are at least four lumber short of our goal
		if (fastenerCount() >= bridgeGoal() && lumberCount() + 3 < bridgeGoal()) {
			return true;
		}
		else {
			return false;
		}
	}
	// not swording a smut orc right now. which is fine!
	else { 
		return false;
	}
}

// following function is called from combat
boolean auto_wantToSwitchSwordToDifferentSmutOrc(monster enemy) {
	// check general condition to start with
	if (!auto_wantToSwitchSwordToDifferentSmutOrc()) {return false;}

	// now we need to check that our enemy is actually an "opposite" smut orc
	monster sword_monster = get_property("swordOfSWordsMonster").to_monster();
	switch (enemy) {
		case $monster[smut orc jacker]:
		case $monster[smut orc pipelayer]:
			if (sword_monster == $monster[smut orc nailer] || sword_monster == $monster[smut orc screwer]) {
				return true;
			}
			else {
				return false;
			}
		case $monster[smut orc nailer]:
		case $monster[smut orc screwer]:
			if (sword_monster == $monster[smut orc jacker] || sword_monster == $monster[smut orc pipelayer]) {
				return true;
			}
			else {
				return false;
			}
	}
	return false;

}

// called before doTasks in the main autoscend loop
// returning true restarts the loop (i.e. return true if an adventure was used)
boolean auto_prepSwordOfSWords() {
	familiar sword = $familiar[Sword of S Words];
	// check that using Sword is allowed
	if(!auto_haveSwordFam() || !canChangeToFamiliar(sword)) {
		return false;
	}

	// ========= Managing the Enable/Disable Sword pref ==========
	// don't use sword if we're out of kills
	if (get_property("_swordOfSwordsKills").to_int() >= 100) {
		if (get_property("auto_preferSwordFam").to_boolean()){
			set_property("auto_preferSwordFam", false);
		}
		return false;
	}
	// if we aren't done with the current target, enable sword
	// generally return here, except if we want to change our smut orc target
	else if (auto_wantCurrentSwordMonster()) {
		if (!get_property("auto_preferSwordFam").to_boolean()){
			set_property("auto_preferSwordFam", true);
		}
		if (!auto_wantToSwitchSwordToDifferentSmutOrc()) {
			return false;
		}
	}
	// we don't want kills on our current monster, so disable pref if it's currently enabled
	else if (get_property("auto_preferSwordFam").to_boolean()){
		set_property("auto_preferSwordFam", false);
	}

	// ========= Decide whether it makes sense to prep the Sword ==========
	// skip if we're out of Sword targets
	if (get_property("_swordOfSWordsMonsterChanged").to_int() > 2) {return false;}
	// check that Sword will be selected from the drop familiars; no point in setting it if it won't be used
	// But temporarily set the pref to true first!
	set_property("auto_preferSwordFam", true);
	if (lookupFamiliarDatafile("drop") != sword) {
		set_property("auto_preferSwordFam", false);
		return false;
	}
	set_property("auto_preferSwordFam", false);

	// ========= Pick a location to prep the Sword in, and adventure there ==========
	location target_location = $location[none];
	// prioritize high drops, then use target usefulness as a tiebreaker

	// require that we're missing at least four of either part type before we consider
	if ((fastenerCount() + 3 < bridgeGoal() || lumberCount() + 3 < bridgeGoal()) && zone_isAvailable($location[The Smut Orc Logging Camp])) {
		target_location = $location[The Smut Orc Logging Camp];
	}
	// we check auto_availableBrickRift() becuase we don't want to farm bricks with sword if we can access them from the original IOTM source
	if (auto_availableBrickRift() == $location[none] && canSummonMonster($monster[shadow slab]) && auto_neededShadowBricksSword() > 2) {
		// represents "not a standard location", which works because this the only supported nonstandard target
		target_location = $location[Noob Cave];
	}
	if (get_property("hiddenBowlingAlleyProgress").to_int() - 1 + item_amount($item[Bowling Ball]) < 2 && zone_isAvailable($location[The Hidden Bowling Alley])) {
		target_location = $location[The Hidden Bowling Alley];
	}
	if (get_property("cyrptNookEvilness").to_int() > 13 && zone_isAvailable($location[The Defiled Nook])) {
		target_location = $location[The Defiled Nook];
	}

	if (target_location != $location[none]){
		handleFamiliar($familiar[Sword of S Words]);
		boolean adv_success;
		if (target_location == $location[Noob Cave]) {
			adv_success = summonMonster($monster[shadow slab]);
		}
		else {
			adv_success = autoAdv(1, target_location);
		}
		if (auto_wantCurrentSwordMonster()) {
			set_property("auto_preferSwordFam", true);
		}
		return adv_success;
	} 
	
	return false;
}

// called in the choose familiar function to disable S Word if it might override monster drops
// normally item familiars will be chosen instead of drop familiars when items matter, but sometimes not (YRs, 100% drops like LFM)
void auto_disableSwordOfSWords(location loc) {
	if (!auto_haveSwordFam() || !get_property("auto_preferSwordFam").to_boolean()) {return;}

	// generate list of banned locations
	boolean[location] list;
	list[$location[Sonofa Beach]] = true;
	list[$location[An Overgrown Shrine (Southwest)]] = true;
	list[$location[An Overgrown Shrine (Southeast)]] = true;
	list[$location[An Overgrown Shrine (Northwest)]] = true;
	list[$location[An Overgrown Shrine (Northeast)]] = true;
	list[$location[A Massive Ziggurat]] = true;
	// we want some gauze garters, and we need item drops for that
	if (get_property("hippiesDefeated").to_int() > 500) {
		list[$location[The Battlefield (Frat Uniform)]] = true;
	}
	if (get_property("fratboysDefeated").to_int() > 500) {
		list[$location[The Battlefield (Hippy Uniform)]] = true;
	}
	if (list contains loc) {
		set_property("auto_preferSwordFam", false);
	}
}
