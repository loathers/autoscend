/**
 * Functions designed to deal with restoring hp/mp, removing status effects, etc.
 *
 * Bulk of the file is in determining what restoration method is optimal to use in a given situation. Restore methods are loaded from data/autoscend_restoration.txt, which can be updated to add new methods as needed. In general it should be as simple as adding a new line to that file with the appropriate values. For edge cases or special methods (e.g. clan hot tub) you may also need to add a bit of extra logic to the __calculate_objective_values function. In extremely rare cases you may need to modify the maximization algorithm itself, see __maximize_restore_options.
 *
 * Current hp/mp sources:
 *  - dwelling (free rests only)
 *  - chateau/campaway camp (free rests only)
 *  - clan hot tub
 *  - hp/mp items listed in autoscend_restoration.txt
 *  - npc purchasable items (meat and coinmasters)
 *  - mall purchasable items (out of ronin)
 */

/**
 * Private Interface
 */

// Loosely maps to autoscend_restoration.txt data, after a little parsing/coercing
record __RestorationMetadata{
	string name;
	string type;
	float hp_restored;
	string restores_variable_hp;
	float mp_restored;
	string restores_variable_mp;
	int soft_reserve_limit;
	int hard_reserve_limit;
	boolean removes_beaten_up;
	boolean[effect] removes_effects;
	boolean[effect] gives_effects;
	int[string] maxima_values;
};


// Holds values used to determine a restoration option's efficacy
record __RestorationOptimization{
	__RestorationMetadata metadata;
	float[string] vars;             // cache, not used for optimization
	float[string] objective_values;
	boolean[string] constraints;  // constraints that much be met, all must be true
};

// Real ugly to_string, probably only enable for debugging
string to_string(__RestorationMetadata r)
{
	string list_to_string(boolean[effect] e_list)
	{
		string s = "[";
		boolean first = true;
		foreach e in e_list
		{
			if(first)
			{
				first = false;
			}
			else
			{
				s += ", ";
			}
			s += e.to_string();
		}
		s += "]";
		return s;
	}

	string removes_effects_str = list_to_string(r.removes_effects);
	string gives_effects_str = list_to_string(r.gives_effects);
	return "__RestorationMetadata(name: "+r.name+", type: "+r.type+", hp_restored: "+r.hp_restored+", restores_variable_hp: "+r.restores_variable_hp+", mp_restored: "+r.mp_restored+", restores_variable_mp: "+r.restores_variable_mp+", removes_beaten_up: "+r.removes_beaten_up+", removes_effects: "+removes_effects_str+", gives_effects: "+gives_effects_str+")";
}

string to_string(__RestorationOptimization o, boolean simple)
{
	string list_to_string(float[string] values)
	{
		string s = "{";
		boolean first = true;
		foreach k, v in values
		{
			if(first)
			{
				first = false;
			}
			else
			{
				s += ", ";
			}
			s += k + ": " + v;
		}
		s += "}";
		return s;
	}

	string list_to_string(boolean[string] values)
	{
		string s = "{";
		boolean first = true;
		foreach k, v in values
		{
			if(first)
			{
				first = false;
			}
			else
			{
				s += ", ";
			}
			s += k + ": " + v;
		}
		s += "}";
		return s;
	}

	if(simple)
	{
		return "("+o.metadata.name + ", hp: " + o.objective_values["hp_total_restored"] + ", mp: " + o.objective_values["mp_total_restored"] + ", negative effects remaining: "+o.objective_values["negative_status_effects_remaining"]+")";
	}

	string vars_str = list_to_string(o.vars);
	string constraints_str = list_to_string(o.constraints);
	string objective_values_str = list_to_string(o.objective_values);
	return "__RestorationOptimization(name: "+o.metadata.name+", vars: "+vars_str+", constraints: "+constraints_str+", objective_values: "+objective_values_str+")";
}

string to_string(__RestorationOptimization[int] optima, boolean simple)
{
	string val = "";
	boolean first = true;
	foreach i, o in optima
	{
		if(first)
		{
			first = false;
		}
		else
		{
			val += "; ";
		}
		val += i + " - " + to_string(o, simple);
	}
	return val;
}

static boolean[effect] __all_negative_effects;
static __RestorationMetadata[string] __known_restoration_sources;
static __RestorationOptimization[int] __restore_maximizer_cache;

// TODO: would be nice to replace this concept with just putting a simple formula in place of the hp/mp fields, e.g. ${my_level}*1.5
// currently custom formulas need to be coded into an if statement
static string __RESTORE_ALL = "all";
static string __RESTORE_HALF = "half";
static string __RESTORE_SCALING = "scaling";
static string __HOT_TUB = "a relaxing hot tub";

/**
 * Parse autoscend_restoration.txt into __known_restoration_sources.
 *
 * Uses an intermediate record for the initial file_to_map, then parses it to make working with __RestorationMetadata friendlier.
 */
void __init_restoration_metadata()
{
	static string resotration_filename = "autoscend_restoration.txt";
	static string negative_effects_filename = "autoscend_negative_effects.txt";

	boolean[effect] parse_effects(string name, string effects_list)
	{
		effects_list = effects_list.to_lower_case();
		boolean[effect] parsed_effects;

		if(effects_list == "all negative")
		{
			parsed_effects = __all_negative_effects;
		}
		else if(effects_list != "none" && effects_list != "")
		{
			foreach _, s in split_string(effects_list, ",")
			{
				effect e = to_effect(s);
				if(e != $effect[none])
				{
					parsed_effects[e] = true;
				}
				else
				{
					auto_log_warning("Unknown effect found parsing restoration metadata: " + name + " removes effect: " + s);
				}
			}
		}
		return parsed_effects;
	}

	float parse_restored_amount(string restored_str)
	{
		restored_str = restored_str.to_lower_case();
		if(restored_str == "all" || restored_str == "half" || restored_str == "scaling")
		{
			return 0;
		}
		else
		{
			return to_float(restored_str);
		}
	}

	string parse_restores_variable(string restored_str)
	{
		restored_str = restored_str.to_lower_case();
		if(restored_str == "all")
		{
			return __RESTORE_ALL;
		}
		else if(restored_str == "half")
		{
			return __RESTORE_HALF;
		}
		else if(restored_str == "scaling")
		{
			return __RESTORE_SCALING;
		}
		return "";
	}

	void init()
	{
		file_to_map(negative_effects_filename, __all_negative_effects);
		__RestorationMetadata[string] parsed_records;
		
		#type[idx,name,hp_restored,mp_restored,soft_reserve_limit,hard_reserve_limit,removes_effects,gives_effects]
		string[string,string,string,string,string,string,string,string] raw_data;
		file_to_map(resotration_filename, raw_data);

		foreach type in $strings[item,skill,clan,dwelling]
		{
			foreach idx,name,hp_restored,mp_restored,soft_reserve_limit,hard_reserve_limit,removes_effects,gives_effects in raw_data[type]
			{
				__RestorationMetadata parsed;
				parsed.type = type;
				parsed.name = name.to_lower_case();
				parsed.hp_restored = parse_restored_amount(hp_restored);
				parsed.restores_variable_hp = parse_restores_variable(hp_restored);
				parsed.mp_restored = parse_restored_amount(mp_restored);
				parsed.restores_variable_mp = parse_restores_variable(mp_restored);
				parsed.soft_reserve_limit = to_int(soft_reserve_limit);
				parsed.hard_reserve_limit = to_int(hard_reserve_limit);
				parsed.removes_effects = parse_effects(parsed.name, removes_effects);
				parsed.removes_beaten_up = (parsed.removes_effects contains $effect[Beaten Up]);
				parsed.gives_effects = parse_effects(parsed.name, gives_effects);

				__known_restoration_sources[parsed.name] = parsed;
			}
		}
	}

	auto_log_info("Loading restoration data.");
	init();
	clear(__restore_maximizer_cache);
}

__RestorationMetadata[string] __restoration_methods()
{
	//Safe way to access __known_restoration_sources, ensuring it is initialized if not already.
	if(count(__known_restoration_sources) == 0)
	{
		__init_restoration_metadata();
	}
	return __known_restoration_sources;
}

