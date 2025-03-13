since r28301;	// _eldritchTentaclesFoughtToday variable
/***
	autoscend_header.ash must be first import
	All non-accessory scripts must be imported here

	Accessory scripts can import autoscend.ash
***/


import <autoscend/autoscend_header.ash>
import <autoscend/combat/auto_combat.ash>		//this file contains its own header. so it needs to be imported early
import <autoscend/autoscend_migration.ash>

import <autoscend/auto_acquire.ash>
import <autoscend/auto_adventure.ash>
import <autoscend/auto_bedtime.ash>
import <autoscend/auto_buff.ash>
import <autoscend/auto_consume.ash>
import <autoscend/auto_craft.ash>
import <autoscend/auto_equipment.ash>
import <autoscend/auto_familiar.ash>
import <autoscend/auto_list.ash>
import <autoscend/auto_monsterparts.ash>
import <autoscend/auto_powerlevel.ash>
import <autoscend/auto_providers.ash>
import <autoscend/auto_restore.ash>
import <autoscend/auto_routing.ash>
import <autoscend/auto_settings.ash>
import <autoscend/auto_sim.ash>
import <autoscend/auto_util.ash>
import <autoscend/auto_zlib.ash>
import <autoscend/auto_zone.ash>

import <autoscend/iotms/clan.ash>
import <autoscend/iotms/elementalPlanes.ash>
import <autoscend/iotms/eudora.ash>
import <autoscend/iotms/mr2007.ash>
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
import <autoscend/iotms/mr2022.ash>
import <autoscend/iotms/mr2023.ash>
import <autoscend/iotms/mr2024.ash>
import <autoscend/iotms/mr2025.ash>

