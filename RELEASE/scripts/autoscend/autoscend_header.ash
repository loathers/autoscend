//	This is the primary header file for autoscend.
//	All potentially cross-dependent functions should be defined here such that we can use them from
//	other scripts without the circular dependency issue. Thanks Ultibot for the advice regarding this.
//	All functions that are defined outside of autoscend must include a note regarding where they come from
//		Seriously, it\'s rude not to.

//	Question Functions
//	Denoted as L<classification>[<path>]_<name>:
//		<classification>: Level to be used (Numeric, X for any). A for entire ascension.
//		<classification>: M for most of ascension, "sc" for Seal Clubber only
//		<path>: [optional] indicates path to be used in. "ed" for ed, "cs" for community service
//			Usually separated with _
########################################################################################################

//auto_record.ash is used to define records. allowing us to then define functions that return said records.
import <autoscend/autoscend_record.ash>

########################################################################################################
//Defined in autoscend.ash
void initializeSettings();
void initializeSession();
int auto_advToReserve();
boolean auto_unreservedAdvRemaining();
boolean LX_burnDelay();
boolean LX_calculateTheUniverse(boolean speculative);
boolean tophatMaker();
boolean LX_doVacation();
void initializeDay(int day);
boolean dailyEvents();
boolean Lsc_flyerSeals();
boolean councilMaintenance();
boolean adventureFailureHandler();
void beatenUpResolution();
int speculative_pool_skill();
boolean autosellCrap();
void print_header();
void resetState();
boolean doTasks();
void auto_begin();
void print_help_text();
void sad_times();
void safe_preference_reset_wrapper(int level);

########################################################################################################
//Defined in autoscend/iotms/clan.ash
int[item] auto_get_clan_lounge();
boolean handleFaxMonster(monster enemy);
boolean handleFaxMonster(monster enemy, string option);
boolean handleFaxMonster(monster enemy, boolean fightIt);
boolean handleFaxMonster(monster enemy, boolean fightIt, string option);
boolean checkFax(monster enemy);
boolean [location] get_floundry_locations();
int changeClan(string clanName);
int changeClan(int toClan);
int changeClan();
int hotTubSoaksRemaining();
boolean isHotTubAvailable();
int doHottub();
boolean isSpeakeasyDrink(item drink);
boolean canDrinkSpeakeasyDrink(item drink);
boolean drinkSpeakeasyDrink(item drink);
boolean drinkSpeakeasyDrink(string drink);
boolean zataraAvailable();
boolean zataraSeaside(string who);
boolean zataraClanmate(string who);
boolean eatFancyDog(string dog);
boolean auto_floundryUse();
boolean auto_floundryAction();
boolean auto_floundryAction(item it);

########################################################################################################
//Defined in autoscend/iotms/auto_elementalPlanes.ash
item[element] getCharterIndexable();
boolean elementalPlanes_initializeSettings();
boolean elementalPlanes_access(element ele);
boolean elementalPlanes_takeJob(element ele);
boolean dinseylandfill_garbageMoney();
boolean getDiscoStyle(int choice);
boolean getDiscoStyle();
boolean volcano_lavaDogs();
boolean volcano_bunkerJob();

########################################################################################################
//Defined in autoscend/iotms/auto_eudora.ash
boolean eudora_available();
boolean[item] eudora_initializeSettings();
item eudora_current();
int[item] eudora_xiblaxian();

########################################################################################################
//Defined in autoscend/iotms/mr2011.ash
boolean isClipartItem(item it);
boolean hasLegionKnife();
boolean pullLegionKnife();

########################################################################################################
//Defined in autoscend/iotms/mr2012.ash
void auto_reagnimatedGetPart(int choice);
boolean handleRainDoh();

########################################################################################################
//Defined in autoscend/iotms/mr2013.ash
void makeStartingSmiths();
boolean didWePlantHere(location loc);
void trickMafiaAboutFlorist();
void oldPeoplePlantStuff();

########################################################################################################
//Defined in autoscend/iotms/mr2014.ash
boolean handleBjornify(familiar fam);
boolean considerGrimstoneGolem(boolean bjornCrown);
boolean dna_startAcquire();
boolean dna_generic();
boolean dna_sorceressTest();
boolean dna_bedtime();
boolean LX_ornateDowsingRod(boolean doing_desert_now);
boolean LX_ornateDowsingRod();
boolean fancyOilPainting();
int turkeyBooze();
int amountTurkeyBooze();
monster icehouseMonster();
boolean icehouseUserErrorProtection();

########################################################################################################
//Defined in autoscend/iotms/mr2015.ash
boolean auto_haveLovebugs();
boolean mayo_acquireMayo(item it);
boolean auto_barrelPrayers();
boolean auto_mayoItems();
boolean chateaumantegna_available();
void chateaumantegna_useDesk();
boolean chateaumantegna_havePainting();
boolean chateaumantegna_usePainting(string option);
boolean chateaumantegna_usePainting();
boolean[item] chateaumantegna_decorations();
void chateaumantegna_buyStuff(item toBuy);
boolean chateaumantegna_nightstandSet();
boolean chateauPainting();
boolean deck_available();
int deck_draws_left();
boolean deck_draw();
boolean deck_cheat(string cheat);
boolean deck_useScheme(string action);
boolean adjustEdHat(string goal);
boolean resolveSixthDMT();
boolean LX_dinseylandfillFunbucks();
void doghouseChoiceHandler(int choice);

########################################################################################################
//Defined in autoscend/iotms/mr2016.ash
boolean snojoFightAvailable();
boolean auto_haveSourceTerminal();
boolean isOverdueDigitize();
boolean auto_sourceTerminalRequest(string request);
boolean auto_sourceTerminalExtrude(string request);
int auto_sourceTerminalExtrudeLeft();
boolean auto_sourceTerminalEnhance(string request);
int auto_sourceTerminalEnhanceLeft();
int[string] auto_sourceTerminalMissing();
int[string] auto_sourceTerminalStatus();
boolean auto_sourceTerminalEducate(skill first, skill second);
boolean auto_sourceTerminalEducate(skill first);
boolean auto_haveWitchess();
boolean auto_advWitchess(string target);
boolean auto_advWitchess(string target, string option);
int auto_advWitchessTargets(string target);
boolean witchessFights();
item auto_bestBadge();
boolean auto_doPrecinct();
boolean expectGhostReport();
boolean haveGhostReport();
boolean LX_ghostBusting();
int timeSpinnerRemaining();
int timeSpinnerRemaining(boolean verify);
boolean timeSpinnerGet(string goal);
boolean timeSpinnerConsume(item goal);
boolean timeSpinnerAdventure();
boolean timeSpinnerAdventure(string option);
boolean canTimeSpinnerMonster(monster mon);
boolean timeSpinnerCombat(monster goal);
boolean timeSpinnerCombat(monster goal, boolean speculative);
boolean timeSpinnerCombat(monster goal, string option, boolean speculative);
void auto_chapeau();
boolean rethinkingCandyList();
boolean rethinkingCandy(effect acquire);
boolean rethinkingCandy(effect acquire, boolean simulate);

########################################################################################################
//Defined in autoscend/iotms/mr2017.ash
boolean auto_hasMummingTrunk();
boolean auto_checkFamiliarMummery(familiar fam);
boolean mummifyFamiliar(familiar fam, string bonus);
boolean mummifyFamiliar(familiar fam);
boolean mummifyFamiliar();
boolean pantogramPants();
boolean pantogramPants(stat st, element el, int hpmp, int meatItemStats, int misc);
boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem);
boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem, string option);
boolean kgbWasteClicks();
string kgbKnownEffects();
boolean kgbTryEffect(effect ef);
boolean kgbDiscovery();
int kgb_tabCount(string page);
int kgb_tabHeight(string page);
boolean kgbSetup();
boolean kgb_getMartini();
boolean kgb_getMartini(string page);
boolean kgb_getMartini(string page, boolean dontCare);
boolean kgbDial(int dial, int curVal, int target);
boolean solveKGBMastermind();
boolean getSpaceJelly();
boolean haveAsdonBuff();
boolean asdonBuff(string goal);
boolean canAsdonBuff(effect goal);
boolean asdonBuff(effect goal);
boolean asdonAutoFeed();
boolean asdonAutoFeed(int goal);
boolean asdonFeed(item it, int qty);
boolean asdonFeed(item it);
boolean asdonCanMissile();
boolean isHorseryAvailable();
int horseCost();
string horseNormalize(string horseText);
boolean getHorse(string type);
void horseDefault();
void horseMaintain();
void horseNone();
void horseNormal();
void horseDark();
void horseCrazy();
void horsePale();
boolean horsePreAdventure();
boolean auto_shouldUseWishes();
int auto_wishesAvailable();
boolean makeGenieWish(string wish);
boolean makeGenieWish(effect eff);
boolean canGenieCombat();
boolean makeGenieCombat(monster mon, string option);
boolean makeGenieCombat(monster mon);
boolean makeGeniePocket();
boolean spacegateVaccineAvailable();
boolean spacegateVaccineAvailable(effect ef);
boolean spacegateVaccine(effect ef);
boolean auto_hasMeteorLore();
int auto_meteorShowersUsed();
int auto_meteorShowersAvailable();
int auto_macroMeteoritesUsed();
int auto_macrometeoritesAvailable();
int auto_meteoriteAdesUsed();

