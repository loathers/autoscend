# This is meant for items that have a date of 2020

boolean auto_haveBirdADayCalendar() {
	return (item_amount($item[Bird-a-Day calendar]) > 0 && auto_is_valid($item[Bird-a-Day calendar]));
}

boolean auto_birdOfTheDay() {
	if (auto_haveBirdADayCalendar() && get_property("_birdOfTheDay") == "") {
		auto_log_info("What a beautiful morning! What's today's bird?");
		return use(1, $item[Bird-a-Day calendar]);
	}
	return false;
}

boolean auto_birdIsValid()
{
	// can't seek a bird if you can't use or don't own the calendar
	if (!auto_haveBirdADayCalendar()) {
		return false;
	}

	// don't want to overwrite favorite bird automatically
	// however, if they already overwrote favorite bird manually today
	// and we somehow have enough mp to continue casting
	// it might as well be an option
	// hence == 0 and not <= 0
	if(auto_birdsLeftToday() == 0)
	{
		return false;
	}

	if(!get_property("_canSeekBirds").to_boolean())
	{
		use(1, $item[Bird-a-Day calendar]);
	}

	return true;
}

float auto_birdModifier(string mod)
{
	if(!auto_birdIsValid())
	{
		return 0;
	}

	return numeric_modifier($effect[Blessing of the Bird], mod);
}

float auto_favoriteBirdModifier(string mod)
{
	return numeric_modifier($effect[Blessing of Your Favorite Bird], mod);
}

int auto_birdsSought()
{
	return get_property("_birdsSoughtToday").to_int();
}

int auto_birdsLeftToday()
{
	return 6 - auto_birdsSought();
}

boolean auto_birdCanSeek()
{
	if(!auto_birdIsValid())
	{
		return false;
	}

	return auto_have_skill($skill[Seek Out a Bird]);
}

boolean auto_favoriteBirdCanSeek()
{
	// can't seek out your favorite if you already did today
	if(get_property("_favoriteBirdVisited").to_boolean())
	{
		return false;
	}

	return auto_have_skill($skill[Visit Your Favorite Bird]);
}

boolean auto_hasPowerfulGlove()
{
	return possessEquipment($item[Powerful Glove]) && 
		auto_is_valid($item[mint-in-box Powerful Glove]);
}

int auto_powerfulGloveCharges()
{
	if (!auto_hasPowerfulGlove()) return 0;
	return 100 - get_property("_powerfulGloveBatteryPowerUsed").to_int();
}

boolean auto_powerfulGloveNoncombatSkill(skill sk)
{
	if (!auto_hasPowerfulGlove()) return false;

	if (auto_powerfulGloveCharges() < 5) return false;

	item old;
	if (!have_equipped($item[Powerful Glove]))
	{
		old = equipped_item($slot[Acc3]);
		equip($slot[Acc3], $item[Powerful Glove]);
	}

	boolean ret = use_skill(1, sk);

	if (old != $item[none])
	{
		equip($slot[Acc3], old);
	}

	if (ret)
	{
		handleTracker(sk, "auto_powerfulglove");
	}
	else
	{
		// if we fail to cast a skill, odds are something has gone wrong with
		// mafia's tracking. Let's check to make sure, then make sure we stop
		// attempting to use more cheats in vain if so.
		string page = visit_url("desc_item.php?whichitem=991142661");
		if(page.contains_text("The Glove's battery is fully depleted."))
		{
			auto_log_error("Mafia's Powerful Glove battery tracking was wrong, correcting.");
			set_property("_powerfulGloveBatteryPowerUsed", 100);
		}
	}

	return ret;
}

// Returns if replaces are available, optionally only if the Powerful Glove is equipped
int auto_powerfulGloveReplacesAvailable(boolean inCombat)
{
	if (!auto_hasPowerfulGlove()) return 0;

	if (inCombat && !have_equipped($item[Powerful Glove])) return 0;

	return (auto_powerfulGloveCharges() / 10).to_int();
}

