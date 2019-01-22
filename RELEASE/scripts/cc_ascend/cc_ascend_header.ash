script "cc_ascend_header.ash"

//	This is the primary (or will be) header file for cc_ascend.
//	All potentially cross-dependent functions should be defined here such that we can use them from
//	other scripts without the circular dependency issue. Thanks Ultibot for the advice regarding this.
//	Documentation can go here too, I suppose.
//	All functions that are defined outside of cc_ascend must include a note regarding where they come from
//		Seriously, it\'s rude not to.

//	Question Functions
//	Denoted as L<classification>[<path>]_<name>:
//		<classification>: Level to be used (Numeric, X for any). A for entire ascension.
//		<classification>: M for most of ascension, "sc" for Seal Clubber only
//		<path>: [optional] indicates path to be used in. "ed" for ed, "cs" for community service
//			Usually separated with _
boolean LA_cs_communityService();				//Defined in cc_ascend/cc_community_service.ash
boolean LM_edTheUndying();						//Defined in cc_ascend/cc_edTheUndying.ash

boolean LX_desertAlternate();
boolean LX_handleSpookyravenNecklace();
boolean LX_handleSpookyravenFirstFloor();
boolean LX_phatLootToken();
boolean LX_islandAccess();
boolean LX_fancyOilPainting();
boolean LX_setBallroomSong();
boolean LX_pirateOutfit();
boolean LX_pirateInsults();
boolean LX_pirateBlueprint();
boolean LX_pirateBeerPong();
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


//*********** Section of stuff moved into cc_optionals.ash *******************/
boolean LX_artistQuest();
boolean LX_dinseylandfillFunbucks();
//*********** End of stuff moved into cc_optionals.ash ***********************/

boolean Lsc_flyerSeals();

boolean L0_handleRainDoh();

boolean L1_ed_island();							//Defined in cc_ascend/cc_edTheUndying.ash
boolean L1_ed_dinsey();							//Defined in cc_ascend/cc_edTheUndying.ash
boolean L1_ed_island(int dickstabOverride);		//Defined in cc_ascend/cc_edTheUndying.ash
boolean L1_ed_islandFallback();					//Defined in cc_ascend/cc_edTheUndying.ash
boolean L1_HRstart();							//Defined in cc_ascend/cc_heavyrains.ash
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
boolean L12_nunsTrickGlandGet();
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
//	They are all defined in cc_ascend/cc_adventure.ash
boolean ccAdv();
boolean ccAdv(location loc);								//num is ignored
boolean ccAdv(int num, location loc);						//num is ignored
boolean ccAdv(int num, location loc, string option);		//num is ignored
boolean ccAdv(location loc, string option);
boolean ccAdvBypass(string url);
boolean ccAdvBypass(string url, string option);
boolean ccAdvBypass(string url, location loc);
boolean ccAdvBypass(string url, location loc, string option);
#boolean ccAdvBypass(string[int] url);
#boolean ccAdvBypass(string[int] url, string option);
#boolean ccAdvBypass(string[int] url, location loc);
boolean ccAdvBypass(int becauseStringIntIsSomehowJustString, string[int] url, location loc, string option);
boolean ccAdvBypass(int snarfblat);
boolean ccAdvBypass(int snarfblat, string option);
boolean ccAdvBypass(int snarfblat, location loc);
boolean ccAdvBypass(int snarfblat, location loc, string option);

//
//	Secondary adventuring functions
//	They are all defined in cc_ascend/cc_adventure.ash
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
//	External cc_ascend.ash functions, indicate where they come from.
//
//


//Do we have a some item either equipped or in inventory (not closet or hagnk\'s.
boolean possessEquipment(item equipment);		//Defined in cc_ascend/cc_equipment.ash

//Do Bjorn stuff
boolean handleBjornify(familiar fam);			//Defined in cc_ascend/cc_equipment.ash

//Remove +NC or +C equipment
void removeNonCombat();							//Defined in cc_ascend/cc_equipment.ash
void removeCombat();							//Defined in cc_ascend/cc_equipment.ash

//Wrapper for get_campground(), primarily deals with the oven issue in Ed.
//Also uses Garden item as identifier for the garden in addition to what get_campground() does
int[item] cc_get_campground();					//Defined in cc_ascend/cc_util.ash


//Returns how many Hero Keys and Phat Loot tokens we have.
//effective count (with malware) vs true count.
int towerKeyCount(boolean effective);			//Defined in cc_ascend/cc_util.ash
int towerKeyCount();							//Defined in cc_ascend/cc_util.ash


//Uses Daily Dungeon Malware to get Phat Loot.
boolean LX_malware();							//Defined in cc_ascend.ash

//Determines if we need ore for the trapper or not.
boolean needOre();								//Defined in cc_ascend/cc_util.ash

//Wrapper for my_path(), in case there are delays in Mafia translating path values
string cc_my_path();							//Defined in cc_ascend/cc_util.ash

//Item disambiguation functions
boolean hasSpookyravenLibraryKey();				//Defined in cc_ascend/cc_util.ash
boolean hasILoveMeVolI();						//Defined in cc_ascend/cc_util.ash
boolean useILoveMeVolI();						//Defined in cc_ascend/cc_util.ash


//Are we expecting a Protonic Accelerator Pack ghost report?
boolean expectGhostReport();					//Defined in cc_ascend/cc_mr2016.ash


//Quest Object information, meant for "normal" runs but could technically be expanded or altered.
record questRecord
{
	string prop;					// cc_ascend property reflecting the quest
	string mprop;					// Mafia property reflecting the quest, if applicable
	int type;						// 0 = main line quest, 1 = side quest (allowing for other options)
	string func;					// cc_ascend function that attempts this quest.
};


