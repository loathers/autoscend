boolean in_robot()
{
	return my_path() == "You, Robot";
}

void robot_initializeSettings()
{
	if(!in_robot())
	{
		return;
	}
	set_property("auto_wandOfNagamar", false);		//wand not used in this path
	set_property("auto_getSteelOrgan", false);		//robots do not have organs
	set_property("auto_getBeehive", true);			//robots are lacking in sources of damage
	set_property("auto_getBoningKnife", true);		//robots do not have AoE spells
	//several quests have tracking issues. confirmed questL08Trapper, questL09Topping, questL07Cyrptic
	set_property("auto_paranoia", 1);
}

string robot_defaultMaximizeStatement()
{
	//custom default maximizer statement for You, Robot.
	string res = "5item,meat,0.5initiative,0.4hp,0.1da 1000max,dr,0.5all res,-fumble,-ml";
	if(my_primestat() == $stat[Moxie])
	{
		res += ",1.5mox";
	}
	else
	{
		res += ",mox";
	}
	if(my_primestat() == $stat[Muscle])
	{
		res += ",1.5mus";
	}
	if(my_primestat() == $stat[mysticality])
	{
		if(possessEquipment($item[Fourth of May Cosplay Saber]) ||
		get_property("youRobotLeft").to_int() == 5)		//sniper rifle attachment
		{
			res += ",1.5mys";	//mys robots only want mainstat with lightsaber or sniper
		}
	}

	//weapon handling
	if(get_property("youRobotLeft").to_int() == 4)	//vice grips. unlocks weapon slot
	{
		if(possessEquipment($item[Fourth of May Cosplay Saber]))
		{
			autoEquip($item[Fourth of May Cosplay Saber]);
		}
		else
		{
			res += ",1.5weapon damage,0.75weapon damage percent,1.5elemental damage";
			if(my_primestat() == $stat[Muscle])
			{
				res += ",melee";
			}
			else
			{
				res += ",-melee";
			}
		}
	}

	if(get_property("youRobotTop").to_int() == 2)  //bird cage. unlocks familiar
	{
		res += ",2familiar weight";
		if(my_familiar().familiar_weight() < 20)
		{
			res += ",5familiar exp";
		}
	}

	return res;
}

boolean robot_top(int choice)
{
	//Top Attachment
	
	if(get_property("youRobotTop").to_int() == choice)
	{
		return false;	//already equipped
	}
	
	int scrap_cost;
	string name;
	switch(choice)
	{
		case 1:
			//Deal 20 damage + 10% of your Mox
			name = "[Pea Shooter]";
			scrap_cost = 5;
			break;
			
		case 2:
			//Allows the use of a familiar
			name = "[Bird Cage]";
			scrap_cost = 5;
			break;
			
		case 3:
			//Gain 1 energy after each fight
			name = "[Solar Panel]";
			scrap_cost = 5;
			break;
			
		case 4:
			//Allows you to equip a hat
			name = "[Mannequin Head]";
			scrap_cost = 15;
			break;
			
		case 5:
			//+50% Meat Drop
			name = "[Meat Radar]";
			scrap_cost = 30;
			break;
			
		case 6:
			//Spend 1 Scrap to deal 100% of your Moxie in damage
			name = "[Junk Cannon]";
			scrap_cost = 30;
			break;
			
		case 7:
			//Spend 1 Energy to deal 100% of your Moxie in damage
			name = "[Tesla Blaster]";
			scrap_cost = 30;
			break;
			
		case 8:
			//Spend 1 energy to deal 100% of your Muscle in Cold damage
			name = "[Snow Blower]";
			scrap_cost = 40;
			break;
			
		default:
			abort("boolean robot_top(int choice) does not recognize the choice: " +choice);
	}
	
	if(my_robot_scraps() < scrap_cost)
	{
		return false;
	}
	
	int starting_scrap = my_robot_scraps();
	auto_log_info("Setting Robot Top Attachment to " +name+ ", Have " +my_robot_scraps()+ " scrap on hand");
	visit_url("place.php?whichplace=scrapheap&action=sh_configure");
	visit_url("choice.php?whichchoice=1445&show=top");
	visit_url("choice.php?whichchoice=1445&part=top&show=top&option=1&p=" +choice);
	cli_execute("refresh all");
	
	if(my_robot_scraps() != starting_scrap - scrap_cost)
	{
		abort("Mysteriously failed to switch the Top Attachment to " +name+ ". Beep Boop.");
	}
	return true;
}

boolean robot_left(int choice)
{
	//Left Arm. this is the weapon hand.
	//kol devs drew it backwards. it says left arm but they drew it as right arm
	
	if(get_property("youRobotLeft").to_int() == choice)
	{
		return false;	//already equipped
	}
	
	int scrap_cost;
	string name;
	switch(choice)
	{
		case 1:
			//Deal 20 damage + 10% of your Mus
			name = "[Pound-O-Tron]";
			scrap_cost = 5;
			break;
			
		case 2:
			//+3 Resistance to All Elements
			name = "[Reflective Shard]";
			scrap_cost = 5;
			break;
			
		case 3:
			//+30% Item Drop
			name = "[Metal Detector]";
			scrap_cost = 5;
			break;
			
		case 4:
			//Allows you to equip a weapon
			name = "[Vice Grips]";
			scrap_cost = 15;
			break;
			
		case 5:
			//Spend 1 Scrap to deal 100% of your Mysticality in damage
			name = "[Sniper Rifle]";
			scrap_cost = 30;
			break;
			
		case 6:
			//Spend 1 Scrap to deal 100% of your Muscle in damage
			name = "[Junk Mace]";
			scrap_cost = 30;
			break;
			
		case 7:
			//-15% Combat Rate
			name = "[Camoflage Curtain]";
			scrap_cost = 30;
			break;
			
		case 8:
			//Spend 1 energy to deal 100% of your Moxie in Sleaze damage
			name = "[Grease Gun]";
			scrap_cost = 40;
			break;
			
		default:
			abort("boolean robot_left\(int choice\) does not recognize the choice: " +choice);
	}
	
	if(my_robot_scraps() < scrap_cost)
	{
		return false;
	}
	
	int starting_scrap = my_robot_scraps();
	auto_log_info("Setting Robot Left Arm to " +name+ ", Have " +my_robot_scraps()+ " scrap on hand");
	visit_url("place.php?whichplace=scrapheap&action=sh_configure");
	visit_url("choice.php?whichchoice=1445&show=left");
	visit_url("choice.php?whichchoice=1445&part=left&show=left&option=1&p=" +choice);
	cli_execute("refresh all");
	
	if(my_robot_scraps() != starting_scrap - scrap_cost)
	{
		abort("Mysteriously failed to switch the Right Arm to " +name+ ". Beep Boop.");
	}
	return true;
}

