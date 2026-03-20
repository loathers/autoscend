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