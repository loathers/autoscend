// TODO: Visit hermit.php for free clover _zombieClover

// TODO: buffs
// * Summon Minion (with Summon Horde): Waking the Dead +20% combat
// * Scavenge: Scavengers Scavenging +20% item
// * Ag-grave-ation: Zomg WTF +30 ml
// * Disquiet Riot: Disquiet Riot  -20% combat

// TODO: Banish
// * Howl of the Alpha: 3 banishes at a time

// TODO: Pickpocket
// * Smash & Graaagh: 30x day, no mafia pref.
// * ?? Handle like a single use XO Skeleton Hugs and Kisses

// TODO: Bear Hug
// * Force equip both to use on group monsters

boolean in_zombieSlayer()
{
	return my_path() == "Zombie Slayer";
}

void zombieSlayer_initializeSettings()
{
	if(in_zombieSlayer())
	{
		// No Naughty Sorceress so no need for a wand.
		set_property("auto_wandOfNagamar", false);
	}
}

int last_zombie_fullness = -1;
boolean zombieSlayer_buySkills()
{
	if(!in_zombieSlayer())
	{
		return false;
	}

	if (auto_have_skill($skill[Ravenous Pounce]) && auto_have_skill($skill[Howl of the Alpha]) && auto_have_skill($skill[Zombie Maestro]))
	{
		return false;
	}

	// Don't check again unless fullness has changed (maybe a hunter brain was eaten)
	if (last_zombie_fullness == my_fullness())
	{
		return false;
	}

	last_zombie_fullness = my_fullness();

	buffer page = visit_url("campground.php?action=grave");
	int bought = 0;

	while (page.contains_text("Focus on Hunger"))
	{
		page = visit_url("campground.php?whichtree=Hunger&preaction=zombieskill&value=Focus on Hunger");
	}

	while (page.contains_text("Focus on Anger"))
	{
		page = visit_url("campground.php?whichtree=Anger&preaction=zombieskill&value=Focus on Anger");
	}

	while (page.contains_text("Focus on Master"))
	{
		page = visit_url("campground.php?whichtree=Master&preaction=zombieskill&value=Focus on Master");
	}

	return bought != 0;
}

boolean lureMinions(int target)
{
	if(!in_zombieSlayer() || !auto_have_skill($skill[Lure Minions]))
	{
		return false;
	}

	if (my_mp() >= target) return true;

	// borrowed from Universal Recovery

	int brains_needed = (fullness_limit() - my_fullness()) + ceil(fullness_limit() / 2);
	int check_brains(int brains) {
		if(brains_needed == 0) return brains;
		int temp = max(brains - brains_needed, 0);
		brains_needed = max(brains_needed - brains, 0);
		return temp;
	}
	boolean exchanged = false;
	boolean lure(int x, int type) {  // type is both choice and number of minions per brain, up to 3.
		// How many times do I do this to reach target?
		x = min(ceil(to_float(target - my_mp()) / type), x);
		//if(Verbosity > 2) print("Using "+x+" brains of level "+ type);
		if(x > 0) {
			if(!exchanged) // Start choice adventure first time only
				visit_url("runskillz.php?action=Skillz&whichskill=12002&pwd&quantity=1&targetplayer="+my_id());
			visit_url("choice.php?pwd&whichchoice=599&option="+type+"&quantity="+ x);
			exchanged = true;
		}
		return my_mp() >= target;
	}

	check_brains(item_amount($item[hunter brain]));
	check_brains(item_amount($item[boss brain]));
	// Count hunter and boss brains, but do not trade them, so number need not be remembered
	int spare_good = check_brains(item_amount($item[good brain]));
	int spare_decent = check_brains(item_amount($item[decent brain]));
	int spare_crappy = check_brains(item_amount($item[crappy brain]));
	// Reserve them in order from best to worst. Then trade them worst first. Stop once one returns true.
	if(lure(spare_crappy, 1) || lure(spare_decent, 2) || lure(spare_good, 3)) {}
	// Finish choice adventure if started
	if(exchanged) visit_url("choice.php?pwd&whichchoice=599&option=5");

	return my_hp() >= target;
}

boolean summonMinions(int target, int meat_reserve)
{
	if(!in_zombieSlayer() || !auto_have_skill($skill[Summon Minion]))
	{
		return false;
	}

	if (my_mp() >= target) return true;

	// borrowed from Universal Recovery

	int x = target - my_mp();
	// Never use Summon Minion if you have Summon Horde because +20% combats could cause trouble
	if(auto_have_skill($skill[Summon Horde])) {
		x = ceil(x / 12.0);
		x = min((my_meat() - meat_reserve) / 1000, x);
		//if(Verbosity > 2) print("Summoning a horde "+ x+" times");
		if(x > 0) {
			visit_url("runskillz.php?action=Skillz&whichskill=12026&pwd&quantity=1&targetplayer="+my_id());
			for cast from 1 to x
				visit_url("choice.php?pwd&whichchoice=601&option=1");
			visit_url("choice.php?pwd&whichchoice=601&option=2");
		}
	}
	else
	{
		x = min((my_meat() - meat_reserve) / 100, x);
		//if(Verbosity > 2) print("Summoning "+x+" minions");
		if(x > 0) {
			visit_url("runskillz.php?action=Skillz&whichskill=12021&pwd&quantity=1&targetplayer="+my_id());
			visit_url("choice.php?pwd&whichchoice=600&option=1&quantity=" + x);
			visit_url("choice.php?pwd&whichchoice=600&option=2");
		}
	}

	return my_hp() >= target;
}

boolean zombieSlayer_acquireMP(int goal, int meat_reserve)
{
	if(!in_zombieSlayer())
	{
		return false;
	}

	if (my_hp() >= goal) return true;

	return lureMinions(goal) || summonMinions(goal, meat_reserve);
}

boolean zombieSlayer_acquireMP(int goal)
{
	return zombieSlayer_acquireMP(goal, meatReserve());
}

boolean zombieSlayer_acquireHP(int goal)
{
	if(!in_zombieSlayer())
	{
		return false;
	}

	if (my_hp() >= goal) return true;

	int missingHP = goal - my_hp();

	// Devour Minions if you need at least 4 casts of Bite Minion
	if (auto_have_skill($skill[Devour Minions]))
	{
		while (missingHP > floor(my_maxhp() * 0.3) && zombieSlayer_acquireMP(mp_cost($skill[Devour Minions])))
		{
			use_skill(1, $skill[Devour Minions]);
			if (my_hp() >= goal) break;
			if (missingHP == goal - my_hp()) break; // Failed
			missingHP = goal - my_hp();
		}
		missingHP = goal - my_hp();
	}

	if (auto_have_skill($skill[Bite Minion]))
	{
		while (missingHp > 0 && zombieSlayer_acquireMP(mp_cost($skill[Bite Minion])))
		{
			use_skill(1, $skill[Bite Minion]);
			if (my_hp() >= goal) break;
			if (missingHP == goal - my_hp()) break; // Failed
			missingHP = goal - my_hp();
		}
	}

	return my_hp() >= goal;
}