// primary attributes we want to sort by (maximize), you probably shouldnt add anything to this
boolean[string] __PRIMARY_SORT_KEYS = {
	"hp_total_restored": true,
	"mp_total_restored": true
};

// values we want to maximize when optimizing
boolean[string] __MAXIMIZE_KEYS = {
	"total_uses_available": true,
	"hp_per_meat_spent": true,
	"hp_per_coinmaster_token_spent": true,
	"hp_per_mp_spent": true,
	"mp_per_meat_spent": true,
	"mp_per_coinmaster_token_spent": true
};

// values we want to minimize when optimizing
boolean[string] __MINIMIZE_KEYS = {
	"total_uses_needed": true,
	"hp_total_wasted_goal": true, // candidate for removal
	"hp_total_short_goal": true,
	"mp_total_wasted_goal": true, // candidate for removal
	"mp_total_short_goal": true,
	"hp_total_wasted_max": true,
	"hp_total_short_max": true, // candidate for removal
	"mp_total_wasted_max": true,
	"mp_total_short_max": true, // candidate for removal
	"total_mp_used": true,
	"total_meat_used": true,
	"total_coinmaster_tokens_used": true,
	"negative_status_effects_remaining": true,
	"soft_reserve_limit_uses": true,
};

// Not used for much, mostly a cache so we dont have to keep recalculating values and print out for debugging
boolean[string] __VARS_KEYS = {
	"hp_goal": true,
	"hp_starting": true,
	"hp_max": true,
	"hp_restored_per_use": true,
	"hp_uses_needed_for_goal": true,
	"mp_goal": true,
	"mp_starting": true,
	"mp_max": true,
	"mp_restored_per_use": true,
	"mp_uses_needed_for_goal": true,
	"blood_skill_opportunity_casts_goal": true,
	"blood_skill_opportunity_casts_max": true,
	"amount_creatable": true,
	"amount_buyable": true,
	"meat_per_use": true,
	"tokens_per_use": true,
	"total_creatable": true,
	"total_buyable": true,
	"reserve_limit_hard": true,
	"total_uses_remaining": true, // candidate for removal
	"soft_reserve_limit": true,
	"hard_reserve_limit": true,
	"hp_max_restorable": true,
	"mp_max_restorable": true,
	"meat_available_to_spend": true
};

// values used to constrain or quickly eliminate methods as not options (e.g. skill not available in a path)
boolean[string] __CONSTRAINT_KEYS = {
	"is_ever_useable": true,
	"is_currently_useable": true,
	"have_required_resources": true,
	"restores_needed_resources": true,
	"meets_hard_reserve_limit": true
};

/**
 * This one is very important. Do not change unless you are prepared to test thoroughly.
 *
 * keys and what rank (order) they are processed to determine a restore method's effectiveness compared to another. Each rank can potentially remove inferior options so they arent considered in the next pass. Changing these values can lead to very different results.
 *
 * __RANKED_GOAL_DESCRIPTIONS below should be updated to reflect the intended goal each rank is attempting to achieve.
 */
int[string] __OBJECTIVE_RANKS = {
	"hp_total_restored": 1,
	"mp_total_restored": 1,
	"negative_status_effects_remaining": 1,
	"soft_reserve_limit_uses": 2,
	"total_coinmaster_tokens_used": 3,
	"hp_per_coinmaster_token_spent": 3,
	"mp_per_coinmaster_token_spent": 3,
	"total_meat_used": 4,
	"hp_per_meat_spent": 4,
	"mp_per_meat_spent": 4,
	"hp_per_mp_spent": 5,
	"hp_total_short_goal": 6,
	"mp_total_short_goal": 6,
	"mp_total_wasted_max": 6,
	"hp_total_wasted_max": 6,
	"total_uses_needed": 7,
};

// describes what each ranking in __OBJECTIVE_RANKS is attempting to optimize for
string[int] __RANKED_GOAL_DESCRIPTIONS = {
	1: "remove negative status effects",
	2: "maintain soft reserve limit (keep at least N on hand if possible)",
	3: "try not to spend coinmaster tokens, maximizing hp/mp restored per token spent if we must spend",
	4: "try not to spend meat, maximizing hp/mp restored per meat spent if we must spend",
	5: "try to spend less mp, maximizing hp restored per mp spent if we must spend",
	6: "minimize hp/mp shortage to goal and wasted hp/mp over max",
	7: "minimize number of uses needed to reach goal"
};

/**
 * Precalculate values we will later use to narrow down our restoration options to the most effective and least costly.
 *
 * Most future work adding new restore methods should hopefully just need to add new fields to __MAXIMIZE_KEYS, __MINIMIZE_KEYS or __CONSTRAINT_KEYS and set them appropriately here. It is also important to add new values to __OBJECTIVE_RANKS so they are considered at the right time to be effective. The optimization algorithm itself shouldnt need to be changed.
 *
 * TODO:
 *  - add mana burn potential
 *  - improve blood burn potential calculations
 *  - add april shower
 *  - integrate with https://sourceforge.net/p/kolmafia/code/HEAD/tree/src/data/restores.txt
 */
