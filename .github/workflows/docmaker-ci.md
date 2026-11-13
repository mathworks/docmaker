# CI workflows

`docmaker-ci.yml` is the primary workflow. It selects `test-mini`, `test-full`, or toolbox packaging based on the GitHub event or a manually selected mode.

## Modes and triggers

| Mode | Trigger | Work performed |
| --- | --- | --- |
| `test-mini` | Pull requests not targeting `master`; pushes to `master`; manual selection | Ubuntu 24.04 with the latest MATLAB builds and tests the Linux MEX. |
| `test-full` | Pull requests targeting `master`; manual selection | Builds and tests the latest Linux MEX and Windows/Mac MEX files. Linux compatibility tests run on R2021a, R2022b, R2023b, R2024b, and R2025b using the latest Linux MEX. The compatibility matrix can run alongside the Windows/Mac tests. |
| Package | Push of a `v*` tag reachable from `master`; manual selection | Builds Windows and Mac MEX files, stages them on Linux, then runs `buildtool('package')`. A valid tag publishes the MLTBX as a GitHub Release; manual runs upload it as a 14-day workflow artifact. |

For a master-targeted pull request, `test-linux-latest` and the Windows/Mac `test-platforms-latest` matrix run concurrently. `test-linux-releases` starts after the Linux latest MEX artifact is available, so it can overlap the Windows/Mac tests. Intel Mac uses MATLAB R2025b; Windows and Apple Silicon use `latest`. Linux compatibility jobs use Ubuntu 22.04 for R2021a, R2022b, and R2023b, and Ubuntu 24.04 for R2024b and R2025b. R2021a is best-effort on Ubuntu 22.04 because its newest officially supported Ubuntu release, 20.04, is no longer available as a GitHub-hosted runner.

In the Actions job list, `test-mini` runs as `test-linux-latest`. Manual `test-full` runs `test-linux-latest` and `test-platforms-latest` concurrently, with `test-linux-releases` depending only on `test-linux-latest`. Tag packaging uses `check-tag`, `mex`, `package`, and `publish` in sequence.

Manual runs use the `mode` selector (`test-mini`, `test-full`, or `package`) and the ref selected in the Actions UI. The `docmaker-ci.yml` workflow must first be merged into the default branch (`master`) before GitHub exposes it there for manual dispatch.

## Package flow

The reusable `build-mex.yml` workflow compiles and tests each native MEX and uploads it as an artifact. The Ubuntu 24.04 package job checks out the selected source, downloads the Windows and Mac artifacts, stages them in `tbx/docmaker/+docmaker`, and runs `buildtool('package')`. That build task creates the Linux MEX and runs its check, test, and documentation dependencies before packaging. CI checks that the resulting MLTBX contains all four platform MEX files.

MEX artifacts use their extensions as names: `mexa64`, `mexw64`, `mexmaci64`, and `mexmaca64`. The toolbox artifact is named `mltbx`.

Before packaging a version tag, CI checks that its commit is reachable from `master`. The package task also checks that the toolbox version matches the tag. The GitHub Release uses the corresponding section from `tbx/docmakerdoc/changelog.md`.

