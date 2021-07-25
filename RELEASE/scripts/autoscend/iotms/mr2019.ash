# This is meant for items that have a date of 2019

int auto_sausageEaten()
{
	return get_property("_sausagesEaten").to_int();
}

int auto_sausageLeftToday()
{
	return 23 - auto_sausageEaten();
}

int auto_sausageUnitsNeededForSausage(int numSaus)
{
	return 111 * numSaus;
}

int auto_sausageMeatPasteNeededForSausage(int numSaus)
{
	return ceil(auto_sausageUnitsNeededForSausage(numSaus).to_float() / 10.0);
}

int auto_sausageFightsToday()
{
	return get_property("_sausageFights").to_int();
}

boolean auto_sausageBlocked()
{
	if(in_tcrs())
	{
		return true;
	}

	if(!canEat($item[magical sausage]))
	{
		return true;
	}
	
	if (get_property("auto_saveMagicalSausage").to_boolean())
	{
		return true;
	}
	
	if (auto_sausageLeftToday() <= 0)
	{
		return true;
	}
	
	if (stomach_left() < 0)	//can still be eaten with == 0
	{
		return true;
	}
	
	return false;
}

boolean auto_sausageWanted()
{
	if (auto_sausageBlocked())
	{
		return false;
	}
	
	// if adventures not needed yet, leave most sausages to acquireMP()
	if (my_adventures() > 10)
	{
		// only grind up to one per level in reserve instead of always grinding all the meat that isn't nailed down
		auto_sausageGrind(my_level() - get_property("_sausagesMade").to_int());
		// it would be a good idea to eat one early on for MP but 2-3 things currently don't allow it:
		// auto_sausageGrind wants 90 turncount and desert unlocked, acquireMP() wants it to restore at least 300 MP
		return false;
	}
	
	// grind and eat sausages once adventures are needed, progressively with eating or drinking to keep a steady source of MP
	
	if (auto_sausageLeftToday() <= 0)
	{
		return false;
	}
	
	int sausageMade = get_property("_sausagesMade").to_int();
	int sausageForBreakfast;	// estimate up to how many sausages before drinks and food?
	int totalSausageEstimated;	// estimate up to how many sausages by the time liver and stomach will be full?
	
	// are there more casings from previous days or copied goblins?
	int extraCasings = item_amount($item[magical sausage casing]) + sausageMade - auto_sausageFightsToday();

	if (my_daycount() == 1)
	{
		// by the time turn 90 allows grinding now, organs will not be empty and more sausages may be eaten anyways
		sausageForBreakfast = 1;
		totalSausageEstimated = max(9, sausageMade);
	}
	else
	{
		sausageForBreakfast = 6;
		// are there more sausages left from previous days?
		int extraSausage = item_amount($item[magical sausage]) + auto_sausageEaten() - sausageMade;
		totalSausageEstimated = min(23, 13 + extraCasings + extraSausage);
		totalSausageEstimated = max(totalSausageEstimated, sausageMade);
	}
	
	// if expectations for today have already been reached lift them
	if (auto_sausageEaten() >= totalSausageEstimated)	totalSausageEstimated = 23;
	
	// sausage consumption progresses with eating or drinking
	float progress = consumptionProgress();
	int totalSausageToEat = ceil(progress * (totalSausageEstimated - sausageForBreakfast)) + sausageForBreakfast;
	
	// a reserve is kept for MP restoration
	boolean noMP = my_class() == $class[Vampyre];
	int sausage_reserve_size = noMP ? 0 : 3;
	
	// no more reserve when close to full or when completely out of adventures
	if (progress > 0.90)		sausage_reserve_size = 2;
	if (progress > 0.95)		sausage_reserve_size = 1;
	if (my_adventures() == 0)	sausage_reserve_size = 0;
	
	// the reserve also needs to be planned inside the daily limit
	totalSausageToEat = min(totalSausageToEat, 23 - sausage_reserve_size);
	
	// try to grind up to the reserve on top of what we want to eat
	int totalSausageToGrind = totalSausageToEat + sausage_reserve_size;
	int sausageToGrind = min(23,totalSausageToGrind) - sausageMade;
	
	auto_sausageGrind(sausageToGrind);
	
	// eat if there is enough after grinding to respect the reserve
	int sausageToEat = totalSausageToEat - auto_sausageEaten();
	int sausageAvailable = item_amount($item[magical sausage]) - sausage_reserve_size;
	sausageToEat = min(sausageToEat, sausageAvailable);
	
	if (sausageToEat > 0)
	{
		return auto_sausageEatEmUp(sausageToEat);
	}
	
	return false;
}