__RestorationOptimization __calculate_objective_values(int hp_goal, int mp_goal, int meat_reserve, boolean useFreeRests, __RestorationMetadata metadata)
{
	__RestorationOptimization optimization_parameters;

	void set_value(string name, float value)
	{
		if(__MAXIMIZE_KEYS contains name || __MINIMIZE_KEYS contains name || __PRIMARY_SORT_KEYS contains name)
		{
			optimization_parameters.objective_values[name] = value;
		}
		else if(__VARS_KEYS contains name)
		{
			optimization_parameters.vars[name] = value;
		}
		else
		{
			//we must have [name] defined in one of the above keys or it will not be stored/retrieved.
			abort("void set_value(string name, float value) was asked to store the undefined key = " + name);
		}
	}

	void set_value(string name, boolean value)
	{
		if(__CONSTRAINT_KEYS contains name)
		{
			optimization_parameters.constraints[name] = value;
		}
		else
		{
			//we must have [name] defined in one of the above keys or it will not be stored/retrieved.
			abort("void set_value(string name, boolean value) was asked to store the undefined key = " + name);
		}
	}

	float get_value(string name)
	{
		if(__MAXIMIZE_KEYS contains name || __MINIMIZE_KEYS contains name || __PRIMARY_SORT_KEYS contains name)
		{
			return optimization_parameters.objective_values[name];
		}
		else if(__VARS_KEYS contains name)
		{
			return optimization_parameters.vars[name];
		}
		//we must have [name] defined in one of the above keys or it will not be stored/retrieved.
		abort("float get_value(string name) was asked to return the undefined key = " + name);
		return 0.0;
	}

	float get_value(string resource_type, string name)
	{
		return get_value(resource_type + "_" + name);
	}

	float hp_restored_per_use()
	{
		float restored_amount = metadata.hp_restored;
		if(metadata.restores_variable_hp == __RESTORE_ALL)
		{
			restored_amount = my_maxhp();
		}
		else if(metadata.restores_variable_hp == __RESTORE_HALF)
		{
			restored_amount = floor(my_maxhp() / 2);
		}

		if(metadata.type == "dwelling")
		{
			restored_amount += numeric_modifier("Bonus Resting HP");
		}

		if (metadata.name == "disco nap" && auto_have_skill($skill[Adventurer of Leisure]))
		{
			restored_amount = 40;
		}

		return restored_amount;
	}

	float mp_restored_per_use()
	{
		float restored_amount = metadata.mp_restored;
		if(metadata.restores_variable_mp == __RESTORE_ALL)
		{
			restored_amount = my_maxmp();
		}
		else if(metadata.restores_variable_mp == __RESTORE_HALF)
		{
			restored_amount = floor(my_maxmp() / 2);
		} else if(metadata.restores_variable_mp == __RESTORE_SCALING)
		{
			if(metadata.name == "magical mystery juice")
			{
				restored_amount = my_level() * 1.5 + 5;
			}
			else if(metadata.name == "generic mana potion")
			{
				restored_amount = my_level() * 2.5;
			}
		}

		if(metadata.type == "dwelling")
		{
			restored_amount += numeric_modifier("Bonus Resting MP");
		}

		return restored_amount;
	}

	float uses_needed_to_reach_goal(string resource_type)
	{
		float goal = get_value(resource_type, "goal");
		float starting = get_value(resource_type, "starting");
		float per_use = get_value(resource_type, "restored_per_use");

		if(per_use < 1.0)
		{
			return 0.0;
		}
		return max(ceil((goal - starting) / per_use), 1.0);
	}

	float total_uses_needed()
	{
		return max(get_value("hp", "uses_needed_for_goal"), get_value("mp", "uses_needed_for_goal"));
	}

	float meat_per_use()
	{
		if (metadata.type == "item")
		{
			item i = to_item(metadata.name);
			if(can_interact() || my_meat() > 20000)
			{
				//we have unlimited mall access = casual, aftercore, or postronin. or we are just rich with over 20k meat.
				//In either case we want to conserve rare items and consider an item's mall value rather than conserving our current meat stocks.
				//ex: scroll of drastic healing will be considered to be worth its mall price here.
				int price = 999999;		//do not use items that cannot be bought
				if(is_tradeable(i))		//is possible to trade in the mall
				{
					price = min(price, auto_mall_price(i));
				}
				if(npc_price(i) > 0)	//is possible to buy from an NPC store
				{
					price = min(price, npc_price(i));
				}
				return price;
			}
			else
			{
				//mall access is limited, this means pulls are limited too. also meat < 20k so we want to spend items to preserve meat
				//ex: scroll of drastic healing will be considered free. since we spent no meat for it to drop.
				return npc_price(i);	//this will set items that cannot be purchased from an NPC store to free.
			}
		}
		else if (metadata.type == "skill")
		{
			float meat_per_mp = 9.0; // default to Doc Galaktik's Invigorating Tonic at 90 meat/10 MP
			if (dispensary_available() || black_market_available())
			{
				meat_per_mp = 8.0; // Knob Goblin seltzer or Black cherry soda at 80 meat/10 MP
			}
			if (get_property("questM24Doc") == "finished")
			{
				meat_per_mp = 6.0; // Doc Galaktik's Invigorating Tonic reduced to 60 meat/10 MP
			}
			if (auto_have_skill($skill[Five Finger Discount]))
			{
				meat_per_mp = meat_per_mp * 0.95; // this isn't quite right for discounted Doc Galaktik but I don't care.
			}
			if (isMystGuildStoreAvailable())
			{
				int mmj_cost = auto_have_skill($skill[Five Finger Discount]) ? 95 : 100;
				int mmj_mp_restored = my_level() * 1.5 + 5;
				float mmj_meat_per_mp = mmj_cost / mmj_mp_restored;
				meat_per_mp = min(meat_per_mp, mmj_meat_per_mp);
				// at level 6 and above, MMJ is better than all but discounted doc galaktik
				// and at level 8 and above it's better than everything
			}
			if (my_class() == $class[Sauceror] || can_interact())
			{
				// your MP cup runneth over
				meat_per_mp = 0;
			}
			skill s = to_skill(metadata.name);
			return (mp_cost(s) * meat_per_mp);
		}
		else
		{
			return 0.0;
		}
	}

	float tokens_per_use()
	{
		if(metadata.type != "item")
		{
			return 0.0;
		}
		item i = to_item(metadata.name);
		if(i.seller != $coinmaster[none])
		{
			return sell_price(i.seller, i);
		}
		return 0.0;
	}

	float total_creatable()
	{
		if(metadata.type != "item")
		{
			return 0.0;
		}
		return creatable_amount(to_item(metadata.name));
	}

	float total_buyable()
	{
		if(metadata.type != "item")
		{
			return 0.0;
		}

		float price_per = 0.0;
		float currency_available = 0.0;
		item it = to_item(metadata.name);

		boolean mall_buyable = can_interact() && is_tradeable(it);
		if(mall_buyable || npc_price(it) > 0)
		{
			price_per = get_value("meat_per_use");
			currency_available = max(0.0, my_meat() - meat_reserve);
		}
		else if(get_value("tokens_per_use") > 0.0)
		{
			price_per = get_value("tokens_per_use");
			currency_available = it.seller.available_tokens;
		}

		if(currency_available == 0)
		{
			return 0.0;
		}

		return floor(currency_available / price_per);
	}

	float total_uses_available()
	{
		float available = 0.0;
		if(metadata.type == "dwelling")
		{
			available = freeRestsRemaining();
		}
		else if(metadata.type == "item")
		{
			available = item_amount(to_item(metadata.name)) + get_value("total_buyable") + get_value("total_creatable");
		}
		else if(metadata.type == "skill")
		{
			available = floor(get_value("mp_starting") / mp_cost(to_skill(metadata.name)));
		}
		else if(metadata.name == __HOT_TUB)
		{
			available = hotTubSoaksRemaining();
		}
		return max(0.0, available);
	}

	float total_uses_remaining()
	{
		return max(0.0, get_value("total_uses_available") - get_value("total_uses_needed"));
	}

	float soft_reserve_limit_uses()
	{
		return max(0.0, get_value("soft_reserve_limit") - get_value("total_uses_remaining"));
	}

	float max_restorable(string resource_type)
	{
		return get_value("total_uses_needed") * get_value(resource_type, "restored_per_use");
	}

	float total_wasted(string resource_type, float goal)
	{
		if((resource_type == "hp" && metadata.restores_variable_hp == __RESTORE_ALL) ||
		(resource_type == "mp" && metadata.restores_variable_mp == __RESTORE_ALL))
		{
			return 0.0;
		}
		if (resource_type == "hp" && metadata.type == "skill")
		{
			// don't consider excess healing from spells as "waste".
			// It would be better to price this in meat terms across all healing but that's not easy to do right now.
			return 0.0;
		}
		return max(0.0, get_value(resource_type, "starting") + get_value(resource_type, "max_restorable") - goal);
	}

	// TODO: doesnt account properly for multiuse situations where we could have more blood skill casts and less waste than this formula suggests
	float blood_skill_opportunity_casts(float goal)
	{
		boolean bloodBondAvailable = auto_have_skill($skill[Blood Bond]) &&
		pathHasFamiliar() && //checks if player can use familiars in this run
		my_maxhp() > hp_cost($skill[Blood Bond]) &&
		goal > ((9-hp_regen())*10) && // blood bond drains hp after combat, make sure we dont accidentally kill the player
		get_property("auto_restoreUseBloodBond").to_boolean();

		boolean bloodBubbleAvailable = auto_have_skill($skill[Blood Bubble]) &&
		my_maxhp() > hp_cost($skill[Blood Bubble]);

		float waste = total_wasted("hp", goal);
		float blood_cost = hp_cost($skill[Blood Bond]);
		if(waste <= blood_cost || !(bloodBubbleAvailable || bloodBondAvailable))
		{
			return 0.0;
		}

		float hp_to_burn = 0.0;
		if(my_hp() > 0)
		{
			hp_to_burn = min(my_hp()-1, waste);
		}
		return floor(hp_to_burn / blood_cost);
	}

	float blood_adjusted_waste(float goal)
	{
		float blood_cost = hp_cost($skill[Blood Bond]);
		float casts = blood_skill_opportunity_casts(goal);
		float waste = total_wasted("hp", goal);
		if(casts < 1)
		{
			return waste;
		}
		else
		{
			return waste - (casts * hp_cost($skill[Blood Bond]));
		}
	}

	float total_short(string resource_type, float goal)
	{
		return max(0.0, goal - (get_value(resource_type, "starting") + get_value(resource_type, "max_restorable")));
	}

	float total_mp_used()
	{
		if(metadata.type != "skill")
		{
			return -1.0;
		}
		return total_uses_needed() * mp_cost(to_skill(metadata.name));
	}

	float total_meat_used()
	{
		if(metadata.type != "item" && metadata.type != "skill")
		{
			return -1.0;
		}
		float needed;
		if(metadata.type == "item")
		{
			item i = to_item(metadata.name);
			needed = max(0.0, total_uses_needed() - item_amount(i));
		}
		else if (metadata.type == "skill")
		{
			needed = total_uses_needed();
		}

		float price = get_value("meat_per_use");
		if (price < 0.0)
		{
			return -1.0;
		}
		return price * needed;
	}

	float meat_available_to_spend()
	{
		return max(0.0, my_meat()-meat_reserve);
	}

	float total_coinmaster_tokens_used()
	{
		if(metadata.type != "item")
		{
			return -1.0;
		}
		item i = to_item(metadata.name);

		if(i.seller != $coinmaster[none])
		{
			return -1.0;
		}

		float needed = max(0.0, total_uses_needed() - item_amount(i));
		float price = sell_price(i.seller, i);

		return needed * price;
	}

	float negative_status_effects_remaining()
	{
		float negative_effects_active = 0;
		foreach e, _ in my_effects()
		{
			if(e != $effect[Beaten Up] && __all_negative_effects contains e && !(metadata.removes_effects contains e))
			{
				negative_effects_active++;
			}
		}
		return negative_effects_active;
	}

	float resource_value_per_meat_spent(string resource_type)
	{
		if(get_value("total_meat_used") <= 0.0)
		{
			return -1.0;
		}

		return get_value(resource_type, "total_restored") / get_value("total_meat_used");
	}

	float resource_value_per_coinmaster_token_spent(string resource_type)
	{
		if(get_value("total_coinmaster_tokens_used") <= 0.0)
		{
			return -1.0;
		}

		return get_value(resource_type, "total_restored") / get_value("total_coinmaster_tokens_used");
	}

	float hp_per_mp_spent()
	{
		if(get_value("total_mp_used") <= 0.0)
		{
			return -1.0;
		}

		return get_value("hp_total_restored") / get_value("total_mp_used");
	}

	float total_restored(string resource_type)
	{
		float starting = get_value(resource_type, "starting");
		float goal = min(get_value(resource_type, "max_restorable") + starting, get_value(resource_type, "max"));

		if(resource_type == "hp" && goal > starting)
		{
			float blood_cost = hp_cost($skill[Blood Bond]);
			float casts = blood_skill_opportunity_casts(goal);
			if(casts > 0.0)
			{
				starting = max(starting - casts * blood_cost, 0.0);
			}
		}

		return goal - starting;
	}

	boolean is_ever_useable()
	{
		if(metadata.type == "item")
		{
			item i = to_item(metadata.name);
			return auto_is_valid(i);
		}
		if(metadata.type == "skill")
		{
			return auto_is_valid(to_skill(metadata.name));
		}
		if(metadata.type == "dwelling")
		{
			item d = to_item(metadata.name);
			return (d == $item[Chateau Mantegna Room Key] && chateaumantegna_available()) ||
			(d == $item[Distant Woods Getaway Brochure] && auto_campawayAvailable()) ||
			(d == get_dwelling() && !haveAnyIotmAlternativeRestSiteAvailable());
		}
		if(metadata.name == __HOT_TUB)
		{
			return isHotTubAvailable();
		}
		return true;
	}

	boolean is_currently_useable()
	{
		if(metadata.type == "item")
		{
			item i = to_item(metadata.name);
			boolean mall_buyable = can_interact() && auto_mall_price(i) > 0;
			boolean npc_meat_buyable = npc_price(i) > 0;
			boolean coinmaster_buyable = i.seller != $coinmaster[none] && is_accessible(i.seller) && get_property("autoSatisfyWithCoinmasters").to_boolean();
			
			boolean can_buy = meat_reserve < my_meat() && (npc_meat_buyable || mall_buyable);
			return (available_amount(i) > 0 || can_buy || coinmaster_buyable);
		}
		if(metadata.type == "skill")
		{
			return auto_have_skill(to_skill(metadata.name));
		}
		if(metadata.type == "dwelling")
		{
			return useFreeRests && haveFreeRestAvailable();
		}
		if(metadata.name == __HOT_TUB)
		{
			return hotTubSoaksRemaining() > 0;
		}
		return true;
	}

	boolean have_required_resources()
	{
		//this is used to quickly remove unavailable restorers from consideration before we even do any optimization.
		
		//for skills, the value of total_uses_available assumes we will not restore_mp to cast. so we overrule it in this function by comparing to our maxmp instead.
		if(metadata.type == "skill")
		{
			skill s = to_skill(metadata.name);
			if(my_maxmp() >= mp_cost(s))
			{
				return true;
			}
		}
		
		//for everything that is not a skill we trust total_uses_available.
		return get_value("total_uses_available") > 0.0;
	}

	boolean restores_needed_resources()
	{
		if(hp_goal > my_hp() && get_value("hp_restored_per_use") == 0)
		{
			return false;
		}
		if(mp_goal > my_mp() && get_value("mp_restored_per_use") == 0)
		{
			return false;
		}
		return true;
	}

	boolean meets_hard_reserve_limit()
	{
		return get_value("total_uses_remaining") >= get_value("hard_reserve_limit");
	}

	optimization_parameters.metadata = metadata;
	set_value("hp_goal", hp_goal);
	set_value("hp_starting", my_hp());
	set_value("hp_max", my_maxhp());
	set_value("hp_restored_per_use", hp_restored_per_use());
	set_value("hp_uses_needed_for_goal", uses_needed_to_reach_goal("hp"));
	set_value("mp_goal", mp_goal);
	set_value("mp_starting", my_mp());
	set_value("mp_max", my_maxmp());
	set_value("mp_restored_per_use", mp_restored_per_use());
	set_value("mp_uses_needed_for_goal", uses_needed_to_reach_goal("mp"));
	set_value("meat_per_use", meat_per_use());
	set_value("tokens_per_use", tokens_per_use());
	set_value("total_uses_needed", total_uses_needed());
	set_value("total_buyable", total_buyable());
	set_value("total_creatable", total_creatable());
	set_value("soft_reserve_limit", metadata.soft_reserve_limit);
	set_value("hard_reserve_limit", metadata.hard_reserve_limit);
	set_value("total_uses_available", total_uses_available());
	set_value("total_uses_remaining", total_uses_remaining()); // candidate for removal
	set_value("soft_reserve_limit_uses", soft_reserve_limit_uses());
	set_value("hp_max_restorable", max_restorable("hp"));
	set_value("hp_total_restored", total_restored("hp"));
	set_value("hp_total_wasted_goal", blood_adjusted_waste(hp_goal)); // candidate for removal
	set_value("hp_total_short_goal", total_short("hp", hp_goal));
	set_value("hp_total_wasted_max", blood_adjusted_waste(my_maxhp()));
	set_value("hp_total_short_max", total_short("hp", my_maxhp())); // candidate for removal
	set_value("mp_max_restorable", max_restorable("mp"));
	set_value("mp_total_restored", total_restored("mp"));
	set_value("mp_total_wasted_goal", total_wasted("mp", mp_goal)); // candidate for removal
	set_value("mp_total_short_goal", total_short("mp", mp_goal));
	set_value("mp_total_wasted_max", total_wasted("mp", my_maxmp()));
	set_value("mp_total_short_max", total_short("mp", my_maxmp())); // candidate for removal
	set_value("total_mp_used", total_mp_used());
	set_value("total_meat_used", total_meat_used());
	set_value("meat_available_to_spend", meat_available_to_spend());
	set_value("total_coinmaster_tokens_used", total_coinmaster_tokens_used());
	set_value("hp_per_meat_spent", resource_value_per_meat_spent("hp"));
	set_value("hp_per_coinmaster_token_spent", resource_value_per_coinmaster_token_spent("hp"));
	set_value("hp_per_mp_spent", hp_per_mp_spent());
	set_value("mp_per_meat_spent", resource_value_per_meat_spent("mp"));
	set_value("mp_per_coinmaster_token_spent", resource_value_per_coinmaster_token_spent("mp"));
	set_value("is_ever_useable", is_ever_useable());
	set_value("is_currently_useable", is_currently_useable());
	set_value("have_required_resources", have_required_resources());
	set_value("restores_needed_resources", restores_needed_resources());
	set_value("meets_hard_reserve_limit", meets_hard_reserve_limit());
	set_value("blood_skill_opportunity_casts_goal", blood_skill_opportunity_casts(hp_goal));
	set_value("blood_skill_opportunity_casts_max", blood_skill_opportunity_casts(my_maxhp()));
	set_value("negative_status_effects_remaining", negative_status_effects_remaining());

	return optimization_parameters;
}