//Large pile dump.
boolean L11_ed_mauriceSpookyraven();						//Defined in cc_ascend/cc_edTheUndying.ash
boolean L12_sonofaPrefix();									//Defined in cc_ascend.ash
boolean L9_ed_chasmBuild();									//Defined in cc_ascend/cc_edTheUndying.ash
boolean L9_ed_chasmBuildClover(int need);					//Defined in cc_ascend/cc_edTheUndying.ash
boolean L9_ed_chasmStart();									//Defined in cc_ascend/cc_edTheUndying.ash
boolean LM_boris();											//Defined in cc_ascend/cc_boris.ash
boolean LM_fallout();										//Defined in cc_ascend/cc_fallout.ash
boolean LM_jello();											//Defined in cc_ascend/cc_jellonewbie.ash
boolean LM_pete();											//Defined in cc_ascend/cc_sneakypete.ash
boolean LX_ghostBusting();									//Defined in cc_ascend/cc_mr2016.ash
boolean LX_theSource();										//Defined in cc_ascend/cc_theSource.ash
familiar[int] List();										//Defined in cc_ascend/cc_list.ash
effect[int] List(boolean[effect] data);						//Defined in cc_ascend/cc_list.ash
familiar[int] List(boolean[familiar] data);					//Defined in cc_ascend/cc_list.ash
int[int] List(boolean[int] data);							//Defined in cc_ascend/cc_list.ash
item[int] List(boolean[item] data);							//Defined in cc_ascend/cc_list.ash
effect[int] List(effect[int] data);							//Defined in cc_ascend/cc_list.ash
familiar[int] List(familiar[int] data);						//Defined in cc_ascend/cc_list.ash
int[int] List(int[int] data);								//Defined in cc_ascend/cc_list.ash
item[int] List(item[int] data);								//Defined in cc_ascend/cc_list.ash
effect[int] ListErase(effect[int] list, int index);			//Defined in cc_ascend/cc_list.ash
familiar[int] ListErase(familiar[int] list, int index);		//Defined in cc_ascend/cc_list.ash
int[int] ListErase(int[int] list, int index);				//Defined in cc_ascend/cc_list.ash
item[int] ListErase(item[int] list, int index);				//Defined in cc_ascend/cc_list.ash
int ListFind(effect[int] list, effect what);				//Defined in cc_ascend/cc_list.ash
int ListFind(effect[int] list, effect what, int idx);		//Defined in cc_ascend/cc_list.ash
int ListFind(familiar[int] list, familiar what);			//Defined in cc_ascend/cc_list.ash
int ListFind(familiar[int] list, familiar what, int idx);	//Defined in cc_ascend/cc_list.ash
int ListFind(int[int] list, int what);						//Defined in cc_ascend/cc_list.ash
int ListFind(int[int] list, int what, int idx);				//Defined in cc_ascend/cc_list.ash
int ListFind(item[int] list, item what);					//Defined in cc_ascend/cc_list.ash
int ListFind(item[int] list, item what, int idx);			//Defined in cc_ascend/cc_list.ash
effect[int] ListInsert(effect[int] list, effect what);		//Defined in cc_ascend/cc_list.ash
familiar[int] ListInsert(familiar[int] list, familiar what);//Defined in cc_ascend/cc_list.ash
int[int] ListInsert(int[int] list, int what);				//Defined in cc_ascend/cc_list.ash
item[int] ListInsert(item[int] list, item what);			//Defined in cc_ascend/cc_list.ash
effect[int] ListInsertAt(effect[int] list, effect what, int idx);//Defined in cc_ascend/cc_list.ash
familiar[int] ListInsertAt(familiar[int] list, familiar what, int idx);//Defined in cc_ascend/cc_list.ash
int[int] ListInsertAt(int[int] list, int what, int idx);	//Defined in cc_ascend/cc_list.ash
item[int] ListInsertAt(item[int] list, item what, int idx);	//Defined in cc_ascend/cc_list.ash
effect[int] ListInsertFront(effect[int] list, effect what);	//Defined in cc_ascend/cc_list.ash
familiar[int] ListInsertFront(familiar[int] list, familiar what);//Defined in cc_ascend/cc_list.ash
int[int] ListInsertFront(int[int] list, int what);			//Defined in cc_ascend/cc_list.ash
item[int] ListInsertFront(item[int] list, item what);		//Defined in cc_ascend/cc_list.ash
effect[int] ListInsertInorder(effect[int] list, effect what);//Defined in cc_ascend/cc_list.ash
familiar[int] ListInsertInorder(familiar[int] list, familiar what);//Defined in cc_ascend/cc_list.ash
int[int] ListInsertInorder(int[int] list, int what);		//Defined in cc_ascend/cc_list.ash
item[int] ListInsertInorder(item[int] list, item what);		//Defined in cc_ascend/cc_list.ash
string ListOutput(effect[int] list);						//Defined in cc_ascend/cc_list.ash
string ListOutput(familiar[int] list);						//Defined in cc_ascend/cc_list.ash
string ListOutput(int[int] list);							//Defined in cc_ascend/cc_list.ash
string ListOutput(item[int] list);							//Defined in cc_ascend/cc_list.ash
effect[int] ListRemove(effect[int] list, effect what);		//Defined in cc_ascend/cc_list.ash
effect[int] ListRemove(effect[int] list, effect what, int idx);//Defined in cc_ascend/cc_list.ash
familiar[int] ListRemove(familiar[int] list, familiar what);//Defined in cc_ascend/cc_list.ash
familiar[int] ListRemove(familiar[int] list, familiar what, int idx);//Defined in cc_ascend/cc_list.ash
int[int] ListRemove(int[int] list, int what);				//Defined in cc_ascend/cc_list.ash
int[int] ListRemove(int[int] list, int what, int idx);		//Defined in cc_ascend/cc_list.ash
item[int] ListRemove(item[int] list, item what);			//Defined in cc_ascend/cc_list.ash
item[int] ListRemove(item[int] list, item what, int idx);	//Defined in cc_ascend/cc_list.ash
location ListOutput(location[int] list);					//Defined in cc_ascend/cc_list.ash
location[int] locationList();								//Defined in cc_ascend/cc_list.ash
location[int] List(boolean[location] data);					//Defined in cc_ascend/cc_list.ash
location[int] List(location[int] data);						//Defined in cc_ascend/cc_list.ash
location[int] ListRemove(location[int] list, location what);//Defined in cc_ascend/cc_list.ash
location[int] ListRemove(location[int] list, location what, int idx);//Defined in cc_ascend/cc_list.ash
location[int] ListErase(location[int] list, int index);		//Defined in cc_ascend/cc_list.ash
location[int] ListInsertFront(location[int] list, location what);//Defined in cc_ascend/cc_list.ash
location[int] ListInsert(location[int] list, location what);//Defined in cc_ascend/cc_list.ash
location[int] ListInsertAt(location[int] list, location what, int idx);//Defined in cc_ascend/cc_list.ash
location[int] ListInsertInorder(location[int] list, location what);//Defined in cc_ascend/cc_list.ash
int ListFind(location[int] list, location what);			//Defined in cc_ascend/cc_list.ash
int ListFind(location[int] list, location what, int idx);	//Defined in cc_ascend/cc_list.ash
location ListOutput(location[int] list);					//Defined in cc_ascend/cc_list.ash
int [item] cc_get_campground();								//Defined in cc_ascend/cc_util.ash
boolean basicAdjustML();									//Defined in cc_ascend/cc_util.ash
boolean beatenUpResolution();								//Defined in cc_ascend.ash
boolean adventureFailureHandler();							//Defined in cc_ascend.ash
boolean councilMaintenance();								//Defined in cc_ascend.ash
boolean [location] get_floundry_locations();				//Defined in cc_ascend/cc_clan.ash
int[item] cc_get_clan_lounge();								//Defined in cc_ascend/cc_clan.ash
boolean acquireMP(int goal);								//Defined in cc_ascend/cc_util.ash
boolean acquireMP(int goal, boolean buyIt);					//Defined in cc_ascend/cc_util.ash
boolean acquireGumItem(item it);							//Defined in cc_ascend/cc_util.ash
boolean acquireHermitItem(item it);							//Defined in cc_ascend/cc_util.ash
int cloversAvailable();									//Defined in cc_ascend/cc_util.ash
boolean cloverUsageInit();									//Defined in cc_ascend/cc_util.ash
boolean cloverUsageFinish();								//Defined in cc_ascend/cc_util.ash
boolean adjustEdHat(string goal);							//Defined in cc_ascend/cc_edTheUndying.ash
int amountTurkeyBooze();									//Defined in cc_ascend/cc_util.ash
boolean awol_buySkills();									//Defined in cc_ascend/cc_awol.ash
void awol_helper(string page);								//Defined in cc_ascend/cc_combat.ash
boolean canSurvive(float mult, int add);					//Defined in cc_ascend/cc_combat.ash
boolean canSurvive(float mult);								//Defined in cc_ascend/cc_combat.ash
boolean awol_initializeSettings();							//Defined in cc_ascend/cc_awol.ash
void awol_useStuff();										//Defined in cc_ascend/cc_awol.ash
effect awol_walkBuff();										//Defined in cc_ascend/cc_awol.ash
boolean backupSetting(string setting, string newValue);		//Defined in cc_ascend/cc_util.ash
int[monster] banishedMonsters();							//Defined in cc_ascend/cc_util.ash
boolean beehiveConsider();									//Defined in cc_ascend/cc_util.ash
string beerPong(string page);								//Defined in cc_ascend/cc_util.ash
int estimatedTurnsLeft();									//Defined in cc_ascend/cc_util.ash
boolean summonMonster();									//Defined in cc_ascend/cc_util.ash
boolean summonMonster(string option);						//Defined in cc_ascend/cc_util.ash
boolean boris_buySkills();									//Defined in cc_ascend/cc_boris.ash
void boris_initializeDay(int day);							//Defined in cc_ascend/cc_boris.ash
void boris_initializeSettings();							//Defined in cc_ascend/cc_boris.ash
boolean buffMaintain(effect buff, int mp_min, int casts, int turns);//Defined in cc_ascend/cc_util.ash
boolean buffMaintain(item source, effect buff, int uses, int turns);//Defined in cc_ascend/cc_util.ash
boolean buffMaintain(skill source, effect buff, int mp_min, int casts, int turns);//Defined in cc_ascend/cc_util.ash
boolean buyUpTo(int num, item it);							//Defined in cc_ascend/cc_util.ash
boolean buyUpTo(int num, item it, int maxprice);			//Defined in cc_ascend/cc_util.ash
boolean buy_item(item it, int quantity, int maxprice);		//Defined in cc_ascend/cc_util.ash
boolean buyableMaintain(item toMaintain, int howMany);		//Defined in cc_ascend/cc_util.ash
boolean buyableMaintain(item toMaintain, int howMany, int meatMin);//Defined in cc_ascend/cc_util.ash
boolean buyableMaintain(item toMaintain, int howMany, int meatMin, boolean condition);//Defined in cc_ascend/cc_util.ash
boolean canYellowRay();										//Defined in cc_ascend/cc_util.ash
boolean ccAdvBypass(int urlGetFlags, string[int] url, location loc, string option);//Defined in cc_ascend/cc_adventure.ash
boolean ccChew(int howMany, item toChew);					//Defined in cc_ascend/cc_cooking.ash
int ccCraft(string mode, int count, item item1, item item2);//Defined in cc_ascend/cc_util.ash
boolean ccDrink(int howMany, item toDrink);					//Defined in cc_ascend/cc_cooking.ash
boolean ccEat(int howMany, item toEat);						//Defined in cc_ascend/cc_cooking.ash
boolean ccEat(int howMany, item toEat, boolean silent);		//Defined in cc_ascend/cc_cooking.ash
boolean ccMaximize(string req, boolean simulate);			//Defined in cc_ascend/cc_util.ash
boolean ccMaximize(string req, int maxPrice, int priceLevel, boolean simulate);//Defined in cc_ascend/cc_util.ash
aggregate ccMaximize(string req, int maxPrice, int priceLevel, boolean simulate, boolean includeEquip);//Defined in cc_ascend/cc_util.ash
boolean ccOverdrink(int howMany, item toOverdrink);			//Defined in cc_ascend/cc_cooking.ash
boolean canDrink(item toDrink);								//Defined in cc_ascend/cc_cooking.ash
boolean canEat(item toEat);									//Defined in cc_ascend/cc_cooking.ash
boolean cc_have_familiar(familiar fam);						//Defined in cc_ascend/cc_cooking.ash
boolean cc_advWitchess(string target);						//Defined in cc_ascend/cc_mr2016.ash
boolean cc_advWitchess(string target, string option);		//Defined in cc_ascend/cc_mr2016.ash
int cc_advWitchessTargets(string target);					//Defined in cc_ascend/cc_mr2016.ash
boolean cc_autosell(int quantity, item toSell);				//Defined in cc_ascend/cc_util.ash
boolean cc_barrelPrayers();									//Defined in cc_ascend/cc_mr2015.ash
void cc_begin();											//Defined in cc_ascend.ash
item cc_bestBadge();										//Defined in cc_ascend/cc_mr2016.ash
boolean cc_change_mcd(int mcd);								//Defined in cc_ascend/cc_util.ash
string cc_combatHandler(int round, string opp, string text);//Defined in cc_ascend/cc_combat.ash
boolean cc_doPrecinct();									//Defined in cc_ascend/cc_mr2016.ash
string cc_edCombatHandler(int round, string opp, string text);//Defined in cc_ascend/cc_combat.ash
boolean cc_floundryAction();								//Defined in cc_ascend/cc_clan.ash
boolean cc_floundryUse();									//Defined in cc_ascend/cc_clan.ash
boolean cc_floundryAction(item it);							//Defined in cc_ascend/cc_clan.ash
boolean cc_haveSourceTerminal();							//Defined in cc_ascend/cc_mr2016.ash
boolean cc_haveWitchess();									//Defined in cc_ascend/cc_mr2016.ash
boolean cc_mayoItems();										//Defined in cc_ascend/cc_mr2015.ash
void cc_process_kmail(string functionname);					//Defined in cc_ascend/cc_zlib.ash
boolean cc_sourceTerminalEducate(skill first);				//Defined in cc_ascend/cc_mr2016.ash
boolean cc_sourceTerminalEducate(skill first, skill second);//Defined in cc_ascend/cc_mr2016.ash
boolean cc_sourceTerminalEnhance(string request);			//Defined in cc_ascend/cc_mr2016.ash
int cc_sourceTerminalEnhanceLeft();							//Defined in cc_ascend/cc_mr2016.ash
boolean cc_sourceTerminalExtrude(string request);			//Defined in cc_ascend/cc_mr2016.ash
int cc_sourceTerminalExtrudeLeft();							//Defined in cc_ascend/cc_mr2016.ash
int[string] cc_sourceTerminalMissing();						//Defined in cc_ascend/cc_mr2016.ash
boolean cc_sourceTerminalRequest(string request);			//Defined in cc_ascend/cc_mr2016.ash
int[string] cc_sourceTerminalStatus();						//Defined in cc_ascend/cc_mr2016.ash
boolean cc_tavern();										//Defined in cc_ascend.ash
string ccsJunkyard(int round, string opp, string text);		//Defined in cc_ascend/cc_combat.ash
int changeClan();											//Defined in cc_ascend/cc_clan.ash
int changeClan(int toClan);									//Defined in cc_ascend/cc_clan.ash
int changeClan(string clanName);							//Defined in cc_ascend/cc_clan.ash
boolean chateaumantegna_available();						//Defined in cc_ascend/cc_mr2015.ash
void chateaumantegna_buyStuff(item toBuy);					//Defined in cc_ascend/cc_mr2015.ash
boolean[item] chateaumantegna_decorations();				//Defined in cc_ascend/cc_mr2015.ash
boolean chateaumantegna_havePainting();						//Defined in cc_ascend/cc_mr2015.ash
boolean chateaumantegna_nightstandSet();					//Defined in cc_ascend/cc_mr2015.ash
void chateaumantegna_useDesk();								//Defined in cc_ascend/cc_mr2015.ash
boolean chateaumantegna_usePainting();						//Defined in cc_ascend/cc_mr2015.ash
boolean chateaumantegna_usePainting(string option);			//Defined in cc_ascend/cc_mr2015.ash
boolean clear_property_if(string setting, string cond);		//Defined in cc_ascend/cc_util.ash
boolean considerGrimstoneGolem(boolean bjornCrown);			//Defined in cc_ascend/cc_util.ash
boolean acquireTransfunctioner();							//Defined in cc_ascend/cc_util.ash
void consumeStuff();										//Defined in cc_ascend/cc_cooking.ash
boolean containsCombat(item it);							//Defined in cc_ascend/cc_combat.ash
boolean containsCombat(skill sk);							//Defined in cc_ascend/cc_combat.ash
boolean containsCombat(string action);						//Defined in cc_ascend/cc_combat.ash

