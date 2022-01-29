void bedtime_still()
{
	//quickly use up all remaining uses of Nash Crosby's Still during bedtime
	if(!stillReachable())
	{
		return;		//we can not reach the still
	}
	while(stills_available() > 0)	//spend remaining still uses
	{
		item target = $item[none];
		
		//first try to get at least 1 each of each of the imrpoved booze if possible
		foreach it in $items[bottle of Calcutta Emerald, bottle of Lieutenant Freeman, bottle of Jorge Sinsonte, bottle of Definit, bottle of Domesticated Turkey, boxed champagne]
		{
			if(target == $item[none] && item_amount(it) == 0 && item_amount(still_targetToOrigin(it)) > 0)
			{
				target = it;
			}
		}
		
		//tonic water is an excellent MP restorer and also can be used to craft some drinks.
		if(target == $item[none] && my_meat() > meatReserve() + 100 && isGeneralStoreAvailable())
		{
			if(buyUpTo(1, $item[soda water]))
			{
				target = $item[tonic water];
			}
		}
		
		//if we can not afford tonic water use it on the improved item we have the least of.
		if(target == $item[none])	//below we will replace target with a better target. only do so if we reached this spot without a target
		{
			//all possible still items except [tonic water] and [bottle of Ooze-O]
			foreach it in $items[bottle of Calcutta Emerald, bottle of Lieutenant Freeman, bottle of Jorge Sinsonte, bottle of Definit, bottle of Domesticated Turkey, boxed champagne, bottle of Pete\'s Sake, tangerine, kiwi, cocktail onion, kumquat, raspberry]
			{
				if(target == $item[none] && item_amount(still_targetToOrigin(it)) > 0)	//do not have a target yet
				{
					target = it;
				}
				if(target != $item[none] &&		//have a target and seek a better one
				item_amount(it) < item_amount(target) &&	//we want the target we have the least of
				item_amount(still_targetToOrigin(it)) > 0)	//we need to actually be able to make it
				{
					target = it;
				}
			}
		}
		
		//finally distill the target
		if(target != $item[none])
		{
			if(!distill(target))	//try to distill target. do something if it fails
			{
				auto_log_warning("bedtime_still() failed to distill [" +target+ "] in Nash Crosby's Still and is giving up to avoid infinite loop");
				break;
			}
		}
		else 		//avoid infinite loop if we did not find any valid targets to distill
		{
			auto_log_warning("bedtime_still() could not find any valid targets to distill");
			break;
		}
	
	}
	
	if(stills_available() > 0)
	{
		auto_log_info("You have " + stills_available() + " uses of Nash Crosby's Still left.", "red");
	}
}

int pullsNeeded(string data)
{
	if(inAftercore())
	{
		return 0;
	}
	if (isActuallyEd() || in_community())
	{
		return 0;
	}

	int count = 0;
	int adv = 0;

	int progress = 0;
	if(internalQuestStatus("questL13Final") == 4)
	{
		progress = 1;
	}
	if(internalQuestStatus("questL13Final") == 5)
	{
		progress = 2;
	}
	if(internalQuestStatus("questL13Final") == 6)
	{
		progress = 3;
	}
	if(internalQuestStatus("questL13Final") == 11)
	{
		progress = 4;
	}
	visit_url("campground.php?action=telescopelow");

	if(progress < 1)
	{
		int crowd1score = 0;
		int crowd2score = 0;
		int crowd3score = 0;

//		Note: Maximizer gives concert White-boy angst, instead of concert 3 (consequently, it doesn\'t work).

		switch(ns_crowd1())
		{
		case 1:					crowd1score = initiative_modifier()/40;							break;
		}

		switch(ns_crowd2())
		{
		case $stat[Moxie]:		crowd2score = (my_buffedstat($stat[Moxie]) - 150) / 40;			break;
		case $stat[Muscle]:		crowd2score = (my_buffedstat($stat[Muscle]) - 150) / 40;		break;
		case $stat[Mysticality]:crowd2score = (my_buffedstat($stat[Mysticality]) - 150) / 40;	break;
		}

		switch(ns_crowd3())
		{
		case $element[cold]:	crowd3score = numeric_modifier("cold damage") / 9;				break;
		case $element[hot]:		crowd3score = numeric_modifier("hot damage") / 9;				break;
		case $element[sleaze]:	crowd3score = numeric_modifier("sleaze damage") / 9;			break;
		case $element[spooky]:	crowd3score = numeric_modifier("spooky damage") / 9;			break;
		case $element[stench]:	crowd3score = numeric_modifier("stench damage") / 9;			break;
		}

		crowd1score = min(max(0, crowd1score), 9);
		crowd2score = min(max(0, crowd2score), 9);
		crowd3score = min(max(0, crowd3score), 9);
		adv = adv + (10 - crowd1score) + (10 - crowd2score) + (10 - crowd3score);
	}

	if(progress < 2)
	{
		ns_hedge1();
		ns_hedge2();
		ns_hedge3();

		auto_log_warning("Hedge time of 4 adventures. (Up to 10 without Elemental Resistances)", "red");
		adv = adv + 4;
	}

	if(progress < 3)
	{
		if((item_amount($item[Richard\'s Star Key]) == 0) && (item_amount($item[Star Chart]) == 0))
		{
			auto_log_warning("Need star chart", "red");
			if(in_heavyrains() && (my_rain() >= 50))
			{
				auto_log_info("You should rain man a star chart", "blue");
			}
			else
			{
				count = count + 1;
			}
		}

		if(item_amount($item[Richard\'s Star Key]) == 0)
		{
			int stars = item_amount($item[star]);
			int lines = item_amount($item[line]);

			if(stars < 8)
			{
				auto_log_warning("Need " + (8-stars) + " stars.", "red");
				count = count + (8-stars);
			}
			if(lines < 7)
			{
				auto_log_warning("Need " + (7-lines) + " lines.", "red");
				count = count + (7-lines);
			}
		}

		if(item_amount($item[Digital Key]) == 0 && whitePixelCount() < 30)
		{
			auto_log_warning("Need " + (30-whitePixelCount()) + " white pixels.", "red");
			count = count + (30 - whitePixelCount());
		}

		if(item_amount($item[skeleton key]) == 0)
		{
			if((item_amount($item[skeleton bone]) > 0) && (item_amount($item[loose teeth]) > 0))
			{
				cli_execute("make skeleton key");
			}
		}
		if(item_amount($item[skeleton key]) == 0)
		{
			auto_log_warning("Need a skeleton key or the ingredients (skeleton bone, loose teeth) for it.");
		}
	}

	if(progress < 4)
	{
		adv = adv + 6;
		if(get_property("auto_wandOfNagamar").to_boolean() && (item_amount($item[Wand Of Nagamar]) == 0) && (cloversAvailable() == 0))
		{
			auto_log_warning("Need a wand of nagamar (can be clovered).", "red");
			count = count + 1;
		}
	}

	if(adv > 0)
	{
		auto_log_info("Estimated adventure need (tower) is: " + adv + ".", "orange");
		if(!in_hardcore())
		{
			auto_log_info("You need " + count + " pulls.", "orange");
		}
	}
	if(pulls_remaining() > 0)
	{
		auto_log_info("You have " + pulls_remaining() + " pulls.", "orange");
	}
	return count;
}

float rollover_value(item it)
{
	if(it == $item[none])
	{
		return 0.0;
	}
	float retval = numeric_modifier(it, "adventures");
	if(hippy_stone_broken() && my_path() != "Oxygenarian")
	{
		retval += get_property("auto_bedtime_pulls_pvp_multi").to_float() * numeric_modifier(it, "PvP Fights");
	}
	if(it == $item[your cowboy boots])		//your cowboy boot's add-ons are considered seperate items in their own slots
	{
		retval += rollover_value($slot[bootspur].equipped_item());
		retval += rollover_value($slot[bootskin].equipped_item());
	}
	return retval;
}

float rollover_improvement(item it, slot sl)
{
	//some items can go in multiple slots so we need to specify which slot we want to compare it to.
	//we can then compare such items to multiple slots and find the best slot for it
	return rollover_value(it) - rollover_value(equipped_item(sl));
}

void bedtime_pulls_rollover_equip(float desirability)
{
	//scan through all pullable items for items that have a better rollover adv gain than currently best equipped item.
	
	equipRollover(true);
	for(int i=0; i<10; i++)
	{
		if(pulls_remaining() == 0)
		{
			break;	//we are out of pulls
		}
		
		item[slot] best;
		item very_best;
		float very_best_val;
		float very_best_improvement;
		slot very_best_slot;
		slot a1 = $slot[acc1];
		slot a2 = $slot[acc2];
		slot a3 = $slot[acc3];
		
		//we will need to know which accessory slot is the worst
		slot worst_acc_slot = a1;
		if(rollover_value(equipped_item(worst_acc_slot)) > rollover_value(equipped_item(a2)))
		{
			worst_acc_slot = $slot[acc2];
		}
		if(rollover_value(equipped_item(worst_acc_slot)) > rollover_value(equipped_item(a3)))
		{
			worst_acc_slot = $slot[acc3];
		}
		
		//populate best with current equipment as a baseline
		foreach sl in $slots[hat, back, shirt, pants, acc1, familiar]
		{
			//populating with current item as baseline is necessary for accessories. harmful for weapon/off-hand. and harmless elsewhere.
			if(sl == $slot[acc1])
			{
				sl = worst_acc_slot;
			}
			best[sl] = equipped_item(sl);
		}
		
		//find the best item for each slot
		foreach it in $items[]
		{
			slot sl = it.to_slot();
			if(!($slots[hat, weapon, off-hand, back, shirt, pants, acc1, familiar] contains sl)) continue;	//exotic slot or not equip
			if(!possessEquipment(it) && !canPull(it,true)) continue;		//do not have it and can not pull it.
			if(!auto_can_equip(it)) continue;		//we can not equip it
			
			if($slot[familiar] == sl && !pathHasFamiliar())
			{
				//in paths without familiar do not pull familiar equip.
				if(!in_robot())
				{
					continue;
				}
			}
			if($slot[acc1] == sl)
			{
				//all accessories always return acc1 from to_slot() function.
				//since we are pulling one item at a time we only want to look at the worst slot each time
				//we just need to make sure that equip conflicts do not arise.
				sl = worst_acc_slot;
				
				if(boolean_modifier(it, "Single Equip"))
				{
					if(equipped_amount(it) > 0 && best[sl] != it)
					{
						//we have it equipped but not in the worst slot. So exclude it from optimizing the worst slot.
						continue;
					}
				}
				
				if(is_watch(it))	//watches conflict with each other. only one watch of any kind can be used
				{
					if(equipped_amount(it) > 0 && !is_watch(best[sl]))
					{
						//we have a watch equipped but not in the worst slot. So exclude it from optimizing the worst slot.
						continue;
					}
				}
				
				//can we even pull another copy of this accessory?
				if(equipped_amount(it) > 0 && best[sl] != it && !canPull(it,true))
				{
					continue;
				}
				
				if(rollover_value(it) > rollover_value(best[sl]))
				{
					best[sl] = it;
				}
			}
			else if($slot[weapon] == sl)
			{
				//weapon and off-hand slots might conflict and require special handling
				//two or more handed weapons just need to make sure they are better than best weapon and off-hand combined
				if(weapon_hands(it) > 1)
				{
					if(rollover_value(it) > rollover_value(best[$slot[weapon]]) + rollover_value(best[$slot[off-hand]]))	//for non conflicting slots. calculate normally
					{
						//there is no need to change offhand target since we pull one item at a time. in fact we prefer offhand to retain an independent value
						best[sl] = it;
					}
				}
				else if(weapon_hands(it) == 1)
				{
					//single handed weapons for the weapon slot
					if(weapon_hands(best[sl]) > 1)
					{
						//the currently desired best weapon is 2 handed weapon. so we sum it value with best off-hand found thus far
						if(rollover_value(it) + rollover_value(best[$slot[off-hand]]) > rollover_value(best[sl]))
						{
							best[sl] = it;
						}
					}
					else if(rollover_value(it) > rollover_value(best[sl]))
					{
						//the currently desired best weapon is 1 handed. So we just compare it to best weapon.
						best[sl] = it;
					}
					
					//single handed weapons for the off-hand slot
					boolean weapon_offhand = have_skill($skill[Double-Fisted Skull Smashing]);
					boolean conflict_mainhand = boolean_modifier(it, "Single Equip") && best[sl] == it;
					boolean conflict_quantity = best[sl] == it && !canPull(it,true) && item_amount(it) + equipped_amount(it) < 2;
					if(weapon_offhand && !conflict_mainhand && !conflict_quantity)
					{
						if(rollover_value(it) > rollover_value(best[$slot[off-hand]]))
						{
							best[$slot[off-hand]] = it;
						}
					}
				}
				else abort("[" +it+ "] listed as having " +weapon_hands(it)+ " hands while being a weapon");
			}
			else if(rollover_value(it) > rollover_value(best[sl]))
			{
				//for non conflicting slots. calculate normally.
				//off-hand might conflict but are resolved at the weapon slot in a way that still requires us to find the best offhand
				best[sl] = it;
			}
		}
		
		//find the very best item
		boolean extra_debug = get_property("_auto_extra_debug_bedtime_pulls").to_boolean();
		foreach sl in $slots[hat, weapon, off-hand, back, shirt, pants, acc1, familiar]
		{
			if(sl == $slot[acc1])
			{
				sl = worst_acc_slot;
			}
			
			if(extra_debug)
			{
				//prints out all the items we want. Too messy for normal runs even in debug mode.
				auto_log_debug("[" +sl+ "] wanted [" +best[sl]+ "] val = " +rollover_value(best[sl])+ ". currently [" +equipped_item(sl)+ "] val = " +rollover_value(equipped_item(sl))+ ". improvement = " +rollover_improvement(best[sl], sl));
			}
			
			//if we already pulled the best item for a slot but maximizer failed to equip our best item into it for some reason then we want to exclude that slot from further attempts.
			boolean maximizer_fail = possessEquipment(best[sl]) && equipped_item(sl) != best[sl];
			if(maximizer_fail)
			{
				auto_log_debug("Bedtime pulls: maximizer is not equipping [" +best[sl]+ "] into [" +sl+ "] for some reason. Skipping this slot");
			}
			else if(rollover_improvement(best[sl], sl) > very_best_val)
			{
				very_best = best[sl];
				very_best_val = rollover_improvement(best[sl], sl);
				very_best_slot = sl;
			}
		}

		very_best_improvement = rollover_improvement(very_best, very_best_slot);
		if(very_best_improvement < desirability)
		{
			break;
		}
		auto_log_info("Pulling [" +very_best+ "] which improves desireability score by " +very_best_improvement);
		if(extra_debug) break;
		pullXWhenHaveY(very_best, 1, 0);
		equipRollover(true);
	}
}

void bedtime_pulls_rollover_equip()
{
	bedtime_pulls_rollover_equip(get_property("auto_bedtime_pulls_min_desirability").to_float());
}

void bedtime_pulls()
{
	if(pulls_remaining() < 1)		//out of pulls or in hardcore or in casual.
	{
		return;
	}
	if(get_property("auto_bedtime_pulls_skip").to_boolean())
	{
		return;
	}
	
	if(get_property("auto_bedtime_pulls_min_desirability").to_float() <= 5.0)
	{
		if(item_amount($item[potato alarm clock]) == 0 && storage_amount($item[potato alarm clock]) > 0)
		{
			pullXWhenHaveY($item[potato alarm clock], 1, 0);
		}

		if(my_daycount() == 1 && my_level() <= 8)
		{
			//this run looks like it will take a couple more days, give priority to good rollover equipment before level 11 quest pulls
			bedtime_pulls_rollover_equip(5.0);
		}
	}

	if(item_amount($item[Muculent Machete]) == 0 && (!is_boris() || !in_wotsf() || !in_pokefam())) // no need in paths where can't use machete
	{
		pullXWhenHaveY($item[Antique Machete], 1, 0);
	}
	if(item_amount($item[Wet Stunt Nut Stew]) == 0 && !possessEquipment($item[Mega Gem]) && !isActuallyEd())
	{
		pullXWhenHaveY($item[wet stew], 1, 0);
	}
	if(!black_market_available())
	{
		pullXWhenHaveY($item[blackberry galoshes], 1, 0);
	}
	if(internalQuestStatus("questL11Desert") < 1)
	{
		int gnasirProgress = get_property("gnasirProgress").to_int();
		if ((gnasirProgress & 16) == 0)
		{
			pullXWhenHaveY($item[drum machine], 1, 0);
		}
		if ((gnasirProgress & 4) == 0)
		{
			pullXWhenHaveY($item[killing jar], 1, 0);
		}
	}
	
	//scan through all pullable items for items that have a better rollover adv gain than currently best equipped item.
	bedtime_pulls_rollover_equip();

	//always pull an 11-leaf clover, if possible
	pullXWhenHaveY($item[11-Leaf Clover], 1, item_amount($item[11-Leaf Clover]));
}

boolean doBedtime()
{
	auto_log_info("Starting bedtime: Pulls Left: " + pulls_remaining(), "blue");

	if(get_property("lastEncounter") == "Like a Bat Into Hell")
	{
		abort("Our last encounter was UNDYING and we ended up trying to bedtime and failed.");
	}

	auto_process_kmail("auto_deleteMail");

	if(my_adventures() > 4)
	{
		if(my_inebriety() <= inebriety_limit())
		{
			if(!in_gnoob() && my_familiar() != $familiar[Stooper])
			{
				return false;
			}
		}
	}
	boolean out_of_blood = (in_darkGyffte() && item_amount($item[blood bag]) == 0);
	if((fullness_left() > 0) && can_eat() && !out_of_blood)
	{
		return false;
	}
	if((inebriety_left() > 0) && can_drink() && !out_of_blood)
	{
		return false;
	}
	int spleenlimit = spleen_limit();
	if(!canChangeFamiliar())
	{
		spleenlimit -= 3;
	}
	if(!haveSpleenFamiliar())
	{
		spleenlimit = 0;
	}
	if((my_spleen_use() < spleenlimit) && !in_hardcore() && (inebriety_left() > 0))
	{
		return false;
	}

	ed_terminateSession();
	bat_terminateSession();

	while(LX_freeCombats());

	if((my_class() == $class[Seal Clubber]) && guild_store_available())
	{
		handleFamiliar("stat");
		int oldSeals = get_property("_sealsSummoned").to_int();
		while((get_property("_sealsSummoned").to_int() < 5) && (!inAftercore()) && (my_meat() > 4500))
		{
			boolean summoned = false;
			if((my_daycount() == 1) && (my_level() >= 6) && isHermitAvailable())
			{
				cli_execute("make figurine of an ancient seal");
				buyUpTo(3, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealAncient();
				summoned = true;
			}
			else if(my_level() >= 9)
			{
				buyUpTo(1, $item[figurine of an armored seal]);
				buyUpTo(10, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealNormal($item[Figurine of an Armored Seal]);
				summoned = true;
			}
			else if(my_level() >= 5)
			{
				buyUpTo(1, $item[figurine of a Cute Baby Seal]);
				buyUpTo(5, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealNormal($item[Figurine of a Cute Baby Seal]);
				summoned = true;
			}
			else
			{
				buyUpTo(1, $item[figurine of a Wretched-Looking Seal]);
				buyUpTo(1, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealNormal($item[Figurine of a Wretched-Looking Seal]);
				summoned = true;
			}
			int newSeals = get_property("_sealsSummoned").to_int();
			if((newSeals == oldSeals) && summoned)
			{
				abort("Unable to summon seals.");
			}
			oldSeals = newSeals;
		}
	}

	if(get_property("auto_priorCharpaneMode").to_int() == 1)
	{
		auto_log_info("Resuming Compact Character Mode.");
		set_property("auto_priorCharpaneMode", 0);
		visit_url("account.php?am=1&pwd=&action=flag_compactchar&value=1&ajax=0", true);
	}

	if((item_amount($item[License To Chill]) > 0) && !get_property("_licenseToChillUsed").to_boolean())
	{
		use(1, $item[License To Chill]);
	}

	if((my_inebriety() <= inebriety_limit()) && can_drink() && (my_rain() >= 50) && (my_adventures() >= 1))
	{
		if(my_daycount() == 1)
		{
			if(item_amount($item[Rain-Doh Indigo Cup]) > 0)
			{
				auto_log_info("Copies left: " + (5 - get_property("_raindohCopiesMade").to_int()), "olive");
			}
			if(!in_hardcore())
			{
				auto_log_info("Pulls remaining: " + pulls_remaining(), "olive");
			}
			if(item_amount($item[beer helmet]) == 0)
			{
				auto_log_info("Please consider an orcish frat boy spy (You want Frat Warrior Fatigues).", "blue");
				if(canYellowRay())
				{
					auto_log_info("Make sure to Ball Lightning the spy!!", "red");
				}
			}
			else
			{
				auto_log_info("If you have the Frat Warrior Fatigues, rain man an Astronomer? Skinflute?", "blue");
			}
		}
		if(auto_have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 5) && (inebriety_left() >= 0) && (my_adventures() > 0))
		{
			auto_log_info("You have " + (5 - get_property("_machineTunnelsAdv").to_int()) + " fights in The Deep Machine Tunnels that you should use!", "blue");
		}
		auto_log_info("You have a rain man to cast, please do so before overdrinking and run me again.", "red");
		return false;
	}

	//We are committing to end of day now...
	getSpaceJelly();
	while(acquireHermitItem($item[11-leaf Clover]));

	januaryToteAcquire($item[Makeshift Garbage Shirt]);		//doubles stat gains in the LOV tunnel. also keep leftover charges for tomorrow.
	loveTunnelAcquire(true, $stat[none], true, 3, true, 1);

	if(item_amount($item[Genie Bottle]) > 0)
	{
		for(int i=get_property("_genieWishesUsed").to_int(); i<3; i++)
		{
			makeGeniePocket();
		}
	}
	if(canGenieCombat() && item_amount($item[beer helmet]) == 0)
	{
		auto_log_info("Please consider genie wishing for an orcish frat boy spy (You want Frat Warrior Fatigues).", "blue");
	}

	if((friars_available()) && (!get_property("friarsBlessingReceived").to_boolean()))
	{
		if(in_pokefam() || in_darkGyffte())
		{
			cli_execute("friars food");
		}
		else
		{
			cli_execute("friars familiar");
		}
	}

	# This does not check if we still want these buffs
	if((my_hp() < (0.9 * my_maxhp())) && hotTubSoaksRemaining() > 0)
	{
		boolean doTub = true;
		foreach eff in $effects[Once-Cursed, Thrice-Cursed, Twice-Cursed]
		{
			if(have_effect(eff) > 0)
			{
				doTub = false;
			}
		}
		if(doTub)
		{
			doHottub();
		}
	}

	if(!get_property("_mayoTankSoaked").to_boolean() && (auto_get_campground() contains $item[Portable Mayo Clinic]) && is_unrestricted($item[Portable Mayo Clinic]))
	{
		string temp = visit_url("shop.php?action=bacta&whichshop=mayoclinic");
	}

	if(in_nuclear() && (get_property("falloutShelterLevel").to_int() >= 3) && !get_property("_falloutShelterSpaUsed").to_boolean())
	{
		string temp = visit_url("place.php?whichplace=falloutshelter&action=vault3");
	}

	//	Also use "nunsVisits", as long as they were won by the Frat (sidequestNunsCompleted="fratboy").
	ed_doResting();
	skill libram = preferredLibram();
	if(libram != $skill[none])
	{
		while(haveFreeRestAvailable() && (mp_cost(libram) <= my_maxmp()))
		{
			doFreeRest();
			while(my_mp() > mp_cost(libram))
			{
				use_skill(1, libram);
			}
		}
	}

	if((is_unrestricted($item[Clan Pool Table])) && (get_property("_poolGames").to_int() < 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
	{
		visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
		visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
		visit_url("clan_viplounge.php?preaction=poolgame&stance=3");
	}
	if(is_unrestricted($item[Colorful Plastic Ball]) && !get_property("_ballpit").to_boolean() && (get_clan_id() != -1))
	{
		cli_execute("ballpit");
	}
	if (get_property("telescopeUpgrades").to_int() > 0 && internalQuestStatus("questL13Final") < 0)
	{
		if(get_property("telescopeLookedHigh") == "false")
		{
			cli_execute("telescope high");
		}
	}

	if(!possessEquipment($item[Vicar\'s Tutu]) && (my_daycount() == 1) && (item_amount($item[lump of Brituminous coal]) > 0))
	{
		if((item_amount($item[frilly skirt]) < 1) && knoll_available())
		{
			buyUpTo(1, $item[frilly skirt]);
		}
		if(item_amount($item[frilly skirt]) > 0)
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[frilly skirt]);
		}
	}

	if((my_daycount() == 1) && (possessEquipment($item[Thor\'s Pliers]) || (freeCrafts() > 0)) && !possessEquipment($item[Chrome Sword]) && !inAftercore() && !in_tcrs())
	{
		item oreGoal = to_item(get_property("trapperOre"));
		int need = 1;
		boolean haveAdvSmithing = have_skill($skill[Super-Advanced Meatsmithing]);
		if(oreGoal == $item[Chrome Ore])
		{
			need = 4;
		}
		if (!haveAdvSmithing) {
			auto_log_info('No Super-Advanced Meatsmithing for chrome sword crafting!');
		}
		if((item_amount($item[Chrome Ore]) >= need) && !possessEquipment($item[Chrome Sword]) && isArmoryAvailable() && haveAdvSmithing)
		{
			cli_execute("make " + $item[Chrome Sword]);
		}
		else
		{
			auto_log_info('Did not make chrome sword');
		}
	}

	equipRollover(false);
	heavyrains_doBedtime();

	while(my_daycount() == 1 && item_amount($item[resolution: be more adventurous]) > 0 && get_property("_resolutionAdv").to_int() < 10 && !can_interact())
	{
		use(1, $item[resolution: be more adventurous]);
	}

	// If in TCRS skip using freecrafts but alert user of how many they can manually use.
	if(in_tcrs() && (freeCrafts() > 0))
	{
		auto_log_warning("In TCRS: Items are variable, skipping End Of Day crafting", "red");
		auto_log_warning("Consider manually using your "+freeCrafts()+" free crafts", "red");
	}
	else if((my_daycount() <= 2) && (freeCrafts() > 0) && my_adventures() > 0)
	{
		// Check for rapid prototyping
		while((freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Cranberries]) > 0) && (item_amount($item[Cranberry Cordial]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			cli_execute("make " + $item[Cranberry Cordial]);
		}
		put_closet(item_amount($item[Cranberries]), $item[Cranberries]);
		while((freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Glass Of Goat\'s Milk]) > 0) && (item_amount($item[Milk Of Magnesium]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			cli_execute("make " + $item[Milk Of Magnesium]);
		}
	}

	dna_bedtime();

	if((get_property("_grimBuff") == "false") && auto_have_familiar($familiar[Grim Brother]))
	{
		string temp = visit_url("choice.php?pwd=&whichchoice=835&option=1", true);
	}

	dailyEvents();
	if((get_property("auto_clanstuff").to_int() < my_daycount()) && (get_clan_id() != -1))
	{
		if(get_property("_klawSummons").to_int() == 0 && get_clan_rumpus() contains 'Mr. Klaw "Skill" Crane Game')
		{
			cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
			cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
			cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
		}
		if(item_amount($item[Clan VIP Lounge Key]) > 0)
		{
			if(is_unrestricted($item[Olympic-sized Clan Crate]) && !get_property("_olympicSwimmingPool").to_boolean())
			{
				cli_execute("swim noncombat");
			}
			if(is_unrestricted($item[Olympic-sized Clan Crate]) && !get_property("_olympicSwimmingPoolItemFound").to_boolean())
			{
				cli_execute("swim item");
			}
			if(is_unrestricted($item[Clan Looking Glass]) && !get_property("_lookingGlass").to_boolean())
			{
				string temp = visit_url("clan_viplounge.php?action=lookingglass");
			}
			if(get_property("_deluxeKlawSummons").to_int() == 0)
			{
				cli_execute("clan_viplounge.php?action=klaw");
				cli_execute("clan_viplounge.php?action=klaw");
				cli_execute("clan_viplounge.php?action=klaw");
			}
			if(!get_property("_aprilShower").to_boolean())
			{
				if(inAftercore())
				{
					cli_execute("shower ice");
				}
				else
				{
					cli_execute("shower " + my_primestat());
				}
			}
			if(is_unrestricted($item[Crimbough]) && !get_property("_crimboTree").to_boolean())
			{
				cli_execute("crimbotree get");
			}
		}
		set_property("auto_clanstuff", ""+my_daycount());
	}

	if((get_property("sidequestOrchardCompleted") != "none") && !get_property("_hippyMeatCollected").to_boolean())
	{
		visit_url("shop.php?whichshop=hippy");
	}

	if((get_property("sidequestArenaCompleted") != "none") && !get_property("concertVisited").to_boolean())
	{
		cli_execute("concert 2");
	}
	if(inAftercore())
	{
		if((item_amount($item[The Legendary Beat]) > 0) && !get_property("_legendaryBeat").to_boolean())
		{
			use(1, $item[The Legendary Beat]);
		}
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() == 0)
		{
			cli_execute("make unbearable light");
		}
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() == 1)
		{
			cli_execute("make cold-filtered water");
		}
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() == 2)
		{
			cli_execute("make bucket of wine");
		}
		if((item_amount($item[Handmade Hobby Horse]) > 0) && !get_property("_hobbyHorseUsed").to_boolean())
		{
			use(1, $item[Handmade Hobby Horse]);
		}
		if((item_amount($item[ball-in-a-cup]) > 0) && !get_property("_ballInACupUsed").to_boolean())
		{
			use(1, $item[ball-in-a-cup]);
		}
		if((item_amount($item[set of jacks]) > 0) && !get_property("_setOfJacksUsed").to_boolean())
		{
			use(1, $item[set of jacks]);
		}
	}

	if((my_daycount() - 5) >= get_property("lastAnticheeseDay").to_int())
	{
		visit_url("place.php?whichplace=desertbeach&action=db_nukehouse");
	}

	if(auto_haveWitchess() && (get_property("puzzleChampBonus").to_int() == 20) && !get_property("_witchessBuff").to_boolean())
	{
		visit_url("campground.php?action=witchess");
		visit_url("choice.php?whichchoice=1181&pwd=&option=3");
		visit_url("choice.php?whichchoice=1183&pwd=&option=2");
	}

	if(auto_haveSourceTerminal())
	{
		int enhances = auto_sourceTerminalEnhanceLeft();
		while(enhances > 0)
		{
			auto_sourceTerminalEnhance("items");
			auto_sourceTerminalEnhance("meat");
			enhances -= 2;
		}
	}

	// Is +50% to all stats the best choice here? I don't know!
	spacegateVaccine($effect[Broad-Spectrum Vaccine]);

	zataraSeaside("item");

	if(is_unrestricted($item[Source Terminal]) && (get_campground() contains $item[Source Terminal]))
	{
		if(!inAftercore() && (get_property("auto_extrudeChoice") != "none"))
		{
			int count = 3 - get_property("_sourceTerminalExtrudes").to_int();

			string[int] extrudeChoice;
			if(get_property("auto_extrudeChoice") != "")
			{
				string[int] extrudeDays = split_string(get_property("auto_extrudeChoice"), ":");
				string[int] tempChoice = split_string(trim(extrudeDays[min(count(extrudeDays), my_daycount()) - 1]), ";");
				for(int i=0; i<count(tempChoice); i++)
				{
					extrudeChoice[i] = tempChoice[i];
				}
			}
			int amt = count(extrudeChoice);
			string acquire = "booze";
			if(auto_my_path() == "Teetotaler")
			{
				acquire = "food";
			}
			while(amt < 3)
			{
				extrudeChoice[count(extrudeChoice)] = acquire;
				amt++;
			}

			while((count > 0) && (item_amount($item[Source Essence]) >= 10))
			{
				auto_sourceTerminalExtrude(extrudeChoice[3-count]);
				count -= 1;
			}
		}
		int extrudeLeft = 3 - get_property("_sourceTerminalExtrudes").to_int();
		if(extrudeLeft > 0 && !in_pokefam() && item_amount($item[Source Essence]) >= 10)
		{
			auto_log_info("You still have " + extrudeLeft + " Source Extrusions left", "blue");
		}
	}

	auto_burnPowerfulGloveCharges();

	if(item_amount($item[Rain-Doh Indigo Cup]) > 0)
	{
		auto_log_info("Copies left: " + (5 - get_property("_raindohCopiesMade").to_int()), "olive");
	}
	if(!in_hardcore())
	{
		auto_log_info("Pulls remaining: " + pulls_remaining(), "olive");
	}

	if(have_skill($skill[Inigo\'s Incantation of Inspiration]))
	{
		int craftingLeft = 5 - get_property("_inigosCasts").to_int();
		auto_log_info("Free Inigo\'s craftings left: " + craftingLeft, "blue");
	}
	if(item_amount($item[Loathing Legion Jackhammer]) > 0)
	{
		int craftingLeft = 3 - get_property("_legionJackhammerCrafting").to_int();
		auto_log_info("Free Loathing Legion Jackhammer craftings left: " + craftingLeft, "blue");
	}
	if(item_amount($item[Thor\'s Pliers]) > 0)
	{
		int craftingLeft = 10 - get_property("_thorsPliersCrafting").to_int();
		auto_log_info("Free Thor's Pliers craftings left: " + craftingLeft, "blue");
	}
	if(freeCrafts() > 0)
	{
		auto_log_info("Free craftings left: " + freeCrafts(), "blue");
	}
	if(get_property("timesRested").to_int() < total_free_rests())
	{
		cs_spendRests();
		auto_log_info("You have " + (total_free_rests() - get_property("timesRested").to_int()) + " free rests remaining.", "blue");
	}
	if(possessEquipment($item[Kremlin\'s Greatest Briefcase]) && (get_property("_kgbClicksUsed").to_int() < 24))
	{
		kgbWasteClicks();
		int clicks = 22 - get_property("_kgbClicksUsed").to_int();
		if(clicks > 0)
		{
			auto_log_info("You have some KGB clicks (" + clicks + ") left!", "green");
		}
	}
	if((get_property("sidequestNunsCompleted") == "fratboy") && (get_property("nunsVisits").to_int() < 3))
	{
		auto_log_info("You have " + (3 - get_property("nunsVisits").to_int()) + " nuns visits left.", "blue");
	}
	if(get_property("libramSummons").to_int() > 0)
	{
		auto_log_info("Total Libram Summons: " + get_property("libramSummons"), "blue");
	}

	int smiles = (5 * (item_amount($item[Golden Mr. Accessory]) + storage_amount($item[Golden Mr. Accessory]) + closet_amount($item[Golden Mr. Accessory]))) - get_property("_smilesOfMrA").to_int();
	if(in_glover())
	{
		smiles = 0;
	}
	if(smiles > 0)
	{
		if(get_property("auto_smileAt") != "")
		{
			cli_execute("/cast " + smiles + " the smile @ " + get_property("auto_smileAt"));
		}
		else
		{
			auto_log_info("You have " + smiles + " smiles of Mr. A remaining.", "blue");
		}
	}

	if((item_amount($item[CSA Fire-Starting Kit]) > 0) && (!get_property("_fireStartingKitUsed").to_boolean()))
	{
		auto_log_info("Still have a CSA Fire-Starting Kit you can use!", "blue");
	}
	if((item_amount($item[Glenn\'s Golden Dice]) > 0) && (!get_property("_glennGoldenDiceUsed").to_boolean()))
	{
		auto_log_info("Still have some of Glenn's Golden Dice that you can use!", "blue");
	}
	if((item_amount($item[License to Chill]) > 0) && (!get_property("_licenseToChillUsed").to_boolean()))
	{
		auto_log_info("You are still licensed enough to be able to chill.", "blue");
	}

	if((item_amount($item[School of Hard Knocks Diploma]) > 0) && (!get_property("_hardKnocksDiplomaUsed").to_boolean()))
	{
		use(1, $item[School of Hard Knocks Diploma]);
	}

	if(!get_property("_lyleFavored").to_boolean())
	{
		string temp = visit_url("place.php?whichplace=monorail&action=monorail_lyle");
	}

	if (get_property("spookyAirportAlways").to_boolean() && !isActuallyEd() && !get_property("_controlPanelUsed").to_boolean())
	{
		visit_url("place.php?whichplace=airport_spooky_bunker&action=si_controlpanel");
		visit_url("choice.php?pwd=&whichchoice=986&option=8",true);
		if(get_property("controlPanelOmega").to_int() >= 99)
		{
			visit_url("choice.php?pwd=&whichchoice=986&option=10",true);
		}
	}

	elementalPlanes_takeJob($element[spooky]);
	elementalPlanes_takeJob($element[stench]);
	elementalPlanes_takeJob($element[cold]);

	if((get_property("auto_dickstab").to_boolean()) && chateaumantegna_available() && (my_daycount() == 1))
	{
		boolean[item] furniture = chateaumantegna_decorations();
		if(!furniture[$item[Artificial Skylight]])
		{
			chateaumantegna_buyStuff($item[Artificial Skylight]);
		}
	}

	auto_beachUseFreeCombs();
	auto_drinkNightcap();

	if(in_plumber() && fullness_left() > 0)
	{
		print("Plumber consumption is complicated. Please manually consume stuff then run me again.", "red");
		return false;
	}
	
	boolean done = (my_inebriety() > inebriety_limit()) || (my_inebriety() == inebriety_limit() && my_familiar() == $familiar[Stooper]);
	if(in_gnoob() || !can_drink() || out_of_blood)
	{
		if((my_adventures() <= 2) || (internalQuestStatus("questL13Final") >= 14))
		{
			done = true;
		}
	}
	if(in_robot())
	{
		//robots eat energy not food nor booze.
		boolean chronolith_done = my_robot_energy() < robot_chronolith_cost() || robot_chronolith_cost() > 47;
		done = chronolith_done && !auto_unreservedAdvRemaining();
	}
	if(!done)
	{
		auto_log_info("Goodnight done, please make sure to handle your overdrinking, then you can run me again.", "blue");
		if(have_familiar($familiar[Stooper]) &&	//do not use auto_ that returns false in 100run, which stooper drinking does not interrupt.
		pathAllowsChangingFamiliar() &&		//some paths forbid familiar or dont allow changing it but mafia still indicates you have the familiar
		inebriety_left() == 0 &&	//stooper drinking is only useful when liver is exactly at max without a stooper equipped.
		my_familiar() != $familiar[Stooper])
		{
			auto_log_info("You have a Stooper, you can increase liver by 1!", "blue");
			use_familiar($familiar[Stooper]);
		}
		if(auto_have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 5))
		{
			auto_log_info("You have " + (5 - get_property("_machineTunnelsAdv").to_int()) + " fights in The Deep Machine Tunnels that you should use!", "blue");
		}
		if((my_inebriety() <= inebriety_limit()) && (my_rain() >= 50) && (my_adventures() >= 1))
		{
			auto_log_info("You have a rain man to cast, please do so before overdrinking and then run me again.", "red");
			return false;
		}
		auto_printNightcap();
		auto_log_warning("You need to overdrink and then run me again. Beep.", "red");
		if(have_skill($skill[The Ode to Booze]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze]);
		}
		return false;
	}
	else
	{
		if(!inAftercore())
		{
			string banish_str = get_property("auto_banishes_day" + my_daycount());
			if(banish_str != "")
			{
				auto_log_info(banish_str);
			}
			string yellowRay_str = get_property("auto_yellowRay_day" + my_daycount());
			if(yellowRay_str != "")
			{
				auto_log_info(yellowRay_str);
			}
			if(!get_property("_photocopyUsed").to_boolean() && (is_unrestricted($item[Deluxe Fax Machine])) && (my_adventures() > 0) && !(is_boris() || is_jarlsberg() || is_pete()) && (item_amount($item[Clan VIP Lounge Key]) > 0))
			{
				auto_log_info("You may have a fax that you can use. Check it out!", "blue");
			}
		}
		
		bedtime_still();	//quickly use up all remaining uses of Nash Crosby's Still during bedtime

		if(get_workshed() == $item[spinning wheel] && is_unrestricted($item[spinning wheel]) && !get_property("_spinningWheel").to_boolean())
		{
			auto_log_info("Using the spinning wheel in your workshed", "blue");
			visit_url("campground.php?action=spinningwheel");
		}
		
		bedtime_pulls();
		pullsNeeded("evaluate");

		if(have_skill($skill[Calculate the Universe]) && (get_property("_universeCalculated").to_int() < get_property("skillLevel144").to_int()))
		{
			auto_log_info("You can still Calculate the Universe!", "blue");
		}

		if(is_unrestricted($item[Deck of Every Card]) && (item_amount($item[Deck of Every Card]) > 0) && (get_property("_deckCardsDrawn").to_int() < 15))
		{
			auto_log_info("You have a Deck of Every Card and " + (15 - get_property("_deckCardsDrawn").to_int()) + " draws remaining!", "blue");
		}

		if(is_unrestricted($item[Time-Spinner]) && (item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() < 10) && glover_usable($item[Time-Spinner]))
		{
			auto_log_info("You have " + (10 - get_property("_timeSpinnerMinutesUsed").to_int()) + " minutes left to Time-Spinner!", "blue");
		}

		if(is_unrestricted($item[Chateau Mantegna Room Key]) && !get_property("_chateauMonsterFought").to_boolean() && get_property("chateauAvailable").to_boolean())
		{
			auto_log_info("You can still fight a Chateau Mangtegna Painting today.", "blue");
		}

		if(!get_property("_streamsCrossed").to_boolean() && possessEquipment($item[Protonic Accelerator Pack]))
		{
			cli_execute("crossstreams");
		}

		if(is_unrestricted($item[shrine to the Barrel God]) && !get_property("_barrelPrayer").to_boolean() && get_property("barrelShrineUnlocked").to_boolean())
		{
			auto_log_info("You can still worship the barrel god today.", "blue");
		}
		if(is_unrestricted($item[Airplane Charter: Dinseylandfill]) && !get_property("_dinseyGarbageDisposed").to_boolean() && elementalPlanes_access($element[stench]))
		{
			if((item_amount($item[bag of park garbage]) > 0) || (pulls_remaining() > 0))
			{
				auto_log_info("You can still dispose of Garbage in Dinseyland.", "blue");
			}
		}
		if(is_unrestricted($item[Airplane Charter: That 70s Volcano]) && !get_property("_infernoDiscoVisited").to_boolean() && elementalPlanes_access($element[hot]))
		{
			if((item_amount($item[Smooth Velvet Hat]) > 0) || (item_amount($item[Smooth Velvet Shirt]) > 0) || (item_amount($item[Smooth Velvet Pants]) > 0) || (item_amount($item[Smooth Velvet Hanky]) > 0) || (item_amount($item[Smooth Velvet Pocket Square]) > 0) || (item_amount($item[Smooth Velvet Socks]) > 0))
			{
				auto_log_info("You can still disco inferno at the Inferno Disco.", "blue");
			}
		}
		if(is_unrestricted($item[Potted Tea Tree]) && !get_property("_pottedTeaTreeUsed").to_boolean() && (auto_get_campground() contains $item[Potted Tea Tree]))
		{
			auto_log_info("You have a tea tree to shake!", "blue");
		}

		if (get_property("spadingData") != "")
		{
			cli_execute("spade autoconfirm");
		}

		auto_log_info("You are probably done for today, beep.", "blue");
		return true;
	}
	return false;
}
