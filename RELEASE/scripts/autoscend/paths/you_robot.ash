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

boolean LM_robot()
{
	if(!in_robot())
	{
		return false;
	}
	
	
	
	abort("temporary abort for you robot. will be removed once the LM function is finished");
	return false;
}

boolean robot_top(string choice)
{
	//TOP ATTACHMENT
	//1, Pea Shooter, Deal 20 damage + 10% of your Mox, 5
	//2, Bird Cage, Allows the use of a familiar, 5
	//3, Solar Panel, Gain 1 energy after each fight, 5
	//4, Mannequin Head, Allows you to equip a hat, 15
	//5, Meat Radar, +50% Meat Drop, 30
	//6, Junk Cannon, Spend 1 Scrap to deal 100% of your Moxie in damage, 30
	//7, Tesla Blaster, Spend 1 Energy to deal 100% of your Moxie in damage, 30
	//8, Snow Blower, Spend 1 energy to deal 100% of your Muscle in Cold damage, 40
	int attachment = 2;
    int scrapcost = 40;
	if (contains_text(choice,"fam")) { attachment = 2; scrapcost = 5;}
	if (contains_text(choice,"energy")) { attachment = 3; scrapcost = 5;}
	if (contains_text(choice,"hat")) { attachment = 4; scrapcost = 15;}
	if (contains_text(choice,"cold")) { attachment = 8; scrapcost = 40;}

	if (to_int(get_property("youRobotTop"))!=attachment && my_robot_scraps() > scrapcost) {
		auto_log_info("Setting Robo Top to "+choice+", Have "+my_robot_scraps()+"left over");
		visit_url("place.php?whichplace=scrapheap&action=sh_configure");
		visit_url("choice.php?whichchoice=1445&show=top");
		visit_url("choice.php?whichchoice=1445&part=top&show=top&option=1&p="+attachment);
		cli_execute("refresh all");
		return true;
	}
	return false;
}

boolean robot_left(string choice)
{
	//LEFT ARM
	//1, Pound-O-Tron, Deal 20 damage + 10% of your Mus, 5
	//2, Reflective Shard, +3 Resistance to All Elements, 5
	//3, Metal Detector, +30% Item Drop, 5
	//4, Vice Grips, Allows you to equip a weapon, 15
	//5, Sniper Rifle, Spend 1 Scrap to deal 100% of your Mysticality in damage, 30
	//6, Junk Mace, Spend 1 Scrap to deal 100% of your Muscle in damage, 30
	//7, Camoflage Curtain, -15% Combat Rate, 30
	//8, Grease Gun, Spend 1 energy to deal 100% of your Moxie in Sleaze damage, 40
	
	int attachment = 4;
    int scrapcost = 40;
	if (contains_text(choice,"weapon")) { attachment = 4; scrapcost = 15;}
	if (contains_text(choice,"noncom")) { attachment = 7; scrapcost = 30;}


	if (to_int(get_property("youRobotLeft"))!=attachment && my_robot_scraps() > scrapcost) {
		auto_log_info("Setting Robo Left to "+choice+", Have "+my_robot_scraps()+"left over");
		visit_url("place.php?whichplace=scrapheap&action=sh_configure");
		visit_url("choice.php?whichchoice=1445&show=left");
		visit_url("choice.php?whichchoice=1445&part=left&show=left&option=1&p="+attachment);
		cli_execute("refresh all");
		return true;
	}
	return false;
}

