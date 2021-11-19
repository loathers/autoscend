// All prototypes for this code described in autoscend_header.ash

boolean LX_artistQuest()
{
	if((get_property("auto_doArtistQuest").to_boolean()) && (get_property("questM02Artist") != "finished"))
	{
		if(get_property("questM02Artist") == "unstarted")
		{
			visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_noquest");
			visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_noquest&getquest=1");
			visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_quest");
		}
		if(get_property("questM02Artist") == "started")
		{
			if(item_amount($item[Pretentious Paintbrush]) == 0)
			{
				autoAdv($location[The Outskirts of Cobb\'s Knob]);
			}
			else if(item_amount($item[Pretentious Palette]) == 0)
			{
				autoAdv($location[The Haunted Pantry]);
			}
			else if(item_amount($item[Pail of Pretentious Paint]) == 0)
			{
				autoAdv($location[The Sleazy Back Alley]);
			}
			else
			{
				visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_quest");
			}
			return true;
		}
		else
		{
			auto_log_warning("Failed starting artist quest, rejecting completely.", "red");
			set_property("auto_doArtistQuest", false);
			return false;
		}
	}
	return false;
}

boolean LX_unlockThinknerdWarehouse(boolean spend_resources)
{
	//unlocks [The Thinknerd Warehouse], returns true if successful or adv is spent
	//much easier to do if you already have torso awaregness
	
	if(internalQuestStatus("questM22Shirt") > -1)
	{
		return false;
	}
	
	auto_log_debug("Trying to unlock [The Thinknerd Warehouse] with spend_resources set to " + spend_resources);
	
	//unlocking is a multi step process. We want to try things in reverse to conserve resources and in case some steps were already complete.
	
	boolean useLetter()
	{
		if(item_amount($item[Letter for Melvign the Gnome]) > 0)
		{
			if(use(1, $item[Letter for Melvign the Gnome]))
			{
				auto_log_debug("Successfully unlocked the [The Thinknerd Warehouse]");
				return true;
			}
			else
			{
				abort("Somehow failed to use [Letter for Melvign the Gnome]... aborting to prevent infinite loops");
			}
		}
		return false;
	}
	
	item target_shirt = $item[none];
	boolean hasShirt = false;
	
	//one time initial scan of inventory
	foreach it in get_inventory()
	{
		if(to_slot(it) == $slot[shirt])
		{
			target_shirt = it;
			hasShirt = true;
			break;
		}
	}
		
	boolean useShirtThenLetter()
	{
		if(!hasShirt)
		{
			return false;
		}
		string temp = visit_url("inv_equip.php?pwd&which=2&action=equip&whichitem=" + target_shirt.to_int());
		if(useLetter()) return true;
		auto_log_error("For some reason LX_unlockThinknerdWarehouse failed when trying to use the shirt [" + target_shirt + "] to get [Letter for Melvign the Gnome] to start the quest");
		return false;
	}
	void getShirtWhenHaveNone(item it)
	{
		if(hasShirt) return;
		if(canPull(it))
		{
			if(pullXWhenHaveY(it, 1, 0))
			{
				target_shirt = it;
				hasShirt = true;
			}
		}
		else if(creatable_amount(it) > 0 && (spend_resources || knoll_available()))
		{
			if(create(1, it))
			{
				target_shirt = it;
				hasShirt = true;
			}
		}
	}
	
	//if you already had a shirt or a letter, then just unlock the quest now
	if(useLetter()) return true;
	if(useShirtThenLetter()) return true;
	
	//Try to acquire a shirt.
	
	//IOTM that does not require a pull
	januaryToteAcquire($item[Letter For Melvign The Gnome]);	//no stats and no pull required
	if(useLetter()) return true;
	
	//TODO, make the following IOTM foldables actually work
	//getShirtWhenHaveNone($item[flaming pink shirt])		//foldable IOTM that requires torso awaregness.
	//getShirtWhenHaveNone($item[origami pasties])			//foldable IOTM that requires torso awaregness.
	//getShirtWhenHaveNone($item[sugar shirt])				//libram summons sugar sheet, multiuse 1 with torso awaregness to get sugar shirt
	
	//Shirts to pull
	getShirtWhenHaveNone($item[Sneaky Pete\'s leather jacket]);		//useful IOTM shirt with no state requirements to wear
	getShirtWhenHaveNone($item[Sneaky Pete\'s leather jacket (collar popped)]);
	getShirtWhenHaveNone($item[Professor What T-Shirt]);			//you likely have it, no requirements to wear, very cheap in mall
	
	//Shirts to smith. Will likely cost 1 adv unless in knoll sign.
	getShirtWhenHaveNone($item[white snakeskin duster]);		//7 mus req
	getShirtWhenHaveNone($item[clownskin harness]);				//15 mus req
	getShirtWhenHaveNone($item[demonskin jacket]);				//25 mus req
	getShirtWhenHaveNone($item[gnauga hide vest]);				//25 mus req
	getShirtWhenHaveNone($item[tuxedo shirt]);					//35 mus req
	getShirtWhenHaveNone($item[yak anorak]);					//42 mus req
	getShirtWhenHaveNone($item[hipposkin poncho]);				//45 mus req
	getShirtWhenHaveNone($item[lynyrdskin tunic]);				//70 mus req
	getShirtWhenHaveNone($item[bat-ass leather jacket]);		//77 mus req

	//wish for a shirt
	if(spend_resources && auto_wishesAvailable() > 0 && auto_shouldUseWishes() && item_amount($item[blessed rustproof +2 gray dragon scale mail]) == 0)
	{
		makeGenieWish("for a blessed rustproof +2 gray dragon scale mail");
		target_shirt = $item[blessed rustproof +2 gray dragon scale mail];
		hasShirt = true;
	}
	
	//TODO adventure somewhere to acquire shirt
	//if(spend_resources && hasTorso())
	
	//did we succeeded in getting a shirt? use it and then the letter.
	if(useShirtThenLetter()) return true;
	
	//sadness, we couldn't unlock this zone.
	auto_log_debug("Failed to unlock [The Thinknerd Warehouse]");
	return false;
}

boolean LX_melvignShirt()
{
	//Do the quest [The Shirt Off His Lack of Back] to get the skill [Torso Awaregness] from melvign the gnome.	
	
	if(hasTorso())
	{
		return false;
	}
	if(get_property("questM22Shirt") == "finished")
	{
		//is it actually possible to finish the quest and not have torso awareness? if not then this can be delted.
		return false;
	}
	if(internalQuestStatus("questM22Shirt") < 0)	//if quest has not started
	{
		if(!LX_unlockThinknerdWarehouse(false))		//if failed to start the quest without spending adv or wish
		{
			return false;
		}
	}
	
	if(item_amount($item[Professor What Garment]) == 0)
	{
		return autoAdv($location[The Thinknerd Warehouse]);
	}
	string temp = visit_url("place.php?whichplace=mountains&action=mts_melvin", false);
	return true;
}

boolean LX_steelOrgan_condition_slow()
{
	return !get_property("auto_slowSteelOrgan").to_boolean() && get_property("auto_getSteelOrgan").to_boolean();
}

boolean LX_steelOrgan()
{
	if(!get_property("auto_getSteelOrgan").to_boolean())
	{
		return false;
	}
	if($classes[Ed the Undying, Gelatinous Noob, Vampyre] contains my_class())
	{
		auto_log_info(my_class() + " can not use a Steel Organ, turning off setting.", "blue");
		set_property("auto_getSteelOrgan", false);
		return false;
	}
	if(in_nuclear() || in_lta())
	{
		auto_log_info("You could get a Steel Organ for aftercore, but why? We won't help with this deviant and perverse behavior. Turning off setting.", "blue");
		set_property("auto_getSteelOrgan", false);
		return false;
	}

	if(have_skill($skill[Liver of Steel]) || have_skill($skill[Stomach of Steel]) || have_skill($skill[Spleen of Steel]))
	{
		auto_log_info("We have a steel organ, turning off the setting." ,"blue");
		set_property("auto_getSteelOrgan", false);
		return false;
	}

	if (internalQuestStatus("questL06Friar") < 3)
	{
		// can't get to Pandaemonium if we haven't cleansed the taint!
		return L6_friarsGetParts();
	}

	if(get_property("questM10Azazel") != "finished")
	{
		auto_log_info("I am hungry for some steel.", "blue");
	}

	if(have_effect($effect[items.enh]) == 0)
	{
		auto_sourceTerminalEnhance("items");
	}

	if(get_property("questM10Azazel") == "unstarted")
	{
		string temp = visit_url("pandamonium.php");
		temp = visit_url("pandamonium.php?action=moan");
		temp = visit_url("pandamonium.php?action=infe");
		temp = visit_url("pandamonium.php?action=sven");
		temp = visit_url("pandamonium.php?action=sven");
		temp = visit_url("pandamonium.php?action=beli");
		temp = visit_url("pandamonium.php?action=mourn");
	}
	if(get_property("questM10Azazel") == "started")
	{
		if((!possessEquipment($item[Observational Glasses]) || item_amount($item[Imp Air]) < 5) && item_amount($item[Azazel\'s Tutu]) == 0)
		{
			autoAdv(1, $location[The Laugh Floor]);
		}
		else if(((item_amount($item[Azazel\'s Unicorn]) == 0) || (item_amount($item[Bus Pass]) < 5)) && (item_amount($item[Azazel\'s Tutu]) == 0))
		{
			int jim = 0;
			int flargwurm = 0;
			int bognort = 0;
			int stinkface = 0;
			int need = 4;
			if(item_amount($item[Comfy Pillow]) > 0)
			{
				jim = to_int($item[Comfy Pillow]);
				need -= 1;
			}
			if(item_amount($item[Booze-Soaked Cherry]) > 0)
			{
				flargwurm = to_int($item[Booze-Soaked Cherry]);
				need -= 1;
			}
			if(item_amount($item[Giant Marshmallow]) > 0)
			{
				bognort = to_int($item[Giant Marshmallow]);
				need -= 1;
			}
			if(item_amount($item[Beer-Scented Teddy Bear]) > 0)
			{
				stinkface = to_int($item[Beer-Scented Teddy Bear]);
				need -= 1;
			}
			if(need > 0)
			{
				int cake = item_amount($item[Sponge Cake]);
				if((jim == 0) && (cake > 0))
				{
					jim = to_int($item[Sponge Cake]);
					need -= 1;
					cake -= 1;
				}
				if((flargwurm == 0) && (cake > 0))
				{
					flargwurm = to_int($item[Sponge Cake]);
					need -= 1;
					cake -= 1;
				}
				int paper = item_amount($item[Gin-Soaked Blotter Paper]);
				if((bognort == 0) && (paper > 0))
				{
					bognort = to_int($item[Gin-Soaked Blotter Paper]);
					need -= 1;
					paper -= 1;
				}
				if((stinkface == 0) && (paper > 0))
				{
					stinkface = to_int($item[Gin-Soaked Blotter Paper]);
					need -= 1;
					paper -= 1;
				}
			}


			if((need == 0) && (item_amount($item[Azazel\'s Unicorn]) == 0))
			{
				string temp = visit_url("pandamonium.php?action=sven");
				visit_url("pandamonium.php?action=sven&bandmember=Jim&togive=" + jim + "&preaction=try");
				temp = visit_url("pandamonium.php?action=sven");
				visit_url("pandamonium.php?action=sven&bandmember=Flargwurm&togive=" + flargwurm + "&preaction=try");
				temp = visit_url("pandamonium.php?action=sven");
				visit_url("pandamonium.php?action=sven&bandmember=Bognort&togive=" + bognort + "&preaction=try");
				temp = visit_url("pandamonium.php?action=sven");
				visit_url("pandamonium.php?action=sven&bandmember=Stinkface&togive=" + stinkface + "&preaction=try");
				return true;
			}

			autoAdv(1, $location[Infernal Rackets Backstage]);
		}
		else if((item_amount($item[Azazel\'s Lollipop]) == 0) && (item_amount($item[Azazel\'s Tutu]) == 0))
		{
			foreach it in $items[Hilarious Comedy Prop, Victor\, the Insult Comic Hellhound Puppet, Observational Glasses]
			{
				if(possessEquipment(it) && auto_can_equip(it))
				{
					autoForceEquip(it);
					visit_url("pandamonium.php?action=mourn&whichitem=" + to_int(it) + "&pwd=");
				}
				else if(available_amount(it) == 0)
				{
					abort("Somehow we do not have " + it + " at this point...");
				}
			}
		}
		else if((item_amount($item[Azazel\'s Tutu]) == 0) && (item_amount($item[Bus Pass]) >= 5) && (item_amount($item[Imp Air]) >= 5))
		{
			string temp = visit_url("pandamonium.php?action=moan");
		}
		else if((item_amount($item[Azazel\'s Tutu]) > 0) && (item_amount($item[Azazel\'s Lollipop]) > 0) && (item_amount($item[Azazel\'s Unicorn]) > 0))
		{
			string temp = visit_url("pandamonium.php?action=temp");
		}
		else
		{
			auto_log_warning("Stuck in the Steel Organ quest and can't continue, moving on.", "red");
			set_property("auto_getSteelOrgan", false);
		}
		return true;
	}
	else if(get_property("questM10Azazel") == "finished")
	{
		auto_log_info("Considering Steel Organ consumption.....", "blue");
		if((item_amount($item[Steel Lasagna]) > 0) && (fullness_left() >= $item[Steel Lasagna].fullness))
		{
			eatsilent(1, $item[Steel Lasagna]);
		}
		boolean wontBeOverdrunk = inebriety_left() >= $item[Steel Margarita].inebriety - 5;
		boolean notOverdrunk = my_inebriety() <= inebriety_limit();
		boolean notSavingForBilliards = hasSpookyravenLibraryKey() || get_property("lastSecondFloorUnlock").to_int() == my_ascensions() || my_inebriety() + $item[Steel Margarita].inebriety <= 10 || my_inebriety() >= 12;
		boolean notWaitingKOLHS = !in_kolhs() || my_inebriety() > 9;
		if(item_amount($item[Steel Margarita]) > 0 && wontBeOverdrunk && notOverdrunk && notSavingForBilliards && notWaitingKOLHS)
		{
			autoDrink(1, $item[Steel Margarita]);
		}
		if((item_amount($item[Steel-Scented Air Freshener]) > 0) && (spleen_left() >= 5))
		{
			autoChew(1, $item[Steel-Scented Air Freshener]);
		}
	}
	return false;
}

boolean LX_guildUnlock()
{
	if(!isGuildClass() || guild_store_available())
	{
		return false;
	}
	if(in_nuclear() || in_pokefam() || in_robot())
	{
		return false;
	}
	if(!(in_picky() || in_community() || in_lowkeysummer()) && get_property('auto_skipUnlockGuild').to_boolean())
	{
		return false;
	}
	if(in_ggoo() && $classes[Seal Clubber, Turtle Tamer] contains my_class())
	{
		return false;	//muscle classes cannot unlock guild in grey goo
	}
	auto_log_info("Let's unlock the guild.", "green");

	string pref;
	location loc = $location[None];
	item goal = $item[none];
	switch(my_primestat())
	{
		case $stat[Muscle]:
			set_property("choiceAdventure111", "3");//Malice in Chains -> Plot a cunning escape
			set_property("choiceAdventure113", "2");//Knob Goblin BBQ -> Kick the chef
			set_property("choiceAdventure118", "2");//When Rocks Attack -> "Sorry, gotta run."
			set_property("choiceAdventure120", "4");//Ennui is Wasted on the Young -> "Since you\'re bored, you\'re boring. I\'m outta here."
			pref = "questG09Muscle";
			loc = $location[The Outskirts of Cobb\'s Knob];
			goal = $item[11-Inch Knob Sausage];
			break;
		case $stat[Mysticality]:
			set_property("choiceAdventure115", "1");//Oh No, Hobo -> Give him a beating
			set_property("choiceAdventure116", "4");//The Singing Tree (Rustling) -> "No singing, thanks."
			set_property("choiceAdventure117", "1");//Trespasser -> Tackle him
			set_property("choiceAdventure114", "2");//The Baker\'s Dilemma -> "Sorry, I\'m busy right now."
			pref = "questG07Myst";
			loc = $location[The Haunted Pantry];
			goal = $item[Exorcised Sandwich];
			break;
		case $stat[Moxie]:
			goal = equipped_item($slot[pants]);
			set_property("choiceAdventure108", "4");//Aww, Craps -> Walk Away
			set_property("choiceAdventure109", "1");//Dumpster Diving -> Punch the hobo
			set_property("choiceAdventure110", "4");//The Entertainer -> Introduce them to avant-garde
			set_property("choiceAdventure112", "2");//Please, Hammer -> "Sorry, no time."
			set_property("choiceAdventure121", "2");//Under the Knife -> Umm, no thanks. Seriously.
			pref = "questG08Moxie";
			if(internalQuestStatus(pref) < 1)
			{
				loc = $location[The Sleazy Back Alley];
			}
			break;
	}
	if(loc != $location[none])
	{
		if(get_property(pref) != "started")
		{
			string temp = visit_url("guild.php?place=challenge");
		}
		if(internalQuestStatus(pref) < 0)
		{
			auto_log_warning("Visiting the guild failed to set guild quest.", "red");
			return false;
		}

		if (canBurnDelay(loc)) {
			// All guild unlock choice adventures have a delay of 5 adventures.
			return false;
		}

		autoAdv(1, loc);
		if (internalQuestStatus(pref) == 1)
		{
			visit_url("guild.php?place=challenge");
		}
		return true;
	}
	return false;
}

boolean startArmorySubQuest()
{
	if(in_koe() || in_nuclear())
	{
		//will unlock the zone but does not actually start the quest. also currently not tracked by mafia so we will think the zone is unavailable.
		if(item_amount($item[Hypnotic Breadcrumbs]) > 0)
		{
			return use(1, $item[Hypnotic Breadcrumbs]);
		}
		return false;
	}

	if(internalQuestStatus("questM25Armorer") == -1)
	{
		visit_url("shop.php?whichshop=armory");
		visit_url("shop.php?whichshop=armory&action=talk");
		visit_url("choice.php?pwd=&whichchoice=1065&option=1");
		if(internalQuestStatus("questM25Armorer") > -1)
		{
			return true;
		}
	}
	return false;
}

boolean finishArmorySideQuest()
{
	if(internalQuestStatus("questM25Armorer") != 4)		//step4 == have [no-handed pie]. need to turn it in.
	{
		return false;
	}
	auto_log_info("finishing quest [Lending a Hand (and a Foot)]");
	visit_url("shop.php?whichshop=armory");
	run_choice(2);		//give no-handed pie to finish the quest
	return internalQuestStatus("questM25Armorer") > 4;
}

boolean LX_armorySideQuest()
{
	//do the quest [Lending a Hand (and a Foot)] and unlock [madeline's baking supply] store
	//step2 = need to kill the cake lord
	//step3 = killed the cake lord
	//step4 = clicked through the mandatory noncombat pages after the cake lord was killed
	startArmorySubQuest();							//always start the quest to unlock the zone. costs no adv
	if(finishArmorySideQuest()) return true;		//always finish the quest if possible. unlocks a shop.

	if(!get_property("auto_doArmory").to_boolean())		//post setting indicating we should do this quest this ascension
	{
		return false;
	}	
	if(internalQuestStatus("questM25Armorer") > -1 && internalQuestStatus("questM25Armorer") < 4)
	{
		return autoAdv($location[Madness Bakery]);
	}
	return false;
}

boolean startMeatsmithSubQuest()
{
	if(in_koe())
	{
		return false;	//quest cannot be started and zone cannot be unlocked.
	}
	if(internalQuestStatus("questM23Meatsmith") != -1)
	{
		return false;	//quest already started
	}
	if(in_nuclear())
	{
		if(item_amount($item[Bone With a Price Tag On It]) > 0)
		{
			//will unlock the zone but does not actually start the quest. also currently not tracked by mafia so we will think the zone is unavailable.
			return use(1, $item[Bone With a Price Tag On It]);
		}
		return false;
	}

	visit_url("shop.php?whichshop=meatsmith");
	visit_url("shop.php?whichshop=meatsmith&action=talk");
	run_choice(1);
	return internalQuestStatus("questM23Meatsmith") > -1;
}

boolean finishMeatsmithSubQuest()
{
	if(internalQuestStatus("questM23Meatsmith") != 1)
	{
		return false;
	}
	if(item_amount($item[Check to the Meatsmith]) > 0)
	{
		visit_url("shop.php?whichshop=meatsmith");
		run_choice(2);
		return true;
	}
	return false;
}

boolean LX_meatsmithSubQuest()
{
	//do meatsmith optional subquest.
	if(startMeatsmithSubQuest()) return true;		//always start the quest if available
	if(finishMeatsmithSubQuest()) return true;		//always turn the quest in if possible
	
	if(internalQuestStatus("questM23Meatsmith") != 0)
	{
		return false;	
	}
	if(!get_property("auto_doMeatsmith").to_boolean())
	{
		return false;		//by default we do not want to do this quest.
	}
	
	return autoAdv($location[The Skeleton Store]);
}

void considerGalaktikSubQuest()
{
	//by default we do not do doc galaktik quest. user can manually enable it via gui for this current ascension.
	//this function considers wheather we should automatically enable it for this ascension.
	
	if(!get_property("auto_considerGalaktik").to_boolean())
	{
		return;		//user must opt in for automatic enabling of galaktik quest when needed
	}
	if(get_property("auto_doGalaktik").to_boolean())
	{
		return;		//already enabled for this ascension
	}
	if(internalQuestStatus("questM24Doc") != 0)		//quest is unstarted or already finished
	{
		return;		//we always try to start this quest. if we could not for some reason then there is no point in trying to do it
	}
	if(my_turncount() < 30)
	{
		return;		//give it some turns to see how well we handle things before deciding if galaktik is needed
	}
	if(in_koe())
	{
		return;		//galaktik is unavailable in kingdom of exploathing
	}
	if(in_darkGyffte() || in_plumber())
	{
		return;		//these classes cannot use galaktik restorers.
	}
	if(my_class() == $class[Accordion Thief] && my_level() > 10)
	{
		return;		//AT get guild store access and can use [magical mystery juice] instead
	}
	if($classes[Pastamancer, Sauceror] contains my_class())
	{
		return;		//Sauceror restores via curse of weaksauce. Pastamancer can use MMJ to restore.
	}
	
	if(my_meat() < 100)
	{
		auto_log_info("We are so poor we cannot effectively restore anymore. Enabling Galaktik quest for this ascension", "red");
		set_property("auto_doGalaktik", true);
		return;
	}
	if(my_meat() < meatReserve() + 100)
	{
		auto_log_info("Our meat reserves are far too low, we still need to save up some for quests. Enabling Galaktik quest for this ascension", "red");
		set_property("auto_doGalaktik", true);
		return;
	}
}

boolean startGalaktikSubQuest()
{
	if(internalQuestStatus("questM24Doc") != -1)
	{
		return false;	//quest already started
	}
	if(in_nuclear() || in_koe())
	{
		//will unlock the zone but does not actually start the quest. also currently not tracked by mafia so we will think the zone is unavailable.
		if(item_amount($item[Map to a Hidden Booze Cache]) > 0)
		{
			return use(1, $item[Map to a Hidden Booze Cache]);
		}
		return false;
	}

	visit_url("shop.php?whichshop=doc");
	visit_url("shop.php?whichshop=doc&action=talk");
	run_choice(1);
	return internalQuestStatus("questM24Doc") > -1;
}

boolean finishGalaktikSubQuest()
{
	if (item_amount($item[fraudwort]) >= 3 && item_amount($item[shysterweed]) >= 3 && item_amount($item[swindleblossom]) >= 3) {
		string temp = visit_url("shop.php?whichshop=doc");
		if (temp.contains_text("What did you need, again?")) {
			visit_url("shop.php?whichshop=doc&action=talk");
		}
		run_choice(2);
		if (internalQuestStatus("questM24Doc") > 1) {
			return true;
		}
	}
	return false;
}

boolean LX_galaktikSubQuest()
{
	//do doc galaktik optional subquest.
	if(startGalaktikSubQuest()) return true;	//always start the quest if available
	if(finishGalaktikSubQuest()) return true;	//always turn the quest in if possible
	considerGalaktikSubQuest();					//if allowed will automatically enable the quest in some cases
	
	if(internalQuestStatus("questM24Doc") != 0)
	{
		//questM24Doc is used by mafia to track progress. step1 means you have the flowers and need to turn them in. 0 means started but incomplete.
		return false;	
	}
	if(!get_property("auto_doGalaktik").to_boolean())
	{
		return false;		//by default we do not want to do this quest.
	}
	
	return autoAdv($location[The Overgrown Lot]);
}

boolean LX_pirateOutfit() {
	if (get_property("lastIslandUnlock").to_int() < my_ascensions()) {
		return LX_islandAccess();
	}
	if (possessEquipment($item[peg key]) && !in_hardcore()) {
		// if we have the key, just pull any outfit parts we are still missing
		foreach _, it in outfit_pieces("Swashbuckling Getup") {
			pullXWhenHaveY(it, 1, 0);
		}
	}
	if (possessOutfit("Swashbuckling Getup")) {
		if (possessOutfit("Swashbuckling Getup", true) && item_amount($item[The Big Book Of Pirate Insults]) == 0 && my_meat() > npc_price($item[The Big Book Of Pirate Insults])) {
			buyUpTo(1, $item[The Big Book Of Pirate Insults]);
		}
		return false;
	}
	auto_log_info("Searching for a pirate outfit.", "blue");
	return autoAdv($location[The Obligatory Pirate\'s Cove]);
}

void piratesCoveChoiceHandler(int choice) {
	if (choice == 22) { // The Arrrbitrator
		if (possessEquipment($item[eyepatch])) {
			if (possessEquipment($item[swashbuckling pants])) {
				run_choice(3); // get 100 Meat.
			} else {
				run_choice(2); // get swashbuckling pants
			}
		} else {
			run_choice(1); // get eyepatch
		}
	} else if (choice == 23) { // Barrie Me at Sea
		if (possessEquipment($item[stuffed shoulder parrot])) {
			if (possessEquipment($item[swashbuckling pants])) {
				run_choice(3); // get 100 Meat.
			} else {
				run_choice(2); // get swashbuckling pants
			}
		} else {
			run_choice(1); // get stuffed shoulder parrot
		}
	} else if (choice == 24) { // Amatearrr Night
		if (possessEquipment($item[stuffed shoulder parrot])) {
			if (possessEquipment($item[eyepatch])) {
				run_choice(2); // get 100 Meat.
			} else {
				run_choice(3); // get eyepatch
			}
		} else {
			run_choice(1); // get stuffed shoulder parrot
		}
	} else {
		abort("unhandled choice in piratesCoveChoiceHandler");
	}
}

string beerPong(string page)
{
	record r {
		string insult;
		string retort;
	};

	r [int] insults;
	insults[1].insult="Arrr, the power of me serve'll flay the skin from yer bones!";
	insults[1].retort="Obviously neither your tongue nor your wit is sharp enough for the job.";
	insults[2].insult="Do ye hear that, ye craven blackguard?  It be the sound of yer doom!";
	insults[2].retort="It can't be any worse than the smell of your breath!";
	insults[3].insult="Suck on <i>this</i>, ye miserable, pestilent wretch!";
	insults[3].retort="That reminds me, tell your wife and sister I had a lovely time last night.";
	insults[4].insult="The streets will run red with yer blood when I'm through with ye!";
	insults[4].retort="I'd've thought yellow would be more your color.";
	insults[5].insult="Yer face is as foul as that of a drowned goat!";
	insults[5].retort="I'm not really comfortable being compared to your girlfriend that way.";
	insults[6].insult="When I'm through with ye, ye'll be crying like a little girl!";
	insults[6].retort="It's an honor to learn from such an expert in the field.";
	insults[7].insult="In all my years I've not seen a more loathsome worm than yerself!";
	insults[7].retort="Amazing!  How do you manage to shave without using a mirror?";
	insults[8].insult="Not a single man has faced me and lived to tell the tale!";
	insults[8].retort="It only seems that way because you haven't learned to count to one.";

	while(!page.contains_text("victory laps"))
	{
		string old_page = page;

		if(!page.contains_text("Insult Beer Pong"))
		{
			abort("You don't seem to be playing Insult Beer Pong.");
		}

		if(page.contains_text("Phooey"))
		{
			auto_log_info("Looks like something went wrong and you lost.", "lime");
			return page;
		}

		foreach i in insults
		{
			if(page.contains_text(insults[i].insult))
			{
				if(page.contains_text(insults[i].retort))
				{
					auto_log_info("Found appropriate retort for insult.", "lime");
					auto_log_debug("Insult: " + insults[i].insult, "lime");
					auto_log_debug("Retort: " + insults[i].retort, "lime");
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;
				}
				else
				{
					auto_log_info("Looks like you needed a retort you haven't learned.", "red");
					auto_log_debug("Insult: " + insults[i].insult, "lime");
					auto_log_debug("Retort: " + insults[i].retort, "lime");

					// Give a bad retort
					page = visit_url("beerpong.php?value=Retort!&response=9");
					return page;
				}
			}
		}

		if(page == old_page)
		{
			abort("String not found. There may be an error with one of the insult or retort strings.");
		}
	}

	auto_log_info("You won a thrilling game of Insult Beer Pong!", "lime");
	return page;
}

string tryBeerPong()
{
	string page = visit_url("adventure.php?snarfblat=157"); //http://127.0.0.1:60081/adventure.php?snarfblat=157
	if(contains_text(page, "Arrr You Man Enough?"))
	{
		page = beerPong(visit_url("choice.php?pwd&whichchoice=187&option=1"));
	}
	return page;
}

int numPirateInsults() {
	int retval = 0;
	int i = 1;
	while (i <= 8) {
		if (get_property("lastPirateInsult" + i) == "true") {
			retval = retval + 1;
		}
		i = i + 1;
	}
	return retval;
}

boolean LX_joinPirateCrew() {
	if (get_property("lastIslandUnlock").to_int() < my_ascensions()) {
		return LX_islandAccess();
	}
	if (internalQuestStatus("questM12Pirate") > 4) {
		return false;
	}
	if (!possessOutfit("Swashbuckling Getup", true)) {
		auto_log_info("Can not equip, or do not have the Swashbuckling Getup. Delaying.", "red");
		return false;
	}
	if (item_amount($item[The Big Book Of Pirate Insults]) == 0 && my_meat() > npc_price($item[The Big Book Of Pirate Insults])) {
		buyUpTo(1, $item[The Big Book Of Pirate Insults]);
	}
	if (internalQuestStatus("questM12Pirate") == -1 || internalQuestStatus("questM12Pirate") == 1 || internalQuestStatus("questM12Pirate") == 3) {
		auto_log_info("Findin' the Cap'n", "blue");
		autoOutfit("Swashbuckling Getup");
		autoAdv($location[Barrrney\'s Barrr]); // this returns false on the Cap'n Caronch adventures for some reason.
		return true;
	} else if (internalQuestStatus("questM12Pirate") == 0) {
		auto_log_info("Nasty Booty time!", "red");
		if (autoAdvBypass("inv_use.php?pwd=&which=3&whichitem=2950", $location[Noob Cave])) {
			return true;
		}
	} else if (internalQuestStatus("questM12Pirate") == 2) {
		auto_log_info("Attempting to infiltrate the frat house", "blue");
		boolean infiltrationReady = false;
		if (possessOutfit("Frat Boy Ensemble", true))  {
			auto_log_info("We have the Frat Boy Ensemble, begin infiltration!", "blue");
			outfit("Frat Boy Ensemble");
			infiltrationReady = true;
		} else if (possessEquipment($item[mullet wig]) && item_amount($item[briefcase]) > 0) {
			auto_log_info("We have a mullet wig and a briefcase, begin infiltration!", "blue");
			autoForceEquip($item[mullet wig]);
			infiltrationReady = true;
		} else if (possessEquipment($item[frilly skirt]) && item_amount($item[hot wing]) > 2) {
			auto_log_info("We have hot wings and a frilly skirt, begin infiltration!", "blue");
			autoForceEquip($item[frilly skirt]);
			infiltrationReady = true;
		}

		if (!infiltrationReady) {
			if (item_amount($item[hot wing]) > 2) {
				if (knoll_available() && my_meat() > npc_price($item[frilly skirt])) {
					auto_log_info("We have hot wings but no frilly skirt. Lets go shopping!", "blue");
					buyUpTo(1, $item[frilly skirt]);
					autoForceEquip($item[frilly skirt]);
					infiltrationReady = true;
				} else {
					auto_log_info("We have hot wings but no frilly skirt. Lets go to the gym!", "blue");
					if (internalQuestStatus("questM01Untinker") == -1) {
						visit_url("place.php?whichplace=forestvillage&preaction=screwquest&action=fv_untinker_quest");
					}
					if (autoAdv($location[The Degrassi Knoll Gym])) {
						return true;
					}
				}
			}
			// TODO: add handling for the other methods here? Do we care about anything other than Catburgling?
		}

		if (infiltrationReady) {
			if (use(1, $item[Orcish Frat House blueprints])) {
				return true;
			}
		}
	} else if (internalQuestStatus("questM12Pirate") == 4) {
		if (numPirateInsults() >= 6) {
			// this is held together with duct tape and hopes and dreams.
			// it can and will fail but it will have to do for now.
			auto_log_info("Beer Pong time.", "blue");
			outfit("Swashbuckling Getup");	//do not use autoOutfit since we use visit_url in tryBeerPong which skips maximizer
			backupSetting("choiceAdventure187", "0");
			tryBeerPong();
			return true;
		} else {
			auto_log_info("Insult gathering party.", "blue");
			addToMaximize("-outfit Swashbuckling Getup");
			// If we're wearing the pirate outfit already, autoAdv will fail to adventure
			// in the cove since the zone isn't available unless we remove it (which wouldn't happen until auto_pre_adv runs)
			autoStripOutfit("Swashbuckling Getup");
			if (autoAdv($location[The Obligatory Pirate\'s Cove])) {
				return true;
			}
		}
	}
	return false;
}

void barrrneysBarrrChoiceHandler(int choice) {
	auto_log_info("barrrneysBarrrChoiceHandler Running choice " + choice, "blue");
	if (choice == 184) { // That Explains All The Eyepatches
		if (my_primestat() == $stat[mysticality]) {
			run_choice(3); // get shot of rotgut
		} else {
			run_choice(1); // combat with tipsy pirate
		}
	} else if (choice == 185) { // Yes, You're a Rock Starrr
		run_choice(3); // combat with tetchy pirate at 0 drunkenness or stats otherwise
	} else if (choice == 186) { // A Test of Testarrrsterone
		if (my_primestat() == $stat[moxie]) {
			run_choice(3); // moxie stats
		} else {
			run_choice(1); // stats
		}
	} else {
		abort("unhandled choice in barrrneysBarrrChoiceHandler");
	}
}

boolean LX_fledglingPirateIsYou() {
	if (internalQuestStatus("questM12Pirate") != 5) {
		return false;
	}

	if (possessEquipment($item[pirate fledges])) {
		return false;
	}

	auto_log_info("F'c'le t'me!", "blue");
	autoOutfit("Swashbuckling Getup");
	return autoAdv($location[The F\'c\'le]);
}

void fcleChoiceHandler(int choice) {
	if (choice == 191) {
		if(item_amount($item[Valuable Trinket]) > 0) {
			run_choice(2);
		} else {
			switch(my_primestat()) {
				case $stat[Muscle]:
					run_choice(3);
					break;
				case $stat[Mysticality]:
					run_choice(4);
					break;
				case $stat[Moxie]:
					run_choice(1);
					break;
			}
		}
	} else {
		abort("unhandled choice in fcleChoiceHandler");
	}
}

boolean LX_unlockBelowdecks() {
	if (internalQuestStatus("questM12Pirate") != 6 || internalQuestStatus("questL11MacGuffin") < 2) {
		return false;
	}

	if (!possessEquipment($item[pirate fledges])) {
		return false;
	}

	auto_log_info("Swordfish? Every password was swordfish!", "blue");
	autoEquip($item[pirate fledges]);
	return autoAdv($location[The Poop Deck]);
}

boolean LX_pirateQuest() {
	if (LX_pirateOutfit() || LX_joinPirateCrew() || LX_fledglingPirateIsYou() || LX_unlockBelowdecks()) {
		return true;
	}
	return false;
}

item[class] epicWeapons;
epicWeapons[$class[Seal Clubber]] = $item[Hammer of Smiting];
epicWeapons[$class[Turtle Tamer]] = $item[Chelonian Morningstar];
epicWeapons[$class[Pastamancer]] = $item[Greek Pasta Spoon of Peril];
epicWeapons[$class[Sauceror]] = $item[17-alarm Saucepan];
epicWeapons[$class[Disco Bandit]] = $item[Shagadelic Disco Banjo];
epicWeapons[$class[Accordion Thief]] = $item[Squeezebox of the Ages];
// usage: item epicWeapon = epicWeapons[my_class()];

item[class] starterWeapons;
starterWeapons[$class[Seal Clubber]] = $item[seal-clubbing club];
starterWeapons[$class[Turtle Tamer]] = $item[turtle totem];
starterWeapons[$class[Pastamancer]] = $item[pasta spoon];
starterWeapons[$class[Sauceror]] = $item[saucepan];
starterWeapons[$class[Disco Bandit]] = $item[disco ball];
starterWeapons[$class[Accordion Thief]] = $item[stolen accordion];
// usage: item starterWeapon = starterWeapons[my_class()];

boolean LX_acquireEpicWeapon()
{
	if (internalQuestStatus("questG04Nemesis") > 4)
	{
		return false;	// already done with this part
	}
	if (!isGuildClass() || !guild_store_available())
	{
		return false;	// no guild access. can't start this quest
	}
	if (internalQuestStatus("questG04Nemesis") < 0)
	{
		visit_url("guild.php?place=scg");	// start quest
		visit_url("guild.php?place=scg"); // No really, start the quest.
		cli_execute("refresh quests");		// fixes buggy tracking. confirmed still in mafia r20143
		if (internalQuestStatus("questG04Nemesis") < 0)
		{
			abort("Failed to start Nemesis quest. Please start it manually then run me again");
		}
	}

	if (item_amount(epicWeapons[my_class()]) > 0)
	{
		return false;
	}

	if (internalQuestStatus("questG04Nemesis") == 4)
	{
		visit_url("guild.php?place=scg");
		return true;
	}

	if (shenShouldDelayZone($location[The Unquiet Garves]))
	{
		auto_log_debug("Delaying The Unquiet Garves in case of Shen.");
		return false;
	}

	if (item_amount(starterWeapons[my_class()]) == 0)
	{
		// make sure we have a starter weapon for the swap.
		acquireGumItem(starterWeapons[my_class()]);
	}

	addToMaximize("-equip " + starterWeapons[my_class()].to_string());

	return autoAdv($location[The Unquiet Garves]);
}

// TODO: Add the rest of the Nemesis quest with a flag to enable doing it in-run?
boolean LX_NemesisQuest()
{
	if (LX_guildUnlock() || LX_acquireEpicWeapon())
	{
		return true;
	}
	return false;
}

void houseUpgrade()
{
	//function for upgrading your dwelling.
	if(isActuallyEd() || in_darkGyffte() || in_nuclear())
	{
		return;		//paths where dwelling is locked
	}
	
	//if you have no dwelling get_dwelling() returns $item[big rock]
	if(item_amount($item[Newbiesport&trade; tent]) > 0 && auto_is_valid($item[Newbiesport&trade; tent]) && get_dwelling() == $item[big rock])
	{
		use(1, $item[Newbiesport&trade; tent]);
	}
	if((get_dwelling() == $item[big rock] || get_dwelling() == $item[Newbiesport&trade; tent]) &&
	item_amount($item[Frobozz Real-Estate Company Instant House (TM)]) > 0 &&
	auto_is_valid($item[Frobozz Real-Estate Company Instant House (TM)]))
	{
		use(1, $item[Frobozz Real-Estate Company Instant House (TM)]);
	}
}
