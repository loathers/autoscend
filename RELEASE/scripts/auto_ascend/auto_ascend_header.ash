script "auto_ascend_header.ash"

//	This is the primary (or will be) header file for auto_ascend.
//	All potentially cross-dependent functions should be defined here such that we can use them from
//	other scripts without the circular dependency issue. Thanks Ultibot for the advice regarding this.
//	Documentation can go here too, I suppose.
//	All functions that are defined outside of auto_ascend must include a note regarding where they come from
//		Seriously, it\'s rude not to.

//	Question Functions
//	Denoted as L<classification>[<path>]_<name>:
//		<classification>: Level to be used (Numeric, X for any). A for entire ascension.
//		<classification>: M for most of ascension, "sc" for Seal Clubber only
//		<path>: [optional] indicates path to be used in. "ed" for ed, "cs" for community service
//			Usually separated with _
boolean LA_cs_communityService();				//Defined in auto_ascend/auto_community_service.ash
boolean LM_edTheUndying();						//Defined in auto_ascend/auto_edTheUndying.ash

boolean LX_desertAlternate();
boolean LX_handleSpookyravenNecklace();
boolean LX_handleSpookyravenFirstFloor();
boolean LX_phatLootToken();
boolean LX_islandAccess();
boolean LX_fancyOilPainting();
boolean LX_setBallroomSong();
boolean LX_fcle();
boolean LX_ornateDowsingRod();
boolean LX_getDictionary();
boolean LX_dictionary();
boolean LX_nastyBooty();
boolean LX_spookyravenSecond();
boolean LX_spookyBedroomCombat();
boolean LX_getDigitalKey();
boolean LX_guildUnlock();
boolean LX_hardcoreFoodFarm();
boolean LX_melvignShirt();
boolean LX_attemptPowerLevel();
boolean LX_attemptFlyering();
boolean LX_bitchinMeatcar();
boolean LX_meatMaid();
boolean LX_craftAcquireItems();
boolean LX_freeCombats();
boolean LX_dolphinKingMap();
boolean LX_steelOrgan();
boolean Lx_resolveSixthDMT();
boolean LX_witchess();
boolean LX_chateauPainting();
boolean LX_faxing();
boolean LX_universeFrat();
boolean LX_burnDelay();
boolean LX_loggingHatchet();


//*********** Section of stuff moved into auto_optionals.ash *******************/
boolean LX_artistQuest();
boolean LX_dinseylandfillFunbucks();
//*********** End of stuff moved into auto_optionals.ash ***********************/

boolean Lsc_flyerSeals();

boolean L0_handleRainDoh();

boolean L1_ed_island();							//Defined in auto_ascend/auto_edTheUndying.ash
boolean L1_ed_dinsey();							//Defined in auto_ascend/auto_edTheUndying.ash
boolean L1_ed_island(int dickstabOverride);		//Defined in auto_ascend/auto_edTheUndying.ash
boolean L1_ed_islandFallback();					//Defined in auto_ascend/auto_edTheUndying.ash
boolean L1_dnaAcquire();
boolean L2_mosquito();
boolean L2_treeCoin();
boolean L2_spookyMap();
boolean L2_spookyFertilizer();
boolean L2_spookySapling();

boolean L3_tavern();

boolean L4_batCave();
boolean L5_haremOutfit();
boolean L5_findKnob();
boolean L5_goblinKing();
boolean L5_getEncryptionKey();
boolean L6_dakotaFanning();
boolean L6_friarsGetParts();
boolean L6_friarsHotWing();
boolean L8_trapperStart();
boolean L7_crypt();
boolean L8_trapperGround();
boolean L8_trapperYeti();
boolean L8_trapperExtreme();
boolean L8_trapperGroar();
boolean L9_chasmStart();
boolean L9_chasmBuild();
boolean L9_highLandlord();
boolean L9_aBooPeak();
boolean L9_twinPeak();
boolean L9_oilPeak();
boolean L9_leafletQuest();

boolean L10_plantThatBean();
boolean L10_airship();
boolean L10_basement();
boolean L10_ground();
boolean L10_topFloor();
boolean L10_holeInTheSkyUnlock();
boolean L10_holeInTheSky();
boolean L11_palindome();
boolean L11_hiddenCity();
boolean L11_hiddenTavernUnlock();
boolean L11_hiddenTavernUnlock(boolean force);
boolean L11_blackMarket();
boolean L11_forgedDocuments();
boolean L11_aridDesert();
boolean L11_mcmuffinDiary();
boolean L11_unlockHiddenCity();
boolean L11_hiddenCityZones();
boolean L11_talismanOfNam();
boolean L11_shenCopperhead();
boolean L11_ronCopperhead();
boolean L11_redZeppelin();
boolean L11_mauriceSpookyraven();
boolean L11_nostrilOfTheSerpent();
boolean L11_unlockPyramid();
boolean L11_unlockEd();
boolean L11_defeatEd();
boolean L11_getBeehive();
boolean L11_fistDocuments();
boolean L12_lastDitchFlyer();
boolean L12_flyerBackup();
boolean L12_flyerFinish();
boolean L12_preOutfit();
boolean L12_getOutfit();
boolean L12_startWar();
boolean L12_filthworms();
boolean L12_sonofaBeach();
boolean L12_sonofaFinish();
boolean L12_gremlins();
boolean L12_gremlinStart();
boolean L12_orchardFinalize();
boolean L12_orchardStart();
boolean L12_finalizeWar();
boolean L13_sorceressDoor();
boolean L13_towerNSEntrance();
boolean L13_towerNSContests();
boolean L13_towerNSHedge();
boolean L13_towerNSTower();
boolean L13_towerNSNagamar();
boolean L13_towerNSTransition();
boolean L13_towerNSFinal();
boolean L13_ed_councilWarehouse();
boolean L13_ed_towerHandler();
boolean questOverride();


//
//	Primary adventuring functions, we need additonal functionality over adv1, so we do it here.
//	Note that, as of at least Mafia r16560, we can not use run_combat(<combat filter>).
//	Don\'t even try it, it requires a custom modification that we can not really do an ASH workaround for.
//	They are all defined in auto_ascend/auto_adventure.ash
boolean autoAdv();
boolean autoAdv(location loc);								//num is ignored
boolean autoAdv(int num, location loc);						//num is ignored
boolean autoAdv(int num, location loc, string option);		//num is ignored
boolean autoAdv(location loc, string option);
boolean autoAdvBypass(string url);
boolean autoAdvBypass(string url, string option);
boolean autoAdvBypass(string url, location loc);
boolean autoAdvBypass(string url, location loc, string option);
#boolean autoAdvBypass(string[int] url);
#boolean autoAdvBypass(string[int] url, string option);
#boolean autoAdvBypass(string[int] url, location loc);
boolean autoAdvBypass(int becauseStringIntIsSomehowJustString, string[int] url, location loc, string option);
boolean autoAdvBypass(int snarfblat);
boolean autoAdvBypass(int snarfblat, string option);
boolean autoAdvBypass(int snarfblat, location loc);
boolean autoAdvBypass(int snarfblat, location loc, string option);

//
//	Secondary adventuring functions
//	They are all defined in auto_ascend/auto_adventure.ash
boolean preAdvXiblaxian(location loc);


// Log Handling/User Output
void print_header();


// Semi-rare Handlers:
boolean fortuneCookieEvent();

// Familiar Behavior, good stuff.
boolean handleFamiliar(familiar fam);
boolean handleFamiliar(string fam);
boolean basicFamiliarOverrides();

// Meat Generation
boolean autosellCrap();

// Daily Events that should happen at start and not end.
boolean dailyEvents();


//
//	External auto_ascend.ash functions, indicate where they come from.
//
//


//Do we have a some item either equipped or in inventory (not closet or hagnk\'s.
boolean possessEquipment(item equipment);		//Defined in auto_ascend/auto_equipment.ash
int equipmentAmount(item equipment); // Defined in auto_ascend/auto_equipment.ash

//Do Bjorn stuff
boolean handleBjornify(familiar fam);			//Defined in auto_ascend/auto_equipment.ash

//Remove +NC or +C equipment
void removeNonCombat();							//Defined in auto_ascend/auto_equipment.ash
void removeCombat();							//Defined in auto_ascend/auto_equipment.ash

//Wrapper for get_campground(), primarily deals with the oven issue in Ed.
//Also uses Garden item as identifier for the garden in addition to what get_campground() does
int[item] auto_get_campground();					//Defined in auto_ascend/auto_util.ash


//Returns how many Hero Keys and Phat Loot tokens we have.
//effective count (with malware) vs true count.
int towerKeyCount(boolean effective);			//Defined in auto_ascend/auto_util.ash
int towerKeyCount();							//Defined in auto_ascend/auto_util.ash


//Uses Daily Dungeon Malware to get Phat Loot.
boolean LX_malware();							//Defined in auto_ascend.ash

//Determines if we need ore for the trapper or not.
boolean needOre();								//Defined in auto_ascend/auto_util.ash

//Wrapper for my_path(), in case there are delays in Mafia translating path values
string auto_my_path();							//Defined in auto_ascend/auto_util.ash

//Visits gnasir, can change based on path
void auto_visit_gnasir();

//Item disambiguation functions
boolean hasSpookyravenLibraryKey();				//Defined in auto_ascend/auto_util.ash
boolean hasILoveMeVolI();						//Defined in auto_ascend/auto_util.ash
boolean useILoveMeVolI();						//Defined in auto_ascend/auto_util.ash


//Are we expecting a Protonic Accelerator Pack ghost report?
boolean expectGhostReport();					//Defined in auto_ascend/auto_mr2016.ash


//Quest Object information, meant for "normal" runs but could technically be expanded or altered.
record questRecord
{
	string prop;					// auto_ascend property reflecting the quest
	string mprop;					// Mafia property reflecting the quest, if applicable
	int type;						// 0 = main line quest, 1 = side quest (allowing for other options)
	string func;					// auto_ascend function that attempts this quest.
};


