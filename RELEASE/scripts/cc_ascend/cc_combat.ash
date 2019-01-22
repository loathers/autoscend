script "cc_combat.ash"

monster ocrs_helper(string page);
void awol_helper(string page);
string ccsJunkyard(int round, string opp, string text);
string cc_edCombatHandler(int round, string opp, string text);
string cc_combatHandler(int round, string opp, string text);

boolean registerCombat(string action);
boolean registerCombat(skill sk);
boolean registerCombat(item it);
boolean containsCombat(string action);
boolean containsCombat(skill sk);
boolean containsCombat(item it);

/*
*	Advance combat round, nothing happens.
*	/goto fight.php?action=useitem&whichitem=1
*
*	Advance combat round, stuff happens: No longer works 21/5/2018
*	/goto fight.php?action=skill&whichskill=$1
*/

string cc_combatHandler(int round, string opp, string text)
{
	#print("cc_combatHandler: " + round, "brown");
	#Yes, round 0, really.
	monster enemy = to_monster(opp);
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	int damageReceived = 0;
	if(round == 0)
	{
		print("cc_combatHandler: " + round, "brown");

		if(enemy == $monster[Government Agent])
		{
			set_property("_portscanPending", false);
		}

		set_property("cc_combatHandler", "");
		set_property("cc_funCombatHandler", "");
		set_property("cc_funPrefix", "");
		set_property("cc_combatHandlerThunderBird", "0");
		set_property("cc_combatHandlerFingernailClippers", "0");
		set_property("cc_combatHP", my_hp());

/*
		if(my_location() == $location[The Deep Machine Tunnels])
		{
			if(!($monsters[Perceiver of Sensations, Performer of Actions, Thinker of Thoughts] contains enemy))
			{
				print("In The Deep Machine Tunnels and did not encounter expected monster....", "red");
				//Digitize happens first, yay for someone asking!
				//We need to remove Corresponding Counter.
				if(isOverdueDigitize())
				{
					set_property("_sourceTerminalDigitizeMonsterCount", get_property("_sourceTerminalDigitizeMonsterCount").to_int() + 1);
					print("Looks like a digitize monster, adjusting monster count but can not restore tracker", "red");
				}
				else if(isExpectingArrow() || isOverdueArrow())
				{
					print("Probably an arrow encounter... trying to adjust...", "red");
					if(to_monster(get_property("romanticTarget")) == enemy)
					{
						if(get_property("_romanticFightsLeft").to_int() == 0)
						{
							print("Have a romantic target but no fights left... can not fix wanderers", "red");
						}
						else
						{
							set_property("_romanticFightsLeft", get_property("_romanticFightsLeft").to_int() - 1);
							print("Attempted to decrement romantic fights left, can not restore counter.", "red");
						}
					}
					else
					{
						print("Not an arrow encounter... can not fix wanderers...", "red");
					}
				}
			}
		}
*/
	}
	else
	{
		damageReceived = get_property("cc_combatHP").to_int() - my_hp();
		set_property("cc_combatHP", my_hp());
	}

	set_property("cc_diag_round", round);

	if(get_property("cc_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	if(my_path() == "One Crazy Random Summer")
	{
		enemy = ocrs_helper(text);
		enemy = last_monster();
	}
	if(my_path() == "Avatar of West of Loathing")
	{
		awol_helper(text);
	}

	phylum type = monster_phylum(enemy);
	phylum current = to_phylum(get_property("dnaSyringe"));

	string combatState = get_property("cc_combatHandler");
	int thunderBirdsLeft = get_property("cc_combatHandlerThunderBird").to_int();
	int fingernailClippersLeft = get_property("cc_combatHandlerFingernailClippers").to_int();

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int mcd = monster_level_adjustment();

	boolean doBanisher = !get_property("kingLiberated").to_boolean();

	int majora = -1;
	if(my_path() == "Disguises Delimit")
	{
		matcher maskMatch = create_matcher("mask(\\d+).png", text);
		if(maskMatch.find())
		{
			majora = maskMatch.group(1).to_int();
			if(round == 0)
			{
				print("Found mask: " + majora, "green");
			}
		}
		if((majora == 7) && !contains_text(combatState, "(swap mask)"))
		{
			if(my_mp() > mp_cost($skill[Swap Mask]))
			{
				set_property("cc_combatHandler", combatState + "(swap mask)");
				return "skill " + $skill[Swap Mask];
			}
		}
		if(majora == 3)
		{
//			if((round > 10) && (my_mp() > mp_cost($skill[Swap Mask])))
//			{
//				return "skill " + $skill[Swap Mask];
//			}
			if(canSurvive(1.5))
			{
				return "attack with weapon";
			}
			abort("May not be able to survive combat. Is swapping protest mask still not allowing us to do anything?");
		}
		if(my_mask() == "protest mask")
		{
			if(my_mp() > mp_cost($skill[Swap Mask]))
			{
				return "skill " + $skill[Swap Mask];
			}
		}
	}

	if(get_property("cc_combatDirective") != "")
	{
		string[int] actions = split_string(get_property("cc_combatDirective"), ";");
		int idx = 0;
		if(round == 0)
		{
			if(actions[0] != "start")
			{
				set_property("cc_combatDirective", "");
				idx = -1;
			}
			else
			{
				idx = 1;
			}
		}
		if(idx >= 0)
		{
			string doThis = actions[idx];
			while(contains_text(doThis, "(") && contains_text(doThis, ")") && (idx < count(actions)))
			{
				set_property("cc_combatHandler", get_property("cc_combatHandler") + doThis);
				idx++;
				if(idx >= count(actions))
				{
					break;
				}
				doThis = actions[idx];
			}
			string restore = "";
			for(int i=idx+1; i<count(actions); i++)
			{
				restore += actions[i];
				if((i+1) < count(actions))
				{
					restore += ";";
				}
			}
			set_property("cc_combatDirective", restore);
			if(idx < count(actions))
			{
				return doThis;
			}
		}
	}

	if($monsters[One Thousand Source Agents, Source Agent] contains enemy)
	{
		if(cc_have_skill($skill[Data Siphon]))
		{
			if(my_mp() < 50)
			{
				if(cc_have_skill($skill[Source Punch]) && (my_mp() >= mp_cost($skill[Source Punch])))
				{
					return "skill " + $skill[Source Punch];
				}
			}
			else if(my_mp() > 125)
			{
				if(!contains_text(combatState, "(reboot)") && cc_have_skill($skill[Reboot]) && (my_mp() >= mp_cost($skill[Reboot])) && ((have_effect($effect[Latency]) > 0) || ((my_hp() * 2) < my_maxhp())))
				{
					set_property("cc_combatHandler", combatState + "(reboot)");
					return "skill " + $skill[Reboot];
				}
				if(!contains_text(combatState, "(humiliatingHack)") && cc_have_skill($skill[Humiliating Hack]) && (my_mp() >= mp_cost($skill[Humiliating Hack])))
				{
					set_property("cc_combatHandler", combatState + "(humiliatingHack)");
					return "skill " + $skill[Humiliating Hack];
				}
				if(!contains_text(combatState, "(disarmament)") && cc_have_skill($skill[Disarmament]) && (my_mp() >= mp_cost($skill[Disarmament])))
				{
					set_property("cc_combatHandler", combatState + "(disarmament)");
					return "skill " + $skill[Disarmament];
				}
				if(!contains_text(combatState, "(big guns)") && cc_have_skill($skill[Big Guns]) && (my_mp() >= mp_cost($skill[Big Guns])) && (my_hp() < 100))
				{
					set_property("cc_combatHandler", combatState + "(big guns)");
					return "skill " + $skill[Big Guns];
				}

			}
			else if(my_mp() > 100)
			{
				if(!contains_text(combatState, "(humiliatingHack)") && cc_have_skill($skill[Humiliating Hack]) && (my_mp() >= mp_cost($skill[Humiliating Hack])))
				{
					set_property("cc_combatHandler", combatState + "(humiliatingHack)");
					return "skill " + $skill[Humiliating Hack];
				}
				if(!contains_text(combatState, "(disarmament)") && cc_have_skill($skill[Disarmament]) && (my_mp() >= mp_cost($skill[Disarmament])))
				{
					set_property("cc_combatHandler", combatState + "(disarmament)");
					return "skill " + $skill[Disarmament];
				}
			}

			if(cc_have_skill($skill[Source Kick]) && (my_mp() >= mp_cost($skill[Source Kick])))
			{
				return "skill " + $skill[Source Kick];
			}
		}

		if((!contains_text(combatState, "big guns")) && (cc_have_skill($skill[Big Guns])) && (my_mp() >= mp_cost($skill[Big Guns])))
		{
			set_property("cc_combatHandler", combatState + "(big guns)");
			return "skill " + $skill[Big Guns];
		}
		if(cc_have_skill($skill[Source Punch]) && (my_mp() >= mp_cost($skill[Source Punch])))
		{
			return "skill " + $skill[Source Punch];
		}
		return "runaway";
	}

	if((enemy == $monster[Your Shadow]) || (opp == "shadow cow puncher") || (opp == "shadow snake oiler") || (opp == "shadow beanslinger") || (opp == "shadow gelatinous noob"))
	{
		if(cc_have_skill($skill[Ambidextrous Funkslinging]))
		{
			if(item_amount($item[Gauze Garter]) >= 2)
			{
				return "item " + $item[Gauze Garter] + ", " + $item[Gauze Garter];
			}
			if(item_amount($item[Filthy Poultice]) >= 2)
			{
				return "item " + $item[filthy Poultice] + ", " + $item[Filthy Poultice];
			}
			if((item_amount($item[Gauze Garter]) > 0) && (item_amount($item[Filthy Poultice]) > 0))
			{
				return "item " + $item[Gauze Garter] + ", " + $item[Filthy Poultice];
			}
		}
		if(item_amount($item[Gauze Garter]) > 0)
		{
			return "item " + $item[Gauze Garter];
		}
		if(item_amount($item[Filthy Poultice]) > 0)
		{
			return "item " + $item[Filthy Poultice];
		}
		if(item_amount($item[Rain-Doh Indigo Cup]) > 0)
		{
			return "item " + $item[Rain-Doh Indigo Cup];
		}
		return "skill something I don't have, I just want to abort";
	}

	if(enemy == $monster[Wall Of Meat])
	{
		if(!contains_text(combatState, "makeitrain") && cc_have_skill($skill[Make It Rain]) && (my_rain() >= 10))
		{
			set_property("cc_combatHandler", combatState + "(makeitrain)");
			return "skill " + $skill[Make It Rain];
		}
	}

	if(enemy == $monster[Wall Of Skin])
	{
		if(item_amount($item[Beehive]) > 0)
		{
			return "item " + $item[Beehive];
		}
#		if((!contains_text(combatState, "love stinkbug")) && cc_have_skill($skill[Summon Love Stinkbug]))
#		{
#			set_property("cc_combatHandler", combatState + "(love stinkbug)");
#			return "skill summon love stinkbug";
#		}

		if(!contains_text(combatState, "shell up") && cc_have_skill($skill[Shell Up]) && (my_mp() >= 6) && (round >= 3))
		{
			set_property("cc_combatHandler", combatState + "(shell up)");
			return "skill " + $skill[Shell Up];
		}

		if(!contains_text(combatState, "sauceshell") && cc_have_skill($skill[Sauceshell]) && (my_mp() >= 35) && (round >= 4))
		{
			set_property("cc_combatHandler", combatState + "(sauceshell)");
			return "skill " + $skill[Sauceshell];
		}

		if(have_equipped($item[Astral Shirt]))
		{
			if(cc_have_skill($skill[headbutt]) && (my_mp() >= 3))
			{
				return "skill " + $skill[Headbutt];
			}
			if(cc_have_skill($skill[clobber]) && (my_mp() >= mp_cost($skill[Clobber])))
			{
				return "skill " + $skill[Clobber];
			}
		}
		if(cc_have_skill($skill[Belch the Rainbow]) && (my_mp() >= mp_cost($skill[Belch the Rainbow])))
		{
			return "skill " + $skill[Belch the Rainbow];
		}
		return "attack with weapon";
	}

	if(enemy == $monster[Wall Of Bones])
	{
		if(item_amount($item[Electric Boning Knife]) > 0)
		{
			return "item " + $item[Electric Boning Knife];
		}
		if(((my_hp() * 4) < my_maxhp()) && (have_effect($effect[Takin\' It Greasy]) > 0))
		{
			return "skill " + $skill[Unleash The Greash];
		}

		if((my_mp() >= 50) && cc_have_skill($skill[Garbage Nova]))
		{
			return "skill " + $skill[Garbage Nova];
		}

		if((my_mp() >= 24) && cc_have_skill($skill[Saucegeyser]))
		{
			return "skill " + $skill[Saucegeyser];
		}
	}


	if(!contains_text(combatState, "blackbox") && (my_path() != "Heavy Rains") && (get_property("_raindohCopiesMade").to_int() < 5))
	{
		if((enemy == $monster[Writing Desk]) && (get_property("writingDesksDefeated").to_int() < 4) && (get_property("lastSecondFloorUnlock").to_int() < my_ascensions()))
		{
			set_property("cc_doCombatCopy", "yes");
		}
		if((enemy == $monster[Gaudy Pirate]) && (get_property("cc_gaudypiratecount").to_int() < 1) && !possessEquipment($item[Talisman O\' Namsilat]) && (item_amount($item[Gaudy Key]) < 2))
		{
			set_property("cc_doCombatCopy", "yes");
		}
		if((enemy == $monster[Modern Zmobie]) && (get_property("cc_modernzmobiecount").to_int() < 3))
		{
			set_property("cc_doCombatCopy", "yes");
		}
	}



	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}
	if(have_equipped($item[Drunkula\'s Wineglass]))
	{
		return "attack with weapon";
	}
	if(my_location() == $location[The Daily Dungeon])
	{
		# If we are in The Daily Dungeon, assume we get 1 token, so only if we need more than 1.
		if((towerKeyCount(false) < 2) && !get_property("_dailyDungeonMalwareUsed").to_boolean() && (item_amount($item[Daily Dungeon Malware]) > 0))
		{
			if($monsters[Apathetic Lizardman, Dairy Ooze, Dodecapede, Giant Giant Moth, Mayonnaise Wasp, Pencil Golem, Sabre-Toothed Lime, Tonic Water Elemental, Vampire Clam] contains enemy)
			{
				return "item " + $item[Daily Dungeon Malware];
			}
		}
	}
	if(!contains_text(combatState, "abstraction") && in_ronin())
	{
		if((item_amount($item[Abstraction: Sensation]) > 0) && (enemy == $monster[Performer of Actions]))
		{
			#	Change +100% Moxie to +100% Init
			set_property("cc_combatHandler", combatState + "(abstraction)");
			return "item " + $item[Abstraction: Sensation];
		}
		if((item_amount($item[Abstraction: Thought]) > 0) && (enemy == $monster[Perceiver of Sensations]))
		{
			# Change +100% Myst to +100% Items
			set_property("cc_combatHandler", combatState + "(abstraction)");
			return "item " + $item[Abstraction: Thought];
		}
		if((item_amount($item[Abstraction: Action]) > 0) && (enemy == $monster[Thinker of Thoughts]))
		{
			# Change +100% Muscle to +10 Familiar Weight
			set_property("cc_combatHandler", combatState + "(abstraction)");
			return "item " + $item[Abstraction: Action];
		}
	}

	if(!contains_text(combatState, "tunneldownwards") && (have_effect($effect[Shape of...Mole!]) > 0) && (my_location() == $location[Mt. Molehill]))
	{
		set_property("cc_combatHandler", combatState + "(tunneldownwards)");
		return "skill " + $skill[Tunnel Downwards];
	}

	if((my_familiar() == $familiar[Stocking Mimic]) && (round < 12) && canSurvive(1.5))
	{
		if(item_amount($item[Dictionary]) > 0)
		{
			return "item " + $item[dictionary];
		}
	}

	if(!contains_text(combatState, "cigaretteLighter") && (my_location() == $location[A Mob Of Zeppelin Protesters]) && (get_property("questL11Ron") == "step1") && (item_amount($item[Cigarette Lighter]) > 0))
	{
		set_property("cc_combatHandler", combatState + "(cigaretteLighter)");
		return "item " + $item[Cigarette Lighter];
	}

	if((my_class() == $class[Avatar of Sneaky Pete]) && canSurvive(2.0))
	{
		int maxAudience = 30;
		if($items[Sneaky Pete\'s Leather Jacket, Sneaky Pete\'s Leather Jacket (Collar Popped)] contains equipped_item($slot[shirt]))
		{
			maxAudience = 50;
		}
		if((my_mp() >= mp_cost($skill[Mug for the Audience])) && cc_have_skill($skill[Mug for the Audience]) && (my_audience() < maxAudience))
		{
			return "skill " + $skill[Mug for the Audience];
		}
	}

	if(!contains_text(combatState, "pickpocket") && ($classes[Accordion Thief, Avatar of Sneaky Pete, Disco Bandit, Gelatinous Noob] contains my_class()) && contains_text(text, "value=\"Pick") && canSurvive(2.0))
	{
		boolean tryIt = false;
		foreach i, drop in item_drops_array(enemy)
		{
			if(drop.type == "0")
			{
				tryIt = true;
			}
			if((drop.rate > 0) && (drop.type != "n") && (drop.type != "c") && (drop.type != "b"))
			{
				tryIt = true;
			}
		}
		if(tryIt)
		{
			set_property("cc_combatHandler", combatState + "(pickpocket)");
			string attemptSteal = steal();
			return "pickpocket";
		}
	}

	if((my_class() == $class[Avatar of Sneaky Pete]) && canSurvive(2.0) && (my_level() < 13))
	{
		if((my_mp() >= mp_cost($skill[Mug for the Audience])) && cc_have_skill($skill[Mug for the Audience]))
		{
			return "skill " + $skill[Mug for the Audience];
		}
	}

	if(!contains_text(combatState, "stealaccordion") && (my_class() == $class[Accordion Thief]) && cc_have_skill($skill[Steal Accordion]) && canSurvive(2.0))
	{
		set_property("cc_combatHandler", combatState + "(stealaccordion)");
		return "skill " + $skill[Steal Accordion];
	}

	if(get_property("cc_useTatter").to_boolean())
	{
		if(item_amount($item[Tattered Scrap Of Paper]) > 0)
		{
			return "item " + $item[Tattered Scrap Of Paper];
		}
	}

	if((get_property("cc_usePowerPill").to_boolean()) && (get_property("_powerPillUses").to_int() < 20) && instakillable(enemy))
	{
		if(item_amount($item[Power Pill]) > 0)
		{
			return "item " + $item[Power Pill];
		}
	}

	if(get_property("cc_useCleesh").to_boolean())
	{
		if(!contains_text(combatState, "cleesh") && cc_have_skill($skill[CLEESH]) && (my_mp() > 10))
		{
			set_property("cc_useCleesh", false);
			set_property("cc_combatHandler", combatState + "(cleesh)");
			return "skill " + $skill[CLEESH];
		}
	}

	if(thunderBirdsLeft > 0)
	{
		thunderBirdsLeft = thunderBirdsLeft - 1;
		if(thunderBirdsLeft == 0)
		{
			set_property("cc_combatHandler", combatState + "(thunderbird)");
		}
		set_property("cc_combatHandlerThunderBird", "" + thunderBirdsLeft);
		return "skill " + $skill[Thunder Bird];
	}

	if(!contains_text(combatState, "thunderstrike") && (monster_level_adjustment() <= 150) && cc_have_skill($skill[Thunder Bird]))
	{
		if($monsters[Big Wisnaqua, The Aquaman, The Big Wisniewski, The Man, The Rain King] contains enemy)
		{
			if(!contains_text(combatState, "weaksauce") && cc_have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= 60) && cc_have_skill($skill[Itchy Curse Finger]))
			{
				set_property("cc_combatHandler", combatState + "(weaksauce)");
				return "skill " + $skill[Curse Of Weaksauce];
			}

			set_property("cc_combatHandler", combatState + "(thunderstrike)");
			set_property("cc_combatHandlerThunderBird", "5");
			return "skill " + $skill[Thunderstrike];
		}
	}

	if((my_location() == $location[The Battlefield (Frat Uniform)]) && (enemy == $monster[gourmet gourami]))
	{
		if((item_amount($item[Louder Than Bomb]) > 0) && (get_property("cc_gremlins") == "finished"))
		{
			handleTracker(enemy, $item[Louder Than Bomb], "cc_banishes");
			return "item " + $item[Louder Than Bomb];
		}
	}

	if((enemy == $monster[dirty thieving brigand]) && !contains_text(combatState, "makeitrain") && (get_property("cc_nunsTrickReady") == "yes"))
	{
		if((my_rain() > rain_cost($skill[Make It Rain])) && cc_have_skill($skill[Make It Rain]))
		{
			set_property("cc_combatHandler", combatState + "(makeitrain)");
			return "skill " + $skill[Make It Rain];
		}
	}

	if((enemy == $monster[dirty thieving brigand]) && !contains_text(combatState, "makeitrain") && (my_rain() > 60))
	{
		if((my_rain() > rain_cost($skill[Make It Rain])) && cc_have_skill($skill[Make It Rain]))
		{
			set_property("cc_combatHandler", combatState + "(makeitrain)");
			return "skill " + $skill[Make It Rain];
		}
	}

	if(my_class() == $class[Seal Clubber])
	{
		if(enemy == $monster[Hellseal Pup])
		{
			return "skill " + $skill[Clobber];
		}
		if(enemy == $monster[Mother Hellseal])
		{
			if(!contains_text(combatState, "indigo cup") && (item_amount($item[Rain-Doh Indigo Cup]) > 0))
			{
				set_property("cc_combatHandler", combatState + "(indigo cup)");
				return "item " + $item[Rain-Doh Indigo Cup];
			}
			return "skill " + $skill[Lunging Thrust-Smack];
		}
	}

	if((enemy == $monster[French Guard Turtle]) && have_equipped($item[Fouet de tortue-dressage]) && (my_mp() >= mp_cost($skill[Apprivoisez La Tortue])))
	{
		return "skill " + $skill[Apprivoisez La Tortue];
	}

	if(!contains_text(combatState, "lattegulp") && (get_property("_latteRefillsUsed").to_int() == 0) && !get_property("_latteDrinkUsed").to_boolean() && have_skill($skill[Gulp Latte]))
	{
		set_property("cc_combatHandler", combatState + "(lattegulp)");
		return "skill " + $skill[Gulp Latte];
	}

	#Do not accidentally charge the nanorhino with a non-banisher
	if((my_familiar() == $familiar[Nanorhino]) && (have_effect($effect[Nanobrawny]) == 0))
	{
		foreach it in $skills[Toss, Clobber, Shell Up, Lunge Smack, Thrust-Smack, Headbutt, Kneebutt, Lunging Thrust-Smack, Club Foot, Shieldbutt, Spirit Snap, Cavalcade Of Fury, Northern Explosion, Spectral Snapper, Harpoon!, Summon Leviatuga]
		{
			if((it == $skill[Shieldbutt]) && !hasShieldEquipped())
			{
				continue;
			}
			if(cc_have_skill(it) && (my_mp() >= mp_cost(it)))
			{
				return "skill " + it;
			}
		}
	}

	if(!contains_text(combatState, "nanotoss") && (have_effect($effect[Nanobrawny]) >= 40))
	{
		#if appropriate enemy, then banish
		if(enemy == $monster[Pygmy Janitor])
		{
			set_property("cc_combatHandler", combatState + "(nanotoss)");
			return "skill " + $skill[Unleash Nanites];
		}
	}

	if(!contains_text(combatState, "winkat") && (my_familiar() == $familiar[Reanimated Reanimator]))
	{
		if($monsters[Lobsterfrogman, Modern Zmobie, Ninja Snowman Assassin, Writing Desk] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(winkat)");
			if((get_property("_badlyRomanticArrows").to_int() == 1) && (round <= 1) && (get_property("romanticTarget") != enemy))
			{
				abort("Have animator out but can not arrow");
			}
			if(enemy == $monster[modern zmobie])
			{
				set_property("cc_waitingArrowAlcove", get_property("cyrptAlcoveEvilness").to_int() - 20);
			}
			return "skill " + $skill[Wink At];
		}
	}

	if(!contains_text(combatState, "blackbox") && (get_property("cc_doCombatCopy") == "yes") && (enemy != $monster[gourmet gourami]) && (item_amount($item[Rain-Doh Black Box]) > 0))
	{
		set_property("cc_doCombatCopy", "no");
		set_property("cc_combatHandler", combatState + "(blackbox)");
		if(get_property("_raindohCopiesMade").to_int() < 5)
		{
			return "item " + $item[Rain-Doh Black Box];
		}
		print("Can not issue copy directive because we have no copies left", "red");
	}

	if(get_property("cc_doCombatCopy") == "yes")
	{
		set_property("cc_doCombatCopy", "no");
	}

	if((enemy == $monster[Plaid Ghost]) && (item_amount($item[T.U.R.D.S. Key]) > 0))
	{
		return "item " + $item[T.U.R.D.S. Key];
	}

	if((enemy == $monster[Tomb Rat]) && (item_amount($item[Tangle Of Rat Tails]) > 0))
	{
		if((item_amount($item[Tomb Ratchet]) + item_amount($item[Crumbling Wooden Wheel])) < 10)
		{
			return "item " + $item[Tangle Of Rat Tails];
		}
	}

	if((enemy == $monster[Storm Cow]) && (cc_have_skill($skill[Unleash The Greash])))
	{
		return "skill " + $skill[Unleash The Greash];
	}

	if(fingernailClippersLeft > 0)
	{
		fingernailClippersLeft = fingernailClippersLeft - 1;
		if(fingernailClippersLeft == 0)
		{
			set_property("cc_combatHandler", combatState + "(fingernail clippers)");
		}
		set_property("cc_combatHandlerFingernailClippers", "" + fingernailClippersLeft);
		return "item " + $item[Military-Grade Fingernail Clippers];
	}

	#Is $monster[one of doctor weirdeaux's creations valid yet?
	if((item_amount($item[military-grade fingernail clippers]) > 0)  && (my_location() == $location[The Mansion of Dr. Weirdeaux]))
	{
		if(!contains_text(combatState, "fingernail clippers"))
		{
			fingernailClippersLeft = 3;
			set_property("cc_combatHandlerFingernailClippers", "3");
		}
	}

	if(!contains_text(combatState, "(extract)") && cc_have_skill($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 2)) && get_property("kingLiberated").to_boolean())
	{
		set_property("cc_combatHandler", combatState + "(extract)");
		return "skill " + $skill[Extract];
	}


	if(cc_have_skill($skill[Summon Mayfly Swarm]) && !contains_text(combatState, "mayfly"))
	{
		if(have_equipped($item[Mayfly Bait Necklace]))
		{
			if($locations[Dreadsylvanian Village, Dreadsylvanian Woods, The Ice Hole, The Ice Hotel, Sloppy Seconds Diner, VYKEA] contains my_location())
			{
				set_property("cc_combatHandler", combatState + "(mayfly)");
				return "skill " + $skill[Summon Mayfly Swarm];
			}
		}
	}

	if((item_amount($item[The Big Book of Pirate Insults]) > 0) && !contains_text(combatState, "insults") && (numPirateInsults() < 8) && (internalQuestStatus("questM12Pirate") < 5))
	{
		if(($locations[Barrrney\'s Barrr, The Obligatory Pirate\'s Cove] contains my_location()) || ((enemy == $monster[Gaudy Pirate]) && (my_location() != $location[Belowdecks])))
		{
			set_property("cc_combatHandler", combatState + "(insults)");
			return "item " + $item[The Big Book Of Pirate Insults];
		}
	}

	if(!contains_text(combatState, "(olfaction)") && (have_effect($effect[On The Trail]) == 0) && cc_have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])))
	{
		if((enemy == $monster[pygmy shaman]) && (my_location() == $location[The Hidden Apartment Building]) && (item_amount($item[soft green echo eyedrop antidote]) > 3) && (have_effect($effect[Thrice-Cursed]) == 0))
		{
			set_property("cc_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "cc_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
	}

	if(!contains_text(combatSTate, "(matingcall)") && cc_have_skill($skill[Gallapagosian Mating Call]) && (my_mp() >= mp_cost($skill[Gallapagosian Mating Call])))
	{
		if((enemy == $monster[pygmy shaman]) && (my_location() == $location[The Hidden Apartment Building]) && (have_effect($effect[Thrice-Cursed]) == 0) && (get_property("gallapagosMonster") != enemy))
		{
			set_property("cc_combatHandler", combatState + "(matingcall)");
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "cc_sniffs");
			return "skill " + $skill[Gallapagosian Mating Call];
		}
	}

	if(!contains_text(combatState, "(makefriends)") && (get_property("makeFriendsMonster") != $monster[Pygmy Shaman]) && cc_have_skill($skill[Make Friends]) && (my_mp() >= mp_cost($skill[Make Friends])) && (my_audience() >= 20))
	{
		if((enemy == $monster[pygmy shaman]) && (my_location() == $location[The Hidden Apartment Building]))
		{
			set_property("cc_combatHandler", combatState + "(makefriends)");
			handleTracker(enemy, $skill[Make Friends], "cc_sniffs");
			return "skill " + $skill[Make Friends];
		}
	}

	if(!contains_text(combatState, "(olfaction)") && (have_effect($effect[On The Trail]) == 0) && cc_have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])) && get_property("kingLiberated").to_boolean())
	{
		if(enemy == $monster[Gurgle the Turgle])
		{
			set_property("cc_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "cc_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
	}

	if(!contains_text(combatState, "(olfaction)") && (have_effect($effect[On The Trail]) == 0) && cc_have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])) && (!cc_have_skill($skill[Rain Man]) || is100FamiliarRun()))
	{
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("writingDesksDefeated").to_int() < 5))
		{
			set_property("cc_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "cc_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
	}

	if(!contains_text(combatState, "(matingcall)") && cc_have_skill($skill[Gallapagosian Mating Call]) && (my_mp() >= mp_cost($skill[Gallapagosian Mating Call])) && (!cc_have_skill($skill[Rain Man]) || is100FamiliarRun()))
	{
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("writingDesksDefeated").to_int() < 5) && (get_property("gallapagosMonster") != enemy))
		{
			set_property("cc_combatHandler", combatState + "(matingcall)");
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "cc_sniffs");
			return "skill " + $skill[Gallapagosian Mating Call];
		}
	}

	if((get_property("makeFriendsMonster") != $monster[Writing Desk]) && cc_have_skill($skill[Make Friends]) && (my_mp() >= mp_cost($skill[Make Friends])) && (my_audience() >= 20))
	{
		if((enemy == $monster[Writing Desk]) && (my_location() == $location[The Haunted Library]) && (get_property("lastSecondFloorUnlock").to_int() < my_ascensions()))
		{
			set_property("cc_combatHandler", combatState + "(makefriends)");
			handleTracker(enemy, $skill[Make Friends], "cc_sniffs");
			return "skill " + $skill[Make Friends];
		}
	}

	if(!contains_text(combatState, "(olfaction)") && (have_effect($effect[On The Trail]) == 0) && cc_have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])) && (enemy == $monster[Smoke Monster]) && (item_amount($item[Pack Of Smokes]) > 0))
	{
		set_property("cc_combatHandler", combatState + "(olfaction)");
		handleTracker(enemy, $skill[Transcendent Olfaction], "cc_sniffs");
		return "skill " + $skill[Transcendent Olfaction];
	}

	if(!contains_text(combatState, "(olfaction)") && (have_effect($effect[On The Trail]) == 0) && cc_have_skill($skill[Transcendent Olfaction]) && (my_mp() >= mp_cost($skill[Transcendent Olfaction])))
	{
		if($monsters[Bob Racecar, cabinet of Dr. Limpieza, Dairy Goat, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Racecar Bob, Tomb Rat] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "cc_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
		if(($monsters[Blooper] contains enemy) && (my_location() == $location[8-Bit Realm]))
		{
			set_property("cc_combatHandler", combatState + "(olfaction)");
			handleTracker(enemy, $skill[Transcendent Olfaction], "cc_sniffs");
			return "skill " + $skill[Transcendent Olfaction];
		}
	}

	if(!contains_text(combatState, "(matingcall)") && cc_have_skill($skill[Gallapagosian Mating Call]) && (my_mp() >= mp_cost($skill[Gallapagosian Mating Call])))
	{
		if(($monsters[cabinet of Dr. Limpieza, Dairy Goat, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Tomb Rat] contains enemy) && (get_property("gallapagosMonster") != enemy))
		{
			set_property("cc_combatHandler", combatState + "(matingcall)");
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "cc_sniffs");
			return "skill " + $skill[Gallapagosian Mating Call];
		}
		if(($monsters[Blooper] contains enemy) && (my_location() == $location[8-Bit Realm]) && (get_property("gallapagosMonster") != enemy))
		{
			set_property("cc_combatHandler", combatState + "(matingcall)");
			handleTracker(enemy, $skill[Gallapagosian Mating Call], "cc_sniffs");
			return "skill " + $skill[Gallapagosian Mating Call];
		}
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			if((get_property("gallapagosMonster") != $monster[Bob Racecar]) && (get_property("gallapagosMonster") != $monster[Racecar Bob]))
			{
				set_property("cc_combatHandler", combatState + "(matingcall)");
				handleTracker(enemy, $skill[Gallapagosian Mating Call], "cc_sniffs");
				return "skill " + $skill[Gallapagosian Mating Call];
			}
		}
	}

	if(cc_have_skill($skill[Make Friends]) && (my_mp() >= mp_cost($skill[Make Friends])) && (my_audience() >= 20))
	{
		if((get_property("makeFriendsMonster") != enemy) && ($monsters[Blooper, Bob Racecar, cabinet of Dr. Limpieza, Dairy Goat, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Racecar Bob, Tomb Rat] contains enemy))
		{
			set_property("cc_combatHandler", combatState + "(makefriends)");
			handleTracker(enemy, $skill[Make Friends], "cc_sniffs");
			return "skill " + $skill[Make Friends];
		}
	}
	if(!contains_text(get_property("longConMonster"),enemy) && cc_have_skill($skill[Long Con]) && (my_mp() >= mp_cost($skill[Long Con])) && (get_property("_longConUsed").to_int() < 5))
	{
		if($monsters[Blooper, cabinet of Dr. Limpieza, Dairy Goat, Dirty Old Lihc, Gaudy Pirate, Morbid Skull, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Tomb Rat, Writing Desk] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(longcon)");
			handleTracker(enemy, $skill[Long Con], "cc_sniffs");
			return "skill " + $skill[Long Con];
		}

		if(($monsters[Bob Racecar, Racecar Bob] contains enemy) && (get_property("palindomeDudesDefeated").to_int() < 5) && !contains_text(get_property("longConMonster"), $monster[Racecar Bob]) && !contains_text(get_property("longConMonster"), $monster[Bob Racecar]))
		{
			set_property("cc_combatHandler", combatState + "(longcon)");
			handleTracker(enemy, $skill[Long Con], "cc_sniffs");
			return "skill " + $skill[Long Con];
		}
	}

	//This should probably be removed.
	if(contains_text(combatState, "insults"))
	{
		if((enemy == $monster[shady pirate]) && cc_have_skill($skill[Thunder Clap]) && (my_thunder() >= 40))
		{
			handleTracker(enemy, $skill[Thunder Clap], "cc_banishes");
			return "skill " + $skill[Thunder Clap];
		}
		if((enemy == $monster[shifty pirate]) && cc_have_skill($skill[Talk About Politics]))
		{
			if(get_property("_pantsgivingBanish").to_int() < 5)
			{
				handleTracker(enemy, $skill[Talk About Politics], "cc_banishes");
				return "skill " + $skill[Talk About Politics];
			}
		}
		if((my_lightning() >= 25) && !isFreeMonster(enemy) && instakillable(enemy))
		{
			if(cc_have_skill($skill[Lightning Strike]))
			{
				handleTracker(enemy, $skill[Lightning Strike], "cc_instakill");
				return "skill " + $skill[Lightning Strike];
			}
		}
	}

	if(!contains_text(combatState, "flyers") && (my_location() != $location[The Battlefield (Frat Uniform)]) && (my_location() != $location[The Battlefield (Hippy Uniform)]) && ((item_amount($item[Rock Band Flyers]) > 0) || (item_amount($item[Jam Band Flyers]) > 0)) && !get_property("cc_ignoreFlyer").to_boolean())
	{
		if(!contains_text(combatState, "beanscreen") && cc_have_skill($skill[Beanscreen]) && (my_mp() >= mp_cost($skill[Beanscreen])))
		{
			set_property("cc_combatHandler", combatState + "(beanscreen)");
			return "skill " + $skill[Beanscreen];
		}

		if(!contains_text(combatState, "broadside") && cc_have_skill($skill[Broadside]) && (my_mp() >= mp_cost($skill[Broadside])))
		{
			set_property("cc_combatHandler", combatState + "(broadside)");
			return "skill " + $skill[Broadside];
		}

		if(!contains_text(combatState, "mind bullets") && cc_have_skill($skill[Mind Bullets]) && (my_mp() >= mp_cost($skill[Mind Bullets])))
		{
			set_property("cc_combatHandler", combatState + "(mind bullets)");
			return "skill " + $skill[Mind Bullets];
		}

		if(!contains_text(combatState, to_string($skill[Snap Fingers])) && cc_have_skill($skill[Snap Fingers]) && (my_mp() >= mp_cost($skill[Snap Fingers])))
		{
			set_property("cc_combatHandler", combatState + "(" + $skill[Snap Fingers] + ")");
			return "skill " + $skill[Snap Fingers];
		}

		if(!contains_text(combatState, "soulbubble") && cc_have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])))
		{
			set_property("cc_combatHandler", combatState + "(soulbubble)");
			return "skill " + $skill[Soul Bubble];
		}

		if(!contains_text(combatState, "hogtie") && !contains_text(combatState, "beanscreen") && cc_have_skill($skill[Hogtie]) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			set_property("cc_combatHandler", combatState + "(hogtie)");
			return  "skill " + $skill[Hogtie];
		}

		if((item_amount($item[Rock Band Flyers]) > 0) && (get_property("flyeredML").to_int() < 10000))
		{
			set_property("cc_combatHandler", combatState + "(flyers)");
			if((item_amount($item[Time-Spinner]) > 0) && cc_have_skill($skill[Ambidextrous Funkslinging]) && !contains_text(combatState, "time-spinner"))
			{
				set_property("cc_combatHandler", combatState + "(flyers)(time-spinner)");
				return "item " + $item[Rock Band Flyers] + ", " + $item[Time-Spinner];
			}
			return "item " + $item[Rock Band Flyers];
		}
		if((item_amount($item[Jam Band Flyers]) > 0) && (get_property("flyeredML").to_int() < 10000))
		{
			set_property("cc_combatHandler", combatState + "(flyers)");
			if((item_amount($item[Time-Spinner]) > 0) && cc_have_skill($skill[Ambidextrous Funkslinging]) && !contains_text(combatState, "time-spinner"))
			{
				set_property("cc_combatHandler", combatState + "(flyers)(time-spinner)");
				return "item " + $item[Jam Band Flyers] + ", " + $item[Time-Spinner];
			}
			return "item " + $item[Jam Band Flyers];
		}
	}

	if((enemy == $monster[dirty thieving brigand]) && !contains_text(combatState, "4dcamera") && (get_property("cc_nunsTrickActive") == "yes") && (item_amount($item[4-d Camera]) == 1) && (get_property("_cameraUsed").to_boolean() != true))
	{
		set_property("cc_combatHandler", combatState + "(4dcamera)");
		return "item " + $item[4-d camera];
	}

	if(item_amount($item[Cocktail Napkin]) > 0)
	{
		if($monsters[Clingy Pirate (Female), Clingy Pirate (Male)] contains enemy)
		{
			return "item " + $item[Cocktail Napkin];
		}
	}

	if(!contains_text(combatState, "DNA") && (monster_level_adjustment() < 150) && (item_amount($item[DNA Extraction Syringe]) > 0))
	{
		if(type != current)
		{
			set_property("cc_combatHandler", combatState + "(DNA)");
			return "item " + $item[DNA extraction syringe];
		}
	}

	if(!contains_text(combatState, "yellowray"))
	{
		boolean doYellow = false;
		if((enemy == $monster[burly sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doYellow = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]) && (get_property("cc_airship") == "finished"))
		{
			doYellow = true;
		}
		if((get_property("cc_nunsTrickGland") == "start") && (enemy == $monster[larval filthworm]))
		{
			doYellow = true;
		}

		if(($monsters[Orcish Frat Boy Spy, War Frat 151st Infantryman] contains enemy) && !have_outfit("Frat Warrior Fatigues"))
		{
			doYellow = true;
		}
		if(($monsters[Knob Goblin Harem Girl] contains enemy) && !have_outfit("Knob Goblin Harem Girl Disguise"))
		{
			doYellow = true;
		}
		if($monsters[Filthworm Royal Guard] contains enemy)
		{
			doYellow = true;
		}

		if(doYellow)
		{
			string combatAction = yellowRayCombatString();
			if(combatAction != "")
			{
				set_property("cc_combatHandler", combatState + "(yellowray)");
				if(index_of(combatAction, "skill") == 0)
				{
					handleTracker(enemy, to_skill(substring(combatAction, 6)), "cc_yellowRays");
				}
				else if(index_of(combatAction, "item") == 0)
				{
					handleTracker(enemy, to_item(substring(combatAction, 5)), "cc_yellowRays");
				}
				else
				{
					print("Unable to track yellow ray behavior: " + combatAction, "red");
				}
				if(combatAction == ("skill " + $skill[Asdon Martin: Missile Launcher]))
				{
					set_property("_missileLauncherUsed", true);
				}
				return combatAction;
			}
			else
			{
				print("Wanted a yellow ray but we can not find one.", "red");
			}
		}
	}

	if(!contains_text(combatState, "hugpocket") && (my_familiar() == $familiar[XO Skeleton]) && (get_property("_xoHugsUsed").to_int() <= 10))
	{
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(hugpocket)");
			return "skill " + $skill[Hugs and Kisses!];
		}
	}

	if(contains_text(combatState, "yellowray"))
	{
		abort("Ugh, where is my damn yellowray!!!");
	}

	if(item_amount($item[Green Smoke Bomb]) > 0)
	{
		if($monsters[Animated Possessions, Natural Spider] contains enemy)
		{
			return "item " + $item[Green Smoke Bomb];
		}
	}

	if(!get_property("kingLiberated").to_boolean())
	{
		if(item_amount($item[short writ of habeas corpus]) > 0)
		{
			if($monsters[Pygmy Orderlies, Pygmy Witch Lawyer, Pygmy Witch Nurse] contains enemy)
			{
				return "item " + $item[Short Writ Of Habeas Corpus];
			}
		}
	}

	if(!contains_text(combatState, "banishercheck"))
	{
		string banishAction = banisherCombatString(enemy, my_location());
		if(banishAction != "")
		{
			print("Looking at banishAction: " + banishAction, "green");
			#abort("Banisher considered here. Weee");
			#wait(10);
			#banishAction = "";
		}
		if(banishAction != "")
		{
			set_property("cc_combatHandler", combatState + "(banisher)");
			if(index_of(banishAction, "skill") == 0)
			{
				handleTracker(enemy, to_skill(substring(banishAction, 6)), "cc_banishes");
			}
			else if(index_of(banishAction, "item") == 0)
			{
				handleTracker(enemy, to_item(substring(banishAction, 5)), "cc_banishes");
			}
			else
			{
				print("Unable to track banisher behavior: " + banishAction, "red");
			}
			return banishAction;
		}
		set_property("cc_combatHandler", combatState + "(banishercheck)");
		combatState += "(banishercheck)";
	}

	if(cc_have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10) && (my_mp() > mp_cost($skill[Macrometeorite])) && (cc_my_path() != "G-Lover"))
	{
		if((enemy == $monster[Banshee Librarian]) && (item_amount($item[Killing Jar]) == 0))
		{
			return "skill " + $skill[Macrometeorite];
		}
		if((enemy == $monster[Beefy Bodyguard Bat]) && ($location[The Boss Bat\'s Lair].turns_spent >= 4) && (my_location() == $location[The Boss Bat\'s Lair]))
		{
			return "skill " + $skill[Macrometeorite];
		}
		if((enemy == $monster[Government Agent]) && (my_location() == $location[Sonofa Beach]))
		{
			return "skill " + $skill[Macrometeorite];
		}
		if((enemy == $monster[Knob Goblin Madam]) && (item_amount($item[Knob Goblin Perfume]) == 0))
		{
			return "skill " + $skill[Macrometeorite];
		}
		if($monsters[Bookbat, Craven Carven Raven, Drunk Goat, Knight In White Satin, Knob Goblin Harem Guard, Mad Wino, Plaid Ghost, Possessed Laundry Press, Sabre-Toothed Goat, Senile Lihc, Skeletal Sommelier, Slick Lihc, White Chocolate Golem] contains enemy)
		{
			return "skill " + $skill[Macrometeorite];
		}
		if((enemy == $monster[Stone Temple Pirate]) && possessEquipment($item[Eyepatch]))
		{
			return "skill " + $skill[Macrometeorite];
		}
		if(my_location() == $location[The Obligatory Pirate\'s Cove])
		{
			if($monsters[Shady Pirate, Shifty Pirate] contains enemy)
			{
				return "skill " + $skill[Macrometeorite];
			}
			if((enemy == $monster[Sassy Pirate]) && possessEquipment($item[Swashbuckling Pants]))
			{
				return "skill " + $skill[Macrometeorite];
			}
			if((enemy == $monster[Smarmy Pirate]) && possessEquipment($item[Eyepatch]))
			{
				return "skill " + $skill[Macrometeorite];
			}
			if((enemy == $monster[Swarthy Pirate]) && possessEquipment($item[Stuffed Shoulder Parrot]))
			{
				return "skill " + $skill[Macrometeorite];
			}
		}
	}

	if(item_amount($item[Disposable Instant Camera]) > 0)
	{
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(disposable instant camera)");
			return "item " + $item[Disposable Instant Camera];
		}
	}

	if(item_amount($item[Duskwalker Syringe]) > 0)
	{
		if($monsters[Oil Baron, Oil Cartel, Oil Slick, Oil Tycoon] contains enemy)
		{
			return "item " + $item[Duskwalker Syringe];
		}
	}

	if(!contains_text(combatState, "opium grenade") && (item_amount($item[opium grenade]) > 0))
	{
		if(enemy == $monster[pair of burnouts])
		{
			set_property("cc_combatHandler", combatState + "(opium grenade)");
			return "item " + $item[opium grenade];
		}
	}

	if(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy))
	{
		if(!contains_text(combatState, "beanscreen") && cc_have_skill($skill[Beanscreen]) && (my_mp() >= mp_cost($skill[Beanscreen])))
		{
			set_property("cc_combatHandler", combatState + "(beanscreen)");
			return "skill " + $skill[Beanscreen];
		}

		if(!contains_text(combatState, "broadside") && cc_have_skill($skill[Broadside]) && (my_mp() >= mp_cost($skill[Broadside])))
		{
			set_property("cc_combatHandler", combatState + "(broadside)");
			return "skill " + $skill[Broadside];
		}

		if(!contains_text(combatState, to_string($skill[Snap Fingers])) && cc_have_skill($skill[Snap Fingers]) && (my_mp() >= mp_cost($skill[Snap Fingers])))
		{
			set_property("cc_combatHandler", combatState + "(" + $skill[Snap Fingers] + ")");
			return "skill " + $skill[Snap Fingers];
		}

		if((!contains_text(combatState, "love gnats")) && cc_have_skill($skill[Summon Love Gnats]))
		{
			set_property("cc_combatHandler", combatState + "(love gnats)");
			return "skill " + $skill[Summon Love Gnats];
		}

		if(!contains_text(combatState, "soulbubble") && cc_have_skill($skill[Soul Saucery]) && (my_soulsauce() >= soulsauce_cost($skill[Soul Bubble])) && (!get_property("lovebugsUnlocked").to_boolean() || blocked))
		{
			set_property("cc_combatHandler", combatState + "(soulbubble)");
			return "skill " + $skill[Soul Bubble];
		}

		if(cc_have_skill($skill[Shoot Ghost]) && (my_mp() > mp_cost($skill[Shoot Ghost])) && !contains_text(combatState, "shootghost3") && !contains_text(combatState, "trapghost"))
		{
			boolean shootGhost = true;
			if(contains_text(combatState, "shootghost2"))
			{
				if((damageReceived * 1.075) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("cc_combatHandler", combatState + "(shootghost3)");
				}
			}
			else if(contains_text(combatState, "shootghost1"))
			{
				if((damageReceived * 2.05) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("cc_combatHandler", combatState + "(shootghost2)");
				}
			}
			else
			{
				set_property("cc_combatHandler", combatState + "(shootghost1)");
			}

			if(shootGhost)
			{
				return "skill " + $skill[Shoot Ghost];
			}
			else
			{
				combatState += "(trapghost)(love stinkbug)";
				set_property("cc_combatHandler", combatState);
			}
		}
		if(!contains_text(combatState, "trapghost") && cc_have_skill($skill[Trap Ghost]) && (my_mp() > mp_cost($skill[Trap Ghost])) && contains_text(combatState, "shootghost3"))
		{
			print("Busting makes me feel good!!", "green");
			set_property("cc_combatHandler", combatState + "(trapghost)");
			return "skill " + $skill[Trap Ghost];
		}
	}

	# Instakill handler
	boolean doInstaKill = true;
	if($monsters[Lobsterfrogman, Ninja Snowman Assassin, Writing Desk] contains enemy)
	{
		if(cc_have_skill($skill[Digitize]) && (get_property("_sourceTerminalDigitizeMonster") != enemy))
		{
			doInstaKill = false;
		}
	}

	if(instakillable(enemy) && !isFreeMonster(enemy) && doInstaKill)
	{
		if((my_lightning() >= 25) && cc_have_skill($skill[Lightning Strike]))
		{
			if(cc_have_skill($skill[lightning strike]))
			{
				handleTracker(enemy, $skill[lightning strike], "cc_instakill");
				return "skill " + $skill[lightning strike];
			}
		}

		if(!contains_text(combatState, "shattering punch") && cc_have_skill($skill[Shattering Punch]) && ((my_mp() / 2) > mp_cost($skill[Shattering Punch])) && (get_property("_shatteringPunchUsed").to_int() < 3))
		{
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
			{
				set_property("cc_combatHandler", combatState + "(shattering punch)");
				handleTracker(enemy, $skill[shattering punch], "cc_instakill");
				return "skill " + $skill[shattering punch];
			}
		}
		if(!contains_text(combatState, "gingerbread mob hit") && cc_have_skill($skill[Gingerbread Mob Hit]) && ((my_mp() / 2) > mp_cost($skill[Gingerbread Mob Hit])) && !get_property("_gingerbreadMobHitUsed").to_boolean())
		{
			if((my_adventures() < 20) || get_property("kingLiberated").to_boolean() || (my_daycount() >= 3))
			{
				set_property("cc_combatHandler", combatState + "(gingerbread mob hit)");
				handleTracker(enemy, $skill[Gingerbread Mob Hit], "cc_instakill");
				return "skill " + $skill[Gingerbread Mob Hit];
			}
		}

//		Can not use _usedReplicaBatoomerang if we have more than 1 because of the double item use issue...
//		Sure, we can try to use a second item (if we have it or are forced to buy it... ugh).
//		if(!contains_text(combatState, "batoomerang") && (item_amount($item[Replica Bat-oomerang]) > 0) && (get_property("_usedReplicaBatoomerang").to_int() < 3))
//		THIS IS COPIED TO THE ED SECTION, IF IT IS FIXED, FIX IT THERE TOO!
		if(!contains_text(combatState, "batoomerang") && (item_amount($item[Replica Bat-oomerang]) > 0))
		{
			if(get_property("cc_batoomerangDay").to_int() != my_daycount())
			{
				set_property("cc_batoomerangDay", my_daycount());
				set_property("cc_batoomerangUse", 0);
			}
			if(get_property("cc_batoomerangUse").to_int() < 3)
			{
				set_property("cc_batoomerangUse", get_property("cc_batoomerangUse").to_int() + 1);
				set_property("cc_combatHandler", combatState + "(batoomerang)");
				handleTracker(enemy, $item[Replica Bat-oomerang], "cc_instakill");
				return "item " + $item[Replica Bat-oomerang];
			}
		}

		if(!contains_text(combatState, "jokesterGun") && (equipped_item($slot[Weapon]) == $item[The Jokester\'s Gun]) && !get_property("_firedJokestersGun").to_boolean() && cc_have_skill($skill[Fire the Jokester\'s Gun]))
		{
			set_property("cc_combatHandler", combatState + "(jokesterGun)");
			handleTracker(enemy, $skill[Fire the Jokester\'s Gun], "cc_instakill");
			return "skill" + $skill[Fire the Jokester\'s Gun];
		}
	}

	if(!contains_text(combatState, "badMedicine") && cc_have_skill($skill[Bad Medicine]) && (my_mp() >= (3 * mp_cost($skill[Bad Medicine]))))
	{
		set_property("cc_combatHandler", combatState + "(badMedicine)");
		return "skill " + $skill[Bad Medicine];
	}

	boolean doWeaksauce = true;
	if((buffed_hit_stat() - 20) > monster_defense())
	{
		doWeaksauce = false;
	}
	if(my_class() == $class[Sauceror])
	{
		doWeaksauce = true;
	}

	if(!contains_text(combatState, "weaksauce") && have_skills($skills[Curse Of Weaksauce, Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
	{
		set_property("cc_combatHandler", combatState + "(weaksauce)");
		return "skill " + $skill[Curse Of Weaksauce];
	}

	if(!contains_text(combatState, "intimidating bellow") && cc_have_skill($skill[Intimidating Bellow]) && (my_mp() >= 25) && cc_have_skill($skill[Louder Bellows]))
	{
		set_property("cc_combatHandler", combatState + "(intimidating bellow)");
		return "skill " + $skill[Intimidating Bellow];
	}

	if(enemy == $monster[Eldritch Tentacle])
	{
		mcd = 151;
	}

	#Default behaviors:
	if(mcd <= 150)
	{
		if(!contains_text(combatState, "weaksauce") && have_skills($skills[Curse Of Weaksauce, Itchy Curse Finger]) && (my_mp() >= 60) && doWeaksauce)
		{
			set_property("cc_combatHandler", combatState + "(weaksauce)");
			return "skill " + $skill[Curse Of Weaksauce];
		}

		if($item[Daily Affirmation: Keep Free Hate In Your Heart].combat)
		{
			if(!contains_text(combatState, "freehate") && get_property("kingLiberated").to_boolean() && (item_amount($item[Daily Affirmation: Keep Free Hate In Your Heart]) > 0) && hippy_stone_broken() && !get_property("_affirmationHateUsed").to_boolean())
			{
				set_property("cc_combatHandler", combatState + "(freehate)");
				return "item " + $item[Daily Affirmation: Keep Free Hate In Your Heart];
			}
		}

		if(!contains_text(combatState, "canhandle") && cc_have_skill($skill[Canhandle]))
		{
			if($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand]))
			{
				set_property("cc_combatHandler", combatState + "(canhandle)");
				return "skill " + $skill[Canhandle];
			}
		}

		if(!contains_text(combatState, "weaksauce") && cc_have_skill($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 20))
		{
			set_property("cc_combatHandler", combatState + "(weaksauce)");
			return "skill " + $skill[Curse Of Weaksauce];
		}

		if(!contains_text(combatState, "pocket crumbs") && cc_have_skill($skill[Pocket Crumbs]))
		{
			set_property("cc_combatHandler", combatState + "(pocket crumbs)");
			return "skill " + $skill[Pocket Crumbs];
		}

		if(!contains_text(combatState, "micrometeorite") && cc_have_skill($skill[Micrometeorite]))
		{
			set_property("cc_combatHandler", combatState + "(micrometeorite)");
			return "skill " + $skill[Micrometeorite];
		}

		if(!contains_text(combatState, $item[Cow Poker]) && (item_amount($item[Cow Poker]) > 0))
		{
			if($monsters[Caugr, Moomy, Pharaoh Amoon-Ra Cowtep, Pyrobove, Spidercow] contains enemy)
			{
				set_property("cc_combatHandler", combatState + "(" + $item[Cow Poker] + ")");
				return "item " + $item[Cow Poker];
			}
		}

		if(!contains_text(combatState, $item[Western-Style Skinning Knife]) && (item_amount($item[Western-Style Skinning Knife]) > 0))
		{
			if($monsters[Caugr, Coal Snake, Diamondback Rattler, Frontwinder, Grizzled Bear, Mountain Lion] contains enemy)
			{
				set_property("cc_combatHandler", combatState + "(" + $item[Western-Style Skinning Knife] + ")");
				return "item " + $item[Western-Style Skinning Knife];
			}
		}

		if(!contains_text(combatState, "air dirty laundry") && cc_have_skill($skill[Air Dirty Laundry]))
		{
			set_property("cc_combatHandler", combatState + "(air dirty laundry)");
			return "skill " + $skill[Air Dirty Laundry];
		}

		if(!contains_text(combatState, "cowboy kick") && cc_have_skill($skill[Cowboy Kick]))
		{
			set_property("cc_combatHandler", combatState + "(cowboy kick)");
			return "skill " + $skill[Cowboy Kick];
		}

		if(!contains_text(combatState, "fire death ray") && cc_have_skill($skill[Fire Death Ray]))
		{
			set_property("cc_combatHandler", combatState + "(fire death ray)");
			return "skill " + $skill[Fire Death Ray];
		}

		if(!contains_text(combatState, "ply reality") && cc_have_skill($skill[ply reality]))
		{
			set_property("cc_combatHandler", combatState + "(ply reality)");
			return "skill " + $skill[Ply Reality];
		}

		if(!contains_text(combatState, "indigo cup") && (item_amount($item[rain-doh indigo cup]) > 0))
		{
			set_property("cc_combatHandler", combatState + "(indigo cup)");
			return "item " + $item[Rain-Doh Indigo Cup];
		}

		if(!contains_text(combatState, "love mosquito") && cc_have_skill($skill[Summon Love Mosquito]))
		{
			set_property("cc_combatHandler", combatState + "(love mosquito)");
			return "skill " + $skill[Summon Love Mosquito];
		}
		if(!contains_text(combatState, "tomayohawk") && (item_amount($item[Tomayohawk-Style Reflex Hammer]) > 0))
		{
			set_property("cc_combatHandler", combatState + "(tomayohawk)");
			return "item " + $item[Tomayohawk-Style Reflex Hammer];
		}

		if(!contains_text(combatState, "cadenza") && (item_type(equipped_item($slot[weapon])) == "accordion") && (my_mp() >= mp_cost($skill[Cadenza])))
		{
			if($items[Accordion of Jordion, Accordionoid Rocca, non-Euclidean non-accordion, Shakespeare\'s Sister\'s Accordion, zombie accordion] contains equipped_item($slot[weapon]))
			{
				set_property("cc_combatHandler", combatState + "(cadenza)");
				return "item " + $skill[Cadenza];
			}
		}

		if(!contains_text(combatState, "(extract)") && cc_have_skill($skill[Extract]) && (my_mp() > (mp_cost($skill[Extract]) * 3)) && (item_amount($item[Source Essence]) <= 60))
		{
			set_property("cc_combatHandler", combatState + "(extract)");
			return "skill " + $skill[Extract];
		}

		if(!contains_text(combatState, "(extract jelly)") && cc_have_skill($skill[Extract Jelly]) && (my_mp() > (mp_cost($skill[Extract Jelly]) * 3)) && canSurvive(2.0) && (my_familiar() == $familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 3) && ($elements[hot, spooky, stench] contains monster_element(enemy)))
		{
			set_property("cc_combatHandler", combatState + "(extract jelly)");
			return "skill " + $skill[Extract Jelly];
		}

		if(!contains_text(combatState, "(scienceMedicine)") && cc_have_skill($skill[Science! Fight With Medicine]) && ((my_hp() * 2) < my_maxhp()))
		{
			set_property("cc_combatHandler", combatState + "(scienceMedicine)");
			return "skill " + $skill[Science! Fight With Medicine];
		}
		if(!contains_text(combatState, "(rationalThought)") && cc_have_skill($skill[Science! Fight With Rational Thought]) && (have_effect($effect[Rational Thought]) < 10))
		{
			set_property("cc_combatHandler", combatState + "(rationalThought)");
			return "skill " + $skill[Science! Fight With Rational Thought];
		}

		if(!contains_text(combatState, "(time-spinner)") && (item_amount($item[Time-Spinner]) > 0))
		{
			set_property("cc_combatHandler", combatState + "(time-spinner)");
			return "item " + $item[Time-Spinner];
		}

		if(!contains_text(combatState, "(sing along)") && cc_have_skill($skill[Sing Along]) && (my_mp() > (mp_cost($skill[Sing Along]))) && (get_property("_boomBoxSong") == "Remainin\' Alive"))
		{
			set_property("cc_combatHandler", combatState + "(sing along)");
			return "skill " + $skill[Sing Along];
		}

		if(!contains_text(combatState, "(sing along)") && cc_have_skill($skill[Sing Along]) && (my_mp() > (mp_cost($skill[Sing Along]))) && canSurvive(2.5) && (get_property("_boomBoxSong") == "Total Eclipse of Your Meat"))
		{
			set_property("cc_combatHandler", combatState + "(sing along)");
			return "skill " + $skill[Sing Along];
		}
	}

	#Default behaviors, multi-staggers when chance is 50% or greater
	if(mcd < 100)
	{
		if(!contains_text(combatState, "blue balls") && (item_amount($item[rain-doh blue balls]) > 0))
		{
			set_property("cc_combatHandler", combatState + "(blue balls)");
			return "item " + $item[Rain-Doh Blue Balls];
		}

		if(!contains_text(combatState, "love gnats") && cc_have_skill($skill[Summon Love Gnats]))
		{
			set_property("cc_combatHandler", combatState + "(love gnats)");
			return "skill " + $skill[Summon Love Gnats];
		}

		if(!contains_text(combatState, "love stinkbug") && contains_text(combatState, "love gnats") && !contains_text(text, "STUN RESIST") && cc_have_skill($skill[Summon Love Stinkbug]))
		{
			set_property("cc_combatHandler", combatState + "(love stinkbug)");
			return "skill " + $skill[Summon Love Stinkbug];
		}

		if(!contains_text(combatState, "(sing along)") && cc_have_skill($skill[Sing Along]) && (my_mp() > (mp_cost($skill[Sing Along]))))
		{
			if((get_property("_boomBoxSong") == "Remainin\' Alive") || (get_property("_boomBoxSong") == "Total Eclipse of Your Meat"))
			{
				set_property("cc_combatHandler", combatState + "(sing along)");
				return "skill " + $skill[Sing Along];
			}
		}
	}

	if((my_location() == $location[Super Villain\'s Lair]) && (cc_my_path() == "License to Adventure") && canSurvive(2.0) && (enemy == $monster[Villainous Minion]))
	{
		if(!get_property("_villainLairCanLidUsed").to_boolean() && (item_amount($item[Razor-Sharp Can Lid]) > 0))
		{
			return "item " + $item[Razor-Sharp Can Lid];
		}
		if(!get_property("_villainLairWebUsed").to_boolean() && (item_amount($item[Spider Web]) > 0))
		{
			return "item " + $item[Spider Web];
		}
		if(!get_property("_villainLairFirecrackerUsed").to_boolean() && (item_amount($item[Knob Goblin Firecracker]) > 0))
		{
			return "item " + $item[Knob Goblin Firecracker];
		}
	}

	if(!contains_text(combatState, "portscan") && cc_have_skill($skill[Portscan]) && (my_location().turns_spent < 8) && (get_property("_sourceTerminalPortscanUses").to_int() < 3) && (my_mp() > mp_cost($skill[Portscan])) && !get_property("_portscanPending").to_boolean())
	{
		if($locations[The Castle in the Clouds in the Sky (Ground Floor), The Haunted Bathroom, The Haunted Gallery] contains my_location())
		{
			set_property("cc_combatHandler", combatState + "(portscan)");
			set_property("_portscanPending", true);
			return "skill " + $skill[Portscan];
		}
	}

	if(!contains_text(combatState, "candyblast") && cc_have_skill($skill[Candyblast]) && (my_mp() > 60) && get_property("kingLiberated").to_boolean())
	{
		# We can get only one candy and we can detect it, if so desired:
		# "Hey, some of it is even intact afterwards!"
		set_property("cc_combatHandler", combatState + "(candyblast)");
		return "skill " + $skill[Candyblast];
	}



	if(!contains_text(combatState, "spirit snap") && (my_class() == $class[Turtle Tamer]) && (cc_have_skill($skill[Spirit Snap]) && (my_mp() > 80)))
	{
		if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
		{
			set_property("cc_combatHandler", combatState + "(spirit snap)");
			return "skill " + $skill[Spirit Snap];
		}
	}

	if(!contains_text(combatState, "stuffedmortarshell") && (my_class() == $class[Sauceror]) && canSurvive(2.0) && cc_have_skill($skill[Stuffed Mortar Shell]) && (my_mp() > mp_cost($skill[Stuffed Mortar Shell])))
	{
		set_property("cc_combatHandler", combatState + "(stuffedmortarshell)");
		return "skill " + $skill[Stuffed Mortar Shell];
	}

	if(!contains_text(combatState, "duplicate") && cc_have_skill($skill[Duplicate]) && (my_mp() > mp_cost($skill[Duplicate])) && (get_property("_sourceTerminalDuplicateUses").to_int() == 0) && !get_property("kingLiberated").to_boolean() && (cc_my_path() != "Nuclear Autumn"))
	{
		if($monsters[Dairy Goat, Gaudy Pirate] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(duplicate)");
			return "skill " + $skill[Duplicate];
		}
	}

	if(!contains_text(combatState, "explodingcigar") && contains_text(combatState, "duplicate") && (item_amount($item[Exploding Cigar]) > 0))
	{
		set_property("cc_combatHandler", combatState + "(explodingcigar)");
		return "item " + $item[Exploding Cigar];
	}

	if(contains_text(combatState, "duplicate") && cc_have_skill($skill[Gelatinous Kick]) && (my_mp() > mp_cost($skill[Gelatinous Kick])))
	{
		if($monsters[Dairy Goat, Gaudy Pirate] contains enemy)
		{
			return "skill " + $skill[Gelatinous Kick];
		}
	}

	if(!contains_text(combatState, "weaksauce") && cc_have_skill($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 32))
	{
		set_property("cc_combatHandler", combatState + "(weaksauce)");
		return "skill " + $skill[Curse Of Weaksauce];
	}

	if(!contains_text(combatState, "weaksauce") && cc_have_skill($skill[Curse Of Weaksauce]) && (my_class() == $class[Sauceror]) && (my_mp() >= 8) && contains_text(combatState, "stuffedmortarshell"))
	{
		set_property("cc_combatHandler", combatState + "(weaksauce)");
		return "skill " + $skill[Curse Of Weaksauce];
	}

	if(!contains_text(combatState, "digitize") && cc_have_skill($skill[Digitize]) && (my_mp() > mp_cost($skill[Digitize])) && (get_property("_sourceTerminalDigitizeUses").to_int() == 0) && !get_property("kingLiberated").to_boolean())
	{
		if($monsters[Ninja Snowman Assassin, Lobsterfrogman, Writing Desk] contains enemy)
		{
			if(get_property("_sourceTerminalDigitizeMonster") != enemy)
			{
				set_property("cc_combatHandler", combatState + "(digitize)");
				return "skill " + $skill[Digitize];
			}
		}
	}

	if(!contains_text(combatState, "digitize") && cc_have_skill($skill[Digitize]) && (my_mp() > mp_cost($skill[Digitize])) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3) && !get_property("kingLiberated").to_boolean())
	{
		if(get_property("cc_digitizeDirective") == enemy)
		{
			if(get_property("_sourceTerminalDigitizeMonster") != enemy)
			{
				set_property("cc_combatHandler", combatState + "(digitize)");
				return "skill " + $skill[Digitize];
			}
		}
	}

	if( (enemy == $monster[LOV Enforcer]) && have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
	{
		return "skill " + $skill[Saucestorm];
	}


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
		if(cc_have_skill($skill[Lunge Smack]) && (my_mp() >= mp_cost($skill[Lunge Smack])) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMinor = "skill " + $skill[Lunge Smack];
			costMinor = mp_cost($skill[Lunge Smack]);
		}
		if(cc_have_skill($skill[lunging thrust-smack]) && (my_mp() >= mp_cost($skill[Lunging Thrust-Smack])) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			attackMajor = "skill " + $skill[Lunging Thrust-Smack];
			costMajor = mp_cost($skill[Lunging Thrust-Smack]);
		}
		if(cc_have_skill($skill[Club Foot]) && (my_mp() >= mp_cost($skill[Club Foot])))
		{
			stunner = "skill " + $skill[Club Foot];
			costStunner = mp_cost($skill[Club Foot]);
		}
		break;
	case $class[Turtle Tamer]:
		attackMinor = "attack with weapon";
		if((my_mp() > 150) && (cc_have_skill($skill[shieldbutt])) && hasShieldEquipped())
		{
			attackMinor = "skill shieldbutt";
			costMinor = mp_cost($skill[Shieldbutt]);
		}
		else if((my_mp() > 80) && ((my_hp() * 2) < my_maxhp()) && cc_have_skill($skill[Kneebutt]))
		{
			attackMinor = "skill kneebutt";
			costMinor = mp_cost($skill[Kneebutt]);
		}
		if(((round > 15) || ((my_hp() * 2) < my_maxhp())) && cc_have_skill($skill[Kneebutt]))
		{
			attackMajor = "skill kneebutt";
			costMajor = mp_cost($skill[Kneebutt]);
		}
		if((cc_have_skill($skill[shieldbutt])) && hasShieldEquipped() && (my_mp() >= mp_cost($skill[Shieldbutt])))
		{
			attackMajor = "skill shieldbutt";
			costMajor = mp_cost($skill[Shieldbutt]);
		}
		if(cc_have_skill($skill[Shell Up]) && (my_mp() >= mp_cost($skill[Shell Up])))
		{
			stunner = "skill shell up";
			costStunner = mp_cost($skill[Shell Up]);
		}

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && cc_have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;
	case $class[Pastamancer]:
		if((my_mp() >= mp_cost($skill[Cannelloni Cannon])) && (cc_have_skill($skill[Cannelloni Cannon])))
		{
			attackMinor = "skill Cannelloni Cannon";
			costMinor = mp_cost($skill[Cannelloni Cannon]);
		}
		if((my_mp() >= mp_cost($skill[Weapon of the Pastalord])) && (cc_have_skill($skill[Weapon of the Pastalord])))
		{
			attackMajor = "skill Weapon of the Pastalord";
			costMajor = mp_cost($skill[Weapon of the Pastalord]);
		}
		if((my_mp() >= mp_cost($skill[Saucestorm])) && (cc_have_skill($skill[Saucestorm])))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			attackMinor = "skill " + $skill[Saucestorm];
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		if((my_mp() >= 1) && cc_have_skill($skill[Utensil Twist]) && (item_type(equipped_item($slot[weapon])) == "utensil"))
		{
			if(equipped_item($slot[weapon]) == $item[Hand That Rocks the Ladle])
			{
				attackMajor = "skill " + $skill[Utensil Twist];
				attackMinor = "skill " + $skill[Utensil Twist];
				costMinor = mp_cost($skill[Utensil Twist]);
				costMajor = mp_cost($skill[Utensil Twist]);
			}
			else if((enemy.physical_resistance <= 80) && (attackMinor != ("skill " + $skill[Saucestorm])))
			{
				attackMinor = "skill " + $skill[Utensil Twist];
				costMinor = mp_cost($skill[Utensil Twist]);
			}
		}
		if(cc_have_skill($skill[Entangling Noodles]) && (my_mp() >= mp_cost($skill[Entangling Noodles])))
		{
			stunner = "skill entangling noodles";
			costStunner = mp_cost($skill[Entangling Noodles]);
		}
		break;
	case $class[Sauceror]:
		if((my_mp() >= mp_cost($skill[Saucegeyser])) && cc_have_skill($skill[Saucegeyser]))
		{
			attackMinor = "skill saucegeyser";
			attackMajor = "skill saucegeyser";
			costMinor = mp_cost($skill[Saucegeyser]);
			costMajor = mp_cost($skill[Saucegeyser]);
		}
		else if((my_mp() >= mp_cost($skill[Saucecicle])) && cc_have_skill($skill[Saucecicle]) && (monster_element(enemy) != $element[cold]))
		{
			attackMinor = "skill saucecicle";
			attackMajor = "skill saucecicle";
			costMinor = mp_cost($skill[Saucecicle]);
			costMajor = mp_cost($skill[Saucecicle]);
		}
		else if((my_mp() >= mp_cost($skill[Saucestorm])) && (cc_have_skill($skill[Saucestorm])))
		{
			attackMinor = "skill saucestorm";
			attackMajor = "skill saucestorm";
			costMinor = mp_cost($skill[Saucestorm]);
			costMajor = mp_cost($skill[Saucestorm]);
		}
		else if((my_mp() >= mp_cost($skill[Wave of Sauce])) && cc_have_skill($skill[Wave of Sauce]) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = "skill wave of sauce";
			attackMajor = "skill wave of sauce";
			costMinor = mp_cost($skill[Wave of Sauce]);
			costMajor = mp_cost($skill[Wave of Sauce]);
		}
		else if((my_mp() >= mp_cost($skill[Stream of Sauce])) && cc_have_skill($skill[Stream of Sauce]) && (monster_element(enemy) != $element[hot]))
		{
			attackMinor = "skill stream of sauce";
			attackMajor = "skill stream of sauce";
			costMinor = mp_cost($skill[Stream of Sauce]);
			costMajor = mp_cost($skill[Stream of Sauce]);
		}

		if(my_soulsauce() >= 5)
		{
			stunner = "skill soul bubble";
			costStunner = mp_cost($skill[Soul Bubble]);
		}

		if(!contains_text(combatState, "delaymortarshell") && contains_text(combatState, "stuffedmortarshell") && (my_class() == $class[Sauceror]) && canSurvive(2.0) && cc_have_skill($skill[Stuffed Mortar Shell]) && cc_have_skill($skill[Salsaball]) && (my_mp() > mp_cost($skill[Salsaball])))
		{
			set_property("cc_combatHandler", combatState + "(delaymortarshell)");
			return "skill salsaball";
		}

		break;

	case $class[Avatar of Boris]:
		if((my_mp() >= mp_cost($skill[Heroic Belch])) && cc_have_skill($skill[Heroic Belch]) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && (my_fullness() >= 5))
		{
			attackMinor = "skill " + $skill[Heroic Belch];
			attackMajor = "skill " + $skill[Heroic Belch];
			costMinor = mp_cost($skill[Heroic Belch]);
			costMajor = mp_cost($skill[Heroic Belch]);
		}

		if((my_mp() >= mp_cost($skill[Broadside])) && cc_have_skill($skill[Broadside]))
		{
			stunner = "skill " + $skill[Broadside];
			costStunner = mp_cost($skill[Broadside]);
		}
		break;

	case $class[Avatar of Sneaky Pete]:
		if(!contains_text(combatState, to_string($skill[Peel Out])) && cc_have_skill($skill[Peel Out]) && (my_mp() > mp_cost($skill[Peel Out])))
		{
			if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, Tomb Asp, Tomb Servant,  W imp] contains enemy)
			{
				set_property("cc_combatHandler", combatState + "(" + $skill[Peel Out] + ")");
				return "skill " + $skill[Peel Out];
			}
		}


		if((item_amount($item[Firebomb]) > 0) && (enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]))
		{
			return "item " + $item[Firebomb];
		}

		if(!contains_text(combatState, to_string($skill[Pop Wheelie])) && cc_have_skill($skill[Pop Wheelie]) && (my_mp() > 40))
		{
			set_property("cc_combatHandler", combatState + "(" + $skill[Pop Wheelie] + ")");
			return "skill " + $skill[Pop Wheelie];
		}

		if(!contains_text(combatState, to_string($skill[Snap Fingers])) && cc_have_skill($skill[Snap Fingers]) && (my_mp() >= mp_cost($skill[Snap Fingers])))
		{
			stunner = $skill[Snap Fingers];
			costStunner = mp_cost($skill[Snap Fingers]);
		}

		break;

	case $class[Accordion Thief]:

		if(!contains_text(combatState, "cadenza") && (item_type(equipped_item($slot[weapon])) == "accordion") && (my_mp() >= mp_cost($skill[Cadenza])) && canSurvive(2.0))
		{
			if($items[accordion file, alarm accordion, autocalliope, bal-musette accordion, baritone accordion, cajun accordion, ghost accordion, peace accordion, pentatonic accordion, pygmy concertinette, skipper\'s accordion, squeezebox of the ages, the trickster\'s trikitixa] contains equipped_item($slot[weapon]))
			{
				set_property("cc_combatHandler", combatState + "(cadenza)");
				return "item " + $skill[Cadenza];
			}
		}

		if(cc_have_skill($skill[Accordion Bash]) && (my_mp() >= mp_cost($skill[Accordion Bash])) && (item_type(equipped_item($slot[weapon])) == "accordion"))
		{
			stunner = "skill " + $skill[Accordion Bash];
			costStunner = mp_cost($skill[Accordion Bash]);
		}

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && cc_have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			costMajor = mp_cost($skill[Saucestorm]);
		}

		break;

	case $class[Disco Bandit]:

		// I have no idea how Disco Bandits fight, even less than AT.

		if(((monster_defense() - my_buffedstat(my_primestat())) > 20) && cc_have_skill($skill[Saucestorm]) && (my_mp() >= mp_cost($skill[Saucestorm])))
		{
			attackMajor = "skill " + $skill[Saucestorm];
			costMajor = mp_cost($skill[Saucestorm]);
		}
		break;

	case $class[Cow Puncher]:
	case $class[Beanslinger]:
	case $class[Snake Oiler]:
		if(!contains_text(combatState, "extractSnakeOil") && (my_hp() > 80) && cc_have_skill($skill[Extract Oil]) && (my_mp() >= (3 * mp_cost($skill[Extract Oil]))))
		{
			if($monsters[Aggressive grass snake, Bacon snake, Batsnake, Black adder, Burning Snake of Fire, Coal snake, Diamondback rattler, Frontwinder, Frozen Solid Snake, King snake, Licorice snake, Mutant rattlesnake, Prince snake, Sewer snake with a sewer snake in it, Snakeleton, The Snake with Like Ten Heads, Tomb asp, Trouser Snake, Whitesnake] contains enemy)
			{

			}
			else if(($phylums[beast, dude, hippy, humanoid, orc, pirate] contains type) && (item_amount($item[Skin Oil]) < 3))
			{
				set_property("cc_combatHandler", combatState + "(extractSnakeOil)");
				return "skill " + $skill[Extract Oil];
			}
			else if(($phylums[bug, construct, constellation, demon, elemental, elf, fish, goblin, hobo, horror, mer-kin, penguin, plant, slime, weird] contains type) && (item_amount($item[Unusual Oil]) < 4))
			{
				set_property("cc_combatHandler", combatState + "(extractSnakeOil)");
				return "skill " + $skill[Extract Oil];
			}
			else if(($phylums[undead] contains type) && (item_amount($item[Skin Oil]) < 5))
			{
				set_property("cc_combatHandler", combatState + "(extractSnakeOil)");
				return "skill " + $skill[Extract Oil];
			}
		}
		if(!contains_text(combatState, "goodMedicine") && cc_have_skill($skill[Good Medicine]) && (my_mp() >= (3 * mp_cost($skill[Good Medicine]))))
		{
			set_property("cc_combatHandler", combatState + "(goodMedicine)");
			return "skill " + $skill[Good Medicine];
		}

		if(!contains_text(combatState, "hogtie") && cc_have_skill($skill[Hogtie]) && (my_mp() >= (6 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			set_property("cc_combatHandler", combatState + "(hogtie)");
			return  "skill " + $skill[Hogtie];
		}


		if(cc_have_skill($skill[One-Two Punch]) && (my_mp() >= mp_cost($skill[One-Two Punch])) && (equipped_item($slot[Weapon]) == $item[none]))
		{
//			attackMajor = "skill " + $skill[One-Two Punch];
//			attackMinor = "skill " + $skill[One-Two Punch];
//			costMajor = mp_cost($skill[One-Two Punch]);
//			costMinor = mp_cost($skill[One-Two Punch]);
			//This does not seem to work.
		}



		if(cc_have_skill($skill[Lavafava]) && (my_mp() >= mp_cost($skill[Lavafava])) && (enemy.defense_element != $element[hot]))
		{
			attackMajor = "skill " + $skill[Lavafava];
			attackMinor = "skill " + $skill[Lavafava];
			costMajor = mp_cost($skill[Lavafava]);
			costMinor = mp_cost($skill[Lavafava]);
		}
		if(cc_have_skill($skill[Beanstorm]) && (my_mp() >= mp_cost($skill[Beanstorm])))
		{
			attackMajor = "skill " + $skill[Beanstorm];
			attackMinor = "skill " + $skill[Beanstorm];
			costMajor = mp_cost($skill[Beanstorm]);
			costMinor = mp_cost($skill[Beanstorm]);
		}

		if(cc_have_skill($skill[Fan Hammer]) && (my_mp() >= mp_cost($skill[Fan Hammer])))
		{
			attackMajor = "skill " + $skill[Fan Hammer];
			attackMinor = "skill " + $skill[Fan Hammer];
			costMajor = mp_cost($skill[Fan Hammer]);
			costMinor = mp_cost($skill[Fan Hammer]);
		}
		if(cc_have_skill($skill[Snakewhip]) && (my_mp() >= mp_cost($skill[Snakewhip])) && (enemy.physical_resistance < 80))
		{
			attackMajor = "skill " + $skill[Snakewhip];
			attackMinor = "skill " + $skill[Snakewhip];
			costMajor = mp_cost($skill[Snakewhip]);
			costMinor = mp_cost($skill[Snakewhip]);
		}

		if(cc_have_skill($skill[Pungent Mung]) && (my_mp() >= mp_cost($skill[Pungent Mung])) && (enemy.defense_element != $element[stench]))
		{
			attackMajor = "skill " + $skill[Pungent Mung];
			attackMinor = "skill " + $skill[Pungent Mung];
			costMajor = mp_cost($skill[Pungent Mung]);
			costMinor = mp_cost($skill[Pungent Mung]);
		}

		if(cc_have_skill($skill[Cowcall]) && (my_mp() >= mp_cost($skill[Cowcall])) && (type != $phylum[undead]) && (enemy.defense_element != $element[spooky]) && (have_effect($effect[Cowrruption]) >= 60))
		{
			attackMajor = "skill " + $skill[Cowcall];
			attackMinor = "skill " + $skill[Cowcall];
			costMajor = mp_cost($skill[Cowcall]);
			costMinor = mp_cost($skill[Cowcall]);
		}

		if(cc_have_skill($skill[Cowcall]) && (my_mp() >= mp_cost($skill[Cowcall])) && (type != $phylum[undead]) && (enemy.defense_element != $element[spooky]) && (my_class() == $class[Cow Puncher]))
		{
			attackMajor = "skill " + $skill[Cowcall];
			attackMinor = "skill " + $skill[Cowcall];
			costMajor = mp_cost($skill[Cowcall]);
			costMinor = mp_cost($skill[Cowcall]);
		}

		if(cc_have_skill($skill[Beanscreen]) && (my_mp() >= mp_cost($skill[Beanscreen])) && canSurvive(2.0))
		{
			stunner = "skill " + $skill[Beanscreen];
			costStunner = mp_cost($skill[Beanscreen]);
		}

		if(cc_have_skill($skill[Hogtie]) && (my_mp() >= (3 * mp_cost($skill[Hogtie]))) && hasLeg(enemy))
		{
			stunner = "skill " + $skill[Hogtie];
			costStunner = mp_cost($skill[Hogtie]);
		}
		break;
	}

	if(round <= 25)
	{
		if(((my_hp() * 10)/3) < my_maxhp())
		{
			if(!contains_text(combatState, "thunderstrike") && cc_have_skill($skill[Thunderstrike]) && (monster_level_adjustment() <= 150))
			{
				set_property("cc_combatHandler", combatState + "(thunderstrike)");
				return "skill " + $skill[Thunderstrike];
			}

			if(!contains_text(combatState, "stunner") && (stunner != "") && (monster_level_adjustment() <= 50) && (my_mp() >= costStunner))
			{
				set_property("cc_combatHandler", combatState + "(stunner)");
				return stunner;
			}

			if(cc_have_skill($skill[Unleash The Greash]) && (monster_element(enemy) != $element[sleaze]) && (have_effect($effect[Takin\' It Greasy]) > 100))
			{
				return "skill " + $skill[Unleash The Greash];
			}
			if(cc_have_skill($skill[Thousand-Yard Stare]) && (monster_element(enemy) != $element[spooky]) && (have_effect($effect[Intimidating Mien]) > 100))
			{
				return "skill " + $skill[Thousand-Yard Stare];
			}
			if($monsters[Aquagoblin, Lord Soggyraven] contains enemy)
			{
				return attackMajor;
			}
			if((my_class() == $class[Turtle Tamer]) && (my_mp() >= mp_cost($skill[Spirit Snap])) && cc_have_skill($skill[Spirit Snap]) && !contains_text(combatState, "spirit snap"))
			{
				if((have_effect($effect[Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the Storm Tortoise]) > 0) || (have_effect($effect[Glorious Blessing of the War Snapper]) > 0) || (have_effect($effect[Glorious Blessing of She-Who-Was]) > 0))
				{
					set_property("cc_combatHandler", combatState + "(spirit snap)");
					return "skill " + $skill[Spirit Snap];
				}
			}
			if(!contains_text(combatState, "northern explosion") && cc_have_skill($skill[Northern Explosion]) && (my_mp() >= mp_cost($skill[Northern Explosion])) && (my_class() == $class[Seal Clubber]) && (monster_element(enemy) != $element[cold]))
			{
				set_property("cc_combatHandler", combatState + "(northern explosion)");
				return "skill " + $skill[Northern Explosion];
			}
			if((!contains_text(combatState, "last attempt")) && (my_mp() >= costMajor))
			{
				if(canSurvive(1.4))
				{
					set_property("cc_combatHandler", combatState + "(last attempt)");
					print("Uh oh, I'm having trouble in combat.", "red");
				}
				return attackMajor;
			}
			if(canSurvive(2.5))
			{
				print("Hmmm, I don't really know what to do in this combat but it looks like I'll live.", "red");
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
		if((monster_level_adjustment() > 150) && (my_mp() >= 45) && cc_have_skill($skill[Shell Up]) && !contains_text(combatState, "shellup") && (my_class() == $class[Turtle Tamer]))
		{
			set_property("cc_combatHandler", combatState + "(shellup)");
			return "skill " + $skill[Shell Up];
		}

		if(attackMinor == "attack with weapon")
		{
			if(!contains_text(combatState, "love stinkbug") && cc_have_skill($skill[Summon Love Stinkbug]))
			{
				set_property("cc_combatHandler", combatState + "(love stinkbug)");
				return "skill " + $skill[Summon Love Stinkbug];
			}
			if(cc_have_skill($skill[Mighty Axing]) && (equipped_item($slot[Weapon]) != $item[none]))
			{
				return "skill " + $skill[Mighty Axing];
			}
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[cold]) && cc_have_skill($skill[Throat Refrigerant]) && (my_mp() >= mp_cost($skill[Throat Refrigerant])))
		{
			return "skill " + $skill[Throat Refrigerant];
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[hot]) && cc_have_skill($skill[Boiling Tear Ducts]) && (my_mp() >= mp_cost($skill[Boiling Tear Ducts])))
		{
			return "skill " + $skill[Boiling Tear Ducts];
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[sleaze]) && cc_have_skill($skill[Projectile Salivary Glands]) && (my_mp() >= mp_cost($skill[Projectile Salivary Glands])))
		{
			return "skill " + $skill[Projectile Salivary Glands];
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[spooky]) && cc_have_skill($skill[Translucent Skin]) && (my_mp() >= mp_cost($skill[Translucent Skin])))
		{
			return "skill " + $skill[Translucent Skin];
		}

		if((enemy.physical_resistance >= 100) && (monster_element(enemy) != $element[stench]) && cc_have_skill($skill[Skunk Glands]) && (my_mp() >= mp_cost($skill[Skunk Glands])))
		{
			return "skill " + $skill[Skunk Glands];
		}

		if((my_location() == $location[The X-32-F Combat Training Snowman]) && contains_text(text, "Cattle Prod") && (my_mp() >= costMajor))
		{
			return attackMajor;
		}

		if((monster_level_adjustment() > 150) && (my_mp() >= costMajor) && (attackMajor != "attack with weapon"))
		{
			return attackMajor;
		}
		if(cc_have_skill($skill[Lunge Smack]) && (my_mp() >= mp_cost($skill[Lunge Smack])) && (attackMinor != "attack with weapon") && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
		{
			return attackMinor;
		}
		if((my_mp() >= costMinor) && (attackMinor != "attack with weapon"))
		{
			return attackMinor;
		}

		if((round > 20) && (my_mp() >= mp_cost($skill[Saucestorm])) && cc_have_skill($skill[Saucestorm]))
		{
			return "skill " + $skill[Saucestorm];
		}

		return "attack with weapon";
	}
	else
	{
		abort("Some sort of problem occurred, it is past round 25 but we are still in non-gremlin combat...");
	}

	if(attackMinor == "attack with weapon")
	{
		if(!contains_text(combatState, "love stinkbug") && cc_have_skill($skill[Summon Love Stinkbug]))
		{
			set_property("cc_combatHandler", combatState + "(love stinkbug)");
			return "skill " + $skill[Summon Love Stinkbug];
		}
	}

	return attackMinor;
#	return get_ccs_action(round);
}

string findBanisher(int round, string opp, string text)
{
	print("In findBanisher for: " + opp, "green");
	monster enemy = to_monster(opp);

	foreach itm in $items[Louder Than Bomb, Tennis Ball]
	{
		if(!contains_text(get_property("cc_gremlinBanishes"), itm) && (item_amount(itm) > 0))
		{
			set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + itm + ")");
			handleTracker(enemy, itm, "cc_banishes");
			return "item " + itm;
		}
	}

	foreach act in $skills[Banishing Shout, Asdon Martin: Spring-Loaded Front Bumper, Talk About Politics, Batter Up!, Thunder Clap, Curse of Vacation, Breathe Out, Snokebomb, KGB Tranquilizer Dart, Beancannon]
	{
		if((!contains_text(get_property("cc_gremlinBanishes"), act)) && cc_have_skill(act) && (my_mp() >= mp_cost(act)) && (my_thunder() >= thunder_cost(act)) && (get_fuel() >= fuel_cost(act)))
		{
			if(act == $skill[Banishing Shout])
			{
				handleTracker(enemy, act, "cc_banishes");
				return "skill " + act;
			}
			if((act == $skill[Batter Up!]) && ((my_fury() < 5) || (item_type(equipped_item($slot[weapon])) != "club")))
			{
				continue;
			}
			if((act == $skill[Asdon Martin: Spring-Loaded Front Bumper]) && contains_text(get_property("banishedMonsters"),"Spring-Loaded Front Bumper"))
			{
				continue;
			}
			if((act == $skill[Talk About Politics]) && (get_property("_pantsgivingBanish").to_int() >= 5))
			{
				continue;
			}
			if((act == $skill[Beancannon]) && (get_property("_beancannonUses").to_int() >= 5))
			{
				continue;
			}
			if((act == $skill[Beancannon]) && !($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand])))
			{
				continue;
			}
			if((act == $skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() >= 3))
			{
				continue;
			}
			set_property("cc_gremlinBanishes", get_property("cc_gremlinBanishes") + "(" + act + ")");
			handleTracker(enemy, act, "cc_banishes");
			return "skill " + act;
		}
	}

//	if(cc_have_skill($skill[Lunging Thrust-Smack]) && (my_mp() >= mp_cost($skill[Lunging Thrust-Smack])))
//	{
//		return "skill lunging thrust-smack";
//	}
	if(cc_have_skill($skill[Storm of the Scarab]) && (my_mp() >= mp_cost($skill[Storm of the Scarab])))
	{
		return "skill Storm of the Scarab";
	}
	return cc_combatHandler(round, opp, text);
//	if(cc_have_skill($skill[Lunge Smack]) && (my_mp() >= mp_cost($skill[Lunge Smack])) && (weapon_type(equipped_item($slot[weapon])) == $stat[Muscle]))
//	{
//		return "skill lunge smack";
//	}
//	return "attack with weapon";
}

string ccsJunkyard(int round, string opp, string text)
{
	monster enemy = to_monster(opp);

	if(!($monsters[A.M.C. gremlin, batwinged gremlin, erudite gremlin, spider gremlin, vegetable gremlin] contains enemy))
	{
		return cc_combatHandler(round, opp, text);
	}

	if(round == 0)
	{
		print("ccsJunkyard: " + round, "brown");
		set_property("cc_gremlinMoly", true);
		set_property("cc_combatHandler", "");
	}
	else
	{
		print("cc_Junkyard: " + round, "brown");
	}
	string combatState = get_property("cc_combatHandler");
	string edCombatState = get_property("cc_edCombatHandler");

	if(my_class() == $class[Ed])
	{
		if(contains_text(edCombatState, "gremlinNeedBanish"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}

	if(enemy == $monster[A.M.C. gremlin])
	{
		set_property("cc_gremlinMoly", false);
	}

	if(my_location() == $location[Next To That Barrel With Something Burning In It])
	{
		if(enemy == $monster[vegetable gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "It does a bombing run over your head"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Out By That Rusted-Out Car])
	{
		if(enemy == $monster[erudite gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "It picks a beet off of itself and beats you with it"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Over Where The Old Tires Are])
	{
		if(enemy == $monster[spider gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "He uses the random junk around him"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}
	else if(my_location() == $location[Near an Abandoned Refrigerator])
	{
		if(enemy == $monster[batwinged gremlin])
		{
			set_property("cc_gremlinMoly", false);
		}
		else if(contains_text(text, "It bites you in the fibula with its mandibles"))
		{
			set_property("cc_gremlinMoly", false);
		}
	}

	if(!contains_text(edCombatState, "gremlinNeedBanish") && !get_property("cc_gremlinMoly").to_boolean() && (my_class() == $class[Ed]))
	{
		set_property("cc_edCombatHandler", "(gremlinNeedBanish)");
	}

	if(round >= 28)
	{
		if(cc_have_skill($skill[Lunging Thrust-Smack]) && (my_mp() >= 8))
		{
			return "skill " + $skill[Lunging Thrust-Smack];
		}
		return "attack with weapon";
	}

	if(contains_text(text, "It whips out a hammer") || contains_text(text, "He whips out a crescent") || contains_text(text, "It whips out a pair") || contains_text(text, "It whips out a screwdriver"))
	{
		return "item " + $item[Molybdenum Magnet];
	}

	if(!contains_text(combatState, "weaksauce") && cc_have_skill($skill[Curse Of Weaksauce]) && (my_mp() >= mp_cost($skill[Curse Of Weaksauce])))
	{
		set_property("cc_combatHandler", combatState + "(weaksauce)");
		return "skill " + $skill[Curse Of Weaksauce];
	}

	if(!contains_text(combatState, "marshmallow") && cc_have_skill($skill[Curse Of The Marshmallow]) && (my_mp() > mp_cost($skill[Curse Of The Marshmallow])))
	{
		set_property("cc_combatHandler", combatState + "(marshmallow)");
		return "skill " + $skill[Curse Of The Marshmallow];
	}
	if(!contains_text(combatState, "love scarab") && cc_have_skill($skill[Summon Love Scarabs]))
	{
		set_property("cc_combatHandler", combatState + "(love scarab)");
		return "skill " + $skill[Summon Love Scarabs];
	}
	if(!contains_text(combatState, "love gnats") && cc_have_skill($skill[Summon Love Gnats]))
	{
		set_property("cc_combatHandler", combatState + "(love gnats)");
		return "skill " + $skill[Summon Love Gnats];
	}

	if(!contains_text(combatState, "badMedicine") && cc_have_skill($skill[Bad Medicine]) && (my_mp() >= mp_cost($skill[Bad Medicine])))
	{
		set_property("cc_combatHandler", combatState + "(badMedicine)");
		return "skill " + $skill[Bad Medicine];
	}

	if(!contains_text(combatState, "goodMedicine") && cc_have_skill($skill[Good Medicine]) && (my_mp() >= mp_cost($skill[Good Medicine])) && canSurvive(2.1))
	{
		set_property("cc_combatHandler", combatState + "(goodMedicine)");
		return "skill " + $skill[Good Medicine];
	}


	if(!get_property("cc_gremlinMoly").to_boolean() && (my_class() == $class[Ed]))
	{
		if((get_property("cc_edCombatStage").to_int() >= 2) || (get_property("cc_edStatus") == "dying"))
		{
			string banisher = findBanisher(round, opp, text);
			if(banisher != "attack with weapon")
			{
				return banisher;
			}
			else if((my_mp() >= 8) && cc_have_skill($skill[Storm Of The Scarab]))
			{
				return "skill " + $skill[Storm Of The Scarab];
			}
			return banisher;
		}
	}


	if(!contains_text(combatState, "flyers") && (my_location() != $location[The Battlefield (Frat Uniform)]) && (my_location() != $location[The Battlefield (Hippy Uniform)]) && !get_property("cc_ignoreFlyer").to_boolean())
	{
		if((item_amount($item[Rock Band Flyers]) > 0) && (get_property("flyeredML").to_int() < 10000))
		{
			set_property("cc_combatHandler", combatState + "(flyers)");
			return "item " + $item[Rock Band Flyers];
		}
		if((item_amount($item[Jam Band Flyers]) > 0) && (get_property("flyeredML").to_int() < 10000))
		{
			set_property("cc_combatHandler", combatState + "(flyers)");
			return "item " + $item[Jam Band Flyers];
		}
	}

	if(!get_property("cc_gremlinMoly").to_boolean())
	{
		if(my_class() == $class[Ed])
		{
			if((get_property("cc_edCombatStage").to_int() >= 2) || (get_property("cc_edStatus") == "dying"))
			{
				return findBanisher(round, opp, text);
			}
			else if(item_amount($item[Dictionary]) > 0)
			{
				return "item " + $item[Dictionary];
			}
			else if(item_amount($item[Seal Tooth]) > 0)
			{
				return "item " + $item[Seal Tooth];
			}
		}
		else
		{
			return findBanisher(round, opp, text);
		}
	}


	if(!get_property("cc_gremlinMoly").to_boolean())
	{
		foreach sk in $skills[Lunging Thrust-Smack, Storm Of The Scarab, Lunge Smack]
		{
			if(cc_have_skill(sk) && (my_mp() >= mp_cost(sk)))
			{
				return "skill " + sk;
			}
		}
		return "attack with weapon";
	}

	foreach it in $items[Dictionary, Seal Tooth, Spectre Scepter, Doc Galaktik\'s Pungent Unguent]
	{
		if((item_amount(it) > 0) && glover_usable(it))
		{
			return "item " + it;
		}
	}
	if(cc_have_skill($skill[Toss]) && (my_mp() >= mp_cost($skill[Toss])))
	{
		return "skill " + $skill[Toss];
	}
	return "attack with weapon";
}

string cc_edCombatHandler(int round, string opp, string text)
{
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	int damageReceived = 0;
	if(my_path() != "Actually Ed the Undying")
	{
		abort("Not in Actually Ed the Undying, this combat filter will result in massive suckage.");
	}
	if(round == 0)
	{
		print("cc_combatHandler: " + round, "brown");
		set_property("cc_combatHandler", "");
		if(get_property("cc_edCombatStage").to_int() == 0)
		{
			set_property("cc_edCombatCount", 1 + get_property("cc_edCombatCount").to_int());
			set_property("cc_edCombatStage", 1);
			set_property("cc_edStatus", "UNDYING!");
		}
		else
		{
			set_property("cc_edCombatStage", 1 + get_property("cc_edCombatStage").to_int());
		}
	}
	else
	{
		damageReceived = get_property("cc_combatHP").to_int() - my_hp();
		set_property("cc_combatHP", my_hp());
	}

	set_property("cc_edCombatRoundCount", 1 + get_property("cc_edCombatRoundCount").to_int());


	if(my_location() == $location[Hippy Camp])
	{
		if(!ed_needShop())
		{
			set_property("cc_edStatus", "dying");
			if(my_mp() < 5)
			{
				foreach it in $items[Holy Spring Water, Spirit Beer, Sacramental Wine]
				{
					if(item_amount(it) > 0)
					{
						return "item " + it;
					}
				}
			}
		}
	}

	if(get_property("cc_edCombatStage").to_int() == 3)
	{
		set_property("cc_edStatus", "dying");
		set_property("cc_edCombatStage", 0);
	}
	set_property("cc_diag_round", round);

	if(get_property("cc_diag_round").to_int() > 60)
	{
		abort("Somehow got to 60 rounds.... aborting");
	}

	monster enemy = to_monster(opp);
	phylum type = monster_phylum(enemy);
	string combatState = get_property("cc_combatHandler");
	string edCombatState = get_property("cc_edCombatHandler");
	if($monsters[LOV Enforcer, LOV Engineer, LOV Equivocator] contains enemy)
	{
		set_property("cc_edStatus", "dying");
	}

	#Handle different path is monster_level_adjustment() > 150 (immune to staggers?)
	int mcd = monster_level_adjustment();

	if(have_effect($effect[Temporary Amnesia]) > 0)
	{
		return "attack with weapon";
	}

	if(!contains_text(combatState, "pocket crumbs") && cc_have_skill($skill[Pocket Crumbs]))
	{
		set_property("cc_combatHandler", combatState + "(pocket crumbs)");
		return "skill " + $skill[Pocket Crumbs];
	}

	if(!contains_text(combatState, "micrometeorite") && cc_have_skill($skill[Micrometeorite]))
	{
		set_property("cc_combatHandler", combatState + "(micrometeorite)");
		return "skill " + $skill[Micrometeorite];
	}

	if(!contains_text(combatState, "air dirty laundry") && cc_have_skill($skill[Air Dirty Laundry]))
	{
		set_property("cc_combatHandler", combatState + "(air dirty laundry)");
		return "skill " + $skill[Air Dirty Laundry];
	}

	if(!contains_text(combatState, "love scarab") && cc_have_skill($skill[Summon Love Scarabs]))
	{
		set_property("cc_combatHandler", combatState + "(love scarab)");
		return "skill " + $skill[Summon Love Scarabs];
	}

	if(!contains_text(combatState, "(time-spinner)") && (item_amount($item[Time-Spinner]) > 0))
	{
		set_property("cc_combatHandler", combatState + "(time-spinner)");
		return "item " + $item[Time-Spinner];
	}

	if(((get_property("edPoints").to_int() <= 4) && (my_daycount() == 1)) || !get_property("lovebugsUnlocked").to_boolean())
	{
		if((!ed_needShop() || (get_property("cc_edCombatStage").to_int() > 1)) && (my_location() != $location[Barrrney\'s Barrr]))
		{
			set_property("cc_edStatus", "dying");
		}
	}

	if(!contains_text(combatState, "(sing along)") && cc_have_skill($skill[Sing Along]) && (my_mp() > (mp_cost($skill[Sing Along]))))
	{
		if((get_property("_boomBoxSong") == "Remainin\' Alive") || ((get_property("_boomBoxSong") == "Total Eclipse of Your Meat") && canSurvive(2.0)))
		{
			set_property("cc_combatHandler", combatState + "(sing along)");
			return "skill " + $skill[Sing Along];
		}
	}

	if(have_equipped($item[Protonic Accelerator Pack]) && isGhost(enemy))
	{
		if(!contains_text(combatState, "love gnats") && cc_have_skill($skill[Summon Love Gnats]))
		{
			set_property("cc_combatHandler", combatState + "(love gnats)");
			return "skill " + $skill[Summon Love Gnats];
		}

		if(cc_have_skill($skill[Shoot Ghost]) && (my_mp() > mp_cost($skill[Shoot Ghost])) && !contains_text(edCombatState, "shootghost3") && !contains_text(edCombatState, "trapghost"))
		{
			boolean shootGhost = true;
			if(contains_text(edCombatState, "shootghost2"))
			{
				if((damageReceived * 1.075) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("cc_edCombatHandler", edCombatState + "(shootghost3)");
				}
			}
			else if(contains_text(edCombatState, "shootghost1"))
			{
				if((damageReceived * 2.05) > my_hp())
				{
					shootGhost = false;
				}
				else
				{
					set_property("cc_edCombatHandler", edCombatState + "(shootghost2)");
				}
			}
			else
			{
				set_property("cc_edCombatHandler", edCombatState + "(shootghost1)");
			}

			if(shootGhost)
			{
				return "skill " + $skill[Shoot Ghost];
			}
			else
			{
				edCombatState += "(trapghost)(love stinkbug)";
				set_property("cc_edCombatHandler", edCombatState);
			}
		}
		if(!contains_text(edCombatState, "trapghost") && cc_have_skill($skill[Trap Ghost]) && (my_mp() > mp_cost($skill[Trap Ghost])) && contains_text(edCombatState, "shootghost3"))
		{
			print("Busting makes me feel good!!", "green");
			set_property("cc_edCombatHandler", edCombatState + "(trapghost)");
			return "skill " + $skill[Trap Ghost];
		}
	}

	# Instakill handler
	boolean doInstaKill = true;
	if($monsters[Lobsterfrogman, Ninja Snowman Assassin, Writing Desk] contains enemy)
	{
		if(cc_have_skill($skill[Digitize]) && (get_property("_sourceTerminalDigitizeMonster") != enemy))
		{
			doInstaKill = false;
		}
	}

	if(instakillable(enemy) && !isFreeMonster(enemy) && doInstaKill)
	{
		if(!contains_text(combatState, "batoomerang") && (item_amount($item[Replica Bat-oomerang]) > 0))
		{
			if(get_property("cc_batoomerangDay").to_int() != my_daycount())
			{
				set_property("cc_batoomerangDay", my_daycount());
				set_property("cc_batoomerangUse", 0);
			}
			if(get_property("cc_batoomerangUse").to_int() < 3)
			{
				set_property("cc_batoomerangUse", get_property("cc_batoomerangUse").to_int() + 1);
				set_property("cc_combatHandler", combatState + "(batoomerang)");
				handleTracker(enemy, $item[Replica Bat-oomerang], "cc_instakill");
				return "item " + $item[Replica Bat-oomerang];
			}
		}

		if(!contains_text(combatState, "jokesterGun") && (equipped_item($slot[Weapon]) == $item[The Jokester\'s Gun]) && !get_property("_firedJokestersGun").to_boolean() && cc_have_skill($skill[Fire the Jokester\'s Gun]))
		{
			set_property("cc_combatHandler", combatState + "(jokesterGun)");
			handleTracker(enemy, $skill[Fire the Jokester\'s Gun], "cc_instakill");
			return "skill" + $skill[Fire the Jokester\'s Gun];
		}
	}


	if(get_property("cc_edStatus") == "UNDYING!")
	{
		if(!contains_text(combatState, "love gnats") && cc_have_skill($skill[Summon Love Gnats]))
		{
			set_property("cc_combatHandler", combatState + "(love gnats)");
			return "skill " + $skill[Summon Love Gnats];
		}

		if((item_amount($item[Ka Coin]) > 200) && cc_have_skill($skill[Curse of Fortune]))
		{
			if(!contains_text(combatState, "curse of fortune"))
			{
				set_property("cc_combatHandler", combatState + "(curse of fortune)");
				return "skill " + $skill[Curse of Fortune];
			}
		}
	}
	else if(get_property("cc_edStatus") == "dying")
	{
		boolean doStunner = true;

		if((mcd > 50) && canSurvive(1.15))
		{
			doStunner = false;
		}

		if(doStunner)
		{
			if(!contains_text(combatState, "love gnats") && cc_have_skill($skill[Summon Love Gnats]))
			{
				set_property("cc_combatHandler", combatState + "(love gnats)");
				return "skill " + $skill[Summon Love Gnats];
			}
		}
	}
	else
	{
		print("Ed combat state does not exist, winging it....", "red");
	}


	if(!contains_text(combatState, "sewage pistol") && cc_have_skill($skill[Fire Sewage Pistol]))
	{
		set_property("cc_combatHandler", combatState + "(sewage pistol)");
		return "skill " + $skill[Fire Sewage Pistol];
	}

	if(enemy == $monster[Protagonist])
	{
		set_property("cc_edStatus", "dying");
	}


	if(!contains_text(combatState, "flyers") && (my_location() != $location[The Battlefield (Frat Uniform)]) && (my_location() != $location[The Battlefield (Hippy Uniform)]) && !get_property("cc_ignoreFlyer").to_boolean())
	{
		if((item_amount($item[Rock Band Flyers]) > 0) && (get_property("flyeredML").to_int() < 10000))
		{
			set_property("cc_combatHandler", combatState + "(flyers)");
			return "item " + $item[Rock Band Flyers];
		}
		if((item_amount($item[Jam Band Flyers]) > 0) && (get_property("flyeredML").to_int() < 10000))
		{
			set_property("cc_combatHandler", combatState + "(flyers)");
			return "item " + $item[Jam Band Flyers];
		}
	}

	if(item_amount($item[Cocktail Napkin]) > 0)
	{
		if($monsters[Clingy Pirate (Female), Clingy Pirate (Male)] contains enemy)
		{
			return "item " + $item[Cocktail Napkin];
		}
	}

	if((enemy == $monster[dirty thieving brigand]) && !contains_text(edCombatState, "curse of fortune"))
	{
		if((item_amount($item[Ka Coin]) > 0) && (cc_have_skill($skill[Curse Of Fortune])))
		{
			set_property("cc_edCombatHandler", edCombatState + "(curse of fortune)");
			set_property("cc_edStatus", "dying");
			return "skill " + $skill[Curse Of Fortune];
		}
	}

	if((item_amount($item[The Big Book of Pirate Insults]) > 0) && !contains_text(combatState, "insults") && (numPirateInsults() < 8) && (get_property("cc_edCombatStage").to_int() < 3) && (get_property("cc_edStatus") != "dying"))
	{
		if(!contains_text(combatState, "beanscreen") && cc_have_skill($skill[Beanscreen]) && (my_mp() >= mp_cost($skill[Beanscreen])))
		{
			set_property("cc_combatHandler", combatState + "(beanscreen)");
			return "skill " + $skill[Beanscreen];
		}

		if(!contains_text(combatState, to_string($skill[Snap Fingers])) && cc_have_skill($skill[Snap Fingers]) && (my_mp() >= mp_cost($skill[Snap Fingers])))
		{
			set_property("cc_combatHandler", combatState + "(" + $skill[Snap Fingers] + ")");
			return "skill " + $skill[Snap Fingers];
		}

		if((my_location() == $location[The Obligatory Pirate\'s Cove]) || (my_location() == $location[barrrney\'s barrr]) || (enemy == $monster[gaudy pirate]))
		{
			set_property("cc_combatHandler", combatState + "(insults)");
			return "item " + $item[The Big Book Of Pirate Insults];
		}
	}

	if(!contains_text(edCombatState, "curseofstench") && cc_have_skill($skill[Curse Of Stench]) && (my_mp() >= 35) && (get_property("stenchCursedMonster") != opp) && (get_property("cc_edCombatStage").to_int() < 3))
	{
		if($monsters[Bob Racecar, Cabinet of Dr. Limpieza, Dairy Goat, Dirty Old Lihc, Government Scientist,  Green Ops Soldier, Possessed Wine Rack, Pygmy Bowler, Pygmy Witch Surgeon, Quiet Healer, Racecar Bob, Writing Desk] contains enemy)
		{
			set_property("cc_edCombatHandler", combatState + "(curseofstench)");
			handleTracker(enemy, $skill[Curse Of Stench], "cc_sniffs");
			return "skill " + $skill[Curse Of Stench];
		}
	}

	if(my_location() == $location[The Secret Council Warehouse])
	{
		if(!contains_text(edCombatState, "curseofstench") && cc_have_skill($skill[Curse Of Stench]) && (my_mp() >= 35) && (get_property("stenchCursedMonster") != opp) && (get_property("cc_edCombatStage").to_int() < 3))
		{
			boolean doStench = false;
			#	Rememeber, we are looking to see if we have enough of the opposite item here.
			if(enemy == $monster[Warehouse Guard])
			{
				int progress = get_property("warehouseProgress").to_int();
				progress = progress + (8 * item_amount($item[Warehouse Inventory Page]));
				if(progress >= 50)
				{
					doStench = true;
				}
			}

			if(enemy == $monster[Warehouse Clerk])
			{
				int progress = get_property("warehouseProgress").to_int();
				progress = progress + (8 * item_amount($item[Warehouse Map Page]));
				if(progress >= 50)
				{
					doStench = true;
				}
			}
			if(doStench)
			{
				set_property("cc_edCombatHandler", combatState + "(curseofstench)");
				handleTracker(enemy, $skill[Curse of Stench], "cc_sniffs");
				return "skill " + $skill[Curse Of Stench];
			}
		}
	}


	if(my_location() == $location[The Smut Orc Logging Camp])
	{
		if(!contains_text(edCombatState, "curseofstench") && cc_have_skill($skill[Curse Of Stench]) && (my_mp() >= 35) && (get_property("stenchCursedMonster") != opp) && (get_property("cc_edCombatStage").to_int() < 3))
		{
			boolean doStench = false;
			string stenched = to_lower_case(get_property("stenchCursedMonster"));

			if((fastenerCount() >= 30) && (stenched != "smut orc pipelayer") && (stenched != "smut orc jacker"))
			{
				#	Sniff 100% lumber
				if((enemy == $monster[Smut Orc Pipelayer]) || (enemy == $monster[Smut Orc Jacker]))
				{
					doStench = true;
				}
			}
			if((lumberCount() >= 30) && (stenched != "smut orc screwer") && (stenched != "smut orc nailer"))
			{
				#	Sniff 100% fastener
				if((enemy == $monster[Smut Orc Screwer]) || (enemy == $monster[Smut Orc Nailer]))
				{
					doStench = true;
				}
			}

			if(doStench)
			{
				set_property("cc_edCombatHandler", combatState + "(curseofstench)");
				handleTracker(enemy, $skill[Curse of Stench], "cc_sniffs");
				return "skill " + $skill[Curse Of Stench];
			}
		}
	}

	if(contains_text(combatState, "insults") && (get_property("cc_edStatus") == "dying"))
	{
		if((enemy == $monster[shady pirate]) && cc_have_skill($skill[Curse Of Vacation]) && (my_mp() >= 30))
		{
			handleTracker(enemy, $skill[Curse Of Vacation], "cc_banishes");
			return "skill " + $skill[Curse Of Vacation];
		}
		if((enemy == $monster[shifty pirate]) && (get_property("_pantsgivingBanish").to_int() < 5) && cc_have_skill($skill[Talk About Politics]))
		{
			handleTracker(enemy, $skill[Talk About Politics], "cc_banishes");
			return "skill " + $skill[Talk About Politics];
		}
	}

	if(!contains_text(combatState, "yellowray"))
	{
		boolean doYellow = false;
		if((my_location() == $location[Hippy Camp]) && !have_outfit("Filthy Hippy Disguise"))
		{
			doYellow = true;
		}
		if((enemy == $monster[Burly sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doYellow = true;
		}
		if((enemy == $monster[Knob Goblin Harem Girl]) && !have_outfit("Knob Goblin Harem Girl Disguise"))
		{
			doYellow = true;
		}
		if((enemy == $monster[Mountain Man]) && (internalQuestStatus("questL08Trapper") < 2))
		{
			doYellow = true;
		}

		if((enemy == $monster[Frat Warrior Drill Sergeant]) || (enemy == $monster[War Pledge]))
		{
			if(!have_outfit("War Hippy Fatigues"))
			{
				doYellow = true;
			}
		}

		if(doYellow)
		{
			string combatAction = yellowRayCombatString();
			if(combatAction != "")
			{
				set_property("cc_combatHandler", combatState + "(yellowray)");
				if(index_of(combatAction, "skill") == 0)
				{
					handleTracker(enemy, to_skill(substring(combatAction, 6)), "cc_yellowRays");
				}
				else if(index_of(combatAction, "item") == 0)
				{
					handleTracker(enemy, to_item(substring(combatAction, 5)), "cc_yellowRays");
				}
				else
				{
					print("Unable to track yellow ray behavior: " + combatAction, "red");
				}
				if(combatAction == ("skill " + $skill[Asdon Martin: Missile Launcher]))
				{
					set_property("_missileLauncherUsed", true);
				}
				return combatAction;
			}
			else
			{
				print("Wanted a yellow ray but we can not find one.", "red");
			}
		}
	}

	if(cc_have_skill($skill[Curse Of Vacation]) && (my_mp() >= mp_cost($skill[Curse Of Vacation])))
	{
		if((enemy == $monster[pygmy orderlies]) && (my_location() == $location[The Hidden Bowling Alley]))
		{
			set_property("cc_combatHandler", combatState + "(curse of vacation)");
			handleTracker(enemy, $skill[Curse Of Vacation], "cc_banishes");
			return "skill " + $skill[Curse Of Vacation];
		}
		if((enemy == $monster[fallen archfiend]) && (my_location() == $location[The Dark Heart of the Woods]) && (get_property("cc_pirateoutfit") != "almost") && (get_property("cc_pirateoutfit") != "finished"))
		{
			set_property("cc_combatHandler", combatState + "(curse of vacation)");
			handleTracker(enemy, $skill[Curse Of Vacation], "cc_banishes");
			return "skill " + $skill[Curse Of Vacation];
		}
		if($monsters[Animated Mahogany Nightstand, Coaltergeist, Crusty Pirate, Flock of Stab-Bats, Irritating Series of Random Encounters, Knob Goblin Harem Guard, Mad Wino, Mismatched Twins, Possessed Laundry Press, Procrastination Giant, Punk Rock Giant, Pygmy Witch Lawyer, Pygmy Witch Nurse, Sabre-Toothed Goat, Slick Lihc, Warehouse Janitor] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(curse of vacation)");
			handleTracker(enemy, $skill[Curse of Vacation], "cc_banishes");
			return "skill " + $skill[Curse Of Vacation];
		}
	}

	if(item_amount($item[Disposable Instant Camera]) > 0)
	{
		if($monsters[Bob Racecar, Racecar Bob] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(disposable instant camera)");
			return "item " + $item[Disposable Instant Camera];
		}
	}

	if((my_location() == $location[Oil Peak]) && (item_amount($item[Duskwalker Syringe]) > 0))
	{
		int oilProgress = get_property("twinPeakProgress").to_int();
		boolean wantCrude = ((oilProgress & 4) == 0);
		if(item_amount($item[Bubblin\' Crude]) > 11)
		{
			wantCrude = false;
		}
		if(item_amount($item[Jar Of Oil]) > 0)
		{
			wantCrude = false;
		}

		
		if(wantCrude)
		{
			return "item " + $item[Duskwalker Syringe];
		}
	}

	if(!contains_text(edCombatState, "lashofthecobra") && cc_have_skill($skill[Lash of the Cobra]) && (my_mp() >= 12))
	{
		set_property("cc_edCombatHandler", edCombatState + "(lashofthecobra)");
		boolean doLash = false;
		if((enemy == $monster[Swarthy Pirate]) && !possessEquipment($item[Stuffed Shoulder Parrot]))
		{
			doLash = true;
		}
		if((enemy == $monster[Big Wheelin\' Twins]) && !possessEquipment($item[Badge Of Authority]))
		{
			doLash = true;
		}

		if((enemy == $monster[Fishy Pirate]) && !possessEquipment($item[Perfume-Soaked Bandana]))
		{
			doLash = true;
		}
		if((enemy == $monster[Funky Pirate]) && !possessEquipment($item[Sewage-Clogged Pistol]) && elementalPlanes_access($element[spooky]))
		{
			doLash = true;
		}
		if((enemy == $monster[Garbage Tourist]) && (item_amount($item[Bag of Park Garbage]) == 0))
		{
			doLash = true;
		}

		if((enemy == $monster[Sassy Pirate]) && !possessEquipment($item[Swashbuckling Pants]))
		{
			doLash = true;
		}
		if((enemy == $monster[Smarmy Pirate]) && !possessEquipment($item[Eyepatch]))
		{
			doLash = true;
		}
		if((enemy == $monster[One-eyed Gnoll]) && !possessEquipment($item[Eyepatch]))
		{
			doLash = true;
		}
		if((enemy == $monster[Stone Temple Pirate]) && !possessEquipment($item[Eyepatch]))
		{
			doLash = true;
		}
		if((enemy == $monster[Dairy Goat]) && (item_amount($item[Goat Cheese]) < 3))
		{
			doLash = true;
		}
		if((enemy == $monster[Renaissance Giant]) && (item_amount($item[Ye Olde Meade]) < 1) && (my_daycount() == 1))
		{
			doLash = true;
		}
		if((enemy == $monster[Protagonist]) && !possessEquipment($item[Ocarina of Space]))
		{
			doLash = true;
		}
		if($monsters[Bearpig Topiary Animal, Elephant (Meatcar?) Topiary Animal, Spider (Duck?) Topiary Animal] contains enemy)
		{
			doLash = true;
		}
		if($monsters[Beanbat, Bookbat] contains enemy)
		{
			doLash = true;
		}
		if(((enemy == $monster[Toothy Sklelton]) || (enemy == $monster[Spiny Skelelton])) && (get_property("cyrptNookEvilness").to_int() > 26))
		{
			doLash = true;
		}
		if((enemy == $monster[Oil Baron]) && (item_amount($item[Bubblin\' Crude]) < 12) && (item_amount($item[Jar of Oil]) == 0))
		{
			doLash = true;
		}

		if((enemy == $monster[Blackberry Bush]) && (item_amount($item[Blackberry]) < 3) && !possessEquipment($item[Blackberry Galoshes]))
		{
			doLash = true;
		}
		if((enemy == $monster[Pygmy Bowler]) && (get_property("_edLashCount").to_int() < 26))
		{
			doLash = true;
		}
		if($monsters[Filthworm Drone, Filthworm Royal Guard, Larval Filthworm] contains enemy)
		{
			doLash = true;
		}
		if(enemy == $monster[Knob Goblin Madam])
		{
			if(item_amount($item[Knob Goblin Perfume]) == 0)
			{
				doLash = true;
			}
		}
		if(enemy == $monster[Knob Goblin Harem Girl])
		{
			if(!possessEquipment($item[Knob Goblin Harem Veil]) || !possessEquipment($item[Knob Goblin Harem Pants]))
			{
				doLash = true;
			}
		}

		if(((my_location() == $location[Hippy Camp]) || (my_location() == $location[Wartime Hippy Camp])) && contains_text(enemy, "hippy"))
		{
			if(!possessEquipment($item[Filthy Knitted Dread Sack]) || !possessEquipment($item[Filthy Corduroys]))
			{
				if(get_property("cc_edStatus") != "dying")
				{
					doLash = true;
				}
			}
		}

		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doLash = true;
			}
		}

		if((enemy == $monster[Dopey 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Helmet]))
		{
			doLash = true;
		}

		if((enemy == $monster[Grumpy 7-Foot Dwarf]) && !possessEquipment($item[7-Foot Dwarven Mattock]))
		{
			doLash = true;
		}

		if((enemy == $monster[Sleepy 7-Foot Dwarf]) && !possessEquipment($item[Miner\'s Pants]))
		{
			doLash = true;
		}

		if((enemy == $monster[Burly Sidekick]) && !possessEquipment($item[Mohawk Wig]))
		{
			doLash = true;
		}

		if((enemy == $monster[Spunky Princess]) && !possessEquipment($item[Titanium Assault Umbrella]))
		{
			doLash = true;
		}

		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doLash = true;
		}

		if((enemy == $monster[P Imp]) || (enemy == $monster[G Imp]))
		{
			if((get_property("cc_pirateoutfit") != "finished") && (get_property("cc_pirateoutfit") != "almost") && (item_amount($item[Hot Wing]) < 3))
			{
				doLash = true;
			}
		}

		if(enemy == $monster[Warehouse Clerk])
		{
			int progress = get_property("warehouseProgress").to_int();
			progress = progress + (8 * item_amount($item[Warehouse Inventory Page]));
			if(progress < 50)
			{
				doLash = true;
			}
		}

		if(enemy == $monster[Warehouse Guard])
		{
			int progress = get_property("warehouseProgress").to_int();
			progress = progress + (8 * item_amount($item[Warehouse Map Page]));
			if(progress < 50)
			{
				doLash = true;
			}
		}

		if(doLash)
		{
			handleTracker(enemy, "cc_lashes");
			return "skill " + $skill[Lash Of The Cobra];
		}
	}

	if((item_amount($item[Tattered Scrap of Paper]) > 0) && !contains_text(combatState, "tatters"))
	{
		if($monsters[Bubblemint Twins, Bunch of Drunken Rats, Coaltergeist, Creepy Ginger Twin, Demoninja, Drunk Goat, Drunken Rat, Fallen Archfiend, Hellion, Knob Goblin Elite Guard, L imp, Mismatched Twins, Sabre-Toothed Goat, W imp] contains enemy)
		{
			set_property("cc_combatHandler", combatState + "(tatters)");
			return "item " + $item[Tattered Scrap Of Paper];
		}
	}

	if(!contains_text(edCombatState, "talismanofrenenutet") && (item_amount($item[Talisman of Renenutet]) > 0))
	{
		boolean doRenenutet = false;
		if((enemy == $monster[Cleanly Pirate]) && (item_amount($item[Rigging Shampoo]) == 0))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Creamy Pirate]) && (item_amount($item[Ball Polish]) == 0))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Curmudgeonly Pirate]) && (item_amount($item[Mizzenmast Mop]) == 0))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Cabinet of Dr. Limpieza]) && ($location[The Haunted Laundry Room].turns_spent > 2))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Possessed Wine Rack]) && ($location[The Haunted Wine Cellar].turns_spent > 2))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Baa\'baa\'bu\'ran]) && (item_amount($item[Stone Wool]) < 2))
		{
			doRenenutet = true;
		}
		if($monsters[Mountain Man, Warehouse Clerk, Warehouse Guard] contains enemy)
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Quiet Healer]) && !possessEquipment($item[Amulet of Extreme Plot Significance]))
		{
			doRenenutet = true;
		}
		if((enemy == $monster[Pygmy Janitor]) && (item_amount($item[Book of Matches]) == 0) && (get_property("relocatePygmyJanitor").to_int() != my_ascensions()))
		{
			doRenenutet = true;
		}
		if(enemy == $monster[Blackberry Bush])
		{
			if(!possessEquipment($item[Blackberry Galoshes]) && (item_amount($item[Blackberry]) < 3))
			{
				doRenenutet = true;
			}
		}
		if(my_location() == $location[Wartime Frat House])
		{
			if(!possessEquipment($item[Beer Helmet]) || !possessEquipment($item[Bejeweled Pledge Pin]) || !possessEquipment($item[Distressed Denim Pants]))
			{
				doRenenutet = true;
			}
		}
		if(doRenenutet)
		{
			if(!contains_text(edCombatState, "curseofindecision") && cc_have_skill($skill[Curse Of Indecision]) && (my_mp() > mp_cost($skill[Curse Of Indecision])))
			{
				set_property("cc_edCombatHandler", edCombatState + "(curseofindecision)");
				return "skill " + $skill[Curse Of Indecision];
			}
			set_property("cc_edCombatHandler", edCombatState + "(talismanofrenenutet)");
			handleTracker(enemy, "cc_renenutet");
			set_property("cc_edStatus", "dying");
			return "item " + $item[Talisman Of Renenutet];
		}
	}

	if((enemy == $monster[Pygmy Orderlies]) && (item_amount($item[Short Writ of Habeas Corpus]) > 0))
	{
		return "item short writ of habeas corpus";
	}

	if(!ed_needShop() && (my_level() >= 10) && (item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[jam Band Flyers]) == 0) && (my_location() != $location[The Hidden Apartment Building]) && (type != $phylum[undead]) && (my_mp() > 20) && (my_location() != $location[Barrrney\'s Barrr]))
	{
		set_property("cc_edStatus", "dying");
	}

	if(get_property("cc_edStatus") == "UNDYING!")
	{
#		if((my_location() == $location[The Secret Government Laboratory]) || !ed_needShop())
		if(my_location() == $location[The Secret Government Laboratory])
		{
			if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
			{
				if((!contains_text(combatState, "love stinkbug")) && get_property("lovebugsUnlocked").to_boolean())
				{
					set_property("cc_combatHandler", combatState + "(love stinkbug2)");
					return "skill " + $skill[Summon Love Stinkbug];
				}
			}
		}

		if((item_amount($item[Ka Coin]) > 200) && cc_have_skill($skill[Curse of Fortune]))
		{
			if(!contains_text(combatState, "curse of fortune"))
			{
				set_property("cc_combatHandler", combatState + "(curse of fortune)");
				return "skill " + $skill[Curse of Fortune];
			}
		}

		if(item_amount($item[Dictionary]) > 0)
		{
#			string macro = "item dictionary; repeat";
#			visit_url("fight.php?action=macro&macrotext=" + url_encode(macro), true, true);
			return "item " + $item[Dictionary];
		}
		if(item_amount($item[Seal Tooth]) > 0)
		{
			return "item " + $item[Seal Tooth];
		}

		return "skill " + $skill[Mild Curse];
	}

	if((my_mp() >= mp_cost($skill[Roar of the Lion])) && (my_location() == $location[The Secret Government Laboratory]) && cc_have_skill($skill[Roar of the Lion]))
	{
		if(cc_have_skill($skill[Storm Of The Scarab]) && (my_buffedstat($stat[Mysticality]) >= 60))
		{
			return "skill " + $skill[Storm Of The Scarab];
		}
		return "skill " + $skill[Roar Of The Lion];
	}
	if((my_mp() >= mp_cost($skill[Storm Of The Scarab])) && ($locations[Pirates of the Garbage Barges, The SMOOCH Army HQ, VYKEA] contains my_location()) && cc_have_skill($skill[Storm of the Scarab]))
	{
		return "skill " + $skill[Storm Of The Scarab];
	}
	if((my_mp() >= mp_cost($skill[Fist Of The Mummy])) && (my_location() == $location[Hippy Camp]) && cc_have_skill($skill[Fist Of The Mummy]))
	{
		return "skill " + $skill[Fist Of The Mummy];
	}


#	if(!contains_text(combatState, "love stinkbug") && cc_have_skill($skill[Summon Love Stinkbug]) && (mcd <= 50))
#	{
#		set_property("cc_combatHandler", combatState + "(love stinkbug1)");
#		return "skill " + $skill[Summon Love Stinkbug];
#	}
#	if(!contains_text(combatState, "love stinkbug") && get_property("lovebugsUnlocked").to_boolean() && (mcd <= 50))
#	{
#		set_property("cc_combatHandler", combatState + "(love stinkbug2)");
#		return "skill " + $skill[Summon Love Stinkbug];
#	}

	int fightStat = my_buffedstat(weapon_type(equipped_item($slot[weapon]))) - 20;
	if((fightStat > monster_defense()) && (round < 20) && canSurvive(1.1) && (get_property("cc_edStatus") == "UNDYING!"))
	{
		return "attack with weapon";
	}

	if(!contains_text(combatState, "cowboy kick") && cc_have_skill($skill[Cowboy Kick]))
	{
		set_property("cc_combatHandler", combatState + "(cowboy kick)");
		return "skill " + $skill[Cowboy Kick];
	}

	if((item_amount($item[Ice-Cold Cloaca Zero]) > 0) && (my_mp() < 15) && (my_maxmp() > 200))
	{
		return "item " + $item[Ice-Cold Cloaca Zero];
	}
	if((my_mp() >= 8) && cc_have_skill($skill[Storm Of The Scarab]) && (my_buffedstat($stat[Mysticality]) > 35))
	{
		return "skill " + $skill[Storm Of The Scarab];
	}

	if((enemy.physical_resistance >= 100) || (round >= 25) || canSurvive(1.25))
	{
		if((my_mp() >= 5) && cc_have_skill($skill[Fist Of The Mummy]))
		{
			return "skill " + $skill[Fist Of The Mummy];
		}
	}

	if(my_mp() < 8)
	{
		foreach it in $items[Holy Spring Water, Spirit Beer, Sacramental Wine]
		{
			if(item_amount(it) > 0)
			{
				return "item " + it;
			}
		}
	}

	if(round >= 29)
	{
		print("About to UNDYING too much but have no other combat resolution. Please report this.", "red");
	}

	if((fightStat > monster_defense()) && (round < 20) && canSurvive(1.1) && (get_property("cc_edStatus") == "dying"))
	{
		print("Attacking with weapon because we don't have enough MP. Expected damage: " + expected_damage() + ", current hp: " + my_hp(), "red");
		return "attack with weapon";
	}

	return "skill " + $skill[Mild Curse];
}



monster ocrs_helper(string page)
{
	if(my_path() != "One Crazy Random Summer")
	{
		abort("Should not be in ocrs_helper if not on the path!");
	}

	string combatState = get_property("cc_combatHandler");

	//	ghostly				physical resistance
	//	untouchable			damage reduced to 5, instant kills still good (much less of an issue now

	/*
		For no staggers, don\'t use staggers
		For blocks skills/combat items, we can probably set them all to used as well.
	*/

	if(isFreeMonster(last_monster()))
	{
		if((!contains_text(combatState, "cleesh")) && cc_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("cc_useCleesh", false);
			set_property("cc_combatHandler", combatState + "(cleesh)");
		}
	}

	if(last_monster().random_modifiers["unstoppable"])
	{
		if(!contains_text(combatState, "unstoppable"))
		{
			set_property("cc_combatHandler", combatState + "(DNA)(air dirty laundry)(ply reality)(indigo cup)(love mosquito)(blue balls)(love gnats)(unstoppable)(micrometeorite)");
			#Block weaksauce and pocket crumbs?
		}
	}

	if(last_monster().random_modifiers["annoying"])
	{
		if(contains_text(page, "makes the most annoying noise you've ever heard, stopping you in your tracks."))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	if(last_monster().random_modifiers["restless"])
	{
		if(contains_text(page, "moves out of the way"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		if(contains_text(page, "quickly moves out of the way"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		if(contains_text(page, "will have moved by the time"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}

		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	if(last_monster().random_modifiers["phase-shifting"])
	{
		if(contains_text(page, "blinks out of existence before"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	if(last_monster().random_modifiers["cartwheeling"])
	{
		if(contains_text(page, "cartwheels out of the way"))
		{
			print("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("cc_combatHandler", get_property("cc_funCombatHandler"));
		}
		set_property("cc_funCombatHandler", get_property("cc_combatHandler"));
	}

	set_property("cc_useCleesh", false);
	if(last_monster().random_modifiers["ticking"])
	{
		if((!contains_text(combatState, "cleesh")) && cc_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("cc_useCleesh", true);
		}
	}
	if(last_monster().random_modifiers["untouchable"])
	{
		if((!contains_text(combatState, "cleesh")) && cc_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("cc_useCleesh", true);
		}
	}
	return last_monster();
}

void awol_helper(string page)
{
	//Let us self-contain this so it is quick to remove later.
	if((my_daycount() == 1) && (my_turncount() < 10))
	{
		set_property("cc_noSnakeOil", 0);
	}

	string combatState = get_property("cc_combatHandler");
	if(contains_text(page, "Your oil extractor is completely clogged up at this point"))
	{
		set_property("cc_noSnakeOil", my_daycount());
	}
	if(get_property("_oilExtracted").to_int() >= 100)
	{
		set_property("cc_noSnakeOil", my_daycount());
	}

	if((!contains_text(combatState, "extractSnakeOil")) && (get_property("cc_noSnakeOil").to_int() == my_daycount()))
	{
		set_property("cc_combatHandler", combatState + "(extractSnakeOil)");
	}
}


boolean registerCombat(string action)
{
	set_property("cc_combatHandler", get_property("cc_combatHandler") + "(" + to_lower_case(action) + ")");
	return true;
}
boolean containsCombat(string action)
{
	action = "(" + to_lower_case(action) + ")";
	return contains_text(get_property("cc_combatHandler"), action);
}

boolean registerCombat(skill sk)
{
	return registerCombat(to_string(sk));
}
boolean registerCombat(item it)
{
	return registerCombat(to_string(it));
}

boolean containsCombat(skill sk)
{
	return containsCombat(to_string(sk));
}
boolean containsCombat(item it)
{
	return containsCombat(to_string(it));
}


boolean canSurvive(float mult, int add)
{
	int damage = expected_damage();
	damage *= mult;
	damage += add;
	return (damage < my_hp());
}

boolean canSurvive(float mult)
{
	return canSurvive(mult, 0);
}