boolean auto_sausageGrind(int numSaus)
{
	return auto_sausageGrind(numSaus, false);
}

boolean auto_sausageGrind(int numSaus, boolean failIfCantMakeAll)
{
	// Some paths are pretty meat-intensive early. Just in case...
	if(my_turncount() < 90 || !isDesertAvailable())
	{
		return false;
	}

	if(in_tcrs()) return false;

	int casingsOwned = item_amount($item[magical sausage casing]);

	if(casingsOwned == 0)
		return false;
		
	//it is actually possible to have a casing but not have the kramco grinder
	if(!possessEquipment($item[Kramco Sausage-o-Matic&trade;]))
	{
		return false;
	}

	if(numSaus <= 0)
		return false;

	if(casingsOwned < numSaus)
	{
		if(failIfCantMakeAll)
		{
			return false;
		}
		numSaus = casingsOwned;
	}

	int sausMade = get_property("_sausagesMade").to_int();
	int pastesNeeded = 0;
	int pastesAvail = item_amount($item[meat paste]);
	int meatToSave = 1000 + meatReserve();
	if(auto_my_path() == "Community Service")
		meatToSave = 500;
	for i from 1 to numSaus
	{
		int sausNum = i + sausMade;
		int pastesForThisSaus = auto_sausageMeatPasteNeededForSausage(sausNum);
		if((pastesNeeded + pastesForThisSaus - pastesAvail) * 10 + meatToSave > my_meat())
		{
			if(failIfCantMakeAll)
			{
				return false;
			}
			if(i == 1)
			{
				return false;
			}
			numSaus = i - 1;
			break;
		}
		pastesNeeded += pastesForThisSaus;
	}

	auto_log_info("Let's grind some sausage!", "blue");
	if(!create(numSaus, $item[magical sausage]))
	{
		auto_log_warning("Something went wrong while grinding sausage...", "red");
		return false;
	}
	loopHandlerDelayAll();

	return true;
}

boolean auto_sausageEatEmUp(int maxToEat)
{
	if (auto_sausageBlocked())
		return false;

	// sausage_reserve_size is handled in auto_sausageWanted()

	if(item_amount($item[magical sausage]) < 1)
		return false;

	boolean noMP = my_class() == $class[Vampyre];
	int originalMp = my_maxmp();
	if(!noMP)
	{
		auto_log_info("We're gonna slurp up some sausage, let's make sure we have enough max mp", "blue");
		cli_execute("checkpoint");
		maximize("mp,-tie", false);
	}
	// I could optimize this a little more by eating more sausage at once if you have enough max mp...
	// but meh.
	while(maxToEat > 0 && item_amount($item[magical sausage]) > 0)
	{
		if(auto_sausageLeftToday() <= 0)
			break;
		if(!noMP)
		{
			int desiredMp = max(my_maxmp() - 999, 0);
			int mpToBurn = max(my_mp() - desiredMp, 0);
			if(mpToBurn > 0)
				cli_execute("burn " + mpToBurn);
		}

		if(!eat(1, $item[magical sausage]))
		{
			auto_log_warning("Somehow failed to eat a sausage! What??", "red");
			return false;
		}
		handleTracker($item[magical sausage], "auto_eaten");
		maxToEat--;
	}

	// burn any mp that'll go away when equipment switches back
	if(!noMP)
	{
		int mpToBurn = max(my_mp() - originalMp, 0);
		if(mpToBurn > 0)
			cli_execute("burn " + mpToBurn);
		cli_execute("outfit checkpoint");
	}

	return true;
}

boolean auto_sausageEatEmUp() {
	return auto_sausageEatEmUp(0);
}

boolean auto_haveKramcoSausageOMatic() {
	if (possessEquipment($item[Kramco Sausage-o-Matic&trade;]) && auto_can_equip($item[Kramco Sausage-o-Matic&trade;])) {
		return true;
	}
	return false;
}

