script "cc_fallout.ash"

void fallout_initializeSettings()
{
	if(my_path() == "Nuclear Autumn")
	{
		set_property("cc_cubeItems", false);
		set_property("cc_getBeehive", true);
		set_property("cc_getStarKey", true);
		set_property("cc_grimstoneOrnateDowsingRod", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_useCubeling", true);
		set_property("cc_wandOfNagamar", true);

		if(item_amount($item[Deck of Every Card]) > 0)
		{
			set_property("cc_useCubeling", false);
		}
	}
}


void fallout_initializeDay(int day)
{
	if(my_path() != "Nuclear Autumn")
	{
		return;
	}

	if(!get_property("falloutShelterChronoUsed").to_boolean() && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		string temp = visit_url("place.php?whichplace=falloutshelter&action=vault5");
	}

	if(!get_property("falloutShelterCoolingTankUsed").to_boolean() && (get_property("falloutShelterLevel").to_int() >= 8))
	{

	}

	if((my_daycount() % 2) == 1)
	{
		cc_sourceTerminalRequest("enquiry stats.enq");
	}
	else
	{
		cc_sourceTerminalRequest("enquiry familiar.enq");
	}

	if(day == 1)
	{
		if(get_property("cc_day1_init") != "finished")
		{
			#set_property("cc_day1_init", "finished");
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("cc_day2_init") == "")
		{

			if(get_property("cc_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				acquireHermitItem($item[Seal Tooth]);
			}
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);

			#set_property("cc_day2_init", "finished");
		}
	}
	else if(day == 3)
	{
		if(get_property("cc_day3_init") == "")
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("cc_day3_init", "finished");
		}
	}
	else if(day == 4)
	{
		if(get_property("cc_day4_init") == "")
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("cc_day4_init", "finished");
		}
	}
}

