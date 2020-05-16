script "autoscend.ash";
since r20103; // Low Key Summer Keys
/***
	autoscend_header.ash must be first import
	All non-accessory scripts must be imported here

	Accessory scripts can import autoscend.ash

***/


import <autoscend/autoscend_header.ash>
import <autoscend/autoscend_migration.ash>
import <canadv.ash>

import <autoscend/auto_adventure.ash>
import <autoscend/auto_casual.ash>
import <autoscend/auto_combat.ash>
import <autoscend/auto_cooking.ash>
import <autoscend/auto_deprecation.ash>
import <autoscend/auto_equipment.ash>
import <autoscend/auto_list.ash>
import <autoscend/auto_monsterparts.ash>
import <autoscend/auto_restore.ash>
import <autoscend/auto_util.ash>
import <autoscend/auto_zlib.ash>
import <autoscend/auto_zone.ash>

import <autoscend/iotms/clan.ash>
import <autoscend/iotms/elementalPlanes.ash>
import <autoscend/iotms/eudora.ash>
import <autoscend/iotms/floristfriar.ash>
import <autoscend/iotms/mr2012.ash>
import <autoscend/iotms/mr2013.ash>
import <autoscend/iotms/mr2014.ash>
import <autoscend/iotms/mr2015.ash>
import <autoscend/iotms/mr2016.ash>
import <autoscend/iotms/mr2017.ash>
import <autoscend/iotms/mr2018.ash>
import <autoscend/iotms/mr2019.ash>
import <autoscend/iotms/mr2020.ash>

import <autoscend/paths/actually_ed_the_undying.ash>
import <autoscend/paths/avatar_of_boris.ash>
import <autoscend/paths/avatar_of_sneaky_pete.ash>
import <autoscend/paths/avatar_of_west_of_loathing.ash>
import <autoscend/paths/community_service.ash>
import <autoscend/paths/dark_gyffte.ash>
import <autoscend/paths/disguises_delimit.ash>
import <autoscend/paths/g_lover.ash>
import <autoscend/paths/gelatinous_noob.ash>
import <autoscend/paths/heavy_rains.ash>
import <autoscend/paths/kingdom_of_exploathing.ash>
import <autoscend/paths/license_to_adventure.ash>
import <autoscend/paths/live_ascend_repeat.ash>
import <autoscend/paths/nuclear_autumn.ash>
import <autoscend/paths/one_crazy_random_summer.ash>
import <autoscend/paths/path_of_the_plumber.ash>
import <autoscend/paths/picky.ash>
import <autoscend/paths/pocket_familiars.ash>
import <autoscend/paths/standard.ash>
import <autoscend/paths/the_source.ash>
import <autoscend/paths/two_crazy_random_summer.ash>
import <autoscend/paths/low_key_summer.ash>

import <autoscend/quests/level_2.ash>
import <autoscend/quests/level_3.ash>
import <autoscend/quests/level_4.ash>
import <autoscend/quests/level_5.ash>
import <autoscend/quests/level_6.ash>
import <autoscend/quests/level_7.ash>
import <autoscend/quests/level_8.ash>
import <autoscend/quests/level_9.ash>
import <autoscend/quests/level_10.ash>
import <autoscend/quests/level_11.ash>
import <autoscend/quests/level_12.ash>
import <autoscend/quests/level_13.ash>
import <autoscend/quests/level_any.ash>
import <autoscend/quests/optional.ash>

void initializeSettings()
{
	if(my_ascensions() <= get_property("auto_doneInitialize").to_int())
	{
		return;
	}
	set_location($location[none]);
	invalidateRestoreOptionCache();

	set_property("auto_useCubeling", true);
	set_property("auto_100familiar", $familiar[none]);
	if(my_familiar() != $familiar[none])
	{
		boolean userAnswer = user_confirm("Familiar already set, is this a 100% familiar run? Will default to 'No' in 15 seconds.", 15000, false);
		if(userAnswer)
		{
			set_property("auto_100familiar", my_familiar());
		}
		if(!canChangeFamiliar())
		{
			set_property("auto_useCubeling", false);
		}
	}

	if(canChangeToFamiliar($familiar[Crimbo Shrub]))
	{
		use_familiar($familiar[Crimbo Shrub]);
		use_familiar($familiar[none]);
	}

	string pool = visit_url("questlog.php?which=3");
	matcher my_pool = create_matcher("a skill level of (\\d+) at shooting pool", pool);
	if(my_pool.find() && (my_turncount() == 0))
	{
		int curSkill = to_int(my_pool.group(1));
		int sharkCountMin = ceil((curSkill * curSkill) / 4);
		int sharkCountMax = ceil((curSkill + 1) * (curSkill + 1) / 4);
		if(get_property("poolSharkCount").to_int() < sharkCountMin || get_property("poolSharkCount").to_int() >= sharkCountMax)
		{
			auto_log_warning("poolSharkCount set to incorrect value.", "red");
			auto_log_info("You can \"set poolSharkCount="+sharkCountMin+"\" to use the least optimistic value consistent with your pool skill.", "blue");
		}
	}

	set_property("auto_abooclover", true);
	set_property("auto_aboopending", 0);
	set_property("auto_aftercore", false);
	set_property("auto_banishes", "");
	set_property("auto_batoomerangDay", 0);
	set_property("auto_beatenUpCount", 0);
	set_property("auto_getBeehive", false);
	set_property("auto_breakstone", get_property("auto_pvpEnable").to_boolean());
	set_property("auto_bruteForcePalindome", false);
	set_property("auto_cabinetsencountered", 0);
	set_property("auto_chasmBusted", true);
	set_property("auto_chewed", "");
	set_property("auto_clanstuff", "0");
	set_property("auto_combatHandler", "");
	set_property("auto_cookie", -1);
	set_property("auto_copies", "");
	set_property("auto_crackpotjar", "");
	set_property("auto_cubeItems", true);
	set_property("auto_dakotaFanning", false);
	set_property("auto_day_init", 0);
	set_property("auto_day1_dna", "");
	set_property("auto_debuffAsdonDelay", 0);
	set_property("auto_disableAdventureHandling", false);
	set_property("auto_doCombatCopy", "no");
	set_property("auto_drunken", "");
	set_property("auto_eaten", "");
	set_property("auto_familiarChoice", $familiar[none]);
	set_property("auto_forceTavern", false);
	set_property("auto_funTracker", "");
	set_property("auto_getBoningKnife", false);
	set_property("auto_getStarKey", true);
	set_property("auto_getSteelOrgan", get_property("auto_alwaysGetSteelOrgan").to_boolean());
	set_property("auto_gnasirUnlocked", false);
	set_property("auto_grimstoneFancyOilPainting", true);
	set_property("auto_grimstoneOrnateDowsingRod", true);
	set_property("auto_haveoven", false);
	set_property("auto_haveSourceTerminal", false);
	set_property("auto_hedge", "fast");
	set_property("auto_hippyInstead", false);
	set_property("auto_holeinthesky", true);
	set_property("auto_ignoreCombat", "");
	set_property("auto_ignoreFlyer", false);
	set_property("auto_instakill", "");
	set_property("auto_modernzmobiecount", "");
	set_property("auto_otherstuff", "");
	set_property("auto_paranoia", -1);
	set_property("auto_paranoia_counter", 0);
	set_property("auto_priorCharpaneMode", "0");
	set_property("auto_powerLevelLastLevel", "0");
	set_property("auto_powerLevelAdvCount", "0");
	set_property("auto_powerLevelLastAttempted", "0");
	set_property("auto_pulls", "");

	 // Day on which the Shen quest was started. Required to predict which zones to avoid until Shen tells us to go there.
	set_property("auto_shenStarted", "");
	// Last level during which we ran out of stuff to do without pre-completing some Shen quests.
	set_property("auto_shenSkipLastLevel", 0); 

	set_property("auto_skipDesert", 0);
	set_property("auto_snapshot", "");
	set_property("auto_sniffs", "");
	set_property("auto_waitingArrowAlcove", "50");
	set_property("auto_wandOfNagamar", true);
	set_property("auto_wineracksencountered", 0);
	set_property("auto_wishes", "");
	set_property("auto_writingDeskSummon", false);
	set_property("auto_yellowRays", "");
	set_property("auto_replaces", "");
	set_property("auto_consumeKeyLimePies", true);
	set_property("auto_skipNuns", "false");
	set_property("auto_skipL12Farm", "false");
	set_property("auto_L12FarmStage", "0");
	set_property("choiceAdventure1003", 0);
	remove_property("auto_minedCells");
	beehiveConsider();

	auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
	if(contains_text(get_property("sourceTerminalEnquiryKnown"), "monsters.enq") && (auto_my_path() == "Pocket Familiars"))
	{
		auto_sourceTerminalRequest("enquiry monsters.enq");
	}
	else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "familiar.enq") && auto_have_familiar($familiar[Mosquito]))
	{
		auto_sourceTerminalRequest("enquiry familiar.enq");
	}
	else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "stats.enq"))
	{
		auto_sourceTerminalRequest("enquiry stats.enq");
	}
	else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "protect.enq"))
	{
		auto_sourceTerminalRequest("enquiry protect.enq");
	}

	eudora_initializeSettings();
	hr_initializeSettings();
	awol_initializeSettings();
	theSource_initializeSettings();
	florist_initializeSettings();
	ed_initializeSettings();
	boris_initializeSettings();
	jello_initializeSettings();
	bond_initializeSettings();
	fallout_initializeSettings();
	pete_initializeSettings();
	groundhog_initializeSettings();
	digimon_initializeSettings();
	majora_initializeSettings();
	glover_initializeSettings();
	bat_initializeSettings();
	koe_initializeSettings();
	zelda_initializeSettings();
	lowkey_initializeSettings();

	set_property("auto_doneInitialize", my_ascensions());
}

int auto_advToReserve()
{
	// Calculates how many adventures we should aim to keep in reserve
	
	// blank int value does not work. and values lower than -1 are not valid.
	if(get_property("auto_save_adv_override") == "" || get_property("auto_save_adv_override").to_int() < -1)
	{
		set_property("auto_save_adv_override", -1);
	}
	
	// if auto_save_adv_override value is 0 or higher then use the override
	if(get_property("auto_save_adv_override").to_int() > -1)
	{
		return get_property("auto_save_adv_override").to_int();
	}

	// automatically calculate how many adv to reserve at end of day
	// free crafting require at least 1 adventure to do.
	// To enter free fights we need at least 1 adventure remaining. Dying costs an adventure, so we reserve 2 adventures so the user can manually complete the remaining fights even if we lose.
	// cocktailcrafting and pasta cooking require 2 adventures.
	
	int reserveadv = 1;
	
	if((my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean()) && auto_freeCombatsRemaining() > 0)
	{
		reserveadv = max(2, reserveadv);
	}
	
	if(freeCrafts() < 2)
	{
		//smallest Pasta dish that takes 2 adv to craft is 3 fullness.
		//Pastamastery is required for all pasta and having it alone is enough to craft foods that take 2 adv to craft
		if(can_eat() && my_fullness()+3 <= fullness_limit() && auto_have_skill($skill[Pastamastery]))
		{
			reserveadv = max(2, reserveadv);
		}
		
		//Advanced Cocktailcrafting skill is enough to make drinks that cost 2 adv to craft
		//because of nightcap, there is no point in checking your inebrity limits.
		if(can_drink() && auto_have_skill($skill[Advanced Cocktailcrafting]))
		{
			reserveadv = max(2, reserveadv);
		}
		
		//sneaky pete specific check. Mixologist lets you spend 2 adv on crafting. cocktail magic makes crafting free.
		if(auto_have_skill($skill[Mixologist]) && !auto_have_skill($skill[Cocktail Magic]))
		{
			reserveadv = max(2, reserveadv);
		}
	}
	
	return reserveadv;
}

boolean auto_unreservedAdvRemaining()
{
	// should the main loop continue to run or not, based on how many adv we wish to reserve.
	if(my_adventures() > auto_advToReserve())
	{
		return true;
	}
	return false;
}

boolean handleFamiliar(string type)
{
	//Can this take zoneInfo into account?

	//	Put all familiars in reverse priority order here.
	int[familiar] blacklist;

	int ascensionThreshold = get_property("auto_ascensionThreshold").to_int();
	if(ascensionThreshold == 0)
	{
		ascensionThreshold = 100;
	}

	if(get_property("auto_blacklistFamiliar") != "")
	{
		string[int] noFams = split_string(get_property("auto_blacklistFamiliar"), ";");
		foreach index, fam in noFams
		{
			blacklist[to_familiar(trim(fam))] = 1;
		}
	}

	boolean suggest = type.ends_with("Suggest");
	if(suggest)
	{
		type = type.substring(0, type.length() - length("Suggest"));
		if(familiar_weight(my_familiar()) < 20)
		{
			return false;
		}
	}

	string [string,int,string] familiars_text;
	if(!file_to_map("autoscend_familiars.txt", familiars_text))
		auto_log_critical("Could not load autoscend_familiars.txt. This is bad!", "red");
	foreach i,name,conds in familiars_text[type]
	{
		familiar thisFamiliar = name.to_familiar();
		if(thisFamiliar == $familiar[none] && name != "none")
		{
			auto_log_error('"' + name + '" does not convert to a familiar properly!', "red");
			auto_log_error(type + "; " + i + "; " + conds, "red");
			continue;
		}
		if(!auto_check_conditions(conds))
			continue;
		if(!auto_have_familiar(thisFamiliar))
			continue;
		if(blacklist contains thisFamiliar)
			continue;
		return handleFamiliar(thisFamiliar);
	}
	return false;
}