boolean auto_sausageGoblin()
{
	return auto_sausageGoblin($location[none], "");
}

boolean auto_sausageGoblin(location loc)
{
	return auto_sausageGoblin(loc, "");
}

boolean auto_sausageGoblin(location loc, string option)
{
	// Sausage Goblins have super low encounter priority so they will be overriden
	// by all sorts stuff like superlikelies, wanderers and semi-rares.
	// The good news is, being overridden just means adventure there again to get it

	if(!auto_haveKramcoSausageOMatic())
	{
		return false;
	}

	// Formula = (y+1) / (5+x*3+max(0,x-5)^3)
	// y is turns since the last goblin
	// x is the number of goblins you've already encountered that day.
	// spoilered by The Dictator in ASS Discord #iotm-discussion
	// intervals are therefore 0, 7, 10, 13, 16, 19, 23, 33, 55, 95, 128...
	int sausageFights = get_property("_sausageFights").to_int();
	float numerator = (total_turns_played() - get_property("_lastSausageMonsterTurn").to_float()) + 1.0;
	float denominator = 5.0 + (sausageFights * 3.0) + (max(0.0, sausageFights - 5.0))**3.0;
	if (sausageFights > 0 && (numerator / denominator) < 1.0)
	{
		return false;
	}

	if(loc == $location[none])
	{
		return true;
	}

	autoEquip($item[Kramco Sausage-o-Matic&trade;]);
	return autoAdv(1, loc, option);
}

boolean pirateRealmAvailable()
{
	if(!is_unrestricted($item[PirateRealm membership packet]))
	{
		return false;
	}
	if((get_property("prAlways").to_boolean() || get_property("_prToday").to_boolean()))
	{
		return true;
	}
	return false;
}

boolean LX_unlockPirateRealm()
{
	if(!pirateRealmAvailable())                       return false;
	if(possessEquipment($item[PirateRealm eyepatch])) return false;
	if(my_adventures() < 40)                          return false;

	visit_url("place.php?whichplace=realm_pirate&action=pr_port");
	return true;
}

boolean auto_saberChoice(string choice)
{
	if(!is_unrestricted($item[Fourth of May Cosplay Saber]))
	{
		return false;
	}
	if(!possessEquipment($item[Fourth of May Cosplay Saber]))
	{
		return false;
	}
	if(get_property("_saberMod").to_int() != 0)
	{
		return false;
	}

	int choiceNum = 5; // Maybe Later
	switch(choice)
	{
	case "mp regen":
	case "mp":
		choiceNum = 1;
		break;
	case "ml":
	case "monster level":
		choiceNum = 2;
		break;
	case "res":
	case "resistance":
		choiceNum = 3;
		break;
	case "fam":
	case "fam weight":
	case "familiar weight":
	case "weight":
		choiceNum = 4;
		break;
	}

	string page = visit_url("main.php?action=may4", false);
	page = visit_url("choice.php?pwd=&whichchoice=1386&option=" + choiceNum);
	return true;
}

boolean auto_saberDailyUpgrade(int day)
{
	if (isActuallyEd())
	{
		return auto_saberChoice("mp");
	}

	// Maybe famweight is better, I don't know.
	if (in_zelda())
	{
		return auto_saberChoice("res");
	}
	
	return auto_saberChoice("fam");
}

monster auto_saberCurrentMonster()
{
	if (get_property("_saberForceMonsterCount") == "0")
	{
		return $monster[none];
	}
	return get_property("_saberForceMonster").to_monster();
}

/* Out-of-combat Saber check: doesn't check that it's equipped
 */
int auto_saberChargesAvailable()
{
	if(!is_unrestricted($item[Fourth of May cosplay saber kit]))
	{
		return 0;
	}
	if(!possessEquipment($item[Fourth of May cosplay saber]))
	{
		return 0;
	}
	if(!auto_is_valid($skill[use the force]))
	{
		return 0;		//if the combat skill is not valid it can not be used even if the saber itself is valid
	}
	return (5 - get_property("_saberForceUses").to_int());
}

string auto_combatSaberBanish()
{
	set_property("choiceAdventure1387", 1);
	return "skill " + $skill[Use the Force];
}