boolean robot_right(string choice)
{
	//RIGHT ARM
	//1, Slab-O-Matic, +30 Maximum HP, 5
	//2, Junk Shield, +10 DR, +50 DA, 5
	//3, Horseshoe Magnet, +1 Scrap after each combat, 5
	//4, Omni-Claw, Allows you to equip an offhand item, 15
	//5, Mammal Prod, Spend 1 energy to deal 100% of your Myst in damage, 30
	//6, Solenoid Piston, Spend 1 energy to deal 100% of your Mus in damage, 30
	//7, Blaring Speaker, +30 ML, 30
	//8, Surplus Flamethrower, Spend 1 energy to deal 100% of your Myst in hot damage, 40
	
	int attachment = 4;
    int scrapcost = 15;
	if (contains_text(choice,"scrap")) { attachment = 3; scrapcost = 5;}
	if (contains_text(choice,"offhand")) { attachment = 4; scrapcost = 15;}
	if (contains_text(choice,"ml")) { attachment = 7; scrapcost = 39;}

	if (to_int(get_property("youRobotRight"))!=attachment && my_robot_scraps() > scrapcost) {
		auto_log_info("Setting Robot Right to "+choice+", Have "+my_robot_scraps()+"left over");
		visit_url("place.php?whichplace=scrapheap&action=sh_configure");
		visit_url("choice.php?whichchoice=1445&show=right");
		visit_url("choice.php?whichchoice=1445&part=right&show=right&option=1&p="+attachment);
		cli_execute("refresh all");
		return true;
	}
	return false;
}

boolean robot_bottom(string choice)
{
	//PROPULSION SYSTEM
	//1, Bald Tires, +10 Maximum HP, 5
	//2, Rocket Crotch, Deal 20 Hot Damage + 10% of your Myst, 5
	//3, Motorcycle Wheel, +30% Combat Initiative, 5
	//4, Robo-Legs, Allows you to equip pants, 15
	//5, Magno-Lev, +30% Item Drop, 30
	//6, Tank Treads, +50 Maximum HP, +10 DR, 30
	//7, Snowplow, Gain 1 Scrap after each fight, 30
	
	int attachment = 4;
    int scrapcost = 15;
	if (contains_text(choice,"init")) { attachment = 3; scrapcost = 5;}
	if (contains_text(choice,"pants")) { attachment = 4; scrapcost = 15;}
	if (contains_text(choice,"scrap")) { attachment = 7; scrapcost = 30;}


	if (to_int(get_property("youRobotBottom"))!=attachment && my_robot_scraps() > scrapcost) {
		auto_log_info("Setting Robot Bottom to "+choice+", Have "+my_robot_scraps()+"left over");
		visit_url("place.php?whichplace=scrapheap&action=sh_configure");
		visit_url("choice.php?whichchoice=1445&show=bottom");
		visit_url("choice.php?whichchoice=1445&part=bottom&show=bottom&option=1&p="+choice);
		cli_execute("refresh all");
		return true;
	}
	return false;
}

boolean robot_cpu(string choice)
{
	//Leverage Coprocessing 	+15 Muscle 	30 	
	//Dynamic Arcane Flux Modeling 	+15 Mysticality 	30 	
	//Upgraded Fashion Sensor 	+15 Moxie 	30 	
	//Financial Neural Net 	+20% Meat Drops 	30 	
	//Spatial Compression Functions 	+30 Maximum HP 	40 	
	//Self-Repair Routines 	Regenerate +10 HP per Adventure 	40 	
	//Weather Control Algorithms 	+2 Resistance to all elements 	40 	
	//Improved Optical Processing 	+20% Item Drops 	40 	
	//Topology Grid 	Allows you to equip shirts 	50 	
	//Overclocking 	Gain 1 Energy per fight 	50 	Your CPU redirects some waste heat back into your battery.
	//Energy	You gain 1 Energy.
	//Biomass Processing Function 	Allows use of potions 	50 	
	//Holographic Deflector Projection 	+30 Maximum HP 	50

	string upgrade = 'robot_energy';
    int energycost = 50;
	if (contains_text(choice,"energy")) { upgrade = 'robot_energy'; energycost = 50;}
	if (contains_text(choice,"potions")) { upgrade = 'robot_potions'; energycost = 50;}


	if (!contains_text(get_property("youRobotCPUUpgrades"),upgrade) && my_robot_energy()>= energycost) {
		auto_log_info("Upgrading CPU with "+upgrade);
		visit_url("place.php?whichplace=scrapheap&action=sh_configure");
		visit_url("choice.php?whichchoice=1445&show=cpus");
		visit_url("choice.php?whichchoice=1445&part=cpus&show=cpus&option=2&p="+upgrade);
		return true;
	}
	return false;
}