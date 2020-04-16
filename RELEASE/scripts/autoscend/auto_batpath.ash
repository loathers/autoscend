script "auto_batpath.ash"

void bat_startAscension()
{
	if(my_path() == "Dark Gyffte") {
		visit_url("choice.php?whichchoice=1343&option=1");
		bat_reallyPickSkills(20);
	}
}
void bat_initializeSettings()
{
	if(my_path() == "Dark Gyffte")
	{
		set_property("auto_cubeItems", false);
		set_property("auto_getSteelOrgan", false);
		set_property("auto_grimstoneFancyOilPainting", false);
		set_property("auto_grimstoneOrnateDowsingRod", false);
		set_property("auto_paranoia", 10);
		set_property("auto_useCubeling", false);
		set_property("auto_wandOfNagamar", false);
		set_property("auto_bat_desiredForm", "");
	}
}

// The following functions set the desired form.
// The pre-adventure handler adjusts our actual form to match.
// This is done to avoid getting stuck in an incorrect form,
// or wasting HP switching back and forth.

boolean bat_wantHowl(location loc)
{
	if(!have_skill($skill[Baleful Howl]))
	{
		return false;
	}
	if(auto_banishesUsedAt(loc) contains "baleful howl")
	{
		return false;
	}
	int[monster] banished = banishedMonsters();
	monster[int] monsters = get_monsters(loc);
	foreach i in monsters
	{
		if (!(banished contains monsters[i]) && (auto_wantToBanish(monsters[i], loc))) {
			return true;
		}
	}
	return false;
}

boolean bat_formNone()
{
	if(my_class() != $class[Vampyre]) return false;
	if(get_property("auto_bat_desiredForm") != "")
	{
		set_property("auto_bat_desiredForm", "");
	}
	return true;
}

boolean bat_formWolf(boolean speculative)
{
	if(my_class() != $class[Vampyre]) return false;
	set_property("auto_bat_desiredForm", "wolf");
	return bat_switchForm($effect[Wolf Form], speculative);
}

boolean bat_formWolf()
{
	return bat_formWolf(false);
}

boolean bat_formMist(boolean speculative)
{
	if(my_class() != $class[Vampyre]) return false;
	set_property("auto_bat_desiredForm", "mist");
	return bat_switchForm($effect[Mist Form], speculative);
}

boolean bat_formMist()
{
	return bat_formMist(false);
}

boolean bat_formBats(boolean speculative)
{
	if(my_class() != $class[Vampyre]) return false;
	set_property("auto_bat_desiredForm", "bats");
	return bat_switchForm($effect[Bats Form], speculative);
}

boolean bat_formBats()
{
	return bat_formBats(false);
}

void bat_clearForms()
{
	foreach ef in $effects[Wolf Form, Mist Form, Bats Form]
	{
		if (0 != have_effect(ef)) {
			use_skill(to_skill(ef));
		}
	}
}

boolean bat_switchForm(effect form, boolean speculative)
{
	if (0 != have_effect(form)) return true;
	if(!have_skill(form.to_skill()))
	{
		if(!speculative)
			bat_clearForms();
		return false;
	}
	if (my_hp() <= 10)
	{
		if(!speculative)
			auto_log_warning("We don't have enough HP to switch form to " + form + "!", "red");
		return false;
	}
	if(speculative)
		return true;
	return use_skill(1, form.to_skill());
}

boolean bat_switchForm(effect form)
{
	return bat_switchForm(form, false);
}

boolean bat_formPreAdventure()
{
	if(my_class() != $class[Vampyre]) return false;

	string desiredForm = get_property("auto_bat_desiredForm");
	effect form;
	switch(desiredForm)
	{
	case "wolf":
		return bat_switchForm($effect[Wolf Form]);
	case "mist":
		return bat_switchForm($effect[Mist Form]);
	case "bats":
		return bat_switchForm($effect[Bats Form]);
	case "":
		bat_clearForms();
		return true;
	default:
		auto_log_error("auto_bat_desiredForm was set to bad value: '" + desiredForm + "'. Should be '', 'wolf', 'mist', or 'bats'.", "red");
		set_property("auto_bat_desiredForm", "");
		return false;
	}
}

