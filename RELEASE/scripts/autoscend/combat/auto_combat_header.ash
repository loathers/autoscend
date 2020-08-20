// This is a header file specific for auto_combat.ash
// These functions are only used for combat so they get their own file.
// If you want a function to be accessible in all files put it /autoscend/autoscend_header.ash

string auto_combatHandler(int round, monster enemy, string text);		//defined in /autoscend/combat/auto_combat.ash

boolean haveUsed(skill sk);							//defined in /autoscend/combat/auto_combat_util.ash
boolean haveUsed(item it);							//defined in /autoscend/combat/auto_combat_util.ash
int usedCount(skill sk);							//defined in /autoscend/combat/auto_combat_util.ash
int usedCount(item it);								//defined in /autoscend/combat/auto_combat_util.ash
void markAsUsed(skill sk);							//defined in /autoscend/combat/auto_combat_util.ash
void markAsUsed(item it);							//defined in /autoscend/combat/auto_combat_util.ash
boolean canUse(skill sk, boolean onlyOnce);			//defined in /autoscend/combat/auto_combat_util.ash
boolean canUse(skill sk);							//defined in /autoscend/combat/auto_combat_util.ash
boolean canUse(item it, boolean onlyOnce);			//defined in /autoscend/combat/auto_combat_util.ash
boolean canUse(item it);							//defined in /autoscend/combat/auto_combat_util.ash
string useSkill(skill sk, boolean mark);			//defined in /autoscend/combat/auto_combat_util.ash
string useSkill(skill sk);							//defined in /autoscend/combat/auto_combat_util.ash
string useItem(item it, boolean mark);				//defined in /autoscend/combat/auto_combat_util.ash
string useItem(item it);							//defined in /autoscend/combat/auto_combat_util.ash
string useItems(item it1, item it2, boolean mark);	//defined in /autoscend/combat/auto_combat_util.ash
string useItems(item it1, item it2);				//defined in /autoscend/combat/auto_combat_util.ash
string getStallString(monster enemy);				//defined in /autoscend/combat/auto_combat_util.ash
boolean enemyCanBlocksSkills();						//defined in /autoscend/combat/auto_combat_util.ash
boolean registerCombat(string action);				//defined in /autoscend/combat/auto_combat_util.ash
boolean registerCombat(skill sk);					//defined in /autoscend/combat/auto_combat_util.ash
boolean registerCombat(item it);					//defined in /autoscend/combat/auto_combat_util.ash
boolean containsCombat(string action);				//defined in /autoscend/combat/auto_combat_util.ash
boolean containsCombat(skill sk);					//defined in /autoscend/combat/auto_combat_util.ash
boolean containsCombat(item it);					//defined in /autoscend/combat/auto_combat_util.ash
boolean canSurvive(float mult, int add);			//defined in /autoscend/combat/auto_combat_util.ash
boolean canSurvive(float mult);						//defined in /autoscend/combat/auto_combat_util.ash
string auto_saberTrickMeteorShowerCombatHandler(int round, monster enemy, string text);				//defined in /autoscend/combat/auto_combat_util.ash
string findBanisher(int round, monster enemy, string text);				//defined in /autoscend/combat/auto_combat_util.ash

void awol_helper(string page);						//defined in /autoscend/combat/auto_combat_awol.ash

string cs_combatNormal(int round, monster enemy, string text);			//defined in /autoscend/combat/auto_combat_community_service.ash
string cs_combatXO(int round, monster enemy, string text);				//defined in /autoscend/combat/auto_combat_community_service.ash
string cs_combatYR(int round, monster enemy, string text);				//defined in /autoscend/combat/auto_combat_community_service.ash
string cs_combatKing(int round, monster enemy, string text);			//defined in /autoscend/combat/auto_combat_community_service.ash
string cs_combatWitch(int round, monster enemy, string text);			//defined in /autoscend/combat/auto_combat_community_service.ash
string cs_combatLTB(int round, monster enemy, string text);				//defined in /autoscend/combat/auto_combat_community_service.ash

string auto_edCombatHandler(int round, monster enemy, string text);		//defined in /autoscend/combat/auto_combat_ed.ash

monster ocrs_helper(string page);					//defined in /autoscend/combat/auto_combat_ocrs.ash

string auto_JunkyardCombatHandler(int round, monster enemy, string text);		//defined in /autoscend/combat/auto_combat_quest.ash