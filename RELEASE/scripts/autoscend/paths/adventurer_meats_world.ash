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
		case $skill[[33023]Bacon Ray]:
			return 1;
		case $skill[[33001]Beef Shank]:
		case $skill[[33012]Spicy Meatball]:
			return 2;
		case $skill[[33002]Meat Cleaver]:
		case $skill[[33014]Chew the Fat]:
			return 5;
		case $skill[[33025]Wet Rub]:
		case $skill[[33024]Meat Locker]:
			return 8;
		case $skill[[33003]Steak Through the Heart]:
			return 10;
		case $skill[[33013]Meat Cute]:
			return 20;
		default:
			return 0;
	}
}