void bat_initializeSession()
{
	if(my_class() == $class[Vampyre])
	{
		set_property("auto_mpAutoRecovery", get_property("mpAutoRecovery"));
		set_property("auto_mpAutoRecoveryTarget", get_property("mpAutoRecoveryTarget"));
		set_property("mpAutoRecovery", -0.05);
		set_property("mpAutoRecoveryTarget", 0.0);
	}
}

void bat_terminateSession()
{
	if(my_class() == $class[Vampyre])
	{
		set_property("mpAutoRecovery", get_property("auto_mpAutoRecovery"));
		set_property("auto_mpAutoRecovery", 0.0);
		set_property("mpAutoRecoveryTarget", get_property("auto_mpAutoRecoveryTarget"));
		set_property("auto_mpAutoRecoveryTarget", 0.0);
	}
}

void bat_initializeDay(int day)
{
	if(my_path() != "Dark Gyffte")
	{
		return;
	}

	if(get_property("auto_day_init").to_int() < day)
	{
		set_property("_auto_bat_bloodBank", 0); // 0: no blood yet, 1: base blood, 2: intimidating blood
		set_property("auto_bat_ensorcels", 0);
		set_property("auto_bat_soulmonster", "");
		bat_tryBloodBank();
		if (bat_shouldPickSkills(20))
		{
			bat_reallyPickSkills(20);
		}
	}
}

int bat_maxHPCost(skill sk)
{
	switch(sk)
	{
		case $skill[Baleful Howl]:
		case $skill[Intimidating Aura]:
		case $skill[Mist Form]:
		case $skill[Sharp Eyes]:
			return 30;
		case $skill[Madness of Untold Aeons]:
			return 25;
		case $skill[Crush]:
		case $skill[Wolf Form]:
		case $skill[Blood Spike]:
		case $skill[Blood Cloak]:
		case $skill[Macabre Cunning]:
		case $skill[Piercing Gaze]:
		case $skill[Ensorcel]:
		case $skill[Flock of Bats Form]:
			return 20;
		case $skill[Ceaseless Snarl]:
		case $skill[Preternatural Strength]:
		case $skill[Blood Chains]:
		case $skill[Sanguine Magnetism]:
		case $skill[Perceive Soul]:
		case $skill[Sinister Charm]:
		case $skill[Batlike Reflexes]:
		case $skill[Spot Weakness]:
			return 15;
		case $skill[Savage Bite]:
		case $skill[[24017]Ferocity]:
		case $skill[Chill of the Tomb]:
		case $skill[Spectral Awareness]:
			return 10;
		case $skill[Flesh Scent]:
		case $skill[Hypnotic Eyes]:
			return 5;
		default:
			return 0;
	}
}

int bat_baseHP()
{
	return 20 * min(23, get_property("darkGyfftePoints").to_int()) + my_basestat($stat[Muscle]) + 20;
}

int bat_remainingBaseHP()
{
	int baseHP = bat_baseHP();
	foreach sk in $skills[]
	{
		// important that this uses have_skill and not auto_have_skill, as auto_have_skill would
		// report incorrectly if any form intrinsics are active
		if(have_skill(sk))
			baseHP -= bat_maxHPCost(sk);
	}
	return baseHP;
}

boolean[skill] bat_desiredSkills(int hpLeft)
{
	boolean[skill] requirements;
	return bat_desiredSkills(hpLeft, requirements);
}

