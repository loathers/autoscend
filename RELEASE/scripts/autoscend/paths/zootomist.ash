static int ZOOPART_NONE       = 0;
static int ZOOPART_HEAD       = 1;
static int ZOOPART_L_SHOULDER = 2;
static int ZOOPART_R_SHOULDER = 3;
static int ZOOPART_L_HAND     = 4;
static int ZOOPART_R_HAND     = 5;
static int ZOOPART_R_NIPPLE   = 6;
static int ZOOPART_L_NIPPLE   = 7;
static int ZOOPART_L_BUTTOCK  = 8;
static int ZOOPART_R_BUTTOCK  = 9;
static int ZOOPART_L_FOOT     = 10;
static int ZOOPART_R_FOOT     = 11;

boolean in_zootomist()
{
	return my_path()==$path[z is for zootomist];
}

int zoo_specimenPreparationsLeft()
{
	if (!in_zootomist()) { return 0; }
	int zoo_grafts_allowed = min(11,get_property("zootomistPoints").to_int()+1);
	return zoo_grafts_allowed-get_property("zootSpecimensPrepared").to_int();
}

boolean zoo_prepareSpecimen()
{
	familiar f = my_familiar();
	if (!in_zootomist()) { return false; }
	if (zoo_specimenPreparationsLeft() > 0)
	{
		visit_url("place.php?whichplace=graftinglab&action=graftinglab_prep");
		visit_url("choice.php?pwd=&whichchoice=1555&option=1", true);
		refresh_status();
		int new_exp = f.experience;
		int new_weight = familiar_weight(f);
		handleTracker(f,"Specimen prepared to "+f.experience+" XP {"+new_weight+" lb}","auto_tracker_path");
		return true;
	}
	return false;
}

void zoo_startPulls()
{
	if (!in_zootomist() || pulls_remaining()==0) { return; }
	if (!have_skill($skill[just the facts]) && auto_is_valid($skill[just the facts])) {
		pullXWhenHaveY($item[book of facts (dog-eared)], 1, 0);
		if (available_amount($item[book of facts (dog-eared)])>0) {use($item[book of facts (dog-eared)]);}
	}
	if (!have_skill($skill[perpetrate mild evil]) && auto_is_valid($skill[perpetrate mild evil])) {
		pullXWhenHaveY($item[Pocket Guide to Mild Evil (used)], 1, 0);
		if (available_amount($item[Pocket Guide to Mild Evil (used)])>0) {use($item[Pocket Guide to Mild Evil (used)]);}
	}
	if (available_amount($item[iflail])==0 && auto_is_valid($item[iflail])) {
		pullXWhenHaveY($item[iflail], 1, 0);
	}
}

void zoo_d2Pulls()
{
	if (!in_zootomist() || pulls_remaining()==0) { return; }
	
	// Pull enough ML for oil peak, we need a provider function here.
	int ml_target = 100.0;
	simMaximizeWith("monster level");
	int curr_ml = numeric_modifier($modifier[monster level]);
	
	// Function to try pulling an ML item, if it improves our ML by at least 10 over best alternative.
	float try_ml_pull(item it) {
		if (!can_equip(it) || (available_amount(it)>0) || !auto_is_valid(it)) { return 0; }
		modifier m = $modifier[monster level];
		slot s = to_slot(it);
		int[item] alternatives = auto_getAllEquipabble(s);
		item[int] ranked_alternatives = auto_sortedByModifier(alternatives,m);
		int islot = (s==$slot[acc1] ? 2 : 0); // we want to compare to our third best item for accessories
		item curr_best_in_slot = count(ranked_alternatives)>islot ? ranked_alternatives[islot] : $item[none];
		float curr_best_mod = numeric_modifier(curr_best_in_slot, m);
		float improvement = numeric_modifier(it,m) - curr_best_mod;
		if (improvement > 10) {
			pullXWhenHaveY(it, 1, 0);
			if (available_amount(it) > 0) { return improvement; }
		}
		return 0;
	}
	// Good ML boosting items. Vinyl Shield is lower than you might think because it can't be wielded with unstable fulminate.
	foreach it in $items[hairshirt, hockey stick of furious angry rage, stainless steel scarf, Porcelain pelerine,
	  Bakelite backpack, brown pirate pants, mer-kin headguard, vinyl shield, red shirt, iFlail]
	{
		if (curr_ml >= ml_target) {break;}
		curr_ml += try_ml_pull(it);
	}
	return;
}

