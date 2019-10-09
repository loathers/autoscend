script "auto_restore.ash";

/**
 * Functions designed to deal with restoring hp/mp, removing status effects, etc.
 *
 * Bulk of the file is in determining what restoration method is optimal to use in a given situation. Restore methods are loaded from data/autoscend_restoration.txt, which can be updated to add new methods as needed. In general it should be as simple as adding a new line to that file with the appropriate values. For edge cases or special methods (e.g. clan hot tub) you may also need to add a bit of extra logic to the __determine_effectiveness function.
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


record __RestorationOptimization{
  __RestorationMetadata effect_metadata;
  int[string] constrains;
  int[string] maxima_values;
  int[string] maxima_weights;
  int[string] minima_values;
  int[string] minima_weights;
}

// Real ugly to_string, probably only enable for debugging
string to_string(__RestorationMetadata r){
  string list_to_string(boolean[effect] e_list){
    string s = "[";
    boolean first = true;
    foreach e in e_list{
      if(!first){
        s += ", ";
        first = false;
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

string to_string(__RestorationOptimization o){
  string list_to_string(int[string] values){
    string s = "{";
    boolean first = true;
    foreach k, v in values{
      if(!first){
        s += ", ";
        first = false;
      }
      s += k + ": " + v;
    }
    s += "}";
    return s;
  }

  string constrains_str = list_to_string(o.constrains);
  string maxima_values_str = list_to_string(o.maxima_values);
  string minima_values_str = list_to_string(o.minima_values);
  string maxima_weights_str = list_to_string(o.maxima_weights);
  string mminima_weights_str = list_to_string(o.minima_weights);
  return "__RestorationOptimization(name: "+o.metadata.name+", constrains: "+constrains_str+", maxima_values: "+maxima_values_str+", maxima_weights: "+maxima_weights_str+", minima_values: "+minima_values+", minima_weights: "+mminima_weights_str+")";
}

static boolean[effect] __all_negative_effects = $effects[Beaten Up];
static __RestorationMetadata[string] __known_restoration_sources;

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

/**
 *  Maximize:
 *    1. hp restored
 *    2. mp restored
 *
 *  Minimize:
 *    1. mp wasted
 *    2. hp wasted
 *    3. meat spent
 *    4. coinmaster tokens spent
 *    5. mp used
 *
 *  Constraints:
 *    1. currently useable
 *    2. have enough mp or can acquire it
 *    3. have enough items on hand or can purchase (meat, coin master)
 */
static boolean[string] __MAXIMIZE_VALUES = $strings["total_uses_available", "hp_total_restored", "mp_total_restored"];
static boolean[string] __MINIMIZE_VALUES = $strings["total_uses_needed","hp_total_wasted","hp_total_short","mp_total_wasted","mp_total_short","total_mp_used","total_meat_used","total_coinmaster_tokens_used"];
static boolean[string] __CONSTRAINT_VALUES = $strings["hp_goal",hp_goal,"hp_starting","hp_max","hp_restored_per_use","hp_uses_needed_for_goal","mp_goal","mp_starting","mp_max","mp_restored_per_use","mp_uses_needed_for_goal"];
static int[string] __WEIGHTS = {
  "total_uses_needed": 1,
  "total_uses_available": 4,
  "hp_total_restored": 2,
  "hp_total_wasted": 3,
  "hp_total_short": 3,
  "mp_total_restored": 2,
  "mp_total_wasted": 4,
  "mp_total_short": 4,
  "total_mp_used": 2,
  "total_meat_used": 2,
  "total_coinmaster_tokens_used": 5
};
static int[int] __RANK_ORDERED_WEIGHTS = {
  0: 5, 1: 4, 2: 3, 3: 2, 4: 1
};

