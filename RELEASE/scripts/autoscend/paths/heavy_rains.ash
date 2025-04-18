boolean in_heavyrains()
{
	return my_path() == $path[Heavy Rains];
}

void heavyrains_initializeSettings()
{
	if(in_heavyrains())
	{
		#Rain Man (Heavy Rains) Related settings
		set_property("auto_holeinthesky", false);
		set_property("auto_mountainmen", "");
		set_property("auto_ninjasnowmanassassin", false);	//are we done with ninja snowman assassins
		set_property("auto_orcishfratboyspy", "");
		set_property("auto_warhippyspy", "");

		set_property("auto_lastthunder", "100");
		set_property("auto_lastthunderturn", "0");

		set_property("auto_wandOfNagamar", false);
		set_property("auto_writingDeskSummon", true);

		set_property("auto_day1_desk", "");
		set_property("auto_day1_skills", "");
	}
}


void heavyrains_initializeDay(int day)
{
	if(in_heavyrains())
	{
		if((day == 1) && (get_property("auto_day1_skills") != "finished"))
		{
			set_property("choiceAdventure967", "1");
			set_property("choiceAdventure968", "1");
			set_property("choiceAdventure969", "3");

			if(item_amount($item[thunder thigh]) > 0) //Thunder Clap, Thunder Bird, Thunder Strike
			{
				visit_url("inv_use.php?which=3&whichitem=7648&pwd");
				visit_url("choice.php?pwd&whichchoice=967&option=1", true);
				if (item_amount($item[thunder thigh]) > 0) {
					visit_url("choice.php?pwd&whichchoice=967&option=3", true);
				}
				if (item_amount($item[thunder thigh]) > 0) {
					visit_url("choice.php?pwd&whichchoice=967&option=5", true);
				}
				set_property("choiceAdventure967", "7");
			}

			if(item_amount($item[aquaconda brain]) > 0) // Rain Man, Make it Rain, Rain Dance
			{
				visit_url("inv_use.php?which=3&whichitem=7647&pwd");
				visit_url("choice.php?pwd&whichchoice=968&option=1", true);
				if (item_amount($item[aquaconda brain]) > 0) {
					visit_url("choice.php?pwd&whichchoice=968&option=3", true);
				}
				if (item_amount($item[aquaconda brain]) > 0) {
					visit_url("choice.php?pwd&whichchoice=968&option=4", true);
				}
				set_property("choiceAdventure968", "2");
			}

			if(item_amount($item[lightning milk]) > 0) // Ball Lightning, Lightning Strike, Riding the Lightning
			{
				visit_url("inv_use.php?which=3&whichitem=7646&pwd");
				visit_url("choice.php?pwd&whichchoice=969&option=3", true);
				if (item_amount($item[lightning milk]) > 0) {
					visit_url("choice.php?pwd&whichchoice=969&option=1", true);
				}
				if (item_amount($item[lightning milk]) > 0) {
					visit_url("choice.php?pwd&whichchoice=969&option=7", true);
				}
				set_property("choiceAdventure969", "2");
			}

			if(item_amount($item[miniature life preserver]) == 0)
			{
				auto_buyUpTo(1, $item[miniature life preserver]);
			}
			set_property("auto_day1_skills", "finished");
			visit_url("main.php");
		}
	}
}

void heavyrains_doBedtime()
{
	if(my_inebriety() > inebriety_limit())
	{
		while((have_skill($skill[Rain Dance])) && (my_rain() >= 10))
		{
			use_skill(1, $skill[Rain Dance]);
		}
		while((have_skill($skill[thunderheart])) && (my_thunder() >= 20))
		{
			use_skill(1, $skill[thunderheart]);
		}
		while((have_skill($skill[Clean-Hair Lightning])) && (my_lightning() >= 10))
		{
			use_skill(1, $skill[Clean-Hair Lightning]);
		}
	}
}

