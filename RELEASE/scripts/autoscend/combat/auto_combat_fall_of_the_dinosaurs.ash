//Path specific combat handling for Fall of the Dinosaurs

void fotd_combat_helper()
{
	//identify dinosaur that has eaten current monster during Fall of the dinosaur path path
	if(!in_fotd())
	{
		return;
	}
	// primitive chicken 			No Meat, 1 in all stats
	// glass-shelled archelon		Reflects spell dmg
	// ghostasaurus					physical dmg reduced to 1, elemental resistance based on monster
	// flatusaurus					elemental dmg
	// spikolodon					stinging dmg to melee attacks
	// high-altitude pterodactyl	avoids all weapon attacks
	// supersonic velociraptor		only have 1 turn to win if win init
	// kachungasaur					300% meat drop, stun resistance based on ML
	// dilophosaur					will always hit

	string[int] dino_list = split_string("chicken archelon ghostasaurus flatusaurus spikolodon pterodactyl velociraptor kachungasaur dilophosaur", " ");
	
	foreach d in dino_list
	{
		string dino = dino_list[d];
		if(last_monster().random_modifiers[dino])
		{
			set_property("_auto_combatFotdDinosaur", dino);
			break;
		}
	}
	
}

string auto_combatFallOfTheDinosaursStage1(int round, monster enemy, string text)
{
	// stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	if(!in_fotd())
	{
		return "";
	}
	
	// Only get 1 combat round with Velociraptor

	string dino = get_property("_auto_combatFotdDinosaur");
	if(dino == "velociraptor")
	{
		return "attack with weapon"; // TODO - needs some logic to determine best auto-kill method -whether that be saucestorm, saucegeyser or attack with weapon
	}
	
	return "";
}

string auto_combatFallOfTheDinoaursStage5(int round, monster enemy, string text)
{
	// stage 5 = kill
	if(!in_fotd())
	{
		return "";
	}
	
	string dino = get_property("_auto_combatFotdDinosaur");
	if(dino == "archelon")
	{
		// reflects damage from spells back to player. 
		if(enemy.physical_resistance >= 80)
		{
			abort("Not sure how to handle a physically resistent enemy eaten by a glass-shelled archelon."); // TODO - work something out here?
		}
		if(canSurvive(1.5) && round < 10)
		{
			return "attack with weapon";
		}
		abort("Not sure how to handle monster eaten by a glass-shelled archelon.");
	}
	if(dino == "pterodactyl")	// immune to melee
	{
		if(canUse($skill[Snipe Pterodactyl], false))
		{
			return useSkill($skill[Snipe Pterodactyl], false);
		}
		if(canUse($skill[Saucegeyser], false))
		{
			return useSkill($skill[Saucegeyser], false);
		}
		if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}
	if(dino == "spikolodon")	// returns stinging damage on melee attacks
	{
		if(canUse($skill[Saucegeyser], false))
		{
			return useSkill($skill[Saucegeyser], false);
		}
		if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}
	if(dino == "ghostasaurus")	// physically immune, ml-scaling elemental resistance
	{
		if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}
	
	return "";
}
