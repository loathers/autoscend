script "cc_mr2016.ash"

#	This is meant for items that have a date of 2016.
#	Handling: Witchess Set, Snojo, Source Terminal, Protonic Accelerator Pack
#			Time-Spinner

boolean snojoFightAvailable();
boolean cc_advWitchess(string target);
boolean cc_advWitchess(string target, string option);

boolean cc_haveWitchess();
boolean cc_haveSourceTerminal();
boolean cc_sourceTerminalRequest(string request);
boolean cc_sourceTerminalEnhance(string request);
int cc_sourceTerminalEnhanceLeft();
boolean cc_sourceTerminalExtrude(string request);
int cc_sourceTerminalExtrudeLeft();
int[string] cc_sourceTerminalStatus();
boolean cc_doPrecinct();
item cc_bestBadge();
boolean cc_sourceTerminalEducate(skill first);
boolean cc_sourceTerminalEducate(skill first, skill second);
boolean LX_ghostBusting();
boolean expectGhostReport();
boolean haveGhostReport();

boolean timeSpinnerGet(string goal);
boolean timeSpinnerConsume(item goal);
boolean timeSpinnerCombat(monster goal);
boolean timeSpinnerCombat(monster goal, string option);
boolean timeSpinnerAdventure(string option);
boolean timeSpinnerAdventure();

boolean rethinkingCandy(effect acquire);
boolean rethinkingCandy(effect acquire, boolean simulate);
boolean rethinkingCandyList();

//Supplemental
int cc_advWitchessTargets(string target);