// Returns if replaces are available if the Powerful Glove was equipped
int auto_powerfulGloveReplacesAvailable()
{
	return auto_powerfulGloveReplacesAvailable(false);
}

boolean auto_powerfulGloveNoncombat()
{
	if (0 < have_effect($effect[Invisible Avatar])) return false;

	return auto_powerfulGloveNoncombatSkill($skill[CHEAT CODE: Invisible Avatar]);
}

boolean auto_powerfulGloveStats()
{
	return auto_powerfulGloveNoncombatSkill($skill[CHEAT CODE: Triple Size]);
}

boolean auto_wantToEquipPowerfulGlove()
{
	if (!auto_hasPowerfulGlove()) return false;

	if (in_zelda() && !zelda_nothingToBuy()) return true;

	int pixels = whitePixelCount();
	if (contains_text(get_property("nsTowerDoorKeysUsed"), "digital key"))
	{
		pixels += 30;
	}

	return pixels < 30;
}

boolean auto_willEquipPowerfulGlove()
{
	foreach s in $slots[acc1, acc2, acc3]
	{
		string pref = getMaximizeSlotPref(s);
		string toEquip = get_property(pref);
		if(toEquip == $item[Powerful Glove])
		{
			return true;
		}
	}

	return false;
}

boolean auto_forceEquipPowerfulGlove()
{
	if (!auto_hasPowerfulGlove()) return false;

	if(auto_willEquipPowerfulGlove())
	{
		return true;
	}

	return autoEquip($slot[acc3], $item[Powerful Glove]);
}

void auto_burnPowerfulGloveCharges()
{
	while (auto_hasPowerfulGlove() && auto_powerfulGloveCharges() >= 5)
	{
		auto_powerfulGloveStats();
	}
}

boolean auto_canFightPiranhaPlant() {
	int numMushroomFights = (in_zelda() ? 5 : 1);
	if (auto_is_valid($item[packet of mushroom spores]) &&
			get_campground() contains $item[packet of mushroom spores] &&
			get_property("_mushroomGardenFights").to_int() < numMushroomFights) {
		return true;
	}
	return false;
}

boolean auto_canTendMushroomGarden() {
	if (auto_is_valid($item[packet of mushroom spores]) &&
			get_campground() contains $item[packet of mushroom spores] &&
			!get_property("_mushroomGardenVisited").to_boolean()) {
		return true;
	}
	return false;
}

int auto_piranhaPlantFightsRemaining() {
	if (auto_canFightPiranhaPlant()) {
		int numMushroomFights = (in_zelda() ? 5 : 1);
		return (numMushroomFights - get_property("_mushroomGardenFights").to_int());
	}
	return 0;
}

boolean auto_mushroomGardenHandler() {
	if (auto_piranhaPlantFightsRemaining() > 0) {
		return autoAdv($location[Your Mushroom Garden]);
	} else if (auto_canTendMushroomGarden()) {
		autoAdv($location[Your Mushroom Garden]);
		// TODO: Malibu Stacey - move all this to a more central location after refactor
		use(item_amount($item[colossal free-range mushroom]), $item[colossal free-range mushroom]);
		use(item_amount($item[immense free-range mushroom]), $item[immense free-range mushroom]);
		use(item_amount($item[giant free-range mushroom]), $item[giant free-range mushroom]);
		use(item_amount($item[bulky free-range mushroom]), $item[bulky free-range mushroom]);
		use(item_amount($item[plump free-range mushroom]), $item[plump free-range mushroom]);
		use(item_amount($item[free-range mushroom]), $item[free-range mushroom]);
		return true;
	}
	return false;
}

