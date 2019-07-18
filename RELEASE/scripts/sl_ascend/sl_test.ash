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
	item[int] item_backmap;
	int[int] cafe_backmap;
	float[int] adv;
	int[int] space;
	loadConsumables("eat", item_backmap, cafe_backmap, adv, space);

	void assertContains(item searchFor, string message)
	{
		boolean found = false;
		foreach i, it in item_backmap
		{
			if (it == searchFor) found = true;
		}
		assertTrue(found, message);
	}

	assertTrue(count(item_backmap) > 0, "item_backmap should be nonempty");
	assertTrue(count(adv) > 0, "adv should be nonempty");
	assertTrue(count(space) > 0, "space should be nonempty");
	assertContains($item[catsup], "hermit items should be present");
	if (canadia_available()) assertTrue(0 < count(cafe_backmap), "In Canadia moonsign: Cafe items should be loaded");
	if (!canadia_available()) assertTrue(0 == count(cafe_backmap), "Not in Canadia moonsign: Cafe items should not be loaded");
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