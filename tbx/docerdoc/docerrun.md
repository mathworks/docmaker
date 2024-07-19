# docerrun :runner:

Run scripts and capture output to image files

## Syntax

`docerrun(s)` runs the MATLAB script(s) `s` and captures figure output to image files.

`docerrun(...,"Size",wh)` sets the size of the output figures to [width height] `wh`.

`docerrun(...,"Resolution",r)` sets the resolution of the screenshots to `r` dpi.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `s` | MATLAB script(s), as an absolute or relative path; wildcards are [supported](https://uk.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | yes |
| `wh` | Width and height of output figures, in pixels | 1x2 double | |
| `r` | Screenshot resolution, in dpi | double | |

## Examples

```matlab
docerrun("mickey/pluto.md")
```
runs a single MATLAB script `mickey/pluto.m`.  The file extension `.m` is optional.  Note that this path is *relative*.

```matlab
docerrun("C:\daisy\mickey\pluto.m")
```
also runs a single MATLAB script, this time specified using an *absolute* path.

```matlab
docerrun("mickey/*.m")
```
runs *all* MATLAB scripts in `mickey`.

```matlab
docerrun("mickey/**/*.m")
```
runs all MATLAB scripts in `mickey` *and its subfolders*.

```matlab
docerrun(["mickey/pluto.m" "mickey/donald.m"])
```
runs *multiple* MATLAB scripts.

```matlab
docerrun("mickey/pluto.m","Size",[400 300])
```
sets the output figure size to 400-by-300 pixels.

```matlab
docerrun("mickey/pluto.md","Resolution",96)
```
sets the screenshot resolution to 96 dpi.

## Description

`docerrun` runs scripts that generate figures to be included in documentation.  Once generated, the figures are:
1. resized to the specified size,
2. captured to image files in PNG format at the specified resolution, and
3. closed.

The generated image files are named after the corresponding script and placed in the same folder.  For example, if a script `mydemo.m` generates two figures, then these will be captured to `mydemo1.png` and `mydemo2.png`.

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://uk.mathworks.com/services/consulting.html) 2024