boolean heavyrains_buySkills()
{
	if(!in_heavyrains())
	{
		return false;
	}
	else
	{
		if(item_amount($item[thunder thigh]) > 0)
		{
			auto_log_info("Trying to use a thunder thigh", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7648&pwd");
			int skillChoice = 8;
			if(!have_skill($skill[Thunder Down Underwear])){
				skillChoice = 6;
			}
			if(!have_skill($skill[Thundercloud])){
				skillChoice = 2;
			}
			if(!have_skill($skill[Thunderheart])){
				skillChoice = 4;
			}
			if(!have_skill($skill[Thunder Thighs])){
				skillChoice = 7;
			}
			if(!have_skill($skill[Thunderstrike])){
				skillChoice = 5;
			}
			if(!have_skill($skill[Thunder Bird])){
				skillChoice = 3;
			}
			if(!have_skill($skill[Thunder Clap])){
				skillChoice = 1;
			}
			
			set_property("choiceAdventure967", skillChoice);
			runChoice(page);
			visit_url("main.php");
			return true;
		}

		if(item_amount($item[aquaconda brain]) > 0)
		{
			auto_log_info("Trying to use a aquaconda brain", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7647&pwd");
			int skillChoice = 8;
			if(!have_skill($skill[Rain Delay])){
				skillChoice = 7;
			}
			if(!have_skill($skill[Rain Coat])){
				skillChoice = 6;
			}
			if(!have_skill($skill[Rainbow])){
				skillChoice = 5;
			}
			if(!have_skill($skill[Rainy Day])){
				skillChoice = 2;
			}
			if(!have_skill($skill[Rain Dance])){
				skillChoice = 4;
			}
			if(!have_skill($skill[Make it Rain])){
				skillChoice = 3;
			}
			if(!have_skill($skill[Rain Man])){
				skillChoice = 1;
			}
			
			set_property("choiceAdventure968", skillChoice);
			runChoice(page);
			visit_url("main.php");
			return true;
		}

		if(item_amount($item[lightning milk]) > 0)
		{
			auto_log_info("Trying to use a lightning milk", "blue");
			string page = visit_url("inv_use.php?which=3&whichitem=7646&pwd");
			int skillChoice = 8;
			if(get_property("_fireworksShop").to_boolean() && !have_skill($skill[Ball Lightning])){
				skillChoice = 3;
			}
			if(!have_skill($skill[Lightning Rod])){
				skillChoice = 6;
			}
			if(!have_skill($skill[[16025]Lightning Bolt])){
				skillChoice = 5;
			}
			if(!have_skill($skill[Sheet Lightning])){
				skillChoice = 4;
			}
			if(!have_skill($skill[Clean-Hair Lightning])){
				skillChoice = 2;
			}
			if(!have_skill($skill[Riding the Lightning])){
				skillChoice = 7;
			}
			if(!have_skill($skill[Lightning Strike])){
				skillChoice = 1;
			}
			if(!get_property("_fireworksShop").to_boolean() && !have_skill($skill[Ball Lightning])){
				skillChoice = 3;
			}

			set_property("choiceAdventure969", skillChoice);
			runChoice(page);
			visit_url("main.php");
			return true;
		}
	}
	return false;
}

boolean canRainManSummon(monster target)
{
	if(!have_skill($skill[Rain Man]) || my_rain() < 50)
	{
		return false;
	}

	// Can only rain man summon copyable monsters
	if(!target.copyable || target.id < 0)
	{
		return false;
	}

	// Can summon any monster with available factoids
	if (target.monster_factoids_available(false) > 0)
	{
		return true;
	}

	// Check the page text
	auto_log_info(target + " factoids unavailable, checking Rain Man if summon is possible", "blue");
	buffer page = visit_url("runskillz.php?pwd&action=Skillz&whichskill=16011&quantity=1");
	// Escape
	run_choice(2);

	return page.contains_text("<option value=" + target.id + ">");
}

boolean rainManSummon(monster target, boolean speculative)
{
	boolean canSummon = canRainManSummon(target);
	if (!canSummon || speculative)
	{
		return canSummon;
	}

	//use the rainman to summon a monster
	auto_log_info("Rain Man will summon: " +target, "blue");
	string[int] pages;
	pages[0] = "runskillz.php?pwd&action=Skillz&whichskill=16011&quantity=1";
	pages[1] = "choice.php?pwd&whichchoice=970&whichmonster=" + target.id + "&option=1&choice2=and+Fight%21";
	// autoAdvBypass will escape from the choice and return false if the monster cannot be fought
	if(autoAdvBypass(0, pages, $location[Noob Cave], ""))
	{
		handleTracker(target, $skill[Rain Man], "auto_copies");
		return true;
	}
	return false;
}

boolean L13_heavyrains_towerFinal()
{
	//Prepare for and defeat the final boss for Heavy Rains run. Which has special rules for engagement.
	if (internalQuestStatus("questL13Final") != 11)
	{
		return false;
	}
	
	//use a damage dealing familiar
	if(canChangeToFamiliar($familiar[warbear drone]))			//old event item. still farmable. up to 6 attacks per round
	{
		use_familiar($familiar[Warbear Drone]);
		//TODO does rain king stripping at begining of combat remove familiar equipment? if yes remove the part below
		pullXWhenHaveY($item[warbear drone codes], 1, 0);
		if(possessEquipment($item[warbear drone codes]))
		{
			equip($item[warbear drone codes]);
		}
	}
	else if(canChangeToFamiliar($familiar[Sludgepuppy]))		//IOTM derivative, infinitely farmable. attacks 3 times per round
	{
		use_familiar($familiar[Sludgepuppy]);
	}
	else if(canChangeToFamiliar($familiar[Imitation Crab]))		//cheap, easily acquired. attacks 2 times per round
	{
		use_familiar($familiar[Imitation Crab]);
	}
	else if(canChangeToFamiliar($familiar[Angry Goat]))			//super cheap. high chance to attack each round.
	{
		use_familiar($familiar[Angry Goat]);
	}
	
	//buff up before the boss
	buffMaintain($effect[Benetton's Medley of Diversity]);			//15 prismatic weapon dmg.
	buffMaintain($effect[Dirge of Dreadfulness (Remastered)]);		//36 spooky spell & weapon dmg
	buffMaintain($effect[Dirge of Dreadfulness]);					//12 spooky weapon dmg
	buffMaintain($effect[Boner Battalion]);						//32-33 sleaze and spooky passive dmg
	buffMaintain($effect[Frigidalmatian]);							//40 (due to cap) cold passive dmg
	effectAblativeArmor(true);					//Unimportant effects protect your important one from being removed.
	
	//Calculate melee/ranged damage. Each element is capped at 40. assume you will be able to deal 40 physical damage.
	cli_execute("outfit Birthday Suit");			//Need to get naked so we can check our stats properly.
	maximize("prismatic damage, +weapon, +offhand", false);

	int hot_dmg = min(40,numeric_modifier("hot damage"));
	int cold_dmg = min(40,numeric_modifier("cold damage"));
	int stench_dmg = min(40,numeric_modifier("stench damage"));
	int sleaze_dmg = min(40,numeric_modifier("sleaze damage"));
	int spooky_dmg = min(40,numeric_modifier("spooky damage"));
	if(auto_have_skill($skill[Cold Shoulder]))
	{
		cold_dmg = min(40, (5+cold_dmg));
	}
	
	//lunging thrust smack as a seal clubber with a club triples elemental damage. this applies to damage that does not come from weapon, excluding cold shoulder.
	boolean want_club = false;
	if(my_class() == $class[Seal Clubber] && auto_have_skill($skill[Lunging Thrust-Smack]))
	{
		maximize("prismatic damage, +weapon, +offhand, +club", false);
		int club_hot_dmg = min(40,(3*numeric_modifier("hot damage")));
		int club_cold_dmg = min(40,(3*numeric_modifier("cold damage")));
		int club_stench_dmg = min(40,(3*numeric_modifier("stench damage")));
		int club_sleaze_dmg = min(40,(3*numeric_modifier("sleaze damage")));
		int club_spooky_dmg = min(40,(3*numeric_modifier("spooky damage")));
		
		if(auto_have_skill($skill[Cold Shoulder]))
		{
			club_cold_dmg = min(40, (5+club_cold_dmg));
		}

		if((hot_dmg + cold_dmg + stench_dmg + sleaze_dmg + spooky_dmg) < (club_hot_dmg + club_cold_dmg + club_stench_dmg + club_sleaze_dmg + club_spooky_dmg))
		{
			want_club = true;
			hot_dmg = club_hot_dmg;
			cold_dmg = club_cold_dmg;
			stench_dmg = club_stench_dmg;
			sleaze_dmg = club_sleaze_dmg;
			spooky_dmg = club_spooky_dmg;
		}
	}
	
	int attack_dmg = 40 + min(40,hot_dmg) + min(40,cold_dmg) + min(40,stench_dmg) + min(40,sleaze_dmg) + min(40,spooky_dmg);
	
	//check magic damage
	boolean spell_extra_element = false;
	if(item_amount($item[Rain-Doh green lantern]) > 0 || item_amount($item[meteorb]) > 0 || item_amount($item[snow mobile]) > 0)
	{
		spell_extra_element = true;
	}
	else foreach it in $items[Rain-Doh green lantern, meteorb, snow mobile]
	{
		if(acquireOrPull(it))
		{
			spell_extra_element = true;
			break;
		}
	}

	int	spell_dmg = 0;
	string best_spell = "";
	if(auto_have_skill($skill[Saucestorm]))
	{
		if(80>spell_dmg)
		{
			best_spell = "saucestorm";
			spell_dmg = max(80,spell_dmg);
		}
		//IIRC hot and cold extra elements don't work for saucestorm, so only want green lantern. TODO verify
		if(item_amount($item[Rain-Doh green lantern]) > 0 && 120>spell_dmg)
		{
			best_spell = "saucestorm";
			spell_dmg = max(120,spell_dmg);
		}
	}
	if(auto_have_skill($skill[Weapon of the Pastalord]) && auto_have_skill($skill[Flavour of Magic]))
	{
		if(80>spell_dmg)
		{
			best_spell = "weapon_of_the_pastalord";
			spell_dmg = max(80,spell_dmg);
		}
		if(spell_extra_element && 120>spell_dmg)
		{
			best_spell = "weapon_of_the_pastalord";
			spell_dmg = max(120,spell_dmg);
		}
	}
	if(auto_have_skill($skill[Turtleini]))
	{
		if(120>spell_dmg)
		{
			best_spell = "turtleini";
			spell_dmg = max(120,spell_dmg);
		}
		if(spell_extra_element && 160>spell_dmg)
		{
			//how does [Turtleini] get affected by extra elements? I am guessing it increases it to 160. TODO verify
			best_spell = "turtleini";
			spell_dmg = max(160,spell_dmg);
		}
	}
	
	boolean plan_on_spells = false;
	if(attack_dmg < spell_dmg)
	{
		plan_on_spells = true;
	}
	
	//final dressup for the boss
	if(plan_on_spells)
	{
		set_property("auto_rain_king_combat", best_spell);
		setFlavour($element[sleaze]);		//a safe element that does not conflict with offhand items.
		executeFlavour();
		if(spell_extra_element)
		{
			maximize("spell damage percent, +weapon", false);
			if(item_amount($item[Rain-Doh green lantern]) > 0)
			{
				equip($slot[off-hand], $item[Rain-Doh green lantern]);
			}
			else if(item_amount($item[meteorb]) > 0)
			{
				equip($slot[off-hand], $item[meteorb]);
			}
			else if(item_amount($item[snow mobile]) > 0)
			{
				equip($slot[off-hand], $item[snow mobile]);
			}
		}
		else
		{
			maximize("spell damage percent, +weapon, +offhand", false);
		}
	}
	else
	{
		set_property("auto_rain_king_combat", "attack");
		if(want_club)
		{
			maximize("prismatic damage, +weapon, +offhand, +club", false);
		}
		else
		{
			maximize("prismatic damage, +weapon, +offhand", false);
		}
	}
	
	//Rain King strips all equipment other than weapon and offhand.
	//Stripped equipment can only provide you with -ML which is applied before the stripping
	auto_buyUpTo(3, $item[water wings for babies]);
	maximize("-ml, -weapon, -offhand", false);
	
	//Fight!
	//auto_disableAdventureHandling because we don't want maximize, switch familiar, change buffs, or anything else that might break our specific prepwork.
	acquireHP();
	acquireMP(200);
	set_property("auto_disableAdventureHandling", true);		
	autoAdvBypass("place.php?whichplace=nstower&action=ns_10_sorcfight", $location[Noob Cave]);
	set_property("auto_disableAdventureHandling", false);
	if(last_monster() != $monster[The Rain King])
	{
		abort("Failed to start the battle with The Rain King");
	}
	if(have_effect($effect[Beaten Up]) > 0)
	{
		abort("The Rain King beat me up! please finish him off manually");
	}
	if(get_property("auto_stayInRun").to_boolean())
	{
		abort("User wanted to stay in run (auto_stayInRun), we are done.");
	}
	else
	{
		visit_url("place.php?whichplace=nstower&action=ns_11_prism");
		if(inAftercore())
		{
			abort("All done. King Ralph has been freed");
		}
		abort("Tried to break prism but failed");
	}
	abort("How did I reach this line? I should have fought [The Rain King]");
	return false;
}
