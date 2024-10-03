boolean in_wereprof()
{
	return my_path() == $path[WereProfessor];
}

void wereprof_initializeSettings()
{
	if(!in_wereprof())
	{
		return;
	}
	set_property("auto_wandOfNagamar", false);		//wand not used in this path
	cli_execute('wereprofessor research');			//parse the research bench
}

boolean is_werewolf()
{
	if(!in_wereprof())
	{
		return false;
	}
	if(have_effect($effect[Savage Beast]) > 0)
	{
		return true;
	}
	return false;
}

boolean is_professor()
{
	if(!in_wereprof())
	{
		return false;
	}
	if(have_effect($effect[Mild-Mannered Professor]) > 0)
	{
		return true;
	}
	return false;
}

void wereprof_buySkills()
{
	if(!in_wereprof())
	{
		return;
	}
	int rp = get_property("wereProfessorResearchPoints").to_int();
	if(is_werewolf() || rp < 10)
	{
		return; // can't access the research bench as a werewolf and don't care about it when we have less than 10 RP
	}
	if(get_property("beastSkillsAvailable") == "")
	{
		cli_execute('wereprofessor research');			//parse the research bench
	}
	boolean do_skills = true;
	if(get_property("wereProfessorTransformTurns").to_int() > 3)
	{
		do_skills = false; //Want as many RP as possible before looping through the skills
	}
	if((is_professor() && turns_played() == 0))
	{
		auto_log_info("Buy skills first", "blue");
		do_skills = true; //Do skills before we do anything else
	}
	if(organsFull() && my_adventures() <= auto_advToReserve() && !(contains_text(get_property("beastSkillsKnown").to_string(), "stomach3") && contains_text(get_property("beastSkillsKnown").to_string(), "liver3")))
	{
		auto_log_info("Need more organs", "blue");
		do_skills = true; //If organs are full, should do skills if we need more organ space and don't have all organ expanding skills and limited adventures left
	}
	int cantbuy;
	/* Taken from wereprofessor.txt in Mafia src
	# Muscle Skill Tree
	mus1	10	none	Osteocalcin injection	Mus +20%
	mus2	20	mus1	Somatostatin catalyst	Mus +30%
	mus3	30	mus2	Endothelin suspension	Mus +50%
	rend1	20	mus3	Ultraprogesterone potion	Rend (Phys)
	rend2	30	rend1	Lactide blocker	Increase damage
	rend3	40	rend2	Haemostatic membrane treatment	Restores HP
	slaughter	100	rend3	Norepinephrine transfusion	Slaughter (Instant)
	hp1	20	mus3	Synthetic prostaglandin	Max HP +20%
	hp2	30	hp1	Leukotriene elixir	Max HP +30%
	hp3	40	hp2	Thromboxane inhibitor	Max HP +50%
	skin1	40	hp3	Calcitonin powder	DR 5
	skin2	50	skin1	Enkephalin activator	DR 10
	skin3	60	skin2	Oxytocin inversion	DR 15
	skinheal	100	skin3	Hemostatic accelerant	Regen 8-10 HP
	stomach1	40	hp3	Triiodothyronine accelerator	Stomach +3
	stomach2	50	stomach1	Thyroxine supplements	Stomach +3
	stomach3	60	stomach2	Amyloid polypeptide mixture	Stomach +3
	feed	100	stomach3	Cholecystokinin antagonist	(Unimplemented)

	# Mysticality Skill Tree
	myst1	10	none	Galanin precipitate	Myst +20%
	myst2	20	myst1	Cortistatin blocker	Myst +30%
	myst3	30	myst2	Prolactin inhibitor	Myst +50%
	bite1	20	myst3	Fluoride rinse	Bite (Stench)
	bite2	30	bite1	Proton pump eliminator	Add (Sleaze)
	bite3	40	bite2	Bisphosphonate drip	Increase damage
	howl	100	bite3	Albuterol innundation	Howl (Stun)
	res1	20	myst3	Omega-3 megadose	Resist All +20%
	res2	30	res1	Omega-6 hyperdose	Resist All +20%
	res3	40	res2	Omega-9 omegadose	Resist All +20%
	items1	40	res3	Diphenhydramine eyedrops	Item Drop 25%
	items2	50	items1	Carbinoxamine eye wash	Item Drop +25%
	items3	60	items2	Intraocular cyproheptadine injections	Item Drop +25%
	hunt	100	items3	Phantosmic tincture	Hunt (Olfaction)
	ml1	40	res3	Anabolic megatestosterone	ML +10
	ml2	50	ml1	Hyperadrenal Pheremones	ML +15
	ml3	60	ml2	Synthetic Rhabdovirus	ML +25
	feasting	100	ml3	Peptide catalyst	Regain more HP

	# Moxie Skill Tree
	mox1	10	none	Dopamine slurry	Mox +20% 
	mox2	20	mox1	Relaxin balm	Mox +30%
	mox3	30	mox2	Melatonin suppositories	Mox +50%
	kick1	20	mox3	Hamstring-tightening solution	Kick (Delevel)
	kick2	30	kick1	Gluteal 4-Androstenediol inection	Improve Kick
	kick3	40	kick2	Subcutaneous dimethandrolone implant	Kick (Stun)
	punt	100	kick3	Novel catecholamine synthesis	Punt (Banish)
	init1	20	mox3	Adrenal decoction	Init +50%
	init2	30	init1	Adrenal distillate	Init +50%
	init3	40	init2	Concentrated adrenaline extract	Init +100%
	meat1	40	init3	Leptin modulator	Meat Drop +25%
	meat2	50	meat1	Carnal dehydrogenase infusion	Meat Drop +50%
	meat3	60	meat2	Dihydrobenzophenanthridine injection	Meat Drop +75%
	perfecthair	100	meat3	Janus kinase blockers	+5 Stats/Fight
	liver1	40	init3	Glucagon condensate	Liver +3
	liver2	50	liver1	Secretin agonist	Liver +3
	liver3	60	liver2	Synthetic aldosterone	Liver +3
	pureblood	100	liver3	Synthroid-parathormone cocktail	Shorten ELR
	*/
	int[string] rpcost = {"stomach3": 60, "liver3": 60, "stomach2": 50, "liver2":50, "stomach1": 40, "liver1": 40, "hp3": 40, "init3": 40, "hp2": 30, "init2": 30,
	"hp1": 20, "init1": 20, "mus3": 30, "mox3": 30, "mus2": 20, "mox2": 20, "mus1": 10, "mox1": 10, "punt": 100, "slaughter": 100, "hunt": 100, "kick3": 40, "kick2": 30,
	"kick1": 20, "rend3": 40, "rend2": 30, "rend1": 20, "items3": 60, "items2": 50, "items1": 40, "res3": 40, "res2": 30, "res1": 20, "myst3": 30, "myst2": 20, "myst1": 10,
	"bite3": 40, "bite2": 30, "bite1": 20, "perfecthair": 100, "meat3": 60, "meat2": 50, "meat1": 40, "ml3": 60, "ml2": 50, "ml1": 40, "skin3": 60, "skin2": 50, "skin1": 40,
	"pureblood": 100, "feasting": 100, "skinheal": 100, "howl": 100, "feed": 100};
	if(do_skills)
	{
		auto_log_info("Buying skills", "blue");
		while(rp >= 10)
		{
			cantbuy = 0;
			//Priority is: Expanding organs, useful skills (banish, instakill, ELR CD), stat gains, +meat, DR, relatively useless skills and waiting on Mafia support skills
			foreach sk in $strings[stomach3, liver3, stomach2, liver2, stomach1, liver1, hp3, init3, hp2, init2, hp1, init1, mus3,
			mox3, mus2, mox2, mus1, mox1, punt, slaughter, pureblood, kick3, kick2, kick1, rend3, rend2, rend1, items3, items2, items1,
			res3, res2, res1, myst3, myst2, myst1, bite3, bite2, bite1, perfecthair, meat3, meat2, meat1, ml3, ml2, ml1, skin3,
			skin2, skin1, hunt, feasting, skinheal, howl, feed]
			{
				if(contains_text(get_property("beastSkillsAvailable").to_string(), sk))
				{
					if(rpcost[sk] > rp)
					{
						cantbuy += 1;
						if(cantbuy==count(split_string(get_property("beastSkillsAvailable").to_string(),",")))
						{
							return; //return if we can't buy any beast skills
						}
					}
					else
					{
						auto_log_info("Buying " + sk, "blue");
						cli_execute('wereprofessor research ' + sk);
						rp = get_property("wereProfessorResearchPoints").to_int();
						break; //break on buy to reset the foreach loop to look from the top
					}
				}
			}
		}
	}
	return;
}

