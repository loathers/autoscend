script "auto_restore.ash";

boolean acquireMP(){
	return acquireMP(my_maxmp());
}

boolean acquireMP(int goal)
{
	return acquireMP(goal, false);
}

boolean acquireMP(int goal, boolean buyIt){
	return acquireMP(goal, buyIt, freeRestsRemaining() > 2);
}

boolean acquireMP(int goal, boolean buyIt, boolean freeRest)
{
	if(goal > my_maxmp())
	{
		return false;
	}

	if(my_mp() >= goal)
	{
		return true;
	}

	// Sausages restore 999MP, this is a pretty arbitrary cutoff but it should reduce pain
	if(my_maxmp() - my_mp() > 300)
	{
		auto_sausageEatEmUp(1);
	}

	if(freeRest){
		while(haveFreeRestAvailable() && my_mp() < goal){
			// dont waste free IotM rests since they are pretty valuable
			if((chateaumantegna_available() || auto_campawayAvailable()) && my_maxmp() - my_mp() < 100){
				int mp_waste = 125 - min(125, my_maxmp() - my_mp());
				int hp_waste = 250 - min(250, my_maxhp() - my_hp());
				if(mp_waste > 80 && hp_waste > 200){
					break;
				}
			}
			doFreeRest();
		}
	}

	item[int] recovers = List($items[Holy Spring Water, Spirit Beer, Sacramental Wine, Magical Mystery Juice, Black Cherry Soda, Doc Galaktik\'s Invigorating Tonic, Carbonated Soy Milk, Natural Fennel Soda, Grogpagne, Bottle Of Monsieur Bubble, Tiny House, Marquis De Poivre Soda, Cloaca-Cola, Phonics Down, Psychokinetic Energy Blob]);
	int at = 0;
	while((at < count(recovers)) && (my_mp() < goal))
	{
		item it = recovers[at];
		int expectedMP = (it.minmp + it.maxmp) / 2;
		int overage = (my_mp() + expectedMP) - goal;
		if(overage > 0)
		{
			float waste = overage / expectedMP;
			if(waste > 0.35)
			{
				at++;
				continue;
			}
		}

		if(!glover_usable(it))
		{
			at++;
			continue;
		}

		if(item_amount(it) > 0)
		{
			int count = item_amount(it);
			use(1, it);
			if(count == item_amount(it))
			{
				print("Failed using item " + it + "!", "red");
				return false;
			}
			continue;
		}
		at++;
	}

	while(buyIt && (my_mp() < goal))
	{
		boolean gLoverBlock = (auto_my_path() == "G-Lover");
		item goal = $item[none];

		if(($classes[Pastamancer, Sauceror] contains my_class()) && guild_store_available() && (my_level() >= 5))
		{
			goal = $item[Magical Mystery Juice];
		}
		else if((get_property("questM24Doc") == "finished") && isGeneralStoreAvailable() && (my_meat() > npc_price($item[Doc Galaktik\'s Invigorating Tonic])))
		{
			goal = $item[Doc Galaktik\'s Invigorating Tonic];
		}
		else if(black_market_available() && (my_meat() > npc_price($item[Black Cherry Soda])) && !gLoverBlock)
		{
			goal = $item[Black Cherry Soda];
		}
		else if(isGeneralStoreAvailable() && (my_meat() > npc_price($item[Doc Galaktik\'s Invigorating Tonic])))
		{
			goal = $item[Doc Galaktik\'s Invigorating Tonic];
		}

		if(goal != $item[none])
		{
			buyUpTo(1, goal, 100);
		}

		if(item_amount(goal) > 0)
		{
			int have = item_amount(goal);
			use(1, goal);
			if(have == item_amount(goal))
			{
				print("Failed using item " + goal + "!", "red");
				return false;
			}
		}
		else
		{
			break;
		}
	}

	return (my_mp() >= goal);
}

boolean acquireMP(float goalPercent){
	return acquireMP(goalPercent, false);
}

boolean acquireMP(float goalPercent, boolean buyIt){
	return acquireMP(goalPercent, buyIt, freeRestsRemaining() > 2);
}

boolean acquireMP(float goalPercent, boolean buyItm, boolean freeRest){
	int goal = my_maxmp();
	if(goalPercent > 1.0){
		goal = ceil((goalPercent/100.0) * my_maxmp());
	} else{
		goal = ceil(goalPercent*my_maxmp());
	}
	return acquireMP(goal.to_int(), buyItm, freeRest);
}

boolean acquireHP(){
	return acquireHP(my_maxhp());
}

boolean acquireHP(int goal){
	return acquireHP(goal, false);
}

boolean acquireHP(int goal, boolean buyIt){
	return acquireHP(goal, buyIt, false);
}

// TODO: not actually implemented yet
boolean acquireHP(int goal, boolean buyItm, boolean freeRest){

	static int mp_cost_multiplier = 3;

	int[skill] hp_per_cast = {
		$skill[Tongue of the Walrus]: 35,
		$skill[Cannelloni Cocoon]: 1000,
		$skill[Shake it Off]: my_maxhp(),
		$skill[Gelatinous Reconstruction]: 13
	};

	//kind of arbitrary, blood bubble helps survivability and blood bond consumes hp per adventure so i put blood bubble higher
	int[skill] blood_skill_value = {
		$skill[Blood Bubble]: 10,
		$skill[Blood Bond]: 1
	};

	skill hp_waste_blood_skill(int goal){
		int blood_bond_cost = hp_cost($skill[Blood Bond]) + ((9-hp_regen())*10);

		boolean canUseFamiliars = auto_have_familiar($familiar[Mosquito]);
		boolean bloodBondAvailable = auto_have_skill($skill[Blood Bond]) &&
			auto_have_familiar($familiar[Mosquito]) && //checks if player can use familiars in this run
			my_maxhp() > hp_cost($skill[Blood Bond]) &&
			goal > blood_bond_cost/3; // blood bond drains hp after combat, make sure we dont accidentally kill the player
		boolean bloodBubbleAvailable = auto_have_skill($skill[Blood Bubble]) &&
			my_maxhp() > hp_cost($skill[Blood Bubble]);

		skill blood_skill = $skill[none];

		if(bloodBondAvailable && bloodBubbleAvailable){
			if(have_effect($effect[Blood Bond]) > have_effect($effect[Blood Bubble])){
				blood_skill = $skill[Blood Bubble];
			} else{
				blood_skill = $skill[Blood Bond];
			}
		} else if(bloodBondAvailable){
			blood_skill = $skill[Blood Bond];
		} else if(bloodBubbleAvailable){
			blood_skill = $skill[Blood Bubble];
		}

		return blood_skill;
	}

	int hp_waste_value(int goal, int hp_waste){
		skill blood = hp_waste_blood_skill(goal);
		if(blood != $skill[none]){
			int casts = floor(hp_waste / hp_cost(blood));
			hp_waste -= (hp_cost(blood) * casts);
		}
		return hp_waste;
	}

	int effectiveness(skill s, int goal){
		if(my_hp() >= goal || !auto_have_skill(s) || !(hp_per_cast contains s) || mp_cost(s) > my_maxmp()){
			return 0;
		}

		int potential_hp_restored = min(goal - my_hp(), hp_per_cast[s]);
		int hp_wasted = hp_per_cast[s] - potential_hp_restored;
		int value = potential_hp_restored - hp_waste_value(goal, hp_wasted);

		// consider how many casts it would take to fully heal to goal
		int casts_to_max = ceil((goal - my_hp()) / hp_per_cast[s]);
		int mp_to_max = mp_cost(s)*casts_to_max;

		if(mp_to_max > my_mp()){
			// we will have to acquire extra mp somehow, which is expensive
			value -= mp_cost_multiplier * (mp_to_max-my_mp());
			value -= my_mp();
		} else{
			value -= mp_to_max;
		}

		value += mp_regen(); // we get some mp back for free, which is valuable.

		return value.to_int();
	}

	int restEffectivenessValue(int goal, boolean freeRest){
		static int[item] restored_from_dwelling = {
			$item[big rock]: 5,
			$item[Newbiesport&trade; tent]: 10,
			$item[Giant Pilgrim Hat]: 15,
			$item[Barskin Tent]: 20,
			$item[Cottage]: 30,
			$item[BRICKO pyramid]: 35,
			$item[Frobozz Real-Estate Company Instant House (TM)]: 40,
			$item[Sandcastle]: 50,
			$item[Ginormous Pumpkin]: 50,
			$item[Giant Faraday Cage]: 50,
			$item[Snow Fort]: 50,
			$item[Elevent]: 50,
			$item[House of Twigs and Spit]: 60,
			$item[Gingerbread House]: 70,
			$item[hobo fortress blueprints]: 85,
			$item[Xiblaxian residence-cube]: 100
		};

		if(haveFreeRestAvailable() || !freeRest){
			return 0;
		}

		int value = 0;
		int potential_hp_restored = restored_from_dwelling[get_dwelling()];
		int potential_mp_restored = potential_hp_restored;

		if(haveAnyIotmAlternateCampsight()){
			potential_hp_restored = 250;
			potential_mp_restored = 125;

			if(have_effect($effect[Beaten Up]) > 0){
				if(!have_skill($skill[Tongue of the Walrus])){
					value += 1000; // this is about the only way the player can remove beaten up in this case
				} else{
					value += mp_cost($skill[Tongue of the Walrus]);
				}
			} else if(!have_skill($skill[Tongue of the Walrus])){
				// try to save campground for when beaten up
				value -= 100;
			} else{
				// only a slight preference to save if they have tongue of the walrus
				value -= mp_cost($skill[Tongue of the Walrus]);
			}
		}

		int desired_max_hp_restorable = min(potential_hp_restored, goal-my_hp());
		int max_mp_restorable = min(potential_mp_restored, my_maxmp()-my_mp());

		value += desired_max_hp_restorable;
		value += max_mp_restorable * mp_cost_multiplier; // mp is pretty valuable

		// remove waste hp/mp from the value
		value -= hp_waste_value(goal, potential_hp_restored - desired_max_hp_restorable);
		value -= (potential_mp_restored - max_mp_restorable) * mp_cost_multiplier; // like I said, mp is pretty valuable

		return value;
	}

	int[string] allEffectivenessValues(int goal, boolean buyItm, boolean freeRest){
		int[string] values;
		values["rest"] = restEffectivenessValue(goal, freeRest);

		foreach s, _ in hp_per_cast {
			values[s.to_string()] = effectiveness(s, goal);
		}

		return values;
	}

	boolean restingIsMostEffective(int goal, boolean buyItm, boolean freeRest){
		int value = restEffectivenessValue(goal, freeRest);
		print("Rest effectivenes calculated at: " + value);

		int[string] effectiveness = allEffectivenessValues(goal, buyItm, freeRest);
		foreach s, v in effectiveness{
			if(v > effectiveness["rest"]){
				return false;
			}
		}
		return true;
	}

	skill mostEffectiveSkill(int goal){
		skill best = $skill[none];
		int value = 0;

		foreach s, _ in hp_per_cast {
			int e = effectiveness(s, goal);
			if(best == $skill[none] && e > value){
				best = s;
				value = e;
			}
		}
		return best;
	}

	boolean use_blood_skill(int goal, int hp_waste){
		skill blood = hp_waste_blood_skill(goal);

		if(blood == $skill[none]){
			return false;
		}

		while(my_hp() - hp_cost(blood) > 0 && hp_waste - hp_cost(blood) > 0){
			use_skill(1, blood);
			hp_waste -= hp_cost(blood);
			blood = hp_waste_blood_skill(goal);
		}
		return true;
	}

	boolean use_healing_skill(skill s, int goal, boolean buyItm){
		if(my_hp() >= goal || s == $skill[none] || !have_skill(s) || !(hp_per_cast contains s)){
			return false;
		}

		if(my_mp() < mp_cost(s) && !acquireMP(mp_cost(s)-my_mp(), buyItm, false)){
			print("Couldnt acquire enough mp to cast " + s);
			return false;
		}

		int potential_hp_restored = min(goal - my_hp(), hp_per_cast[s]);
		use_blood_skill(goal, hp_per_cast[s] - potential_hp_restored);
		return use_skill(1, s);
	}

	if(goal > my_maxhp()){
		goal = my_maxhp();
	}

	// let mafia figure out how to best remove beaten up
	if(have_effect($effect[Beaten Up]) > 0){
		print("Ouch, you got beaten up. Lets get you patched up, if we can.");
		uneffect($effect[Beaten Up]);

		if(have_effect($Effect[Beaten Up]) > 0){
			print("Well, you're still beaten up, thats probably not great...", "red");
		}
	}

	print("Target HP => "+goal+" - Considering healing options at " + my_hp() + "/" + my_maxhp() + " HP with " + my_mp() + "/" + my_maxmp() + " MP", "blue");
	while(my_hp() < goal){
		skill healing = mostEffectiveSkill(goal);
		if(restingIsMostEffective(goal, buyItm, freeRest)){
			print("Using rest (effectiveness value: "+ restEffectivenessValue(goal, freeRest) +", free: " + haveFreeRestAvailable() + ")");
			doRest();
		} else if(healing != $skill[none]){
			print("Using " + healing + " (effectiveness value: " + effectiveness(healing, goal) + ")");
			use_healing_skill(healing, goal, buyItm);
		} else{
			print("Uh, couldnt determine an effective healing mechanism. Sorry.", "red");
			return false;
		}
	}

	return true;
}

boolean acquireHP(float goalPercent){
	return acquireHP(goalPercent, false);
}

boolean acquireHP(float goalPercent, boolean buyItm){
	return acquireHP(goalPercent, buyItm, freeRestsRemaining() > 2);
}

boolean acquireHP(float goalPercent, boolean buyItm, boolean freeRest){
	int goal = my_maxhp();
	if(goalPercent > 1.0){
		goal = ceil((goalPercent/100.0) * my_maxhp());
	} else{
		goal = ceil(goalPercent*my_maxhp());
	}
	return acquireHP(goal.to_int(), buyItm, freeRest);
}

/*
 * Use a rest (can consume adventures if no free rests remain). Also attempts to maximize
 * chateau bonus from resting if possible.
 *
 * TODO: if resting in campaway camp, check if we can/should use a burnt stick to get extra stats
 *
 * returns the number of times rested today (caller will have to work out if it rested or not)
 */
int doRest()
{
	if(chateaumantegna_available())
	{
		cli_execute("outfit save Backup");
		chateaumantegna_nightstandSet();

		boolean[item] restBonus = chateaumantegna_decorations();
		stat bonus = $stat[none];
		if(restBonus contains $item[Electric Muscle Stimulator])
		{
			bonus = $stat[Muscle];
		}
		else if(restBonus contains $item[Foreign Language Tapes])
		{
			bonus = $stat[Mysticality];
		}
		else if(restBonus contains $item[Bowl of Potpourri])
		{
			bonus = $stat[Moxie];
		}

		boolean closet = false;
		item grab = $item[none];
		item replace = $item[none];
		switch(bonus)
		{
		case $stat[Muscle]:
			replace = equipped_item($slot[off-hand]);
			grab = $item[Fake Washboard];
			if(can_equip($item[LOV Eardigan]) && (item_amount($item[LOV Eardigan]) > 0))
			{
				equip($slot[shirt], $item[LOV Eardigan]);
			}
			break;
		case $stat[Mysticality]:
			replace = equipped_item($slot[off-hand]);
			grab = $item[Basaltamander Buckler];
			if(can_equip($item[LOV Epaulettes]) && (item_amount($item[LOV Epaulettes]) > 0))
			{
				equip($slot[back], $item[LOV Epaulettes]);
			}
			break;
		case $stat[Moxie]:
			replace = equipped_item($slot[weapon]);
			grab = $item[Backwoods Banjo];
			if(can_equip($item[LOV Earrings]) && (item_amount($item[LOV Earrings]) > 0))
			{
				equip($slot[acc1], $item[LOV Earrings]);
			}
			break;
		}

		if((grab != $item[none]) && possessEquipment(grab) && (replace != grab) && can_equip(grab))
		{
			equip(grab);
		}
		if(!possessEquipment(grab) && (replace != grab) && (closet_amount(grab) > 0) && can_equip(grab))
		{
			closet = true;
			take_closet(1, grab);
			equip(grab);
		}

		visit_url("place.php?whichplace=chateau&action=chateau_restbox");

		if((replace != grab) && (replace != $item[none]))
		{
			equip(replace);
		}
		cli_execute("outfit Backup");
		if(closet)
		{
			if(item_amount(grab) > 0)
			{
				put_closet(1, grab);
			}
		}

	}
	else
	{
		set_property("restUsingChateau", false);
		cli_execute("rest");
		set_property("restUsingChateau", true);
	}
	return get_property("timesRested").to_int();
}

boolean haveFreeRestAvailable(){
	return get_property("timesRested").to_int() < total_free_rests();
}

int freeRestsRemaining(){
	return max(0, total_free_rests() - get_property("timesRested").to_int());
}

boolean haveAnyIotmAlternateCampsight(){
	return chateaumantegna_available() || auto_campawayAvailable();
}

/*
 * Try to use a free rest.
 *
 * returns true if a rest was used false if it wasnt (for any reason)
 */
boolean doFreeRest(){
	if(haveFreeRestAvailable()){
		int rest_count = get_property("timesRested").to_int();
		return doRest() > rest_count;
	}
	return false;
}

/*
 * Do a rest if the conditions are met. If either hp or mp remaining is below
 * their respective thesholds, it will try to rest.
 *
 * hp_threshold is the percent of hp (out of 1.0, e.g. 0.8 = 80%) below which it will try to rest
 * mp_threshold is the percent of mp (out of 1.0, e.g. 0.8 = 80%) below which it will try to rest
 * freeOnly will only try to rest if it is free when set to true, otherwise will always rest if the above thesholds are met
 *
 * returns true if a rest was used, false if it wasnt (for any reason)
 */
boolean doRest(float hp_threshold, float mp_threshold, boolean freeOnly){
	float hp_percent = 1.0 - ((my_maxhp() - my_hp()) / my_maxhp());
	float mp_percent = 1.0 - ((my_maxmp() - my_mp()) / my_maxmp());
	if(hp_percent < hp_threshold || mp_percent < mp_threshold){
		if(freeOnly){
			return doFreeRest();
		} else{
			int rest_count = get_property("timesRested").to_int();
			return doRest() > rest_count;
		}
	}
	return false;
}

float mp_regen()
{
	return 0.5 * (numeric_modifier("MP Regen Min") + numeric_modifier("MP Regen Max"));
}

float hp_regen()
{
	return 0.5 * (numeric_modifier("HP Regen Min") + numeric_modifier("HP Regen Max"));
}

boolean uneffect(effect toRemove)
{
	if(have_effect(toRemove) == 0)
	{
		return true;
	}
	if(($effects[Driving Intimidatingly, Driving Obnoxiously, Driving Observantly, Driving Quickly, Driving Recklessly, Driving Safely, Driving Stealthily, Driving Wastefully, Driving Waterproofly] contains toRemove) && (auto_get_campground() contains $item[Asdon Martin Keyfob]))
	{
		string temp = visit_url("campground.php?pwd=&preaction=undrive");
		return true;
	}

	if(cli_execute("uneffect " + toRemove))
	{
		//Either we don\'t have the effect or it is shruggable.
		return true;
	}

	if(item_amount($item[Soft Green Echo Eyedrop Antidote]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		print("Effect removed by Soft Green Echo Eyedrop Antidote.", "blue");
		return true;
	}
	else if(item_amount($item[Ancient Cure-All]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		print("Effect removed by Ancient Cure-All.", "blue");
		return true;
	}
	return false;
}

boolean useCocoon()
{
	if((have_effect($effect[Beaten Up]) > 0 || my_maxhp() <= 70) && have_skill($skill[Tongue Of The Walrus]) && my_mp() >= mp_cost($skill[Tongue Of The Walrus]))
	{
		use_skill(1, $skill[Tongue Of The Walrus]);
	}

	if(my_hp() >= my_maxhp())
	{
		return true;
	}

	int mpCost = 0;
	int casts = 1;
	skill cocoon = $skill[none];
	if(have_skill($skill[Cannelloni Cocoon]))
	{
		print("Considering using Cocoon at " + my_hp() + "/" + my_maxhp() + " HP with " + my_mp() + "/" + my_maxmp() + " MP", "blue");

		boolean canUseFamiliars = have_familiar($familiar[Mosquito]);
		skill blood_skill = $skill[none];
		if(auto_have_skill($skill[Blood Bubble]) && auto_have_skill($skill[Blood Bond]))
		{
			if(have_effect($effect[Blood Bubble]) > have_effect($effect[Blood Bond]) && canUseFamiliars)
			{
				blood_skill = $skill[Blood Bond];
			}
			else
			{
				blood_skill = $skill[Blood Bubble];
			}
		}
		else if(auto_have_skill($skill[Blood Bubble]))
		{
			blood_skill = $skill[Blood Bubble];
		}
		else if(auto_have_skill($skill[Blood Bond]) && canUseFamiliars)
		{
			blood_skill = $skill[Blood Bond];
		}
		cocoon = $skill[Cannelloni Cocoon];
		mpCost = mp_cost(cocoon);
		int hpNeed = ceil((my_maxhp() - my_hp()) / 1000.0);
		int maxCasts = my_mp() / mpCost;
		casts = min(hpNeed, maxCasts);
		if(auto_beta() && blood_skill != $skill[none] && casts > 0)
		{
			int healto = my_hp() + 1000 * casts;
			int wasted = min(max(healto - my_maxhp(), 0), my_hp() - 1);
			int blood_casts = wasted / 30;
			use_skill(blood_casts, blood_skill);
		}
	}
	else if(have_skill($skill[Shake It Off]))
	{
		cocoon = $skill[Shake It Off];
		mpCost = mp_cost(cocoon);
	}
	else if(have_skill($skill[Gelatinous Reconstruction]))
	{
		cocoon = $skill[Gelatinous Reconstruction];
		mpCost = mp_cost(cocoon);
		int hpNeed = (my_maxhp() - my_hp()) / 15;
		int maxCasts = my_mp() / mpCost;
		int worst = min(hpNeed, maxCasts);
		casts = min(worst, 7);
	}

	if(cocoon == $skill[none])
	{
		return false;
	}
	if(casts > 0 && my_mp() >= (mpCost * casts))
	{
		use_skill(casts, cocoon);
		return true;
	}
	return false;
}
