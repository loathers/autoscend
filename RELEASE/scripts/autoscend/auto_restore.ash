script "auto_restore.ash";

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
  int hp_restored;
  string restores_variable_hp;
  int mp_restored;
  string restores_variable_mp;
  boolean removes_beaten_up;
  boolean[effect] removes_effects;
  boolean[effect] gives_effects;
  int[string] maxima_values;
};


// Holds values used to determine a restoration option's efficacy
record __RestorationOptimization{
  __RestorationMetadata metadata;
  int[string] vars;             // cache, not used for optimization
  int[string] maxima_values;    // values to maximize
  int[string] minima_values;    // values to minimize
  boolean[string] constraints;  // constraints that much be met, all must be true
};

// Real ugly to_string, probably only enable for debugging
string to_string(__RestorationMetadata r){
  string list_to_string(boolean[effect] e_list){
    string s = "[";
    boolean first = true;
    foreach e in e_list{
      if(first){
        first = false;
      } else{
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

string to_string(__RestorationOptimization o, boolean simple){

  string list_to_string(int[string] values){
    string s = "{";
    boolean first = true;
    foreach k, v in values{
      if(first){
        first = false;
      } else {
        s += ", ";
      }
      s += k + ": " + v;
    }
    s += "}";
    return s;
  }

  string list_to_string(boolean[string] values){
    string s = "{";
    boolean first = true;
    foreach k, v in values{
      if(first){
        first = false;
      } else {
        s += ", ";
      }
      s += k + ": " + v;
    }
    s += "}";
    return s;
  }

  if(simple){
    return "("+o.metadata.name + ", hp: " + o.maxima_values["hp_total_restored"] + ", mp: " + o.maxima_values["mp_total_restored"] + ")";
  }

  string vars_str = list_to_string(o.vars);
  string constraints_str = list_to_string(o.constraints);
  string maxima_values_str = list_to_string(o.maxima_values);
  string minima_values_str = list_to_string(o.minima_values);
  return "__RestorationOptimization(name: "+o.metadata.name+", vars: "+vars_str+", constraints: "+constraints_str+", maxima_values: "+maxima_values_str+", minima_values: "+minima_values_str+")";
}

string to_string(__RestorationOptimization[int] optima, boolean simple){
  string val = "";
  boolean first = true;
  foreach i, o in optima{
    if(first){
      first = false;
    } else{
      val += "; ";
    }
    val += i + " - " + to_string(o, simple);
  }
  return val;
}

static boolean[effect] __all_negative_effects = $effects[Beaten Up]; //not really used yet
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
void __init_restoration_metadata(){
  static string resotration_filename = "autoscend_restoration.txt";

  boolean[effect] parse_effects(string name, string effects_list){
    effects_list = effects_list.to_lower_case();
    boolean[effect] parsed_effects;

    if(effects_list == "all negative"){
      parsed_effects = __all_negative_effects;
    } else if(effects_list != "none" && effects_list != ""){
      foreach _, s in split_string(effects_list, ","){
        effect e = to_effect(s);
        if(e != $effect[none]){
          parsed_effects[e] = true;
        } else{
          print("Unknown effect found parsing restoration metadata: " + name + " removes effect: " + s);
        }
      }
    }

    return parsed_effects;
  }

  int parse_restored_amount(string restored_str){
    restored_str = restored_str.to_lower_case();
    if(restored_str == "all" || restored_str == "half" || restored_str == "scaling"){
      return 0;
    } else{
      return to_int(restored_str);
    }
  }

  string parse_restores_variable(string restored_str){
    restored_str = restored_str.to_lower_case();
    if(restored_str == "all"){
      return __RESTORE_ALL;
    } else if(restored_str == "half"){
      return __RESTORE_HALF;
    } else if(restored_str == "scaling"){
      return __RESTORE_SCALING;
    }
    return "";
  }

  void init(){
    record intermediate_record{
      string name;
      string type;
      string hp_restored;
      string mp_restored;
      string removes_effects;
      string gives_effects;
    };

    intermediate_record[int] raw_records;
    file_to_map(resotration_filename, raw_records);

    __RestorationMetadata[string] parsed_records;

    foreach i, r in raw_records{
      __RestorationMetadata parsed;
      parsed.name = r.name.to_lower_case();
      parsed.type = r.type.to_lower_case();
      parsed.hp_restored = parse_restored_amount(r.hp_restored);
      parsed.restores_variable_hp = parse_restores_variable(r.hp_restored);
      parsed.mp_restored = parse_restored_amount(r.mp_restored);
      parsed.restores_variable_mp = parse_restores_variable(r.mp_restored);
      parsed.removes_effects = parse_effects(parsed.name, r.removes_effects);
      parsed.removes_beaten_up = (parsed.removes_effects contains $effect[Beaten Up]);
      parsed.gives_effects = parse_effects(parsed.name, r.gives_effects);

      __known_restoration_sources[parsed.name] = parsed;
    }
  }

  print("Loading restoration data.");
  init();
  clear(__restore_maximizer_cache);
}

/**
 * Safe way to access __known_restoration_sources, ensuring it is initialized if not already.
 */
__RestorationMetadata[string] __restoration_methods(){
  if(count(__known_restoration_sources) == 0){
    __init_restoration_metadata();
  }
  return __known_restoration_sources;
}


int[string] __MAXIMIZE_VALUES ={
  "total_uses_available": 4,
  "hp_total_restored": 2,
  "mp_total_restored": 2
};
int[string] __MINIMIZE_VALUES = {
  "total_uses_needed": 1,
  "hp_total_wasted": 2,
  "hp_total_short": 1,
  "mp_total_wasted": 3,
  "mp_total_short": 1,
  "total_mp_used": 4,
  "total_meat_used": 4,
  "total_coinmaster_tokens_used": 5
};
int[string] __VARS_VALUES = {
  "hp_goal": 0, // the "weight" here is mostly for posterity, not actually used
  "hp_starting": 0,
  "hp_max": 0,
  "hp_restored_per_use": 0,
  "hp_uses_needed_for_goal": 0,
  "mp_goal": 0,
  "mp_starting": 0,
  "mp_max": 0,
  "mp_restored_per_use": 0,
  "mp_uses_needed_for_goal": 0
};
boolean[string] __CONSTRAINT_VALUES = {
  "is_ever_useable": true,
  "is_currently_useable": true,
  "have_required_resources": true,
  "restores_needed_resources": true
};

/**
 * Precalculate values we will later use to narrow down our restoration options to the most effective and least costly.
 *
 * Most future work adding new restore methods should hopefully just need to add new fields to __MAXIMIZE_VALUES, __MINIMIZE_VALUES or __CONSTRAINT_VALUES and set them appropriately here. The optimization algorithm itself shouldnt need to be changed.
 *
 *  __MAXIMIZE_VALUES is the set of keys and weights used to maximize an options value (e.g. amount of hp restored), values for a restore method are stored in __RestorationOptimization.maxima_values for later use.
 *  __MINIMIZE_VALUES is the set of keys and weights used to minimize an options cost (e.g. meat spent), values for a restore method are stored in __RestorationOptimization.minima_values for later use.
 *  __CONSTRAINT_VALUES is the set of keys used to remove options that are not available to the player (e.g. skill not available in current path), __RestorationOptimization.constraints stores whether the constrain was met or not. All contstrains must be true or the option will be removed from consideration.
 *  __VARS_VALUES is simply a cache so we dont have to recalculate values over and over, it is not used in the optimization algorithm but can be useful for debugging.
 */
__RestorationOptimization __calculate_objective_values(int hp_goal, int mp_goal, boolean buyItems, boolean useFreeRests, __RestorationMetadata metadata){
  __RestorationOptimization optimization_parameters;

  void set_value(string name, int value){
    if(__MAXIMIZE_VALUES contains name ){
      optimization_parameters.maxima_values[name] = value;
    } else if(__MINIMIZE_VALUES contains name){
      optimization_parameters.minima_values[name] = value;
    } else if(__VARS_VALUES contains name){
      optimization_parameters.vars[name] = value;
    }
  }

  void set_value(string name, boolean value){
    if(__CONSTRAINT_VALUES contains name){
      optimization_parameters.constraints[name] = value;
    }
  }

  int get_value(string name){
    if(__MAXIMIZE_VALUES contains name){
      return optimization_parameters.maxima_values[name];
    } else if(__MINIMIZE_VALUES contains name){
      return optimization_parameters.minima_values[name];
    } else if(__VARS_VALUES contains name){
      return optimization_parameters.vars[name];
    }
    return 0;
  }

  int get_value(string resource_type, string name){
    return get_value(resource_type + "_" + name);
  }

  int hp_restored_per_use(){
    int restored_amount = metadata.hp_restored;
    if(metadata.restores_variable_hp == __RESTORE_ALL){
      restored_amount = my_maxhp();
    } else if(metadata.restores_variable_hp == __RESTORE_HALF){
      restored_amount = floor(my_maxhp() / 2);
    }

    if(metadata.type == "dwelling"){
      restored_amount += numeric_modifier("Bonus Resting HP");
    }

    return restored_amount;
  }

  int mp_restored_per_use(){
    int restored_amount = metadata.mp_restored;
    if(metadata.restores_variable_mp == __RESTORE_ALL){
      restored_amount = my_maxmp();
    } else if(metadata.restores_variable_mp == __RESTORE_HALF){
      restored_amount = floor(my_maxmp() / 2);
    } else if(metadata.restores_variable_mp == __RESTORE_SCALING){
      if(metadata.name == "magical mystery juice"){
        restored_amount = my_level() * 1.5 + 5;
      } else if(metadata.name == "generic mana potion"){
        restored_amount = my_level() * 2.5;
      }
    }

    if(metadata.type == "dwelling"){
      restored_amount += numeric_modifier("Bonus Resting MP");
    }

    return restored_amount;
  }

  int uses_needed_to_reach_goal(string resource_type){
    int goal = get_value(resource_type, "goal");
    int starting = get_value(resource_type, "starting");
    int per_use = get_value(resource_type, "restored_per_use");

    if(per_use < 1){
      return 0;
    }
    return max(ceil((goal - starting) / per_use), 1);
  }

  int total_uses_needed(){
    return max(get_value("hp", "uses_needed_for_goal"), get_value("mp", "uses_needed_for_goal"));
  }

  int total_uses_available(){
    if(metadata.type == "dwelling"){
      return freeRestsRemaining();
    } else if(metadata.type == "item"){
      return available_amount(to_item(metadata.name)); //I believe this will take coinmasters into consideration for us
    } else if(metadata.type == "skill"){
      return floor(get_value("mp_starting") / mp_cost(to_skill(metadata.name)));
    } else if(metadata.name == __HOT_TUB){
      return hotTubSoaksRemaining();
    }
    return 0;
  }

  int total_restored(string resource_type){
    int uses = min(get_value("total_uses_needed"), get_value("total_uses_available"));
    return uses * get_value(resource_type, "restored_per_use");
  }

  int total_wasted(string resource_type){
    int restorable = get_value(resource_type, "max") - get_value(resource_type, "starting");
    int restored = get_value(resource_type, "total_restored");
    return max(0, restored-restorable);
  }

  int total_short(string resource_type){
    int restorable = get_value(resource_type, "goal") - get_value(resource_type, "starting");
    int restored = get_value(resource_type, "total_restored");
    if(restored >= restorable){
      return 0;
    }
    return restorable - restored;
  }

  int total_mp_used(){
    if(metadata.type != "skill"){
      return 0;
    }
    return total_uses_needed() * mp_cost(to_skill(metadata.name));
  }

  int total_meat_used(){
    if(metadata.type != "item"){
      return 0;
    }
    item i = to_item(metadata.name);
    int needed = max(0, total_uses_needed() - item_amount(i));
    int price = npc_price(i);
    if(can_interact()){
      price = min(price, auto_mall_price(i));
    }
    return price * needed;
  }

  int total_coinmaster_tokens_used(){
    if(metadata.type != "item"){
      return 0;
    }
    item i = to_item(metadata.name);

    if(i.seller != $coinmaster[none]){
      return 0;
    }

    int needed = max(0, total_uses_needed() - item_amount(i));
    int price = sell_price(i.seller, i);

    return needed * price;
  }

  boolean is_ever_useable(){
    if(metadata.type == "item"){
      item i = to_item(metadata.name);
      return auto_is_valid(i);
    }
    if(metadata.type == "skill"){
      return auto_is_valid(to_skill(metadata.name));
    }
    if(metadata.type == "dwelling"){
      item d = to_item(metadata.name);
      return (d == $item[Chateau Mantegna Room Key] && chateaumantegna_available()) ||
        (d == $item[Distant Woods Getaway Brochure] && auto_campawayAvailable()) ||
        (d == get_dwelling() && !(chateaumantegna_available() || auto_campawayAvailable()));
    }
    if(metadata.name == __HOT_TUB){
      return isHotTubAvailable();
    }
    return true;
  }

  boolean is_currently_useable(){
    if(metadata.type == "item"){
      item i = to_item(metadata.name);
      boolean npc_buyable = npc_price(i) > 0 || (i.seller != $coinmaster[none] && inaccessible_reason(i.seller) == "" && get_property("autoSatisfyWithCoinmasters").to_boolean());
      boolean mall_buyable = can_interact() && auto_mall_price(i) > 0;
      boolean can_buy = buyItems && (npc_buyable || mall_buyable);
      return (available_amount(i) > 0 || can_buy);
    }
    if(metadata.type == "skill"){
      return auto_have_skill(to_skill(metadata.name));
    }
    if(metadata.type == "dwelling"){
      return useFreeRests;
    }
    return true;
  }

  boolean have_required_resources(){
    if(metadata.type == "skill" && my_maxmp() < mp_cost(to_skill(metadata.name))){
      return false;
    }
    if(get_value("total_mp_used") > 0){
      return true; //could maybe be smarter about determining if its possible to acquire extra mp or not, for now just assume we have mp available
    }
    if(get_value("total_meat_used") > my_meat()){
      return false;
    }
    if(get_value("total_coinmaster_tokens_used") > 0 && get_value("total_coinmaster_tokens_used") > to_item(metadata.name).seller.available_tokens){
      return false;
    }
    return get_value("total_uses_needed") >= get_value("total_uses_needed");
  }

  boolean restores_needed_resources(){
    if(hp_goal > my_hp() && get_value("hp_restored_per_use") == 0){
      return false;
    }
    if(mp_goal > my_mp() && get_value("mp_restored_per_use") == 0){
      return false;
    }
    return true;
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
  set_value("total_uses_needed", total_uses_needed());
  set_value("total_uses_available", total_uses_available());
  set_value("hp_total_restored", total_restored("hp"));
  set_value("hp_total_wasted", total_wasted("hp"));
  set_value("hp_total_short", total_short("hp"));
  set_value("mp_total_restored", total_restored("mp"));
  set_value("mp_total_wasted", total_wasted("mp"));
  set_value("mp_total_short", total_short("mp"));
  set_value("total_mp_used", total_mp_used());
  set_value("total_meat_used", total_meat_used());
  set_value("total_coinmaster_tokens_used", total_coinmaster_tokens_used());
  set_value("is_ever_useable", is_ever_useable());
  set_value("is_currently_useable", is_currently_useable());
  set_value("have_required_resources", have_required_resources());
  set_value("restores_needed_resources", restores_needed_resources());


  return optimization_parameters;
}

/**
 * Given a set of hp/mp goals and restoration options, determine which options are available to us and sort them from best to worst. Returns a set of options that the algorithm has determined are "equivalent" in value.
 *
 * Implements a muli-objective optimization algorithm known as Kung's algorithm (not steps 1 and 2 are mostly handled by ):
 *  1) apply a set of functions to each __RestorationMetadata which measure goals we want to minimize or maximize (e.g. total hp restored, mp cost, etc. see __calculate_objective_values)
 *  2) apply a set of constraint functions to remove any __RestorationMetadata which fail to meet baseline criteria (e.g. inaccessible in this path. see __calculate_objective_values)
 *  3) sort the set of available __RestorationMetadata by goals we want to maximize (see __MAXIMIZE_VALUES) from largest to smallest
 *  4) recursively process the sorted set of __RestorationMetadata removing any dominated options
 *
 * Each value has a weight associated with it which you will find in the relevant __MAXIMIZE_VALUES and __MINIMIZE_VALUES maps. For step 3, the maximization sort, the value is calculated as a simple weighted sum. For step 4, determining dominated options, each weight is its own pass over the set of options. This lets us weed out any options that are grossly outmatched in a heavily weighted category early on so we dont end up with an option that, say, minimizes mp use but ends up spending all your hard earned and valuable filthy lucre (bad example but hopefully it illustrates my point). Each pass narrows down our options until we are left only with options that should be more or less equivalent, sorted from most maximized to least maximized (due to the first maximization sort).
 *
 * For more details on multi-objective optimization take a look at:
 *  https://engineering.purdue.edu/~sudhoff/ee630/Lecture09.pdf
 *  http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.206.4467&rep=rep1&type=pdf
 *  https://www.youtube.com/watch?v=LAC212ZwBB4
 *  https://www.youtube.com/watch?v=xLjfa8NXQD8
 *  https://www.youtube.com/watch?v=Hm2LK4vJzRw
 */
__RestorationOptimization[int] __maximize_restore_options(int hp_goal, int mp_goal, boolean buyItems, boolean useFreeRests){

  // returns a sublist of p from [start, stop)
  __RestorationOptimization[int] slice(__RestorationOptimization[int] p, int start, int stop){
    __RestorationOptimization[int] subset;
    if(start >= 0 && start <= count(p) && stop >= 0 && stop <= count(p)){
      int i = start;
      while(i < stop){
        subset[count(subset)] = p[i];
        i++;
      }
    }
    return subset;
  }

  // returns a copy of p
  __RestorationOptimization[int] copy(__RestorationOptimization[int] p){
    return slice(p, 0, count(p));
  }

  // adds all elements in right to left, does not create a new aggregate. left is returned for convenience
  __RestorationOptimization[int] combine(__RestorationOptimization[int] left, __RestorationOptimization[int] right){
    int i = 0;
    while(i < count(right)){
      left[count(left)] = right[i];
      i++;
    }
    return left;
  }

  int weighted_sum(__RestorationOptimization o, int[string] maxima){
    int sum = 0;
    foreach s, _ in maxima{
      sum += o.maxima_values[s] * maxima[s];
    }
    return sum;
  }

  int[int] rank_ordered_weights(int[string] weights){
    int[int] unordered;
    boolean[int] value_set;
    foreach s, w in weights{
      if(!(value_set contains w)){
        value_set[w] = true;
        unordered[count(unordered)] = w;
      }
    }
    sort unordered by -value;
    return unordered;
  }

  /**
   * Returns a set of __RestorationOptimization which are not dominated by any other element in the set. In other words it combines T and B into a single set, removing any elements that are demonstrably worse than another element.
   *
   * An element is non dominated for a given set of minima keys and weights if:
   *  1. the element is no worse in every category than all other elements
   *  2. the element is better than another element in at least one category
   *
   * For a more indepth explaination of dominance/non-dominance see: https://www.youtube.com/watch?v=xLjfa8NXQD8
   *
   * Assumptions:
   *  1. All elements in T are non-dominated by each other
   *  2. All elements in B are non-dominated by each other
   *  3. All elements in T and B have already had their relevant minima valus calculated
   *  3. All keys in `minima` are present in every element of both T and B
   */
  __RestorationOptimization[int] non_dominated_set(__RestorationOptimization[int] T, __RestorationOptimization[int] B, int[string] minima, int weight){
    __RestorationOptimization[int] M;
    boolean[string] dominated;

    int Ti = 0;
    int Bi = 0;
    boolean Ti_dominated = false;
    boolean Bi_dominated = false;

    while(Ti < count(T)){
      Bi = 0;
      while(Bi < count(B)){
        if(dominated contains B[Bi].metadata.name){
          Bi++;
          continue;
        }

        int T_dominance = 0;
        int B_dominance = 0;
        foreach key, _ in minima {
          if(minima[key] == weight && T[Ti].minima_values[key] > B[Bi].maxima_values[key]){
            B_dominance++;
          } else if(minima[key] == weight && T[Ti].minima_values[key] < B[Bi].maxima_values[key]){
            T_dominance++;
          }
        }
        if(T_dominance > B_dominance){ // T dominated B, continue checking same Ti against the rest of B
          dominated[B[Bi].metadata.name] = true;
        } else if(B_dominance > T_dominance){ // B dominated T, start checking next Ti against this Bi
          dominated[T[Ti].metadata.name] = true;
        }
        Bi++;
      }
      if(!(dominated contains T[Ti].metadata.name)){
        M[count(M)] = T[Ti];
      }
      Ti++;
    }

    Bi = 0;
    while(Bi < count(B)){
      if(!(dominated contains B[Bi].metadata.name)){
        M[count(M)] = B[Bi];
      }
      Bi++;
    }
    return M;
  }

  __RestorationOptimization[int] ranked_weighted_optimization(__RestorationOptimization[int] p, int[string] minima, int weight){
    if(count(p) == 1){
      return p;
    } else{
      int mid = floor(count(p)/2);
      __RestorationOptimization[int] T = ranked_weighted_optimization(slice(p, 0, mid), minima, weight);
      __RestorationOptimization[int] B = ranked_weighted_optimization(slice(p, mid, count(p)), minima, weight);
      return non_dominated_set(T, B, minima, weight);
    }
  }

  __RestorationOptimization[int] ranked_weighted_optimization(__RestorationOptimization[int] p, int[string] minima){
    auto_debug_print("Beginning restoration optimization of "+count(p)+" options (minimize costs and waste)");
    if(count(p) == 0){
      return p;
    }

    __RestorationOptimization[int] ranked = copy(p);
    int[int] weights = rank_ordered_weights(minima);
    foreach _, weight in weights {
      ranked = ranked_weighted_optimization(ranked, minima, weight);
      auto_debug_print("Rank " + weight + " optimization ("+count(ranked)+" options): " + to_string(ranked, true));
      if(count(ranked) <= 1){
        break;
      }
    }
    return ranked;
  }

  int partition(__RestorationOptimization[int] p, int[string] maxima, int left_index, int right_index){
    int pivot_value = weighted_sum(p[left_index], maxima);
    int l = left_index + 1;
    int r = right_index;
    boolean done = false;
    __RestorationOptimization swap;

    while(!done){
      while(l <= r){
        if(weighted_sum(p[l], maxima) >= pivot_value){
          l++;
        } else{
          break;
        }
      }

      while(r >= l){
        if(weighted_sum(p[r], maxima) <= pivot_value){
          r--;
        } else{
          break;
        }
      }

      if(r < l){
        done = true;
      } else{
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

  void quick_sort_maximize(__RestorationOptimization[int] p, int[string] maxima, int left_index, int right_index){
    if(left_index < right_index){
      int pivot = partition(p, maxima, left_index, right_index);
      quick_sort_maximize(p, maxima, left_index, pivot-1);
      quick_sort_maximize(p, maxima, pivot+1, right_index);
    }
  }

  void quick_sort_maximize(__RestorationOptimization[int] p, int[string] maxima){
    auto_debug_print("Sorting "+count(p)+" options by maximization objectives.");
    quick_sort_maximize(p, maxima, 0, count(p)-1);
  }

  __RestorationOptimization[int] apply_constraints(__RestorationOptimization[int] p, boolean[string] constraints){
    int c = count(p);
    auto_debug_print("Applying constraints to "+c+" objective values.");

    __RestorationOptimization[int] constrained;

    foreach _, o in p{
      boolean fail = false;
      foreach c, _ in constraints{
        if(!o.constraints[c]){
          fail = true;
          break;
        }
      }
      if(!fail){
        constrained[count(constrained)] = o;
      }
    }

    auto_debug_print("Removed  "+(c-count(constrained))+" objective values from consideration.");

    return constrained;
  }

  __RestorationOptimization[int] calculate_objective_values(){
    if(count(__restore_maximizer_cache) > 0){
      auto_debug_print("Recalculating cached restore objective values.");
      foreach i, o in __restore_maximizer_cache{
         __RestorationOptimization recalculated =
         __restore_maximizer_cache[i] = __calculate_objective_values(hp_goal, mp_goal, buyItems, useFreeRests, o.metadata);
      }
    } else{
      auto_debug_print("Calculating restore objective values.");
      foreach name, metadata in __restoration_methods(){
        __RestorationOptimization o = __calculate_objective_values(hp_goal, mp_goal, buyItems, useFreeRests, metadata);
        if(o.constraints["is_ever_useable"]){
          __restore_maximizer_cache[count(__restore_maximizer_cache)] = o;
        }
      }
    }

    return __restore_maximizer_cache;
  }

  __RestorationOptimization[int] optimized = calculate_objective_values();
  optimized = apply_constraints(optimized, __CONSTRAINT_VALUES);
  quick_sort_maximize(optimized, __MAXIMIZE_VALUES);
  return ranked_weighted_optimization(optimized, __MINIMIZE_VALUES);
}

boolean __restore(string resource_type, int goal, boolean buyItems, boolean useFreeRests){

  int current_resource(){
    if(resource_type == "hp"){
      return my_hp();
    } else if(resource_type == "mp"){
      return my_mp();
    }
    return -1;
  }

  int hp_target(){
    if(resource_type == "hp"){
      return goal;
    } else{
      return my_hp();
    }
  }

  int mp_target(){
    if(resource_type == "mp"){
      return goal;
    } else{
      return my_mp();
    }
  }

  boolean use_restore(__RestorationMetadata metadata, boolean buyItems, boolean useFreeRests){
    if(metadata.name == ""){
      return false;
    }

    print("Using " + metadata.type + " " + metadata.name + " as restore.", "blue");
    if(metadata.type == "item"){
      item i = to_item(metadata.name);
      return retrieve_item(1, i) && use(1, i);
    }

    if(metadata.type == "dwelling"){
      return doFreeRest();
    }

    if(metadata.name == __HOT_TUB){
      int pre_soaks = hotTubSoaksRemaining();
      return doHottub() == pre_soaks - 1;
    }

    if(metadata.type == "skill"){
      skill s = to_skill(metadata.name);
      if(my_mp() < mp_cost(s) && !acquireMP(mp_cost(s), buyItems, useFreeRests)){
        print("Couldnt acquire enough MP to cast " + s, "red");
        return false;
      }
      return use_skill(1, s);
    }

    return false;
  }

  print("Target "+resource_type+" => "+goal+" - Considering restore options at " + my_hp() + "/" + my_maxhp() + " HP with " + my_mp() + "/" + my_maxmp() + " MP", "blue");

  while(current_resource() < goal){
    __RestorationOptimization[int] options = __maximize_restore_options(hp_target(), mp_target(), buyItems, useFreeRests);
    if(count(options) == 0){
      print("Target "+resource_type+" => " + goal + " - Uh, couldnt determine an effective restoration mechanism. Sorry.", "red");
      return false;
    }

    boolean success = false;
    foreach i, o in options{
      success = use_restore(o.metadata, buyItems, useFreeRests);
      if(success){
        break;
      } else{
        auto_debug_print("Target "+resource_type+" => " + goal + " option " + o.metadata.name + " failed. Trying next option (if available).");
      }
    }

    if(!success){
      print("Target "+resource_type+" => " + goal + " - Uh oh. All restore options tried ("+count(options)+") failed. Sorry.", "red");
      return false;
    }
	}
  return true;
}

void __cure_bad_stuff(){
  foreach e in $effects[Hardly Poisoned at All, A Little Bit Poisoned, Somewhat Poisoned, Really Quite Poisoned, Majorly Poisoned, Toad In The Hole]{
    if(have_effect(e) > 0){
      uneffect(e);
    }
  }

	// let mafia figure out how to best remove beaten up
	if(have_effect($effect[Beaten Up]) > 0){
		print("Ouch, you got beaten up. Lets get you patched up, if we can.");
		uneffect($effect[Beaten Up]);

		if(have_effect($Effect[Beaten Up]) > 0){
			print("Well, you're still beaten up, thats probably not great...", "red");
		}
	}
}

/**
 * Public Interface
 */

void invalidateRestoreOptionCache(){
 clear(__known_restoration_sources);
 clear(__restore_maximizer_cache);
}


/**
 * Try to acquire your max mp (buyItems: false, useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= my_maxmp() after attempting to restore.
 */
boolean acquireMP(){
	return acquireMP(my_maxmp());
}

/**
 * Try to acquire up to the mp goal (buyItems: false, useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goal after attempting to restore.
 */
boolean acquireMP(int goal)
{
	return acquireMP(goal, can_interact());
}

/**
 * Try to acquire up to the mp goal, optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goal after attempting to restore.
 */
boolean acquireMP(int goal, boolean buyItems){
	return acquireMP(goal, buyItems, true);
}

/**
 * Try to acquire up to the mp goal, optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goal after attempting to restore.
 */
boolean acquireMP(int goal, boolean buyItems, boolean useFreeRests)
{

  __cure_bad_stuff();

	if(goal > my_maxmp())
	{
		return false;
	}

	if(my_mp() >= goal)
	{
		return true;
	}

	// Sausages restore 999MP, this is a pretty arbitrary cutoff but it should reduce pain
  // TODO: move this to general effectiveness method
	if(my_maxmp() - my_mp() > 300){
		auto_sausageEatEmUp(1);
	}
  __restore("mp", goal, buyItems, useFreeRests);
	return (my_mp() >= goal);
}

/**
 * Try to acquire up to the mp goal expressed as a percentage (out of either 1.0 or 100.0) (buyItems: false, useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goalPercent after attempting to restore.
 */
boolean acquireMP(float goalPercent){
	return acquireMP(goalPercent, can_interact());
}

/**
 * Try to acquire up to the mp goal expressed as a percentage, optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goalPercent after attempting to restore.
 */
boolean acquireMP(float goalPercent, boolean buyItems){
	return acquireMP(goalPercent, buyItems, true);
}

/**
 * Try to acquire up to the mp goal expressed as a percentage (out of either 1.0 or 100.0), optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any mp.
 *
 * returns true if my_mp() >= goalPercent after attempting to restore.
 */
boolean acquireMP(float goalPercent, boolean buyItems, boolean useFreeRests){
	int goal = my_maxmp();
	if(goalPercent > 1.0){
		goal = ceil((goalPercent/100.0) * my_maxmp());
	} else{
		goal = ceil(goalPercent*my_maxmp());
	}
	return acquireMP(goal.to_int(), buyItems, useFreeRests);
}

/**
 * Try to acquire your max hp (buyItems: false, useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= my_maxhp() after attempting to restore.
 */
boolean acquireHP(){
	return acquireHP(my_maxhp());
}

/**
 * Try to acquire up to the hp goal (buyItems: false, useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goal after attempting to restore.
 */
boolean acquireHP(int goal){
	return acquireHP(goal, can_interact());
}

/**
 * Try to acquire up to the hp goal, optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goal after attempting to restore.
 */
boolean acquireHP(int goal, boolean buyItems){
	return acquireHP(goal, buyItems, true);
}

 /**
  * Try to acquire up to the hp goal, optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any hp.
  *
  * returns true if my_hp() >= goal after attempting to restore.
  */
boolean acquireHP(int goal, boolean buyItems, boolean useFreeRests){

  __cure_bad_stuff();

  if(goal > my_maxhp()){
		return false;
	}

	if(my_hp() >= goal){
		return true;
	}

  __restore("hp", goal, buyItems, useFreeRests);

	return my_hp() >= goal;
}

/**
 * Try to acquire up to the hp goal expressed as a percentage (out of either 1.0 or 100.0) (buyItems: false, useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goalPercent after attempting to restore.
 */
boolean acquireHP(float goalPercent){
	return acquireHP(goalPercent, can_interact());
}

/**
 * Try to acquire up to the hp goal expressed as a percentage (out of either 1.0 or 100.0), optionally buying items (useFreeRests: true). Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goalPercent after attempting to restore.
 */
boolean acquireHP(float goalPercent, boolean buyItems){
	return acquireHP(goalPercent, buyItems, true);
}

/**
 * Try to acquire up to the hp goal expressed as a percentage (out of either 1.0 or 100.0), optionally buying items and using free rests. Will also cure poisoned and beaten up before restoring any hp.
 *
 * returns true if my_hp() >= goalPercent after attempting to restore.
 */
boolean acquireHP(float goalPercent, boolean buyItems, boolean useFreeRests){
	int goal = my_maxhp();
	if(goalPercent > 1.0){
		goal = ceil((goalPercent/100.0) * my_maxhp());
	} else{
		goal = ceil(goalPercent*my_maxhp());
	}
	return acquireHP(goal.to_int(), buyItems, useFreeRests);
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
		string temp = visit_url("campground.php?pwd=&preaction=undrive");
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
		print("Effect removed by Soft Green Echo Eyedrop Antidote.", "blue");
		return true;
	}
	else if(item_amount($item[Ancient Cure-All]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		print("Effect removed by Ancient Cure-All.", "blue");
		return true;
	}
	return false;
}

// Deprecated, please use acquireHP()
boolean useCocoon()
{
  return acquireHP();
}

/**
 * we could in theory set this as our restore script, but autoscend is not currently designed to heal this way and changing this now would probably break assumptions people have anticipated in their code, causing undefined behavior. I assume this is why we have the warning about autoscend not playing well with restore scripts and disabling them when it starts.
 *
 * Additionally this script would require some number of imports of other methods (mostly auto_util.ash) which may or may not be easy to do. I did try once by just importing autoscend, but I ended up with an infinite loop. At least thats what it seemed like, I didnt try very hard to make it work. My understanding of ash leads me to believe it should work and I was just doing something stupid. So for now this is just here for posterity.
 */
boolean main(string type, int amount) {
  if(type == "MP"){
    acquireMP(amount);
  } else if(type == "HP"){
    acquireHP(amount);
  }
	return true;	// This ensures that mafia does not attempt to heal with resources that are being conserved.
}
