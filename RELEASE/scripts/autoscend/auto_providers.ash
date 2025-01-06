
float providePlusCombat(int amt, location loc, boolean doEquips, boolean speculative) {
	auto_log_info((speculative ? "Checking if we can" : "Trying to") + " provide " + amt + " positive combat rate, " + (doEquips ? "with" : "without") + " equipment", "blue");

	float alreadyHave = numeric_modifier("Combat Rate");
	float need = amt - alreadyHave;

	if (need > 0) {
		auto_log_debug("We currently have " + alreadyHave + ", so we need an extra " + need);
	} else {
		auto_log_debug("We already have enough!");
	}

	float delta = 0;

	float result() {
		return numeric_modifier("Combat Rate") + delta;
	}

	if (doEquips) {
		string max = "200combat " + amt + "max";
		if (speculative) {
			simMaximizeWith(loc, max);
		} else {
			addToMaximize(max);
			simMaximize(loc);
		}
		delta = simValue("Combat Rate") - numeric_modifier("Combat Rate");
		auto_log_debug("With gear we can get to " + result());
	}

	boolean pass() {
		return result() >= amt;
	}

	if(pass()) {
		return result();
	}

	// first lets do stuff that is "free" (as in has no MP cost, item use or can be freely removed/toggled)
	
	if (have_effect($effect[Become Superficially Interested]) > 0) {
		visit_url("charsheet.php?pwd=&action=newyouinterest");
		if(pass()) {
			return result();
		}
	}

	foreach eff in $effects[Driving Stealthily, The Sonata of Sneakiness, In The Darkness] {
		uneffect(eff);
		if(pass()) {
			return result();
		}
	}

	if (get_property("_horsery") == "dark horse") {
		if (!speculative) {
			horseNone();
		}
		delta += (-1.0 * numeric_modifier("Horsery:dark horse", "Combat Rate")); // horsery changes don't happen until pre-adventure so this needs to be manually added otherwise it won't count.
		auto_log_debug("We " + (speculative ? "can remove" : "will remove") + " Dark Horse, we will have " + result());
	} else if (!speculative) {
		horseMaintain();
	}
	if(pass()) {
		return result();
	}

	void handleEffect(effect eff) {
		if (speculative) {
			delta += numeric_modifier(eff, "Combat Rate");
			if (eff == $effect[Musk of the Moose] && have_effect($effect[Smooth Movements]) > 0) {
				delta += (-1.0 * numeric_modifier($effect[Smooth Movements], "Combat Rate")); // numeric_modifer doesn't take into account uneffecting the opposite skill so we have to add it manually.
			}
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + result());
	}

	boolean tryEffects(boolean [effect] effects) {
		foreach eff in effects {
			if (buffMaintain(eff, 0, 1, 1, speculative)) {
				handleEffect(eff);
			}
			if (pass()) {
				return true;
			}
		}
		return false;
	}
	
	// Do the April band
	if(auto_haveAprilingBandHelmet())
	{
		if(!speculative)
			auto_setAprilBandCombat();
		handleEffect($effect[Apriling Band Battle Cadence]);
		if(pass())
			return result();
	}

	// Now handle buffs that cost MP, items or other resources

	shrugAT($effect[Carlweather\'s Cantata Of Confrontation]);
	if (tryEffects($effects[
		Musk of the Moose,
		Carlweather's Cantata of Confrontation,
		Attracting Snakes,
		Blinking Belly,
		Song of Battle,
		Frown,
		Angry,
		Screaming! \ SCREAMING! \ AAAAAAAH!,
		Coffeesphere,
		Unmuffled
	])) {
		return result();
	}

	if (tryEffects($effects[
		Taunt of Horus,
		Patent Aggression,
		Lion in Ambush,
		Everything Must Go!,
		Hippy Stench,
		High Colognic,
		Celestial Saltiness,
		Simply Irresistible,
		Crunching Leaves,
		Romantically Roused,
		Crunchy Steps
	])) {
		return result();
	}

	if(canAsdonBuff($effect[Driving Obnoxiously])) {
		if (!speculative) {
			asdonBuff($effect[Driving Obnoxiously]);
		}
		handleEffect($effect[Driving Obnoxiously]);
	}

	if(my_meat() > 100 + meatReserve()) {
		tryEffects($effects[Waking the Dead]);
	}

	if(pass()) {
		return result();
	}

	if (!speculative)
	{
		//Prep for if other +combat familiars are added
		foreach fam in $familiars[Jumpsuited Hound Dog]
		{
			if(canChangeToFamiliar(fam))
			{
				handleFamiliar(fam);
				if(pass()){
					return result();
				}
			}
		}
	}

	return result();
}

float providePlusCombat(int amt, boolean doEquips, boolean speculative)
{
	return providePlusCombat(amt, my_location(), doEquips, speculative);
}

boolean providePlusCombat(int amt, location loc, boolean doEquips)
{
	return providePlusCombat(amt, loc, doEquips, false) >= amt;
}

boolean providePlusCombat(int amt, boolean doEquips)
{
	return providePlusCombat(amt, my_location(), doEquips);
}

boolean providePlusCombat(int amt, location loc)
{
	return providePlusCombat(amt, loc, true);
}

boolean providePlusCombat(int amt)
{
	return providePlusCombat(amt, my_location());
}

float providePlusNonCombat(int amt, location loc, boolean doEquips, boolean speculative) {
	auto_log_info((speculative ? "Checking if we can" : "Trying to") + " provide " + amt + " negative combat rate, " + (doEquips ? "with" : "without") + " equipment", "blue");

	// numeric_modifier will return -combat as a negative value and +combat as a positive value
	// so we will need to invert the return values otherwise this will be wrong (since amt is supposed to be positive).
 	float alreadyHave = -1.0 * numeric_modifier("Combat Rate");
	float need = amt - alreadyHave;

	if (need > 0) {
		auto_log_debug("We currently have " + alreadyHave + ", so we need an extra " + need);
	} else {
		auto_log_debug("We already have enough!");
	}

	float delta = 0;

	float result() {
		return (-1.0 * numeric_modifier("Combat Rate")) + delta;
	}

	if (doEquips) {
		string max = "-200combat " + amt + "max";
		if (speculative) {
			simMaximizeWith(max);
		} else {
			addToMaximize(max);
			simMaximize();
		}
		delta = (-1.0 * simValue("Combat Rate")) - (-1.0* numeric_modifier("Combat Rate"));
		auto_log_debug("With gear we can get to " + result());
	}

	boolean pass() {
		return result() >= amt;
	}

	if(pass()) {
		return result();
	}


	// first lets do stuff that is "free" (as in has no MP cost, item use or can be freely removed/toggled)

	if (have_effect($effect[Become Intensely Interested]) > 0) {
		visit_url("charsheet.php?pwd=&action=newyouinterest");
		if(pass()) {
			return result();
		}
	}

	foreach eff in $effects[Carlweather\'s Cantata Of Confrontation, Driving Obnoxiously] {
		uneffect(eff);
		if(pass()) {
			return result();
		}
	}

	if (isHorseryAvailable() && my_meat() > horseCost() && get_property("_horsery") != "dark horse") {
		if (!speculative) {
			horseDark();
		}
		delta += (-1.0 * numeric_modifier("Horsery:dark horse", "Combat Rate")); // horsery changes don't happen until pre-adventure so this needs to be manually added otherwise it won't count.
		auto_log_debug("We " + (speculative ? "can gain" : "will gain") + " Dark Horse, we will have " + result());
	} else if (!speculative) {
		horseMaintain();
	}
	if(pass()) {
		return result();
	}


	void handleEffect(effect eff) {
		if (speculative) {
			delta += (-1.0 * numeric_modifier(eff, "Combat Rate"));
			if (eff == $effect[Smooth Movements] && have_effect($effect[Musk of the Moose]) > 0) {
				delta += numeric_modifier($effect[Musk of the Moose], "Combat Rate"); // numeric_modifer doesn't take into account uneffecting the opposite skill so we have to add it manually.
			}
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + result());
	}

	boolean tryEffects(boolean [effect] effects) {
		foreach eff in effects {
			if (buffMaintain(eff, 0, 1, 1, speculative)) {
				handleEffect(eff);
			}
			if (pass()) {
				return true;
			}
		}
		return false;
	}
	
	// Do the April band
	if(auto_haveAprilingBandHelmet())
	{
		if(!speculative)
			auto_setAprilBandNonCombat();
		handleEffect($effect[Apriling Band Patrol Beat]);
		if(pass())
			return result();
	}

	// Now handle buffs that cost MP, items or other resources

	shrugAT($effect[The Sonata of Sneakiness]);
	if (tryEffects($effects[
		Shelter Of Shed,
		Brooding,
		Muffled,
		Smooth Movements,
		The Sonata of Sneakiness,
		Hiding From Seekers,
		Song of Solitude,
		Inked Well,
		Bent Knees,
		Extended Toes,
		Ink Cloud,
		Cloak of Shadows,
		Chocolatesphere,
		Disquiet Riot
	])) {
		return result();
	}

	if ((-1.0 * auto_birdModifier("Combat Rate")) > 0) {
		if (tryEffects($effects[Blessing of the Bird])) {
			return result();
		}
	}

	if ((-1.0 * auto_favoriteBirdModifier("Combat Rate")) > 0) {
		if (tryEffects($effects[Blessing of Your Favorite Bird])) {
			return result();
		}
	}

	if (tryEffects($effects[
		Ashen,
		Predjudicetidigitation,
		Patent Invisibility,
		Ministrations in the Dark,
		Fresh Scent,
		Become Superficially interested,
		Gummed Shoes,
		Simply Invisible,
		Inky Camouflage,	
		Celestial Camouflage,
		Feeling Lonely,
		Feeling Sneaky,
		Ultra-Soft Steps,
		Hippy Antimilitarism
	])) {
		return result();
	}

	if(canAsdonBuff($effect[Driving Stealthily])) {
		if (!speculative) {
			asdonBuff($effect[Driving Stealthily]);
		}
		handleEffect($effect[Driving Stealthily]);
	}
	if(pass()) {
		return result();
	}

	//blooper ink costs 15 coins without which it will error when trying to buy it, so that is the bare minimum we need to check for
	//However we don't want to waste our early coins on it as they are precious. So require at least 400 coins before buying it.
	if(in_plumber() && 0 == have_effect($effect[Blooper Inked]) && item_amount($item[coin]) > 400) {
		if (!speculative) {
			retrieve_item(1, $item[blooper ink]);
		}
		if (tryEffects($effects[Blooper Inked])) {
			return result();
		}
	}

	// Glove charges are a limited per-day resource, lets do this last so we don't waste possible uses of Replace Enemy
	if (auto_hasPowerfulGlove() && tryEffects($effects[Invisible Avatar])) {
		return result();
	}

	if (!speculative)
	{
		foreach fam in $familiars[Peace Turkey, Disgeist]
		{
			if(canChangeToFamiliar(fam))
			{
				handleFamiliar(fam);
				if(pass()){
					return result();
				}
			}
		}
	}

	return result();
}

float providePlusNonCombat(int amt, boolean doEquips, boolean speculative)
{
	return providePlusNonCombat(amt, my_location(), doEquips, speculative);
}

boolean providePlusNonCombat(int amt, location loc, boolean doEquips)
{
	return providePlusNonCombat(amt, loc, doEquips, false) >= amt;
}

boolean providePlusNonCombat(int amt, boolean doEquips)
{
	return providePlusNonCombat(amt, my_location(), doEquips);
}

boolean providePlusNonCombat(int amt, location loc)
{
	return providePlusNonCombat(amt, loc, true);
}

boolean providePlusNonCombat(int amt)
{
	return providePlusNonCombat(amt, my_location());
}

float provideInitiative(int amt, location loc, boolean doEquips, boolean speculative)
{
	auto_log_info((speculative ? "Checking if we can" : "Trying to") + " provide " + amt + " initiative, " + (doEquips ? "with" : "without") + " equipment", "blue");

	float alreadyHave = numeric_modifier("Initiative");
	float need = amt - alreadyHave;

	if(need > 0)
	{
		auto_log_debug("We currently have " + alreadyHave + ", so we need an extra " + need);
	}
	else
	{
		auto_log_debug("We already have enough!");
	}

	float delta = 0;

	float result()
	{
		return numeric_modifier("Initiative") + delta;
	}

	if(doEquips)
	{
		string max = "500initiative " + amt + "max";
		if(speculative)
		{
			simMaximizeWith(loc, max);
		}
		else
		{
			addToMaximize(max);
			simMaximize(loc);
		}
		delta = simValue("Initiative") - numeric_modifier("Initiative");
		auto_log_debug("With gear we can get to " + result());
	}

	boolean pass()
	{
		return result() >= amt;
	}

	if(pass())
		return result();

	if (!speculative && doEquips)
	{
		handleFamiliar("init");
		if(pass())
			return result();
	}

	void handleEffect(effect eff)
	{
		if(speculative)
		{
			delta += numeric_modifier(eff, "Initiative");
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + result());
	}

	boolean tryEffects(boolean [effect] effects)
	{
		foreach eff in effects
		{
			if(buffMaintain(eff, 0, 1, 1, speculative))
				handleEffect(eff);
			if(pass())
				return true;
		}
		return false;
	}

	if(tryEffects($effects[
		Cletus's Canticle of Celerity,
		Springy Fusilli,
		Soulerskates,
		Walberg's Dim Bulb,
		Song of Slowness,
		Your Fifteen Minutes,
		Suspicious Gaze,
		Bone Springs,
		Living Fast,
		Nearly Silent Hunting,
		Stretched,
	]))
		return result();

	if(canAsdonBuff($effect[Driving Quickly]))
	{
		if(!speculative)
			asdonBuff($effect[Driving Quickly]);
		handleEffect($effect[Driving Quickly]);
	}
	if(pass())
		return result();

	if(bat_formBats(speculative))
	{
		handleEffect($effect[Bats Form]);
	}
	if(pass())
		return result();

	if(auto_birdModifier("Initiative") > 0)
	{
		if(tryEffects($effects[Blessing of the Bird]))
			return result();
	}

	if(auto_favoriteBirdModifier("Initiative") > 0)
	{
		if(tryEffects($effects[Blessing of Your Favorite Bird]))
			return result();
	}

	if(doEquips && auto_have_familiar($familiar[Grim Brother]) && (have_effect($effect[Soles of Glass]) == 0) && (get_property("_grimBuff").to_boolean() == false))
	{
		if(!speculative)
		{
			// We must visit the familiar's page before we can select the choice.
			auto_log_debug("Attempting to visit Grim brother");
			visit_url("familiar.php?action=chatgrim&pwd", true);
			auto_log_debug("Attempting to select Soles of Glass");
			visit_url("choice.php?pwd&whichchoice=835&option=1", true);
		}
			
		handleEffect($effect[Soles of Glass]);
		if(pass())
			return result();
	}

	if(tryEffects($effects[
		Adorable Lookout,
		Alacri Tea,
		All Fired Up,
		Clear Ears\, Can't Lose,
		Fishy\, Oily,
		The Glistening,
		Human-Machine Hybrid,
		Patent Alacrity,
		Provocative Perkiness,
		Sepia Tan,
		Sugar Rush,
		Ticking Clock,
		Well-Swabbed Ear,
		Poppy Performance
	]))
		return result();

	if(auto_sourceTerminalEnhanceLeft() > 0 && have_effect($effect[init.enh]) == 0 && auto_is_valid($effect[init.enh]))
	{
		if(!speculative)
			auto_sourceTerminalEnhance("init");
		handleEffect($effect[init.enh]);
		if(pass())
			return result();
	}

	if(doEquips && auto_canBeachCombHead("init"))
	{
		if(!speculative)
			auto_beachCombHead("init");
		handleEffect(auto_beachCombHeadEffect("init"));
		if(pass())
			return result();
	}

	if(doEquips && auto_haveCCSC() && have_effect($effect[Peppermint Rush]) == 0 && !get_property("_candyCaneSwordLyle").to_boolean()) {
		if (!speculative) {
			equip($item[candy cane sword cane]);
			string temp = visit_url("place.php?whichplace=monorail&action=monorail_lyle");
		}
		handleEffect($effect[Peppermint Rush]);
		if(pass())
			return result();
	}

	if(doEquips && amt >= 400)
	{
		if(!get_property("_bowleggedSwaggerUsed").to_boolean() && buffMaintain($effect[Bow-Legged Swagger], 0, 1, 1, speculative))
		{
			if(speculative)
				delta += delta + numeric_modifier("Initiative");
			auto_log_debug("With Bow-Legged Swagger we " + (speculative ? "can get to" : "now have") + " " + result());
		}
		if(pass())
			return result();
	}

	return result();
}

float provideInitiative(int amt, boolean doEquips, boolean speculative)
{
	return provideInitiative(amt, my_location(), doEquips, speculative);
}

boolean provideInitiative(int amt, location loc, boolean doEquips)
{
	return provideInitiative(amt, loc, doEquips, false) >= amt;
}

boolean provideInitiative(int amt, boolean doEquips)
{
	return provideInitiative(amt, my_location(), doEquips);
}

int [element] provideResistances(int [element] amt, location loc, boolean doEquips, boolean speculative)
{
	string debugprint = "Trying to provide ";
	foreach ele,goal in amt
	{
		debugprint += goal;
		debugprint += " ";
		debugprint += ele;
		debugprint += " resistance, ";
	}
	debugprint += (doEquips ? "with equipment" : "without equipment");
	auto_log_info(debugprint, "blue");

	if(amt[$element[stench]] > 0)
	{
		uneffect($effect[Flared Nostrils]);
	}
	
	int [element] gearLoss;
	if(!doEquips)
	{	//trying to provide without equipment also means trying to reach goal without value provided by current equipment
		//currently equipment is not being locked and may be changed in pre adv after the provider returns success
		//so may need to take into account removal of what is provided by current equipment to compensate
		//must reduce the result (not raise goal value) since other functions look at the result
		string unequipsString;
		foreach sl in $slots[hat,weapon,off-hand,back,shirt,pants,acc1,acc2,acc3,familiar]
		{
			//simulate removing all gear regardless of individual res modifiers, must account for familiar weight or outfit bonus
			if(equipped_item(sl) != $item[none]) unequipsString += "unequip " + sl + "; ";
		}
		if(unequipsString != "")
		{
			cli_execute("speculate quiet; " + unequipsString);
			foreach ele in amt
			{
				//record the amount that would be lost to modify the result with
				gearLoss[ele] = min(0,simValue(ele + " resistance") - numeric_modifier(ele + " resistance"));
			}
		}
	}

	int [element] delta;

	int result(element ele)
	{
		return numeric_modifier(ele + " Resistance") + delta[ele] + gearLoss[ele];
	}

	int [element] result()
	{
		int [element] res;
		foreach ele in amt
		{
			res[ele] = result(ele);
		}
		return res;
	}

	string resultstring()
	{
		string s = "";
		foreach ele in amt
		{
			if(s != "")
			{
				s += ", ";
			}
			s += result(ele) + " " + ele.to_string() + " resistance";
		}
		return s;
	}

	void handleEffect(effect eff)
	{
		if(speculative)
		{
			foreach ele in amt
			{
				delta[ele] += numeric_modifier(eff, ele + " Resistance");
			}
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + resultstring());
	}

	boolean pass(element ele)
	{
		return result(ele) >= amt[ele];
	}

	boolean pass()
	{
		foreach ele in amt
		{
			if(!pass(ele))
				return false;
		}
		if (canChangeFamiliar() && $familiars[Trick-or-Treating Tot, Mu, Exotic Parrot] contains my_familiar()) {
			// if we pass while having a resist familiar equipped, make sure we keep it equipped
			// otherwise we may end up flip-flopping from the resist familiar and something else
			// which could cost us adventures if switching familiars affects our resistances enough
			handleFamiliar(my_familiar());
		}
		return true;
	}

	if(doEquips)
	{
		if(speculative)
		{
			string max = "";
			foreach ele,goal in amt
			{
				if(max.length() > 0)
				{
					max += ",";
				}
				max += "2000" + ele + " resistance " + goal + "max";
			}
			simMaximizeWith(loc, max);
		}
		else
		{
			foreach ele,goal in amt
			{
				addToMaximize("2000" + ele + " resistance " + goal + "max");
			}
			simMaximize(loc);
		}
		foreach ele in amt
		{
			delta[ele] = simValue(ele + " Resistance") - numeric_modifier(ele + " Resistance");
		}
		auto_log_debug("With gear we can get to " + resultstring());
	}

	if(pass())
		return result();

	boolean tryEffects(boolean [effect] effects)
	{
		foreach eff in effects
		{
			boolean effectMatters = false;
			foreach ele in amt
			{
				if(!pass(ele) && numeric_modifier(eff, ele + " Resistance") > 0)
				{
					effectMatters = true;
				}
			}
			if(!effectMatters)
			{
				continue;
			}
			if(buffMaintain(eff, 0, 1, 1, speculative))
			{
				handleEffect(eff);
			}
			if(pass())
				return true;
		}
		return false;
	}

	// effects from skills
	if(tryEffects($effects[
		Elemental Saucesphere,
		Astral Shell,
		Hide of Sobek,
		Spectral Awareness,
		Scariersauce,
		Scarysauce,
		Blessing of the Bird,
		Blessing of Your Favorite Bird,
		Feeling Peaceful,
		Shifted Reality,
	]))
		return result();

	if(bat_formMist(speculative))
		handleEffect($effect[Mist Form]);
	if(pass())
		return result();

	if(doEquips && canChangeFamiliar())
	{
		familiar resfam = $familiar[none];
		foreach fam in $familiars[Trick-or-Treating Tot, Mu, Exotic Parrot]
		{
			if(auto_have_familiar(fam))
			{
				resfam = fam;
				break;
			}
		}
		if(resfam != $familiar[none])
		{
			// need to use now so maximizer will see it
			use_familiar(resfam);
			if(resfam == $familiar[Trick-or-Treating Tot])
			{
				cli_execute("acquire 1 li'l candy corn costume");
			}
			// update maximizer scores with familiar
			simMaximize(loc);
			foreach ele in amt
			{
				delta[ele] = simValue(ele + " Resistance") - numeric_modifier(ele + " Resistance");
			}
		}
		if(pass()) {
			return result();
		}
	}

	if(doEquips)
	{
		// effects from items that we'd have to buy or have found
		if(tryEffects($effects[
			Red Door Syndrome,
			Well-Oiled,
			Oiled-Up,
			Egged On,
			Flame-Retardant Trousers,
			Fireproof Lips,
			Insulated Trousers,
			Fever From the Flavor,
			Smelly Pants,
			Neutered Nostrils,
			Can't Smell Nothin\',
			Spookypants,
			Balls of Ectoplasm,
			Hyphemariffic,
			Sleaze-Resistant Trousers,
			Hyperoffended,
			Covered in the Rainbow,
			Temporarily Filtered,
			Gritty,
			Too Shamed,
			Twangy,
			minor invulnerability,
			Incredibly Healthy
		]))
			return result();
	}

	return result();
}

int [element] provideResistances(int [element] amt, boolean doEquips, boolean speculative)
{
	return provideResistances(amt, my_location(), doEquips, speculative);
}

boolean provideResistances(int [element] amt, location loc, boolean doEquips)
{
	int [element] res = provideResistances(amt, doEquips, false);
	foreach ele, i in amt
	{
		if(res[ele] < i)
			return false;
	}
	return true;
}

boolean provideResistances(int [element] amt, boolean doEquips)
{
	return provideResistances(amt, my_location(), doEquips);
}

float [stat] provideStats(int [stat] amt, location loc, boolean doEquips, boolean speculative)
{
	string debugprint = "Trying to provide ";
	foreach st,goal in amt
	{
		debugprint += goal;
		debugprint += " ";
		debugprint += st;
		debugprint += ", ";
	}
	debugprint += (doEquips ? "with equipment" : "without equipment");
	auto_log_info(debugprint, "blue");

	float [stat] delta;

	float result(stat st)
	{
		return my_buffedstat(st) + delta[st];
	}

	float [stat] result()
	{
		float [stat] res;
		foreach st in amt
		{
			res[st] = result(st);
		}
		return res;
	}

	string resultstring()
	{
		string s = "";
		foreach st in amt
		{
			if(s != "")
			{
				s += ", ";
			}
			s += result(st) + " " + st.to_string();
		}
		return s;
	}

	void handleEffect(effect eff)
	{
		if(speculative)
		{
			foreach st in amt
			{
				delta[st] += numeric_modifier(eff, st);
				delta[st] += numeric_modifier(eff, st + " Percent") * my_basestat(st) / 100.0;
			}
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + resultstring());
	}

	boolean pass(stat st)
	{
		return result(st) >= amt[st];
	}

	boolean pass()
	{
		foreach st in amt
		{
			if(!pass(st))
				return false;
		}
		return true;
	}

	if(doEquips)
	{
		if(speculative)
		{
			string max = "";
			foreach st,goal in amt
			{
				if(max.length() > 0)
				{
					max += ",";
				}
				max += "200" + st + " " + goal + "max";
			}
			simMaximizeWith(loc, max);
		}
		else
		{
			foreach st,goal in amt
			{
				addToMaximize("200" + st + " " + goal + "max");
			}
			simMaximize(loc);
		}
		foreach st in amt
		{
			delta[st] = simValue("Buffed " + st) - my_buffedstat(st);
		}
		auto_log_debug("With gear we can get to " + resultstring());
	}

	if(pass())
		return result();

	boolean tryEffects(boolean [effect] effects)
	{
		foreach eff in effects
		{
			boolean effectMatters = false;
			foreach st in amt
			{
				if(!pass(st) && (numeric_modifier(eff, st) > 0 || numeric_modifier(eff, st + " Percent") > 0))
				{
					effectMatters = true;
				}
			}
			if(!effectMatters)
			{
				continue;
			}
			if(buffMaintain(eff, 0, 1, 1, speculative))
			{
				handleEffect(eff);
			}
			if(pass())
				return true;
		}
		return false;
	}

	if(tryEffects($effects[
		// muscle effects
		Juiced and Loose,					//+50% mus. nuclear autumn only. 3 MP/adv
		Quiet Determination,				//+25% mus. facial expression. 1 MP/adv
		Rage of the Reindeer,				//+10% mus. +10 weapon dmg. 1 MP/adv
		Power Ballad of the Arrowsmith,		//+10 mus. +20 maxHP. song. 5 MP (duration varies).
		Seal Clubbing Frenzy,				//+2 mus. 0.2 MP/adv
		Patience of the Tortoise,			//+1 mus. +3 maxHP. 0.2 MP/adv
		
		// myst effects
		Mind Vision,						//+50% mys. nuclear autumn only. 3 MP/adv
		Quiet Judgement,					//+25% mys. facial expression. 1 MP/adv
		The Magical Mojomuscular Melody,	//+10 mys. +20 maxMP. song. 3 MP (duration varies).
		Pasta Oneness,						//+2 mys. 0.2 MP/adv
		Saucemastery,						//+1 mys. +3 maxMP. 0.2 MP/adv

		// moxie effects
		Impeccable Coiffure,				//+50% mox. nuclear autumn only. 3 MP/adv
		Song of Bravado,					//+15% all. NOT a song. 10 MP/adv
		The Moxious Madrigal,				//+10 mox. song. 2 MP (duration varies).
		Disco State of Mind,				//+2 mox. 0.2 MP/adv
		Mariachi Mood,						//+1 mox. +3 maxHP. 0.2 MP/adv

		// all-stat effects
		Cheerled,							//+50% all. Class=Pig Skinner
		Big,								//+20% all. 1.5 MP/adv
		Song of Bravado,					//+15% all. NOT a song. 10 MP/adv
		Stevedave's Shanty of Superiority,	//+10% all. song. 30 MP (duration varies).

		// varying effects
		Blessing of the Bird,
		Blessing of Your Favorite Bird,
		Feeling Excited,
	]))
		return result();

	if(auto_have_skill($skill[Quiet Desperation]))		//+25% mox. facial expression. 1 MP/adv
		tryEffects($effects[Quiet Desperation]);
	else
		tryEffects($effects[Disco Smirk]);				//+10 mox. facial expression. 1 MP/adv

	if(pass())
		return result();

	// buffs from items
	if(doEquips)
	{
		if(tryEffects($effects[
			// muscle effects
			Browbeaten,
			Extra Backbone,
			Extreme Muscle Relaxation,
			Faboooo,
			Feroci Tea,
			Fishy Fortification,
			Football Eyes,
			Go Get \'Em\, Tiger!,
			Lycanthropy\, Eh?,
			Marinated,
			Phorcefullness,
			Rainy Soul Miasma,
			Savage Beast Inside,
			Steroid Boost,
			Spiky Hair,
			Sugar Rush,
			Superheroic,
			Temporary Lycanthropy,
			Truly Gritty,
			Vital,
			Woad Warrior,

			// myst effects
			Baconstoned,
			Erudite,
			Far Out,
			Glittering Eyelashes,
			Liquidy Smoky,
			Marinated,
			Mystically Oiled,
			OMG WTF,
			Paging Betty,
			Rainy Soul Miasma,
			Ready to Snap,
			Rosewater Mark,
			Seeing Colors,
			Sweet\, Nuts,

			// moxie effects
			Almost Cool,
			Bandersnatched,
			Busy Bein' Delicious,
			Butt-Rock Hair,
			Funky Coal Patina,
			Liquidy Smoky,
			Locks Like the Raven,
			Lycanthropy\, Eh?,
			Memories of Puppy Love,
			Newt Gets In Your Eyes,
			Notably Lovely,
			Oiled Skin,
			Radiating Black Body&trade;,
			Spiky Hair,
			Sugar Rush,
			Superhuman Sarcasm,
			Unrunnable Face,
			Gaffe Free,
			Poppy Performance,

			// all-stat effects
			Confidence of the Votive,
			Pyrite Pride,
			Human-Human Hybrid,
			Industrial Strength Starch,
			Mutated,
			Seriously Mutated,
			Pill Power,
			Slightly Larger Than Usual,
			Standard Issue Bravery,
			Tomato Power,
			Vital,
			Triple-Sized,
		]))
			return result();

		foreach st in amt
		{
			if(!pass(st) && auto_canBeachCombHead(st.to_string()))
			{
				if(!speculative)
					auto_beachCombHead(st.to_string());
				handleEffect(auto_beachCombHeadEffect(st.to_string()));
			}
		}
		if(pass())
			return result();
	}

	return result();
}

float [stat] provideStats(int [stat] amt, boolean doEquips, boolean speculative)
{
	return provideStats(amt, my_location(), doEquips, speculative);
}

boolean provideStats(int [stat] amt, location loc, boolean doEquips)
{
	float [stat] res = provideStats(amt, doEquips, false);
	foreach st, i in amt
	{
		if(res[st] < i)
		{
			return false;
		}
	}
	return true;
}

boolean provideStats(int [stat] amt, boolean doEquips)
{
	return provideStats(amt, my_location(), doEquips);
}

float provideMuscle(int amt, location loc, boolean doEquips, boolean speculative)
{
	int [stat] statsNeeded;
	statsNeeded[$stat[muscle]] = amt;
	float [stat] res = provideStats(statsNeeded, loc, doEquips, speculative);
	return res[$stat[muscle]];
}

float provideMuscle(int amt, boolean doEquips, boolean speculative)
{
	return provideMuscle(amt, my_location(), doEquips, speculative);
}

boolean provideMuscle(int amt, location loc, boolean doEquips)
{
	return provideMuscle(amt, loc, doEquips, false) >= amt;
}

boolean provideMuscle(int amt, boolean doEquips)
{
	return provideMuscle(amt, my_location(), doEquips);
}

float provideMysticality(int amt, location loc, boolean doEquips, boolean speculative)
{
	int [stat] statsNeeded;
	statsNeeded[$stat[mysticality]] = amt;
	float [stat] res = provideStats(statsNeeded, loc, doEquips, speculative);
	return res[$stat[mysticality]];
}

float provideMysticality(int amt, boolean doEquips, boolean speculative)
{
	return provideMysticality(amt, my_location(), doEquips, speculative);
}

boolean provideMysticality(int amt, location loc, boolean doEquips)
{
	return provideMysticality(amt, loc, doEquips, false) >= amt;
}

boolean provideMysticality(int amt, boolean doEquips)
{
	return provideMysticality(amt, my_location(), doEquips);
}

float provideMoxie(int amt, location loc, boolean doEquips, boolean speculative)
{
	int [stat] statsNeeded;
	statsNeeded[$stat[moxie]] = amt;
	float [stat] res = provideStats(statsNeeded, loc, doEquips, speculative);
	return res[$stat[moxie]];
}

float provideMoxie(int amt, boolean doEquips, boolean speculative)
{
	return provideMoxie(amt, my_location(), doEquips, speculative);
}

boolean provideMoxie(int amt, location loc, boolean doEquips)
{
	return provideMoxie(amt, loc, doEquips, false) >= amt;
}

boolean provideMoxie(int amt, boolean doEquips)
{
	return provideMoxie(amt, my_location(), doEquips);
}

float provideMeat(int amt, location loc, boolean doEverything, boolean speculative)
{
	auto_log_info((speculative ? "Checking if we can" : "Trying to") + " provide " + amt + " meat, " + (doEverything ? "with" : "without") + " equipment, familiar, and limited buffs", "blue");
	float alreadyHave = numeric_modifier("Meat Drop");
	float need = amt - alreadyHave;
	if(need > 0)
	{
		auto_log_debug("We currently have " + alreadyHave + ", so we need an extra " + need);
	}
	else
	{
		auto_log_debug("We already have enough +meat!");
		return alreadyHave;
	}
	float delta = 0;
	float result()
	{
		return numeric_modifier("Meat Drop") + delta;
	}
	boolean pass()
	{
		return result() >= amt;
	}
	if(pass())
		return result();
	
	// don't craft equipment here. See how much +meat we can get with gear on hand
	if(doEverything)
	{
		string max = "500meat " + (amt + 100) + "max";
		if(speculative)
		{
			simMaximizeWith(loc, max);
		}
		else
		{
			addToMaximize(max);
			simMaximize(loc);
		}
		delta = simValue("Meat Drop") - numeric_modifier("Meat Drop");
		auto_log_debug("With existing gear we can get to " + result());
		if(pass())
			return result();
	}
	//see how much familiar will help
	if(doEverything && canChangeFamiliar())
	{
		if(!speculative)
		{
			handleFamiliar("meat");
		}
		// fam isn't equipped immediatly even if we aren't speculating
		// so add bonus from fam regardless of speculation
		familiar target = lookupFamiliarDatafile("meat");
		if(target != $familiar[none] && target != my_familiar())
		{
			int famWeight = familiar_weight(target) + weight_adjustment();
			delta += numeric_modifier(target, "Meat Drop",famWeight,$item[none]);
			auto_log_debug("With using familiar: " + target + " we can get to " + result());
		}
		else
		{
			auto_log_debug("Already have desired familar, " + target + ", active.");
		}
		if(pass())
			return result();
	}
	void handleEffect(effect eff)
	{
		if(speculative)
		{
			delta += numeric_modifier(eff, "Meat Drop");
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + result());
	}
	boolean tryEffects(boolean [effect] effects)
	{
		foreach eff in effects
		{
			if(buffMaintain(eff, 0, 1, 1, speculative))
				handleEffect(eff);
			if(pass())
				return true;
		}
		return false;
	}
	// unlimited skills
	if(tryEffects($effects[
		Polka of Plenty, //50% meat
		Disco Leer //10% meat
	]))
		if(pass())
			return result();
	if(canAsdonBuff($effect[Driving Observantly]))
	{
		//50% meat, 50% item, 50% booze drops
		if(!speculative)
			asdonBuff($effect[Driving Observantly]);
		handleEffect($effect[Driving Observantly]);
	}
	if(pass())
		return result();
	if(bat_formWolf(speculative))
	{
		//150% meat, 150% muscle
		handleEffect($effect[Wolf Form]);
	}
	if(pass())
		return result();
	if(auto_birdModifier("Meat Drop") > 0)
	{
		//Can be 20/40/60/80/100% meat drop
		if(tryEffects($effects[Blessing of the Bird]))
			if(pass())
				return result();
	}
	if(auto_favoriteBirdModifier("Meat Drop") > 0)
	{
		//Can be 20/40/60/80/100% meat drop
		if(tryEffects($effects[Blessing of Your Favorite Bird]))
			if(pass())
				return result();
	}
	if(isActuallyEd())
	{
		//50% meat drop
		if(!have_skill($skill[Gift of the Maid]) && ($servant[Maid].experience >= 441))
		{
			visit_url("charsheet.php");
			if(have_skill($skill[Gift of the Maid]))
			{
				auto_log_warning("Gift of the Maid not properly detected until charsheet refresh.", "red");
			}
		}
		if(tryEffects($effects[
		Purr of the Feline //makes the maid 5 levels higher
		]))
		if(pass())
			return result();
	}
	songboomSetting("meat"); //30% meat
	// items
	if(tryEffects($effects[
		Flapper Dancin\', //100% meat
		Heightened Senses, //50% meat, 25% item drop
		Big Meat Big Prizes, //50% meat
		Human-Constellation Hybrid, //50% meat
		Patent Avarice, //50% meat
		Earning Interest, //50% meat
		Bet Your Autumn Dollar, //50% meat
		The Grass... \ Is Blue..., //40% meat, 20% item
		Greedy Resolve, //30% meat
		Worth Your Salt, //25% meat, max hp +25
		Human-Fish Hybrid, //10 fam
		Human-Humanoid Hybrid, //20% meat, 10% all stats
		Heart of Pink, //20% meat, +3 all stats
		Kindly Resolve, //5 fam weight
		Human-Machine Hybrid, //5 fam weight, DA +50, DR 5
		Sweet Heart, // Muscle +X, +2X% meat
		Cranberry Cordiality, //10% meat
		So You Can Work More... //10% meat
	]))
		if(pass())
			return result();

	if(have_effect($effect[Synthesis: Greed]) == 0)
	{
		rethinkingCandy($effect[Synthesis: Greed]); //300% meat
		if(pass())
			return result();
	}
	if(available_amount($item[Li\'l Pirate Costume]) > 0 && canChangeToFamiliar($familiar[Trick-or-Treating Tot]) && (!in_heavyrains()))
	{
		use_familiar($familiar[Trick-or-Treating Tot]);
		autoEquip($item[Li\'l Pirate Costume]); //300% meat
		handleFamiliar($familiar[Trick-or-Treating Tot]);
		if(pass())
			return result();
	}
	if(!in_wereprof())
	{
		//wereprof doesn't like +ML effects outside of Werewolf
		if(tryEffects($effects[Frosty])) //200% meat, 100% item, 100% init, 25 ML
			if(pass())
				return result();
	}
	if(auto_sourceTerminalEnhanceLeft() > 0 && have_effect($effect[meat.enh]) == 0 && auto_is_valid($effect[meat.enh]))
	{
		if(!speculative)
			auto_sourceTerminalEnhance("meat");
		handleEffect($effect[meat.enh]); //60% meat
		if(pass())
			return result();
	}
	if(item_amount($item[body spradium]) > 0 && !in_tcrs() && have_effect($effect[Boxing Day Glow]) == 0)
	{
		autoChew(1, $item[body spradium]); //50% meat, 5 fam weight
		if(pass())
			return result();
	}

	// craft equipment, even limited use, here
	if(doEverything)
	{
		handleBjornify($familiar[Hobo Monkey]); //25% meat, hot damage, delevels
		//craft IOTM derivative that gives high item bonus
		if((equipped_item($slot[off-hand]) != $item[Half a Purse]) && !possessEquipment($item[Half a Purse]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
		{
			//+X% meat based on smithness (10% if only half a purse is equipped)
			auto_buyUpTo(1, $item[Loose Purse Strings]);
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Loose purse strings]);
		}
		string max = "500meat " + (amt + 100) + "max";
		if(speculative)
		{
			simMaximizeWith(loc, max);
		}
		else
		{
			addToMaximize(max);
			simMaximize(loc);
		}
		delta = simValue("Meat Drop") - numeric_modifier("Meat Drop");
		auto_log_debug("With existing and crafted gear we can get to " + result());
		if(pass())
			return result();
	}
	// Use limited resources like Inhaler
	if(doEverything)
	{
		if(tryEffects($effects[
		shadow waters, //200% meat, 100% item, 100% init, -10% combat
		Sinuses For Miles, //200% meat
		Car-Charged, //100% meat, 100% item, 5-10MP, 50% init, 50% spell dmg, +3 stats per fight
		Incredibly Well Lit //100% meat, 50% item
		]))
			if(pass())
				return result();
		if(zataraAvailable() && (0 == have_effect($effect[Meet the Meat])) & auto_is_valid($effect[Meet the Meat]))
		{
			if(!speculative)
			{
				zataraSeaside("meat");
			}
			handleEffect($effect[Meet the meat]); //100% meat, 50% gear drops
			if(pass())
				return result();			
		}
		if((get_property("sidequestArenaCompleted") == "fratboy") && !get_property("concertVisited").to_boolean() && (have_effect($effect[Winklered]) == 0))
		{
			if(is_professor())
			{
				//Need to manually equip because professor
				if(!have_equipped($item[beer helmet])) equip($item[beer helmet]);
				if(!have_equipped($item[distressed denim pants])) equip($item[distressed denim pants]);
				if(!have_equipped($item[bejeweled pledge pin])) equip($item[bejeweled pledge pin]);
			}
			else
			{
				outfit("Frat Warrior Fatigues");
			}
			if(!speculative)
			{
				cli_execute("concert 2"); //40% meat
			}
			handleEffect($effect[Winklered]); //40% meat
			if(pass())
				return result();
		}
		if(pass())
			return result();
		if(auto_totalEffectWishesAvailable() > 0)
		{
			boolean success = true;
			int specwishes = 0;
			foreach eff in $effects[Frosty, //200% meat, 100% item, 25 ML, 100% init
			Braaaaaains, //200% meat, -50% item
			Let's Go Shopping!,  //150% meat, 75% item, -300% myst
			Always Be Collecting, //100% meat, 50% item
			Incredibly Well Lit, //100% meat, 50% item
			A View to Some Meat, //100% meat
			Cravin' for a Ravin', //100% meat
			Low on the Hog, //100% meat
			Leisurely Amblin', //100% meat
			Trufflin', //100% meat
			Here's Some More Mud in Your Eye, //100% meat
			Eau d' Clochard, //100% meat
			Flapper Dancin', //100% meat
			Fishing for Meat, //100% meat
			Preternatural Greed] //100% meat
			{
				if(eff == $effect[Frosty] && in_wereprof()) continue; //skip frosty in wereprof
				if(have_effect(eff) == 0)
				{
					if(!speculative)
						success = auto_wishForEffect(eff);
					specwishes +=1;
					if(specwishes <= auto_totalEffectWishesAvailable())
					{
						handleEffect(eff);
						if(pass())
							return result();
					}
					else
					{
						success = false;
					}
				}
				if(!success) break;
			}
		}
		auto_log_debug("With limited buffs we can get to " + result());
		if(pass())
			return result();
	}

	return result();
}

float provideMeat(int amt, boolean doEverything, boolean speculative)
{
	return provideMeat(amt, my_location(), doEverything, speculative);
}

boolean provideMeat(int amt, location loc, boolean doEverything)
{
	return provideMeat(amt, loc, doEverything, false) >= amt;
}

boolean provideMeat(int amt, boolean doEverything)
{
	return provideMeat(amt, my_location(), doEverything);
}

float provideItem(int amt, location loc, boolean doEverything, boolean speculative)
{
	//doEverything means use equipment, familiar slot, and limited buffs (ie steely eye squint)
	auto_log_info((speculative ? "Checking if we can" : "Trying to") + " provide " + amt + " item, " + (doEverything ? "with" : "without") + " equipment, familiar, and limited buffs", "blue");

	float alreadyHave = numeric_modifier("Item Drop");
	float need = amt - alreadyHave;

	if(need > 0)
	{
		auto_log_debug("We currently have " + alreadyHave + ", so we need an extra " + need);
	}
	else
	{
		auto_log_debug("We already have enough +item!");
		return alreadyHave;
	}

	float delta = 0;

	float result()
	{
		return numeric_modifier("Item Drop") + delta;
	}

	boolean pass()
	{
		return result() >= amt;
	}

	if(pass())
		return result();
	
	// don't craft equipment here. See how much +item we can get with gear on hand
	if(doEverything)
	{
		string max = "500item " + (amt + 100) + "max";
		if(speculative)
		{
			simMaximizeWith(loc, max);
		}
		else
		{
			addToMaximize(max);
			simMaximize(loc);
		}
		delta = simValue("Item Drop") - numeric_modifier("Item Drop");
		auto_log_debug("With existing gear we can get to " + result());

		if(pass())
			return result();
	}

	//see how much familiar will help
	if(doEverything && canChangeFamiliar())
	{
		if(!speculative)
		{
			handleFamiliar("item");
		}
		// fam isn't equipped immediatly even if we aren't speculating
		// so add bonus from fam regardless of speculation
		familiar target = lookupFamiliarDatafile("item");
		if(target != $familiar[none] && target != my_familiar())
		{
			int famWeight = familiar_weight(target) + weight_adjustment();
			delta += numeric_modifier(target, "Item Drop",famWeight,$item[none]);
			auto_log_debug("With using familiar: " + target + " we can get to " + result());
		}
		else
		{
			auto_log_debug("Already have desired familar, " + target + ", active.");
		}

		if(pass())
			return result();
	}

	void handleEffect(effect eff)
	{
		if(speculative)
		{
			delta += numeric_modifier(eff, "Item Drop");
		}
		auto_log_debug("We " + (speculative ? "can gain" : "just gained") + " " + eff.to_string() + ", now we have " + result());
	}

	boolean tryEffects(boolean [effect] effects)
	{
		foreach eff in effects
		{
			if(buffMaintain(eff, 0, 1, 1, speculative))
				handleEffect(eff);
			if(pass())
				return true;
		}
		return false;
	}

	if(in_heavyrains())
	{
		buffMaintain($effect[Fishy Whiskers]); // HR only
	}

	// unlimited skills
	if(tryEffects($effects[
		Fat Leon\'s Phat Loot Lyric, //20% item
		Singer\'s Faithful Ocelot //10% item
	]))
		return result();

	if(canAsdonBuff($effect[Driving Observantly]))
	{
		//50% meat, 50% item, 50% booze drops
		if(!speculative)
			asdonBuff($effect[Driving Observantly]);
		handleEffect($effect[Driving Observantly]);
	}
	if(pass())
		return result();

	if(!bat_wantHowl(loc) && bat_formBats(speculative))
	{
		//150% item, 150% init
		handleEffect($effect[Bats Form]);
	}
	if(pass())
		return result();

	if(auto_birdModifier("Item Drop") > 0)
	{
		//Can be 10/20/30/40/50% item drop
		if(tryEffects($effects[Blessing of the Bird]))
			return result();
	}

	if(auto_favoriteBirdModifier("Item Drop") > 0)
	{
		//Can be 10/20/30/40/50% item drop
		if(tryEffects($effects[Blessing of Your Favorite Bird]))
			return result();
	}

	// items
	if(tryEffects($effects[
		Unusual Perspective, //50% item
		Five Sticky Fingers, //50% item
		Spitting Rhymes, //50% item
		Wet and Greedy, //25% item
		Serendipi Tea, //25% item
		Glowing Hands, //25% item
		Eagle Eyes, //20% item
		Juiced and Jacked, //20% item
		The Grass... \ Is Blue..., //40% meat, 20% item
		Joyful Resolve, //15% item
		Fortunate Resolve, //10% item
		Human-Human Hybrid, //10% item
		Heart of Lavender, //10% item
	]))
		return result();
	
	if(!in_wereprof())
	{
		//wereprof doesn't like +ML effects outside of Werewolf
		if(tryEffects($effects[Frosty])) //200% meat, 100% item, 100% init, 25 ML
			return result();
	}

	if((auto_is_valid($item[possessed sugar cube]) && item_amount($item[possessed sugar cube]) > 0) && (have_effect($effect[Dance of the Sugar Fairy]) == 0))
	{
		if(!speculative)
			cli_execute("make sugar fairy");
		handleEffect($effect[Dance of the Sugar Fairy]); //25% item
		if(pass())
			return result();
	}
	
	if(auto_sourceTerminalEnhanceLeft() > 0 && have_effect($effect[items.enh]) == 0 && auto_is_valid($effect[items.enh]))
	{
		if(!speculative)
			auto_sourceTerminalEnhance("items"); //30% item
		handleEffect($effect[items.enh]);
		if(pass())
			return result();
	}

	//check specific item drop bonus
	generic_t itemFoodNeed = zone_needItemFood(loc);
	generic_t itemBoozeNeed = zone_needItemBooze(loc);
	float itemDropFood = result() + simValue("Food Drop");
	float itemDropBooze = result() + simValue("Booze Drop");
	if(itemFoodNeed._boolean && itemDropFood < itemFoodNeed._float)
	{
		auto_log_debug("Trying food drop supplements");
		//max at start of an expression with item and food drop is ineffective in combining them, have to let the maximizer try to add on top
		addToMaximize("49food drop " + ceil(itemFoodNeed._float) + "max");
		simMaximize();
		itemDropFood = simValue("Item Drop") + simValue("Food Drop");
	}
	if(itemBoozeNeed._boolean && itemDropBooze < itemBoozeNeed._float)
	{
		auto_log_debug("Trying booze drop supplements");
		addToMaximize("49booze drop " + ceil(itemBoozeNeed._float) + "max");
		simMaximize();
		itemDropBooze = simValue("Item Drop") + simValue("Booze Drop");
		//no zone item yet needs both food and booze, bottle of Chateau de Vinegar exception is a cooking ingredient but doesn't use food drop bonus
	}
	if(pass())
		return result();

	// craft equipment, even limited use, here
	if(doEverything)
	{
		//craft IOTM derivative that gives high item bonus
		if((!possessEquipment($item[A Light That Never Goes Out])) && (item_amount($item[Lump of Brituminous Coal]) > 0) && auto_is_valid($item[A Light That Never Goes Out]))
		{
			auto_buyUpTo(1, $item[third-hand lantern]);
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[third-hand lantern]);
		}

		if(auto_is_valid($item[Broken Champagne Bottle]) && get_property("garbageChampagneCharge").to_int() > 0) {
			//fold and remove maximizer block on using IOTM with 9 charges a day that doubles item drop chance
			januaryToteAcquire($item[Broken Champagne Bottle]);
		}

		string max = "500item " + (amt + 100) + "max";
		if(speculative)
		{
			simMaximizeWith(loc, max);
		}
		else
		{
			addToMaximize(max);
			simMaximize(loc);
		}
		delta = simValue("Item Drop") - numeric_modifier("Item Drop");
		auto_log_debug("With existing and crafted gear we can get to " + result());

		if(pass())
			return result();
	}

	if(doEverything && amt >= 400)
	{
		if(!get_property("_steelyEyedSquintUsed").to_boolean() && buffMaintain($effect[Steely-Eyed Squint], 0, 1, 1, speculative))
		{
			if(speculative)
				delta += delta + numeric_modifier("Item Drop");
			auto_log_debug("With Steely Eyed Squint we " + (speculative ? "can get to" : "now have") + " " + result());
		}
		if(pass())
			return result();
	}

	// Use limited resources
	if(doEverything)
	{
		if(tryEffects($effects[
		shadow waters, //200% meat, 100% item, 100% init, -10% combat
		One Very Clear Eye, //100% item
		Car-Charged, //100% meat, 100% item, 5-10MP, 50% init, 50% spell dmg, +3 stats per fight
		Incredibly Well Lit, //100% meat, 50% item
		Crunching Leaves //25% item, +5 combat
		]))
			if(pass())
				return result();
		if(zataraAvailable() && (0 == have_effect($effect[There\'s no N in Love])) & auto_is_valid($effect[There\'s no N in Love]))
		{
			if(!speculative)
			{
				zataraSeaside("item");
			}
			handleEffect($effect[There\'s no N in Love]); //50% booze/food/item
			if(pass())
				return result();			
		}
		if((get_property("sidequestArenaCompleted") == "hippy") && !get_property("concertVisited").to_boolean() && (have_effect($effect[Dilated Pupils]) == 0))
		{
			if(is_professor())
			{
				//Need to manually equip because professor
				if(!have_equipped($item[reinforced beaded headband])) equip($item[reinforced beaded headband]);
				if(!have_equipped($item[bullet-proof corduroys])) equip($item[bullet-proof corduroys]);
				if(!have_equipped($item[round purple sunglasses])) equip($item[round purple sunglasses]);
			}
			else
			{
				outfit("War Hippy Fatigues");
			}
			if(!speculative)
			{
				cli_execute("concert 2"); //20% item
			}
			handleEffect($effect[Dilated Pupils]); //20% item
			if(pass())
				return result();
		}
		if(pass())
			return result();
		if(auto_totalEffectWishesAvailable() > 0)
		{
			boolean success = true;
			int specwishes = 0;
			foreach eff in $effects[Frosty, //200% meat, 100% item, 25 ML, 100% init
			One Very Clear Eye, //100% item
			Let's Go Shopping!,  //150% meat, 75% item, -300% myst
			Always Be Collecting, //100% meat, 50% item
			Incredibly Well Lit, //100% meat, 50% item
			]{
				if(eff == $effect[Frosty] && in_wereprof()) continue; //skip frosty in wereprof
				if(have_effect(eff) == 0)
				{
					if(!speculative)
						success = auto_wishForEffect(eff);
					specwishes +=1;
					if(specwishes <= auto_totalEffectWishesAvailable())
					{
						handleEffect(eff);
						if(pass())
							return result();
					}
					else
					{
						success = false;
					}
				}
				if(!success) break;
			}
		}
		auto_log_debug("With limited buffs we can get to " + result());
		if(pass())
			return result();
	}
	return result();
}

float provideItem(int amt, boolean doEverything, boolean speculative)
{
	return provideItem(amt, my_location(), doEverything, speculative);
}

boolean provideItem(int amt, location loc, boolean doEverything)
{
	return provideItem(amt, loc, doEverything, false) >= amt;
}

boolean provideItem(int amt, boolean doEverything)
{
	return provideItem(amt, my_location(), doEverything);
}
