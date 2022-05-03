string auto_combatDefaultStage5(int round, monster enemy, string text)
{
	// stage 5 = kill
	string retval;
	
	// Path = Heavy Rains
	retval = auto_combatHeavyRainsStage5(round, enemy, text);
	if(retval != "") return retval;
	
	// Path = path of the plumber
	retval = auto_combatPlumberStage5(round, enemy, text);
	if(retval != "") return retval;
	
	// Path = disguises delimit
	retval = auto_combatDisguisesStage5(round, enemy, text);
	if(retval != "") return retval;
	
	// Path = gelatinous noob
	retval = auto_combatGelatinousNoobStage5(round, enemy, text);
	if(retval != "") return retval;
	
	// Path = you, robot
	retval = auto_combat_robot_stage5(round, enemy, text);
	if(retval != "") return retval;

	// Path = zombie slayer
	retval = auto_combatZombieSlayerStage5(round, enemy, text);
	if(retval != "") return retval;

	phylum type = monster_phylum(enemy);
	string attackMinor = "attack with weapon";
	string attackMajor = "attack with weapon";
	int costMinor = 0;
	int costMajor = 0;
	int damageReceived = 0;
	if(round != 0)
	{
		damageReceived = get_property("auto_combatHP").to_int() - my_hp();
	}
	
	if((enemy == $monster[LOV Enforcer]) && canUse($skill[Saucestorm], false))
	{
		return useSkill($skill[Saucestorm], false);
	}
	
	//nemesis quest specific kill methods
	if(my_class() == $class[Seal Clubber])
	{
		if(enemy == $monster[Hellseal Pup])
		{
			return useSkill($skill[Clobber], false);
		}
		if(enemy == $monster[Mother Hellseal])
		{
			if(canUse($item[Rain-Doh Indigo Cup]))
			{
				return useItem($item[Rain-Doh Indigo Cup]);
			}
			return useSkill($skill[Lunging Thrust-Smack], false);
		}
	}
	
	//nemesis quest tame guard turtle. takes multiple rounds and buffs enemy by 40%. so it should go after stun and delevel
	if((enemy == $monster[French Guard Turtle]) && have_equipped($item[Fouet de tortue-dressage]) && (my_mp() >= mp_cost($skill[Apprivoisez La Tortue])))
	{
		return useSkill($skill[Apprivoisez La Tortue], false);
	}
	
	//iotm back item and the enemies it spawns (free fights) can be killed using special skills to get extra XP and item drops
	if(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy) && !combat_status_check("skipGhostbusting"))
	{
		//shoot ghost 3 times provoking retaliation, then trap ghost skill unlocks which instawins combat.
		skill stunner = getStunner(enemy);
		if(stunner != $skill[none])
		{
			combat_status_add("stunned");
			return useSkill(stunner);
		}

		//shots_takens tracks how many times we used [shoot ghost] skill this combat. it is reset in combat initialize
		int shots_takens = usedCount($skill[Shoot Ghost]);
		if(canUse($skill[Shoot Ghost], false) && shots_takens < 3)
		{
			float survive_needed = 3.05 - shots_takens.to_float();
			if(canSurvive(survive_needed))
			{
				markAsUsed($skill[Shoot Ghost]);		//needs to be manually done for skills with a use limit that is not 1
				return useSkill($skill[Shoot Ghost], false);
			}
			else
			{
				combat_status_add("skipGhostbusting");
			}
		}
		
		if(canUse($skill[Trap Ghost]) && shots_takens == 3)
		{
			auto_log_info("Busting makes me feel good!!", "green");
			return useSkill($skill[Trap Ghost]);
		}
	}
	
	//turtle tamer specific skill
	if(my_class() == $class[Turtle Tamer] && canUse($skill[Spirit Snap]) && my_mp() > 80)
	{
		if(have_effect($effect[Glorious Blessing of the War Snapper]) > 0)
		{
			return useSkill($skill[Spirit Snap]);		//50% buffed muscle physical damage once
		}
		if(have_effect($effect[Glorious Blessing of She-Who-Was]) > 0 && monster_element(enemy) != $element[spooky])
		{
			return useSkill($skill[Spirit Snap]);		//35% buffed muscle spooky damage once
		}
	}
	
	//8-16 + 0.25*mys damage. hardcap 50. costs 8MP. does NOT benefit from bringing up the rear ability to double damage cap
	//each time used has a 33% chance of dropping a candy. one candy per battle max. TODO track this
	//Cannelloni Cannon is better as it has 16-32 + 0.25*mys damage, is tuneable, and its cap can be boosted with bringing up the rear.
	//TODO write up a function to determine if we want to use this for the free candy. consider sauceror regeneration and candy mixing
	if(canUse($skill[Candyblast]) && my_mp() > 60 && inAftercore())
	{
		# We can get only one candy and we can detect it, if so desired:
		# "Hey, some of it is even intact afterwards!"
		return useSkill($skill[Candyblast]);
	}
	
	if((my_class() != $class[Sauceror]) && canUse(auto_spoonCombatSkill()))
	{
		return useSkill(auto_spoonCombatSkill());
	}
    
	//mortar shell is amazing. it really should not be limited to sauceror only.
	if(canUse($skill[Stuffed Mortar Shell]) && (my_class() == $class[Sauceror]) && canSurvive(2.0) && (currentFlavour() != monster_element(enemy) || currentFlavour() == $element[none]))
	{
		set_property("_auto_combatTracker_MortarRound", round);
		return useSkill($skill[Stuffed Mortar Shell]);
	}

	//general killing code
	switch(my_class())
	{
	case $class[Seal Clubber]:
		attackMinor = "attack with weapon";
		if(canUse($skill[Lunge Smack], false) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMinor = useSkill($skill[Lunge Smack], false);
			costMinor = mp_cost($skill[Lunge Smack]);
		}
		if(canUse($skill[Lunging Thrust-Smack], false) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMajor = useSkill($skill[Lunging Thrust-Smack], false);
			costMajor = mp_cost($skill[Lunging Thrust-Smack]);
		}

		if((buffed_hit_stat() - 20) < monster_defense() && canUse($skill[Saucestorm], false) && !hasClubEquipped())
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		if(enemy.physical_resistance > 80)
		{
			boolean success = false;
			foreach sk in $skills[Saucestorm, Saucegeyser, Northern Explosion]
			{
				if(canUse(sk, false))
				{
					attackMinor = useSkill(sk, false);
					attackMajor = useSkill(sk, false);
					costMinor = mp_cost(sk);
					costMajor = mp_cost(sk);
					success = true;
					break;
				}
			}
			if(!success)
			{
				abort("I am fighting a physically immune monster and I do not know how to kill it");
			}
		}

		break;
	case $class[Turtle Tamer]:
		attackMinor = "attack with weapon";
		if(my_mp() > 150 && canUse($skill[Shieldbutt], false))
		{
			attackMinor = useSkill($skill[Shieldbutt], false);
			costMinor = mp_cost($skill[Shieldbutt]);
		}
		else if((my_mp() > 80) && ((my_hp() * 2) < my_maxhp()) && canUse($skill[Kneebutt], false))
		{
			attackMinor = useSkill($skill[Kneebutt], false);
			costMinor = mp_cost($skill[Kneebutt]);
		}
		if(((round > 15) || ((my_hp() * 2) < my_maxhp())) && canUse($skill[Kneebutt], false))
		{
			attackMajor = useSkill($skill[Kneebutt], false);
			costMajor = mp_cost($skill[Kneebutt]);
		}
		if(canUse($skill[Shieldbutt], false))
		{
			attackMajor = useSkill($skill[Shieldbutt], false);
			costMajor = mp_cost($skill[Shieldbutt]);
		}

		if((buffed_hit_stat() - 20) < monster_defense() && canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;
	case $class[Pastamancer]:
		if(canUse($skill[Cannelloni Cannon], false))
		{
			attackMinor = useSkill($skill[Cannelloni Cannon], false);
			costMinor = mp_cost($skill[Cannelloni Cannon]);
		}
		if(canUse($skill[Weapon of the Pastalord], false))
		{
			attackMajor = useSkill($skill[Weapon of the Pastalord]);
			costMajor = mp_cost($skill[Weapon of the Pastalord]);
		}
		if(canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			attackMinor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		if(canUse($skill[Utensil Twist], false) && (item_type(equipped_item($slot[weapon])) == "utensil"))
		{
			if(equipped_item($slot[weapon]) == $item[Hand That Rocks the Ladle])
			{
				attackMajor = useSkill($skill[Utensil Twist], false);
				attackMinor = useSkill($skill[Utensil Twist], false);
				costMinor = mp_cost($skill[Utensil Twist]);
				costMajor = mp_cost($skill[Utensil Twist]);
			}
			else if((enemy.physical_resistance <= 80) && (attackMinor != useSkill($skill[Saucestorm], false)))
			{
				attackMinor = useSkill($skill[Utensil Twist], false);
				costMinor = mp_cost($skill[Utensil Twist]);
			}
		}
		break;
	case $class[Sauceror]:
		if(canUse($skill[Saucegeyser], false))
		{
			attackMinor = useSkill($skill[Saucegeyser], false);
			attackMajor = useSkill($skill[Saucegeyser], false);
			costMinor = mp_cost($skill[Saucegeyser]);
			costMajor = mp_cost($skill[Saucegeyser]);
		}
		else if(canUse($skill[Saucecicle], false) && (monster_element(enemy) != $element[cold]))
		{
			attackMinor = useSkill($skill[Saucecicle], false);
			attackMajor = useSkill($skill[Saucecicle], false);
			costMinor = mp_cost($skill[Saucecicle]);
			costMajor = mp_cost($skill[Saucecicle]);
		}
		else if(canUse($skill[Saucestorm], false))
		{
			attackMinor = useSkill($skill[Saucestorm], false);
			attackMajor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		else if(canUse($skill[Wave of Sauce], false) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = useSkill($skill[Wave of Sauce], false);
			attackMajor = useSkill($skill[Wave of Sauce], false);
			costMinor = mp_cost($skill[Wave of Sauce]);
			costMajor = mp_cost($skill[Wave of Sauce]);
		}
		else if(canUse($skill[Stream of Sauce], false) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = useSkill($skill[Stream of Sauce], false);
			attackMajor = useSkill($skill[Stream of Sauce], false);
			costMinor = mp_cost($skill[Stream of Sauce]);
			costMajor = mp_cost($skill[Stream of Sauce]);
		}
		
		//let mortar deal the killing blow so we get more MP from the exploding curse of weaksauce
		int mortar_round = get_property("_auto_combatTracker_MortarRound").to_int();
		if(mortar_round > -1 &&		//mortar was used this combat
		mortar_round == round-1 &&	//mortar will hit this round
		//TODO make sure mortar will actually kill it
		canSurvive(2.0))			//monster is not too scary.
		{
			if(monster_hp() > 1 &&		//avoid killing blow with seal tooth or else 0 MP will be given
			canUse($item[Seal Tooth], false))
			{
				return useItem($item[Seal Tooth], false);
			}
			if(monster_hp() > 15 &&		//avoid killing blow with salsaball or else ~2MP will be given
			canUse($skill[Salsaball], false))
			{
				return useSkill($skill[Salsaball], false);
			}
		}
		
		break;

	case $class[Avatar of Boris]:
		// If we're fighting a ghost, of course we want to use elemental damage!
		if(canUse($skill[Heroic Belch], false) && (enemy.physical_resistance >= 80) && $element[stench] != monster_element(enemy))
		{
			attackMinor = useSkill($skill[Heroic Belch]);
			attackMajor = useSkill($skill[Heroic Belch]);
			costMinor = mp_cost($skill[Heroic Belch]);
			costMajor = mp_cost($skill[Heroic Belch]);
		}

		// Mighty axing is better than attacking as it will never fumble and has no mp cost
		if(canUse($skill[Mighty Axing], false))
		{
			attackMinor = useSkill($skill[Mighty Axing], false);
			attackMajor = useSkill($skill[Mighty Axing], false);
			costMinor = mp_cost($skill[Mighty Axing]);
			costMajor = mp_cost($skill[Mighty Axing]);
		}

		if(canUse($skill[Cleave], false))
		{
			attackMajor = useSkill($skill[Cleave], false);
			costMajor = mp_cost($skill[Cleave]);
		}

		// Avoid apathy and cunctatitis by using a ranged attack
		if (equipped_item($slot[Weapon]) == $item[Trusty] && canUse($skill[Throw Trusty], false) && $monsters[Apathetic Lizardman, Procrastination Giant] contains enemy)
		{
			attackMinor = useSkill($skill[Throw Trusty], false);
			attackMajor = useSkill($skill[Throw Trusty], false);
			costMinor = mp_cost($skill[Throw Trusty]);
			costMajor = mp_cost($skill[Throw Trusty]);
		}

		if(canUse($skill[Heroic Belch], false) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && (my_fullness() >= 5))
		{
			attackMinor = useSkill($skill[Heroic Belch], false);
			attackMajor = useSkill($skill[Heroic Belch], false);
			costMinor = mp_cost($skill[Heroic Belch]);
			costMajor = mp_cost($skill[Heroic Belch]);
		}
		break;
	
	case $class[Avatar of Jarlsberg]:
		//AoJ spells have a hard DMG cap of 10*(MP Cost) before percentage modifiers are applied. 
		//Things that change the MP costs will change said dmg cap.
		//AoJ can **only** attack via spells / items / jiggling
		attackMinor = useSkill($skill[Curdle], false);
		attackMajor = useSkill($skill[Curdle], false);
		costMinor = mp_cost($skill[Curdle]);
		costMajor = mp_cost($skill[Curdle]);

		// Default to curdle if the monster is physically resistant
		if (enemy.physical_resistance < 50)
		{
			if (canUse($skill[Chop], false))
			{
				attackMinor = useSkill($skill[Chop], false);
				attackMajor = useSkill($skill[Chop], false);
				costMinor = mp_cost($skill[Chop]);
				costMajor = mp_cost($skill[Chop]);
			}

			if (canUse($skill[Slice], false))
			{
				attackMajor = useSkill($skill[Slice], false);
				costMajor = mp_cost($skill[Slice]);
			}
		}

		// Prefer double damage
		if ($elements[cold, spooky] contains monster_element(enemy) && canUse($skill[Bake]))
		{
			attackMinor = useSkill($skill[Bake]);
			attackMajor = useSkill($skill[Bake]);
			costMinor = mp_cost($skill[Bake]);
			costMajor = mp_cost($skill[Bake]);
		}
		else if ($elements[cold, spooky] contains monster_element(enemy) && canUse($skill[Boil], false))
		{
			attackMinor = useSkill($skill[Boil], false);
			attackMajor = useSkill($skill[Boil], false);
			costMinor = mp_cost($skill[Boil]);
			costMajor = mp_cost($skill[Boil]);
		}
		else if ($elements[stench, sleaze] contains monster_element(enemy) && canUse($skill[Freeze], false))
		{
			attackMinor = useSkill($skill[Freeze], false);
			attackMajor = useSkill($skill[Freeze], false);
			costMinor = mp_cost($skill[Freeze]);
			costMajor = mp_cost($skill[Freeze]);
		}
		else if (enemy.physical_resistance >= 50)
		{
			// If physically resistant, fallback to an elemental spell that will do normal damage
			if (monster_element(enemy) != $element[hot] && canUse($skill[Bake]))
			{
				attackMinor = useSkill($skill[Bake]);
				attackMajor = useSkill($skill[Bake]);
				costMinor = mp_cost($skill[Bake]);
				costMajor = mp_cost($skill[Bake]);
			}
			else if (monster_element(enemy) != $element[hot] && canUse($skill[Boil], false))
			{
				attackMinor = useSkill($skill[Boil], false);
				attackMajor = useSkill($skill[Boil], false);
				costMinor = mp_cost($skill[Boil]);
				costMajor = mp_cost($skill[Boil]);
			}
			else if (monster_element(enemy) != $element[cold] && canUse($skill[Freeze], false))
			{
				attackMinor = useSkill($skill[Freeze], false);
				attackMajor = useSkill($skill[Freeze], false);
				costMinor = mp_cost($skill[Freeze]);
				costMajor = mp_cost($skill[Freeze]);
			}
		}

		// Prefer double damage
		if ($elements[hot, stench] contains monster_element(enemy) && canUse($skill[Fry], false))
		{
			attackMajor = useSkill($skill[Fry], false);
			costMajor = mp_cost($skill[Fry]);
		}
		else if (monster_element(enemy) != $element[none] && canUse($skill[Grill], false))
		{
			attackMajor = useSkill($skill[Grill], false);
			costMajor = mp_cost($skill[Grill]);
		}
		else if (enemy.physical_resistance >= 50)
		{
			// If physically resistant, fallback to an elemental spell that will do normal damage
			if (monster_element(enemy) != $element[sleaze] && canUse($skill[Fry], false))
			{
				attackMajor = useSkill($skill[Fry], false);
				costMajor = mp_cost($skill[Fry]);
			}
			else if (canUse($skill[Grill], false))
			{
				attackMajor = useSkill($skill[Grill], false);
				costMajor = mp_cost($skill[Grill]);
			}
		}

		break;

	case $class[Avatar of Sneaky Pete]:
		if(canUse($skill[Pop Wheelie], false))
		{
			attackMajor = useSkill($skill[Pop Wheelie], false);
			costMajor = mp_cost($skill[Pop Wheelie]);
		}

		if(canUse($skill[Smoke Break]) && (enemy.physical_resistance >= 80))
		{
			attackMinor = useSkill($skill[Smoke Break]);
			attackMajor = useSkill($skill[Smoke Break]);
			costMinor = mp_cost($skill[Smoke Break]);
			costMajor = mp_cost($skill[Smoke Break]);
		}
		else if(canUse($skill[Flash Headlight]) && (enemy.physical_resistance >= 80) && (get_property("peteMotorbikeHeadlight") == "Party Bulb" || (get_property("peteMotorbikeHeadlight") == "Blacklight Bulb" && monster_element(enemy) != $element[sleaze])))
		{
			attackMinor = useSkill($skill[Flash Headlight]);
			attackMajor = useSkill($skill[Flash Headlight]);
			costMinor = mp_cost($skill[Flash Headlight]);
			costMajor = mp_cost($skill[Flash Headlight]);
		}
		else if(canUse($item[Firebomb], false) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = useItem($item[Firebomb], false);
			attackMajor = useItem($item[Firebomb], false);
			costMinor = 0;
			costMajor = 0;
		}
		break;

	case $class[Accordion Thief]:

		if(canUse($skill[Cadenza]) && (item_type(equipped_item($slot[weapon])) == "accordion") && canSurvive(2.0))
		{
			if($items[accordion file, alarm accordion, autocalliope, bal-musette accordion, baritone accordion, cajun accordion, ghost accordion, peace accordion, pentatonic accordion, pygmy concertinette, skipper\'s accordion, squeezebox of the ages, the trickster\'s trikitixa] contains equipped_item($slot[weapon]))
			{
				return useSkill($skill[Cadenza]);
			}
		}

		if((buffed_hit_stat() - 20) < monster_defense() && canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		if(enemy.physical_resistance > 80 && canUse($skill[Saucestorm], false))
		{
			attackMinor = useSkill($skill[Saucestorm], false);
			attackMajor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;

	case $class[Disco Bandit]:

		if(auto_have_skill($skill[Disco State of Mind]) && auto_have_skill($skill[Flashy Dancer]) && auto_have_skill($skill[Disco Greed]) && auto_have_skill($skill[Disco Bravado]) && stunnable(enemy) && monster_level_adjustment() < 150)
		{
			float mpRegen = (numeric_modifier("MP Regen Min") + numeric_modifier("MP Regen Max")) / 2;
			int netCost = 0;

			foreach dance in $skills[Disco Dance of Doom, Disco Dance II: Electric Boogaloo, Disco Dance 3: Back in the Habit]
			{
				netCost += mp_cost(dance);
				if(canUse(dance) && mpRegen > netCost * 2)
				{
					return useSkill(dance);
				}
			}
		}

		if((buffed_hit_stat() - 20) < monster_defense() && canUse($skill[Saucestorm], false))
		{
			attackMajor = useSkill($skill[Saucestorm], false);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		if(enemy.physical_resistance > 80 && canUse($skill[Saucestorm], false))
		{
			attackMinor = useSkill($skill[Saucestorm], false);
			attackMajor = useSkill($skill[Saucestorm], false);
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;

	case $class[Cow Puncher]:
	case $class[Beanslinger]:
	case $class[Snake Oiler]:
		if(canUse($skill[Extract Oil]) && (my_hp() > 80) && (my_mp() >= (3 * mp_cost($skill[Extract Oil]))))
		{
			if($monsters[Aggressive grass snake, Bacon snake, Batsnake, Black adder, Burning Snake of Fire, Coal snake, Diamondback rattler, Frontwinder, Frozen Solid Snake, King snake, Licorice snake, Mutant rattlesnake, Prince snake, Sewer snake with a sewer snake in it, Snakeleton, The Snake with Like Ten Heads, Tomb asp, Trouser Snake, Whitesnake] contains enemy && (item_amount($item[Snake Oil]) < 4))
			{
				return useSkill($skill[Extract Oil]);
			}
			else if(($phylums[beast, dude, hippy, humanoid, orc, pirate] contains type) && (item_amount($item[Skin Oil]) < 3))
			{
				return useSkill($skill[Extract Oil]);
			}
			else if(($phylums[bug, construct, constellation, demon, elemental, elf, fish, goblin, hobo, horror, mer-kin, penguin, plant, slime, weird] contains type) && (item_amount($item[Unusual Oil]) < 4))
			{
				return useSkill($skill[Extract Oil]);
			}
			else if(($phylums[undead] contains type) && (item_amount($item[Eldritch Oil]) < 5))
			{
				return useSkill($skill[Extract Oil]);
			}
		}
		if(canUse($skill[Good Medicine]) && (my_mp() >= (3 * mp_cost($skill[Good Medicine]))))
		{
			return useSkill($skill[Good Medicine]);
		}

		if(canUse($skill[Lavafava], false) && (enemy.defense_element != $element[hot]))
		{
			attackMajor = useSkill($skill[Lavafava], false);
			attackMinor = useSkill($skill[Lavafava], false);
			costMajor = mp_cost($skill[Lavafava]);
			costMinor = mp_cost($skill[Lavafava]);
		}
		if(canUse($skill[Beanstorm], false))
		{
			attackMajor = useSkill($skill[Beanstorm], false);
			attackMinor = useSkill($skill[Beanstorm], false);
			costMajor = mp_cost($skill[Beanstorm]);
			costMinor = mp_cost($skill[Beanstorm]);
		}

		if(canUse($skill[Fan Hammer], false))
		{
			attackMajor = useSkill($skill[Fan Hammer], false);
			attackMinor = useSkill($skill[Fan Hammer], false);
			costMajor = mp_cost($skill[Fan Hammer]);
			costMinor = mp_cost($skill[Fan Hammer]);
		}
		if(canUse($skill[Snakewhip], false) && (enemy.physical_resistance < 80))
		{
			attackMajor = useSkill($skill[Snakewhip], false);
			attackMinor = useSkill($skill[Snakewhip], false);
			costMajor = mp_cost($skill[Snakewhip]);
			costMinor = mp_cost($skill[Snakewhip]);
		}

		if(canUse($skill[Pungent Mung], false) && (enemy.defense_element != $element[stench]))
		{
			attackMajor = useSkill($skill[Pungent Mung], false);
			attackMinor = useSkill($skill[Pungent Mung], false);
			costMajor = mp_cost($skill[Pungent Mung]);
			costMinor = mp_cost($skill[Pungent Mung]);
		}

		if(canUse($skill[Cowcall], false) && (type != $phylum[undead]) && (enemy.defense_element != $element[spooky]) && (have_effect($effect[Cowrruption]) >= 60 || my_class() == $class[Cow Puncher]))
		{
			attackMajor = useSkill($skill[Cowcall], false);
			attackMinor = useSkill($skill[Cowcall], false);
			costMajor = mp_cost($skill[Cowcall]);
			costMinor = mp_cost($skill[Cowcall]);
		}
		break;

	case $class[Vampyre]:
		foreach sk in $skills[Chill of the Tomb, Blood Spike, Piercing Gaze, Savage Bite]
		{
			if(sk == $skill[Chill of the Tomb] && enemy.monster_element() == $element[cold])
				continue;
			if(canUse(sk, false) && my_hp() > hp_cost(sk))
			{
				attackMajor = useSkill(sk, false);
				if(my_hp() > 3 * hp_cost(sk))
				{
					attackMinor = useSkill(sk, false);
				}
				break;
			}
		}
		// Hack for Logging Camp: deprioritize Dark Feast, use Chill of the Tomb aggressively
		if(my_hp() > 0.5 * my_maxhp() && attackMajor == useSkill($skill[Chill of the Tomb], false) && my_location() == $location[The Smut Orc Logging Camp])
		{
			break;
		}
		if(my_hp() < my_maxhp() && (monster_hp() <= 30 || (monster_hp() <= 100 && auto_have_skill($skill[Hypnotic Eyes]))) && canUse($skill[Dark Feast]))
		{
			return useSkill($skill[Dark Feast]);
		}
		// intentionally not setting costMinor or costMajor since they don't cost mp...

		// If we're in a form or something, a beehive is probably better than just attacking
		if(attackMinor == "attack with weapon" && !have_skill($skill[Preternatural Strength]) && canUse($item[beehive]) && ($stat[moxie] != weapon_type(equipped_item($slot[Weapon]))))
		{
			attackMinor = useItem($item[beehive], false);
		}
		break;
	}

	if(((my_hp() * 10)/3) < my_maxhp())
	{
		if(canUse($skill[Thunderstrike]) && (monster_level_adjustment() <= 150))
		{
			return useSkill($skill[Thunderstrike]);
		}

		if(canUse($skill[Unleash The Greash]) && (monster_element(enemy) != $element[sleaze]) && (have_effect($effect[Takin\' It Greasy]) > 100))
		{
			return useSkill($skill[Unleash The Greash]);
		}
		if(canUse($skill[Thousand-Yard Stare]) && (monster_element(enemy) != $element[spooky]) && (have_effect($effect[Intimidating Mien]) > 100))
		{
			return useSkill($skill[Thousand-Yard Stare]);
		}
		if($monsters[Aquagoblin, Lord Soggyraven, Groar] contains enemy && (my_mp() >= costMajor))
		{
			return attackMajor;
		}
		if((my_class() == $class[Turtle Tamer]) && canUse($skill[Spirit Snap]))
		{
			if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
			{
				return useSkill($skill[Spirit Snap]);
			}
		}
		if(canUse($skill[Northern Explosion]) && (my_class() == $class[Seal Clubber]) && (monster_element(enemy) != $element[cold]) && (hasClubEquipped() || (buffed_hit_stat() - 20) > monster_defense()))
		{
			return useSkill($skill[Northern Explosion]);
		}
		if((!combat_status_check("last attempt")) && (my_mp() >= costMajor))
		{
			if(canSurvive(1.4))
			{
				combat_status_add("last attempt");
				auto_log_warning("Uh oh, I'm having trouble in combat.", "red");
			}
			return attackMajor;
		}
		if(canSurvive(2.5))
		{
			auto_log_warning("Hmmm, I don't really know what to do in this combat but it looks like I'll live.", "red");
			if(my_mp() >= costMajor)
			{
				return attackMajor;
			}
			else if(my_mp() >= costMinor)
			{
				return attackMinor;
			}
			return "attack with weapon";
		}
		if(my_location() != $location[The Slime Tube])
		{
			abort("Could not handle monster, sorry");
		}
	}
	if((monster_level_adjustment() > 150) && (my_mp() >= 45) && canUse($skill[Shell Up]) && (my_class() == $class[Turtle Tamer]))
	{
		return useSkill($skill[Shell Up]);
	}

	if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[cold]) && canUse($skill[Throat Refrigerant], false))
	{
		return useSkill($skill[Throat Refrigerant], false);
	}

	if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]) && canUse($skill[Boiling Tear Ducts], false))
	{
		return useSkill($skill[Boiling Tear Ducts], false);
	}

	if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[sleaze]) && canUse($skill[Projectile Salivary Glands]))
	{
		return useSkill($skill[Projectile Salivary Glands]);
	}

	if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[spooky]) && canUse($skill[Translucent Skin], false))
	{
		return useSkill($skill[Translucent Skin], false);
	}

	if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && canUse($skill[Skunk Glands], false))
	{
		return useSkill($skill[Skunk Glands], false);
	}

	if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod") && (my_mp() >= costMajor))
	{
		return attackMajor;
	}

	if((monster_level_adjustment() > 150) && (my_mp() >= costMajor) && (attackMajor != "attack with weapon"))
	{
		return attackMajor;
	}

	if($monsters[Aquagoblin, Lord Soggyraven, Groar] contains enemy && (my_mp() >= costMajor))
	{
		return attackMajor;
	}

	if(canUse($skill[Lunge Smack], false) && (attackMinor != "attack with weapon") && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
	{
		return attackMinor;
	}
	if((my_mp() >= costMinor) && (attackMinor != "attack with weapon"))
	{
		return attackMinor;
	}

	if((round > 20) && canUse($skill[Saucestorm], false))
	{
		return useSkill($skill[Saucestorm], false);
	}

	if((attackMinor == "attack with weapon") && monster_defense() > 20 && (buffed_hit_stat() - 20) < monster_defense() && canUse($skill[Saucestorm], false))
	{
		return useSkill($skill[Saucestorm], false);
	}

	return attackMinor;
}
