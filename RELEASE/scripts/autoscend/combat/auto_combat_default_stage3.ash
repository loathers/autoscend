string auto_combatDefaultStage3(int round, monster enemy, string text)
{
	// stage 3 = debuff: delevel, stun, curse, damage over time
	string retval;
	
	// Path = Heavy Rains
	retval = auto_combatHeavyRainsStage3(round, enemy, text);
	if(retval != "") return retval;

	// Path = zombie slayer
	retval = auto_combatZombieSlayerStage3(round, enemy, text);
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
	
	//iotm skill that duplicates dropped items
	//prioritize grey goose over xo and extinguisher because the drones last multiple fights until they are consumed 
	if(canUse($skill[Emit Matter Duplicating Drones]) && my_familiar() == $familiar[Grey Goose])
	{
		boolean forceDrop = false;
		boolean canExtingo = true;
		if(auto_fireExtinguisherCharges() <= 30 || !canUse($skill[Fire Extinguisher: Polar Vortex], false))
		{
			canExtingo = false;
		}
		boolean drones = gooseExpectedDrones() >= 1; //only want to try if we expect any number of drones.

		//dupe a sonar-in-a-biscuit if we're lucky, only want to try it if we need more than 1 biscuit
		if((item_drops(enemy) contains $item[sonar-in-a-biscuit]) && (count(item_drops(enemy)) <= 2) && (internalQuestStatus("questL04Bat") <= 1) && drones)
		{
			forceDrop = true;
		}
		
		//dupe stone wool
		if((item_drops(enemy) contains $item[stone wool]) && item_amount($item[stone wool]) < 2 && drones)
		{
			forceDrop = true;
		}

		//dupe goat cheese
		if(enemy == $monster[Dairy goat] && canExtingo = false && item_amount($item[Goat Cheese]) < 3 && drones)
		{
			forceDrop = true;
		}

		//dupe Smut Orc Keepsake
		if(enemy == $monster[Smut orc pervert] && auto_autumnatonQuestingIn() != $location[The Smut Orc Logging Camp] && my_location() == $location[The Smut Orc Logging Camp] && drones)
		{
			forceDrop = true;
		}
		
		//dupe some hedge trimmers if we're lucky
		if(canExtingo = false && ($monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal] contains enemy) && auto_autumnatonQuestingIn() != $location[Twin Peak] && hedgeTrimmersNeeded() > 1 && drones)
		{
			forceDrop = true;
		}
		
		//dupe some stars/lines
		if(my_location() == $location[The Hole in the Sky] && item_drops(enemy) contains $item[star] && item_drops(enemy) contains $item[line] && needStarKey() && (item_amount($item[star]) < 8 && item_amount($item[line]) < 7) && drones)
		{
			forceDrop = true;
		}

		//dupe some blackberries
		if(enemy == $monster[Blackberry bush] && drones)
		{
			forceDrop = true;
		}

		//dupe some glark cables
		if(enemy == $monster[Red butler] && drones)
		{
			forceDrop = true;
		}
		
		//dupe some bowling balls if we can't use an Industrial Fire Extinguisher
		if(canExtingo = false && (enemy == $monster[Pygmy bowler] && (get_property("hiddenBowlingAlleyProgress").to_int() + item_amount($item[Bowling Ball])) < 6) && drones)
		{
			forceDrop = true;
		}

		//dupe tomb ratchets if we're lucky
		if(($monsters[Tomb rat, Tomb rat king] contains enemy) && ((item_amount($item[Crumbling Wooden Wheel]) + item_amount($item[Tomb Ratchet])) < 10) && drones)
		{
			forceDrop = true;
		}

		//dupe Cursed Dragon Wishbone and Cursed Bat Paw if in AoSOL
		if(($monsters[two-headed shadow bat, shadowboner shadowdagon] contains enemy) && drones)
		{
			forceDrop = true;
		}
		
		//dupe GROPs if yellow rayed that didn't instakill. Commented out until support for green smoke bombs is added
		/*if(enemy == $monster[Green Ops Soldier] and combat_status_check("yellowray") and drones){
			forceDrop = true;
		}*/

		if(dronesOut()) //If we have drones out, let's not use the skill again
		{
			forceDrop = false;
		}

		if(forceDrop)
		{
			handleTracker(enemy, $skill[Emit Matter Duplicating Drones], "auto_otherstuff");
			return useSkill($skill[Emit Matter Duplicating Drones]);			
		}
	}
	
	//iotm skill that can be used on any combat round, repeatedly until an item is stolen
	if(canUse($skill[Hugs and Kisses!]) && (my_familiar() == $familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() < 11))
	{
		boolean forceDrop = false;
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			forceDrop = true;
		}

		// reserve enough resources to force filthworm drops
		if(get_property("_xoHugsUsed").to_int() < 8)
		{
			// snatch a wig if we're lucky
			if(enemy == $monster[Burly Sidekick] && !possessEquipment($item[Mohawk wig]))
				forceDrop = true;

			// snatch a hedge trimmer if we're lucky
			if($monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal] contains enemy)
				forceDrop = true;

			// snatch a killing jar if we're lucky
			if(enemy == $monster[banshee librarian] && (0 == item_amount($item[Killing jar])))
				forceDrop = true;

			// snatch a sonar-in-a-biscuit if we're lucky
			if((item_drops(enemy) contains $item[sonar-in-a-biscuit]) && (count(item_drops(enemy)) <= 2) && (get_property("questL04Bat")) != "finished")
				forceDrop = true;
		}				

		if(forceDrop)
		{
			handleTracker(enemy, $skill[Hugs and Kisses!], "auto_otherstuff");
			return useSkill($skill[Hugs and Kisses!]);			
		}
	}

	//iotm skill that can be used on any combat round, repeatedly until an item is stolen
	//prioritize XO over extinguisher since extinguisher has other uses
	//take into account if a yellow ray has been used. Must have been one that doesn't insta-kill
	if(canUse($skill[Fire Extinguisher: Polar Vortex], false) && auto_fireExtinguisherCharges() > 10)
	{
		boolean forceDrop = false;
		//only force 1 scent gland from each filthworm
		if(!combat_status_check("yellowray"))
		{
			if(enemy == $monster[Larval Filthworm] && item_amount($item[filthworm hatchling scent gland]) < 1)
			{
				forceDrop = true;
			}
			if(enemy == $monster[Filthworm Drone] && item_amount($item[filthworm drone scent gland]) < 1)
			{
				forceDrop = true;
			}
			if(enemy == $monster[Filthworm Royal Guard] && item_amount($item[filthworm royal guard scent gland]) < 1)
			{
				forceDrop = true;
			}
		}
		

		// polar vortex is more likely to pocket an item the higher the drop rate. Unlike XO which has equal chance for all drops
		// reserve 30 charge for filth worms
		if(auto_fireExtinguisherCharges() > 30)
		{
			int dropsFromYR = 0;
			if(combat_status_check("yellowray"))
			{
				dropsFromYR = 1;
			}

			if($monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal] contains enemy)
			{
				if(hedgeTrimmersNeeded() + dropsFromYR > 0)
				{
					forceDrop = true;
				}
			}

			// Number of times bowled is 1 less than hiddenBowlingAlleyProgress. Need 5 bowling balls total, 5+1 = 6 needed in this conditional
			if(enemy == $monster[Pygmy bowler] && (get_property("hiddenBowlingAlleyProgress").to_int() + item_amount($item[Bowling Ball]) + dropsFromYR) < 6)
			{
				forceDrop = true;
			}

			if(enemy == $monster[Dairy Goat] && (item_amount($item[Goat Cheese]) + dropsFromYR) < 3)
			{
				forceDrop = true;
			}	
		}
				

		if(forceDrop)
		{
			handleTracker(enemy, $skill[Fire Extinguisher: Polar Vortex], "auto_otherstuff");
			return useSkill($skill[Fire Extinguisher: Polar Vortex]);	
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
			//Saucerors use Weaksauce to get MP, but no more MP will be coming if there isn't enough MP left to cast a spell, mortar can not have been launched yet at this point
			//if mp >= 60 Weaksauce has probably been cast above already
			int MPafterWeaksauce = my_mp() - mp_cost($skill[Curse Of Weaksauce]);
			boolean canCastAfterWeaksauce;
			foreach sp in $skills[Saucestorm,Stuffed Mortar Shell,Saucegeyser]
			{
				if(canUse(sp,false) && MPafterWeaksauce >= mp_cost(sp))
				{
					canCastAfterWeaksauce = true;
					break;
				}
			}
			if(!canCastAfterWeaksauce)
			{	if(canUse($skill[Wave of Sauce], false) && (monster_element(enemy) != $element[hot]) && MPafterWeaksauce >= mp_cost($skill[Wave of Sauce]))
				{
					canCastAfterWeaksauce = true;
				}
				else if(canUse($skill[Saucecicle], false) && (monster_element(enemy) != $element[cold]) && MPafterWeaksauce >= mp_cost($skill[Saucecicle]))
				{
					canCastAfterWeaksauce = true;
				}
			}
			if(canCastAfterWeaksauce)
			{
				return useSkill($skill[Curse Of Weaksauce]);
			}
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

		if(my_location() == $location[The Smut Orc Logging Camp] && canSurvive(1.0) && get_property("chasmBridgeProgress").to_int() < 30)
		{
			boolean coldMortarShell = canUse($skill[Stuffed Mortar Shell]) && have_effect($effect[Spirit of Peppermint]) != 0;
			skill coldSkillToUse;
			int coldAttackDamageMultiplier = 1;
			if(my_class() == $class[Seal Clubber])
			{
				if(canUse($skill[Lunging Thrust-Smack], false))
				{
					coldAttackDamageMultiplier = 3;	//triple elemental bonus
				}
				else if(canUse($skill[Thrust-Smack], false))
				{
					coldAttackDamageMultiplier = 2;	//double elemental bonus
				}
			}
			int coldAttackDamage = numeric_modifier("cold damage")*coldAttackDamageMultiplier;	//todo add ML damage multiplier
			
			// Listed from Most to Least Damaging to hopefully cause Death on the turn when the Shell hits.
			if(canUse($skill[Saucegeyser], false) && numeric_modifier("Cold Spell Damage") > numeric_modifier("Hot Spell Damage"))
			{
				//100% chance of cold Saucegeyser
				coldSkillToUse = $skill[Saucegeyser];
			}
			else if(canUse($skill[Saucecicle], false))
			{
				coldSkillToUse = $skill[Saucecicle];
			}
			else if(canUse($skill[Cannelloni Cannon], false) && have_effect($effect[Spirit of Peppermint]) != 0)
			{
				coldSkillToUse = $skill[Cannelloni Cannon];
			}
			else if(canUse($skill[Northern Explosion], false))
			{
				coldSkillToUse = $skill[Northern Explosion];
			}
			else if(monster_level_adjustment() < -65 && canUse($skill[Saucestorm], false))
			{
				//in extreme case where orcs are reduced to few HP by -ML Saucestorm is better than 50% chance of cold Saucegeyser
				//todo compare actual damage predictions instead
				coldSkillToUse = $skill[Saucestorm];
			}
			else if(coldAttackDamage > 3*max(1,(69 + monster_level_adjustment())))
			{
				//cold bonus weapon attack can also be better than 50% chance of cold Saucegeyser
				//todo compare actual damage predictions instead
				if(my_class() == $class[Seal Clubber])
				{
					if(canUse($skill[Lunging Thrust-Smack], false))
					{
						coldSkillToUse = $skill[Lunging Thrust-Smack];	//triple elemental bonus
					}
					else if(canUse($skill[Thrust-Smack], false))
					{
						coldSkillToUse = $skill[Thrust-Smack];	//double elemental bonus
					}
					else if(canUse($skill[Lunge Smack], false))
					{
						coldSkillToUse = $skill[Lunge Smack];
					}
				}
				//other classes default to regular attack later
			}
			else if(canUse($skill[Saucegeyser], false) && numeric_modifier("Cold Spell Damage") == numeric_modifier("Hot Spell Damage"))
			{
				//equal is 50% chance of cold Saucegeyser. "cold > hot" is used higher in priority. "cold < hot" is 100% hot Saucegeyser and not worth using
				coldSkillToUse = $skill[Saucegeyser];
			}
			else if(in_nuclear() && canUse($skill[Throat Refrigerant], false)){
				coldSkillToUse = $skill[Throat Refrigerant];
			}
			
			int MPreservedForColdSpells = coldMortarShell ? mp_cost($skill[Stuffed Mortar Shell]) : 0;
			if(coldSkillToUse != $skill[none])	MPreservedForColdSpells += mp_cost(coldSkillToUse);
			
			// Mating Call has unlimited uses and a small effect so unlike other sniff skills there is no reason not to use it here to balance bridge parts except MP cost
			if(canUse($skill[Gallapagosian Mating Call], false) && my_mp() >= (MPreservedForColdSpells + mp_cost($skill[Gallapagosian Mating Call])))
			{
				boolean useMiniSniff = false;
				boolean sniffedLumber = (isSniffed($monster[Smut Orc Pipelayer]) || isSniffed($monster[Smut Orc Jacker]));
				boolean sniffedFastener = (isSniffed($monster[Smut Orc Screwer]) || isSniffed($monster[Smut Orc Nailer]));
				boolean haveLumberBias = (equipped_amount($item[Logging Hatchet]) > 0 && equipped_amount($item[Loadstone]) == 0);
				boolean haveFastenerBias = (equipped_amount($item[Loadstone]) > 0 && equipped_amount($item[Logging Hatchet]) == 0);
				
				if(enemy == $monster[Smut Orc Pipelayer] || enemy == $monster[Smut Orc Jacker])
				{
					if(!sniffedLumber)
					{
						if(fastenerCount() >= 30 && lumberCount() < 29)
						{	useMiniSniff = true;
						}
						else if(haveFastenerBias && fastenerCount() >= lumberCount())
						{	useMiniSniff = true;	//will get more fastener from Loadstone
						}
						else if(fastenerCount() > (lumberCount() + 2))
						{	useMiniSniff = true;	//have more fastener, try to make up for it
						}
						else if(sniffedFastener && !haveLumberBias && fastenerCount() > lumberCount())
						{	useMiniSniff = true;	//may have sniffed fastener too hard
						}
					}
				}
				else if(enemy == $monster[Smut Orc Screwer] || enemy == $monster[Smut Orc Nailer])
				{
					if(!sniffedFastener)
					{
						if(lumberCount() >= 30 && fastenerCount() < 29)
						{	useMiniSniff = true;
						}
						else if(haveLumberBias && lumberCount() >= fastenerCount())
						{	useMiniSniff = true;	//will get more lumber from Logging Hatchet
						}
						else if(lumberCount() > (fastenerCount() + 2))
						{	useMiniSniff = true;	//have more lumber, try to make up for it
						}
						else if(sniffedLumber && !haveFastenerBias && lumberCount() > fastenerCount())
						{	useMiniSniff = true;	//may have sniffed lumber too hard
						}
					}
				}
				if(useMiniSniff)
				{
					handleTracker(enemy, $skill[Gallapagosian Mating Call], "auto_sniffs");
					return useSkill($skill[Gallapagosian Mating Call], false);
				}
			}
			
			if(coldMortarShell)
			{
				return useSkill($skill[Stuffed Mortar Shell]);
			}
			else if(coldSkillToUse != $skill[none])
			{
				return useSkill(coldSkillToUse, false);
			}
			else if(!in_robot() && $classes[Seal Clubber, Turtle Tamer, Pastamancer, Sauceror, Disco Bandit, Accordion Thief] contains my_class())
			{
				if(coldAttackDamage > (69 + monster_level_adjustment()) && coldAttackDamage > 0)
				{
					//if cold damage bonus > their health make sure an attack that uses elemental bonus gets to be used
					if(my_class() == $class[Seal Clubber])
					{
						if(canUse($skill[Lunging Thrust-Smack], false))
						{
							return useSkill($skill[Lunging Thrust-Smack], false);	//triple elemental bonus
						}
						else if(canUse($skill[Thrust-Smack], false))
						{
							return useSkill($skill[Thrust-Smack], false);	//double elemental bonus
						}
						else if(canUse($skill[Lunge Smack], false))
						{
							return useSkill($skill[Lunge Smack], false);
						}
						else
						{
							return "attack with weapon";
						}
					}
					else
					{
						return "attack with weapon";
					}
				}
				else if(monster_level_adjustment() <= -25 && canUse($skill[Saucestorm], false))		//todo check predicted damage instead of arbitrary values
				{
					auto_log_warning("None of the best [cold] skills available against smut orcs but trying weaker alternative in view of the negative monster level.", "red");
					return useSkill($skill[Saucestorm], false);
				}
				else
				{
					auto_log_warning("None of our preferred [cold] skills available against smut orcs. Engaging in Fisticuffs.", "red");
				}
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
		if(canUse($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && (item_amount($item[Source Essence]) <= 60) && canSurvive(2.0))
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
			
			if(canSurvive(5.0) && (get_property("boomBoxSong") == "Total Eclipse of Your Meat") && (expected_damage() < 10) && !in_wotsf())
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

		if(!(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy)))
		{
			if(canUse($skill[Summon Love Stinkbug]) && haveUsed($skill[Summon Love Gnats]) && !contains_text(text, "STUN RESIST"))
			{
				return useSkill($skill[Summon Love Stinkbug]);
			}
		}
	}
	
	//weaksauce has probably already been cast in one of several checks above, except when above 150 ML, or without itchy curse finger or mp < 60
	if(canUse($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 32 || haveUsed($skill[Stuffed Mortar Shell])) && doWeaksauce)
	{
		return useSkill($skill[Curse Of Weaksauce]);
	}
	
	//turtle tamer specific damage over time
	if(my_class() == $class[Turtle Tamer] && canUse($skill[Spirit Snap]) && my_mp() > 80)
	{
		//storm turtle blessings makes spirit snap cause 15/20/25% buffed muscle as DoT for rest of combat
		//must not block stage4 so should not use if it will kill the monster
		if((have_effect($effect[Blessing of the Storm Tortoise]) > 0 && monster_hp() > 0.15*my_buffedstat($stat[muscle]))|| 
		(have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0 && monster_hp() > 0.20*my_buffedstat($stat[muscle])) || 
		(have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0 && monster_hp() > 0.25*my_buffedstat($stat[muscle])))
		{
			return useSkill($skill[Spirit Snap]);
		}
	}

	// Multi-round stuns
	if(canUse($skill[Thunderstrike]) && enemy_la <= 150 && !canSurvive(5.0))
	{
		combat_status_add("stunned");
		return useSkill($skill[Thunderstrike]);
	}

	if(enemy_la <= 100 && stunnable(enemy) && (!canSurvive(5.0) || $monsters[Groar] contains enemy))
	{
		skill stunner = getStunner(enemy);
		if(stunner != $skill[none])
		{
			combat_status_add("stunned");
			return useSkill(stunner);
		}
	}
	
	return "";
}