//Large pile dump.
boolean L11_ed_mauriceSpookyraven();						//Defined in auto_ascend/auto_edTheUndying.ash
boolean L12_sonofaPrefix();									//Defined in auto_ascend.ash
boolean L9_ed_chasmBuild();									//Defined in auto_ascend/auto_edTheUndying.ash
boolean L9_ed_chasmBuildClover(int need);					//Defined in auto_ascend/auto_edTheUndying.ash
boolean L9_ed_chasmStart();									//Defined in auto_ascend/auto_edTheUndying.ash
boolean LM_boris();											//Defined in auto_ascend/auto_boris.ash
boolean LM_fallout();										//Defined in auto_ascend/auto_fallout.ash
boolean LM_jello();											//Defined in auto_ascend/auto_jellonewbie.ash
boolean LM_pete();											//Defined in auto_ascend/auto_sneakypete.ash
boolean LX_ghostBusting();									//Defined in auto_ascend/auto_mr2016.ash
boolean LX_theSource();										//Defined in auto_ascend/auto_theSource.ash
familiar[int] List();										//Defined in auto_ascend/auto_list.ash
effect[int] List(boolean[effect] data);						//Defined in auto_ascend/auto_list.ash
familiar[int] List(boolean[familiar] data);					//Defined in auto_ascend/auto_list.ash
int[int] List(boolean[int] data);							//Defined in auto_ascend/auto_list.ash
item[int] List(boolean[item] data);							//Defined in auto_ascend/auto_list.ash
effect[int] List(effect[int] data);							//Defined in auto_ascend/auto_list.ash
familiar[int] List(familiar[int] data);						//Defined in auto_ascend/auto_list.ash
int[int] List(int[int] data);								//Defined in auto_ascend/auto_list.ash
item[int] List(item[int] data);								//Defined in auto_ascend/auto_list.ash
effect[int] ListErase(effect[int] list, int index);			//Defined in auto_ascend/auto_list.ash
familiar[int] ListErase(familiar[int] list, int index);		//Defined in auto_ascend/auto_list.ash
int[int] ListErase(int[int] list, int index);				//Defined in auto_ascend/auto_list.ash
item[int] ListErase(item[int] list, int index);				//Defined in auto_ascend/auto_list.ash
int ListFind(effect[int] list, effect what);				//Defined in auto_ascend/auto_list.ash
int ListFind(effect[int] list, effect what, int idx);		//Defined in auto_ascend/auto_list.ash
int ListFind(familiar[int] list, familiar what);			//Defined in auto_ascend/auto_list.ash
int ListFind(familiar[int] list, familiar what, int idx);	//Defined in auto_ascend/auto_list.ash
int ListFind(int[int] list, int what);						//Defined in auto_ascend/auto_list.ash
int ListFind(int[int] list, int what, int idx);				//Defined in auto_ascend/auto_list.ash
int ListFind(item[int] list, item what);					//Defined in auto_ascend/auto_list.ash
int ListFind(item[int] list, item what, int idx);			//Defined in auto_ascend/auto_list.ash
effect[int] ListInsert(effect[int] list, effect what);		//Defined in auto_ascend/auto_list.ash
familiar[int] ListInsert(familiar[int] list, familiar what);//Defined in auto_ascend/auto_list.ash
int[int] ListInsert(int[int] list, int what);				//Defined in auto_ascend/auto_list.ash
item[int] ListInsert(item[int] list, item what);			//Defined in auto_ascend/auto_list.ash
effect[int] ListInsertAt(effect[int] list, effect what, int idx);//Defined in auto_ascend/auto_list.ash
familiar[int] ListInsertAt(familiar[int] list, familiar what, int idx);//Defined in auto_ascend/auto_list.ash
int[int] ListInsertAt(int[int] list, int what, int idx);	//Defined in auto_ascend/auto_list.ash
item[int] ListInsertAt(item[int] list, item what, int idx);	//Defined in auto_ascend/auto_list.ash
effect[int] ListInsertFront(effect[int] list, effect what);	//Defined in auto_ascend/auto_list.ash
familiar[int] ListInsertFront(familiar[int] list, familiar what);//Defined in auto_ascend/auto_list.ash
int[int] ListInsertFront(int[int] list, int what);			//Defined in auto_ascend/auto_list.ash
item[int] ListInsertFront(item[int] list, item what);		//Defined in auto_ascend/auto_list.ash
effect[int] ListInsertInorder(effect[int] list, effect what);//Defined in auto_ascend/auto_list.ash
familiar[int] ListInsertInorder(familiar[int] list, familiar what);//Defined in auto_ascend/auto_list.ash
int[int] ListInsertInorder(int[int] list, int what);		//Defined in auto_ascend/auto_list.ash
item[int] ListInsertInorder(item[int] list, item what);		//Defined in auto_ascend/auto_list.ash
string ListOutput(effect[int] list);						//Defined in auto_ascend/auto_list.ash
string ListOutput(familiar[int] list);						//Defined in auto_ascend/auto_list.ash
string ListOutput(int[int] list);							//Defined in auto_ascend/auto_list.ash
string ListOutput(item[int] list);							//Defined in auto_ascend/auto_list.ash
effect[int] ListRemove(effect[int] list, effect what);		//Defined in auto_ascend/auto_list.ash
effect[int] ListRemove(effect[int] list, effect what, int idx);//Defined in auto_ascend/auto_list.ash
familiar[int] ListRemove(familiar[int] list, familiar what);//Defined in auto_ascend/auto_list.ash
familiar[int] ListRemove(familiar[int] list, familiar what, int idx);//Defined in auto_ascend/auto_list.ash
int[int] ListRemove(int[int] list, int what);				//Defined in auto_ascend/auto_list.ash
int[int] ListRemove(int[int] list, int what, int idx);		//Defined in auto_ascend/auto_list.ash
item[int] ListRemove(item[int] list, item what);			//Defined in auto_ascend/auto_list.ash
item[int] ListRemove(item[int] list, item what, int idx);	//Defined in auto_ascend/auto_list.ash
location ListOutput(location[int] list);					//Defined in auto_ascend/auto_list.ash
location[int] locationList();								//Defined in auto_ascend/auto_list.ash
location[int] List(boolean[location] data);					//Defined in auto_ascend/auto_list.ash
location[int] List(location[int] data);						//Defined in auto_ascend/auto_list.ash
location[int] ListRemove(location[int] list, location what);//Defined in auto_ascend/auto_list.ash
location[int] ListRemove(location[int] list, location what, int idx);//Defined in auto_ascend/auto_list.ash
location[int] ListErase(location[int] list, int index);		//Defined in auto_ascend/auto_list.ash
location[int] ListInsertFront(location[int] list, location what);//Defined in auto_ascend/auto_list.ash
location[int] ListInsert(location[int] list, location what);//Defined in auto_ascend/auto_list.ash
location[int] ListInsertAt(location[int] list, location what, int idx);//Defined in auto_ascend/auto_list.ash
location[int] ListInsertInorder(location[int] list, location what);//Defined in auto_ascend/auto_list.ash
int ListFind(location[int] list, location what);			//Defined in auto_ascend/auto_list.ash
int ListFind(location[int] list, location what, int idx);	//Defined in auto_ascend/auto_list.ash
location ListOutput(location[int] list);					//Defined in auto_ascend/auto_list.ash
int [item] auto_get_campground();								//Defined in auto_ascend/auto_util.ash
boolean basicAdjustML();									//Defined in auto_ascend/auto_util.ash
boolean beatenUpResolution();								//Defined in auto_ascend.ash
boolean adventureFailureHandler();							//Defined in auto_ascend.ash
boolean councilMaintenance();								//Defined in auto_ascend.ash
boolean [location] get_floundry_locations();				//Defined in auto_ascend/auto_clan.ash
int[item] auto_get_clan_lounge();								//Defined in auto_ascend/auto_clan.ash
boolean acquireMP(int goal);								//Defined in auto_ascend/auto_util.ash
boolean acquireMP(int goal, boolean buyIt);					//Defined in auto_ascend/auto_util.ash
boolean acquireGumItem(item it);							//Defined in auto_ascend/auto_util.ash
boolean acquireHermitItem(item it);							//Defined in auto_ascend/auto_util.ash
int cloversAvailable();									//Defined in auto_ascend/auto_util.ash
boolean cloverUsageInit();									//Defined in auto_ascend/auto_util.ash
boolean cloverUsageFinish();								//Defined in auto_ascend/auto_util.ash
boolean adjustEdHat(string goal);							//Defined in auto_ascend/auto_edTheUndying.ash
int amountTurkeyBooze();									//Defined in auto_ascend/auto_util.ash
boolean awol_buySkills();									//Defined in auto_ascend/auto_awol.ash
void awol_helper(string page);								//Defined in auto_ascend/auto_combat.ash
boolean canSurvive(float mult, int add);					//Defined in auto_ascend/auto_combat.ash
boolean canSurvive(float mult);								//Defined in auto_ascend/auto_combat.ash
boolean awol_initializeSettings();							//Defined in auto_ascend/auto_awol.ash
void awol_useStuff();										//Defined in auto_ascend/auto_awol.ash
effect awol_walkBuff();										//Defined in auto_ascend/auto_awol.ash
boolean backupSetting(string setting, string newValue);		//Defined in auto_ascend/auto_util.ash
int[monster] banishedMonsters();							//Defined in auto_ascend/auto_util.ash
boolean beehiveConsider();									//Defined in auto_ascend/auto_util.ash
string beerPong(string page);								//Defined in auto_ascend/auto_util.ash
int estimatedTurnsLeft();									//Defined in auto_ascend/auto_util.ash
boolean summonMonster();									//Defined in auto_ascend/auto_util.ash
boolean summonMonster(string option);						//Defined in auto_ascend/auto_util.ash
boolean in_tcrs();											//Defined in auto_ascend/auto_tcrs.ash
boolean tcrs_initializeSettings();							//Defined in auto_ascend/auto_tcrs.ash
float tcrs_expectedAdvPerFill(string quality);				//Defined in auto_ascend/auto_tcrs.ash
boolean tcrs_loadCafeDrinks(int[int] cafe_backmap, float[int] adv, int[int] inebriety);	//Defined in auto_ascend/auto_tcrs.ash
boolean tcrs_consumption();									//Defined in auto_ascend/auto_tcrs.ash
boolean tcrs_maximize_with_items(string maximizerString);	//Defined in auto_ascend/auto_tcrs.ash
boolean in_koe();											//Defined in auto_ascend/auto_koe.ash
boolean boris_buySkills();									//Defined in auto_ascend/auto_boris.ash
void boris_initializeDay(int day);							//Defined in auto_ascend/auto_boris.ash
void boris_initializeSettings();							//Defined in auto_ascend/auto_boris.ash
boolean buffMaintain(effect buff, int mp_min, int casts, int turns);//Defined in auto_ascend/auto_util.ash
boolean buffMaintain(item source, effect buff, int uses, int turns);//Defined in auto_ascend/auto_util.ash
boolean buffMaintain(skill source, effect buff, int mp_min, int casts, int turns);//Defined in auto_ascend/auto_util.ash
boolean buyUpTo(int num, item it);							//Defined in auto_ascend/auto_util.ash
boolean buyUpTo(int num, item it, int maxprice);			//Defined in auto_ascend/auto_util.ash
boolean buy_item(item it, int quantity, int maxprice);		//Defined in auto_ascend/auto_util.ash
boolean buyableMaintain(item toMaintain, int howMany);		//Defined in auto_ascend/auto_util.ash
boolean buyableMaintain(item toMaintain, int howMany, int meatMin);//Defined in auto_ascend/auto_util.ash
boolean buyableMaintain(item toMaintain, int howMany, int meatMin, boolean condition);//Defined in auto_ascend/auto_util.ash
boolean canYellowRay(monster target); //Defined in auto_ascend/auto_util.ash
boolean canYellowRay();										//Defined in auto_ascend/auto_util.ash
boolean autoAdvBypass(int urlGetFlags, string[int] url, location loc, string option);//Defined in auto_ascend/auto_adventure.ash
boolean autoChew(int howMany, item toChew);					//Defined in auto_ascend/auto_cooking.ash
float expectedAdventuresFrom(item it);						//Defined in auto_ascend/auto_cooking.ash
int autoCraft(string mode, int count, item item1, item item2);//Defined in auto_ascend/auto_util.ash
boolean canOde(item toDrink); //Defined in auto_ascend/auto_cooking.ash
boolean canSimultaneouslyAcquire(int[item] needed);			//Defined in auto_ascend/auto_util.ash
boolean clear_property_if(string setting, string cond);		//Defined in auto_ascend/auto_util.ash
boolean autoDrink(int howMany, item toDrink);					//Defined in auto_ascend/auto_cooking.ash
boolean autoEat(int howMany, item toEat);						//Defined in auto_ascend/auto_cooking.ash
boolean autoEat(int howMany, item toEat, boolean silent);		//Defined in auto_ascend/auto_cooking.ash
boolean auto_knapsackAutoConsume(string type, boolean simulate);	//Defined in auto_ascend/auto_cooking.ash
boolean loadConsumables(item[int] item_backmap, int[int] cafe_backmap, float[int] adv, int[int] inebriety);	 //Defined in auto_ascend/auto_cooking.ash
void auto_autoDrinkNightcap(boolean simulate);				//Defined in auto_ascend/auto_cooking.ash
boolean auto_autoDrinkOne(boolean simulate);					//Defined in auto_ascend/auto_cooking.ash
boolean saucemavenApplies(item it);							//Defined in auto_ascend/auto_cooking.ash
boolean autoMaximize(string req, boolean simulate);			//Defined in auto_ascend/auto_util.ash
boolean autoMaximize(string req, int maxPrice, int priceLevel, boolean simulate);//Defined in auto_ascend/auto_util.ash
aggregate autoMaximize(string req, int maxPrice, int priceLevel, boolean simulate, boolean includeEquip);//Defined in auto_ascend/auto_util.ash
boolean autoOverdrink(int howMany, item toOverdrink);			//Defined in auto_ascend/auto_cooking.ash
boolean canDrink(item toDrink);								//Defined in auto_ascend/auto_cooking.ash
boolean canEat(item toEat);									//Defined in auto_ascend/auto_cooking.ash
boolean canChew(item toChew); //Defined in auto_ascend/auto_cooking.ash
boolean auto_have_familiar(familiar fam);						//Defined in auto_ascend/auto_cooking.ash
boolean auto_advWitchess(string target);						//Defined in auto_ascend/auto_mr2016.ash
boolean auto_advWitchess(string target, string option);		//Defined in auto_ascend/auto_mr2016.ash
int auto_advWitchessTargets(string target);					//Defined in auto_ascend/auto_mr2016.ash
boolean auto_autosell(int quantity, item toSell);				//Defined in auto_ascend/auto_util.ash
boolean auto_barrelPrayers();									//Defined in auto_ascend/auto_mr2015.ash
void auto_begin();											//Defined in auto_ascend.ash
item auto_bestBadge();										//Defined in auto_ascend/auto_mr2016.ash
boolean auto_change_mcd(int mcd);								//Defined in auto_ascend/auto_util.ash
string auto_combatHandler(int round, string opp, string text);//Defined in auto_ascend/auto_combat.ash
boolean auto_doPrecinct();									//Defined in auto_ascend/auto_mr2016.ash
string auto_edCombatHandler(int round, string opp, string text);//Defined in auto_ascend/auto_combat.ash
string auto_saberTrickMeteorShowerCombatHandler(int round, string opp, string text); //Defined in auto_ascend/auto_combat.ash
boolean auto_floundryAction();								//Defined in auto_ascend/auto_clan.ash
boolean auto_floundryUse();									//Defined in auto_ascend/auto_clan.ash
boolean auto_floundryAction(item it);							//Defined in auto_ascend/auto_clan.ash
boolean auto_haveSourceTerminal();							//Defined in auto_ascend/auto_mr2016.ash
boolean auto_haveWitchess();									//Defined in auto_ascend/auto_mr2016.ash
boolean auto_mayoItems();										//Defined in auto_ascend/auto_mr2015.ash
boolean auto_maximizedConsumeStuff();							//Defined in auto_ascend/auto_cooking.ash
void auto_process_kmail(string functionname);					//Defined in auto_ascend/auto_zlib.ash
boolean auto_sourceTerminalEducate(skill first);				//Defined in auto_ascend/auto_mr2016.ash
boolean auto_sourceTerminalEducate(skill first, skill second);//Defined in auto_ascend/auto_mr2016.ash
boolean auto_sourceTerminalEnhance(string request);			//Defined in auto_ascend/auto_mr2016.ash
int auto_sourceTerminalEnhanceLeft();							//Defined in auto_ascend/auto_mr2016.ash
boolean auto_sourceTerminalExtrude(string request);			//Defined in auto_ascend/auto_mr2016.ash
int auto_sourceTerminalExtrudeLeft();							//Defined in auto_ascend/auto_mr2016.ash
int[string] auto_sourceTerminalMissing();						//Defined in auto_ascend/auto_mr2016.ash
boolean auto_sourceTerminalRequest(string request);			//Defined in auto_ascend/auto_mr2016.ash
int[string] auto_sourceTerminalStatus();						//Defined in auto_ascend/auto_mr2016.ash
boolean auto_tavern();										//Defined in auto_ascend.ash
string ccsJunkyard(int round, string opp, string text);		//Defined in auto_ascend/auto_combat.ash
int changeClan();											//Defined in auto_ascend/auto_clan.ash
int changeClan(int toClan);									//Defined in auto_ascend/auto_clan.ash
int changeClan(string clanName);							//Defined in auto_ascend/auto_clan.ash
boolean chateaumantegna_available();						//Defined in auto_ascend/auto_mr2015.ash
void chateaumantegna_buyStuff(item toBuy);					//Defined in auto_ascend/auto_mr2015.ash
boolean[item] chateaumantegna_decorations();				//Defined in auto_ascend/auto_mr2015.ash
boolean chateaumantegna_havePainting();						//Defined in auto_ascend/auto_mr2015.ash
boolean chateaumantegna_nightstandSet();					//Defined in auto_ascend/auto_mr2015.ash
void chateaumantegna_useDesk();								//Defined in auto_ascend/auto_mr2015.ash
boolean chateaumantegna_usePainting();						//Defined in auto_ascend/auto_mr2015.ash
boolean chateaumantegna_usePainting(string option);			//Defined in auto_ascend/auto_mr2015.ash
boolean clear_property_if(string setting, string cond);		//Defined in auto_ascend/auto_util.ash
boolean considerGrimstoneGolem(boolean bjornCrown);			//Defined in auto_ascend/auto_util.ash
boolean acquireTransfunctioner();							//Defined in auto_ascend/auto_util.ash
void consumeStuff();										//Defined in auto_ascend/auto_cooking.ash
boolean containsCombat(item it);							//Defined in auto_ascend/auto_combat.ash
boolean containsCombat(skill sk);							//Defined in auto_ascend/auto_combat.ash
boolean containsCombat(string action);						//Defined in auto_ascend/auto_combat.ash

