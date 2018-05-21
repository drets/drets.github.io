---
title: My keyboard tweaks
published: 2018-05-22T11:00:00
tags: keyboard, emacs
gh-issue: 4
---

A few years ago I have started to feel pain in the wrists.
So, I was looking for the ways of how to optimize the keyboard interaction. I will share the keyboard tweaks which helped _me_ to avoid pain in the wrists so far.  

<div></div><!--more-->

Environment
-----------

The last few years I use MacBook Pro 2015 13-inch display. Laptop powered by Linux ([NixOS](https://en.wikipedia.org/wiki/NixOS)).

<img width="500" src="/images/posts/keyboard-adjustments/mbp2015-keyboard.jpg" />

Custom keyboard layout
----------------------
I have the custom keyboard layout. I have _stolen_ layout from [Artyom](https://github.com/neongreen) and extended it afterwards. Custom keyboard layout uses the [X keyboard extension](https://en.wikipedia.org/wiki/X_keyboard_extension). Layout schemes can be found in [~/.config/xkb/symbols](https://github.com/drets/dots/tree/2854ef40f729afd7a41b17095234070f76e0ff8f/.config/xkb/symbols) folder. I apply the layout on the system startup using:

```bash
setxkbmap -layout "us(my),ru(my)" -option "" -option "grp:lctrl_toggle" -print | xkbcomp -I"$HOME/.config/xkb" - $DISPLAY
```

Layout highlights:  

• `d` is the third shift level.  
Say, layout scheme has `key <AD04> {[ r, R, enfilledcircbullet ]};` line. So, by holding `d` and pressing `r` (`d + r`) we get `•` (enfilledcircbullet) character.  

<img width="250" src="/images/posts/keyboard-adjustments/enfilledcircbullet.png" />

• `Backspace` is in place of `j`  

<img width="250" src="/images/posts/keyboard-adjustments/backspace.png" />

(`j` moved to the third level: `d + p`).  

• Arrow keys added to the third level (left: `d + j`, up: `d + i`, right: `d + l`, down: `d + k`).  

<img width="250" src="/images/posts/keyboard-adjustments/arrows.png" />

• `Ctrl` is in place of `s`  

<img width="250" src="/images/posts/keyboard-adjustments/ctrl.png" />

(`s` moved to the `u`, `u` moved to the `{`, `{` moved to the third level: `d + t`).  

• `Enter` added to the third level: `d + space`.  

<img width="250" src="/images/posts/keyboard-adjustments/enter.png" />

• Mouse left click added to the third level: `d + f.`  

<img width="250" src="/images/posts/keyboard-adjustments/left-click.png" />

I press the keys by left hand and navigate the cursor using touchpad by right hand.  

Sticky keys
-----------
I made _all_ the modifier keys (including the third level key) to be sticky by using the [xkbset](http://faculty.missouri.edu/~stephen/software/#xkbset) program.
It runs on the system startup:

```bash
xkbset sticky -twokey -latchlock
xkbset mousekeys
xkbset exp 1 =sticky =mousekeys =sticky =twokey =latchlock
```
Say, I want to type `R`. I can do it in a regular way by holding `Shift` and pressing `r`, or I can press `Shift`, _release_ `Shift` and then press `r`. 

Emacs
-----
I recommend to use [evil](https://github.com/emacs-evil/evil) mode, unless you have the custom keyboard layout. My current emacs configuration can be found in [~/.emacs.d](https://github.com/drets/dots/tree/master/.emacs.d) folder. I won't go into details, just one thing − I bound `avy-goto-word-or-subword-1` to `Tab` :)

awesome wm
----------
I use [awesome window manager](https://awesomewm.org/) having nine workspaces.  
To switch the workspace:

| Workspace | Key          |
|-----------+--------------|
| one       | Command + u  |
| two       | Command + i  |
| three     | Command + o  |
| four      | Command + j  |
| five      | Command + k  |
| six       | Command + l  |
| seven     | Command + m  |
| eight     | Command + <  |
| nine      | Command + >  |

<img width="250" src="/images/posts/keyboard-adjustments/workspaces.png" />

Alternative way
---------------
And yet the best way to prevent the wrists pain is:

<img width="500" src="/images/posts/keyboard-adjustments/alternative-way.jpg" />