/**
 * Given a set of hp/mp goals and restoration options, determine which options are available to us and sort them from best to worst. Returns a set of options that the algorithm has determined are "equivalent" in value. Generally this should lead to an obvious best choice but when options are limited you may get several back.
 *
 * Implements a muli-objective optimization algorithm known as Kung's algorithm (not steps 1 and 2 are mostly handled by __calculate_objective_values above):
 *  1) apply a set of functions to each __RestorationMetadata which measure goals we want to minimize or maximize (e.g. total hp restored, mp cost, etc. see __calculate_objective_values)
 *  2) apply a set of constraint functions to remove any __RestorationMetadata which fail to meet baseline criteria (e.g. inaccessible in this path. see __calculate_objective_values)
 *  3) sort the set of available __RestorationMetadata by primary goals we want to maximize (see __PRIMARY_SORT_KEYS) from largest to smallest
 *  4) For each ranking, process the sorted set of __RestorationMetadata removing any dominated options based on the objective values for that rank until we are down to 1 option or a set of "equivalent" options
 *
 * Each value has a rank associated with it which you will find in the __OBJECTIVE_RANKS map. For step 3, the maximization sort, the value is calculated as a simple weighted sum and makes the algorithm in step 4 more efficient. For step 4, determining dominated options, each rank is its own pass over the set of options. This lets us weed out any options that are grossly outmatched in a category we care more about early on so we dont end up with an option that, say, minimizes mp use but ends up spending all your meat buying items. Each pass narrows down our options until we are left only with options that should be more or less equivalent, sorted from most maximized to least maximized (due to the first maximization sort).
 *
 * For more details on multi-objective optimization take a look at:
 *  https://engineering.purdue.edu/~sudhoff/ee630/Lecture09.pdf
 *  http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.206.4467&rep=rep1&type=pdf
 *  https://www.youtube.com/watch?v=LAC212ZwBB4
 *  https://www.youtube.com/watch?v=xLjfa8NXQD8
 *  https://www.youtube.com/watch?v=Hm2LK4vJzRw
 */
