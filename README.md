# NOTICE

ASScend (formerly [sl_ascend](https://github.com/soolar/sl_ascend); formerly, formally cc_ascend) is under new managment. The previous developers decided they could no longer continue supporting the script or Kingdom of Loathing after [actions of Jick and some of the other developers](https://www.reddit.com/r/kol/comments/d0cq9s/allegations_of_misconduct_by_asymmetric_members/) were made public.

The script was moved to this more communal location and has tentative support from some much less experienced developers. Basic support is expected to continue but fixes and enhancements will likely be slow. Large feature support (such as new challenge paths) will probably not happen without more support from the community. Feel free to [pitch in](./docs/CONTRIBUTING.md).

Seriously, we need and want the help. Want to learn how to code? Or maybe you know how to code but want to check out KoLMafia's ash scripting langauge? We are very friendly and happy to teach.

# ASScend

ASScend is a script that will play through an entire ascension for you in the Kingdom of Loathing.
It is built up from sl\_ascend and cc\_ascend before it.

## Installation

Run this command in the graphical CLI:
```
svn checkout https://github.com/Loathing-Associates-Scripting-Society/ASScend/trunk/RELEASE/
```
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

### ASScend Beta
If you would like to try the newest feature you can checkout the beta branch:
```
svn checkout https://github.com/Loathing-Associates-Scripting-Society/ASScend/branches/beta/RELEASE/
```

Note: you may need to delete KoLMafia's svn cache if you want to switch between the master and beta branches. It can be found in `<mafia dir>/svn/Loathing-Associates-Scripting-Society-ASScend-trunk-RELEASE` and `<mafia dir>/svn/Loathing-Associates-Scripting-Society-ASScend-branches-beta-RELEASE` respectively

## Usage

Just type sl\_ascend in the gCLI! You can configure sl\_ascend in the relay browser via the relay
script soolascend. If you ever want to interrupt the script, please use the interrupt button in
the soolascend relay script rather than terminating via mafia with escape. Otherwise certain settings
may not be restored properly to their pre-run values.

## Requirements

There are a couple specific requirements to run sl\_ascend effectively. If you run in to issues in
a path that allows access to your normally permed skills, don't report them if you don't have these
skills permed:

* Saucestorm
* Cannelloni Cocoon

Other things that help greatly but shouldn't be strictly required (I think):

* Curse of Weaksauce + Itchy Curse Finger
* Stuffed Mortar Shell
* Saucegeyser

## Community Service

If you want to run HCCS, the recommended setup is Sauceror with all of the skills mentioned in the
requirements section. Other classes should work as well, but Sauceror works best.

## Two Crazy Random Summer

The recommended class/sign combination for running sl\_ascend in TCRS is Sauceror/Blender.
Other signs should work okay too, but they won't have any special support (like automatic diet,
or using certain nice cheap potions).

## Warning

This code base has changed hands and evolved over years of development. Most of the code was written by people who are no longer playing the game or maintaining it. So, there may be mistakes and learning curves. Please be patient and understanding, this is a hobby for us.

Your ascension may or may not break in spectacular ways! Sorry in advance if that happens! Also, at the moment you will probably have to handle the vast majority of your diet manually. At least, in hardcore standard, anyway.

## Issues?

Please do create github issues for any problems you run in to. I make no promises about how fast
I'll be to handle them, but I'll try to fix reasonable problems in a reasonable timeframe.

You can also come discuss problems with the script on the [#sl\_ascend channel on the Ascension Speed Society discord server](https://discord.gg/96xZxv3), or just discuss the script in general!

Some people maintain a list of common problems, solutions, and tips on writing a bug report [in this document](https://docs.google.com/document/d/1AfyKDHSDl-fogGSeNXTwbC6A06BG-gTkXUAdUta9_Ns).

## Other Contributors

Thanks to the following people for their contributions via pull requests:

soolar (IGN: Soolar the Second (#2463557))

Rinn (IGN: Epicgamer (#37195))

jaspercb (IGN: Jeparo (#2246666))

MatthewDarling (IGN: MasterAssasin (#613216))

Malibu Stacey (IGN: Malibu Stacey (#2705901))

cognificent (IGN: cognificent (#2313727))

gausie (IGN: gausie (#1197090))

## Special Thanks

This script would obviously not be possible without the work of Cheesecookie and soolar.
They did by far the majority of the work. So thanks a bunch to both of you!
