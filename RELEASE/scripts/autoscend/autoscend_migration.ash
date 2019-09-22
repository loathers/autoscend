script "autoscend_migration.ash"

static string __autoscend_version = "1.0.0";
static string __remove_sl_ascend_confirmation = "Looks like you have the old sl_ascend project installed as well. Would you like to remove it? (it is no longer maintained)";
static string __migrate_sl_ascend_properties_confirmation = "Looks like you may be migrating from sl_ascend. Starting with a fresh run using autoscend is adviable but we can try to migrate all the sl_ascend properties (results may vary).";
static string __migrate_sl_ascend_properties_remove_confirmation = "Would you like to clean up old sl_ascend properties after migrating them?";

string autoscend_current_version(){
  if(!property_exists("auto_current_version")){
    set_property("auto_current_version", __autoscend_version);
  }
  return get_property("auto_current_version");
}

string autoscend_previous_version(){
  if(!property_exists("auto_prev_version")){
    return "";
  } else{
    return get_property("auto_prev_version");
  }
}

boolean autoscend_needs_update(){
  if(autoscend_current_version() != __autoscend_version){
    set_property("auto_prev_version", get_property("auto_current_version"));
    set_property("auto_current_version", __autoscend_version);
    set_property("auto_need_update", true);
  }
  return get_property("auto_need_update");
}

boolean autoscend_migrate(){

  static string[int] props;
  file_to_map("autoscend_properties.txt", props);

  boolean repo_present(string repo){
    return svn_exists(repo) || svn_info(repo).url != "";
  }

  boolean repo_name(string repo){
    if(svn_exists(repo)){
      return repo;
    }

    // the svn ash functions dont seem very reliable in my experience
    // construct mafia's repo naming from the repo url
    string name = replace_string(svn_info(repo).url, "https://github.com/", "");
    name = replace_string(name, "http://github.com/", "");
    name = replace_string(name, "/", "-");
    return name;
  }

  boolean sanity_check_sl_ascend_autoscend_properties(){
    int prop_conflicts = 0;
    foreach _, p in props{
      string old_prop = replace_string(p ,"auto_" , "sl_");
      if(property_exists(old_prop)){
        if(property_exists(p) && property_exists(old_prop) && get_property(p) != get_property(old_prop)){
          prop_conflicts++;
        }
      }
    }

    if(prop_conflicts > 0){
      print("Found " + prop_conflicts + " conflicting property values between sl_ascend properties and autoscend properties. Please do not use sl_ascend and autoscend at the same time or you will likely break both scripts until you start a fresh run. .", "red");
      return false;
    }
    return true;
  }

  /*
   * Migrate sl_* properties to auto_* properties. Attempts to look for and warn about conflicts.
   *
   * Returns true if the property migration ran successfully with no conflicts,
   * false if the user declined the migration or the migration ran and saw conflicting
   * property values.
   */
  boolean autoscend_migrate_properties(){
    if(!user_confirm(__migrate_sl_ascend_properties_confirmation, 10000, true)){
      return false;
    }

    boolean cleanup = user_confirm(__migrate_sl_ascend_properties_remove_confirmation, 10000, false);

    int prop_conflicts = 0;
    foreach _, p in props{
      string old_prop = replace_string(p ,"auto_" , "sl_");
      if(property_exists(old_prop)){
        if(!property_exists(p)){
          print("Migrating " + old_prop + " => " + p + " ("+get_property(old_prop)+")");
          set_property(p, get_property(old_prop));
        } else if(get_property(old_prop) != get_property(p)){
          prop_conflicts++;
        }
        if(cleanup) remove_property(old_prop);
      }
    }

    if(prop_conflicts > 0){
      print("Found " + prop_conflicts + " conflicting property values while migrating from sl_ascend properties to autoscend properties. Things might be in a crazy state until you start a fresh run. Please do not use sl_ascend and autoscend at the same time.", "red");
      return false;
    }
    return true;
  }

  /*
   * Look for and remove sl_ascend repo if it exists, prompting the user for confirmation.
   *
   * Returns true if sl_ascend repo is abscent after the function runs or false if it is
   * present.
   */
  boolean remove_sl_ascend_repos(){
    if(repo_present("sl_ascend")){
      if(user_confirm(__remove_sl_ascend_confirmation, 10000, false)){
        cli_execute("svn delete " + repo_name("sl_ascend"));
      }
    }
    return !repo_present("sl_ascend");
  }

  boolean all_good = true;
  if(autoscend_needs_update()){
    if(sl_ascend_present()){
      all_good = autoscend_migrate_properties() && remove_sl_ascend_repos();
    }
    set_property("auto_need_update", false);
  } else if(repo_present("sl_ascend")){
    all_good = sanity_check_sl_ascend_autoscend_properties();
  }
  return all_good;
}
