# docerrun :runner:

Run MATLAB scripts and save generated figures to image files

## Syntax

`docerrun(s)` runs the MATLAB script(s) `s` and saves generated figures to image files.

`docerrun(...,"Size",wh)` sets the size of the figures to [width height] `wh`.

`docerrun(...,"Resolution",r)` sets the resolution of the screenshots to `r` dpi.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `s` | MATLAB script(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | yes |
| `wh` | Width and height of figures, in pixels | 1x2 double | |
| `r` | Screenshot resolution, in dpi | double | |

## Examples

```matlab
docerrun("mickey/pluto.m")
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
sets the figure size to 400-by-300 pixels.

```matlab
docerrun("mickey/pluto.m","Resolution",96)
```
sets the screenshot resolution to 96 dpi.

## Description

## Steps

Each run consists of 4 steps:
1. Run the MATLAB script
2. Resize the generated figure(s) to the specified size
3. Save the figure(s) to image file(s) at the specified resolution next to the original script
4. Close the generated figure(s)

## Image filenames

The generated image files are named after the corresponding MATLAB script.  For example, if a script `mickey/pluto.m` generates two figures, then these will be saved to `mickey/pluto1.png` and `mickey/pluto2.png`.

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024