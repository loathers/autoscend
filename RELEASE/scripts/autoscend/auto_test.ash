script "auto_test.ash"

import <autoscend.ash>

boolean passed;

void assertTrue(boolean val, string message)
{
	if (!val)
	{
		auto_log_warning("Assertion failed: " + message, "red");
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
}

void testKnapsackAutoConsume()
{
	auto_knapsackAutoConsume("eat", true);
	auto_knapsackAutoConsume("drink", true);
}

void main()
{
	void runTest(string name)
	{
		passed = true;
		call void name();
		string color = passed ? "green" : "red";
		string sstatus = passed ? "PASS" : "FAIL";
		auto_log_info(name + ": " + sstatus, color);
	}
	runTest("testLoadConsumables");
	runTest("testKnapsackAutoConsume");
}