__RestorationOptimization __calculate_objective_values(int hp_goal, int mp_goal, __RestorationMetadata metadata){
  __RestorationOptimization optimization_parameters;

  void set_value(name, int value, int weight){
    if(__MAXIMIZE_VALUES contains name){
      optimization_parameters.maxima_values[name] = value;
      optimization_parameters.maxima_weights[name] = __WEIGHTS[name];
    } else if(__MINIMIZE_VALUES contains name){
      optimization_parameters.minima_values[name] = value;
      optimization_parameters.minima_weights[name] =  __WEIGHTS[name];
    } else if(__CONSTRAINT_VALUES contains name){
      optimization_parameters.constraints[name] = value;
    }
  }

  void set_value(name, int value){
    set_value(name, value, 0);
  }

  int get_value(string name){
    if(__MAXIMIZE_VALUES contains name){
      return optimization_parameters.maxima_values[name];
    } else if(__MINIMIZE_VALUES contains name){
      return optimization_parameters.minima_values[name];
    } else if(__CONSTRAINT_VALUES contains name){
      return optimization_parameters.constraints[name];
    }
    return 0;
  }

  int get_value(string resource_type, string name){
    return get_value(resource_type + "_" + name);
  }

  // Determine how much hp is restored, working out scaling formulas if needed
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
    return restored_amount;
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


  __RestorationOptimization optimization_parameters;
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
  set_value("total_uses_available", total_uses_on_available());
  set_value("hp_total_restored", total_restored("hp"));
  set_value("hp_total_wasted", total_wasted("hp"));
  set_value("hp_total_short", total_short("hp"));
  set_value("mp_total_restored", total_restored("mp"));
  set_value("mp_total_wasted", total_wasted("mp"));
  set_value("mp_total_short", total_short("mp"));
  set_value("total_mp_used", total_mp_used());
  set_value("total_meat_used", total_meat_used());
  set_value("total_coinmaster_tokens_used", total_coinmaster_tokens_used());
}