import <autoscend/paths/actually_ed_the_undying.ash>
import <autoscend/paths/auto_path_util.ash>
import <autoscend/paths/avant_guard.ash>
import <autoscend/paths/avatar_of_boris.ash>
import <autoscend/paths/avatar_of_jarlsberg.ash>
import <autoscend/paths/avatar_of_sneaky_pete.ash>
import <autoscend/paths/avatar_of_shadows_over_loathing.ash>
import <autoscend/paths/avatar_of_west_of_loathing.ash>
import <autoscend/paths/bees_hate_you.ash>
import <autoscend/paths/bugbear_invasion.ash>
import <autoscend/paths/casual.ash>
import <autoscend/paths/community_service.ash>
import <autoscend/paths/dark_gyffte.ash>
import <autoscend/paths/disguises_delimit.ash>
import <autoscend/paths/fall_of_the_dinosaurs.ash>
import <autoscend/paths/g_lover.ash>
import <autoscend/paths/gelatinous_noob.ash>
import <autoscend/paths/grey_goo.ash>
import <autoscend/paths/heavy_rains.ash>
import <autoscend/paths/i_love_u_hate.ash>
import <autoscend/paths/kingdom_of_exploathing.ash>
import <autoscend/paths/kolhs.ash>
import <autoscend/paths/legacy_of_loathing.ash>
import <autoscend/paths/license_to_adventure.ash>
import <autoscend/paths/live_ascend_repeat.ash>
import <autoscend/paths/low_key_summer.ash>
import <autoscend/paths/nuclear_autumn.ash>
import <autoscend/paths/one_crazy_random_summer.ash>
import <autoscend/paths/path_of_the_plumber.ash>
import <autoscend/paths/picky.ash>
import <autoscend/paths/pocket_familiars.ash>
import <autoscend/paths/quantum_terrarium.ash>
import <autoscend/paths/small.ash>
import <autoscend/paths/the_source.ash>
import <autoscend/paths/two_crazy_random_summer.ash>
import <autoscend/paths/way_of_the_surprising_fist.ash>
import <autoscend/paths/wereprofessor.ash>
import <autoscend/paths/wildfire.ash>
import <autoscend/paths/you_robot.ash>
import <autoscend/paths/zombie_slayer.ash>

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

	if (inAftercore()) {
		return;
	}

	// called once per ascension on the first launch of the script.
	// should not handle anything other than intialising properties etc.
	// all paths that have extra settings should call their path specific
	// initialise function at the end of this function (may override properties set in here).
	
	//if we detected a path drop we need to reinitialize. either due to dropping a path or breaking ronin in some paths.
	boolean reinitialize = get_property("_auto_reinitialize").to_boolean();
	if(!reinitialize && my_ascensions() == get_property("auto_doneInitialize").to_int())
	{
		return;		//already initialized settings this ascension
	}
	set_location($location[none]);
	invalidateRestoreOptionCache();

	if(!reinitialize)
	{
		set_property("auto_100familiar", $familiar[none]);
		if(my_familiar() != $familiar[none] && pathAllowsChangingFamiliar()) //If we can't control familiar changes, no point setting 100% familiar data
		{
			boolean userAnswer = user_confirm("Familiar already set, is this a 100% familiar run? Will default to 'No' in 15 seconds.", 15000, false);
			if(userAnswer)
			{
				set_property("auto_100familiar", my_familiar());
			}
		}
		//check for a workshed
		if(get_workshed() != $item[none])
		{
			boolean userAnswer = user_confirm("Workshed already set, do you want Autoscend to handle your workshed? Will default to 'Yes' in 15 seconds.", 15000, true);
			if(userAnswer)
			{
				set_property("auto_workshed", "auto");
			}
			else
			{
				set_property("auto_workshed", get_workshed().to_string());
			}
		}
	}

	auto_spoonTuneConfirm();

	icehouseUserErrorProtection();

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
	set_property("auto_beatenUpLastAdv", false);
	remove_property("auto_beatenUpLocations");
	set_property("auto_getBeehive", false);
	set_property("auto_bruteForcePalindome", false);
	set_property("auto_doWhiteys", false);
	set_property("auto_cabinetsencountered", 0);
	set_property("auto_chasmBusted", true);
	set_property("auto_chewed", "");
	set_property("auto_clanstuff", "0");
	set_property("auto_considerCCSCShore", true);
	set_property("auto_copies", "");
	set_property("auto_dakotaFanning", false);
	set_property("auto_day_init", 0);
	set_property("auto_day1_dna", "");
	set_property("auto_debuffAsdonDelay", 0);
	set_property("auto_disableAdventureHandling", false);
	set_property("auto_doCombatCopy", "no");
	set_property("auto_drunken", "");
	set_property("auto_eaten", "");
	set_property("auto_familiarChoice", "");
	remove_property("auto_forcedNC");
	set_property("auto_forceNonCombatLocation", "");
	set_property("auto_forceNonCombatSource", "");
	set_property("auto_forceNonCombatTurn", -1);
	set_property("auto_forceTavern", false);
	set_property("auto_freeruns", "");
	set_property("auto_funTracker", "");
	set_property("auto_getBoningKnife", false);
	set_property("auto_getStarKey", true);
	set_property("auto_getSteelOrgan", get_property("auto_getSteelOrgan_initialize"));
	set_property("auto_gnasirUnlocked", false);
	set_property("auto_grimstoneFancyOilPainting", true);
	set_property("auto_grimstoneOrnateDowsingRod", true);
	set_property("auto_haveoven", false);
	set_property("auto_doGalaktik", get_property("auto_doGalaktik_initialize"));
	set_property("auto_L8_ninjaAssassinFail", false);
	set_property("auto_L8_extremeInstead", false);
	set_property("auto_L9_smutOrcPervert", false);
	set_property("auto_haveSourceTerminal", false);
	set_property("auto_hedge", "fast");
	set_property("auto_hippyInstead", false);
	set_property("auto_holeinthesky", true);
	set_property("auto_ignoreCombat", "");
	set_property("auto_ignoreFlyer", false);
	set_property("auto_instakill", "");
	set_property("auto_instakillSource", "");
	set_property("auto_instakillSuccess", false);
	set_property("auto_iotm_claim", "");
	set_property("auto_lucky", "");
	set_property("auto_luckySource", "none");
	set_property("auto_modernzmobiecount", "");
	set_property("auto_powerfulglove", "");
	set_property("auto_otherstuff", "");
	set_property("auto_paranoia", -1);
	set_property("auto_paranoia_counter", 0);
	set_property("auto_parkaSpikesDeployed", false);
	set_property("auto_avalancheDeployed", false);
	set_property("auto_priorCharpaneMode", "0");
	set_property("auto_powerLevelAdvCount", "0");
	set_property("auto_powerLevelLastAttempted", "0");
	set_property("auto_pulls", "");
	remove_property("auto_shenZonesTurnsSpent");
	remove_property("auto_lastShenTurn");
	set_property("auto_sniffs", "");
	set_property("auto_stopMinutesToRollover", "5");
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
	remove_property("auto_saveMargarita");
	remove_property("auto_csDoWheel");
	remove_property("auto_hccsTurnSave");
	remove_property("auto_hccsNoConcludeDay");
	remove_property("auto_saveSausage");
	remove_property("auto_saveVintage");
	set_property("auto_dontUseCookBookBat", false);
	set_property("auto_dietpills", 0);
	beehiveConsider(false);

	eudora_initializeSettings();
	heavyrains_initializeSettings();
	awol_initializeSettings();
	aosol_initializeSettings();
	theSource_initializeSettings();
	ed_initializeSettings();
	boris_initializeSettings();
	bond_initializeSettings();
	bugbear_initializeSettings();
	nuclear_initializeSettings();
	pete_initializeSettings();
	pokefam_initializeSettings();
	disguises_initializeSettings();
	glover_initializeSettings();
	bat_initializeSettings();
	koe_initializeSettings();
	kolhs_initializeSettings();
	plumber_initializeSettings();
	lowkey_initializeSettings();
	bhy_initializeSettings();
	qt_initializeSettings();
	jarlsberg_initializeSettings();
	robot_initializeSettings();
	wildfire_initializeSettings();
	zombieSlayer_initializeSettings();
	fotd_initializeSettings();
	lol_initializeSettings();
	small_initializeSettings();
	wereprof_initializeSettings();
	ag_initializeSettings();

	set_property("auto_doneInitializePath", my_path().name);		//which path we initialized as
	set_property("auto_doneInitialize", my_ascensions());
	remove_property("_auto_reinitialize");
}