boolean fallout_buySkills()
{
	if(my_path() != "Nuclear Autumn")
	{
		return false;
	}

	if(item_amount($item[Rad]) < 30)
	{
		return false;
	}

	if(have_skill($skill[Internal Soda Machine]))
	{
		return false;
	}

	int toBuy = 0;

/*
22012 Boiling Tear Ducts  doublewater.gif 5   10  0				30		Hot Damage
22013 Throat Refrigerant  snowflake.gif   5   10  0				30		Cold Damage
22014 Skunk Glands    stench.gif  5   10  0						30		Stench Damage
22015 Translucent Skin    glass.gif   5   10  0					30		Spooky Damage
22016 Projectile Salivary Glands  raindrop.gif    5   10  0		30		Combat Damage?
22017 Mind Bullets    sixshooter.gif  5   15  0					60		Stunner
22019 Metallic Skin   pittedmetal.gif 0   0   0					90		+2 all res
22020 Adipose Polymers    glueglob.gif    0   0   0				90		+100 DA, +10 DR
22021 Extra Muscles   strboost.gif    0   0   0					90		Muscle +50%
22022 Extra Brain birdbrain.gif   0   0   0						90		Myst +50%
22023 Hypno-Eyes  spiral.gif  0   0   0							90		Moxie +50%
22027 Flappy Ears spiral.gif  3   30  10						60		30 MP: 10 adv of Ear Winds: +2 all res
22028 Magic Sweat sebashield.gif  3   30  10					60		30 MP: 10 adv of Hardened Sweatshirt: +100 DA, +10 DR
22029 Steroid Bladder eggsac.gif  3   30  10					60		30 MP: 10 adv of Juiced and Loose: +50% Muscle
22030 Intracranial Eye    eyeball.gif 3   30  10				60		30 MP: 10 adv of Mind Vision: +50% Myst
22031 Self-Combing Hair   toupee.gif  3   30  10				60		30 MP: 10 adv of Impeccable Coiffure: +50% Moxie
22037 Extra Gall Bladder  bladder.gif 0   0   0					60		Food +100% adventures
22038 Extra Kidney    kidney.gif  0   0   0						60		Booze +100% adventuree
22039 Internal Soda Machine   cloaca.gif  2   0   0				30		20 Meat -> 10 MP

22024 Backwards Knees knee.gif 0 0 0 							120		Passive +20 init
22025 Sucker Fingers plunger.gif 0 0 0							120		Passive +15 item
22032 Bone Springs spring.gif 3 30 10 							90		Noncombat (30): 10 adv of Bone Springs: +20 Init
22033 Magnetic Ears ears.gif 3 10 20 							90		Noncombat (10): 20 adv of Magnetized Ears: +15 Item
22034 Firefly Abdomen bulb.gif 3 30 10 							90		Noncombat (30): 10 adv of Blinking Belly: +10/15 C
22035 Squid Glands inkwell.gif 3 30 10 							90		Noncombat (30): 10 adv of Inked Well: +10/15 NC
22036 Extremely Punchable Face wink.gif 3 30 10 				90		Noncombat (30): 10 adv pf Punchable Face: +30 ML

Missing: 858, 866
*/
	if(!have_skill($skill[Extra Gall Bladder]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 877;
		}
	}
	else if(!have_skill($skill[Extra Kidney]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 878;
		}
	}
	else if(!have_skill($skill[Extra Muscles]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 861;
		}
	}
	else if(!have_skill($skill[Magnetic Ears]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 873;
		}
	}
	else if(!have_skill($skill[Hypno-Eyes]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 863;
		}
	}
	else if(!have_skill($skill[Metallic Skin]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 859;
		}
	}
	else if(!have_skill($skill[Adipose Polymers]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 860;
		}
	}
	else if(!have_skill($skill[Sucker Fingers]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 120)
		{
			toBuy = 865;
		}
	}
	else if(!have_skill($skill[Squid Glands]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 120)
		{
			toBuy = 875;
		}
	}
	else if(!have_skill($skill[Steroid Bladder]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 869;
		}
	}
	else if(!have_skill($skill[Self-Combing Hair]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 871;
		}
	}
	else if(!have_skill($skill[Flappy Ears]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 867;
		}
	}
	else if(!have_skill($skill[Magic Sweat]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 868;
		}
	}
	else if(!have_skill($skill[Mind Bullets]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 857;
		}
	}
	else if(!have_skill($skill[Extra Brain]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 862;
		}
	}
	else if(!have_skill($skill[Intracranial Eye]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 60)
		{
			toBuy = 870;
		}
	}
	else if(!have_skill($skill[Boiling Tear Ducts]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 30)
		{
			toBuy = 852;
		}
	}
	else if(!have_skill($skill[Throat Refrigerant]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 30)
		{
			toBuy = 853;
		}
	}
	else if(!have_skill($skill[Extremely Punchable Face]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 876;
		}
	}
	else if(!have_skill($skill[Firefly Abdomen]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 874;
		}
	}
	else if(!have_skill($skill[Backwards Knees]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 120)
		{
			toBuy = 864;
		}
	}
	else if(!have_skill($skill[Bone Springs]) && (toBuy == 0) && (get_property("falloutShelterLevel").to_int() >= 6))
	{
		if(item_amount($item[Rad]) >= 90)
		{
			toBuy = 872;
		}
	}
	else if(!have_skill($skill[Skunk Glands]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 30)
		{
			toBuy = 854;
		}
	}
	else if(!have_skill($skill[Translucent Skin]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 30)
		{
			toBuy = 855;
		}
	}
	else if(!have_skill($skill[Projectile Salivary Glands]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 30)
		{
			toBuy = 856;
		}
	}
	else if(!have_skill($skill[Internal Soda Machine]) && (toBuy == 0))
	{
		if(item_amount($item[Rad]) >= 30)
		{
			toBuy = 879;
		}
	}

	if(toBuy != 0)
	{
		string page = visit_url("shop.php?whichshop=mutate");
		page = visit_url("shop.php?whichshop=mutate&action=buyitem&quantity=1&pwd=&whichrow=" + toBuy);
	}
	return true;
}


boolean LM_fallout()
{
	if(my_path() != "Nuclear Autumn")
	{
		return false;
	}

	fallout_buySkills();

	return false;
}