########################################################################################################
//Defined in autoscend/iotms/mr2018.ash
boolean isjanuaryToteAvailable();
int januaryToteTurnsLeft(item it);
boolean januaryToteAcquire(item it);
int auto_godLobsterFightsRemaining();
boolean godLobsterCombat();
boolean godLobsterCombat(item it);
boolean godLobsterCombat(item it, int goal);
boolean godLobsterCombat(item it, int goal, string option);
boolean fantasyRealmAvailable();
int fantasyBanditsFought();
boolean acquiredFantasyRealmToken();
boolean fantasyRealmToken();
boolean songboomSetting(string goal);
boolean songboomSetting(int option);
void auto_setSongboom();
int catBurglarHeistsLeft();
boolean catBurglarHeist(item it);
item[monster] catBurglarHeistDesires();
boolean catBurglarHeist();
boolean cheeseWarMachine(int stats, int it, int eff, int potion);
boolean neverendingPartyCombat();
int neverendingPartyRemainingFreeFights();
boolean neverendingPartyAvailable();
string auto_latteDropName(location l);
boolean auto_latteDropAvailable(location l);
boolean auto_latteDropWanted(location l);
string auto_latteTranslate(string ingredient);
boolean auto_latteRefill(string want1, string want2, string want3, boolean force);
boolean auto_latteRefill(string want1, string want2, string want3);
boolean auto_latteRefill(string want1, string want2, boolean force);
boolean auto_latteRefill(string want1, string want2);
boolean auto_latteRefill(string want1, boolean force);
boolean auto_latteRefill(string want1);
boolean auto_latteRefill();
boolean auto_haveVotingBooth();
boolean auto_voteSetup();
boolean auto_voteSetup(int candidate);
boolean auto_voteSetup(int candidate, int first, int second);
boolean auto_voteMonster();
boolean auto_voteMonster(boolean freeMon);
boolean auto_voteMonster(boolean freeMon, location loc);
boolean auto_voteMonster(boolean freeMon, location loc, string option);
boolean fightClubNap();
boolean fightClubSpa();
boolean fightClubSpa(effect eff);
boolean fightClubSpa(int option);
boolean fightClubStats();
boolean isTallGrassAvailable();
int pokeFertilizerAmountAvailable();
boolean isPokeFertilizerAvailable();
boolean haveAnyPokeFamiliarEquipment();
boolean pokeFertilizeAndHarvest();

########################################################################################################
//Defined in autoscend/iotms/mr2019.ash
int auto_sausageEaten();
int auto_sausageLeftToday();
int auto_sausageUnitsNeededForSausage(int numSaus);
int auto_sausageMeatPasteNeededForSausage(int numSaus);
int auto_sausageFightsToday();
boolean auto_sausageBlocked();
boolean auto_sausageWanted();
boolean auto_sausageGrind(int numSaus);
boolean auto_sausageGrind(int numSaus, boolean failIfCantMakeAll);
boolean auto_sausageEatEmUp(int maxToEat);
boolean auto_sausageEatEmUp();
boolean auto_haveKramcoSausageOMatic();
boolean auto_sausageGoblin();
boolean auto_sausageGoblin(location loc);
boolean auto_sausageGoblin(location loc, string option);
boolean pirateRealmAvailable();
boolean LX_unlockPirateRealm();
boolean auto_saberChoice(string choice);
boolean auto_saberDailyUpgrade(int day);
monster auto_saberCurrentMonster();
int auto_saberChargesAvailable();
string auto_combatSaberBanish();
string auto_combatSaberCopy();
string auto_combatSaberYR();
skill auto_spoonCombatSkill();
string auto_spoonGetDesiredSign();
void auto_spoonTuneConfirm();
boolean auto_spoonReadyToTuneMoon();
boolean auto_spoonTuneMoon();
boolean auto_beachCombAvailable();
int auto_beachCombHeadNumFrom(string name);
effect auto_beachCombHeadEffectFromNum(int num);
effect auto_beachCombHeadEffect(string name);
boolean auto_canBeachCombHead(string name);
boolean auto_beachCombHead(string name);
int auto_beachCombFreeUsesLeft();
boolean auto_beachUseFreeCombs();
boolean auto_campawayAvailable();
boolean auto_campawayGrabBuffs();
boolean auto_havePillKeeper();
int auto_pillKeeperUses();
boolean auto_pillKeeperFreeUseAvailable();
boolean auto_pillKeeperAvailable();
boolean auto_pillKeeper(int pill);
boolean auto_pillKeeper(string pill);
void auto_deliberate_pizza();
boolean auto_changeSnapperPhylum(phylum toChange);
void auto_snapperPreAdventure(location loc);

########################################################################################################
//Defined in autoscend/iotms/mr2020.ash
boolean auto_haveBirdADayCalendar();
boolean auto_birdOfTheDay();
boolean auto_birdIsValid();
float auto_birdModifier(string mod);
float auto_favoriteBirdModifier(string mod);
int auto_birdsSought();
int auto_birdsLeftToday();
boolean auto_birdCanSeek();
boolean auto_favoriteBirdCanSeek();
boolean auto_hasPowerfulGlove();
int auto_powerfulGloveCharges();
boolean auto_powerfulGloveNoncombatSkill(skill sk);
int auto_powerfulGloveReplacesAvailable(boolean inCombat);
int auto_powerfulGloveReplacesAvailable();
boolean auto_powerfulGloveNoncombat();
boolean auto_powerfulGloveStats();
boolean auto_wantToEquipPowerfulGlove();
boolean auto_willEquipPowerfulGlove();
boolean auto_forceEquipPowerfulGlove();
void auto_burnPowerfulGloveCharges();
boolean auto_canFightPiranhaPlant();
boolean auto_canTendMushroomGarden();
int auto_piranhaPlantFightsRemaining();
boolean auto_mushroomGardenHandler();
void mushroomGardenChoiceHandler(int choice);
boolean auto_getGuzzlrCocktailSet();
boolean auto_canCamelSpit();
boolean auto_latheHardwood(item toLathe);
boolean auto_latheAppropriateWeapon();
boolean auto_hasCargoShorts();
int auto_cargoShortsGetPocket(item i);
int auto_cargoShortsGetPocket(monster m);
int auto_cargoShortsGetPocket(effect e);
boolean auto_cargoShortsCanOpenPocket();
boolean auto_cargoShortsCanOpenPocket(int pocket);
boolean auto_cargoShortsCanOpenPocket(item i);
boolean auto_cargoShortsCanOpenPocket(monster m);
boolean auto_cargoShortsCanOpenPocket(effect e);
boolean auto_cargoShortsCanOpenPocket(stat s);
boolean auto_cargoShortsCanOpenPocket(string s);
boolean auto_cargoShortsOpenPocket(int pocket);
boolean auto_cargoShortsOpenPocket(item i);
boolean auto_cargoShortsOpenPocket(monster m, boolean speculative);
boolean auto_cargoShortsOpenPocket(effect e);
boolean auto_cargoShortsOpenPocket(stat e);
boolean auto_cargoShortsOpenPocket(string s);
boolean auto_canMapTheMonsters();
boolean auto_mapTheMonsters();
void cartographyChoiceHandler(int choice);
boolean auto_hasRetrocape();
boolean auto_configureRetrocape(string hero, string tag);
boolean auto_handleRetrocape();
boolean auto_buyCrimboCommerceMallItem();