__RestorationOptimization[int] __maximize_restore_options(int hp_goal, int mp_goal, int meat_reserve, boolean useFreeRests)
{

	// returns a sublist of p from [start, stop)
	__RestorationOptimization[int] slice(__RestorationOptimization[int] p, int start, int stop)
	{
		__RestorationOptimization[int] subset;
		if(start >= 0 && start <= count(p) && stop >= 0 && stop <= count(p))
		{
			int i = start;
			while(i < stop)
			{
				subset[count(subset)] = p[i];
				i++;
			}
		}
		return subset;
	}

	// returns a copy of p
	__RestorationOptimization[int] copy(__RestorationOptimization[int] p)
	{
		return slice(p, 0, count(p));
	}

	// adds all elements in right to left, does not create a new aggregate. left is returned for convenience
	__RestorationOptimization[int] combine(__RestorationOptimization[int] left, __RestorationOptimization[int] right)
	{
		int i = 0;
		while(i < count(right))
		{
			left[count(left)] = right[i];
			i++;
		}
		return left;
	}

	float weighted_sum(__RestorationOptimization o, boolean[string] keys, int[string] value_ranks)
	{
		float sum = 0.0;
		foreach s, _ in keys
		{
			sum += o.objective_values[s] * value_ranks[s];
		}
		return sum;
	}

	// return a set of ranks for the given keys (e.g. __OBJECTIVE_RANKS) in ascending order
	int[int] ordered_ranks(int[string] weights)
	{
		int[int] unordered;
		boolean[int] value_set;
		foreach s, w in weights
		{
			if(!(value_set contains w))
			{
				value_set[w] = true;
				unordered[count(unordered)] = w;
			}
		}
		sort unordered by value;
		return unordered;
	}

	/**
	* Returns a set of __RestorationOptimization which are not dominated by any other element in the set. In other words it combines T and B into a single set, removing any elements that are demonstrably worse than another element. Naming conventions come from commonly used symbols in the algorithms implementation, so if they feel weird blame mathemeticians.
	*
	* An element is non dominated for a given set of value keys and weights if:
	*  1. the element is no worse in every category than all other elements
	*  2. the element is better than another element in at least one category
	*
	* For a more indepth explaination of dominance/non-dominance see: https://www.youtube.com/watch?v=xLjfa8NXQD8
	*
	* The values are only considered if they match the current rank. This lets us pass over the set multiple times to weed out bad options in phases.
	*
	* Assumptions:
	*  1. All elements in T are non-dominated by each other
	*  2. All elements in B are non-dominated by each other
	*  3. All elements in T and B have already had their relevant objective valus calculated
	*  4. All keys in `maximize_keys` and `minimize_keys` are present in every element of both T and B
	*/
	__RestorationOptimization[int] non_dominated_set(__RestorationOptimization[int] T, __RestorationOptimization[int] B, int[string] value_ranks, int rank, boolean[string] maximize_keys, boolean[string] minimize_keys)
	{
		__RestorationOptimization[int] M;
		boolean[string] dominated;

		int Ti = 0;
		int Bi = 0;

		while(Ti < count(T))
		{
			Bi = 0;
			while(Bi < count(B))
			{
				if(dominated contains B[Bi].metadata.name)
				{
					Bi++;
					continue;
				}

				int T_dominance = 0;
				int B_dominance = 0;
				foreach key, r in value_ranks
				{
					if(r == rank)
					{
						if(T[Ti].objective_values[key] == -1.0 || B[Bi].objective_values[key] == -1.0)
						{
							continue; // -1.0 means the key is not applicable to an option, e.g. hp_per_mp_spent on free rests which dont cost mp
						}
						if(T[Ti].objective_values[key] < B[Bi].objective_values[key])
						{
							if(maximize_keys contains key)
							{
								B_dominance++;
							}
							else if(minimize_keys contains key)
							{
								T_dominance++;
							}
						}
						else if(T[Ti].objective_values[key] > B[Bi].objective_values[key])
						{
							if(maximize_keys contains key)
							{
								T_dominance++;
							}
							else if(minimize_keys contains key)
							{
								B_dominance++;
							}
						}
					}
				}
				
				if(T_dominance > B_dominance)
				{
					dominated[B[Bi].metadata.name] = true;
				}
				else if(B_dominance > T_dominance)
				{
					dominated[T[Ti].metadata.name] = true;
					break;
				}
				Bi++;
			}
			
			if(!(dominated contains T[Ti].metadata.name))
			{
				M[count(M)] = T[Ti];
			}
			else
			{
				auto_log_debug("Removed from consideration: " + to_string(T[Ti], true));
			}
			Ti++;
		}

		Bi = 0;
		while(Bi < count(B))
		{
			if(!(dominated contains B[Bi].metadata.name))
			{
				M[count(M)] = B[Bi];
			}
			else
			{
				auto_log_debug("Removed from consideration: " + to_string(B[Bi], true));
			}
			Bi++;
		}
		return M;
	}

	__RestorationOptimization[int] ranked_optimization(__RestorationOptimization[int] p, int[string] value_ranks, int rank, boolean[string] maximize_keys, boolean[string] minimize_keys)
	{
		if(count(p) == 1)
		{
			return p;
		}
		else
		{
			int mid = floor(count(p)/2);
			__RestorationOptimization[int] T = ranked_optimization(slice(p, 0, mid), value_ranks, rank, maximize_keys, minimize_keys);
			__RestorationOptimization[int] B = ranked_optimization(slice(p, mid, count(p)), value_ranks, rank, maximize_keys, minimize_keys);
			return non_dominated_set(T, B, value_ranks, rank, maximize_keys, minimize_keys);
		}
	}

	__RestorationOptimization[int] ranked_optimization(__RestorationOptimization[int] p, int[string] value_ranks, boolean[string] maximize_keys, boolean[string] minimize_keys)
	{
		auto_log_debug("Beginning optimization of "+count(p)+" restoration options.");
		if(count(p) == 0)
		{
			return p;
		}

		__RestorationOptimization[int] ranked = copy(p);
		int[int] ranks = ordered_ranks(value_ranks);
		auto_log_debug(count(ranked)+" options before optimization: " + to_string(ranked, false));
		foreach _, rank in ranks
		{
			string desc = (__RANKED_GOAL_DESCRIPTIONS contains rank) ?  __RANKED_GOAL_DESCRIPTIONS[rank] : "whoops, someone changed things and didnt update the descriptions. Bad dev.";
			auto_log_debug("Rank " + rank + " optimization, prefer to... " + desc);
			if(count(ranked) <= 1)
			{
				break;
			}
			ranked = ranked_optimization(ranked, value_ranks, rank, maximize_keys, minimize_keys);
		}
		return ranked;
	}

	int partition(__RestorationOptimization[int] p, boolean[string] sort_keys, int[string] value_ranks, int left_index, int right_index)
	{
		int pivot_value = weighted_sum(p[left_index], sort_keys, value_ranks);
		int l = left_index + 1;
		int r = right_index;
		boolean done = false;
		__RestorationOptimization swap;

		while(!done)
		{
			while(l <= r)
			{
				if(weighted_sum(p[l], sort_keys, value_ranks) >= pivot_value)
				{
					l++;
				}
				else
				{
					break;
				}
			}

			while(r >= l)
			{
				if(weighted_sum(p[r], sort_keys, value_ranks) <= pivot_value)
				{
					r--;
				}
				else
				{
					break;
				}
			}

			if(r < l)
			{
				done = true;
			}
			else
			{
				swap = p[l];
				p[l] = p[r];
				p[r] = swap;
			}
		}

		swap = p[left_index];
		p[left_index] = p[r];
		p[r] = swap;

		return r;
	}

	void quick_sort_maximize(__RestorationOptimization[int] p, boolean[string] sort_keys, int[string] value_ranks, int left_index, int right_index)
	{
		if(left_index < right_index)
		{
			int pivot = partition(p, sort_keys, value_ranks, left_index, right_index);
			quick_sort_maximize(p, sort_keys, value_ranks, left_index, pivot-1);
			quick_sort_maximize(p, sort_keys, value_ranks, pivot+1, right_index);
		}
	}

	void quick_sort_maximize(__RestorationOptimization[int] p, boolean[string] sort_keys, int[string] value_ranks)
	{
		auto_log_debug("Sorting "+count(p)+" options by primary objectives.");
		if(count(p) > 1)
		{
			quick_sort_maximize(p, sort_keys, value_ranks, 0, count(p)-1);
		}
	}

	__RestorationOptimization[int] apply_constraints(__RestorationOptimization[int] p, boolean[string] constraint_keys)
	{
		int c = count(p);
		auto_log_debug("Applying constraints to "+c+" objective values.");

		__RestorationOptimization[int] constrained;

		foreach _, o in p
		{
			boolean fail = false;
			foreach c, _ in constraint_keys
			{
				if(!o.constraints[c])
				{
					fail = true;
					break;
				}
			}
			if(!fail)
			{
				constrained[count(constrained)] = o;
			}
		}

		auto_log_debug("Removed  "+(c-count(constrained))+" restore options from consideration.");

		return constrained;
	}

	__RestorationOptimization[int] calculate_objective_values()
	{
		if(count(__restore_maximizer_cache) > 0)
		{
			auto_log_debug("Recalculating cached restore objective values.");
			foreach i, o in __restore_maximizer_cache
			{
				__RestorationOptimization recalculated =
				__restore_maximizer_cache[i] = __calculate_objective_values(hp_goal, mp_goal, meat_reserve, useFreeRests, o.metadata);
			}
		}
		else
		{
			auto_log_debug("Calculating restore objective values.");
			foreach name, metadata in __restoration_methods()
			{
				__RestorationOptimization o = __calculate_objective_values(hp_goal, mp_goal, meat_reserve, useFreeRests, metadata);
				if(o.constraints["is_ever_useable"])
				{
					__restore_maximizer_cache[count(__restore_maximizer_cache)] = o;
				}
			}
		}

		return __restore_maximizer_cache;
	}

	__RestorationOptimization[int] optimized = calculate_objective_values();
	optimized = apply_constraints(optimized, __CONSTRAINT_KEYS);
	quick_sort_maximize(optimized, __PRIMARY_SORT_KEYS, __OBJECTIVE_RANKS);
	return ranked_optimization(optimized, __OBJECTIVE_RANKS, __MAXIMIZE_KEYS, __MINIMIZE_KEYS);
}

