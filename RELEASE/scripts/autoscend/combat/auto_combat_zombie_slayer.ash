//Path specific combat handling for Zombie Slayer

boolean wantBearHug(monster enemy)
{
	return canUse($skill[Bear Hug]) && 
		get_property("_bearHugs").to_int() < 10 && 
		!enemy.boss && 
		!contains_text(enemy.attributes, "FREE") && 
		enemy.group > 1;
}

boolean wantKodiakMoment(monster enemy)
{
	return canUse($skill[Kodiak Moment]) && enemy.physical_resistance >= 80;
} 

string auto_combatZombieSlayerStage1(int round, monster enemy, string text)
{
	// stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	if (!in_zombieSlayer())
	{
		return "";
	}

	return "";
}

string auto_combatZombieSlayerStage2(int round, monster enemy, string text)
{
	// stage 2 = enders: escape, replace, instakill, yellowray and other actions that instantly end combat
	if (!in_zombieSlayer())
	{
		return "";
	}

	return "";
}

string auto_combatZombieSlayerStage3(int round, monster enemy, string text)
{
	// stage 3 = debuff: delevel, stun, curse, damage over time
	if (!in_zombieSlayer())
	{
		return "";
	}

	if(canUse($skill[Infectious Bite]) && canSurvive(4.0))
	{
		return useSkill($skill[Infectious Bite]);
	}
	
	if(canUse($skill[Meat Shields]) && enemy.boss && canSurvive(4.0))
	{
		return useSkill($skill[Meat Shields]);
	}

	// Just always use Bear-ly Legal for the delevel + meat, unless we want to Bear Hug or Kodiak Moment
	if (canUse($skill[Bear-ly Legal]) && !wantBearHug(enemy) && !wantKodiakMoment(enemy))
	{
		return useSkill($skill[Bear-ly Legal]);
	}

	return "";
}

string auto_combatZombieSlayerStage4(int round, monster enemy, string text)
{
	// stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	if (!in_zombieSlayer())
	{
		return "";
	}
	
	// Basically stolen from Ed's Lash targets
	if(canUse($skill[Smash & Graaagh]) && get_property("_zombieSmashPocketsUsed").to_int() < 30 && canSurvive(2.0)) 
	{
		boolean doSmash = false;

		if((enemy == $monster[Big Wheelin\' Twins]) && !possessEquipment($item[Badge Of Authority]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Mountain Man]) && (item_amount(get_property("trapperOre").to_item()) < 3))
		{
			doSmash = true;
		}
		if((enemy == $monster[Fishy Pirate]) && !possessEquipment($item[Perfume-Soaked Bandana]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Garbage Tourist]) && (item_amount($item[Bag of Park Garbage]) == 0))
		{
			doSmash = true;
		}
		if (enemy == $monster[Dairy Goat] && item_amount($item[Goat Cheese]) < 3)
		{
			doSmash = true;
		}
		if (enemy == $monster[Monstrous Boiler] && item_amount($item[Red-Hot Boilermaker]) < 1 && get_property("booPeakProgress").to_int() > 0)
		{
			doSmash = true;
		}
		if (enemy == $monster[Fitness Giant] && item_amount($item[Pec Oil]) < 1 && get_property("booPeakProgress").to_int() > 0)
		{
			doSmash = true;
		}
		if (enemy == $monster[Renaissance Giant] && item_amount($item[Ye Olde Meade]) < 1)
		{
			doSmash = true;
		}
		if($monsters[Bearpig Topiary Animal, Elephant (Meatcar?) Topiary Animal, Spider (Duck?) Topiary Animal] contains enemy)
		{
			doSmash = true;
		}
		if($monsters[Beanbat, Bookbat] contains enemy)
		{
			doSmash = true;
		}
		if((enemy == $monster[Banshee Librarian]) && (item_amount($item[killing jar]) < 1) && (get_property("desertExploration").to_int() < 100) && ((get_property("gnasirProgress").to_int() & 4) == 0))
		{
			doSmash = true;
		}
		if(((enemy == $monster[Toothy Sklelton]) || (enemy == $monster[Spiny Skelelton])) && (get_property("cyrptNookEvilness").to_int() > 14 + cyrptEvilBonus(true)))
		{
			doSmash = true;
		}
		if((enemy == $monster[Oil Baron]) && (item_amount($item[Bubblin\' Crude]) < 12) && (item_amount($item[Jar of Oil]) == 0))
		{
			doSmash = true;
		}
		if((enemy == $monster[Blackberry Bush]) && (item_amount($item[Blackberry]) < 3) && !possessEquipment($item[Blackberry Galoshes]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Pygmy Bowler]) && (get_property("_zombieSmashPocketsUsed").to_int() < 26))
		{
			doSmash = true;
		}
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			doSmash = true;
		}
		if(enemy == $monster[Knob Goblin Madam])
		{
			if(item_amount($item[Knob Goblin Perfume]) == 0)
			{
				doSmash = true;
			}
		}
		if(enemy == $monster[Knob Goblin Harem Girl])
		{
			if(!possessEquipment($item[Knob Goblin Harem Veil]) || !possessEquipment($item[Knob Goblin Harem Pants]))
			{
				doSmash = true;
			}
		}
		if ((my_location() == $location[Hippy Camp] || my_location() == $location[Wartime Hippy Camp]) && contains_text(enemy, "hippy") && my_level() >= 12)
		{
			if(!possessEquipment($item[Filthy Knitted Dread Sack]) || !possessEquipment($item[Filthy Corduroys]))
			{

				doSmash = true;

			}
		}
		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doSmash = true;
			}
		}
		if((enemy == $monster[Dopey 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Helmet]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Grumpy 7-Foot Dwarf]) && !possessEquipment($item[7-Foot Dwarven Mattock]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Sleepy 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Pants]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Burly Sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Spunky Princess]) && !possessEquipment($item[Titanium Assault Umbrella]) && !possessEquipment($item[unbreakable umbrella]))
		{
			doSmash = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doSmash = true;
		}
		if (enemy == $monster[Copperhead Club bartender] && internalQuestStatus("questL11Ron") < 2)
		{
			doSmash = true;
		}

		if (doSmash)
		{
			handleTracker(enemy, $skill[Smash & Graaagh], "auto_otherstuff");
			return useSkill($skill[Smash & Graaagh]);			
		}
		
	}


	return "";
}

string auto_combatZombieSlayerStage5(int round, monster enemy, string text)
{
	if (!in_zombieSlayer())
	{
		return "";
	}

	if (wantBearHug(enemy))
	{
		return useSkill($skill[Bear Hug]);
	}

	// Spam plague claws if we won't die
	if(round < 20 && canSurvive(5.0) && auto_have_skill($skill[Plague Claws]) && enemy.physical_resistance < 80)
	{
		return useSkill($skill[Plague Claws]);
	}

	if (wantKodiakMoment(enemy))
	{
		return useSkill($skill[Kodiak Moment]);
	}

	if (canUse($skill[Bilious Burst]) && enemy.physical_resistance >= 80)
	{
		return useSkill($skill[Bilious Burst]);
	}

	return "";
}
