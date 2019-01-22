script "cc_ascend/cc_equipment.ash";

void equipBaseline();
void equipBaselineWeapon();
void equipBaselinePants();
void equipBaselineBack();
void equipBaselineShirt();
void equipBaselineHat();
void equipBaselineAccessories();
void equipBaselineAcc1();
void equipBaselineAcc2();
void equipBaselineAcc3();
void equipBaselineHolster();
void equipBaselineFam();
void equipRollover();
void handleOffHand();
void ensureSealClubs();
item handleSolveThing(item[int] poss, slot loc);
item handleSolveThing(item[int] poss);
item handleSolveThing(boolean[item] poss, slot loc);
item handleSolveThing(boolean[item] poss);
void makeStartingSmiths();


//	Replace the current acc3 item (from baseline) with another. Mostly for our Xiblaxian handling so that is why this is the only one implemented.
void replaceBaselineAcc3();

void makeStartingSmiths()
{
	if(!have_skill($skill[Summon Smithsness]))
	{
		return;
	}

	if(item_amount($item[Lump of Brituminous Coal]) == 0)
	{
		if(my_mp() < (3 * mp_cost($skill[Summon Smithsness])))
		{
			print("You don't have enough MP for initialization, it might be ok but probably not.", "red");
		}
		use_skill(3, $skill[Summon Smithsness]);
	}

	if(knoll_available())
	{
		buyUpTo(1, $item[maiden wig]);
	}

	switch(my_class())
	{
	case $class[Seal Clubber]:
		if(!possessEquipment($item[Meat Tenderizer is Murder]))
		{
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[seal-clubbing club]);
		}
		if(!possessEquipment($item[Vicar\'s Tutu]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && knoll_available())
		{
			buy(1, $item[Frilly Skirt]);
			ccCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Frilly Skirt]);
		}
		break;
	case $class[Turtle Tamer]:
		if(!possessEquipment($item[Work is a Four Letter Sword]))
		{
			buyUpTo(1, $item[Sword Hilt]);
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[sword hilt]);
		}
		if(!possessEquipment($item[Ouija Board\, Ouija Board]))
		{
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[turtle totem]);
		}
		break;
	case $class[Sauceror]:
		if(!possessEquipment($item[Saucepanic]))
		{
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[Saucepan]);
		}
		if(!possessEquipment($item[A Light that Never Goes Out]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
		{
			ccCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Third-hand Lantern]);
		}
		break;
	case $class[Pastamancer]:
		if(!possessEquipment($item[Hand That Rocks the Ladle]))
		{
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[Pasta Spoon]);
		}
		break;
	case $class[Disco Bandit]:
		if(!possessEquipment($item[Frankly Mr. Shank]))
		{
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[Disco Ball]);
		}
		break;
	case $class[Accordion Thief]:
		if(!possessEquipment($item[Shakespeare\'s Sister\'s Accordion]))
		{
			ccCraft("smith", 1, $item[lump of Brituminous coal], $item[Stolen Accordion]);
		}
		break;
	}

	if(knoll_available() && !possessEquipment($item[Hairpiece on Fire]) && (item_amount($item[lump of Brituminous Coal]) > 0))
	{
		ccCraft("smith", 1, $item[lump of Brituminous coal], $item[maiden wig]);
	}
	buffMaintain($effect[Merry Smithsness], 0, 1, 10);
}

boolean possessEquipment(item equipment)
{
	if(equipment == $item[none])
	{
		return false;
	}

	if(item_amount(equipment) > 0)
	{
		return true;
	}
//	if(closet_amount(equipment) > 0)
//	{
//		return true;
//	}
	foreach mySlot in $slots[]
	{
		if(equipped_item(mySlot) == equipment)
		{
			return true;
		}
	}

	if(item_type(equipment) == "familiar equipment")
	{
		foreach fam in $familiars[]
		{
			if(familiar_equipped_equipment(fam) == equipment)
			{
				return true;
			}
		}
	}

	return false;
}


boolean handleBjornify(familiar fam)
{
	if(in_hardcore())
	{
		return false;
	}

	if((equipped_item($slot[back]) != $item[buddy bjorn]) || (my_bjorned_familiar() == fam))
	{
		return false;
	}

	if(is100FamiliarRun() && (fam == my_familiar()))
	{
		return false;
	}

	if(have_familiar(fam))
	{
		bjornify_familiar(fam);
	}
	else
	{
		if(have_familiar($familiar[El Vibrato Megadrone]))
		{
			bjornify_familiar($familiar[El Vibrato Megadrone]);
		}
		else
		{
			if((my_familiar() != $familiar[Grimstone Golem]) && have_familiar($familiar[Grimstone Golem]))
			{
				bjornify_familiar($familiar[Grimstone Golem]);
			}
			else if(have_familiar($familiar[Adorable Seal Larva]))
			{
				bjornify_familiar($familiar[Adorable Seal Larva]);
			}
			else
			{
				return false;
			}
		}
	}
	if(my_familiar() == $familiar[none])
	{
		if(my_bjorned_familiar() == $familiar[Grimstone Golem])
		{
			handleFamiliar("stat");
		}
		else if(my_bjorned_familiar() == $familiar[Grim Brother])
		{
			handleFamiliar("item");
		}
		else
		{
			handleFamiliar("item");
		}
	}
	return true;
}


void handleOffHand()
{
	item toEquip = $item[none];
	boolean[item] poss;

	if((my_path() == "Heavy Rains") && (item_amount($item[Thor\'s Pliers]) > 0) && have_skill($skill[Double-Fisted Skull Smashing]))
	{
		equip($slot[off-hand], $item[Thor\'s Pliers]);
		return;
	}

	if((my_path() == "Nuclear Autumn") && have_skill($skill[Projectile Salivary Glands]) && possessEquipment($item[Lead Umbrella]))
	{
		if((equipped_item($slot[off-hand]) != $item[Lead Umbrella]) && (have_effect($effect[Rad-Pro Tected]) == 0))
		{
			equip($slot[off-hand], $item[Lead Umbrella]);
			return;
		}
	}

	if(weapon_hands(equipped_item($slot[weapon])) > 1)
	{
		return;
	}

	if(my_path() == "Way of the Surprising Fist")
	{
		return;
	}

	# string item_type($item[]) returns "shield" for shields, yay!
	#if weapon_type(equipped_item($slot[weapon]) == $stat[Moxie]) we can dual-wield other ranged weapons.
	if(my_class() != $class[Turtle Tamer])
	{
		if(have_skill($skill[Double-Fisted Skull Smashing]) && (weapon_type(equipped_item($slot[weapon])) != $stat[Moxie]))
		{
			poss = $items[Turtle Totem, Knob Goblin Scimitar, Mace of the Tortoise, Sabre Teeth, Pitchfork, Cardboard Wakizashi, Oversized Pizza Cutter, Hot Plate, Spiked Femur, Party Crasher, Yorick, Sawblade Shield, Wicker Shield, Keg Shield, KoL Con 13 Snowglobe, Latte Lovers Member\'s Mug, Operation Patriot Shield, Ox-head Shield, Fake Washboard, Barrel Lid];
		}
		else
		{
			poss = $items[7-ball, 5-ball, 2-ball, 1-ball, Hot Plate, Disturbing Fanfic, Coffin Lid, Tesla\'s Electroplated Beans, Rubber Ribcage, Heavy-Duty Clipboard, Meteorite Guard, Party Crasher, Sawblade Shield, Wicker Shield, Keg Shield, Six-Rainbow Shield, Whatsian Ionic Pliers, Little Black Book, KoL Con 13 Snowglobe, Yorick, Astral Shield, Latte Lovers Member\'s Mug, A Light That Never Goes Out, Astral Statuette, Operation Patriot Shield, Ox-head Shield, Fake Washboard, Barrel Lid];

			if(have_skill($skill[Beancannon]) && (get_property("_beancannonUses").to_int() < 5))
			{
				poss = $items[7-ball, 5-ball, 2-ball, 1-ball, Hot Plate, Disturbing Fanfic, Coffin Lid, Rubber Ribcage, Astral Statuette, Heavy-Duty Clipboard, KoL Con 13 Snowglobe, Sawblade Shield, Wicker Shield, Keg Shield, Whatsian Ionic Pliers, Little Black Book, Tesla\'s Electroplated Beans, World\'s Blackest-Eyed Peas, Trader Olaf\'s Exotic Stinkbeans, Shrub\'s Premium Baked Beans, Hellfire Spicy Beans, Frigid Northern Beans, Heimz Fortified Kidney Beans, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Mixed Garbanzos and Chickpeas, Yorick, Astral Shield, Latte Lovers Member\'s Mug, A Light That Never Goes Out, Ox-head Shield, Operation Patriot Shield, Fake Washboard, Barrel Lid];
			}
		}
	}
	if(my_class() == $class[Turtle Tamer])
	{
		poss = $items[Hot Plate, Coffin Lid, Sewer Turtle, Barskin Buckler, Turtle Wax Shield, Clownskin Buckler, Box Turtle, Demon Buckler, Meat Shield, White Satin Shield, Meteorite Guard, Polyester Pad, Gnauga Hide Buckler, Yakskin Buckler, Rubber Ribcage, Penguin Skin Buckler, Hippo Skin Buckler, Tortoboggan Shield, Padded Tortoise, Painted Shield, Spiky Turtle Shield, Wicker Shield, Catskin Buckler, Battered Hubcap, Keg Shield, Mer-kin Roundshield, KoL Con 13 Snowglobe, Latte Lovers Member\'s Mug, Ouija Board\, Ouija Board, Ox-head Shield, Barrel Lid, Operation Patriot Shield, Fake Washboard];
	}

	if(my_class() == $class[Pastamancer])
	{
		if((have_skill($skill[Double-Fisted Skull Smashing])) && (weapon_type(equipped_item($slot[weapon])) != $stat[Moxie]))
		{
			poss = $items[Turtle Totem, Knob Goblin Scimitar, Meteorite Guard, KoL Con 13 Snowglobe, Sabre Teeth, Pitchfork, Cardboard Wakizashi, Oversized Pizza Cutter, Spiked Femur, Wicker Shield, Keg Shield, Yorick, Ox-head Shield, Latte Lovers Member\'s Mug, Barrel Lid, Basaltamander Buckler, Operation Patriot Shield, Jarlsberg\'s Pan];
		}
		else
		{
			poss = $items[Hot Plate, Disturbing Fanfic, Coffin Lid, Rubber Ribcage, Heavy-Duty Clipboard, Meteorite Guard, KoL Con 13 Snowglobe, Sawblade Shield, Wicker Shield, Keg Shield, Sticky Hand Whip, Whatsian Ionic Pliers, Little Black Book, Astral Shield, Astral Statuette, Yorick, A Light That Never Goes Out, Ox-head Shield, Latte Lovers Member\'s Mug, Barrel Lid, Basaltamander Buckler, Operation Patriot Shield, Jarlsberg\'s Pan];
		}
	}

	if(my_class() == $class[Sauceror])
	{
		poss = $items[Hot Plate, Low-Budget Shield, Disturbing Fanfic, Coffin Lid, Rubber Ribcage, Heavy-Duty Clipboard, Meteorite Guard, Sawblade Shield, Wicker Shield, Keg Shield, Whatsian Ionic Pliers, Little Black Book, KoL Con 13 Snowglobe, Astral Shield, Astral Statuette, Yorick, Ox-head Shield, Latte Lovers Member\'s Mug, Operation Patriot Shield, Jarlsberg\'s Pan, Barrel Lid, Basaltamander Buckler, A Light that Never Goes Out];
	}

	if(my_class() == $class[Disco Bandit])
	{
		if((have_skill($skill[Double-Fisted Skull Smashing])) && (weapon_type(equipped_item($slot[weapon])) != $stat[Moxie]))
		{
			poss = $items[Turtle Totem, Knob Goblin Scimitar, Meteorite Guard, KoL Con 13 Snowglobe, Sabre Teeth, Pitchfork, Cardboard Wakizashi, Oversized Pizza Cutter, Spiked Femur, Wicker Shield, Yorick, Latte Lovers Member\'s Mug, Keg Shield, Ox-head Shield, Barrel Lid, Operation Patriot Shield];
		}
		else
		{
			poss = $items[Hot Plate, Disturbing Fanfic, Coffin Lid, Rubber Ribcage, Heavy-Duty Clipboard, Meteorite Guard, KoL Con 13 Snowglobe, Sawblade Shield, Wicker Shield, Keg Shield, Whatsian Ionic Pliers, Little Black Book, Astral Shield, Astral Statuette, Latte Lovers Member\'s Mug, Yorick, Ox-head Shield, Operation Patriot Shield, Fake Washboard, A Light That Never Goes Out, Barrel Lid];
		}
	}

	if(my_class() == $class[Avatar of Jarlsberg])
	{
		poss = $items[Jarlsberg\'s Pan, Jarlsberg\'s Pan (Cosmic Portal Mode)];
	}

	item[int] possList = List(poss);
	if(my_level() >= 13)
	{
		int barrelLid = possList.ListFind($item[Barrel Lid]);
		if(barrelLid != -1)
		{
			possList = possList.ListRemove($item[Barrel Lid]);
		}
	}
	if(cc_my_path() == "Disguises Delimit")
	{
		int barrelLid = possList.ListFind($item[KoL Con 13 Snowglobe]);
		if(barrelLid != -1)
		{
			possList = possList.ListRemove($item[KoL Con 13 Snowglobe]);
		}
	}

	if(my_class() == $class[Gelatinous Noob])
	{
		possList = possList.ListRemove($item[Barrel Lid]);
	}

	toEquip = handleSolveThing(possList, $slot[off-hand]);
/*
	if(contains_text(holiday(), "Oyster Egg Day"))
	{
		poss = $items[Hot Plate, Disturbing Fanfic, Coffin Lid, Sawblade Shield, Wicker Shield, Keg Shield, Barrel Lid];
		if((toEquip == $item[none]) || (poss contains toEquip))
		{
			if(!possessEquipment($item[Oyster Basket]) && (my_meat() >= 300))
			{
				buy(1, $item[Oyster Basket]);
			}
			if(possessEquipment($item[Oyster Basket]))
			{
				toEquip = $item[Oyster Basket];
			}
		}
	}
*/
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[off-hand])))
	{
		if((weapon_type(toEquip) != $stat[none]) && (equipped_item($slot[weapon]) == $item[none]))
		{
			return;
		}

		if(equipped_item($slot[weapon]) != toEquip)
		{
			equip($slot[Off-hand], toEquip);
		}
		else if((equipped_item($slot[weapon]) == toEquip) && (item_amount(toEquip) > 0))
		{
			equip($slot[Off-hand], toEquip);
		}
	}
}

item handleSolveThing(item[int] poss)
{
	return handleSolveThing(poss, $slot[none]);
}

item handleSolveThing(item[int] poss, slot loc)
{
	string override = get_property("cc_equipment_override_" + loc);
	if(override != "")
	{
		string[int] overrides = split_string(override, ";");
		poss = itemList();
		foreach index, iName in overrides
		{
			poss = poss.ListInsert(to_item(iName));
		}
	}

	item toEquip = $item[none];
	set_property("cc_ignoreCombat", to_lower_case(get_property("cc_ignoreCombat")));
	int idx = 0;
	while(idx < count(poss))
	{
		boolean ignore = false;
		item thing = poss[idx];
		if(contains_text(get_property("cc_ignoreCombat"), "(noncombat)") && (numeric_modifier(thing, "Combat Rate") < 0))
		{
			ignore = true;
		}
		if(contains_text(get_property("cc_ignoreCombat"), "(combat)") && (numeric_modifier(thing, "Combat Rate") > 0))
		{
			ignore = true;
		}
		if(contains_text(get_property("cc_ignoreCombat"), "(ml)") && (numeric_modifier(thing, "Monster Level") > 0))
		{
			ignore = true;
		}
		if((get_property("cc_beatenUpCount").to_int() >= 7) && (numeric_modifier(thing, "Monster Level") > 0))
		{
			ignore = true;
		}
		if(contains_text(get_property("cc_ignoreCombat"), "(seal)") && (loc == $slot[weapon]) && (item_type(thing) != "club"))
		{
			ignore = true;
		}
		if(!glover_usable(thing))
		{
			if(thing != $item[Protonic Accelerator Pack])
			{
				ignore = true;
			}
			else
			{
				if(!expectGhostReport() && !haveGhostReport())
				{
					ignore = true;
				}
			}
		}

		item acc1 = equipped_item($slot[acc1]);
		item acc2 = equipped_item($slot[acc2]);
		item acc3 = equipped_item($slot[acc3]);
		if(loc == $slot[acc1])
		{
			acc1 = $item[none];
			acc2 = $item[none];
			acc3 = $item[none];
		}
		else if(loc == $slot[acc2])
		{
			acc2 = $item[none];
			acc3 = $item[none];
		}
		else if(loc == $slot[acc3])
		{
			acc3 = $item[none];
		}
		//Yes, $slot[acc3] is always blocked here, however, we need to reconcile this with the Xiblaxian handler in precheese.ash

		if(possessEquipment(thing) && can_equip(thing) && (acc1 != thing) && (acc2 != thing) && (acc3 != thing) && !ignore)
		{
			toEquip = thing;
		}
		if(ignore && (equipped_item(loc) == thing))
		{
			equip(loc, $item[none]);
		}
		idx += 1;
	}
	return toEquip;
}

item handleSolveThing(boolean[item] poss)
{
	return handleSolveThing(poss, $slot[none]);
}

item handleSolveThing(boolean[item] poss, slot loc)
{
	return handleSolveThing(List(poss),loc);
}

void equipBaselinePants()
{
	item toEquip = $item[none];

	item[int] poss = List($items[Old Sweatpants, Studded Leather Boxer Shorts, Knob Goblin Harem Pants, three-legged pants, Knob Goblin Pants, Pants Of The Slug Lord, Chain-Mail Monokini, Stylish Swimsuit, Union Scalemail Pants, Genie\'s Pants, Hep Waders, Paper-Plate-Mail Pants, Troutpiece, Bloody Clown Pants, Alpha-Mail Pants, Knob Goblin Uberpants, Psychic\'s Pslacks, Filthy Corduroys, Antique Greaves, Ninja Hot Pants, Demonskin Trousers, Leotarrrd, Swashbuckling Pants, Burnt Snowpants, Troutpiece, Snowboarder Pants, Oil Slacks, Furry Pants, Pygmy Briefs, Bloodied Surgical Dungarees, Spangly Mariachi Pants, Stainless Steel Slacks, Vicar\'s Tutu, Troll Britches, Xiblaxian Stealth Trousers, Distressed Denim Pants, Greatest American Pants, Pantogram Pants, Troutsers, Bankruptcy Barrel, Astral Shorts, Pantsgiving]);

	if(my_primestat() == $stat[Muscle])
	{
		poss = ListInsertAt(poss, $item[Discarded Swimming Trunks], poss.ListFind($item[Stainless Steel Slacks]));
	}

	if(my_class() == $class[Turtle Tamer])
	{
		poss = ListInsertAt(poss, $item[Galapagosian Cuisses], poss.ListFind($item[Vicar\'s Tutu]));
	}

	toEquip = handleSolveThing(poss, $slot[pants]);

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[pants])))
	{
		equip($slot[pants],toEquip);
	}
}

void equipBaselineShirt()
{
	if(!hasTorso())
	{
		return;
	}
	item toEquip = $item[none];
	item[int] poss = List($items[Professor What T-Shirt, Barskin Cloak, Thinknerd T-Shirt, Harem Girl T-Shirt, Clownskin Harness, Bronze Breastplate, KoL Con 13 T-Shirt, White Snakeskin Duster, Grateful Undead T-shirt, Demonskin Jacket, Gnauga Hide Vest, Tuxedo Shirt, Grungy Flannel Shirt, Lynyrdskin Tunic, Makeshift Garbage Shirt, Glass Casserole Dish, Surgical Apron, Punk Rock Jacket, Bat-Ass Leather Jacket, Midriff Scrubs, Star Shirt, Yak Anorak, Dragonscale Breastplate, Blessed Rustproof +2 Gray Dragon Scale Mail, Ultracolor&trade; Shirt, Sea Salt Scrubs, Shark Jumper, Bod-Ice, Liam\'s Mail, Astral Shirt, Stephen\'s Lab Coat, LOV Eardigan, Sneaky Pete\'s Leather Jacket, Sneaky Pete\'s Leather Jacket (Collar Popped)]);


	if((my_primestat() == $stat[muscle]) && (my_level() < 13))
	{
		poss = ListInsert(poss, $item[LOV Eardigan]);
	}

	if((januaryToteTurnsLeft($item[Makeshift Garbage Shirt]) > 0) && (my_level() < 13))
	{
		poss = ListInsert(poss, $item[Makeshift Garbage Shirt]);
	}
	else
	{
		poss = ListInsertAt(poss, $item[Makeshift Garbage Shirt], poss.ListFind($item[Glass Casserole Dish]));
	}


	toEquip = handleSolveThing(poss, $slot[shirt]);

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[shirt])))
	{
		equip($slot[shirt],toEquip);
	}
}

void equipBaselineBack()
{
	item toEquip = $item[none];

	item[int] poss = List($items[Whatsit-Covered Turtle Shell, Black Cloak, Pillow Shell, Oil Shell, Gabardine Gunnysack, Fiberglass Frock, Giant Gym Membership Card, Frozen Turtle Shell, Misty Cloak, Misty Cape, Misty Robe, Makeshift Cape, Polyester Parachute, Buddy Bjorn, Camp Scout Backpack, Protonic Accelerator Pack]);

	switch(my_primestat())
	{
	case $stat[Muscle]:
		poss = ListInsertAt(poss, $item[Misty Cloak], poss.ListFind($item[Makeshift Cape]));
		poss = ListInsertAt(poss, $item[Misty Cape], poss.ListFind($item[Makeshift Cape]));
		poss = ListInsertAt(poss, $item[Misty Robe], poss.ListFind($item[Makeshift Cape]));
		break;
	case $stat[Mysticality]:
		poss = ListInsertAt(poss, $item[Misty Cloak], poss.ListFind($item[Makeshift Cape]));
		poss = ListInsertAt(poss, $item[Misty Cape], poss.ListFind($item[Makeshift Cape]));
		poss = ListInsertAt(poss, $item[Misty Robe], poss.ListFind($item[Makeshift Cape]));
		poss = poss.ListInsert($item[LOV Epaulettes]);
		break;
	case $stat[Moxie]:
		poss = ListInsertAt(poss, $item[Misty Cloak], poss.ListFind($item[Makeshift Cape]));
		poss = ListInsertAt(poss, $item[Misty Cape], poss.ListFind($item[Makeshift Cape]));
		poss = ListInsertAt(poss, $item[Misty Robe], poss.ListFind($item[Makeshift Cape]));
		break;
	}

	if(expectGhostReport())
	{
		poss = poss.ListInsert($item[Protonic Accelerator Pack]);
	}

	toEquip = handleSolveThing(poss, $slot[back]);

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[back])))
	{
		equip($slot[back],toEquip);
	}
}

void equipBaselineHat()
{
	item toEquip = $item[none];

	item[int] poss = List($items[Knob Goblin Harem Veil, Snorkel, Seal-Skull Helmet, Helmet Turtle, Ravioli Hat, Hollandaise Helmet, Kentucky-Style Derby, Knobby Helmet Turtle, Viking Helmet, Eyepatch, Pentacorn Hat, Oversized Skullcap, Goofily-Plumed Helmet, Dolphin King\'s Crown, Yellow Plastic Hard Hat, Wooden Salad Bowl, Football Helmet, Filthy Knitted Dread Sack, Chef\'s Hat, Genie\'s Turbane, Bellhop\'s Hat, Crown of the Goblin King, Gravy Boat, one-gallon hat, two-gallon hat, three-gallon hat, four-gallon hat, five-gallon hat, six-gallon hat, seven-gallon hat, Psychic\'s Circlet, Meteortarboard, Wad Of Used Tape, Astral Chapeau, Van der Graaf helmet, Safarrri Hat, Mohawk Wig, Brown Felt Tophat, Mark I Steam-Hat, Burning Paper Hat, Mark II Steam-Hat, eight-gallon hat, nine-gallon hat, ten-gallon hat, eleven-gallon hat, Cold Water Bottle, Beer Helmet, Mark III Steam-Hat, Mark IV Steam-Hat, Nurse\'s Hat, Training Helmet, Fuzzy Earmuffs, Mark V Steam-Hat, Hairpiece On Fire, Reinforced Beaded Headband, Giant Yellow Hat, Xiblaxian Stealth Cowl, Very Pointy Crown, Boris\'s Helm, Boris\'s Helm (askew), The Crown of Ed the Undying, Team Avarice Cap]);

	if(my_class() == $class[Turtle Tamer])
	{
		poss = ListInsertAt(poss, $item[Elder Turtle Shell], poss.ListFind($item[Van der Graaf Helmet]));
	}
	toEquip = handleSolveThing(poss, $slot[hat]);

	# Clarify this, do we have a filter for wanting +NC?
	if(possessEquipment($item[Very Pointy Crown]))
	{
		toEquip = $item[Very Pointy Crown];
	}
	else if(possessEquipment($item[Xiblaxian Stealth Cowl]))
	{
		toEquip = $item[Xiblaxian Stealth Cowl];
	}

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[hat])))
	{
		equip($slot[hat],toEquip);
	}
}

void equipBaselineWeapon()
{
	item toEquip = $item[none];
	boolean[item] poss;

	if(my_path() == "Way of the Surprising Fist")
	{
		return;
	}

	switch(my_class())
	{
	case $class[Seal Clubber]:
		poss = $items[Seal-Clubbing Club, Gnollish Flyswatter, Club of Corruption, Remaindered Axe, Skeleton Bone, Corrupt Club of Corruption, Flaming Crutch, Homoerotic Frat-Paddle, Kneecapping Stick, Corrupt Club of Corrupt Corruption, Spiked Femur, Severed Flipper, Gnawed-Up Dog Bone, Mannequin Leg, Infernal Toilet Brush, Hilarious Comedy Prop, Giant Foam Finger, Red Hot Poker, Maxwell\'s Silver Hammer, Elegant Nightstick, Curmudgel, Giant Foam Finger, Oversized Pipe, Ghast Iron Cleaver, Frozen Seal Spine, Stainless Steel Shillelagh, Porcelain Police Baton, Bass Clarinet, Fish Hatchet, Lead Pipe, Meat Tenderizer Is Murder, Dented Scepter];
		break;
	case $class[Turtle Tamer]:
		poss = $items[Turtle Totem, Knob Goblin Tongs, Knob Goblin Scimitar, Skeleton Bone, Corn Holder, Eggbeater, Elegant Nightstick, Law-Abiding Citizen Cane, Mace of the Tortoise, Oversized Pizza Cutter, Maxwell\'s Silver Hammer, Witty Rapier, Ancient Ice Cream Scoop, Antique Machete, Spectral Axe, Short-Handled Mop, Ghast Iron Cleaver, Oversized Pipe, Octopus\'s Spade, Rusty Piece Of Rebar, Thor\'s Pliers, Rope, Lead Pipe, Work Is A Four Letter Sword, Bass Clarinet, Fish Hatchet, Garbage Sticker, Dented Scepter];
		break;
	case $class[Sauceror]:
		poss = $items[Saucepan, Dishrag, Corn Holder, Eggbeater, Cardboard Wakizashi, Witty Rapier, Oversized Pizza Cutter, Titanium Assault Umbrella, Thor\'s Pliers, Candlestick, Fish Hatchet, Bass Clarinet, Saucepanic];
		break;
	case $class[Pastamancer]:
		poss = $items[Pasta Spoon, Knob Goblin Tongs, Dishrag, Corn Holder, Eggbeater, Cardboard Wakizashi, Witty Rapier, Thor\'s Pliers, Wrench, Fish Hatchet, Bass Clarinet, Hand That Rocks The Ladle];
		break;
	case $class[Disco Bandit]:
		poss = $items[Dented Harmonica, Frigid Derringer, The Jokester\'s Gun, Fish Hatchet, Knife, Bass Clarinet, Frankly Mr. Shank];
		break;
	case $class[Accordion Thief]:
		poss = $items[Dented Harmonica, Frigid Derringer, The Jokester\'s Gun, Fish Hatchet, Revolver, accord ion, Bass Clarinet, Shakespeare\'s Sister\'s Accordion];
		break;
	case $class[Avatar of Boris]:
		poss = $items[Trusty];
		break;
	case $class[Avatar of Sneaky Pete]:
		poss = $items[Knife, Revolver, Sneaky Pete\'s Basket, Bass Clarinet];
		break;
	case $class[Ed]:
#		poss = $items[[7961] Staff of Ed];
		poss = $items[Spiked Femur, Grassy Cutlass, Oversized Pizza Cutter, Giant Artisanal Rice Peeler, Titanium Assault Umbrella, Ocarina of Space, 7961, sewage-clogged pistol];
		break;
	case $class[Avatar of Jarlsberg]:
		poss = $items[Staff of the Standalone Cheese];
		break;
	case $class[Cow Puncher]:
		poss = $items[Seal-Clubbing Club, Gnollish Flyswatter, Club of Corruption, Remaindered Axe, Skeleton Bone, Corrupt Club of Corruption, Flaming Crutch, Homoerotic Frat-Paddle, Kneecapping Stick, Corrupt Club of Corrupt Corruption, Spiked Femur, Severed Flipper, Mannequin Leg, Infernal Toilet Brush, Hilarious Comedy Prop, Giant Foam Finger, Red Hot Poker, Maxwell\'s Silver Hammer, Elegant Nightstick, Oversized Pipe, Ghast Iron Cleaver, Frozen Seal Spine, Stainless Steel Shillelagh, Porcelain Police Baton, Lead Pipe, Meat Tenderizer Is Murder, Dented Scepter];
		break;
	case $class[Beanslinger]:
		poss = $items[Pasta Spoon, Cardboard Wakizashi, Dishrag, Corn Holder, Eggbeater, Oversized Pizza Cutter, Chopsticks, Thor\'s Pliers, Wrench];
		break;
	case $class[Snake Oiler]:
		poss = $items[Finger Cymbals, Double-Barreled Sling, Hilarious Comedy Prop, Space Tourist Phaser, Knife, Thor\'s Pliers, Frankly Mr. Shank];
		break;
	case $class[Gelatinous Noob]:
		poss = $items[Finger Cymbals, Double-Barreled Sling, Hilarious Comedy Prop, Space Tourist Phaser, Frigid Derringer, Thor\'s Pliers, Bass Clarinet, Frankly Mr. Shank];
		break;

	default:
		print("If you just started an ascension (Ed primarily) enter 'refresh all' and then restart", "red");
		abort("You don't have a valid class for this equipper, must be an avatar path or something.");
		break;
	}
	toEquip = handleSolveThing(poss, $slot[weapon]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[weapon])))
	{
		equip($slot[weapon], toEquip);
	}

	handleOffHand();
}

void equipBaselineFam()
{
	if(my_familiar() == $familiar[none])
	{
		return;
	}

	if(my_path() == "Heavy Rains")
	{
		if(item_amount($item[miniature life preserver]) > 0)
		{
			equip($slot[familiar], $item[miniature life preserver]);
			if(!is_familiar_equipment_locked() && boolean_modifier(equipped_item($slot[familiar]), "Generic"))
			{
				lock_familiar_equipment(true);
			}
		}
	}
	else
	{
		item toEquip = $item[none];

		boolean[item] poss = $items[Chocolate-stained Collar, Tiny Bowler, Guard Turtle Collar, Vicious Spiked Collar, Ant Hoe, Ant Pick, Ant Rake, Ant Pitchfork, Ant Sickle, Anniversary Tiny Latex Mask, Origami &quot;Gentlemen\'s&quot; Magazine, Tiny Fly Glasses, Annoying Pitchfork, Li\'l Businessman Kit, Lead Necklace, Flaming Familiar Doppelg&auml;nger, Wax Lips, Lucky Tam O\'Shanter, Lucky Tam O\'Shatner, Miniature Gravy-Covered Maypole, Kill Screen, Loathing Legion Helicopter, Little Box of Fireworks, Filthy Child Leash, Mayflower Bouquet, Plastic Pumpkin Bucket, Moveable Feast, Ittah Bittah Hookah, Snow Suit, Astral Pet Sweater, Muscle Band, Shell Bell, Smoke Ball, Razor Fang, Amulet Coin, Luck Incense];
		toEquip = handleSolveThing(poss, $slot[familiar]);

		if((toEquip != $item[none]) && (toEquip != equipped_item($slot[familiar])))
		{
			if(is_familiar_equipment_locked() && boolean_modifier(equipped_item($slot[familiar]), "Generic"))
			{
				lock_familiar_equipment(false);
			}
			equip($slot[familiar], toEquip);
		}
	}
	if(!is_familiar_equipment_locked() && boolean_modifier(equipped_item($slot[familiar]), "Generic"))
	{
		lock_familiar_equipment(true);
	}
}

void equipBaseline()
{
	equipBaselineHat();
	equipBaselineShirt();
	equipBaselineWeapon();
	equipBaselinePants();
	equipBaselineBack();
	equipBaselineAcc1();
	equipBaselineAcc2();
	equipBaselineAcc3();
	equipBaselineFam();
	equipBaselineHolster();

	if(my_daycount() == 1)
	{
		if(have_familiar($familiar[grimstone golem]))
		{
			if(get_property("_grimFairyTaleDropsCrown").to_int() >= 1)
			{
				handleBjornify($familiar[El Vibrato Megadrone]);
			}
		}
		else
		{
			handleBjornify($familiar[El Vibrato Megadrone]);
		}
	}
	if(my_daycount() == 2)
	{
		handleBjornify($familiar[El Vibrato Megadrone]);
	}

	if(get_property("cc_diceMode").to_boolean())
	{
		if(item_amount($item[Dice Ring]) > 0)
		{
			equip($slot[acc1], $item[Dice Ring]);
		}
		if(item_amount($item[Dice Belt Buckle]) > 0)
		{
			equip($slot[acc2], $item[Dice Belt Buckle]);
		}
		if(item_amount($item[Dice Sunglasses]) > 0)
		{
			equip($slot[acc3], $item[Dice Sunglasses]);
		}
		if(item_amount($item[Dice-Print Do-Rag]) > 0)
		{
			equip($slot[hat], $item[Dice-Print Do-Rag]);
		}
		if(item_amount($item[Dice-Shaped Backpack]) > 0)
		{
			equip($slot[back], $item[Dice-Shaped Backpack]);
		}
		if(item_amount($item[Dice-Print Pajama Pants]) > 0)
		{
			equip($slot[pants], $item[Dice-Print Pajama Pants]);
		}
		if((item_amount($item[Kill Screen]) > 0) && (my_familiar() != $familiar[none]))
		{
			equip($slot[familiar], $item[Kill Screen]);
		}
	}
}

void equipBaselineAccessories()
{
	item[int] poss = List($items[Jaunty Feather, Vampire Collar, Stuffed Shoulder Parrot, Infernal Insoles, Imp Unity Ring, Ring Of Telling Skeletons What To Do, Garish Pinky Ring, Batskin Belt, Bonerdagon Necklace, Grumpy Old Man Charrrm Bracelet, Jolly Roger Charrrm Bracelet, Glowing Red Eye, Jangly Bracelet, Plastic Detective Badge, Pirate Fledges, Glow-In-The-Dark Necklace, Compression Stocking, Wicker Kickers, Perfume-Soaked Bandana, Iron Beta of Industry, Mr. Accessory Jr., Time-Twitching Toolbelt, Xiblaxian Holo-Wrist-Puter, Badge Of Authority, Bronze Detective Badge, Ghost of a Necklace, Silver Detective Badge, Gold Detective Badge, Ring Of The Skeleton Lord, Sphygmayomanometer, Kremlin\'s Greatest Briefcase, Numberwang, Astral Mask, Astral Belt, Bram\'s Choker, Mr. Cheeng\'s Spectacles, Astral Ring, Astral Bracer, Hand In Glove, Codpiece, Gumshoes, Caveman Dan\'s Favorite Rock, Barrel Hoop Earring, Battle Broom, Your Cowboy Boots, Over-The-Shoulder Folder Holder, World\'s Best Adventurer Sash]);

	if((my_level() >= 13) && (get_property("flyeredML").to_int() >= 10000))
	{
		//Remove ML Stuff
	}

	//Remove things based on needs:
	//cc_beatenupcount (sp)
	//DO we want +item
	//World\'s Best Adventurer Sash value, sphygmayomanometer value
	//spectacles value

	if(my_class() == $class[Gelatinous Noob])
	{
		poss = poss.ListInsert($item[Mr. Screege\'s Spectacles]);
	}
	if(get_property("_kgbTranquilizerDartUses").to_int() >= 3)
	{
		poss = poss.ListRemove($item[Kremlin\'s Greatest Briefcase]);
	}



#	if(possessEquipment($item[Your Cowboy Boots]))
#	{
#		if(equipped_item($slot[bootspur]) == $item[Ticksilver Spurs])
#		{
#			poss = poss.ListInsertAt($item[Your Cowboy Boots], poss.ListFind($item[Grandfather Watch]));
#		}
#	}

#	if(possessEquipment($item[Over-the-shoulder Folder Holder]))
#	{
#		foreach sl in $slots[folder1, folder2, folder3, folder4, folder5]
#		{
#			if(equipped_item(sl) == $item[Folder (Sports Car)])
#			{
#			}
#		}
#	}

	int nextAcc = count(poss) - 1;
	foreach sl in $slots[acc1, acc2, acc3]
	{
		item toEquip = $item[none];

		while((toEquip == $item[none]) && (nextAcc >= 0))
		{
			if(possessEquipment(poss[nextAcc]) && can_equip(poss[nextAcc]))
			{
				toEquip = poss[nextAcc];
			}

			nextAcc--;
		}

		if(toEquip == $item[none])
		{
			break;
		}
		equip(sl, toEquip);
	}
}

void equipBaselineAcc1()
{
	item toEquip = $item[none];
	boolean[item] poss = $items[Vampire Collar, Infernal Insoles, Batskin Belt, Plastic Detective Badge, Bronze Detective Badge, Ghost of a Necklace, Silver Detective Badge, Gold Detective Badge, Ring Of The Skeleton Lord, Sphygmayomanometer, Kremlin\'s Greatest Briefcase, Numberwang, Astral Mask, Astral Belt, Bram\'s Choker, Astral Ring, Astral Bracer, Codpiece, Over-The-Shoulder Folder Holder];

	if(possessEquipment($item[barrel hoop earring]))
	{
		poss = $items[Vampire Collar, Infernal Insoles, Batskin Belt, Ghost of a Necklace, Sphygmayomanometer, Numberwang, Astral Mask, Astral Belt, Bram\'s Choker, Astral Ring, Astral Bracer, your cowboy boots, Over-The-Shoulder Folder Holder];
	}

	toEquip = handleSolveThing(poss, $slot[acc1]);

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[acc1])))
	{
		equip($slot[acc1], toEquip);
	}
}

void equipBaselineAcc2()
{
	item toEquip = $item[none];
	boolean[item] poss;
	if((my_level() >= 13) && (get_property("flyeredML").to_int() >= 10000))
	{
		poss = $items[Shiny Ring, Torquoise Ring, Jaunty Feather, Stuffed Shoulder Parrot, Genie\'s Bracers, Silent Nightlight, Time-Twitching Toolbelt, Glow-in-the-dark necklace, Glowing Red Eye, Bonerdagon Necklace, Batskin Belt, Jangly Bracelet, Pirate Fledges, Iron Beta of Industry, Your Cowboy Boots, Sphygmayomanometer, Barrel Hoop Earring, Codpiece, World\'s Best Adventurer Sash];
	}
	else
	{
		if(my_primestat() == $stat[muscle])
		{
			poss = $items[Shiny Ring, Torquoise Ring, Jaunty Feather, Vampire Collar, Stuffed Shoulder Parrot, Genie\'s Bracers, Silent Nightlight, imp unity ring, garish pinky ring, batskin belt, Jolly Roger Charrrm Bracelet, Glowing Red Eye, Jangly Bracelet, Pirate Fledges, glow-in-the-dark necklace, Compression Stocking, Wicker Kickers, Iron Beta of Industry, Sphygmayomanometer, perfume-soaked bandana, your cowboy boots, World\'s Best Adventurer Sash, Hand In Glove, barrel hoop earring, Gumshoes, Caveman Dan\'s Favorite Rock, Brutal Brogues, Battle Broom];
		}
		else
		{
			poss = $items[Shiny Ring, Torquoise Ring, Jaunty Feather, Vampire Collar, Stuffed Shoulder Parrot, Genie\'s Bracers, Silent Nightlight, imp unity ring, garish pinky ring, batskin belt, Jolly Roger Charrrm Bracelet, Glowing Red Eye, Jangly Bracelet, Pirate Fledges, glow-in-the-dark necklace, Compression Stocking, Wicker Kickers, Iron Beta of Industry, Sphygmayomanometer, perfume-soaked bandana, your cowboy boots, World\'s Best Adventurer Sash, Hand In Glove, barrel hoop earring, Gumshoes, Caveman Dan\'s Favorite Rock, Battle Broom];
		}
	}
	toEquip = handleSolveThing(poss, $slot[acc2]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[acc2])))
	{
		equip($slot[acc2], toEquip);
	}
}

void equipBaselineAcc3()
{
	item toEquip = $item[none];
	item[int] poss = List($items[Jaunty Feather, Garish Pinky Ring, ring of telling skeletons what to do, Glowing Red Eye, Blackberry Galoshes, Meteorthopedic Shoes, grumpy old man charrrm bracelet, Pirate Fledges, Plastic Detective Badge, Bronze Detective Badge, Mr. Accessory Jr., Silver Detective Badge, Gold Detective Badge, Ring Of The Skeleton Lord, Tube Sock, Time-Twitching Toolbelt, Glow-in-the-dark necklace, Xiblaxian Holo-Wrist-Puter, Sphygmayomanometer, LOV Earrings, Badge Of Authority, Codpiece, Mr. Cheeng\'s Spectacles, Numberwang, Barrel Hoop Earring]);

	if(my_class() == $class[Gelatinous Noob])
	{
		poss = poss.ListInsert($item[Mr. Screege\'s Spectacles]);
	}

	toEquip = handleSolveThing(poss, $slot[acc3]);

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[acc3])))
	{
		equip($slot[acc3], toEquip);
	}
}

void replaceBaselineAcc3()
{
	item toEquip = $item[none];
	boolean[item] poss = $items[Jaunty Feather, ring of telling skeletons what to do, Glowing Red Eye, grumpy old man charrrm bracelet, Pirate Fledges, Plastic Detective Badge, Bronze Detective Badge, Mr. Accessory Jr., Silver Detective Badge, Gold Detective Badge, Ring Of The Skeleton Lord, Glow-in-the-dark necklace, Xiblaxian Holo-Wrist-Puter, Sphygmayomanometer, Badge Of Authority, Codpiece, Mr. Cheeng\'s Spectacles, Numberwang, Barrel Hoop Earring];

	foreach thing in poss
	{
		if(possessEquipment(thing) && can_equip(thing) && (equipped_item($slot[acc1]) != thing) && (equipped_item($slot[acc2]) != thing) && (equipped_item($slot[acc3]) != thing))
		{
			toEquip = thing;
		}
	}

	if(toEquip == $item[none])
	{
		equip($slot[acc3], $item[none]);
	}
	else if((toEquip != $item[none]) && (toEquip != equipped_item($slot[acc3])))
	{
		equip($slot[acc3], toEquip);
	}
}

void equipBaselineHolster()
{
	if(my_path() != "Avatar of West of Loathing")
	{
		return;
	}

	item toEquip = $item[none];
	boolean[item] poss = $items[toy sixgun, rinky-dink sixgun, reliable sixgun, makeshift sixgun, custom sixgun, porquoise-handled sixgun, hamethyst-handled sixgun, baconstone-handled sixgun, Pecos Dave\'s sixgun];

	toEquip = handleSolveThing(poss, $slot[holster]);

	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[holster])))
	{
		equip($slot[holster], toEquip);
	}
}

void ensureSealClubs()
{
	set_property("cc_ignoreCombat", get_property("cc_ignoreCombat") + "(seal)");
	equipBaseline();
	set_property("cc_ignoreCombat", "");
}


void removeNonCombat()
{
	set_property("cc_ignoreCombat", get_property("cc_ignoreCombat") + "(noncombat)");
	equipBaseline();
	set_property("cc_ignoreCombat", "");
}

void removeCombat()
{
	set_property("cc_ignoreCombat", get_property("cc_ignoreCombat") + "(combat)");
	equipBaseline();
	set_property("cc_ignoreCombat", "");
}

void equipRollover()
{
	if(my_class() == $class[Gelatinous Noob])
	{
		return;
	}
	item toEquip = $item[none];
	item[int] poss = List($items[Genie\'s Turbane, Sea Cowboy Hat, Psychic\'s Circlet, Hairpiece on Fire, Spelunker\'s Fedora, Uncle Crimbo\'s Hat, Leather Aviator\'s Cap, Very Pointy Crown]);

	toEquip = handleSolveThing(poss, $slot[hat]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[hat])))
	{
		equip($slot[hat], toEquip);
	}

	toEquip = $item[none];
	poss = List($items[Time Bandit Time Towel, Auxiliary Backbone, Gabardine Gunnysack, Burning Cape, First Post Shirt - Cir Senam, Octolus-Skin Cloak]);

	toEquip = handleSolveThing(poss, $slot[back]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[back])))
	{
		equip($slot[back], toEquip);
	}


	if(hasTorso())
	{
		toEquip = $item[none];
		poss = List($items[General Sage\'s Lonely Diamonds Club Jacket, Makeshift Garbage Shirt, Glass Casserole Dish, Sneaky Pete\'s Leather Jacket, Sneaky Pete\'s Leather Jacket (Collar Popped)]);

		toEquip = handleSolveThing(poss, $slot[shirt]);
		if((toEquip != $item[none]) && (toEquip != equipped_item($slot[shirt])))
		{
			equip($slot[shirt], toEquip);
		}
	}

	toEquip = $item[none];
	poss = List($items[Deadfall Branch, Meatspout Staff, Chrome Staff, Chrome Sword, Sword Behind Inappropriate Prepositions, Time Sword, The Nuge\'s Favorite Crossbow, Staff Of Kitchen Royalty]);

	toEquip = handleSolveThing(poss, $slot[weapon]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[weapon])))
	{
		equip($slot[weapon], toEquip);
	}

	toEquip = $item[none];
	poss = List($items[Deadfall Branch, Ancient Calendar, Novelty Monorail Ticket, Mer-kin stopwatch, Astral Statuette, Silver Cow Creamer, Staff Of Kitchen Royalty, Royal Scepter]);
	switch(my_primestat())
	{
	case $stat[Muscle]:
		poss = ListInsertAt(poss, $item[red LavaCo Lamp&trade;], poss.ListFind($item[Royal Scepter]));
		break;
	case $stat[Mysticality]:
		poss = ListInsertAt(poss, $item[blue LavaCo Lamp&trade;], poss.ListFind($item[Royal Scepter]));
		break;
	case $stat[Moxie]:
		poss = ListInsertAt(poss, $item[green LavaCo Lamp&trade;], poss.ListFind($item[Royal Scepter]));
		break;
	}

	toEquip = handleSolveThing(poss, $slot[off-hand]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[off-hand])))
	{
		equip($slot[off-hand], toEquip);
	}

	toEquip = $item[none];
	poss = List($items[Genie\'s Pants, Paperclip Pants, Electronic Dulcimer Pants, Psychic\'s Pslacks, Vicar\'s Tutu, Ninjammies, Pantaloons of Hatred, Ratskin Pajama Pants]);

	toEquip = handleSolveThing(poss, $slot[pants]);
	if((toEquip != $item[none]) && (toEquip != equipped_item($slot[pants])))
	{
		equip($slot[pants], toEquip);
	}


	poss = List($items[Coarse Hemp Socks, Red Armband, Tiny Plastic Crimbo Reindeer, Tiny Plastic Bitchin\' Meatcar, Dead Guy\'s Watch, Gold Wedding Ring, Mafia Organizer Badge, Tiny Plastic Golden Gundam, Tiny Die-Cast Golden Ring, Gingerservo, BGE Pocket Calendar, Wristwatch of the White Knight, Imitation Nice Watch, Boots of Twilight Whispers, Aerogel Ascot, Official Council Aide Pin, Meteorthopedic Shoes, Grandfather Watch, Gingerbeard, Fudgecycle, Draftsman\'s Driving Gloves, Spacegate Scientist\'s Insignia, Numberwang, Ticksilver Ring, Sasq&trade; Watch, Counterclockwise Watch, Treads of Loathing]);
	if(possessEquipment($item[Your Cowboy Boots]))
	{
		if(equipped_item($slot[bootspur]) == $item[Ticksilver Spurs])
		{
			poss = poss.ListInsertAt($item[Your Cowboy Boots], poss.ListFind($item[Grandfather Watch]));
		}
	}
	if(possessEquipment($item[Kremlin\'s Greatest Briefcase]))
	{
		string mod = string_modifier($item[Kremlin\'s Greatest Briefcase], "Modifiers");
		if(contains_text(mod, "Adventures"))
		{
			poss = poss.ListInsertAt($item[Kremlin\'s Greatest Briefcase], poss.ListFind($item[Grandfather Watch]));
		}
	}
	if(possessEquipment($item[Over-the-shoulder Folder Holder]))
	{
		boolean adv = false;
		boolean pvp = false;
		foreach sl in $slots[folder1, folder2, folder3, folder4, folder5]
		{
			if(equipped_item(sl) == $item[Folder (Sports Car)])
			{
				adv = true;
			}
			if(equipped_item(sl) == $item[Folder (Sportsballs)])
			{
				pvp = true;
			}
			if(adv && pvp)
			{
				poss = poss.ListInsertAt($item[Over-The-Shoulder Folder Holder], poss.ListFind($item[Numberwang]));
			}
			else if(adv)
			{
				poss = poss.ListInsertAt($item[Over-The-Shoulder Folder Holder], poss.ListFind($item[Grandfather Watch]));
			}
			else if(pvp)
			{
				poss = poss.ListInsertAt($item[Over-The-Shoulder Folder Holder], poss.ListFind($item[Grandfather Watch]));
			}
		}
	}
	## How do we check watches? Gingerbeard/Uncle Hobo? at +6/+9?
	boolean foundWatch = false;
	Item[int] watches = List($items[Dead Guy\'s Watch, Imitation Nice Watch, Wristwatch of the White Knight, Grandfather Watch, Sasq&trade; Watch, Counterclockwise Watch]);
	for(int i=count(watches)-1; i>=0; i--)
	{
		if(foundWatch && possessEquipment(watches[i]))
		{
			poss = poss.ListRemove(watches[i]);
		}
		else if(possessEquipment(watches[i]))
		{
			foundWatch = true;
		}
	}

	int nextRollover = count(poss) - 1;
	foreach sl in $slots[acc1, acc2, acc3]
	{
		item toEquip = $item[none];

		while((toEquip == $item[none]) && (nextRollover >= 0))
		{
			if(possessEquipment(poss[nextRollover]) && can_equip(poss[nextRollover]))
			{
				toEquip = poss[nextRollover];
			}

			nextRollover--;
		}

		if(toEquip == $item[none])
		{
			break;
		}
		equip(sl, toEquip);
	}

	### Original end of rollover accessory code.

	if(have_familiar($familiar[Trick-or-Treating Tot]) && !possessEquipment($item[Li\'l Unicorn Costume]) && !is100FamiliarRun() && (my_meat() > (3000 + npc_price($item[Li\'l Unicorn Costume]))) && (cc_my_path() != "G-Lover") && (cc_my_path() != "Pocket Familiars"))
	{
		cli_execute("buy Li\'l Unicorn Costume");
	}

	if(have_familiar($familiar[Trick-or-Treating Tot]) && possessEquipment($item[Li\'l Unicorn Costume]) && !is100FamiliarRun($familiar[Trick-or-Treating Tot]) && (my_familiar() != $familiar[none]) && (cc_my_path() != "G-Lover"))
	{
		use_familiar($familiar[Trick-or-Treating Tot]);
		if(equipped_item($slot[Familiar]) != $item[Li\'l Unicorn Costume])
		{
			equip($slot[Familiar], $item[Li\'l Unicorn Costume]);
		}
	}
	else if(my_familiar() != $familiar[none])
	{
		toEquip = $item[none];
		poss = List($items[Solid Shifting Time Weirdness]);

		toEquip = handleSolveThing(poss, $slot[familiar]);
		if((toEquip != $item[none]) && (toEquip != equipped_item($slot[familiar])))
		{
			equip($slot[familiar], toEquip);
		}
	}
}
