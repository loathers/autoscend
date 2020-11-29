
float providePlusCombat(int amt, boolean doEquips, boolean speculative) {
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
			simMaximizeWith(max);
		} else {
			addToMaximize(max);
			simMaximize();
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

	foreach eff in $effects[Driving Stealthily, The Sonata of Sneakiness] {
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

	// Now handle buffs that cost MP, items or other resources

	shrugAT($effect[Carlweather\'s Cantata Of Confrontation]);
	if (tryEffects($effects[
		Musk of the Moose,
		Carlweather's Cantata of Confrontation,
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
		Simply Irresistible
	])) {
		return result();
	}

	if(canAsdonBuff($effect[Driving Obnoxiously])) {
		if (!speculative) {
			asdonBuff($effect[Driving Obnoxiously]);
		}
		handleEffect($effect[Driving Obnoxiously]);
	}
	if(pass()) {
		return result();
	}

	return result();
}

boolean providePlusCombat(int amt, boolean doEquips)
{
	return providePlusCombat(amt, doEquips, false) >= amt;
}

boolean providePlusCombat(int amt)
{
	return providePlusCombat(amt, true);
}

float providePlusNonCombat(int amt, boolean doEquips, boolean speculative) {
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

	// Now handle buffs that cost MP, items or other resources

	shrugAT($effect[The Sonata of Sneakiness]);
	if (tryEffects($effects[
		Shelter Of Shed,
		Brooding,
		Muffled,
		Smooth Movements,
		The Sonata of Sneakiness,
		Song of Solitude,
		Inked Well,
		Bent Knees,
		Extended Toes,
		Ink Cloud,
		Cloak of Shadows,
		Chocolatesphere
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
		Celestial Camouflage
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
	if (in_zelda() && 0 == have_effect($effect[Blooper Inked]) && item_amount($item[coin]) > 400) {
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

	return result();
}

boolean providePlusNonCombat(int amt, boolean doEquips)
{
	return providePlusNonCombat(amt, doEquips, false) >= amt;
}

boolean providePlusNonCombat(int amt)
{
	return providePlusNonCombat(amt, true);
}

float provideInitiative(int amt, boolean doEquips, boolean speculative)
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
			simMaximizeWith(max);
		}
		else
		{
			addToMaximize(max);
			simMaximize();
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
			visit_url("choice.php?pwd&whichchoice=835&option=1", true);
		handleEffect($effect[Soles of Glass]);
		if(pass())
			return result();
	}

	if(tryEffects($effects[
		Adorable Lookout,
		Alacri Tea,
		All Fired Up,
		Fishy\, Oily,
		The Glistening,
		Human-Machine Hybrid,
		Patent Alacrity,
		Provocative Perkiness,
		Sepia Tan,
		Sugar Rush,
		Ticking Clock,
		Well-Swabbed Ear,
	]))
		return result();

	if(auto_sourceTerminalEnhanceLeft() > 0 && have_effect($effect[init.enh]) == 0)
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

boolean provideInitiative(int amt, boolean doEquips)
{
	return provideInitiative(amt, doEquips, false) >= amt;
}

int [element] provideResistances(int [element] amt, boolean doEquips, boolean speculative)
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

	int [element] delta;

	int result(element ele)
	{
		return numeric_modifier(ele + " Resistance") + delta[ele];
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
			simMaximizeWith(max);
		}
		else
		{
			foreach ele,goal in amt
			{
				addToMaximize("2000" + ele + " resistance " + goal + "max");
			}
			simMaximize();
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
		Scarysauce,
		Blessing of the Bird,
		Blessing of Your Favorite Bird,
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
			simMaximize();
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
		]))
			return result();
	}

	return result();
}

boolean provideResistances(int [element] amt, boolean doEquips)
{
	int [element] res = provideResistances(amt, doEquips, false);
	foreach ele, i in amt
	{
		if(res[ele] < i)
			return false;
	}
	return true;
}

float [stat] provideStats(int [stat] amt, boolean doEquips, boolean speculative)
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
			simMaximizeWith(max);
		}
		else
		{
			foreach st,goal in amt
			{
				addToMaximize("200" + st + " " + goal + "max");
			}
			simMaximize();
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
		Juiced and Loose,
		Quiet Determination,
		Power Ballad of the Arrowsmith,
		Seal Clubbing Frenzy,
		Patience of the Tortoise,
		
		// myst effects
		Mind Vision,
		Quiet Judgement,
		The Magical Mojomuscular Melody,
		Pasta Oneness,
		Saucemastery,

		// moxie effects
		Impeccable Coiffure,
		Song of Bravado,
		Disco State of Mind,
		Mariachi Mood,

		// all-stat effects
		Song of Bravado,
		Stevedave's Shanty of Superiority,

		// varying effects
		Blessing of the Bird,
		Blessing of Your Favorite Bird,
	]))
		return result();

	if(auto_have_skill($skill[Quiet Desperation]))
		tryEffects($effects[Quiet Desperation]);
	else
		tryEffects($effects[Disco Smirk]);

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

			// all-stat effects
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

boolean provideStats(int [stat] amt, boolean doEquips)
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

float provideMuscle(int amt, boolean doEquips, boolean speculative)
{
	int [stat] statsNeeded;
	statsNeeded[$stat[muscle]] = amt;
	float [stat] res = provideStats(statsNeeded, doEquips, speculative);
	return res[$stat[muscle]];
}

boolean provideMuscle(int amt, boolean doEquips)
{
	return provideMuscle(amt, doEquips, false) >= amt;
}

float provideMysticality(int amt, boolean doEquips, boolean speculative)
{
	int [stat] statsNeeded;
	statsNeeded[$stat[mysticality]] = amt;
	float [stat] res = provideStats(statsNeeded, doEquips, speculative);
	return res[$stat[mysticality]];
}

boolean provideMysticality(int amt, boolean doEquips)
{
	return provideMysticality(amt, doEquips, false) >= amt;
}

float provideMoxie(int amt, boolean doEquips, boolean speculative)
{
	int [stat] statsNeeded;
	statsNeeded[$stat[moxie]] = amt;
	float [stat] res = provideStats(statsNeeded, doEquips, speculative);
	return res[$stat[moxie]];
}

boolean provideMoxie(int amt, boolean doEquips)
{
	return provideMoxie(amt, doEquips, false) >= amt;
}