########################################################################################################
//Defined in autoscend/iotms/mr2021.ash
boolean auto_haveEmotionChipSkills();
boolean auto_canFeelEnvy();
boolean auto_canFeelHatred();
boolean auto_canFeelNostalgic();
boolean auto_canFeelPride();
boolean auto_canFeelSuperior();
boolean auto_canFeelLonely();
boolean auto_canFeelExcitement();
boolean auto_canFeelNervous();
boolean auto_canFeelPeaceful();
boolean auto_haveBackupCamera();
void auto_enableBackupCameraReverser();
int auto_backupUsesLeft();
boolean auto_backupTarget();
boolean auto_harvestBatteries();
int batteryPoints(item battery);
int totalBatteryPoints();
boolean batteryCombine(item battery);
boolean batteryCombine(item battery, boolean simulate);
boolean can_get_battery(item target);
boolean auto_getBattery(item target);
boolean have_fireworks_shop();
boolean auto_buyFireworksHat();
boolean auto_haveFireExtinguisher();
int auto_fireExtinguisherCharges();
string auto_FireExtinguisherCombatString(location place);
boolean auto_canExtinguisherBeRefilled();
boolean auto_haveColdMedCabinet();
int auto_CMCconsultsLeft();
boolean auto_shouldUseCMC();
boolean auto_CMCconsultAvailable();
void auto_CMCconsult();

########################################################################################################
//Defined in autoscend/iotms/mr2022.ash
boolean auto_haveCosmicBowlingBall();
string auto_bowlingBallCombatString(location place, boolean speculation);
boolean auto_haveCombatLoversLocket();
int auto_CombatLoversLocketCharges();
boolean auto_haveReminiscedMonster(monster mon);
boolean auto_monsterInLocket(monster mon);
boolean auto_fightLocketMonster(monster mon, boolean speculative);
boolean auto_haveGreyGoose();
int gooseExpectedDrones();
boolean dronesOut();
void prioritizeGoose();
boolean canUseCleaver();
void juneCleaverChoiceHandler(int choice);
boolean canUseSweatpants();
int getSweat();
void sweatpantsPreAdventure();
boolean auto_hasStillSuit();
int auto_expectedStillsuitAdvs();
void utilizeStillsuit();
boolean auto_hasParka();
boolean auto_configureParka(string tag);
boolean auto_handleParka();
boolean auto_hasAutumnaton();
boolean auto_autumnatonCanAdv(location canAdventureInloc);
boolean auto_autumnatonReadyToQuest();
location auto_autumnatonQuestingIn();
boolean auto_autumnatonCheckForUpgrade(string upgrade);
boolean auto_sendAutumnaton(location loc);

boolean auto_autumnatonQuest();
boolean auto_hasSpeakEasy();
int auto_remainingSpeakeasyFreeFights();


boolean auto_haveTrainSet();
void auto_modifyTrainSet(int one, int two, int three, int four, int five, int six, int seven, int eight);
void auto_checkTrainSet();


########################################################################################################
//Defined in autoscend/iotms/mr2023.ash
boolean auto_haveRockGarden();
void rockGardenEnd();
void pickRocks();
boolean wantToThrowGravel(location loc, monster enemy);
boolean auto_haveSITCourse();
void auto_SITCourse();

########################################################################################################
//Defined in autoscend/paths/actually_ed_the_undying.ash
boolean isActuallyEd();
int ed_spleen_limit();
void ed_initializeSettings();
void ed_initializeSession();
void ed_terminateSession();
void ed_initializeDay(int day);
boolean L13_ed_towerHandler();
boolean L13_ed_councilWarehouse();
boolean handleServant(servant who);
boolean handleServant(string name);
boolean ed_doResting();
boolean ed_buySkills();
boolean ed_eatStuff();
skill ed_nextUpgrade();
int ed_KaCost(skill upgrade);
boolean ed_needShop();
boolean ed_shopping();
void ed_handleAdventureServant(location loc);
boolean L1_ed_island();
boolean L1_ed_islandFallback();
boolean L9_ed_chasmStart();
boolean ed_DelayNC_DailyDungeon();
boolean ed_DelayNC(int potential_dmg);
boolean ed_DelayNC(float potential_dmg_percent);
boolean edUnderworldAdv();
boolean edAcquireHP();
boolean edAcquireHP(int goal);
boolean LM_edTheUndying();
void edUnderworldChoiceHandler(int choice);

########################################################################################################
//Defined in autoscend/paths/avatar_of_boris.ash
boolean is_boris();
void borisTrusty();
boolean borisAdjustML();
void boris_initializeSettings();
void boris_initializeDay(int day);
void boris_buySkills();
boolean borisDemandSandwich(boolean immediately);
void borisWastedMP();
boolean borisAcquireHP(int goal);
boolean LM_boris();

########################################################################################################
//Defined in autoscend/paths/avatar_of_jarlsberg.ash
boolean is_jarlsberg();
void jarlsberg_initializeSettings();
void jarlsberg_initializeDay(int day);
void jalrsberg_buySkills();
boolean LM_jarlsberg();

########################################################################################################
//Defined in autoscend/paths/avatar_of_sneaky_pete.ash
boolean is_pete();
void pete_initializeSettings();
void pete_initializeDay(int day);
void pete_buySkills();
int pete_peelOutRemaining();
boolean LM_pete();

########################################################################################################
//Defined in autoscend/paths/avatar_of_west_of_loathing.ash
boolean in_awol();
boolean awol_initializeSettings();
void awol_useStuff();
effect awol_walkBuff();
boolean awol_buySkills();

########################################################################################################
//Defined in autoscend/paths/avatar_of_shadows_over_loathing.ash
boolean in_aosol();
boolean aosol_initializeSettings();
void aosol_unCurse();
boolean aosol_buySkills();
boolean auto_pigSkinnerAcquireHP(int goal);
boolean auto_cheeseWizardAcquireHP(int goal);
boolean auto_jazzAgentAcquireHP(int goal);

########################################################################################################
//Defined in autoscend/paths/bees_hate_you.ash
boolean in_bhy();
void bhy_initializeSettings();
boolean bhy_usable(string str);
boolean bhy_is_item_valid(item it);
boolean LM_bhy();
boolean L13_bhy_towerFinal();

########################################################################################################
//Defined in autoscend/paths/bugbear_invasion.ash
boolean in_bugbear();
void bugbear_initializeSettings();
boolean LX_bugbearInvasion();
boolean LX_bugbearInvasionFinale();

########################################################################################################
//Defined in autoscend/paths/casual.ash
boolean inAftercore();
boolean inPostRonin();
void casualCheck();
boolean L8_slopeCasual();
void acquireFamiliarRagamuffinImp();
void acquireFamiliarsCasual();
boolean LX_acquireFamiliarLeprechaun();
boolean LM_canInteract();

########################################################################################################
//Defined in autoscend/paths/community_service.ash
boolean in_community();
boolean LA_cs_communityService();
boolean cs_witchess();
void cs_initializeDay(int day);
boolean do_chateauGoat();
boolean cs_spendRests();
void cs_make_stuff(int curQuest);
boolean cs_eat_spleen();
boolean cs_eat_stuff(int quest);
void cs_dnaPotions();
boolean cs_giant_growth();
boolean auto_csHandleGrapes();
int estimate_cs_questCost(int quest);
int [int] get_cs_questList();
int expected_next_cs_quest();
string what_cs_quest(int quest);
int expected_next_cs_quest_internal();
boolean do_cs_quest(int quest);
boolean do_cs_quest(string quest);
int get_cs_questCost(int quest);
int get_cs_questCost(string input);
int get_cs_questNum(string input);
void set_cs_questListFast(int[int] fast);
boolean cs_preTurnStuff(int curQuest);
boolean cs_healthMaintain();
boolean cs_mpMaintain();
boolean cs_mpMaintain(int target);
boolean canTrySaberTrickMeteorShower();
boolean trySaberTrickMeteorShower();
int beachHeadTurnSavings(int quest);
boolean tryBeachHeadBuff(int quest);

########################################################################################################
//Defined in autoscend/paths/dark_gyffte.ash
boolean in_darkGyffte();
void bat_startAscension();
void bat_initializeSettings();
boolean bat_wantHowl(location loc);
boolean bat_formNone();
boolean bat_formWolf(boolean speculative);
boolean bat_formWolf();
boolean bat_formMist(boolean speculative);
boolean bat_formMist();
boolean bat_formBats(boolean speculative);
boolean bat_formBats();
void bat_clearForms();
boolean bat_switchForm(effect form, boolean speculative);
boolean bat_switchForm(effect form);
boolean bat_formPreAdventure();
void bat_initializeSession();
void bat_terminateSession();
void bat_initializeDay(int day);
int bat_maxHPCost(skill sk);
int bat_baseHP();
int bat_remainingBaseHP();
boolean[skill] bat_desiredSkills(int hpLeft);
boolean[skill] bat_desiredSkills(int hpLeft, boolean[skill] forcedPicks);
void bat_reallyPickSkills(int hpLeft);
void bat_reallyPickSkills(int hpLeft, boolean[skill] requiredSkills);
boolean bat_shouldPickSkills(int hpLeft);
boolean bat_haveEnsorcelee();
phylum bat_ensorceledMonster();
boolean bat_shouldEnsorcel(monster m);
int bat_creatable_amount(item desired);
boolean bat_multicraft(string mode, boolean [item] options);
boolean bat_cook(item desired);
boolean bat_consumption();
boolean bat_skillValid(skill sk);
boolean bat_tryBloodBank();
boolean LM_batpath();