boolean __restore(string resource_type, int goal, int meat_reserve, boolean useFreeRests)
{
	int current_resource()
	{
		if(resource_type == "hp")
		{
			return my_hp();
		}
		else if(resource_type == "mp")
		{
			return my_mp();
		}
		return -1;
	}
	
	int max_resource()
	{
		if(resource_type == "hp")
		{
			return my_maxhp();
		}
		else if(resource_type == "mp")
		{
			return my_maxmp();
		}
		return -1;
	}
	
	int hp_target()
	{
		if(resource_type == "hp")
		{
			return goal;
		}
		else
		{
			return my_hp();
		}
	}
	
	int mp_target()
	{
		if(resource_type == "mp")
		{
			return goal;
		}
		else
		{
			return my_mp();
		}
	}
	
	skill pick_blood_skill(int final_hp)
	{
		boolean bloodBondAvailable = auto_have_skill($skill[Blood Bond]) &&
		pathHasFamiliar() &&
		my_maxhp() > hp_cost($skill[Blood Bond]) &&
		final_hp > ((9-hp_regen())*10) && // blood bond drains hp after combat, make sure we dont accidentally kill the player
		get_property("auto_restoreUseBloodBond").to_boolean();
	
		boolean bloodBubbleAvailable = auto_have_skill($skill[Blood Bubble]) &&
		my_maxhp() > hp_cost($skill[Blood Bubble]);

		skill blood_skill = $skill[none];
		if(bloodBondAvailable && bloodBubbleAvailable)
		{
			if(have_effect($effect[Blood Bond]) > have_effect($effect[Blood Bubble]))
			{
				blood_skill = $skill[Blood Bubble];
			}
			else
			{
				blood_skill = $skill[Blood Bond];
			}
		}
		else if(bloodBondAvailable)
		{
			blood_skill = $skill[Blood Bond];
		}
		else if(bloodBubbleAvailable)
		{
			blood_skill = $skill[Blood Bubble];
		}
		return blood_skill;
	}

	boolean use_opportunity_blood_skills(int hp_restored_per_use, int final_hp)
	{
		if (!auto_have_skill($skill[Blood Bond]) && !auto_have_skill($skill[Blood Bubble]))
		{
			return false;
		}
		int restored = my_hp() + hp_restored_per_use;
		int waste = min(my_hp()-1, restored-my_maxhp());
		if(waste <= 0) return true;
		// both blood skills we care about cost 30
		int casts_total = waste / 30;
		if(casts_total <= 0) return true;
		// ratio should be 1 / the number of turns of that effect per cast
		float [skill] skill_ratios;
		float total_ratio = 0.0;
		if(auto_have_skill($skill[Blood Bubble]))
		{
			float bubble_ratio = 1.0 / 3.0;
			skill_ratios[$skill[Blood Bubble]] = bubble_ratio;
			total_ratio += bubble_ratio;
		}
		if(auto_have_skill($skill[Blood Bond]))
		{
			float bond_ratio = 1.0 / 10.0;
			skill_ratios[$skill[Blood Bond]] = bond_ratio;
			total_ratio += bond_ratio;
		}
		int casts_so_far;
		int [skill] to_cast;
		foreach sk, ratio in skill_ratios
		{
			int times_to_cast = floor(casts_total * ratio / total_ratio);
			to_cast[sk] = times_to_cast;
			casts_so_far += times_to_cast;
		}
		if(casts_so_far < casts_total)
		{
			to_cast[pick_blood_skill(final_hp)] += casts_total - casts_so_far;
		}
		boolean success = true;
		foreach sk, times in to_cast
		{
			success &= use_skill(times, sk);
		}
		return success;
	}

	boolean use_restore(__RestorationMetadata metadata, int meat_reserve, boolean useFreeRests)
	{
		if(metadata.name == "")
		{
			return false;
		}

		auto_log_info("Using " + metadata.type + " " + metadata.name + " as restore.", "blue");
		if(metadata.type == "item")
		{
			item i = to_item(metadata.name);
			return retrieve_item(1, i) && use(1, i);
		}

		if(metadata.type == "dwelling")
		{
			return doFreeRest();
		}

		if(metadata.name == __HOT_TUB)
		{
			int pre_soaks = hotTubSoaksRemaining();
			return doHottub() == pre_soaks - 1;
		}

		if(metadata.type == "skill")
		{
			skill s = to_skill(metadata.name);
			if(my_mp() < mp_cost(s) && !acquireMP(mp_cost(s), meat_reserve, useFreeRests))
			{
				auto_log_warning("Couldnt acquire enough MP to cast " + s, "red");
				return false;
			}
			return use_skill(1, s);
		}

		return false;
	}

	string list_to_string(boolean[effect] e_list)
	{
		string s = "[";
		boolean first = true;
		foreach e in e_list
		{
			if(first)
			{
				first = false;
			}
			else
			{
				s += ", ";
			}
			s += e.to_string();
		}
		s += "]";
		return s;
	}

	boolean[effect] negative_effects()
	{
		boolean[effect] negative;
		foreach e, _ in my_effects()
		{
			if(__all_negative_effects contains e)
			{
				negative[e] = true;
			}
		}
		return negative;
	}

	auto_log_info("Target "+resource_type+" => "+goal+" - Considering restore options at " + my_hp() + "/" + my_maxhp() + " HP with " + my_mp() + "/" + my_maxmp() + " MP", "blue");
	auto_log_info("Active Negative Effects => " + list_to_string(negative_effects()));

	while(current_resource() < goal)
	{
		if(goal > max_resource())	//prevent infinite loop in case maxHP or maxMP dropped below goal
		{
			goal = max_resource();
		}
		__RestorationOptimization[int] options = __maximize_restore_options(hp_target(), mp_target(), meat_reserve, useFreeRests);
		if(count(options) == 0)
		{
			auto_log_critical("Target "+resource_type+" => " + goal + " - couldnt determine an effective restoration mechanism", "red");
			if(get_property("auto_ignoreRestoreFailure").to_boolean() || get_property("_auto_ignoreRestoreFailureToday").to_boolean())
			{
				auto_log_critical("Ignoring the error as per user instructions", "red");
 				return false;
			}
			print("Aborting due to restore failure... you can override this setting for today by entering in gCLI:");
			print("set _auto_ignoreRestoreFailureToday = true");
			abort();
		}

		boolean success = false;
		foreach i, o in options
		{
			use_opportunity_blood_skills(o.vars["hp_restored_per_use"], my_hp()+o.vars["hp_total_restored"]);
			success = use_restore(o.metadata, meat_reserve, useFreeRests);
			if(success)
			{
				break;
			}
			else
			{
				auto_log_warning("Target "+resource_type+" => " + goal + " option " + o.metadata.name + " failed. Trying next option (if available).");
			}
		}

		if(!success)
		{
			auto_log_warning("Target "+resource_type+" => " + goal + " - Uh oh. All restore options tried ("+count(options)+") failed. Sorry.", "red");
			return false;
		}
	}
	return true;
}