string cs_combatKing(int round, string opp, string text);	//Defined in auto_ascend/auto_community_service.ash
string cs_combatLTB(int round, string opp, string text);	//Defined in auto_ascend/auto_community_service.ash
string cs_combatNormal(int round, string opp, string text);	//Defined in auto_ascend/auto_community_service.ash
string cs_combatWitch(int round, string opp, string text);	//Defined in auto_ascend/auto_community_service.ash
string cs_combatYR(int round, string opp, string text);		//Defined in auto_ascend/auto_community_service.ash
void cs_dnaPotions();										//Defined in auto_ascend/auto_community_service.ash
boolean cs_eat_spleen();									//Defined in auto_ascend/auto_community_service.ash
boolean cs_eat_stuff(int quest);							//Defined in auto_ascend/auto_community_service.ash
boolean cs_giant_growth();									//Defined in auto_ascend/auto_community_service.ash
void cs_initializeDay(int day);								//Defined in auto_ascend/auto_community_service.ash
void cs_make_stuff(int curQuest);							//Defined in auto_ascend/auto_community_service.ash
boolean cs_spendRests();									//Defined in auto_ascend/auto_community_service.ash
boolean cs_witchess();										//Defined in auto_ascend/auto_community_service.ash
int estimate_cs_questCost(int quest);						//Defined in auto_ascend/auto_community_service.ash
int [int] get_cs_questList();								//Defined in auto_ascend/auto_community_service.ash
boolean auto_csHandleGrapes();								//Defined in auto_ascend/auto_community_service.ash
string what_cs_quest(int quest);							//Defined in auto_ascend/auto_community_service.ash
int get_cs_questCost(int quest);							//Defined in auto_ascend/auto_community_service.ash
int get_cs_questCost(string input);							//Defined in auto_ascend/auto_community_service.ash
int get_cs_questNum(string input);							//Defined in auto_ascend/auto_community_service.ash
int expected_next_cs_quest();								//Defined in auto_ascend/auto_community_service.ash
int expected_next_cs_quest_internal();						//Defined in auto_ascend/auto_community_service.ash
boolean do_chateauGoat();									//Defined in auto_ascend/auto_community_service.ash
boolean do_cs_quest(int quest);								//Defined in auto_ascend/auto_community_service.ash
boolean do_cs_quest(string quest);							//Defined in auto_ascend/auto_community_service.ash
boolean cs_preTurnStuff(int curQuest);						//Defined in auto_ascend/auto_community_service.ash
void set_cs_questListFast(int[int] fast);					//Defined in auto_ascend/auto_community_service.ash
boolean cs_healthMaintain();											//Defined in auto_ascend/auto_community_service.ash
boolean cs_healthMaintain(int target);						//Defined in auto_ascend/auto_community_service.ash
boolean cs_mpMaintain();													//Defined in auto_ascend/auto_community_service.ash
boolean cs_mpMaintain(int target);								//Defined in auto_ascend/auto_community_service.ash
boolean canTrySaberTrickMeteorShower();           //Defined in auto_ascend/auto_community_service.ash
boolean trySaberTrickMeteorShower();              //Defined in auto_ascend/auto_community_service.ash
int beachHeadTurnSavings(int quest);							//Defined in auto_ascend/auto_community_service.ash
boolean tryBeachHeadBuff(int quest);							//Defined in auto_ascend/auto_community_service.ash