__RestorationMetadata[int] __optimize(int hp_goal, int mp_goal, __RestorationMetadata[string] restore_options){

  // returns a sublist of p from [start, stop)
  __RestorationMetadata[int] slice(__RestorationOptimization[int] p, int start, int stop){
    __RestorationOptimization[int] subset;
    if(start >= 0 && start < count(p) && stop > start && stop <= count(p)){
      int i = start;
      while(i < stop){
        subset[count(subset)] = p[i];
        i++;
      }
    }
    return subset;
  }

  __RestorationMetadata[int] copy(__RestorationOptimization[int] p){
    return slice(p, 0, count(p));
  }

  __RestorationMetadata[int] combine(__RestorationOptimization[int] left, __RestorationMetadata[int] right){
    int i = 0;
    while(i < count(right)){
      left[count(left)] = right[i];
      i++;
    }
    return left;
  }

  int weighted_sum(__RestorationOptimization o, boolean[string] maxima){
    int sum = 0;
    for s in maxima{
      sum += o.maxima_values[s] * o.weights[s];
    }
    return sum;
  }

  int weighted_value(__RestorationOptimization o, boolean[string] maxima){
    return o.maxima_values[s] * o.weights[s];
  }

  __RestorationOptimization[int] non_dominated_set(__RestorationOptimization[int] T, __RestorationOptimization[int] B, boolean[string] minima, int weight){
    __RestorationMetadata[int] M;
    int Ti = 0;
    int Bi = 0;

    while(Ti < count(T)){
      Bi = 0;
      while(Bi < count(B)){
        int
        for maxima in minimize_maxima {
          if(T[Ti].maxima_values[maxima] >= B[Bi].maxima_values[maxima]){

          }
        }
      }
    }

    while(Bi < count(B)){
      Ti = 0;
      boolean dominated = false;
      while(Ti < count(T)){

        for maxima in secondary_maxima{

        }
        if(maxima in maximize && T[Ti].maxima_values[maxima] > B[Bi].maxima_values[maxima]){
          dominated = true;
          break;
        } else if(maxima in minimize && T[Ti].maxima_values[maxima] < B[Bi].maxima_values[maxima]){

        }
        Ti++;
      }
      if(!dominated){
        M[count(M)] = B[Bi];
      }
      Bi++;
    }
    return M;
  }

  __RestorationOptimization[int] ranked_weighted_sort(__RestorationOptimization[int] p, boolean[string] minima, int weight){
    if(count(p) == 1){
      return p;
    } else{
      int mid = floor(count(p)/2);
      __RestorationOptimization[int] T = non_dominated_set(slice(p, 0, mid), maxima);
      __RestorationOptimization[int] B = non_dominated_set(slice(p, mid+1, count(p)), maxima);
      return filter(T, B, maxima);
    }
  }

  __RestorationOptimization[int] ranked_weighted_sort(__RestorationOptimization[int] p, boolean[string] minima){
    __RestorationOptimization[int] ranked = copy(p);
    foreach _, weight in __RANK_ORDERED_WEIGHTS {
      ranked_weighted_sort(ranked, minima, weight);
    }
    return ranked;
  }

  int partition(__RestorationOptimization[int] p, boolean[string] primary_maxima, int left_index, int right_index){
    int pivot_value = weighted_sum(p[left_index], primary_maxima);
    int l = left_index + 1;
    int r = right_index;
    boolean done = false;
    __RestorationMetadata swap;

    while(!done){
      while(l <= r){
        if(maximize_primary && weighted_sum(p[l], primary_maxima) >= pivot_value){
          l++;
        } else if(!maximize_primary && weighted_sum(p[l], primary_maxima) <= pivot_value){
          l++;
        } else{
          break;
        }
      }

      while(r >= l){
        if(maximize_primary && weighted_sum(p[r], primary_maxima) <= pivot_value){
          r--;
        } else if(!maximize_primary && weighted_sum(p[r], primary_maxima) >= pivot_value){
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

  __RestorationMetadata[int] quick_sort(__RestorationOptimization[int] p, boolean[string] primary_maxima, int left_index, int right_index){
    if(left_index < right_index){
      int pivot = partition(p, maxima, left_index, right_index);
      quick_sort(p, maxima, left_index, pivot-1);
      quick_sort(p, maxima, pivot+1, right_index);
    }
    return p;
  }

  __RestorationMetadata[int] quick_sort(__RestorationOptimization[int] p, boolean[string] primary_maxima){
    return quick_sort(p, primary_maxima, 0, count(p)-1);
  }

  __RestorationOptimization[int] calculate_objective_values(){
    __RestorationOptimization[int] p;
    foreach name, metadata in restore_options{
      p[count(p)] = calculate_objective_values(hp_goal, mp_goal, restore_options);
    }
    return p;
  }

  __RestorationOptimization[int] optimized = __calculate_objective_values()
  quick_sort(optimized, __MAXIMIZE_VALUES);



  foreach maxima in maximize{
    optimized = sort(optimized, maxima);
    auto_debug_print("Optimized restore options on (max) " + maxima);
  }

  foreach maxima in minimize{
    optimized = sort(optimized, maxima);
    auto_debug_print("Optimized restore options on (min) " + maxima);
  }

  return optimized;
}



/**
 * Calculate the effectiveness of a restoration method given starting hp/mp and hp/mp targets.
 *
 * Effectiveness is roughly calculated as: (hp restored + mp restored) - (meat cost + mp cost + hp waste + mp waste)
 *
 * A little more detail on effectiveness calculation:
 *  - hp/mp waste is considered over the goal hp/mp, not max hp/mp
 *  - skills that would require us to get more mp have the extra mp needed weighted, mp is expensive and valuable and we want to avoid having to get more if we can.
 *  - items on hand that would be consumed are not considered a "cost", only extras we would need to buy.
 *  - a restore method could have a large negative value depending on cost/weight associated with it, but it can still be used (if it is the least negative)
 *
 * TODO:
 *  - give value/cost to effects
 *  - variable weights for coinmasters (probably move cost modifier weight to data file)
 */
__RestorationEffectiveness __determine_effectiveness(int hp_goal, int starting_hp, int mp_goal, int starting_mp, __RestorationMetadata metadata){

  // How many times can we use the method currently
  int uses_on_hand(){
    if(metadata.type == "dwelling"){
      return freeRestsRemaining();
    } else if(metadata.type == "item"){
      return available_amount(to_item(metadata.name)); //I believe this will take coinmasters into consideration for us
    } else if(metadata.type == "skill"){
      return floor(starting_mp / mp_cost(to_skill(metadata.name)));
    } else if(metadata.name == __HOT_TUB){
      return hotTubSoaksRemaining();
    }
    return 0;
  }

  // Determine how much hp is restored, working out scaling formulas if needed
  int hp_restored_per(){
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

  // Determine how much mp is restored, working out scaling formulas if needed
  int mp_restored_per(){
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

  int hp_wasted_by(int starting_hp){
    int needed = hp_goal - starting_hp;
    int wasted = hp_restored_per() - needed;

    // negative waste means we are short of goal, no waste
    return max(0, wasted);
  }

  int mp_wasted_by(int starting_mp){
    int needed = mp_goal - starting_mp;
    int wasted = mp_restored_per() - needed;

    // negative waste means we are short of goal, no waste
    return max(0, wasted);
  }

  /**
   * How many times we would need to use the method to reach the hp goal.
   *
   * If the restoration method doesnt restore hp, 0 is returned
   */
  int uses_needed_to_reach_hp_goal(){
    if(hp_restored_per() < 1){
      return 0;
    }
    return ceil((hp_goal - starting_hp) / hp_restored_per())+1;
  }

  /**
   * How many times we would need to use the method to reach the hp goal.
   *
   * If the restoration method doesnt restore hp, 0 is returned
   */
  int uses_needed_to_reach_mp_goal(){
    if(mp_restored_per() < 1){
      return 0;
    }
    return ceil((mp_goal - starting_mp) / mp_restored_per())+1;
  }

  // Gives the mp cost if the restoration is a skill, 0 otherwise
  int mp_cost_per(){
    if(metadata.type == "skill"){
      return mp_cost(to_skill(metadata.name));
    }
    return 0;
  }

  // Gives the npc/mall meat price of an item, or 0 if not purchasable (which is all non-items by definition)
  int meat_cost_per(){
    if(metadata.type == "item"){
      item i = to_item(metadata.name);
      if(can_interact()){
        return min(npc_price(i), auto_mall_price(i));
      }
      return npc_price(i);
    }
    return 0;
  }

  int coinmaster_cost_per(){
    if(metadata.type == "item"){
      item i = to_item(metadata.name);
      if(i.seller != $coinmaster[none]){
        return sell_price(i.seller , i);
      }
    }
    return 0;
  }

  int general_cost_modifier(__RestorationEffectiveness effectiveness){
    int cost_modifier = 0;
    if(effectiveness.meat_cost_per_use > 0){
      cost_modifier += (effectiveness.total_uses_needed - effectiveness.uses_available) * effectiveness.meat_cost_per_use;
    }
    if(effectiveness.coinmaster_cost_per_use > 0){
      cost_modifier += (effectiveness.total_uses_needed - effectiveness.uses_available) * effectiveness.coinmaster_cost_per_use * __coinmaster_cost_multiplier;
    }
    return cost_modifier;
  }

  // TODO: value overage between goal and max to be value (not cost) but less valuable (half?)
  // TODO: handle case where we have N uses but need > N uses and cant make up the difference (weighted cost?)
  void hp_effectiveness(__RestorationEffectiveness effectiveness){
    if(effectiveness.hp_restored_per_use <= 0){
      effectiveness.hp_effectiveness_value = 0;
      effectiveness.hp_effectiveness_cost_modifier = 0;
      effectiveness.total_hp_restored = 0;
      return;
    }

    int hp_effectiveness_value = 0;
    int hp_effectiveness_cost_modifier = 0;

    if(effectiveness.mp_cost_per_use > 0){
      int mp_to_max = effectiveness.mp_cost_per_use * effectiveness.total_uses_needed;
      if(mp_to_max > effectiveness.starting_mp){
        hp_effectiveness_cost_modifier = effectiveness.starting_mp + (__mp_cost_multiplier * (mp_to_max - effectiveness.starting_mp));
      } else{
        hp_effectiveness_cost_modifier = mp_to_max;
      }
      hp_effectiveness_cost_modifier -= (__mp_cost_multiplier * mp_regen());
    }


    hp_effectiveness_value = effectiveness.hp_restored_per_use * effectiveness.total_uses_needed;

    int past_goal_waste = hp_wasted_by(starting_hp) - hp_wasted_by(my_maxhp());
    int past_max_waste = hp_wasted_by(my_maxhp());
    if(effectiveness.total_uses_needed > 1){
      int last_use_starting_hp = starting_hp + (effectiveness.hp_restored_per_use * effectiveness.uses_to_hp_goal);
      past_goal_waste = hp_wasted_by(last_use_starting_hp) - hp_wasted_by(my_maxhp());
      past_max_waste = (effectiveness.total_uses_needed - effectiveness.uses_to_hp_goal) * hp_wasted_by(my_maxhp());
    }

    // consider extra hp between goal and max hp as reduced cost and any past max hp as full cost
    hp_effectiveness_cost_modifier += floor(past_goal_waste / 4);
    hp_effectiveness_cost_modifier += past_max_waste;

    effectiveness.hp_effectiveness_value = hp_effectiveness_value;
    effectiveness.hp_effectiveness_cost_modifier = hp_effectiveness_cost_modifier;


    effectiveness.total_hp_restored = min(effectiveness.hp_restored_per_use * effectiveness.total_uses_needed, my_maxhp()-starting_hp);
  }

  void mp_effectiveness(__RestorationEffectiveness effectiveness){
    if(effectiveness.mp_restored_per_use <= 0){
      effectiveness.mp_effectiveness_value = 0;
      effectiveness.mp_effectiveness_cost_modifier = 0;
      effectiveness.total_mp_restored = 0;
      return;
    }

    int mp_effectiveness_value = 0;
    int mp_effectiveness_cost_modifier = 0;

    mp_effectiveness_value = effectiveness.mp_restored_per_use * effectiveness.total_uses_needed;
    int past_goal_waste = mp_wasted_by(starting_mp) - mp_wasted_by(my_maxmp());
    int past_max_waste = mp_wasted_by(my_maxmp());

    if(effectiveness.total_uses_needed > 1){
      int last_use_starting_mp = starting_mp + (effectiveness.mp_restored_per_use * effectiveness.uses_to_mp_goal);
      past_goal_waste = mp_wasted_by(last_use_starting_mp) - mp_wasted_by(my_maxmp());
      past_max_waste = (effectiveness.total_uses_needed - effectiveness.uses_to_mp_goal) * mp_wasted_by(my_maxmp());
    }

    mp_effectiveness_cost_modifier += floor(past_goal_waste / 2);
    mp_effectiveness_cost_modifier += past_max_waste;

    effectiveness.mp_effectiveness_value = mp_effectiveness_value;
    effectiveness.mp_effectiveness_cost_modifier = mp_effectiveness_cost_modifier;
    effectiveness.total_mp_restored = effectiveness.mp_restored_per_use * effectiveness.total_uses_needed;
  }

  __RestorationEffectiveness effectiveness;
  effectiveness.effect_metadata = metadata;
  effectiveness.hp_goal = hp_goal;
  effectiveness.starting_hp = starting_hp;
  effectiveness.mp_goal = mp_goal;
  effectiveness.starting_mp = starting_mp;
  effectiveness.hp_restored_per_use = hp_restored_per();
  effectiveness.mp_restored_per_use = mp_restored_per();
  effectiveness.uses_available = uses_on_hand();
  effectiveness.uses_to_hp_goal = uses_needed_to_reach_hp_goal();
  effectiveness.uses_to_mp_goal = uses_needed_to_reach_mp_goal();
  effectiveness.total_uses_needed = max(effectiveness.uses_to_hp_goal, effectiveness.uses_to_mp_goal);
  effectiveness.mp_cost_per_use = mp_cost_per();
  effectiveness.meat_cost_per_use = meat_cost_per();
  hp_effectiveness(effectiveness);
  mp_effectiveness(effectiveness);
  effectiveness.general_cost_modifier = general_cost_modifier(effectiveness);
  effectiveness.total_meat_spent = effectiveness.meat_cost_per_use * max(effectiveness.total_uses_needed - effectiveness.uses_available, 0);
  effectiveness.total_coinmaster_tokens_spent = effectiveness.coinmaster_cost_per_use * max(effectiveness.total_uses_needed - effectiveness.uses_available, 0);
  effectiveness.total_value = (effectiveness.mp_effectiveness_value + effectiveness.hp_effectiveness_value) - (effectiveness.mp_effectiveness_cost_modifier + effectiveness.hp_effectiveness_cost_modifier + effectiveness.general_cost_modifier);

  logprint(to_string(metadata));
  logprint(metadata.name + " effectiveness - " + to_string(effectiveness));
  return effectiveness;
}

/**
 * Filters __known_restoration_sources down to what is currently accessible to the player, calls __determine_effectiveness to calculate how effective each of those options are, then returns the one that is best (generally the highest __RestorationEffectiveness.total_value)
 *
 * TODO:
 *  - give value/cost to effects
 */
__RestorationMetadata __most_effective_restore(int goal_hp, int starting_hp, int goal_mp, int starting_mp, boolean buyItems, boolean useFreeRests){

  boolean haveAnyIotmAlternateCampsight(){
  	return chateaumantegna_available() || auto_campawayAvailable();
  }

  //filters out most of the stuff that is obviously not available
  boolean is_useable(__RestorationMetadata metadata){
    if(metadata.type == "item"){
      item i = to_item(metadata.name);
      boolean npc_buyable = npc_price(i) > 0 || (i.seller != $coinmaster[none] && inaccessible_reason(i.seller) == "");
      boolean mall_buyable = can_interact() && auto_mall_price(i) > 0;
      boolean can_buy = buyItems && (npc_buyable || mall_buyable);
      return auto_is_valid(i) && (available_amount(i) > 0 || can_buy);
    }
    if(metadata.type == "skill"){
      skill s = to_skill(metadata.name);
      return auto_is_valid(s) && auto_have_skill(s) && my_maxmp() >= mp_cost(s);
    }
    if(metadata.type == "dwelling" && useFreeRests){
      item d = to_item(metadata.name);
      return (d == $item[Chateau Mantegna Room Key] && chateaumantegna_available()) ||
        (d == $item[Distant Woods Getaway Brochure] && auto_campawayAvailable()) ||
        (d == get_dwelling() && !haveAnyIotmAlternateCampsight());
    }
    if(metadata.name == __HOT_TUB){
      return isHotTubAvailable();
    }
    return false;
  }

  __RestorationEffectiveness pick_best(__RestorationEffectiveness a, __RestorationEffectiveness b){
    print(a.effect_metadata.name + " ("+a.total_value+") vs " + b.effect_metadata.name + " ("+b.total_value+")");
    boolean wants_hp = goal_hp > starting_hp;
    boolean wants_mp = goal_mp > starting_mp;

    __RestorationEffectiveness best;

    if(a.effect_metadata.name == ""){
      return b;
    } else if(b.effect_metadata.name == ""){
      return a;
    } else if(b.uses_available < b.total_uses_needed){
      return a; //prioritize methods that dont require obtaining resources
    } else if(a.total_value > b.total_value){
      return a;
    } else if(a.total_value < b.total_value){
      return b;
    } else if(!wants_mp){
      if((a.mp_effectiveness_value + a.mp_effectiveness_cost_modifier) < (b.mp_effectiveness_value + b.mp_effectiveness_cost_modifier)){
        return a; //prefer wasting as little mp as possible
      } else if((a.mp_effectiveness_value + a.mp_effectiveness_cost_modifier) > (b.mp_effectiveness_value + b.mp_effectiveness_cost_modifier)){
        return b; //prefer wasting as little mp as possible
      }
    } else if(!wants_hp){
      if((a.hp_effectiveness_value + a.hp_effectiveness_cost_modifier) < (b.hp_effectiveness_value + b.hp_effectiveness_cost_modifier)){
        return a; // prefer wasting as little hp as possible
      } else if((a.hp_effectiveness_value + a.hp_effectiveness_cost_modifier) > (b.hp_effectiveness_value + b.hp_effectiveness_cost_modifier)){
        return b; // prefer wasting as little hp as possible
      }
    }
    return a; // all things being equal...
  }

  print("Calculating restore options (current hp: "+starting_hp+", hp goal: "+goal_hp+", current mp: "+starting_mp+", mp goal: "+goal_mp+")");
  __RestorationEffectiveness best_effectiveness;

  foreach name, metadata in __restoration_methods() {
    if(!is_useable(metadata)){
      continue;
    }

    __RestorationEffectiveness effectiveness = __determine_effectiveness(goal_hp, starting_hp, goal_mp, starting_mp, metadata);

    //dont have enough items/mp on hand
    if(effectiveness.uses_available < effectiveness.total_uses_needed){
      if((effectiveness.coinmaster_cost_per_use > 0 || effectiveness.meat_cost_per_use > 0) && !buyItems){
        print(name + " removed from consideration: caller requested not to buy items.");
        continue;
      }
      if(effectiveness.coinmaster_cost_per_use > 0 && !get_property("autoSatisfyWithCoinmasters").to_boolean()){
        print(name + " removed from consideration: coinmaster item with 'autoSatisfyWithCoinmasters' property set to false.");
        continue;
      }
      if(my_meat() < effectiveness.total_meat_spent){
        print(name + " removed from consideration: not enough meat.");
        continue;
      }
      if(effectiveness.coinmaster_cost_per_use > 0 && effectiveness.total_coinmaster_tokens_spent < to_item(name).seller.available_tokens){
        print(name + " removed from consideration: not enough tokens to purchase needed quantity.");
        continue;
      }
    }

    if(goal_hp > starting_hp && effectiveness.total_hp_restored == 0){
      print(name + " removed from consideration: doesnt restore any hp.");
      continue;
    }

    if(goal_mp > starting_mp && effectiveness.total_mp_restored == 0){
      print(name + " removed from consideration: doesnt restore any mp.");
      continue;
    }

    best_effectiveness = pick_best(best_effectiveness, effectiveness);
  }

  print("Best restore option: " + best_effectiveness.effect_metadata.type + " " + best_effectiveness.effect_metadata.name + " (effectiveness: "+best_effectiveness.total_value+")", "blue");
  return best_effectiveness.effect_metadata;
}

/**
 * Actually use the restoration method. Will only do 1 use even if the method needs more than one use to achieve the desired goal. This allows you to do the effectiveness calculation in a loop in case a different method becomes more effective.
 */
boolean __use_restore(__RestorationMetadata metadata, boolean buyItems, boolean useFreeRests){
  if(metadata.name == ""){
    return false;
  }

  print("Using " + metadata.type + " " + metadata.name + " as restore.");
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
      print("Couldnt acquire enough MP to cast " + s);
      return false;
    }
    return use_skill(1, s);
  }

  return false;
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

  print("Target MP => "+goal+" - Considering restore options at " + my_hp() + "/" + my_maxhp() + " HP with " + my_mp() + "/" + my_maxmp() + " MP", "blue");
	while(my_mp() < goal){
    __RestorationMetadata best_restore = __most_effective_restore(my_hp(), my_hp(), goal, my_mp(), buyItems, useFreeRests);
    if(!__use_restore(best_restore, buyItems, useFreeRests)){
			print("Target MP => " + goal + " - Uh, couldnt determine an effective restoration mechanism. Sorry.", "red");
			return false;
    }
	}

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

	print("Target HP => "+goal+" - Considering restoration options at " + my_hp() + "/" + my_maxhp() + " HP with " + my_mp() + "/" + my_maxmp() + " MP", "blue");
	while(my_hp() < goal){
    __RestorationMetadata best_restore = __most_effective_restore(goal, my_hp(), my_mp(), my_mp(), buyItems, useFreeRests);
    if(!__use_restore(best_restore, buyItems, useFreeRests)){
      print("Target HP => " + goal + " - Uh, couldnt determine an effective restoration mechanism. Sorry.", "red");
			return false;
    }
	}

	return true;
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
