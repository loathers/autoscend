script "sl_test.ash"

import <sl_ascend.ash>

boolean passed;

void assertTrue(boolean val, string message)
{
	if (!val)
	{
		print("Assertion failed: " + message, "red");
	}
	passed &= val;
}

void testLoadConsumables()
{
	ConsumeAction[int] actions;
	loadConsumables("eat", actions);

	void assertContains(item searchFor, string message)
	{
		boolean found = false;
		foreach i, action in actions
		{
			if (action.it == searchFor) found = true;
		}
		assertTrue(found, message);
	}

	assertTrue(count(actions) > 0, "actions should be nonempty");
	if (isHermitAvailable())
	{
		assertContains($item[catsup], "hermit items should be present");
	}
	// if (canadia_available()) assertTrue(0 < count(cafe_backmap), "In Canadia moonsign: Cafe items should be loaded");
	// if (!canadia_available()) assertTrue(0 == count(cafe_backmap), "Not in Canadia moonsign: Cafe items should not be loaded");
}

void testKnapsackAutoConsume()
{
	sl_knapsackAutoConsume("eat", true);
	sl_knapsackAutoConsume("drink", true);
}

void main()
{
	void runTest(string name)
	{
		passed = true;
		call void name();
		string color = passed ? "green" : "red";
		string sstatus = passed ? "PASS" : "FAIL";
		print(name + ": " + sstatus, color);
	}
	runTest("testLoadConsumables");
	runTest("testKnapsackAutoConsume");
}