boolean dealWithMilkOfMagnesium(boolean useAdv);			//Defined in auto_ascend/auto_cooking.ash
void debugMaximize(string req, int meat);					//Defined in auto_ascend/auto_util.ash
boolean deck_available();									//Defined in auto_ascend/auto_mr2015.ash
boolean deck_cheat(string cheat);							//Defined in auto_ascend/auto_mr2015.ash
boolean deck_draw();										//Defined in auto_ascend/auto_mr2015.ash
int deck_draws_left();										//Defined in auto_ascend/auto_mr2015.ash
boolean deck_useScheme(string action);						//Defined in auto_ascend/auto_mr2015.ash
boolean didWePlantHere(location loc);						//Defined in auto_ascend/auto_floristfriar.ash
boolean dinseylandfill_garbageMoney();						//Defined in auto_ascend/auto_elementalPlanes.ash
boolean dna_bedtime();										//Defined in auto_ascend/auto_mr2014.ash
boolean dna_generic();										//Defined in auto_ascend/auto_mr2014.ash
boolean dna_sorceressTest();								//Defined in auto_ascend/auto_mr2014.ash
boolean dna_startAcquire();									//Defined in auto_ascend/auto_mr2014.ash
boolean auto_reagnimatedGetPart();	//Defined in auto_ascend/auto_mr2012.ash
boolean doBedtime();										//Defined in auto_ascend.ash
boolean doHRSkills();										//Defined in auto_ascend/auto_heavyrains.ash
boolean doVacation();										//Defined in auto_ascend.ash
int doHottub();												//Defined in auto_ascend/auto_clan.ash
int doNumberology(string goal);								//Defined in auto_ascend/auto_util.ash
int doNumberology(string goal, boolean doIt);				//Defined in auto_ascend/auto_util.ash
int doNumberology(string goal, boolean doIt, string option);//Defined in auto_ascend/auto_util.ash
int doNumberology(string goal, string option);				//Defined in auto_ascend/auto_util.ash
int doRest();												//Defined in auto_ascend/auto_util.ash
boolean haveFreeRestAvailable();		//Defined in auto_ascend/auto_util.ash
boolean doFreeRest();										//Defined in auto_ascend/auto_util.ash
boolean doTasks();											//Defined in auto_ascend.ash
boolean keepOnTruckin();									//Defined in auto_ascend/auto_cooking.ash
boolean doThemtharHills();									//Defined in auto_ascend.ash
boolean isSpeakeasyDrink(item drink); //Defined in auto_ascend/auto_clan.ash
boolean canDrinkSpeakeasyDrink(item drink); //Defined in auto_ascend/auto_clan.ash
boolean drinkSpeakeasyDrink(item drink);					//Defined in auto_ascend/auto_clan.ash
boolean drinkSpeakeasyDrink(string drink);					//Defined in auto_ascend/auto_clan.ash
boolean eatFancyDog(string dog);							//Defined in auto_ascend/auto_clan.ash
boolean zataraClanmate(string who);							//Defined in auto_ascend/auto_clan.ash
boolean zataraSeaside(string who);							//Defined in auto_ascend/auto_clan.ash
float edMeatBonus();										//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_buySkills();										//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_autoAdv(int num, location loc, string option);		//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_autoAdv(int num, location loc, string option, boolean skipFirstLife);//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_doResting();										//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_eatStuff();										//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_handleAdventureServant(int num, location loc, string option);//Defined in auto_ascend/auto_edTheUndying.ash
void ed_initializeDay(int day);								//Defined in auto_ascend/auto_edTheUndying.ash
void ed_initializeSession();								//Defined in auto_ascend/auto_edTheUndying.ash
void ed_initializeSettings();								//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_needShop();										//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_preAdv(int num, location loc, string option);	//Defined in auto_ascend/auto_edTheUndying.ash
boolean ed_shopping();										//Defined in auto_ascend/auto_edTheUndying.ash
int ed_spleen_limit();										//Defined in auto_ascend/auto_edTheUndying.ash
void ed_terminateSession();									//Defined in auto_ascend/auto_edTheUndying.ash
effect[int] effectList();									//Defined in auto_ascend/auto_list.ash
boolean elementalPlanes_access(element ele);				//Defined in auto_ascend/auto_elementalPlanes.ash
boolean elementalPlanes_initializeSettings();				//Defined in auto_ascend/auto_elementalPlanes.ash
boolean elementalPlanes_takeJob(element ele);				//Defined in auto_ascend/auto_elementalPlanes.ash
int elemental_resist(element goal);							//Defined in auto_ascend/auto_util.ash
float elemental_resist_value(int resistance);				//Defined in auto_ascend/auto_util.ash
void ensureSealClubs();										//Defined in auto_ascend/auto_equipment.ash
string getMaximizeSlotPref(slot s); //Defined in auto_ascend/auto_equipment.ash
item getTentativeMaximizeEquip(slot s); //Defined in auto_ascend/auto_equipment.ash
boolean autoEquip(slot s, item it); //Defined in auto_ascend/auto_equipment.ash
boolean autoEquip(item it); //Defined in auto_ascend/auto_equipment.ash
boolean autoForceEquip(slot s, item it); //Defined in auto_ascend/auto_equipment.ash
boolean autoForceEquip(item it); //Defined in auto_ascend/auto_equipment.ash
boolean tryAddItemToMaximize(slot s, item it); //Defined in auto_ascend/auto_equipment.ash
boolean useMaximizeToEquip(); //Defined in auto_ascend/auto_equipment.ash
string defaultMaximizeStatement(); //Defined in auto_ascend/auto_equipment.ash
void resetMaximize(); //Defined in auto_ascend/auto_equipment.ash
void finalizeMaximize(); //Defined in auto_ascend/auto_equipment.ash
void addToMaximize(string add); //Defined in auto_ascend/auto_equipment.ash
void removeFromMaximize(string rem); //Defined in auto_ascend/auto_equipment.ash
boolean maximizeContains(string check); //Defined in auto_ascend/auto_equipment.ash
boolean simMaximize(); //Defined in auto_ascend/auto_equipment.ash
boolean simMaximizeWith(string add); //Defined in auto_ascend/auto_equipment.ash
float simValue(string modifier); //Defined in auto_ascend/auto_equipment.ash
void equipOverrides(); //Defined in auto_ascend/auto_equipment.ash
void equipMaximizedGear(); //Defined in auto_ascend/auto_equipment.ash
void equipBaseline();										//Defined in auto_ascend/auto_equipment.ash
void equipRollover();										//Defined in auto_ascend/auto_equipment.ash
boolean eudora_available();									//Defined in auto_ascend/auto_eudora.ash
item eudora_current();										//Defined in auto_ascend/auto_eudora.ash
boolean[item] eudora_initializeSettings();					//Defined in auto_ascend/auto_eudora.ash
int[item] eudora_xiblaxian();								//Defined in auto_ascend/auto_eudora.ash
boolean evokeEldritchHorror();								//Defined in auto_ascend/auto_util.ash
boolean evokeEldritchHorror(string option);					//Defined in auto_ascend/auto_util.ash
boolean fallout_buySkills();								//Defined in auto_ascend/auto_fallout.ash
void fallout_initializeDay(int day);						//Defined in auto_ascend/auto_fallout.ash
void fallout_initializeSettings();							//Defined in auto_ascend/auto_fallout.ash
int fastenerCount();										//Defined in auto_ascend/auto_util.ash
boolean fightScienceTentacle();								//Defined in auto_ascend/auto_util.ash
boolean fightScienceTentacle(string option);				//Defined in auto_ascend/auto_util.ash
string findBanisher(int round, string opp, string text);	//Defined in auto_ascend/auto_combat.ash
void florist_initializeSettings();							//Defined in auto_ascend/auto_floristfriar.ash
boolean forceEquip(slot sl, item it);						//Defined in auto_ascend/auto_util.ash
int fullness_left();										//Defined in auto_ascend/auto_util.ash
location solveDelayZone();									//Defined in auto_ascend/auto_util.ash
item getAvailablePerfectBooze();							//Defined in auto_ascend/auto_cooking.ash
item[element] getCharterIndexable();						//Defined in auto_ascend/auto_elementalPlanes.ash
boolean getDiscoStyle();									//Defined in auto_ascend/auto_elementalPlanes.ash
boolean getDiscoStyle(int choice);							//Defined in auto_ascend/auto_elementalPlanes.ash
boolean mummifyFamiliar(familiar fam, string bonus);		//Defined in auto_ascend/auto_mr2017.ash
int januaryToteTurnsLeft(item it);							//Defined in auto_ascend/auto_mr2018.ash
boolean januaryToteAcquire(item it);						//Defined in auto_ascend/auto_mr2018.ash
boolean godLobsterCombat();									//Defined in auto_ascend/auto_mr2018.ash
boolean godLobsterCombat(item it);							//Defined in auto_ascend/auto_mr2018.ash
boolean godLobsterCombat(item it, int goal);				//Defined in auto_ascend/auto_mr2018.ash
boolean godLobsterCombat(item it, int goal, string option);	//Defined in auto_ascend/auto_mr2018.ash
boolean fantasyRealmToken();								//Defined in auto_ascend/auto_mr2018.ash
boolean fantasyRealmAvailable();							//Defined in auto_ascend/auto_mr2018.ash
boolean songboomSetting(string goal);						//Defined in auto_ascend/auto_mr2018.ash
boolean songboomSetting(int choice);						//Defined in auto_ascend/auto_mr2018.ash
int catBurglarHeistsLeft();									//Defined in auto_ascend/auto_mr2018.ash
boolean catBurglarHeist(item it);							//Defined in auto_ascend/auto_mr2018.ash
boolean fightClubNap();										//Defined in auto_ascend/auto_mr2018.ash
boolean fightClubStats();									//Defined in auto_ascend/auto_mr2018.ash
boolean fightClubSpa();										//Defined in auto_ascend/auto_mr2018.ash
boolean fightClubSpa(int option);							//Defined in auto_ascend/auto_mr2018.ash
boolean fightClubSpa(effect eff);							//Defined in auto_ascend/auto_mr2018.ash
boolean cheeseWarMachine(int stats, int it, int buff, int potion);//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat(stat st, boolean hardmode, string option, boolean powerlevelling);//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat(effect eff, boolean hardmode, string option, boolean powerlevelling);//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat(stat st, boolean hardmode);	//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat(effect eff, boolean hardmode);//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat(stat st);					//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat(effect eff);					//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyCombat();							//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyPowerlevel();					//Defined in auto_ascend/auto_mr2018.ash
boolean neverendingPartyAvailable();						//Defined in auto_ascend/auto_mr2018.ash
string auto_latteDropName(location l); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteDropAvailable(location l); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteDropWanted(location l); // Defined in auto_ascend/auto_mr2018.ash
string auto_latteTranslate(string ingredient); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(string want1, string want2, string want3, boolean force); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(string want1, string want2, string want3); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(string want1, string want2, boolean force); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(string want1, string want2); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(string want1, boolean force); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(string want1); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_latteRefill(); // Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteSetup();										//Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteSetup(int candidate);						//Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteSetup(int candidate, int first, int second);	//Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteMonster();									//Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteMonster(boolean freeMon);					//Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteMonster(boolean freeMon, location loc);		//Defined in auto_ascend/auto_mr2018.ash
boolean auto_voteMonster(boolean freeMon, location loc, string option);//Defined in auto_ascend/auto_mr2018.ash
int auto_sausageEaten(); // Defined in auto_ascend/auto_mr2019.ash
int auto_sausageLeftToday(); // Defined in auto_ascend/auto_mr2019.ash
int auto_sausageUnitsNeededForSausage(int numSaus); // Defined in auto_ascend/auto_mr2019.ash
int auto_sausageMeatPasteNeededForSausage(int numSaus); // Defined in auto_ascend/auto_mr2019.ash
int auto_sausageFightsToday(); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageGrind(int numSaus); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageGrind(int numSaus, boolean failIfCantMakeAll); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageEatEmUp(int maximumToEat); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageEatEmUp(); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageGoblin(); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageGoblin(location loc); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_sausageGoblin(location loc, string option); // Defined in auto_ascend/auto_mr2019.ash
boolean pirateRealmAvailable(); // Defined in auto_ascend/auto_mr2019.ash
boolean LX_unlockPirateRealm(); // Defined in auto_ascend/auto_mr2019.ash
boolean auto_saberChoice(string choice);	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_saberDailyUpgrade(int day);	// Defined in auto_ascend/auto_mr2019.ash
monster auto_saberCurrentMonster();	// Defined in auto_ascend/auto_mr2019.ash
int auto_saberChargesAvailable();	// Defined in auto_ascend/auto_mr2019.ash
string auto_combatSaberBanish();	// Defined in auto_ascend/auto_mr2019.ash
string auto_combatSaberCopy();	// Defined in auto_ascend/auto_mr2019.ash
string auto_combatSaberYR();	// Defined in auto_ascend/auto_mr2019.ash
string auto_spoonGetDesiredSign();	// Defined in auto_ascend/auto_mr2019.ash
void auto_spoonTuneConfirm();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_spoonReadyToTuneMoon();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_spoonTuneMoon();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_beachCombAvailable();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_canBeachCombHead(string name);	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_beachCombHead(string name);	// Defined in auto_ascend/auto_mr2019.ash
int auto_beachCombFreeUsesLeft();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_beachUseFreeCombs();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_campawayAvailable();	// Defined in auto_ascend/auto_mr2019.ash
boolean auto_campawayGrabBuffs();	// Defined in auto_ascend/auto_mr2019.ash
boolean getSpaceJelly();									//Defined in auto_ascend/auto_mr2017.ash
int horseCost();											//Defined in auto_ascend/auto_mr2017.ash
string horseNormalize(string horseText); // Defined in auto_ascend/auto_mr2017.ash
boolean getHorse(string type);								//Defined in auto_ascend/auto_mr2017.ash
void horseDefault(); // Defined in auto_ascend/auto_mr2017.ash
void horseMaintain(); // Defined in auto_ascend/auto_mr2017.ash
void horseNone(); // Defined in auto_ascend/auto_mr2017.ash
void horseNormal(); // Defined in auto_ascend/auto_mr2017.ash
void horseDark(); // Defined in auto_ascend/auto_mr2017.ash
void horseCrazy(); // Defined in auto_ascend/auto_mr2017.ash
void horsePale(); // Defined in auto_ascend/auto_mr2017.ash
boolean horsePreAdventure(); // Defined in auto_ascend/auto_mr2017.ash
boolean[int] knapsack(int maxw, int n, int[int] weight, float[int] val); // Defined in auto_ascend/auto_util.ash
boolean kgbDiscovery();										//Defined in auto_ascend/auto_mr2017.ash
boolean kgbWasteClicks();									//Defined in auto_ascend/auto_mr2017.ash
boolean kgbTryEffect(effect ef);							//Defined in auto_ascend/auto_mr2017.ash
string kgbKnownEffects();									//Defined in auto_ascend/auto_mr2017.ash
boolean solveKGBMastermind();								//Defined in auto_ascend/auto_mr2017.ash
boolean kgbDial(int dial, int curVal, int target);			//Defined in auto_ascend/auto_mr2017.ash
boolean kgbSetup();											//Defined in auto_ascend/auto_mr2017.ash
int kgb_tabHeight(string page);								//Defined in auto_ascend/auto_mr2017.ash
int kgb_tabCount(string page);								//Defined in auto_ascend/auto_mr2017.ash
boolean kgb_getMartini();									//Defined in auto_ascend/auto_mr2017.ash
boolean kgb_getMartini(string page);						//Defined in auto_ascend/auto_mr2017.ash
boolean kgb_getMartini(string page, boolean dontCare);		//Defined in auto_ascend/auto_mr2017.ash
boolean kgbModifiers(string mod);							//Defined in auto_ascend/auto_mr2017.ash
boolean haveAsdonBuff();											//Defined in auto_ascend/auto_mr2017.ash
boolean asdonBuff(effect goal);								//Defined in auto_ascend/auto_mr2017.ash
boolean asdonBuff(string goal);								//Defined in auto_ascend/auto_mr2017.ash
boolean asdonFeed(item it, int qty);						//Defined in auto_ascend/auto_mr2017.ash
boolean asdonFeed(item it);									//Defined in auto_ascend/auto_mr2017.ash
boolean asdonAutoFeed();									//Defined in auto_ascend/auto_mr2017.ash
boolean asdonAutoFeed(int goal);							//Defined in auto_ascend/auto_mr2017.ash
boolean asdonCanMissile();										//Defined in auto_ascend/auto_mr2017.ash
boolean makeGenieWish(effect eff);							//Defined in auto_ascend/auto_mr2017.ash
boolean canGenieCombat();									//Defined in auto_ascend/auto_mr2017.ash
boolean makeGenieCombat(monster mon, string option);		//Defined in auto_ascend/auto_mr2017.ash
boolean makeGenieCombat(monster mon);						//Defined in auto_ascend/auto_mr2017.ash
boolean makeGeniePocket();									//Defined in auto_ascend/auto_mr2017.ash
boolean spacegateVaccineAvailable();						//Defined in auto_ascend/auto_mr2017.ash
boolean spacegateVaccineAvailable(effect ef);				//Defined in auto_ascend/auto_mr2017.ash
boolean spacegateVaccine(effect ef);						//Defined in auto_ascend/auto_mr2017.ash
int auto_meteorShowersUsed();                     //Defined in auto_ascend/auto_mr2017.ash
int auto_meteorShowersAvailable();                //Defined in auto_ascend/auto_mr2017.ash
int auto_macroMeteoritesUsed();                   //Defined in auto_ascend/auto_mr2017.ash
int auto_macrometeoritesAvailable();              //Defined in auto_ascend/auto_mr2017.ash
int auto_meteoriteAdesUsed();                   //Defined in auto_ascend/auto_mr2017.ash
boolean handleBarrelFullOfBarrels(boolean daily);			//Defined in auto_ascend/auto_util.ash
boolean handleCopiedMonster(item itm);						//Defined in auto_ascend/auto_util.ash
boolean handleCopiedMonster(item itm, string option);		//Defined in auto_ascend/auto_util.ash
boolean handleFamiliar(string type);						//Defined in auto_ascend.ash
boolean powerLevelAdjustment();								//Defined in auto_ascend.ash
boolean handleFaxMonster(monster enemy);					//Defined in auto_ascend/auto_clan.ash
boolean handleFaxMonster(monster enemy, boolean fightIt);	//Defined in auto_ascend/auto_clan.ash
boolean handleFaxMonster(monster enemy, boolean fightIt, string option);//Defined in auto_ascend/auto_clan.ash
boolean handleFaxMonster(monster enemy, string option);		//Defined in auto_ascend/auto_clan.ash
void handleJar();											//Defined in auto_ascend.ash
int handlePulls(int day);									//Defined in auto_ascend.ash
boolean handleSealAncient();								//Defined in auto_ascend/auto_util.ash
boolean handleSealAncient(string option);					//Defined in auto_ascend/auto_util.ash
boolean handleSealNormal(item it);							//Defined in auto_ascend/auto_util.ash
boolean handleSealNormal(item it, string option);			//Defined in auto_ascend/auto_util.ash
boolean handleSealElement(element flavor);					//Defined in auto_ascend/auto_util.ash
boolean handleSealElement(element flavor, string option);	//Defined in auto_ascend/auto_util.ash
boolean handleServant(servant who);							//Defined in auto_ascend/auto_edTheUndying.ash
boolean handleServant(string name);							//Defined in auto_ascend/auto_edTheUndying.ash
item handleSolveThing(boolean[item] poss);					//Defined in auto_ascend/auto_equipment.ash
item handleSolveThing(boolean[item] poss, slot loc);		//Defined in auto_ascend/auto_equipment.ash
item handleSolveThing(item[int] poss);						//Defined in auto_ascend/auto_equipment.ash
item handleSolveThing(item[int] poss, slot loc);			//Defined in auto_ascend/auto_equipment.ash
void handleTracker(item used, string tracker);				//Defined in auto_ascend/auto_util.ash
void handleTracker(monster enemy, item toTrack, string tracker);//Defined in auto_ascend/auto_util.ash
void handleTracker(monster enemy, skill toTrack, string tracker);//Defined in auto_ascend/auto_util.ash
void handleTracker(monster enemy, string toTrack, string tracker);//Defined in auto_ascend/auto_util.ash
void handleTracker(monster enemy, string tracker);			//Defined in auto_ascend/auto_util.ash
void handleTracker(string used, string tracker); //Defined in auto_ascend/auto_util.ash
void handleTracker(item used, string detail, string tracker); //Defined in auto_ascend/auto_util.ash
boolean hasArm(monster enemy);								//Defined in auto_ascend/auto_monsterparts.ash
boolean hasHead(monster enemy);								//Defined in auto_ascend/auto_monsterparts.ash
boolean hasLeg(monster enemy);								//Defined in auto_ascend/auto_monsterparts.ash
boolean hasShieldEquipped();								//Defined in auto_ascend/auto_util.ash
boolean hasTail(monster enemy);								//Defined in auto_ascend/auto_monsterparts.ash
boolean hasTorso(monster enemy);							//Defined in auto_ascend/auto_monsterparts.ash
boolean haveAny(boolean[item] array);						//Defined in auto_ascend/auto_util.ash
boolean have_skills(boolean[skill] array);					//Defined in auto_ascend/auto_util.ash
boolean auto_have_skill(skill sk);							//Defined in auto_ascend/auto_util.ash
boolean haveGhostReport();									//Defined in auto_ascend/auto_mr2016.ash
boolean haveSpleenFamiliar();								//Defined in auto_ascend/auto_util.ash
int howLongBeforeHoloWristDrop();							//Defined in auto_ascend/auto_util.ash
void hr_doBedtime();										//Defined in auto_ascend/auto_heavyrains.ash
boolean hr_handleFamiliar(familiar fam);					//Defined in auto_ascend/auto_heavyrains.ash
void hr_initializeDay(int day);								//Defined in auto_ascend/auto_heavyrains.ash
void hr_initializeSettings();								//Defined in auto_ascend/auto_heavyrains.ash
boolean in_ronin();											//Defined in auto_ascend/auto_util.ash
int inebriety_left();										//Defined in auto_ascend/auto_util.ash
void initializeDay(int day);								//Defined in auto_ascend.ash
void initializeSettings();									//Defined in auto_ascend.ash
boolean stunnable(monster mon);								//Defined in auto_ascend/auto_util.ash
boolean instakillable(monster mon);							//Defined in auto_ascend/auto_util.ash
int[int] intList();											//Defined in auto_ascend/auto_list.ash
int internalQuestStatus(string prop);						//Defined in auto_ascend/auto_util.ash
questRecord questRecord();									//Defined in auto_ascend/auto_util.ash
questRecord[int] questDatabase();							//Defined in auto_ascend/auto_util.ash
int questsLeft();											//Defined in auto_ascend/auto_util.ash
int freeCrafts();											//Defined in auto_ascend/auto_util.ash
boolean is100FamiliarRun();									//Defined in auto_ascend/auto_util.ash
boolean is100FamiliarRun(familiar thisOne);					//Defined in auto_ascend/auto_util.ash
boolean isBanished(monster enemy);							//Defined in auto_ascend/auto_util.ash
boolean isExpectingArrow();									//Defined in auto_ascend/auto_util.ash
boolean isFreeMonster(monster mon);							//Defined in auto_ascend/auto_util.ash
boolean isGalaktikAvailable();								//Defined in auto_ascend/auto_util.ash
boolean isGeneralStoreAvailable();							//Defined in auto_ascend/auto_util.ash
boolean isArmoryAvailable();								//Defined in auto_ascend/auto_util.ash
boolean isGhost(monster mon);								//Defined in auto_ascend/auto_util.ash
boolean isGuildClass();										//Defined in auto_ascend/auto_util.ash
boolean hasTorso();											//Defined in auto_ascend/auto_util.ash
boolean isHermitAvailable();								//Defined in auto_ascend/auto_util.ash
boolean isOverdueArrow();									//Defined in auto_ascend/auto_util.ash
boolean isOverdueDigitize();								//Defined in auto_ascend/auto_util.ash
boolean isProtonGhost(monster mon);							//Defined in auto_ascend/auto_util.ash
boolean isUnclePAvailable();								//Defined in auto_ascend/auto_util.ash
boolean is_avatar_potion(item it);							//Defined in auto_ascend/auto_util.ash
int auto_mall_price(item it);									//Defined in auto_ascend/auto_util.ash
item[int] itemList();										//Defined in auto_ascend/auto_list.ash
int jello_absorbsLeft();									//Defined in auto_ascend/auto_jellonewbie.ash
boolean jello_buySkills();									//Defined in auto_ascend/auto_jellonewbie.ash
void jello_initializeSettings();							//Defined in auto_ascend/auto_jellonewbie.ash
string[item] jello_lister();								//Defined in auto_ascend/auto_jellonewbie.ash
string[item] jello_lister(string goal);						//Defined in auto_ascend/auto_jellonewbie.ash
void jello_startAscension(string page);						//Defined in auto_ascend/auto_jellonewbie.ash
boolean lastAdventureSpecialNC();							//Defined in auto_ascend/auto_util.ash
boolean loopHandler(string turnSetting, string counterSetting, int threshold);//Defined in auto_ascend/auto_util.ash
boolean loopHandler(string turnSetting, string counterSetting, string abortMessage, int threshold);//Defined in auto_ascend/auto_util.ash
boolean loopHandlerDelay(string counterSetting);			//Defined in auto_ascend/auto_util.ash
boolean loopHandlerDelay(string counterSetting, int threshold);//Defined in auto_ascend/auto_util.ash
boolean loopHandlerDelayAll();								// Defined in auto_ascend/auto_util.ash
string reverse(string s);									// Defined in auto_ascend/auto_util.ash
boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem);//Defined in auto_ascend/auto_mr2017.ash
boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem, string option);//Defined in auto_ascend/auto_mr2017.ash
boolean pantogramPants();									//Defined in auto_ascend/auto_mr2017.ash
boolean pantogramPants(stat st, element el, int hpmp, int meatItemStats, int misc);//Defined in auto_ascend/auto_mr2017.ash
int lumberCount();											//Defined in auto_ascend/auto_util.ash
boolean makePerfectBooze();									//Defined in auto_ascend/auto_cooking.ash
void makeStartingSmiths();									//Defined in auto_ascend/auto_equipment.ash
int maxSealSummons();										//Defined in auto_ascend/auto_util.ash
void maximize_hedge();										//Defined in auto_ascend.ash
boolean mayo_acquireMayo(item it);							//Defined in auto_ascend/auto_mr2015.ash
int ns_crowd1();											//Defined in auto_ascend/auto_util.ash
stat ns_crowd2();											//Defined in auto_ascend/auto_util.ash
element ns_crowd3();										//Defined in auto_ascend/auto_util.ash
element ns_hedge1();										//Defined in auto_ascend/auto_util.ash
element ns_hedge2();										//Defined in auto_ascend/auto_util.ash
element ns_hedge3();										//Defined in auto_ascend/auto_util.ash
int numPirateInsults();										//Defined in auto_ascend/auto_util.ash
monster ocrs_helper(string page);							//Defined in auto_ascend/auto_combat.ash
boolean ocrs_initializeSettings();							//Defined in auto_ascend/auto_summerfun.ash
boolean ocrs_postCombatResolve();							//Defined in auto_ascend/auto_summerfun.ash
boolean ocrs_postHelper();									//Defined in auto_ascend/auto_summerfun.ash
void oldPeoplePlantStuff();									//Defined in auto_ascend/auto_floristfriar.ash
boolean organsFull();										//Defined in auto_ascend/auto_util.ash
boolean ovenHandle();										//Defined in auto_ascend/auto_util.ash
boolean pete_buySkills();									//Defined in auto_ascend/auto_sneakypete.ash
void pete_initializeDay(int day);							//Defined in auto_ascend/auto_sneakypete.ash
void pete_initializeSettings();								//Defined in auto_ascend/auto_sneakypete.ash
boolean picky_buyskills();									//Defined in auto_ascend/auto_picky.ash
void picky_initializeSettings();							//Defined in auto_ascend/auto_picky.ash
void picky_pulls();											//Defined in auto_ascend/auto_picky.ash
void picky_startAscension();								//Defined in auto_ascend/auto_picky.ash
skill preferredLibram();									//Defined in auto_ascend/auto_util.ash
location provideAdvPHPZone();								//Defined in auto_ascend/auto_util.ash
boolean providePlusCombat(int amt);							//Defined in auto_ascend/auto_util.ash
boolean providePlusCombat(int amt, boolean doEquips);		//Defined in auto_ascend/auto_util.ash
boolean providePlusNonCombat(int amt);						//Defined in auto_ascend/auto_util.ash
boolean providePlusNonCombat(int amt, boolean doEquips);	//Defined in auto_ascend/auto_util.ash
boolean acquireCombatMods(int amt);							//Defined in auto_ascend/auto_util.ash
boolean acquireCombatMods(int amt, boolean doEquips);		//Defined in auto_ascend/auto_util.ash
void pullAll(item it);										//Defined in auto_ascend/auto_util.ash
void pullAndUse(item it, int uses);							//Defined in auto_ascend/auto_util.ash
boolean pullXWhenHaveY(item it, int howMany, int whenHave);	//Defined in auto_ascend/auto_util.ash
int pullsNeeded(string data);								//Defined in auto_ascend.ash
boolean pulverizeThing(item it);							//Defined in auto_ascend/auto_util.ash
boolean rainManSummon(string monsterName, boolean copy, boolean wink);//Defined in auto_ascend/auto_heavyrains.ash
boolean rainManSummon(string monsterName, boolean copy, boolean wink, string option);//Defined in auto_ascend/auto_heavyrains.ash
boolean registerCombat(item it);							//Defined in auto_ascend/auto_combat.ash
boolean registerCombat(skill sk);							//Defined in auto_ascend/auto_combat.ash
boolean registerCombat(string action);						//Defined in auto_ascend/auto_combat.ash
void replaceBaselineAcc3();									//Defined in auto_ascend/auto_equipment.ash
boolean restoreAllSettings();								//Defined in auto_ascend/auto_util.ash
boolean restoreSetting(string setting);						//Defined in auto_ascend/auto_util.ash
boolean restore_property(string setting, string source);	//Defined in auto_ascend/auto_util.ash
boolean rethinkingCandy(effect acquire);					//Defined in auto_ascend/auto_mr2016.ash
boolean rethinkingCandy(effect acquire, boolean simulate);	//Defined in auto_ascend/auto_mr2016.ash
boolean rethinkingCandyList();								//Defined in auto_ascend/auto_mr2016.ash
boolean routineRainManHandler();							//Defined in auto_ascend/auto_heavyrains.ash
string runChoice(string page_text);							//Defined in auto_ascend/auto_util.ash
string safeString(item input);								//Defined in auto_ascend/auto_util.ash
string safeString(monster input);							//Defined in auto_ascend/auto_util.ash
string safeString(skill input);								//Defined in auto_ascend/auto_util.ash
string safeString(string input);							//Defined in auto_ascend/auto_util.ash
boolean setAdvPHPFlag();									//Defined in auto_ascend/auto_util.ash
boolean set_property_ifempty(string setting, string change);//Defined in auto_ascend/auto_util.ash
boolean settingFixer();										//Defined in auto_ascend/auto_deprecation.ash
void shrugAT();												//Defined in auto_ascend/auto_util.ash
void shrugAT(effect anticipated);							//Defined in auto_ascend/auto_util.ash
boolean snojoFightAvailable();								//Defined in auto_ascend/auto_mr2016.ash
int solveCookie();											//Defined in auto_ascend/auto_util.ash
int spleen_left();											//Defined in auto_ascend/auto_util.ash
void standard_initializeSettings();							//Defined in auto_ascend/auto_standard.ash
void standard_pulls();										//Defined in auto_ascend/auto_standard.ash
boolean startArmorySubQuest();								//Defined in auto_ascend/auto_util.ash
boolean startGalaktikSubQuest();							//Defined in auto_ascend/auto_util.ash
boolean startMeatsmithSubQuest();							//Defined in auto_ascend/auto_util.ash
string statCard();											//Defined in auto_ascend/auto_util.ash
int stomach_left();											//Defined in auto_ascend/auto_util.ash
boolean theSource_buySkills();								//Defined in auto_ascend/auto_theSource.ash
boolean theSource_initializeSettings();						//Defined in auto_ascend/auto_theSource.ash
boolean theSource_oracle();									//Defined in auto_ascend/auto_theSource.ash
boolean timeSpinnerAdventure();								//Defined in auto_ascend/auto_mr2016.ash
boolean timeSpinnerAdventure(string option);				//Defined in auto_ascend/auto_mr2016.ash
boolean timeSpinnerCombat(monster goal);					//Defined in auto_ascend/auto_mr2016.ash
boolean timeSpinnerCombat(monster goal, string option);		//Defined in auto_ascend/auto_mr2016.ash
boolean timeSpinnerConsume(item goal);						//Defined in auto_ascend/auto_mr2016.ash
boolean timeSpinnerGet(string goal);						//Defined in auto_ascend/auto_mr2016.ash
void tootGetMeat();											//Defined in auto_ascend/auto_util.ash
boolean tophatMaker();										//Defined in auto_ascend.ash
boolean trackingSplitterFixer(string oldSetting, int day, string newSetting);//Defined in auto_ascend/auto_deprecation.ash
void trickMafiaAboutFlorist();								//Defined in auto_ascend/auto_floristfriar.ash
string trim(string input);									//Defined in auto_ascend/auto_util.ash
string tryBeerPong();										//Defined in auto_ascend/auto_util.ash
boolean tryCookies();										//Defined in auto_ascend/auto_cooking.ash
boolean tryPantsEat();										//Defined in auto_ascend/auto_cooking.ash
int turkeyBooze();											//Defined in auto_ascend/auto_util.ash
boolean uneffect(effect toRemove);							//Defined in auto_ascend/auto_util.ash
boolean useCocoon();										//Defined in auto_ascend/auto_util.ash
boolean use_barrels();										//Defined in auto_ascend/auto_util.ash
boolean needStarKey();										//Defined in auto_ascend/auto_util.ash
boolean needDigitalKey();									//Defined in auto_ascend/auto_util.ash
int whitePixelCount();										//Defined in auto_ascend/auto_util.ash
boolean careAboutDrops(monster mon);						//Defined in auto_ascend/auto_util.ash
boolean volcano_bunkerJob();								//Defined in auto_ascend/auto_elementalPlanes.ash
boolean volcano_lavaDogs();									//Defined in auto_ascend/auto_elementalPlanes.ash
boolean warAdventure();										//Defined in auto_ascend.ash
boolean haveWarOutfit();									//Defined in auto_ascend.ash
boolean warOutfit();										//Defined in auto_ascend.ash
item whatHiMein();											//Defined in auto_ascend/auto_util.ash
effect whatStatSmile();										//Defined in auto_ascend/auto_util.ash
void woods_questStart();									//Defined in auto_ascend/auto_util.ash
boolean xiblaxian_makeStuff();								//Defined in auto_ascend/auto_mr2014.ash
string yellowRayCombatString(monster target, boolean inCombat); //Defined in auto_ascend/auto_util.ash
string yellowRayCombatString(monster target);					//Defined in auto_ascend/auto_util.ash
string yellowRayCombatString();								//Defined in auto_ascend/auto_util.ash
boolean adjustForYellowRay(string combat_string); //Defined in auto_ascend/auto_util.ash
boolean adjustForYellowRayIfPossible(monster target); //Defined in auto_ascend/auto_util.ash
boolean adjustForYellowRayIfPossible(); //Defined in auto_ascend/auto_util.ash
string banisherCombatString(monster enemy, location loc, boolean inCombat); //Defined in auto_ascend/auto_util.ash
string banisherCombatString(monster enemy, location loc);	//Defined in auto_ascend/auto_util.ash
boolean[string] auto_banishesUsedAt(location loc); // Defined in auto_ascend/auto_util.ash
boolean auto_wantToBanish(monster enemy, location loc); // Defined in auto_ascend/auto_util.ash
boolean auto_wantToSniff(monster enemy, location loc); // Defined in auto_ascend/auto_util.ash
boolean auto_wantToYellowRay(monster enemy, location loc); // Defined in auto_ascend/auto_util.ash
int total_items(boolean [item] items); // Defined in auto_ascend/auto_util.ash
boolean zoneCombat(location loc);							//Defined in auto_ascend/auto_util.ash
boolean zoneItem(location loc);								//Defined in auto_ascend/auto_util.ash
boolean zoneMeat(location loc);								//Defined in auto_ascend/auto_util.ash
boolean zoneNonCombat(location loc);						//Defined in auto_ascend/auto_util.ash
boolean declineTrades();									//Defined in auto_ascend/auto_util.ash
boolean auto_beta(); //Defined in auto_ascend/auto_util.ash
void auto_interruptCheck(); //Defined in auto_ascend/auto_util.ash

