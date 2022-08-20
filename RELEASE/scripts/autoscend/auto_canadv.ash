#/******************************************************************************
#                            CanAdv by Zarqon
#     A tool for handily determining if an area is available for adventuring
#*******************************************************************************
#
#   We did the work so you don't have to.  Import this into your scripts!
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=2027
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
since r19788;  // handling_choice()
import <zlib.ash>

setvar("canadv_unlockGuild", false);  // Whether to unlock the guild automatically (the only thing in this script that spends adventures!)

boolean explo = my_path() == "Kingdom of Exploathing";   // we'll need this check a lot

boolean checkguild(boolean prep) {    // guild quest-unlocking
   if (!($classes[seal clubber, turtle tamer, pastamancer, sauceror, disco bandit, accordion thief] contains my_class())) return false;
   if ($strings[Nuclear Autumn, Pocket Familiars] contains my_path()) return false;  // guild not available
   if (!guild_store_available()) {
      if (prep && to_boolean(getvar("canadv_unlockGuild"))) cli_execute("guild");
       else return false;
   }
   void sayhito(string who) { vprint("Checking in with "+who,8); visit_url("guild.php?place="+who);  }
  // paco
   if (!qprop("questG01Meatcar")) {
      if (qprop("questG01Meatcar < started") || have_item($item[bitchin' meatcar]) > 0) sayhito("paco");
   } else if (!qprop("questG02Whitecastle")) {
      if (qprop("questG02Whitecastle < started") || have_item($item[white citadel satisfaction satchel]) > 0) sayhito("paco");
      if (handling_choice() && last_choice() == 930) run_choice(1);
   } else if (!qprop("questG06Delivery")) {
      if (my_buffedstat(my_primestat()) >= 100 && (qprop("questG06Delivery < started") || have_item($item[thick padded envelope]) > 0)) sayhito("paco");
   }
  // ocg
   if (!qprop("questG03Ego")) switch (get_property("questG03Ego")) {
      case "unstarted": sayhito("ocg"); break;
      case "started": if (item_amount($item[Fernswarthy's key]) > 0) sayhito("ocg"); break;
      case "step1": if (my_buffedstat(my_primestat()) >= 18 && item_amount($item[Fernswarthy's key]) == 0) sayhito("ocg"); break;
      case "step6": if (item_amount($item[dusty old book]) > 0) sayhito("ocg"); break;
   }
  // scg!
   if (!explo && !qprop("questG04Nemesis")) switch (get_property("questG04Nemesis")) {
      case "unstarted":
      case "step4:":
      case "step8":
      case "step9":
      case "step16":
      case "step29": sayhito("scg"); break;
   }
   return true;
}
static {
   record {
      string page;
      int when;
   }[string] urlcache;
}
string timed_url(string url, int expiry, int verb) {   // returns cached url unless expiry time (in ms) has passed (1 hr: 3600000)
   if (urlcache contains url && urlcache[url].when > gametime_to_int()) return urlcache[url].page;
   vprint("Visiting "+url+" (good for "+rnum(expiry)+"ms)",verb);
   urlcache[url].page = visit_url(url);
   urlcache[url].when = gametime_to_int() + expiry;
   return urlcache[url].page;
}

boolean can_adv(location where, boolean prep, int verb) {
  // prepare yourself!
   if (where == $location[none]) return vprint("Not a known location!",-6);
   switch (limit_mode()) {
      case "batman": if (where.parent != "Batfellow Area") return vprint("Not a Bat-Location!",-verb); break;
      case "Spelunky": if (where.zone != "Spelunky Area") return vprint("Not a Spelunky location!",-verb); break;
   }
   verb = max(verb,2);  // disallow negative verbs since return value depends on it
   vprint("Checking '"+where+"'...", verb);
   boolean equipcheck(item req, slot bodzone) {
      if (have_equipped(req)) return true;
      if (!can_equip(req) || !be_good(req)) return vprint("You need to equip a "+req+", which you currently can't.",-verb);
      return prep ? retrieve_item(1,req) && equip(bodzone,req) : have_item(req) > 0;
   }
   boolean equipcheck(item req) {
      return equipcheck(req,to_slot(req));
   }
   if (prep) {
      if (my_adventures() == 0) return vprint("An adventurer without adventures is you!",-verb);
      if (my_hp() == 0) { restore_hp(0); if (my_hp() == 0) return vprint("You need at least _a_ HP.",-verb); }
      if (my_inebriety() > inebriety_limit() && !equipcheck($item[Drunkula's wineglass]) && !($locations[Drunken Stupor, St. Sneaky Pete's Day Stupor] contains where))
         return vprint("You sheriushly shouldn't be advenshuring like thish.",-verb);
      if (my_path() == "KOLHS" && where.zone != "KOL High School" && get_property("_kolhsAdventures").to_int() < 40) return vprint("You gotta stay in school, kid.",-verb);
   }
   if (where == $location[St. Sneaky Pete's Day Stupor] && !equipcheck($item[Drunkula's wineglass])) return (my_inebriety() > 25 && contains_text(holiday(),"St. Sneaky Pete's Day"));
   if (where == $location[Drunken Stupor] && !equipcheck($item[Drunkula's wineglass])) return (my_inebriety() > inebriety_limit());
   if (!explo && my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
  // load permanently unlocked zones
   string theprop = get_property("unlockedLocations");
   if (theprop == "" || index_of(theprop,"--") < 1 || substring(theprop,0,index_of(theprop,"--")) != to_string(my_ascensions()))
      theprop = my_ascensions()+"--";
   if (list_contains(theprop, where) && !prep) return true;

   boolean primecheck(int req, boolean softhard) {
      if (my_buffedstat(my_primestat()) < req)
         return vprint((softhard ? "KoL suggests you have " : "You need ")+"at least "+req+" "+to_string(my_primestat())+" to adventure at "+where+"."+
            (softhard ? " (You can disable this warning in your KoL account menu)" : ""),-verb);
      return true;
   }
   boolean primecheck(int req) { return primecheck(req,false); }
   boolean levelcheck(int req) {
      if (explo) return true;   // bypass level checks in Exploathing since the unlocks are not level-based
      if (my_level() < req) return vprint("You need to be level "+req+" or higher to adventure at "+where+".",-verb);
      return true;
   }
   boolean itemcheck(item req) {
      if (available_amount(req) == 0 && (!prep || !retrieve_item(1,req)))
         return vprint("You need a '"+req+"' to adventure here.",-verb);
      return true;
   }
   boolean effectcheck(effect req) {
      if (have_effect(req) == 0) return vprint("You need '"+req+"' to be active to adventure at "+where+".",-verb);
      return true;
   }
   boolean famcheck(familiar req) {
      if (to_familiar(getvar("is_100_run")) != $familiar[none] && req != to_familiar(getvar("is_100_run"))) 
         return vprint("You need to equip a "+req+", which you currently can't due to being on a 100% run with a "+to_familiar(getvar("is_100_run"))+".",-verb);
      if (my_familiar() == req) return true;
      if (have_familiar(req) && prep) return use_familiar(req);
      return have_familiar(req);
   }
   boolean hobocheck() {
      if (!timed_url("clan_hobopolis.php",600000,verb).contains_text("deeper.gif")) return vprint("You have not yet traversed the sewers.",-verb);  // 10 min
      matcher hoboimg;
      boolean hspec(int place, string img, int cutoff) {  // cutoff = last adventurable image number
         hoboimg = create_matcher(img+"(\\d+)\\.gif", timed_url("clan_hobopolis.php?place="+place,50000,verb));  // 30 sec
         if (!hoboimg.find()) return vprint("Unable to match image for "+img+"X.gif",-2);
         return hoboimg.group(1).to_int() <= cutoff;
      }
      switch(where) {
         case $location[Hobopolis Town Square]: return hspec(2,"townsquare",24);
         case $location[Burnbarrel Blvd.]: return hspec(4,"burnbarrelblvd",9);
         case $location[Exposure Esplanade]: return hspec(5,"exposureesplanade",9);
         case $location[The Heap]: return hspec(6,"theheap",9);
         case $location[The Ancient Hobo Burial Ground]: return hspec(7,"burialground",9);
         case $location[The Purple Light District]: return hspec(8,"purplelightdistrict",9);
      }
      return true;
   }
   boolean outfitcheck(string req) {
      if (!have_outfit(req)) return vprint("You don't have the '"+req+"' outfit.",-verb);
      foreach n,i in outfit_pieces(req) if (!equipcheck(i)) return false;  // reason message is already given in equipcheck
      return prep ? outfit(req) : true;
   }
   boolean add_unlocked() {
      if (list_contains(theprop,where)) return true;
      set_property("unlockedLocations",list_add(theprop,where));
      return true;
   }
   boolean perm_urlcheck(string url, string needle) {
      string page = visit_url(url);
      vprint("Visited "+url+" (length: "+length(page)+")",9);
      if (contains_text(page,needle)) return add_unlocked();
      return false;
   }
   boolean not_blind() {   // can sea
      vprint("Checking diveability of "+where+"...",verb);
      if (prep) {  // more reliably equip underwater stuff using maximize
         if (!boolean_modifier("Underwater Familiar") && !maximize("familiar, Underwater Familiar", false)) 
            return vprint("Unable to equip your familiar for underwater adventuring.",-verb);
         return (boolean_modifier("Adventure Underwater") || maximize("sea, -tie", !prep));
      }
      if (!boolean_modifier("Underwater Familiar") && available_amount($item[das boot]) == 0 && available_amount($item[little bitty bathysphere]) == 0)
         return vprint("Unable to equip your familiar for underwater adventuring.",-verb);
      if (boolean_modifier("Adventure Underwater")) return true;
      foreach sl in $slots[] if (equipped_item(sl).boolean_modifier("Adventure Underwater")) return true;
      if (available_amount($item[The Crown of Ed the Undying]) > 0 && equipcheck($item[The Crown of Ed the Undying])) return true; // don't check for "fish" because this is !prep
      foreach it in $items[] if (available_amount(it) > 0 && it.boolean_modifier("Adventure Underwater") && equipcheck(it)) return true;
      return false;
   }
   boolean seafloor_check(string url) {
      string page = timed_url("seafloor.php",50000,verb);   // 30 sec
      vprint("Visited seafloor.php (length: "+length(page)+")",9);
      if (contains_text(page,url+"a.gif") || contains_text(page,url+"b.gif")) return add_unlocked();
      return false;
   }
   boolean jarcheck(string who) {
      item jar = to_item("jar of psychoses ("+who+")");
      return (get_campground() contains jar) || itemcheck(jar);
   }
   boolean zone_check(string zone) {
     // Exploathing zone whitelist.  This simplifies a LOT of checks down the road
      if (explo && !($strings[Astral, Beach, BatHole, Beanstalk, Cyrpt, Dungeon, Ellsbury's Claim, Exploathing, FantasyRealm, Fernswarthy's Tower, Friars, Gyms, HiddenCity, Highlands, Jacking, Kegger, Knob,
             Lab, Landscaper, Magic Commune, Manor0, Manor1, Manor2, Manor3, McLarge, Memories, Menagerie, Mountain, Pandamonium, PirateRealm, PirateRealm Island, Plains, Portal, Psychoses, Pyramid, Sorceress,
             Spaaace, The Red Zeppelin's Mooring, Town, Twitch, Vanya's Castle, Woods, Wormwood] contains zone)) return vprint(zone + " is unavailable when the Kingdom is exploathed.",-verb);
     // Grey Goo zone blacklist
      if (my_path() == "Grey Goo" && $strings[Beanstalk, Clan Basement, Dreadsylvania, Hobopolis, Knob, Plains, Menagerie, Sorceress, The Sea] contains zone) return vprint(zone + " is unavailable when covered in Goo.",-verb);
      switch (zone) {
     // batbloke
      case "Center Park (Low Crime)":
      case "Downtown":
      case "Industrial District (High Crime)":
      case "Slums (Moderate Crime)": return limit_mode() == "batman";
     // alphabetical
      case "Astral": return effectcheck($effect[half-astral]) || itemcheck($item[astral mushroom]);
      case "BatHole": return levelcheck(4) && qprop("questL04Bat >= started");
      case "Beach": return get_property("lastDesertUnlock") == my_ascensions() || my_path() == "Actually Ed the Undying";
      case "Beanstalk": return levelcheck(10);
      case "Campground": return my_path() != "You, Robot";
      case "Clan Basement": return get_clan_name() != "";
      case "Conspiracy Island": return is_unrestricted($item[airplane charter: Conspiracy island]) && (get_property("spookyAirportAlways").to_boolean() || get_property("_spookyAirportToday").to_boolean());
      case "Cyrpt": return levelcheck(7) && itemcheck($item[evilometer]);
      case "Dinseylandfill": return is_unrestricted($item[airplane charter: Dinseylandfill]) && (get_property("stenchAirportAlways").to_boolean() || get_property("_stenchAirportToday").to_boolean());
      case "Dreadsylvania": return levelcheck(15) && timed_url("clan_dreadsylvania.php", 1800000, verb).contains_text(">Dreadsylvania<");  // 30 minutes
      case "Dungeon": return !explo || where == $location[the daily dungeon];
      case "Exploathing": return explo;
      case "FantasyRealm": return get_property("frAlways").to_boolean() || get_property("_frToday").to_boolean();
      case "Farm": return zone_check("IsleWar") && qprop("questL12War >= step1") && get_property("sidequestFarmCompleted") == "none";
      case "Friars": return levelcheck(6) && qprop("questL06Friar >= started") && !qprop("questL06Friar");
      case "Gingerbread City": return get_property("gingerbreadCityAvailable").to_boolean();
      case "The Grey Goo Impact Site": return my_path() == "Grey Goo" && my_daycount() < 4;
      case "HiddenCity": return levelcheck(11) && qprop("questL11Worship >= step3");
      case "Highlands": return levelcheck(9) && qprop("questL09Topping >= started") && get_property("chasmBridgeProgress").to_int() >= 30;
      case "Hobopolis": return contains_text(timed_url("town_clan.php", 1800000,verb), "clanbasement.gif") && !contains_text(timed_url("clan_basement.php?fromabove=1",1800000,verb), "not allowed");  // 30 min
      case "Island": return get_property("lastIslandUnlock") == my_ascensions() && qprop("questL12War != step1");
      case "IsleWar": return levelcheck(12) && qprop("questL12War >= started") && !qprop("questL12War");
      case "Jacking": return itemcheck($item[map to Professor Jacking's laboratory]) && qprop("questI02Beat >= step1");
      case "Junkyard": return zone_check("IsleWar") && get_property("sidequestJunkyardCompleted") == "none" && 
         (have_outfit("Frat Warrior Fatigues") || (have_outfit("War Hippy Fatigues") && get_property("fratboysDefeated").to_int() >= 192));
      case "Knob": if (where == $location[the outskirts of cobb's knob]) return true; return levelcheck(5) && qprop("questL05Goblin >= started");
      case "KOL High School": return my_path() == "KOLHS";
      case "Lab": return levelcheck(5) && itemcheck($item[Cobb's Knob lab key]);
      case "Le Marais D&egrave;gueulasse":
      case "Little Canadia": return canadia_available();
      case "Manor0": return levelcheck(11) && (itemcheck($item[your father's macguffin diary]) || itemcheck($item[copy of a jerk adventurer's father's diary])) && qprop("questL11Manor >= step1");
      case "Manor1": if (where == $location[the haunted pantry]) return true; return qprop("questM20Necklace >= started");
      case "Manor2": return qprop("questM21Dance >= step1");
      case "Manor3": return qprop("questM21Dance");
      case "McLarge": return levelcheck(8) && qprop("questL08Trapper >= step1");
      case "Memories": return itemcheck($item[empty agua de vida bottle]);
      case "Menagerie": return itemcheck($item[Cobb's Knob menagerie key]);
      case "Mothership": return my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0;
      case "MoxSign": return gnomads_available() && zone_check("Beach");
      case "MusSign": return knoll_available();
      case "Mountain": return !explo || where == $location[the smut orc logging camp];
      case "Orchard": return zone_check("IsleWar") && get_property("sidequestOrchardCompleted") == "none";
      case "Pandamonium": return qprop("questL06Friar");
      case "PirateRealm":
      case "PirateRealm Island": return get_property("prAlways").to_boolean() || get_property("_prToday").to_boolean();
      case "Plains": return !explo || where == $location[Inside the Palindome];
      case "Pyramid": return itemcheck($item[2325]) || (my_path() != "Actually Ed the Undying" && qprop("questL13Final"));
      case "Rift": return levelcheck(4) && my_level() < 6 && my_ascensions() > 0 && itemcheck($item[fernswarthy's letter]);
      case "Rumpelstiltskin's Home For Children": return get_property("grimstoneMaskPath") == "gnome" || itemcheck($item[grimstone mask]);
      case "Skid Row": return get_property("grimstoneMaskPath") == "wolf" || itemcheck($item[grimstone mask]);
      case "Sorceress": return my_path() != "Bugbear Invasion" && levelcheck(13) && !qprop("questL13Final") && qprop("questL13Final >= started");
      case "Spaaace": return effectcheck($effect[transpondent]) || (!prep && itemcheck($item[transporter transponder])) || (prep && use(1,$item[transporter transponder]));
      case "Spelunky Area": return limit_mode() == "Spelunky";
      case "Spring Break Beach": return is_unrestricted($item[airplane charter: Spring Break Beach]) && (get_property("sleazeAirportAlways").to_boolean() || get_property("_sleazeAirportToday").to_boolean());
      case "Suburbs": return effectcheck($effect[dis abled]) || (!prep && itemcheck($item[devilish folio])) || (prep && use(1,$item[devilish folio]));
      case "That 70s Volcano": return is_unrestricted($item[airplane charter: That 70s Volcano]) && (get_property("hotAirportAlways").to_boolean() || get_property("_hotAirportToday").to_boolean());
      case "The Candy Witch and the Relentless Child Thieves": return get_property("grimstoneMaskPath") == "witch" || itemcheck($item[grimstone mask]);
      case "The Drip": return get_property("drippyJuice").to_int() > 0;
      case "The Glaciest": return is_unrestricted($item[airplane charter: The Glaciest]) && (get_property("coldAirportAlways").to_boolean() || get_property("_coldAirportToday").to_boolean());
      case "The Prince's Ball": return get_property("grimstoneMaskPath") == "stepmother" || itemcheck($item[grimstone mask]);
      case "The Red Zeppelin's Mooring": return qprop("questL11Ron >= started");
      case "The Sea": if (!levelcheck(11) || $strings[Avatar of Boris, Zombie Slayer, Avatar of Jarlsberg, Class Act II, Avatar of Sneaky Pete, Actually Ed the Undying, 
            One Crazy Random Summer, The Source, Gelatinous Noob, License to Adventure, Dark Gyffte, Path of the Plumber, You\, Robot, Wildfire, Grey You] contains my_path()) return vprint("The Sea is unavailable.",-verb);
         if (qprop("questS01OldGuy < 0")) visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");   // unlocking the sea starts the Old Man quest
         if (qprop("questS01OldGuy < 0")) return vprint("The Sea could not be unlocked.",-verb);
         return true;
      case "The Snojo": return get_property("snojoAvailable").to_boolean();
      case "The Spacegate": return get_property("spacegateAlways").to_boolean() || get_property("_spacegateToday").to_boolean();
      case "Tower": return primecheck(11) && qprop("questG03Ego >= step1");
      case "Twitch": return get_property("timeTowerAvailable").to_boolean();
      case "Vanya's Castle": return itemcheck($item[map to vanya's castle]) && equipcheck($item[continuum transfunctioner]);
      case "Volcano": return primecheck(90) && qprop("questG04Nemesis >= step25");
      case "Woods": return levelcheck(2) && qprop("questL02Larva >= started");
      case "Wormwood": return effectcheck($effect[absinthe-minded]) || (!prep && itemcheck($item[tiny bottle of absinthe])) || (prep && use(1,$item[tiny bottle of absinthe]));
     // never open; their individual locations do not need to be present below
      case "The Candy Diorama":
      case "Crimbo05":
      case "Crimbo06":
      case "Crimbo07":
      case "Crimbo08":
      case "Crimbo09":
      case "Crimbo10":
      case "Crimbo12":
      case "Crimbo13":
      case "Crimbo14":
      case "Crimbo15":
      case "Crimbo16":
      case "Crimbo17":
      case "Crimbo18":
      case "Tammy's Offshore Platform":   // aka crimbo19
      case "Crimbo21":
      case "Events":
      case "WhiteWed": return vprint("Zone '"+zone+"' is never available.",-verb);
//      case "Gyms": case "Casino": case "Town": return true;
//      default: print("Unhandled zone: "+zone, "olive");
      }
      return true;
   }
  // begin location checking
   if (!zone_check(where.zone)) return false;
   if (!get_ignore_zone_warnings() && !primecheck(where.recommended_stat,true)) return false;
   switch (where) {
  // always open if their zone is
   case $location[The Bat Hole Entrance]:               // bathole
   case $location[The Deep Dark Jungle]:                // conspiracy
   case $location[The Mansion of Dr. Weirdeaux]:
   case $location[The Secret Government Laboratory]:
   case $location[Barf Mountain]:                       // dinseylandfill
   case $location[Pirates of the Garbage Barges]:
   case $location[The Toxic Teacups]:
   case $location[Uncle Gator's Country Fun-Time Liquid Waste Sluice]:
   case $location[Dreadsylvanian Castle]:               // dread
   case $location[Dreadsylvanian Village]:
   case $location[Dreadsylvanian Woods]:
   case $location[The Dripping Trees]:                  // drip
   case $location[The Haiku Dungeon]:                   // dungeon
   case $location[The Limerick Dungeon]:
   case $location[Mcmillicancuddy's Barn]:              // farm
   case $location[Mcmillicancuddy's Pond]:
   case $location[Mcmillicancuddy's Back 40]:
   case $location[Mcmillicancuddy's Other Back 40]:
   case $location[Mcmillicancuddy's Granary]:
   case $location[Mcmillicancuddy's Bog]:
   case $location[Mcmillicancuddy's Family Plot]:
   case $location[Mcmillicancuddy's Shady Thicket]:
   case $location[The Dark Neck of the Woods]:          // friars
   case $location[The Dark Heart of the Woods]:
   case $location[The Dark Elbow of the Woods]:
   case $location[Gingerbread Civic Center]:            // gingerbread
   case $location[Gingerbread Industrial Zone]:
   case $location[Gingerbread Train Station]:
   case $location[The Ice Hotel]:                       // glaciest
   case $location[VYKEA]:
   case $location[The Goo Fields]:                      // grey goo impact site
   case $location[The Goo-Choked Fun House]:
   case $location[The Goo-Coated Knob]:
   case $location[The Goo-Spewing Bat Hole]:
   case $location[The Goo-Bedecked Beanstalk]:
   case $location[The Goo-Shrouded Palindome]:
   case $location[The Goo-Girded Garves]:
   case $location[The Goo-Splattered Tower Ruins]:
   case $location[Ye Olde Medievale Villagee]:          // grimstone
   case $location[Portal to Terrible Parents]:
   case $location[Rumpelstiltskin's Workshop]:
   case $location[The Prince's Restroom]:
   case $location[The Prince's Dance Floor]:
   case $location[The Prince's Kitchen]:
   case $location[The Prince's Balcony]:
   case $location[The Prince's Lounge]:
   case $location[The Prince's Canapes Table]:
   case $location[Sweet-Ade Lake]:
   case $location[Eager Rice Burrows]:
   case $location[Gumdrop Forest]:
   case $location[The Inner Wolf Gym]:
   case $location[Unleash Your Inner Wolf]:
   case $location[A Massive Ziggurat]:                  // hiddencity
   case $location[The Hidden Park]:
   case $location[An Overgrown Shrine (Northwest)]:
   case $location[An Overgrown Shrine (Southwest)]:
   case $location[An Overgrown Shrine (Northeast)]:
   case $location[An Overgrown Shrine (Southeast)]:
   case $location[A-Boo Peak]:                          // highlands
   case $location[Oil Peak]:
   case $location[Twin Peak]:
   case $location[Wartime Hippy Camp]:                  // islewar
   case $location[Wartime Frat House]:
   case $location[Sonofa Beach]:
   case $location[Professor Jacking's Small-O-Fier]:    // jacking
   case $location[Professor Jacking's Huge-A-Ma-tron]:
   case $location[Near an Abandoned Refrigerator]:      // junkyard
   case $location[Next to that Barrel with Something Burning in it]:
   case $location[Over Where the Old Tires Are]:
   case $location[Out by that Rusted-Out Car]:
   case $location[The Outskirts of Cobb's Knob]:        // knob
   case $location[Art Class]:                           // kol high school
   case $location[Chemistry Class]:
   case $location[Shop Class]:
   case $location[The Hallowed Halls]:
   case $location[The Knob Shaft (Mining)]:             // lab
   case $location[Cobb's Knob Laboratory]:
   case $location[Outskirts of Camp Logging Camp]:      // little canadia
   case $location[Camp Logging Camp]:
   case $location[The Haunted Boiler Room]:             // manor0
   case $location[The Haunted Laundry Room]:
   case $location[The Haunted Wine Cellar]:
   case $location[The Haunted Conservatory]:            // manor1
   case $location[The Haunted Kitchen]:
   case $location[The Haunted Pantry]:
   case $location[The Haunted Bathroom]:                // manor2
   case $location[The Haunted Bedroom]:
   case $location[The Haunted Gallery]:
   case $location[The Haunted Laboratory]:              // manor3
   case $location[The Haunted Nursery]:
   case $location[The Haunted Storage Room]:
   case $location[The Goatlet]:                         // mclarge
   case $location[The Primordial Soup]:                 // memories
   case $location[The Jungles of Ancient Loathing]:
   case $location[Seaside Megalopolis]:
   case $location[Cobb's Knob Menagerie\, Level 1]:     // menagerie
   case $location[Cobb's Knob Menagerie\, Level 2]:
   case $location[Cobb's Knob Menagerie\, Level 3]:
   case $location[The Barrel Full of Barrels]:          // mountain
   case $location[The Dire Warren]:
   case $location[Noob Cave]:
   case $location[Thugnderdome]:                        // moxsign
   case $location[The Hatching Chamber]:                // orchard
   case $location[Infernal Rackets Backstage]:          // pandamonium
   case $location[The Laugh Floor]:
   case $location[Pandamonium Slums]:
   case $location[The Upper Chamber]:                   // pyramid
   case $location[A Mob of Zeppelin Protesters]:        // red zeppelin
   case $location[Battlefield (No Uniform)]:            // rift
   case $location[The X-32-F Combat Training Snowman]:  // snojo
   case $location[Hamburglaris Shield Generator]:       // spaaaace
   case $location[Domed City of Grimacia]:
   case $location[Domed City of Ronaldus]:
   case $location[The Fun-Guy Mansion]:                 // spring break
   case $location[Sloppy Seconds Diner]:
   case $location[The Clumsiness Grove]:                // suburbs
   case $location[The Glacier of Jerks]:
   case $location[The Maelstrom of Lovers]:
   case $location[LavaCo&trade; Lamp Factory]:          // that 70's volcano
   case $location[The Bubblin' Caldera]:
   case $location[The SMOOCH Army HQ]:
   case $location[The Velvet / Gold Mine]:
   case $location[The Sleazy Back Alley]:               // town
   case $location[12 West Main]:                        // twitch
   case $location[An Illicit Bohemian Party]:
   case $location[Globe Theatre Backstage]:
   case $location[Globe Theatre Main Stage]:
   case $location[KoL Con Clan Party House]:
   case $location[Moonshiners' Woods]:
   case $location[The Cave Before Time]:
   case $location[The Post-Mall]:
   case $location[The Roman Forum]:
   case $location[The Rowdy Saloon]:
   case $location[The Spooky Old Abandoned Mine]:
   case $location[Vanya's Castle Foyer]:                // vanya's castle
   case $location[Vanya's Castle Chapel]:
   case $location[The Spooky Forest]:                   // woods
   case $location[The Stately Pleasure Dome]:           // wormwood
   case $location[The Mouldering Mansion]:
   case $location[The Rogue Windmill]: return true;
  // astral
   case $location[An Incredibly Strange Place (Bad Trip)]: if (prep) set_property("choiceAdventure71","1"); return primecheck(19);
   case $location[An Incredibly Strange Place (Mediocre Trip)]: if (prep) set_property("choiceAdventure71","2"); return primecheck(51);
   case $location[An Incredibly Strange Place (Great Trip)]: if (prep) set_property("choiceAdventure71","3"); return primecheck(143);
  // bathole
   case $location[Guano Junction]: return resist($element[stench],prep);
   case $location[The Batrat and Ratbat Burrow]: if (prep && qprop("questL04Bat < step1")) use_upto(1, $item[sonar-in-a-biscuit],true);
      return qprop("questL04Bat >= step1") || item_amount($item[sonar-in-a-biscuit]) > 0;
   case $location[The Beanbat Chamber]: if (prep && qprop("questL04Bat < step2")) use_upto(2 - to_int(qprop("questL04Bat >= step1")), $item[sonar-in-a-biscuit],true);
      return qprop("questL04Bat >= step2") || item_amount($item[sonar-in-a-biscuit]) > 1 - to_int(qprop("questL04Bat >= step1"));
   case $location[The Boss Bat's Lair]: if (prep && qprop("questL04Bat < step3")) use_upto(3 - (to_int(qprop("questL04Bat >= step1")) + to_int(qprop("questL04Bat >= step2"))), $item[sonar-in-a-biscuit],true);
      if (qprop("questL04Bat")) return false;
      return get_property("questL04Bat") == "step3" || item_amount($item[sonar-in-a-biscuit]) > 2 - (to_int(qprop("questL04Bat >= step1")) + to_int(qprop("questL04Bat >= step2")));
  // beach
   case $location[South of the Border]: return !explo;
   case $location[Kokomo Resort]: if (explo) return false; if (have_effect($effect[tropical contact high]) > 0) return true;
      return (prep && use(1,$item[kokomo resort pass])) || (!prep && item_amount($item[kokomo resort pass]) > 0);
   case $location[The Arid, Extra-Dry Desert]: return my_path() == "Actually Ed the Undying" || itemcheck($item[your father's macguffin diary]) || itemcheck($item[copy of a jerk adventurer's father's diary]);
   case $location[The Oasis]: return my_path() == "Actually Ed the Undying" || ((itemcheck($item[your father's macguffin diary]) || itemcheck($item[copy of a jerk adventurer's father's diary])) && 
         qprop("questL11Desert >= started") && get_property("desertExploration").to_int() > 0);
   case $location[The Shore, Inc. Travel Agency]: if (explo) return false;
      if (my_path() == "Way of the Surprising Fist") return (my_adventures() < 5) ? vprint("Not enough adventures to take a vacation.",-verb) : true;
      if (my_adventures() < 3) return vprint("Not enough adventures to take a vacation.",-verb);
      if (my_meat() < 500) return vprint("Not enough meat to take a vacation.",-verb);
      return (perm_urlcheck("main.php","map7beach.gif"));
  // beanstalk
   case $location[The Castle in the Clouds in the Sky \(Top Floor\)]: if (!qprop("questL10Garbage") && get_property("lastCastleTopUnlock").to_int() < my_ascensions()) return false;
   case $location[The Castle in the Clouds in the Sky \(Ground Floor\)]: if (!qprop("questL10Garbage") && get_property("lastCastleGroundUnlock").to_int() < my_ascensions()) return false;
   case $location[The Castle in the Clouds in the Sky \(Basement\)]: return explo || itemcheck($item[S.O.C.K.]) || itemcheck($item[intragalactic rowboat]);
   case $location[The Hole in the Sky]: return explo || itemcheck($item[steam-powered model rocketship]);
   case $location[The Penultimate Fantasy Airship]: return explo ? false : perm_urlcheck("place.php?whichplace=plains&action=garbage_grounds","climb_beanstalk.gif");
  // campground
   case $location[Your Mushroom Garden]: return get_campground() contains $item[packet of mushroom spores] && is_unrestricted($item[packet of mushroom spores]) && 
      get_property("_mushroomGardenFights").to_int() < 1 + 4*to_int(my_class() == $class[plumber]);
  // casino
   case $location[The Poker Room]: if (my_meat() < 30) return vprint("You need 30 meat to play the "+where+".",-verb);
   case $location[Pirate Party]:
   case $location[Lemon Party]:
   case $location[The Roulette Tables]: if (my_meat() < 10) return vprint("You need 10 meat to play the "+where+".",-verb);
   case $location[Goat Party]: if (my_meat() < 5) return vprint("You need 5 meat to play the Goat Party.",-verb); return itemcheck($item[casino pass]);
  // clan basement
   case $location[Richard's Hobo Moxie]:
   case $location[Richard's Hobo Muscle]:
   case $location[Richard's Hobo Mysticality]: return zone_check("Hobopolis") && hobocheck();  // these are in zone "Gyms"
   case $location[A Maze of Sewer Tunnels]: return my_adventures() > 9 && !visit_url("clan_hobopolis.php").contains_text("deeper.gif");
   case $location[Hobopolis Town Square]:
   case $location[Burnbarrel Blvd.]:
   case $location[Exposure Esplanade]:
   case $location[The Heap]:
   case $location[The Ancient Hobo Burial Ground]:
   case $location[The Purple Light District]: return hobocheck();
   case $location[The Slime Tube]: return (timed_url("clan_slimetube.php", 300000,verb).contains_text("thebucket.gif"));  // 5 min
  // cyrpt
   case $location[The Defiled Nook]: return get_property("cyrptNookEvilness").to_int() > 0;
   case $location[The Defiled Cranny]: return get_property("cyrptCrannyEvilness").to_int() > 0;
   case $location[The Defiled Alcove]: return get_property("cyrptAlcoveEvilness").to_int() > 0;
   case $location[The Defiled Niche]: return get_property("cyrptNicheEvilness").to_int() > 0;
   case $location[Haert of the Cyrpt]: return qprop("questL07Cyrptic >= started") && !qprop("questL07Cyrptic") && timed_url("questlog.php?which=1", 3600000, verb).contains_text("999<");  // 1hr
  // drip
   case $location[The Dripping Hall]: return get_property("drippingHallUnlocked").to_boolean();
  // dungeon
   case $location[The Daily Dungeon]: return !get_property("dailyDungeonDone").to_boolean();
   case $location[The Enormous Greater-Than Sign]: return my_basestat(my_primestat()) > 44 && (get_property("lastPlusSignUnlock").to_int() < my_ascensions() || contains_text(visit_url("da.php"),"Greater"));
   case $location[The Dungeons of Doom]: return get_property("lastPlusSignUnlock").to_int() == my_ascensions() && perm_urlcheck("da.php","ddoom.gif");
   case $location[Video Game Level 1]:
   case $location[Video Game Level 2]:
   case $location[Video Game Level 3]: return (itemcheck($item[GameInformPowerDailyPro Walkthru]) || itemcheck($item[GameInformPowerDailyPro magazine]));
  // exploathing
   case $location[The Exploaded Battlefield]: return !qprop("questL12HippyFrat");
   case $location[The Invader]: return !to_boolean(get_property("spaceInvaderDefeated"));
  // fantasyrealm
   case $location[The Bandit Crossroads]:
   case $location[The Towering Mountains]:
   case $location[The Mystic Wood]:
   case $location[The Putrid Swamp]:
   case $location[The Cursed Village]:
   case $location[The Sprawling Cemetery]:
   case $location[The Old Rubee Mine]:
   case $location[The Foreboding Cave]:
   case $location[The Faerie Cyrkle]:
   case $location[The Druidic Campsite]:
   case $location[Near the Witch's House]:
   case $location[The Evil Cathedral]:
   case $location[The Barrow Mounds]:
   case $location[The Cursed Village Thieves' Guild]:
   case $location[The Troll Fortress]:
   case $location[The Labyrinthine Crypt]:
   case $location[The Lair of the Phoenix]:
   case $location[The Dragon's Moor]:
   case $location[Duke Vampire's Chateau]:
   case $location[The Master Thief's Chalet]:
   case $location[The Spider Queen's Lair]:
   case $location[The Archwizard's Tower]:
   case $location[The Ley Nexus]:
   case $location[The Ghoul King's Catacomb]:
   case $location[The Ogre Chieftain's Keep]: return equipcheck($item[fantasyrealm G. E. M.], $slot[acc3]) && get_property("_frAreasUnlocked").contains_text(where.to_string()) && 
      get_property("_frHoursLeft").to_int() > 0 && (!prep || use_familiar($familiar[none]));
  // gingerbread
   case $location[Gingerbread Sewers]: return get_property("gingerSewersUnlocked").to_boolean();
   case $location[Gingerbread Upscale Retail District]: return get_property("gingerRetailUnlocked").to_boolean();
  // glaciest
   case $location[The Ice Hole]: return not_blind();
  // grimstone
   case $location[A Deserted Stretch of I-911]: return get_property("grimstoneMaskPath") == "hare";
  // gyms
   case $location[Pump Up Moxie]: return zone_check("MoxSign");
   case $location[Pump Up Muscle]: return (knoll_available() && (checkguild(prep) || qprop("questM01Untinker > unstarted")) && perm_urlcheck("place.php?whichplace=plains","Degrassi Gnoll"));
   case $location[Pump Up Mysticality]: return canadia_available();
  // hiddencity
   case $location[The Hidden Apartment Building]: return get_property("hiddenApartmentProgress").to_int() > 0;
   case $location[The Hidden Hospital]: return get_property("hiddenHospitalProgress").to_int() > 0;
   case $location[The Hidden Office Building]: return get_property("hiddenOfficeProgress").to_int() > 0;
   case $location[The Hidden Bowling Alley]: return get_property("hiddenBowlingAlleyProgress").to_int() > 0;
  // holiday
   case $location[The Spectral Pickle Factory]: return primecheck(50) && today_to_string().substring(4, 8) == "0401";
   case $location[The Arrrboretum]: return gameday_to_string() == "Petember 4";
   case $location[Generic Summer Holiday Swimming!]: return gameday_to_string() == "Bill 3";
   case $location[Trick-or-Treating]: return (gameday_to_string() == "Porktember 8" || today_to_string().substring(4, 8) == "1031");
   case $location[The Yuletide Bonfire]: return gameday_to_string() == "Dougtember 4";
  // island
   case $location[Barrrney's Barrr]: return qprop("questM12Pirate > unstarted") || equipcheck($item[pirate fledges],$slot[acc3]) || outfitcheck("swashbuckling getup");
   case $location[The F'c'le]: return qprop("questM12Pirate > 4") && (equipcheck($item[pirate fledges],$slot[acc3]) || outfitcheck("swashbuckling getup"));
   case $location[The Poop Deck]: return qprop("questM12Pirate > 4") && equipcheck($item[pirate fledges]);
   case $location[Belowdecks]: return qprop("questM12Pirate") && equipcheck($item[pirate fledges],$slot[acc3]);
   case $location[Hippy Camp In Disguise]: if (!outfitcheck("filthy hippy disguise")) return false;
   case $location[Hippy Camp]: return get_property("sideDefeated") != "hippies" && get_property("sideDefeated") != "both";
   case $location[Frat House In Disguise]: if (!outfitcheck("frat boy ensemble")) return false;
   case $location[Frat House]: return get_property("sideDefeated") != "fratboys" && get_property("sideDefeated") != "both";
   case $location[The Obligatory Pirate's Cove]: if (prep) cli_execute("unequip pirate fledges"); 
      return !have_equipped($item[pirate fledges]) && !is_wearing_outfit("swashbuckling getup");
   case $location[McMillicancuddy's Farm]:
   case $location[Post-War Junkyard]: return qprop("questL12War");
   case $location[The Hippy Camp (Bombed Back to the Stone Age)]: return qprop("questL12War") && get_property("sideDefeated") != "fratboys";
   case $location[The Orcish Frat House (Bombed Back to the Stone Age)]: return qprop("questL12War") && get_property("sideDefeated") != "hippies";
  // islewar
   case $location[Wartime Hippy Camp (Frat Disguise)]: return outfitcheck("frat warrior fatigues") || outfitcheck("frat boy ensemble");
   case $location[Wartime Frat House (Hippy Disguise)]: return outfitcheck("war hippy fatigues") || outfitcheck("filthy hippy disguise");
   case $location[The Battlefield (Frat Uniform)]: return qprop("questL12War >= step1") && outfitcheck("frat warrior fatigues") && get_property("hippiesDefeated") != "1000";
   case $location[The Battlefield (Hippy Uniform)]: return qprop("questL12War >= step1") && outfitcheck("war hippy fatigues") && get_property("fratboysDefeated") != "1000";
   case $location[The Themthar Hills]: return qprop("questL12War >= step1") && get_property("sidequestNunsCompleted") == "none";
  // knob
   case $location[Cobb's Knob Kitchens]:
   case $location[Cobb's Knob Barracks]:
   case $location[Cobb's Knob Treasury]:
   case $location[Cobb's Knob Harem]: return perm_urlcheck("cobbsknob.php",to_url(where));
   case $location[Throne Room]: return (!qprop("questL05Goblin") &&
      (outfitcheck("harem girl disguise") && (effectcheck($effect[knob goblin perfume]) || (!prep && itemcheck($item[knob goblin perfume])) ||
       (prep && use(1,$item[knob goblin perfume])))) || (outfitcheck("Knob Goblin Elite Guard Uniform") && itemcheck($item[knob cake])));
  // lab
   case $location[The Knob Shaft]: return have_effect($effect[earthen fist]) == 0;
  // le marais degueulasse
   case $location[The Edge of the Swamp]: return qprop("questM18Swamp >= started");
   case $location[Swamp Beaver Territory]: return get_property("maraisBeaverUnlock") == "true";
   case $location[The Corpse Bog]: return get_property("maraisCorpseUnlock") == "true";
   case $location[The Dark and Spooky Swamp]: return get_property("maraisDarkUnlock") == "true";
   case $location[The Ruined Wizard Tower]: return get_property("maraisWizardUnlock") == "true";
   case $location[The Weird Swamp Village]: return get_property("maraisVillageUnlock") == "true";
   case $location[The Wildlife Sanctuarrrrrgh]: return get_property("maraisWildlifeUnlock") == "true";
  // manor
   case $location[The Haunted Billiards Room]: return itemcheck($item[Spookyraven billiards room key]);
   case $location[The Haunted Library]: return itemcheck($item[7302]);   // spookyraven library key is NOT item #1764
   case $location[The Haunted Ballroom]: return qprop("questM21Dance > 2");
   case $location[Summoning Chamber]: if (qprop("questL11Manor < 2") || qprop("questL11Manor > 3")) return false;
      return timed_url("place.php?whichplace=manor4&action=manor4_chamberwall",5000,verb).contains_text("chamberboss");  // 5 sec url check here because step2 doesn't upgrade to step3 when you break down the wall
  // mclarge
   case $location[Dwarven Factory Warehouse]:
   case $location[The Mine Foremens' Office]: return (primecheck(100) && outfitcheck("mining gear") && checkguild(prep) && qprop("questG06Delivery >= started"));
   case $location[The Icy Peak]: return qprop("questL08Trapper");
   case $location[Itznotyerzitz Mine]: return have_effect($effect[earthen fist]) == 0;
   case $location[Itznotyerzitz Mine (In Disguise)]: return (my_path() == "Way of the Surprising Fist") ? effectcheck($effect[earthen fist]) : outfitcheck("mining gear");
   case $location[the eXtreme Slope]:
   case $location[Lair of the Ninja Snowmen]: return qprop("questL08Trapper >= step2");
   case $location[Mist-Shrouded Peak]: return !qprop("questL08Trapper") && qprop("questL08Trapper > 2");
  // mothership
   case $location[Engineering]: return get_property("mothershipProgress") == "2" && get_property("statusEngineering") == "open";
   case $location[Galley]: return get_property("mothershipProgress") == "2" && get_property("statusGalley") == "open";
   case $location[Medbay]: return get_property("statusMedbay") == "open";
   case $location[Morgue]: return get_property("mothershipProgress") == "1" && get_property("statusMorgue") == "open";
   case $location[Navigation]: return get_property("mothershipProgress") == "2" && get_property("statusNavigation") == "open";
   case $location[Science Lab]: return get_property("mothershipProgress") == "1" && get_property("statusScienceLab") == "open";
   case $location[Sonar]: return get_property("statusSonar") == "open";
   case $location[Special Ops]: return get_property("mothershipProgress") == "1" && get_property("statusSpecialOps") == "open";
   case $location[Waste Processing]: return get_property("statusWasteProcessing") == "open";
  // mountain
   case $location[Mt. Molehill]: return effectcheck($effect[shape of...mole!]) || (!prep && itemcheck($item[llama lama gong]));
   case $location[The Fungal Nethers]: return primecheck(25) && qprop("questG04Nemesis >= 12");
   case $location[The Smut Orc Logging Camp]: return levelcheck(9) && qprop("questL09Topping >= started");
   case $location[The Thinknerd Warehouse]: return qprop("questM22Shirt > unstarted");
   case $location[The Valley of Rof L'm Fao]: return levelcheck(9) && qprop("questM15Lol >= started");
   case $location[The Secret Council Warehouse]: return my_path() == "Actually Ed the Undying" && qprop("questL13Warehouse >= started");
  // orchard
   case $location[The Feeding Chamber]: return effectcheck($effect[filthworm larva stench]);
   case $location[The Royal Guard Chamber]: return effectcheck($effect[filthworm drone stench]);
   case $location[The Filthworm Queen's Chamber]: return effectcheck($effect[filthworm guard stench]);
  // PirateRealm
   case $location[Battle Island]:
   case $location[Crab Island]:
   case $location[Glass Island]:
   case $location[Dessert Island]:
   case $location[Key Key]:
   case $location[Skull Island]:
   case $location[Isla Gublar]:
   case $location[Cemetery Island]:
   case $location[Jungle Island]:
   case $location[Trash Island]:
   case $location[Prison Island]:
   case $location[Signal Island]:
   case $location[Tiki Island]:
   case $location[Storm Island]:
   case $location[Red Roger's Fortress]:
   case $location[Jack's Hideout]:
   case $location[The Temple]: if (to_location(get_property("_LastPirateRealmIsland")) != where) return false;
   case $location[PirateRealm Island]: return get_property("_LastPirateRealmIsland") != "";
   case $location[Sailing the PirateRealm Seas]: return get_property("_LastPirateRealmIsland") == "";
  // plains
   case $location[The Unquiet Garves]: return qprop("questL07Cyrptic >= started") || (checkguild(prep) && qprop("questG03Ego >= started"));
   case $location[The VERY Unquiet Garves]: return qprop("questL07Cyrptic");
   case $location[the Degrassi Knoll Bakery]:
   case $location[the Degrassi Knoll Garage]:
   case $location[the Degrassi Knoll Gym]:
   case $location[the Degrassi Knoll Restroom]: return (!knoll_available() && (checkguild(prep) || qprop("questM01Untinker >= started")) && perm_urlcheck("place.php?whichplace=plains","knollinside.gif"));
   case $location[The "Fun" House]: return primecheck(12) && checkguild(prep) && qprop("questG04Nemesis >= 5") && perm_urlcheck("place.php?whichplace=plains","funhouse.gif");
   case $location[Inside the Palindome]: return levelcheck(11) && equipcheck($item[talisman o' namsilat],$slot[acc3]);
  // psychoses
   case $location[Anger Man's Level]:
   case $location[Fear Man's Level]:
   case $location[Doubt Man's Level]:
   case $location[Regret Man's Level]: return jarcheck("The Crackpot Mystic");
   case $location[The Nightmare Meatrealm]: return jarcheck("The Meatsmith");
   case $location[A Kitchen Drawer]:
   case $location[A Grocery Bag]: return jarcheck("The Pretentious Artist");
   case $location[Triad Factory]: return jarcheck("The Suspicious-Looking Guy") && itemcheck($item[zaibatsu lobby card]) && item_amount($item[strange goggles]) == 0;
   case $location[Chinatown Shops]: return jarcheck("The Suspicious-Looking Guy") && item_amount($item[strange goggles]) == 0;
   case $location[1st Floor, Shiawase-Mitsuhama Building]: return jarcheck("The Suspicious-Looking Guy") && contains_text(timed_url("place.php?whichplace=junggate_1",5000,verb),to_url(where));  // 5 sec
   case $location[2nd Floor, Shiawase-Mitsuhama Building]: cli_execute("use * zaibatsu level 2 card"); return jarcheck("The Suspicious-Looking Guy") && contains_text(timed_url("place.php?whichplace=junggate_1", 5000, verb),to_url(where));
   case $location[3rd Floor, Shiawase-Mitsuhama Building]: cli_execute("use * zaibatsu level 3 card"); return jarcheck("The Suspicious-Looking Guy") && contains_text(timed_url("place.php?whichplace=junggate_1", 5000, verb),to_url(where));
   case $location[Chinatown Tenement]: return jarcheck("The Suspicious-Looking Guy") && itemcheck($item[test site key]);
   case $location[The Gourd!]: return jarcheck("The Captain of the Gourd");
   case $location[The Tower of Procedurally-Generated Skeletons]: return jarcheck("Jick");
   case $location[The Old Man's Bathtime Adventures]: return jarcheck("The Old Man");
  // pyramid
   case $location[The Lower Chambers]: return get_property("lowerChamberUnlock").to_boolean() && !qprop("questL11Pyramid");
   case $location[The Middle Chamber]: return get_property("middleChamberUnlock").to_boolean();
  // red zeppelin's mooring
   case $location[The Red Zeppelin]: return get_property("zeppelinProtestors").to_int() >= 80 || qprop("questL11Ron >= 2");
  // rift
   case $location[Battlefield (Cloaca Uniform)]: return outfitcheck("cloaca-cola uniform");
   case $location[Battlefield (Dyspepsi Uniform)]: return outfitcheck("dyspepsi-cola uniform");
  // sea
   case $location[The Briny Deeps]:                     // sea
   case $location[The Brinier Deepers]:
   case $location[The Briniest Deepests]:
   case $location[An Octopus's Garden]: return not_blind();
   case $location[The Wreck of the Edgar Fitzsimmons]: return qprop("questS02Monkees >= 1") && seafloor_check("shipwreck") && not_blind();
   case $location[Madness Reef]: return qprop("questS02Monkees > 1") && seafloor_check("reef") && not_blind();
   case $location[The Marinara Trench]: return qprop("questS02Monkees > 1") && seafloor_check("trench") && not_blind();
   case $location[Anemone Mine]:
   case $location[Anemone Mine (Mining)]: return qprop("questS02Monkees > 1") && seafloor_check("mine") && not_blind();
   case $location[The Dive Bar]: return qprop("questS02Monkees > 1") && seafloor_check("divebar") && not_blind();
   case $location[The Skate Park]: return qprop("questS02Monkees > 1") && seafloor_check("skatepark") && not_blind();
   case $location[The Mer-Kin Outpost]: return qprop("questS02Monkees > 5") && seafloor_check("outpost") && not_blind();
   case $location[The Coral Corral]: return qprop("questS02Monkees > 5") && get_property("merkinLockkeyMonster") != "" && seafloor_check("corral") && not_blind();
   case $location[The Caliginous Abyss]: return qprop("questS02Monkees > 1") && seafloor_check("abyss") && not_blind();
   case $location[Mer-kin Elementary School]:
   case $location[Mer-kin Gymnasium]: return get_property("seahorseName") != "" && outfitcheck("Crappy Mer-kin Disguise") && not_blind();
   case $location[Mer-kin Library]: return get_property("seahorseName") != "" && outfitcheck("Mer-kin Scholar's Vestments") && not_blind();
   case $location[Mer-kin Colosseum]: return get_property("seahorseName") != "" && outfitcheck("Mer-kin Gladiatorial Gear") && not_blind();
  // signs
   case $location[The Bugbear Pen]: return primecheck(13) && qprop("questM03Bugbear >= 0") && !qprop("questM03Bugbear");
   case $location[Post-Quest Bugbear Pens]: return primecheck(13) && qprop("questM03Bugbear") && perm_urlcheck("woods.php","pen.gif");
   case $location[The Spooky Gravy Burrow]: return (famcheck($familiar[spooky gravy fairy]) || famcheck($familiar[sleazy gravy fairy]) ||
           famcheck($familiar[frozen gravy fairy]) || famcheck($familiar[flaming gravy fairy]) || famcheck($familiar[stinky gravy fairy]));
  // sorceress
   case $location[Fastest Adventurer Contest]: return get_property("questL13Final") == "step1" && get_property("nsContestants1") > 0;
   case $location[Strongest Adventurer Contest]:
   case $location[Smartest Adventurer Contest]:
   case $location[Smoothest Adventurer Contest]:
   case $location[A Crowd of (Stat) Adventurers]: return get_property("questL13Final") == "step1" && get_property("nsContestants2") > 0;
   case $location[Hottest Adventurer Contest]:
   case $location[Coldest Adventurer Contest]:
   case $location[Spookiest Adventurer Contest]:
   case $location[Stinkiest Adventurer Contest]:
   case $location[Sleaziest Adventurer Contest]:
   case $location[A Crowd of (Element) Adventurers]: return get_property("questL13Final") == "step1" && get_property("nsContestants3") > 0;
   case $location[The Hedge Maze]: return get_property("questL13Final") == "step4";
   case $location[Tower Level 1]: return get_property("questL13Final") == "step6";
   case $location[Tower Level 2]: return get_property("questL13Final") == "step7";
   case $location[Tower Level 3]: return get_property("questL13Final") == "step8";
   case $location[Tower Level 4]: return get_property("questL13Final") == "step9";
   case $location[Tower Level 5]: return get_property("questL13Final") == "step10";
   case $location[The Naughty Sorceress' Chamber]: return get_property("questL13Final") == "step11";
  // spacegate
   case $location[Through the Spacegate]: return get_property("_spacegateCoordinates") != "" && get_property("_spacegateTurnsLeft") > 0;
  // spring break
   case $location[The Sunken Party Yacht]: return not_blind();
  // that 70s volcano
   case $location[The Velvet / Gold Mine (Mining)]: if (numeric_modifier("Hot Resistance") < 15) return vprint("You have only "+rnum(numeric_modifier("Hot Resistance"))+" of 15 Hot Resistance needed to mine here.",-verb);
      return equipcheck($item[high-temperature mining drill]);
  // tower
   case $location[Fernswarthy's Basement]: return qprop("questG03Ego >= step4") && perm_urlcheck("fernruin.php",to_url(where));
   case $location[Tower Ruins]: return (itemcheck($item[fernswarthy's letter]));
  // town
   case $location[Madness Bakery]: return qprop("questM25Armorer >= started");
   case $location[The Deep Machine Tunnels]: return famcheck($familiar[machine elf]) || (effectcheck($effect[inside the snowglobe]) || (!prep && itemcheck($item[deep machine tunnels snowglobe])) || (prep && use(1,$item[deep machine tunnels snowglobe])));
   case $location[The Overgrown Lot]: return qprop("questM24Doc >= started");
   case $location[The Copperhead Club]: return levelcheck(11) && qprop("questL11Shen >= started");
   case $location[The Skeleton Store]: if (qprop("questM23Meatsmith >= started")) return true; cli_execute("use * bone with a price tag on it"); 
      return perm_urlcheck("place.php?whichplace=town_market",to_url(where));
   case $location[Investigating a Plaintive Telegram]: return get_property("telegraphOfficeAvailable").to_boolean();
   case $location[The Tunnel of L.O.V.E.]: return get_property("loveTunnelAvailable").to_boolean() && !to_boolean(get_property("_loveTunnelUsed"));
   case $location[Super Villain's Lair]: return my_path() == "License to Adventure" && get_property("_villainLairProgress").to_int() < 999;
   case $location[The Neverending Party]: return (get_property("_questPartyFair") == "" || qprop("_questPartyFair < finished")) && (get_property("neverendingPartyAlways").to_boolean() || get_property("_neverendingPartyToday").to_boolean());
  // volcano
   case $location[The Broodling Grounds]: return my_class() == $class[seal clubber];
   case $location[The Outer Compound]: return my_class() == $class[turtle tamer];
   case $location[The Temple Portico]: return my_class() == $class[pastamancer];
   case $location[Convention Hall Lobby]: return my_class() == $class[sauceror];
   case $location[Outside the Club]: return my_class() == $class[disco bandit] && !qprop("questG04Nemesis");
   case $location[The Island Barracks]: return my_class() == $class[accordion thief];
   case $location[The Nemesis' Lair]: return qprop("questG04Nemesis > 25") && !qprop("questG04Nemesis");
  // woods
   case $location[8-Bit Realm]: return !explo && primecheck(20);
   case $location[A Barroom Brawl]:
   case $location[The Typical Tavern Cellar]: return levelcheck(3) && qprop("questL03Rat >= started");
   case $location[The Black Forest]: return levelcheck(11) && qprop("questL11MacGuffin >= started");
   case $location[The Hidden Temple]: return get_property("lastTempleUnlock").to_int() == my_ascensions();
   case $location[The Old Landfill]: return perm_urlcheck("woods.php",to_url(where));
   case $location[The Road to the White Citadel]: return qprop("questG02Whitecastle > 0") && !qprop("questG02Whitecastle");
   case $location[Whitey's Grove]: return (levelcheck(7) && primecheck(34) && !explo && (qprop("questL11Palindome >= step3") || (checkguild(prep) && qprop("questG02Whitecastle >= started"))) && perm_urlcheck("woods.php","grove.gif"));
  // unique locations
   case $location[Friar Ceremony Location]: return (itemcheck($item[dodecagram]) && itemcheck($item[box of birthday candles]) && itemcheck($item[eldritch butterknife]));
   case $location[El Vibrato Island]: return (itemcheck($item[el vibrato trapezoid]) || contains_text(visit_url("campground.php"),"Portal1.gif"));
   case $location[The Red Queen's Garden]: return !explo && (effectcheck($effect[down the rabbit hole]) || (!prep && itemcheck($item[&quot;DRINK ME&quot; potion])) || (prep && use(1,$item[&quot;DRINK ME&quot; potion])));
   case $location[The Landscaper's Lair]: return itemcheck($item[antique painting of a landscape]);
   case $location[Kegger in the Woods]: return (itemcheck($item[map to the kegger in the woods]));
   case $location[The Electric Lemonade Acid Parade]: return (itemcheck($item[map to the magic commune]));
   case $location[Neckback Crick]: return (itemcheck($item[map to ellsbury's claim]));
  // never open
   case $location[Heartbreaker's Hotel]:
   case $location[Spectral Salad Factory]: return vprint(where+" is no longer adventurable.",-verb);
   default: vprint("Unknown location: "+where+" (zone: "+where.zone+")","olive",-2);
            return vprint("Please report this missing location here: http://kolmafia.us/showthread.php?t=2027","black",-2);
   }
}

boolean can_adv(location where, boolean p) { return can_adv(where, p, 9); }
boolean can_adv(location where, int verb)  { return can_adv(where, false, verb); }
boolean can_adv(location where) {            return can_adv(where, false, 9); }

string[string] post = form_fields();  // provide hook for relay scripts to Ajax zone availability
if (post contains "where") {
   location w = to_location(post["where"]);
   int postverb = (post contains "verb" && is_integer(post["verb"])) ? post["verb"].to_int() : 9;
   if (w == $location[none] || !can_adv(w, postverb)) write("unavailable");
    else write("available");
   exit;
}

void main(location theplace) {
   if (theplace == $location[none]) {
      foreach l in $locations[]
         if (can_adv(l)) vprint(l+" is available to your character.","green",7);
          else vprint(l+" is not available to your character.",-6);
      exit;
   }
   if (can_adv(theplace)) vprint(theplace+" is available to your character.","green",7);
    else vprint(theplace+" is not available to your character.",-6);
}