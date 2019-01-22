script "cc_jellonewbie.ash"

void jello_initializeSettings();
string[item] jello_lister();
string[item] jello_lister(string goal);
boolean jello_buySkills();
boolean LM_jello();
void jello_startAscension(string page);
int jello_absorbsLeft();

void jello_initializeSettings()
{
	if(my_path() == "Gelatinous Noob")
	{
		set_property("cc_cubeItems", false);
		set_property("cc_getStarKey", true);
		set_property("cc_holeinthesky", true);
	}
}

void jello_startAscension(string page)
{
	if(contains_text(page, "Welcome to the Kingdom, Gelatinous Noob"))
	{
		print("In starting Jello Adventure", "blue");
		matcher my_skillPoints = create_matcher("You can pick <span class=\"num\">(\\d\+)</span> more skill", page);
		if(my_skillPoints.find())
		{
			int skillPoints = to_int(my_skillPoints.group(1));
			print("Found " + skillPoints + " skillpoints", "blue");
			boolean [int] skills = $ints[50, 49, 48, 47, 46, 55, 45, 70, 60, 69, 30, 29, 95, 54, 105, 75, 35, 10, 20, 68, 53, 52, 51, 44, 43, 42, 85, 83, 93, 34, 58, 28, 57, 84, 8, 56, 6, 18, 17, 37, 7, 9, 67, 59, 39, 74, 73, 72, 40, 66, 77, 78, 38];

			string goal = "";
			foreach idx in skills
			{
				if(contains_text(page, "name=\"skills[]\" value=\"" + idx + "\""))
				{
					goal += "&skills[]=" + idx;
					skillPoints--;
				}
				if(skillPoints == 0)
				{
					break;
				}
			}

			page = visit_url("choice.php?pwd=&option=1&whichchoice=1230" + goal);
		}
	}
}