string auto_combatSaberCopy()
{
	set_property("choiceAdventure1387", 2);
	return "skill " + $skill[Use the Force];
}

string auto_combatSaberYR()
{
	set_property("choiceAdventure1387", 3);
	return "skill " + $skill[Use the Force];
}

string auto_spoonGetDesiredSign()
{
	string spoonsign = get_property("auto_spoonsign").to_lower_case();

	string statSign(string musc, string myst, string mox)
	{
		switch(my_primestat())
		{
			case $stat[Muscle]:
				return musc;
			case $stat[Mysticality]:
				return myst;
			case $stat[Moxie]:
				return mox;
			default:
				abort("Invalid mainstat, what?");
				return "butts"; // needed or mafia complains about missing return value
		}
	}
	// coerce spoonsign to be one of the nine signs, instead of shorthands
	switch(spoonsign)
	{
		case "knoll":
			return statSign("mongoose", "wallaby", "vole");
		case "canadia":
			return statSign("platypus", "opossum", "marmot");
		case "gnomad":
			return statSign("wombat", "blender", "packrat");
		case "mongoose":
		case "wallaby":
		case "vole":
		case "platypus":
		case "opossum":
		case "marmot":
		case "wombat":
		case "blender":
		case "packrat":
			return spoonsign;
		// a couple extra alternate labels
		case "clover":
			return "marmot";
		case "famweight":
		case "weight":
		case "familiar weight":
		case "familiar":
		case "fam":
			return "platypus";
		case "food":
			return "opossum";
		case "booze":
			return "blender";
		default:
			// spoonsign is invalid or none/false/whatever to say don't do this
			return "";
	}
}

void auto_spoonTuneConfirm()
{
	if(!possessEquipment($item[hewn moon-rune spoon]) || !auto_is_valid($item[hewn moon-rune spoon]))
	{
		// couldn't change signs if we wanted to
		return;
	}

	if(get_property("auto_spoonconfirmed").to_int() == my_ascensions())
	{
		return;
	}

	string spoonsign = auto_spoonGetDesiredSign();
	if(spoonsign == "")
	{
		// the user doesn't want to change signs
		return;
	}

	if(user_confirm("You're currently set to change signs to " + spoonsign + " after wrapping up your business in your current sign. Do you want to interrupt the script to go change that? Will default to 'No' in 15 seconds.", 15000, false))
	{
		abort("Alright, please go change auto_spoonsign via the autoscend relay script and then rerun.");
	}
	else
	{
		set_property("auto_spoonconfirmed", my_ascensions());
	}
}

boolean auto_spoonReadyToTuneMoon()
{
	if(!possessEquipment($item[hewn moon-rune spoon]) || !auto_is_valid($item[hewn moon-rune spoon]))
	{
		// need a valid spoon to change moon signs
		return false;
	}

	string currsign = my_sign().to_lower_case();
	string spoonsign = auto_spoonGetDesiredSign();

	if(spoonsign == "")
	{
		// the user doesn't want to change signs automatically
		return false;
	}

	if(spoonsign == currsign)
	{
		// we'd just be changing to the same sign, so do nothing
		return false;
	}

	boolean toKnoll = $strings[mongoose, wallaby, vole] contains spoonsign;
	boolean toCanadia = $strings[platypus, opossum, marmot] contains spoonsign;
	boolean toGnomad = $strings[wombat, blender, packrat] contains spoonsign;

	if(!toKnoll && !toCanadia && !toGnomad)
	{
		abort("Something weird is going on with auto_spoonsign. It's not an invalid/blank value, but also not a knoll, canadia, or gnomad sign? This is impossible.");
	}

	if(my_sign() == "Vole" && (get_property("cyrptAlcoveEvilness") > 26 || get_property("questL07Cyrptic") == "unstarted"))
	{
		// we want to stay vole long enough to do the alcove, since the initiative helps
		return false;
	}

	if(inKnollSign() && !toKnoll)
	{
		if(get_property("questM01Untinker") != "finished")
		{
			// just finish the untinker quest if we can, it's free.
			visit_url("place.php?whichplace=forestvillage&preaction=screwquest&action=fv_untinker_quest");
			visit_url("place.php?whichplace=knoll_friendly&action=dk_innabox");
			visit_url("place.php?whichplace=forestvillage&action=fv_untinker");
		}
		if(!isDesertAvailable())
		{
			// we want to get the meatcar via the knoll store
			return false;
		}
		if((auto_get_campground() contains $item[Asdon Martin Keyfob]) && is_unrestricted($item[Asdon Martin Keyfob]))
		{
			// we want to get the bugbear outfit before switching away for easy bread access
			if(!buyUpTo(1, $item[bugbear beanie]) || !buyUpTo(1, $item[bugbear bungguard]))
			{
				return false;
			}
		}
	}

	if(inCanadiaSign() && !toCanadia && item_amount($item[logging hatchet]) == 0)
	{
		// want to make sure we've grabbed the logging hatchet before switching away from canadia
		return false;
	}

	if(inGnomeSign() && !toGnomad && auto_is_valid($skill[Torso Awareness]) && !auto_have_skill($skill[Torso Awareness]))
	{
		// we want to know about our torso before swapping away from gnomad signs
		return false;
	}

	if(currsign == "opossum" && my_fullness() == 0)
	{
		// we want to eat something before swapping away from opossum
		return false;
	}

	if(currsign == "blender" && my_inebriety() == 0)
	{
		// we want to drink something before swapping away from blender
		return false;
	}

	return true;
}