boolean robot_right(int choice)
{
	//Right Arm. this is the offhand.
	//kol devs drew it backwards. it says right arm but they drew it as left arm
	
	if(get_property("youRobotRight").to_int() == choice)
	{
		return false;	//already equipped
	}
	
	int scrap_cost;
	string name;
	switch(choice)
	{
		case 1:
			//+30 Maximum HP
			name = "[Slab-O-Matic]";
			scrap_cost = 5;
			break;
			
		case 2:
			//+10 DR, +50 DA
			name = "[Junk Shield]";
			scrap_cost = 5;
			break;
			
		case 3:
			//+1 Scrap after each combat
			name = "[Horseshoe Magnet]";
			scrap_cost = 5;
			break;
			
		case 4:
			//Allows you to equip an offhand item
			name = "[Omni-Claw]";
			scrap_cost = 15;
			break;
			
		case 5:
			//Spend 1 energy to deal 100% of your Myst in damage
			name = "[Mammal Prod]";
			scrap_cost = 30;
			break;
			
		case 6:
			//Spend 1 energy to deal 100% of your Mus in damage
			name = "[Solenoid Piston]";
			scrap_cost = 30;
			break;
			
		case 7:
			//+30 ML
			name = "[Blaring Speaker]";
			scrap_cost = 30;
			break;
			
		case 8:
			//Spend 1 energy to deal 100% of your Myst in hot damage
			name = "[Surplus Flamethrower]";
			scrap_cost = 40;
			break;
			
		default:
			abort("boolean robot_right(int choice) does not recognize the choice: " +choice);
	}
	
	if(my_robot_scraps() < scrap_cost)
	{
		return false;
	}
	
	int starting_scrap = my_robot_scraps();
	auto_log_info("Setting Robot Right Arm to " +name+ ", Have " +my_robot_scraps()+ " scrap on hand");
	visit_url("place.php?whichplace=scrapheap&action=sh_configure");
	visit_url("choice.php?whichchoice=1445&show=right");
	visit_url("choice.php?whichchoice=1445&part=right&show=right&option=1&p=" +choice);
	cli_execute("refresh all");
	
	if(my_robot_scraps() != starting_scrap - scrap_cost)
	{
		abort("Mysteriously failed to switch the Right Arm to " +name+ ". Beep Boop.");
	}
	return true;
}

boolean robot_bottom(int choice)
{
	//Propulsion System

	if(get_property("youRobotBottom").to_int() == choice)
	{
		return false;	//already equipped
	}
	
    int scrap_cost;
	string name;
	switch(choice)
	{
		case 1:
			//+10 Maximum HP
			name = "[Bald Tires]";
			scrap_cost = 5;
			break;
			
		case 2:
			//Deal 20 Hot Damage + 10% of your Myst
			name = "[Rocket Crotch]";
			scrap_cost = 5;
			break;
			
		case 3:
			//+30% Combat Initiative
			name = "[Motorcycle Wheel]";
			scrap_cost = 5;
			break;
			
		case 4:
			//Allows you to equip pants
			name = "[Robo-Legs]";
			scrap_cost = 15;
			break;
			
		case 5:
			//+30% Item Drop
			name = "[Magno-Lev]";
			scrap_cost = 30;
			break;
			
		case 6:
			//+50 Maximum HP, +10 DR
			name = "[Tank Treads]";
			scrap_cost = 30;
			break;
			
		case 7:
			//Gain 1 Scrap after each fight
			name = "[Snowplow]";
			scrap_cost = 30;
			break;
			
		default:
			abort("boolean robot_bottom(int choice) does not recognize the choice: " +choice);
	}
	
	if(my_robot_scraps() < scrap_cost)
	{
		return false;
	}

	int starting_scrap = my_robot_scraps();
	auto_log_info("Setting Robot Propulsion System to " +name+ ", Have " +my_robot_scraps()+ " scrap on hand");
	visit_url("place.php?whichplace=scrapheap&action=sh_configure");
	visit_url("choice.php?whichchoice=1445&show=bottom");
	visit_url("choice.php?whichchoice=1445&part=bottom&show=bottom&option=1&p=" +choice);
	cli_execute("refresh all");
	
	if(my_robot_scraps() != starting_scrap - scrap_cost)
	{
		abort("Mysteriously failed to switch the Propulsion System to " +name+ ". Beep Boop.");
	}
	return true;
}

