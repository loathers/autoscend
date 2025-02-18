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

skill getZooBestPunch(monster m)
{
	return $skill[left \ punch];
}

boolean leftKickHasOlfaction()
{
	return true;
}

boolean leftKickHasYellowRay()
{
	return true;
}

boolean leftKickHasBanish()
{
	return true;
}

boolean leftKickHasPickpocket()
{
	return false;
}

boolean rightKickHasOlfaction()
{
	return false;
}

boolean rightKickHasYellowRay()
{
	return false;
}

boolean rightKickHasBanish()
{
	return false;
}

boolean rightKickHasPickpocket()
{
	return false;
}
