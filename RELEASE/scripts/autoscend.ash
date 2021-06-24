since r20762;	//min mafia revision needed to run this script. Last update: Add 'logPreferenceChangeFilter', which is a comma separated list of preferences to not log when logPreferenceChange is enabled
/***
	autoscend_header.ash must be first import
	All non-accessory scripts must be imported here

	Accessory scripts can import autoscend.ash

	If updating since revision, update .github/workflows/ci.yml and cached kolmafia.jar
***/


import <autoscend/autoscend_header.ash>
import <autoscend/autoscend_migration.ash>
import <canadv.ash>

import <autoscend/auto_adventure.ash>
import <autoscend/auto_bedtime.ash>
import <autoscend/auto_consume.ash>
import <autoscend/auto_settings.ash>
import <autoscend/auto_equipment.ash>
import <autoscend/auto_familiar.ash>
import <autoscend/auto_list.ash>
import <autoscend/auto_monsterparts.ash>
import <autoscend/auto_providers.ash>
import <autoscend/auto_restore.ash>
import <autoscend/auto_util.ash>
import <autoscend/auto_zlib.ash>
import <autoscend/auto_zone.ash>

import <autoscend/combat/auto_combat.ash>

import <autoscend/iotms/clan.ash>
import <autoscend/iotms/elementalPlanes.ash>
import <autoscend/iotms/eudora.ash>
import <autoscend/iotms/mr2011.ash>
import <autoscend/iotms/mr2012.ash>
import <autoscend/iotms/mr2013.ash>
import <autoscend/iotms/mr2014.ash>
import <autoscend/iotms/mr2015.ash>
import <autoscend/iotms/mr2016.ash>
import <autoscend/iotms/mr2017.ash>
import <autoscend/iotms/mr2018.ash>
import <autoscend/iotms/mr2019.ash>
import <autoscend/iotms/mr2020.ash>
import <autoscend/iotms/mr2021.ash>

import <autoscend/paths/actually_ed_the_undying.ash>
import <autoscend/paths/avatar_of_boris.ash>
import <autoscend/paths/avatar_of_jarlsberg.ash>
import <autoscend/paths/avatar_of_sneaky_pete.ash>
import <autoscend/paths/avatar_of_west_of_loathing.ash>
import <autoscend/paths/bees_hate_you.ash>
import <autoscend/paths/casual.ash>
import <autoscend/paths/community_service.ash>
import <autoscend/paths/dark_gyffte.ash>
import <autoscend/paths/disguises_delimit.ash>
import <autoscend/paths/g_lover.ash>
import <autoscend/paths/gelatinous_noob.ash>
import <autoscend/paths/grey_goo.ash>
import <autoscend/paths/heavy_rains.ash>
import <autoscend/paths/kingdom_of_exploathing.ash>
import <autoscend/paths/kolhs.ash>
import <autoscend/paths/license_to_adventure.ash>
import <autoscend/paths/live_ascend_repeat.ash>
import <autoscend/paths/nuclear_autumn.ash>
import <autoscend/paths/one_crazy_random_summer.ash>
import <autoscend/paths/path_of_the_plumber.ash>
import <autoscend/paths/picky.ash>
import <autoscend/paths/pocket_familiars.ash>
import <autoscend/paths/quantum_terrarium.ash>
import <autoscend/paths/the_source.ash>
import <autoscend/paths/two_crazy_random_summer.ash>
import <autoscend/paths/low_key_summer.ash>

import <autoscend/quests/level_01.ash>
import <autoscend/quests/level_02.ash>
import <autoscend/quests/level_03.ash>
import <autoscend/quests/level_04.ash>
import <autoscend/quests/level_05.ash>
import <autoscend/quests/level_06.ash>
import <autoscend/quests/level_07.ash>
import <autoscend/quests/level_08.ash>
import <autoscend/quests/level_09.ash>
import <autoscend/quests/level_10.ash>
import <autoscend/quests/level_11.ash>
import <autoscend/quests/level_12.ash>
import <autoscend/quests/level_13.ash>
import <autoscend/quests/level_any.ash>
import <autoscend/quests/optional.ash>

