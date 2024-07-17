# docerrun :runner:

Run scripts and capture output as images

## Syntax

`docerrun(s)` runs the MATLAB scripts `s` and captures figure output to image files in PNG format.

`docerrun(...,"Size",wh)` sets the size of the output figures to [width height] `wh`.

`docerrun(...,"Resolution",r)` sets the resolution of the screenshots to `r` dpi.

## Description

`docerrun` runs scripts that generate figures to be included in documentation.  Once generated, the figures are:
1. resized to the specified size,
2. captured to image files in PNG format at the specified resolution, and
3. closed.

The generated image files are named after the corresponding script and placed in the same folder.  For example, if a script `mydemo.m` generates two figures, then these will be captured to `mydemo1.png` and `mydemo2.png`.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `s` | MATLAB script, as filename(s) or [dirspec](https://uk.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string | required |
| `wh` | Width and height of output figures, in pixels | 1x2 double | `Size` |
| `r` | Screenshot resolution, in dpi | double | `Resolution` |

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://uk.mathworks.com/services/consulting.html) 2024