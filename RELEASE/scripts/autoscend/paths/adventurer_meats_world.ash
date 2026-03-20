//TODO: double check pickpocketing works
boolean in_amw()
{
	return my_path() == $path[Adventurer Meats World];
}

boolean amw_initializeSettings()
{
	set_property("auto_wandOfNagamar", false);
	return false;
}

int amw_meatCost(skill sk) //as of now just combat
{
	switch(sk)
	{
		case $skill[Bacon Ray]:
			return 1;
		case $skill[Beef Shank]:
		case $skill[Spicy Meatball]:
			return 2;
		case $skill[Meat Cleaver]:
		case $skill[Chew the Fat]:
			return 5;
		case $skill[Wet Rub]:
		case $skill[Meat Locker]:
			return 8;
		case $skill[Steak Through the Heart]:
			return 10;
		case $skill[Meat Cute]:
			return 20;
		default:
			return 0;
	}
}

boolean amw_buySubstat(stat st, int numberToBuy)
// buys substats, whether st is a stat or a substat
{
	if (numberToBuy > my_meat()){return false;}

	// setting which substat to buy
	int option = 0;
	if (st == $stat[muscle] || st == $stat[submuscle]){
		option = 1;
	}
	if (st == $stat[mysticality] || st == $stat[submysticality]){
		option = 2;
	}
	if (st == $stat[moxie] || st == $stat[submuscle]){
		option = 3;
	}

	if (option != 0){
		string url = `choice.php?whichchoice=1592&pwd&option={to_string(option)}&num={to_string(numberToBuy)}`;
		visit_url(url, true);
		return true;
	}
	return false;
}

// attempt to buy the cheapest bundle of advs
boolean amw_buyAdv()
{
	// not sure how to tell if we can afford adventures yet, so attempting even if we can't afford
	int starting_meat = my_meat();
	string url = `choice.php?whichchoice=1593&pwd&option=1`;
	visit_url(url, true);

	// successful if meat was spent
	if (my_meat() < starting_meat){return true;}
	return false;
}