boolean snojoFightAvailable()
{
	if(!is_unrestricted($item[X-32-F Snowman Crate]))
	{
		return false;
	}
	if(!get_property("snojoAvailable").to_boolean())
	{
		return false;
	}
	if(my_inebriety() > inebriety_limit())
	{
		return false;
	}

	if(!get_property("kingLiberated").to_boolean())
	{
		int[string] controls;
		controls["MUSCLE"] = 1;
		controls["MYSTICALITY"] = 2;
		controls["MOXIE"] = 3;
		controls["Muscle"] = 1;
		controls["Mysticality"] = 2;
		controls["Moxie"] = 3;

		//List the three desired goals and then a "final" state that we stay in
		string[int] standard;
		standard[0] = "Moxie";
		standard[1] = "Mysticality";
		standard[2] = "Muscle";
		standard[3] = "Moxie";

		if((my_path() == "Avatar of Boris") && (possessEquipment($item[Boris\'s Helm]) || possessEquipment($item[Boris\'s Helm (Askew)])))
		{
			standard[0] = "Muscle";
			standard[1] = "Mysticality";
			standard[2] = "Moxie";
			standard[3] = "Mysticality";
		}
		if(my_path() == "Community Service")
		{
			standard[0] = "Mysticality";
			standard[1] = "Moxie";
			standard[2] = "Muscle";
			standard[3] = "Mysticality";
		}
		if(my_path() == "License to Adventure")
		{
			standard[0] = "Mysticality";
			standard[1] = "Moxie";
			standard[2] = "Muscle";
			standard[3] = "Mysticality";
		}

		if((get_property("snojo" + standard[0] + "Wins").to_int() < 14) && (get_property("snojoSetting") != to_upper_case(standard[0])))
		{
			string temp = visit_url("place.php?whichplace=snojo&action=snojo_controller");
			temp = run_choice(controls[standard[0]]);
		}
		if((get_property("snojoSetting") == to_upper_case(standard[0])) && (get_property("snojo" + standard[0] + "Wins").to_int() >= 14) && (get_property("snojoSetting") != to_upper_case(standard[1])) && (get_property("snojo" + standard[1] + "Wins").to_int() < 14))
		{
			string temp = visit_url("place.php?whichplace=snojo&action=snojo_controller");
			temp = run_choice(controls[standard[1]]);
		}
		if((get_property("snojoSetting") == to_upper_case(standard[1])) && (get_property("snojo" + standard[1] + "Wins").to_int() >= 14) && (get_property("snojoSetting") != to_upper_case(standard[2])) && (get_property("snojo" + standard[2] + "Wins").to_int() < 14))
		{
			string temp = visit_url("place.php?whichplace=snojo&action=snojo_controller");
			temp = run_choice(controls[standard[2]]);
		}
		if((get_property("snojoSetting") == to_upper_case(standard[2])) && (get_property("snojo" + standard[2] + "Wins").to_int() >= 11) && (get_property("snojoSetting") != to_upper_case(standard[3])))
		{
			string temp = visit_url("place.php?whichplace=snojo&action=snojo_controller");
			temp = run_choice(controls[standard[3]]);
		}
	}

	if(get_property("snojoSetting") == "NONE")
	{
		print("Snojo not set, attempting to set to " + my_primestat(), "blue");
		visit_url("place.php?whichplace=snojo&action=snojo_controller");
	}
	return (get_property("_snojoFreeFights").to_int() < 10);
}


boolean cc_haveSourceTerminal()
{
	if(!is_unrestricted($item[Source Terminal]))
	{
		return false;
	}
	static boolean didCheck = false;
	if((cc_my_path() == "Nuclear Autumn") && !didCheck)
	{
		didCheck = true;
		string temp = visit_url("place.php?whichplace=falloutshelter&action=vault_term");
		if(contains_text(temp, "Source Terminal"))
		{
			set_property("cc_haveSourceTerminal", true);
		}
	}

	return (cc_get_campground() contains $item[Source Terminal]);
}

boolean cc_sourceTerminalRequest(string request)
{
	//enhance <effect>.enh		[meat|items|init|critical]
	//enquiry <effect>.enq		[familiar|monsters]
	//educate <skill>.edu		[digitize|extract]
	//extrude <item>.ext		[food|booze|goggles]

	print("Source Terminal request: " + request, "green");


	//"campground.php?action=terminal&hack=enhance items.enh"
	if(cc_haveSourceTerminal())
	{
		if(cc_my_path() == "Nuclear Autumn")
		{
			string temp = visit_url("place.php?whichplace=falloutshelter&action=vault_term");
		}
		else
		{
			string temp = visit_url("campground.php?action=terminal");
		}
#		temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=reset");
		string temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=" + request);
#		temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=reset");
		return true;
	}
	return false;
}

boolean cc_sourceTerminalExtrude(string request)
{
	if(!cc_haveSourceTerminal())
	{
		return false;
	}
	if(cc_sourceTerminalExtrudeLeft() == 0)
	{
		return false;
	}
	string actual = "";
	request = to_lower_case(request);
	switch(request)
	{
	case "food":
	case "food.ext":
	case "browser cookie":	actual = "food";			break;
	case "booze":
	case "booze.ext":
	case "hacked gibson":	actual = "booze";			break;
	case "goggles":
	case "goggles.ext":
	case "source shades":	actual = "goggles";			break;
	default:			return false;
	}

	return cc_sourceTerminalRequest("extrude -f " + actual + ".ext");
}

int cc_sourceTerminalExtrudeLeft()
{
	if(cc_haveSourceTerminal())
	{
		return 3 - get_property("_sourceTerminalExtrudes").to_int();
	}
	return 0;
}

boolean cc_sourceTerminalEnhance(string request)
{
	if(!cc_haveSourceTerminal())
	{
		return false;
	}
	if(cc_sourceTerminalEnhanceLeft() == 0)
	{
		return false;
	}
	string actual = "";
	switch(request)
	{
	case "meat":
	case "meat.enh":		actual = "meat";			break;
	case "item":
	case "items":
	case "item.enh":
	case "items.enh":		actual = "items";			break;
	case "substats":
	case "substats.enh":
	case "stats":			actual = "substats";		break;
	case "damage":
	case "damage.enh":		actual = "damage";			break;
	case "init":
	case "initiative":		actual = "init";			break;
	case "critical":		actual = "critical";		break;
	default:			return false;
	}

	if(contains_text(get_property("sourceTerminalEnhanceKnown"), actual + ".enh"))
	{
		return cc_sourceTerminalRequest("enhance " + actual + ".enh");
	}
	return false;
}
int cc_sourceTerminalEnhanceLeft()
{
	if(cc_haveSourceTerminal())
	{
		int used = get_property("_sourceTerminalEnhanceUses").to_int();

		int total = 1;
		if(get_property("sourceTerminalChips") != "")
		{
			string[int] chips = split_string(get_property("sourceTerminalChips"), ",");
			foreach index in chips
			{
				string chip = trim(chips[index]);
				if((chip == "CRAM") || (chip == "SCRAM"))
				{
					total += 1;
				}
			}
		}
		return total - used;
	}
	return 0;
}

int[string] cc_sourceTerminalMissing()
{
	int[string] status;

	status["ASHRAM"] = 1;
	status["CRAM"] = 1;
	status["DIAGRAM"] = 1;
	status["DRAM"] = 1;
	status["GRAM"] = 10;
	status["INGRAM"] = 1;
	status["PRAM"] = 10;
	status["SCRAM"] = 1;
	status["SPAM"] = 10;
	status["TRAM"] = 1;
	status["TRIGRAM"] = 1;
	status["booze.ext"] = 1;
	status["compress.edu"] = 1;
	status["cram.ext"] = 1;
	status["critical.enh"] = 1;
	status["damage.enh"] = 1;
	status["digitize"] = 3;
	status["digitize.edu"] = 1;
	status["dram.ext"] = 1;
	status["duplicate.edu"] = 1;
	status["educate"] = 2;
	status["enhance"] = 103;
	status["enhanceBuff"] = 100;
	status["enhanceUses"] = 3;
	status["enquiry"] = 250;
	status["extract.edu"] = 1;
	status["familiar.enq"] = 1;
	status["familiar.ext"] = 1;
	status["food.ext"] = 1;
	status["goggles.ext"] = 1;
	status["gram.ext"] = 1;
	status["init.enh"] = 1;
	status["items.enh"] = 1;
	status["meat.enh"] = 1;
	status["monsters.enq"] = 1;
	status["mpReduce"] = 15;
	status["portscan.edu"] = 1;
	status["pram.ext"] = 1;
	status["protect.enq"] = 1;
	status["spam.ext"] = 1;
	status["stats.enq"] = 1;
	status["substats.enh"] = 1;
	status["tram.ext"] = 1;
	status["turbo.edu"] = 1;
	int[string] have = cc_sourceTerminalStatus();
	foreach thing in have
	{
		status[thing] -= have[thing];
	}
	return status;
}

int[string] cc_sourceTerminalStatus()
{
	int[string] status;
	if(cc_haveSourceTerminal())
	{
		string temp = visit_url("campground.php?action=terminal");
		temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=reset");
		temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=status");
		temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=ls");

		matcher ramMatcher = create_matcher("<div>((?:[A-Z]*?)?[RP]AM) (chip(?:s?)) installed([:,]) ((?:\\d+)|(?:\\w))", temp);
		while(ramMatcher.find())
		{
			if(ramMatcher.group(3) == ",")
			{
				status[ramMatcher.group(1)] = 1;
			}
			else
			{
				status[ramMatcher.group(1)] = ramMatcher.group(4).to_int();
			}
		}

		matcher extrude = create_matcher("\\b((?:\\w+?)[.](?:ext|enh|edu|enq))", temp);
		while(extrude.find())
		{
			status[extrude.group(1)] = 1;
		}

#		temp = visit_url("choice.php?pwd=&whichchoice=1191&option=1&input=reset");
		status["enhanceBuff"] = 25 + (25 * status["INGRAM"]) + (5 * status["PRAM"]);
		status["enhanceUses"] = 1 + status["CRAM"] + status["SCRAM"];
		status["enhance"] = status["enhanceBuff"] + status["enhanceUses"];
		status["enquiry"] = 50 + ((status["DIAGRAM"] + 1) * status["GRAM"] * 10);
		status["educate"] = 1 + status["DRAM"];
		status["digitize"] = 1 + status["TRIGRAM"] + status["TRAM"];
		status["mpReduce"] = (5 * status["ASHRAM"]) + status["SPAM"];
	}

	return status;
}

boolean cc_sourceTerminalEducate(skill first, skill second)
{
	if(!cc_haveSourceTerminal())
	{
		return false;
	}
	if(cc_my_path() == "Pocket Familiars")
	{
		return false;
	}
	if(first == $skill[none])
	{
		first = second;
		second = $skill[none];
	}
	if(!contains_text(get_property("sourceTerminalChips"), "DRAM"))
	{
		second = $skill[none];
		set_property("sourceTerminalEducate2", "");
	}

	if(first == $skill[none])
	{
		return false;
	}

	string firstSkill = to_lower_case(to_string(first)) + ".edu";
	string secondSkill = to_lower_case(to_string(second)) + ".edu";

	if((get_property("sourceTerminalEducate1") == firstSkill) || (get_property("sourceTerminalEducate2") == firstSkill))
	{
		if((get_property("sourceTerminalEducate1") == secondSkill) || (get_property("sourceTerminalEducate2") == secondSkill) || (secondSkill == "none.edu"))
		{
			return true;
		}
	}

	cc_sourceTerminalRequest("educate " + firstSkill);
	if(secondSkill != "none.edu")
	{
		cc_sourceTerminalRequest("educate " + secondSkill);
	}
	return true;
}

boolean cc_sourceTerminalEducate(skill first)
{
	return cc_sourceTerminalEducate(first, $skill[none]);
}

boolean cc_haveWitchess()
{
	if(!is_unrestricted($item[Witchess Set]))
	{
		return false;
	}
	return (cc_get_campground() contains $item[Witchess Set]);
}

boolean cc_advWitchess(string target)
{
	return cc_advWitchess(target, "");
}

boolean cc_advWitchess(string target, string option)
{
	if(!cc_haveWitchess())
	{
		return false;
	}

	if(my_adventures() == 0)
	{
		return false;
	}

	int goal = cc_advWitchessTargets(target);
	if(goal == 0)
	{
		return false;
	}

	if(get_property("_cc_witchessBattles").to_int() >= 5)
	{
		return false;
	}

#	if(get_property("_witchessFights").to_int() >= 5)
#	{
#		return false;
#	}

#	if(get_property("_witchessFights").to_int() > get_property("_cc_witchessBattles").to_int())
#	{
#		print("_witchessFights is greater than our tracking, it is probably more accurate at this point (assuming manual Witchess combats).", "red");
#		set_property("_cc_witchessBattles", get_property("_witchessFights"));
#	}

	set_property("_cc_witchessBattles", get_property("_cc_witchessBattles").to_int() + 1);

	string temp = visit_url("campground.php?action=witchess");
	if(!contains_text(temp, "Examine the shrink ray"))
	{
		set_property("_cc_witchessBattles", 5);
		return false;
	}
	temp = visit_url("choice.php?whichchoice=1181&pwd=&option=1");
	matcher witchessMatcher = create_matcher("You can fight (\\d) more piece(s?) today", temp);
	if(witchessMatcher.find())
	{
		int consider = (5 - witchessMatcher.group(1).to_int()) + 1;
		if(consider > get_property("_cc_witchessBattles").to_int())
		{
			set_property("_cc_witchessBattles", consider);
		}
	}
	else
	{
		set_property("_cc_witchessBattles", 5);
		return false;
	}
	temp = visit_url("choice.php?pwd=&option=2&whichchoice=1182");

	string[int] pages;
	pages[0] = "campground.php?action=witchess";
	pages[1] = "choice.php?whichchoice=1181&pwd=&option=1";
	pages[2] = "choice.php?pwd=" + my_hash() + "&whichchoice=1182&option=1&piece=" + goal;

	// We use 4 to cause pages[2] to use GET.
	return ccAdvBypass(4, pages, $location[Noob Cave], option);
}


int cc_advWitchessTargets(string target)
{
	target = to_lower_case(target);
	if((target == "knight") || (target == "meat") || (target == "food"))
	{
		return 1936;
	}
	if((target == "pawn") || (target == "spleen") || (target == "init"))
	{
		return 1935;
	}
	if((target == "bishop") || (target == "item") || (target == "booze"))
	{
		return 1942;
	}
	if((target == "rook") || (target == "ml") || (target == "stats"))
	{
		return 1938;
	}

	if((target == 1942) && (cc_my_path() == "Teetotaler"))
	{
		return 1936;
	}

	if((target == "ox") || (target == "ox-head shield") || (target == "shield") || (target == "pvp") || (target == "hp") || (target == "resist") || (target == "resistance"))
	{
		return 1937;
	}

	if((target == "king") || (target == "dented scepter") || (target == "scepter") || (target == "club") || (target == "muscle") || (target == "hpregen"))
	{
		return 1940;
	}

	if((target == "witch") || (target == "battle broom") || (target == "broom") || (target == "myst") || (target == "mpregen") || (target == "spell"))
	{
		return 1941;
	}

	if((target == "queen") || (target == "very pointy crown") || (target == "crown") || (target == "adv") || (target == "moxie") || (target == "nc") || (target == "noncombat") || (target == "non-combat"))
	{
		return 1939;
	}

	return 0;
}


item cc_bestBadge()
{
	item retval = $item[none];
	foreach it in $items[Plastic Detective Badge, Bronze Detective Badge, Silver Detective Badge, Gold Detective Badge]
	{
		if(possessEquipment(it))
		{
			retval = it;
		}
	}

	return retval;
}

boolean cc_doPrecinct()
{
	if(!is_unrestricted($item[Detective School Application]))
	{
		return false;
	}
	if(!get_property("hasDetectiveSchool").to_boolean())
	{
		return false;
	}
	if(get_property("_detectiveCasesCompleted").to_int() >= 3)
	{
		return false;
	}
	if(svn_info("Ezandora-Detective-Solver-branches-Release").last_changed_rev > 0)
	{
		//Assume if someone has this installed that they want to use it.
		cli_execute("ash import<Detective Solver.ash> solveAllCases(false);");
		return true;
	}

	if(get_property("cc_eggDetective") != "")
	{
		set_property("cc_eggDetective", "");
	}


	string page = visit_url("place.php?whichplace=town_wrong&action=townwrong_precinct");
	matcher eggMatcher = create_matcher("You have been on this case for (\\d+) minute(?:s?)", page);
	if(!eggMatcher.find())
	{
		if(!contains_text(page, "The Precinct"))
		{
			return false;
		}

		int casesLeft = 0;
		matcher precinctMatcher = create_matcher("[(](\\d) more case(?:s?) today[)]", page);
		if(precinctMatcher.find())
		{
			casesLeft = to_int(precinctMatcher.group(1));
			print("We have " + casesLeft + " case(s) leftover!", "green");
		}

		if(casesLeft == 0)
		{
			page = visit_url("wham.php", false);
			if(!contains_text(page, "You have been on this case for"))
			{
				return false;
			}
			print("Trying to resume case....", "red");
		}

		page = visit_url("choice.php?pwd=&whichchoice=1193&option=1");
		eggMatcher = create_matcher("You have been on this case for (\\d+) minute(?:s?)", page);

		if(!contains_text(page, "murdered with an egg"))
		{
			if(!eggMatcher.find())
			{
				print("Someone was not murdered with an egg.... that's sad." + page, "red");
				return false;
			}
		}
		print("Murdered with an egg! I love Egg!!", "green");
		page = visit_url("wham.php", false);
	}

	eggMatcher = create_matcher("You have been on this case for (\\d+) minute(?:s?)", page);
	if(!eggMatcher.find())
	{
		print("I can not resolve my case situation....", "red");
		return false;
	}

	while(!contains_text(get_property("cc_eggDetective"), "solved"))
	{
		string[int] eggData = split_string(get_property("cc_eggDetective"), ",");
		int i=1;
		while(i<=9)
		{
			boolean visited = false;
			foreach index in eggData
			{
				//print("Subegg: " + eggData[index], "blue");
				string[int] subEgg = split_string(eggData[index], ":");
				if(subEgg[0].to_int() == i)
				{
					visited = true;
					break;
				}
			}

			if(!visited)
			{
				print("Going to visit room: " + i, "green");
				page = visit_url("wham.php?visit=" + i, false);
				matcher personMatcher = create_matcher("<td align=center width=200>(?:\\s+)<img src=[\"](?:[a-z0-9/_.:]+?)[.]gif[\"]>(?:\\s+)<br>(?:\\s+)<b>([a-zA-Z ]+?)</b>(?:\\s+?)<br>(?:\\s+?)([a-zA-Z -]+)(?:\\s+?)<p>(?:\\s+?)[(]([a-zA-Z ']+?)[)]", page);
				if(personMatcher.find())
				{
					string person = personMatcher.group(1);
					string job = personMatcher.group(2);
					string room = personMatcher.group(3);
					print("Found " + personMatcher.group(1), "green");
					print("Found " + personMatcher.group(2), "green");
					print("Found " + personMatcher.group(3), "green");
					string generated = "" + i + ":" + room + ":" + person + ":" + job;

					//Get killer response as well.
					page = visit_url("wham.php?ask=killer&visit=" + i, false);
					matcher killerMatcher = create_matcher("you (?:ask|say)(?:.*?)<p>(.*?)(\\s*?)<!-- </div> -->", page);
					if(killerMatcher.find())
					{
						string killerInfo = killerMatcher.group(1);
						killerInfo = replace_string(killerInfo, ",", "");
						killerInfo = replace_string(killerInfo, ":", "");
						killerInfo = replace_string(killerInfo, "<p>", "");
						killerInfo = replace_string(killerInfo, "<i>", "");
						killerInfo = replace_string(killerInfo, "</i>", "");

						string[int] nameSplit = split_string(person, " ");
						foreach index in nameSplit
						{
							killerInfo = replace_string(killerInfo, nameSplit[index], "");
						}
						generated += ":" + killerInfo;
					}
					else
					{
						print("Jerkwad '" + person + "' won't say anything!", "blue");
						generated += ":liar";
					}
					set_property("cc_eggDetective", generated + "," + get_property("cc_eggDetective"));
				}
			}
			i += 1;
		}

		eggData = split_string(get_property("cc_eggDetective"), ",");
		print("Generating goals...", "blue");
		//At this point we\'ve visited every place and queried everyone. Now we need to determine who is identifying a killer.

		//Extract names and jobs
		boolean[string] personGoals;
		boolean[string] jobGoals;
		boolean[string] locationGoals;
		foreach index in eggData
		{
			if(eggData[index] == "")
			{
				continue;
			}
			string[int] subEgg = split_string(eggData[index], ":");
			personGoals[subEgg[2]] = true;
			jobGoals[subEgg[3]] = true;
			locationGoals[subEgg[1]] = true;
		}

		print("Verifications....", "blue");
		foreach index in eggData
		{
			//print("Subegg: " + eggData[index], "blue");
			string[int] subEgg = split_string(eggData[index], ":");
			if(count(subEgg) < 4)
			{
				continue;
			}
			boolean isTruth = true;
			if(subEgg[4] == "liar")
			{
				isTruth = false;
			}
			if(subEgg[4] != "liar")
			{
				boolean hasAnyone = false;
				string oldValue = subEgg[4];
				foreach goal in personGoals
				{
					matcher goalMatcher = create_matcher("\\b" + goal + "\\b",subEgg[4]);
					if(goalMatcher.find())
					{
						hasAnyone = true;
						subEgg[4] = goal;
					}
				}
				foreach goal in jobGoals
				{
					matcher goalMatcher = create_matcher("\\b" + goal + "\\b",subEgg[4]);
					if(goalMatcher.find())
					{
						hasAnyone = true;
						subEgg[4] = goal;
					}
				}
				string replaceString = "liar";
				if(hasAnyone)
				{
					replaceString = subEgg[4];
				}

				string temp = get_property("cc_eggDetective");
				temp = replace_string(temp, oldValue, replaceString);
				set_property("cc_eggDetective", temp);
				eggData = split_string(get_property("cc_eggDetective"), ",");
				subEgg[4] = replaceString;
			}
			if(subEgg[4] != "liar")
			{
				print(subEgg[2] + " is accusing: " + subEgg[4], "blue");
				//Now we need to determine if they are lying or not.
				int currentLocation = to_int(subEgg[0]);
				page = visit_url("wham.php?visit=" + currentLocation, false);

				int otherPerson = 1;
				boolean corrupted = false;
				string locationName = subEgg[1];
				while((otherPerson <= 9) && isTruth)
				{
					if(currentLocation == otherPerson)
					{
						otherPerson += 1;
						continue;
					}

					string[int] currentEgg;
					foreach index in eggData
					{
						string[int] subEgg = split_string(eggData[index], ":");
						if(to_int(subEgg[0]) == otherPerson)
						{
							currentEgg = subEgg;
						}
					}

					page = visit_url("wham.php?ask=" + otherPerson + "&visit=" + currentLocation, false);
					matcher killerMatcher = create_matcher("you (?:ask|say)(?:.*?)<p>(.*?)(\\s*?)<!-- </div> -->", page);
					if(killerMatcher.find())
					{
						string killerInfo = killerMatcher.group(1);
						//We are asking to attach a job to the person. They might not know.
						//We need to look up the particular person.
						boolean exact = false;
						int count = 0;
						foreach goal in jobGoals
						{

							matcher goalMatcher = create_matcher("\\b" + goal + "\\b",killerInfo);
							if(goalMatcher.find())
							{
								if(goal != currentEgg[3])
								{
									print("Asked about " + currentEgg[2] + "," + currentEgg[3] + " and was told: " + goal, "red");
									count += 1;
								}
								else
								{
									exact = true;
								}
							}
						}
						if(!exact && (count != 0))
						{
							isTruth = false;
						}

						exact = false;
						count = 0;
						foreach goal in locationGoals
						{
							matcher goalMatcher = create_matcher("\\b" + goal + "\\b",killerInfo);
							if(goalMatcher.find())
							{
								if(goal != currentEgg[1])
								{
									print("Asked about " + currentEgg[2] + "," + currentEgg[1] + " and was told: " + goal, "red");
									count += 1;
								}
								else
								{
									exact = true;
								}
							}
						}
						if(!exact && (count != 0))
						{
							if(killerInfo == locationName)
							{
								if(corrupted)
								{
									print("Doubly corrupted possible truth teller. This person is probably correct.", "blue");
									return false;
								}
								print("Corrupted truth teller? Going to retry....", "red");
								corrupted = true;
								continue;
							}
							isTruth = false;
						}
					}

					//if still isTruth, we can try the relative questions if so desired.
					//Really, we should check the list of accused and try to uniquify it.

					otherPerson += 1;
					corrupted = false;
				}
			}
			if(subEgg[4] == "liar")
			{
				isTruth = false;
			}
			if(isTruth)
			{
				print(subEgg[2] + " is accusing: " + subEgg[4] + " and may be telling the truth!", "blue");
				//Find person they are accusing and do it.

				string[int] currentEgg;
				foreach index in eggData
				{
					string[int] subsubEgg = split_string(eggData[index], ":");
					if((subsubEgg[2] == subEgg[4]) || (subsubEgg[3] == subEgg[4]))
					{
						print("Accusation against: " + subsubEgg[2], "blue");
						page = visit_url("wham.php?visit=" + subsubEgg[0], false);

						eggMatcher = create_matcher("You have been on this case for (\\d+) minute(?:s?)", page);
						if(eggMatcher.find())
						{
							print("On the case for " + eggMatcher.group(1) + " minutes...", "green");
						}

						page = visit_url("wham.php?visit=" + subsubEgg[0] + "&accuse=" + subsubEgg[0], false);
						matcher pensionMatcher = create_matcher("been awarded (\\d+) cop dollars", page);
						if(pensionMatcher.find())
						{
							print("Received a pension of " + pensionMatcher.group(1) + " cop dollars.", "green");
						}
						set_property("cc_eggDetective", "");
						return true;
					}
				}
			}
		}

		set_property("cc_eggDetective", get_property("cc_eggDetective") + "solved");
		return false;
	}

	return true;
}

boolean expectGhostReport()
{
	if(total_turns_played() >= get_property("nextParanormalActivity").to_int())
	{
		if(total_turns_played() > get_property("nextParanormalActivity").to_int())
		{
			string page = visit_url("charpane.php");
			matcher myGhost = create_matcher("<tr rel=\"protonquest\">(?:.*?)<b>(.*?)</b>", page);
			if(myGhost.find())
			{
				location goal = to_location(myGhost.group(1));
				set_property("ghostLocation", goal);
				set_property("questPAGhost", "started");
			}
		}
#<tr rel="protonquest"><td class="small" colspan="2"><div>Investigate the paranormal activity reported at <A class=nounder target=mainpane href=place.php?whichplace=manor1><b>The Haunted Conservatory</b></a>.</div></td></tr>

		if(get_property("questPAGhost") == "unstarted")
		{
			return true;
		}
	}
	return false;
}

boolean haveGhostReport()
{
	if(get_property("questPAGhost") == "unstarted")
	{
		return false;
	}
	if((get_property("questPAGhost") == "started") && (get_property("ghostLocation") != ""))
	{
		return true;
	}
	return false;
}


boolean LX_ghostBusting()
{
	if(!possessEquipment($item[Protonic Accelerator Pack]))
	{
		return false;
	}
	if(get_property("questPAGhost") == "unstarted")
	{
		if(!expectGhostReport())
		{
			return false;
		}
		if(get_property("questPAGhost") == "unstarted")
		{
			return false;
		}
	}

	location goal = get_property("ghostLocation").to_location();
	boolean canAttempt = have_equipped($item[Protonic Accelerator Pack]);
	if(possessEquipment($item[Protonic Accelerator Pack]) && can_equip($item[Protonic Accelerator Pack]))
	{
		canAttempt = true;
	}

	if((goal != $location[none]) && canAttempt)
	{
		if((cc_my_path() == "Community Service") && (my_daycount() == 1) && (goal == $location[The Spooky Forest]))
		{
			return false;
		}

		useCocoon();
		print("Ghost busting time! At: " + get_property("ghostLocation"), "blue");
		boolean newbieFail = false;
		if(goal == $location[The Skeleton Store])
		{
			startMeatsmithSubQuest();
			if(internalQuestStatus("questM23Meatsmith") == -1)
			{
				newbieFail = true;
			}
			else if(internalQuestStatus("questM23Meatsmith") == 0)
			{
				if(item_amount($item[Skeleton Store Office Key]) > 0)
				{
					set_property("choiceAdventure1060", 4);
				}
				else
				{
					set_property("choiceAdventure1060", 1);
				}
			}
			else
			{
				set_property("choiceAdventure1060", 2);
			}
		}
		if(item_amount($item[Check to the Meatsmith]) > 0)
		{
			string temp = visit_url("shop.php?whichshop=meatsmith");
			temp = visit_url("choice.php?pwd=&whichchoice=1059&option=2");
			return true;
		}
		if(goal == $location[Madness Bakery])
		{
			startArmorySubQuest();
			if(internalQuestStatus("questM25Armorer") == -1)
			{
				newbieFail = true;
			}
			else if(internalQuestStatus("questM25Armorer") <= 1)
			{
				set_property("choiceAdventure1061", 1);
			}
			else
			{
				set_property("choiceAdventure1061", 5);
			}
		}
		if(item_amount($item[no-handed pie]) > 0)
		{
			string temp = visit_url("shop.php?whichshop=armory");
			temp = visit_url("choice.php?pwd=&whichchoice=1065&option=2");
			return true;
		}
		if(goal == $location[The Overgrown Lot])
		{
			//Meh.
			startGalaktikSubQuest();
			if(internalQuestStatus("questM24Doc") == -1)
			{
				newbieFail = true;
			}
			else if(get_property("questM24Doc") != "finished")
			{
				set_property("choiceAdventure1062", 1);
			}
			else
			{
				set_property("choiceAdventure1062", 4);
			}
		}
		if((item_amount($item[Swindleblossom]) >= 3) && (item_amount($item[Fraudwort]) >= 3) && (item_amount($item[Shysterweed]) >= 3))
		{
			string temp = visit_url("shop.php?whichshop=doc");
			temp = visit_url("shop.php?whichshop=doc&action=talk");
			temp = visit_url("choice.php?pwd=&whichchoice=1064&option=2");
			return true;
		}
		if((goal == $location[The Batrat and Ratbat Burrow]) && (internalQuestStatus("questL04Bat") < 1))
		{
			return false;
		}
		if((goal == $location[Cobb\'s Knob Laboratory]) && (item_amount($item[Cobb\'s Knob Lab Key]) == 0))
		{
			return false;
		}

		if((goal == $location[Lair of the Ninja Snowmen]) && ((get_property("cc_trapper") != "yeti") && (get_property("cc_trapper") != "finished")))
		{
			return false;
		}
		if((goal == $location[The VERY Unquiet Garves]) && (get_property("cc_crypt") != "finished"))
		{
			return false;
		}
		if(goal == $location[The Castle in the Clouds in the Sky (Top Floor)])
		{
			if(get_property("cc_castleground") != "finished")
			{
				return false;
			}
			if(L10_topFloor() || L10_holeInTheSkyUnlock())
			{
				return true;
			}
		}
		if(goal == $location[Lair of the Ninja Snowmen])
		{
			if((item_amount($item[Ninja Rope]) == 0) || (item_amount($item[Ninja Carabiner]) == 0) || (item_amount($item[Ninja Crampons]) == 0))
			{
				if(L8_trapperYeti())
				{
					return true;
				}
			}
		}

		if((goal == $location[The Red Zeppelin]) && (internalQuestStatus("questL11Ron") < 3))
		{
			return false;
		}
		if((goal == $location[The Hidden Park]) && (get_property("cc_hiddenunlock") == "finished"))
		{
			return false;
		}

		item replaceAcc3 = $item[none];
		if(goal == $location[Inside The Palindome])
		{
			if(!possessEquipment($item[Talisman O\' Namsilat]))
			{
				return false;
			}
			if(equipped_item($slot[acc3]) != $item[Talisman O\' Namsilat])
			{
				replaceAcc3 = equipped_item($slot[acc3]);
				equip($slot[acc3], $item[Talisman O\' Namsilat]);
			}
		}

		if(newbieFail)
		{
			print("Can't bust that ghost, we don't feel good!!", "blue");
			abort("Ghost busting failure, this should not happen");
			set_property("questPAGhost", "unstarted");
			set_property("ghostLocation", "");
			return false;
		}

		if((equipped_item($slot[Back]) != $item[Protonic Accelerator Pack]) && can_equip($item[Protonic Accelerator Pack]))
		{
			equip($slot[Back], $item[Protonic Accelerator Pack]);
		}

		print("Time to bust some ghosts!!!", "green");
		boolean advVal = ccAdv(goal);
		if(replaceAcc3 != $item[none])
		{
			equip($slot[acc3], replaceAcc3);
		}
		if(have_effect($effect[Beaten Up]) == 0)
		{
			set_property("questPAGhost", "unstarted");
			set_property("ghostLocation", "");
		}

		return advVal;
	}
	return false;
}

boolean timeSpinnerGet(string goal)
{
	goal = to_lower_case(goal);
	if(!($strings[booze, drink, food, memory, history, ears, mall, none] contains goal))
	{
		return false;
	}

	if($strings[booze, drink, food, memory, history, ears, mall] contains goal)
	{
		if(get_property("_timeSpinnerReplicatorUsed").to_boolean())
		{
			return false;
		}
	}

	if((goal == "booze") && (get_property("timeSpinnerMedals").to_int() < 5))
	{
		return false;
	}
	if((goal == "drink") && (get_property("timeSpinnerMedals").to_int() < 5))
	{
		return false;
	}
	if((goal == "food") && (get_property("timeSpinnerMedals").to_int() < 15))
	{
		return false;
	}
	if((goal == "history") && (get_property("timeSpinnerMedals").to_int() < 10))
	{
		return false;
	}
	if((goal == "memory") && (get_property("timeSpinnerMedals").to_int() < 20))
	{
		return false;
	}

	if(is_unrestricted($item[Time-Spinner]) && (item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() <= 8))
	{
		if(svn_info("Ezandora-Far-Future-branches-Release").last_changed_rev > 0)
		{
			//Required by dependencies
			cli_execute("FarFuture " + goal);
			return true;
		}
		return false;
	}
	return false;
}
boolean timeSpinnerConsume(item goal)
{
	if(is_unrestricted($item[Time-Spinner]) && (item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() <= 7))
	{
		string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9104");
		if(get_property("_timeSpinnerMinutesUsed").to_int() <= 7)
		{
			temp = visit_url("choice.php?pwd=&whichchoice=1195&option=2");
			temp = visit_url("choice.php?pwd=&whichchoice=1197&option=1&foodid=" + to_int(goal));
		}
	}
	return false;
}

boolean timeSpinnerAdventure()
{
	return timeSpinnerAdventure("");
}

boolean timeSpinnerAdventure(string option)
{
	if(is_unrestricted($item[Time-Spinner]) && (item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() <= 9))
	{
		string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9104");
		if(get_property("_timeSpinnerMinutesUsed").to_int() <= 9)
		{
			string[int] pages;
			pages[0] = "inv_use.php?pwd=&which=3&whichitem=9104";
			pages[1] = "choice.php?pwd=&whichchoice=1195&option=3";
			if(ccAdvBypass(0, pages, $location[Noob Cave], option)) {}
			return true;
		}
	}
	return false;
}


boolean timeSpinnerCombat(monster goal)
{
	return timeSpinnerCombat(goal, "");
}

boolean timeSpinnerCombat(monster goal, string option)
{
	if(is_unrestricted($item[Time-Spinner]) && (item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() <= 7))
	{
		string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9104");
		if(get_property("_timeSpinnerMinutesUsed").to_int() <= 7)
		{
			string[int] pages;
			pages[0] = "inv_use.php?pwd=&which=3&whichitem=9104";
			pages[1] = "choice.php?pwd=&whichchoice=1195&option=1";
			pages[2] = "choice.php?pwd=&whichchoice=1196&option=1&monid=" + goal.id;
			if(ccAdvBypass(0, pages, $location[Noob Cave], option))
			{}
			else
			{
				if(get_property("lastEncounter") == "Travel to a Recent Fight")
				{
					string temp = visit_url("choice.php?pwd&whichchoice=1196&option=2");
				}
				else
				{
					abort("Time-Spinner combat failed and we were unable to leave the Time-Spinner");
				}
				return false;
			}
			
			return true;
		}
	}
	return false;
}

boolean rethinkingCandyList()
{
	boolean[effect] synthesis = $effects[Synthesis: Hot, Synthesis: Cold, Synthesis: Pungent, Synthesis: Scary, Synthesis: Greasy, Synthesis: Strong, Synthesis: Smart, Synthesis: Cool, Synthesis: Hardy, Synthesis: Energy, Synthesis: Greed, Synthesis: Collection, Synthesis: Movement, Synthesis: Learning, Synthesis: Style];
	foreach eff in synthesis
	{
		print("Trying effect: " + eff + ": " + string_modifier(eff, "Modifiers") , "orange");
		rethinkingCandy(eff, true);
	}
	return true;
}

boolean rethinkingCandy(effect acquire)
{
	return rethinkingCandy(acquire, false);
}

boolean rethinkingCandy(effect acquire, boolean simulate)
{
	if(!have_skill($skill[Sweet Synthesis]) && !simulate)
	{
		return false;
	}
	if((spleen_left() == 0) && !simulate)
	{
		return false;
	}

	boolean[effect] synthesisList = $effects[Synthesis: Hot, Synthesis: Cold, Synthesis: Pungent, Synthesis: Scary, Synthesis: Greasy, Synthesis: Strong, Synthesis: Smart, Synthesis: Cool, Synthesis: Hardy, Synthesis: Energy, Synthesis: Greed, Synthesis: Collection, Synthesis: Movement, Synthesis: Learning, Synthesis: Style];
	effect[int] synthesis = List(synthesisList);

	if(!(synthesisList contains acquire))
	{
		return false;
	}

	int maxprice = 2500;
	if(get_property("cc_maxCandyPrice").to_int() != 0)
	{
		maxprice = get_property("cc_maxCandyPrice").to_int();
	}

	item[int] simpleList;
	item[int] complexList;
	foreach it in $items[]
	{
		if(it.candy && (item_amount(it) > 0) && (cc_mall_price(it) <= maxprice) && it.tradeable)
		{
			if(it.candy_type == "simple")
			{
				simpleList[count(simpleList)] = it;
			}
			else if(it.candy_type == "complex")
			{
				complexList[count(complexList)] = it;
			}
		}
	}

	sort simpleList by cc_mall_price(value);
	sort complexList by cc_mall_price(value);
	item[int] simple = List(simpleList);
	item[int] complex = List(complexList);

#	foreach idx, it in simple
#	{
#		print(it + ": " + item_amount(it) + " (" + to_int(it) + "): " + it.candy_type + " Cost: " + cc_mall_price(it), "blue");
#	}
#
#	foreach idx, it in complex
#	{
#		print(it + ": " + item_amount(it) + " (" + to_int(it) + "): " + it.candy_type + " Cost: " + cc_mall_price(it), "blue");
#	}

	int bestCost = 2 * maxprice;
	item bestFirst = $item[none];
	item bestSecond = $item[none];
	if($effects[Synthesis: Hot, Synthesis: Cold, Synthesis: Pungent, Synthesis: Scary, Synthesis: Greasy] contains acquire)
	{
		int goal = ListFind(synthesis, acquire) % 5;
		for(int i=0; i<count(simple); i++)
		{
			int current = to_int(simple[i]);
			int startNextIndex = i+1;
			if(item_amount(simple[i]) > 1)
			{
				startNextIndex = i;
			}
			for(int j=startNextIndex; j<count(simple); j++)
			{
				int sum = (to_int(simple[j]) + current) % 5;
				if(sum == goal)
				{
					if(simulate)
					{
						print("Possible: " + simple[i] + ", " + simple[j], "blue");
					}
					if((cc_mall_price(simple[i]) + cc_mall_price(simple[j])) < bestCost)
					{
						bestCost = cc_mall_price(simple[i]) + cc_mall_price(simple[j]);
						bestFirst = simple[i];
						bestSecond = simple[j];
					}
				}
			}
		}
	}
	else if($effects[Synthesis: Strong, Synthesis: Smart, Synthesis: Cool, Synthesis: Hardy, Synthesis: Energy] contains acquire)
	{
		int goal = ListFind(synthesis, acquire) % 5;
		for(int i=0; i<count(simple); i++)
		{
			int current = to_int(simple[i]);
			for(int j=0; j<count(complex); j++)
			{
				int sum = (to_int(complex[j]) + current) % 5;
				if(sum == goal)
				{
					if(simulate)
					{
						print("Possible: " + simple[i] + ", " + complex[j], "blue");
					}
					if((cc_mall_price(simple[i]) + cc_mall_price(complex[j])) < bestCost)
					{
						bestCost = cc_mall_price(simple[i]) + cc_mall_price(complex[j]);
						bestFirst = simple[i];
						bestSecond = complex[j];
					}
				}
			}
		}
	}
	else if($effects[Synthesis: Greed, Synthesis: Collection, Synthesis: Movement, Synthesis: Learning, Synthesis: Style] contains acquire)
	{
		int goal = ListFind(synthesis, acquire) % 5;
		for(int i=0; i<count(complex); i++)
		{
			int current = to_int(complex[i]);
			int startNextIndex = i+1;
			if(item_amount(complex[i]) > 1)
			{
				startNextIndex = i;
			}
			for(int j=startNextIndex; j<count(complex); j++)
			{
				int sum = (to_int(complex[j]) + current) % 5;
				if(sum == goal)
				{
					if(simulate)
					{
						print("Possible: " + complex[i] + ", " + complex[j], "blue");
					}
					if((cc_mall_price(complex[i]) + cc_mall_price(complex[j])) < bestCost)
					{
						bestCost = cc_mall_price(complex[i]) + cc_mall_price(complex[j]);
						bestFirst = complex[i];
						bestSecond = complex[j];
					}
				}
			}
		}
	}
	else
	{
		return false;
	}

	if(bestFirst != $item[none])
	{
		print("Best case: " + bestFirst + ", " + bestSecond + ": " + bestCost, "green");
		if(!simulate)
		{
			int prior = have_effect(acquire);
			string temp = visit_url("runskillz.php?pwd=&targetplayer=" + my_id() + "&quantity=1&whichskill=166");

			string url = "choice.php?whichchoice=1217&option=1&pwd=&a=" + to_int(bestFirst) + "&b=" + to_int(bestSecond);
			temp = visit_url(url);
			if(have_effect(acquire) == prior)
			{
				abort("Failed to Sweetly Synthesize: " + url);
			}
		}
		return true;
	}
	else if(simulate)
	{
		print("Could not find a possible candy combination", "red");
	}
	else
	{
		return false;
	}
	return false;
}