boolean robot_cpu(int choice, boolean want_buy)
{
	//CPU Upgrades. buys the upgrade which matches choice
	//returns true if bought now or if we already had it.
	//want_buy means we want to actually purcahse it. otherwise we will only check if we have it already
	
	string upgrade;		//url component and also mafia tracking string in youRobotCPUUpgrades property
	string name;		//actual name of upgrade to log for the user to read
    int energy_cost;
	switch(choice)
	{
		case 1:
			//+15 Buffed Muscle
			name = "[Leverage Coprocessing]";
			upgrade = "robot_muscle";
			energy_cost = 30;
			break;
			
		case 2:
			//+15 Buffed Mysticality
			name = "[Dynamic Arcane Flux Modeling]";
			upgrade = "robot_mysticality";
			energy_cost = 30;
			break;
			
		case 3:
			//+15 Buffed Moxie
			name = "[Upgraded Fashion Sensor]";
			upgrade = "robot_moxie";
			energy_cost = 30;
			break;
			
		case 4:
			//+20% Meat Drops
			name = "[Financial Neural Net]";
			upgrade = "robot_meat";
			energy_cost = 30;
			break;
			
		case 5:
			//+30 Maximum HP
			name = "[Spatial Compression Functions]";
			upgrade = "robot_hp1";
			energy_cost = 40;
			break;
			
		case 6:
			//Regenerate +10 HP per Adventure
			name = "[Self-Repair Routines]";
			upgrade = "robot_regen";
			energy_cost = 40;
			break;
			
		case 7:
			//+2 Resistance to all elements
			name = "[Weather Control Algorithms]";
			upgrade = "robot_resist";
			energy_cost = 40;
			break;
			
		case 8:
			//+20% Item Drops
			name = "[Improved Optical Processing]";
			upgrade = "robot_items";
			energy_cost = 40;
			break;
			
		case 9:
			//Allows you to equip shirts
			name = "[Topology Grid]";
			upgrade = "robot_shirt";
			energy_cost = 50;
			break;
			
		case 10:
			//Gain 1 Energy per fight
			name = "[Overclocking]";
			upgrade = "robot_energy";
			energy_cost = 50;
			break;
			
		case 11:
			//Allows use of potions
			name = "[Biomass Processing Function]";
			upgrade = "robot_potions";
			energy_cost = 50;
			break;
			
		case 12:
			//+30 Maximum HP
			name = "[Holographic Deflector Projection]";
			upgrade = "robot_hp2";
			energy_cost = 50;
			break;
			
		default:
			abort("boolean robot_cpu(int choice) does not recognize the choice: " +choice);
	}
	
	if(contains_text(get_property("youRobotCPUUpgrades"),upgrade))
	{
		return true;	//I already have it
	}
	else if(!want_buy)
	{
		return false;	//we only wanted to check if we have it. we do not.
	}
	if(my_robot_energy() < energy_cost)
	{
		return false;	//I can not afford it
	}
	
	int starting_energy = my_robot_energy();
	auto_log_info("Upgrading CPU with " +name);
	visit_url("place.php?whichplace=scrapheap&action=sh_configure");
	visit_url("choice.php?whichchoice=1445&show=cpus");
	visit_url("choice.php?pwd&whichchoice=1445&part=cpus&show=cpus&option=2&p=" +upgrade);
	
	if(my_robot_energy() != starting_energy - energy_cost)
	{
		abort("Mysteriously failed to upgrade the CPU with " +choice+ ". Beep Boop.");
	}
	return true;
}

boolean robot_cpu(int choice)
{
	return robot_cpu(choice, true);
}

void robot_skillbuy()
{
	//select robot skills to install into your CPU. this costs energy.
	if(!in_robot())
	{
		return;
	}
	if(!auto_unreservedAdvRemaining())
	{
		return;		//we should not buy any skills when out of adv. as we could end up wasting a day
	}

	//massive turngen that pays for itself in 50 fights
	//10. [Overclocking] = Gain 1 Energy per fight. costs 50 energy.
	if(!robot_cpu(10, false) && my_robot_energy() > 80)
	{
		robot_cpu(10);	//buy it if we can
	}
	if(!robot_cpu(10, false))	//still don't have it?
	{
		return;		//do not buy anything else. save the energy for [Overclocking]
	}
	
	//robots are pretty fragile and should all get this ASAP
	//3. [Upgraded Fashion Sensor] = +15 Buffed Moxie. costs 30 energy.
	if(!robot_cpu(3, false) && my_robot_energy() > 60)
	{
		robot_cpu(3);	//buy it if we can
	}
	
	//myst classes can benefit from the extra damage
	//2. [Dynamic Arcane Flux Modeling] = +15 Buffed Mysticality. costs 30 energy.
	if(my_primestat() == $stat[Mysticality] && !robot_cpu(2, false) && my_robot_energy() > 60)
	{
		robot_cpu(2);	//buy it if we can
	}
	
	//muscle classes can benefit from the extra damage
	//1. [Leverage Coprocessing] = +15 Buffed Muscle. costs 30 energy.
	if(my_primestat() == $stat[muscle] && !robot_cpu(1, false) && my_robot_energy() > 60)
	{
		robot_cpu(1);	//buy it if we can
	}
	
	//we should get passive HP recovery
	//6. [Self-Repair Routines] = Regenerate +10 HP per Adventure. costs 40 energy
	if(!robot_cpu(6, false) && my_robot_energy() > 70)
	{
		robot_cpu(6);	//buy it if we can
	}
	
	//once we have unlocked the 2nd spookyraven floor we should get the first maxHP boost.
	//5. [Spatial Compression Functions] = +30 Maximum HP. costs 40 energy
	if(get_property("lastSecondFloorUnlock").to_int() == my_ascensions() && !robot_cpu(5, false) && my_robot_energy() > 70)
	{
		robot_cpu(5);	//buy it if we can
	}

	//we already have essentials. The rest should be acquired using excess energy.
	if(robot_chronolith_cost() > 47)
	{
		robot_cpu(8);		//8. [Improved Optical Processing] = +20% Item Drops. costs 40 energy.
		robot_cpu(4);		//4. [Financial Neural Net] = +20% Meat Drops. costs 30 energy.
		robot_cpu(12);		//12. [Holographic Deflector Projection] = +30 Maximum HP. costs 50 energy.
		robot_cpu(11);		//11. [Biomass Processing Function] = Allows use of potions. costs 50 energy.
		robot_cpu(7);		//7. [Weather Control Algorithms] = +2 Resistance to all elements. costs 40 energy.
		robot_cpu(9);		//9. [Topology Grid] = Allows you to equip shirts. costs 50 energy.
	}
	
	//if we bought [Topology Grid] we are done. shirt helps with surgeonosity which we why we even bother with it
	if(robot_cpu(9, false))
	{
		set_property("auto_robot_skills_bought", my_ascensions());
	}
}

int robot_energy_per_collect()
{
	//how much energy do you get per adv spent on Collect Energy
	//first one gives 25 + ascension points. ascension points are 1 per softcore 2 per hardcore robot ascensions done. capped at 37
	//subsequent collections give 15% less each time. compounded exponenetially (this is a good thing for you). final step is rounded to nearest int.
	//there is some slight wobble to it that can cause some inconsistent rounding on kol's side. Thus this is an estimate not an absolute
	
	int ascension_points = get_property("youRobotPoints").to_int();
	int collected_today = get_property("_energyCollected").to_int();
	
	float raw = (25.0 + ascension_points) * (0.85**collected_today);
	
	//only the final step is rounded. it is rounded to the nearest int. not floor, not ceil
	return round(raw);
}

