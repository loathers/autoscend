// Functions designed for general utility in any path

boolean auto_buySkills()  // This handles skill acquisition for general paths
{
	// TODO: Torso Awareness is worth obtaining in other cases too.
	//we need 5000 meat for the skill. and want to save an additional 1000 meat above meat reserve since torso awareness is somewhat low priority
	if((my_meat() >= meatReserve() + 6000)
	   && gnomads_available()
	   && (!have_skill($skill[Torso Awareness]))
	   && (item_amount($item[January\'s Garbage Tote]) != 0)
	   && (is_unrestricted($item[January\'s Garbage Tote])))
	{
		visit_url("gnomes.php?action=trainskill&whichskill=12");
	}
	if(!guild_store_available())
	{
		return false;
	}
	switch(my_class())
	{
	case $class[Seal Clubber]:
		if((my_level() >= 1) && (my_meat() >= 800) && (!have_skill($skill[Lunge Smack])))
		{
			visit_url("guild.php?action=buyskill&skillid=4", true);
		}
		if((my_level() >= 1) && (my_meat() >= 1500) && (!have_skill($skill[Fortitude Of The Muskox])))
		{
			visit_url("guild.php?action=buyskill&skillid=8", true);
		}
		if((my_level() >= 3) && (my_meat() >= 2500) && (!have_skill($skill[Cold Shoulder])))
		{
			visit_url("guild.php?action=buyskill&skillid=28", true);
		}
		if((my_level() >= 4) && (my_meat() >= 4500) && (!have_skill($skill[Wrath of the Wolverine])))
		{
			visit_url("guild.php?action=buyskill&skillid=29", true);
		}
		if((my_level() >= 10) && (my_meat() >= 12000) && (!have_skill($skill[Ire of the Orca])))
		{
			visit_url("guild.php?action=buyskill&skillid=35", true);
		}
		if((my_level() >= 11) && (my_meat() >= 12000) && (!have_skill($skill[Batter Up!])))
		{
			visit_url("guild.php?action=buyskill&skillid=14", true);
		}
		break;
	case $class[Turtle Tamer]:
		if((my_level() >= 3) && (my_meat() >= 1000) && (!have_skill($skill[Amphibian Sympathy])))
		{
			visit_url("guild.php?action=buyskill&skillid=14", true);
		}
		if((my_level() >= 2) && (my_meat() >= 5000) && (!have_skill($skill[Skin of the Leatherback])))
		{
			visit_url("guild.php?action=buyskill&skillid=4", true);
		}
		if((my_level() >= 2) && (my_meat() >= 1250) && (!have_skill($skill[Headbutt])))
		{
			visit_url("guild.php?action=buyskill&skillid=3", true);
		}
		if((my_level() >= 2) && (my_meat() >= 800) && (!have_skill($skill[Blessing of the War Snapper])))
		{
			visit_url("guild.php?action=buyskill&skillid=30", true);
		}
		if((my_level() >= 8) && (my_meat() >= 3500) && (!have_skill($skill[Empathy of the Newt])))
		{
			visit_url("guild.php?action=buyskill&skillid=9", true);
		}
		if((my_level() >= 9) && (my_meat() >= 12000) && (!have_skill($skill[Spiky Shell])))
		{
			visit_url("guild.php?action=buyskill&skillid=31", true);
		}
		if((my_level() >= 11) && (my_meat() >= 9000) && (!have_skill($skill[Shieldbutt])))
		{
			visit_url("guild.php?action=buyskill&skillid=5", true);
		}
		if((my_level() >= 11) && (my_meat() >= 9000) && (!have_skill($skill[Butts of Steel])))
		{
			visit_url("guild.php?action=buyskill&skillid=34", true);
		}
		if((my_level() >= 7) && (my_meat() >= 13000) && (!have_skill($skill[Kneebutt])))
		{
			visit_url("guild.php?action=buyskill&skillid=15", true);
		}
		if((my_level() >= 5) && (my_meat() >= 11000) && (!have_skill($skill[Shell Up])))
		{
			visit_url("guild.php?action=buyskill&skillid=28", true);
		}
		if((my_level() >= 11) && (my_meat() >= 17000) && (!have_skill($skill[Blessing of the Storm Tortoise])))
		{
			visit_url("guild.php?action=buyskill&skillid=37", true);
		}
		if((my_level() >= 6) && (my_meat() >= 17400) && (!have_skill($skill[Spirit Snap])))
		{
			visit_url("guild.php?action=buyskill&skillid=32", true);
		}
		break;
	case $class[Pastamancer]:
		if((my_level() >= 1) && (my_meat() >= 500) && !have_skill($skill[Utensil Twist]))
		{
			visit_url("guild.php?action=buyskill&skillid=25", true);
		}
		if((my_level() >= 2) && (my_meat() >= 1000) && !have_skill($skill[Entangling Noodles]))
		{
			visit_url("guild.php?action=buyskill&skillid=4", true);
		}
		if((my_level() >= 5) && (my_meat() >= 4000) && !have_skill($skill[Pastamastery]))
		{
			visit_url("guild.php?action=buyskill&skillid=6", true);
		}
		if((my_level() >= 9) && (my_meat() >= 12500) && !have_skill($skill[Spirit of Ravioli]))
		{
			visit_url("guild.php?action=buyskill&skillid=14", true);
		}
		if((my_level() >= 11) && (my_meat() >= 15000) && !have_skill($skill[Leash Of Linguini]))
		{
			visit_url("guild.php?action=buyskill&skillid=10", true);
		}
		if((my_level() >= 12) && (my_meat() >= 25000) && !have_skill($skill[Cannelloni Cocoon]))
		{
			visit_url("guild.php?action=buyskill&skillid=12", true);
		}
		break;
	case $class[Sauceror]:
		if((my_level() >= 1) && (my_meat() >= 1250) && !have_skill($skill[Simmer]) && in_community())
		{
			visit_url("guild.php?action=buyskill&skillid=25", true);
		}
		if((my_level() >= 3) && (my_meat() >= 1000) && !have_skill($skill[Expert Panhandling]))
		{
			visit_url("guild.php?action=buyskill&skillid=4", true);
		}
		if((my_level() >= 4) && (my_meat() >= 3000) && !have_skill($skill[Elemental Saucesphere]))
		{
			visit_url("guild.php?action=buyskill&skillid=7", true);
		}
		if((my_level() >= 4) && (my_meat() >= 1000) && !have_skill($skill[Inner Sauce]))
		{
			visit_url("guild.php?action=buyskill&skillid=28", true);
		}
		if((my_level() >= 5) && (my_meat() >= 5000) && !have_skill($skill[Advanced Saucecrafting]))
		{
			visit_url("guild.php?action=buyskill&skillid=6", true);
		}
		if((my_level() >= 5) && (my_meat() >= 4000) && !have_skill($skill[Saucestorm]))
		{
			visit_url("guild.php?action=buyskill&skillid=5", true);
		}
		if((my_level() >= 6) && (my_meat() >= 2500) && !have_skill($skill[Soul Saucery]))
		{
			visit_url("guild.php?action=buyskill&skillid=27", true);
		}
		if((my_level() >= 8) && (my_meat() >= 12000) && !have_skill($skill[Itchy Curse Finger]))
		{
			visit_url("guild.php?action=buyskill&skillid=30", true);
		}
		if((my_level() >= 11) && (my_meat() >= 20000) && !have_skill($skill[Saucemaven]))
		{
			visit_url("guild.php?action=buyskill&skillid=39", true);
		}
		if((my_level() >= 12) && (my_meat() >= 20000) && !have_skill($skill[Curse of Weaksauce]))
		{
			visit_url("guild.php?action=buyskill&skillid=34", true);
		}
		break;
	case $class[Disco Bandit]:
		if((my_level() >= 2) && (my_meat() >= 2100) && !have_skill($skill[Overdeveloped Sense of Self Preservation]))
		{
			visit_url("guild.php?action=buyskill&skillid=10", true);
		}
		if((my_level() >= 5) && (my_meat() >= 2500) && !have_skill($skill[Advanced Cocktailcrafting]))
		{
			visit_url("guild.php?action=buyskill&skillid=14", true);
		}
		if((my_level() >= 6) && (my_meat() >= 2500) && !have_skill($skill[Nimble Fingers]))
		{
			visit_url("guild.php?action=buyskill&skillid=4", true);
		}
		if((my_level() >= 8) && (my_meat() >= 7500) && !have_skill($skill[Mad Looting Skillz]))
		{
			visit_url("guild.php?action=buyskill&skillid=6", true);
		}
		break;
	case $class[Accordion Thief]:
		if((my_level() >= 1) && (my_meat() >= 400) && !have_skill($skill[The Moxious Madrigal]))
		{
			visit_url("guild.php?action=buyskill&skillid=4", true);
		}
		if((my_level() >= 2) && (my_meat() >= 1250) && !have_skill($skill[The Magical Mojomuscular Melody]))
		{
			visit_url("guild.php?action=buyskill&skillid=7", true);
		}
		if((my_level() >= 4) && (my_meat() >= 3500) && !have_skill($skill[The Power Ballad of the Arrowsmith]))
		{
			visit_url("guild.php?action=buyskill&skillid=8", true);
		}
		if((my_level() >= 5) && (my_meat() >= 2000) && !have_skill($skill[The Polka of Plenty]))
		{
			visit_url("guild.php?action=buyskill&skillid=6", true);
		}
		if((my_level() >= 7) && (my_meat() >= 7500) && !have_skill($skill[Fat Leon\'s Phat Loot Lyric]))
		{
			visit_url("guild.php?action=buyskill&skillid=10", true);
		}
		if((my_level() >= 7) && (my_meat() >= 25000) && !have_skill($skill[Five Finger Discount]))
		{
			visit_url("guild.php?action=buyskill&skillid=35", true);
		}
		if((my_level() >= 10) && (my_meat() >= 12500) && !have_skill($skill[Thief Among the Honorable]))
		{
			visit_url("guild.php?action=buyskill&skillid=38", true);
		}
		if((my_level() >= 11) && (my_meat() >= 20000) && !have_skill($skill[Sticky Fingers]))
		{
			visit_url("guild.php?action=buyskill&skillid=39", true);
		}
		if((my_level() >= 12) && (my_meat() >= 25000) && !have_skill($skill[The Ode to Booze]))
		{
			visit_url("guild.php?action=buyskill&skillid=14", true);
		}
		if((my_level() >= 13) && (my_meat() >= 30000) && !have_skill($skill[The Sonata of Sneakiness]))
		{
			visit_url("guild.php?action=buyskill&skillid=15", true);
		}
		if((my_level() >= 13) && (my_meat() >= 30000) && !have_skill($skill[Master Accordion Master Thief]))
		{
			visit_url("guild.php?action=buyskill&skillid=41", true);
		}
		break;
	}
	return false;
}

void pathDroppedCheck()
{
	//detect path drops and reinitialize with settings appropriate for the new path
	//this will also trigger when standard path changes to none after ronin is broken
	if(my_path() == get_property("auto_doneInitializePath"))
	{
		return;		//our current path is the same one we last initialized as
	}
	if(get_property("auto_doneInitializePath") == "")
	{
		//this setting has not been set. this means the run started with an older version of autoscend that did not have this setting
		//a path of none would have returned "None" not "". This is only backwards support and can be deleted in the future.
		return;
	}
	print("Path change detected. You were previously " +get_property("auto_doneInitializePath")+ " and are now a " +my_path(), "red");
	set_property("_auto_reinitialize", true);
	initializeSettings();
}