string cs_combatKing(int round, string opp, string text);	//Defined in cc_ascend/cc_community_service.ash
string cs_combatLTB(int round, string opp, string text);	//Defined in cc_ascend/cc_community_service.ash
string cs_combatNormal(int round, string opp, string text);	//Defined in cc_ascend/cc_community_service.ash
string cs_combatWitch(int round, string opp, string text);	//Defined in cc_ascend/cc_community_service.ash
string cs_combatYR(int round, string opp, string text);		//Defined in cc_ascend/cc_community_service.ash
void cs_dnaPotions();										//Defined in cc_ascend/cc_community_service.ash
boolean cs_eat_spleen();									//Defined in cc_ascend/cc_community_service.ash
boolean cs_eat_stuff(int quest);							//Defined in cc_ascend/cc_community_service.ash
boolean cs_giant_growth();									//Defined in cc_ascend/cc_community_service.ash
void cs_initializeDay(int day);								//Defined in cc_ascend/cc_community_service.ash
void cs_make_stuff(int curQuest);							//Defined in cc_ascend/cc_community_service.ash
boolean cs_spendRests();									//Defined in cc_ascend/cc_community_service.ash
boolean cs_witchess();										//Defined in cc_ascend/cc_community_service.ash
int estimate_cs_questCost(int quest);						//Defined in cc_ascend/cc_community_service.ash
int [int] get_cs_questList();								//Defined in cc_ascend/cc_community_service.ash
boolean cc_csHandleGrapes();								//Defined in cc_ascend/cc_community_service.ash
string what_cs_quest(int quest);							//Defined in cc_ascend/cc_community_service.ash
int get_cs_questCost(int quest);							//Defined in cc_ascend/cc_community_service.ash
int get_cs_questCost(string input);							//Defined in cc_ascend/cc_community_service.ash
int get_cs_questNum(string input);							//Defined in cc_ascend/cc_community_service.ash
int expected_next_cs_quest();								//Defined in cc_ascend/cc_community_service.ash
int expected_next_cs_quest_internal();						//Defined in cc_ascend/cc_community_service.ash
boolean do_chateauGoat();									//Defined in cc_ascend/cc_community_service.ash
boolean do_cs_quest(int quest);								//Defined in cc_ascend/cc_community_service.ash
boolean do_cs_quest(string quest);							//Defined in cc_ascend/cc_community_service.ash
boolean cs_preTurnStuff(int curQuest);						//Defined in cc_ascend/cc_community_service.ash
void set_cs_questListFast(int[int] fast);					//Defined in cc_ascend/cc_community_service.ash