boolean LX_robot_get_energy()
{
	//collect energy in the scrap heap. costs 1 adv. gives 25 energy. decreased by 15% per use today.
	//first use each day grants bonus based on number of robot ascensions. to a max of 37
	if(!in_robot())
	{
		return false;
	}
	if(my_adventures() < 1)
	{
		return false;
	}
	int start = get_property("_energyCollected").to_int();
	visit_url("place.php?whichplace=scrapheap&action=sh_getpower");
	if(start + 1 != get_property("_energyCollected").to_int())
	{
		abort("Collect Energy mysteriously failed. Beep Boop.");
	}
	return true;
}

boolean LX_robot_get_scrap_once()
{
	//getting scrap gives 4 to 6 scrap and 50 HP recovery.
	//on first use per day you also get scrap, equal to 3 tiems ascension points. capped at 37
	//return true if we need to restart the main loop due to having spent an adv
	if(!in_robot())
	{
		return false;
	}
	if(my_adventures() < 1)
	{
		return false;
	}
	int start = my_robot_scraps();
	visit_url("place.php?whichplace=scrapheap&action=sh_scrounge");
	if(start == my_robot_scraps())
	{
		abort("Collect Energy mysteriously failed. Beep Boop.");
	}
	return true;
}

boolean LX_robot_get_scrap(int target)
{
	//get scrap to match the required target amount.
	//return true to restart the main loop.
	if(!in_robot())
	{
		return false;
	}
	if(my_robot_scraps() >= target)
	{
		return false;	//already done
	}
	
	//spend 1 adv to grab scraps. restart loop if successful. will abort on fail
	if(LX_robot_get_scrap_once()) return true;
	
	return false;
}

int robot_chronolith_cost()
{
	//this function returns the current energy cost of using chronolith
	//chronolith provides you with 10 adventures per use at variable cost.
	//cost 10 energy +1 per use. after 37 activations price is at x2. after 74 activations price is at x10
	//mafia tracker _chronolithActivations DOES NOT track how many times you used it today. Instead it tracks the extra cost.
	return 10 + get_property("_chronolithActivations").to_int();
}

void robot_get_adv()
{
	//robots can not eat or drink. they get all their adventures in the chronolith by spending energy.
	//each use gives 10 adv and has energy cost of 10 + uses_today. doubles after 37. 10x after 74
	if(!in_robot())
	{
		return;
	}
	if(my_robot_energy() < robot_chronolith_cost())
	{
		return;		//I don't have enough energy
	}
	if(my_adventures() > 10 && my_robot_energy() < 100)
	{
		//wait until adv count is low before we consume energy.
		return;
	}
	if(robot_chronolith_cost() > 47)
	{
		//we hit the softcap and now costs are double.
		//TODO instead of just stopping check if we already got all the energy upgrades.
		//if we did buy all the energy upgrades we might as well use it
		return;
	}
	
	int start_adv = my_adventures();
	visit_url("place.php?whichplace=scrapheap&action=sh_chronobo");
	if(my_adventures() != 10 + start_adv)
	{
		abort("Mysteriously failed to use the chronolith. Beep. Boop.");
	}
}

int robot_statbot_cost()
{
	//statbot 5000 provides you with +5 base stats to a chosen stat for 10 + X. where X is the number of times it was used this ascension.
	//this function returns the current energy cost
	return 10 + get_property("statbotUses").to_int();
}

boolean robot_statbot(stat target)
{
	//robot does not get XP from combat. robot CAN get XP from noncombats such as haunted bedroom.
	//robot can trade energy for 5 base stats at statbot 5000. cost scales up with uses and does not reset on rollover.
	if(!in_robot())
	{
		return false;
	}
	if(my_robot_energy() < robot_statbot_cost())
	{
		return false;		//I don't have enough energy to buy more stats
	}
	
	int nn = 1;		//muscle
	if(target == $stat[Mysticality])
	{
		nn = 2;
	}
	if(target == $stat[Moxie])
	{
		nn = 3;
	}
	
	int start_uses = get_property("statbotUses").to_int();
	visit_url("place.php?whichplace=scrapheap&action=sh_upgrade");
	run_choice(nn);
	
	if(get_property("statbotUses").to_int() != 1 + start_uses)
	{
		abort("Using Statbot-5000 mysteriously failed. Beep Boop.");
	}
	return true;
}

stat robot_stat_wanted()
{
	//which stat do we most want to raise next as a robot. If we want multiple stats that would be handled elsewhere.
	boolean is_mus = my_primestat() == $stat[muscle];
	boolean is_mys = my_primestat() == $stat[mysticality];
	boolean is_mox = my_primestat() == $stat[moxie];
	if(!is_mox && my_basestat($stat[moxie]) < my_basestat(my_primestat()))
	{
		//mys classes should keep moxie higher than their mainstat since they are effectively a discount moxie class in this path
		//mus classes should keep moxie higher than their mainstat due to low init, no healing skill, & very low HP in this path
		return $stat[moxie];
	}
	if(my_level() < 13)
	{
		//raise primestat until we are level 13 to unlock all quests
		return my_primestat();
	}
	if(disregardInstantKarma() && possessEquipment($item[Fourth of May Cosplay Saber]))
	{
		//you can never have enough dakka. with lightsaber increasing primestat increases your damage.
		return my_primestat();
	}
	if(is_mys)
	{
		//if we are not raising mys for saber then after level 13 mys classes should stop raising their mys and only raise their mox
		return $stat[moxie];
	}
	else if(disregardInstantKarma())
	{
		//mox and muscle should just keep on raising that offense stat if they do not care about karma.
		return my_primestat();
	}
	if(my_basestat($stat[moxie]) < 70)
	{
		//we need 70 mox to wear the war outfit
		return $stat[moxie];
	}
	if(my_basestat($stat[mysticality]) < 70)
	{
		//we need 70 mox to wear the war outfit
		return $stat[mysticality];
	}
	
	return $stat[none];
}