boolean handleFamiliar(familiar fam)
{
	if(!canChangeFamiliar())
	{
		return true;
	}

	if(fam == $familiar[none])
	{
		return true;
	}
	if(!is_unrestricted(fam))
	{
		return false;
	}

	if((fam == $familiar[Ms. Puck Man]) && !auto_have_familiar($familiar[Ms. Puck Man]) && auto_have_familiar($familiar[Puck Man]))
	{
		fam = $familiar[Puck Man];
	}
	if((fam == $familiar[Puck Man]) && !auto_have_familiar($familiar[Puck Man]) && auto_have_familiar($familiar[Ms. Puck Man]))
	{
		fam = $familiar[Ms. Puck Man];
	}

	familiar toEquip = $familiar[none];
	if(auto_have_familiar(fam))
	{
		toEquip = fam;
	}
	else
	{
		boolean[familiar] poss = $familiars[Mosquito, Leprechaun, Baby Gravy Fairy, Slimeling, Golden Monkey, Hobo Monkey, Crimbo Shrub, Galloping Grill, Fist Turkey, Rockin\' Robin, Piano Cat, Angry Jung Man, Grimstone Golem, Adventurous Spelunker, Rockin\' Robin];

		int spleen_hold = 4;
		if(item_amount($item[Astral Energy Drink]) > 0)
		{
			spleen_hold = spleen_hold + 8;
		}
		if(in_hardcore() && ((my_spleen_use() + spleen_hold) <= spleen_limit()))
		{
			foreach fam in $familiars[Golden Monkey, Grim Brother, Unconscious Collective]
			{
				if((fam.drops_today < 1) && auto_have_familiar(fam))
				{
					toEquip = fam;
				}
			}
		}
		else if(in_hardcore() && (item_amount($item[Yellow Pixel]) < 30) && auto_have_familiar($familiar[Ms. Puck Man]))
		{
			toEquip = $familiar[Ms. Puck Man];
		}
		else if(in_hardcore() && (item_amount($item[Yellow Pixel]) < 30) && auto_have_familiar($familiar[Puck Man]))
		{
			toEquip = $familiar[Puck Man];
		}

		foreach thing in poss
		{
			if((auto_have_familiar(thing)) && (my_bjorned_familiar() != thing))
			{
				toEquip = thing;
			}
		}
	}

	if((toEquip != $familiar[none]) && (my_bjorned_familiar() != toEquip))
	{
		#use_familiar(toEquip);
		set_property("auto_familiarChoice", toEquip);
	}
	if(get_property("kingLiberated").to_boolean() && (toEquip != $familiar[none]) && (toEquip != my_familiar()) && (my_bjorned_familiar() != toEquip))
	{
		use_familiar(toEquip);
	}
#	set_property("auto_familiarChoice", my_familiar());

	if(hr_handleFamiliar(fam))
	{
		return true;
	}
	return false;
}

boolean basicFamiliarOverrides()
{
	if(($familiars[Adventurous Spelunker, Rockin\' Robin] contains my_familiar()) && auto_have_familiar($familiar[Grimstone Golem]) && (in_hardcore() || !possessEquipment($item[Buddy Bjorn])))
	{
		if(!possessEquipment($item[Ornate Dowsing Rod]) && (item_amount($item[Odd Silver Coin]) < 5) && (item_amount($item[Grimstone Mask]) == 0) && considerGrimstoneGolem(false))
		{
			handleFamiliar($familiar[Grimstone Golem]);
		}
	}

	int spleen_hold = 8 * item_amount($item[Astral Energy Drink]);
	foreach it in $items[Agua De Vida, Grim Fairy Tale, Groose Grease, Powdered Gold, Unconscious Collective Dream Jar]
	{
		spleen_hold += 4 * item_amount(it);
	}
	if((spleen_left() >= (4 + spleen_hold)) && haveSpleenFamiliar())
	{
		int spleenHave = 0;
		foreach fam in $familiars[Baby Sandworm, Bloovian Groose, Golden Monkey, Grim Brother, Unconscious Collective]
		{
			if(auto_have_familiar(fam))
			{
				spleenHave++;
			}
		}

		if(spleenHave > 0)
		{
			int need = (spleen_left() + 3)/4;
			int bound = (need + spleenHave - 1) / spleenHave;
			foreach fam in $familiars[Baby Sandworm, Bloovian Groose, Golden Monkey, Grim Brother, Unconscious Collective]
			{
				if((fam.drops_today < bound) && auto_have_familiar(fam))
				{
					handleFamiliar(fam);
					break;
				}
			}
		}
	}
	else if((item_amount($item[Yellow Pixel]) < 20) && (auto_have_familiar($familiar[Ms. Puck Man]) || auto_have_familiar($familiar[Puck Man])))
	{
		handleFamiliar($familiar[Ms. Puck Man]);
	}

	foreach fam in $familiars[Golden Monkey, Grim Brother, Unconscious Collective]
	{
		if((my_familiar() == fam) && (fam.drops_today >= 1))
		{
			handleFamiliar("item");
		}
	}
	if((my_familiar() == $familiar[Puck Man]) && (item_amount($item[Yellow Pixel]) > 20))
	{
		handleFamiliar("item");
	}
	if((my_familiar() == $familiar[Ms. Puck Man]) && (item_amount($item[Yellow Pixel]) > 20))
	{
		handleFamiliar("item");
	}

	if(in_hardcore() && (my_mp() < 50) && ((my_maxmp() - my_mp()) > 20))
	{
		handleFamiliar("regen");
	}

	return false;
}


boolean LX_burnDelay()
{
	location burnZone = solveDelayZone();
	boolean wannaVote = auto_voteMonster(true);
	boolean wannaDigitize = isOverdueDigitize();
	boolean wannaSausage = auto_sausageGoblin();

	// if we're a plumber and we're still stuck doing a flat 15 damage per attack
	// then a scaling monster is probably going to be a bad time
	if(in_zelda() && !zelda_canDealScalingDamage())
	{
		// unless we can still kill it in one hit, then it should probably be fine?
		int predictedScalerHP = to_int(0.75 * (my_buffedstat($stat[Muscle]) + monster_level_adjustment()));
		if(predictedScalerHP > 15)
		{
			auto_log_info("Want to burn delay with scaling wanderers, but we can't deal scaling damage yet and it would be too strong :(");
			wannaVote = false;
			wannaSausage = false;
			addToMaximize("-equip Kramco Sausage O-Matic");
			addToMaximize("-equip &quot;I Voted!&quot; sticker");
		}
	}

	if(burnZone != $location[none])
	{
		if(wannaVote)
		{
			auto_log_info("Burn some delay somewhere (voting), if we found a place!", "green");
			if(auto_voteMonster(true, burnZone, ""))
			{
				return true;
			}
		}
		if(wannaDigitize)
		{
			auto_log_info("Burn some delay somewhere (digitize), if we found a place!", "green");
			if(autoAdv(burnZone))
			{
				return true;
			}
		}
		if(wannaSausage)
		{
			auto_log_info("Burn some delay somewhere (sausage goblin), if we found a place!", "green");
			if(auto_sausageGoblin(burnZone, ""))
			{
				return true;
			}
		}
	}
	else if(wannaVote || wannaDigitize || wannaSausage)
	{
		if(wannaVote) auto_log_warning("Had overdue voting monster but couldn't find a zone to burn delay", "red");
		if(wannaDigitize) auto_log_warning("Had overdue digitize but couldn't find a zone to burn delay", "red");
		if(wannaSausage) auto_log_warning("Had overdue sausage but couldn't find a zone to burn delay", "red");
	}
	return false;
}


boolean LX_universeFrat()
{
	if(my_daycount() >= 2)
	{
		if(possessEquipment($item[Beer Helmet]) && possessEquipment($item[Distressed Denim Pants]) && possessEquipment($item[Bejeweled Pledge Pin]))
		{
			doNumberology("adventures3");
		}
		else if((my_mp() >= mp_cost($skill[Calculate the Universe])) && (doNumberology("battlefield", false) != -1) && adjustForYellowRayIfPossible($monster[War Frat 151st Infantryman]))
		{
			doNumberology("battlefield");
			return true;
		}
	}
	return false;
}

boolean LX_faxing()
{
	if (my_level() >= 9 && !get_property("_photocopyUsed").to_boolean() && isActuallyEd() && my_daycount() < 3 && !is_unrestricted($item[Deluxe Fax Machine]))
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(handleFaxMonster($monster[Lobsterfrogman]))
		{
			return true;
		}
	}
	return false;
}

int pullsNeeded(string data)
{
	if(get_property("kingLiberated").to_boolean())
	{
		return 0;
	}
	if (isActuallyEd() || auto_my_path() == "Community Service")
	{
		return 0;
	}

	int count = 0;
	int adv = 0;

	int progress = 0;
	if(internalQuestStatus("questL13Final") == 4)
	{
		progress = 1;
	}
	if(internalQuestStatus("questL13Final") == 5)
	{
		progress = 2;
	}
	if(internalQuestStatus("questL13Final") == 6)
	{
		progress = 3;
	}
	if(internalQuestStatus("questL13Final") == 11)
	{
		progress = 4;
	}
	visit_url("campground.php?action=telescopelow");

	if(progress < 1)
	{
		int crowd1score = 0;
		int crowd2score = 0;
		int crowd3score = 0;

//		Note: Maximizer gives concert White-boy angst, instead of concert 3 (consequently, it doesn\'t work).

		switch(ns_crowd1())
		{
		case 1:					crowd1score = initiative_modifier()/40;							break;
		}

		switch(ns_crowd2())
		{
		case $stat[Moxie]:		crowd2score = (my_buffedstat($stat[Moxie]) - 150) / 40;			break;
		case $stat[Muscle]:		crowd2score = (my_buffedstat($stat[Muscle]) - 150) / 40;		break;
		case $stat[Mysticality]:crowd2score = (my_buffedstat($stat[Mysticality]) - 150) / 40;	break;
		}

		switch(ns_crowd3())
		{
		case $element[cold]:	crowd3score = numeric_modifier("cold damage") / 9;				break;
		case $element[hot]:		crowd3score = numeric_modifier("hot damage") / 9;				break;
		case $element[sleaze]:	crowd3score = numeric_modifier("sleaze damage") / 9;			break;
		case $element[spooky]:	crowd3score = numeric_modifier("spooky damage") / 9;			break;
		case $element[stench]:	crowd3score = numeric_modifier("stench damage") / 9;			break;
		}

		crowd1score = min(max(0, crowd1score), 9);
		crowd2score = min(max(0, crowd2score), 9);
		crowd3score = min(max(0, crowd3score), 9);
		adv = adv + (10 - crowd1score) + (10 - crowd2score) + (10 - crowd3score);
	}

	if(progress < 2)
	{
		ns_hedge1();
		ns_hedge2();
		ns_hedge3();

		auto_log_warning("Hedge time of 4 adventures. (Up to 10 without Elemental Resistances)", "red");
		adv = adv + 4;
	}

	if(progress < 3)
	{
		if((item_amount($item[Richard\'s Star Key]) == 0) && (item_amount($item[Star Chart]) == 0))
		{
			auto_log_warning("Need star chart", "red");
			if((auto_my_path() == "Heavy Rains") && (my_rain() >= 50))
			{
				auto_log_info("You should rain man a star chart", "blue");
			}
			else
			{
				count = count + 1;
			}
		}

		if(item_amount($item[Richard\'s Star Key]) == 0)
		{
			int stars = item_amount($item[star]);
			int lines = item_amount($item[line]);

			if(stars < 8)
			{
				auto_log_warning("Need " + (8-stars) + " stars.", "red");
				count = count + (8-stars);
			}
			if(lines < 7)
			{
				auto_log_warning("Need " + (7-lines) + " lines.", "red");
				count = count + (7-lines);
			}
		}

		if(item_amount($item[Digital Key]) == 0 && whitePixelCount() < 30)
		{
			auto_log_warning("Need " + (30-whitePixelCount()) + " white pixels.", "red");
			count = count + (30 - whitePixelCount());
		}

		if(item_amount($item[skeleton key]) == 0)
		{
			if((item_amount($item[skeleton bone]) > 0) && (item_amount($item[loose teeth]) > 0))
			{
				cli_execute("make skeleton key");
			}
		}
		if(item_amount($item[skeleton key]) == 0)
		{
			auto_log_warning("Need a skeleton key or the ingredients (skeleton bone, loose teeth) for it.");
		}
	}

	if(progress < 4)
	{
		adv = adv + 6;
		if(get_property("auto_wandOfNagamar").to_boolean() && (item_amount($item[Wand Of Nagamar]) == 0) && (cloversAvailable() == 0))
		{
			auto_log_warning("Need a wand of nagamar (can be clovered).", "red");
			count = count + 1;
		}
	}

	if(adv > 0)
	{
		auto_log_info("Estimated adventure need (tower) is: " + adv + ".", "orange");
		if(!in_hardcore())
		{
			auto_log_info("You need " + count + " pulls.", "orange");
		}
	}
	if(pulls_remaining() > 0)
	{
		auto_log_info("You have " + pulls_remaining() + " pulls.", "orange");
	}
	return count;
}

boolean tophatMaker()
{
	if(!knoll_available() || (item_amount($item[Brass Gear]) == 0) || possessEquipment($item[Mark V Steam-Hat]))
	{
		return false;
	}
	item reEquip = $item[none];

	if(possessEquipment($item[Mark IV Steam-Hat]))
	{
		if(equipped_item($slot[Hat]) == $item[Mark IV Steam-Hat])
		{
			reEquip = $item[Mark V Steam-Hat];
			equip($slot[hat], $item[none]);
		}
		autoCraft("combine", 1, $item[Brass Gear], $item[Mark IV Steam-Hat]);
	}
	else if(possessEquipment($item[Mark III Steam-Hat]))
	{
		if(equipped_item($slot[Hat]) == $item[Mark III Steam-Hat])
		{
			reEquip = $item[Mark IV Steam-Hat];
			equip($slot[hat], $item[none]);
		}
		autoCraft("combine", 1, $item[Brass Gear], $item[Mark III Steam-Hat]);
	}
	else if(possessEquipment($item[Mark II Steam-Hat]))
	{
		if(equipped_item($slot[Hat]) == $item[Mark II Steam-Hat])
		{
			reEquip = $item[Mark III Steam-Hat];
			equip($slot[hat], $item[none]);
		}
		autoCraft("combine", 1, $item[Brass Gear], $item[Mark II Steam-Hat]);
	}
	else if(possessEquipment($item[Mark I Steam-Hat]))
	{
		if(equipped_item($slot[Hat]) == $item[Mark I Steam-Hat])
		{
			reEquip = $item[Mark II Steam-Hat];
			equip($slot[hat], $item[none]);
		}
		autoCraft("combine", 1, $item[Brass Gear], $item[Mark I Steam-Hat]);
	}
	else if(possessEquipment($item[Brown Felt Tophat]))
	{
		if(equipped_item($slot[Hat]) == $item[Brown Felt Tophat])
		{
			reEquip = $item[Mark I Steam-Hat];
			equip($slot[hat], $item[none]);
		}
		autoCraft("combine", 1, $item[Brass Gear], $item[Brown Felt Tophat]);
	}
	else
	{
		return false;
	}

	auto_log_info("Mark Steam-Hat upgraded!", "blue");
	if(reEquip != $item[none])
	{
		equip($slot[hat], reEquip);
	}
	return true;
}

int handlePulls(int day)
{
	if(item_amount($item[Astral Six-Pack]) > 0)
	{
		use(1, $item[Astral Six-Pack]);
	}
	if(item_amount($item[Astral Hot Dog Dinner]) > 0)
	{
		use(1, $item[Astral Hot Dog Dinner]);
	}

	initializeSettings();

	if(in_hardcore())
	{
		return 0;
	}

	if(day == 1)
	{
		set_property("lightsOutAutomation", "1");
		# Do starting pulls:
		if((pulls_remaining() != 20) && !in_hardcore() && (my_turncount() > 0))
		{
			auto_log_info("I assume you've handled your pulls yourself... who knows.");
			return 0;
		}

		if((storage_amount($item[etched hourglass]) > 0) && auto_is_valid($item[etched hourglass]))
		{
			pullXWhenHaveY($item[etched hourglass], 1, 0);
		}

		if((storage_amount($item[can of rain-doh]) > 0) && glover_usable($item[Can Of Rain-Doh]) && (pullXWhenHaveY($item[can of Rain-doh], 1, 0)))
		{
			if(item_amount($item[Can of Rain-doh]) > 0)
			{
				use(1, $item[can of Rain-doh]);
				put_closet(1, $item[empty rain-doh can]);
			}
		}
		if((storage_amount($item[Buddy Bjorn]) > 0) && !($classes[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Ed] contains my_class()))
		{
			pullXWhenHaveY($item[Buddy Bjorn], 1, 0);
		}
		if((storage_amount($item[Camp Scout Backpack]) > 0) && !possessEquipment($item[Buddy Bjorn]) && glover_usable($item[Camp Scout Backpack]))
		{
			pullXWhenHaveY($item[Camp Scout Backpack], 1, 0);
		}

		if(my_path() == "Way of the Surprising Fist")
		{
			pullXWhenHaveY($item[Bittycar Meatcar], 1, 0);
		}

		if(!possessEquipment($item[Astral Shirt]))
		{
			boolean getPeteShirt = true;
			if(!hasTorso())
			{
				getPeteShirt = false;
			}
			if((my_primestat() == $stat[Muscle]) && get_property("loveTunnelAvailable").to_boolean())
			{
				getPeteShirt = false;
			}
			if(auto_my_path() == "G-Lover")
			{
				getPeteShirt = false;
			}
			if (storage_amount($item[Sneaky Pete\'s Leather Jacket]) == 0 && storage_amount($item[Sneaky Pete\'s Leather Jacket (Collar Popped)]) == 0)
			{
				getPeteShirt = false;
			}

			if(getPeteShirt)
			{
				pullXWhenHaveY($item[Sneaky Pete\'s Leather Jacket], 1, 0);
				if(item_amount($item[Sneaky Pete\'s Leather Jacket]) == 0)
				{
					pullXWhenHaveY($item[Sneaky Pete\'s Leather Jacket (Collar Popped)], 1, 0);
				}
				else
				{
					cli_execute("fold " + $item[Sneaky Pete\'s Leather Jacket (Collar Popped)]);
				}
			}
		}

		if(((auto_my_path() == "Picky") || !canChangeFamiliar()) && (item_amount($item[Deck of Every Card]) == 0) && (fullness_left() >= 4))
		{
			if((item_amount($item[Boris\'s Key]) == 0) && canEat($item[Boris\'s Key Lime Pie]) && !contains_text(get_property("nsTowerDoorKeysUsed"), $item[Boris\'s Key]))
			{
				pullXWhenHaveY($item[Boris\'s Key Lime Pie], 1, 0);
			}
			if((item_amount($item[Sneaky Pete\'s Key]) == 0) && canEat($item[Sneaky Pete\'s Key Lime Pie]) && !contains_text(get_property("nsTowerDoorKeysUsed"), $item[Sneaky Pete\'s Key]))
			{
				pullXWhenHaveY($item[Sneaky Pete\'s Key Lime Pie], 1, 0);
			}
			if((item_amount($item[Jarlsberg\'s Key]) == 0) && canEat($item[Jarlsberg\'s Key Lime Pie]) && !contains_text(get_property("nsTowerDoorKeysUsed"), $item[Jarlsberg\'s Key]))
			{
				pullXWhenHaveY($item[Jarlsberg\'s Key Lime Pie], 1, 0);
			}
		}

		if((equipped_item($slot[folder1]) == $item[folder (tranquil landscape)]) && (equipped_item($slot[folder2]) == $item[folder (skull and crossbones)]) && (equipped_item($slot[folder3]) == $item[folder (Jackass Plumber)]) && glover_usable($item[Over-The-Shoulder Folder Holder]))
		{
			pullXWhenHaveY($item[over-the-shoulder folder holder], 1, 0);
		}
		if((my_primestat() == $stat[Muscle]) && (auto_my_path() != "Heavy Rains"))
		{
			if((closet_amount($item[Fake Washboard]) == 0) && glover_usable($item[Fake Washboard]))
			{
				pullXWhenHaveY($item[Fake Washboard], 1, 0);
			}
			if((item_amount($item[Fake Washboard]) == 0) && (closet_amount($item[Fake Washboard]) == 0))
			{
				pullXWhenHaveY($item[numberwang], 1, 0);
			}
			else
			{
				if(get_property("barrelShrineUnlocked").to_boolean())
				{
					put_closet(item_amount($item[Fake Washboard]), $item[Fake Washboard]);
				}
			}
		}
		else
		{
			pullXWhenHaveY($item[Numberwang], 1, 0);
		}
		if(auto_my_path() == "Pocket Familiars")
		{
			pullXWhenHaveY($item[Ring Of Detect Boring Doors], 1, 0);
			pullXWhenHaveY($item[Pick-O-Matic Lockpicks], 1, 0);
			pullXWhenHaveY($item[Eleven-Foot Pole], 1, 0);
		}

		if((my_class() == $class[Sauceror]) || (my_class() == $class[Pastamancer]))
		{
			if((item_amount($item[Deck of Every Card]) == 0) && !auto_have_skill($skill[Summon Smithsness]))
			{
				pullXWhenHaveY($item[Thor\'s Pliers], 1, 0);
			}
			if(glover_usable($item[Basaltamander Buckler]))
			{
				pullXWhenHaveY($item[Basaltamander Buckler], 1, 0);
			}
		}

		if(auto_my_path() == "Picky")
		{
			pullXWhenHaveY($item[gumshoes], 1, 0);
		}
		if(auto_have_skill($skill[Summon Smithsness]))
		{
			pullXWhenHaveY($item[hand in glove], 1, 0);
		}
		else
		{
			//pullXWhenHaveY(<smithsWeapon>, 1, 0);
			//Possibly pull other smiths gear?
		}

		if((auto_my_path() != "Heavy Rains") && (auto_my_path() != "License to Adventure") && !($classes[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Ed] contains my_class()))
		{
			if(!possessEquipment($item[Snow Suit]) && !possessEquipment($item[Astral Pet Sweater]) && glover_usable($item[Snow Suit]))
			{
				pullXWhenHaveY($item[snow suit], 1, 0);
			}
			if(!possessEquipment($item[Snow Suit]) && !possessEquipment($item[Filthy Child Leash]) && !possessEquipment($item[Astral Pet Sweater]) && glover_usable($item[Filthy Child Leash]))
			{
				pullXWhenHaveY($item[Filthy Child Leash], 1, 0);
			}
		}

		if(get_property("auto_dickstab").to_boolean())
		{
			pullXWhenHaveY($item[Shore Inc. Ship Trip Scrip], 3, 0);
		}

		if(auto_my_path() != "G-Lover")
		{
			pullXWhenHaveY($item[Infinite BACON Machine], 1, 0);
		}

		if(is_unrestricted($item[Bastille Battalion control rig]))
		{
			string temp = visit_url("storage.php?action=pull&whichitem1=" + to_int($item[Bastille Battalion Control Rig]) + "&howmany1=1&pwd");
		}

		if((auto_my_path() != "Pocket Familiars") && (auto_my_path() != "G-Lover"))
		{
			pullXWhenHaveY($item[Replica Bat-oomerang], 1, 0);
		}

		if(my_class() == $class[Vampyre])
		{
			auto_log_info("You are a powerful vampire who is doing a softcore run. Turngen is busted in this path, so let's see how much we can get.", "blue");
			if((storage_amount($item[mime army shotglass]) > 0) && is_unrestricted($item[mime army shotglass]))
			{
				pullXWhenHaveY($item[mime army shotglass], 1, 0);
			}
			int available_bloodbags = 7;
			if(item_amount($item[Vampyric cloake]) > 0)
			{
				available_bloodbags += 1;
			}
			if(item_amount($item[Lil\' Doctor&trade; Bag]) > 0)
			{
				available_bloodbags += 1;
			}

			int available_stomach = 5;
			int available_drink = 5;
			if(item_amount($item[mime army shotglass]) > 0)
			{
				available_drink += 1;
			}

			// assuming dieting pills
			pullXWhenHaveY($item[gauze garter], (1+available_stomach)/2, 0);
			pullXWhenHaveY($item[monstar energy beverage], available_drink, 0);
		}
	}
	else if(day == 2)
	{
		if((closet_amount($item[Fake Washboard]) == 1) && get_property("barrelShrineUnlocked").to_boolean())
		{
			take_closet(1, $item[Fake Washboard]);
		}
	}

	return pulls_remaining();
}

boolean doVacation()
{
	if(in_koe())
	{
		return false;
	}
	if(in_zelda())
	{
		zelda_equipTool($stat[moxie]);
		equipMaximizedGear();
	}
	if(my_primestat() == $stat[Muscle])
	{
		set_property("choiceAdventure793", "1");
	}
	else if(my_primestat() == $stat[Mysticality])
	{
		set_property("choiceAdventure793", "2");
	}
	else
	{
		set_property("choiceAdventure793", "3");
	}
	return autoAdv(1, $location[The Shore\, Inc. Travel Agency]);
}

boolean fortuneCookieEvent()
{
	if(get_counters("Fortune Cookie", 0, 0) == "Fortune Cookie")
	{
		auto_log_info("Semi rare time!", "blue");
		cli_execute("counters");

		location goal = $location[The Hidden Temple];

		if((my_path() == "Community Service") && (my_daycount() == 1))
		{
			goal = $location[The Limerick Dungeon];
		}

		if (goal == $location[The Hidden Temple] && (get_property("semirareLocation") == goal || item_amount($item[stone wool]) >= 2 || internalQuestStatus("questL11Worship") >= 3 || get_property("lastTempleUnlock").to_int() < my_ascensions()))
		{
			goal = $location[The Castle in the Clouds in the Sky (Top Floor)];
		}

		if (goal == $location[The Castle in the Clouds in the Sky (Top Floor)] && (get_property("semirareLocation") == goal || item_amount($item[Mick\'s IcyVapoHotness Inhaler]) > 0 || internalQuestStatus("questL10Garbage") < 9 || get_property("lastCastleTopUnlock").to_int() < my_ascensions() || get_property("sidequestNunsCompleted") != "none" || in_koe()))
		{
			goal = $location[The Limerick Dungeon];
		}

		if (goal == $location[The Limerick Dungeon] && (get_property("semirareLocation") == goal || item_amount($item[Cyclops Eyedrops]) > 0 || get_property("lastFilthClearance").to_int() >= my_ascensions() || get_property("sidequestOrchardCompleted") != "none" || get_property("currentHippyStore") != "none" || isActuallyEd() || in_koe()))
		{
			goal = $location[The Copperhead Club];
		}

		if (goal == $location[The Copperhead Club] && (get_property("semirareLocation") == goal || internalQuestStatus("questL11Shen") < 0 || internalQuestStatus("questL11Ron") >= 2))
		{
			goal = $location[The Haunted Kitchen];
		}

		if (goal == $location[The Haunted Kitchen] && (get_property("semirareLocation") == goal || get_property("chasmBridgeProgress").to_int() >= 30 || internalQuestStatus("questL09Topping") >= 1 || isActuallyEd()))
		{
			goal = $location[The Outskirts of Cobb\'s Knob];
		}

		if (goal == $location[The Outskirts of Cobb\'s Knob] && (get_property("semirareLocation") == goal || internalQuestStatus("questL05Goblin") > 1 || item_amount($item[Knob Goblin encryption key]) > 0 || $location[The Outskirts of Cobb\'s Knob].turns_spent >= 10))
		{
			goal = $location[The Haunted Pantry];
		}

		if((goal == $location[The Haunted Pantry]) && (get_property("semirareLocation") == goal))
		{
			goal = $location[The Sleazy Back Alley];
		}

		if((goal == $location[The Sleazy Back Alley]) && (get_property("semirareLocation") == goal))
		{
			goal = $location[The Outskirts of Cobb\'s Knob];
		}

		if((goal == $location[The Outskirts of Cobb\'s Knob]) && (get_property("semirareLocation") == goal))
		{
			auto_log_warning("Do we not have access to either The Haunted Pantry or The Sleazy Back Alley?", "red");
			goal = $location[The Haunted Pantry];
		}
		
		if(in_zelda())
		{
			//prevent plumber crash when it tries to adventure without plumber gear.
			zelda_equipTool($stat[moxie]);
			equipMaximizedGear();
		}
		
		boolean retval = autoAdv(goal);
		if (item_amount($item[Knob Goblin lunchbox]) > 0)
		{
			use(item_amount($item[Knob Goblin lunchbox]), $item[Knob Goblin lunchbox]);
		}
		return retval;
	}
	return false;
}

void initializeDay(int day)
{
	if(get_property("kingLiberated").to_boolean())
	{
		return;
	}

	invalidateRestoreOptionCache();

	if(!possessEquipment($item[Your Cowboy Boots]) && get_property("telegraphOfficeAvailable").to_boolean() && is_unrestricted($item[LT&T Telegraph Office Deed]))
	{
		#string temp = visit_url("desc_item.php?whichitem=529185925");
		#if(equipped_item($slot[bootspur]) == $item[Nicksilver spurs])
		#if(contains_text(temp, "Item Drops from Monsters"))
		#{
			string temp = visit_url("place.php?whichplace=town_right&action=townright_ltt");
		#}
	}

	auto_saberDailyUpgrade(day);

	if((item_amount($item[cursed microwave]) >= 1) && !get_property("_cursedMicrowaveUsed").to_boolean())
	{
		use(1, $item[cursed microwave]);
	}
	if((item_amount($item[cursed pony keg]) >= 1) && !get_property("_cursedKegUsed").to_boolean())
	{
		use(1, $item[cursed pony keg]);
	}
	if(storage_amount($item[Talking Spade]) > 0)
	{
		pullXWhenHaveY($item[Talking Spade], 1, 0);
	}

	if(item_amount($item[Telegram From Lady Spookyraven]) > 0)
	{
		auto_log_warning("Lady Spookyraven quest not detected as started should have been auto-started. Starting it. If you are not in an Ed run, report this. Otherwise, it is expected.", "red");
		use(1, $item[Telegram From Lady Spookyraven]);
		set_property("questM20Necklace", "started");
	}

	if(internalQuestStatus("questM20Necklace") == -1)
	{
		if(item_amount($item[Telegram From Lady Spookyraven]) > 0)
		{
			auto_log_warning("Lady Spookyraven quest not started and we have a Telegram so let us use it.", "red");
			boolean temp = use(1, $item[Telegram From Lady Spookyraven]);
		}
		else
		{
			auto_log_warning("Lady Spookyraven quest not detected as started but we don't have the telegram, assuming it is... If you are not in an Ed run, report this. Otherwise, it is expected.", "red");
			set_property("questM20Necklace", "started");
		}
	}

	auto_barrelPrayers();

	if(get_property("auto_mummeryChoice") != "")
	{
		string[int] mummeryChoice = split_string(get_property("auto_mummeryChoice"), ";");
		foreach idx, opt in mummeryChoice
		{
			int goal = idx + 1;
			if((opt == "") || (goal > 7))
			{
				continue;
			}
			mummifyFamiliar(to_familiar(opt), goal);
		}
	}

	if(!get_property("_pottedTeaTreeUsed").to_boolean() && (auto_get_campground() contains $item[Potted Tea Tree]) && !get_property("kingLiberated").to_boolean())
	{
		if(get_property("auto_teaChoice") != "")
		{
			string[int] teaChoice = split_string(get_property("auto_teaChoice"), ";");
			item myTea = trim(teaChoice[min(count(teaChoice), my_daycount()) - 1]).to_item();
			if(myTea != $item[none])
			{
				boolean buff = cli_execute("teatree " + myTea);
			}
		}
		else if(day == 1)
		{
			if(fullness_limit() > 0)
			{
				boolean buff = cli_execute("teatree " + $item[Cuppa Voraci Tea]);
			}
			else if(inebriety_limit() > 0)
			{
				boolean buff = cli_execute("teatree " + $item[Cuppa Sobrie Tea]);
			}
			else
			{
				boolean buff = cli_execute("teatree " + $item[Cuppa Royal Tea]);
			}
		}
		else if(day == 2)
		{
			if(inebriety_limit() > 0)
			{
				boolean buff = cli_execute("teatree " + $item[Cuppa Sobrie Tea]);
			}
			else if(fullness_limit() > 0)
			{
				boolean buff = cli_execute("teatree " + $item[Cuppa Voraci Tea]);
			}
			else
			{
				boolean buff = cli_execute("teatree " + $item[Cuppa Royal Tea]);
			}
		}
		else
		{
			visit_url("campground.php?action=teatree");
			run_choice(1);
		}
	}

	auto_floundryAction();

	if((item_amount($item[GameInformPowerDailyPro Magazine]) > 0) && (my_daycount() == 1))
	{
		visit_url("inv_use.php?pwd=&which=3&whichitem=6174", true);
		visit_url("inv_use.php?pwd=&which=3&whichitem=6174&confirm=Yep.", true);
		set_property("auto_disableAdventureHandling", true);
		autoAdv(1, $location[Video Game Level 1]);
		set_property("auto_disableAdventureHandling", false);
		if(item_amount($item[Dungeoneering Kit]) > 0)
		{
			use(1, $item[Dungeoneering Kit]);
		}
	}

	if((item_amount($item[GameInformPowerDailyPro Magazine]) > 0) && (my_daycount() == 2) && (auto_my_path() == "Community Service"))
	{
		visit_url("inv_use.php?pwd=&which=3&whichitem=6174", true);
		visit_url("inv_use.php?pwd=&which=3&whichitem=6174&confirm=Yep.", true);
		set_property("auto_disableAdventureHandling", true);
		autoAdv(1, $location[Video Game Level 1]);
		set_property("auto_disableAdventureHandling", false);
		if(item_amount($item[Dungeoneering Kit]) > 0)
		{
			use(1, $item[Dungeoneering Kit]);
		}
	}

	auto_doPrecinct();
	if(!in_koe() && (item_amount($item[Cop Dollar]) >= 10) && (item_amount($item[Shoe Gum]) == 0))
	{
		boolean temp = cli_execute("make shoe gum");
	}
	
	//a free to cast intrinsic that makes swords count as clubs. if you have it there is no reason to ever have it off regardless of class.
	if(auto_have_skill($skill[Iron Palm Technique]) && (have_effect($effect[Iron Palms]) == 0))
	{
		use_skill(1, $skill[Iron Palm Technique]);
	}

	ed_initializeDay(day);
	boris_initializeDay(day);
	fallout_initializeDay(day);
	pete_initializeDay(day);
	cs_initializeDay(day);
	bond_initializeDay(day);
	digimon_initializeDay(day);
	majora_initializeDay(day);
	glover_initializeDay(day);
	bat_initializeDay(day);

	if(day == 1)
	{
		if(get_property("auto_day_init").to_int() < 1)
		{
			if (item_amount($item[Newbiesport&trade; tent]) > 0)
			{
				use(1, $item[Newbiesport&trade; tent]);
			}
			kgbSetup();
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}

			if((auto_get_clan_lounge() contains $item[Clan Floundry]) && (item_amount($item[Fishin\' Pole]) == 0))
			{
				visit_url("clan_viplounge.php?action=floundry");
			}

			visit_url("tutorial.php?action=toot");
			use(item_amount($item[Letter From King Ralph XI]), $item[Letter From King Ralph XI]);
			use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
			tootGetMeat();

			hr_initializeDay(day);
			// It's nice to have a moxie weapon for Flock of Bats form
			if(my_class() == $class[Vampyre] && get_property("darkGyfftePoints").to_int() < 21 && !possessEquipment($item[disco ball]))
			{
				acquireGumItem($item[disco ball]);
			}
			if(!($classes[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Ed, Vampyre, Plumber] contains my_class()))
			{
				if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && (auto_predictAccordionTurns() < 5) && ((my_meat() > npc_price($item[Toy Accordion])) && (npc_price($item[Toy Accordion]) != 0)))
				{
					//Try to get Antique Accordion early if we possibly can.
					if(isUnclePAvailable() && ((my_meat() > npc_price($item[Antique Accordion])) && (npc_price($item[Antique Accordion]) != 0)) && (auto_my_path() != "G-Lover"))
					{
						buyUpTo(1, $item[Antique Accordion]);
					}
					// Removed "else". In some situations when mafia or supporting scripts are behaving wonky we may completely fail to get an accordion
					if((isArmoryAvailable()) && (item_amount($item[Antique Accordion]) == 0))
					{
						buyUpTo(1, $item[Toy Accordion]);
					}
				}
				if(!possessEquipment($item[Turtle Totem]))
				{
					acquireGumItem($item[Turtle Totem]);
				}
				if(!possessEquipment($item[Saucepan]))
				{
					acquireGumItem($item[Saucepan]);
				}
			}

			makeStartingSmiths();

			handleFamiliar("item");
			equipBaseline();

			handleBjornify($familiar[none]);
			handleBjornify($familiar[El Vibrato Megadrone]);

			string temp = visit_url("guild.php?place=challenge");

			if(get_property("auto_breakstone").to_boolean())
			{
				temp = visit_url("peevpee.php?action=smashstone&pwd&confirm=on", true);
				temp = visit_url("peevpee.php?place=fight");
				set_property("auto_breakstone", false);
			}

			auto_beachCombHead("exp");
		}

		if((get_property("lastCouncilVisit").to_int() < my_level()) && (auto_my_path() != "Community Service"))
		{
			cli_execute("counters");
			council();
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		fortuneCookieEvent();

		if(get_property("auto_day_init").to_int() < 2)
		{
			if((item_amount($item[Tonic Djinn]) > 0) && !get_property("_tonicDjinn").to_boolean())
			{
				set_property("choiceAdventure778", "2");
				use(1, $item[Tonic Djinn]);
			}
			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			hr_initializeDay(day);

			if(!in_hardcore() && (item_amount($item[Handful of Smithereens]) <= 5))
			{
				pulverizeThing($item[Hairpiece On Fire]);
				pulverizeThing($item[Vicar\'s Tutu]);
			}
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && isUnclePAvailable() && ((my_meat() > npc_price($item[Antique Accordion])) && (npc_price($item[Antique Accordion]) != 0)) && (auto_predictAccordionTurns() < 10) && !($classes[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Ed, Vampyre, Plumber] contains my_class()) && (auto_my_path() != "G-Lover"))
			{
				buyUpTo(1, $item[Antique Accordion]);
			}
			if(my_class() == $class[Avatar of Boris])
			{
				if((item_amount($item[Clancy\'s Crumhorn]) == 0) && (minstrel_instrument() != $item[Clancy\'s Crumhorn]))
				{
					buyUpTo(1, $item[Clancy\'s Crumhorn]);
				}
			}
			if(auto_have_skill($skill[Summon Smithsness]) && (my_mp() > (3 * mp_cost($skill[Summon Smithsness]))))
			{
				use_skill(3, $skill[Summon Smithsness]);
			}

			if(item_amount($item[handful of smithereens]) >= 2)
			{
				buyUpTo(2, $item[Ben-Gal&trade; Balm], 25);
				cli_execute("make 2 louder than bomb");
			}

			if(get_property("auto_dickstab").to_boolean())
			{
				pullXWhenHaveY($item[frost flower], 1, 0);
			}
		}
		if (chateaumantegna_havePainting() && !isActuallyEd() && auto_my_path() != "Community Service")
		{
			if(auto_have_familiar($familiar[Reanimated Reanimator]))
			{
				handleFamiliar($familiar[Reanimated Reanimator]);
			}
			chateaumantegna_usePainting();
			handleFamiliar($familiar[Angry Jung Man]);
		}
	}
	else if(day == 3)
	{
		if(get_property("auto_day_init").to_int() < 3)
		{
			while(acquireHermitItem($item[Ten-leaf Clover]));

			picky_pulls();
		}
	}
	else if(day == 4)
	{
		if(get_property("auto_day_init").to_int() < 4)
		{
			while(acquireHermitItem($item[Ten-leaf Clover]));
		}
	}
	if(day >= 2)
	{
		ovenHandle();
	}

	string campground = visit_url("campground.php");
	if(contains_text(campground, "beergarden7.gif"))
	{
		cli_execute("garden pick");
	}
	if(contains_text(campground, "wintergarden3.gif"))
	{
		cli_execute("garden pick");
	}
	if(contains_text(campground, "thanksgardenmega.gif"))
	{
		cli_execute("garden pick");
	}

	set_property("auto_forceNonCombatSource", "");

	set_property("auto_day_init", day);
}

boolean dailyEvents()
{
	while(auto_doPrecinct());
	handleBarrelFullOfBarrels(true);

	auto_campawayGrabBuffs();
	kgb_getMartini();
	fightClubNap();
	fightClubStats();

	chateaumantegna_useDesk();

	if((item_amount($item[Burned Government Manual Fragment]) > 0) && is_unrestricted($item[Burned Government Manual Fragment]) && get_property("auto_alienLanguage").to_boolean())
	{
		use(item_amount($item[Burned Government Manual Fragment]), $item[Burned Government Manual Fragment]);
	}

	if((item_amount($item[glass gnoll eye]) > 0) && !get_property("_gnollEyeUsed").to_boolean())
	{
		use(1, $item[Glass gnoll Eye]);
	}
	if((item_amount($item[chroner trigger]) > 0) && !get_property("_chronerTriggerUsed").to_boolean())
	{
		use(1, $item[chroner trigger]);
	}
	if((item_amount($item[chroner cross]) > 0) && !get_property("_chronerCrossUsed").to_boolean())
	{
		use(1, $item[chroner cross]);
	}
	if((item_amount($item[chester\'s bag of candy]) > 0) && !get_property("_bagOfCandyUsed").to_boolean())
	{
		use(1, $item[chester\'s bag of candy]);
	}
	if((item_amount($item[cheap toaster]) > 0) && !get_property("_toastSummoned").to_boolean())
	{
		use(1, $item[cheap toaster]);
	}
	if((item_amount($item[warbear breakfast machine]) > 0) && !get_property("_warbearBreakfastMachineUsed").to_boolean())
	{
		use(1, $item[warbear breakfast machine]);
	}
	if((item_amount($item[warbear soda machine]) > 0) && !get_property("_warbearSodaMachineUsed").to_boolean())
	{
		use(1, $item[warbear soda machine]);
	}
	if((item_amount($item[the cocktail shaker]) > 0) && !get_property("_cocktailShakerUsed").to_boolean())
	{
		use(1, $item[the cocktail shaker]);
	}
	if((item_amount($item[taco dan\'s taco stand flier]) > 0) && !get_property("_tacoFlierUsed").to_boolean())
	{
		use(1, $item[taco dan\'s taco stand flier]);
	}
	if((item_amount($item[Festive Warbear Bank]) > 0) && !get_property("_warbearBankUsed").to_boolean())
	{
		use(1, $item[Festive Warbear Bank]);
	}

	if((item_amount($item[etched hourglass]) > 0) && !get_property("_etchedHourglassUsed").to_boolean())
	{
		use(1, $item[etched hourglass]);
	}

	if((item_amount($item[Can of Rain-doh]) > 0) && (item_amount($item[Rain-Doh Red Wings]) == 0))
	{
		use(1, $item[can of Rain-doh]);
		put_closet(1, $item[empty rain-doh can]);
	}

	if(item_amount($item[Clan VIP Lounge Key]) > 0)
	{
		if(!get_property("_olympicSwimmingPoolItemFound").to_boolean() && is_unrestricted($item[Olympic-sized Clan Crate]))
		{
			cli_execute("swim item");
		}
		if(!get_property("_lookingGlass").to_boolean() && is_unrestricted($item[Clan Looking Glass]))
		{
			string temp = visit_url("clan_viplounge.php?action=lookingglass");
		}
		if(get_property("_deluxeKlawSummons").to_int() == 0)
		{
			cli_execute("clan_viplounge.php?action=klaw");
			cli_execute("clan_viplounge.php?action=klaw");
			cli_execute("clan_viplounge.php?action=klaw");
		}
		if(!get_property("_crimboTree").to_boolean() && is_unrestricted($item[Crimbough]))
		{
			cli_execute("crimbotree get");
		}
	}

	if((get_property("_klawSummons").to_int() == 0) && (get_clan_id() != -1))
	{
		cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
		cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
		cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
	}

	if((item_amount($item[Infinite BACON Machine]) > 0) && !get_property("_baconMachineUsed").to_boolean())
	{
		use(1, $item[Infinite BACON Machine]);
	}
	if((item_amount($item[Picky Tweezers]) > 0) && !get_property("_pickyTweezersUsed").to_boolean())
	{
		use(1, $item[Picky Tweezers]);
	}

	if(have_skill($skill[That\'s Not a Knife]) && !get_property("_discoKnife").to_boolean())
	{
		foreach it in $items[Boot Knife, Broken Beer Bottle, Candy Knife, Sharpened Spoon, Soap Knife]
		{
			if(item_amount(it) == 1)
			{
				put_closet(1, it);
			}
		}
		use_skill(1, $skill[That\'s Not a Knife]);
	}

	while(zataraClanmate(""));

	if(item_amount($item[Genie Bottle]) > 0 && auto_is_valid($item[pocket wish]))
	{
		for(int i=get_property("_genieWishesUsed").to_int(); i<3; i++)
		{
			makeGeniePocket();
		}
	}

	return true;
}

boolean doBedtime()
{
	auto_log_info("Starting bedtime: Pulls Left: " + pulls_remaining(), "blue");

	if(get_property("lastEncounter") == "Like a Bat Into Hell")
	{
		abort("Our last encounter was UNDYING and we ended up trying to bedtime and failed.");
	}

	auto_process_kmail("auto_deleteMail");

	if(my_adventures() > 4)
	{
		if(my_inebriety() <= inebriety_limit())
		{
			if(my_class() != $class[Gelatinous Noob] && my_familiar() != $familiar[Stooper])
			{
				return false;
			}
		}
	}
	boolean out_of_blood = (my_class() == $class[Vampyre] && item_amount($item[blood bag]) == 0);
	if((fullness_left() > 0) && can_eat() && !out_of_blood)
	{
		return false;
	}
	if((inebriety_left() > 0) && can_drink() && !out_of_blood)
	{
		return false;
	}
	int spleenlimit = spleen_limit();
	if(!canChangeFamiliar())
	{
		spleenlimit -= 3;
	}
	if(!haveSpleenFamiliar())
	{
		spleenlimit = 0;
	}
	if((my_spleen_use() < spleenlimit) && !in_hardcore() && (inebriety_left() > 0))
	{
		return false;
	}

	ed_terminateSession();
	bat_terminateSession();

	while(LX_freeCombats());

	if((my_class() == $class[Seal Clubber]) && guild_store_available() && (auto_my_path() != "G-Lover"))
	{
		handleFamiliar("stat");
		int oldSeals = get_property("_sealsSummoned").to_int();
		while((get_property("_sealsSummoned").to_int() < 5) && (!get_property("kingLiberated").to_boolean()) && (my_meat() > 4500))
		{
			boolean summoned = false;
			if((my_daycount() == 1) && (my_level() >= 6) && isHermitAvailable())
			{
				cli_execute("make figurine of an ancient seal");
				buyUpTo(3, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealAncient();
				summoned = true;
			}
			else if(my_level() >= 9)
			{
				buyUpTo(1, $item[figurine of an armored seal]);
				buyUpTo(10, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealNormal($item[Figurine of an Armored Seal]);
				summoned = true;
			}
			else if(my_level() >= 5)
			{
				buyUpTo(1, $item[figurine of a Cute Baby Seal]);
				buyUpTo(5, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealNormal($item[Figurine of a Cute Baby Seal]);
				summoned = true;
			}
			else
			{
				buyUpTo(1, $item[figurine of a Wretched-Looking Seal]);
				buyUpTo(1, $item[seal-blubber candle]);
				ensureSealClubs();
				handleSealNormal($item[Figurine of a Wretched-Looking Seal]);
				summoned = true;
			}
			int newSeals = get_property("_sealsSummoned").to_int();
			if((newSeals == oldSeals) && summoned)
			{
				abort("Unable to summon seals.");
			}
			oldSeals = newSeals;
		}
	}

	if(get_property("auto_priorCharpaneMode").to_int() == 1)
	{
		auto_log_info("Resuming Compact Character Mode.");
		set_property("auto_priorCharpaneMode", 0);
		visit_url("account.php?am=1&pwd=&action=flag_compactchar&value=1&ajax=0", true);
	}

	if((item_amount($item[License To Chill]) > 0) && !get_property("_licenseToChillUsed").to_boolean())
	{
		use(1, $item[License To Chill]);
	}

	if((my_inebriety() <= inebriety_limit()) && can_drink() && (my_rain() >= 50) && (my_adventures() >= 1))
	{
		if(my_daycount() == 1)
		{
			if(item_amount($item[Rain-Doh Indigo Cup]) > 0)
			{
				auto_log_info("Copies left: " + (5 - get_property("_raindohCopiesMade").to_int()), "olive");
			}
			if(!in_hardcore())
			{
				auto_log_info("Pulls remaining: " + pulls_remaining(), "olive");
			}
			if(item_amount($item[beer helmet]) == 0)
			{
				auto_log_info("Please consider an orcish frat boy spy (You want Frat Warrior Fatigues).", "blue");
				if(canYellowRay())
				{
					auto_log_info("Make sure to Ball Lightning the spy!!", "red");
				}
			}
			else
			{
				auto_log_info("If you have the Frat Warrior Fatigues, rain man an Astronomer? Skinflute?", "blue");
			}
		}
		if(auto_have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 5) && (inebriety_left() >= 0) && (my_adventures() > 0))
		{
			auto_log_info("You have " + (5 - get_property("_machineTunnelsAdv").to_int()) + " fights in The Deep Machine Tunnels that you should use!", "blue");
		}
		auto_log_info("You have a rain man to cast, please do so before overdrinking and run me again.", "red");
		return false;
	}

	//We are committing to end of day now...
	getSpaceJelly();
	while(acquireHermitItem($item[Ten-leaf Clover]));

	januaryToteAcquire($item[Makeshift Garbage Shirt]);		//doubles stat gains in the LOV tunnel. also keep leftover charges for tomorrow.
	loveTunnelAcquire(true, $stat[none], true, 3, true, 1);

	if(item_amount($item[Genie Bottle]) > 0)
	{
		for(int i=get_property("_genieWishesUsed").to_int(); i<3; i++)
		{
			makeGeniePocket();
		}
	}
	if(canGenieCombat() && item_amount($item[beer helmet]) == 0)
	{
		auto_log_info("Please consider genie wishing for an orcish frat boy spy (You want Frat Warrior Fatigues).", "blue");
	}

	if((friars_available()) && (!get_property("friarsBlessingReceived").to_boolean()))
	{
		if(auto_my_path() == "Pocket Familiars" || my_class() == $class[Vampyre])
		{
			cli_execute("friars food");
		}
		else
		{
			cli_execute("friars familiar");
		}
	}

	# This does not check if we still want these buffs
	if((my_hp() < (0.9 * my_maxhp())) && hotTubSoaksRemaining() > 0)
	{
		boolean doTub = true;
		foreach eff in $effects[Once-Cursed, Thrice-Cursed, Twice-Cursed]
		{
			if(have_effect(eff) > 0)
			{
				doTub = false;
			}
		}
		if(doTub)
		{
			doHottub();
		}
	}

	if(!get_property("_mayoTankSoaked").to_boolean() && (auto_get_campground() contains $item[Portable Mayo Clinic]) && is_unrestricted($item[Portable Mayo Clinic]))
	{
		string temp = visit_url("shop.php?action=bacta&whichshop=mayoclinic");
	}

	if((auto_my_path() == "Nuclear Autumn") && (get_property("falloutShelterLevel").to_int() >= 3) && !get_property("_falloutShelterSpaUsed").to_boolean())
	{
		string temp = visit_url("place.php?whichplace=falloutshelter&action=vault3");
	}

	//	Also use "nunsVisits", as long as they were won by the Frat (sidequestNunsCompleted="fratboy").
	ed_doResting();
	skill libram = preferredLibram();
	if(libram != $skill[none])
	{
		while(haveFreeRestAvailable() && (mp_cost(libram) <= my_maxmp()))
		{
			doFreeRest();
			while(my_mp() > mp_cost(libram))
			{
				use_skill(1, libram);
			}
		}
	}

	if((is_unrestricted($item[Clan Pool Table])) && (get_property("_poolGames").to_int() < 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
	{
		visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
		visit_url("clan_viplounge.php?preaction=poolgame&stance=1");
		visit_url("clan_viplounge.php?preaction=poolgame&stance=3");
	}
	if(is_unrestricted($item[Colorful Plastic Ball]) && !get_property("_ballpit").to_boolean() && (get_clan_id() != -1))
	{
		cli_execute("ballpit");
	}
	if (get_property("telescopeUpgrades").to_int() > 0 && internalQuestStatus("questL13Final") < 0)
	{
		if(get_property("telescopeLookedHigh") == "false")
		{
			cli_execute("telescope high");
		}
	}

	if(!possessEquipment($item[Vicar\'s Tutu]) && (my_daycount() == 1) && (item_amount($item[lump of Brituminous coal]) > 0))
	{
		if((item_amount($item[frilly skirt]) < 1) && knoll_available())
		{
			buyUpTo(1, $item[frilly skirt]);
		}
		if(item_amount($item[frilly skirt]) > 0)
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[frilly skirt]);
		}
	}

	if((my_daycount() == 1) && (possessEquipment($item[Thor\'s Pliers]) || (freeCrafts() > 0)) && !possessEquipment($item[Chrome Sword]) && !get_property("kingLiberated").to_boolean() && !in_tcrs())
	{
		item oreGoal = to_item(get_property("trapperOre"));
		int need = 1;
		if(oreGoal == $item[Chrome Ore])
		{
			need = 4;
		}
		if((item_amount($item[Chrome Ore]) >= need) && !possessEquipment($item[Chrome Sword]) && isArmoryAvailable())
		{
			cli_execute("make " + $item[Chrome Sword]);
		}
	}

	equipRollover();
	hr_doBedtime();

	while(my_daycount() == 1 && item_amount($item[resolution: be more adventurous]) > 0 && get_property("_resolutionAdv").to_int() < 10 && !can_interact())
	{
		use(1, $item[resolution: be more adventurous]);
	}

	// If in TCRS skip using freecrafts but alert user of how many they can manually use.
	if((in_tcrs()) && (freeCrafts() > 0))
	{
		auto_log_warning("In TCRS: Items are variable, skipping End Of Day crafting", "red");
		auto_log_warning("Consider manually using your "+freeCrafts()+" free crafts", "red");
	}
	else if((my_daycount() <= 2) && (freeCrafts() > 0) && my_adventures() > 0)
	{
		// Check for rapid prototyping
		while((freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Cranberries]) > 0) && (item_amount($item[Cranberry Cordial]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			cli_execute("make " + $item[Cranberry Cordial]);
		}
		put_closet(item_amount($item[Cranberries]), $item[Cranberries]);
		while((freeCrafts() > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Glass Of Goat\'s Milk]) > 0) && (item_amount($item[Milk Of Magnesium]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			cli_execute("make " + $item[Milk Of Magnesium]);
		}
	}

	dna_bedtime();

	if((get_property("_grimBuff") == "false") && auto_have_familiar($familiar[Grim Brother]))
	{
		string temp = visit_url("choice.php?pwd=&whichchoice=835&option=1", true);
	}

	dailyEvents();
	if((get_property("auto_clanstuff").to_int() < my_daycount()) && (get_clan_id() != -1))
	{
		if(is_unrestricted($item[Olympic-sized Clan Crate]) && !get_property("_olympicSwimmingPool").to_boolean())
		{
			cli_execute("swim noncombat");
		}
		if(is_unrestricted($item[Olympic-sized Clan Crate]) && !get_property("_olympicSwimmingPoolItemFound").to_boolean())
		{
			cli_execute("swim item");
		}
		if(get_property("_klawSummons").to_int() == 0)
		{
			cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
			cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
			cli_execute("clan_rumpus.php?action=click&spot=3&furni=3");
		}
		if(is_unrestricted($item[Clan Looking Glass]) && !get_property("_lookingGlass").to_boolean())
		{
			string temp = visit_url("clan_viplounge.php?action=lookingglass");
		}
		if(get_property("_deluxeKlawSummons").to_int() == 0)
		{
			cli_execute("clan_viplounge.php?action=klaw");
			cli_execute("clan_viplounge.php?action=klaw");
			cli_execute("clan_viplounge.php?action=klaw");
		}
		if(!get_property("_aprilShower").to_boolean())
		{
			if(get_property("kingLiberated").to_boolean())
			{
				cli_execute("shower ice");
			}
			else
			{
				cli_execute("shower " + my_primestat());
			}
		}
		if(is_unrestricted($item[Crimbough]) && !get_property("_crimboTree").to_boolean())
		{
			cli_execute("crimbotree get");
		}
		set_property("auto_clanstuff", ""+my_daycount());
	}

	if((get_property("sidequestOrchardCompleted") != "none") && !get_property("_hippyMeatCollected").to_boolean())
	{
		visit_url("shop.php?whichshop=hippy");
	}

	if((get_property("sidequestArenaCompleted") != "none") && !get_property("concertVisited").to_boolean())
	{
		cli_execute("concert 2");
	}
	if(get_property("kingLiberated").to_boolean())
	{
		if((item_amount($item[The Legendary Beat]) > 0) && !get_property("_legendaryBeat").to_boolean())
		{
			use(1, $item[The Legendary Beat]);
		}
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() == 0)
		{
			cli_execute("make unbearable light");
		}
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() == 1)
		{
			cli_execute("make cold-filtered water");
		}
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() == 2)
		{
			cli_execute("make bucket of wine");
		}
		if((item_amount($item[Handmade Hobby Horse]) > 0) && !get_property("_hobbyHorseUsed").to_boolean())
		{
			use(1, $item[Handmade Hobby Horse]);
		}
		if((item_amount($item[ball-in-a-cup]) > 0) && !get_property("_ballInACupUsed").to_boolean())
		{
			use(1, $item[ball-in-a-cup]);
		}
		if((item_amount($item[set of jacks]) > 0) && !get_property("_setOfJacksUsed").to_boolean())
		{
			use(1, $item[set of jacks]);
		}
	}

	if((my_daycount() - 5) >= get_property("lastAnticheeseDay").to_int())
	{
		visit_url("place.php?whichplace=desertbeach&action=db_nukehouse");
	}

	if(auto_haveWitchess() && (get_property("puzzleChampBonus").to_int() == 20) && !get_property("_witchessBuff").to_boolean())
	{
		visit_url("campground.php?action=witchess");
		visit_url("choice.php?whichchoice=1181&pwd=&option=3");
		visit_url("choice.php?whichchoice=1183&pwd=&option=2");
	}

	if(auto_haveSourceTerminal())
	{
		int enhances = auto_sourceTerminalEnhanceLeft();
		while(enhances > 0)
		{
			auto_sourceTerminalEnhance("items");
			auto_sourceTerminalEnhance("meat");
			enhances -= 2;
		}
	}

	// Is +50% to all stats the best choice here? I don't know!
	spacegateVaccine($effect[Broad-Spectrum Vaccine]);

	zataraSeaside("item");

	if(is_unrestricted($item[Source Terminal]) && (get_campground() contains $item[Source Terminal]))
	{
		if(!get_property("_kingLiberated").to_boolean() && (get_property("auto_extrudeChoice") != "none"))
		{
			int count = 3 - get_property("_sourceTerminalExtrudes").to_int();

			string[int] extrudeChoice;
			if(get_property("auto_extrudeChoice") != "")
			{
				string[int] extrudeDays = split_string(get_property("auto_extrudeChoice"), ":");
				string[int] tempChoice = split_string(trim(extrudeDays[min(count(extrudeDays), my_daycount()) - 1]), ";");
				for(int i=0; i<count(tempChoice); i++)
				{
					extrudeChoice[i] = tempChoice[i];
				}
			}
			int amt = count(extrudeChoice);
			string acquire = "booze";
			if(auto_my_path() == "Teetotaler")
			{
				acquire = "food";
			}
			while(amt < 3)
			{
				extrudeChoice[count(extrudeChoice)] = acquire;
				amt++;
			}

			while((count > 0) && (item_amount($item[Source Essence]) >= 10))
			{
				auto_sourceTerminalExtrude(extrudeChoice[3-count]);
				count -= 1;
			}
		}
		int extrudeLeft = 3 - get_property("_sourceTerminalExtrudes").to_int();
		if((extrudeLeft > 0) && (auto_my_path() != "Pocket Familiars") && (item_amount($item[Source Essence]) >= 10))
		{
			auto_log_info("You still have " + extrudeLeft + " Source Extrusions left", "blue");
		}
	}

	auto_burnPowerfulGloveCharges();

	if(item_amount($item[Rain-Doh Indigo Cup]) > 0)
	{
		auto_log_info("Copies left: " + (5 - get_property("_raindohCopiesMade").to_int()), "olive");
	}
	if(!in_hardcore())
	{
		auto_log_info("Pulls remaining: " + pulls_remaining(), "olive");
	}

	if(have_skill($skill[Inigo\'s Incantation of Inspiration]))
	{
		int craftingLeft = 5 - get_property("_inigosCasts").to_int();
		auto_log_info("Free Inigo\'s craftings left: " + craftingLeft, "blue");
	}
	if(item_amount($item[Loathing Legion Jackhammer]) > 0)
	{
		int craftingLeft = 3 - get_property("_legionJackhammerCrafting").to_int();
		auto_log_info("Free Loathing Legion Jackhammer craftings left: " + craftingLeft, "blue");
	}
	if(item_amount($item[Thor\'s Pliers]) > 0)
	{
		int craftingLeft = 10 - get_property("_thorsPliersCrafting").to_int();
		auto_log_info("Free Thor's Pliers craftings left: " + craftingLeft, "blue");
	}
	if(freeCrafts() > 0)
	{
		auto_log_info("Free craftings left: " + freeCrafts(), "blue");
	}
	if(get_property("timesRested").to_int() < total_free_rests())
	{
		cs_spendRests();
		auto_log_info("You have " + (total_free_rests() - get_property("timesRested").to_int()) + " free rests remaining.", "blue");
	}
	if(possessEquipment($item[Kremlin\'s Greatest Briefcase]) && (get_property("_kgbClicksUsed").to_int() < 24))
	{
		kgbWasteClicks();
		int clicks = 22 - get_property("_kgbClicksUsed").to_int();
		if(clicks > 0)
		{
			auto_log_info("You have some KGB clicks (" + clicks + ") left!", "green");
		}
	}
	if((get_property("sidequestNunsCompleted") == "fratboy") && (get_property("nunsVisits").to_int() < 3))
	{
		auto_log_info("You have " + (3 - get_property("nunsVisits").to_int()) + " nuns visits left.", "blue");
	}
	if(get_property("libramSummons").to_int() > 0)
	{
		auto_log_info("Total Libram Summons: " + get_property("libramSummons"), "blue");
	}

	int smiles = (5 * (item_amount($item[Golden Mr. Accessory]) + storage_amount($item[Golden Mr. Accessory]) + closet_amount($item[Golden Mr. Accessory]))) - get_property("_smilesOfMrA").to_int();
	if(auto_my_path() == "G-Lover")
	{
		smiles = 0;
	}
	if(smiles > 0)
	{
		if(get_property("auto_smileAt") != "")
		{
			cli_execute("/cast " + smiles + " the smile @ " + get_property("auto_smileAt"));
		}
		else
		{
			auto_log_info("You have " + smiles + " smiles of Mr. A remaining.", "blue");
		}
	}

	if((item_amount($item[CSA Fire-Starting Kit]) > 0) && (!get_property("_fireStartingKitUsed").to_boolean()))
	{
		auto_log_info("Still have a CSA Fire-Starting Kit you can use!", "blue");
	}
	if((item_amount($item[Glenn\'s Golden Dice]) > 0) && (!get_property("_glennGoldenDiceUsed").to_boolean()))
	{
		auto_log_info("Still have some of Glenn's Golden Dice that you can use!", "blue");
	}
	if((item_amount($item[License to Chill]) > 0) && (!get_property("_licenseToChillUsed").to_boolean()))
	{
		auto_log_info("You are still licensed enough to be able to chill.", "blue");
	}

	if((item_amount($item[School of Hard Knocks Diploma]) > 0) && (!get_property("_hardKnocksDiplomaUsed").to_boolean()))
	{
		use(1, $item[School of Hard Knocks Diploma]);
	}

	if(!get_property("_lyleFavored").to_boolean())
	{
		string temp = visit_url("place.php?whichplace=monorail&action=monorail_lyle");
	}

	if (get_property("spookyAirportAlways").to_boolean() && !isActuallyEd() && !get_property("_controlPanelUsed").to_boolean())
	{
		visit_url("place.php?whichplace=airport_spooky_bunker&action=si_controlpanel");
		visit_url("choice.php?pwd=&whichchoice=986&option=8",true);
		if(get_property("controlPanelOmega").to_int() >= 99)
		{
			visit_url("choice.php?pwd=&whichchoice=986&option=10",true);
		}
	}

	elementalPlanes_takeJob($element[spooky]);
	elementalPlanes_takeJob($element[stench]);
	elementalPlanes_takeJob($element[cold]);

	if((get_property("auto_dickstab").to_boolean()) && chateaumantegna_available() && (my_daycount() == 1))
	{
		boolean[item] furniture = chateaumantegna_decorations();
		if(!furniture[$item[Artificial Skylight]])
		{
			chateaumantegna_buyStuff($item[Artificial Skylight]);
		}
	}

	auto_beachUseFreeCombs();

	boolean done = (my_inebriety() > inebriety_limit()) || (my_inebriety() == inebriety_limit() && my_familiar() == $familiar[Stooper]);
	if((my_class() == $class[Gelatinous Noob]) || !can_drink() || out_of_blood)
	{
		if((my_adventures() <= 2) || (internalQuestStatus("questL13Final") >= 14))
		{
			done = true;
		}
	}
	if(!done)
	{
		auto_log_info("Goodnight done, please make sure to handle your overdrinking, then you can run me again.", "blue");
		if(auto_have_familiar($familiar[Stooper]) && (inebriety_left() == 0) && (my_familiar() != $familiar[Stooper]) && (auto_my_path() != "Pocket Familiars"))
		{
			auto_log_info("You have a Stooper, you can increase liver by 1!", "blue");
			use_familiar($familiar[Stooper]);
		}
		if(auto_have_familiar($familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 5))
		{
			auto_log_info("You have " + (5 - get_property("_machineTunnelsAdv").to_int()) + " fights in The Deep Machine Tunnels that you should use!", "blue");
		}
		if((my_inebriety() <= inebriety_limit()) && (my_rain() >= 50) && (my_adventures() >= 1))
		{
			auto_log_info("You have a rain man to cast, please do so before overdrinking and then run me again.", "red");
			return false;
		}
		auto_autoDrinkNightcap(true); // simulate;
		auto_log_warning("You need to overdrink and then run me again. Beep.", "red");
		if(have_skill($skill[The Ode to Booze]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 0, 1, 1);
		}
		return false;
	}
	else
	{
		if(!get_property("kingLiberated").to_boolean())
		{
			auto_log_info(get_property("auto_banishes_day" + my_daycount()));
			auto_log_info(get_property("auto_yellowRay_day" + my_daycount()));
			pullsNeeded("evaluate");
			if(!get_property("_photocopyUsed").to_boolean() && (is_unrestricted($item[Deluxe Fax Machine])) && (my_adventures() > 0) && !($classes[Avatar of Boris, Avatar of Sneaky Pete] contains my_class()) && (item_amount($item[Clan VIP Lounge Key]) > 0))
			{
				auto_log_info("You may have a fax that you can use. Check it out!", "blue");
			}
			if((pulls_remaining() > 0) && (my_daycount() == 1))
			{
				string consider = "";
				boolean[item] cList;
				cList = $items[Antique Machete, wet stew, blackberry galoshes, drum machine, killing jar];
				if((my_class() == $class[Avatar of Boris]) || (item_amount($item[Muculent Machete]) != 0))
				{
					cList = $items[wet stew, blackberry galoshes, drum machine, killing jar];
				}
				foreach it in cList
				{
					if(!possessEquipment(it))
					{
						if(consider == "")
						{
							consider = consider + it;
						}
						else
						{
							consider = consider + ", " + it;
						}
					}
				}
				auto_log_warning("You still have pulls, consider: " + consider + "?", "red");
			}
		}

		if(have_skill($skill[Calculate the Universe]) && (get_property("_universeCalculated").to_int() < get_property("skillLevel144").to_int()))
		{
			auto_log_info("You can still Calculate the Universe!", "blue");
		}

		if(is_unrestricted($item[Deck of Every Card]) && (item_amount($item[Deck of Every Card]) > 0) && (get_property("_deckCardsDrawn").to_int() < 15))
		{
			auto_log_info("You have a Deck of Every Card and " + (15 - get_property("_deckCardsDrawn").to_int()) + " draws remaining!", "blue");
		}

		if(is_unrestricted($item[Time-Spinner]) && (item_amount($item[Time-Spinner]) > 0) && (get_property("_timeSpinnerMinutesUsed").to_int() < 10) && glover_usable($item[Time-Spinner]))
		{
			auto_log_info("You have " + (10 - get_property("_timeSpinnerMinutesUsed").to_int()) + " minutes left to Time-Spinner!", "blue");
		}

		if(is_unrestricted($item[Chateau Mantegna Room Key]) && !get_property("_chateauMonsterFought").to_boolean() && get_property("chateauAvailable").to_boolean())
		{
			auto_log_info("You can still fight a Chateau Mangtegna Painting today.", "blue");
		}

		if(stills_available() > 0)
		{
			auto_log_info("You have " + stills_available() + " uses of Nash Crosby's Still left.", "blue");
		}

		if(!get_property("_streamsCrossed").to_boolean() && possessEquipment($item[Protonic Accelerator Pack]))
		{
			cli_execute("crossstreams");
		}

		if(is_unrestricted($item[shrine to the Barrel God]) && !get_property("_barrelPrayer").to_boolean() && get_property("barrelShrineUnlocked").to_boolean())
		{
			auto_log_info("You can still worship the barrel god today.", "blue");
		}
		if(is_unrestricted($item[Airplane Charter: Dinseylandfill]) && !get_property("_dinseyGarbageDisposed").to_boolean() && elementalPlanes_access($element[stench]))
		{
			if((item_amount($item[bag of park garbage]) > 0) || (pulls_remaining() > 0))
			{
				auto_log_info("You can still dispose of Garbage in Dinseyland.", "blue");
			}
		}
		if(is_unrestricted($item[Airplane Charter: That 70s Volcano]) && !get_property("_infernoDiscoVisited").to_boolean() && elementalPlanes_access($element[hot]))
		{
			if((item_amount($item[Smooth Velvet Hat]) > 0) || (item_amount($item[Smooth Velvet Shirt]) > 0) || (item_amount($item[Smooth Velvet Pants]) > 0) || (item_amount($item[Smooth Velvet Hanky]) > 0) || (item_amount($item[Smooth Velvet Pocket Square]) > 0) || (item_amount($item[Smooth Velvet Socks]) > 0))
			{
				auto_log_info("You can still disco inferno at the Inferno Disco.", "blue");
			}
		}
		if(is_unrestricted($item[Potted Tea Tree]) && !get_property("_pottedTeaTreeUsed").to_boolean() && (auto_get_campground() contains $item[Potted Tea Tree]))
		{
			auto_log_info("You have a tea tree to shake!", "blue");
		}

		auto_log_info("You are probably done for today, beep.", "blue");
		return true;
	}
	return false;
}

boolean powerLevelAdjustment()
{
	if(get_property("auto_powerLevelLastLevel").to_int() != my_level() && get_property("auto_powerLevelAdvCount").to_int() > 0)
	{
		set_property("auto_powerLevelLastLevel", my_level());
		set_property("auto_powerLevelAdvCount", 0);
		return true;
	}
	return false;
}

boolean LX_attemptPowerLevel()
{
	set_property("auto_powerLevelAdvCount", get_property("auto_powerLevelAdvCount").to_int() + 1);
	set_property("auto_powerLevelLastAttempted", my_turncount());
	set_property("auto_powerLevelLastLevel", my_level());
	
	handleFamiliar("stat");
	addToMaximize("100 exp");
	
	auto_log_warning("I need to powerlevel", "red");
	int delay = get_property("auto_powerLevelTimer").to_int();
	if(delay == 0)
	{
		delay = 10;
	}
	wait(delay);

	if(LX_freeCombats(true)) return true;
	
	if(chateaumantegna_available() && haveFreeRestAvailable() && auto_my_path() != "The Source")
	{
		doFreeRest();
		cli_execute("scripts/autoscend/auto_post_adv.ash");
		loopHandlerDelayAll();
		return true;
	}
	
	//The Source path specific powerleveling
	LX_attemptPowerLevelTheSource();

	//scaling damage zones
	if(elementalPlanes_access($element[stench]) && auto_have_skill($skill[Summon Smithsness]) && (get_property("auto_beatenUpCount").to_int() == 0))
	{
		if(autoAdv($location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice])) return true;
	}
	if(elementalPlanes_access($element[spooky]))
	{
		if(autoAdv($location[The Deep Dark Jungle])) return true;
	}
	if(elementalPlanes_access($element[cold]))
	{
		if(autoAdv($location[VYKEA])) return true;
	}
	if(elementalPlanes_access($element[sleaze]))
	{
		if(autoAdv($location[Sloppy Seconds Diner])) return true;
	}
	if (elementalPlanes_access($element[hot]))
	{
		if(autoAdv($location[The SMOOCH Army HQ])) return true;
	}
	if (neverendingPartyAvailable())
	{
		if(neverendingPartyPowerlevel()) return true;
	}
	//do not use the scaling zone [The Thinknerd Warehouse] here.
	//it has low stat caps on the scaling, resulting in <30 substats per adv

	// use spare clovers to powerlevel
	int cloverLimit = get_property("auto_wandOfNagamar").to_boolean() ? 1 : 0;
	if(my_level() >= 12 && internalQuestStatus("questL12War") > 1 && cloversAvailable() > cloverLimit)
	{
		//Determine where to go for clover stats, do not worry about clover failures
		location whereTo = $location[none];
		switch (my_primestat())
		{
			case $stat[Muscle]:
				whereTo = $location[The Haunted Gallery];
				break;
			case $stat[Mysticality]:
				whereTo = $location[The Haunted Bathroom];
				break;
			case $stat[Moxie]:
				whereTo = $location[The Haunted Ballroom];
				break;
		}

		cloverUsageInit();
		boolean adv_spent = autoAdv(whereTo);
		cloverUsageFinish();
		if(adv_spent) return true;
	}

	// [Haunted Gallery] is the optimal powerleveling spot if you have no scaling monsters nor clovers left.
	if (internalQuestStatus("questM21Dance") > 3)
	{
		switch (my_primestat())
		{
			case $stat[Muscle]:
				set_property("louvreDesiredGoal", "4"); // get Muscle stats
				break;
			case $stat[Mysticality]:
				set_property("louvreDesiredGoal", "5"); // get Myst stats
				break;
			case $stat[Moxie]:
				set_property("louvreDesiredGoal", "6"); // get Moxie stats
				break;
		}
		if (isActuallyEd() && (!possessEquipment($item[serpentine sword]) || !possessEquipment($item[snake shield])))
		{
			set_property("choiceAdventure89", "2"); // fight the snake knight (as Ed)
		}
		else
		{
			set_property("choiceAdventure89", "6"); // ignore the NC & banish it for 10 adv
		}
		providePlusNonCombat(25);
		if(autoAdv($location[The Haunted Gallery])) return true;
	}
	
	return false;
}

boolean disregardInstantKarma()
{
	//under level 13 we wan to get max XP. level 14+ we already missed the insta karma, no need to hold back anymore.
	return my_level() != 13 || get_property("auto_disregardInstantKarma").to_boolean();
}

int auto_freeCombatsRemaining()
{
	return auto_freeCombatsRemaining(false);
}

int auto_freeCombatsRemaining(boolean print_remaining_fights)
{

	void debugPrint(string msg)
	{
	  if (!print_remaining_fights) return;
	  print(msg, "red");
	}

	int count = 0;
	
	debugPrint("Remaining Free Fights:");
	if(!in_koe() && canChangeToFamiliar($familiar[Machine Elf]))
	{
		int temp = 5-get_property("_machineTunnelsAdv").to_int();
		count += temp;
		debugPrint("Machine Elf = " + temp);
	}
	if(snojoFightAvailable())
	{
		int temp = 10-get_property("_snojoFreeFights").to_int();
		count += temp;
		debugPrint("Snojo = " + temp);
	}
	if(canChangeToFamiliar($familiar[God Lobster]) && disregardInstantKarma())
	{
		int temp = 3-get_property("_godLobsterFights").to_int();
		count += temp;
		debugPrint("God Lobster = " + temp);
	}
	if(neverendingPartyRemainingFreeFights() > 0)
	{
		int temp = neverendingPartyRemainingFreeFights();
		count += temp;
		debugPrint("Neverending Party = " + temp);
	}
	if(get_property("_eldritchTentacleFought").to_boolean() == false)
	{
		count++;
		debugPrint("Tent Tentacle = 1");
	}
	if(auto_have_skill($skill[Evoke Eldritch Horror]) && get_property("_eldritchHorrorEvoked").to_boolean() == false)
	{
		count++;
		debugPrint("Evoke Eldritch = 1");
	}
	
	return count;
}

boolean LX_freeCombats()
{
	return LX_freeCombats(disregardInstantKarma());
}

boolean LX_freeCombats(boolean powerlevel)
{
	if(auto_freeCombatsRemaining() == 0)
	{
		auto_log_debug("Could not use free combats because you have none");
		return false;
	}
	
	if(my_inebriety() > inebriety_limit())
	{
		auto_log_debug("Could not use free combats because you are overdrunk");
		return false;
	}
	
	if(my_adventures() == 0)
	{
		auto_log_warning("Could not use free combats because you are out of adventures", "red");
		return false;
	}
	
	if(my_adventures() < 2)
	{
		auto_freeCombatsRemaining(true);		//print remaining free combats.
		auto_log_warning("Too few adventures to safely automate free combats", "red");
		auto_log_warning("If we lose your last adv on a free combat the remaining free combats are wasted", "red");
		auto_log_warning("This should only happen if you lost a free fight. If you did not then please report this", "red");
		abort("Please perform the remaining free combats manually then run me again");
	}
	
	auto_log_debug("LX_freeCombats active with powerlevel set to " + powerlevel);
	
	resetMaximize();
	if(disregardInstantKarma())
	{
		handleFamiliar("stat");
	}

	if(neverendingPartyRemainingFreeFights() > 0)
	{
		if(powerlevel)
		{
			auto_log_debug("LX_freeCombats is calling neverendingPartyPowerlevel()");
			if(neverendingPartyPowerlevel()) return true;
		}
		else
		{
			auto_log_debug("LX_freeCombats is calling neverendingPartyCombat()");
			if(neverendingPartyCombat()) return true;
		}
	}
	
	boolean adv_done = false;

	if(!in_koe() && get_property("_machineTunnelsAdv").to_int() < 5 && canChangeToFamiliar($familiar[Machine Elf]))
	{
		auto_log_debug("LX_freeCombats is adventuring in [The Deep Machine Tunnels]");
		backupSetting("choiceAdventure1119", 1);

		familiar bjorn = my_bjorned_familiar();
		if(bjorn == $familiar[Machine Elf])
		{
			handleBjornify($familiar[Grinning Turtle]);
		}
		handleFamiliar($familiar[Machine Elf]);
		adv_done = autoAdv(1, $location[The Deep Machine Tunnels]);
		if(bjorn == $familiar[Machine Elf])
		{
			handleBjornify(bjorn);
		}

		loopHandlerDelayAll();
		if(adv_done) return true;
	}

	if(snojoFightAvailable())
	{
		auto_log_debug("LX_freeCombats is adventuring in [The Snojo]");
		adv_done = autoAdv(1, $location[The X-32-F Combat Training Snowman]);
		loopHandlerDelayAll();
		if(adv_done) return true;
	}

	if(powerlevel)
	{
		auto_log_debug("LX_freeCombats is calling godLobsterCombat()");
		if(godLobsterCombat()) return true;
	}
	
	if(get_property("_eldritchTentacleFought").to_boolean() == false)
	{
		auto_log_debug("LX_freeCombats is calling fightScienceTentacle()");
		if(fightScienceTentacle()) return true;
	}
	
	if(auto_have_skill($skill[Evoke Eldritch Horror]) && get_property("_eldritchHorrorEvoked").to_boolean() == false)
	{
		auto_log_debug("LX_freeCombats is calling evokeEldritchHorror()");
		if(evokeEldritchHorror()) return true;
	}
	
	if(auto_freeCombatsRemaining() == 0)
	{
		auto_log_debug("I reached the end of LX_freeCombats() but I think the following free combats were not used for some reason:");
		auto_freeCombatsRemaining(true);		//print remaining free combats.
	}

	return false;
}

boolean Lsc_flyerSeals()
{
	if(my_class() != $class[Seal Clubber])
	{
		return false;
	}
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}
	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}
	if(get_property("flyeredML").to_int() >= 10000)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}
	if(get_property("choiceAdventure1003").to_int() >= 3)
	{
		return false;
	}

	if((get_property("_sealsSummoned").to_int() < maxSealSummons()) && (my_meat() > 500))
	{
		element towerTest = ns_crowd3();
		boolean doElement = false;
		if(item_amount($item[powdered sealbone]) > 0)
		{
			if((towerTest == $element[cold]) && (item_amount($item[frost-rimed seal hide]) < 2) && (item_amount($item[figurine of a cold seal]) > 0))
			{
				doElement = true;
			}
			if((towerTest == $element[hot]) && (item_amount($item[sizzling seal fat]) < 2) && (item_amount($item[figurine of a charred seal]) > 0))
			{
				doElement = true;
			}
			if((towerTest == $element[sleaze]) && (item_amount($item[seal lube]) < 2) && (item_amount($item[figurine of a slippery seal]) > 0))
			{
				doElement = true;
			}
			if((towerTest == $element[spooky]) && (item_amount($item[scrap of shadow]) < 2) && (item_amount($item[figurine of a shadowy seal]) > 0))
			{
				doElement = true;
			}
			if((towerTest == $element[stench]) && (item_amount($item[fustulent seal grulch]) < 2) && (item_amount($item[figurine of a stinking seal]) > 0))
			{
				doElement = true;
			}
		}

		handleFamiliar("initSuggest");
		boolean clubbedSeal = false;
		if(doElement)
		{
			if((item_amount($item[imbued seal-blubber candle]) == 0) && guild_store_available())
			{
				buyUpTo(1, $item[seal-blubber candle]);
				cli_execute("make imbued seal-blubber candle");
			}
			if(item_amount($item[Imbued Seal-Blubber Candle]) > 0)
			{
				ensureSealClubs();
				handleSealElement(towerTest);
				clubbedSeal = true;
			}
		}
		else if(guild_store_available() && isHermitAvailable())
		{
			buyUpTo(1, $item[figurine of an armored seal]);
			buyUpTo(10, $item[seal-blubber candle]);
			if((item_amount($item[Figurine of an Armored Seal]) > 0) && (item_amount($item[Seal-Blubber Candle]) >= 10))
			{
				handleSealNormal($item[Figurine of an Armored Seal]);
				clubbedSeal = true;
			}
		}
		if((item_amount($item[bad-ass club]) == 0) && (item_amount($item[ingot of seal-iron]) > 0) && have_skill($skill[Super-Advanced Meatsmithing]))
		{
			if((item_amount($item[Tenderizing Hammer]) == 0) && ((my_meat() >= (npc_price($item[Tenderizing Hammer]) * 2)) && (npc_price($item[Tenderizing Hammer]) != 0)))
			{
				buyUpTo(1, $item[Tenderizing Hammer]);
			}
			if(item_amount($item[Tenderizing Hammer]) > 0)
			{
				use(1, $item[ingot of seal-iron]);
			}
		}
		handleFamiliar("item");
		return clubbedSeal;
	}
	return false;
}

boolean LX_hardcoreFoodFarm()
{
	if(!in_hardcore() || !isGuildClass())
	{
		return false;
	}
	if(my_fullness() >= 11)
	{
		return false;
	}

	if(my_level() < 8)
	{
		return false;
	}

	// If we are in TCRS we don't know what food is good, we don't want to waste adv.
	if(in_tcrs())
	{
		return false;
	}

	int possMeals = item_amount($item[Goat Cheese]);
	possMeals = possMeals + item_amount($item[Bubblin\' Crude]);

	if((my_fullness() >= 5) && (possMeals > 0))
	{
		return false;
	}
	if(possMeals > 1)
	{
		return false;
	}

	if((my_daycount() >= 3) && (my_adventures() > 15))
	{
		return false;
	}
	if(my_daycount() >= 4)
	{
		return false;
	}

	if (internalQuestStatus("questL09Topping") > 2)
	{
		autoAdv(1, $location[Oil Peak]);
		return true;
	}
	if(my_level() >= 8)
	{
		if(get_property("_sourceTerminalDuplicateUses").to_int() == 0)
		{
			auto_sourceTerminalEducate($skill[Extract], $skill[Duplicate]);
		}
		autoAdv(1, $location[The Goatlet]);
		auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
	}

	return false;
}

boolean LX_craftAcquireItems()
{
	if((item_amount($item[Ten-Leaf Clover]) > 0) && glover_usable($item[Ten-Leaf Clover]))
	{
		use(item_amount($item[Ten-Leaf Clover]), $item[Ten-Leaf Clover]);
	}

	if((get_property("lastGoofballBuy").to_int() != my_ascensions()) && (internalQuestStatus("questL03Rat") >= 0))
	{
		visit_url("place.php?whichplace=woods");
		auto_log_info("Gotginb Goofballs", "blue");
		visit_url("tavern.php?place=susguy&action=buygoofballs", true);
		put_closet(item_amount($item[Bottle of Goofballs]), $item[Bottle of Goofballs]);
	}

	auto_floundryUse();

	if(in_hardcore())
	{
		if(have_effect($effect[Adventurer\'s Best Friendship]) > 120)
		{
			set_property("choiceAdventure1106", 3);
		}
		else
		{
			set_property("choiceAdventure1106", 2);
		}
	}
	else
	{
		if((have_effect($effect[Adventurer\'s Best Friendship]) > 30) && auto_have_familiar($familiar[Mosquito]))
		{
			set_property("choiceAdventure1106", 3);
		}
		else
		{
			set_property("choiceAdventure1106", 2);
		}
	}

	// Snow Berries can be acquired out of standard by using Van Keys from NEP. We need to check to make sure they are usable.
	if(auto_is_valid($item[snow berries]))
	{
		if((item_amount($item[snow berries]) == 3) && (my_daycount() == 1) && get_property("auto_grimstoneFancyOilPainting").to_boolean())
		{
			cli_execute("make 1 snow cleats");
		}

		if((item_amount($item[snow berries]) > 0) && (my_daycount() > 1) && (get_property("chasmBridgeProgress").to_int() >= 30) && (my_level() >= 9))
		{
			visit_url("place.php?whichplace=orc_chasm");
			if(get_property("chasmBridgeProgress").to_int() >= 30)
			{
				#if(in_hardcore() && isGuildClass())
				if(isGuildClass())
				{
					if((item_amount($item[Snow Berries]) >= 3) && (item_amount($item[Ice Harvest]) >= 3) && (item_amount($item[Unfinished Ice Sculpture]) == 0))
					{
						cli_execute("make 1 Unfinished Ice Sculpture");
					}
					if((item_amount($item[Snow Berries]) >= 2) && (item_amount($item[Snow Crab]) == 0))
					{
						cli_execute("make 1 Snow Crab");
					}
				}
				#cli_execute("make " + item_amount($item[snow berries]) + " snow cleats");
			}
			else
			{
				abort("Bridge progress came up as >= 30 but is no longer after viewing the page.");
			}
		}
	}

	if(knoll_available() && (item_amount($item[Detuned Radio]) == 0) && (my_meat() >= npc_price($item[Detuned Radio])) && (auto_my_path() != "G-Lover"))
	{
		buyUpTo(1, $item[Detuned Radio]);
		auto_setMCDToCap();
		visit_url("choice.php?pwd&whichchoice=835&option=2", true);
	}

	if((my_adventures() <= 3) && (my_daycount() == 1) && in_hardcore())
	{
		if(LX_meatMaid())
		{
			return true;
		}
	}

	#Can we have some other way to check that we have AT skills? Checking all skills just to be sure.
	if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && isUnclePAvailable() && (my_meat() >= npc_price($item[Antique Accordion])) && (auto_predictAccordionTurns() < 10) && (auto_my_path() != "G-Lover"))
	{
		boolean buyAntiqueAccordion = false;

	foreach SongCheck in ATSongList()
		{
			if(have_skill(SongCheck))
			{
				buyAntiqueAccordion = true;
			}
		}

		if(buyAntiqueAccordion)
		{
			buyUpTo(1, $item[Antique Accordion]);
		}
	}

	if((my_meat() > 7500) && (item_amount($item[Seal Tooth]) == 0))
	{
		acquireHermitItem($item[Seal Tooth]);
	}

	if(my_class() == $class[Turtle Tamer])
	{
		if(!possessEquipment($item[Turtle Wax Shield]) && (item_amount($item[Turtle Wax]) > 0))
		{
			use(1, $item[Turtle Wax]);
		}
		if(have_skill($skill[Armorcraftiness]) && !possessEquipment($item[Painted Shield]) && (my_meat() > 3500) && (item_amount($item[Painted Turtle]) > 0) && (item_amount($item[Tenderizing Hammer]) > 0))
		{
			// Make Painted Shield - Requires an Adventure
		}
		if(have_skill($skill[Armorcraftiness]) && !possessEquipment($item[Spiky Turtle Shield]) && (my_meat() > 3500) && (item_amount($item[Hedgeturtle]) > 1) && (item_amount($item[Tenderizing Hammer]) > 0))
		{
			// Make Spiky Turtle Shield - Requires an Adventure
		}
	}
	if((get_power(equipped_item($slot[pants])) < 70) && !possessEquipment($item[Demonskin Trousers]) && (my_meat() >= npc_price($item[Pants Kit])) && (item_amount($item[Demon Skin]) > 0) && (item_amount($item[Tenderizing Hammer]) > 0) && knoll_available())
	{
		buyUpTo(1, $item[Pants Kit]);
		autoCraft("smith", 1, $item[Pants Kit], $item[Demon Skin]);
	}
	if(!possessEquipment($item[Tighty Whiteys]) && (my_meat() >= npc_price($item[Pants Kit])) && (item_amount($item[White Snake Skin]) > 0) && (item_amount($item[Tenderizing Hammer]) > 0) && knoll_available())
	{
		buyUpTo(1, $item[Pants Kit]);
		autoCraft("smith", 1, $item[Pants Kit], $item[White Snake Skin]);
	}

	if(!possessEquipment($item[Grumpy Old Man Charrrm Bracelet]) && (item_amount($item[Jolly Roger Charrrm Bracelet]) > 0) && (item_amount($item[Grumpy Old Man Charrrm]) > 0))
	{
		use(1, $item[Jolly Roger Charrrm Bracelet]);
		use(1, $item[Grumpy Old Man Charrrm]);
	}

	if(!possessEquipment($item[Booty Chest Charrrm Bracelet]) && (item_amount($item[Jolly Roger Charrrm Bracelet]) > 0) && (item_amount($item[Booty Chest Charrrm]) > 0))
	{
		use(1, $item[Jolly Roger Charrrm Bracelet]);
		use(1, $item[Booty Chest Charrrm]);
	}

	if((item_amount($item[Magical Baguette]) > 0) && !possessEquipment($item[Loafers]))
	{
		visit_url("inv_use.php?pwd=&which=1&whichitem=8167");
		run_choice(2);
	}
	if((item_amount($item[Magical Baguette]) > 0) && !possessEquipment($item[Bread Basket]))
	{
		visit_url("inv_use.php?pwd=&which=1&whichitem=8167");
		run_choice(3);
	}
	if((item_amount($item[Magical Baguette]) > 0) && !possessEquipment($item[Breadwand]))
	{
		visit_url("inv_use.php?pwd=&which=1&whichitem=8167");
		run_choice(1);
	}

	if(knoll_available() && (have_skill($skill[Torso Awaregness]) || have_skill($skill[Best Dressed])) && (item_amount($item[Demon Skin]) > 0) && !possessEquipment($item[Demonskin Jacket]))
	{
		//Demonskin Jacket, requires an adventure, knoll available doesn\'t matter here...
	}

	if (in_koe())
	{
		if ((creatable_amount($item[Antique Accordion]) > 0 && !possessEquipment($item[Antique Accordion])) && auto_predictAccordionTurns() < 10)
		{
			retrieve_item(1, $item[Antique Accordion]);
		}
		if(creatable_amount($item[low-pressure oxygen tank]) > 0 && !possessEquipment($item[low-pressure oxygen tank]))
		{
			retrieve_item(1, $item[low-pressure oxygen tank]);
		}
	}

	LX_dolphinKingMap();
	auto_mayoItems();

	if(item_amount($item[Metal Meteoroid]) > 0 && !in_tcrs())
	{
		item it = $item[Meteorthopedic Shoes];
		if(!possessEquipment(it))
		{
			int choice = 1 + to_int(it) - to_int($item[Meteortarboard]);
			string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9516");
			temp = visit_url("choice.php?pwd=&whichchoice=1264&option=" + choice);
		}

		it = $item[Meteortarboard];
		if(!possessEquipment(it) && (get_power(equipped_item($slot[Hat])) < 140) && (get_property("auto_beatenUpCount").to_int() >= 5))
		{
			int choice = 1 + to_int(it) - to_int($item[Meteortarboard]);
			string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9516");
			temp = visit_url("choice.php?pwd=&whichchoice=1264&option=" + choice);
		}

		it = $item[Meteorite Guard];
		if(!possessEquipment(it) && !possessEquipment($item[Kol Con 13 Snowglobe]) && (get_property("auto_beatenUpCount").to_int() >= 5))
		{
			int choice = 1 + to_int(it) - to_int($item[Meteortarboard]);
			string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=9516");
			temp = visit_url("choice.php?pwd=&whichchoice=1264&option=" + choice);
		}
	}

	if(auto_my_path() != "Community Service")
	{
		if(item_amount($item[Portable Pantogram]) > 0)
		{
			switch(my_daycount())
			{
			case 1:
				pantogramPants(my_primestat(), $element[hot], 1, 1, 1);
				break;
			default:
				pantogramPants(my_primestat(), $element[cold], 1, 2, 1);
				break;
			}
		}
		mummifyFamiliar($familiar[Intergnat], my_primestat());
		mummifyFamiliar($familiar[Hobo Monkey], "meat");
		mummifyFamiliar($familiar[XO Skeleton], "mpregen");
		#set_property("_dailyCreates", true);
	}

	return false;
}

boolean councilMaintenance()
{
	if (auto_my_path() == "Community Service" || in_koe())
	{
		return false;
	}
	if(my_level() > get_property("lastCouncilVisit").to_int())
	{
		council();
		if (isActuallyEd() && my_level() == 11 && item_amount($item[7961]) > 0)
		{
			cli_execute("refresh inv");
		}
		return true;
	}
	return false;
}

boolean adventureFailureHandler()
{
	if(my_location().turns_spent > 52)
	{
		boolean tooManyAdventures = false;
		if (($locations[The Battlefield (Frat Uniform), The Battlefield (Hippy Uniform), The Deep Dark Jungle, The Neverending Party, Noob Cave, Pirates of the Garbage Barges, The Secret Government Laboratory, Sloppy Seconds Diner, The SMOOCH Army HQ, Super Villain\'s Lair, Uncle Gator\'s Country Fun-Time Liquid Waste Sluice, VYKEA, The X-32-F Combat Training Snowman, The Exploaded Battlefield, The Arrrboretum] contains my_location()) == false)
		{
			tooManyAdventures = true;
		}

		if(tooManyAdventures && (my_path() == "The Source"))
		{
			if($locations[The Haunted Ballroom, The Haunted Bathroom, The Haunted Bedroom, The Haunted Gallery] contains my_location())
			{
				tooManyAdventures = false;
			}
		}

		if(tooManyAdventures && isActuallyEd())
		{
			if ($location[Hippy Camp] == my_location())
			{
				tooManyAdventures = false;
			}
		}

		if ($locations[The Haunted Gallery] contains my_location() && my_location().turns_spent < 100)
		{
			tooManyAdventures = false;
		}

		if(tooManyAdventures)
		{
			if(get_property("auto_newbieOverride").to_boolean())
			{
				set_property("auto_newbieOverride", false);
				auto_log_warning("We have spent " + my_location().turns_spent + " turns at '" + my_location() + "' and that is bad... override accepted.", "red");
			}
			else
			{
				auto_log_critical("You can set auto_newbieOverride = true to bypass this once.", "blue");
				abort("We have spent " + my_location().turns_spent + " turns at '" + my_location() + "' and that is bad... aborting.");
			}
		}
	}

	if(last_monster() == $monster[Crate])
	{
		if(get_property("auto_newbieOverride").to_boolean())
		{
			set_property("auto_newbieOverride", false);
		}
		else
		{
			abort("We went to the Noob Cave for reals... uh oh");
		}
	}
	else
	{
		set_property("auto_newbieOverride", false);
	}
	return false;
}

boolean beatenUpResolution(){

	if(have_effect($effect[Beaten Up]) > 0){
		if(get_property("auto_beatenUpCount").to_int() > 10){
			abort("We are getting beaten up too much, this is not good. Aborting.");
		}
		acquireHP();
	}

	if(have_effect($effect[Beaten Up]) > 0){
		cli_execute("refresh all");
	}
	return have_effect($effect[Beaten Up]) > 0;
}

int speculative_pool_skill()
{
	int expectPool = get_property("poolSkill").to_int();
	expectPool += min(10,to_int(2 * square_root(get_property("poolSharkCount").to_int())));
	if(my_inebriety() >= 10)
	{
		expectPool += (30 - (2 * my_inebriety()));
	}
	else
	{
		expectPool += my_inebriety();
	}
	if((have_effect($effect[Chalky Hand]) > 0) || (item_amount($item[Handful of Hand Chalk]) > 0))
	{
		expectPool += 3;
	}
	if(have_effect($effect[Chalked Weapon]) > 0)
	{
		expectPool += 5;
	}
	if(have_effect($effect[Influence of Sphere]) > 0)
	{
		expectPool += 5;
	}
	if(have_effect($effect[Video... Games?]) > 0)
	{
		expectPool += 5;
	}
	if(have_effect($effect[Swimming with Sharks]) > 0)
	{
		expectPool += 3;
	}
	return expectPool;
}

boolean autosellCrap()
{
	if((item_amount($item[dense meat stack]) > 1) && (item_amount($item[dense meat stack]) <= 10))
	{
		auto_autosell(1, $item[dense meat stack]);
	}
	foreach it in $items[Blue Money Bag, Red Money Bag, White Money Bag]
	{
		if(item_amount(it) > 0)
		{
			auto_autosell(item_amount(it), it);
		}
	}
	foreach it in $items[Ancient Vinyl Coin Purse, Bag Of Park Garbage, Black Pension Check, CSA Discount Card, Fat Wallet, Gathered Meat-Clip, Old Leather Wallet, Penultimate Fantasy Chest, Pixellated Moneybag, Old Coin Purse, Shiny Stones, Warm Subject Gift Certificate]
	{
		if((item_amount(it) > 0) && glover_usable(it) && is_unrestricted(it))
		{
			use(1, it);
		}
	}

	if(!in_hardcore() && !isGuildClass())
	{
		return false;
	}
	if(my_meat() > 6500)
	{
		return false;
	}

	if(item_amount($item[meat stack]) > 1)
	{
		auto_autosell(1, $item[meat stack]);
	}

	foreach it in $items[Anticheese, Awful Poetry Journal, Beach Glass Bead, Beer Bomb, Chaos Butterfly, Clay Peace-Sign Bead, Decorative Fountain, Dense Meat Stack, Empty Cloaca-Cola Bottle, Enchanted Barbell, Fancy Bath Salts, Frigid Ninja Stars, Feng Shui For Big Dumb Idiots, Giant Moxie Weed, Half of a Gold Tooth, Headless Sparrow, Imp Ale, Keel-Haulin\' Knife, Kokomo Resort Pass, Leftovers Of Indeterminate Origin, Mad Train Wine, Mangled Squirrel, Margarita, Meat Paste, Mineapple, Moxie Weed, Patchouli Incense Stick, Phat Turquoise Bead, Photoprotoneutron Torpedo, Plot Hole, Procrastination Potion, Rat Carcass, Smelted Roe, Spicy Jumping Bean Burrito, Spicy Bean Burrito, Strongness Elixir, Sunken Chest, Tambourine Bells, Tequila Sunrise, Uncle Jick\'s Brownie Mix, Windchimes]
	{
		if(item_amount(it) > 0)
		{
			auto_autosell(min(5,item_amount(it)), it);
		}
	}
	if(item_amount($item[hot wing]) > 3)
	{
		auto_autosell(item_amount($item[hot wing]) - 3, $item[hot wing]);
	}
	return true;
}

void print_header()
{
	if(my_thunder() > get_property("auto_lastthunder").to_int())
	{
		set_property("auto_lastthunderturn", "" + my_turncount());
		set_property("auto_lastthunder", "" + my_thunder());
	}
	if(in_hardcore())
	{
		auto_log_info("Turn(" + my_turncount() + "): Starting with " + my_adventures() + " left at Level: " + my_level(), "cyan");
	}
	else
	{
		auto_log_info("Turn(" + my_turncount() + "): Starting with " + my_adventures() + " left and " + pulls_remaining() + " pulls left at Level: " + my_level(), "cyan");
	}
	if(((item_amount($item[Rock Band Flyers]) == 1) || (item_amount($item[Jam Band Flyers]) == 1)) && (get_property("flyeredML").to_int() < 10000) && !get_property("auto_ignoreFlyer").to_boolean())
	{
		auto_log_info("Still flyering: " + get_property("flyeredML"), "blue");
	}
	auto_log_info("Encounter: " + combat_rate_modifier() + "   Exp Bonus: " + experience_bonus(), "blue");
	auto_log_info("Meat Drop: " + meat_drop_modifier() + "	 Item Drop: " + item_drop_modifier(), "blue");
	auto_log_info("HP: " + my_hp() + "/" + my_maxhp() + ", MP: " + my_mp() + "/" + my_maxmp() + ", Meat: " + my_meat(), "blue");
	auto_log_info("Tummy: " + my_fullness() + "/" + fullness_limit() + " Liver: " + my_inebriety() + "/" + inebriety_limit() + " Spleen: " + my_spleen_use() + "/" + spleen_limit(), "blue");
	auto_log_info("ML: " + monster_level_adjustment() + " control: " + current_mcd(), "blue");
	if(my_class() == $class[Sauceror])
	{
		auto_log_info("Soulsauce: " + my_soulsauce(), "blue");
	}
	if((have_effect($effect[Ultrahydrated]) > 0) && (get_property("desertExploration").to_int() < 100))
	{
		auto_log_info("Ultrahydrated: " + have_effect($effect[Ultrahydrated]), "violet");
	}
	if(have_effect($effect[Everything Looks Yellow]) > 0)
	{
		auto_log_info("Everything Looks Yellow: " + have_effect($effect[Everything Looks Yellow]), "blue");
	}
	if(equipped_item($slot[familiar]) == $item[Snow Suit])
	{
		auto_log_info("Snow suit usage: " + get_property("_snowSuitCount") + " carrots: " + get_property("_carrotNoseDrops"), "blue");
	}
	if(auto_my_path() == "Heavy Rains")
	{
		auto_log_info("Thunder: " + my_thunder() + " Rain: " + my_rain() + " Lightning: " + my_lightning(), "green");
	}
	if (isActuallyEd())
	{
		auto_log_info("Ka Coins: " + item_amount($item[Ka Coin]) + " Lashes used: " + get_property("_edLashCount"), "green");
	}
	if (in_zelda())
	{
		auto_log_info("Coins: " + item_amount($item[Coin]), "green");
	}
}

boolean doTasks()
{
	if(get_property("_casualAscension").to_int() >= my_ascensions())
	{	
		auto_log_warning("I think I'm in a casual ascension and should not run. To override: set _casualAscension = -1", "red");	
		return false;	
	}
	
	//These settings should never persist into another turn, ever.
	set_property("auto_doCombatCopy", "no");
	set_property("auto_disableFamiliarChanging", false);

	print_header();

	auto_interruptCheck();

	int delay = get_property("auto_delayTimer").to_int();
	if(delay != 0)
	{
		auto_log_info("Delay between adventures... beep boop... ", "blue");
		wait(delay);
	}

	int paranoia = get_property("auto_paranoia").to_int();
	boolean is_april_fools = today_to_string().substring(4) == "0401";
	if (is_april_fools)
	{
		auto_log_info("Salad april fools, so we paranoid salad.");
		cli_execute("refresh quests");
	}
	else if(paranoia != -1)
	{
		int paranoia_counter = get_property("auto_paranoia_counter").to_int();
		if(paranoia_counter >= paranoia)
		{
			auto_log_info("I think I'm paranoid and complicated", "blue");
			auto_log_info("I think I'm paranoid, manipulated", "blue");
			cli_execute("refresh quests");
			set_property("auto_paranoia_counter", 0);
		}
		else
		{
			set_property("auto_paranoia_counter", paranoia_counter + 1);
		}
	}
	if(get_property("auto_helpMeMafiaIsSuperBrokenAaah").to_boolean())
	{
		cli_execute("refresh inv");
	}

	// As soon as Shen gives us his first item request, we know what sequence of snakes we're getting.
	// This can't be done inside the L11 quest handling, in case the user manually begins the Shen quest.
	// This value is wrong if the user meets Shen, then runs autoscend on the following day.
	// That's OK, although it'll make our pathing a little funky.
	if (get_property("auto_shenStarted") == "" && (1 <= internalQuestStatus("questL11Shen")))
	{
		set_property("auto_shenStarted", my_daycount());
		auto_log_info("It seems Shen has given us a quest.", "blue");
		auto_log_info("I am going to avoid the following zones until Shen tells me to go there or until I run out of other things to do:");
		int linec = 1;
		foreach z, _ in shenZonesToAvoidBecauseMaybeSnake()
		{
			auto_log_info(linec++ + ". " + z);
		}
		auto_log_info("These zones will be incorrect if autoscend did not run on the day you manually met Shen..", "blue");
		auto_log_info("You can change these zones by changing the start date autoscend uses: set auto_shenStarted=2", "blue");
		auto_log_info("You can also disable this feature: set auto_shenSkipLastLevel=999.", "blue");

		auto_log_warning("This feature is super experimental. Please report any issues.", "red");
	}

	bat_formNone();
	horseDefault();
	resetMaximize();
	resetFlavour();

	basicAdjustML();
	powerLevelAdjustment();
	handleFamiliar("item");
	basicFamiliarOverrides();

	councilMaintenance();
	# This function buys missing skills in general, not just for Picky.
	# It should be moved.
	picky_buyskills();
	awol_buySkills();
	awol_useStuff();
	theSource_buySkills();
	zelda_buyStuff();

	oldPeoplePlantStuff();
	use_barrels();
	auto_latteRefill();

	//This just closets stuff so G-Lover does not mess with us.
	if(LM_glover())						return true;

	tophatMaker();
	xiblaxian_makeStuff();
	deck_useScheme("");
	autosellCrap();
	asdonAutoFeed();
	LX_craftAcquireItems();
	auto_spoonTuneMoon();

	ocrs_postCombatResolve();
	beatenUpResolution();
	groundhogSafeguard();


	//Early adventure options that we probably want
	if(dna_startAcquire())				return true;
	if(LM_boris())						return true;
	if(LM_pete())						return true;
	if(LM_jello())						return true;
	if(LM_fallout())					return true;
	if(LM_groundhog())					return true;
	if(LM_digimon())					return true;
	if(LM_majora())						return true;
	if(LM_batpath()) 					return true;
	if(doHRSkills())					return true;

	if(auto_my_path() != "Community Service")
	{
		cheeseWarMachine(0, 0, 0, 0);

		int turnGoal = 0;
		if (isActuallyEd() && !possessEquipment($item[The Crown Of Ed The Undying]))
		{
			turnGoal = 15;
		}

		if(my_turncount() >= turnGoal)
		{
			switch(my_daycount())
			{
			case 1:		loveTunnelAcquire(true, $stat[none], true, 1, true, 3);		break;
			case 2:		loveTunnelAcquire(true, $stat[none], true, 3, true, 1);		break;
			default:	loveTunnelAcquire(true, $stat[none], true, 2, true, 1);		break;
			}
		}
	}


	if(fortuneCookieEvent())			return true;
	if(theSource_oracle())				return true;
	if(LX_theSource())					return true;
	if(LX_ghostBusting())				return true;


	if(witchessFights())					return true;
	if(my_daycount() != 2)				doNumberology("adventures3");

	//
	//Adventuring actually starts here.
	//

	if(LA_cs_communityService())
	{
		return true;
	}
	if(auto_my_path() == "Community Service")
	{
		abort("Should not have gotten here, aborted LA_cs_communityService method allowed return to caller. Uh oh.");
	}

	auto_voteSetup(0,0,0);

	auto_setSongboom();

	if(LM_bond())						return true;
	if(LX_universeFrat())				return true;
	handleJar();
	adventureFailureHandler();

	dna_sorceressTest();
	dna_generic();

	if(get_property("auto_useCubeling").to_boolean())
	{
		if((item_amount($item[ring of detect boring doors]) == 1) && (item_amount($item[eleven-foot pole]) == 1) && (item_amount($item[pick-o-matic lockpicks]) == 1))
		{
			set_property("auto_cubeItems", false);
		}
		if(get_property("auto_cubeItems").to_boolean() && (my_familiar() != $familiar[Gelatinous Cubeling]) && auto_have_familiar($familiar[Gelatinous Cubeling]))
		{
			handleFamiliar($familiar[Gelatinous Cubeling]);
		}
	}

	if((my_daycount() == 1) && ($familiar[Fist Turkey].drops_today < 5) && auto_have_familiar($familiar[Fist Turkey]))
	{
		handleFamiliar($familiar[Fist Turkey]);
	}

	if(((my_hp() * 5) < my_maxhp()) && (my_mp() > 100))
	{
		acquireHP();
	}

	boolean weak_and_zelda = in_zelda() && !zelda_canDealScalingDamage();
	if(my_daycount() == 1)
	{
		if((my_adventures() < 10) && (my_level() >= 7) && (my_hp() > 0) && !weak_and_zelda)
		{
			fightScienceTentacle();
			if(my_mp() > (2 * mp_cost($skill[Evoke Eldritch Horror])))
			{
				evokeEldritchHorror();
			}
		}
	}
	else if((my_level() >= 9) && (my_hp() > 0) && !weak_and_zelda)
	{
		fightScienceTentacle();
		if(my_mp() > (2 * mp_cost($skill[Evoke Eldritch Horror])))
		{
			evokeEldritchHorror();
		}
	}
	if(my_adventures() == (1 + auto_advToReserve()) && inebriety_left() == 0 && stomach_left() < 1)
	{
		auto_log_debug("Only 1 non reserved adv remains for main loop so doing free combats");
		if(LX_freeCombats()) return true;
	}

	if(catBurglarHeist())			return true;
	if(chateauPainting())			return true;
	if(LX_faxing())						return true;
	if(LX_artistQuest())				return true;
	if(L5_findKnob())					return true;
	if(LM_edTheUndying())				return true;
	if(L12_sonofaPrefix())				return true;
	if(LX_burnDelay())					return true;

	if(snojoFightAvailable() && (my_daycount() == 2) && (get_property("snojoMoxieWins").to_int() == 10))
	{
		return autoAdv(1, $location[The X-32-F Combat Training Snowman]);
	}

	if(resolveSixthDMT())			return true;
	if(LX_dinseylandfillFunbucks())		return true;
	if(L12_flyerFinish())				return true;
	if(L12_getOutfit() || L12_startWar())
	{
		return true;
	}
	if(LX_loggingHatchet())				return true;
	if(LX_guildUnlock())				return true;
	if(knoll_available() && get_property("auto_spoonconfirmed").to_int() == my_ascensions())
	{
		if(LX_bitchinMeatcar())			return true;
	}
	if(LX_findHelpfulLowKey())			return true;
	if(LX_bitchinMeatcar())				return true;
	if(L5_getEncryptionKey())			return true;
	if(LX_handleSpookyravenNecklace())	return true;
	if(LX_unlockPirateRealm())			return true;
	if(handleRainDoh())				return true;
	if(routineRainManHandler())			return true;
	if(LX_handleSpookyravenFirstFloor())return true;

	if(!get_property("auto_slowSteelOrgan").to_boolean() && get_property("auto_getSteelOrgan").to_boolean())
	{
		if(L6_friarsGetParts())				return true;
		if(LX_steelOrgan())					return true;
	}

	if(L4_batCave())					return true;
	if(L2_mosquito())					return true;
	if(L2_treeCoin())					return true;
	if(L2_spookyMap())					return true;
	if(L2_spookyFertilizer())			return true;
	if(L2_spookySapling())				return true;
	if(L6_dakotaFanning())				return true;
	if(L5_haremOutfit())				return true;
	if(LX_phatLootToken())				return true;
	if(L5_goblinKing())					return true;
	if(LX_islandAccess())				return true;

	if(in_hardcore() && isGuildClass())
	{
		if(L6_friarsGetParts())
		{
			return true;
		}
	}

	if(LX_spookyravenSecond())			return true;
	if(L3_tavern())						return true;
	if(L6_friarsGetParts())				return true;
	if(LX_hardcoreFoodFarm())			return true;

	if(in_hardcore() && LX_steelOrgan())
	{
		return true;
	}

	if(L9_leafletQuest())				return true;
	if(L7_crypt())						return true;
	if(fancyOilPainting())				return true;

	if((my_level() > 6) && (my_daycount() != 2))
	{
		if(LX_freeCombats()) return true;
	}

	if(L8_trapperStart())				return true;
	if(L8_trapperGround())				return true;
	if(L8_trapperNinjaLair())			return true;
	if(L8_trapperGroar())				return true;
	if(LX_steelOrgan())					return true;
	if(L10_plantThatBean())				return true;
	if(L12_preOutfit())					return true;
	if(L10_airship())					return true;
	if(L10_basement())					return true;
	if(L10_ground())					return true;
	if(L11_blackMarket())				return true;
	if(L11_forgedDocuments())			return true;
	if(L11_mcmuffinDiary())				return true;
	if(L10_topFloor())					return true;
	if(L10_holeInTheSkyUnlock())		return true;
	if(L9_chasmBuild())					return true;
	if(L9_highLandlord())				return true;
	if(L12_flyerBackup())				return true;
	if(Lsc_flyerSeals())				return true;
	if(L11_mauriceSpookyraven())		return true;
	if(L11_nostrilOfTheSerpent())		return true;
	if(L11_unlockHiddenCity())			return true;
	if(L11_hiddenCityZones())			return true;
	if(ornateDowsingRod())				return true;
	if(L11_aridDesert())				return true;

	if (get_property("sidequestNunsCompleted") != "none" && item_amount($item[Half A Purse]) == 1)
	{
		pulverizeThing($item[Half A Purse]);
		if(item_amount($item[Handful of Smithereens]) > 0)
		{
			cli_execute("make " + $item[Louder Than Bomb]);
		}
	}

	if(L11_hiddenCity())				return true;
	if(L11_talismanOfNam())				return true;
	if(L11_palindome())					return true;
	if(L11_unlockPyramid())				return true;
	if(L11_unlockEd())					return true;
	if(L11_defeatEd())					return true;
	if(L12_gremlins())					return true;
	if(L12_sonofaFinish())				return true;
	if(L12_sonofaBeach())				return true;
	if(L12_filthworms())				return true;
	if(L12_orchardFinalize())			return true;
	if(L12_themtharHills())				return true;
	if(L12_farm())						return true;
	if(L11_getBeehive())				return true;
	if(L12_finalizeWar())				return true;
	if(LX_getDigitalKey())				return true;
	if(LX_getStarKey())					return true;
	if(L12_lastDitchFlyer())			return true;

	if(!get_property("kingLiberated").to_boolean() && (my_inebriety() < inebriety_limit()) && !get_property("_gardenHarvested").to_boolean())
	{
		int[item] camp = auto_get_campground();
		if((camp contains $item[Packet of Thanksgarden Seeds]) && (camp contains $item[Cornucopia]) && (camp[$item[Cornucopia]] > 0) && (internalQuestStatus("questL12War") >= 1))
		{
			cli_execute("garden pick");
		}
	}

	if (L12_clearBattlefield())			return true;
	if(LX_koeInvaderHandler())			return true;
	
	//release the softblock on quests that are waiting for shen quest
	if(my_level() > get_property("auto_shenSkipLastLevel").to_int() && get_property("questL11Shen") != "finished")
	{
		auto_log_warning("I was trying to avoid zones that Shen might need, but I've run out of stuff to do.", "red");
		set_property("auto_shenSkipLastLevel", my_level());
		return true;
	}
	
	//release the softblock on various quests that await optimal conditions.
	if(my_level() != get_property("auto_powerLevelLastLevel").to_int())
	{
		auto_log_warning("Hmmm, we need to stop being so feisty about quests...", "red");
		set_property("auto_powerLevelLastLevel", my_level());
		return true;
	}
	
	if(LX_getDigitalKey()) 				return true;
	if(LX_getStarKey()) 				return true;
	
	if (my_level() < 13)
	{
		if(LX_attemptPowerLevel()) return true;
	}
	
	if(L13_towerNSContests())			return true;
	if(L13_towerNSHedge())				return true;
	if(L13_sorceressDoor())				return true;
	if(L13_towerNSTower())				return true;
	if(L13_towerNSNagamar())			return true;
	if(L13_towerNSFinal())				return true;

	if(my_level() != get_property("auto_powerLevelLastLevel").to_int())
	{
		auto_log_warning("I've run out of stuff to do. Time to powerlevel, I suppose.", "red");
		set_property("auto_powerLevelLastLevel", my_level());
		return true;
	}

	auto_log_info("I should not get here more than once because I pretty much just finished all my in-run stuff. Beep", "blue");
	return false;
}

void auto_begin()
{
	if(get_auto_attack() != 0)
	{
		boolean shouldUnset = user_confirm("You have an auto attack enabled. This can cause issues. Would you like us to disable it? Will default to 'No' in 30 seconds.", 30000, false);
		if(shouldUnset)
		{
			set_auto_attack(0);
		}
		else
		{
			auto_log_warning("Okay, but the warranty is off.", "red");
		}
	}

	//This also should set our path too.
	string page = visit_url("main.php");
	page = visit_url("api.php?what=status&for=4", false);
	if((get_property("_casualAscension").to_int() >= my_ascensions()) && (my_ascensions() > 0))
	{
		return;
	}

	if(contains_text(page, "Being Picky"))
	{
		picky_startAscension();
	}
	else if(contains_text(page, "Welcome to the Kingdom, Gelatinous Noob"))
	{
		jello_startAscension(page);
	}
	else if(contains_text(page, "it appears that a stray bat has accidentally flown right through you") || (get_property("lastAdventure") == "Intro: View of a Vampire"))
	{
		bat_startAscension();
	}
	else if(contains_text(page, "<b>Torpor</b>") && contains_text(page, "Madness of Untold Aeons") && contains_text(page, "Rest for untold Millenia"))
	{
		auto_log_info("Torporing, since I think we're already in torpor.", "blue");
		bat_reallyPickSkills(20);
	}

	if(to_string(my_class()) == "Astral Spirit")
	{
		# my_class() can report Astral Spirit even though it is not a valid class....
		auto_log_warning("We think we are an Astral Spirit, if you actually are that's bad!", "red");
		cli_execute("refresh all");
	}

	auto_log_info("Hello " + my_name() + ", time to explode!");
	auto_log_info("This is version: " + svn_info("autoscend").last_changed_rev + " Mafia: " + get_revision());
	auto_log_info("This is day " + my_daycount() + ".");
	auto_log_info("Turns played: " + my_turncount() + " current adventures: " + my_adventures());
	auto_log_info("Current Ascension: " + auto_my_path());

	set_property("auto_disableAdventureHandling", false);
	set_property("auto_disableFamiliarChanging", false);

	auto_spoonTuneConfirm();

	settingFixer();

	uneffect($effect[Ode To Booze]);
	handlePulls(my_daycount());
	initializeDay(my_daycount());

	backupSetting("promptAboutCrafting", 0);
	backupSetting("requireBoxServants", false);
	backupSetting("breakableHandling", 4);
	backupSetting("trackLightsOut", false);
	backupSetting("autoSatisfyWithCloset", false);
	backupSetting("autoSatisfyWithCoinmasters", true);
	backupSetting("autoSatisfyWithNPCs", true);
	backupSetting("removeMalignantEffects", false);
	backupSetting("autoAntidote", 0);
	backupSetting("dontStopForCounters", true);

	backupSetting("kingLiberatedScript", "scripts/autoscend/auto_king.ash");
	backupSetting("afterAdventureScript", "scripts/autoscend/auto_post_adv.ash");
	backupSetting("choiceAdventureScript", "scripts/autoscend/auto_choice_adv.ash");
	backupSetting("betweenBattleScript", "scripts/autoscend/auto_pre_adv.ash");
	backupSetting("recoveryScript", "");

	backupSetting("hpAutoRecovery", -0.05);
	backupSetting("hpAutoRecoveryTarget", -0.05);
	backupSetting("mpAutoRecovery", -0.05);
	backupSetting("mpAutoRecoveryTarget", -0.05);
	backupSetting("manaBurningTrigger", -0.05);
	backupSetting("manaBurningThreshold", -0.05);
	backupSetting("autoAbortThreshold", -0.05);

	backupSetting("currentMood", "apathetic");
	backupSetting("customCombatScript", "autoscend_null");
	backupSetting("battleAction", "custom combat script");

	backupSetting("choiceAdventure1107", 1);
	backupSetting("choiceAdventure330", 1);		//haunted billiards room NC shark chum

	if(get_property("counterScript") != "")
	{
		backupSetting("counterScript", "scripts/autoscend/auto_counter.ash");
	}

	string charpane = visit_url("charpane.php");
	if(contains_text(charpane, "<hr width=50%><table"))
	{
		auto_log_info("Switching off Compact Character Mode, will resume during bedtime");
		set_property("auto_priorCharpaneMode", 1);
		visit_url("account.php?am=1&pwd=&action=flag_compactchar&value=0&ajax=0", true);
	}

	if (!get_property("_canSeekBirds").to_boolean() &&
		(0 < item_amount($item[Bird-a-Day calendar])) &&
		(auto_is_valid($item[Bird-a-Day calendar])))
	{
		auto_log_info("What a beautiful morning! What's today's bird?");
		use(1, $item[Bird-a-Day calendar]);
	}

	ed_initializeSession();
	bat_initializeSession();

	if(my_daycount() > 1)
	{
		resetMaximize();
		equipBaseline();
	}

	if(my_familiar() == $familiar[Stooper])
	{
		auto_log_info("Avoiding stooper stupor...", "blue");
		use_familiar($familiar[none]);
	}
	dailyEvents();
	
	// the main loop of autoscend is doTasks() which is actually called as part of the while.
	while(auto_unreservedAdvRemaining() && (my_inebriety() <= inebriety_limit()) && !(my_inebriety() == inebriety_limit() && my_familiar() == $familiar[Stooper]) && !get_property("kingLiberated").to_boolean() && doTasks())
	{
		if((my_fullness() >= fullness_limit()) && (my_inebriety() >= inebriety_limit()) && (my_spleen_use() == spleen_limit()) && (my_adventures() < 4) && (my_rain() >= 50) && (get_counters("Fortune Cookie", 0, 4) == "Fortune Cookie"))
		{
			abort("Manually handle, because we have fortune cookie and rain man colliding at the end of our day and we don't know quite what to do here");
		}
		#We save the last adventure for a rain man, damn it.
		consumeStuff();
	}

	if(get_property("kingLiberated").to_boolean())
	{
		equipBaseline();
		handleFamiliar("item");
		if(item_amount($item[Boris\'s Helm]) > 0)
		{
			equip($item[Boris\'s Helm]);
		}
		if(item_amount($item[camp scout backpack]) > 0)
		{
			equip($item[camp scout backpack]);
		}
		if(item_amount($item[operation patriot shield]) > 0)
		{
			equip($item[operation patriot shield]);
		}
		if((equipped_item($slot[familiar]) != $item[snow suit]) && (item_amount($item[snow suit]) > 0))
		{
			equip($item[snow suit]);
		}
		if((item_amount($item[mr. cheeng\'s spectacles]) > 0) && !have_equipped($item[Mr. Cheeng\'s Spectacles]))
		{
			equip($slot[acc2], $item[mr. cheeng\'s spectacles]);
		}
		if((item_amount($item[mr. screege\'s spectacles]) > 0) && !have_equipped($item[Mr. Screege\'s Spectacles]))
		{
			equip($slot[acc3], $item[mr. screege\'s spectacles]);
		}
		if((item_amount($item[numberwang]) > 0) && can_equip($item[numberwang]))
		{
			equip($slot[acc1], $item[numberwang]);
		}
	}

	if(doBedtime())
	{
		auto_log_info("Done for today (" + my_daycount() + "), beep boop");
	}
}

void print_help_text()
{
	print_html("Thank you for using autoscend!");
	print_html("If you need to configure or interrupt the script, choose <b>autoscend</b> from the drop-down \"run script\" menu in your browser.");
	print_html("If you want to contribute, please open an issue <a href=\"https://github.com/Loathing-Associates-Scripting-Society/autoscend/issues\">on Github</a>");
	print_html("A FAQ with common issues (and tips for a great bug report) <a href=\"https://docs.google.com/document/d/1AfyKDHSDl-fogGSeNXTwbC6A06BG-gTkXUAdUta9_Ns\">can be found here</a>");
	print_html("The developers also hang around <a href=\"https://discord.gg/96xZxv3\">on the Ascension Speed Society discord server</a>");
	print_html("");
}

void sad_times()
{
	print_html('autoscend (formerly sl_ascend) is under new management. Soolar (the maintainer of sl_ascend) and Jeparo (the most active contributor) have decided to cease development of sl_ascend in response to Jick\'s behavior that has recently <a href="https://www.reddit.com/r/kol/comments/d0cq9s/allegations_of_misconduct_by_asymmetric_members/">come to light</a>. New developers have taken over maintenance and rebranded sl_ascend to autoscend as per Soolar\'s request. Please be patient with us during this transition period. Please see the readme on the <a href="https://github.com/Loathing-Associates-Scripting-Society/autoscend">github</a> page for more information.');
}

void safe_preference_reset_wrapper(int level)
{
	if(level <= 0)
	{
		auto_begin();
	}
	else
	{
		boolean succeeded;
		try
		{
			safe_preference_reset_wrapper(level-1);
			succeeded = true;
		}
		finally
		{
			restoreAllSettings();
			if(level == 1)
			{
				sad_times();
			}
		}
	}
}

void main()
{
	backupSetting("printStackOnAbort", true);
	print_help_text();
	sad_times();
	try
	{
		cli_execute("refresh all");
	}
	finally
	{
		if(!autoscend_migrate() && !user_confirm("autoscend might not have upgraded from a previous version correctly, do you want to continue? Will default to true in 10 seconds.", 10000, true)){
			abort("User aborted script after failed migration.");
		}
		safe_preference_reset_wrapper(3);
	}
}