boolean dealWithMilkOfMagnesium(boolean useAdv);			//Defined in cc_ascend/cc_cooking.ash
void debugMaximize(string req, int meat);					//Defined in cc_ascend/cc_util.ash
boolean deck_available();									//Defined in cc_ascend/cc_mr2015.ash
boolean deck_cheat(string cheat);							//Defined in cc_ascend/cc_mr2015.ash
boolean deck_draw();										//Defined in cc_ascend/cc_mr2015.ash
int deck_draws_left();										//Defined in cc_ascend/cc_mr2015.ash
boolean deck_useScheme(string action);						//Defined in cc_ascend/cc_mr2015.ash
boolean didWePlantHere(location loc);						//Defined in cc_ascend/cc_floristfriar.ash
boolean dinseylandfill_garbageMoney();						//Defined in cc_ascend/cc_elementalPlanes.ash
boolean dna_bedtime();										//Defined in cc_ascend/cc_mr2014.ash
boolean dna_generic();										//Defined in cc_ascend/cc_mr2014.ash
boolean dna_sorceressTest();								//Defined in cc_ascend/cc_mr2014.ash
boolean dna_startAcquire();									//Defined in cc_ascend/cc_mr2014.ash
boolean doBedtime();										//Defined in cc_ascend.ash
boolean doHRSkills();										//Defined in cc_ascend/cc_heavyrains.ash
int doHottub();												//Defined in cc_ascend/cc_clan.ash
int doNumberology(string goal);								//Defined in cc_ascend/cc_util.ash
int doNumberology(string goal, boolean doIt);				//Defined in cc_ascend/cc_util.ash
int doNumberology(string goal, boolean doIt, string option);//Defined in cc_ascend/cc_util.ash
int doNumberology(string goal, string option);				//Defined in cc_ascend/cc_util.ash
int doRest();												//Defined in cc_ascend/cc_util.ash
boolean doTasks();											//Defined in cc_ascend.ash
boolean keepOnTruckin();									//Defined in cc_ascend/cc_cooking.ash
boolean doThemtharHills(boolean trickMode);					//Defined in cc_ascend.ash
boolean drinkSpeakeasyDrink(item drink);					//Defined in cc_ascend/cc_clan.ash
boolean drinkSpeakeasyDrink(string drink);					//Defined in cc_ascend/cc_clan.ash
boolean eatFancyDog(string dog);							//Defined in cc_ascend/cc_clan.ash
boolean zataraClanmate(string who);							//Defined in cc_ascend/cc_clan.ash
boolean zataraSeaside(string who);							//Defined in cc_ascend/cc_clan.ash
float edMeatBonus();										//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_buySkills();										//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_ccAdv(int num, location loc, string option);		//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_ccAdv(int num, location loc, string option, boolean skipFirstLife);//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_doResting();										//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_eatStuff();										//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_handleAdventureServant(int num, location loc, string option);//Defined in cc_ascend/cc_edTheUndying.ash
void ed_initializeDay(int day);								//Defined in cc_ascend/cc_edTheUndying.ash
void ed_initializeSession();								//Defined in cc_ascend/cc_edTheUndying.ash
void ed_initializeSettings();								//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_needShop();										//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_preAdv(int num, location loc, string option);	//Defined in cc_ascend/cc_edTheUndying.ash
boolean ed_shopping();										//Defined in cc_ascend/cc_edTheUndying.ash
int ed_spleen_limit();										//Defined in cc_ascend/cc_edTheUndying.ash
void ed_terminateSession();									//Defined in cc_ascend/cc_edTheUndying.ash
effect[int] effectList();									//Defined in cc_ascend/cc_list.ash
boolean elementalPlanes_access(element ele);				//Defined in cc_ascend/cc_elementalPlanes.ash
boolean elementalPlanes_initializeSettings();				//Defined in cc_ascend/cc_elementalPlanes.ash
boolean elementalPlanes_takeJob(element ele);				//Defined in cc_ascend/cc_elementalPlanes.ash
int elemental_resist(element goal);							//Defined in cc_ascend/cc_util.ash
float elemental_resist_value(int resistance);				//Defined in cc_ascend/cc_util.ash
void ensureSealClubs();										//Defined in cc_ascend/cc_equipment.ash
void equipBaseline();										//Defined in cc_ascend/cc_equipment.ash
void equipBaselineAccessories();							//Defined in cc_ascend/cc_equipment.ash
void equipBaselineAcc1();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineAcc2();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineAcc3();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineBack();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineFam();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineHat();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineHolster();								//Defined in cc_ascend/cc_equipment.ash
void equipBaselinePants();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineShirt();									//Defined in cc_ascend/cc_equipment.ash
void equipBaselineWeapon();									//Defined in cc_ascend/cc_equipment.ash
void equipRollover();										//Defined in cc_ascend/cc_equipment.ash
boolean eudora_available();									//Defined in cc_ascend/cc_eudora.ash
item eudora_current();										//Defined in cc_ascend/cc_eudora.ash
boolean[item] eudora_initializeSettings();					//Defined in cc_ascend/cc_eudora.ash
int[item] eudora_xiblaxian();								//Defined in cc_ascend/cc_eudora.ash
boolean evokeEldritchHorror();								//Defined in cc_ascend/cc_util.ash
boolean evokeEldritchHorror(string option);					//Defined in cc_ascend/cc_util.ash
boolean fallout_buySkills();								//Defined in cc_ascend/cc_fallout.ash
void fallout_initializeDay(int day);						//Defined in cc_ascend/cc_fallout.ash
void fallout_initializeSettings();							//Defined in cc_ascend/cc_fallout.ash
int fastenerCount();										//Defined in cc_ascend/cc_util.ash
boolean fightScienceTentacle();								//Defined in cc_ascend/cc_util.ash
boolean fightScienceTentacle(string option);				//Defined in cc_ascend/cc_util.ash
string findBanisher(int round, string opp, string text);	//Defined in cc_ascend/cc_combat.ash
void florist_initializeSettings();							//Defined in cc_ascend/cc_floristfriar.ash
boolean forceEquip(slot sl, item it);						//Defined in cc_ascend/cc_util.ash
int fullness_left();										//Defined in cc_ascend/cc_util.ash
location solveDelayZone();									//Defined in cc_ascend/cc_util.ash
item getAvailablePerfectBooze();							//Defined in cc_ascend/cc_cooking.ash
item[element] getCharterIndexable();						//Defined in cc_ascend/cc_elementalPlanes.ash
boolean getDiscoStyle();									//Defined in cc_ascend/cc_elementalPlanes.ash
boolean getDiscoStyle(int choice);							//Defined in cc_ascend/cc_elementalPlanes.ash
boolean mummifyFamiliar(familiar fam, string bonus);		//Defined in cc_ascend/cc_mr2017.ash
int januaryToteTurnsLeft(item it);							//Defined in cc_ascend/cc_mr2018.ash
boolean januaryToteAcquire(item it);						//Defined in cc_ascend/cc_mr2018.ash
boolean godLobsterCombat();									//Defined in cc_ascend/cc_mr2018.ash
boolean godLobsterCombat(item it);							//Defined in cc_ascend/cc_mr2018.ash
boolean godLobsterCombat(item it, int goal);				//Defined in cc_ascend/cc_mr2018.ash
boolean godLobsterCombat(item it, int goal, string option);	//Defined in cc_ascend/cc_mr2018.ash
boolean fantasyRealmToken();								//Defined in cc_ascend/cc_mr2018.ash
boolean songboomSetting(string goal);						//Defined in cc_ascend/cc_mr2018.ash
boolean songboomSetting(int choice);						//Defined in cc_ascend/cc_mr2018.ash
boolean fightClubNap();										//Defined in cc_ascend/cc_mr2018.ash
boolean fightClubSpa();										//Defined in cc_ascend/cc_mr2018.ash
boolean fightClubSpa(int option);							//Defined in cc_ascend/cc_mr2018.ash
boolean fightClubSpa(effect eff);							//Defined in cc_ascend/cc_mr2018.ash
boolean cheeseWarMachine(int stats, int it, int buff, int potion);//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat(stat st, boolean hardmode, string option);//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat(effect eff, boolean hardmode, string option);//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat(stat st, boolean hardmode);	//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat(effect eff, boolean hardmode);//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat(stat st);					//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat(effect eff);					//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyCombat();							//Defined in cc_ascend/cc_mr2018.ash
boolean neverendingPartyAvailable();						//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteSetup();										//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteSetup(int candidate);						//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteSetup(int candidate, int first, int second);	//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteMonster();									//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteMonster(boolean freeMon);					//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteMonster(boolean freeMon, location loc);		//Defined in cc_ascend/cc_mr2018.ash
boolean cc_voteMonster(boolean freeMon, location loc, string option);//Defined in cc_ascend/cc_mr2018.ash
boolean getSpaceJelly();									//Defined in cc_ascend/cc_mr2017.ash
int horseCost();											//Defined in cc_ascend/cc_mr2017.ash
boolean getHorse(string type);								//Defined in cc_ascend/cc_mr2017.ash
boolean kgbDiscovery();										//Defined in cc_ascend/cc_mr2017.ash
boolean kgbWasteClicks();									//Defined in cc_ascend/cc_mr2017.ash
boolean kgbTryEffect(effect ef);							//Defined in cc_ascend/cc_mr2017.ash
string kgbKnownEffects();									//Defined in cc_ascend/cc_mr2017.ash
boolean solveKGBMastermind();								//Defined in cc_ascend/cc_mr2017.ash
boolean kgbDial(int dial, int curVal, int target);			//Defined in cc_ascend/cc_mr2017.ash
boolean kgbSetup();											//Defined in cc_ascend/cc_mr2017.ash
int kgb_tabHeight(string page);								//Defined in cc_ascend/cc_mr2017.ash
int kgb_tabCount(string page);								//Defined in cc_ascend/cc_mr2017.ash
boolean kgb_getMartini();									//Defined in cc_ascend/cc_mr2017.ash
boolean kgb_getMartini(string page);						//Defined in cc_ascend/cc_mr2017.ash
boolean kgb_getMartini(string page, boolean dontCare);		//Defined in cc_ascend/cc_mr2017.ash
boolean kgbModifiers(string mod);							//Defined in cc_ascend/cc_mr2017.ash
boolean asdonBuff(effect goal);								//Defined in cc_ascend/cc_mr2017.ash
boolean asdonBuff(string goal);								//Defined in cc_ascend/cc_mr2017.ash
boolean asdonFeed(item it, int qty);						//Defined in cc_ascend/cc_mr2017.ash
boolean asdonFeed(item it);									//Defined in cc_ascend/cc_mr2017.ash
boolean asdonAutoFeed();									//Defined in cc_ascend/cc_mr2017.ash
boolean asdonAutoFeed(int goal);							//Defined in cc_ascend/cc_mr2017.ash
boolean makeGenieWish(effect eff);							//Defined in cc_ascend/cc_mr2017.ash
boolean makeGenieCombat(monster mon, string option);		//Defined in cc_ascend/cc_mr2017.ash
boolean makeGenieCombat(monster mon);						//Defined in cc_ascend/cc_mr2017.ash
boolean makeGeniePocket();									//Defined in cc_ascend/cc_mr2017.ash
boolean handleBarrelFullOfBarrels(boolean daily);			//Defined in cc_ascend/cc_util.ash
boolean handleCopiedMonster(item itm);						//Defined in cc_ascend/cc_util.ash
boolean handleCopiedMonster(item itm, string option);		//Defined in cc_ascend/cc_util.ash
boolean handleFamiliar(string type);						//Defined in cc_ascend.ash
boolean powerLevelAdjustment();								//Defined in cc_ascend.ash
boolean handleFaxMonster(monster enemy);					//Defined in cc_ascend/cc_clan.ash
boolean handleFaxMonster(monster enemy, boolean fightIt);	//Defined in cc_ascend/cc_clan.ash
boolean handleFaxMonster(monster enemy, boolean fightIt, string option);//Defined in cc_ascend/cc_clan.ash
boolean handleFaxMonster(monster enemy, string option);		//Defined in cc_ascend/cc_clan.ash
void handleJar();											//Defined in cc_ascend.ash
void handleOffHand();										//Defined in cc_ascend/cc_equipment.ash
int handlePulls(int day);									//Defined in cc_ascend.ash
boolean handleSealAncient();								//Defined in cc_ascend/cc_util.ash
boolean handleSealAncient(string option);					//Defined in cc_ascend/cc_util.ash
boolean handleSealNormal(item it);							//Defined in cc_ascend/cc_util.ash
boolean handleSealNormal(item it, string option);			//Defined in cc_ascend/cc_util.ash
boolean handleSealElement(element flavor);					//Defined in cc_ascend/cc_util.ash
boolean handleSealElement(element flavor, string option);	//Defined in cc_ascend/cc_util.ash
boolean handleServant(servant who);							//Defined in cc_ascend/cc_edTheUndying.ash
boolean handleServant(string name);							//Defined in cc_ascend/cc_edTheUndying.ash
item handleSolveThing(boolean[item] poss);					//Defined in cc_ascend/cc_equipment.ash
item handleSolveThing(boolean[item] poss, slot loc);		//Defined in cc_ascend/cc_equipment.ash
item handleSolveThing(item[int] poss);						//Defined in cc_ascend/cc_equipment.ash
item handleSolveThing(item[int] poss, slot loc);			//Defined in cc_ascend/cc_equipment.ash
void handleTracker(item used, string tracker);				//Defined in cc_ascend/cc_util.ash
void handleTracker(monster enemy, item toTrack, string tracker);//Defined in cc_ascend/cc_util.ash
void handleTracker(monster enemy, skill toTrack, string tracker);//Defined in cc_ascend/cc_util.ash
void handleTracker(monster enemy, string toTrack, string tracker);//Defined in cc_ascend/cc_util.ash
void handleTracker(monster enemy, string tracker);			//Defined in cc_ascend/cc_util.ash
boolean hasArm(monster enemy);								//Defined in cc_ascend/cc_monsterparts.ash
boolean hasHead(monster enemy);								//Defined in cc_ascend/cc_monsterparts.ash
boolean hasLeg(monster enemy);								//Defined in cc_ascend/cc_monsterparts.ash
boolean hasShieldEquipped();								//Defined in cc_ascend/cc_util.ash
boolean hasTail(monster enemy);								//Defined in cc_ascend/cc_monsterparts.ash
boolean hasTorso(monster enemy);							//Defined in cc_ascend/cc_monsterparts.ash
boolean haveAny(boolean[item] array);						//Defined in cc_ascend/cc_util.ash
boolean have_skills(boolean[skill] array);					//Defined in cc_ascend/cc_util.ash
boolean cc_have_skill(skill sk);							//Defined in cc_ascend/cc_util.ash
boolean haveGhostReport();									//Defined in cc_ascend/cc_mr2016.ash
boolean haveSpleenFamiliar();								//Defined in cc_ascend/cc_util.ash
int howLongBeforeHoloWristDrop();							//Defined in cc_ascend/cc_util.ash
void hr_doBedtime();										//Defined in cc_ascend/cc_heavyrains.ash
boolean hr_handleFamiliar(familiar fam);					//Defined in cc_ascend/cc_heavyrains.ash
void hr_initializeDay(int day);								//Defined in cc_ascend/cc_heavyrains.ash
void hr_initializeSettings();								//Defined in cc_ascend/cc_heavyrains.ash
boolean in_ronin();											//Defined in cc_ascend/cc_util.ash
int inebriety_left();										//Defined in cc_ascend/cc_util.ash
void initializeDay(int day);								//Defined in cc_ascend.ash
void initializeSettings();									//Defined in cc_ascend.ash
boolean instakillable(monster mon);							//Defined in cc_ascend/cc_util.ash
int[int] intList();											//Defined in cc_ascend/cc_list.ash
int internalQuestStatus(string prop);						//Defined in cc_ascend/cc_util.ash
questRecord questRecord();									//Defined in cc_ascend/cc_util.ash
questRecord[int] questDatabase();							//Defined in cc_ascend/cc_util.ash
int questsLeft();											//Defined in cc_ascend/cc_util.ash
int freeCrafts();											//Defined in cc_ascend/cc_util.ash
boolean is100FamiliarRun();									//Defined in cc_ascend/cc_util.ash
boolean is100FamiliarRun(familiar thisOne);					//Defined in cc_ascend/cc_util.ash
boolean isBanished(monster enemy);							//Defined in cc_ascend/cc_util.ash
boolean isExpectingArrow();									//Defined in cc_ascend/cc_util.ash
boolean isFreeMonster(monster mon);							//Defined in cc_ascend/cc_util.ash
boolean isGalaktikAvailable();								//Defined in cc_ascend/cc_util.ash
boolean isGeneralStoreAvailable();							//Defined in cc_ascend/cc_util.ash
boolean isGhost(monster mon);								//Defined in cc_ascend/cc_util.ash
boolean isGuildClass();										//Defined in cc_ascend/cc_util.ash
boolean hasTorso();											//Defined in cc_ascend/cc_util.ash
boolean isHermitAvailable();								//Defined in cc_ascend/cc_util.ash
boolean isOverdueArrow();									//Defined in cc_ascend/cc_util.ash
boolean isOverdueDigitize();								//Defined in cc_ascend/cc_util.ash
boolean isProtonGhost(monster mon);							//Defined in cc_ascend/cc_util.ash
boolean isUnclePAvailable();								//Defined in cc_ascend/cc_util.ash
boolean is_avatar_potion(item it);							//Defined in cc_ascend/cc_util.ash
int cc_mall_price(item it);									//Defined in cc_ascend/cc_util.ash
item[int] itemList();										//Defined in cc_ascend/cc_list.ash
int jello_absorbsLeft();									//Defined in cc_ascend/cc_jellonewbie.ash
boolean jello_buySkills();									//Defined in cc_ascend/cc_jellonewbie.ash
void jello_initializeSettings();							//Defined in cc_ascend/cc_jellonewbie.ash
string[item] jello_lister();								//Defined in cc_ascend/cc_jellonewbie.ash
string[item] jello_lister(string goal);						//Defined in cc_ascend/cc_jellonewbie.ash
void jello_startAscension(string page);						//Defined in cc_ascend/cc_jellonewbie.ash
boolean lastAdventureSpecialNC();							//Defined in cc_ascend/cc_util.ash
boolean loopHandler(string turnSetting, string counterSetting, int threshold);//Defined in cc_ascend/cc_util.ash
boolean loopHandler(string turnSetting, string counterSetting, string abortMessage, int threshold);//Defined in cc_ascend/cc_util.ash
boolean loopHandlerDelay(string counterSetting);			//Defined in cc_ascend/cc_util.ash
boolean loopHandlerDelay(string counterSetting, int threshold);//Defined in cc_ascend/cc_util.ash
boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem);//Defined in cc_ascend/cc_mr2017.ash
boolean loveTunnelAcquire(boolean enforcer, stat statItem, boolean engineer, int loveEffect, boolean equivocator, int giftItem, string option);//Defined in cc_ascend/cc_mr2017.ash
boolean pantogramPants();									//Defined in cc_ascend/cc_mr2017.ash
boolean pantogramPants(stat st, element el, int hpmp, int meatItemStats, int misc);//Defined in cc_ascend/cc_mr2017.ash
int lumberCount();											//Defined in cc_ascend/cc_util.ash
boolean makePerfectBooze();									//Defined in cc_ascend/cc_cooking.ash
void makeStartingSmiths();									//Defined in cc_ascend/cc_equipment.ash
int maxSealSummons();										//Defined in cc_ascend/cc_util.ash
void maximize_hedge();										//Defined in cc_ascend.ash
boolean mayo_acquireMayo(item it);							//Defined in cc_ascend/cc_mr2015.ash
int ns_crowd1();											//Defined in cc_ascend/cc_util.ash
stat ns_crowd2();											//Defined in cc_ascend/cc_util.ash
element ns_crowd3();										//Defined in cc_ascend/cc_util.ash
element ns_hedge1();										//Defined in cc_ascend/cc_util.ash
element ns_hedge2();										//Defined in cc_ascend/cc_util.ash
element ns_hedge3();										//Defined in cc_ascend/cc_util.ash
int numPirateInsults();										//Defined in cc_ascend/cc_util.ash
monster ocrs_helper(string page);							//Defined in cc_ascend/cc_combat.ash
boolean ocrs_initializeSettings();							//Defined in cc_ascend/cc_summerfun.ash
boolean ocrs_postCombatResolve();							//Defined in cc_ascend/cc_summerfun.ash
boolean ocrs_postHelper();									//Defined in cc_ascend/cc_summerfun.ash
void oldPeoplePlantStuff();									//Defined in cc_ascend/cc_floristfriar.ash
boolean organsFull();										//Defined in cc_ascend/cc_util.ash
boolean ovenHandle();										//Defined in cc_ascend/cc_util.ash
boolean pete_buySkills();									//Defined in cc_ascend/cc_sneakypete.ash
void pete_initializeDay(int day);							//Defined in cc_ascend/cc_sneakypete.ash
void pete_initializeSettings();								//Defined in cc_ascend/cc_sneakypete.ash
boolean picky_buyskills();									//Defined in cc_ascend/cc_picky.ash
void picky_initializeSettings();							//Defined in cc_ascend/cc_picky.ash
void picky_pulls();											//Defined in cc_ascend/cc_picky.ash
void picky_startAscension();								//Defined in cc_ascend/cc_picky.ash
skill preferredLibram();									//Defined in cc_ascend/cc_util.ash
location provideAdvPHPZone();								//Defined in cc_ascend/cc_util.ash
boolean providePlusCombat(int amt);							//Defined in cc_ascend/cc_util.ash
boolean providePlusCombat(int amt, boolean doEquips);		//Defined in cc_ascend/cc_util.ash
boolean providePlusNonCombat(int amt);						//Defined in cc_ascend/cc_util.ash
boolean providePlusNonCombat(int amt, boolean doEquips);	//Defined in cc_ascend/cc_util.ash
boolean acquireCombatMods(int amt);							//Defined in cc_ascend/cc_util.ash
boolean acquireCombatMods(int amt, boolean doEquips);		//Defined in cc_ascend/cc_util.ash
void pullAll(item it);										//Defined in cc_ascend/cc_util.ash
void pullAndUse(item it, int uses);							//Defined in cc_ascend/cc_util.ash
boolean pullXWhenHaveY(item it, int howMany, int whenHave);	//Defined in cc_ascend/cc_util.ash
int pullsNeeded(string data);								//Defined in cc_ascend.ash
boolean pulverizeThing(item it);							//Defined in cc_ascend/cc_util.ash
boolean rainManSummon(string monsterName, boolean copy, boolean wink);//Defined in cc_ascend/cc_heavyrains.ash
boolean rainManSummon(string monsterName, boolean copy, boolean wink, string option);//Defined in cc_ascend/cc_heavyrains.ash
boolean registerCombat(item it);							//Defined in cc_ascend/cc_combat.ash
boolean registerCombat(skill sk);							//Defined in cc_ascend/cc_combat.ash
boolean registerCombat(string action);						//Defined in cc_ascend/cc_combat.ash
void replaceBaselineAcc3();									//Defined in cc_ascend/cc_equipment.ash
boolean restoreAllSettings();								//Defined in cc_ascend/cc_util.ash
boolean restoreSetting(string setting);						//Defined in cc_ascend/cc_util.ash
boolean restore_property(string setting, string source);	//Defined in cc_ascend/cc_util.ash
boolean rethinkingCandy(effect acquire);					//Defined in cc_ascend/cc_mr2016.ash
boolean rethinkingCandy(effect acquire, boolean simulate);	//Defined in cc_ascend/cc_mr2016.ash
boolean rethinkingCandyList();								//Defined in cc_ascend/cc_mr2016.ash
boolean routineRainManHandler();							//Defined in cc_ascend/cc_heavyrains.ash
string runChoice(string page_text);							//Defined in cc_ascend/cc_util.ash
string safeString(item input);								//Defined in cc_ascend/cc_util.ash
string safeString(monster input);							//Defined in cc_ascend/cc_util.ash
string safeString(skill input);								//Defined in cc_ascend/cc_util.ash
string safeString(string input);							//Defined in cc_ascend/cc_util.ash
boolean setAdvPHPFlag();									//Defined in cc_ascend/cc_util.ash
boolean set_property_ifempty(string setting, string change);//Defined in cc_ascend/cc_util.ash
boolean settingFixer();										//Defined in cc_ascend/cc_deprecation.ash
void shrugAT();												//Defined in cc_ascend/cc_util.ash
void shrugAT(effect anticipated);							//Defined in cc_ascend/cc_util.ash
boolean snojoFightAvailable();								//Defined in cc_ascend/cc_mr2016.ash
int solveCookie();											//Defined in cc_ascend/cc_util.ash
int spleen_left();											//Defined in cc_ascend/cc_util.ash
void standard_initializeSettings();							//Defined in cc_ascend/cc_standard.ash
void standard_pulls();										//Defined in cc_ascend/cc_standard.ash
boolean startArmorySubQuest();								//Defined in cc_ascend/cc_util.ash
boolean startGalaktikSubQuest();							//Defined in cc_ascend/cc_util.ash
boolean startMeatsmithSubQuest();							//Defined in cc_ascend/cc_util.ash
string statCard();											//Defined in cc_ascend/cc_util.ash
int stomach_left();											//Defined in cc_ascend/cc_util.ash
boolean theSource_buySkills();								//Defined in cc_ascend/cc_theSource.ash
boolean theSource_initializeSettings();						//Defined in cc_ascend/cc_theSource.ash
boolean theSource_oracle();									//Defined in cc_ascend/cc_theSource.ash
boolean timeSpinnerAdventure();								//Defined in cc_ascend/cc_mr2016.ash
boolean timeSpinnerAdventure(string option);				//Defined in cc_ascend/cc_mr2016.ash
boolean timeSpinnerCombat(monster goal);					//Defined in cc_ascend/cc_mr2016.ash
boolean timeSpinnerCombat(monster goal, string option);		//Defined in cc_ascend/cc_mr2016.ash
boolean timeSpinnerConsume(item goal);						//Defined in cc_ascend/cc_mr2016.ash
boolean timeSpinnerGet(string goal);						//Defined in cc_ascend/cc_mr2016.ash
void tootGetMeat();											//Defined in cc_ascend/cc_util.ash
boolean tophatMaker();										//Defined in cc_ascend.ash
boolean trackingSplitterFixer(string oldSetting, int day, string newSetting);//Defined in cc_ascend/cc_deprecation.ash
void trickMafiaAboutFlorist();								//Defined in cc_ascend/cc_floristfriar.ash
string trim(string input);									//Defined in cc_ascend/cc_util.ash
string tryBeerPong();										//Defined in cc_ascend/cc_util.ash
boolean tryCookies();										//Defined in cc_ascend/cc_cooking.ash
boolean tryPantsEat();										//Defined in cc_ascend/cc_cooking.ash
int turkeyBooze();											//Defined in cc_ascend/cc_util.ash
boolean uneffect(effect toRemove);							//Defined in cc_ascend/cc_util.ash
boolean useCocoon();										//Defined in cc_ascend/cc_util.ash
boolean use_barrels();										//Defined in cc_ascend/cc_util.ash
boolean needStarKey();										//Defined in cc_ascend/cc_util.ash
boolean needDigitalKey();									//Defined in cc_ascend/cc_util.ash
int whitePixelCount();										//Defined in cc_ascend/cc_util.ash
boolean careAboutDrops(monster mon);						//Defined in cc_ascend/cc_util.ash
boolean volcano_bunkerJob();								//Defined in cc_ascend/cc_elementalPlanes.ash
boolean volcano_lavaDogs();									//Defined in cc_ascend/cc_elementalPlanes.ash
boolean warAdventure();										//Defined in cc_ascend.ash
boolean haveWarOutfit();									//Defined in cc_ascend.ash
boolean warOutfit();										//Defined in cc_ascend.ash
item whatHiMein();											//Defined in cc_ascend/cc_util.ash
effect whatStatSmile();										//Defined in cc_ascend/cc_util.ash
void woods_questStart();									//Defined in cc_ascend/cc_util.ash
boolean xiblaxian_makeStuff();								//Defined in cc_ascend/cc_mr2014.ash
string yellowRayCombatString();								//Defined in cc_ascend/cc_util.ash
string banisherCombatString(monster enemy, location loc);	//Defined in cc_ascend/cc_util.ash
boolean zoneCombat(location loc);							//Defined in cc_ascend/cc_util.ash
boolean zoneItem(location loc);								//Defined in cc_ascend/cc_util.ash
boolean zoneMeat(location loc);								//Defined in cc_ascend/cc_util.ash
boolean zoneNonCombat(location loc);						//Defined in cc_ascend/cc_util.ash
boolean declineTrades();									//Defined in cc_ascend/cc_util.ash

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
boolean cc_deleteMail(kmailObject msg);						//Defined in cc_ascend/cc_util.ash