void initializeSettings() {

	// called once per ascension on the first launch of the script.
	// should not handle anything other than intialising properties etc.
	// all paths that have extra settings should call their path specific
	// initialise function at the end of this function (may override properties set in here).

	if(my_ascensions() == get_property("auto_doneInitialize").to_int())
	{
		return;		//already initialized settings this ascension
	}
	set_location($location[none]);
	invalidateRestoreOptionCache();

	set_property("auto_100familiar", $familiar[none]);
	if(my_familiar() != $familiar[none] && pathAllowsChangingFamiliar()) //If we can't control familiar changes, no point setting 100% familiar data
	{
		boolean userAnswer = user_confirm("Familiar already set, is this a 100% familiar run? Will default to 'No' in 15 seconds.", 15000, false);
		if(userAnswer)
		{
			set_property("auto_100familiar", my_familiar());
		}
	}

	auto_spoonTuneConfirm();

	string pool = visit_url("questlog.php?which=3");
	matcher my_pool = create_matcher("a skill level of (\\d+) at shooting pool", pool);
	if(my_pool.find() && (my_turncount() == 0))
	{
		int curSkill = to_int(my_pool.group(1));
		int sharkCountMin = ceil((curSkill * curSkill) / 4);
		int sharkCountMax = ceil((curSkill + 1) * (curSkill + 1) / 4);
	}

	set_property("auto_abooclover", true);
	set_property("auto_aboopending", 0);
	set_property("auto_banishes", "");
	set_property("auto_batoomerangDay", 0);
	set_property("auto_beatenUpCount", 0);
	set_property("auto_getBeehive", false);
	set_property("auto_bruteForcePalindome", false);
	set_property("auto_cabinetsencountered", 0);
	set_property("auto_chasmBusted", true);
	set_property("auto_chewed", "");
	set_property("auto_clanstuff", "0");
	set_property("auto_combatHandler", "");
	set_property("auto_cookie", -1);
	set_property("auto_copies", "");
	set_property("auto_crackpotjar", "");
	set_property("auto_dakotaFanning", false);
	set_property("auto_day_init", 0);
	set_property("auto_day1_dna", "");
	set_property("auto_debuffAsdonDelay", 0);
	set_property("auto_disableAdventureHandling", false);
	set_property("auto_doCombatCopy", "no");
	set_property("auto_drunken", "");
	set_property("auto_eaten", "");
	set_property("auto_familiarChoice", "");
	set_property("auto_forceTavern", false);
	set_property("auto_funTracker", "");
	set_property("auto_getBoningKnife", false);
	set_property("auto_getStarKey", true);
	set_property("auto_getSteelOrgan", get_property("auto_alwaysGetSteelOrgan"));
	set_property("auto_gnasirUnlocked", false);
	set_property("auto_grimstoneFancyOilPainting", true);
	set_property("auto_grimstoneOrnateDowsingRod", true);
	set_property("auto_haveoven", false);
	set_property("auto_doGalaktik", false);
	set_property("auto_doArmory", false);
	set_property("auto_doMeatsmith", false);
	set_property("auto_L8_ninjaAssassinFail", false);
	set_property("auto_L8_extremeInstead", false);
	set_property("auto_haveSourceTerminal", false);
	set_property("auto_hedge", "fast");
	set_property("auto_hippyInstead", false);
	set_property("auto_holeinthesky", true);
	set_property("auto_ignoreCombat", "");
	set_property("auto_ignoreFlyer", false);
	set_property("auto_instakill", "");
	set_property("auto_modernzmobiecount", "");
	set_property("auto_powerfulglove", "");
	set_property("auto_otherstuff", "");
	set_property("auto_paranoia", -1);
	set_property("auto_paranoia_counter", 0);
	set_property("auto_priorCharpaneMode", "0");
	set_property("auto_powerLevelLastLevel", "0");
	set_property("auto_powerLevelAdvCount", "0");
	set_property("auto_powerLevelLastAttempted", "0");
	set_property("auto_pulls", "");

	// Last level during which we ran out of stuff to do without pre-completing some Shen quests.
	set_property("auto_shenSkipLastLevel", 0); 
	remove_property("auto_shenZonesTurnsSpent");
	remove_property("auto_lastShenTurn");
	
	set_property("auto_delayLastLevel", 0);

	set_property("auto_sniffs", "");
	set_property("auto_waitingArrowAlcove", "50");
	set_property("auto_wandOfNagamar", true);
	set_property("auto_wineracksencountered", 0);
	set_property("auto_wishes", "");
	set_property("auto_writingDeskSummon", false);
	set_property("auto_yellowRays", "");
	set_property("auto_replaces", "");
	set_property("auto_skipNuns", "false");
	set_property("auto_skipL12Farm", "false");
	set_property("auto_L12FarmStage", "0");
	set_property("choiceAdventure1003", 0);
	set_property("auto_junkspritesencountered", 0);
	set_property("auto_openedziggurat", false);
	remove_property("auto_minedCells");
	remove_property("auto_shinningStarted");
	remove_property("auto_boughtCommerceGhostItem");
	beehiveConsider();

	eudora_initializeSettings();
	hr_initializeSettings();
	awol_initializeSettings();
	theSource_initializeSettings();
	ed_initializeSettings();
	boris_initializeSettings();
	bond_initializeSettings();
	fallout_initializeSettings();
	pete_initializeSettings();
	pokefam_initializeSettings();
	majora_initializeSettings();
	glover_initializeSettings();
	bat_initializeSettings();
	koe_initializeSettings();
	kolhs_initializeSettings();
	zelda_initializeSettings();
	lowkey_initializeSettings();
	bhy_initializeSettings();
	grey_goo_initializeSettings();
	qt_initializeSettings();
	jarlsberg_initializeSettings();

	set_property("auto_doneInitialize", my_ascensions());
}

void initializeSession() {
	// called once every time the script is started.
	// anything that needs to be set only for the duration the script is running
	// should be set in here.

	auto_enableBackupCameraReverser();
	ed_initializeSession();
	bat_initializeSession();
}