boolean auto_spoonTuneMoon()
{
	if(!auto_spoonReadyToTuneMoon())
	{
		return false;
	}

	slot wasspoon = $slot[none];
	foreach sl in $slots[acc1, acc2, acc3]
	{
		if(equipped_item(sl) == $item[hewn moon-rune spoon])
		{
			equip(sl, $item[none]);
			wasspoon = sl;
			break;
		}
	}

	string spoonsign = auto_spoonGetDesiredSign();
	int signnum = 0;
	foreach sign in $strings[mongoose, wallaby, vole, platypus, opossum, marmot, wombat, blender, packrat]
	{
		++signnum;
		if(sign == spoonsign)
		{
			break;
		}
	}

	string res = visit_url('inv_use.php?whichitem=10254&pwd=' + my_hash());
	boolean cantune = (res.index_of("You can't figure out the angle to see the moon's reflection in the spoon anymore.") == -1);
	if(cantune)
	{
		auto_log_info("Changing signs to " + spoonsign + ", sign #" + signnum, "blue");
		visit_url('inv_use.php?whichitem=10254&pwd&doit=96&whichsign=' + signnum, true);
		cli_execute("refresh all");
	}
	else
	{
		auto_log_warning("Tried to change signs to " + spoonsign + ", but moon has already been tuned", "red");
	}

	if(wasspoon != $slot[none])
	{
		equip(wasspoon, $item[hewn moon-rune spoon]);
	}

	return cantune;
}

boolean auto_beachCombAvailable()
{
	if(!is_unrestricted($item[Beach Comb Box]) || !possessEquipment($item[Beach Comb]))
	{
		return false;
	}

	return true;
}

int auto_beachCombHeadNumFrom(string name)
{
	switch (name.to_lower_case())
	{
		case "hot":
			return 1;
		case "cold":
			return 2;
		case "stench":
			return 3;
		case "spooky":
			return 4;
		case "sleaze":
			return 5;
		case "muscle":
		case "musc":
			return 6;
		case "mysticality":
		case "myst":
			return 7;
		case "moxie":
		case "mox":
			return 8;
		case "init":
		case "initiative":
			return 9;
		case "weight":
		case "familiar":
			return 10;
		case "exp":
		case "stats":
			return 11;
	}
	auto_log_error("Invalid string " + name + "provided to auto_beachCombHeadNumFrom");
	return -1;
}

