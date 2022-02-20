boolean buffMaintain(skill source, effect buff, item mustEquip, int mp_min, int casts, int turns, boolean speculative)
{
	if(!glover_usable(buff))
	{
		return false;
	}

	if(!auto_have_skill(source) || (have_effect(buff) >= turns))
	{
		return false;
	}

	if((my_mp() < mp_min) || (my_mp() < (casts * mp_cost(source))))
	{
		return false;
	}
	if(my_hp() <= (casts * hp_cost(source)))
	{
		return false;
	}
	if(my_adventures() < (casts * adv_cost(source)))
	{
		return false;
	}
	if(my_lightning() < (casts * lightning_cost(source)))
	{
		return false;
	}
	if(my_rain() < (casts * rain_cost(source)))
	{
		return false;
	}
	if(my_soulsauce() < (casts * soulsauce_cost(source)))
	{
		return false;
	}
	if(my_thunder() < (casts * thunder_cost(source)))
	{
		return false;
	}
	//handling for buffs that must equip something first
	boolean equip_changed = false;
	slot equip_slot = to_slot(mustEquip);
	item equip_original = equipped_item(equip_slot);
	if(mustEquip != $item[none])
	{
		if(!possessEquipment(mustEquip) ||	//we can not wear what we do not have. this checks both inventory and already worn
		!auto_is_valid(mustEquip) ||	//checks path limitations
		!can_equip(mustEquip))	//checks if stats are high enough
		{
			return false;	//we can not wear this equipment
		}
		if(!speculative)
		{
			//wear it now before using the buff. do not use the auto_ functions here because we only want to wear it long enough to cast the buff. not change what we wear to the next adventure
			equip(equip_slot, mustEquip);
			if(equipped_amount(mustEquip) == 0)
			{
				auto_log_warning("buffMaintain failed to equip [" +mustEquip+ "] for some reason. which is necessary in order to apply [" +buff+ "] using the skill [" +source+ "].");
				return false;
			}
			equip_changed = true;
		}
	}
	if(!speculative)
	{
		use_skill(casts, source);
	}
	
	if(equip_changed)
	{
		equip(equip_slot, equip_original);		//return equipment to how it was originally
	}
	return true;
}

boolean buffMaintain(item source, effect buff, int uses, int turns, boolean speculative)
{
	if(in_tcrs())
	{
		auto_log_debug("We want to use " + source + " but are in 2CRS.", "blue");
		return false;
	}

	if(!glover_usable(buff))
	{
		return false;
	}
	if(!auto_is_valid(source))
	{
		return false;
	}

	if(have_effect(buff) >= turns)
	{
		return false;
	}
	if((item_amount(source) < uses) && !in_wotsf())
	{
		if(historical_price(source) < 2000)
		{
			buy(uses - item_amount(source), source, 1000);
		}
	}
	if(item_amount(source) < uses)
	{
		return false;
	}
	if(!speculative)
		use(uses, source);
	return true;
}