//From Zlib Stuff
record kmailObject {
	int id;                   // message id
	string type;              // possible values observed thus far: normal, giftshop
	int fromid;               // sender\'s playerid (0 for npcs)
	int azunixtime;           // KoL server\'s unix timestamp
	string message;           // message (not including items/meat)
	int[item] items;          // items included in the message
	int meat;                 // meat included in the message
	string fromname;          // sender\'s playername
	string localtime;         // your local time according to your KoL account, human-readable string
};
boolean auto_deleteMail(kmailObject msg);						//Defined in auto_ascend/auto_util.ash

boolean auto_is_valid(item it); //Defined in auto_ascend/auto_util.ash
boolean auto_is_valid(familiar fam); //Defined in auto_ascend/auto_util.ash
boolean auto_is_valid(skill sk); //Defined in auto_ascend/auto_util.ash

boolean auto_debug_print(string s, string color); //Defined in auto_ascend/auto_util.ash
boolean auto_debug_print(string s); //Defined in auto_ascend/auto_util.ash

boolean auto_can_equip(item it); //Defined in auto_ascend/auto_util.ash
boolean auto_can_equip(item it, slot s); //Defined in auto_ascend/auto_util.ash

boolean auto_check_conditions(string conds); //Defined in auto_ascend/auto_util.ash