void initializeSession() {
	// called once every time the script is started.
	// anything that needs to be set only for the duration the script is running
	// should be set in here.

	auto_enableBackupCameraReverser();
	set_property("_auto_organSpace", -1.0);
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
	
	if(auto_freeCombatsRemaining() > 0)
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
	boolean voteMonsterAvailable = auto_voteMonster(true);
	boolean digitizeMonsterNext = isOverdueDigitize();
	boolean sausageGoblinAvailable = auto_sausageGoblin();
	boolean backupTargetAvailable = auto_backupTarget();
	boolean voidMonsterAvailable = auto_voidMonster();
	boolean habitatingMonsters = auto_habitatMonster() != $monster[none];

	// if we're a plumber and we're still stuck doing a flat 15 damage per attack
	// then a scaling monster is probably going to be a bad time
	if(in_plumber() && !plumber_canDealScalingDamage())
	{
		// unless we can still kill it in one hit, then it should probably be fine?
		int predictedScalerHP = to_int(0.75 * (my_buffedstat($stat[Muscle]) + monster_level_adjustment()));
		if(predictedScalerHP > 15)
		{
			auto_log_info("Want to burn delay with scaling wanderers, but we can't deal scaling damage yet and it would be too strong :(");
			voteMonsterAvailable = false;
			sausageGoblinAvailable = false;
			addToMaximize("-equip Kramco Sausage O-Matic");
			addToMaximize("-equip &quot;I Voted!&quot; sticker");
		}
	}

	// See the encounter priority flowcharts available at https://i.imgur.com/sdVH4SPh.jpg
	// and https://github.com/loathers/encounter/blob/main/heirarchy.mermaid if adding handling for more stuff

	if (voteMonsterAvailable && !backupTargetAvailable)
	{
		// Voting monsters are inherently free (the ones we fight anyway).
		// don't fight them if we're going to backup because they will overwrite the monster we want to backup
		location voterZone = solveDelayZone(get_property("breathitinCharges").to_int() > 0);
		if (voterZone != $location[none])
		{
			auto_log_info(`Fighting a free {get_property("_voteMonster")} in {voterZone.to_string()} to burn delay!`, "green");
			set_property("auto_nextEncounter",get_property("_voteMonster"));
			if (auto_voteMonster(true, voterZone))
			{
				return true;
			}
			set_property("auto_nextEncounter","");
		}
	}

	if (digitizeMonsterNext)
	{
		// Digitize Wanderers will happen regardless so prioritize handling them.
		// hopefully they don't overwrite something we want to backup.
		location digitizeZone = solveDelayZone(isFreeMonster(get_property("_sourceTerminalDigitizeMonster").to_monster()) && get_property("breathitinCharges").to_int() > 0);
		if (digitizeZone == $location[none])
		{
			// if the monster is inherently free and we have Breathitin charges, fight it in the Noob Cave since we can't avoid it
			// and we likely want to fight it. Noob Cave is available from turn 0 & is not outdoors so Breathitin won't trigger.
			digitizeZone = $location[Noob Cave];
		}
		auto_log_info(`Fighting a {get_property("_sourceTerminalDigitizeMonster")} in {digitizeZone.to_string()} to burn delay!`, "green");
		set_property("auto_nextEncounter",get_property("_sourceTerminalDigitizeMonster"));
		if (autoAdv(digitizeZone))
		{
			return true;
		}
		set_property("auto_nextEncounter","");
	}

	if (backupTargetAvailable)
	{
		location backupZone = solveDelayZone(isFreeMonster(get_property("lastCopyableMonster").to_monster()) && get_property("breathitinCharges").to_int() > 0);
		if (backupZone == $location[none])
		{
			// if the monster is inherently free and we have Breathitin charges, fight it in the Noob Cave since we can't avoid it
			// and we likely want to fight it. Noob Cave is available from turn 0 & is not outdoors so Breathitin won't trigger.
			backupZone = $location[Noob Cave];
		}

		auto_log_info(`Fighting a {get_property("lastCopyableMonster")} in {backupZone.to_string()} to burn delay!`, "green");
		if (auto_backupToYourLastEnemy(backupZone))
		{
			return true;
		}
	}

	if (sausageGoblinAvailable)
	{
		// Sausage Goblins are inherently free
		location goblinZone = solveDelayZone(get_property("breathitinCharges").to_int() > 0);
		if (goblinZone != $location[none])
		{
			auto_log_info(`Fighting a Sausage Goblin in {goblinZone.to_string()} to burn delay!`, "green");
			if (auto_sausageGoblin(goblinZone, ""))
			{
				return true;
			}
		}
	}

	if (voidMonsterAvailable)
	{
		// Void monsters are inherently free (the ones we fight anyway).
		location voidZone = solveDelayZone(get_property("breathitinCharges").to_int() > 0);
		if (voidZone != $location[none])
		{
			auto_log_info(`Fighting a Void monster in {voidZone.to_string()} to burn delay!`, "green");
			if (auto_voidMonster(voidZone))
			{
				return true;
			}
		}
	}

	if (habitatingMonsters)
	{
		location habitatZone = solveDelayZone(isFreeMonster(auto_habitatMonster()) && get_property("breathitinCharges").to_int() > 0);
		if (habitatZone != $location[none])
		{
			auto_log_info(`Might be fighting a {auto_habitatMonster()} in {habitatZone.to_string()} to burn delay!`, "green");
			if (autoAdv(habitatZone))
			{
				return true;
			}
		}
	}

	if (voteMonsterAvailable)
	{
		auto_log_warning("Had overdue voting monster but couldn't find a zone to burn delay", "red");
	}
	if (digitizeMonsterNext) 
	{
		auto_log_warning("Had overdue digitize but couldn't find a zone to burn delay", "red");
	}
	if (sausageGoblinAvailable)
	{
		auto_log_warning("Had overdue sausage but couldn't find a zone to burn delay", "red");
	}
	if (voidMonsterAvailable)
	{
		auto_log_warning("Cursed Magnifying Glass's void monster is next but couldn't find a zone to burn delay", "red");
	}
	if (habitatingMonsters)
	{
		auto_log_warning("Habitating a monster but couldn't find a zone to burn delay", "red");
	}
	return false;
}