familiar zoo_graftedToPart(int bodyPart)
{
	switch(bodyPart)
	{
		case ZOOPART_HEAD:
			return get_property("zootGraftedHeadFamiliar").to_int().to_familiar();
		case ZOOPART_L_SHOULDER:
			return get_property("zootGraftedShoulderLeftFamiliar").to_int().to_familiar();
		case ZOOPART_R_SHOULDER:
			return get_property("zootGraftedShoulderRightFamiliar").to_int().to_familiar();
		case ZOOPART_L_HAND:
			return get_property("zootGraftedHandLeftFamiliar").to_int().to_familiar();
		case ZOOPART_R_HAND:
			return get_property("zootGraftedHandRightFamiliar").to_int().to_familiar();
		case ZOOPART_R_NIPPLE:
			return get_property("zootGraftedNippleRightFamiliar").to_int().to_familiar();
		case ZOOPART_L_NIPPLE:
			return get_property("zootGraftedNippleLeftFamiliar").to_int().to_familiar();
		case ZOOPART_L_BUTTOCK:
			return get_property("zootGraftedButtCheekLeftFamiliar").to_int().to_familiar();
		case ZOOPART_R_BUTTOCK:
			return get_property("zootGraftedButtCheekRightFamiliar").to_int().to_familiar();
		case ZOOPART_L_FOOT:
			return get_property("zootGraftedFootLeftFamiliar").to_int().to_familiar();
		case ZOOPART_R_FOOT:
			return get_property("zootGraftedFootRightFamiliar").to_int().to_familiar();
		default:
			return $familiar[none];
	}
}

familiar[int] zoo_graftedFams()
{
	familiar[int] fams;
	for (int i = 1 ; i < 12 ; i++) {fams[i] = zoo_graftedToPart(i);}
	return fams;
}

boolean[familiar] zoo_graftedIntrinsicFams()
{
	boolean[familiar] fams;
	void check(int part)
	{
		familiar f = zoo_graftedToPart(part);
		if (f!=$familiar[none]) {fams[f] = true;}
	}
	check(ZOOPART_HEAD);
	check(ZOOPART_L_SHOULDER);
	check(ZOOPART_R_SHOULDER);
	check(ZOOPART_L_BUTTOCK );
	check(ZOOPART_R_BUTTOCK );
	return fams;
}

boolean zoo_isGrafted(familiar f)
{
	if (f==$familiar[none]) { return false; }
	foreach i,fam in zoo_graftedFams()
	{
		if (fam==f) { return true ;}
	}
	return false;
}

int [int] zoo_getBodyPartPriority()
{
	int [int] priority;
	if(auto_have_familiar($familiar[burly bodyguard]) || zoo_isGrafted($familiar[burly bodyguard]))
	{
		priority = {ZOOPART_L_NIPPLE,
		ZOOPART_R_NIPPLE,
		ZOOPART_L_FOOT,
		ZOOPART_HEAD,
		ZOOPART_L_HAND,
		ZOOPART_L_SHOULDER,
		ZOOPART_R_SHOULDER,
		ZOOPART_L_BUTTOCK,
		ZOOPART_R_HAND,
		ZOOPART_R_BUTTOCK,
		ZOOPART_R_FOOT};
	}
	else
	{
		priority = {ZOOPART_L_NIPPLE,
		ZOOPART_R_NIPPLE,
		ZOOPART_L_FOOT,
		ZOOPART_HEAD,
		ZOOPART_L_HAND,
		ZOOPART_L_SHOULDER,
		ZOOPART_R_SHOULDER,
		ZOOPART_L_BUTTOCK,
		ZOOPART_R_BUTTOCK,
		ZOOPART_R_FOOT,
		ZOOPART_R_HAND};
	}
	return priority;
}

familiar zoo_getBestFam(int bodyPart)
{
	return zoo_getBestFam(bodyPart, false);
}