boolean [monster] auto_getMonsters(string category); //Defined in auto_ascend/auto_util.ash

boolean auto_badassBelt(); //Defined in auto_ascend/auto_util.ash

//Dump from accessory scripts.
void handlePreAdventure();									//Defined in auto_pre_adv.ash
void handlePreAdventure(location place);					//Defined in auto_pre_adv.ash

void handlePostAdventure();									//Defined in auto_post_adv.ash

void handleKingLiberation();								//Defined in auto_king.ash
boolean pullPVPJunk();										//Defined in auto_king.ash

boolean auto_acquireKeycards();								//Defined in auto_ascend/auto_aftercore.ash
boolean auto_aftercore();										//Defined in auto_ascend/auto_aftercore.ash
boolean auto_aftercore(int leave);							//Defined in auto_ascend/auto_aftercore.ash
boolean auto_ascendIntoCS();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_ascendIntoBond();								//Defined in auto_ascend/auto_aftercore.ash
boolean auto_cheeseAftercore(int leave);						//Defined in auto_ascend/auto_aftercore.ash
boolean auto_cheesePostCS();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_cheesePostCS(int leave);							//Defined in auto_ascend/auto_aftercore.ash
void auto_combatTest();										//Defined in auto_ascend/auto_aftercore.ash
boolean auto_dailyDungeon();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_doCS();											//Defined in auto_ascend/auto_aftercore.ash
boolean auto_doWalford();										//Defined in auto_ascend/auto_aftercore.ash
boolean auto_fingernail();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_goreBucket();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_guildClown();									//Defined in auto_ascend/auto_aftercore.ash
item auto_guildEpicWeapon();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_guildUnlock();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_junglePuns();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_jungleSandwich();								//Defined in auto_ascend/auto_aftercore.ash
boolean auto_lubeBarfMountain();								//Defined in auto_ascend/auto_aftercore.ash
boolean auto_mtMolehill();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_nastyBears();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_nemesisCave();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_nemesisIsland();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_packOfSmokes();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_racismReduction();								//Defined in auto_ascend/auto_aftercore.ash
boolean auto_sexismReduction();								//Defined in auto_ascend/auto_aftercore.ash
boolean auto_sloppySecondsDiner();							//Defined in auto_ascend/auto_aftercore.ash
boolean auto_toxicGlobules();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_toxicMascot();									//Defined in auto_ascend/auto_aftercore.ash
boolean auto_trashNet();										//Defined in auto_ascend/auto_aftercore.ash
string simpleCombatFilter(int round, string opp, string text);//Defined in auto_ascend/auto_aftercore.ash