########################################################################################################
//Defined in autoscend/paths/disguises_delimit.ash
boolean in_fotd();
void fotd_initializeSettings();
boolean fotd_gameWarden();

########################################################################################################
//Defined in autoscend/paths/fall_of_the_dinosaurs.ash
boolean in_disguises();
void disguises_initializeSettings();

########################################################################################################
//Defined in autoscend/paths/g_lover.ash
boolean in_glover();
void glover_initializeDay(int day);
void glover_initializeSettings();
boolean glover_usable(string it);
boolean glover_usable(effect eff);
boolean LM_glover();

########################################################################################################
//Defined in autoscend/paths/gelatinous_noob.ash
boolean in_gnoob();
void gnoob_startAscension(string page);
int gnoobAbsorbCost(item it);
void gnoob_buySkills();
string[item] gnoob_lister(string goal);
int gnoob_absorbsLeft();
string[item] gnoob_lister();
boolean LM_gnoob();

########################################################################################################
//Defined in autoscend/paths/grey_goo.ash
boolean in_ggoo();
void grey_goo_initializeSettings();
void grey_goo_initializeDay(int day);
boolean LA_grey_goo_tasks();

########################################################################################################
//Defined in autoscend/paths/heavy_rains.ash
boolean in_heavyrains();
void heavyrains_initializeSettings();
boolean routineRainManHandler();
void heavyrains_initializeDay(int day);
void heavyrains_doBedtime();
boolean heavyrains_buySkills();
boolean rainManSummon(monster target, boolean copy, boolean wink);
boolean L13_heavyrains_towerFinal();

########################################################################################################
//Defined in autoscend/paths/kingdom_of_exploathing.ash
boolean in_koe();
boolean koe_initializeSettings();
int koe_rmi_count();
boolean koe_acquire_rmi();
boolean LX_koeInvaderHandler();
item koe_L12FoodSelect();
void koe_RationingOutDestruction();
boolean L12_koe_clearBattlefield();
boolean L12_koe_finalizeWar();
boolean L13_koe_towerNSNagamar();

########################################################################################################
//Defined in autoscend/paths/kolhs.ash
boolean in_kolhs();
boolean kolhs_mandatorySchool();
void kolhs_initializeSettings();
void kolhs_closetDrink();
void kolhs_consume();
void kolhs_preadv(location place);
boolean LX_kolhs_visitYearbookClub();
boolean LX_kolhs_yearbookCameraGet();
boolean LX_kolhs_yearbookCameraQuest();
boolean LX_kolhs_school();
void kolhsChoiceHandler(int choice);
boolean LM_kolhs();

########################################################################################################
//Defined in autoscend/paths/license_to_adventure.ash
boolean in_lta();
void bond_initializeSettings();
boolean bond_initializeDay(int day);
boolean bond_buySkills();
boolean LM_bond();
item[int] bondDrinks();

########################################################################################################
//Defined in autoscend/paths/live_ascend_repeat.ash
boolean in_lar();
boolean lar_safeguard();
boolean lar_repeat(location loc);
boolean lar_abort(location loc);
boolean LM_lar();

########################################################################################################
//Defined in autoscend/paths/low_key_summer.ash
boolean in_lowkeysummer();
void lowkey_initializeSettings();
boolean lowkey_needKey(item key);
int lowkey_keyDelayRemaining(location loc);
int lowkey_keysRemaining();
location lowkey_nextKeyLocation(boolean checkAvailable);
location lowkey_nextKeyLocation();
location lowkey_nextAvailableKeyLocation();
location lowkey_nextAvailableKeyDelayLocation();
boolean lowkey_keyAdv(item key);
boolean lowkey_zoneUnlocks();
boolean LX_findHelpfulLowKey();
boolean L13_sorceressDoorLowKey();
boolean LX_lowkeySummer();

########################################################################################################
//Defined in autoscend/paths/nuclear_autumn.ash
boolean in_nuclear();
void nuclear_initializeSettings();
void nuclear_initializeDay(int day);
boolean nuclear_buySkills();
boolean LM_nuclear();

########################################################################################################
//Defined in autoscend/paths/one_crazy_random_summer.ash
boolean in_ocrs();
boolean ocrs_postHelper();
boolean ocrs_postCombatResolve();

########################################################################################################
//Defined in autoscend/paths/path_of_the_plumber.ash
boolean in_plumber();
boolean plumber_initializeSettings();
boolean plumber_haveHammer();
boolean plumber_equippedHammer();
boolean plumber_haveFlower();
boolean plumber_equippedFlower();
boolean plumber_equippedBoots();
int plumber_numBadgesBought();
boolean plumber_buySkill(skill sk);
boolean plumber_buyEquipment(item it);
stat plumber_costume();
boolean plumber_buyCostume(stat st);
boolean plumber_nothingToBuy();
boolean plumber_buyStuff();
int plumber_ppCost(skill sk);
boolean plumber_canDealScalingDamage();
boolean plumber_skillValid(skill sk);
boolean plumber_equipTool(stat st, boolean forceEquipRightNow);
boolean plumber_equipTool(stat st);
boolean plumber_forceEquipTool();
void plumber_eat_xp();
boolean LM_plumber();

########################################################################################################
//Defined in autoscend/paths/picky.ash
boolean in_picky();
void picky_pulls();
void picky_startAscension();

########################################################################################################
//Defined in autoscend/paths/pocket_familiars.ash
boolean in_pokefam();
void pokefam_initializeSettings();
string pokefam_defaultMaximizeStatement();
boolean pokefam_makeTeam();
boolean L12_pokefam_clearBattlefield();

########################################################################################################
//Defined in autoscend/paths/quantum_terrarium.ash
boolean in_quantumTerrarium();
boolean qt_currentFamiliar(familiar fam);
familiar qt_nextQuantumFamiliar();
int qt_turnsToNextQuantumAlignment();
boolean LX_quantumTerrarium();
void qt_initializeSettings();
boolean qt_FamiliarAvailable (familiar fam);
boolean qt_FamiliarSwap (familiar fam);

########################################################################################################
//Defined in autoscend/paths/the_source.ash
boolean in_theSource();
boolean theSource_initializeSettings();
boolean theSource_buySkills();
boolean L8_theSourceNinjaOracle();
boolean LX_theSource();
boolean theSource_oracle();
boolean LX_attemptPowerLevelTheSource();

########################################################################################################
//Defined in autoscend/paths/two_crazy_random_summer.ash
boolean in_tcrs();
float tcrs_expectedAdvPerFill(string quality);
boolean tcrs_maximize_with_items(string maximizerString);

########################################################################################################
//Defined in autoscend/paths/way_of_the_surprising_fist.ash
boolean in_wotsf();

########################################################################################################
//Defined in autoscend/paths/wildfire.ash
boolean in_wildfire();
void wildfire_initializeSettings();
boolean wildfire_groar_check();
boolean wildfire_warboss_check();
boolean LX_wildfire_calculateTheUniverse();
void wildfire_rainbarrel();
void wildfire_refillExtinguiser();
int wildfire_water_cost(string target);
boolean LX_wildfire_grease_pump();
boolean LX_wildfire_pump(int target);
boolean LX_wildfire_dust();
boolean LX_wildfire_frack();
boolean LX_wildfire_sprinkle();
boolean LX_wildfire_hose_once(location place);
boolean LX_wildfire_hose(location place, int target_fire);
boolean LX_wildfire_hose(location place);
boolean LX_wildfire_water();
boolean LX_wildfire_spookyravenManorFirstFloor();
boolean LA_wildfire();

########################################################################################################
//Defined in autoscend/paths/you_robot.ash
boolean in_robot();
void robot_initializeSettings();
string robot_defaultMaximizeStatement();
boolean robot_top(int choice);
boolean robot_left(int choice);
boolean robot_right(int choice);
boolean robot_bottom(int choice);
boolean robot_cpu(int choice, boolean no_buy);
boolean robot_cpu(int choice);
void robot_skillbuy();
int robot_energy_per_collect();
boolean LX_robot_get_energy();
boolean LX_robot_get_scrap_once();
boolean LX_robot_get_scrap(int target);
int robot_chronolith_cost();
void robot_get_adv();
int robot_statbot_cost();
boolean robot_statbot(stat target);
stat robot_stat_wanted();
boolean LX_robot_level();
boolean LX_robot_powerlevel();
boolean robot_assemble();
boolean robot_assemble_want_sniper();
boolean robot_assemble_want_rocket_crotch();
boolean robot_assemble_want_bird_cage();
void robot_directive();
boolean robot_directive_check(string check);
boolean robot_delay(string check);
boolean LM_robot();
boolean LA_robot();

