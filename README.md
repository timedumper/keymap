# Keymap

## Legend

 - `"foo bar"` means keyboard will press one or more keys (could be a macro) that result in "foo bar" (for instance, _"prev word"_ will send the keys that move the cursor to the previous word)
 
 - `1:A 2:B ...` means that key will behave as either `A` or `B` based on the number of times it is tapped/held (implemented as tap dance in QMK).
 
   For instance, `1:...` means single tap or hold. `2:...` means double tap or double hold (a tap, followed by a hold). And so on.
 
 - `UPPERCASE` means layer name (all layer names are in upper case); without additonal notes it means momentary switch to that layer

 - `[N]` means a "footnote" (see footnote text below the layer image)

## Layer: BASE 
![](./renders/layer-BASE.svg)

## Layer: NAV1 and NAV2

![](./renders/layer-NAV1.svg)

The right half is mostly text navigation plus cursor keys. The left one is mainly a bunch of system-wide shortcuts that I often use.

#### [1] Leader sequences

This key acts as a leader for the following sequences:
  - `a` opens spotlight search
  - `v` shifted paste (`cmd + shift + v`)
  - `c` capture screenshot
  - `d` switch to the next IDE
  - `dd` type up a short help about supported IDEs

#### [2] bold/backticks tap dance 

 - single tap → taps `cmd + B` (bold)
 - double tap → macro that surrounds selected text with backticks
 - single hold → macro that surrounds preceeding word with backticks
 
#### [3] app switcher
 
Custom programmed key that works just like app switcher. For instance, on Mac 
  - first tap begins holding `cmd` then taps `tab`
  - each subsequent taps sends another `tab` tap (this advances to the next app)
  - when thumb key is released the `cmd` is also released which deactivates the app switcher
  - pressing and holding this key for half a second while the switcher is active will quit the current app by tapping `Q` (such delay is intentional as it helps with accidental app closures)
 
![](./renders/layer-NAV2.svg)

This layer is a bit harder to reach (requires double hold instead of a single one) so here I keep some less often used shortcuts that I don't want to be cramped in the main navigaiton layer.

Note: `cmd + <digit>` ones are used to quickly switch between terminal tabs with one hand.

## Layer: IDE L1, IDE L2 and IDE RIGHT

![](./renders/layer-IDE-L1.svg)

![](./renders/layer-IDE-L2.svg)

![](./renders/layer-IDE-RIGHT.svg)

## Layer: TKL

![](./renders/layer-TKL.svg)
