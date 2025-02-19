boolean in_zootomist()
{
	return my_path()==$path[z is for zootomist];
}

void zoo_initializeSettings()
{
	set_property("auto_lastGraft", 3);
}

void zootomist_pulls()
{
	if (!in_zootomist() || pulls_remaining()==0) { return; }
	if (!have_skill($skill[just the facts]) && auto_is_valid($skill[just the facts])) {
		pullXWhenHaveY($item[book of facts (dog-eared)], 1, 0);
		if (available_amount($item[book of facts (dog-eared)])>0) {use($item[book of facts (dog-eared)]);}
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
	Each body part is categorized by what it gives when a familiar is grafted to it
	*/
	string[int] bodyPartType = {
		1: "intrinsic",
		2: "intrinsic",
		3: "intrinsic",
		4: "dcombat",
		5: "dcombat",
		6: "lbuff",
		7: "rbuff",
		8: "intrinsic",
		9: "intrinsic",
		10: "combat",
		11: "combat"
	};
	string[int] bodyPartName = {
		1: "head",
		2: "left shoulder",
		3: "right shoulder",
		4: "left hand",
		5: "right hand",
		6: "left nipple",
		7: "right nipple",
		8: "left butt cheek",
		9: "right butt cheek",
		10: "left foot",
		11: "right foot"
	};
	//Ideally, we get the attributes of all familiars we have and rank them by what is best in each slot and level them from there
	//We need access to familiar tags. There is this information already in familiars.txt in KoLMafia, we just need to parse it
	string[familiar] graftFam = {
		$familiar[oily woim]: "lbuff",
		$familiar[killer bee]: "lbuff",
		$familiar[mosquito]: "lbuff",
		$familiar[helix fossil]: "lbuff",
		$familiar[stab bat]: "rbuff",
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
