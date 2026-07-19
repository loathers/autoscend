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

boolean auto_haveCupOf13s() {
	if(auto_is_valid($item[Cup of 13s]) && available_amount($item[Cup of 13s]) > 0 ) {
		return true;
	}
	return false;
}

item[int] auto_pickCupOf13sIngredients() {
	item spoon = $item[spoon];
	item spoon_alt;
	// deciding on which other item we want if spoon isn't available
	// these items partially come from the meatsmith, but that follows armory and leggery restrictions
	if (knoll_available() && isHermitAvailable() && isArmoryAndLeggeryStoreAvailable() && my_meat() > 7200) {
		spoon_alt = $item[dripping meat staff];
	}
	else if (my_meat() > 12200 && have_skill($skill[Armorcraftiness]) && isArmoryAndLeggeryStoreAvailable()) {
		spoon_alt = $item[meat shield];
	}
	else {spoon_alt = $item[none];}

	// summon spoons if possible
	while (item_amount($item[spoon]) < 3 && canUse($skill[Generate Irony]) && my_mp() > 30) {
		useSkill($skill[Generate Irony]);
	}

	item[int] cup_ingredients;
	for x from 1 to 3 {
		if (item_amount(spoon) >= x) {
			cup_ingredients[x] = spoon;
		}
		else {
			cup_ingredients[x] = spoon_alt;
		}
	}
	return cup_ingredients;
}

// answers the question of "are supported ingredients available"
boolean auto_canMakeCupOf13sDrink() {
	if (!auto_haveCupOf13s() || in_small()) {return false;} // taken from irrat's fork, using just in case we don't get 10x adv in small
	item[int] tentative_ingredients = auto_pickCupOf13sIngredients();
	if (tentative_ingredients[3] == $item[none]) {
		return false;
	}
	return true;
}

float auto_CupOf13sDesirability() {
	item[int] tentative_ingredients = auto_pickCupOf13sIngredients();
	float net_adv_gain = 12.0;
	for x from 1 to 3 {
		if (tentative_ingredients[x] == $item[meat shield] && (free_crafts() - x < 1)) {
			net_adv_gain -= 1;
		}
		else if (tentative_ingredients[x] == $item[meat shield]) {
			// valuing free crafts at 0.5 adv
			net_adv_gain -= 0.5;
		}
	}
	return net_adv_gain;
}

boolean auto_acquireCupOf13sIngredients(item[int] ingredients) {
	// get spoon count
	int spoon_count = 0;
	for x from 1 to 3 {
		if (ingredients[x] == $item[spoon]) {
			spoon_count += 1;
		}
	}
	// make sure we have enough. Spoons are gotten elsewhere.
	if (item_amount($item[spoon]) < spoon_count) {
		return false;
	}
	// if we're only using spoons for our drink, we don't need to get any other ingredients
	if (spoon_count > 2) {
		return true;
	}

	// alt as in alternative to spoon (not that we expect spoon-having)
	item alt = ingredients[3];
	int alt_count = 3 - spoon_count;
	if (alt == $item[meat shield]) {
		return (
			auto_buyUpTo(alt_count, $item[buckler buckle]) &&
			cli_execute(`make {alt_count} dense meat stack`) &&
			autoCraft("smith", alt_count, $item[buckler buckle], $item[dense meat stack]) >= alt_count
		);
	}
	else if (alt == $item[dripping meat staff]) {
		return (
			auto_buyUpTo(alt_count, $item[big stick]) &&
			cli_execute(`make {alt_count} meat stack`) &&
			auto_hermit(alt_count, $item[ketchup]) &&
			autoCraft("smith", alt_count, $item[big stick], $item[meat stack]) >= alt_count &&
			autoCraft("smith", alt_count, $item[basic meat staff], $item[ketchup]) >= alt_count
		);
	}
	else {return false;}
}

boolean consumeCupOf13s() {
	item[int] ing = auto_pickCupOf13sIngredients();
	auto_log_info(`Consuming a delicious drink of {ing[1]}, {ing[2]}, and {ing[3]} from our Cup of 13s.`);
	if (!auto_acquireCupOf13sIngredients(ing)) {return false;}
	int advs = my_adventures();
	string url1 = `inventory.php?pwd=${my_hash()}&action=cupof13s`;
	string url2 = `choice.php?pwd={my_hash()}&whichchoice=1601&option=1`;
	string url3 = `&whichitem1={to_int(ing[1])}&whichitem2={to_int(ing[2])}&whichitem3={to_int(ing[3])}`;
  	visit_url(url1);
  	visit_url(url2 + url3);

  	if (advs == my_adventures()) {
    	visit_url("main.php");
		cli_execute("refresh inventory");
		return false;
	}
	return true;
}