void __cure_bad_stuff()
{
	foreach e in $effects[Hardly Poisoned at All, A Little Bit Poisoned, Somewhat Poisoned, Really Quite Poisoned, Majorly Poisoned, Toad In The Hole]
	{
		if(have_effect(e) > 0)
		{
			uneffect(e);
		}
	}

	// let mafia figure out how to best remove beaten up
	if(have_effect($effect[Beaten Up]) > 0){
		auto_log_info("Ouch, you got beaten up. Lets get you patched up, if we can.");
		uneffect($effect[Beaten Up]);

		if(have_effect($Effect[Beaten Up]) > 0){
			auto_log_warning("Well, you're still beaten up, thats probably not great...", "red");
		}
	}
}

/**
 * Public Interface
 */

void invalidateRestoreOptionCache()
{
	clear(__known_restoration_sources);
	clear(__restore_maximizer_cache);
}


/**
 * Try to acquire your max mp (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= my_maxmp() after attempting to restore.
 */
boolean acquireMP()
{
	return acquireMP(min(0.95 * my_maxmp(),300));
}

/**
 * Try to acquire up to the mp goal (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goal after attempting to restore.
 */
boolean acquireMP(int goal)
{
	return acquireMP(goal, meatReserve());
}

/**
 * Try to acquire up to the mp goal, optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goal after attempting to restore.
 */
boolean acquireMP(int goal, int meat_reserve)
{
	return acquireMP(goal, meat_reserve, true);
}

/**
 * Try to acquire up to the mp goal, optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goal after attempting to restore.
 */
boolean acquireMP(int goal, int meat_reserve, boolean useFreeRests)
{
	//vampyres don't use MP
	if(my_class() == $class[Vampyre])
	{
		return false;
	}

	boolean isMax = (goal == my_maxmp());

	__cure_bad_stuff();

	if(isMax)
	{
		goal = my_maxmp(); //in case max rose after curing the bad stuff
	}
	else if(goal > my_maxmp())
	{
		return false;
	}
	else if(my_mp() >= goal)
	{
		return true;
	}

	// Sausages restore 999MP, this is a pretty arbitrary cutoff but it should reduce pain
	// TODO: move this to general effectiveness method
	if(my_maxmp() - my_mp() > 300)
	{
		if (!auto_sausageBlocked())
		{
			if(item_amount($item[magical sausage]) < 1 && get_property("_sausagesMade").to_int() < 23)
			{
				auto_sausageGrind(1);
			}
			auto_sausageEatEmUp(1);		//this involve outfit changes which can lower our maxMP to below what goal was. which would cause infinite loop
			goal = min(goal, my_maxmp());
		}
	}
	__restore("mp", goal, meat_reserve, useFreeRests);
	return (my_mp() >= goal);
}

/**
 * Try to acquire up to the mp goal expressed as a percentage (out of either 1.0 or 100.0) (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goalPercent after attempting to restore.
 */
boolean acquireMP(float goalPercent)
{
	return acquireMP(goalPercent, meatReserve());
}

/**
 * Try to acquire up to the mp goal expressed as a percentage, optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goalPercent after attempting to restore.
 */
boolean acquireMP(float goalPercent, int meat_reserve)
{
	return acquireMP(goalPercent, meat_reserve, true);
}

/**
 * Try to acquire up to the mp goal expressed as a percentage (out of either 1.0 or 100.0), optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goalPercent after attempting to restore.
 */
boolean acquireMP(float goalPercent, int meat_reserve, boolean useFreeRests)
{
	int goal = my_maxmp();
	if(goalPercent > 1.0){
		goal = ceil((goalPercent/100.0) * my_maxmp());
	} else{
		goal = ceil(goalPercent*my_maxmp());
	}
	return acquireMP(goal.to_int(), meat_reserve, useFreeRests);
}

/**
 * Try to acquire your max hp (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= my_maxhp() after attempting to restore.
 */
boolean acquireHP()
{
	return acquireHP(my_maxhp());
}

/**
 * Try to acquire up to the hp goal (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goal after attempting to restore.
 */
boolean acquireHP(int goal)
{
	return acquireHP(goal, meatReserve());
}

/**
 * Try to acquire up to the hp goal, optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goal after attempting to restore.
 */
boolean acquireHP(int goal, int meat_reserve)
{
	return acquireHP(goal, meat_reserve, true);
}