//Dump from accessory scripts.
void handlePreAdventure();									//Defined in precheese.ash
void handlePreAdventure(location place);					//Defined in precheese.ash

void handlePostAdventure();									//Defined in postcheese.ash

void handleKingLiberation();								//Defined in kingcheese.ash
boolean pullPVPJunk();										//Defined in kingcheese.ash

boolean cc_acquireKeycards();								//Defined in cc_ascend/cc_aftercore.ash
boolean cc_aftercore();										//Defined in cc_ascend/cc_aftercore.ash
boolean cc_aftercore(int leave);							//Defined in cc_ascend/cc_aftercore.ash
boolean cc_ascendIntoCS();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_ascendIntoBond();								//Defined in cc_ascend/cc_aftercore.ash
boolean cc_cheeseAftercore(int leave);						//Defined in cc_ascend/cc_aftercore.ash
boolean cc_cheesePostCS();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_cheesePostCS(int leave);							//Defined in cc_ascend/cc_aftercore.ash
void cc_combatTest();										//Defined in cc_ascend/cc_aftercore.ash
boolean cc_dailyDungeon();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_doCS();											//Defined in cc_ascend/cc_aftercore.ash
boolean cc_doWalford();										//Defined in cc_ascend/cc_aftercore.ash
boolean cc_fingernail();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_goreBucket();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_guildClown();									//Defined in cc_ascend/cc_aftercore.ash
item cc_guildEpicWeapon();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_guildUnlock();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_junglePuns();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_jungleSandwich();								//Defined in cc_ascend/cc_aftercore.ash
boolean cc_lubeBarfMountain();								//Defined in cc_ascend/cc_aftercore.ash
boolean cc_mtMolehill();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_nastyBears();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_nemesisCave();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_nemesisIsland();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_packOfSmokes();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_racismReduction();								//Defined in cc_ascend/cc_aftercore.ash
boolean cc_sexismReduction();								//Defined in cc_ascend/cc_aftercore.ash
boolean cc_sloppySecondsDiner();							//Defined in cc_ascend/cc_aftercore.ash
boolean cc_toxicGlobules();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_toxicMascot();									//Defined in cc_ascend/cc_aftercore.ash
boolean cc_trashNet();										//Defined in cc_ascend/cc_aftercore.ash
string simpleCombatFilter(int round, string opp, string text);//Defined in cc_ascend/cc_aftercore.ash