boolean LX_robot_level()
{
	if(!in_robot())
	{
		return false;
	}
	
	//leaflet should be done ASAP
	if(L9_leafletQuest()) return true;
	
	//grab the XP from free rests in chateau mantegna
	if(chateaumantegna_available() && haveFreeRestAvailable())
	{
		doFreeRest();
		cli_execute("scripts/autoscend/auto_post_adv.ash");
		loopHandlerDelayAll();
		return true;
	}
	
	//once we got a couple of levelups we should do the 2nd floor quest for the extra substat rewards
	if(my_level() > 7)
	{
		if(LX_spookyravenManorSecondFloor()) return true;
	}
	
	//mox and mys both need to be leveled up to 70 so we can wear the war outfit for L12 quest.
	//mus needs to be leveled up to 62 to equip [antique machete] to clear dense lianas
	//Haunted Bedroom is ideal for it as it raises all 3 stats. provides meat. and does it all through noncombats.
	//we should grab several levels there early on before we start relying on statbot
	if(my_level() < 9)
	{
		if(autoAdv($location[The Haunted Bedroom])) return true;
	}
	
	//delay checks before we buy stats from statbot 5000
	if(get_property("auto_robot_skills_bought").to_int() != my_ascensions())
	{
		return false;		//we want to preserve our energy to buy skills
	}
	if(my_robot_energy() < robot_statbot_cost() + robot_chronolith_cost() || robot_chronolith_cost() <= 47)
	{
		return false;		//we want to preserve our energy to buy adventures
	}
	
	//if we reached this point we are actually willing to use statbot 5000 to buy 5 stat points.
	stat target = robot_stat_wanted();
	if(target != $stat[none])
	{
		if(robot_statbot(target)) return true;
	}
	
	return false;
}

boolean LX_robot_powerlevel()
{
	//a function for more aggressive leveling when our robot runs out of things to do.
	//hopefully this never comes up and we only use LX_robot_level() to level
	if(!in_robot())
	{
		return false;
	}
	if(!isAboutToPowerlevel())
	{
		return false;
	}
	if(my_level() > 12 && my_basestat($stat[mysticality]) >= 70 && my_basestat($stat[moxie]) >= 70)
	{
		return false;
	}
	
	set_property("auto_powerLevelAdvCount", get_property("auto_powerLevelAdvCount").to_int() + 1);
	set_property("auto_powerLevelLastAttempted", my_turncount());
	auto_log_warning("I need to powerlevel", "red");
	int delay = get_property("auto_powerLevelTimer").to_int();
	if(delay == 0)
	{
		delay = 10;
	}
	wait(delay);
	
	//mox and mys both need to be leveled up to 70 so we can wear the war outfit for L12 quest.
	//mus needs to be leveled up to 62 to equip [antique machete] to clear dense lianas
	//Haunted Bedroom is ideal for it as it raises all 3 stats. provides meat. and does it all through noncombats.
	//however we should not over rely on it. it is best to allow statbot to operate as well
	boolean need_mus = my_basestat($stat[muscle]) < 62;
	boolean need_mys = my_basestat($stat[mysticality]) < 70;
	boolean need_mox = my_basestat($stat[moxie]) < 70;
	if(need_mus || need_mys || need_mox)
	{
		if(autoAdv($location[The Haunted Bedroom])) return true;
	}

	//until chronolith cost is 10*income we are gaining adventures with every combat.
	//if gaining adv it is preferable to adv in haunted gallery for XP and adv	
	int income = 1;
	if(get_property("youRobotTop").to_int() == 3)
	{
		income++;		//solar panel head attachment installed
	}
	if(robot_cpu(10, false))
	{
		income++;		//overclocking cpu upgrade installed
	}
	if(robot_chronolith_cost() <= 10*income)
	{
		if(autoAdv($location[The Haunted Bedroom])) return true;
	}
	
	//raise individual stats
	stat target = robot_stat_wanted();
	if(target != $stat[none])
	{
		// use spare clovers to powerlevel mainstat if you have spare clovers
		if(my_level() < 13 && cloversAvailable() > 0 && !can_interact())		//do not waste all clovers in postronin
		{
			//Determine where to go for clover stats, do not worry about clover failures
			location whereTo = $location[none];
			switch (target)
			{
				case $stat[Muscle]:
					whereTo = $location[The Haunted Gallery];
					break;
				case $stat[Mysticality]:
					whereTo = $location[The Haunted Bathroom];
					break;
				case $stat[Moxie]:
					whereTo = $location[The Haunted Ballroom];
					break;
			}

			cloverUsageInit();
			boolean adv_spent = autoAdv(whereTo);
			cloverUsageFinish();
			if(adv_spent) return true;
		}
		
		//buy 5 primestats from statbot 5000.
		if(robot_statbot(target)) return true;
	}
	
	//in case we can not afford statbot cost. try a final time in haunted bedroom
	if(autoAdv($location[The Haunted Bedroom])) return true;
	
	return false;
}