boolean wereprof_haveAllEquipment()
{
	//Only care about the final equipment
	if(!possessEquipment($item[triphasic molecular oculus]) || !possessEquipment($item[irresponsible-tension exoskeleton]))
	{
		return false;
	}
	return true;
}

void wereprof_buyEquip()
{
	if(is_werewolf() || wereprof_haveAllEquipment())
	{
		return; // can't tinker if we are a werewolf and don't care about anything but the best oculus and exoskeleton
	}
	
	//There's probably a better way to do this
	while(item_amount($item[smashed scientific equipment]) >= 1)
	{
		while(!possessEquipment($item[triphasic molecular oculus]) || !possessEquipment($item[irresponsible-tension exoskeleton]))
		{
			if(!possessEquipment($item[biphasic molecular oculus]) && !possessEquipment($item[triphasic molecular oculus]))
			{
				cli_execute('tinker biphasic molecular oculus');
				break;
			}
			if(possessEquipment($item[biphasic molecular oculus]) && !possessEquipment($item[triphasic molecular oculus]))
			{
				cli_execute('tinker triphasic molecular oculus');
				break;
			}
			if(!possessEquipment($item[high-tension exoskeleton]) && !possessEquipment($item[ultra-high-tension exoskeleton]) && !possessEquipment($item[irresponsible-tension exoskeleton]))
			{
				cli_execute('tinker high-tension exoskeleton');
				break;
			}
			if(possessEquipment($item[high-tension exoskeleton]) && !possessEquipment($item[ultra-high-tension exoskeleton]) && !possessEquipment($item[irresponsible-tension exoskeleton]))
			{
				cli_execute('tinker ultra-high-tension exoskeleton');
				break;
			}
			if(!possessEquipment($item[high-tension exoskeleton]) && possessEquipment($item[ultra-high-tension exoskeleton]) && !possessEquipment($item[irresponsible-tension exoskeleton]))
			{
				cli_execute('tinker irresponsible-tension exoskeleton');
				break;
			}
		}
	}
}

