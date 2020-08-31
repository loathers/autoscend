import <autoscend.ash>

void handleKingLiberation()
{
	restoreAllSettings();
	if(!inAftercore())
	{
		auto_log_info("can't run king liberated script. I am not actually in aftercore.");
		return;
	}

	auto_log_info("Yay! The King is saved. I suppose you should do stuff.");

	if(my_familiar() != $familiar[Black Cat])
	{
		set_property("auto_100familiar", "");
	}

	if(have_display())
	{
		boolean[item] toDisplay = $items[Instant Karma, Thwaitgold Ant Statuette, Thwaitgold Bee Statuette, Thwaitgold Bookworm Statuette, Thwaitgold Butterfly Statuette, Thwaitgold Caterpillar Statuette, Thwaitgold Cockroach Statuette, Thwaitgold Dragonfly Statuette, Thwaitgold Firefly Statuette, Thwaitgold Goliath Beetle Statuette, Thwaitgold Grasshopper Statuette, Thwaitgold Maggot Statuette, Thwaitgold Moth Statuette, Thwaitgold Nit Statuette, Thwaitgold Praying Mantis Statuette, Thwaitgold Scarab Beetle Statuette, Thwaitgold Scorpion Statuette, Thwaitgold Spider Statuette, Thwaitgold Stag Beetle Statuette, Thwaitgold Termite Statuette, Thwaitgold Wheel Bug Statuette, Thwaitgold Woollybear Statuette];
		foreach it in toDisplay
		{
			if(item_amount(it) > 0)
			{
				auto_log_info("Displaying " + item_amount(it) + " " + it, "green");
			}
			put_display(item_amount(it), it);
		}
	}
	
	if(get_property("lastEmptiedStorage").to_int() != my_ascensions())
	{
		cli_execute("pull all");
	}

	visit_url("museum.php?action=icehouse", false);
	visit_url("place.php?whichplace=desertbeach&action=db_nukehouse");
	if((get_property("sidequestOrchardCompleted") != "none") && !get_property("_hippyMeatCollected").to_boolean())
	{
		visit_url("shop.php?whichshop=hippy");
	}
	visit_url("clan_rumpus.php?action=click&spot=3&furni=3");
	visit_url("clan_rumpus.php?action=click&spot=3&furni=3");
	visit_url("clan_rumpus.php?action=click&spot=3&furni=3");
	visit_url("clan_rumpus.php?action=click&spot=1&furni=4");
	visit_url("clan_rumpus.php?action=click&spot=4&furni=2");
	visit_url("clan_rumpus.php?action=click&spot=9&furni=3");

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

	visit_url("campground.php?action=workshed");

	if(get_property("auto_snapshot") == "")
	{
		if(svn_info("bumcheekascend-snapshot").last_changed_rev > 0)
		{
			cli_execute("snapshot");
		}
		if(svn_info("ccascend-snapshot").last_changed_rev > 0)
		{
			cli_execute("cc_snapshot");
		}
		set_property("auto_snapshot", "done");
	}

	visit_url("place.php?whichplace=town_wrong&action=townwrong_precinct");

	if((item_amount($item[Game Grid Token]) > 0) || (item_amount($item[Game Grid Ticket]) > 0))
	{
		int oldToken = item_amount($item[Defective Game Grid Token]);
		visit_url("place.php?whichplace=arcade&action=arcade_plumber", false);
		if(item_amount($item[Defective Game Grid Token]) > oldToken)
		{
			auto_log_info("Woohoo!!! You got a game grid tokON!!", "green");
		}
	}

	if(inAftercore() && !get_property("auto_aftercore").to_boolean())
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
			while(item_amount($item[Shore Inc. Ship Trip Scrip]) < 3)
			{
				adventure(1, $location[The Shore\, Inc. Travel Agency]);
			}
		}

		set_property("auto_aftercore", true);
	}

	if(get_property("auto_clearCombatScripts").to_boolean())
	{
		restoreSetting("kingLiberatedScript");
		restoreSetting("afterAdventureScript");
		restoreSetting("betweenBattleScript");
		restoreSetting("counterScript");
	}
	auto_log_info("King Liberation Complete. Thank you for playing", "blue");
}

void main()
{
	handleKingLiberation();
}