########################################################################################################
//Defined in autoscend/paths/zombie_slayer.ash
boolean in_zombieSlayer();
void zombieSlayer_initializeSettings();
boolean zombieSlayer_buySkills();
boolean zombieSlayer_acquireMP(int goal, int meat_reserve);
boolean zombieSlayer_acquireHP(int goal);
boolean zombieSlayer_usable(familiar fam);
boolean zombieSlayer_canInfect(monster enemy);
boolean LM_zombieSlayer();

########################################################################################################
//Defined in autoscend/quests/level_01.ash
void tootOriole();
void tootGetMeat();

########################################################################################################
//Defined in autoscend/quests/level_02.ash
void spookyForestChoiceHandler(int choice);
boolean L2_mosquito();

########################################################################################################
//Defined in autoscend/quests/level_03.ash
boolean auto_tavern();
boolean L3_tavern();

########################################################################################################
//Defined in autoscend/quests/level_04.ash
boolean L4_batCave();

########################################################################################################
//Defined in autoscend/quests/level_05.ash
boolean L5_getEncryptionKey();
boolean L5_findKnob();
boolean L5_haremOutfit();
boolean L5_goblinKing();
boolean L5_slayTheGoblinKing();

########################################################################################################
//Defined in autoscend/quests/level_06.ash
boolean L6_friarsGetParts_condition_hardcore();
boolean L6_friarsGetParts();
boolean L6_dakotaFanning();

########################################################################################################
//Defined in autoscend/quests/level_07.ash
void cyrptChoiceHandler(int choice);
int cyrptEvilBonus(boolean inCombat);
int cyrptEvilBonus();
boolean L7_crypt();
boolean L7_override();

########################################################################################################
//Defined in autoscend/quests/level_08.ash
boolean needOre();
int getCellToMine(item oreGoal);
boolean L8_getGoatCheese();
boolean L8_getMineOres();
void itznotyerzitzMineChoiceHandler(int choice);
boolean L8_trapperExtreme();
void theeXtremeSlopeChoiceHandler(int choice);
boolean L8_trapperSlopeSoftcore();
boolean L8_trapperNinjaLair();
boolean L8_trapperGroar();
boolean L8_trapperPeak();
boolean L8_trapperSlope();
boolean L8_trapperTalk();
boolean L8_trapperQuest();

########################################################################################################
//Defined in autoscend/quests/level_09.ash
boolean LX_loggingHatchet();
boolean L9_leafletQuest();
void L9_chasmMaximizeForNoncombat();
int fastenerCount();
int lumberCount();
void prepareForSmutOrcs();
boolean L9_chasmBuild();
boolean L9_aBooPeak();
int hedgeTrimmersNeeded();
boolean L9_twinPeak();
boolean L9_oilPeak();
boolean L9_highLandlord();

########################################################################################################
//Defined in autoscend/quests/level_10.ash
boolean L10_plantThatBean();
boolean L10_airship();
boolean L10_basement();
void castleBasementChoiceHandler(int choice);
boolean L10_ground();
boolean L10_topFloor();
void castleTopFloorChoiceHandler(int choice);
boolean L10_holeInTheSkyUnlock();
boolean L10_rainOnThePlains();

########################################################################################################
//Defined in autoscend/quests/level_11.ash
int shenItemsReturnedOrInProgress();
boolean[location] shenSnakeLocations(int day, int n_items_returned);
boolean[location] shenZonesToAvoidBecauseMaybeSnake();
boolean shenShouldDelayZone(location loc);
int[location] getShenZonesTurnsSpent();
boolean LX_unlockHiddenTemple();
boolean hasSpookyravenLibraryKey();
boolean hasILoveMeVolI();
boolean useILoveMeVolI();
boolean LX_unlockHauntedBilliardsRoom(boolean delayKitchen);
boolean LX_unlockHauntedBilliardsRoom();
boolean LX_unlockHauntedLibrary();
boolean LX_unlockManorSecondFloor();
boolean LX_spookyravenManorFirstFloor();
boolean LX_danceWithLadySpookyraven();
void hauntedBedroomChoiceHandler(int choice, string[int] options);
boolean LX_getLadySpookyravensFinestGown();
boolean LX_getLadySpookyravensDancingShoes();
boolean LX_getLadySpookyravensPowderPuff();
boolean LX_spookyravenManorSecondFloor();
void blackForestChoiceHandler(int choice);
boolean L11_blackMarket();
boolean L11_getBeehive();
boolean L11_forgedDocuments();
boolean L11_mcmuffinDiary();
void auto_visit_gnasir();
boolean L11_getUVCompass();
boolean L11_aridDesert();
boolean L11_unlockHiddenCity();
void hiddenTempleChoiceHandler(int choice, string page);
boolean liana_cleared(location loc);
boolean L11_hiddenTavernUnlock();
boolean L11_hiddenTavernUnlock(boolean force);
void hiddenCityChoiceHandler(int choice);
boolean L11_hiddenCity();
boolean L11_hiddenCityZones();
boolean L11_mauriceSpookyraven();
boolean L11_redZeppelin();
boolean L11_ronCopperhead();
boolean L11_shenStartQuest();
boolean L11_shenCopperhead();
boolean L11_talismanOfNam();
boolean L11_palindome();
boolean L11_unlockPyramid();
boolean L11_unlockEd();
boolean L11_defeatEd();

########################################################################################################
//Defined in autoscend/quests/level_12.ash
void copy_warplan(WarPlan target, WarPlan source);
string auto_warSide();
int auto_warSideQuestsDone();
WarPlan auto_warSideQuestsState();
int auto_warEnemiesRemaining();
int auto_warKillsPerBattle();
int auto_warKillsPerBattle(int sidequests);
int auto_estimatedAdventuresForChaosButterfly();
int auto_estimatedAdventuresForDooks();
WarPlan warplan_from_bitmask(int mask);
int bitmask_from_warplan(WarPlan plan);
WarPlan auto_bestWarPlan();
int auto_warTotalBattles(WarPlan plan, int remaining);
int auto_warTotalBattles(WarPlan plan);
void equipWarOutfit();
void equipWarOutfit(boolean lock);
boolean haveWarOutfit(boolean canWear);
boolean haveWarOutfit();
boolean warAdventure();
boolean L12_getOutfit();
boolean L12_preOutfit();
boolean L12_startWar();
boolean L12_filthworms();
boolean L12_orchardFinalize();
void gremlinsFamiliar();
boolean L12_gremlins();
boolean L12_sonofaBeach();
boolean L12_sonofaPrefix();
boolean L12_sonofaFinish();
boolean L12_flyerBackup();
boolean L12_lastDitchFlyer();
boolean L12_flyerFinish();
boolean L12_themtharHills();
boolean LX_obtainChaosButterfly();
boolean L12_farm();
boolean L12_clearBattlefield();
boolean L12_finalizeWar();
boolean L12_islandWar();

########################################################################################################
//Defined in autoscend/quests/level_13.ash
boolean needStarKey();
boolean needDigitalKey();
int towerKeyCount();
int towerKeyCount(boolean effective);
int EightBitScore();
boolean EightBitRealmHandler();
boolean get8BitFatLootToken();
boolean LX_getDigitalKey();
void LX_buyStarKeyParts();
boolean LX_getStarKey();
boolean beehiveConsider();
int ns_crowd1();
stat ns_crowd2();
element ns_crowd3();
element ns_hedge1();
element ns_hedge2();
element ns_hedge3();
boolean L13_towerNSContests();
void maximize_hedge();
boolean L13_towerNSHedge();
boolean L13_sorceressDoor();
boolean L13_towerNSTower();
boolean L13_towerNSFinal();
boolean L13_towerNSNagamar();
boolean L13_towerAscent();

########################################################################################################
//Defined in autoscend/quests/level_any.ash
boolean LX_bitchinMeatcar_condition();
boolean LX_bitchinMeatcar();
boolean LX_unlockDesert();
boolean LX_desertAlternate();
boolean LX_islandAccess();
boolean startHippyBoatmanSubQuest();
boolean LX_hippyBoatman();
void oldLandfillChoiceHandler(int choice);
boolean LX_lockPicking();
float estimateDailyDungeonAdvNeeded();
boolean LX_fatLootToken();
void useTonicDjinn();
boolean LX_dailyDungeonToken();
void dailyDungeonChoiceHandler(int choice, string[int] options);
boolean LX_dolphinKingMap();
boolean LX_meatMaid();
item LX_getDesiredWorkshed();
boolean LX_setWorkshed();
boolean LX_dronesOut();