boolean[skill] bat_desiredSkills(int hpLeft, boolean[skill] forcedPicks)
{
	int costSoFar = 0;
	int baseHP = bat_baseHP();
	boolean[skill] picks;

	if(get_property("_auto_bat_bloodBank") != "2")
	{
		forcedPicks[$skill[Intimidating Aura]] = true;
	}

	boolean addPick(skill sk)
	{
		if(picks contains sk) return true;
		if(baseHP - costSoFar - bat_maxHPCost(sk) < hpLeft)
			return false;
		costSoFar += bat_maxHPCost(sk);
		picks[sk] = true;
		return true;
	}
	foreach sk in forcedPicks
	{
		addPick(sk);
	}
	foreach sk in $skills[
		Chill of the Tomb,
		Blood Chains,
		Madness of Untold Aeons,
		Sinister Charm,
		Blood Cloak,
		Baleful Howl,
		Perceive Soul,
		Hypnotic Eyes,
		Ensorcel,
		Sharp Eyes,
		Batlike Reflexes,
		Ceaseless Snarl,
		Flock of Bats Form,
		Mist Form,
		Sanguine Magnetism,
		Macabre Cunning,
		[24017]Ferocity,
		Flesh Scent,
		Wolf Form,
		Spot Weakness,
		Preternatural Strength,
		Savage Bite,
		Intimidating Aura,
		Spectral Awareness,
		Piercing Gaze,
		Blood Spike,
	]
	{
		addPick(sk);
	}
	return picks;
}

void bat_reallyPickSkills(int hpLeft)
{
	boolean[skill] requiredSkills;
	bat_reallyPickSkills(hpLeft, requiredSkills);
}

void bat_reallyPickSkills(int hpLeft, boolean[skill] requiredSkills)
{
	// Why Astral Spirit? When entering a DG run, before exiting the initial
	// noncombat and Torpor, that's what KoLmafia thinks you are.
	if(my_class() != $class[Vampyre] && to_string(my_class()) != "Astral Spirit")
	{
		return;
	}

	// Confirm that we're in Torpor
	visit_url("campground.php?action=coffin");

	boolean[skill] picks = bat_desiredSkills(hpLeft, requiredSkills);
	string url = "choice.php?whichchoice=1342&option=2&pwd=" + my_hash();
	foreach sk,_ in picks
	{
		url += "&sk[]=";
		url += sk.to_int() - 24000;
	}
	visit_url(url);
	visit_url("choice.php?whichchoice=1342&option=1&pwd=" + my_hash());
	// FIXME: Check that our skill-setting succeeded.
}

boolean bat_shouldPickSkills(int hpLeft)
{
	boolean[skill] picks = bat_desiredSkills(hpLeft);

	foreach sk in $skills[]
	{
		if(sk.bat_maxHPCost() == 0)
			continue;

		if ((picks contains sk) != have_skill(sk))
		{
			auto_log_info("We'd like to make a skill change for " + sk.to_string() + ", which we " + (picks contains sk ? "want" : "don't want") + " but " + (have_skill(sk) ? "have" : "don't have"), "blue");
			return true;
		}
	}

	return false;
}

boolean bat_shouldEnsorcel(monster m)
{
	if(my_class() != $class[Vampyre] || !auto_have_skill($skill[Ensorcel]))
		return false;

	// until we have a way to tell what we already have as an ensorcelee, just ensorcel goblins
	// to help avoid getting beaten up...
	if(m.monster_phylum() == $phylum[goblin] && !isFreeMonster(m))
		return true;

	return false;
}

