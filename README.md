# sl\_ascend

sl\_ascend is a script that will play through an entire ascension for you in the Kingdom of Loathing.
It is built up from cc\_ascend.

## Installation

Run this command in the graphical CLI:
<pre>
svn checkout https://github.com/soolar/sl_ascend/trunk/RELEASE/
</pre>
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

## Usage

Just type sl\_ascend in the gCLI! You can configure sl\_ascend in the relay browser via the relay
script soolascend. If you ever want to interrupt the script, please use the interrupt button in
the soolascend relay script rather than terminating via mafia with escape. Otherwise certain settings
may not be restored properly to their pre-run values.

## Requirements

There aren't many specific requirements I can think of, but there is one important one: Saucestorm.
If you run in to combat related issues in a path that allows access to your normally permed skills,
don't report them if you don't have Saucestorm permed.

Other things that help greatly but shouldn't be strictly required (I think):

* Curse of Weaksauce + Itchy Curse Finger
* Stuffed Mortar Shell
* Saucegeyser

## Community Service

If you want to run HCCS, the recommended setup is Sauceror with all of the skills mentioned in the
requirements section. Other classes should work as well, but Sauceror works best.

## Warning

I'm still new to this codebase, so I can't be 100% confident that I am not making any mistakes.
cc\_ascend was broken at the start of the year (2019) by some changes to the game, which I believe
I have fixed the script to handle, but I'm not 100% sure it will handle all aspects of the game
perfectly yet...

Basically, your ascension may or may not break in spectacular ways! Sorry in advance if that happens!

Also, at the moment you will probably have to handle the vast majority of your diet manually.
At least, in hardcore standard, anyway.

## Issues?

Please do create github issues for any problems you run in to. I make no promises about how fast
I'll be to handle them, but I'll try to fix reasonable problems in a reasonable timeframe.

If you really need a quick answer about something, feel free to kmail me in game at
Soolar the Second (#2463557), but be warned that not even I fully understand this code base
at the moment, so I might not be able to help!

You can also come discuss problems with the script on the [#sl\_ascend channel on the Ascension Speed Society discord server](https://discord.gg/96xZxv3), or just discuss the script in general!

Some people maintain a list of common problems, solutions, and tips on writing a bug report [in this document](https://docs.google.com/document/d/1AfyKDHSDl-fogGSeNXTwbC6A06BG-gTkXUAdUta9_Ns).

## Other Contributors

Thanks to the following people for their contributions via pull requests:

Rinn (IGN: Epicgamer (#37195))

jaspercb (IGN: Jeparo (#2246666))

MatthewDarling (IGN: MasterAssasin (#613216))

Malibu Stacey (IGN: Malibu Stacey (#2705901))

cognificent (IGN: cognificent (#2313727))

gausie (IGN: gausie (#1197090))

## Special Thanks

This script would obviously not be possible without the work of Cheesecookie.
He did by far the majority of the work, all I've done so far is make some minor adjustments to
handle game changes, new IotMs, and new paths. So thanks a bunch to Cheesecookie!