familiar zoo_getBestFam(int bodyPart, boolean verbose)
{
	//Identifies the 11 familiars we want based on what we have and stores them in prefs so we only go through the list of fams once
	//Goes through fam attributes of all familiars and filters from there
	string[familiar] famAttributes;
	//priority, familiar
	float[familiar] intrinsicFams;
	float[familiar] punchFams;
	float[familiar] lbuffFams;
	float[familiar] rbuffFams;
	float[familiar] kickFams;
	//Weights for familiar priority. These are based off of our default maximizer statement
	float[string] intrinsicWeights = { 
		"technological": 100, //20% item drop
		"haseyes": 75, //15% item drop
		"object": 25, //5% item drop
		"hashands": 20, //20% meat drop
		"hasclaws": 20, //20% meat drop
		"bite": 15, //15% meat drop
		"animal": 10, //10% meat drop
		"haswings": 12.5, //50% initiative
		"haslegs": 12.5, //50% initiative
		"fast": 12.5, //50% initiative
		"animatedart": 12.5, //50% initiative
		"robot": 10, //10 DR
		"polygonal": 10, //10 DR
		"hasshell": 10, //10 DR
		"hasbones": 5, //5 DR
		"food": 0.5, //1 stench res
		"hasstinger": 0.5, //1 stench res
		"good": 0.5, //1 spooky res
		"evil": 0.5, //1 spooky res
		"reallyevil": 0.5, //1 spooky res
		"hard": 0.5, //1 sleaze res
		"phallic": 0.5, //1 sleaze res
		"edible": 0.5, //1 sleaze res
		"cute": 0.5, //1 sleaze res
		"mineral": 0.5, //1 hot res
		"swims": 0.5, //1 hot res
		"aquatic": 0.5, //1 hot res
		"vegetable": 0.5, //1 cold res
		"wearsclothes": 0.5, //1 cold res
		"isclothes": 0.5, //1 cold res
		"flies": 1, //never fumble
		"insect": 10, //25 max hp
		"software": 10, //25 max hp
		"person": 8, //20 max hp
		"undead": 8, //20 max hp
		"humanoid": 6, //15 max hp
		"organic": 4, //10 max hp
		"sentient": 2, //5 max hp
		"orb": 5, //25 max mp
		"cold": 15, //10 cold dmg
		"hasbeak": 0, //10 weapon dmg. Won't use in zootomist
		"hot": 15, //10 hot dmg
		"sleaze": 15, //10 sleaze dmg
		"spooky": 15, //10 spooky dmg
		"stench": 15, //10 stench dmg
		"cantalk": 1, //-1mp for skills
	};
	float[string] lNipWeights = { 
		"animal": 2.5, //25 hp regen
		"animatedart": 0.5, //50% moxie
		"aquatic": 1, //2 hot res
		"bite": 30, //sleaze dmg
		"cantalk": 37.5, //25% myst
		"cold": 30, //20 cold dmg
		"edible": 20, //20 muscle
		"evil": 0, //10 weapon dmg. Won't use in zootomist
		"fast": 150, //30% item drop
		"flies": 12.5, //50% initiative
		"food": 30, //20 stench dmg
		"good": 5, //50% dmg to skeletons
		"hard": 5, //25% weapon drop
		"hasbeak": 150, //30% food drop
		"hasbones": 2.5, //25% dmg to skeletons
		"hasclaws": 4, //20% crit rate
		"haseyes": 2, //4 spooky res
		"hashands": 15, //15 meat drop
		"haslegs": 10, //50% pant drop
		"hasshell": 20, //20 DR
		"hasstinger": 15, //10 spooky dmg
		"haswings": 20, //20 myst
		"hot": 15, //10 hot dmg
		"hovers": 250, //-5% combat
		"insect": 6.25, //25% init
		"isclothes": 2, //4 cold res
		"object": 40, //100 maxhp
		"organic": 500, //+1 fam exp
		"person": 1, //2 stench res
		"phallic": 10, //10 moxie
		"polygonal": 2, //4 sleaze res
		"reallyevil": 250, //-5 combat
		"robot": 37.5, //25% muscle
		"sentient": 10, //5 fam weight
		"sleaze": 50, //50% booze drop
		"software": 10, //50% max mp
		"stench": 5, //50% dmg to zombies
		"technological": 45, //10-20mp per turn
		"undead": 3, //30 dmg to undead
		"vegetable": 2, //20 familiar dmg
		"wearsclothes": 10, //50% gear drop
	};
	float[string] rNipWeights = { 
		"animal": 15, //10 stench dmg
		"animatedart": 1, //2 spooky res
		"aquatic": 10, //10 muscle
		"bite": 0, //weapon dmg. Won't use in zootomist
		"cantalk": 20, //100% max mp
		"cold": 2, //4 hot res
		"cute": 37.5, //25% moxie
		"edible": 150, //30% booze drops
		"evil": 30, //20 spooky dmg
		"fast": 25, //100% initiative
		"flies": 20, //20 moxie
		"food": 250, //50% food drops
		"good": 20, //10 fam weight
		"hard": 75, //50% muscle
		"hasbones": 5, //50% dmg to skeletons
		"hasclaws": 10, //50% weapon drop
		"haseyes": 25, //+5% combat
		"hashands": 75, //15% item drop
		"haslegs": 5, //25% gear drop
		"hasshell": 20, //20 DR
		"hasstinger": 2, //2x crit hit chance
		"haswings": 12.5, //50% init
		"hot": 1, //2 cold res
		"insect": 500, //1 fam exp
		"isclothes": 5, //25% pant drop
		"mineral": 20, //20 DR
		"object": 2, //4 stench res
		"orb": 10, //10 myst
		"organic": 1, //10 fam dmg
		"person": 30, //30% meat drop
		"phallic": 5, //5 pool skill
		"polygonal": 15, //10 sleaze dmg
		"reallyevil": 0, //20 weapon dmg. Won't use in zootomist
		"robot": 30, //20 hot dmg
		"sentient": 75, //50% myst
		"software": 75, //20-30 mp regen
		"spooky": 5, //50 ghost dmg
		"stench": 25, //+5% combat
		"swims": 15, //10 cold dmg
		"technological": 15, //10-20 hp regen
		"undead": 3, //30 dmg to undead
		"vegetable": 1, //2 sleaze res
		"wearsclothes": 50, //50% max hp
	};
	string[string] footParam = {
		"bite": "instakill",
		"cute": "instakill",
		"evil": "instakill",
		"food": "instakill",
		"hasstinger": "instakill",
		"object": "instakill",
		"reallyevil": "instakill",
		"stench": "instakill",
		"animatedart": "banish",
		"hard": "banish",
		"hasbones": "banish",
		"haslegs": "banish",
		"haswings": "banish",
		"spooky": "banish",
		"swims": "banish",
		"vegetable": "banish",
		"hasbeak": "pp",
		"hasclaws": "pp",
		"hashands": "pp",
		"isclothes": "pp",
		"polygonal": "pp",
		"sleaze": "pp",
		"technological": "pp",
		"wearsclothes": "pp",
		"aquatic": "heal",
		"cold": "heal",
		"edible": "heal",
		"good": "heal",
		"organic": "heal",
		"person": "heal",
		"phallic": "heal",
		"undead": "heal",
		"animal": "sniff",
		"haseyes": "sniff",
		"hot": "sniff",
		"humanoid": "sniff",
		"mineral": "sniff",
		"orb": "sniff",
		"sentient": "sniff",
		"software": "sniff"
	};
	int[string] footWeights = {
		"instakill": 10,
		"banish": 10,
		"pp": 5,
		"heal": 5,
		"sniff": 5
	};
	boolean[familiar] blacklistFams = $familiars[reassembled blackbird, reconstituted crow, homemade robot];
	foreach fam in $familiars[]
	{
		//comment out below line and uncomment second below line to see all unrestricted fams
		if(auto_have_familiar(fam) && !(blacklistFams contains fam))
		//if(is_unrestricted(fam))
		{
			famAttributes[fam] = fam.attributes;
		}
	}
	foreach fam, attr in famAttributes
	{
		string[int] attrs = split_string(attr,"; ");
		//buffs
		foreach k, a in attrs
		{
			intrinsicFams[fam] += intrinsicWeights[a];
			lbuffFams[fam] += lNipWeights[a];
			rbuffFams[fam] += rNipWeights[a];
			kickFams [fam] += footWeights[footParam[a]];
		}
	}
	
	// Function for sorting familiars by their weights
	familiar[int] sortFams(float[familiar] map)
	{
		// Make an indexed list of the familiars
		familiar[int] ranked_list;
		foreach entry in map
		{
			ranked_list[count(ranked_list)] = entry;
		}
		// Sort by their weight, high to low
		sort ranked_list by -map[value];
		return ranked_list;
	}
	
	boolean[familiar] used;
	familiar[int] intrinsicFam;
	familiar lbuffFam  = zoo_graftedToPart(ZOOPART_L_NIPPLE);
	familiar rbuffFam  = zoo_graftedToPart(ZOOPART_R_NIPPLE);
	familiar lkickFam  = zoo_graftedToPart(ZOOPART_L_FOOT);
	familiar rkickFam  = zoo_graftedToPart(ZOOPART_R_FOOT);
	familiar lpunchFam = zoo_graftedToPart(ZOOPART_L_HAND);
	familiar rpunchFam = zoo_graftedToPart(ZOOPART_R_HAND);
	
	if (rbuffFam == $familiar[none])
	{
		foreach i,fam in sortFams(rbuffFams)
		{
			if (!(used contains fam))
			{
				rbuffFam = fam;
				used[fam] = true;
				break;
			}
		}
	}
	
	if (lbuffFam == $familiar[none])
	{
		foreach i,fam in sortFams(lbuffFams)
		{
			if (!(used contains fam))
			{
				lbuffFam = fam;
				used[fam] = true;
				break;
			}
		}
	}
	
	if (lkickFam == $familiar[none])
	{
		foreach fam in $familiars[quantum entangler, foul ball, Defective Childrens' Stapler]
		{
			if(auto_have_familiar(fam))
			{
				lkickFam = fam;
				used[fam] = true;
				break;
			}
		}
	}
	
	if (lkickFam == $familiar[none])
	{
		foreach i,fam in sortFams(kickFams)
		{
			if (!(used contains fam))
			{
				lkickFam = fam;
				used[fam] = true;
				break;
			}
		}
	}
	
	int intrinsic_index = 0;
	foreach i,fam in sortFams(intrinsicFams)
	{
		// We only need enough to fill our empty graft slots
		if (count(intrinsicFam)>=5-count(zoo_graftedIntrinsicFams()))
		{
			break;
		}
		if (!(used contains fam))
		{
			intrinsicFam[intrinsic_index++] = fam;
			used[fam] = true; // should probably not add to used if we already have grafts that will prevent this ever being used
		}
	}
	
	// Right kick banishes (cassava and limb are super-banishes, magimech is OK)
	if (rkickFam == $familiar[none])
	{
		foreach fam in $familiars[dire cassava, phantom limb, MagiMechTech MicroMechaMech]
		{
			if(auto_have_familiar(fam))
			{
				rkickFam = fam;
				used[fam] = true;
				break;
			}
		}
	}
	
	// Backup right kick options
	if (rkickFam == $familiar[none])
	{
		foreach i,fam in sortFams(kickFams)
		{
			if (!(used contains fam))
			{
				rkickFam = fam;
				used[fam] = true;
				break;
			}
		}
	}
	
	// Punch familiars, hardcoded for now.
	// Barrrnacle can kill everything in-run, so a good default choice
	// Burly bodyguard levels up with AG path progression so can be grafted faster.
	// Cold cut is a pure cold punch, can be useful for certain monsters (smorcs, war boss)
	// volleyball and mosquito and fairyas backups. Everybody needs somebody to punch.
	familiar[int] punchPotential;
	int ipunch = 0;
	foreach fam in $familiars[barrrnacle, cold cut, blood-faced volleyball, mosquito, baby gravy fairy]
	{
		if (ipunch == 1 && auto_have_familiar($familiar[burly bodyguard])) {
			punchPotential[ipunch++] = $familiar[burly bodyguard];
		}
		punchPotential[ipunch++] = fam;
	}
		
	for (int ifam = 0 ; ifam < count(punchPotential) ; ifam++)
	{
		familiar fam = punchPotential[ifam];
		if(auto_have_familiar(fam) && (!(used contains fam)))
		{
			if(lpunchFam==$familiar[none])
			{
				lpunchFam = fam;
				used[fam] = true;
			}
			else if(rpunchFam==$familiar[none])
			{
				rpunchFam = fam;
				used[fam] = true;
			}
		}
	}

	if(verbose)
	{
		auto_log_info("Best Right nipple fams", "purple");
		auto_log_info(rbuffFam + ":" + rbuffFams[rbuffFam], "purple");
		auto_log_info("Best Left nipple fams", "blue");
		auto_log_info(lbuffFam + ":" + lbuffFams[lbuffFam], "blue");
		auto_log_info("Best Left Foot Fam", "green");
		auto_log_info(lkickFam + ":" + kickFams[lkickFam], "green");
		auto_log_info("Best Head, Shoulder, and Butt Fam", "orange");
		if (count(intrinsicFam)>0)
		{
			foreach i, fam in intrinsicFam
			{
				auto_log_info(fam + ":" + intrinsicFams[fam], "orange");
			}
		}
		else
		{
			auto_log_info("All slots occupied", "orange");
		}
		auto_log_info("Best Right Foot Fam", "green");
		auto_log_info(rkickFam + ":" + kickFams[rkickFam], "red");
		auto_log_info("Best Left Hand Fam", "red");
		auto_log_info(lpunchFam, "red");
		auto_log_info("Best Right Hand Fam", "red");
		auto_log_info(rpunchFam, "red");
	}
	
	familiar bestIntrinsicFam = intrinsicFam[0];
	switch(bodyPart)
	{
		case ZOOPART_HEAD:
		case ZOOPART_L_SHOULDER:
		case ZOOPART_R_SHOULDER:
		case ZOOPART_L_BUTTOCK:
		case ZOOPART_R_BUTTOCK:
			return bestIntrinsicFam;
		case ZOOPART_L_HAND:
			return lpunchFam;
		case ZOOPART_R_HAND:
			return rpunchFam;
		case ZOOPART_L_NIPPLE:
			return lbuffFam;
		case ZOOPART_R_NIPPLE:
			return rbuffFam;
		case ZOOPART_L_FOOT:
			return lkickFam;
		case ZOOPART_R_FOOT:
			return rkickFam;
	}
	return $familiar[none];
}

int zoo_getNextPart()
{
	if (!in_zootomist() || my_level() > 11) {return ZOOPART_NONE;}
	int[int] bpp = zoo_getBodyPartPriority();
	for (int ipart = 0 ; ipart < count(bpp) ; ipart++)
	{
		int part = bpp[ipart];
		if (zoo_graftedToPart(part) == $familiar[none]) { return part; }
	}
	return ZOOPART_NONE;
}

familiar zoo_getNextFam()
{
	if (!in_zootomist() || my_level() > 11) {return $familiar[none];}
	return zoo_getBestFam(zoo_getNextPart(), false);
}

boolean zoo_graftFam()
{
	if (!in_zootomist() || my_level()>=13)
	{
		return false;
	}
	/*Body parts are identified by number
	1 = head
	2 = left shoulder
	3 = right shoulder
	4 = left hand
	5 = right hand
	6 = right nipple
	7 = left nipple
	8 = left butt cheek
	9 = right butt cheek
	10 = left foot
	11 = right foot
	Each body part is categorized by what it gives when a familiar is grafted to it.
	intrinsic provides the intrinsic buff and adds to it.
	punch is a combat damage skill
	lbuff is left nipple buff
	rbuff is right nipple buff
	combat is a useful combat skill (yr, olfact, banish)
	*/
	string[int] bodyPartType = {
		ZOOPART_HEAD       : "intrinsic",
		ZOOPART_L_SHOULDER : "intrinsic",
		ZOOPART_R_SHOULDER : "intrinsic",
		ZOOPART_L_HAND     : "punch",
		ZOOPART_R_HAND     : "punch",
		ZOOPART_L_NIPPLE   : "lbuff",
		ZOOPART_R_NIPPLE   : "rbuff",
		ZOOPART_L_BUTTOCK  : "intrinsic",
		ZOOPART_R_BUTTOCK  : "intrinsic",
		ZOOPART_L_FOOT     : "kick",
		ZOOPART_R_FOOT     : "kick"
	};
	string[int] bodyPartName = {
		ZOOPART_HEAD       : "head",
		ZOOPART_L_SHOULDER : "left shoulder",
		ZOOPART_R_SHOULDER : "right shoulder",
		ZOOPART_L_HAND     : "left hand",
		ZOOPART_R_HAND     : "right hand",
		ZOOPART_L_NIPPLE   : "left nipple",
		ZOOPART_R_NIPPLE   : "right nipple",
		ZOOPART_L_BUTTOCK  : "left butt cheek",
		ZOOPART_R_BUTTOCK  : "right butt cheek",
		ZOOPART_L_FOOT     : "left foot",
		ZOOPART_R_FOOT     : "right foot"
	};
	
	while (zoo_getNextPart() != ZOOPART_NONE)
	{
		int p = zoo_getNextPart();
		familiar existing_graft = zoo_graftedToPart(p);
		if (existing_graft != $familiar[none]) { continue;}
		familiar fam = zoo_getBestFam(p, false);
		handleFamiliar(fam);
		int next_graft_weight = zoo_nextGraftWeight();
		if(familiar_weight(fam) < next_graft_weight)
		{
			//can only graft if the fam is higher than the level at the last graft
			zoo_BoostWeight(fam,next_graft_weight);
			return false;
		}
		equip(fam,$item[none]); //unequip fam equipment to not lose it, just in case
		visit_url("place.php?whichplace=graftinglab&action=graftinglab_chamber");
		visit_url("choice.php?pwd=&whichchoice=1553&option=1&slot=" + p + "&fam=" + to_int(fam));
		auto_log_info("Grafting a " + fam + " to you", "blue");
		handleTracker(fam,"Grafted to " + bodyPartName[p],"auto_tracker_path");
		refresh_status();
		return true;
	}
	
	auto_log_info("No more to graft");
	return false;
}

int zoo_nextGraftWeight()
{
	return min(my_level()+2,13);
}

boolean zoo_boostWeight(familiar f)
{
	return zoo_boostWeight(f,zoo_nextGraftWeight());
}

boolean zoo_boostWeight(familiar f, int target_weight)
{
	if(my_familiar() != f)
	{
		use_familiar(f);
	}
	// We want a fight with the bodyguard before we consider boosting because it superlevels first combat
	if(f==$familiar[burly bodyguard])
	{
		if (f.experience == 0)
		{
			return false;
		}
	}
	
	float experience_needed = target_weight*target_weight - f.experience;
	
	float mayam_exp    = 100;
	float piccolo_exp  =  40;
	float specimen_exp =  20;
	
	boolean mayamavailable = auto_haveMayamCalendar() && !(auto_MayamIsUsed("fur")) && !(auto_MayamAllUsed());
	
	provideFamExp(min(25,experience_needed),$location[The Outskirts of Cobb\'s Knob], true, true, false);
	float fight = numeric_modifier("familiar experience") + 1;
	auto_log_info(f + " needs " + experience_needed + " experience");
	auto_log_info("To level up your familiar, you should:");
	float amt = 0;
	float diff = experience_needed - amt;
	while(diff >= 1)
	{
		if(diff >= 100 && mayamavailable)
		{
			auto_log_info("Use the Mayam calendar and get fur on the outer ring");
			amt += mayam_exp;
			auto_MayamClaim("fur wood yam clock");
			handleTracker(f,"Mayam fur used to "+f.experience+" XP {"+familiar_weight(f)+" lb}","auto_tracker_path");
			mayamavailable = false;
		}
		else if(diff >= 40 && auto_AprilPiccoloBoostsLeft()> 0 )
		{
			auto_log_info("Play the Apriling Band Piccolo");
			amt += piccolo_exp;
			auto_playAprilPiccolo();
		}
		else if(diff >= 20 && zoo_specimenPreparationsLeft() > 0)
		{
			auto_log_info("Try to use the Specimen Preparation Bench");
			amt += specimen_exp;
			zoo_prepareSpecimen();
		}
		else if(diff <= 0)
		{
			return true;
		}
		else
		{
			int fights_needed = ceil(diff / fight);
			auto_log_info("Do " + fights_needed + " (preferably free) fights");
			amt += fight * fights_needed;
		}
		diff = experience_needed - amt;
		auto_log_info("Diff = " + diff);
	}
	return false;
}

skill getZooKickYR()
{
	boolean isYR(int fam_id) {
		familiar fam = to_familiar(fam_id);
		return $familiars[quantum entangler, foul ball, Defective Childrens' Stapler] contains fam;
	}
	if (isYR(to_int(get_property("zootGraftedFootLeftFamiliar")))) {
		return $skill[left %n kick];
	}
	if (isYR(to_int(get_property("zootGraftedFootRightFamiliar")))) {
		return $skill[right %n kick];
	}
	return $skill[none];
}

skill getZooKickFreeKill() //different than YR. Better than instakill
{
	boolean isYR(int fam_id) {
		familiar fam = to_familiar(fam_id);
		return $familiars[quantum entangler, foul ball, Defective Childrens' Stapler] contains fam;
	}
	if (isYR(to_int(get_property("zootGraftedFootLeftFamiliar")))) {
		return $skill[left %n kick];
	}
	if (isYR(to_int(get_property("zootGraftedFootRightFamiliar")))) {
		return $skill[right %n kick];
	}
	return $skill[none];
}

skill getZooKickSniff()
{
	boolean haveYR = yellowRayCombatString($monster[none], false) != ""; //Could potentially Yellow Ray. We want false because the item might not be bought/equipped
	if (leftKickHasSniff() && (leftKickHasInstaKill() && !haveYR)) {
		return $skill[left %n kick];
	}
	if (rightKickHasSniff() && (rightKickHasInstaKill() && !haveYR)) {
		return $skill[right %n kick];
	}
	return $skill[none];
}

skill getZooKickBanish()
{
	if (have_effect($effect[Everything Looks Blue])>0) { return $skill[none]; }
	boolean isBanish(int fam_id) {
		familiar fam = to_familiar(fam_id);
		return $familiars[Dire Cassava, Phantom Limb,MagiMechTech MicroMechaMech] contains fam;
	}
	if (isBanish(to_int(get_property("zootGraftedFootLeftFamiliar")))) {
		return $skill[left %n kick];
	}
	if (isBanish(to_int(get_property("zootGraftedFootRightFamiliar")))) {
		return $skill[right %n kick];
	}
	return $skill[none];
}

skill getZooKickPickpocket()
{
	boolean haveYR = yellowRayCombatString($monster[none], false) != ""; //Could potentially Yellow Ray. We want false because the item might not be bought/equipped
	if (leftKickHasPickpocket() && (leftKickHasInstaKill() && !haveYR) && getZooKickBanish() != $skill[left %n kick]) {
		return $skill[left %n kick];
	}
	if (rightKickHasPickpocket() && (rightKickHasInstaKill() && !haveYR) && getZooKickBanish() != $skill[right %n kick]) {
		return $skill[right %n kick];
	}
	return $skill[none];
}

skill getZooKickInstaKill()
{
	//Only instakill if we can't yellow ray
	if(yellowRayCombatString($monster[none], false) != "") //Could potentially Yellow Ray. We want false because the item might not be bought/equipped
	{
		return $skill[none];
	}
	//uncomment return $skill[kick] and comment return $skill[none] if you want us to auto use your instakill. Not recommended
	if (leftKickHasInstaKill()) {
		//return $skill[left %n kick];
		return $skill[none];
	}
	if (rightKickHasInstaKill()) {
		//return $skill[right %n kick];
		return $skill[none];
	}
	return $skill[none];
}

skill getZooBestPunch()
{
	return getZooBestPunch($monster[fluffy bunny]);
}

skill getZooBestPunch(monster m)
{
	if(have_skill($skill[left %n punch]))
	{
		return $skill[left %n punch];
	}
	else
	{
		return $skill[none];
	}
}

boolean leftKickHasSniff()
{
	string fAttrs = zoo_graftedToPart(ZOOPART_L_FOOT).attributes;
	string[int] attrs = split_string(fAttrs,"; ");
	string[int] sniffs = {
		"animal",
		"haseyes",
		"hot",
		"humanoid",
		"mineral",
		"orb",
		"sentient",
		"software"
	};
	foreach i,attr in attrs
	{
		foreach j, sniff in sniffs
		{
			if(sniff == attr)
			{
				return true;
			}
		}
	}
	return false;
}

boolean leftKickHasPickpocket()
{
	string fAttrs = zoo_graftedToPart(ZOOPART_L_FOOT).attributes;
	string[int] attrs = split_string(fAttrs,"; ");
	string[int] pps = {
		"hasbeak",
		"hasclaws",
		"hashands",
		"isclothes",
		"polygonal",
		"sleaze",
		"technological",
		"wearsclothes"
	};
	foreach i,attr in attrs
	{
		foreach j, pp in pps
		{
			if(pp == attr)
			{
				return true;
			}
		}
	}
	return false;
}

boolean leftKickHasInstaKill()
{
	string fAttrs = zoo_graftedToPart(ZOOPART_L_FOOT).attributes;
	string[int] attrs = split_string(fAttrs,"; ");
	string[int] instakills = {
		"bite",
		"cute",
		"evil",
		"food",
		"hasstinger",
		"object",
		"reallyevil",
		"stench"
	};
	foreach i,attr in attrs
	{
		foreach j, instakill in instakills
		{
			if(instakill == attr)
			{
				return true;
			}
		}
	}
	return false;
}

boolean rightKickHasSniff()
{
	string fAttrs = zoo_graftedToPart(ZOOPART_R_FOOT).attributes;
	string[int] attrs = split_string(fAttrs,"; ");
	string[int] sniffs = {
		"animal",
		"haseyes",
		"hot",
		"humanoid",
		"mineral",
		"orb",
		"sentient",
		"software"
	};
	foreach i,attr in attrs
	{
		foreach j, sniff in sniffs
		{
			if(sniff == attr)
			{
				return true;
			}
		}
	}
	return false;
}

boolean rightKickHasPickpocket()
{
	string fAttrs = zoo_graftedToPart(ZOOPART_R_FOOT).attributes;
	string[int] attrs = split_string(fAttrs,"; ");
	string[int] pps = {
		"hasbeak",
		"hasclaws",
		"hashands",
		"isclothes",
		"polygonal",
		"sleaze",
		"technological",
		"wearsclothes"
	};
	foreach i,attr in attrs
	{
		foreach j, pp in pps
		{
			if(pp == attr)
			{
				return true;
			}
		}
	}
	return false;
}

boolean rightKickHasInstaKill()
{
	string fAttrs = zoo_graftedToPart(ZOOPART_R_FOOT).attributes;
	string[int] attrs = split_string(fAttrs,"; ");
	string[int] instakills = {
		"bite",
		"cute",
		"evil",
		"food",
		"hasstinger",
		"object",
		"reallyevil",
		"stench"
	};
	foreach i,attr in attrs
	{
		foreach j, instakill in instakills
		{
			if(instakill == attr)
			{
				return true;
			}
		}
	}
	return false;
}

boolean LX_zootoFight()
{
	if(!in_zootomist() || my_level()>=13)
	{
		return false;
	}

	boolean additionalFights()
	{
		if(L5_getEncryptionKey())
		{
			return true;
		}
		
		if(LX_unlockHauntedBilliardsRoom(false))
		{
			return true;
		}

		if(LX_unlockHiddenTemple())
		{
			return true;
		}
		if(LX_lastChance()) //Should be high enough level by this point to handle these zones
		{
			return true;
		}
		return false;
	}
	
	// Set our familiar
	handleFamiliar(zoo_getNextFam());
	
	int target_weight = zoo_nextGraftWeight();
	int expToLevel = target_weight*target_weight - my_familiar().experience;

	// We want lots of XP
	provideFamExp(min(25,expToLevel), true, true);
	
	if(my_level() >= 9)
	{	// If we have Mayam, let's get that stone wool and unlock our Mayam.
		if (auto_haveMayamCalendar() && get_property("lastTempleAdventures").to_int()<my_ascensions())
		{
			if (available_amount($item[stone wool]) < 2 && internalQuestStatus("questL11Worship") < 0)
			{
				if (LX_killBaaBaaBuran()) { return true; }
			}
			if (auto_doTempleSummit()) { return true; }
		}
	}
	
	if(my_level() >= 7)
	{
		if(auto_doPhoneQuest())
		{
			return true;
		}
		// should get wishes in Shadow Rift. If not can't do this

		if (yellowRayCombatString($monster[none], false) != "")
		{
			if(get_property("auto_hippyInstead").to_boolean() && !(possessOutfit("War Hippy Fatigues")))
			{
				adjustForYellowRayIfPossible();
				return summonMonster($monster[War Hippy Airborne Commander]);
			}
			else if(!(possessOutfit("Frat Warrior Fatigues")))
			{
				adjustForYellowRayIfPossible();
				return summonMonster($monster[War Frat Mobile Grill Unit]);
			}
		}
		if(auto_have_familiar($familiar[Jill-of-All-Trades]) && candyBlockOutfit("treat") != "")
		{
			if(candyBlock())
			{
				return true;
			}
			if(!(get_property("_mapToACandyRichBlockUsed").to_boolean()))
			{
				while(item_amount($item[Map to a candy-rich block]) == 0)
				{
					handleFamiliar($familiar[Jill-of-All-Trades]);
					if(L7_defiledNook()) //Need eyes anyway so might as well try to get a couple while getting the map
					{
						return true;
					}
					else
					{
						additionalFights(); //didn't get a map trying to complete the Nook so doing additional combats
					}
				}
			}
		}
	}
	if(my_level() >= 5)
	{
		if(speakeasyCombat())
		{
			return true;
		}
		if(auto_fightFlamingLeaflet())
		{
			return true;
		}
	}

	// Do the temple unlock first, so we can get stone wool to reset our mayam
	if (auto_haveMayamCalendar() && my_level() >= 2)
	{
		if(LX_unlockHiddenTemple())
		{
			return true;
		}
	}
	
	if(additionalFights())
	{
		return true;
	}

	return false;
}
