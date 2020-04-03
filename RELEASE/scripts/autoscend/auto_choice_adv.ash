script "auto_choice_adv.ash";
import<autoscend.ash>

void main(int choice, string page)
{
	switch (choice) {
		case 1023: // Like a Bat Into Hell (Actually Ed the Undying)
			run_choice(1); // Enter the Underworld
			auto_log_info("Ed died in combat " + get_property("_edDefeats").to_int() + " time(s)", "blue");
			ed_shopping(); // "free" trip to the Underworld, may as well go shopping!
			visit_url("place.php?whichplace=edunder&action=edunder_leave");
			break;
		case 1024:  // Like a Bat out of Hell (Actually Ed the Undying)
			if (get_property("_edDefeats").to_int() < get_property("edDefeatAbort").to_int()) {
				// resurrecting is still free.
				run_choice(1, false); // UNDYING!
			} else {
				// resurrecting will cost Ka
				run_choice(2); // Accept the cold embrace of death (Return to the Pyramid)
				auto_log_info("Ed died in combat for reals!");
				set_property("auto_beatenUpCount", get_property("auto_beatenUpCount").to_int() + 1);
			}
			break;
		case 1340: // Is There A Doctor In The House? (Lil' Doctor Bag™)
			auto_log_info("Accepting doctor quest, it's our job!");
			run_choice(1);
			break;
		case 1342: // Torpor (Dark Gyffte)
			bat_reallyPickSkills(20);
			break;
		case 1387: // Using the Force (Fourth of May Cosplay Saber)
			run_choice(get_property("_auto_saberChoice").to_int());
			break;
		default:
			break;
	}
}