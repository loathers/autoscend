static int ZOOPART_HEAD       = 1;
static int ZOOPART_L_SHOULDER = 2;
static int ZOOPART_R_SHOULDER = 3;
static int ZOOPART_L_HAND     = 4;
static int ZOOPART_R_HAND     = 5;
static int ZOOPART_L_NIPPLE   = 6;
static int ZOOPART_R_NIPPLE   = 7;
static int ZOOPART_L_BUTTOCK  = 8;
static int ZOOPART_R_BUTTOCK  = 9;
static int ZOOPART_L_FOOT     = 10;
static int ZOOPART_R_FOOT     = 11;

boolean in_zootomist()
{
	return my_path()==$path[z is for zootomist];
}

void zoo_initializeSettings()
{
	set_property("auto_lastGraft", 3);
	set_property("auto_grafts", "");
}

void zootomist_pulls()
{
	if (!in_zootomist() || pulls_remaining()==0) { return; }
	if (!have_skill($skill[just the facts]) && auto_is_valid($skill[just the facts])) {
		pullXWhenHaveY($item[book of facts (dog-eared)], 1, 0);
		if (available_amount($item[book of facts (dog-eared)])>0) {use($item[book of facts (dog-eared)]);}
	}
}

void zoo_useFam()
{
	//Identifies the 11 familiars we want based on what we have and stores them in prefs so we only go through the list of fams once
	//Goes through fam attributes of all familiars and filters from there
	//Unfortunately, Mafia's attributes are incomplete for now
	string[int, familiar] famAttributes;
	//familiar, pos in map, priority
	int[int,familiar] intrinsicFams;
	int[int,familiar] dcombatFams;
	int[int,familiar] lbuffFams;
	int[int,familiar] rbuffFams;
	int[int,familiar] combatFams;
	//foreach counters
	int f = 0; //familiars
	int i = 0; //instrinsic
	int d = 0; //damage in combat
	int l = 0; //left nipple
	int r = 0; //right nipple
	int c = 0; //combat skills
	foreach fam in $familiars[]
	{
		if(have_familiar(fam))
		{
			famAttributes[f] = {fam:fam.attributes};
			f++;
			//auto_log_info(fam + ": " + famAttributes[fam]);
		}
	}
	foreach j, fam, attr in famAttributes
	{
		string[int] attrs = split_string(attr,";");
		foreach k, a in attrs
		{
			if($strings[technological, hashands, hasclaws] contains a)
			{
				//technological = 20% item drop, hashands/hasclaws = 20% meat drop
				if(a == "technological")
				{
					intrinsicFams[i] = {fam: 1};
				}
				else
				{
					intrinsicFams[i] = {fam: 2};
				}
				auto_log_info(fam + ":" + intrinsicFams[i][fam]);
				i++;
			}
		}
	}
}

