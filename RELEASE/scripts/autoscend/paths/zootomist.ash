boolean in_zootomist()
{
	return my_path()==$path[z is for zootomist];
}

void zootomist_pulls()
{
	if (!in_zootomist() || pulls_remaining()==0) { return; }
	if (!have_skill($skill[just the facts]) && auto_is_valid($skill[just the facts])) {
		pullXWhenHaveY($item[book of facts (dog-eared)], 1, 0);
		if (available_amount($item[book of facts (dog-eared)])>0) {use($item[book of facts (dog-eared)]);}
	}
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