boolean LM_bond();											//Defined in cc_ascend/cc_bondmember.ash
boolean bond_buySkills();									//Defined in cc_ascend/cc_bondmember.ash
boolean bond_initializeSettings();							//Defined in cc_ascend/cc_bondmember.ash
item[int] bondDrinks();										//Defined in cc_ascend/cc_bondmember.ash
void bond_initializeDay(int day);							//Defined in cc_ascend/cc_bondmember.ash


void majora_initializeSettings();							//Defined in cc_ascend/cc_majora.ash
void majora_initializeDay(int day);							//Defined in cc_ascend/cc_majora.ash
boolean LM_majora();										//Defined in cc_ascend/cc_majora.ash

void digimon_initializeSettings();							//Defined in cc_ascend/cc_digimon.ash
void digimon_initializeDay(int day);						//Defined in cc_ascend/cc_digimon.ash
boolean digimon_makeTeam();									//Defined in cc_ascend/cc_digimon.ash
boolean LM_digimon();										//Defined in cc_ascend/cc_digimon.ash
boolean digimon_ccAdv(int num, location loc, string option);//Defined in cc_ascend/cc_digimon.ash

void glover_initializeSettings();							//Defined in cc_ascend/cc_glover.ash
void glover_initializeDay(int day);							//Defined in cc_ascend/cc_glover.ash
boolean glover_usable(string it);							//Defined in cc_ascend/cc_glover.ash
boolean LM_glover();										//Defined in cc_ascend/cc_glover.ash