########################################################################################################
//Defined in autoscend/quests/optional.ash
boolean LX_artistQuest();
boolean LX_unlockThinknerdWarehouse(boolean spend_resources);
boolean LX_melvignShirt();
boolean LX_steelOrgan_condition_slow();
boolean LX_steelOrgan();
boolean LX_guildUnlock();
boolean startArmorySubQuest();
boolean finishArmorySideQuest();
boolean LX_armorySideQuest();
void considerGalaktikSubQuest();
boolean startGalaktikSubQuest();
boolean finishGalaktikSubQuest();
boolean LX_galaktikSubQuest();
boolean startMeatsmithSubQuest();
boolean finishMeatsmithSubQuest();
boolean LX_meatsmithSubQuest();
boolean LX_doingPirates();
boolean LX_pirateOutfit();
void piratesCoveChoiceHandler(int choice);
string beerPong(string page);
string tryBeerPong();
int numPirateInsults();
boolean LX_joinPirateCrew();
void barrrneysBarrrChoiceHandler(int choice);
boolean LX_fledglingPirateIsYou();
void fcleChoiceHandler(int choice);
boolean LX_unlockBelowdecks();
boolean LX_pirateQuest();
boolean LX_unlockKnobMenagerie();
boolean tomb_already_found();
boolean LX_acquireEpicWeapon();
boolean LX_NemesisQuest();
void houseUpgrade();

########################################################################################################
//Defined in autoscend/auto_acquire.ash
boolean haveAny(boolean[item] array);
boolean acquireOrPull(item it);
boolean canPull(item it, boolean update);
boolean canPull(item it);
boolean pulledToday(item it);
int auto_mall_price(item it);
boolean pullXWhenHaveYCasual(item it, int howMany, int whenHave);
boolean pullXWhenHaveY(item it, int howMany, int whenHave);
boolean pulverizeThing(item it);
boolean buyableMaintain(item toMaintain, int howMany);
boolean buyableMaintain(item toMaintain, int howMany, int meatMin);
boolean buyableMaintain(item toMaintain, int howMany, int meatMin, boolean condition);
boolean buy_item(item it, int quantity, int maxprice);
boolean buyUpTo(int num, item it);
boolean buyUpTo(int num, item it, int maxprice);
float npcStoreDiscountMulti();
boolean acquireGumItem(item it);
boolean acquireTotem();
boolean auto_hermit(int amt, item it);
boolean acquireHermitItem(item it);
boolean pull_meat(int target);
int handlePulls(int day);
boolean LX_craftAcquireItems();

########################################################################################################
//Defined in autoscend/auto_adventure.ash
boolean autoAdv(int num, location loc, string option);		//num is ignored
boolean autoAdv(int num, location loc);						//num is ignored
boolean autoAdv(location loc);
boolean autoAdv(location loc, string option);
boolean autoAdvBypass(int urlGetFlags, string[int] url, location loc, string option);
boolean autoAdvBypass(string url, location loc);
boolean autoAdvBypass(string url, location loc, string option);
boolean autoAdvBypass(int snarfblat, location loc);
boolean autoAdvBypass(int snarfblat, location loc, string option);
boolean autoAdvBypass(int snarfblat);
boolean autoAdvBypass(string url);
boolean autoAdvBypass(int snarfblat, string option);
boolean autoAdvBypass(string url, string option);

########################################################################################################
//Defined in autoscend/auto_bedtime.ash
void bedtime_still();
int pullsNeeded(string data);
float rollover_value(item it);
float rollover_improvement(item it, slot sl);
void bedtime_pulls_rollover_equip();
void bedtime_pulls();
boolean doBedtime();

########################################################################################################
//Defined in autoscend/auto_buff.ash
boolean buffMaintain(skill source, effect buff, item mustEquip, int mp_min, int casts, int turns, boolean speculative);
boolean buffMaintain(item source, effect buff, int uses, int turns, boolean speculative);
boolean buffMaintain(effect buff, int mp_min, int casts, int turns, boolean speculative);
boolean buffMaintain(effect buff, int mp_min, int casts, int turns);
boolean buffMaintain(effect buff);
boolean auto_faceCheck(effect face);

########################################################################################################
//Defined in autoscend/auto_consume.ash
int spleen_left();
int stomach_left();
int fullness_left();
int inebriety_left();
boolean saucemavenApplies(item it);
float expectedAdventuresFrom(item it);
boolean canOde(item toDrink);
boolean autoDrink(int howMany, item toDrink);
boolean autoDrink(int howMany, item toDrink, boolean silent);
boolean autoOverdrink(int howMany, item toOverdrink);
string cafeFoodName(int id);
string cafeDrinkName(int id);
boolean autoDrinkCafe(int howmany, int id);
boolean autoEatCafe(int howmany, int id);
boolean autoChew(int howMany, item toChew);
boolean autoEat(int howMany, item toEat);
boolean autoEat(int howMany, item toEat, boolean silent);
boolean acquireMilkOfMagnesiumIfUnused(boolean useAdv);
boolean consumeMilkOfMagnesiumIfUnused();
boolean canDrink(item toDrink);
boolean canEat(item toEat);
boolean canChew(item toChew);
float consumptionProgress();
void consumeStuff();
boolean consumeFortune();
void auto_printNightcap();
void auto_drinkNightcap();
boolean auto_autoConsumeOne(string type);
item auto_autoConsumeOneSimulation(string type);
boolean auto_knapsackAutoConsume(string type, boolean simulate);
int auto_spleenFamiliarAdvItemsPossessed();
boolean auto_chewAdventures();
boolean auto_breakfastCounterVisit();
item still_targetToOrigin(item target);
boolean stillReachable();
boolean distill(item target);
boolean prepare_food_xp_multi();

########################################################################################################
//Defined in autoscend/auto_settings.ash
boolean trackingSplitterFixer(string oldSetting, int day, string newSetting);
void cleanup_property(string target);
void auto_rename_property(string oldprop, string newprop);
void boolFix(string p);
void auto_settingsUpgrade();
void auto_settingsFix();
void auto_settingsDelete();
void defaultConfig(string prop, string val);
void auto_settingsDefaults();
void auto_settings();

########################################################################################################
//Defined in autoscend/auto_craft.ash
boolean is_foldable(item target);
int foldable_amount(item target);
boolean auto_fold(item target);
boolean untinkerable(item target);
boolean canUntinker();
boolean canUntinker(item target);
boolean untinker(item target);
boolean untinker(int amount, item target);

########################################################################################################
//Defined in autoscend/auto_equipment.ash
string getMaximizeSlotPref(slot s);
boolean autoEquip(slot s, item it);
boolean autoEquip(item it);
boolean autoForceEquip(slot s, item it);
boolean autoForceEquip(item it);
boolean autoOutfit(string toWear);
boolean autoStripOutfit(string toRemove);
boolean tryAddItemToMaximize(slot s, item it);
item[slot] speculatedMaximizerEquipment(string statement);
void equipStatgainIncreasers(boolean[stat] increaseThisStat, boolean alwaysEquip);
void equipStatgainIncreasers(stat increaseThisStat, boolean alwaysEquip);
void equipStatgainIncreasers();
void equipStatgainIncreasersFor(item it);
void resetMaximize();
void addToMaximize(string add);
void removeFromMaximize(string rem);
boolean maximizeContains(string check);
boolean simMaximize();
boolean simMaximize(location loc);
boolean simMaximizeWith(location loc, string add);
boolean simMaximizeWith(string add);
float simValue(string modifier);
void equipMaximizedGear();
void equipOverrides();
int equipmentAmount(item equipment);
boolean possessEquipment(item equipment);
boolean possessUnrestricted(item it);
boolean possessOutfit(string outfit, boolean checkCanEquip);
boolean possessOutfit(string outfit);
void equipBaseline();
void ensureSealClubs();
void equipRollover(boolean silent);
boolean auto_forceEquipSword(boolean speculative);
boolean auto_forceEquipSword();
boolean is_watch(item it);