boolean LX_calculateTheUniverse(boolean speculative)
{
	if(in_wildfire())
	{
		return LX_wildfire_calculateTheUniverse();
	}
	if(my_mp() < mp_cost($skill[Calculate the Universe]))
	{
		return false;
	}
	if(get_property("_universeCalculated").to_int() >= min(3, get_property("skillLevel144").to_int()))
	{
		return false;
	}
	
	//do we want to summon a [War Frat 151st Infantryman] for the frat warrior outfit?
	if(!possessOutfit("Frat Warrior Fatigues") && auto_warSide() == "fratboy")
	{
		if(doNumberology("battlefield", false) != -1 && adjustForYellowRayIfPossible($monster[War Frat 151st Infantryman]))
		{
			if(speculative)
			{
				return true;
			}
			else
			{
				return (doNumberology("battlefield") != -1);
			}
		}
		return false;	//we want 151 and can get it in general. but not right now. so save it for later
	}
	
	doNumberology("adventures3");
	return false;	//we do not want to restart the loop as all we're doing is generating 3 adventures
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

boolean LX_doVacation()
{
	if(in_koe() || is_werewolf())
	{
		return false;		//cannot vacation in kingdom of exploathing path or are a werewolf in wereprofessor
	}
	
	int meat_needed = 500;
	int adv_needed = 3;
	int adv_budget = my_adventures() - auto_advToReserve();
	if(in_wotsf())
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
	if(in_plumber())	//avoid error for not having plumber gear equipped.
	{
		plumber_equipTool($stat[moxie]);
		equipMaximizedGear();
	}

	return autoAdv(1, $location[The Shore\, Inc. Travel Agency]);
}

boolean auto_doTempleSummit()
{
	if(!hidden_temple_unlocked() || internalQuestStatus("questL11Worship") < 3)
	{
		return false;
	}
	if(available_amount($item[stone wool])==0)
	{
		return false;
	}
	if (get_property("lastTempleAdventures").to_int()>=my_ascensions())
	{
		return false;
	}
	buffMaintain($effect[Stone-Faced]);
	if(have_effect($effect[Stone-Faced]) == 0)
	{
		return false;
	}
	return autoAdv($location[The Hidden Temple]);
}

void initializeDay(int day)
{
	if(inAftercore())
	{
		return;
	}

	invalidateRestoreOptionCache();

	if (get_property("auto_day_init").to_int() < day)
	{
		set_property("auto_powerLevelLastLevel", "0");
		set_property("auto_delayLastLevel", "0");
		set_property("auto_cmcConsultLastLevel", "0");
		set_property("auto_breathitinLastLevel", "0");
	}

	if(!possessEquipment($item[Your Cowboy Boots]) && get_property("telegraphOfficeAvailable").to_boolean() && is_unrestricted($item[LT&T Telegraph Office Deed]))
	{
		#string temp = visit_url("desc_item.php?whichitem=529185925");
		#if(equipped_item($slot[bootspur]) == $item[Nicksilver spurs])
		#if(contains_text(temp, "Item Drops from Monsters"))
		#{
			string temp = visit_url("place.php?whichplace=town_right&action=townright_ltt");
		#}
	}

	if(auto_is_valid($item[Fourth of May cosplay saber]))
	{
		auto_saberDailyUpgrade(day);
	}

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
	
	auto_getClanPhotoBoothDefaultItems();
	auto_getClanPhotoBoothEffect("space",3);

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

	auto_doPrecinct();
	if(!(in_koe() || in_lar()) && (item_amount($item[Cop Dollar]) >= 10) && (item_amount($item[Shoe Gum]) == 0))
	{
		boolean temp = cli_execute("make shoe gum");
	}
	
	//a free to cast intrinsic that makes swords count as clubs. there is no reason to ever have it on if not a seal clubber?
	//regardless of class there is a reason not to if auto_configureRetrocape("vampire", "kill") can be used. it needs the sword to count as a sword and not as a club
	if(my_class() == $class[seal clubber] && auto_have_skill($skill[Iron Palm Technique]) && (have_effect($effect[Iron Palms]) == 0))
	{
		use_skill(1, $skill[Iron Palm Technique]);
	}

	// Get emotionally chipped if you have the item.  boris\jarlsberg\sneaky pete\zombie slayer\ed cannot use this skill so excluding.
	if (!have_skill($skill[Emotionally Chipped]) && item_amount($item[spinal-fluid-covered emotion chip]) > 0 && can_read_skillbook($item[spinal-fluid-covered emotion chip]))
	{
		use(1, $item[spinal-fluid-covered emotion chip]);
	}
	
	// Open our duffel bag
	auto_openMcLargeHugeSkis();
	
	//you must finish the Toot Oriole quest to unlock council quests.
	tootOriole();

	ed_initializeDay(day);
	boris_initializeDay(day);
	nuclear_initializeDay(day);
	pete_initializeDay(day);
	glover_initializeDay(day);
	bat_initializeDay(day);
	jarlsberg_initializeDay(day);

	// Bulk cache mall prices
	if(!in_hardcore() && get_property("auto_day_init").to_int() < day)
	{
		auto_log_info("Bulk caching mall prices for consumables");
		if(get_property("auto_last_mallcached") != today_to_string())
		{
			mall_prices("food");
			mall_prices("booze");
			set_property("auto_last_mallcached",today_to_string());	//should not cache food,booze again after starting a new ascension on the same day
		}
		//food,booze will explicitly request historical_price to avoid making individual mall searches, in case a new mafia session gets started
		//hprestore and mprestore types corresponding with mall_prices search categories are not available. but it's not as many searches as food,booze
		//so cache those again even in a new ascension in case it's getting started in a new session
		mall_prices("hprestore");
		mall_prices("mprestore");
	}

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
			if(item_amount($item[baby bodyguard]) > 0 && !have_familiar($familiar[burly bodyguard])) //will only happen in Avant Guard
			{
				use(1, $item[baby bodyguard]);
			}

			if((auto_get_clan_lounge() contains $item[Clan Floundry]) && (item_amount($item[Fishin\' Pole]) == 0))
			{
				visit_url("clan_viplounge.php?action=floundry");
			}

			tootGetMeat();

			heavyrains_initializeDay(day);
			// It's nice to have a moxie weapon for Flock of Bats form
			if(in_darkGyffte() && get_property("darkGyfftePoints").to_int() < 21 && !possessEquipment($item[disco ball]))
			{
				acquireGumItem($item[disco ball]);
			}
			if(!(is_boris() || is_jarlsberg() || is_pete() || isActuallyEd() || in_darkGyffte() || in_plumber() || in_wereprof()))
			{
				if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && (auto_predictAccordionTurns() < 5) && ((my_meat() > npc_price($item[Toy Accordion])) && (npc_price($item[Toy Accordion]) != 0)))
				{
					//Try to get Antique Accordion early if we possibly can.
					if(isUnclePAvailable() && ((my_meat() > npc_price($item[Antique Accordion])) && (npc_price($item[Antique Accordion]) != 0)) && !in_glover())
					{
						auto_buyUpTo(1, $item[Antique Accordion]);
					}
					// Removed "else". In some situations when mafia or supporting scripts are behaving wonky we may completely fail to get an accordion
					if((isArmoryAvailable()) && (item_amount($item[Antique Accordion]) == 0))
					{
						auto_buyUpTo(1, $item[Toy Accordion]);
					}
					
					if((in_koe()) && (item_amount($item[Antique Accordion]) == 0) && (koe_rmi_count() >= 10))
					{
						koe_acquire_rmi(10);
						buy($coinmaster[Cosmic Ray\'s Bazaar], 1, $item[Antique Accordion]);
					}
				}
				acquireTotem();
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

		if((get_property("lastCouncilVisit").to_int() < my_level()))
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
					if (have_familiar(fam) && !in_bhy())
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
		
		if(get_property("auto_day_init").to_int() < 2)
		{
			useTonicDjinn();
			
			if(item_amount($item[gym membership card]) > 0)
			{
				equipStatgainIncreasers();
				use(1, $item[gym membership card]);
			}

			heavyrains_initializeDay(day);

			if(!in_hardcore() && (item_amount($item[Handful of Smithereens]) <= 5))
			{
				pulverizeThing($item[Hairpiece On Fire]);
				pulverizeThing($item[Vicar\'s Tutu]);
			}
			while(acquireHermitItem($item[11-Leaf Clover]));
			if((item_amount($item[Antique Accordion]) == 0) && (item_amount($item[Aerogel Accordion]) == 0) && isUnclePAvailable() && ((my_meat() > npc_price($item[Antique Accordion])) && (npc_price($item[Antique Accordion]) != 0)) && (auto_predictAccordionTurns() < 10) && !(is_boris() || is_jarlsberg() || is_pete() || isActuallyEd() || in_darkGyffte() || in_plumber() || !in_glover()))
			{
				auto_buyUpTo(1, $item[Antique Accordion]);
			}
			if(is_boris())
			{
				if((item_amount($item[Clancy\'s Crumhorn]) == 0) && (minstrel_instrument() != $item[Clancy\'s Crumhorn]))
				{
					auto_buyUpTo(1, $item[Clancy\'s Crumhorn]);
				}
			}
			if(auto_have_skill($skill[Summon Smithsness]) && (my_mp() > (3 * mp_cost($skill[Summon Smithsness]))))
			{
				use_skill(3, $skill[Summon Smithsness]);
			}

			if(item_amount($item[handful of smithereens]) >= 2)
			{
				auto_buyUpTo(2, $item[Ben-Gal&trade; Balm]);
				cli_execute("make 2 louder than bomb");
			}
		}
		if (chateaumantegna_havePainting() && !isActuallyEd())
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
			while(acquireHermitItem($item[11-leaf Clover]));

			picky_pulls();
		}
	}
	else if(day == 4)
	{
		if(get_property("auto_day_init").to_int() < 4)
		{
			while(acquireHermitItem($item[11-leaf Clover]));
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
	
	// Hit bastille, then council in case we levelled up (and unlocked getaway camp)
	cheeseWarMachine(0, 0, 0, 0);
	council();

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

	while(zataraClanmate());

	if(item_amount($item[Genie Bottle]) > 0 && auto_is_valid($item[genie bottle]) && auto_is_valid($item[pocket wish]) && !in_glover())
	{
	//if bottle is valid and pocket wishes are not (such as in glover) then we should save the wishes for use and only convert leftovers into pocket wishes at bedtime
		for(int i=get_property("_genieWishesUsed").to_int(); i<3; i++)
		{
			makeGeniePocket();
		}
	}

	auto_getGuzzlrCocktailSet();
	auto_latheAppropriateWeapon();
	auto_harvestBatteries();
	pickRocks();
	auto_SITCourse();
	auto_LegacyOfLoathingDailies();
	auto_buyFrom2002MrStore();
	auto_useBlackMonolith();
	auto_scepterSkills();
	auto_getAprilingBandItems();
	auto_MayamClaimAll();
	auto_buyFromSeptEmberStore();
	
	return true;
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
	// although seals can be fought drunk, it complicates code without serving a purpose
	if(my_inebriety() > inebriety_limit())
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
				auto_buyUpTo(1, $item[seal-blubber candle]);
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
			auto_buyUpTo(1, $item[figurine of an armored seal]);
			auto_buyUpTo(10, $item[seal-blubber candle]);
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
				auto_buyUpTo(1, $item[Tenderizing Hammer]);
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

boolean councilMaintenance()
{
	if (in_koe())
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
	int limit = (in_avantGuard() ? 100 : 50);
	if(place.turns_spent > limit)
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
		
		//holiday events
		The Arrrboretum, The Spectral Pickle Factory] contains place)
		{
			tooManyAdventures = false;
		}

		if(tooManyAdventures && in_theSource())
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
		
		if (tooManyAdventures && in_robot())
		{
			if ($locations[The Penultimate Fantasy Airship, The Smut Orc Logging Camp, The Haunted Bedroom, The Haunted Billiards Room] contains place)
			{
				tooManyAdventures = false;
			}
		}

		if ($locations[The Haunted Gallery] contains place && place.turns_spent < 100)
		{
			tooManyAdventures = false;
		}

		if ($locations[The Daily Dungeon] contains place && get_property("auto_forceFatLootToken").to_boolean())
		{
			tooManyAdventures = false;
		}
		
		boolean can_powerlevel_stench = elementalPlanes_access($element[stench]) && auto_have_skill($skill[Summon Smithsness]) && get_property("auto_beatenUpCount").to_int() == 0;
		boolean has_powerlevel_iotm = can_powerlevel_stench || elementalPlanes_access($element[spooky]) || elementalPlanes_access($element[cold]) || elementalPlanes_access($element[sleaze]) || elementalPlanes_access($element[hot]) || neverendingPartyAvailable();
		if(!has_powerlevel_iotm && $locations[The Haunted Gallery, The Haunted Bedroom] contains place)
		{
			tooManyAdventures = false;		//if we do not have iotm powerlevel zones then we are forced to use haunted gallery or bedroom
		}
		
		if(my_session_adv() < get_property("_auto_override_tooManyAdv").to_int())
		{
			tooManyAdventures = false;		//currently in override for too many adv
		}

		if(tooManyAdventures)
		{
			if(get_property("auto_newbieOverride").to_boolean())
			{
				set_property("auto_newbieOverride", false);
				set_property("_auto_override_tooManyAdv", my_session_adv()+5);		//override 5 adv at a time
				auto_log_warning("We have spent " + place.turns_spent + " turns at '" + place + "' and that is bad... override accepted.", "red");
			}
			else
			{
				print("You can bypass this once by executing the gCLI command:", "blue");
				print("set auto_newbieOverride = true", "blue");
				abort("We have spent " + place.turns_spent + " turns at '" + place + "' and that is bad... aborting.");
			}
		}
	}

	if(last_monster() == $monster[Crate] && !(get_property("screechDelay").to_boolean()) && (in_wereprof() && !($location[Noob Cave].turns_spent < 8))) //want 7 turns of Noob Cave in Wereprof for Smashed Scientific Equipment
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

void beatenUpResolution()
{
	if(have_effect($effect[Beaten Up]) > 0)
	{
		if(get_property("auto_beatenUpCount").to_int() > 10 && get_property("lastEncounter") != "Poetic Justice")
		{
			abort("We are getting beaten up too much, this is not good. Aborting.");
		}
		acquireHP();
	}

	if(have_effect($effect[Beaten Up]) > 0)
	{
		if(have_effect($effect[Beaten Up]) == 2 && get_property("lastEncounter") == "Dr. Awkward" && internalQuestStatus("questL11Palindome") > 5)
		{
			//beaten up by the quest item when unlocking Dr. Awkward, not by failing a fight
			set_property("_auto_AwkwardBeatenUp",my_turncount().to_string());
			auto_log_info("We must have failed to remove beaten up before defeating Dr. Awkward and that hasn't stopped us so far...");
		}
		else if(have_effect($effect[Beaten Up]) == 1 && get_property("_auto_AwkwardBeatenUp").to_int() != 0 && my_turncount() - get_property("_auto_AwkwardBeatenUp").to_int() <= 1)
		{
			auto_log_info("This should be the last turn of beaten up from Dr. Awkward");
		}
		else
		{
			cli_execute("refresh all");
			if(have_effect($effect[Beaten Up]) > 0)
			{
				abort("We failed to remove beaten up. Adventuring in the same place that we got beaten in with half stats will just result in us dying again");
			}
		}
	}
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
	if(in_wotsf()) 
	{
		return false;		//selling things in the way of the surprising fist only donates the money to charity, so we should not autosell anything automatically
	}
	foreach it in $items[dense meat stack, meat stack,  //quest rewards that are better off as meat. If we ever need it we can freely recreate them at no loss.
	Blue Money Bag, Red Money Bag, White Money Bag,  //vampyre path boss rewards and major source of meat in run.
	Space Blanket, //can be inside MayDay package. Only purpose is to sell for meat
	Void Stone] //dropped by Void Fights when Cursed Magnifying Glass is equiped. Only purpose is to sell for meat
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
		if(item_amount(it) > 1 && is_unrestricted(it))		//for these items we want to keep 1 in stock. sell the rest
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

	foreach it in $items[Anticheese, Awful Poetry Journal, Azurite, Beach Glass Bead, Beer Bomb, Bit-o-Cactus, Clay Peace-Sign Bead, Cocoa Eggshell Fragment, Decorative Fountain, Dense Meat Stack, Empty Cloaca-Cola Bottle, Enchanted Barbell, Eye Agate, Fancy Bath Salts, Frigid Ninja Stars, Feng Shui For Big Dumb Idiots, Giant Moxie Weed, Half of a Gold Tooth, Headless Sparrow, Imp Ale, Keel-Haulin\' Knife, Kokomo Resort Pass, Lapis Lazuli, Leftovers Of Indeterminate Origin, Mad Train Wine, Mangled Squirrel, Margarita, Meat Paste, Mineapple, Moxie Weed, Patchouli Incense Stick, Phat Turquoise Bead, Photoprotoneutron Torpedo, Plot Hole, Procrastination Potion, Rat Carcass, Sea Honeydew, Sea Lychee, Sea Tangelo, Smelted Roe, Spicy Jumping Bean Burrito, Spicy Bean Burrito, Strongness Elixir, Sunken Chest, Tambourine Bells, Tequila Sunrise, Uncle Jick\'s Brownie Mix, Windchimes]
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
	if(item_amount($item[Chaos Butterfly]) > 1)
	{
		auto_autosell(item_amount($item[Chaos Butterfly]) - 1, $item[Chaos Butterfly]);
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
	if(in_heavyrains())
	{
		auto_log_info("Thunder: " + my_thunder() + " Rain: " + my_rain() + " Lightning: " + my_lightning(), "green");
	}
	if(isActuallyEd())
	{
		auto_log_info("Ka Coins: " + item_amount($item[Ka Coin]) + " Lashes used: " + get_property("_edLashCount"), "green");
	}
	if(in_plumber())
	{
		auto_log_info("Coins: " + item_amount($item[Coin]), "green");
	}
}

void resetState() {
	//These settings should never persist into another turn, ever. They only track something for a single instance of the main loop.
	//We use boolean instead of adventure count because of free combats.
	
	remove_property("auto_combatDirective");		//An action to execute at the start of next combat. resets every loop.
	remove_property("auto_digitizeDirective");		//digitize a specified monster on the next combat.
	set_property("auto_doCombatCopy", "no");
	set_property("_auto_thisLoopHandleFamiliar", false); // have we called handleFamiliar this loop
	set_property("auto_disableAdventureHandling", false); // used to stop auto_pre_adv and auto_post_adv from doing anything.
	set_property("auto_disableFamiliarChanging", false); // disable autoscend making changes to familiar
	set_property("auto_familiarChoice", ""); // which familiar do we want to switch to during pre_adventure
	set_property("choiceAdventure1387", -1); // using the force non-combat
	set_property("_auto_tunedElement", ""); // Flavour of Magic elemental alignment
	set_property("auto_nextEncounter", ""); // monster that was expected last turn
	set_property("auto_habitatMonster", ""); // monster we want to cast Recall Facts: Monster Habitats
	set_property("auto_purple_candled", ""); //monster we want to cast Blow the Purple Candle
	set_property("auto_nonAdvLoc", false); // location is a non-adventure.php location

	if(doNotBuffFamiliar100Run())		//some familiars are always bad
	{
		set_property("_auto_bad100Familiar", true);			//disable buffing familiar
	}
	else		//some familiars are only bad at certain locations
	{
		set_property("_auto_bad100Familiar", false); 		//reset to not bad. target location might set them as bad again
	}

	set_property("auto_parkaSetting", ""); // jurassic parka setting
	set_property("auto_retrocapeSettings", ""); // retrocape config
	set_property("auto_januaryToteAcquireCalledThisTurn", false); // january tote item switching

	horseDefault(); // horsery tracking

	set_property("auto_snapperPhylum", ""); // internal Red-Nosed Snapper phylum tracking. Ensures we only change it maximum once per adventure (and don't lose charges)

	bat_formNone(); // Vampyre form tracking

	resetMaximize();

	if (canChangeToFamiliar($familiar[Left-Hand Man]) && familiar_equipped_equipment($familiar[Left-Hand Man]) != $item[none])
	{
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

	string task_path = my_path().name;
	if (!(task_order contains task_path))
	{
		task_path = "default";
	}

	foreach i,task_function,condition_function in task_order[task_path]
	{
		auto_log_debug("Attempting to execute task " + i + " " + task_function);
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
		familiar fam = (is100FamRun() ? get_property("auto_100familiar").to_familiar() : findNonRockFamiliarInTerrarium());
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
	// Check if rollover's coming up soon
	if(almostRollover())
	{
		print("Rollover's coming!  Gotta consume what we can and go to bed!", "red");
		// How much organ space left?  If none, go to bed
		float organ_space = consumptionProgress();
		auto_log_debug(`{organ_space} organ space`, "blue");
		if(organ_space >= 0.999)
		{
		  return false;
		}
		// How much organ space was available the last time we were here?
		float previous_space = get_property("_auto_organSpace").to_float();
		float organ_space_change = organ_space - previous_space;
		auto_log_debug(`{previous_space} previous space`, "blue");
		auto_log_debug(`{organ_space_change} organ space change`, "blue");
		set_property("_auto_organSpace", organ_space);
		// If no space used the last time consumption was done, don't bother trying again
		if(organ_space_change < 0.001)
		{
		  return false;
		}
		// There's space left to fill, but let's continue only if we don't have enough adventures
		return needToConsumeForEmergencyRollover();
	}
	
	casualCheck();
	
	print_header();

	auto_interruptCheck(false);

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
	if (in_wereprof()) {
		// wereprof doesn't update wereProfessorTransformTurns unless you hit the charpane
		visit_url("charpane.php", false);
	}

	// actually doing stuff should start from here onwards.
	resetState();

	basicAdjustML();

	finishBuildingSmutOrcBridge();
	councilMaintenance();
	auto_buySkills();		// formerly picky_buyskills() now moved here
	awol_buySkills();
	awol_useStuff();
	aosol_unCurse();
	aosol_buySkills();
	theSource_buySkills();
	jarlsberg_buySkills();
	boris_buySkills();
	pete_buySkills();
	zombieSlayer_buySkills();
	auto_refreshQTFam();
	lol_buyReplicas();
	iluh_buyEquiq();

	oldPeoplePlantStuff();
	use_barrels();
	auto_latteRefill();
	auto_buyCrimboCommerceMallItem();
	houseUpgrade();

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
	auto_chapeau();
	auto_buyFireworksHat();
	auto_CMCconsult();
	auto_checkTrainSet();
	prioritizeGoose();
	auto_useWardrobe();
	auto_MayamClaimAll();
	
	ocrs_postCombatResolve();
	beatenUpResolution();
	lar_safeguard();


	//Early adventure options that we probably want
	if(dna_startAcquire())				return true;
	if(LM_boris())						return true;
	if(LM_pete())						return true;
	if(LM_gnoob())						return true;
	if(LM_nuclear())					return true;
	if(LM_lar())						return true;
	if(LM_batpath()) 					return true;
	if(heavyrains_buySkills())			return true;
	if(LM_canInteract()) 				return true;
	if(LM_kolhs()) 						return true;
	if(LM_jarlsberg())					return true;
	if(LM_robot())						return true;
	if(LM_plumber())					return true;
	if(LM_zombieSlayer())				return true;

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

	if(theSource_oracle())				return true;
	if(LX_theSource())					return true;
	if(LX_ghostBusting())				return true;
	if(witchessFights())				return true;

	//
	//Adventuring actually starts here.
	//

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
	if (auto_juneCleaverAdventure()) { return true; }
	if (auto_burnLeaves()) { return true; }
	if(LX_ForceNC())					return true;
	if(LX_dronesOut())					return true;
	if(LM_bond())						return true;
	if(LX_calculateTheUniverse(false))	return true;
	rockGardenEnd();
	adventureFailureHandler();
	dna_sorceressTest();
	dna_generic();
	if(LA_wildfire())					return true;
	if(LA_robot())						return true;
	if(auto_autumnatonQuest())			return true;
	if(auto_smallCampgroundGear())		return true;
	auto_lostStomach(false);
	autoCleanse(); //running turbo only
	if(auto_doPhoneQuest())				return true;
	
	if(auto_doTempleSummit())		return true;
	
	if (process_tasks()) return true;

	meatReserveMessage();
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

	if(in_community())
	{
		abort("Community Service is no longer supported.");
	}

	if (in_bad_moon())
	{
		boolean nope = user_confirm("Bad moon is not a thing we will ever support even if you can somehow meet the scripts minimum requirements. Do you understand?");
		string failure = (nope ? "Just no." : "Even if you don't understand, it's still no.");
		abort(failure);
	}

	LX_handleIntroAdventures(); // handle early non-combats in challenge paths.
	cli_execute("refresh all");

	if(to_string(my_class()) == "Astral Spirit")
	{
		# my_class() can report Astral Spirit even though it is not a valid class....
		//workaround for this bug specifically https://kolmafia.us/showthread.php?25579
		abort("Mafia thinks you are an astral spirit. Type \"logout\" in gCLI and then log back in afterwards. as this is needed to fix this and identify what your class actually is");
	}

	auto_log_info("Hello " + my_name() + ", time to explode!");
	auto_log_info("This is version: " + git_info("autoscend").commit + " Mafia: " + get_revision());
	auto_log_info("This is day " + my_daycount() + ".");
	auto_log_info("Turns played: " + my_turncount() + " current adventures: " + my_adventures());
	auto_log_info("Current Ascension: " + my_path().name);

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
		backupSetting("spadingScript", "excavator.js");
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
	backupSetting("allowNonMoodBurning", true); // required to be true for burn cli cmd to work properly
	backupSetting("lastChanceThreshold", 1); // burn command will always use last chance skill, if we have no active buffs
	backupSetting("lastChanceBurn",""); // clear default mana burn skill so mafia doesn't attempt to cast a skill we don't currently have

	string charpane = visit_url("charpane.php");
	if(contains_text(charpane, "<hr width=50%><table"))
	{
		auto_log_info("Switching off Compact Character Mode, will resume during bedtime");
		set_property("auto_priorCharpaneMode", 1);
		visit_url("account.php?am=1&pwd=&action=flag_compactchar&value=0&ajax=0", true);
	}

	initializeSettings(); // sets properties (once) for the entire run (all paths).
	pathDroppedCheck();		//detects path changing. such as due to being dropped. and reinitialize appropriate settings

	initializeSession(); // sets properties for the current session (should all be reset when we're done)

	if(my_familiar() == $familiar[Stooper] && pathAllowsChangingFamiliar())
	{
		auto_log_info("Avoiding stooper stupor...", "blue");
		familiar fam = (is100FamRun() ? get_property("auto_100familiar").to_familiar() : findNonRockFamiliarInTerrarium());
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
	print_html("If you want to contribute, please open an issue <a href=\"https://github.com/loathers/autoscend/issues\">on Github</a>");
	print_html("A FAQ with common issues (and tips for a great bug report) <a href=\"https://docs.google.com/document/d/1AfyKDHSDl-fogGSeNXTwbC6A06BG-gTkXUAdUta9_Ns\">can be found here</a>");
	print_html("The developers also hang around <a href=\"https://discord.gg/96xZxv3\">on the Ascension Speed Society discord server</a>");
	print_html("");
}

void sad_times()
{
	print_html('autoscend (formerly sl_ascend) is under new management. Soolar (the maintainer of sl_ascend) and Jeparo (the most active contributor) have decided to cease development of sl_ascend in response to Jick\'s behavior that has recently <a href="https://www.reddit.com/r/kol/comments/d0cq9s/allegations_of_misconduct_by_asymmetric_members/">come to light</a>. New developers have taken over maintenance and rebranded sl_ascend to autoscend as per Soolar\'s request. Please be patient with us during this transition period. Please see the readme on the <a href="https://github.com/loathers/autoscend">github</a> page for more information.');
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

void main(string... input)
{
	backupSetting("printStackOnAbort", true);

	// parse input
	if(count(input) > 0)
	{
		switch(input[0])
		{
			case "sim":
				// display useful items/skills/perms/etc and if the user has them
				printSim();
				return;
			case "turbo":
			// gotta go faaaaaast. Doing a double confirm because of the nature of this parameter.
				user_confirm("This will get expensive for you. This should only be used if you are trying to go for a 1-day and don't care about expenses. Do you really want to do this? Will default to 'No' in 15 seconds.", 15000, false);
				{
					user_confirm("This will use UMSBs and Spice Melanges if you have them. If you are ok with this, you have 15 seconds to hit 'Yes'", 15000, false);
					{
						set_property("auto_turbo", "true");
						auto_log_info("Ka-chow! Gotta go fast.");
						break;
					}
				}
			default:
				auto_log_info("Running normal autoscend because you didn't enter in a valid parameter");
		}
	}

	print_help_text();
	sad_times();
	if(!autoscend_migrate() && !user_confirm("autoscend might not have upgraded from a previous version correctly, do you want to continue? Will default to true in 10 seconds.", 10000, true)){
		abort("User aborted script after failed migration.");
	}
	safe_preference_reset_wrapper(3);
}
