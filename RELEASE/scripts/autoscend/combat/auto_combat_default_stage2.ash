string auto_combatDefaultStage2(int round, monster enemy, string text)
{
	##stage 2 = debuff: delevel, stun, curse, damage over time
	string retval;
	
	#Path = Heavy Rains
	retval = auto_combatHeavyRainsStage2(round, enemy, text);
	if(retval != "") return retval;
	
	//delevel (10 + medicine_level)% in avatar of west of loathing path
	if(canUse($skill[Bad Medicine]) && (my_mp() >= (3 * mp_cost($skill[Bad Medicine]))))
	{
		return useSkill($skill[Bad Medicine]);
	}
	
	//boris specific 3MP skill that delevels by 15%, with an upgrade it delevels 30% and stuns.
	//even without the upgrade it it is worth it. actually without upgrade you need it more due to low skill.
	if(canUse($skill[Intimidating Bellow]) && expected_damage() > 0 && !enemyCanBlocksSkills())
	{
		return useSkill($skill[Intimidating Bellow]);
	}
	
	//if monster level adjustment is over 150 then they are immune to staggers. many deleveling skills also stagger.
	int enemy_la = monster_level_adjustment();
	
	//shape of a mole when using Llama lama gong. delevel by 5
	if(canUse($skill[Tunnel Downwards]) && (have_effect($effect[Shape of...Mole!]) > 0) && (my_location() == $location[Mt. Molehill]))
	{
		return useSkill($skill[Tunnel Downwards]);
	}
	
	//iotm familiar specific skill. delevel by 10 and try to steal an item. can be used on any combat round, repeatedly until an item is stolen
	if(canUse($skill[Hugs and Kisses!]) && (my_familiar() == $familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() < 11))
	{
		boolean dohug = false;
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			dohug = true;
		}

		if(get_property("_xoHugsUsed").to_int() < 8)
		{
			// snatch a wig if we're lucky
			if(enemy == $monster[Burly Sidekick] && !possessEquipment($item[Mohawk wig]))
				dohug = true;

			// snatch a hedge trimmer if we're lucky
			if($monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal] contains enemy)
				dohug = true;

			// snatch a killing jar if we're lucky
			if(enemy == $monster[banshee librarian] && (0 == item_amount($item[Killing jar])))
				dohug = true;

			// snatch a sonar-in-a-biscuit if we're lucky
			if((item_drops(enemy) contains $item[sonar-in-a-biscuit]) && (count(item_drops(enemy)) <= 2) && (get_property("questL04Bat")) != "finished")
				dohug = true;
		}

		if(dohug)
		{
			handleTracker(enemy, $skill[Hugs and Kisses!], "auto_otherstuff");
			return useSkill($skill[Hugs and Kisses!]);
		}
	}
	
	//delevel ~3% per combat round for rest of combat.
	//if sauceror and you kill enemy with a spell you regain up to 50MP. this is the primary source of MP for a sauceror.
	//with itchy curse finger skill it will also stagger on the turn it is cast
	boolean doWeaksauce = true;
	if((buffed_hit_stat() - 20) > monster_defense())
	{
		doWeaksauce = false;
	}
	if(my_class() == $class[Sauceror])
	{
		doWeaksauce = true;
	}
	// if(enemy == $monster[invader bullet]) // TODO: on version bump
	if(enemy.to_string().to_lower_case() == "invader bullet")
	{
		doWeaksauce = false;
	}
	if(canUse($skill[Curse of Weaksauce]) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
	{
		return useSkill($skill[Curse of Weaksauce]);
	}
	
	//[Eldritch Tentacle] is Immune to Stuns, Staggers, automatic kills and has a 50% resistance to Deleveling
	if(enemy == $monster[Eldritch Tentacle])
	{
		enemy_la = 151;
	}

	// if(enemy == $monster[invader bullet]) // TODO: on version bump
	if(enemy.to_string().to_lower_case() == "invader bullet")
	{
		enemy_la = 151;
	}

	if($monsters[Naughty Sorceress, Naughty Sorceress (2)] contains enemy && !get_property("auto_confidence").to_boolean())
	{
		enemy_la = 151;
	}

	#Default behaviors:
	if(enemy_la <= 150)		//enemy has not been rendered immune to staggering from monster level
	{
		if(canUse($skill[Curse of Weaksauce]) && have_skill($skill[Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}

		if($item[Daily Affirmation: Keep Free Hate In Your Heart].combat)
		{
			if(canUse($item[Daily Affirmation: Keep Free Hate In Your Heart]) && inAftercore() && hippy_stone_broken() && !get_property("_affirmationHateUsed").to_boolean())
			{
				return useItem($item[Daily Affirmation: Keep Free Hate In Your Heart]);
			}
		}

		if(canUse($skill[Canhandle]))
		{
			if($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand]))
			{
				return useSkill($skill[Canhandle]);
			}
		}

		if (canUse($skill[Curse Of Weaksauce]) && my_class() == $class[Sauceror] && doWeaksauce)
		{
			return useSkill($skill[Curse Of Weaksauce]);
		}

		if(canUse($skill[Detect Weakness]))
		{
			return useSkill($skill[Detect Weakness]);
		}

		if(canUse($skill[Deploy Robo-Handcuffs]))
		{
			return useSkill($skill[Deploy Robo-Handcuffs]);
		}

		if(canUse($skill[Pocket Crumbs]))
		{
			return useSkill($skill[Pocket Crumbs]);
		}

		if(canUse($skill[Micrometeorite]))
		{
			return useSkill($skill[Micrometeorite]);
		}

		if(canUse($item[Cow Poker]))
		{
			if($monsters[Caugr, Moomy, Pharaoh Amoon-Ra Cowtep, Pyrobove, Spidercow] contains enemy)
			{
				return useItem($item[Cow Poker]);
			}
		}

		if(canUse($item[Western-Style Skinning Knife]))
		{
			if($monsters[Caugr, Coal Snake, Diamondback Rattler, Frontwinder, Grizzled Bear, Mountain Lion] contains enemy)
			{
				return useItem($item[Western-Style Skinning Knife]);
			}
		}

		if(my_location() == $location[The Smut Orc Logging Camp] && canSurvive(1.0))
		{
			// Listed from Most to Least Damaging to hopefully cause Death on the turn when the Shell hits.
			if(canUse($skill[Stuffed Mortar Shell]) && have_effect($effect[Spirit of Peppermint]) != 0)
			{
				return useSkill($skill[Stuffed Mortar Shell]);
			}
			else if(canUse($skill[Saucegeyser], false))
			{
				return useSkill($skill[Saucegeyser], false);
			}
			else if(canUse($skill[Saucecicle], false))
			{
				return useSkill($skill[Saucecicle], false);
			}
			else if(canUse($skill[Cannelloni Cannon], false) && have_effect($effect[Spirit of Peppermint]) != 0)
			{
				return useSkill($skill[Cannelloni Cannon], false);
			}
			else if(canUse($skill[Northern Explosion], false))
			{
				return useSkill($skill[Northern Explosion], false);
			}
			else if($classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief] contains my_class())
			{
				auto_log_warning("None of our preferred [cold] skills available against smut orcs. Engaging in Fisticuffs.", "red");
			}
		}

		if(my_location() == $location[The Haunted Kitchen] && canUse($skill[Become a Cloud of Mist]) && get_property("_vampyreCloakeFormUses").to_int() < 10)
		{
			int hot = to_int(numeric_modifier("Hot Resistance"));
			int stench = to_int(numeric_modifier("Stench Resistance"));

			if(((hot < 9 && hot % 3 != 0) || (stench < 9 && stench % 3 != 0)) && canUse($skill[Become a Cloud of Mist]))
			{
				return useSkill($skill[Become a Cloud of Mist]);
			}
		}

		if (enemy == $monster[dirty thieving brigand] && canUse($skill[Become a Wolf]) && get_property("_vampyreCloakeFormUses").to_int() < 10)
		{
			return useSkill($skill[Become a Wolf]);
		}

		if(canUse($skill[Air Dirty Laundry]))
		{
			return useSkill($skill[Air Dirty Laundry]);
		}

		if(canUse($skill[Cowboy Kick]))
		{
			return useSkill($skill[Cowboy Kick]);
		}

		if(canUse($skill[Fire Death Ray]))
		{
			return useSkill($skill[Fire Death Ray]);
		}

		if(canUse($skill[ply reality]))
		{
			return useSkill($skill[Ply Reality]);
		}

		if(canUse($item[Rain-Doh indigo cup]))
		{
			return useItem($item[Rain-Doh Indigo Cup]);
		}

		if(canUse($skill[Summon Love Mosquito]))
		{
			return useSkill($skill[Summon Love Mosquito]);
		}

		if(canUse($item[Tomayohawk-Style Reflex Hammer]))
		{
			return useItem($item[Tomayohawk-Style Reflex Hammer]);
		}

		// skills from Lathe weapons
		// Ebony Epee
		if(canUse($skill[Disarming Thrust]))
		{
			return useSkill($skill[Disarming Thrust]);
		}
		// Weeping Willow Wand
		if(canUse($skill[Barrage of Tears]))
		{
			return useSkill($skill[Barrage of Tears]);
		}
		// Poison Dart (from beechwood blowgun) is not used here
		// because it does not stagger the enemy like the others

		if(canUse($skill[Cadenza]) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			if($items[Accordion of Jordion, Accordionoid Rocca, non-Euclidean non-accordion, Shakespeare\'s Sister\'s Accordion, zombie accordion] contains equipped_item($slot[weapon]))
			{
				return useSkill($skill[Cadenza]);
			}
		}

		//source terminal iotm specific skill to acquire source essence from enemies
		if(canUse($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && (item_amount($item[Source Essence]) <= 60) && stunnable(enemy))
		{
			return useSkill($skill[Extract]);
		}

		if(canUse($skill[Extract Jelly]) && (my_mp() > (mp_cost($skill[Extract Jelly]) * 3)) && canSurvive(2.0) && (my_familiar() == $familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 3) && ($elements[hot, spooky, stench] contains monster_element(enemy)))
		{
			return useSkill($skill[Extract Jelly]);
		}

		if(canUse($skill[Science! Fight With Medicine]) && ((my_hp() * 2) < my_maxhp()))
		{
			return useSkill($skill[Science! Fight With Medicine]);
		}
		if(canUse($skill[Science! Fight With Rational Thought]) && (have_effect($effect[Rational Thought]) < 10))
		{
			return useSkill($skill[Science! Fight With Rational Thought]);
		}

		if(canUse($item[Time-Spinner]))
		{
			return useItem($item[Time-Spinner]);
		}
		
		if(canUse($skill[Sing Along]))
		{
			//15% devel, but no stun. 
			
			if(canSurvive(2.0) && (get_property("boomBoxSong") == "Remainin\' Alive"))
			{
				return useSkill($skill[Sing Along]);
			}
		
			//this is for increasing meat income. gain +25 meat per monster, at the cost of letting it act once. If healing is too costly this can be a net loss of meat. until a full cost calculator is made, limit to under 10 HP damage and no more than 20% of your remaining HP.
			
			if(canSurvive(5.0) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat") && (expected_damage() < 10) && (auto_my_path() != "Way of the Surprising Fist"))
			{
				return useSkill($skill[Sing Along]);
			}
		
			//if doing nuns quest or wall of meat, disregard profit and only check if you can survive using sing along.
			
			if(canSurvive(3.0) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat") && $monsters[dirty thieving brigand, wall of meat] contains enemy)
			{
				return useSkill($skill[Sing Along]);
			}
		}
	}

	#Default behaviors, multi-staggers when chance is 50% or greater
	if(enemy_la < 100 && stunnable(enemy))
	{
		if(canUse($item[Rain-Doh blue balls]))
		{
			return useItem($item[Rain-Doh blue balls]);
		}

		if(canUse($skill[Summon Love Gnats]))
		{
			return useSkill($skill[Summon Love Gnats]);
		}

		if(canUse($skill[Summon Love Stinkbug]) && haveUsed($skill[Summon Love Gnats]) && !contains_text(text, "STUN RESIST"))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
	}
	
	if(canUse($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 32 || haveUsed($skill[Stuffed Mortar Shell])) && doWeaksauce)
	{
		return useSkill($skill[Curse Of Weaksauce]);
	}
	
	//turtle tamer specific damage over time
	if(my_class() == $class[Turtle Tamer] && canUse($skill[Spirit Snap]) && my_mp() > 80)
	{
		//storm turtle blessings makes spirit snap cause 15/20/25% buffed muscle as DoT for rest of combat
		if(have_effect($effect[Blessing of the Storm Tortoise]) > 0 || have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0 || have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0)
		{
			return useSkill($skill[Spirit Snap]);
		}
	}
	
	return "";
}
