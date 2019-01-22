script "kingcheese.ash";
import <cc_ascend.ash>

void handleKingLiberation()
{
	restoreAllSettings();
	if(get_property("kingLiberated").to_boolean() && (get_property("cc_snapshot") == ""))
	{
		print("Yay! The King is saved. I suppose you should do stuff.");
		if(!get_property("cc_kingLiberation").to_boolean())
		{
			set_property("cc_snapshot", "aborted");
			return;
		}
		visit_url("storage.php?action=takemeat&pwd&amt=" + my_storage_meat());
		visit_url("storage.php?pwd&");

		if(my_familiar() != $familiar[Black Cat])
		{
			set_property("cc_100familiar", $familiar[none]);
		}

		// Some items don\'t get pulled, notably, Stench Wad but some others as well (fat loot token, holiday fun, box of sunshine).
		// This might fix it...
		cli_execute("refresh all");

		if(have_display())
		{
			boolean[item] toDisplay = $items[Instant Karma, Thwaitgold Ant Statuette, Thwaitgold Bee Statuette, Thwaitgold Bookworm Statuette, Thwaitgold Butterfly Statuette, Thwaitgold Caterpillar Statuette, Thwaitgold Cockroach Statuette, Thwaitgold Dragonfly Statuette, Thwaitgold Firefly Statuette, Thwaitgold Goliath Beetle Statuette, Thwaitgold Grasshopper Statuette, Thwaitgold Maggot Statuette, Thwaitgold Moth Statuette, Thwaitgold Nit Statuette, Thwaitgold Praying Mantis Statuette, Thwaitgold Scarab Beetle Statuette, Thwaitgold Scorpion Statuette, Thwaitgold Spider Statuette, Thwaitgold Stag Beetle Statuette, Thwaitgold Termite Statuette, Thwaitgold Wheel Bug Statuette, Thwaitgold Woollybear Statuette];
			foreach it in toDisplay
			{
				if(item_amount(it) > 0)
				{
					print("Displaying " + item_amount(it) + " " + it, "green");
				}
				put_display(item_amount(it), it);
			}
		}

		boolean[item] toPull = $items[30669 scroll, 33398 scroll, 334 scroll, 5-hour acrimony, 64067 scroll, 668 scroll, 7-foot dwarven mattock, aerogel accordion, angst burger, anti-earplugs, antique accordion, antique tacklebox, Asdon Martin Keyfob, ass-stompers of violence, backwoods banjo, bacon, bag o\' tricks, bag of park garbage, ball-in-a-cup, baneful bandolier, Basaltamander Buckler, Bastille Battalion control rig, beach buck, bellhop\'s hat, belt of loathing, blue LavaCo Lamp&trade;, Boris\'s Helm, Boris\'s Helm (askew), box of sunshine, Brand of Violence, Bricko Eye Brick, Bricko Brick, Buddy Bjorn, buffalo dime, Camp Scout Backpack, can of rain-doh, carrot juice, carrot nose, caustic slime nodule, chamoisole, cheap sunglasses, cheer extractor, chibibuddy&trade; (on), chibibuddy&trade; (off), chroner, circle drum, clara\'s bell, claw of the infernal seal, cloak of dire shadows, coinspiracy, cold stone of hatred, cold wad, confusing led clock, cop dollar, corroded breeches, corrosive cowl, cow poker, Crayon Shavings, The Crown of Ed the Undying, crown of thrones, crumpled felt fedora, Crystalline Cheer, csa fire-starting kit, Daily Affirmation: Keep Free Hate In Your Heart, Dallas Dynasty Falcon Crest Shield, das boot, Deck of Every Card, deck of tropical cards, defective game grid token, diabolical crossbow, Dinsey\'s Brain, Dinsey\'s Glove, Dinsey\'s Oculus, Dinsey\'s Pants, Dinsey\'s Pizza Cutter, Dinsey\'s Radar Dish, dreadful fedora, dreadful glove, dreadful sweater, drunkula\'s wineglass, electronic dulcimer pants, eleven-foot pole, eternal car battery, Everfull Glass, Experimental Carbon Fiber Pasta Additive, Fake Washboard, FantasyRealm Key, Fat Loot Token, Fiberglass Fedora, Fiberglass Fetish, Filthy Lucre, First Post Shirt - Cir Senam, Fishy Pipe, Flaskfull of Hollow, Fossilized Necklace, Freddy Kruegerand, Frying Brainpan, Fudgecycle, Funfunds&trade;, fuzzy slippers of hatred, game grid ticket, game grid token, garbage sticker, gabardine gunnysack, genie bottle, giant yellow hat, girdle of hatred, glass eye, glass of goat\'s milk, Glenn\'s Golden Dice, goggles of loathing, Golden Mr. Accessory, grandfather watch, Gravyskin Belt of the Sauceblob, Great Wolf\'s Headband, Greatest American Pants, green face paint, green LavaCo Lamp&trade;, Grisly Shield, Hairpiece on Fire, Half A Purse, Handmade Hobby Horse, Hardened Slime Belt, Hardened Slime Hat, Hardened Slime Pants, High-Temperature mining drill, HOA regulation book, Hobo Nickel, Holiday Fun!, hot wad, how to avoid scams, instant karma, Incredibly Dense Meat Gem, ittah bittah hookah, Jackass Plumber Home Game, January\'s Garbage Tote, jarlsberg\'s pan, jarlsberg\'s pan (Cosmic Portal Mode), jeans of loathing, Jewel-Eyed Wizard Hat, jodhpurs of violence, The Jokester\'s gun, juju mojo mask, Jumping Horseradish, KoL Con 13 Snowglobe, Kremlin\'s Greatest Briefcase, LARP Membership Card, leathery bat skin, the legendary beat, lens of hatred, lens of violence, Liar\'s Pants, Li\'l Unicorn Costume, License To Chill, Lime, Little Geneticist DNA-Splicing Lab, Little Red Book, little wooden mannequin, llama lama gong, Loathing Legion Helicopter, Loathing Legion Jackhammer, Loathing Legion Knife, Lucky Crimbo Tiki Necklace, LyleCo Premium Magnifying Glass, LyleCo Premium Monocle, LyleCo Premium Pickaxe, LyleCo Premium Rope, Mace of the Tortoise, Mafia Middle Finger Ring, Mafia Pinky Ring, Mafia Thumb Ring, Map to Kokomo, Malevolent Medallion, mayor ghost\'s scissors, mayfly bait necklace, mer-kin digpick, mer-kin gladiator mask, mer-kin gladiator tailpiece, Mercenary Pistol, Mesmereyes&trade; Contact Lenses, milk of magnesium, Mime Army Shotglass, mime pocket probe, miner\'s helmet, miner\'s pants, Mr. Accessory, Mr. Accessory Jr., Mr. Cheeng\'s Spectacles, Mr. Eh?, Mr. Screege\'s Spectacles, mon tiki, Moveable Feast, Mumming Trunk, nasty-smelling moss, nasty rat mask, ninjammies, novelty belt buckle of violence, The Nuge\'s Favorite Crossbow, numberwang, octolus-skin cloak, odd silver coin, operation patriot shield, opium grenade, order of the silver wossname, ornamental sextant, Oscus\'s dumpster waders, Oscus\'s Neverending Soda, Oscus\'s Pelt, outrageous sombrero, over-the-shoulder folder holder, packet of beer seeds, packet of dragon\'s teeth, packet of tall grass seeds, packet of thanksgarden seeds, packet of winter seeds, pantaloons of hatred, pantsgiving, PARTY HARD T-Shirt, Pecos Dave\'s sixgun, peppermint parasol, pernicious cudgel, Pick-O-Matic lockpicks, pigsticker of violence, pine cone necklace, plastic vampire fangs, Platinum Yendorian Express Card, pocket square of loathing, poppy, portable cassette player, portable mayo clinic, Portable Pantogram, possessed sugar cube, Protonic Accelerator Pack, Primitive Alien Totem, psychoanalytic jar, puppet strings, quake of arrows, Ratskin Pajama Pants, red and green rain stick, red face paint, red LavaCo Lamp&trade;, reflection of a map, replica bat-oomerang, Ring of Detect Boring Doors, Ring Of The Skeleton Lord, Robin\'s Egg, Royal Scepter, rubber spider, Rubee&trade;, Sacramento Wine, sand dollar, sasq&trade; watch, scepter of loathing, School of Hard Knocks Diploma, sea lasso, sea cowbell, sewing kit, set of jacks, shirt kit, Shore Inc. Ship Trip Scrip, silver cow creamer, Sister Accessory, sleaze wad, slime-covered club, slime-covered compass, slime-covered greaves, slime-covered helmet, slime-covered lantern, slime-covered necklace, slime-covered shovel, slime-covered speargun, slime-covered staff, smooth velvet bra, smooth velvet hanky, smooth velvet hat, smooth velvet pants, smooth velvet pocket square, smooth velvet shirt, smooth velvet socks, Sneaky Pete\'s Leather Jacket, Sneaky Pete\'s Leather Jacket (Collar Popped), snow suit, soft green echo eyedrop antidote, solid shifting time weirdness, Source essence, Source shades, Spacegate Research, Space Trip Safety Headphones, Special Seasoning, Spelunker\'s Fedora, Spelunker\'s Khakis, spinning wheel, spooky putty monster, spooky putty sheet, spooky wad, sprinkles, staff of kitchen royalty, staff of the scummy sink, staff of simmering hatred, stench wad, stinky cheese diaper, stinky cheese eye, stinky cheese sword, stinky cheese wheel, Stephen\'s Lab Coat, stick-knife of loathing, stinky fannypack, STYX Deodorant Body Spray, Tales of Spelunking, Talisman of Baio, Talking Spade, Tenderizing Hammer, Thor\'s Pliers, Ticksilver Ring, Tiki Lighter, Time Bandit Time Towel, Time Bandit Badge of Courage, Time Lord Badge of Honor, Time Shuriken, time sword, Time-Spinner, Time-twitching Toolbelt, tiny costume wardrobe, Toggle Switch (Bartend), tropical paperweight, toy accordion, Travoltan Trousers, Transmission from Planet Xi, Treads of Loathing, twinkly wad, unbearable light, Uncle Buck, Uncle Crimbo\'s Hat, unconscious collective dream jar, V for Vivala Mask, villainous scythe, volcoino, Wal-Mart gift certificate, Wand of Oscus, water wings for babies, Western-Style Skinning Knife, Work is a Four Letter Sword, woven baling wire bracelets, Xiblaxian 5D Printer, Xiblaxian Alloy, Xiblaxian Circuitry, Xiblaxian Holo-Wrist-Puter, Xiblaxian Polymer, Xiblaxian Stealth Cowl, Xiblaxian Stealth Trousers, Xiblaxian Stealth Vest, Zombo\'s Empty Eye];
		foreach it in toPull
		{
			if(storage_amount(it) > 0)
			{
				print("Pulling " + storage_amount(it) + " " + it, "green");
			}
			pullAll(it);
		}

		toPull = $items[Bittycar meatcar, burrowgrub hive, Can of Rain-Doh, Cheap Toaster, chester\'s bag of candy, chroner cross, chroner trigger, the cocktail shaker, Creepy Voodoo Doll, festive warbear bank, glass gnoll eye, infinite BACON machine, picky tweezers, taco dan\'s taco stand flier, Trivial Avocations Board Game, warbear breakfast machine, warbear soda machine];
		foreach it in toPull
		{
			if(storage_amount(it) > 0)
			{
				print("Pulling/Using " + storage_amount(it) + " " + it, "green");
			}
			pullAndUse(it, 1);
		}

		pullPVPJunk();

//		visit_url("lair2.php?preaction=key&whichkey=436");
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

		if(get_property("cc_borrowedTimeOnLiberation").to_boolean() && (get_property("_borrowedTimeUsed") == "false"))
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

		if(get_property("cc_snapshot") == "")
		{
			if(svn_info("bumcheekascend-snapshot").last_changed_rev > 0)
			{
				cli_execute("snapshot");
			}
			if(svn_info("ccascend-snapshot").last_changed_rev > 0)
			{
				cli_execute("cc_snapshot");
			}
			set_property("cc_snapshot", "done");
		}

		visit_url("place.php?whichplace=town_wrong&action=townwrong_precinct");

		if((item_amount($item[Game Grid Token]) > 0) || (item_amount($item[Game Grid Ticket]) > 0))
		{
			int oldToken = item_amount($item[Defective Game Grid Token]);
			visit_url("place.php?whichplace=arcade&action=arcade_plumber", false);
			if(item_amount($item[Defective Game Grid Token]) > oldToken)
			{
				print("Woohoo!!! You got a game grid tokON!!", "green");
			}
		}
	}

	if((get_property("kingLiberated") == "true") && !get_property("cc_aftercore").to_boolean())
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


		if(get_property("cc_dickstab").to_boolean())
		{
			while(item_amount($item[Shore Inc. Ship Trip Scrip]) < 3)
			{
				adventure(1, $location[The Shore\, Inc. Travel Agency]);
			}
		}

		if(have_skill($skill[Iron Palm Technique]) && (have_effect($effect[Iron Palms]) == 0))
		{
			use_skill(1, $skill[Iron Palm Technique]);
		}
		set_property("cc_aftercore", true);
	}

	if(get_property("cc_clearCombatScripts").to_boolean())
	{
		restoreSetting("kingLiberatedScript");
		restoreSetting("afterAdventureScript");
		restoreSetting("betweenAdventureScript");
		restoreSetting("betweenBattleScript");
		restoreSetting("counterScript");
	}
	print("King Liberation Complete. Thank you for playing", "blue");
}


boolean pullPVPJunk()
{
	if(!get_property("cc_pullPVPJunk").to_boolean())
	{
		return false;
	}
	boolean[item] toPull = $items[artisanal hand-squeezed wheatgrass juice, ascii fu manchu, bangyomaman battle juice, black friar\'s tonsure, black magic powder, blob of acid, blue oyster badge, booby trap, brigand brittle, bubblin\' chemistry solution, bull blubber, button rouge, cheap clip-on ninja tie, clove-flavored lip balm, compressed air canister, cube of ectoplasm, dancing fan, ectoplasm <i>au jus</i>, eldritch dough, electric copperhead potion, enchanted flyswatter, enchanted muesli, enchanted plunger, filthy armor, fireclutch, fitspiration&trade; poster, flask of rainwater, flayed mind, frog lip-print, fu manchu wax, gearhead goo, giant neckbeard, giant tube of black lipstick, gilt perfume bottle, glass of gnat milk, glass of warm milk, gnollish crossdress, gold toothbrush, handyman &quot;hand soap&quot;, holistic headache remedy, iiti kitty gumdrop, illuminati earpiece, janglin\' bones, jazzy cigarette holder, knob goblin mutagen, kobold kibble, leather glove, leonard\'s glasses, lucky cat\'s paw, lynyrd skinner toothblack, missing eye simulation device, muscle oil, ninja eyeblack, ninja fear powder, oil-filled donut, page of the necrohobocon, perpendicular guano, pirate cream pie, plastic jefferson wings, punk patch, pygmy adder oil, pygmy dart, pygmy papers, pygmy witchhazel, ravenous eye, red army camouflage kit, redeye&trade; eyedrops, salt water taffy, scrunchie tourniquet, secret mummy herbs and spices, Shivering Ch&egrave;vre, short deposition, skelelton spine, skeletal banana, skullery maid\'s knee, smart bone dust, smut orc sunglasses, space marine flash grenade, spooky gravy fairy warlock hat, steampunk potion, stone golem pebbles, tears of the quiet healer, temporary tribal tattoo, tiny canopic jar, una poca de gracia, unholy water, vial of swamp vapors, voodoo glowskull, white chocolate golem seeds, zombie hollandaise];
	foreach it in toPull
	{
		pullAll(it);
	}

	toPull = $items[all-purpose cleaner, awful poetry journal, batgut];
	foreach it in toPull
	{
		pullAll(it);
	}
	return true;
}

void main()
{
	handleKingLiberation();
}
