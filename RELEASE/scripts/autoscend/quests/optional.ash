script "optional.ash"

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

boolean LX_steelOrgan()
{
	if(!get_property("auto_getSteelOrgan").to_boolean())
	{
		return false;
	}
	if (get_property("questL06Friar") != "finished")
	{
		return false;
	}
	if(my_adventures() == 0)
	{
		return false;
	}
	if($classes[Ed, Gelatinous Noob, Vampyre] contains my_class())
	{
		auto_log_info(my_class() + " can not use a Steel Organ, turning off setting.", "blue");
		set_property("auto_getSteelOrgan", false);
		return false;
	}
	if((auto_my_path() == "Nuclear Autumn") || (auto_my_path() == "License to Adventure"))
	{
		auto_log_info("You could get a Steel Organ for aftercore, but why? We won't help with this deviant and perverse behavior. Turning off setting.", "blue");
		set_property("auto_getSteelOrgan", false);
		return false;
	}
	if(my_path() == "Avatar of West of Loathing")
	{
		if((get_property("awolPointsCowpuncher").to_int() < 7) || (get_property("awolPointsBeanslinger").to_int() < 1) || (get_property("awolPointsSnakeoiler").to_int() < 5))
		{
			set_property("auto_getSteelOrgan", false);
			return false;
		}
	}

	if(have_skill($skill[Liver of Steel]) || have_skill($skill[Stomach of Steel]) || have_skill($skill[Spleen of Steel]))
	{
		auto_log_info("We have a steel organ, turning off the setting." ,"blue");
		set_property("auto_getSteelOrgan", false);
		return false;
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
			if(!possessEquipment($item[Observational Glasses]))
			{
				uneffect($effect[The Sonata of Sneakiness]);
				buffMaintain($effect[Hippy Stench], 0, 1, 1);
				buffMaintain($effect[Carlweather\'s Cantata of Confrontation], 10, 1, 1);
				buffMaintain($effect[Musk of the Moose], 10, 1, 1);
				# Should we check for -NC stuff and deal with it?
				# We need a Combat Modifier controller
			}
			if(item_amount($item[Imp Air]) >= 5)
			{
				handleFamiliar($familiar[Jumpsuited Hound Dog]);
			}
			else
			{
				handleFamiliar("item");
			}
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

			if(item_amount($item[Azazel\'s Unicorn]) == 0)
			{
				uneffect($effect[Carlweather\'s Cantata of Confrontation]);
				buffMaintain($effect[The Sonata of Sneakiness], 20, 1, 1);
				buffMaintain($effect[Smooth Movements], 10, 1, 1);
			}
			else
			{
				uneffect($effect[The Sonata of Sneakiness]);
			}
			handleFamiliar("item");
			autoAdv(1, $location[Infernal Rackets Backstage]);
		}
		else if((item_amount($item[Azazel\'s Lollipop]) == 0) && (item_amount($item[Azazel\'s Tutu]) == 0))
		{
			foreach it in $items[Hilarious Comedy Prop, Victor\, the Insult Comic Hellhound Puppet, Observational Glasses]
			{
				if(possessEquipment(it))
				{
					autoForceEquip(it);
					string temp = visit_url("pandamonium.php?action=mourn&whichitem=" + to_int(it) + "&pwd=");
				}
				else
				{
					if(available_amount(it) == 0)
					{
						abort("Somehow we do not have " + it + " at this point...");
					}
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
		boolean notSavingForBilliards = hasSpookyravenLibraryKey() || get_property("lastSecondFloorUnlock").to_int() == my_ascensions();
		if((item_amount($item[Steel Margarita]) > 0) && wontBeOverdrunk && notOverdrunk && (notSavingForBilliards || my_inebriety() + $item[Steel Margarita].inebriety <= 10 || my_inebriety() >= 12))
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
	if((auto_my_path() == "Nuclear Autumn") || (auto_my_path() == "Pocket Familiars"))
	{
		return false;
	}
	auto_log_info("Let's unlock the guild.", "green");

	string pref;
	location loc = $location[None];
	item goal = $item[none];
	switch(my_primestat())
	{
		case $stat[Muscle] :
			set_property("choiceAdventure111", "3");//Malice in Chains -> Plot a cunning escape
			set_property("choiceAdventure113", "2");//Knob Goblin BBQ -> Kick the chef
			set_property("choiceAdventure118", "2");//When Rocks Attack -> "Sorry, gotta run."
			set_property("choiceAdventure120", "4");//Ennui is Wasted on the Young -> "Since you\'re bored, you\'re boring. I\'m outta here."
			set_property("choiceAdventure543", "1");//Up In Their Grill -> Grab the sausage, so to speak. I mean... literally.
			pref = "questG09Muscle";
			loc = $location[The Outskirts of Cobb\'s Knob];
			goal = $item[11-Inch Knob Sausage];
			break;
		case $stat[Mysticality]:
			set_property("choiceAdventure115", "1");//Oh No, Hobo -> Give him a beating
			set_property("choiceAdventure116", "4");//The Singing Tree (Rustling) -> "No singing, thanks."
			set_property("choiceAdventure117", "1");//Trespasser -> Tackle him
			set_property("choiceAdventure114", "2");//The Baker\'s Dilemma -> "Sorry, I\'m busy right now."
			set_property("choiceAdventure544", "1");//A Sandwich Appears! -> sudo exorcise me a sandwich
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
			set_property("choiceAdventure542", "1");//Now\'s Your Pants! I Mean... Your Chance! -> Yoink
			pref = "questG08Moxie";
			if(goal != $item[none])
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

		autoAdv(1, loc);
		if(item_amount(goal) > 0)
		{
			visit_url("guild.php?place=challenge");
		}
		return true;
	}
	return false;
}

boolean LX_pirateOutfit() {
	if (get_property("lastIslandUnlock").to_int() < my_ascensions()) {
		return LX_islandAccess();
	}
	if (possessOutfit("Swashbuckling Getup")) {
		if (item_amount($item[The Big Book Of Pirate Insults]) == 0 && my_meat() > npc_price($item[The Big Book Of Pirate Insults])) {
			buyUpTo(1, $item[The Big Book Of Pirate Insults]);
		}
		return false;
	}
	auto_log_info("Searching for a pirate outfit.", "blue");
	providePlusNonCombat(25, true);
	if (autoAdv($location[The Obligatory Pirate\'s Cove])) {
		return true;
	}
	return false;
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
		if (numPirateInsults() >= 6) {
			providePlusNonCombat(25, true);
		}
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
			autoOutfit("Frat Boy Ensemble");
			infiltrationReady = true;
		} else if (possessEquipment($item[mullet wig]) && item_amount($item[briefcase]) > 0) {
			autoForceEquip($item[mullet wig]);
			infiltrationReady = true;
		} else if (possessEquipment($item[frilly skirt]) && item_amount($item[hot wing]) > 2) {
			autoForceEquip($item[frilly skirt]);
			infiltrationReady = true;
		}

		if (!infiltrationReady) {
			if (item_amount($item[hot wing]) > 2) {
				if (knoll_available() && my_meat() > npc_price($item[frilly skirt])) {
					buyUpTo(1, $item[frilly skirt]);
					autoForceEquip($item[frilly skirt]);
					infiltrationReady = true;
				} else {
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
			autoOutfit("Swashbuckling Getup");
			backupSetting("choiceAdventure187", "0");
			tryBeerPong();
			return true;
		} else {
			auto_log_info("Insult gathering party.", "blue");
			addToMaximize("-outfit Swashbuckling Getup");
			providePlusCombat(25, true);
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
	providePlusCombat(25, true);
	if (autoAdv($location[The F\'c\'le])) {
		return true;
	}
	return false;
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
	providePlusNonCombat(25, true);
	if (autoAdv($location[The Poop Deck])) {
		return true;
	}
	return false;
}

boolean LX_pirateQuest() {
	if (LX_pirateOutfit() || LX_joinPirateCrew() || LX_fledglingPirateIsYou() || LX_unlockBelowdecks()) {
		return true;
	}
	return false;
}

item[class] legendaryEpicWeapons;
legendaryEpicWeapons[$class[Seal Clubber]] = $item[Hammer of Smiting];
legendaryEpicWeapons[$class[Turtle Tamer]] = $item[Chelonian Morningstar];
legendaryEpicWeapons[$class[Pastamancer]] = $item[Greek Pasta Spoon of Peril];
legendaryEpicWeapons[$class[Sauceror]] = $item[17-alarm Saucepan];
legendaryEpicWeapons[$class[Disco Bandit]] = $item[Shagadelic Disco Banjo];
legendaryEpicWeapons[$class[Accordion Thief]] = $item[Squeezebox of the Ages];
// usage: item legendaryEpicWeapon = legendaryEpicWeapons[my_class()];

item[class] starterWeapons;
starterWeapons[$class[Seal Clubber]] = $item[seal-clubbing club];
starterWeapons[$class[Turtle Tamer]] = $item[turtle totem];
starterWeapons[$class[Pastamancer]] = $item[pasta spoon];
starterWeapons[$class[Sauceror]] = $item[saucepan];
starterWeapons[$class[Disco Bandit]] = $item[disco ball];
starterWeapons[$class[Accordion Thief]] = $item[stolen accordion];
// usage: item starterWeapon = starterWeapons[my_class()];

boolean LX_acquireLegendaryEpicWeapon()
{
	if (internalQuestStatus("questG04Nemesis") > 4)
	{
		return false;	//already done with this part
	}
	if(!isGuildClass() || !guild_store_available())
	{
		return false;	//no guild access. can't start this quest
	}
	if(internalQuestStatus("questG04Nemesis") < 0)
	{
		visit_url("guild.php?place=scg");	//start quest
		cli_execute("refresh quests");		//fixes buggy tracking. confirmed still in mafia r20143
		if (internalQuestStatus("questG04Nemesis") < 0)
		{
			abort("Failed to start Nemesis quest. Please start it manually then run me again");
		}
	}

	if (item_amount(legendaryEpicWeapons[my_class()]) > 0) {
		return false;
	}

	if (internalQuestStatus("questG04Nemesis") == 4) {
		visit_url("guild.php?place=scg");
		return true;
	}

	if (shenShouldDelayZone($location[The Unquiet Garves])) {
		auto_log_debug("Delaying The Unquiet Garves in case of Shen.");
		return false;
	}

	addToMaximize("-equip " + starterWeapons[my_class()].to_string());

	if (autoAdv($location[The Unquiet Garves])) {
		return true;
	}
	return false;
}

// TODO: Add the rest of the Nemesis quest with a flag to enable doing it in-run?
boolean LX_NemesisQuest()
{
	if(LX_guildUnlock()) return true;
	if(LX_acquireLegendaryEpicWeapon()) return true;
	
	return false;
}