int bat_creatable_amount(item desired)
{
	if(my_class() != $class[Vampyre])
		return 0;
	if(item_amount($item[blood bag]) == 0)
		return 0;

	switch(desired)
	{
		case $item[bloodstick]:
		case $item[blood snowcone]:
		case $item[blood roll-up]:
		case $item[bottle of Sanguiovese]:
		case $item[mulled blood]:
		case $item[Red Russian]:
			return creatable_amount(desired);
		case $item[actual blood sausage]:
			return min(item_amount($item[blood bag]), total_items($items[batgut, ratgut]));
		case $item[blood-soaked sponge cake]:
			return min(item_amount($item[blood bag]), total_items($items[filthy poultice, gauze garter]));
		case $item[dusty bottle of blood]:
			return min(item_amount($item[blood bag]), total_items($items[dusty bottle of Merlot, dusty bottle of Port, dusty bottle of Pinot Noir, dusty bottle of Zinfandel, dusty bottle of Marsala, dusty bottle of Muscat]));
		case $item[vampagne]:
			return min(item_amount($item[blood bag]), total_items($items[carbonated soy milk, monstar energy beverage]));
	}
	auto_log_warning("Hmm, " + desired + " isn't a Vampyre consumable", "red");
	return 0;
}

boolean bat_multicraft(string mode, boolean [item] options)
{
	if(my_class() != $class[Vampyre])
		return false;
	if(item_amount($item[blood bag]) == 0)
		return false;

	foreach ingredient in options
	{
		if(item_amount(ingredient) > 0)
		{
			if(craft(mode, 1, $item[blood bag], ingredient) > 0)
				return true;
		}
	}

	return false;
}

boolean bat_cook(item desired)
{
	if(my_class() != $class[Vampyre])
		return false;
	if(item_amount($item[blood bag]) == 0)
		return false;

	switch(desired)
	{
		case $item[bloodstick]:
		case $item[blood snowcone]:
		case $item[blood roll-up]:
		case $item[bottle of Sanguiovese]:
		case $item[mulled blood]:
		case $item[Red Russian]:
			return create(1, desired);
		case $item[actual blood sausage]:
			return bat_multicraft("cook", $items[batgut, ratgut]);
		case $item[blood-soaked sponge cake]:
			return bat_multicraft("cook", $items[filthy poultice, gauze garter]);
		case $item[dusty bottle of blood]:
			return bat_multicraft("cocktail", $items[dusty bottle of Merlot, dusty bottle of Port, dusty bottle of Pinot Noir, dusty bottle of Zinfandel, dusty bottle of Marsala, dusty bottle of Muscat]);
		case $item[vampagne]:
			return bat_multicraft("cocktail", $items[carbonated soy milk, monstar energy beverage]);
	}
	auto_log_warning("Hmm, " + desired + " isn't a Vampyre consumable", "red");
	return false;
}