boolean groundhogSafeguard();								//Defined in cc_ascend/cc_groundhog.ash
void groundhog_initializeSettings();						//Defined in cc_ascend/cc_groundhog.ash
boolean canGroundhog(location loc);							//Defined in cc_ascend/cc_groundhog.ash
boolean groundhogAbort(location loc);						//Defined in cc_ascend/cc_groundhog.ash
boolean LM_groundhog();										//Defined in cc_ascend/cc_groundhog.ash

//Record from cc_ascend/cc_zone.ash
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
generic_t zone_needItem(location loc);						//Defined in cc_ascend/cc_zone.ash
generic_t zone_difficulty(location loc);					//Defined in cc_ascend/cc_zone.ash
generic_t zone_combatMod(location loc);						//Defined in cc_ascend/cc_zone.ash
generic_t zone_delay(location loc);							//Defined in cc_ascend/cc_zone.ash
generic_t zone_available(location loc);						//Defined in cc_ascend/cc_zone.ash
location[int] zone_list();									//Defined in cc_ascend/cc_zone.ash
int[location] zone_delayable();								//Defined in cc_ascend/cc_zone.ash
boolean zone_isAvailable(location loc);						//Defined in cc_ascend/cc_zone.ash
location[int] zones_available();							//Defined in cc_ascend/cc_zone.ash
monster[int] mobs_available();								//Defined in cc_ascend/cc_zone.ash
item[int] drops_available();								//Defined in cc_ascend/cc_zone.ash
item[int] hugpocket_available();							//Defined in cc_ascend/cc_zone.ash