boolean zooGraftFam()
{
	/*Body parts are identified by number
	1 = head
	2 = left shoulder
	3 = right shoulder
	4 = left hand
	5 = right hand
	6 = left nipple
	7 = right nipple
	8 = left butt cheek
	9 = right butt cheek
	10 = left foot
	11 = right foot
	Each body part is categorized by what it gives when a familiar is grafted to it.
	intrinsic provides the intrinsic buff and adds to it.
	dcombat is a combat damage skill
	lbuff is left nipple buff
	rbuff is right nipple buff
	combat is a useful combat skill (yr, olfact, banish)
	*/
	string[int] bodyPartType = {
		ZOOPART_HEAD       : "intrinsic",
		ZOOPART_L_SHOULDER : "intrinsic",
		ZOOPART_R_SHOULDER : "intrinsic",
		ZOOPART_L_HAND     : "dcombat",
		ZOOPART_R_HAND     : "dcombat",
		ZOOPART_L_NIPPLE   : "lbuff",
		ZOOPART_R_NIPPLE   : "rbuff",
		ZOOPART_L_BUTTOCK  : "intrinsic",
		ZOOPART_R_BUTTOCK  : "intrinsic",
		ZOOPART_L_FOOT     : "combat",
		ZOOPART_R_FOOT     : "combat"
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
	//Ideally, we get the attributes of all familiars we have and rank them by what is best in each slot and level them from there
	//We need access to familiar tags. There is this information already in familiars.txt in KoLMafia, we just need to parse it
	string[familiar] graftFam = {
		$familiar[oily woim]: "rbuff",
		$familiar[killer bee]: "rbuff",
		$familiar[mosquito]: "rbuff",
		$familiar[helix fossil]: "rbuff",
		$familiar[stab bat]: "lbuff",
		$familiar[mechanical songbird]: "intrinsic",
		$familiar[autonomous disco ball]: "intrinsic",
		$familiar[scary death orb]: "intrinsic",
		$familiar[smiling rat]: "intrinsic",
		$familiar[jumpsuited hound dog]: "intrinsic",
		$familiar[baby z-rex]: "intrinsic",
		$familiar[exotic parrot]: "intrinsic",
		$familiar[quantum entangler]: "combat",
		$familiar[magimechtech micromechamech]: "combat"
	};
	foreach fam, bodypart in graftFam
	{
		if(familiar_weight(fam) < get_property("auto_lastGraft").to_int()) //Use Mafia pref once that's a thing
		{
			//can only graft if the fam is higher than the level at the last graft
			continue;
		}
		string auto_grafts = get_property("auto_grafts"); //Use Mafia pref once that's a thing
		int famnumber = to_int(fam);
		int bodyPartNum;
		foreach i, bp in bodyPartType
		{
			if(contains_text(auto_grafts,i))
			{
				continue;
			}
			else if(bp == bodypart)
			{
				bodyPartNum = i;
				break;
			}
		}
		string temp = visit_url("choice.php?pwd=&whichchoice=1553&option=1&slot=" + bodyPartNum + "&fam=" + famnumber, true);
		auto_log_info("Grafting a " + fam.to_string() + " to you", "blue");
		handleTracker(fam,"Grafted to " + bodyPartName[bodyPartNum],"auto_otherstuff");
		return true;
	}

	return false;
}

boolean zooBoostWeight(familiar f, int target_weight)
{
	return false;
}

skill getZooKickYR()
{
	// Optimise countdowns here once Mafia has that info
	if (leftKickHasYellowRay()) {
		return $skill[left \ kick];
	}
	if (rightKickHasYellowRay()) {
		return $skill[right \ kick];
	}
	return $skill[none];
}

skill getZooKickSniff()
{
	if (leftKickHasSniff()) {
		return $skill[left \ kick];
	}
	if (rightKickHasSniff()) {
		return $skill[right \ kick];
	}
	return $skill[none];
}

skill getZooKickBanish()
{
	if (leftKickHasBanish()) {
		return $skill[left \ kick];
	}
	if (rightKickHasBanish()) {
		return $skill[right \ kick];
	}
	return $skill[none];
}

skill getZooKickPickpocket()
{
	if (leftKickHasPickpocket()) {
		return $skill[left \ kick];
	}
	if (rightKickHasPickpocket()) {
		return $skill[right \ kick];
	}
	return $skill[none];
}

skill getZooKickFreeKill()
{
	if (leftKickHasFreeKill()) {
		return $skill[left \ kick];
	}
	if (rightKickHasFreeKill()) {
		return $skill[right \ kick];
	}
	return $skill[none];
}

skill getZooBestPunch(monster m)
{
	return $skill[left \ punch];
}

// These will be done intelligently once Mafia can tell us.
// For now, hardcode them to fit what you grafted.
// Repo versions are designed for Quantum Entangler on left foot (optimal), MicroMech on right (not optimal).
// Cooldowns on eg banish can be handled like:
//~ boolean rightKickHasBanish()
//~ {
//~ 	return have_effect($effect[Everything Looks Blue]) <= 0;
//~ }

boolean leftKickHasSniff()
{
	return false;
}

boolean leftKickHasYellowRay()
{
	return true;
}

boolean leftKickHasBanish()
{
	return false;
}

boolean leftKickHasPickpocket()
{
	return false;
}

boolean leftKickHasFreeKill()
{
	return false;
}

boolean rightKickHasSniff()
{
	return false;
}

boolean rightKickHasYellowRay()
{
	return false;
}

boolean rightKickHasBanish()
{
	return have_effect($effect[Everything Looks Blue]) <= 0;
}

boolean rightKickHasPickpocket()
{
	return false;
}

boolean rightKickHasFreeKill()
{
	return false;
}
