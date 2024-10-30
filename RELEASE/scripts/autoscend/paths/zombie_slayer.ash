// TODO: Visit hermit.php for free (10-leaf) clover _zombieClover

// DONE: buffs
// * Summon Minion (with Summon Horde): Waking the Dead +20% combat - Added to auto_providers.ash & auto_buff.ash
// * Scavenge: Scavengers Scavenging +20% item - added to auto_buff.ash and auto_post_adv.ash
// * Ag-grave-ation: Zomg WTF +30 ml - added to auto_buff.ash & auto_util.ash
// * Disquiet Riot: Disquiet Riot  -20% combat - Added to auto_providers.ash & auto_buff.ash
// * Zombie Chow: Chow Downed +5 Familiar Weight - added to auto_buff.ash and auto_post_adv.ash

// DONE: Banish -  added to auto_combat_util.ash
// TODO - track that it can banish 3 at once
// * Howl of the Alpha: 3 banishes at a time 

// TODO: Pickpocket - added to round 4 as a standard thing
// * Smash & Graaagh: 30x day, no mafia pref.
// * ?? Handle like a single use XO Skeleton Hugs and Kisses

// TODO: Bear Hug
// * Force equip both to use on group monsters

boolean in_zombieSlayer()
{
	return my_path() == $path[Zombie Slayer];
}

void zombieSlayer_initializeSettings()
{
	if(in_zombieSlayer())
	{
		// No Naughty Sorceress so no need for a wand.
		set_property("auto_wandOfNagamar", false);
		set_property("auto_getSheriffBadgeSupplies", false);

		if (item_amount($item[clan vip lounge key]) > 0) {
			if (item_amount($item[photo booth supply list]) == 0) 
			{
				buffer page = visit_url("clan_viplounge.php?action=photobooth");
				if (!page.contains_text("Borrow a prop"))
				{
					abort("We can not borrow a prop right now, or clan does not have a photo booth");
				}
				else 
				{
					page = visit_url("choice.php?pwd&whichchoice=1533&option=2");
					if (!page.contains_text("Borrow a photo booth supply list"))
					{
						abort("Can not borrow a photo booth supply list right now");
					}
					else {
						auto_log_debug("We will borrow a supply list from the photo booth now.");
						visit_url("choice.php?pwd&whichchoice=1535&option=1&avtion=Borrow a photo booth supply list");
					}
				}
			}
		}
		else {
			abort("You don't havea clan VIP lounge key. It's prabably better if you uninstallt this and install the regular autoscend instead.");
		}

		if (item_amount($item[photo booth supply list]) == 0) 
		{
			abort("Could not find a photo booth sullpy list. Without it this is useless.");
		}

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

	if (my_mp() >= goal) return true;

	return lureMinions(goal) || summonMinions(goal, meat_reserve);
}

boolean zombieSlayer_acquireMP(int goal)
{
	return zombieSlayer_acquireMP(goal, meatReserve());
}

boolean isHavingHiddenApartmentCurse() {
	boolean isCursed = false;
	// We are only interested in this when the Hidden Apartment quest is active
	if (get_property("questL11Curses") != "started") {
		return false;
	}
	foreach eff in $effects[Once-Cursed, Thrice-Cursed, Twice-Cursed]
	{
		if(have_effect(eff) > 0)
		{
			isCursed = true;
		}
	}
	return isCursed;
}

boolean zombieSlayer_acquireHP(int goal)
{
	if(!in_zombieSlayer())
	{
		return false;
	}

	if (my_hp() >= goal) return true;

	int missingHP = goal - my_hp();
	boolean failOut = false;

	// Devour Minions if you need at least 4 casts of Bite Minion or if doing the Hidden Apartment Building
	while ((missingHp > 0) && (!failOut)) 
	{
		// Devour Minions is less cost effective when we are under max 80hp 
		// It is also less effective if we would heal less than 30% of max hp
		// But if we have the hidden apartment curses we should always try to use it anyway
		if ((my_maxhp() > 80 && missingHP > floor(my_maxhp() * 0.3)) || isHavingHiddenApartmentCurse())
		{
			if (auto_have_skill($skill[Devour Minions]) && zombieSlayer_acquireMP(mp_cost($skill[Devour Minions])))
			{
				auto_log_debug("Sacrificing 4 minions for HP");
				use_skill(1, $skill[Devour Minions]);
			}
		} 
		// Only use Bite Minions if it doesn't remove a hidden apartment curse (wich it can do if we have Devour Minion)
		if (!(auto_have_skill($skill[Devour Minions]) && isHavingHiddenApartmentCurse())) 
		{
			if (auto_have_skill($skill[Bite Minion]) && zombieSlayer_acquireMP(mp_cost($skill[Bite Minion])))
			{
				auto_log_debug("Sacrificing 1 minion for HP");
				use_skill(1, $skill[Bite Minion]);
			}
		}
		if (missingHP == goal - my_hp()) 
		{
			auto_log_debug("Could not sacrifice minion(s) for HP", "red");
			failOut = true; // Failed
		} 
		missingHP = goal - my_hp();
	}

/*
	// Devour Minions if you need at least 4 casts of Bite Minion 
	if (auto_have_skill($skill[Devour Minions]))
	{
		while ((missingHP > floor(my_maxhp() * 0.3) || ((have_effect($effect[Thrice-Cursed]) > 0 || have_effect($effect[Twice-Cursed]) > 0 || have_effect($effect[Once-Cursed]) > 0) && !(internalQuestStatus("questL11Curses") > 1 || item_amount($item[Moss-Covered Stone Sphere]) > 0))) && zombieSlayer_acquireMP(mp_cost($skill[Devour Minions])))
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
		// Dont use this if you have Devour minions and one of those n:th-cursed effects
		if (!(auto_have_skill($skill[Devour Minions]) && isHavingHiddenApartmentCurse())) {
			while (missingHp > 0 && zombieSlayer_acquireMP(mp_cost($skill[Bite Minion])))
			{
				use_skill(1, $skill[Bite Minion]);
				if (my_hp() >= goal) break;
				if (missingHP == goal - my_hp()) break; // Failed
				missingHP = goal - my_hp();
			}
		}
	}
*/
	return my_hp() >= goal;
}

boolean zombieSlayer_canInfect(monster enemy){
	foreach phy in $phylums[plant, bug, constellation, construct, elemental, slime]
	{
		if(monster_phylum(enemy) == phy)
		{
			return false;
		}
	}

	return true;
}


boolean zombieSlayer_usable(familiar fam)
{
	if (!in_zombieSlayer())
	{
		return true;
	}
	return contains_text(fam.attributes, "undead");
}

boolean LM_zombieSlayer()
{
	//this function is called early once every loop of doTasks() in autoscend.ash
	//if something in this function returns true then it will restart the loop and get called again.
	
	if(!in_zombieSlayer())
	{
		return false;
	}
	
	while(item_amount($item[hunter brain]) > 0 && my_fullness() < fullness_limit())
	{
		autoEat(min(item_amount($item[hunter brain]), fullness_limit() - my_fullness()), $item[hunter brain]);
	}

	zombieSlayer_buySkills();

	return false;
}