boolean jello_buySkills()
{
	/*
		Need to consider skill orders, how to handle when we have starting skills.
		Blacklist and whitelist are just for testing for now, need more work.
	*/

	boolean[item] blacklist = $items[LOV Enamorang, Enchanted Bean];
	boolean[item] whitelist = $items[Abstraction: Thought, Accidental Cider, All-Purpose Cleaner, All-Purpose Flower, Ancient Vinyl Coin Purse, Anti-Anti-Antidote, Anticheese, Baby Oil Shooter, Barrel Pickle, Bat Guano, Bat Wing Kabob, Beach Glass Bead, Black Forest Cake, Black No. 2, Black Pension Check, Bottle of Gregnadigne, Bottle of Novelty Hot Sauce, Bottle of Popskull, Bottle of Whiskey, Buckler Buckle, Carob Chunks, Catgut Taco, Cocktail Mushroom, Cog, Concentrated Magicalness Pill, Cranberries, Crossbow String, Decomposed Boot, Decorative Fountain, Demon Skin, Dire Fudgesicle, Dirty Bottlecap, Disintegrating Quill Pen, Doc Galaktik\'s Homeopathic Elixir, Doc Galaktik\'s Invigorating Tonic, Dusty Bottle of Zinfandel, Eldritch Effluvium, Falcon&trade; Maltese Liquor, Fermenting Powder, Fine Wine, Fish-Liver Oil, Flaregun, Fricasseed Brains, Ghuol-Ear Kabob, Ghuol Egg, Gnollish Casserole Dish, Gnollish Pie Tin, Greek Fire, Hatorade, Herbs, Hermit Permit, Imp Ale, Interesting Clod of Dirt, Lemon, Limepatch, Meat Engine, Meat Paste, Meat Stack, Mushroom Pizza, Old Coin Purse, Orange, Overpriced &quot;imported&quot; beer, Pants Kit, Patchouli Incense Stick, Petrified Noodles, Phat Turquoise Bead, pickle-flavored chewing gum, Pickled Egg, Pile of Gold Coins, Pink Pony, Pink Slime, Plain Pizza, Polysniff Perfume, Potted Cactus, Redrum, Ruby W, Seal Tooth, Shot of Granola Liqueur, Shot of Grapefruit Schnapps, Slap and Tickle, Snifter of Thoroughly Aged Brandy, Spring, Sprocket, Steampunk Potion, Stench Nuggets, Stench Powder, Strawberry, Sturdy Sword Hilt, Super-Spiky Hair Gel, Tenderizing Hammer, Tires, Tom\'s of the Spanish Main Toothpaste, Unnamed Cocktail, Unstable Quark, Used Beer, Wad of Tofu, Weremoose Spit, Whiskey Sour, Wussiness Potion];

	if(internalQuestStatus("questM21Dance") >= 1)
	{
//		whitelist[$item[Handful of Hand Chalk]] = true;
	}

	while(jello_absorbsLeft() > 0)
	{
		string[item] available = jello_lister();
		int start = my_absorbs();
		int earlyTerm = max(5, get_property("_noobSkillCount").to_int() + ((my_daycount() - 1) * min(my_level()+2, 15))) + get_property("noobPoints").to_int() + 2;

		foreach sk in $skills[Large Intestine, Small Intestine, Stomach-Like Thing, Rudimentary Alimentary Canal, Central Hypothalamus, Arrogance, Sense of Pride, Sense of Purpose, Retractable Toes, Bendable Knees, Ink Gland, Anger Glands, Basic Self-Worth, Work Ethic, Visual Cortex, Saccade Reflex, Frown Muscles, Powerful Vocal Chords, Optic Nerves, Right Eyeball, Left Eyeball, Thumbs, Index Fingers, Middle Fingers, Ring Fingers, Pinky Fingers, Hot Headedness, Sunglasses, Sense of Sarcasm, Beating Human Heart, Oversized Right Kidney, Anterior Cruciate Ligaments, Achilles Tendons, Kneecaps, Ankle Joints, Hamstrings, Pathological Greed, Sense of Entitlement, Business Acumen, Financial Ambition, The Concept of Property, Bravery Gland, Subcutaneous Fat, Adrenal Gland, Nasal Septum, Hyperactive Amygdala, Nasal Lamina Propria, Right Eyelid, Pinchable Nose, Left Eyelid, Nose Hair, Overalls, Rigid Rib Cage, Rigid Headbone]
		{
			earlyTerm --;
			if(earlyTerm <= 0)
			{
				break;
			}
			if(jello_absorbsLeft() <= 0)
			{
				break;
			}
			if(!have_skill(sk))
			{
				item[int] possible;
				int count = 0;
				foreach it in available
				{
					if(!blacklist[it] && it.noob_skill == sk)
					{
						possible[count(possible)] = it;
					}
				}
				int bound = count(possible);
				if(bound == 0)
				{
					continue;
				}

				sort possible by cc_mall_price(value);

				print("Trying to acquire skill " + sk + " and considering: " , "green");
				for(int i=0; i<bound; i++)
				{
					print(possible[i] + ": " + cc_mall_price(possible[i]), "blue");
				}

				for(int i=0; (i<bound) && !have_skill(sk); i++)
				{
					if(!whitelist[possible[i]])
					{
						continue;
					}
					if(item_amount(possible[i]) == 0)
					{
						if(creatable_amount(possible[i]) == 0)
						{
							if(npc_price(possible[i]) < my_meat())
							{
								buyUpTo(1, possible[i], npc_price(possible[i]));
							}
							else
							{
								continue;
							}
						}
						else
						{
							cli_execute("make " + possible[i]);
						}
					}
					cli_execute("absorb " + possible[i]);
				}
			}
		}

		if(start == my_absorbs())
		{
			break;
		}
	}
	if((jello_absorbsLeft() > 0) && (my_adventures() <= 2) && (my_level() >= 12))
	{
		buyUpTo(1, $item[Potted Cactus]);
		cli_execute("absorb " + $item[Potted Cactus]);
	}
	return true;
}


string[item] jello_lister(string goal)
{
	string[item] retval;
//	int output = 0;
	foreach it in $items[]
	{
		boolean canGet = (item_amount(it) > 0) || (creatable_amount(it) > 0); # || (available_amount(it) > 0);
		if((npc_price(it) > 0) && (my_meat() >= npc_price(it)))
		{
			canGet = true;
		}
		if(canGet && (it.noob_skill != $skill[none]) && !have_skill(it.noob_skill))
		{
			string result = string_modifier(it.noob_skill, "Modifiers");
			if($skills[Anger Glands, Bendable Knees, Frown Muscles, Ink Gland, Powerful Vocal Chords, Retractable Toes] contains it.noob_skill)
			{
				result = "Combat Rate";
			}
			if(contains_text(result, goal))
			{
//				string color = "green";
//				if((output % 2) == 1)
//				{
//					color = "blue";
//				}
//				print(it + ": " + result, color);
//				output++;
				retval[it] = result;
			}
		}
	}
	return retval;
}

int jello_absorbsLeft()
{
	if(my_path() != "Gelatinous Noob")
	{
		return 0;
	}
	int absorbs = min(my_level() + 2, 15);
	return absorbs - my_absorbs();
}

string[item] jello_lister()
{
	return jello_lister("");
}

boolean LM_jello()
{
	if(my_path() != "Gelatinous Noob")
	{
		return false;
	}
	jello_buySkills();
	return false;
}