########################################################################################################
//Defined in autoscend/auto_familiar.ash
boolean is100FamRun();
boolean doNotBuffFamiliar100Run();
boolean isAttackFamiliar(familiar fam);
boolean pathHasFamiliar();
boolean pathAllowsChangingFamiliar();
boolean auto_have_familiar(familiar fam);
boolean canChangeFamiliar();
boolean canChangeToFamiliar(familiar target);
familiar lookupFamiliarDatafile(string type);
boolean handleFamiliar(string type);
boolean handleFamiliar(familiar fam);
boolean autoChooseFamiliar(location place);
boolean haveSpleenFamiliar();
boolean wantCubeling();
void preAdvUpdateFamiliar(location place);
boolean checkTerrarium();
void getTerrarium();
boolean hatchFamiliar(familiar adult);
void hatchList();
void acquireFamiliars();

########################################################################################################
//Defined in autoscend/auto_list.ash
familiar[int] List();
effect[int] List(boolean[effect] data);
familiar[int] List(boolean[familiar] data);
int[int] List(boolean[int] data);
item[int] List(boolean[item] data);
effect[int] List(effect[int] data);
familiar[int] List(familiar[int] data);
int[int] List(int[int] data);
item[int] List(item[int] data);
effect[int] ListErase(effect[int] list, int index);
familiar[int] ListErase(familiar[int] list, int index);
int[int] ListErase(int[int] list, int index);
item[int] ListErase(item[int] list, int index);
int ListFind(effect[int] list, effect what);
int ListFind(effect[int] list, effect what, int idx);
int ListFind(familiar[int] list, familiar what);
int ListFind(familiar[int] list, familiar what, int idx);
int ListFind(int[int] list, int what);
int ListFind(int[int] list, int what, int idx);
int ListFind(item[int] list, item what);
int ListFind(item[int] list, item what, int idx);
effect[int] ListInsert(effect[int] list, effect what);
familiar[int] ListInsert(familiar[int] list, familiar what);
int[int] ListInsert(int[int] list, int what);
item[int] ListInsert(item[int] list, item what);
effect[int] ListInsertAt(effect[int] list, effect what, int idx);
familiar[int] ListInsertAt(familiar[int] list, familiar what, int idx);
int[int] ListInsertAt(int[int] list, int what, int idx);
item[int] ListInsertAt(item[int] list, item what, int idx);
effect[int] ListInsertFront(effect[int] list, effect what);
familiar[int] ListInsertFront(familiar[int] list, familiar what);
int[int] ListInsertFront(int[int] list, int what);
item[int] ListInsertFront(item[int] list, item what);
effect[int] ListInsertInorder(effect[int] list, effect what);
familiar[int] ListInsertInorder(familiar[int] list, familiar what);
int[int] ListInsertInorder(int[int] list, int what);
item[int] ListInsertInorder(item[int] list, item what);
string ListOutput(effect[int] list);
string ListOutput(familiar[int] list);
string ListOutput(int[int] list);
string ListOutput(item[int] list);
effect[int] ListRemove(effect[int] list, effect what);
effect[int] ListRemove(effect[int] list, effect what, int idx);
familiar[int] ListRemove(familiar[int] list, familiar what);
familiar[int] ListRemove(familiar[int] list, familiar what, int idx);
int[int] ListRemove(int[int] list, int what);
int[int] ListRemove(int[int] list, int what, int idx);
item[int] ListRemove(item[int] list, item what);
item[int] ListRemove(item[int] list, item what, int idx);
location ListOutput(location[int] list);
location[int] locationList();
location[int] List(boolean[location] data);
location[int] List(location[int] data);
location[int] ListRemove(location[int] list, location what);
location[int] ListRemove(location[int] list, location what, int idx);
location[int] ListErase(location[int] list, int index);
location[int] ListInsertFront(location[int] list, location what);
location[int] ListInsert(location[int] list, location what);
location[int] ListInsertAt(location[int] list, location what, int idx);
location[int] ListInsertInorder(location[int] list, location what);
int ListFind(location[int] list, location what);
int ListFind(location[int] list, location what, int idx);
location ListOutput(location[int] list);
effect[int] effectList();
int[int] intList();
item[int] itemList();

########################################################################################################
//Defined in autoscend/auto_monsterparts.ash
boolean hasArm(monster enemy);
boolean hasHead(monster enemy);
boolean hasLeg(monster enemy);
boolean hasTail(monster enemy);
boolean hasTorso(monster enemy);

########################################################################################################
//Defined in autoscend/auto_path_util.ash
boolean auto_buySkills();
void pathDroppedCheck();

########################################################################################################
//Defined in autoscend/auto_powerlevel.ash
boolean isAboutToPowerlevel();
location highestScalingZone();
boolean LX_attemptPowerLevel();
boolean disregardInstantKarma();
int auto_freeCombatsRemaining();
int auto_freeCombatsRemaining(boolean print_remaining_fights);
boolean LX_freeCombats();
boolean LX_freeCombats(boolean powerlevel);
boolean LX_freeCombatsTask();

########################################################################################################
//Defined in autoscend/auto_providers.ash
float providePlusCombat(int amt, location loc, boolean doEquips, boolean speculative);
float providePlusCombat(int amt, boolean doEquips, boolean speculative);
boolean providePlusCombat(int amt, location loc, boolean doEquips);
boolean providePlusCombat(int amt, boolean doEquips);
boolean providePlusCombat(int amt, location loc);
boolean providePlusCombat(int amt);
float providePlusNonCombat(int amt, location loc, boolean doEquips, boolean speculative);
float providePlusNonCombat(int amt, boolean doEquips, boolean speculative);
boolean providePlusNonCombat(int amt, location loc, boolean doEquips);
boolean providePlusNonCombat(int amt, boolean doEquips);
boolean providePlusNonCombat(int amt, location loc);
boolean providePlusNonCombat(int amt);
float provideInitiative(int amt, location loc, boolean doEquips, boolean speculative);
float provideInitiative(int amt, boolean doEquips, boolean speculative);
boolean provideInitiative(int amt, location loc, boolean doEquips);
boolean provideInitiative(int amt, boolean doEquips);
int [element] provideResistances(int [element] amt, location loc, boolean doEquips, boolean speculative);
int [element] provideResistances(int [element] amt, boolean doEquips, boolean speculative);
boolean provideResistances(int [element] amt, location loc, boolean doEquips);
boolean provideResistances(int [element] amt, boolean doEquips);
float [stat] provideStats(int [stat] amt, location loc, boolean doEquips, boolean speculative);
float [stat] provideStats(int [stat] amt, boolean doEquips, boolean speculative);
boolean provideStats(int [stat] amt, location loc, boolean doEquips);
boolean provideStats(int [stat] amt, boolean doEquips);
float provideMuscle(int amt, location loc, boolean doEquips, boolean speculative);
float provideMuscle(int amt, boolean doEquips, boolean speculative);
boolean provideMuscle(int amt, location loc, boolean doEquips);
boolean provideMuscle(int amt, boolean doEquips);
float provideMysticality(int amt, location loc, boolean doEquips, boolean speculative);
float provideMysticality(int amt, boolean doEquips, boolean speculative);
boolean provideMysticality(int amt, location loc, boolean doEquips);
boolean provideMysticality(int amt, boolean doEquips);
float provideMoxie(int amt, location loc, boolean doEquips, boolean speculative);
float provideMoxie(int amt, boolean doEquips, boolean speculative);
boolean provideMoxie(int amt, location loc, boolean doEquips);
boolean provideMoxie(int amt, boolean doEquips);

########################################################################################################
//Defined in autoscend/auto_restore.ash
//Restoration (hp/mp) functions
void invalidateRestoreOptionCache();
boolean acquireMP();
boolean acquireMP(int goal);
boolean acquireMP(int goal, int meat_reserve);
boolean acquireMP(int goal, int meat_reserve, boolean freeRest);
boolean acquireMP(float goalPercent);
boolean acquireMP(float goalPercent, int meat_reserve);
boolean acquireMP(float goalPercent, int meat_reserve, boolean freeRest);
boolean acquireHP();
boolean acquireHP(int goal);
boolean acquireHP(int goal, int meat_reserve);
boolean acquireHP(int goal, int meat_reserve, boolean freeRest);
boolean acquireHP(float goalPercent);
boolean acquireHP(float goalPercent, int meat_reserve);
boolean acquireHP(float goalPercent, int meat_reserve, boolean freeRest);
float mp_regen();
float hp_regen();
int doRest();
boolean haveAnyIotmAlternativeRestSiteAvailable();
boolean doFreeRest();
boolean haveFreeRestAvailable();
int freeRestsRemaining();
boolean uneffect(effect toRemove);

########################################################################################################
//Defined in autoscend/autoscend_migration.ash
string autoscend_current_version();
string autoscend_previous_version();
boolean autoscend_needs_update();
boolean autoscend_migrate();

########################################################################################################
//Defined in autoscend/auto_zlib.ash
void auto_process_kmail(string functionname);