boolean LM_bond();											//Defined in auto_ascend/auto_bondmember.ash
boolean bond_buySkills();									//Defined in auto_ascend/auto_bondmember.ash
boolean bond_initializeSettings();							//Defined in auto_ascend/auto_bondmember.ash
item[int] bondDrinks();										//Defined in auto_ascend/auto_bondmember.ash
void bond_initializeDay(int day);							//Defined in auto_ascend/auto_bondmember.ash


void majora_initializeSettings();							//Defined in auto_ascend/auto_majora.ash
void majora_initializeDay(int day);							//Defined in auto_ascend/auto_majora.ash
boolean LM_majora();										//Defined in auto_ascend/auto_majora.ash

void digimon_initializeSettings();							//Defined in auto_ascend/auto_digimon.ash
void digimon_initializeDay(int day);						//Defined in auto_ascend/auto_digimon.ash
boolean digimon_makeTeam();									//Defined in auto_ascend/auto_digimon.ash
boolean LM_digimon();										//Defined in auto_ascend/auto_digimon.ash
boolean digimon_autoAdv(int num, location loc, string option);//Defined in auto_ascend/auto_digimon.ash

void glover_initializeSettings();							//Defined in auto_ascend/auto_glover.ash
void glover_initializeDay(int day);							//Defined in auto_ascend/auto_glover.ash
boolean glover_usable(string it);							//Defined in auto_ascend/auto_glover.ash
boolean LM_glover();										//Defined in auto_ascend/auto_glover.ash

