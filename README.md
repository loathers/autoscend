# NOTICE

autoscend (formerly [sl_ascend](https://github.com/soolar/sl_ascend); formerly, formally cc_ascend) is under new managment. The previous developers decided they could no longer continue supporting the script or Kingdom of Loathing after [actions of Jick and some of the other developers](https://www.reddit.com/r/kol/comments/d0cq9s/allegations_of_misconduct_by_asymmetric_members/) were made public.

The script was moved to this more communal location and has tentative support from some much less experienced developers. Basic support is expected to continue but fixes and enhancements will likely be slow. Large feature support (such as new challenge paths) will probably not happen without more support from the community. Feel free to [pitch in](./docs/CONTRIBUTING.md).

Seriously, we need and want the help. Want to learn how to code? Or maybe you know how to code but want to check out KoLMafia's ash scripting langauge? We are very friendly and happy to teach.

# autoscend

autoscend is a script that will play through an entire ascension for you in the Kingdom of Loathing.
It is built up from sl\_ascend and cc\_ascend before it.

autoscend's goal is to be able to brute force an ascension for all paths of KoL, not to do it optimally, but within a couple of real-life days of the target. If you bear this in mind while you use it, you will have a much better experience.  
If, however, you expect it to run absolutely bleeding edge ascensions with optimal day/turn counts you are in for a world of disappointment.  
A general purpose ascension script, which supports accounts with any number of perms and/or Mr Store items from none to almost all, will not be optimally tuned to your specific situation. We suggest you adjust your expectations accordingly.

## License
[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/80x15.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)  
This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Installation

Run this command in the graphical CLI:
```
svn checkout https://github.com/Loathing-Associates-Scripting-Society/autoscend/trunk/RELEASE/
```
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

## Usage

Just type autoscend in the gCLI! You can configure autoscend in the relay browser via the relay
script autoscend. If you ever want to interrupt the script, please use the interrupt button in
the autoscend relay script rather than terminating via mafia with escape. Otherwise certain settings
may not be restored properly to their pre-run values.

## Requirements

There are a couple specific requirements to run autoscend effectively. If you run in to issues in
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

We do not recommend running autoscend on this path as the item seeds change almost monthly which makes it impossible for us to support it reliably.

## Actually Ed the Undying

The recommended choices in Valhalla for Actually Ed the Undying are 

* Astral Pilsners.
* Astral Ring if you have less than 20 skill points, Astral Belt otherwise.
* Opossum moon sign

## Warning

This code base has changed hands and evolved over years of development. Most of the code was written by people who are no longer playing the game or maintaining it. So, there may be mistakes and learning curves. Please be patient and understanding, this is a hobby for us.

Your ascension may or may not break in spectacular ways! Sorry in advance if that happens!

## Issues?

Please do create github issues for any problems you run in to. We make no promises about how fast
we'll be to handle them, but we'll try to fix reasonable problems in a reasonable timeframe.

You can also come discuss problems with the script on the [#autoscend channel on the Ascension Speed Society discord server](https://discord.gg/96xZxv3), or just discuss the script in general!

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

taltamir (IGN: taltamir (#2195333))

phulin (IGN: worthawholebean (#1972588))

chunkinaround (IGN: threebullethamburgler (#1993636))

Phillammon (IGN: Phillammon (#2393910))

## Special Thanks

This script would obviously not be possible without the work of Cheesecookie and soolar.
They did by far the majority of the work. So thanks a bunch to both of you!
