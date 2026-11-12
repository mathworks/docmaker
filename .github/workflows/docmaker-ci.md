# CI workflows

`docmaker-ci.yml` is the primary workflow. It selects `test-mini`, `test-full`, or toolbox packaging based on the GitHub event or a manually selected mode.

## Modes and triggers

| Mode | Trigger | Work performed |
| --- | --- | --- |
| `test-mini` | Pull requests not targeting `master`; pushes to `master`; manual selection | Ubuntu 24.04 with the latest MATLAB runs `buildtool('test')`, which checks the code, builds the Linux MEX, and runs the test suite. |
| `test-full` | Pull requests targeting `master`; manual selection | Builds and tests native MEX files on Ubuntu 24.04/Linux, Windows, Intel Mac, and Apple Silicon using the latest supported MATLAB release for each platform. Linux also runs compatibility tests on R2021a, R2022b, R2023b, R2024b, and R2025b with the latest Linux MEX. |
| Package | Push of a `v*` tag reachable from `master`; manual selection | Builds and tests Windows and Mac MEX files, stages them on Linux, then runs `buildtool('package')`. A valid tag publishes the MLTBX as a GitHub Release; manual runs upload it as a 14-day workflow artifact. |

Pushes to `cmark_multiplatform` run the native Linux, Windows, Intel Mac, and Apple Silicon matrix in parallel. They do not run the older-release Linux compatibility matrix.

For a master-targeted pull request, `test-full` runs instead of a separate `test-mini` job. Intel Mac uses MATLAB R2025b; Windows, Linux, and Apple Silicon use `latest`. Linux compatibility jobs use Ubuntu 22.04 for R2021a, R2022b, and R2023b, and Ubuntu 24.04 for R2024b and R2025b. R2021a is best-effort on Ubuntu 22.04 because its newest officially supported Ubuntu release, 20.04, is no longer available as a GitHub-hosted runner.

In the Actions job list, `test-mini` runs as `test-linux-latest`. Manual `test-full` runs `test-platforms-releases` followed by `test-linux-releases`. Tag packaging uses `check-tag`, `mex`, `package`, and `publish` in sequence.

Manual runs use the `mode` selector (`test-mini`, `test-full`, or `package`) and the ref selected in the Actions UI. The `docmaker-ci.yml` workflow must first be merged into the default branch (`master`) before GitHub exposes it there for manual dispatch.

## Package flow

The reusable `build-mex.yml` workflow compiles and tests each native MEX and uploads it as an artifact. The Ubuntu 24.04 package job checks out the selected source, downloads the Windows and Mac artifacts, stages them in `tbx/docmaker/+docmaker`, and runs `buildtool('package')`. That build task creates the Linux MEX and runs its check, test, and documentation dependencies before packaging. CI checks that the resulting MLTBX contains all four platform MEX files.

Before packaging a version tag, CI checks that its commit is reachable from `master`. The package task also checks that the toolbox version matches the tag. The GitHub Release uses the corresponding section from `tbx/docmakerdoc/changelog.md`.