boolean acquireHP(int goal, int meat_reserve, boolean useFreeRests)
{
	//Try to acquire up to the hp goal, optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any hp.
	//returns true if my_hp() >= goal after attempting to restore.

	if(isActuallyEd())
	{
		return edAcquireHP();
	}

	//vampyres can only be restored using blood bags, which are too valuable to waste on healing HP.
	//better to make food/drink from them and then rest in your coffin
	if(my_class() == $class[Vampyre])
	{
		return false;
	}
	
	//owning a hand in glove breaks maxHP tracking. need to check possession rather than equipped because unequipping it also breaks it. in fact it causes us to get stuck in an infinite loop of trying to restore hp when already at max HP.
	//mafia devs think it is actually a kol bug so they won't fix it. https://kolmafia.us/showthread.php?25214
	if(possessEquipment($item[Hand in Glove]))
	{
		int initial_maxHP = my_maxhp();
		cli_execute("refresh status");
		if(initial_maxHP == my_maxhp())
		{
			auto_log_debug("I just refreshed status because I detected [Hand in Glove]. But it turned out to not have been necessary");
		}
		else
		{
			auto_log_debug("I just refreshed status because I detected [Hand in Glove] and it corrected my maxHP value. This prevented an infinite loop");
		}
	}

	boolean isMax = (goal == my_maxhp());

	__cure_bad_stuff();

	if(isMax)
	{
		goal = my_maxhp(); //in case max rose after curing the bad stuff
	}
	else if(goal > my_maxhp())
	{
		return false;
	}
	else if(my_hp() >= goal*0.95)
	{
		return true;
	}

	if(in_boris())
	{
		return borisAcquireHP(goal);
	}
	if (my_class() == $class[Plumber])
	{
		while (my_hp() < goal && my_hp() < my_maxhp() && item_amount($item[coin]) > 400)
		{
			retrieve_item(1, $item[super deluxe mushroom]);
			use(1, $item[super deluxe mushroom]);
		}
	}
	else
	{
		__restore("hp", goal, meat_reserve, useFreeRests);
	}

	return my_hp() >= goal;
}

/**
 * Try to acquire up to the hp goal expressed as a percentage (out of either 1.0 or 100.0) (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goalPercent after attempting to restore.
 */
boolean acquireHP(float goalPercent)
{
	return acquireHP(goalPercent, meatReserve());
}

/**
 * Try to acquire up to the hp goal expressed as a percentage (out of either 1.0 or 100.0), optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goalPercent after attempting to restore.
 */
boolean acquireHP(float goalPercent, int meat_reserve)
{
	return acquireHP(goalPercent, meat_reserve, true);
}

/**
 * Try to acquire up to the hp goal expressed as a percentage (out of either 1.0 or 100.0), optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goalPercent after attempting to restore.
 */
boolean acquireHP(float goalPercent, int meat_reserve, boolean useFreeRests)
{
	int goal = my_maxhp();
	if(goalPercent > 1.0){
		goal = ceil((goalPercent/100.0) * my_maxhp());
	} else{
		goal = ceil(goalPercent*my_maxhp());
	}
	return acquireHP(goal.to_int(), meat_reserve, useFreeRests);
}

/*
 * Use a rest (can consume adventures if no free rests remain). Also attempts to maximize
 * chateau bonus from resting if possible.
 *
 * TODO: if resting in campaway camp, check if we can/should use a burnt stick to get extra stats
 *
 * returns the number of times rested today (caller will have to work out if it rested or not)
 */
int doRest()
{
	if(chateaumantegna_available())
	{
		cli_execute("outfit save Backup");
		chateaumantegna_nightstandSet();

		boolean[item] restBonus = chateaumantegna_decorations();
		stat bonus = $stat[none];
		if(restBonus contains $item[Electric Muscle Stimulator])
		{
			bonus = $stat[Muscle];
		}
		else if(restBonus contains $item[Foreign Language Tapes])
		{
			bonus = $stat[Mysticality];
		}
		else if(restBonus contains $item[Bowl of Potpourri])
		{
			bonus = $stat[Moxie];
		}

		boolean closet = false;
		item grab = $item[none];
		item replace = $item[none];
		switch(bonus)
		{
		case $stat[Muscle]:
			replace = equipped_item($slot[off-hand]);
			grab = $item[Fake Washboard];
			if(can_equip($item[LOV Eardigan]) && (item_amount($item[LOV Eardigan]) > 0))
			{
				equip($slot[shirt], $item[LOV Eardigan]);
			}
			break;
		case $stat[Mysticality]:
			replace = equipped_item($slot[off-hand]);
			grab = $item[Basaltamander Buckler];
			if(can_equip($item[LOV Epaulettes]) && (item_amount($item[LOV Epaulettes]) > 0))
			{
				equip($slot[back], $item[LOV Epaulettes]);
			}
			break;
		case $stat[Moxie]:
			replace = equipped_item($slot[weapon]);
			grab = $item[Backwoods Banjo];
			if(can_equip($item[LOV Earrings]) && (item_amount($item[LOV Earrings]) > 0))
			{
				equip($slot[acc1], $item[LOV Earrings]);
			}
			break;
		}

		if((grab != $item[none]) && possessEquipment(grab) && (replace != grab) && can_equip(grab))
		{
			equip(grab);
		}
		if(!possessEquipment(grab) && (replace != grab) && (closet_amount(grab) > 0) && can_equip(grab))
		{
			closet = true;
			take_closet(1, grab);
			equip(grab);
		}

		visit_url("place.php?whichplace=chateau&action=chateau_restbox");

		if((replace != grab) && (replace != $item[none]))
		{
			equip(replace);
		}
		cli_execute("outfit Backup");
		if(closet)
		{
			if(item_amount(grab) > 0)
			{
				put_closet(1, grab);
			}
		}

	}
	else
	{
		set_property("restUsingChateau", false);
		cli_execute("rest");
		set_property("restUsingChateau", true);
	}
	return get_property("timesRested").to_int();
}

boolean haveFreeRestAvailable(){
	return get_property("timesRested").to_int() < total_free_rests();
}

int freeRestsRemaining(){
	return max(0, total_free_rests() - get_property("timesRested").to_int());
}

boolean haveAnyIotmAlternativeRestSiteAvailable(){
	return chateaumantegna_available() || auto_campawayAvailable();
}

/*
 * Try to use a free rest.
 *
 * returns true if a rest was used false if it wasnt (for any reason)
 */
boolean doFreeRest(){
	if(haveFreeRestAvailable()){
		int rest_count = get_property("timesRested").to_int();
		return doRest() > rest_count;
	}
	return false;
}

float mp_regen()
{
	return 0.5 * (numeric_modifier("MP Regen Min") + numeric_modifier("MP Regen Max"));
}

float hp_regen()
{
	return 0.5 * (numeric_modifier("HP Regen Min") + numeric_modifier("HP Regen Max"));
}

boolean uneffect(effect toRemove)
{
	if(have_effect(toRemove) == 0)
	{
		return true;
	}
	if(($effects[Driving Intimidatingly, Driving Obnoxiously, Driving Observantly, Driving Quickly, Driving Recklessly, Driving Safely, Driving Stealthily, Driving Wastefully, Driving Waterproofly] contains toRemove) && (auto_get_campground() contains $item[Asdon Martin Keyfob]))
	{
		visit_url("campground.php?pwd=&preaction=undrive");
		return true;
	}

	if(cli_execute("uneffect " + toRemove))
	{
		//Either we don\'t have the effect or it is shruggable.
		return true;
	}

	if(item_amount($item[Soft Green Echo Eyedrop Antidote]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		auto_log_info("Effect removed by Soft Green Echo Eyedrop Antidote.", "blue");
		return true;
	}
	else if(item_amount($item[Ancient Cure-All]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		auto_log_info("Effect removed by Ancient Cure-All.", "blue");
		return true;
	}
	return false;
}

/**
 * we could in theory set this as our restore script, but autoscend is not currently designed to heal this way and changing this now would probably break assumptions people have anticipated in their code, causing undefined behavior. I assume this is why we have the warning about autoscend not playing well with restore scripts and disabling them when it starts.
 *
 * Additionally this script would require some number of imports of other methods (mostly auto_util.ash) which may or may not be easy to do. I did try once by just importing autoscend, but I ended up with an infinite loop. At least thats what it seemed like, I didnt try very hard to make it work. My understanding of ash leads me to believe it should work and I was just doing something stupid. So for now this is just here for posterity.
 */
boolean main(string type, int amount)
{
	if(type == "MP")
	{
		acquireMP(amount);
	}
	else if(type == "HP")
	{
		acquireHP(amount);
	}
	return true;	// This ensures that mafia does not attempt to heal with resources that are being conserved.
}
