# Markdown conversion

## cmark-gfm

DocMaker uses [cmark-gfm](https://github.com/github/cmark-gfm) to convert Markdown to HTML. cmark-gfm is GitHub's fork of cmark, a CommonMark parsing and rendering library and program in C. Emoji support is included by [gemoji](https://github.com/github/gemoji). The converter is bundled with the toolbox, works offline, and supports all platforms (Windows x64, Linux x86-64, Intel macOS, and Apple Silicon macOS).

*cmark-gfm is the default converter, and is strongly recommended. It's faster :rocket: than hosted services, and your content stays local :lock:.*

## GitHub Markdown API

DocMaker also supports [GitHub Markdown API](https://docs.github.com/en/rest/markdown) to convert Markdown to HTML using GitHub's rendering engine.

GitHub rate-limits API requests, and authenticated requests have a higher limit. A GitHub access token with no permissions is sufficient. To provide a token, set `DOCMAKER_GITHUB_TOKEN` as a MATLAB Secret or environment variable.

The API hostname defaults to `api.github.com`. To use an alternative GitHub instance, set `DOCMAKER_GITHUB_HOSTNAME` as a MATLAB Secret or environment variable.

GitHub Markdown API requires network access and sends document contents to GitHub. See the [GitHub API terms of service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#h-api-terms) and [privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) for further information.

## GitLab Markdown API

DocMaker also supports the [GitLab Markdown API](https://docs.gitlab.com/api/markdown/) to convert Markdown to HTML using GitLab's rendering engine.

This API requires authentication. A GitLab access token with `api` scope is sufficient. To provide a token, set `DOCMAKER_GITLAB_TOKEN` as a MATLAB Secret or environment variable.

The API hostname defaults to `gitlab.com`. To use an alternative GitLab instance, set `DOCMAKER_GITLAB_HOSTNAME` as a MATLAB Secret or environment variable.

The GitLab Markdown API requires network access and sends document contents to GitLab. See the [GitLab API terms of use](https://handbook.gitlab.com/handbook/legal/api-terms/) and [privacy statement](https://about.gitlab.com/privacy/) for further information.

___

[home](index.md) :house: | [convert](docconvert.md) :arrow_right: | [run](docrun.md) :runner: | [index](docindex.md) :scroll: | [delete](docdelete.md) :recycle: | [build](DocMakerTask.md) :factory: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hatching_chick: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026
