import <autoscend.ash>

void displayOnKingLiberation()
{
	if(have_display())
	{
		boolean[item] toDisplay = $items[
		Thwaitgold Bee Statuette,					//2011 Bees Hate You
		Thwaitgold Grasshopper Statuette,			//2011 Way of the Surprising Fist
		Thwaitgold Butterfly Statuette,				//2011 Trendy
		Thwaitgold Stag Beetle Statuette,			//2012 Avatar of Boris
		Thwaitgold Woollybear Statuette,			//2012 Bugbear Invasion
		Thwaitgold Maggot Statuette,				//2012 Zombie Slayer
		Thwaitgold Praying Mantis Statuette,		//2012 Class Act
		Thwaitgold Firefly Statuette,				//2013 Avatar of Jarlsberg
		Thwaitgold Goliath Beetle Statuette,		//2013 BIG!
		Thwaitgold Bookworm Statuette,				//2013 KOLHS
		Thwaitgold Ant Statuette,					//2013 Class Act II: A Class For Pigs
		Thwaitgold Dragonfly Statuette,				//2014 Avatar of Sneaky Pete
		Thwaitgold Wheel Bug Statuette,				//2014 Slow and Steady
		Thwaitgold Spider Statuette,				//2014 Heavy Rains
		Thwaitgold Nit Statuette,					//2014 Picky
		Thwaitgold Scarab Beetle Statuette,			//2015 Actually Ed the Undying
		Thwaitgold Caterpillar Statuette,			//2015 One Crazy Random Summer
		Thwaitgold Termite Statuette,				//2015 Community Service
		Thwaitgold Scorpion Statuette,				//2016 Avatar of West of Loathing
		Thwaitgold Moth Statuette,					//2016 The Source
		Thwaitgold Cockroach Statuette,				//2016 Nuclear Autumn
		Thwaitgold amoeba statuette,				//2017 Gelatinous Noob
		Thwaitgold bug statuette,					//2017 License to Adventure
		Thwaitgold time fly statuette,				//2017 Live. Ascend. Repeat.
		Thwaitgold metabug statuette,				//2018 Pocket Familiars
		Thwaitgold chigger statuette,				//2018 G-Lover
		Thwaitgold masked hunter statuette,			//2018 Disguises Delimit
		Thwaitgold mosquito statuette,				//2019 Dark Gyffte
		Thwaitgold nymph statuette,					//2019 Two Crazy Random Summer
		Thwaitgold bombardier beetle statuette,		//2019 Kingdom of Exploathing
		Thwaitgold buzzy beetle statuette,			//2020 Path of the Plumber
		Thwaitgold keyhole spider statuette,		//2020 Low Key Summer
		Thwaitgold slug statuette,					//2020 Grey Goo
		];
		
		foreach it in toDisplay
		{
			if(item_amount(it) > 0)
			{
				auto_log_info("Displaying " + item_amount(it) + " " + it, "green");
			}
			put_display(item_amount(it), it);
		}
	}
}

void handleKingLiberation()
{
	if(!inAftercore())
	{
		auto_log_info("can't run king liberated script. I am not actually in aftercore.");
		return;
	}
	restoreAllSettings();
	auto_log_info("Yay! The King is saved. I suppose you should do stuff.");
		
	cli_execute("pull all");
	visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");		//start sea quest so breakfast can collect [sea jelly]
	cli_execute("breakfast");
	
	displayOnKingLiberation();

	//workaround for mafia thinking icehouse is empty when you finish a standard run
	visit_url("museum.php?action=icehouse", false);
	
	//workaround for telegraphOfficeAvailable not updating when you finish a standard run. also grab your boots
	visit_url("place.php?whichplace=town_right");

	//probably a workaround for going into a standard run with an out of standard item resulting in mafia thinking you have no item in workshed.
	//is this fix still needed?
	visit_url("campground.php?action=workshed");
	
	visit_url("place.php?whichplace=town_wrong&action=townwrong_precinct");

	if(get_property("auto_snapshot").to_int() != my_ascensions())
	{
		if(svn_info("ccascend-snapshot").last_changed_rev > 0)
		{
			cli_execute("cc_snapshot.ash");
		}
		set_property("auto_snapshot", my_ascensions());
	}
	
	if(get_property("auto_borrowedTimeOnLiberation").to_boolean() && (get_property("_borrowedTimeUsed") == "false"))
	{
		if(get_property("_clipartSummons").to_int() < 3)
		{
			cli_execute("make borrowed time");
		}
		if((item_amount($item[Borrowed Time]) > 0) && (my_daycount() > 1))
		{
			use(1, $item[borrowed time]);
		}
	}

	if(get_property("auto_aftercore").to_int() != my_ascensions())
	{
//		buy_item($item[4-d camera], 1, 10000);
//		buy_item($item[mojo filter], 2, 3500);
//		buy_item($item[stone wool], 2, 3500);
//		buy_item($item[drum machine], 1, 2500);
//		buy_item($item[killing jar], 1, 500);
//		buy_item($item[spooky-gro fertilizer], 1, 500);
//		buy_item($item[stunt nuts], 1, 500);
//		buy_item($item[wet stew], 1, 3500);
//		buy_item($item[star chart], 1, 500);
//		buy_item($item[milk of magnesium], 2, 1200);
//		buy_item($item[Boris\'s Key Lime Pie], 1, 8500);
//		buy_item($item[Jarlsberg\'s Key Lime Pie], 1, 8500);
//		buy_item($item[Sneaky Pete\'s Key Lime Pie], 1, 8500);
//		buy_item($item[Digital Key Lime Pie], 1, 8500);
//		buy_item($item[Star Key Lime Pie], 3, 8500);
//		buy_item($item[The Big Book of Pirate insults], 1, 600);
//		buy_item($item[hand in glove], 1, 5000);


		if(get_property("auto_dickstab").to_boolean())
		{
			while(item_amount($item[Shore Inc. Ship Trip Scrip]) < 4)
			{
				if(!LX_doVacation()) break;		//tries to vacation and if fails it will break the loop
			}
		}

		set_property("auto_aftercore", my_ascensions());
	}

	auto_log_info("King Liberation Complete. Thank you for playing", "blue");
}

void main()
{
	handleKingLiberation();
}