########################################################################################################
//Defined in autoscend/auto_zone.ash
boolean zone_unlock(location loc);
boolean zone_isAvailable(location loc, boolean unlockIfPossible);
boolean zone_isAvailable(location loc);
int[location] zone_delayable();
generic_t zone_needItem(location loc);
generic_t zone_combatMod(location loc);
generic_t zone_delay(location loc);
boolean zone_available(location loc);
generic_t zone_difficulty(location loc);
boolean zone_hasLuckyAdventure(location loc);
location[int] zones_available();
monster[int] mobs_available();
item[int] drops_available();
item[int] hugpocket_available();
boolean is_ghost_in_zone(location loc);
boolean[location] monster_to_location(monster target);

########################################################################################################
//Defined in autoscend/auto_util.ash
//Other files are placed alphabetically. But due to its sheer size auto_util.ash goes last

boolean autoMaximize(string req, boolean simulate);
boolean autoMaximize(string req, int maxPrice, int priceLevel, boolean simulate);
aggregate autoMaximize(string req, int maxPrice, int priceLevel, boolean simulate, boolean includeEquip);
void debugMaximize(string req, int meat);
string trim(string input);
string safeString(string input);
string safeString(skill input);
string safeString(item input);
string safeString(monster input);
void handleTracker(string used, string tracker);
void handleTracker(string used, string detail, string tracker);
boolean organsFull();
boolean backupSetting(string setting, string newValue);
boolean restoreAllSettings();
boolean restoreSetting(string setting);
location provideAdvPHPZone();
boolean loopHandler(string turnSetting, string counterSetting, string abortMessage, int threshold);
boolean loopHandler(string turnSetting, string counterSetting, int threshold);
boolean loopHandlerDelay(string counterSetting);
boolean loopHandlerDelay(string counterSetting, int threshold);
boolean loopHandlerDelayAll();
string reverse(string s);
boolean setAdvPHPFlag();
boolean isOverdueArrow();
boolean isExpectingArrow();
int[monster] banishedMonsters();
boolean isBanished(monster enemy);
boolean is_avatar_potion(item it);
int autoCraft(string mode, int count, item item1, item item2);
int internalQuestStatus(string prop);
int estimatedTurnsLeft();
boolean canYellowRay(monster target);
boolean canYellowRay();
boolean[string] auto_banishesUsedAt(location loc);
boolean auto_wantToBanish(monster enemy, location loc);
boolean canBanish(monster enemy, location loc);
boolean adjustForBanish(string combat_string);
boolean adjustForBanishIfPossible(monster enemy, location loc);
boolean adjustForYellowRay(string combat_string);
boolean adjustForYellowRayIfPossible(monster target);
boolean adjustForYellowRayIfPossible();
boolean canReplace(monster target);
boolean canReplace();
boolean adjustForReplace(string combat_string);
boolean adjustForReplaceIfPossible(monster target);
boolean adjustForReplaceIfPossible();
boolean canSniff(monster enemy, location loc);
boolean adjustForSniffingIfPossible(monster target);
boolean adjustForSniffingIfPossible();
string statCard();
boolean hasTorso();
boolean isGuildClass();
float elemental_resist_value(int resistance);
int elemental_resist(element goal);
skill preferredLibram();
boolean lastAdventureSpecialNC();
effect whatStatSmile();
item whatHiMein();
boolean ovenHandle();
boolean isGhost(monster mon);
boolean isProtonGhost(monster mon);
int cloversAvailable();
boolean cloverUsageInit();
boolean cloverUsageRestart();
boolean cloverUsageFinish();
boolean isHermitAvailable();
boolean isGalaktikAvailable();
boolean isGeneralStoreAvailable();
boolean isArmoryAndLeggeryStoreAvailable();
boolean isMusGuildStoreAvailable();
boolean isMystGuildStoreAvailable();
boolean isArmoryAvailable();
boolean isUnclePAvailable();
boolean isDesertAvailable();
boolean inKnollSign();
boolean inCanadiaSign();
boolean inGnomeSign();
boolean allowSoftblockShen();
boolean setSoftblockShen();
boolean instakillable(monster mon);
boolean stunnable(monster mon);
float combatItemDamageMultiplier();
float MLDamageToMonsterMultiplier();
int freeCrafts();
boolean isFreeMonster(monster mon);
boolean declineTrades();
boolean auto_deleteMail(kmailObject msg);
boolean LX_summonMonster();
boolean canSummonMonster(monster mon);
boolean summonMonster(monster mon);
boolean summonMonster(monster mon, boolean speculative);
boolean handleCopiedMonster(item itm);
boolean handleCopiedMonster(item itm, string option);
int maxSealSummons();
boolean acquireCombatMods(int amt);
boolean acquireCombatMods(int amt, boolean doEquips);
boolean basicAdjustML();
int highest_available_mcd();
boolean auto_change_mcd(int mcd);
boolean auto_change_mcd(int mcd, boolean immediately);
boolean evokeEldritchHorror(string option);
boolean evokeEldritchHorror();
boolean fightScienceTentacle(string option);
boolean fightScienceTentacle();
boolean handleSealNormal(item it);
boolean handleSealNormal(item it, string option);
boolean handleSealAncient();
boolean handleSealAncient(string option);
boolean handleSealElement(element flavor);
boolean handleSealElement(element flavor, string option);
boolean handleBarrelFullOfBarrels(boolean daily);
boolean use_barrels();
boolean forceEquip(slot sl, item it);
boolean auto_autosell(int quantity, item toSell);
string runChoice(string page_text);
boolean set_property_ifempty(string setting, string change);
boolean restore_property(string setting, string source);
boolean clear_property_if(string setting, string cond);
int doNumberology(string goal);
int doNumberology(string goal, string option);
int doNumberology(string goal, boolean doIt);
int doNumberology(string goal, boolean doIt, string option);
boolean auto_have_skill(skill sk);
boolean have_skills(boolean[skill] array);
void woods_questStart();
int howLongBeforeHoloWristDrop();
boolean hasShieldEquipped();
boolean careAboutDrops(monster mon);
float effectiveDropChance(item it, float baseDropRate);
boolean[effect] ATSongList();
void shrugAT();
void shrugAT(effect anticipated);
boolean acquireTransfunctioner();
int [item] auto_get_campground();
location solveDelayZone();
boolean setSoftblockDelay();
boolean allowSoftblockDelay();
boolean setSoftblockDelay();
boolean canBurnDelay(location loc);
boolean auto_is_valid(item it);
boolean auto_is_valid(familiar fam);
boolean auto_is_valid(skill sk);
boolean auto_is_valid(effect eff);
void auto_log(string s, string color, int log_level);
void auto_log_error(string s);
void auto_log_warning(string s, string color);
void auto_log_warning(string s);
void auto_log_info(string s, string color);
void auto_log_info(string s);
void auto_log_debug(string s, string color);
void auto_log_debug(string s);
boolean auto_can_equip(item it);
boolean auto_can_equip(item it, slot s);
boolean auto_check_conditions(string conds);
boolean [monster] auto_getMonsters(string category);
boolean auto_wantToSniff(monster enemy, location loc);
boolean auto_wantToYellowRay(monster enemy, location loc);
boolean auto_wantToReplace(monster enemy, location loc);
int total_items(boolean [item] items);
boolean auto_badassBelt();
void auto_interruptCheck(boolean debug);
void auto_interruptCheck();
element currentFlavour();
boolean setFlavour(element ele);
boolean executeFlavour();
boolean autoFlavour(location place);
boolean canSimultaneouslyAcquire(int[item] needed);
boolean[int] knapsack(int maxw, int n, int[int] weight, float[int] val);
int auto_reserveAmount(item it);
int auto_reserveCraftAmount(item orig_it);
int auto_convertDesiredML(int DML);
boolean auto_setMCDToCap();
boolean UrKelCheck(int UrKelToML, int UrKelUpperLimit, int UrKelLowerLimit);
boolean angryAgateCheck(int angryAgateToML, int angryAgateUpperLimit, int angryAgateLowerLimit);
boolean auto_MaxMLToCap(int ToML, boolean doAltML);
boolean auto_canForceNextNoncombat();
boolean auto_forceNextNoncombat();
boolean auto_haveQueuedForcedNonCombat();
boolean is_expectedForcedNonCombat(string encounterName);
boolean is_superlikely(string encounterName);
int auto_predictAccordionTurns();
boolean hasTTBlessing();
void effectAblativeArmor(boolean passive_dmg_allowed);
int currentPoolSkill();
int poolSkillPracticeGains();
boolean hasUsefulShirt();
int meatReserve();
