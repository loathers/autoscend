script "postcheese.ash";
import<cc_ascend.ash>

void handlePostAdventure()
{
	if(limit_mode() == "spelunky")
	{
		return;
	}

	if(have_effect($effect[Eldritch Attunement]) > 0)
	{
		if(last_monster() != $monster[Eldritch Tentacle])
		{
			print("Expected Tentacle, uh oh!", "red");
			return;
		}
		print("No Tentacle expected this time!", "green");
	}

	//We need to do this early, and even if postAdventure handling is done.
	if(my_path() == "The Source")
	{
		if(get_property("cc_diag_round").to_int() == 0)
		{
			monster last = last_monster();
			string temp = visit_url("main.php");
			if(last != last_monster())
			{
				print("Interrupted battle detected at post combat time", "red");
				if(have_effect($effect[Beaten Up]) > 0)
				{
					print("Post combat time caused up to be Beaten Up!", "red");
					return;
				}
				ccAdv(my_location());
				return;
			}
		}
	}

	//This has a post combat scenario, let us just handle it.
	if(last_monster() == $monster[Cake Lord])
	{
		run_choice(1);
		run_choice(1);
	}

	if((get_property("lastEncounter") == "Daily Briefing") && (cc_my_path() == "License to Adventure"))
	{
		set_property("_cc_bondBriefing", "started");
	}

	if((get_property("_villainLairProgress").to_int() < 999) && ((get_property("_villainLairColor") != "") || get_property("_villainLairColorChoiceUsed").to_boolean()) && (cc_my_path() == "License to Adventure") && (my_location() == $location[Super Villain\'s Lair]))
	{
		if(item_amount($item[Can Of Minions-Be-Gone]) > 0)
		{
			use(1, $item[Can Of Minions-Be-Gone]);
		}
	}

	if(get_property("cc_disableAdventureHandling").to_boolean())
	{
		print("Postadventure skipped by standard adventure handler.", "green");
		return;
	}

	if(!get_property("_ballInACupUsed").to_boolean() && (item_amount($item[Ball-In-A-Cup]) > 0))
	{
		use(1, $item[Ball-In-A-Cup]);
	}
	if(!get_property("_setOfJacksUsed").to_boolean() && (item_amount($item[Set of Jacks]) > 0))
	{
		use(1, $item[Set of Jacks]);
	}
	if(!get_property("_hobbyHorseUsed").to_boolean() && (item_amount($item[Handmade Hobby Horse]) > 0))
	{
		use(1, $item[Handmade Hobby Horse]);
	}
	if(!get_property("_creepyVoodooDollUsed").to_boolean() && (item_amount($item[Creepy Voodoo Doll]) > 0))
	{
		use(1, $item[Creepy Voodoo Doll]);
	}


	if((my_location() == $location[The Lower Chambers]) && (item_amount($item[[2334]Holy MacGuffin]) == 0))
	{
		print("Postadventure skipped by Ed the Undying!", "green");
		return;
	}

	ocrs_postHelper();
	if(last_monster().random_modifiers["clingy"])
	{
		print("Postadventure skipped by clingy modifier.", "green");
		return;
	}

	if(have_effect($effect[Cunctatitis]) > 0)
	{
		if((my_mp() >= 12) && cc_have_skill($skill[Disco Nap]))
		{
			use_skill(1, $skill[Disco Nap]);
		}
		else
		{
			uneffect($effect[Cunctatitis]);
		}
	}

	float regen = numeric_modifier("MP Regen Min").to_float() * 2.0;
	regen += numeric_modifier("MP Regen Max").to_float();
	regen = regen / 3.0;




	if(my_class() == $class[Avatar of Sneaky Pete])
	{
		buffMaintain($effect[All Revved Up], 25, 1, 10);
		buffMaintain($effect[Of Course It Looks Great], 55, 1, 10);
		if(cc_have_skill($skill[Throw Party]) && !get_property("_petePartyThrown").to_boolean())
		{
			int threshold = 50;
			if(!possessEquipment($item[Sneaky Pete\'s Leather Jacket]) && !possessEquipment($item[Sneaky Pete\'s Leather Jacket (Collar Popped)]))
			{
				threshold = 30;
			}
			if(my_audience() >= threshold)
			{
				use_skill(1, $skill[Throw Party]);
			}
		}
		if(cc_have_skill($skill[Incite Riot]) && !get_property("_peteRiotIncited").to_boolean())
		{
			int threshold = -50;
			if(!possessEquipment($item[Sneaky Pete\'s Leather Jacket]) && !possessEquipment($item[Sneaky Pete\'s Leather Jacket (Collar Popped)]))
			{
				threshold = -30;
			}
			if(my_audience() <= threshold)
			{
				use_skill(1, $skill[Incite Riot]);
			}
		}
	}

	if(my_path() == "Nuclear Autumn")
	{
		buffMaintain($effect[Juiced and Loose], 35, 1, 1);
		buffMaintain($effect[Hardened Sweatshirt], 35, 1, 1);
		buffMaintain($effect[Ear Winds], 35, 1, 1);
		buffMaintain($effect[Magnetized Ears], 40, 1, 1);
		buffMaintain($effect[Impeccable Coiffure], 75, 1, 1);
		buffMaintain($effect[Mind Vision], 200, 1, 1);

		buffMaintain($effect[Juiced and Loose], 75, 1, 50);
		buffMaintain($effect[Hardened Sweatshirt], 75, 1, 50);
		buffMaintain($effect[Bone Springs], 75, 1, 1);

		if((my_meat() > 5000) && ((my_turncount() >= 50) || get_property("falloutShelterChronoUsed").to_boolean()))
		{
			buffMaintain($effect[Rad-Pro Tected], 0, 1, 1);
		}
	}

	if(my_path() == "Actually Ed the Undying")
	{
		int maxBuff = max(5, 660 - my_turncount());
		if(spleen_limit() < 35)
		{
			maxBuff = min(maxBuff, spleen_limit());
		}
		if(my_mp() < 40)
		{
			maxBuff = 5;
		}
		if(my_level() < 13)
		{
			buffMaintain($effect[Prayer of Seshat], 5, 1, maxBuff);
		}
		if(my_location() == $location[The Secret Government Laboratory])
		{
			buffMaintain($effect[Wisdom of Thoth], 5, 1, maxBuff);
			buffMaintain($effect[Power of Heka], 10, 1, maxBuff);
		}
		else
		{
			buffMaintain($effect[Wisdom of Thoth], 150, 1, maxBuff);
			buffMaintain($effect[Power of Heka], 100, 1, maxBuff);
		}

		if(get_property("edPoints").to_int() <= 6)
		{
			buffMaintain($effect[Wisdom of Thoth], 5, 1, 10);
			buffMaintain($effect[Power of Heka], 10, 1, 10);
		}

		buffMaintain($effect[Hide of Sobek], 200, 1, maxBuff);
		if(my_location() == $location[Hippy Camp])
		{
			buffMaintain($effect[Hide of Sobek], 20, 1, maxBuff);
		}

		if(!($locations[Hippy Camp, The Outskirts Of Cobb\'s Knob, Pirates of the Garbage Barges, The Secret Government Laboratory] contains my_location()))
		{
			buffMaintain($effect[Bounty of Renenutet], 20, 1, maxBuff);
		}

		if((my_servant() == $servant[Priest]) && ($servant[Priest].experience < 196) && ($servant[Priest].experience >= 81))
		{
			buffMaintain($effect[Purr of the Feline], 10, 1, maxBuff);
		}
		if(my_servant() == $servant[Cat])
		{
			buffMaintain($effect[Purr of the Feline], 10, 1, maxBuff);
		}
		if((my_servant() == $servant[Belly-Dancer]) && ($servant[Belly-Dancer].experience < 196) && ($servant[Belly-Dancer].experience >= 81))
		{
			buffMaintain($effect[Purr of the Feline], 10, 1, maxBuff);
		}

		foreach ef in $effects[Prayer Of Seshat, Wisdom Of Thoth, Hide Of Sobek, Bounty Of Renenutet]
		{
			if(my_mp() > 100)
			{
				buffMaintain(ef, 20, 1, maxBuff);
			}
		}

		if((my_level() < 13) && (my_level() > 3) && !get_property("cc_needLegs").to_boolean() && (get_property("edPoints").to_int() > 15) && !($locations[Hippy Camp, The Outskirts Of Cobb\'s Knob] contains my_location()))
		{
			buffMaintain($effect[Blessing of Serqet], 50, 1, 1);
		}

		if((my_mp() + 100) < my_maxmp())
		{
			acquireMP(100, false);
		}
		return;
	}

	skill libram = preferredLibram();

	if(my_adventures() > 20)
	{
		buffMaintain($effect[Merry Smithsness], 0, 1, 10);
	}

	#Deal with Poison, (should do all of them actually)
	if((have_effect($effect[Really Quite Poisoned]) > 0) || (have_effect($effect[A Little Bit Poisoned]) > 0) || (have_effect($effect[Majorly Poisoned]) > 0))
	{
		if((my_mp() > 12) && cc_have_skill($skill[Disco Nap]))
		{
			use_skill(1, $skill[Disco Nap]);
		}
		else if(isGeneralStoreAvailable())
		{
			buyUpTo(1, $item[Anti-Anti-Antidote], 30);
			if(cc_my_path() != "G-Lover")
			{
				use(1, $item[Anti-Anti-Antidote]);
			}
		}
	}

	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		if(!uneffect($effect[Temporary Amnesia]))
		{
			abort("Could not remove temporary amnesia and now I suckzor.");
		}
	}

	if((my_class() == $class[Turtle Tamer]) && guild_store_available())
	{
		buffMaintain($effect[Eau de Tortue], 0, 1, 1);
	}

	if((monster_level_adjustment() > 140) && !get_property("kingLiberated").to_boolean())
	{
		buffMaintain($effect[Butt-Rock Hair], 0, 1, 1);
		buffMaintain($effect[Go Get \'Em\, Tiger!], 0, 1, 1);
	}

	if(my_path() == "Community Service")
	{
		if(cc_have_skill($skill[Summon BRICKOs]) && (get_property("_brickoEyeSummons").to_int() < 3))
		{
			libram = $skill[Summon BRICKOs];
		}
		else if(cc_have_skill($skill[Summon Taffy]))
		{
			libram = $skill[Summon Taffy];
		}

		int missing = (my_maxmp() - my_mp()) / 15;
		int casts = (my_soulsauce() - 25) / 5;
		if(casts < 0)
		{
			casts = 0;
		}
		int regen = casts;
		if(casts > missing)
		{
			regen = missing;
		}
		if(regen > 0)
		{
			use_skill(regen, $skill[Soul Food]);
		}

		buffMaintain($effect[Inscrutable Gaze], 30, 1, 1);
		buffMaintain($effect[Big], 50, 1, 1);

		boolean [skill] toCast = $skills[Acquire Rhinestones, Advanced Cocktailcrafting, Advanced Saucecrafting, Communism!, Grab a Cold One, Lunch Break, Pastamastery, Perfect Freeze, Request Sandwich, Spaghetti Breakfast, Summon Alice\'s Army Cards, Summon Carrot, Summon Confiscated Things, Summon Crimbo Candy, Summon Geeky Gifts, Summon Hilarious Objects, Summon Holiday Fun!, Summon Kokomo Resort Pass, Summon Tasteful Items];

		foreach sk in toCast
		{
			if(is_unrestricted(sk) && cc_have_skill(sk) && (my_mp() >= mp_cost(sk)))
			{
				use_skill(1, sk);
			}
		}

		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 15) && (mp_cost(libram) < 75))
		{
			use_skill(1, libram);
		}
		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 175))
		{
			use_skill(1, libram);
		}

		return;
	}

	if(cc_my_path() == "The Source")
	{
		if((get_property("sourceInterval").to_int() > 0) && (get_property("sourceInterval").to_int() <= 600) && (get_property("sourceAgentsDefeated").to_int() >= 9))
		{
			if((have_effect($effect[Song of Bravado]) == 0) && (have_effect($effect[Song of Sauce]) == 0) && (have_effect($effect[Song of Slowness]) == 0) && (have_effect($effect[Song of the North]) == 0))
			{
				buffMaintain($effect[Song of Starch], 250, 1, 1);
			}
		}
	}

	if(my_class() == $class[Sauceror])
	{
		if((my_level() >= 6) && (have_effect($effect[[1458]Blood Sugar Sauce Magic]) == 0) && cc_have_skill($skill[Blood Sugar Sauce Magic]) && !in_hardcore())
		{
			use_skill(1, $skill[Blood Sugar Sauce Magic]);
		}

		if(((my_level() <= 8) && (my_soulsauce() >= 92)) || (my_soulsauce() >= 100))
		{
			use_skill(1, $skill[Soul Rotation]);
		}
		int missing = (my_maxmp() - my_mp()) / 15;
		int casts = (my_soulsauce() - 25) / 5;
		if(casts < 0)
		{
			casts = 0;
		}
		int regen = casts;
		if(casts > missing)
		{
			regen = missing;
		}
		if(regen > 0)
		{
			use_skill(regen, $skill[Soul Food]);
		}
	}

	if((monster_level_adjustment() > 120) && ((my_hp() * 10) < (my_maxhp() * 8)) && (my_mp() >= 20))
	{
		useCocoon();
	}

	if((my_maxhp() > 200) && (my_hp() < 80) && (my_mp() > 25))
	{
		useCocoon();
	}


	if(cc_have_skill($skill[Thunderheart]) && (my_thunder() >= 90) && ((my_turncount() - get_property("cc_lastthunderturn").to_int()) >= 9))
	{
		use_skill(1, $skill[Thunderheart]);
	}


	effect awolDesired = awol_walkBuff();
	if(awolDesired != $effect[none])
	{
		if(!get_property("kingLiberated").to_boolean())
		{
			int awolMP = 85;
			if(my_class() == $class[Beanslinger])
			{
				awolMP = 95;
			}
			buffMaintain(awolDesired, awolMP, 1, 20);
		}
		else
		{
			buffMaintain(awolDesired, 120, 1, 1);
		}
	}

	if(cc_have_skill($skill[Demand Sandwich]) && (my_mp() > 85) && (my_level() >= 9) && (get_property("_demandSandwich").to_int() < 3))
	{
		use_skill(1, $skill[Demand Sandwich]);
	}

	if(cc_have_skill($skill[Summon Smithsness]) && (my_mp() > 20))
	{
		use_skill(1, $skill[Summon Smithsness]);
	}

	# This is the list of castables that all MP sequences will use.
	boolean [skill] toCast = $skills[Acquire Rhinestones, Advanced Cocktailcrafting, Advanced Saucecrafting, Communism!, Grab a Cold One, Lunch Break, Pastamastery, Perfect Freeze, Request Sandwich, Spaghetti Breakfast, Summon Alice\'s Army Cards, Summon Carrot, Summon Confiscated Things, Summon Crimbo Candy, Summon Geeky Gifts, Summon Hilarious Objects, Summon Holiday Fun!, Summon Kokomo Resort Pass, Summon Tasteful Items];

	if(my_maxmp() < 50)
	{
		buffMaintain($effect[Power Ballad of the Arrowsmith], 7, 1, 5);
		buffMaintain(whatStatSmile(), 15, 1, 10);
		buffMaintain($effect[Leash of Linguini], 20, 1, 10);
		if(regen > 10.0)
		{
			buffMaintain($effect[Empathy], 25, 1, 10);
		}
		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 25))
		{
			use_skill(1, libram);
		}

		foreach sk in toCast
		{
			if(is_unrestricted(sk) && cc_have_skill(sk) && ((my_mp() - 40) >= mp_cost(sk)))
			{
				use_skill(1, sk);
			}
		}

		if(regen > 10.0)
		{
			buffMaintain($effect[Rage of the Reindeer], 30, 1, 10);
		}
		buffMaintain($effect[Astral Shell], 35, 1, 10);
		buffMaintain($effect[Elemental Saucesphere], 30, 1, 10);

		if(my_location() != $location[The Broodling Grounds])
		{
			buffMaintain($effect[Spiky Shell], 20, 1, 10);
			buffMaintain($effect[Scarysauce], 25, 1, 10);
		}
		buffMaintain($effect[Ghostly Shell], 25, 1, 10);
		buffMaintain($effect[Walberg\'s Dim Bulb], 35, 1, 10);
#		buffMaintain($effect[Springy Fusilli], 40, 1, 10);
		buffMaintain($effect[Blubbered Up], 30, 1, 10);
#		buffMaintain($effect[Tenacity of the Snapper], 30, 1, 10);
		buffMaintain($effect[Reptilian Fortitude], 30, 1, 10);
		if(regen > 10.0)
		{
			buffMaintain($effect[Disco Fever], 40, 1, 10);
		}
		buffMaintain($effect[Saucemastery], 25, 1, 4);
		buffMaintain($effect[Pasta Oneness], 25, 1, 4);

		if(regen > 7.5)
		{
			buffMaintain($effect[Seal Clubbing Frenzy], 10, 3, 4);
			buffMaintain($effect[Patience of the Tortoise], 10, 3, 4);
			buffMaintain($effect[Mariachi Mood], 25, 1, 4);
			buffMaintain($effect[Disco State of Mind], 25, 1, 4);
		}
	}
	else if(my_maxmp() < 80)
	{
		buffMaintain($effect[Power Ballad of the Arrowsmith], 7, 1, 5);
		buffMaintain(whatStatSmile(), 20, 1, 10);
		buffMaintain($effect[Leash of Linguini], 30, 1, 10);
		if(regen > 10.0)
		{
			buffMaintain($effect[Empathy], 35, 1, 10);
		}

		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 32))
		{
			use_skill(1, libram);
		}

		foreach sk in toCast
		{
			if(is_unrestricted(sk) && cc_have_skill(sk) && ((my_mp() - 50) >= mp_cost(sk)))
			{
				use_skill(1, sk);
			}
		}
#		buffMaintain($effect[Prayer of Seshat], 5, 1, 10);

		if(regen > 10.0)
		{
			buffMaintain($effect[Rage of the Reindeer], 40, 1, 10);
		}
		buffMaintain($effect[Astral Shell], 50, 1, 10);
		buffMaintain($effect[Elemental Saucesphere], 40, 1, 10);
		if(my_location() != $location[The Broodling Grounds])
		{
			buffMaintain($effect[Spiky Shell], 40, 1, 10);
			buffMaintain($effect[Scarysauce], 40, 1, 10);
#			buffMaintain($effect[Jalape&ntilde;o Saucesphere], 50, 1, 10);
		}
		buffMaintain($effect[Ghostly Shell], 45, 1, 10);
		if(my_class() == $class[Turtle Tamer])
		{
			buffMaintain($effect[Disdain of the Storm Tortoise], 60, 1, 10);
		}
		buffMaintain($effect[Walberg\'s Dim Bulb], 50, 1, 10);
#		buffMaintain($effect[Springy Fusilli], 60, 1, 10);
#		buffMaintain($effect[Flimsy Shield of the Pastalord], 70, 1, 10);
		buffMaintain($effect[Blubbered Up], 60, 1, 10);
#		buffMaintain($effect[Tenacity of the Snapper], 50, 1, 10);
		buffMaintain($effect[Reptilian Fortitude], 50, 1, 10);
		if(regen > 10.0)
		{
			buffMaintain($effect[Disco Fever], 60, 1, 10);
		}
		buffMaintain($effect[Saucemastery], 50, 3, 4);
		buffMaintain($effect[Pasta Oneness], 50, 3, 4);
		if(regen > 8.2)
		{
			buffMaintain($effect[Seal Clubbing Frenzy], 25, 3, 4);
			buffMaintain($effect[Patience of the Tortoise], 25, 3, 4);
			buffMaintain($effect[Mariachi Mood], 50, 3, 4);
			buffMaintain($effect[Disco State of Mind], 50, 3, 4);
		}
	}
	else if(my_maxmp() < 170)
	{
		if(my_level() < 13)
		{
			buffMaintain(whatStatSmile(), 40, 1, 10);
		}

		buffMaintain($effect[Leash of Linguini], 35, 1, 10);
		if(regen > 4.0)
		{
			buffMaintain($effect[Empathy], 50, 1, 10);
		}

		foreach sk in toCast
		{
			if(is_unrestricted(sk) && cc_have_skill(sk) && ((my_mp() - 90) >= mp_cost(sk)))
			{
				use_skill(1, sk);
			}
		}

		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 40))
		{
			use_skill(1, libram);
		}

#		buffMaintain($effect[Prayer of Seshat], 5, 1, 10);
		buffMaintain($effect[Big], 100, 1, 10);
		buffMaintain($effect[Rage of the Reindeer], 80, 1, 10);
		buffMaintain($effect[Astral Shell], 80, 1, 10);
		buffMaintain($effect[Elemental Saucesphere], 120, 1, 10);
		if(my_location() != $location[The Broodling Grounds])
		{
			buffMaintain($effect[Spiky Shell], 80, 1, 10);
			buffMaintain($effect[Scarysauce], 120, 1, 10);
#			buffMaintain($effect[Jalape&ntilde;o Saucesphere], 60, 1, 10);
		}
		buffMaintain($effect[Ghostly Shell], 80, 1, 10);
		if(my_class() == $class[Turtle Tamer])
		{
			buffMaintain($effect[Disdain of the Storm Tortoise], 80, 1, 10);
		}
		buffMaintain($effect[Walberg\'s Dim Bulb], 80, 1, 10);
		buffMaintain($effect[Springy Fusilli], 80, 1, 10);
#		buffMaintain($effect[Flimsy Shield of the Pastalord], 80, 1, 10);
		buffMaintain($effect[Blubbered Up], 120, 1, 10);
#		buffMaintain($effect[Tenacity of the Snapper], 80, 1, 10);
		if(regen > 10.0)
		{
			buffMaintain($effect[Reptilian Fortitude], 150, 1, 10);
			buffMaintain($effect[Disco Fever], 80, 1, 10);
			buffMaintain($effect[Seal Clubbing Frenzy], 50, 5, 4);
			buffMaintain($effect[Patience of the Tortoise], 50, 5, 4);
		}
#		buffMaintain($effect[Rotten Memories], 100, 1, 10);

		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 80))
		{
			use_skill(1, libram);
		}

		if(my_mp() > 80)
		{
			if((my_mp() > 95) && (my_maxhp() > my_hp()))
			{
				useCocoon();
			}
			buffMaintain($effect[Takin\' It Greasy], 50, 1, 5);
			buffMaintain($effect[Intimidating Mien], 50, 1, 5);
		}
	}
	else
	{
		boolean didOutfit = false;
		if((my_basestat($stat[mysticality]) >= 200) && (my_buffedstat($stat[mysticality]) >= 200) && (get_property("kingLiberated") != "false") && (item_amount($item[Wand of Oscus]) > 0) && (item_amount($item[Oscus\'s Dumpster Waders]) > 0) && (item_amount($item[Oscus\'s Pelt]) > 0))
		{
			cli_execute("outfit save Backup");
			#Using the cli command may not upgrade our stats if our max mp drops
			#Not sure if the ASH command actually handles it properly, we'll see.
			#cli_execute("outfit Vile Vagrant Vestments");
			#outfit does not... damn it.
			if(!outfit("Vile Vagrant Vestments"))
			{
				print("Could not wear Vile Vagrant Outfit for some raisin", "red");
			}
			didOutfit = true;
		}

		boolean doML = true;
		if(get_property("kingLiberated").to_boolean())
		{
			doML = false;
		}
		if((equipped_amount($item[Space Trip Safety Headphones]) > 0) || (equipped_amount($item[Red Badge]) > 0))
		{
			doML = false;
		}
		if(((get_property("flyeredML").to_int() > 9999) || get_property("cc_hippyInstead").to_boolean() || (get_property("cc_war") == "finished") || (get_property("sidequestArenaCompleted") != "none")) && (my_level() >= 13))
		{
			doML = false;
			#change_mcd(0);
		}
		if((my_mp() > 150) && (my_maxhp() > 300) && (my_hp() < 140))
		{
			useCocoon();
		}
		if((my_mp() > 100) && (my_maxhp() > 500) && (my_hp() < 250))
		{
			useCocoon();
		}
		if((my_mp() > 75) && (my_maxhp() > 500) && (my_hp() < 200))
		{
			useCocoon();
		}
		if((my_mp() > 75) && (my_maxhp() > 700) && (my_hp() < 300))
		{
			useCocoon();
		}
		if((my_mp() > 75) && ((my_hp() == 0) || ((my_maxhp()/my_hp()) > 3)))
		{
			useCocoon();
		}

		buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 250, 1, 10);

		if(my_level() < 13)
		{
			buffMaintain(whatStatSmile(), 40, 1, 10);
		}

		buffMaintain($effect[Empathy], 50, 1, 10);
		buffMaintain($effect[Leash of Linguini], 35, 1, 10);

		foreach sk in toCast
		{
			if(is_unrestricted(sk) && cc_have_skill(sk) && ((my_mp() - 85) >= mp_cost(sk)))
			{
				use_skill(1, sk);
			}
		}

		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 32))
		{
			print("Mymp: " + my_mp() + " of " + my_maxmp() + " and cost: " + mp_cost(libram), "blue");
			boolean temp = false;
			try
			{
				#if(use_skill(1, libram)) {}
				temp = use_skill(1, libram);
			}
			finally
			{
				if(!temp)
				{
					print("No longer have enough MP and failed.", "red");
					print("Mymp: " + my_mp() + " of " + my_maxmp() + " and cost: " + mp_cost(libram), "blue");
				}
			}
		}

#		buffMaintain($effect[Prayer of Seshat], 5, 1, 10);

		buffMaintain($effect[Singer\'s Faithful Ocelot], 280, 1, 10);
		if(doML)
		{
			if((monster_level_adjustment() + (2 * my_level())) <= 150)
			{
				buffMaintain($effect[Ur-Kel\'s Aria of Annoyance], 80, 1, 10);
			}
			if((monster_level_adjustment() + 10) <= 150)
			{
				buffMaintain($effect[Drescher\'s Annoying Noise], 80, 1, 10);
			}
			if((monster_level_adjustment() + 10) <= 150)
			{
				buffMaintain($effect[Pride of the Puffin], 80, 1, 10);
			}
		}
		buffMaintain($effect[Big], 100, 1, 10);
		buffMaintain($effect[Rage of the Reindeer], 80, 1, 10);
		buffMaintain($effect[Astral Shell], 80, 1, 10);
		buffMaintain($effect[Elemental Saucesphere], 120, 1, 10);
		if(my_location() != $location[The Broodling Grounds])
		{
			buffMaintain($effect[Spiky Shell], 120, 1, 10);
			buffMaintain($effect[Scarysauce], 160, 1, 10);
			buffMaintain($effect[Jalape&ntilde;o Saucesphere], 225, 1, 10);
		}
		buffMaintain($effect[Ghostly Shell], 80, 1, 10);
		if(regen > 15.0)
		{
			buffMaintain($effect[Disdain of the War Snapper], 200, 1, 10);
		}
		buffMaintain($effect[Walberg\'s Dim Bulb], 80, 1, 10);
		buffMaintain($effect[Springy Fusilli], 80, 1, 10);
		if(regen > 15.0)
		{
			buffMaintain($effect[Flimsy Shield of the Pastalord], 180, 1, 10);
		}
		buffMaintain($effect[Blubbered Up], 200, 1, 10);
		if(my_level() < 13)
		{
			buffMaintain($effect[Aloysius\' Antiphon of Aptitude], 150, 1, 10);
		}
		buffMaintain($effect[Tenacity of the Snapper], 200, 1, 10);
		buffMaintain($effect[Reptilian Fortitude], 200, 1, 10);
		if(regen > 20.0)
		{
			buffMaintain($effect[Antibiotic Saucesphere], 350, 1, 10);
		}
		if(regen > 5.0)
		{
			buffMaintain($effect[Disco Fever], 120, 1, 10);
		}
		if(my_primestat() == $stat[Muscle])
		{
			buffMaintain($effect[Seal Clubbing Frenzy], 200, 5, 4);
			buffMaintain($effect[Patience of the Tortoise], 200, 5, 4);
		}
		if(my_primestat() == $stat[Moxie])
		{
			buffMaintain($effect[Mariachi Mood], 200, 5, 4);
			buffMaintain($effect[Disco State of Mind], 200, 5, 4);
		}
		if(my_primestat() == $stat[Mysticality])
		{
			buffMaintain($effect[Saucemastery], 200, 5, 4);
			buffMaintain($effect[Pasta Oneness], 200, 5, 4);
		}
		if(familiar_weight(my_familiar()) < 20)
		{
			buffMaintain($effect[Curiosity of Br\'er Tarrypin], 50, 1, 2);
		}
		buffMaintain($effect[Jingle Jangle Jingle], 120, 1, 2);
		buffMaintain($effect[A Few Extra Pounds], 200, 1, 2);
		buffMaintain($effect[Boon of the War Snapper], 200, 1, 5);
		buffMaintain($effect[Boon of She-Who-Was], 200, 1, 5);
		buffMaintain($effect[Boon of the Storm Tortoise], 200, 1, 5);

		buffMaintain($effect[Ruthlessly Efficient], 50, 1, 5);
		buffMaintain($effect[Mathematically Precise], 150, 1, 5);
#		buffMaintain($effect[Rotten Memories], 150, 1, 10);

		if(get_property("kingLiberated").to_boolean())
		{
			if((cc_have_skill($skill[Summon Rad Libs])) && (my_mp() > 6))
			{
				use_skill(3, $skill[Summon Rad Libs]);
			}
			if((cc_have_skill($skill[Summon Geeky Gifts])) && (my_mp() > 5))
			{
				use_skill(1, $skill[Summon Geeky Gifts]);
			}
			if((cc_have_skill($skill[Summon Stickers])) && (my_mp() > 6))
			{
				use_skill(3, $skill[Summon Stickers]);
			}
			if((cc_have_skill($skill[Summon Sugar Sheets])) && (my_mp() > 6))
			{
				use_skill(3, $skill[Summon Sugar Sheets]);
			}
			if(cc_have_skill($skill[Rainbow Gravitation]))
			{
				use_skill(3, $skill[Rainbow Gravitation]);
			}
		}

		if((libram != $skill[none]) && ((my_mp() - mp_cost(libram)) > 80))
		{
			use_skill(1, libram);
		}

		if(my_mp() > 80)
		{
			if((my_mp() > 95) && (my_maxhp() > my_hp()))
			{
				useCocoon();
			}
			buffMaintain($effect[Takin\' It Greasy], 50, 1, 5);
			buffMaintain($effect[Intimidating Mien], 50, 1, 5);
		}

		if(didOutfit)
		{
			cli_execute("outfit Backup");
		}
	}

	if(my_class() == $class[Pastamancer])
	{
		thrall cur = my_thrall();
		thrall consider = $thrall[none];

/*							Cost		L1				L5				L10
		Vampieroghi			12			1-2 (Dmg, Heal)	Dispel Neg		+60 Max HP
		Vermincelli			30			2 MP Regen		Dmg, Poison		+30 Max MP
		Angel Hair Wisp		60			5% init			Block Crits		Block
(Undead)Elbow Maraconi		100			Equalize Mus	+2 Weapon Dmg	+10% crit
		Penne Dreadful		150			Equalize Mox	Jump Delevel	DR + 10
		Spaghetti Elemental	150			+Stats Ceil(/3)	Block First Att	+5 spell dmg
		Lasagmbie			200			20+2 Meat		Spooky Dmg		+10 spooky spell dmg
		Spice Ghost			250			10+1 Item		Spices			Stun Increase
*/

		if((my_mp() >= (1.2 * mp_cost($skill[Bind Vermincelli]))) && (cur == $thrall[none]) && cc_have_skill($skill[Bind Vermincelli]))
		{
			consider = $thrall[Vermincelli];
		}
		if((my_mp() >= (1.2 * mp_cost($skill[Bind Spice Ghost]))) && cc_have_skill($skill[Bind Spice Ghost]) && (my_daycount() > 1) && (numeric_modifier("MP Regen Min").to_int() > 9))
		{
			consider = $thrall[Spice Ghost];
		}

		if((consider != cur) && (consider != $thrall[none]))
		{
			skill toEquip = to_skill("Bind " + consider);
			if(toEquip != $skill[none])
			{
				if(my_mp() >= mp_cost(toEquip))
				{
					use_skill(1, toEquip);
				}
			}
			else
			{
				print("Thrall handler error. Could not generate appropriate skill.", "red");
			}
		}
	}

	if(get_property("cc_cubeItems").to_boolean() && (item_amount($item[Ring Of Detect Boring Doors]) == 1) && (item_amount($item[Eleven-Foot Pole]) == 1) && (item_amount($item[Pick-O-Matic Lockpicks]) == 1))
	{
		set_property("cc_cubeItems", false);
	}

	if(!get_property("kingLiberated").to_boolean())
	{
		if((my_daycount() == 1) && (my_bjorned_familiar() != $familiar[grim brother]) && (get_property("_grimFairyTaleDropsCrown").to_int() == 0) && (have_familiar($familiar[grim brother])) && (equipped_item($slot[back]) == $item[Buddy Bjorn]) && (my_familiar() != $familiar[Grim Brother]))
		{
			bjornify_familiar($familiar[grim brother]);
		}
		if((my_bjorned_familiar() == $familiar[grimstone golem]) && (get_property("_grimstoneMaskDropsCrown") == 1) && have_familiar($familiar[El Vibrato Megadrone]))
		{
			bjornify_familiar($familiar[el vibrato megadrone]);
		}
		if((my_bjorned_familiar() == $familiar[grim brother]) && (get_property("_grimFairyTaleDropsCrown").to_int() >= 1))
		{
			bjornify_familiar($familiar[el vibrato megadrone]);
		}
	}

	if(my_path() == "Heavy Rains")
	{
		print("Post adventure done: Thunder: " + my_thunder() + " Rain: " + my_rain() + " Lightning: " + my_lightning(), "green");
	}

	if((item_amount($item[The Big Book of Pirate Insults]) > 0) && ((my_location() == $location[Barrrney\'s Barrr]) || (my_location() == $location[The Obligatory Pirate\'s Cove])))
	{
		print("Have " + numPirateInsults() + " insults.", "green");
	}

	if(my_location() == $location[The Broodling Grounds])
	{
		print("Have " + item_amount($item[Hellseal Brain]) + " brain(s).", "green");
		print("Have " + item_amount($item[Hellseal Hide]) + " hide(s).", "green");
		print("Have " + item_amount($item[Hellseal Sinew]) + " sinew(s).", "green");
	}

	if((my_location() == $location[The Hidden Bowling Alley]) && get_property("kingLiberated").to_boolean())
	{
		if(item_amount($item[Bowling Ball]) > 0)
		{
			put_closet(item_amount($item[Bowling Ball]), $item[Bowling Ball]);
		}
	}

	if((my_level() < 13) && !get_property("kingLiberated").to_boolean() && (my_meat() > 7500))
	{
		if(item_amount($item[pulled red taffy]) >= 6)
		{
			buffMaintain($effect[Cinnamon Challenger], 0, 6, 10);
		}
		if(item_amount($item[pulled orange taffy]) >= 6)
		{
			buffMaintain($effect[Orange Crusher], 0, 6, 10);
		}
		if(item_amount($item[pulled violet taffy]) >= 6)
		{
			buffMaintain($effect[Purple Reign], 0, 6, 10);
		}

		buffMaintain($effect[Gummi-Grin], 0, 1, 1);
		buffMaintain($effect[Strong Resolve], 0, 1, 1);
		buffMaintain($effect[Irresistible Resolve], 0, 1, 1);
		buffMaintain($effect[Brilliant Resolve], 0, 1, 1);
		buffMaintain($effect[From Nantucket], 0, 1, 1);
		buffMaintain($effect[Squatting and Thrusting], 0, 1, 1);
		buffMaintain($effect[You Read the Manual], 0, 1, 1);
		buyableMaintain($item[Hair Spray], 1, 200, my_class() != $class[Turtle Tamer]);
		buyableMaintain($item[Blood of the Wereseal], 1, 3500, (monster_level_adjustment() > 135));
		buyableMaintain($item[Ben-gal&trade; Balm], 1, 200);
	}

	buyableMaintain($item[Turtle Pheromones], 1, 800, my_class() == $class[Turtle Tamer]);

	if((get_property("cc_beatenUpCount").to_int() <= 10) && (have_effect($effect[Beaten Up]) > 0) && (my_mp() >= mp_cost($skill[Tongue of the Walrus])) && cc_have_skill($skill[Tongue of the Walrus]))
	{
		print("Owwie, was beaten up but trying to recover", "red");
		if(my_location() == $location[The X-32-F Combat Training Snowman])
		{
			print("At the snojo, let's not keep going there and dying....", "red");
			set_property("_snojoFreeFights", 10);
		}
		set_property("cc_beatenUpCount", get_property("cc_beatenUpCount").to_int() + 1);
		use_skill(1, $skill[Tongue of the Walrus]);
	}


	# We only do this in aftercore because we don't want a spiralling death loop in-run.
	if(get_property("kingLiberated").to_boolean() && (have_effect($effect[Beaten Up]) > 0) && (my_mp() >= mp_cost($skill[Tongue of the Walrus])) && cc_have_skill($skill[Tongue of the Walrus]))
	{
		print("Owwie, was beaten up but trying to recover", "red");
		use_skill(1, $skill[Tongue of the Walrus]);
	}

	#Should we create a separate function to track these? How many are we going to track?
	if((last_monster() == $monster[Writing Desk]) && (get_property("lastEncounter") == $monster[Writing Desk]) && (have_effect($effect[Beaten Up]) == 0))
	{
		print("Fought " + get_property("writingDesksDefeated") + " writing desks.", "blue");
	}
	if((last_monster() == $monster[Gaudy Pirate]) && (get_property("lastEncounter") == $monster[Gaudy Pirate]) && (have_effect($effect[Beaten Up]) == 0))
	{
		set_property("cc_gaudypiratecount", "" + (get_property("cc_gaudypiratecount").to_int() + 1));
		print("Fought " + get_property("cc_gaudypiratecount") + " gaudy pirates.", "blue");
	}
	if((last_monster() == $monster[Modern Zmobie]) && (get_property("lastEncounter") == $monster[Modern Zmobie]) && (have_effect($effect[Beaten Up]) == 0))
	{
		set_property("cc_modernzmobiecount", "" + (get_property("cc_modernzmobiecount").to_int() + 1));
		print("Fought " + get_property("cc_modernzmobiecount") + " modern zmobies.", "blue");
	}

	if(have_effect($effect[Disavowed]) > 0)
	{
		if(get_property("_cc_bondBriefing") != "finished")
		{
			set_property("_cc_bondBriefing", "started");
		}
		if(cc_have_skill($skill[Disco Nap]) && (my_mp() > mp_cost($skill[Disco Nap])))
		{
			print("We have been disavowed...", "red");
			use_skill(1, $skill[Disco Nap]);
		}
		else
		{
			abort("We have been disavowed...");
		}
	}

	set_property("cc_combatDirective", "");
	set_property("cc_digitizeDirective", "");

	if(have_effect($effect[Beaten Up]) > 0)
	{
		set_property("cc_beatenUpCount", get_property("cc_beatenUpCount").to_int() + 1);
	}

	print("Post Adventure done, beep.", "purple");
}

void main()
{
	handlePostAdventure();
}