boolean wereprof_oculus()
{
	if(!in_wereprof())
	{
		return false;
	}
	if(have_equipped($item[biphasic molecular oculus]) || have_equipped($item[triphasic molecular oculus]))
	{
		return true;
	}
	return false;
}

boolean LM_wereprof()
{
	if(!in_wereprof())
	{
		return false;
	}
	if(is_werewolf())
	{
		return false;
	}
	item elixer = $item[Doc Galaktik\'s Homeopathic Elixir];
	int elixerAmount = item_amount(elixer);
	if(elixerAmount < 10 && (my_meat() - npc_price(elixer) > meatReserve()))
	{
		// make a stock pile of 10 healing items to use as needed when werewolf
		// buy a single one each time through to slowly build it
		auto_buyUpTo(elixerAmount + 1, elixer);
	}

	auto_log_info("Getting skills", "blue");
	wereprof_buySkills();
	auto_log_info("Getting equipment", "blue");
	wereprof_buyEquip();
	
	if(!get_property("auto_haveoven").to_boolean()) //buy an oven ASAP
	{
		auto_log_info("Buying an oven", "blue");
		ovenHandle();
		return true;
	}
	return false;
}

boolean LX_wereprof_getSmashedEquip()
{
	if(!in_wereprof())
	{
		return false;
	}
	if(is_professor() || wereprof_haveAllEquipment())
	{
		return false;
	}

	location[int] smashedLocs;
	string alreadySmashedLocs = get_property("antiScientificMethod").to_string();
	//There's a couple other locations, but we shouldn't EVER visit them
	foreach sl in $locations[The Hidden Hospital, The Castle in the Clouds in the Sky (Top Floor), Noob Cave, The Haunted Pantry, The Thinknerd Warehouse, Vanya's Castle]
	{
		if(!contains_text(alreadySmashedLocs,sl.to_string()) && zone_available(sl))
		{
			auto_log_info("Going for Smashed Scientific Equipment in " + sl.to_string(), "blue");
			return autoAdv(1, sl);
		}
	}
	return false;
}

boolean wereprof_usable(string str)
{
	if(!in_wereprof())
	{
		return true;
	}
	if(str == "Stooper") //currently only thing we don't want at all
	{
		return false;
	}
	return true;
}
