// This is a header file specific for auto_combat.ash
// These functions are only used for combat so they get their own file.
// If you want a function to be accessible in all files put it /autoscend/autoscend_header.ash

#####################################################
//defined in /autoscend/combat/auto_combat.ash
void auto_combatInitialize(int round, monster enemy, string text);
string auto_combatHandler(int round, monster enemy, string text);		

#####################################################
//defined in /autoscend/combat/auto_combat_util.ash
boolean haveUsed(skill sk);
boolean haveUsed(item it);
int usedCount(skill sk);
int usedCount(item it);
void markAsUsed(skill sk);
void markAsUsed(item it);
boolean canUse(skill sk, boolean onlyOnce, boolean inCombat);
boolean canUse(skill sk, boolean onlyOnce);
boolean canUse(skill sk);
boolean canUse(item it, boolean onlyOnce);
boolean canUse(item it);
string useSkill(skill sk, boolean mark);
string useSkill(skill sk);
string useItem(item it, boolean mark);
string useItem(item it);
string useItems(item it1, item it2, boolean mark);
string useItems(item it1, item it2);
boolean isSniffed(monster enemy, skill sk);
boolean isSniffed(monster enemy);
skill getSniffer(monster enemy, boolean inCombat);
skill getSniffer(monster enemy);
skill getCopier(monster enemy, boolean inCombat);
skill getCopier(monster enemy);
skill getStunner(monster enemy);
boolean enemyCanBlocksSkills();
boolean canSurvive(float mult, int add);
boolean canSurvive(float mult);
boolean hasClubEquipped();
string auto_saberTrickMeteorShowerCombatHandler(int round, monster enemy, string text);				
string findBanisher(int round, monster enemy, string text);
string findPhylumBanisher(int round, phylum enemyphylum, string text);
string banisherCombatString(phylum enemyphylum, location loc, boolean inCombat);
string banisherCombatString(monster enemy, location loc, boolean inCombat);
string banisherCombatString(phylum enemyphylum, location loc);
string banisherCombatString(monster enemy, location loc);
string yellowRayCombatString(monster target, boolean inCombat, boolean noForceDrop);
string yellowRayCombatString(monster target, boolean inCombat);
string yellowRayCombatString(monster target);
string yellowRayCombatString();
string replaceMonsterCombatString(monster target, boolean inCombat);
string replaceMonsterCombatString(monster target);
string replaceMonsterCombatString();
float turns_to_kill(float dmg);
boolean combat_status_check(string mark);
void combat_status_add(string mark);
boolean wantToForceDrop(monster enemy);
boolean wantToDouse(monster enemy);
boolean canSurviveShootGhost(monster enemy, int shots);

#####################################################
//defined in /autoscend/combat/auto_combat_awol.ash
void awol_combat_helper(string page);		

#####################################################
//defined in /autoscend/combat/auto_combat_ed.ash
string auto_edCombatHandler(int round, monster enemy, string text);		

#####################################################
//defined in /autoscend/combat/auto_combat_mr2012.ash
string auto_combat_nanorhinoBuff(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_ocrs.ash
monster ocrs_combat_helper(string page);					

#####################################################
//defined in /autoscend/combat/auto_combat_quest.ash
string auto_JunkyardCombatHandler(int round, monster enemy, string text);		

#####################################################
//defined in /autoscend/combat/auto_combat_default_stage1.ash
string auto_combatDefaultStage1(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_default_stage2.ash
string auto_combatDefaultStage2(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_default_stage3.ash
string auto_combatDefaultStage3(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_default_stage4.ash
string auto_combatDefaultStage4(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_default_stage5.ash
string auto_combatDefaultStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_dark_gyffte.ash
string auto_combatDarkGyffteStage2(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_disguises_delimit.ash
void disguises_combat_helper(int round, monster enemy, string text);
string auto_combatDisguisesStage1(int round, monster enemy, string text);
string auto_combatDisguisesStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_fall_of_the-dinosaurs.ash
void fotd_combat_helper();
string auto_combatFallOfTheDinosaursStage1(int round, monster enemy, string text);
string auto_combatFallOfTheDinosaursStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_kingdom_of_exploathing.ash
string auto_combatExploathingStage1(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_license_to_adventure.ash
string auto_combatLicenseToAdventureStage4(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_gelatinous_noob.ash
string auto_combatGelatinousNoobStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_heavy_rains.ash
string auto_combatHeavyRainsStage1(int round, monster enemy, string text);
string auto_combatHeavyRainsStage3(int round, monster enemy, string text);
string auto_combatHeavyRainsStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_jarlsberg.ash
string auto_combatJarlsbergStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_pete.ash
string auto_combatPeteStage1(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_plumber.ash
string auto_combatPlumberStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_the_source.ash
string auto_combatTheSourceStage1(int round, monster enemy, string text);
string auto_combatTheSourceStage4(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_bees_hate_you.ash
string auto_combatBHYStage1(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_wereprofessor.ash
string auto_combatWereProfessorStage1(int round, monster enemy, string text);
string auto_combatWereProfessorStage4(int round, monster enemy, string text);
string auto_combatWereProfessorStage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_wildfire.ash
string auto_combatWildfireStage1(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_you_robot.ash
string auto_combat_robot_stage5(int round, monster enemy, string text);

#####################################################
//defined in /autoscend/combat/auto_combat_zombie_slayer.ash
string auto_combatZombieSlayerStage3(int round, monster enemy, string text);
string auto_combatZombieSlayerStage4(int round, monster enemy, string text);
string auto_combatZombieSlayerStage5(int round, monster enemy, string text);