boolean auto_getGuzzlrCocktailSet() {
	if (possessEquipment($item[Guzzlr tablet]) && auto_is_valid($item[Guzzlr tablet])) {
		if (get_property("guzzlrGoldDeliveries").to_int() >= 5
		&& get_property("questGuzzlr") == "unstarted"
		&& get_property("_guzzlrPlatinumDeliveries").to_int() == 0
		&& !get_property("_guzzlrQuestAbandoned").to_boolean()) {
			auto_log_info("Getting a Guzzlr Cocktail Set (for all the good it will do).");
			visit_url("inventory.php?tap=guzzlr", false);
			run_choice(4); // take platinum quest
			wait(1); // mafia's tracking breaks occasionally if you go too fast.
			visit_url("inventory.php?tap=guzzlr", false);
			run_choice(1); // abandon
			run_choice(5); // leave the choice.
			return true; // ponder on what else you could've spent the Mr. Accessory on instead.
		}
	}
	return false;
}

boolean auto_latheHardwood(item toLathe)
{
	// can't lathe if lathe is out of standard (or otherwise unusable)
	if(!auto_is_valid($item[SpinMaster&trade; lathe]))
		return false;

	// can't lathe... without a lathe
	if(item_amount($item[SpinMaster&trade; lathe]) < 1)
		return false;

	// if breakfast hasn't run and you haven't grabbed it manually, we won't
	// see the scrap if we don't go grab it ourself. So do that, if needed.
	if(!get_property("_spinmasterLatheVisited").to_boolean())
		visit_url("shop.php?whichshop=lathe");

	// can't lathe without hardwood
	if(item_amount($item[flimsy hardwood scraps]) < 1)
		return false;

	// can't lathe things that aren't made of hardwood
	if(!($items[
		beechwood blowgun,
		birch battery,
		ebony epee,
		maple magnet,
		weeping willow wand,
	] contains toLathe))
		return false;

	return buy($coinmaster[Your SpinMaster&trade; lathe], 1, toLathe);
}

boolean auto_latheAppropriateWeapon()
{
	item toLathe;

	switch(my_primestat())
	{
		case $stat[Muscle]:
			toLathe = $item[ebony epee];
			break;
		case $stat[Mysticality]:
			toLathe = $item[weeping willow wand];
			break;
		case $stat[Moxie]:
			toLathe = $item[beechwood blowgun];
			break;
	}

	switch(my_class())
	{
		// autoscend likes Plumber to go for moxie, so let's make sure it
		// does even if another stat is ahead at the start of the day.
		case $class[Plumber]:
			toLathe = $item[beechwood blowgun];
			break;
		// If any future classes also have a variable mainstat, specify the desired item here
	}

	// don't want to accidentally use a second scrap in casual or something
	if(possessEquipment(toLathe))
		return false;

	return auto_latheHardwood(toLathe);
}

boolean auto_hasCargoShorts()
{
	return possessEquipment($item[Cargo Cultist Shorts]) && 
		auto_is_valid($item[Bagged Cargo Cultist Shorts]);
}

