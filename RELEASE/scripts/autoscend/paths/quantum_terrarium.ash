// boolean in_qTerrarium()
// // If we needed a function to check if we're in Quantum Terrarium for some reason?
// {
// 	return (my_path() == "Quantum Terrarium");
// }

// void qTerrarium_initializeSettings()
// //Set whatever necessary settings need set.
// {
// 	if(my_path() == "Quantum Terrarium")
// 	{
// 		set_property("whatever", true/false);
// 	}
// }

boolean qFamiliarSwap (familiar fam)
//Swap/designate next familiar swap if possible.
{
   if(fam == $familiar[none])
	{
      print(fam.to_string() + " is not a valid familiar, weird behaviour.";
      return false;
	}
   if (qFamiliarAvailable(fam))
   {
      visit_url("qterrarium.php?pwd=&action=fam&fid="+ fam.to_int);
      return true;
   }
   
}

boolean qFamiliarAvailable (familiar fam)
//Check to see if target familiar can be forced.
{
   string qTerrariumPage = visit_url("qterrarium.php");
   string qFamiliarKey = "^\<option value \=\"" + fam.to_int() + "\"\>$";
   matcher qFamiliarSearch = create_matcher(qFamiliarKey, qTerrariumPage);

   if (total_turns_played() < get_property("_nextQuantumAlignment").to_int())
   {
      return false;
   }
   else if (find(qFamiliarSearch))
   {
      return true;
   }
   else 
   {
      return false;
   }
}
