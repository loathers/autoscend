# Contributing Guide

autoscend is a community project and we welcome contributions. There are many ways to contribute, including submitting bug reports, improving documentation, submitting feature requests, reviewing new submissions, or contributing code that can be incorporated into the project.

This document describes our development process. Following these guidelines shows that you respect the time and effort of the developers managing this project. In return, you will be shown respect in addressing your issue, reviewing your changes, and incorporating your contributions.

**Table of Contents:**

1. [Code of Conduct](#code-of-conduct)
2. [Important Resources](#important-resources)
3. [Questions](#questions)
4. [Reporting Bugs and Feature Requests](#reporting-bugs-and-feature-requests)
5. [Contributing Code](#contributing-code)
	1. [Forks and Branches](#forks-and-branches)
	2. [Merging Pull Requests](#merging-pull-requests)


## Code of Conduct

We basically abide by one ultimate golden rule:

1. Don't act like a jackass

That covers a surprising number of bases.

## Important Resources

* [autoscend channel on the Ascension Speed Society discord server](https://discord.gg/96xZxv3)
* [KoLMafia Ash Function Reference](https://wiki.kolmafia.us/index.php?title=Ash_Functions)
* [KoLMafia Basic Scripting](http://kolmafia.sourceforge.net/scripting.html)
* [KoLMafia Advanced Scripting](http://kolmafia.sourceforge.net/advanced.html)

## Questions

The best place to ask questions is the [autoscend channel on the Ascension Speed Society discord server](https://discord.gg/96xZxv3).

## Reporting Bugs and Feature Requests

Before submitting bugs or feature request please ask for help in the [autoscend channel on the Ascension Speed Society discord server](https://discord.gg/96xZxv3) and search through the [issues page](https://github.com/Loathing-Associates-Scripting-Society/autoscend/issues) to see if it is already reported. If you find a similar issue to yours feel free to add extra details or just a +1 to it.

Finally, if no one on discord can help your you cant find a similar issue, read and fill out the [issue template](./ISSUE_TEMPLATE.md) that appears when you open a new issue.

## Contributing Code

When writing code to contribute please take notice of the general style of the code you are working with and attempt to mimic it as best as possible. For example if the variables are camel case (`someVariable`) dont use snake case variable names (`some_variable`). If you are adding a new function you need to be sure to add the function signature in [autoscend_header.ash](../RELEASE/scripts/autoscend/autoscend_header.ash).

Working on your first open source project or pull request? Her are some helpful tutorials:

* [How to Contribute to an Open Source Project on GitHub][1]
* [Make a Pull Request][2]
* [First Timers Only][3]
* [Github forking, branching and pull requests][4]

### Forks and Branches
You can request access to the project which will let you push working branches to the project, but you can also just (or even prefer) to fork the repository and submit pull requests from your fork.

**master** branch:
The master branch is the current "release" of autoscend. When someone does `svn checkout https://github.com/Loathing-Associates-Scripting-Society/autoscend/trunk/RELEASE/` in KoLMafia, they are getting the master branch scripts.

**beta** branch:
The `beta` branch is the sort of latest and greatest where people can use to get experimental or less tested features. Once features are vetted the beta branch can be merged to master, or specific features can be cherry-picked in.

Both `beta` and `master` are restricted and can only be merged into with a pull request which requires approval from 1 other developer (though admins can by pass this requirements if they need to).

For all of our sanity a good git work flow is something like this:
1. `git checkout beta`
2. `git pull`
3. `git checkout -b my-cool-new-feature`
4. change code, add and commit files with [good commit messages][5]
5. when ready, submit a [pull request](https://github.com/Loathing-Associates-Scripting-Society/autoscend/compare/beta...Loathing-Associates-Scripting-Society:master) for your `my-cool-new-feature` branch against the `beta` branch

### Merging Pull Requests
When closing pull requests, please use the "Squash and Merge" option when merging the branch. This creates much cleaner git commit histories and make it much easier to cherry-pick features from one branch to another (for example if we only want to release a couple features in the beta branch and not everything). After the merge its also good practice to delete the branch from the remote, again trying to keep the repository clean.

[1]: https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github
[2]: http://makeapullrequest.com/
[3]: http://www.firsttimersonly.com
[4]: https://gist.github.com/Chaser324/ce0505fbed06b947d962
[5]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
