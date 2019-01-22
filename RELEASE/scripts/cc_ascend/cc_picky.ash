script "picky.ash"
# Code here is supplementary handlers and specialized handlers

void picky_initializeSettings()
{
	if(my_path() == "Picky")
	{
		set_property("cc_getStarKey", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_nunsTrick", false);
		set_property("cc_wandOfNagamar", true);
	}
}

void picky_pulls()
{
	if(my_path() == "Picky")
	{
		if(my_daycount() == 3)
		{
			#pullXWhenHaveY($item[Wand of Nagamar], 1, 0);		//Pull made obsolete by Questificaton
			#pullXWhenHaveY($item[Star Key Lime Pie], 3, 0);
			pullXWhenHaveY($item[Cold Hi Mein], 3, 0);
		}

	}
}

void picky_startAscension()
{
	print("In Being Picky Adventure", "blue");
	if((my_class() == $class[Turtle Tamer]) || (my_class() == $class[Seal Clubber]))
	{
		print("Selecting skills", "blue");
		string page = visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=188", true);
		if(contains_text(page, "<option value=\"165\""))
		{
			visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=165", true);
		}
		else
		{
			visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=140", true);
		}
#		if(!have_familiar($familiar[Angry Jung Man]))
#		{
#			visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=140", true);
#		}
#		else
#		{
#			visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=165", true);
#		}
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=178", true);

		# Olfaction, Torso
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=19", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=12", true);

		# Pulverize, Astral Shell, Hero of the Half Shell, Cannelloni Cocoon
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=1016", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=2012", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=2020", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=3012", true);

		# Elemental Saucesphere, Mad Looting Skillz, Smooth Movement
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=4007", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=5006", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=5017", true);

		# Fat Leon's Phat Loot Lyric, The Sonata of Sneakiness
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=6010", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=6015", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=3&submit=I Am Done Picking", true);
	}
}

boolean picky_buyskills()
{
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
		if((my_level() >= 1) && (my_meat() >= 1250) && !have_skill($skill[Simmer]) && (cc_my_path() == "Community Service"))
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
