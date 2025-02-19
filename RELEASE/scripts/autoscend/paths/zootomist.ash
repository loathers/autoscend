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
	*/
	int[familiar] graftFam = {
		$familiar[oily woim]: 6,
		$familiar[stab bat]: 7,
		$familiar[mechanical songbird]: 1,
		$familiar[mechanical songbird]: 2,
		$familiar[mechanical songbird]: 3,
		$familiar[mechanical songbird]: 8,
		$familiar[mechanical songbird]: 9,
		$familiar[autonomous disco ball]: 1,
		$familiar[autonomous disco ball]: 2,
		$familiar[autonomous disco ball]: 3,
		$familiar[autonomous disco ball]: 8,
		$familiar[autonomous disco ball]: 9,
		$familiar[scary death orb]: 1,
		$familiar[scary death orb]: 2,
		$familiar[scary death orb]: 3,
		$familiar[scary death orb]: 8,
		$familiar[scary death orb]: 9,
		$familiar[smiling rat]: 1,
		$familiar[smiling rat]: 2,
		$familiar[smiling rat]: 3,
		$familiar[smiling rat]: 8,
		$familiar[smiling rat]: 9,
		$familiar[jumpsuited hound dog]: 1,
		$familiar[jumpsuited hound dog]: 2,
		$familiar[jumpsuited hound dog]: 3,
		$familiar[jumpsuited hound dog]: 8,
		$familiar[jumpsuited hound dog]: 9,
		$familiar[baby z-rex]: 1,
		$familiar[baby z-rex]: 2,
		$familiar[baby z-rex]: 3,
		$familiar[baby z-rex]: 8,
		$familiar[baby z-rex]: 9,
		$familiar[exotic parrot]: 1,
		$familiar[exotic parrot]: 2,
		$familiar[exotic parrot]: 3,
		$familiar[exotic parrot]: 8,
		$familiar[exotic parrot]: 9
	};
	foreach fam, bodypart in graftFam
	{
		if(familiar_weight(fam) < get_property("auto_lastGraft").to_int())
		{
			//can only graft if the fam is higher than the level at the last graft
			continue;
		}
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