int auto_advToReserve()
{
	// Calculates how many adventures we should aim to keep in reserve
	
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
	if(inAftercore())
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

		if((storage_amount($item[mafia thumb ring]) > 0) && auto_is_valid($item[mafia thumb ring]))
		{
			pullXWhenHaveY($item[mafia thumb ring], 1, 0);
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
			if(in_glover())
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
		if(in_pokefam())
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

		if(!in_glover())
		{
			pullXWhenHaveY($item[Infinite BACON Machine], 1, 0);
		}

		if(is_unrestricted($item[Bastille Battalion control rig]))
		{
			string temp = visit_url("storage.php?action=pull&whichitem1=" + to_int($item[Bastille Battalion Control Rig]) + "&howmany1=1&pwd");
		}

		if(!in_pokefam() && !in_glover())
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

boolean LX_doVacation()
{
	if(in_koe())
	{
		return false;		//cannot vacation in kingdom of exploathing path
	}
	
	int meat_needed = 500;
	int adv_needed = 3;
	int adv_budget = my_adventures() - auto_advToReserve();
	if(my_path() == "Way of the Surprising Fist")
	{
		meat_needed = 5;
		adv_needed = 5;
	}
	if(adv_needed > adv_budget)
	{
		auto_log_info("I want to vacation but I do not have enough adventures left", "red");
		return false;
	}
	if(meat_needed > my_meat())
	{
		auto_log_info("I want to vacation but I do not have enough meat", "red");
		return false;
	}
	if(in_zelda())	//avoid error for not having plumber gear equipped.
	{
		zelda_equipTool($stat[moxie]);
		equipMaximizedGear();
	}

	return autoAdv(1, $location[The Shore\, Inc. Travel Agency]);
}

boolean fortuneCookieEvent()
{
	//Semi-rare Handler
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

		if (goal == $location[The Castle in the Clouds in the Sky (Top Floor)] && (get_property("semirareLocation") == goal || item_amount($item[Mick\'s IcyVapoHotness Inhaler]) > 0 || internalQuestStatus("questL10Garbage") < 9 || get_property("lastCastleTopUnlock").to_int() < my_ascensions() || get_property("sidequestNunsCompleted") != "none" || get_property("auto_skipNuns").to_boolean() || in_koe()))
		{
			goal = $location[The Limerick Dungeon];
		}

		if (goal == $location[The Limerick Dungeon] && (get_property("semirareLocation") == goal || item_amount($item[Cyclops Eyedrops]) > 0 || get_property("lastFilthClearance").to_int() >= my_ascensions() || get_property("sidequestOrchardCompleted") != "none" || get_property("currentHippyStore") != "none" || isActuallyEd() || in_koe() || item_amount($item[heart of the filthworm queen]) > 0))
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
		return retval;
	}
	return false;
}

void initializeDay(int day)
{
	if(inAftercore())
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

	if(!get_property("_pottedTeaTreeUsed").to_boolean() && (auto_get_campground() contains $item[Potted Tea Tree]) && !inAftercore())
	{
		if(get_property("auto_teaChoice") != "")
		{
			string[int] teaChoice = split_string(get_property("auto_teaChoice"), ";");
			string myTea = trim(teaChoice[min(count(teaChoice), my_daycount()) - 1]);
			if (myTea.to_item() != $item[none] || myTea == "shake")
			{
				boolean buff = cli_execute("teatree " + myTea);
			}
		}
		else if (day == 1 && auto_is_valid($item[Potted Tea Tree]))
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
		else if (day == 2 && auto_is_valid($item[Potted Tea Tree]))
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
	
	//you must finish the Toot Oriole quest to unlock council quests.
	tootOriole();

	ed_initializeDay(day);
	boris_initializeDay(day);
	fallout_initializeDay(day);
	pete_initializeDay(day);
	cs_initializeDay(day);
	bond_initializeDay(day);
	pokefam_initializeDay(day);
	glover_initializeDay(day);
	bat_initializeDay(day);
	grey_goo_initializeDay(day);
	jarlsberg_initializeDay(day);

	if(day == 1)
	{
		if(get_property("auto_day_init").to_int() < 1)
		{
			auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
			if(contains_text(get_property("sourceTerminalEnquiryKnown"), "monsters.enq") && in_pokefam())
			{
				auto_sourceTerminalRequest("enquiry monsters.enq");
			}
			else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "familiar.enq") && pathHasFamiliar())
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
					if(isUnclePAvailable() && ((my_meat() > npc_price($item[Antique Accordion])) && (npc_price($item[Antique Accordion]) != 0)) && !in_glover())
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

			equipBaseline();

			handleBjornify($familiar[none]);
			handleBjornify($familiar[El Vibrato Megadrone]);

			string temp = visit_url("guild.php?place=challenge");

			if(get_property("auto_pvpEnable").to_boolean() && !hippy_stone_broken())
			{
				visit_url("peevpee.php?action=smashstone&pwd&confirm=on", true);
				visit_url("peevpee.php?place=fight");
			}

			auto_beachCombHead("exp");
		}

		if((get_property("lastCouncilVisit").to_int() < my_level()) && (auto_my_path() != "Community Service"))
		{
			cli_execute("counters");
			council();
		}
		
		// If we have the shortest order cook, loop familiars that will benefit from that.
		if (pathHasFamiliar() && pathAllowsChangingFamiliar())
		{
			familiar init_fam = my_familiar();
			if (have_familiar($familiar[shorter-order cook]))
			{
				foreach fam in $familiars[ghost of crimbo carols, ghost of crimbo commerce, ghost of crimbo cheer]
				{
					if (have_familiar(fam))
					{
						use_familiar(fam);
					}
				}
			}
			use_familiar(init_fam);
		}
	}//day1
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
			if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && isUnclePAvailable() && ((my_meat() > npc_price($item[Antique Accordion])) && (npc_price($item[Antique Accordion]) != 0)) && (auto_predictAccordionTurns() < 10) && !($classes[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Ed, Vampyre, Plumber] contains my_class()) && !in_glover())
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
	if(contains_text(campground, "beergarden7.gif") && is_unrestricted($item[packet of beer seeds]))
	{
		cli_execute("garden pick");
	}
	if(contains_text(campground, "wintergarden3.gif") && is_unrestricted($item[packet of winter seeds]))
	{
		cli_execute("garden pick");
	}
	if(contains_text(campground, "thanksgardenmega.gif") && is_unrestricted($item[packet of thanksgarden seeds]))
	{
		cli_execute("garden pick");
	}

	set_property("auto_forceNonCombatSource", "");

	set_property("auto_day_init", day);
}

boolean dailyEvents()
{
	//Daily Events that should happen at start and not end.
	
	auto_birdOfTheDay();
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

	if (get_property("_klawSummons").to_int() == 0 && get_clan_rumpus() contains 'Mr. Klaw "Skill" Crane Game') {
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

	if (item_amount($item[Genie Bottle]) > 0 && auto_is_valid($item[pocket wish]) && !in_glover())
	{
		for(int i=get_property("_genieWishesUsed").to_int(); i<3; i++)
		{
			makeGeniePocket();
		}
	}

	auto_getGuzzlrCocktailSet();
	auto_latheAppropriateWeapon();
	auto_harvestBatteries();
	
	return true;
}

boolean isAboutToPowerlevel() {
	return get_property("auto_powerLevelLastLevel").to_int() == my_level();
}

boolean LX_attemptPowerLevel()
{
	if (!isAboutToPowerlevel())		//determined that the softblock on quests waiting for optimal conditions is still on
	{
		auto_log_warning("Hmmm, we need to stop being so feisty about quests...", "red");
		set_property("auto_powerLevelLastLevel", my_level());		//release softblock until you level up
		set_property("auto_powerLevelAdvCount", 0);
		return true;		//restart the main loop to give those quests a chance to run now that the softblock is released.
	}
	
	if (my_level() > 12) {
		return false;
	}

	auto_log_warning("I've run out of stuff to do. Time to powerlevel, I suppose.", "red");

	set_property("auto_powerLevelAdvCount", get_property("auto_powerLevelAdvCount").to_int() + 1);
	set_property("auto_powerLevelLastAttempted", my_turncount());
	
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

	if (LX_getDigitalKey() || LX_getStarKey())
	{
		return true;
	}

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
		if(neverendingPartyCombat()) return true;
	}
	if(timeSpinnerAdventure()) return true;
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
	
	if (internalQuestStatus("questM21Dance") > 3)
	{
		int goal_count = 0;
		if(my_primestat() == $stat[Muscle])
		{
			goal_count++;
		}
		if(my_primestat() == $stat[Mysticality] || my_basestat($stat[Mysticality]) < 70)	//war outfit requires 70 base mys
		{
			goal_count++;
		}
		if(my_primestat() == $stat[Moxie] ||
		my_basestat($stat[Moxie]) < 70 || 	//war outfit requires 70 base mox
		get_property("auto_beatenUpCount").to_int() > 5)	//if we are getting beaten up we should raise moxie
		{
			goal_count++;
		}
		if(my_meat() < meatReserve() + 1000)
		{
			goal_count++;
		}
		boolean prefer_bedroom = false;
		if(goal_count > 1) //for multiple targets then haunted bedroom is best
		{
			prefer_bedroom = true;
		}
		else if(providePlusNonCombat(25, true, true) < 15)	//only perform the simulation if goal_count is 1
		{
			prefer_bedroom = true;	//for one target it depends on your noncombat. bad -combat prefers bedroom. otherwise prefer haunted gallery
		}
		
		if(prefer_bedroom)
		{
			if(autoAdv($location[The Haunted Bedroom])) return true;
		}
		else		//do [The Haunted Gallery] instead
		{
			switch (my_primestat())		//we only ever do the haunted gallery if the sole stat we want is primestat.
			{
				case $stat[Muscle]:
					backupSetting("louvreDesiredGoal", "4"); // get Muscle stats
					break;
				case $stat[Mysticality]:
					backupSetting("louvreDesiredGoal", "5"); // get Myst stats
					break;
				case $stat[Moxie]:
					backupSetting("louvreDesiredGoal", "6"); // get Moxie stats
					break;
			}
			providePlusNonCombat(25, true);
			if(autoAdv($location[The Haunted Gallery])) return true;
		}		
	}
	return false;
}

boolean disregardInstantKarma()
{
	//do we want to ignore the instant karma you get for defeating the naughty sorceress at exactly level 13. Used to tweak our XP gains.
	if(inAftercore())
	{
		return true;
	}
	if(my_level() != 13)
	{
		//under level 13 we wan to get max XP gains. level 14+ we already missed the insta karma, no need to hold back anymore.
		return true;
	}
	//auto_disregardInstantKarma is a user configured setting
	return get_property("auto_disregardInstantKarma").to_boolean();
}

int auto_freeCombatsRemaining()
{
	return auto_freeCombatsRemaining(false);
}

int auto_freeCombatsRemaining(boolean print_remaining_fights)
{

	void logRemainingFights(string msg)
	{
	  if (!print_remaining_fights) return;
	  print(msg, "red");
	}

	int count = 0;
	
	logRemainingFights("Remaining Free Fights:");
	if(!in_koe() && canChangeToFamiliar($familiar[Machine Elf]))
	{
		int temp = 5-get_property("_machineTunnelsAdv").to_int();
		count += temp;
		logRemainingFights("Machine Elf = " + temp);
	}
	if(snojoFightAvailable())
	{
		int temp = 10-get_property("_snojoFreeFights").to_int();
		count += temp;
		logRemainingFights("Snojo = " + temp);
	}
	if(canChangeToFamiliar($familiar[God Lobster]) && disregardInstantKarma())
	{
		int temp = 3-get_property("_godLobsterFights").to_int();
		count += temp;
		logRemainingFights("God Lobster = " + temp);
	}
	if(neverendingPartyRemainingFreeFights() > 0)
	{
		int temp = neverendingPartyRemainingFreeFights();
		count += temp;
		logRemainingFights("Neverending Party = " + temp);
	}
	if(get_property("_eldritchTentacleFought").to_boolean() == false)
	{
		count++;
		logRemainingFights("Tent Tentacle = 1");
	}
	if(auto_have_skill($skill[Evoke Eldritch Horror]) && get_property("_eldritchHorrorEvoked").to_boolean() == false)
	{
		count++;
		logRemainingFights("Evoke Eldritch = 1");
	}

	if (auto_canFightPiranhaPlant()) {
		int temp = auto_piranhaPlantFightsRemaining();
		count += temp;
		logRemainingFights("Piranha Plant Fights = " + temp);
	}

	if (auto_canTendMushroomGarden()) {
		count++;
		logRemainingFights("Tend to Mushroom Garden = 1"); //Not actually a free fight, but included to ensure carried out at bedtime.
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
		auto_log_warning("This error should only occur if you lost a free fight. If you did not then please report this", "red");
		abort("Please perform the remaining free combats manually then run me again");
	}
	
	auto_log_debug("LX_freeCombats active with powerlevel set to " + powerlevel);
	
	resetMaximize();
	if(disregardInstantKarma())
	{
		handleFamiliar("stat");
	}

	if (auto_canFightPiranhaPlant() || auto_canTendMushroomGarden()) {
		auto_log_debug("LX_freeCombats is calling auto_mushroomGardenHandler()");
		return auto_mushroomGardenHandler();
	}

	if(neverendingPartyRemainingFreeFights() > 0)
	{
		if(powerlevel)
		{
			auto_log_debug("LX_freeCombats is calling neverendingPartyCombat()");
			if(neverendingPartyCombat()) return true;
		}
		else
		{
			auto_log_debug("LX_freeCombats is calling neverendingPartyCombat()");
			if (handleFamiliar($familiar[Red-Nosed Snapper]))
			{
				auto_changeSnapperPhylum($phylum[dude]);
			}
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

boolean LX_freeCombatsTask()
{
	if (my_adventures() == (1 + auto_advToReserve()) && inebriety_left() == 0 && stomach_left() < 1)
	{
		auto_log_debug("Only 1 non reserved adv remains for main loop so doing free combats");
		return LX_freeCombats();
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
		if((have_effect($effect[Adventurer\'s Best Friendship]) > 30) && pathHasFamiliar())
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

	if(knoll_available() && (item_amount($item[Detuned Radio]) == 0) && (my_meat() >= npc_price($item[Detuned Radio])) && !in_glover())
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
	if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && isUnclePAvailable() && (my_meat() >= npc_price($item[Antique Accordion])) && (auto_predictAccordionTurns() < 10) && !in_glover())
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

	if(knoll_available() && (have_skill($skill[Torso Awareness]) || have_skill($skill[Best Dressed])) && (item_amount($item[Demon Skin]) > 0) && !possessEquipment($item[Demonskin Jacket]))
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
	location place = my_location();
	if(my_location().turns_spent > 52)
	{
		boolean tooManyAdventures = true;
		
		//general override function
		if ($locations[
		//Many places do not have a proper ID which makes them indistinguishable from noob cave
		Noob Cave,
		
		//quest locations where you spend lots of adventures and can not over adventure either
		The Battlefield (Frat Uniform), The Battlefield (Hippy Uniform),
		
		//kingdom of exploathing specific location for the hippy-frat war
		The Exploaded Battlefield,
		
		//IOTM zones only used to powerlevel
		The Deep Dark Jungle, The Neverending Party, Pirates of the Garbage Barges, The Secret Government Laboratory, Sloppy Seconds Diner, The SMOOCH Army HQ, Super Villain\'s Lair, Uncle Gator\'s Country Fun-Time Liquid Waste Sluice, VYKEA, The X-32-F Combat Training Snowman,
		
		//in KOLHS path you must spend 40 adv per day split between those locations. zones only exist in kolhs
		The Hallowed Halls, Art Class, Chemistry Class, Shop Class,
		
		//holiday event. must spend 100 turns there to complete the holiday.
		The Arrrboretum] contains place)
		{
			tooManyAdventures = false;
		}

		if(tooManyAdventures && (my_path() == "The Source"))
		{
			if($locations[The Haunted Ballroom, The Haunted Bathroom, The Haunted Bedroom, The Haunted Gallery] contains place)
			{
				tooManyAdventures = false;
			}
		}

		if(tooManyAdventures && isActuallyEd())
		{
			if ($location[Hippy Camp] == place)
			{
				tooManyAdventures = false;
			}
		}
		
		if(tooManyAdventures && in_bhy())
		{
			if($locations[A-Boo Peak, Twin Peak] contains place)
			{
				//bees prevent doing these quickly
				tooManyAdventures = false;
			}
		}

		if (tooManyAdventures && in_glover())
		{
			if ($locations[The Penultimate Fantasy Airship, The Smut Orc Logging Camp, The Hidden Temple] contains place)
			{
				tooManyAdventures = false;
			}
		}

		if ($locations[The Haunted Gallery] contains place && place.turns_spent < 100)
		{
			tooManyAdventures = false;
		}
		
		boolean can_powerlevel_stench = elementalPlanes_access($element[stench]) && auto_have_skill($skill[Summon Smithsness]) && get_property("auto_beatenUpCount").to_int() == 0;
		boolean has_powerlevel_iotm = can_powerlevel_stench || elementalPlanes_access($element[spooky]) || elementalPlanes_access($element[cold]) || elementalPlanes_access($element[sleaze]) || elementalPlanes_access($element[hot]) || neverendingPartyAvailable();
		if(!has_powerlevel_iotm && $locations[The Haunted Gallery, The Haunted Bedroom] contains place)
		{
			tooManyAdventures = false;		//if we do not have iotm powerlevel zones then we are forced to use haunted gallery or bedroom
		}

		if(tooManyAdventures)
		{
			if(get_property("auto_newbieOverride").to_boolean())
			{
				set_property("auto_newbieOverride", false);
				auto_log_warning("We have spent " + place.turns_spent + " turns at '" + place + "' and that is bad... override accepted.", "red");
			}
			else
			{
				auto_log_critical("You can set auto_newbieOverride = true to bypass this once.", "blue");
				abort("We have spent " + place.turns_spent + " turns at '" + place + "' and that is bad... aborting.");
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
	if(auto_is_valid($item[Handful of Hand Chalk]) && (have_effect($effect[Chalky Hand]) > 0 || item_amount($item[Handful of Hand Chalk]) > 0))
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
	if(can_interact() && my_meat() > 20000)
	{
		return false;		//do not autosell stuff in casual or postronin unless you are very poor
	}
	foreach it in $items[dense meat stack, meat stack, Blue Money Bag, Red Money Bag, White Money Bag]
	{
		if(item_amount(it) > 0)
		{
			auto_autosell(min(10,item_amount(it)), it);		//autosell all of this item
		}
	}
	foreach it in $items[Ancient Vinyl Coin Purse, Black Pension Check, CSA Discount Card, Fat Wallet, Gathered Meat-Clip, Old Leather Wallet, Penultimate Fantasy Chest, Pixellated Moneybag, Old Coin Purse, Shiny Stones, Warm Subject Gift Certificate]
	{
		if(item_amount(it) > 0 && auto_is_valid(it))
		{
			use(min(10,item_amount(it)), it);
		}
	}
	foreach it in $items[Bag Of Park Garbage]		//keeping 1 garbage in stock to avoid possible harmful loop with dinseylandfill_garbageMoney()
	{
		if(item_amount(it) > 1)		//for these items we want to keep 1 in stock. sell the rest
		{
			use(min(10,item_amount(it)-1), it);
		}
	}
	foreach it in $items[elegant nightstick]		//keeping 2 nightsticks in stock for double fisting
	{
		if(item_amount(it) > 2)		//for these items we want to keep 2 in stock. sell the rest
		{
			auto_autosell(min(10,item_amount(it)-2), it);
		}
	}

	//bellow this point are items we only want to sell if we are desperate for meat.
	if(my_meat() > meatReserve())
	{
		return false;
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

void resetState() {
	//These settings should never persist into another turn, ever. They only track something for a single instance of the main loop.
	//We use boolean instead of adventure count because of free combats.
	
	set_property("auto_doCombatCopy", "no");
	set_property("_auto_thisLoopHandleFamiliar", false); // have we called handleFamiliar this loop
	set_property("auto_disableAdventureHandling", false); // used to stop auto_pre_adv and auto_post_adv from doing anything.
	set_property("auto_disableFamiliarChanging", false); // disable autoscend making changes to familiar
	set_property("auto_familiarChoice", ""); // which familiar do we want to switch to during pre_adventure
	set_property("choiceAdventure1387", -1); // using the force non-combat
	set_property("_auto_tunedElement", ""); // Flavour of Magic elemental alignment

	if(doNotBuffFamiliar100Run())		//some familiars are always bad
	{
		set_property("_auto_bad100Familiar", true);			//disable buffing familiar
	}
	else		//some familiars are only bad at certain locations
	{
		set_property("_auto_bad100Familiar", false); 		//reset to not bad. target location might set them as bad again
	}

	set_property("auto_retrocapeSettings", ""); // retrocape config
	set_property("auto_januaryToteAcquireCalledThisTurn", false); // january tote item switching

	horseDefault(); // horsery tracking

	set_property("auto_snapperPhylum", ""); // internal Red-Nosed Snapper phylum tracking. Ensures we only change it maximum once per adventure (and don't lose charges)

	bat_formNone(); // Vampyre form tracking

	resetMaximize();

	if (canChangeToFamiliar($familiar[Left-Hand Man]) && familiar_equipped_equipment($familiar[Left-Hand Man]) != $item[none]) {
		// Leaving something equipped on the Left-Hand man like the Latte is currently bugged in mafia
		// as it will show any skills the equipment gives as available even when you have a completely different familiar
		// see https://kolmafia.us/showthread.php?24780-April-2020-IOTM-sinistral-homunculus&p=158453&viewfull=1#post158453
		auto_log_info(`Unequipping your {familiar_equipped_equipment($familiar[Left-Hand Man])} from the Left-Hand Man`, "blue");
		use_familiar($familiar[Left-Hand Man]);
		equip($slot[familiar], $item[none]);
	}

	foreach it in $items[staph of homophones, sword behind inappropriate prepositions]
	{
		// these screw with text in the game which breaks mafia's parsing in a lot of places.
		if (have_equipped(it))
		{
			equip($item[none], it.to_slot());
		}
	}
	foreach eff in $effects[Dis Abled, Haiku State of Mind, Just the Best Anapests, O Hai!, Robocamo, Yes\, Can Haz]
	{
		// as do these which can all be freely shrugged.
		if (have_effect(eff) > 0)
		{
			cli_execute(`uneffect {eff.to_string()}`);
		}
	}
}

boolean process_tasks()
{
	string [string,int,string] task_order;
	if(!file_to_map("autoscend_task_order.txt", task_order))
	{
		abort("Could not load /data/autoscend_task_order.txt");
	}

	string task_path = my_path();
	if (!(task_order contains task_path))
	{
		task_path = "default";
	}

	foreach i,task_function,condition_function in task_order[task_path]
	{
		if (condition_function == "" || (call boolean condition_function()))
		{
			boolean result = call boolean task_function();
			if (result)
			{
				return true;
			}
		}
	}

	return false;
}

boolean doTasks()
{
	//this is the main loop for autoscend. returning true will restart from the begining. returning false will quit the loop and go on to do bedtime

	auto_settingsFix();		//check and correct invalid configuration inputs made by users
	if(!auto_unreservedAdvRemaining())
	{
		auto_log_warning("No more unreserved adventures left", "red");
		return false;	//we are out of adventures
	}
	if(get_property("_auto_doneToday").to_boolean())
	{
		auto_log_warning("According to property _auto_doneToday I am done for today", "red");
		return false;
	}
	if(my_familiar() == $familiar[Stooper] && pathAllowsChangingFamiliar())
	{
		auto_log_info("Avoiding stooper stupor...", "blue");
		familiar fam = (is100FamRun() ? get_property("auto_100familiar").to_familiar() : $familiar[Mosquito]);
		use_familiar(fam);
	}
	if(my_inebriety() > inebriety_limit())
	{
		auto_log_warning("I am overdrunk", "red");
		return false;
	}
	if(inAftercore())
	{
		auto_log_warning("I am in aftercore", "red");
		return false;
	}	
	if(inCasual())
	{	
		auto_log_warning("I think I'm in a casual ascension and should not run. To override: set _casualAscension = -1", "red");
		return false;	
	}
	
	print_header();

	auto_interruptCheck();

	int delay = get_property("auto_delayTimer").to_int();
	if(delay > 0)
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
	if(get_property("auto_inv_paranoia").to_boolean())
	{
		cli_execute("refresh inv");
	}

	// actually doing stuff should start from here onwards.
	resetState();

	basicAdjustML();

	councilMaintenance();
	# This function buys missing skills in general, not just for Picky.
	# It should be moved.
	picky_buyskills();
	awol_buySkills();
	awol_useStuff();
	theSource_buySkills();
	zelda_buyStuff();
	jarlsberg_buySkills();
	boris_buySkills();
	pete_buySkills();

	oldPeoplePlantStuff();
	use_barrels();
	auto_latteRefill();
	auto_buyCrimboCommerceMallItem();
	houseUpgrade();
	getTerrarium();			//get a familiar terrarium if you do not have one yet so you can use familiars
	acquireFamiliars();		//get useful and cheap familiars
	hatchList();			//hatch familiars that are commonly dropped in run

	//This just closets stuff so G-Lover does not mess with us.
	if(LM_glover())						return true;
	//This just closets stuff that bees don't like
	if(LM_bhy())						return true;

	tophatMaker();
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
	if(LM_pokefam())					return true;
	if(LM_majora())						return true;
	if(LM_batpath()) 					return true;
	if(doHRSkills())					return true;
	if(LM_canInteract()) 				return true;
	if(LM_kolhs()) 						return true;
	if(LM_jarlsberg())					return true;

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

	if(LA_grey_goo_tasks())
	{
		return true;
	}
	if(in_ggoo())
	{
		abort("Should not have gotten here, aborted LA_grey_goo_tasks method allowed return to caller. Uh oh.");
	}

	auto_voteSetup(0,0,0);

	auto_setSongboom();

	if(LM_bond())						return true;
	if(LX_universeFrat())				return true;
	handleJar();
	adventureFailureHandler();

	dna_sorceressTest();
	dna_generic();

	if(((my_hp() * 5) < my_maxhp()) && (my_mp() > 100))
	{
		acquireHP();
	}

	if (process_tasks()) return true;

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
		//workaround for this bug specifically https://kolmafia.us/showthread.php?25579
		abort("Mafia thinks you are an astral spirit. Type \"logout\" in gCLI and then log back in afterwards. as this is needed to fix this and identify what your class actually is");
	}

	auto_log_info("Hello " + my_name() + ", time to explode!");
	auto_log_info("This is version: " + svn_info("autoscend").last_changed_rev + " Mafia: " + get_revision());
	auto_log_info("This is day " + my_daycount() + ".");
	auto_log_info("Turns played: " + my_turncount() + " current adventures: " + my_adventures());
	auto_log_info("Current Ascension: " + auto_my_path());

	auto_settings();

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
	backupSetting("maximizerCombinationLimit", "100000");
	backupSetting("afterAdventureScript", "scripts/autoscend/auto_post_adv.ash");
	backupSetting("choiceAdventureScript", "scripts/autoscend/auto_choice_adv.ash");
	backupSetting("betweenBattleScript", "scripts/autoscend/auto_pre_adv.ash");
	backupSetting("recoveryScript", "");
	backupSetting("counterScript", "");
	if (!get_property("auto_disableExcavator").to_boolean())
	{
		backupSetting("spadingScript", "excavator.ash");
	}

	backupSetting("hpAutoRecovery", -0.05);
	backupSetting("hpAutoRecoveryTarget", -0.05);
	backupSetting("mpAutoRecovery", -0.05);
	backupSetting("mpAutoRecoveryTarget", -0.05);
	backupSetting("manaBurningTrigger", -0.05);
	backupSetting("manaBurningThreshold", -0.05);
	backupSetting("autoAbortThreshold", -0.05);

	backupSetting("currentMood", "apathetic");

	backupSetting("logPreferenceChange", "true");
	backupSetting("logPreferenceChangeFilter", "maximizerMRUList,testudinalTeachings,auto_maximize_current");
	backupSetting("maximizerMRUSize", 0); // shuts the maximizer spam up!
	
	backupSetting("choiceAdventure1107", 1);

	string charpane = visit_url("charpane.php");
	if(contains_text(charpane, "<hr width=50%><table"))
	{
		auto_log_info("Switching off Compact Character Mode, will resume during bedtime");
		set_property("auto_priorCharpaneMode", 1);
		visit_url("account.php?am=1&pwd=&action=flag_compactchar&value=0&ajax=0", true);
	}

	initializeSettings(); // sets properties (once) for the entire run (all paths).

	initializeSession(); // sets properties for the current session (should all be reset when we're done)

	if(my_familiar() == $familiar[Stooper] && pathAllowsChangingFamiliar())
	{
		auto_log_info("Avoiding stooper stupor...", "blue");
		familiar fam = (is100FamRun() ? get_property("auto_100familiar").to_familiar() : $familiar[Mosquito]);
		use_familiar(fam);
	}

	// =================================================
	// Actually doing stuff should start from here down.
	// =================================================

	resetMaximize(); // initializeDay calls equipBaseline for some reason so this is needed until it is refactored.
	initializeDay(my_daycount());
	handlePulls(my_daycount());

	dailyEvents(); // All once-per-day stuff (which doesn't spend adventures) should go in here

	// Try to consume something if not enough adventures to get going
	if (!auto_unreservedAdvRemaining())
	{
		consumeStuff();
	}
	
	// the main loop of autoscend is doTasks() which is actually called as part of the while.
	while(doTasks())
	{
		if((my_fullness() >= fullness_limit()) && (my_inebriety() >= inebriety_limit()) && (my_spleen_use() == spleen_limit()) && (my_adventures() < 4) && (my_rain() >= 50) && (get_counters("Fortune Cookie", 0, 4) == "Fortune Cookie"))
		{
			abort("Manually handle, because we have fortune cookie and rain man colliding at the end of our day and we don't know quite what to do here");
		}
		#We save the last adventure for a rain man, damn it.
		consumeStuff();
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