boolean buffMaintain(effect buff, int mp_min, int casts, int turns, boolean speculative)
{
	skill useSkill = $skill[none];
	item useItem = $item[none];
	item mustEquip = $item[none];

	if(buff == $effect[none])
	{
		return false;
	}

	switch(buff)
	{
	#Jalapeno Saucesphere
	case $effect[A Few Extra Pounds]:			useSkill = $skill[Holiday Weight Gain];			break;
	case $effect[A Little Bit Poisoned]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Adorable Lookout]:				useItem = $item[Giraffe-Necked Turtle];			break;
	case $effect[Alacri Tea]:					useItem = $item[cuppa Alacri Tea];				break;
	case $effect[All Fired Up]:					useItem = $item[Ant Agonist];					break;
	case $effect[All Glory To The Toad]:		useItem = $item[Colorful Toad];					break;
	case $effect[All Revved Up]:				useSkill = $skill[Rev Engine];					break;
	case $effect[Almost Cool]:					useItem = $item[Mostly-Broken Sunglasses];		break;
	case $effect[Aloysius\' Antiphon of Aptitude]:useSkill = $skill[Aloysius\' Antiphon of Aptitude];break;
	case $effect[Amazing]:						useItem = $item[Pocket Maze];					break;
	case $effect[Angry]:						useSkill = $skill[Anger Glands];					break;
	case $effect[Antibiotic Saucesphere]:		useSkill = $skill[Antibiotic Saucesphere];		break;
	case $effect[Arched Eyebrow of the Archmage]:useSkill = $skill[Arched Eyebrow of the Archmage];break;
	case $effect[Armor-Plated]:					useItem = $item[Bent Scrap Metal];				break;
	case $effect[Ashen]:					useItem = $item[pile of ashes];						break;
	case $effect[Ashen Burps]:					useItem = $item[ash soda];						break;
	case $effect[Astral Shell]:
		if(auto_have_skill($skill[Astral Shell]) && acquireTotem())
		{
			useSkill = $skill[Astral Shell];
		}																						break;
	case $effect[Baconstoned]:
		if(item_amount($item[Vial of Baconstone Juice]) > 0)
		{
			useItem = $item[Vial of Baconstone Juice];
		}
		else if(item_amount($item[Flask of Baconstone Juice]) > 0)
		{
			useItem = $item[Flask of Baconstone Juice];
		}
		else
		{
			useItem = $item[Jug of Baconstone Juice];
		}																						break;
	case $effect[Baited Hook]:					useItem = $item[Wriggling Worm];				break;
	case $effect[Balls of Ectoplasm]:			useItem = $item[Ectoplasmic Orbs];				break;
	case $effect[Bandersnatched]:				useItem = $item[Tonic O\' Banderas];			break;
	case $effect[Barbecue Saucy]:				useItem = $item[Dollop of Barbecue Sauce];		break;
	case $effect[Be A Mind Master]:				useItem = $item[Daily Affirmation: Be A Mind Master];	break;
	case $effect[Become Superficially Interested]:	useItem = $item[Daily Affirmation: Be Superficially Interested];	break;
	case $effect[Bendin\' Hell]:					useSkill = $skill[Bend Hell];					break;
	case $effect[Bent Knees]:					useSkill = $skill[Bendable Knees];					break;
	case $effect[Benetton\'s Medley of Diversity]:	useSkill = $skill[Benetton\'s Medley of Diversity];		break;
	case $effect[Berry Elemental]:				useItem = $item[Tapioc Berry];					break;
	case $effect[Berry Statistical]:			useItem = $item[Snarf Berry];					break;
	case $effect[Big]:							useSkill = $skill[Get Big];						break;
	case $effect[Big Meat Big Prizes]:			useItem = $item[Meat-Inflating Powder];			break;
	case $effect[Biologically Shocked]:			useItem = $item[glowing syringe];				break;
	case $effect[Bitterskin]:					useItem = $item[Bitter Pill];					break;
	case $effect[Black Eyes]:					useItem = $item[Black Eye Shadow];				break;
	case $effect[Blackberry Politeness]:		useItem = $item[Blackberry Polite];				break;
	case $effect[Blessing of Serqet]:			useSkill = $skill[Blessing of Serqet];			break;
	case $effect[Blessing of the Bird]:
		if(auto_birdCanSeek())
		{
			useSkill = $skill[Seek Out a Bird];
		}																						break;
	case $effect[Blessing of Your Favorite Bird]:
		if(auto_favoriteBirdCanSeek())
		{
			useSkill = $skill[Visit Your Favorite Bird];
		}																						break;
	case $effect[Blinking Belly]:				useSkill = $skill[Firefly Abdomen];				break;
	case $effect[Blood-Gorged]:					useItem = $item[Vial Of Blood Simple Syrup];	break;
	case $effect[Blood Bond]:					useSkill = $skill[Blood Bond];					break;
	case $effect[Blood Bubble]:					useSkill = $skill[Blood Bubble];				break;
	case $effect[Bloody Potato Bits]:			useSkill = $skill[none];						break;
	case $effect[Bloodstain-Resistant]:			useItem = $item[Bloodstain Stick];				break;
	case $effect[Blooper Inked]:				useItem = $item[Blooper Ink];					break;
	case $effect[Blubbered Up]:					useSkill = $skill[Blubber Up];					break;
	case $effect[Blue Swayed]:					useItem = $item[Pulled Blue Taffy];				break;
	case $effect[Bone Springs]:					useSkill = $skill[Bone Springs];				break;
	case $effect[Boner Battalion]:				useSkill = $skill[Summon &quot;Boner Battalion&quot;];	break;
	case $effect[Boon of She-Who-Was]:			useSkill = $skill[Spirit Boon];					break;
	case $effect[Boon of the Storm Tortoise]:	useSkill = $skill[Spirit Boon];					break;
	case $effect[Boon of the War Snapper]:		useSkill = $skill[Spirit Boon];					break;
	case $effect[Bounty of Renenutet]:			useSkill = $skill[Bounty of Renenutet];			break;
	case $effect[Bow-Legged Swagger]:			useSkill = $skill[Bow-Legged Swagger];			break;
	case $effect[Bram\'s Bloody Bagatelle]:		useSkill = $skill[Bram\'s Bloody Bagatelle];		break;
	case $effect[Brawnee\'s Anthem of Absorption]:useSkill = $skill[Brawnee\'s Anthem of Absorption];break;
	case $effect[Brilliant Resolve]:			useItem = $item[Resolution: Be Smarter];		break;
	case $effect[Brooding]:						useSkill = $skill[Brood];						break;
	case $effect[Browbeaten]:					useItem = $item[Old Eyebrow Pencil];			break;
	case $effect[Burning Hands]:				useItem = $item[sticky lava globs];				break;
	case $effect[Busy Bein\' Delicious]:		useItem = $item[Crimbo fudge];					break;
	case $effect[Butt-Rock Hair]:				useItem = $item[Hair Spray];					break;
	case $effect[Can\'t Smell Nothin\']:	useItem = $item[Dogsgotnonoz pills];	break;
	case $effect[Car-Charged]:	useItem = $item[Battery (car)];	break;
	case $effect[Carlweather\'s Cantata of Confrontation]:useSkill = $skill[Carlweather\'s Cantata of Confrontation];break;
	case $effect[Carol Of The Bulls]: useSkill = $skill[Carol Of The Bulls]; break;
	case $effect[Carol Of The Hells]: useSkill = $skill[Carol Of The Hells]; break;
	case $effect[Carol Of The Thrills]: useSkill = $skill[Carol Of The Thrills]; break;
	case $effect[Cautious Prowl]:				useSkill = $skill[Walk: Cautious Prowl];		break;
	case $effect[Ceaseless Snarling]: useSkill = $skill[Ceaseless Snarl]; break;
	case $effect[Celestial Camouflage]:			useItem = $item[Celestial Squid Ink];			break;
	case $effect[Celestial Saltiness]:			useItem = $item[Celestial Au Jus];				break;
	case $effect[Celestial Sheen]:				useItem = $item[Celestial Olive Oil];			break;
	case $effect[Celestial Vision]:				useItem = $item[Celestial Carrot Juice];			break;
	case $effect[Cinnamon Challenger]:			useItem = $item[Pulled Red Taffy];				break;
	case $effect[Cletus\'s Canticle of Celerity]:	useSkill = $skill[Cletus\'s Canticle of Celerity];break;
	case $effect[Cloak of Shadows]: useSkill = $skill[Blood Cloak]; break;
	case $effect[Clyde\'s Blessing]:			useItem = $item[The Legendary Beat];			break;
	case $effect[Chalky Hand]:					useItem = $item[Handful of Hand Chalk];			break;
	case $effect[Chocolatesphere]:					useSkill = $skill[Chocolatesphere];			break;
	case $effect[Cranberry Cordiality]:			useItem = $item[Cranberry Cordial];				break;
	case $effect[Coffeesphere]:				useSkill = $skill[Coffeesphere];			break;
	case $effect[Cold Hard Skin]:				useItem = $item[Frost-Rimed Seal Hide];			break;
	case $effect[Contemptible Emanations]:		useItem = $item[Cologne of Contempt];			break;
	case $effect[The Cupcake of Wrath]:			useItem = $item[Green-Frosted Astral Cupcake];	break;
	case $effect[Curiosity of Br\'er Tarrypin]:
		if(pathHasFamiliar() && auto_have_skill($skill[Curiosity of Br\'er Tarrypin]) && acquireTotem())
		{
			useSkill = $skill[Curiosity of Br\'er Tarrypin];
		}																						break;
	case $effect[Dance of the Sugar Fairy]:		useItem = $item[Sugar Fairy];					break;
	case $effect[Destructive Resolve]:			useItem = $item[Resolution: Be Feistier];		break;
	case $effect[Dexteri Tea]:					useItem = $item[cuppa Dexteri tea];				break;
	case $effect[Digitally Converted]:			useItem = $item[Digital Underground Potion];	break;
	case $effect[The Dinsey Look]:				useItem = $item[Dinsey Face Paint];				break;
	case $effect[Dirge of Dreadfulness]:		useSkill = $skill[Dirge of Dreadfulness];		break;
	case $effect[Dirge of Dreadfulness (Remastered)]:
		mustEquip = $item[velour vaqueros];
		useSkill = $skill[Dirge of Dreadfulness];
		break;
	case $effect[Disco Fever]:					useSkill = $skill[Disco Fever];					break;
	case $effect[Disco Leer]:					useSkill = $skill[Disco Leer];					break;
	case $effect[Disco Smirk]:					useSkill = $skill[Disco Smirk];					break;
	case $effect[Disco State of Mind]:			useSkill = $skill[Disco Aerobics];				break;
	case $effect[Disdain of She-Who-Was]:		useSkill = $skill[Blessing of She-Who-Was];		break;
	case $effect[Disdain of the Storm Tortoise]:useSkill = $skill[Blessing of the Storm Tortoise];break;
	case $effect[Disdain of the War Snapper]:	useSkill = $skill[Blessing of the War Snapper];	break;
	case $effect[Drenched With Filth]:			useItem = $item[Concentrated Garbage Juice];	break;
	case $effect[Drescher\'s Annoying Noise]:	useSkill = $skill[Drescher\'s Annoying Noise];	break;
	case $effect[Drunk and Avuncular]:			useItem = $item[Drunk Uncles Holo-Record];		break;
	case $effect[Eagle Eyes]:					useItem = $item[eagle feather];					break;
	case $effect[Ear Winds]:					useSkill = $skill[Flappy Ears];					break;
	case $effect[Eau D\'enmity]:				useItem = $item[Perfume of Prejudice];			break;
	case $effect[Eau de Tortue]:				useItem = $item[Turtle Pheromones];				break;
	case $effect[Egged On]:						useItem = $item[Robin\'s Egg];					break;
	case $effect[Eldritch Alignment]:			useItem = $item[Eldritch Alignment Spray];		break;
	case $effect[Elemental Saucesphere]:		useSkill = $skill[Elemental Saucesphere];		break;
	case $effect[Empathy]:
		if(pathHasFamiliar() && auto_have_skill($skill[Empathy of the Newt]) && acquireTotem())
		{
			useSkill = $skill[Empathy of the Newt];
		}																						break;
	case $effect[Erudite]:						useItem = $item[Black Sheepskin Diploma];		break;
	case $effect[Expert Oiliness]:				useItem = $item[Oil of Expertise];				break;
	case $effect[Experimental Effect G-9]:		useItem = $item[Experimental Serum G-9];		break;
	case $effect[Extended Toes]:				useSkill = $skill[Retractable Toes];			break;
	case $effect[Extra Backbone]:				useItem = $item[Really Thick Spine];			break;
	case $effect[Extreme Muscle Relaxation]:	useItem = $item[Mick\'s IcyVapoHotness Rub];	break;
	case $effect[Everything Must Go!]:			useItem = $item[Violent Pastilles];				break;
	case $effect[Eyes All Black]:				useItem = $item[Delicious Candy];				break;
	case $effect[Faboooo]:						useItem = $item[Fabiotion];						break;
	case $effect[Far Out]:						useItem = $item[Patchouli Incense Stick];		break;
	case $effect[Fat Leon\'s Phat Loot Lyric]:	useSkill = $skill[Fat Leon\'s Phat Loot Lyric];	break;
	case $effect[Feeling Lonely]:					useSkill = $skill[none];						break;
	case $effect[Feeling Excited]:					useSkill = $skill[none];						break;
	case $effect[Feeling Nervous]:					useSkill = $skill[none];						break;
	case $effect[Feeling Peaceful]:					useSkill = $skill[none];						break;
	case $effect[Feeling Punchy]:				useItem = $item[Punching Potion];				break;
	case $effect[Feroci Tea]:					useItem = $item[cuppa Feroci tea];				break;
	case $effect[Fever From the Flavor]:	useItem = $item[bottle of antifreeze];	break;
	case $effect[Fireproof Lips]:					useItem = $item[SPF 451 lip balm];			break;
	case $effect[Fire Inside]:					useItem = $item[Hot Coal];						break;
	case $effect[Fishy\, Oily]:
		if(in_heavyrains())
		{
			useItem = $item[Gourmet Gourami Oil];
		}																						break;
	case $effect[Fishy Fortification]:			useItem = $item[Fish-Liver Oil];				break;
	case $effect[Fishy Whiskers]:
		if(in_heavyrains())
		{
			useItem = $item[Catfish Whiskers];
		}																						break;
	case $effect[Flame-Retardant Trousers]:		useItem = $item[Hot Powder];					break;
	case $effect[Flaming Weapon]:				useItem = $item[Hot Nuggets];					break;
	case $effect[Flamibili Tea]:				useItem = $item[cuppa Flamibili Tea];			break;
	case $effect[Flexibili Tea]:				useItem = $item[cuppa Flexibili Tea];			break;
	case $effect[Flimsy Shield of the Pastalord]:
		useSkill = $skill[Shield of the Pastalord];
		if(my_class() == $class[Pastamancer])
		{
			buff = $effect[Shield of the Pastalord];
		}
		break;
	case $effect[Float Like a Butterfly, Smell Like a Bee]:
		if(in_bhy())
		{
			useItem = $item[honeypot];
		}																						break;
	case $effect[Florid Cheeks]:				useItem = $item[Henna Face Paint];				break;
	case $effect[Football Eyes]:				useItem = $item[Black Facepaint];				break;
	case $effect[Fortunate Resolve]:			useItem = $item[Resolution: Be Luckier];		break;
	case $effect[Frenzied, Bloody]:				useSkill = $skill[Blood Frenzy];				break;
	case $effect[Fresh Scent]:					useItem = $item[deodorant];						break;
	case $effect[Frigidalmatian]:				useSkill = $skill[Frigidalmatian];				break;
	case $effect[Frog in Your Throat]:			useItem = $item[Frogade];						break;
	case $effect[From Nantucket]:				useItem = $item[Ye Olde Bawdy Limerick];		break;
	case $effect[Frost Tea]:					useItem = $item[cuppa Frost tea];				break;
	case $effect[Frostbeard]:					useSkill = $skill[Beardfreeze];					break;
	case $effect[Frosty]:						useItem = $item[Frost Flower];					break;
	case $effect[Frown]:						useSkill = $skill[Frown Muscles];				break;
	case $effect[Funky Coal Patina]:			useItem = $item[Coal Dust];						break;
	case $effect[Gelded]:						useItem = $item[Chocolate Filthy Lucre];		break;
	case $effect[Ghostly Shell]:
		if(auto_have_skill($skill[Ghostly Shell]) && acquireTotem())
		{
			useSkill = $skill[Ghostly Shell];
		}																						break;
	case $effect[The Glistening]:				useItem = $item[Vial of the Glistening];		break;
	case $effect[Glittering Eyelashes]:			useItem = $item[Glittery Mascara];				break;
	case $effect[Go Get \'Em\, Tiger!]:			useItem = $item[Ben-gal&trade; Balm];			break;
	case $effect[Got Milk]:						useItem = $item[Milk of Magnesium];				break;
	case $effect[Gothy]:						useItem = $item[Spooky Eyeliner];				break;
	case $effect[Gr8ness]:						useItem = $item[Potion of Temporary Gr8ness];	break;
	case $effect[Graham Crackling]:				useItem = $item[Heather Graham Cracker];		break;
	case $effect[Greasy Peasy]:					useItem = $item[Robot Grease];					break;
	case $effect[Greedy Resolve]:				useItem = $item[Resolution: Be Wealthier];		break;
	case $effect[Gristlesphere]:				useSkill = $skill[Gristlesphere];		break;
	case $effect[Gummed Shoes]:					useItem = $item[Shoe Gum];						break;
	case $effect[Gummi-Grin]:					useItem = $item[Gummi Turtle];					break;
	case $effect[Hairy Palms]:					useItem = $item[Orcish Hand Lotion];			break;
	case $effect[Ham-Fisted]:					useItem = $item[Vial of Hamethyst Juice];		break;
	case $effect[Hardened Fabric]:				useItem = $item[Fabric Hardener];				break;
	case $effect[Hardened Sweatshirt]:			useSkill = $skill[Magic Sweat];					break;
	case $effect[Hardly Poisoned At All]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Healthy Blue Glow]:			useItem = $item[gold star];						break;
	case $effect[Heightened Senses]:			useItem = $item[airborne mutagen];				break;
	case $effect[Heart of Green]:			useItem = $item[green candy heart];				break;
	case $effect[Heart of Lavender]:			useItem = $item[lavender candy heart];				break;
	case $effect[Heart of Orange]:			useItem = $item[orange candy heart];				break;
	case $effect[Heart of Pink]:			useItem = $item[pink candy heart];				break;
	case $effect[Heart of White]:			useItem = $item[white candy heart];				break;
	case $effect[Heart of Yellow]:			useItem = $item[yellow candy heart];				break;
	case $effect[Hide of Sobek]:				useSkill = $skill[Hide of Sobek];				break;
	case $effect[High Colognic]:				useItem = $item[Musk Turtle];					break;
	case $effect[Hippy Stench]:					useItem = $item[reodorant];						break;
	case $effect[Hot Hands]:					useItem = $item[lotion of hotness];				break;
	case $effect[How to Scam Tourists]:			useItem = $item[How to Avoid Scams];			break;
	case $effect[Human-Beast Hybrid]:			useItem = $item[Gene Tonic: Beast];				break;
	case $effect[Human-Constellation Hybrid]:	useItem = $item[Gene Tonic: Constellation];		break;
	case $effect[Human-Demon Hybrid]:			useItem = $item[Gene Tonic: Demon];				break;
	case $effect[Human-Elemental Hybrid]:		useItem = $item[Gene Tonic: Elemental];			break;
	case $effect[Human-Fish Hybrid]:			useItem = $item[Gene Tonic: Fish];				break;
	case $effect[Human-Human Hybrid]:			useItem = $item[Gene Tonic: Dude];				break;
	case $effect[Human-Humanoid Hybrid]:		useItem = $item[Gene Tonic: Humanoid];			break;
	case $effect[Human-Machine Hybrid]:			useItem = $item[Gene Tonic: Construct];			break;
	case $effect[Human-Mer-kin Hybrid]:			useItem = $item[Gene Tonic: Mer-kin];			break;
	case $effect[Human-Pirate Hybrid]:			useItem = $item[Gene Tonic: Pirate];			break;
	case $effect[Hyperoffended]:						useItem = $item[donkey flipbook];		break;
	case $effect[Hyphemariffic]:				useItem = $item[Black Eyedrops];				break;
	case $effect[Icy Glare]:					useSkill = $skill[Icy Glare];					break;
	case $effect[Impeccable Coiffure]:			useSkill = $skill[Self-Combing Hair];			break;
	case $effect[Inigo\'s Incantation of Inspiration]:useSkill = $skill[Inigo\'s Incantation of Inspiration];break;
	case $effect[Incredibly Hulking]:			useItem = $item[Ferrigno\'s Elixir of Power];	break;
	case $effect[Industrial Strength Starch]:	useItem = $item[Industrial Strength Starch];	break;
	case $effect[Ink Cloud]:					useSkill = $skill[Ink Gland];						break;
	case $effect[Inked Well]:					useSkill = $skill[Squid Glands];				break;
	case $effect[Inky Camouflage]:	useItem = $item[Vial of Squid Ink];	break;
	case $effect[Inscrutable Gaze]:				useSkill = $skill[Inscrutable Gaze];			break;
	case $effect[Insulated Trousers]:			useItem = $item[Cold Powder];					break;
	case $effect[Intimidating Mien]:			useSkill = $skill[Intimidating Mien];			break;
	case $effect[Invisible Avatar]:					useSkill = $skill[none];						break;
	case $effect[Irresistible Resolve]:			useItem = $item[Resolution: Be Sexier];			break;
	case $effect[Jackasses\' Symphony of Destruction]:useSkill = $skill[Jackasses\' Symphony of Destruction];	break;
	case $effect[Jalape&ntilde;o Saucesphere]:	useSkill = $skill[Jalape&ntilde;o Saucesphere];	break;
	case $effect[Jingle Jangle Jingle]:
		if(auto_have_skill($skill[Jingle Bells]) && acquireTotem())
		{
			useSkill = $skill[Jingle Bells];
		}																						break;
	case $effect[Joyful Resolve]:				useItem = $item[Resolution: Be Happier];		break;
	case $effect[Juiced and Jacked]:			useItem = $item[Pumpkin Juice];					break;
	case $effect[Juiced and Loose]:				useSkill = $skill[Steroid Bladder];				break;
	case $effect[Leash of Linguini]:
		if(pathHasFamiliar())
		{
			useSkill = $skill[Leash of Linguini];
		}																						break;
	case $effect[Leisurely Amblin\']:			useSkill = $skill[Walk: Leisurely Amble];		break;
	case $effect[Lion in Ambush]:				useItem = $item[Lion Musk];						break;
	case $effect[Liquidy Smoky]:				useItem = $item[Liquid Smoke];					break;
	case $effect[Lit Up]:						useItem = $item[Bottle of Lighter Fluid];		break;
	case $effect[Litterbug]:					useItem = $item[Old Candy Wrapper];				break;
	case $effect[Living Fast]:					useSkill = $skill[Live Fast];						break;
	case $effect[Locks Like the Raven]:			useItem = $item[Black No. 2];					break;
	case $effect[Loyal Tea]:					useItem = $item[cuppa Loyal Tea];				break;
	case $effect[Lucky Struck]:					useItem = $item[Lucky Strikes Holo-Record];		break;
	case $effect[Lycanthropy\, Eh?]:			useItem = $item[Weremoose Spit];				break;
	case $effect[Kindly Resolve]:				useItem = $item[Resolution: Be Kinder];			break;
	case $effect[Knob Goblin Perfume]:			useItem = $item[Knob Goblin Perfume];			break;
	case $effect[Knowing Smile]:				useSkill = $skill[Knowing Smile];				break;
	case $effect[Macaroni Coating]:				useSkill = $skill[none];						break;
	case $effect[The Magic Of LOV]:				useItem = $item[LOV Elixir #6];					break;
	case $effect[The Magical Mojomuscular Melody]:useSkill = $skill[The Magical Mojomuscular Melody];break;
	case $effect[Magnetized Ears]:				useSkill = $skill[Magnetic Ears];				break;
	case $effect[Majorly Poisoned]:				useSkill = $skill[Disco Nap];					break;
	case $effect[Manbait]:						useItem = $item[The Most Dangerous Bait];		break;
	case $effect[Mariachi Mood]:				useSkill = $skill[Moxie of the Mariachi];		break;
	case $effect[Marinated]:					useItem = $item[Bowl of Marinade];				break;
	case $effect[Mathematically Precise]:
		if(is_unrestricted($item[Crimbot ROM: Mathematical Precision]))
		{
			useSkill = $skill[Mathematical Precision];
		}																						break;
	case $effect[Mayeaugh]:						useItem = $item[Glob of Spoiled Mayo];			break;
	case $effect[Memories of Puppy Love]:		useItem = $item[Old Love Note];					break;
	case $effect[Merry Smithsness]:				useItem = $item[Flaskfull of Hollow];			break;
	case $effect[Mind Vision]:					useSkill = $skill[Intracranial Eye];			break;
	case $effect[Ministrations in the Dark]:	useItem = $item[EMD Holo-Record];				break;
	case $effect[The Moxie Of LOV]:				useItem = $item[LOV Elixir #9];					break;
	case $effect[The Moxious Madrigal]:			useSkill = $skill[The Moxious Madrigal];		break;
	case $effect[Muffled]:
		if(get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler")
		{
			useSkill = $skill[Rev Engine];
		}																						break;
	case $effect[Musk of the Moose]:			useSkill = $skill[Musk of the Moose];			break;
	case $effect[Musky]:						useItem = $item[Lynyrd Musk];					break;
	case $effect[Mutated]:						useItem = $item[Gremlin Mutagen];				break;
	case $effect[Mysteriously Handsome]:		useItem = $item[Handsomeness Potion];			break;
	case $effect[Mystically Oiled]:				useItem = $item[Ointment of the Occult];		break;
	case $effect[Nearly All-Natural]:			useItem = $item[bag of grain];					break;
	case $effect[Nearly Silent Hunting]:		useSkill = $skill[Silent Hunter];				break;
	case $effect[Neuroplastici Tea]:			useItem = $item[cuppa Neuroplastici tea];		break;
	case $effect[Neutered Nostrils]:			useItem = $item[Polysniff Perfume];				break;
	case $effect[Newt Gets In Your Eyes]:		useItem = $item[eyedrops of newt];				break;
	case $effect[Nigh-Invincible]:				useItem = $item[pixel star];					break;
	case $effect[Notably Lovely]:				useItem = $item[Confiscated Love Note];			break;
	case $effect[Obscuri Tea]:					useItem = $item[cuppa Obscuri tea];				break;
	case $effect[Ode to Booze]:					shrugAT($effect[Ode to Booze]);
												useSkill = $skill[The Ode to Booze];			break;
	case $effect[Of Course It Looks Great]:		useSkill = $skill[Check Hair];					break;
	case $effect[Oiled Skin]:					useItem = $item[Skin Oil];						break;
	case $effect[Oiled-Up]:						useItem = $item[Pec Oil];						break;
	case $effect[Oilsphere]:						useSkill = $skill[Oilsphere];						break;
	case $effect[OMG WTF]:						useItem = $item[Confiscated Cell Phone];		break;
	case $effect[One Very Clear Eye]:			useItem = $item[Cyclops Eyedrops];				break;
	case $effect[Orange Crusher]:				useItem = $item[Pulled Orange Taffy];			break;
	case $effect[Paging Betty]:					useItem = $item[Bettie Page];					break;
	case $effect[Pasta Eyeball]:				useSkill = $skill[none];						break;
	case $effect[Pasta Oneness]:				useSkill = $skill[Manicotti Meditation];		break;
	case $effect[Patent Aggression]:			useItem = $item[Patent Aggression Tonic];		break;
	case $effect[Patent Alacrity]:				useItem = $item[Patent Alacrity Tonic];			break;
	case $effect[Patent Avarice]:				useItem = $item[Patent Avarice Tonic];			break;
	case $effect[Patent Invisibility]:			useItem = $item[Patent Invisibility Tonic];		break;
	case $effect[Patent Prevention]:			useItem = $item[Patent Preventative Tonic];		break;
	case $effect[Patent Sallowness]:			useItem = $item[Patent Sallowness Tonic];		break;
	case $effect[Patience of the Tortoise]:		useSkill = $skill[Patience of the Tortoise];	break;
	case $effect[Patient Smile]:				useSkill = $skill[Patient Smile];				break;
	case $effect[Paul\'s Passionate Pop Song]:				useSkill = $skill[Paul\'s Passionate Pop Song];				break;
	case $effect[Penne Fedora]:					useSkill = $skill[none];						break;
	case $effect[Peppermint Bite]:				useItem = $item[Crimbo Peppermint Bark];		break;
	case $effect[Peppermint Twisted]:			useItem = $item[Peppermint Twist];				break;
	case $effect[Perceptive Pressure]:			useItem = $item[Pressurized Potion of Perception];	break;
	case $effect[Perspicacious Pressure]:		useItem = $item[Pressurized Potion of Perspicacity];break;
	case $effect[Phorcefullness]:				useItem = $item[Philter of Phorce];				break;
	case $effect[Physicali Tea]:				useItem = $item[cuppa Physicali tea];			break;
	case $effect[Pill Power]:
		if(item_amount($item[miniature power pill]) > 0)
		{
			useItem = $item[miniature power pill];
		}
		else
		{
			useItem = $item[power pill];
		}																						break;
	case $effect[Pill Party!]:					useItem = $item[Pill Cup];						break;
	case $effect[Pisces in the Skyces]:			useItem = $item[tobiko marble soda];			break;
	case $effect[Psalm of Pointiness]:			shrugAT($effect[Psalm of Pointiness]);
												useSkill = $skill[The Psalm of Pointiness];		break;
	case $effect[Prayer of Seshat]:				useSkill = $skill[Prayer of Seshat];			break;
	case $effect[Pride of the Puffin]:			useSkill = $skill[Pride of the Puffin];			break;
	case $effect[Polar Express]:				useItem = $item[Cloaca Cola Polar];				break;
	case $effect[Polka of Plenty]:				useSkill = $skill[The Polka of Plenty];			break;
	case $effect[Polonoia]:						useItem = $item[Polo Trophy];					break;
	case $effect[Power\, Man]:					useItem = $item[Power-Guy 2000 Holo-Record];	break;
	case $effect[Power Ballad of the Arrowsmith]:useSkill = $skill[The Power Ballad of the Arrowsmith];break;
	case $effect[Power of Heka]:				useSkill = $skill[Power of Heka];				break;
	case $effect[The Power Of LOV]:				useItem = $item[LOV Elixir #3];					break;
	case $effect[Prideful Strut]:				useSkill = $skill[Walk: Prideful Strut];		break;
	case $effect[Predjudicetidigitation]:	useItem = $item[worst candy];break;
	case $effect[Protection from Bad Stuff]:	useItem = $item[scroll of Protection from Bad Stuff];break;
	case $effect[Provocative Perkiness]:		useItem = $item[Libation of Liveliness];		break;
	case $effect[Puddingskin]:					useItem = $item[scroll of Puddingskin];			break;
	case $effect[Pulchritudinous Pressure]:		useItem = $item[Pressurized Potion of Pulchritude];break;
	case $effect[Punchable Face]:				useSkill = $skill[Extremely Punchable Face];	break;
	case $effect[Purity of Spirit]:				useItem = $item[cold-filtered water];			break;
	case $effect[Purr of the Feline]:			useSkill = $skill[Purr of the Feline];			break;
	case $effect[Purple Reign]:					useItem = $item[Pulled Violet Taffy];			break;
	case $effect[Puzzle Fury]:					useItem = $item[37x37x37 puzzle cube];			break;
	case $effect[Pyromania]:					useSkill = $skill[Pyromania];					break;
	case $effect[Quiet Desperation]:			useSkill = $skill[Quiet Desperation];			break;
	case $effect[Quiet Determination]:			useSkill = $skill[Quiet Determination];			break;
	case $effect[Quiet Judgement]:				useSkill = $skill[Quiet Judgement];				break;
	case $effect[\'Roids of the Rhinoceros]:	useItem = $item[Bottle of Rhinoceros Hormones];	break;
	case $effect[Rad-Pro Tected]:				useItem = $item[Rad-Pro (1 oz.)];				break;
	case $effect[Radiating Black Body&trade;]:	useItem = $item[Black Body&trade; Spray];		break;
	case $effect[Rage of the Reindeer]:			useSkill = $skill[Rage of the Reindeer];		break;
	case $effect[Rainy Soul Miasma]:
		if(item_amount($item[Thin Black Candle]) > 0)
		{
			useItem = $item[Thin Black Candle];
		}
		else if(item_amount($item[Drizzlers&trade; Black Licorice]) > 0)
		{
			useItem = $item[Drizzlers&trade; Black Licorice];
		}																						break;
	case $effect[Ready to Snap]:				useItem = $item[Ginger Snaps];					break;
	case $effect[Really Quite Poisoned]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Record Hunger]:				useItem = $item[The Pigs Holo-Record];			break;
	case $effect[Red Lettered]:					useItem = $item[Red Letter];					break;
	case $effect[Red Door Syndrome]:			useItem = $item[Can of Black Paint];			break;
	case $effect[Reptilian Fortitude]:
		if(auto_have_skill($skill[Reptilian Fortitude]) && acquireTotem())
		{
			useSkill = $skill[Reptilian Fortitude];
		}																						break;
	case $effect[A Rose by Any Other Material]:	useItem = $item[Squeaky Toy Rose];				break;
	case $effect[Rosewater Mark]:				useItem = $item[Old Rosewater Cream];			break;
	case $effect[Rotten Memories]:				useSkill = $skill[Rotten Memories];				break;
	case $effect[Ruthlessly Efficient]:
		if(is_unrestricted($item[Crimbot ROM: Ruthless Efficiency]))
		{
			useSkill = $skill[Ruthless Efficiency];
		}																						break;
	case $effect[Salamander in Your Stomach]:	useItem = $item[Salamander Slurry];				break;
	case $effect[Saucemastery]:					useSkill = $skill[Sauce Contemplation];			break;
	case $effect[Sauce Monocle]:				useSkill = $skill[Sauce Monocle];				break;
	case $effect[Savage Beast Inside]:			useItem = $item[jar of &quot;Creole Lady&quot; marrrmalade];break;
	case $effect[Scariersauce]:
		mustEquip = $item[velour viscometer];
		useSkill = $skill[Scarysauce];
		break;
	case $effect[Scarysauce]:					useSkill = $skill[Scarysauce];					break;
	case $effect[Scowl of the Auk]:				useSkill = $skill[Scowl of the Auk];			break;
	case $effect[Screaming! \ SCREAMING! \ AAAAAAAH!]:useSkill = $skill[Powerful Vocal Chords];			break;
	case $effect[Seal Clubbing Frenzy]:			useSkill = $skill[Seal Clubbing Frenzy];		break;
	case $effect[Sealed Brain]:					useItem = $item[Seal-Brain Elixir];				break;
	case $effect[Seeing Colors]:				useItem = $item[Funky Dried Mushroom];			break;
	case $effect[Sepia Tan]:					useItem = $item[Old Bronzer];					break;
	case $effect[Serendipi Tea]:				useItem = $item[cuppa Serendipi tea];			break;
	case $effect[Seriously Mutated]:			useItem = $item[Extra-Potent Gremlin Mutagen];	break;
	case $effect[Shells of the Damned]:			useItem = $item[cyan seashell];					break;
	case $effect[Shield of the Pastalord]:
		useSkill = $skill[Shield of the Pastalord];
		if(my_class() != $class[Pastamancer])
		{
			buff = $effect[Flimsy Shield of the Pastalord];
		}
		break;
	case $effect[Shelter of Shed]:				useSkill = $skill[Shelter of Shed];				break;
	case $effect[Shrieking Weasel]:				useItem = $item[Shrieking Weasel Holo-Record];	break;
	case $effect[Simmering]:					useSkill = $skill[Simmer];						break;
	case $effect[Simply Invisible]:			useItem = $item[Invisibility Potion];		break;
	case $effect[Simply Irresistible]:			useItem = $item[Irresistibility Potion];		break;
	case $effect[Simply Irritable]:			useItem = $item[Irritability potion];		break;
	case $effect[Singer\'s Faithful Ocelot]:	useSkill = $skill[Singer\'s Faithful Ocelot];	break;
	case $effect[Sinuses For Miles]:			useItem = $item[Mick\'s IcyVapoHotness Inhaler];break;
	case $effect[Sleaze-Resistant Trousers]:	useItem = $item[Sleaze Powder];					break;
	case $effect[Sleazy Hands]:					useItem = $item[Lotion of Sleaziness];			break;
	case $effect[Slightly Larger Than Usual]:	useItem = $item[Giant Giant Moth Dust];			break;
	case $effect[Slinking Noodle Glob]:			useSkill = $skill[none];						break;
	case $effect[Smelly Pants]:					useItem = $item[Stench Powder];					break;
	case $effect[Smooth Movements]:				useSkill = $skill[Smooth Movement];				break;
	case $effect[Snarl of the Timberwolf]:		useSkill = $skill[Snarl of the Timberwolf];		break;
	case $effect[Snarl of Three Timberwolves]:
		mustEquip = $item[velour voulge];
		useSkill = $skill[Snarl of the Timberwolf];
		break;
	case $effect[Snow Shoes]:					useItem = $item[Snow Cleats];					break;
	case $effect[Somewhat Poisoned]:			useSkill = $skill[Disco Nap];					break;
	case $effect[Song of Accompaniment]:		useSkill = $skill[Song of Accompaniment];		break;
	case $effect[Song of Battle]:				useSkill = $skill[Song of Battle];				break;
	case $effect[Song of Bravado]:				useSkill = $skill[Song of Bravado];				break;
	case $effect[Song of Cockiness]:			useSkill = $skill[Song of Cockiness];			break;
	case $effect[Song of Fortune]:				useSkill = $skill[Song of Fortune];				break;
	case $effect[Song of the Glorious Lunch]:	useSkill = $skill[Song of the Glorious Lunch];	break;
	case $effect[Song of the North]:			useSkill = $skill[Song of the North];			break;
	case $effect[Song of Sauce]:				useSkill = $skill[Song of Sauce];				break;
	case $effect[Song of Slowness]:				useSkill = $skill[Song of Slowness];			break;
	case $effect[Song of Solitude]:				useSkill = $skill[Song of Solitude];			break;
	case $effect[Song of Starch]:				useSkill = $skill[Song of Starch];				break;
	case $effect[The Sonata of Sneakiness]:		useSkill = $skill[The Sonata of Sneakiness];	break;
	case $effect[Soulerskates]:					useSkill = $skill[Soul Rotation];				break;
	case $effect[Sour Softshoe]:				useItem = $item[pulled yellow taffy];			break;
	case $effect[Spectral Awareness]: useSkill = $skill[Spectral Awareness]; break;
	case $effect[Spice Haze]:					useSkill = $skill[Bind Spice Ghost];			break;
	case $effect[Spiky Hair]:					useItem = $item[Super-Spiky Hair Gel];			break;
	case $effect[Spiky Shell]:
		if(auto_have_skill($skill[Spiky Shell]) && acquireTotem())
		{
			useSkill = $skill[Spiky Shell];
		}																						break;
	case $effect[Spiritually Awake]:			useItem = $item[Holy Spring Water];				break;
	case $effect[Spiritually Aware]:			useItem = $item[Spirit Beer];					break;
	case $effect[Spiritually Awash]:			useItem = $item[Sacramental Wine];				break;
	case $effect[Spiro Gyro]:					useItem = $item[Programmable Turtle];			break;
	case $effect[Spooky Hands]:					useItem = $item[Lotion of Spookiness];			break;
	case $effect[Spooky Weapon]:				useItem = $item[Spooky Nuggets];				break;
	case $effect[Spookypants]:					useItem = $item[Spooky Powder];					break;
	case $effect[Springy Fusilli]:				useSkill = $skill[Springy Fusilli];				break;
	case $effect[Squatting and Thrusting]:		useItem = $item[Squat-Thrust Magazine];			break;
	case $effect[Stabilizing Oiliness]:			useItem = $item[Oil of Stability];				break;
	case $effect[Standard Issue Bravery]:		useItem = $item[CSA Bravery Badge];				break;
	case $effect[Steely-Eyed Squint]:			useSkill = $skill[Steely-Eyed Squint];			break;
	case $effect[Steroid Boost]:				useItem = $item[Knob Goblin Steroids];			break;
	case $effect[Stevedave\'s Shanty of Superiority]:useSkill = $skill[Stevedave\'s Shanty of Superiority];			break;
	case $effect[Stickler for Promptness]:		useItem = $item[Potion of Punctual Companionship];	break;
	case $effect[Stinky Hands]:					useItem = $item[Lotion of Stench];				break;
	case $effect[Stinky Weapon]:				useItem = $item[Stench Nuggets];				break;
	case $effect[Stone-Faced]:					useItem = $item[Stone Wool];					break;
	case $effect[Strong Grip]:					useItem = $item[Finger Exerciser];				break;
	case $effect[Strong Resolve]:				useItem = $item[Resolution: Be Stronger];		break;
	case $effect[Sugar Rush]:
		foreach it in $items[Crimbo Fudge, Crimbo Peppermint Bark, Crimbo Candied Pecan, Breath Mint, Tasty Fun Good Rice Candy, That Gum You Like, Angry Farmer Candy]
		{
			if(item_amount(it) > 0)
			{
				useItem = it;
			}
		}																						break;
	case $effect[Superdrifting]:				useItem = $item[Superdrifter Holo-Record];		break;
	case $effect[Superheroic]:					useItem = $item[Confiscated Comic Book];		break;
	case $effect[Superhuman Sarcasm]:			useItem = $item[Serum of Sarcasm];				break;
	case $effect[Suspicious Gaze]:				useSkill = $skill[Suspicious Gaze];				break;
	case $effect[Sweet Heart]:					useItem = $item[love song of sugary cuteness];			break;
	case $effect[Sweet\, Nuts]:					useItem = $item[Crimbo Candied Pecan];			break;
	case $effect[Sweetbreads Flamb&eacute;]:	useItem = $item[Greek Fire];					break;
	case $effect[Takin\' It Greasy]:			useSkill = $skill[Grease Up];					break;
	case $effect[Taunt of Horus]:				useItem = $item[Talisman of Horus];				break;
	case $effect[Temporary Lycanthropy]:		useItem = $item[Blood of the Wereseal];			break;
	case $effect[Tenacity of the Snapper]:
		if(auto_have_skill($skill[Tenacity of the Snapper]) && acquireTotem())
		{
			useSkill = $skill[Tenacity of the Snapper];
		}																						break;
	case $effect[There is a Spoon]:				useItem = $item[Dented Spoon];					break;
	case $effect[This is Where You\'re a Viking]:useItem = $item[VYKEA woadpaint];				break;
	case $effect[Throwing Some Shade]:			useItem = $item[Shady Shades];					break;
	case $effect[Ticking Clock]:				useItem = $item[Cheap wind-up Clock];			break;
	case $effect[Toad in the Hole]:				useItem = $item[Anti-anti-antidote];			break;
	case $effect[Tomato Power]:					useItem = $item[Tomato Juice of Powerful Power];break;
	case $effect[Tortious]:						useItem = $item[Mocking Turtle];				break;
	case $effect[Triple-Sized]:					useSkill = $skill[none];						break;
	case $effect[Truly Gritty]:					useItem = $item[True Grit];						break;
	case $effect[Twen Tea]:						useItem = $item[cuppa Twen tea];				break;
	case $effect[Twinkly Weapon]:				useItem = $item[Twinkly Nuggets];				break;
	case $effect[Unmuffled]:
		if(get_property("peteMotorbikeMuffler") == "Extra-Loud Muffler")
		{
			useSkill = $skill[Rev Engine];
		}																						break;
	case $effect[Unrunnable Face]:				useItem = $item[Runproof Mascara];				break;
	case $effect[Unusual Perspective]:			useItem = $item[Unusual Oil];					break;
	case $effect[Ur-Kel\'s Aria of Annoyance]:	useSkill = $skill[Ur-Kel\'s Aria of Annoyance];	break;
	case $effect[Using Protection]:				useItem = $item[Orcish Rubber];					break;
	case $effect[Visions of the Deep Dark Deeps]:useSkill = $skill[Deep Dark Visions];			break;
	case $effect[Vital]:						useItem = $item[Doc Galaktik\'s Vitality Serum];break;
	case $effect[Vitali Tea]:					useItem = $item[cuppa Vitali tea];				break;
	case $effect[Walberg\'s Dim Bulb]:			useSkill = $skill[Walberg\'s Dim Bulb];			break;
	case $effect[WAKKA WAKKA WAKKA]:			useItem = $item[Yellow Pixel Potion];			break;
	case $effect[Wasabi With You]:				useItem = $item[Wasabi Marble Soda];			break;
	case $effect[Well-Oiled]:					useItem = $item[Oil of Parrrlay];				break;
	case $effect[Well-Swabbed Ear]:				useItem = $item[Swabbie&trade; Swab];			break;
	case $effect[Wet and Greedy]:				useItem = $item[Goblin Water];					break;
	case $effect[Whispering Strands]:			useSkill = $skill[none];						break;
	case $effect[Wisdom of Thoth]:				useSkill = $skill[Wisdom of Thoth];				break;
	case $effect[Wit Tea]:						useItem = $item[cuppa Wit tea];					break;
	case $effect[Woad Warrior]:					useItem = $item[Pygmy Pygment];					break;
	case $effect[Wry Smile]:					useSkill = $skill[Wry Smile];					break;
	case $effect[Yoloswagyoloswag]:				useItem = $item[Yolo&trade; Chocolates];		break;
	case $effect[You Read the Manual]:			useItem = $item[O\'Rly Manual];					break;
	case $effect[Your Fifteen Minutes]:			useSkill = $skill[Fifteen Minutes of Flame];	break;
	default: abort("Effect (" + buff + ") is not known to us. Beep.");							break;
	}

	if(my_class() != $class[Pastamancer])
	{
		switch(buff)
		{
		case $effect[Bloody Potato Bits]:		useSkill = $skill[Bind Vampieroghi];			break;
		case $effect[Macaroni Coating]:			useSkill = $skill[Bind Undead Elbow Macaroni];	break;
		case $effect[Pasta Eyeball]:			useSkill = $skill[Bind Lasagmbie];				break;
		case $effect[Penne Fedora]:				useSkill = $skill[Bind Penne Dreadful];			break;
		case $effect[Slinking Noodle Glob]:		useSkill = $skill[Bind Vermincelli];			break;
		case $effect[Spice Haze]:				useSkill = $skill[Bind Spice Ghost];			break;
		case $effect[Whispering Strands]:		useSkill = $skill[Bind Angel Hair Wisp];		break;
		}
	}

	if(my_class() == $class[Turtle Tamer])
	{
		switch(buff)
		{
		case $effect[Boon of the War Snapper]:
			useSkill = $skill[Spirit Boon];
			if((have_effect($effect[Glorious Blessing of the War Snapper]) == 0) && (have_effect($effect[Grand Blessing of the War Snapper]) == 0) && (have_effect($effect[Blessing of the War Snapper]) == 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Boon of She-Who-Was]:
			useSkill = $skill[Spirit Boon];
			if((have_effect($effect[Glorious Blessing of She-Who-Was]) == 0) && (have_effect($effect[Grand Blessing of She-Who-Was]) == 0) && (have_effect($effect[Blessing of She-Who-Was]) == 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Boon of the Storm Tortoise]:
			useSkill = $skill[Spirit Boon];
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Grand Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Blessing of the Storm Tortoise]) == 0))
			{
				useSkill = $skill[none];
			}
			break;

		case $effect[Disdain of the War Snapper]:
			useSkill = $skill[none];
			if((have_effect($effect[Glorious Blessing of the War Snapper]) == 0) && (have_effect($effect[Grand Blessing of the War Snapper]) == 0) && (have_effect($effect[Blessing of the War Snapper]) == 0))
			{
				useSkill = $skill[Blessing of the War Snapper];
			}
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Blessing of the Storm Tortoise]) != 0))
			{
				useSkill = $skill[none];
			}
			if((have_effect($effect[Glorious Blessing of She-Who-Was]) != 0) || (have_effect($effect[Grand Blessing of She-Who-Was]) != 0) || (have_effect($effect[Blessing of She-Who-Was]) != 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of She-Who-Was]:
			useSkill = $skill[none];
			if((have_effect($effect[Glorious Blessing of She-Who-Was]) == 0) && (have_effect($effect[Grand Blessing of She-Who-Was]) == 0) && (have_effect($effect[Blessing of She-Who-Was]) == 0))
			{
				useSkill = $skill[Blessing of She-Who-Was];
			}
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Blessing of the Storm Tortoise]) != 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of the Storm Tortoise]:
			useSkill = $skill[none];
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Grand Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Blessing of the Storm Tortoise]) == 0))
			{
				useSkill = $skill[Blessing of the Storm Tortoise];
			}
			break;
		}
	}
	else
	{
		switch(buff)
		{
		case $effect[Disdain of She-Who-Was]:
			useSkill = $skill[Blessing of She-Who-Was];
			if(have_effect($effect[Disdain of the War Snapper]) > 0)
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of the Storm Tortoise]:
			useSkill = $skill[Blessing of the Storm Tortoise];
			if((have_effect($effect[Disdain of She-Who-Was]) > 0) || (have_effect($effect[Disdain of the War Snapper]) > 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of the War Snapper]:
			useSkill = $skill[Blessing of the War Snapper];
			break;
		}
	}

	if (buff == $effect[Triple-Sized])
	{
		if (speculative)
		{
			return auto_powerfulGloveCharges() >= 5;
		}
		else
		{
			return auto_powerfulGloveStats();
		}
	}

	if (buff == $effect[Invisible Avatar])
	{
		if (speculative)
		{
			return auto_powerfulGloveCharges() >= 5;
		}
		else
		{
			return auto_powerfulGloveNoncombat();
		}
	}

	if ($effects[Feeling Lonely, Feeling Excited, Feeling Nervous, Feeling Peaceful] contains buff && auto_haveEmotionChipSkills())
	{
		skill feeling = buff.to_skill();
		//speculate to see if buff will be cast. Return false if it will not be
		if(buffMaintain(feeling, buff, mustEquip, mp_min, casts, turns, true))
		{
			if (speculative)
			{
				return feeling.timescast < feeling.dailylimit;
			}
			else if (feeling.timescast < feeling.dailylimit)
			{
				useSkill = buff.to_skill();
				handleTracker(useSkill, "auto_otherstuff");
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	boolean[effect] falloutEffects = $effects[Drunk and Avuncular, Lucky Struck, Ministrations in the Dark, Power\, Man, Record Hunger, Shrieking Weasel, Superdrifting];
	if(falloutEffects contains buff)
	{
		if(!possessEquipment($item[Wrist-Boy]))
		{
			return false;
		}
		if($effects[Drunk and Avuncular, Record Hunger] contains buff)
		{
			if(inAftercore())
			{
				return false;
			}
			if(have_effect(buff) >= 3)
			{
				return false;
			}
		}
		foreach ef in falloutEffects
		{
			if((have_effect(ef) > 0) && (ef != buff))
			{
				uneffect(ef);
			}
		}
	}
	
	if(useItem != $item[none])
	{
		return buffMaintain(useItem, buff, casts, turns, speculative);
	}
	if(useSkill != $skill[none])
	{
		return buffMaintain(useSkill, buff, mustEquip, mp_min, casts, turns, speculative);
	}
	return false;
}

boolean buffMaintain(effect buff, int mp_min, int casts, int turns)
{
	return buffMaintain(buff, mp_min, casts, turns, false);
}

boolean buffMaintain(effect buff)
{
	return buffMaintain(buff,0,1,1);
}

// Checks to see if we are already wearing a facial expression before using buffMaintain
//	if an expression is REQUIRED force it using buffMaintain
boolean auto_faceCheck(effect face)
{
	boolean[effect] FacialExpressions = $effects[Snarl of the Timberwolf, Scowl of the Auk, Stiff Upper Lip, Patient Smile, Quiet Determination, Arched Eyebrow of the Archmage, Wizard Squint, Quiet Judgement, Icy Glare, Wry Smile, Disco Leer, Disco Smirk, Suspicious Gaze, Knowing Smile, Quiet Desperation, Inscrutable Gaze];
	boolean CanEmote = true;

	foreach FExp in FacialExpressions
	{
		if(have_effect(FExp) > 0)
		{
			CanEmote = false;
		}
	}

	if(CanEmote)
	{
		buffMaintain(face);
	}
	else
	{
		auto_log_debug("Can not get " + face + " expression as we are already emoting.");
		return false;
	}

	return true;
}