boolean bat_consumption()
{
	if(my_class() != $class[Vampyre])
		return false;

	if(have_outfit("War Hippy Fatigues") && is_accessible($coinmaster[Dimemaster]))
	{
		sell($item[padl phone].buyer, item_amount($item[padl phone]), $item[padl phone]);
		sell($item[red class ring].buyer, item_amount($item[red class ring]), $item[red class ring]);
		sell($item[blue class ring].buyer, item_amount($item[blue class ring]), $item[blue class ring]);
		sell($item[white class ring].buyer, item_amount($item[white class ring]), $item[white class ring]);
	}
	if(have_outfit("Frat Warrior Fatigues") && is_accessible($coinmaster[Quartersmaster]))
	{
		sell($item[pink clay bead].buyer, item_amount($item[pink clay bead]), $item[pink clay bead]);
		sell($item[purple clay bead].buyer, item_amount($item[purple clay bead]), $item[purple clay bead]);
		sell($item[green clay bead].buyer, item_amount($item[green clay bead]), $item[green clay bead]);
		sell($item[communications windchimes].buyer, item_amount($item[communications windchimes]), $item[communications windchimes]);
	}

	boolean consume_first(boolean [item] its)
	{
		foreach it in its
		{
			if(bat_creatable_amount(it) > 0 || available_amount(it) > 0)
			{
				if (available_amount(it) == 0)
					bat_cook(it);
				if(it.fullness > 0)
					autoEat(1, it);
				else if(it.inebriety > 0)
					autoDrink(1, it);
				else if(it.spleen > 0)
					autoChew(1, it);
				else
				{
					auto_log_warning("Woah, I made a " + it + " to consume, but you can't consume that?", "red");
					return false;
				}
				return true;
			}
		}
		return false;
	}

	if ((fullness_left() > 0) && (get_property("availableQuarters").to_int() < 2))
	{
		pullXWhenHaveY($item[gauze garter], 1, 0);
	}
	if ((my_level() >= 7) &&
		(spleen_left() >= 3) &&
		(fullness_left() >= 2) &&
		(item_amount($item[dieting pill]) > 0) &&
		((item_amount($item[blood-soaked sponge cake]) > 0) ||
		 (bat_creatable_amount($item[blood-soaked sponge cake]) > 0)))
	{
		if (item_amount($item[blood-soaked sponge cake]) == 0)
			bat_cook($item[blood-soaked sponge cake]);
		if (item_amount($item[blood-soaked sponge cake]) > 0)
		{
			autoChew(1, $item[dieting pill]);
			autoEat(1, $item[blood-soaked sponge cake]);
			return true;
		}
	}
	if (item_amount($item[blood bag]) > 0)
	{
		if (inebriety_left() > 0)
		{
			if(consume_first($items[vampagne]))
				return true;
		}
	}
	if (my_adventures() <= 8 && item_amount($item[blood bag]) > 0)
	{
		if (inebriety_left() > 0)
		{
			if (get_property("availableQuarters").to_int() < 3)
			{
				pullXWhenHaveY($item[monstar energy beverage], 1, 0);
			}
			// don't auto consume bottle of Sanguiovese, only drink those if we're down to one adventure
			if(consume_first($items[vampagne, dusty bottle of blood, Red Russian, mulled blood]))
				return true;
		}
		if (fullness_left() > 0)
		{
			// don't auto consume bloodstick, only eat those if we're down to one adventure AFTER booze
			if(consume_first($items[blood-soaked sponge cake, blood roll-up, blood snowcone, actual blood sausage, ]))
				return true;
		}
	}

	if(my_adventures() <= 1)
	{
		if (fullness_left() > 0)
		{
			if (consume_first($items[bloodstick]))
				return true;
		}
		if(inebriety_left() > 0)
		{
			if (consume_first($items[bottle of Sanguiovese]))
				return true;
		}
	}

	return true;
}

boolean bat_skillValid(skill sk)
{
	if($skills[Savage Bite, Crush, Baleful Howl, Ceaseless Snarl] contains sk && have_effect($effect[Bats Form]) + have_effect($effect[Mist Form]) > 0)
		return false;

	if($skills[Blood Spike, Blood Chains, Chill of the Tomb, Blood Cloak] contains sk && have_effect($effect[Wolf Form]) + have_effect($effect[Bats Form]) > 0)
		return false;

	if($skills[Piercing Gaze, Perceive Soul, Ensorcel, Spectral Awareness] contains sk && have_effect($effect[Wolf Form]) + have_effect($effect[Mist Form]) > 0)
		return false;

	if((mp_cost(sk) > 0) && (my_class() == $class[Vampyre]))
		return false;

	return true;
}

boolean bat_tryBloodBank()
{
	int bloodBank = get_property("_auto_bat_bloodBank").to_int();
	if(bloodBank == 0 || (bloodBank == 1 && have_skill($skill[Intimidating Aura])))
	{
		visit_url("place.php?whichplace=town_right&action=town_bloodbank");
		set_property("_auto_bat_bloodBank", (have_skill($skill[Intimidating Aura]) ? 2 : 1));
		return true;
	}

	return false;
}

boolean LM_batpath()
{
	if(my_class() != $class[Vampyre])
		return false;

	if(bat_remainingBaseHP() >= 70 && bat_shouldPickSkills(20))
	{
		auto_log_info("Let's swap out some skills", "blue");
		bat_reallyPickSkills(20);
		return true;
	}
	bat_tryBloodBank();
	return false;
}
