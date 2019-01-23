# sl\_ascend

sl\_ascend is a script that will play through an entire ascension for you in the Kingdom of Loathing.
It is built up from cc\_ascend, which was built up from bumcheekascend before it.

## Installation

Run this command in the graphical CLI:
<pre>
svn checkout https://github.com/soolar/sl_ascend/trunk/RELEASE/
</pre>
Will require [a recent build of KoLMafia](http://builds.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

## Usage

Just type sl\_ascend in the gCLI! You can configure sl\_ascend in the relay browser via the relay
script soolascend.

## Warning

I'm still new to this codebase, so I can't be 100% confident that I am not making any mistakes.
cc\_ascend was broken at the start of the year (2019) by some changes to the game, which I believe
I have fixed the script to handle, but I'm not 100% sure it will handle all aspects of the game
perfectly yet...

Basically, your ascension may or may not break in spectacular ways! Sorry in advance if that happens!

Also, at the moment you will probably have to handle the vast majority of your diet manually.

## Issues?

Please do create github issues for any problems you run in to. I make no promises about how fast
I'll be to handle them, but I'll try to fix reasonable problems in a reasonable timeframe.

If you really need a quick answer about something, feel free to kmail me in game at
Soolar the Second (#2463557), but be warned that not even I fully understand this code base
at the moment, so I might not be able to help!

## So what IS fixed?

I believe I have properly modified the script to no longer ever consider the pirate route, and to
always take the copperhead route. I also believe I have properly purged any attempt at using the
nuns trick or the writing desk trick, since both of those were deleted from the game. I'm only
90% sure about this though. If you find a situation where the script attempts to do pirates or
the nuns trick or the writing desk trick for any reason, please let me know ASAP!

## Special Thanks

This script would obviously not be possible without the work of Cheesecookie and bumcheekcity before
me. They did by far the majority of the work, all I've done so far is make some minor adjustments to
handle game changes and new IotMs. So thanks a bunch to both of them!