boolean robot_assemble()
{
	//selects replacement parts to assemble unto your chasis. this costs scrap.
	//return true if you want to restart the main loop. otherwise return false
	if(!in_robot())
	{
		return false;
	}

	//top assembly. hat
	//rarely is there something better than solar panel. those edge cases can be handled later
	if(robot_directive_check("outfit"))
	{
		//we are doing a quest that requires wearing an outfit.
		if(get_property("youRobotTop").to_int() != 4)
		{
			if(LX_robot_get_scrap(15)) return true;
		}
		robot_top(4);	//Mannequin Head. hat slot unlocked
	}
	else if(robot_directive_check("chasm") && my_primestat() == $stat[muscle])
	{
		if(get_property("youRobotTop").to_int() != 8)
		{
			if(LX_robot_get_scrap(40)) return true;
		}
		robot_top(8);		//Snow Blower. Spend 1 energy to deal 100% of your Muscle in Cold damage
	}
	else if(robot_assemble_want_bird_cage())
	{
		//we are doing a quest that requires a familiar
		if(get_property("youRobotTop").to_int() != 2)
		{
			if(LX_robot_get_scrap(5)) return true;
		}
		robot_top(2);	//bird cage. unlock familiar
	}
	else
	{
		if(get_property("youRobotTop").to_int() != 3)
		{
			if(LX_robot_get_scrap(5)) return true;
		}
		robot_top(3);	//solar panel. +1 energy / combat won.
	}
	
	//"left" arm. weapon slot
	if(robot_assemble_want_sniper())
	{
		if(get_property("lastSecondFloorUnlock").to_int() == my_ascensions() && get_property("youRobotLeft").to_int() != 5)
		{
			//we already unlocked the 2nd floor so this is actually uregen enough to collect scrap. spend adv on it
			if(LX_robot_get_scrap(30)) return true;		//will abort if it fails
		}
		robot_left(5);		//sniper rifle. spend 1 scrap to deal mys physical damage
		if(LX_robot_get_scrap(10)) return true;		//get ammo
	}
	else
	{
		if(get_property("youRobotLeft").to_int() != 4)
		{
			if(LX_robot_get_scrap(15)) return true;
		}
		robot_left(4);		//vice grips. unlock weapon slot
	}
	
	//"right" arm. offhand
	if(robot_directive_check("desert") || (robot_directive_check("chasm") && possessEquipment($item[Loadstone])))
	{
		if(get_property("youRobotRight").to_int() != 4)
		{
			if(LX_robot_get_scrap(15)) return true;
		}
		robot_right(4);		//omni-claw. offhand slot unlock
	}
	else
	{
		if(get_property("youRobotRight").to_int() != 3)
		{
			if(LX_robot_get_scrap(5)) return true;
		}
		robot_right(3);		//horseshow magnet. +1 scrap / combat victory
	}
	
	//propulsion. pants.
	if(robot_directive_check("outfit"))
	{
		//we are doing a quest that requires wearing an outfit.
		if(get_property("youRobotBottom").to_int() != 4)
		{
			if(LX_robot_get_scrap(15)) return true;
		}
		robot_bottom(4);		//Robo-Legs. pants slot unlocked
	}
	else if(internalQuestStatus("questL13Final") > 5)
	{
		//we have started climbing the tower of the [Nautomatic Sorceress]
		if(get_property("youRobotBottom").to_int() != 6)
		{
			if(LX_robot_get_scrap(30)) return true;
		}
		robot_bottom(6);	//Tank Treads. +50 Maximum HP +10 DR
	}
	else if(robot_assemble_want_rocket_crotch())
	{
		if(get_property("youRobotBottom").to_int() != 2)
		{
			if(LX_robot_get_scrap(5)) return true;
		}
		robot_bottom(2);	//rocket crotch. 20 + 0.1 mys fire dmg attack
	}
	else
	{
		//all other situations we want init bonus. which is useful on various quests as well as general combat
		//situationally urgent. cheap enough we can just always treat it as uregent and grab the scrap if needed
		if(get_property("youRobotBottom").to_int() != 3)
		{
			if(LX_robot_get_scrap(5)) return true;
		}
		robot_bottom(3);	//motorcycle wheel. +30% combat initiative
	}
	
	return false;
}

boolean robot_assemble_want_sniper()
{
	//do we want to switch our left hand to sniper rifle attachment?
	//this does not check if it is urgent to do so immediately.
	if(robot_directive_check("machete"))
	{
		return false;
	}
	if(my_primestat() != $stat[mysticality])
	{
		return false;		//only mys classes ever want to use the sniper rifle
	}
	if(possessEquipment($item[Fourth of May Cosplay Saber]))
	{
		return false;		//saber is so good to obsoletes sniper rifle
	}
	if(robot_directive_check("outfit3"))		//fighting L12 warboss
	{
		return true;		//as a mys class without a saber we need some way to kill the warboss
	}
	if(my_basestat($stat[Moxie]) > 110)		//can not use buffed or we risk a loop of switching back and forth.
	{
		return false;		//we are powerful enough to dump the sniper and switch to a weapon slot
	}
	
	return true;
}

boolean robot_assemble_want_rocket_crotch()
{
	//do we want to switch our propulsion system to rocket crotch
	//unless user played manually will only be used to keep it as starting gear temporarily
	if(robot_directive_check("raven1"))
	{
		return true;		//useful in spookyraven 1st floor to defeat the ghosts
	}
	if(robot_directive_check("city"))
	{
		return true;		//needed to kill ghosts
	}
	boolean left_vice = get_property("youRobotLeft").to_int() == 4;		//vice grips. unlock weapon slot
	boolean left_sniper = get_property("youRobotLeft").to_int() == 5;		//sniper rifle. deal 100% mys damage
	if(my_primestat() == $stat[mysticality] && !left_vice && !left_sniper)
	{
		//generally it is only wanted by mys classes who have no other means of attack
		return true;
	}
	return false;
}

boolean robot_assemble_want_bird_cage()
{
	//do we want to switch our top attachment to [bird cage] to unlock familiar?
	//to prevent issues. our autoscend functions related to familiars say we do not have familiars at all if we do not have a [bird cage] already
	//as such you should use mafia's have_familiar(familiar name) function to check availability.
	if(get_property("auto_robot_directive") == "desert")
	{
		if(have_familiar($familiar[Melodramedary]))
		{
			return true;		//+1%p desert exploration. it is great
		}
		else if(have_familiar($familiar[Left-Hand Man]) && possessUnrestricted($item[Ornate Dowsing Rod]))
		{
			return true;		//we can use both the rod and the compass this way
		}
	}
	
	return false;
}