int auto_cargoShortsGetPocket(item i)
{
	// Until mafia tracks these
	switch (i)
	{
		case $item[Yeg's Motel mouthwash]: return 26;
		case $item[Yeg's Motel shower cap]: return 84;
		case $item[Yeg's Motel alarm clock]: return 121;
		case $item[Yeg's Motel stationery]: return 130;
		case $item[Yeg's Motel slippers]: return 132;
		case $item[Yeg's Motel hand soap]: return 177;
		case $item[Yeg's Motel bathrobe]: return 218;
		case $item[Yeg's Motel toothbrush]: return 284;
		case $item[Yeg's Motel disposable razor]: return 322;
		case $item[flask of moonshine]: return 324;
		case $item[Yeg's Motel ashtray]: return 409;
		case $item[Yeg's Motel pillow mint]: return 439;
		case $item[sizzling desk bell]: return 517;
		case $item[greasy desk bell]: return 533;
		case $item[frost-rimed desk bell]: return 587;
		case $item[uncanny desk bell]: return 590;
		case $item[Yeg's Motel Sewing Kit]: return 642;
		case $item[nasty desk bell]: return 653;
		case $item[Yeg's Motel minibar key]: return 660;

		// Chess
		case $item[alabaster pawn]: return 46;
		case $item[onyx pawn]: return 105;
		case $item[alabaster rook]: return 111;
		case $item[onyx rook]: return 197;
		case $item[alabaster knight]: return 275;
		case $item[onyx knight]: return 4;
		case $item[alabaster king]: return 523;
		case $item[onyx king]: return 88;
		case $item[alabaster bishop]: return 567;
		case $item[onyx bishop]: return 537;
		case $item[alabaster queen]: return 651;
		case $item[onyx queen]: return 506;

		// Other
		case $item[cursed piece of thirteen]: return 600;
	}
	return -1;
}

int auto_cargoShortsGetPocket(monster m)
{
	// Until mafia tracks these
	switch (m)
	{
		case $monster[bookbat]: return 30;
		case $monster[dairy goat]: return 47;
		case $monster[Knob Goblin Elite Guardsman]: return 136;
		case $monster[dirty old lihc]: return 143;
		case $monster[batrat]: return 191;
		case $monster[Lobsterfrogman]: return 220;
		case $monster[modern zmobie]: return 235;
		case $monster[blooper]: return 250;
		case $monster[creepy clown]: return 267;
		case $monster[Knob Goblin Harem Girl]: return 299;
		case $monster[big creepy spider]: return 306;
		case $monster[camel's toe]: return 317;
		case $monster[Pufferfish]: return 363;
		case $monster[skinflute]: return 383;
		case $monster[fruit golem]: return 402;
		case $monster[eXtreme Orcish snowboarder]: return 425;
		case $monster[Mob Penguin Thug]: return 428;
		case $monster[War Hippy (space) cadet]: return 443;
		case $monster[completely different spider]: return 448;
		case $monster[pygmy shaman]: return 452;
		case $monster[booze giant]: return 490;
		case $monster[mountain man]: return 565;
		case $monster[War Pledge]: return 568;
		case $monster[Green Ops Soldier]: return 589;
		case $monster[1335 HaXx0r]: return 646;
		case $monster[smut orc pervert]: return 666;
	}
	return -1;
}

int auto_cargoShortsGetPocket(effect e)
{
	// Until mafia tracks these
	switch (e)
	{
		case $effect[Ode to Booze]: return 242;
		case $effect[Night Vision]: return 339;
		case $effect[Filthworm Drone Stench]: return 343;
		case $effect[Medieval Mage Mayhem]: return 617;
	}
	return -1;
}

boolean auto_cargoShortsCanOpenPocket()
{
	if (!auto_hasCargoShorts())
		return false;
	
	return !get_property("_cargoPocketEmptied").to_boolean();
}

boolean auto_cargoShortsCanOpenPocket(int pocket)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;
	
	if (pocket <= 0 || pocket > 666)
		return false;

	foreach key,value in get_property("cargoPocketsEmptied").split_string(",")
	{
		if (value.to_int() == pocket)
			return false;
	}
	
	return true;
}

boolean auto_cargoShortsCanOpenPocket(item i)
{
	return auto_cargoShortsCanOpenPocket(auto_cargoShortsGetPocket(i));
}

boolean auto_cargoShortsCanOpenPocket(monster m)
{
	return auto_cargoShortsCanOpenPocket(auto_cargoShortsGetPocket(m));
}

boolean auto_cargoShortsCanOpenPocket(effect e)
{
	return auto_cargoShortsCanOpenPocket(auto_cargoShortsGetPocket(e));
}

boolean auto_cargoShortsOpenPocket(int pocket)
{
	if (!auto_cargoShortsCanOpenPocket(pocket))
		return false;
	
	cli_execute("try; cargo " + pocket);
	if (get_property("_cargoPocketEmptied").to_boolean())
	{
		return true;
	}
	return false;
}

boolean auto_cargoShortsOpenPocket(item i)
{
	return auto_cargoShortsOpenPocket(auto_cargoShortsGetPocket(i));
}

boolean auto_cargoShortsOpenPocket(monster m)
{
	return auto_cargoShortsOpenPocket(auto_cargoShortsGetPocket(m));
}

boolean auto_cargoShortsOpenPocket(effect e)
{
	return auto_cargoShortsOpenPocket(auto_cargoShortsGetPocket(e));
}
