# CI workflows

`docmaker-ci.yml` is the primary workflow. It selects `test-mini`, `test-full`, toolbox packaging, or a draft GitHub release based on the GitHub event or a manually selected mode.

## Modes and triggers

| Mode | Trigger | Work performed |
| --- | --- | --- |
| `test-mini` | Pull requests not targeting `master`; pushes to `master`; manual selection | Ubuntu 24.04 with the latest MATLAB builds and tests the Linux MEX. |
| `test-full` | Pull requests targeting `master`; manual selection | Builds and tests the latest Linux MEX and Windows/Mac MEX files. Linux compatibility tests run on R2021a, R2022b, R2023b, R2024b, and R2025b using the latest Linux MEX. The compatibility matrix can run alongside the Windows/Mac tests. |
| Package | Push of a `vMAJOR.MINOR.PATCH` tag reachable from `master`; manual selection | Builds Windows and Mac MEX files, stages them on Linux, then runs `buildtool('package')`. A valid tag publishes the MLTBX as a GitHub Release; manual runs upload it as a 14-day workflow artifact. |
| Draft | Manual selection | Builds and tests the MEX files, packages the toolbox, and creates a GitHub draft release tagged from the toolbox version in `Contents.m`. It does not run the tag ancestry check or publish to File Exchange. |

For a master-targeted pull request, `test-linux-latest` and the Windows/Mac `test-platforms-latest` matrix run concurrently. `test-linux-releases` starts after the Linux latest MEX artifact is available, so it can overlap the Windows/Mac tests. Intel Mac uses MATLAB R2025b; Windows and Apple Silicon use `latest`. Linux compatibility jobs use Ubuntu 22.04 for R2021a, R2022b, and R2023b, and Ubuntu 24.04 for R2024b and R2025b. R2021a is best-effort on Ubuntu 22.04 because its newest officially supported Ubuntu release, 20.04, is no longer available as a GitHub-hosted runner.

In the Actions job list, `test-mini` runs as `test-linux-latest`. Manual `test-full` runs `test-linux-latest` and `test-platforms-latest` concurrently, with `test-linux-releases` depending only on `test-linux-latest`. Tag packaging uses `check-tag`, `mex`, `package`, and `publish` in sequence.

Manual runs use the `mode` selector (`test-mini`, `test-full`, `package`, or `draft`) and the ref selected in the Actions UI. The `docmaker-ci.yml` workflow must first be merged into the default branch (`master`) before GitHub exposes it there for manual dispatch.

## Package flow

The reusable `build-mex.yml` workflow compiles and tests each native MEX and uploads it as an artifact. The Ubuntu 24.04 package job checks out the selected source, downloads the Windows and Mac artifacts, stages them in `tbx/docmaker/+docmaker`, and runs `buildtool('package')`. That build task creates the Linux MEX and runs its check, test, and documentation dependencies before packaging. CI checks that the resulting MLTBX contains all four platform MEX files.

The manual `draft` mode uses that package artifact to create a GitHub draft release. It reads the toolbox version from `tbx/docmaker/Contents.m` to form the release tag. Draft releases support prerelease and build versions: their tag and title keep the full version, while release notes use the matching `MAJOR.MINOR.PATCH` changelog section. Automatic publishing accepts only plain `vMAJOR.MINOR.PATCH` tags. The draft job does not run `check-tag`; the normal tag-push publish flow retains that gate.

MEX artifacts use their extensions as names: `mexa64`, `mexw64`, `mexmaci64`, and `mexmaca64`. The toolbox artifact is named `mltbx`.

For tag-push releases, `check-tag` requires the exact `vMAJOR.MINOR.PATCH` format and verifies that the commit is reachable from `master` before MEX builds and packaging begin. The package task also checks that the toolbox version matches the tag. The GitHub Release uses the corresponding `MAJOR.MINOR.PATCH` section from `tbx/docmakerdoc/changelog.md`.

