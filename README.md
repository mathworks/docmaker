# MATLAB&#174; DocMaker :hatching_chick:

DocMaker is a tool for generating MATLAB toolbox documentation.

With DocMaker, you can:
* write documentation in [Markdown](https://commonmark.org/help/) and convert to HTML for viewing in MATLAB
* run MATLAB code blocks in documents and include textual and graphical output
* create MATLAB documentation index files from a Markdown table of contents

DocMaker requires MATLAB R2021a or later to *generate* documentation.

## Developer documentation

The repository contains a top-level [MATLAB project](https://www.mathworks.com/help/matlab/projects.html).  Developers should follow the [user setup instructions](tbx/docmakerdoc/index.md) by generating a GitHub access token and registering the token with MATLAB.

Development requires the [MATLAB Build Tool](https://www.mathworks.com/help/matlab/matlab_prog/overview-of-matlab-build-tool.html) which was introduced in MATLAB R2022b.

## User documentation

DocMaker ships with [documentation](./tbx/docmakerdoc/index.md) that you can browse online, including:

* a [getting started guide](./tbx/docmakerdoc/index.md) including system requirements and examples
* a function reference for [`docconvert`](./tbx/docmakerdoc/docconvert.md), [`docrun`](./tbx/docmakerdoc/docrun.md), [`docindex`](./tbx/docmakerdoc/docindex.md), and [`docdelete`](./tbx/docmakerdoc/docdelete.md)
* [release notes](./tbx/docmakerdoc/changelog.md) detailing new features, bug fixes, and compatibility considerations for each version

## About the project

DocMaker is developed by [David Sampson](https://www.mathworks.com/matlabcentral/profile/authors/16247) from [MathWorks](https://www.mathworks.com/services/consulting.html).

___

:copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026