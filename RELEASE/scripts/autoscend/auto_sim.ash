
void printSim()
{
	printSimRequired();
	printSimSuggested();
	printSimMarginal();
	print();
	print("Note: Recommended to run in aftercore to properly detect everything");
}

void PrintSimRequired()
{
	print("Required Things:");
	
	skill sk = $skill[Saucestorm];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Critical for autoscend combat");
	sk = $skill[Itchy Curse Finger];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Critical for autoscend combat");
	sk = $skill[Curse of Weaksauce];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Critical for autoscend combat");
	sk = $skill[Tongue of the Walrus];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Healing skill which cures beaten up");
	sk = $skill[Cannelloni Cocoon];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Heals up to 1000 HP for 20 MP. Very cost effective");
}

void printSimSuggested()
{
	print();
	print("Suggested Things:");

	skill sk = $skill[Transcendent Olfaction];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Significantly increases chance of encountering a monster");
	sk = $skill[Stuffed Mortar Shell];
	formattedSimPrint(have_skill(sk), sk.to_string(), "MP efficient and high damage");
	sk = $skill[Saucegeyser];
	formattedSimPrint(have_skill(sk), sk.to_string(), "High damage spell. Helpful for bosses");
	sk = $skill[Lock Picking];
	formattedSimPrint(have_skill(sk), sk.to_string(), "Out of standard easy key source");

	familiar fam = $familiar[Nosy Nose];
	formattedSimPrint(have_familiar(fam), fam.to_string(), "Familiar with olfaction-lite ability");
	fam = $familiar[Gelatinous Cubeling];
	formattedSimPrint(have_familiar(fam), fam.to_string(), "Familiar which speeds up the daily dungeon");

	boolean maxedPoolSkill = get_property("poolSharkCount").to_int() >= 25;
	formattedSimPrint(maxedPoolSkill, "Pool Shark", "Lucky! adv which permanently increases your pool skill. It is possible for Mafia to not realize you have maxed this. If you are confident you have, enter the following in the CLI: `set poolSharkCount=25`");

	// if we have combat locket, check if we have used monsters in there
	if(auto_haveCombatLoversLocket())
	{
		monster mon = $monster[Fantasy Bandit];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Fighting 5x in a day will get you a fat loot token");
		mon = $monster[screambat];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Lets you break a wall in the Bat Hole");
		mon = $monster[lobsterfrogman];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Need 5x for war sidequest");
		mon = $monster[Astronomer];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Helpful for star key");
		mon = $monster[Skinflute];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Helpful for star key");
		mon = $monster[Camel\'s Toe];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Helpful for star key");
		mon = $monster[War Frat Mobile Grill Unit];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Frat warrior war start outfit");
		mon = $monster[War Hippy Airborne Commander];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "War hippy war start outfit");
		mon = $monster[Baa\'baa\'bu\'ran];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "3x Stone Wool for L12 quest");
		mon = $monster[Green Ops Soldier];
		formattedSimPrint(auto_monsterInLocket(mon), `Locket Monster: {mon.to_string()}`, "Get war progress even when copied into other zones, plus smoke bombs");
	}

	// if we have cookbookbat, make sure we have all its recipes
	if(have_familiar($familiar[Cookbookbat]))
	{
		boolean[string] recipes = $strings[Boris's beer, honey bun of Boris, ratatouille de Jarlsberg, Jarlsberg's vegetable soup, Pete's wiley whey bar,
				St. Pete's sneaky smoothie, Boris's bread, roasted vegetable of Jarlsberg, Pete's rich ricotta, roasted vegetable focaccia, 
				plain calzone, baked veggie ricotta casserole];
		foreach recipe in recipes
		{
			boolean haveRecipe = !get_property(`unknownRecipe${recipe.to_item().to_int()}`).to_boolean();
			formattedSimPrint(haveRecipe, `Recipe: {recipe}`, "Cookbookbat recipes need to be learned, even if you have the familiar");
		}
	}

}

void printSimMarginal()
{
	print();
	print("Marginal Things:");

	familiar fam = $familiar[Oily Woim];
	formattedSimPrint(have_familiar(fam), fam.to_string(), "Familiar which provides init");
	fam = $familiar[Exotic Parrot];
	formattedSimPrint(have_familiar(fam), fam.to_string(), "Familiar which provides elemental resistance");
	fam = $familiar[Hobo Monkey];
	formattedSimPrint(have_familiar(fam), fam.to_string(), "Familiar that's a 1.25x leprechaun");

	item it = $item[Etched Hourglass];
	formattedSimPrint(item_amount(it) > 0, `Potential Pull: {it.to_string()}`, "Extra RO adventures");
	it = $item[Potato Alarm Clock];
	formattedSimPrint(item_amount(it) > 0, `Potential Pull: {it.to_string()}`, "Extra RO adventures");
	it = $item[Mafia Thumb Ring];
	formattedSimPrint(possessEquipment(it), `Potential Pull: {it.to_string()}`, "Accessory which generates an adv 4% of combats");
	it = $item[Numberwang];
	formattedSimPrint(possessEquipment(it), `Potential Pull: {it.to_string()}`, "Good all around accessory");
	it = $item[Deck of Lewd Playing Cards];
	formattedSimPrint(possessEquipment(it), `Potential Pull: {it.to_string()}`, "Sleaze dmg helps Belch House, Zeppelin Mob, and sometimes tower test");
	it = $item[Infinite BACON Machine];
	formattedSimPrint(item_amount(it) > 0, `Potential Pull: {it.to_string()}`, "Might make milk for big stats. Poor, for modern standards, yellow ray source");
	it = $item[Mime Army Shotglass];
	formattedSimPrint(item_amount(it) > 0, `Potential Pull: {it.to_string()}`, "Only pulled for Dark Gyffte as every organ space is really good");
}

void formattedSimPrint(boolean have, string name, string description)
{
	string symbol = have ? "✓" : "X";
	print(`{symbol} {name} - {description}`, have ? "blue" : "red");
}