boolean groundhogSafeguard();								//Defined in auto_ascend/auto_groundhog.ash
void groundhog_initializeSettings();						//Defined in auto_ascend/auto_groundhog.ash
boolean canGroundhog(location loc);							//Defined in auto_ascend/auto_groundhog.ash
boolean groundhogAbort(location loc);						//Defined in auto_ascend/auto_groundhog.ash
boolean LM_groundhog();										//Defined in auto_ascend/auto_groundhog.ash

void bat_startAscension(); // Defined in auto_ascend/auto_batpath.ash
void bat_initializeSession(); // Defined in auto_ascend/auto_batpath.ash
void bat_terminateSession(); // Defined in auto_ascend/auto_batpath.ash
void bat_initializeDay(int day); // Defined in auto_ascend/auto_batpath.ash
int bat_maxHPCost(skill sk); // Defined in auto_ascend/auto_batpath.ash
int bat_baseHP(); // Defined in auto_ascend/auto_batpath.ash
int bat_remainingBaseHP(); // Defined in auto_ascend/auto_batpath.ash
boolean[skill] bat_desiredSkills(int hpLeft); // Defined in auto_ascend/auto_batpath.ash
boolean[skill] bat_desiredSkills(int hpLeft, boolean[skill] requiredSkills); // Defined in auto_ascend/auto_batpath.ash
void bat_reallyPickSkills(int hpLeft); // Defined in auto_ascend/auto_batpath.ash
void bat_reallyPickSkills(int hpLeft, boolean[skill] requiredSkills); // Defined in auto_ascend/auto_batpath.ash
boolean bat_shouldPickSkills(int hpLeft); // Defined in auto_ascend/auto_batpath.ash
boolean bat_shouldEnsorcel(monster m); // Defined in auto_ascend/auto_batpath.ash
int bat_creatable_amount(item desired); // Defined in auto_ascend/auto_batpath.ash
boolean bat_multicraft(string mode, boolean [item] options); // Defined in auto_ascend/auto_batpath.ash
boolean bat_cook(item desired); // Defined in auto_ascend/auto_batpath.ash
boolean bat_consumption(); // Defined in auto_ascend/auto_batpath.ash
boolean bat_skillValid(skill sk); // Defined in auto_ascend/auto_batpath.ash
boolean bat_tryBloodBank(); // Defined in auto_ascend/auto_batpath.ash
boolean bat_wantHowl(location loc); // Defined in auto_ascend/auto_batpath.ash
void bat_formNone(); // Defined in auto_ascend/auto_batpath.ash
void bat_formWolf(); // Defined in auto_ascend/auto_batpath.ash
void bat_formMist(); // Defined in auto_ascend/auto_batpath.ash
void bat_formBats(); // Defined in auto_ascend/auto_batpath.ash
void bat_clearForms(); // Defined in auto_ascend/auto_batpath.ash
boolean bat_switchForm(effect form); // Defined in auto_ascend/auto_batpath.ash
boolean bat_formPreAdventure(); // Defined in auto_ascend/auto_batpath.ash
boolean LM_batpath(); // Defined in auto_ascend/auto_batpath.ash
element currentFlavour(); // Defined in auto_ascend/auto_util.ash
void resetFlavour(); // Defined in auto_ascend/auto_util.ash
boolean setFlavour(element ele); // Defined in auto_ascend/auto_util.ash
boolean executeFlavour(); // Defined in auto_ascend/auto_util.ash
boolean autoFlavour(location place); // Defined in auto_ascend/auto_util.ash
int auto_reserveAmount(item it); // Defined in auto_ascend/auto_util.ash
int auto_reserveCraftAmount(item it); // Defined in auto_ascend/auto_util.ash
float mp_regen(); // Defined in auto_ascend/auto_util.ash

//Record from auto_ascend/auto_zone.ash
record generic_t
{
	boolean _error;
	boolean _boolean;
	int _int;
	float _float;
	string _string;
	item _item;
	location _location;
	class _class;
	stat _stat;
	skill _skill;
	effect _effect;
	familiar _familiar;
	slot _slot;
	monster _monster;
	element _element;
	phylum _phylum;
};
generic_t zone_needItem(location loc);						//Defined in auto_ascend/auto_zone.ash
generic_t zone_difficulty(location loc);					//Defined in auto_ascend/auto_zone.ash
generic_t zone_combatMod(location loc);						//Defined in auto_ascend/auto_zone.ash
generic_t zone_delay(location loc);							//Defined in auto_ascend/auto_zone.ash
generic_t zone_available(location loc);						//Defined in auto_ascend/auto_zone.ash
location[int] zone_list();									//Defined in auto_ascend/auto_zone.ash
int[location] zone_delayable();								//Defined in auto_ascend/auto_zone.ash
boolean zone_isAvailable(location loc);						//Defined in auto_ascend/auto_zone.ash
location[int] zones_available();							//Defined in auto_ascend/auto_zone.ash
monster[int] mobs_available();								//Defined in auto_ascend/auto_zone.ash
item[int] drops_available();								//Defined in auto_ascend/auto_zone.ash
item[int] hugpocket_available();							//Defined in auto_ascend/auto_zone.ash