boolean robot_choice_adv(int choice, string page)
{
	//an override function for some of the robot choice adventures.
	//return true if an override was found and used. return false if nothing was done
	if(!in_robot())
	{
		return false;
	}
	auto_log_debug("Running robot_choice_adv");
	
	switch (choice)
	{
		case 876: // One Simple Nightstand (The Haunted Bedroom)
			boolean robot_need_mus = my_primestat() == $stat[muscle] || my_basestat($stat[muscle]) < 62;
			if(my_meat() < 1000 + meatReserve() && auto_is_valid($item[old leather wallet]) && !robot_need_mus)
			{
				run_choice(1); //get old leather wallet worth ~500 meat
			}
			else if(item_amount($item[ghost key]) > 0 && my_primestat() == $stat[muscle])
			{
				run_choice(3); // spend 1 ghost key for primestat, get ~200 muscle XP
			}
			else
			{
				run_choice(2); // get min(200,muscle) of muscle XP
			}
			break;
		case 878: // One Ornate Nightstand (The Haunted Bedroom)
			boolean robot_need_mys = my_primestat() == $stat[mysticality] || my_basestat($stat[mysticality]) < 70;
			boolean needSpectacles = (item_amount($item[Lord Spookyraven\'s Spectacles]) == 0 && internalQuestStatus("questL11Manor") < 2);
			if (needSpectacles) {
				run_choice(3); // get Lord Spookyraven's spectacles
			} else if (item_amount($item[disposable instant camera]) == 0 && internalQuestStatus("questL11Palindome") < 1) {
				run_choice(4); // get disposable instant camera
			} else if (!robot_need_mys || my_meat() < 1000 + meatReserve()) {
				run_choice(1); // get ~500 meat
			} else if(item_amount($item[ghost key]) > 0 && my_primestat() == $stat[mysticality]) {
				run_choice(5); // spend 1 ghost key for primestat, get ~200 mysticality XP
			} else {
				run_choice(2); // get min(200,mys) of mys XP
			}
			break;
		case 879: // One Rustic Nightstand (The Haunted Bedroom)
			string[int] options = available_choice_options();
			if(options contains 4) {
				run_choice(4); // only shows up rarely. when this line was added it was worth 1.3 million in mall
			} else if(item_amount($item[ghost key]) > 0 && my_primestat() == $stat[moxie]) {
				run_choice(5); // spend 1 ghost key for primestat, get ~200 moxie XP
			} else {
				run_choice(1); // get moxie substats
			}
			break;
		default:
			//none of the overrides was used. so we return false
			return false;
	}
	//an override must have been used. as we broke out of the switch without reaching default
	return true;
}

void robot_directive()
{
	//configures a directive which will allow us to group quests together for robot assembly changes.
	//directives are needed because changing attachments actually carries a cost. unlike outfit changes which are free.
	if(!in_robot())
	{
		remove_property("auto_robot_directive");
		return;
	}
	string directive = get_property("auto_robot_directive");
	
	//set and remove spookyraven directives: "raven1"
	boolean raven1_done = get_property("lastSecondFloorUnlock").to_int() == my_ascensions();		//first floor finished
	if(directive == "" && !raven1_done)
	{
		set_property("auto_robot_directive", "raven1");
	}
	if(directive == "raven1" && raven1_done)
	{
		remove_property("auto_robot_directive");
	}
	
	if(my_level() < 13)
	{
		return;	//all directives below this line should wait until level 13
	}

	//set and remove "outfit1", "outfit2", and "outfit3" directives
	boolean slope_ready = in_hardcore() && internalQuestStatus("questL08Trapper") == 2;
	boolean slope_done = in_hardcore() ? get_property("questL08Trapper") == "finished" : true;		//softcore always considered done
	
	boolean gob_ready = internalQuestStatus("questL05Goblin") == 1 && possessOutfit("Knob Goblin Harem Girl Disguise");
	boolean gob_done = get_property("questL05Goblin") == "finished";
	
	boolean outfit_check_riders = (slope_ready || slope_done) && (gob_ready || gob_done);
	
	boolean island_access = get_property("lastIslandUnlock").to_int() >= my_ascensions();
	boolean arena_done = get_property("sidequestArenaCompleted") != "none" || get_property("flyeredML").to_int() > 9999 ||
	auto_warSide() == "hippy";		//hippy arena not implemented yet
	boolean war_can_kill_boss = my_primestat() != $stat[mysticality] || possessEquipment($item[Fourth of May Cosplay Saber]);
	boolean war_battlefield_cleared = auto_warEnemiesRemaining() == 0;
	boolean war_have_preoutfit = possessOutfit("Filthy Hippy Disguise") || possessOutfit("Frat Boy Ensemble");
	boolean war_have_stats = my_basestat($stat[moxie]) >= 70 && my_basestat($stat[mysticality]) >= 70;
	//ready to start the war
	boolean war_ready1 = internalQuestStatus("questL12War") == 0 && war_have_stats && (haveWarOutfit() || war_have_preoutfit);
	//ready to clear the battlefield
	boolean war_ready2 = internalQuestStatus("questL12War") == 1 && arena_done && !war_battlefield_cleared;
	//ready to kill the warboss
	boolean war_ready3 = internalQuestStatus("questL12War") == 1 && war_can_kill_boss && war_battlefield_cleared;
	boolean war_started = internalQuestStatus("questL12War") == 1;		//L12 war started. 0 is for war QUEST started but NOT the war itself
	boolean war_finished = get_property("questL12War") == "finished";
	if(directive == "outfit1" && slope_done && gob_done && (war_started || war_battlefield_cleared || war_finished))
	{
		//we remove outfit1 and go do other quests while flyering for arena
		remove_property("auto_robot_directive");
	}
	if(directive == "outfit2" && slope_done && gob_done && (war_battlefield_cleared || war_finished))
	{
		//we cleared the battlefield so it is time to directly move directive from outfit2 (clear battlefield) to outfit3 (kill warboss)
		//we want to make sure we are done with slope and gob as well since mys classes prefer not to do them using outfit3.
		remove_property("auto_robot_directive");
	}
	if(directive == "outfit3" && war_finished)
	{
		remove_property("auto_robot_directive");
	}
	if(directive == "" && war_ready1 && outfit_check_riders && island_access)
	{
		set_property("auto_robot_directive", "outfit1");
	}
	if(directive == "" && war_ready2 && outfit_check_riders)
	{
		set_property("auto_robot_directive", "outfit2");
	}
	if(directive == "" && war_ready3 && outfit_check_riders)
	{
		set_property("auto_robot_directive", "outfit3");
	}
	
	//set and remove "desert" and "chasm" directives. we want to chain from desert into chasm if chasm needs offhand
	boolean desert_ready = internalQuestStatus("questL11Desert") == 0;
	boolean desert_done = internalQuestStatus("questL11Desert") > 0;
	boolean chasm_offhand_slot_needed = possessEquipment($item[Loadstone]) || canPull($item[Loadstone]);
	boolean chasm_ready = internalQuestStatus("questL09Topping") == 0 && get_property("chasmBridgeProgress").to_int() < 30 && !shenShouldDelayZone($location[The Smut Orc Logging Camp]);
	boolean chasm_done = internalQuestStatus("questL09Topping") > 0;
	
	if(directive == "chasm" && chasm_done)
	{
		remove_property("auto_robot_directive");
	}
	if(directive == "desert" && desert_done)
	{
		if(chasm_ready && chasm_offhand_slot_needed)
		{
			set_property("auto_robot_directive", "chasm");
		}
		else
		{
			remove_property("auto_robot_directive");
		}
	}
	if(directive == "" && desert_ready && (chasm_ready || !chasm_offhand_slot_needed || chasm_done))
	{
		//we want desert to wait until chasm is ready so we can chain the two. to avoid having to switch offhand
		set_property("auto_robot_directive", "desert");
	}
	if(directive == "" && chasm_ready)
	{
		set_property("auto_robot_directive", "chasm");
	}
	
	//set and remove "machete" directive. used exclusively by mys classes
	//the need for this might have been obsoleted by updates to leveling functions
	boolean city_ready = internalQuestStatus("questL11Worship") == 3;		//we unlocked the hidden city
	boolean city_ziggurat_ready = internalQuestStatus("questL11Worship") == 4;		//we are about to do ziggurat next
	boolean city_finished = get_property("questL11Worship") == "finished";
	boolean liana_cleared = get_property("hiddenApartmentProgress") > 0 &&
	get_property("hiddenOfficeProgress") > 0 &&
	get_property("hiddenHospitalProgress") > 0 &&
	get_property("hiddenBowlingAlleyProgress") > 0 &&
	get_property("auto_openedziggurat").to_boolean();
	if(directive == "machete" && liana_cleared)
	{
		remove_property("auto_robot_directive");
	}
	if(directive == "" && city_ready && my_primestat() == $stat[mysticality] && !liana_cleared)
	{
		set_property("auto_robot_directive", "machete");
	}
	
	//set and remove city directive. it is used to switch our bottom to rocket crotch for fire damage so we can kill the ghosts
	//TODO refactor the hidden city code from 1 megafunction into modern code. then refactor this directive.
	if(directive == "city" && (city_finished || city_ziggurat_ready))
	{
		remove_property("auto_robot_directive");
	}
	if(directive == "" && city_ready && !city_ziggurat_ready && liana_cleared)
	{
		set_property("auto_robot_directive", "city");
	}
	
	//set and remove "ml" directive for oil peak and defiled cranny.
	//defiled cranny currently disabled. it is a megafunction that needs to be broken up and refactored into modern code before handling it here.
	//mafia is not tracking fires lit during the highland quest. TODO make our own tracking in another PR and then write code here
}

boolean robot_directive_check(string check)
{
	if(!in_robot())
	{
		remove_property("auto_robot_directive");
	}
	return get_property("auto_robot_directive").contains_text(check);
}

boolean robot_delay(string check)
{
	//should we delay quests until directive contains string check?
	//for a contains example. climbing the slope wants "outfit". it does not care if outfit1, outfit2, or outfit3.
	//on the other hand L12 quest final boss must be on "outfit3" specifically.
	//return true to delay. false to not delay
	return in_robot() && !robot_directive_check(check);
}

boolean LM_robot()
{
	if(!in_robot())
	{
		return false;
	}
	
	//every boss drops 1 of those. it is a quest item which gives you 30 to 50 energy when used.
	if(item_amount($item[Robo-battery]) > 0)
	{
		cli_execute("refresh quests");		//there are some quest tracking issues in you robot. this alleviates them
		use(item_amount($item[Robo-battery]), $item[Robo-battery]);
	}
	
	if(robot_energy_per_collect() > 3)
	{
		//spend adv to directly acquire energy so long as it provides us with more energy than we would have gotten from adventuring.
		//this is assuming we adventure with solar panel and CPU upgrade
		if(LX_robot_get_energy()) return true;
	}
	
	if(!get_property("youRobotScavenged").to_boolean())
	{
		//get the bonus scrap from first scavenging of the day
		if(LX_robot_get_scrap_once()) return true;
	}
	
	robot_skillbuy();
	
	return false;
}

boolean LA_robot()
{
	if(!in_robot())
	{
		return false;
	}
	
	robot_directive();
	if(robot_assemble()) return true;
	
	//directives must be done first. we do not want to waste time with those attachments
	string directive = get_property("auto_robot_directive");
	if(directive == "raven1")
	{
		//unlock first floor of spookyraven manor
		//force ignoring the delay for 9 hot & 9 stench res setting so we can get through the kitchen
		if(LX_unlockHauntedBilliardsRoom(false)) return true;
		if(LX_spookyravenManorFirstFloor()) return true;
		abort("Failed to execute directive: " +directive);
	}
	if(directive == "desert")
	{
		if(L11_aridDesert()) return true;
		abort("Failed to execute directive: " +directive);
	}
	if(directive == "outfit1" || directive == "outfit2")
	{
		//we are at portions of quests that need an outfit. first two are specific portions so they should be done first.
		if(L5_slayTheGoblinKing()) return true;
		if(L8_trapperSlope()) return true;
		//last one is the function for the entire quest.
		//it will make as much progress as it needs to before the directive is cleared
		if(L12_islandWar()) return true;
		abort("Failed to execute directive: " +directive);
	}
	if(directive == "outfit3")
	{
		//we are killing the boss of the L12 war. it requires an outfit. but might also require other things.
		if(L12_finalizeWar()) return true;
		abort("Failed to execute directive: " +directive);
	}
	if(directive == "chasm")
	{
		//we should do some prep first.
		if(LX_loggingHatchet()) return true;	//no adv spent.
		pullXWhenHaveY($item[Loadstone], 1, 0);
		pullXWhenHaveY($item[Logging Hatchet], 1, 0);
		if(robot_assemble()) return true;		//switch offhand in case we pulled a loadstone
		if(L9_chasmBuild()) return true;
		abort("Failed to execute directive: " +directive);
	}
	if(directive == "machete")
	{
		//myst classes might need to forcibly switch to machete to clear out the dense lianas
		//all classes need rocket crotch to kill ghosts
		if(L11_hiddenCityZones()) return true;
		abort("Failed to execute directive: " +directive);
	}
	if(directive == "city")
	{
		//myst classes might need to forcibly switch to machete to clear out the dense lianas
		//all classes need rocket crotch to kill ghosts
		if(L11_hiddenCity()) return true;
		abort("Failed to execute directive: " +directive);
	}
	
	//while only god lobster gives XP. the rest give you energy and scrap.
	if(LX_freeCombats(true)) return true;
	
	if(LX_galaktikSubQuest()) return true;			//only if user manually set auto_doGalaktik to true this ascension
	if(LX_armorySideQuest()) return true;			//only if user manually set auto_doArmory to true this ascension
	
	//get some levels early on
	if(LX_robot_level()) return true;
	
	if(my_level() > 12)
	{
		//island access is needed to start the war
		if(LX_islandAccess()) return true;
		//we do not actually need to be wearing an outfit to do the pre outfit. so this does not go in directives
		if(L12_preOutfit()) return true;
	}
	
	
	return false;
}
