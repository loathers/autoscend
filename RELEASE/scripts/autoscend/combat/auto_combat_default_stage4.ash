string auto_combatDefaultStage4(int round, monster enemy, string text)
{
	//stage 4 killing the enemy.
	
	string combatState = get_property("auto_combatHandler");
	phylum type = monster_phylum(enemy);
	string attackMinor = "attack with weapon";
	string attackMajor = "attack with weapon";
	int costMinor = 0;
	int costMajor = 0;
	string stunner = "";
	int costStunner = 0;

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
		if(canUse($skill[Club Foot], false))
		{
			stunner = useSkill($skill[Club Foot], false);
			costStunner = mp_cost($skill[Club Foot]);
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
		if((my_mp() > 150) && canUse($skill[Shieldbutt], false) && hasShieldEquipped())
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
		if(canUse($skill[Shieldbutt], false) && hasShieldEquipped())
		{
			attackMajor = useSkill($skill[Shieldbutt], false);
			costMajor = mp_cost($skill[Shieldbutt]);
		}
		if(canUse($skill[Shell Up], false)) // can't mark it when using it as the generic stunner
		{
			stunner = useSkill($skill[Shell Up], false);
			costStunner = mp_cost($skill[Shell Up]);
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
		if(canUse($skill[Entangling Noodles], false))
		{
			stunner = useSkill($skill[Entangling Noodles], false);
			costStunner = mp_cost($skill[Entangling Noodles]);
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

		if(canUse($skill[Soul Bubble], false) && my_soulsauce() >= 5)
		{
			stunner = useSkill($skill[Soul Bubble]);
			costStunner = mp_cost($skill[Soul Bubble]);
		}

		if(!contains_text(combatState, "delaymortarshell") && canSurvive(2.0) && haveUsed($skill[Stuffed Mortar Shell]) && canUse($skill[Salsaball], false))
		{
			set_property("auto_combatHandler", combatState + "(delaymortarshell)");
			return useSkill($skill[Salsaball], false);
		}

		break;

	case $class[Avatar of Boris]:
		if(canUse($skill[Heroic Belch], false) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && (my_fullness() >= 5))
		{
			attackMinor = useSkill($skill[Heroic Belch], false);
			attackMajor = useSkill($skill[Heroic Belch], false);
			costMinor = mp_cost($skill[Heroic Belch]);
			costMajor = mp_cost($skill[Heroic Belch]);
		}

		if(canUse($skill[Broadside], false))
		{
			stunner = useSkill($skill[Broadside], false);
			costStunner = mp_cost($skill[Broadside]);
		}
		break;

	case $class[Avatar of Sneaky Pete]:
		if(canUse($skill[Peel Out]))
		{
			if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, Tomb Asp, Tomb Servant,  W imp] contains enemy)
			{
				return useSkill($skill[Peel Out]);
			}
		}


		if(canUse($item[Firebomb], false) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]))
		{
			return useItem($item[Firebomb], false);
		}

		if(canUse($skill[Pop Wheelie]) && (my_mp() > 40))
		{
			return useSkill($skill[Pop Wheelie]);
		}

		if(canUse($skill[Snap Fingers], false))
		{
			stunner = useSkill($skill[Snap Fingers], false);
			costStunner = mp_cost($skill[Snap Fingers]);
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

		if(canUse($skill[Accordion Bash], false) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			stunner = useSkill($skill[Accordion Bash], false);
			costStunner = mp_cost($skill[Accordion Bash]);
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

		if(auto_have_skill($skill[Disco State of Mind]) && auto_have_skill($skill[Flashy Dancer]) && auto_have_skill($skill[Disco Greed]) && auto_have_skill($skill[Disco Bravado]) && monster_level_adjustment() < 150)
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
			else if(($phylums[undead] contains type) && (item_amount($item[Skin Oil]) < 5))
			{
				return useSkill($skill[Extract Oil]);
			}
		}
		if(canUse($skill[Good Medicine]) && (my_mp() >= (3 * mp_cost($skill[Good Medicine]))))
		{
			return useSkill($skill[Good Medicine]);
		}

		if(canUse($skill[Hogtie]) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			return useSkill($skill[Hogtie]);
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

		if(canUse($skill[Beanscreen]) && !canSurvive(5.0))
		{
			stunner = useSkill($skill[Beanscreen]);
			costStunner = mp_cost($skill[Beanscreen]);
		}

		if(canUse($skill[Hogtie], false) && (my_mp() >= (3 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			stunner = useSkill($skill[Hogtie], false);
			costStunner = mp_cost($skill[Hogtie]);
		}
		break;

	case $class[Vampyre]:
		foreach sk in $skills[Chill of the Tomb, Blood Spike, Piercing Gaze, Savage Bite]
		{
			if(sk == $skill[Chill of the Tomb] && enemy.monster_element() == $element[cold])
				continue;
			if(canUse(sk, false) && my_hp() > 3 * hp_cost(sk))
			{
				attackMajor = useSkill(sk, false);
				attackMinor = useSkill(sk, false);
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
		if(canUse($skill[Blood Chains], false) && my_hp() > 3 * hp_cost($skill[Blood Chains]))
			stunner = useSkill($skill[Blood Chains], false);
		// intentionally not setting costMinor or costMajor since they don't cost mp...

		// If we're in a form or something, a beehive is probably better than just attacking
		if(attackMajor == "attack with weapon" && !have_skill($skill[Preternatural Strength]) && canUse($item[beehive]) && ($stat[moxie] != weapon_type(equipped_item($slot[Weapon]))))
		{
			attackMajor = useItem($item[beehive], false);
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

		if(!contains_text(combatState, "stunner") && (stunner != "") && (monster_level_adjustment() <= 100) && (my_mp() >= costStunner) && stunnable(enemy))
		{
			set_property("auto_combatHandler", combatState + "(stunner)");
			return stunner;
		}

		if(canUse($skill[Unleash The Greash]) && (monster_element(enemy) != $element[sleaze]) && (have_effect($effect[Takin\' It Greasy]) > 100))
		{
			return useSkill($skill[Unleash The Greash]);
		}
		if(canUse($skill[Thousand-Yard Stare]) && (monster_element(enemy) != $element[spooky]) && (have_effect($effect[Intimidating Mien]) > 100))
		{
			return useSkill($skill[Thousand-Yard Stare]);
		}
		if($monsters[Aquagoblin, Lord Soggyraven] contains enemy)
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
		if((!contains_text(combatState, "last attempt")) && (my_mp() >= costMajor))
		{
			if(canSurvive(1.4))
			{
				set_property("auto_combatHandler", combatState + "(last attempt)");
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

	if(attackMinor == "attack with weapon")
	{
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
		if(canUse($skill[Mighty Axing], false) && (equipped_item($slot[Weapon]) != $item[none]))
		{
			return useSkill($skill[Mighty Axing], false);
		}
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

	return attackMinor;
}