effect auto_beachCombHeadEffectFromNum(int num)
{
	switch(num)
	{
		case 1: return $effect[Hot-Headed];
		case 2: return $effect[Cold as Nice];
		case 3: return $effect[A Brush with Grossness];
		case 4: return $effect[Does It Have a Skull In There??];
		case 5: return $effect[Oiled, Slick];
		case 6: return $effect[Lack of Body-Building];
		case 7: return $effect[We\'re All Made of Starfish];
		case 8: return $effect[Pomp & Circumsands];
		case 9: return $effect[Resting Beach Face];
		case 10: return $effect[Do I Know You From Somewhere?];
		case 11: return $effect[You Learned Something Maybe!];
	}
	auto_log_error("Invalid number " + num + " provided to auto_beachCombHeadEffectFromNum");
	return $effect[none];
}

effect auto_beachCombHeadEffect(string name)
{
	return auto_beachCombHeadEffectFromNum(auto_beachCombHeadNumFrom(name));
}

boolean auto_canBeachCombHead(string name) {
	if (!auto_beachCombAvailable())
	{
	   return false;
	}
	int head = auto_beachCombHeadNumFrom(name);
	foreach _, usedHead in (get_property("_beachHeadsUsed").split_string(","))
	{
		if (to_string(head) == usedHead) { return false; }
	}
	return get_property("_freeBeachWalksUsed").to_int() < 11;
}

boolean auto_beachCombHead(string name)
{
	if(!auto_beachCombAvailable())   return false;
	if(!auto_canBeachCombHead(name)) return false;

	boolean ret = cli_execute("beach head " + auto_beachCombHeadNumFrom(name));
	
	if (ret)
	{
		handleTracker($item[Beach Comb], name, "auto_otherstuff");
	}
	return ret;
}

int auto_beachCombFreeUsesLeft(){
	if(!auto_beachCombAvailable() || get_property("_freeBeachWalksUsed").to_int() >= 11){
		return 0;
	}
	return 11 - get_property("_freeBeachWalksUsed").to_int();
}

boolean auto_beachUseFreeCombs() {
	if(!auto_beachCombAvailable()) { return false; }
	if(get_property("_freeBeachWalksUsed").to_int() >= 11) { return false; }
	cli_execute("CombBeach free");
	return true;
}

// place.php?whichplace=campaway
boolean auto_campawayAvailable()
{
	return is_unrestricted($item[Distant Woods Getaway Brochure]) && get_property("getawayCampsiteUnlocked").to_boolean();
}

boolean auto_campawayGrabBuffs()
{
	if(!auto_campawayAvailable())
	{
		return false;
	}

	int lim = 4 - get_property("_campAwaySmileBuffs").to_int() - get_property("_campAwayCloudBuffs").to_int();
	for (int i=0; i < lim; i++)
	{
		visit_url("place.php?whichplace=campaway&action=campaway_sky");
	}

	if(get_property("_campAwayCloudBuffs").to_int() == 0 && item_amount($item[campfire smoke]) + creatable_amount($item[campfire smoke]) > 0)
	{
		if(item_amount($item[campfire smoke]) == 0)
		{
			create(1, $item[campfire smoke]);
		}
		string message = "why is my computer on fire?";
		string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=" + $item[campfire smoke].to_int());
		temp = visit_url("choice.php?pwd=&whichchoice=1394&option=1&message=" + message);
		visit_url("place.php?whichplace=campaway&action=campaway_sky");
	}

	return true;
}

boolean auto_havePillKeeper() {
	return (possessEquipment($item[Eight Days a Week Pill Keeper]) && is_unrestricted($item[Unopened Eight Days a Week Pill Keeper]));
}

int auto_pillKeeperUses()
{
	if (!auto_havePillKeeper()) {
		return 0;
	}
	return spleen_left()/3 + 1 - get_property("_freePillKeeperUsed").to_boolean().to_int();
}

boolean auto_pillKeeperFreeUseAvailable()
{
	return auto_havePillKeeper() && !get_property("_freePillKeeperUsed").to_boolean();
}

boolean auto_pillKeeperAvailable()
{
	return auto_pillKeeperUses() > 0;
}

boolean auto_pillKeeper(int pill)
{
	if(auto_pillKeeperUses() == 0) return false;
	auto_log_info("Using pill keeper: consuming pill #" + pill, "blue");
	string page = visit_url("main.php?eowkeeper=1", false);
	page = visit_url("choice.php?pwd=&whichchoice=1395&pwd&option=" + pill, true);
	// Succeeded in consuming a pill
	if (contains_text(page, "You grab the day"))
	{
		string detail = "unknown";
		switch(pill)
		{
			case 1: detail = "yellow ray"; break;
			case 2: detail = "potion"; break;
			case 3: detail = "noncombat"; break;
			case 4: detail = "resistance"; break;
			case 5: detail = "stat"; break;
			case 6: detail = "fam weight"; break;
			case 7: detail = "semirare"; break;
			case 8: detail = "random"; break;
		}
		handleTracker($item[Eight Days a Week Pill Keeper], detail, "auto_chewed");
		return true;
	}

	// yellow ray, noncombat, or semirare already queued
	if (contains_text(page, "You can't take any more of that right now."))
	{
		auto_log_warning("Pill keeper pill #" + pill + " already in effect", "red");
		return true;
	}

	if (contains_text(page, "Your spleen can't handle any more days worth of medicine!"))
	{
		auto_log_warning("Not enough spleen remaining to use pill keeper", "red");
	}

	// Failed to consume a pill
	return false;
}

boolean auto_pillKeeper(string pill)
{
	int pillId;
	switch(pill.to_lower_case())
	{
	case "yr":
	case "yellow ray":
		pillID = 1; break;
	case "potion":
		pillID = 2; break;
	case "noncombat":
	case "bell":
		pillID = 3; break;
	case "resistance":
		pillID = 4; break;
	case "stat":
		pillID = 5; break;
	case "weight":
	case "fam weight":
		pillID = 6; break;
	case "semirare":
		pillID = 7; break;
	case "random":
		pillID = 8; break;
	default:
		abort("invalid argument to auto_pillKeeper: \"" + pill + "\"");
	}

	return auto_pillKeeper(pillId);
}

record PizzaPlan {
	item ing1;
	item ing2;
	item ing3;
	item ing4;
};

item[int] auto_pizza_ingredients(PizzaPlan plan)
{
	item[int] ret;
	ret[0] = plan.ing1;
	ret[1] = plan.ing2;
	ret[2] = plan.ing3;
	ret[3] = plan.ing4;
	return ret;
}

// Note this doesn't clamp to 15 - that's enforced elsewhere.
int auto_pizza_unclamped_advs(PizzaPlan plan)
{
	int char_sum = 0;
	foreach i, ing in auto_pizza_ingredients(plan)
	{
		char_sum += length(ing.to_string());
	}
	int advs = round(char_sum/10.0);

	return advs;
}

float[stat] auto_pizza_stats(PizzaPlan plan)
{
	float[stat] ret;
	ret[$stat[muscle]] = 0.0;
	ret[$stat[moxie]] = 0.0;
	foreach i, ing in auto_pizza_ingredients(plan)
	{
		ret[$stat[muscle]] += 10 * ing.fullness;
		ret[$stat[moxie]] += 10 * ing.inebriety;
	}
	return ret;
}

float auto_score_pizza(PizzaPlan plan)
{
	int unclamped_advs = auto_pizza_unclamped_advs(plan);
	int advs = min(15, unclamped_advs);
	int waste = max(0, 15 - unclamped_advs);
	float total_stat = auto_pizza_stats(plan)[my_primestat()];

	return 15 * advs + 0.1 * total_stat - 3 * waste;
}

void auto_deliberate_pizza()
{
	int [item] ingredients;

	boolean[item] keep_one = $items[];

	foreach it, i in get_inventory()
	{
		if (keep_one contains it) {
			if (i > 1)
			{
				ingredients[it] = min(4, i - 1);
			}
		}
		else
		{
			ingredients[it] = min(4, i);
		}
	}

	item[int] ingredients_list;

	foreach it, amount in ingredients
	{
		for (int i=0; i<amount; i++)
		{
			ingredients_list[count(ingredients_list)] = it;
		}
	}

	if (count(ingredients_list) < 4)
	{
		auto_log_info("Skipping pizza planning, not enough ingredients.");
		return;
	}

	PizzaPlan best_plan;
	float best_score = 0.0;

	for (int i=0; i<10000; i++)
	{
		int a = random(count(ingredients_list));
		int b = random(count(ingredients_list));
		int c = random(count(ingredients_list));
		int d = random(count(ingredients_list));

		if (a == b || a == c || a == d || b == c || b == d || c == d) continue;

		PizzaPlan speculative_plan;
		speculative_plan.ing1 = ingredients_list[a];
		speculative_plan.ing2 = ingredients_list[b];
		speculative_plan.ing3 = ingredients_list[c];
		speculative_plan.ing4 = ingredients_list[d];

		float score = auto_score_pizza(speculative_plan);
		if (score > best_score)
		{
			best_plan = speculative_plan;
		}
	}
	auto_log_info("Best plan:\n  " + 
		to_string(best_plan.ing1) + "\n  " +
		to_string(best_plan.ing2) + "\n  " +
		to_string(best_plan.ing3) + "\n  " +
		to_string(best_plan.ing4) + "\n  ");
	auto_log_info("For " + auto_pizza_unclamped_advs(best_plan) + " adventures.");
}

boolean auto_changeSnapperPhylum(phylum toChange)
{
  // Calling this function with a suitable phylum (anything other than none)
	// will cause the Red-Nosed Snapper to be changed to that phylum during pre-Adventure handling.
	// This will overwrite any current phylum, losing all progress towards that item (this is intended)
	// You have been warned.

	if (!canChangeToFamiliar($familiar[Red-Nosed Snapper]) || toChange == $phylum[none])
	{
		return false;
	}
	set_property("auto_snapperPhylum", toChange);
	return true;
}

void auto_snapperPreAdventure(location loc)
{
	if (my_familiar() != $familiar[Red-Nosed Snapper])
	{
		return;
	}
	
	string desiredPhylum = get_property("auto_snapperPhylum");
	if (desiredPhylum != "" && desiredPhylum.to_phylum() == $phylum[none])
	{
		auto_log_warning(`auto_snapperPhylum was set to bad value: {desiredPhylum}. Should be a valid phylum.`, "red");
		remove_property("auto_snapperPhylum");
		return;
	}

	if (get_property("redSnapperPhylum") == desiredPhylum)
	{
		auto_log_debug(`Red-Nosed Snapper is already guiding you towards {desiredPhylum}`);
		return;
	}

	// this is mainly in case autoChooseFamiliar switches to the Snapper due to no "better" +item familiars being available
	// It is preferred that you do not rely on this to change phylum in a quest, call changeSnapperPhylum in the quest handling code instead.
	if (desiredPhylum == "" && get_property("redSnapperProgress").to_int() == 0)
	{
		switch (loc)
		{
			case $location[The Penultimate Fantasy Airship]:
			case $location[The Hidden Park]:
			case $location[The Hidden Hospital]:
			case $location[The Hidden Office Building]:
			case $location[The Hidden Apartment Building]:
			case $location[The Hidden Bowling Alley]:
			case $location[The Copperhead Club]:
			case $location[A Mob of Zeppelin Protesters]:
			case $location[The Red Zeppelin]:
			case $location[Inside the Palindome]:
			case $location[The Neverending Party]:
			case $location[South of The Border]:
			case $location[The Valley of Rof L'm Fao]:
				desiredPhylum = $phylum[dude].to_string(); // human musk (banisher)
				break;
			case $location[The Hole in the Sky]:
				desiredPhylum = $phylum[constellation].to_string(); // micronova (yellow ray)
				break;
			case $location[The Smut Orc Logging Camp]:
				desiredPhylum = $phylum[orc].to_string(); // boot flask (size 3 awesome booze)
				break;
			case $location[The Outskirts of Cobb's Knob]:
			case $location[Cobb's Knob Barracks]:
			case $location[Cobb's Knob Kitchens]:
			case $location[Cobb's Knob Harem]:
			case $location[Cobb's Knob Treasury]:
			case $location[Cobb's Knob Laboratory]:
				desiredPhylum = $phylum[goblin].to_string(); // guffin (size 3 awesome food)
				break;
			case $location[The "Fun" House]:
				desiredPhylum = $phylum[horror].to_string(); // powdered madness (free kill)
				break;
			case $location[Twin Peak]:
				// this is actually a dude heavy zone *but* we want to fight the topiary monsters for rusty hedge trimmers.
				desiredPhylum = $phylum[beast].to_string();
				break;
			default:
				auto_log_info(`Going to {loc} with the Red-Nosed Snapper without setting a phylum. This is not necessarily bad but it might be worth checking.`, "blue");
				return;
		}
	}

	if(desiredPhylum != "")
	{
		cli_execute(`snapper {desiredPhylum}`);
		auto_log_info(`Red-Nosed Snapper is now guiding you towards {desiredPhylum}`, "blue");
	}
}
