# Markdown conversion

## cmark-gfm

DocMaker uses [cmark-gfm](https://github.com/github/cmark-gfm) to convert Markdown to HTML. cmark-gfm is GitHub's fork of cmark, a CommonMark parsing and rendering library and program in C. Emoji support is included by [gemoji](https://github.com/github/gemoji). The converter is bundled with the toolbox, works offline, and supports all platforms (Windows x64, Linux x86-64, Intel macOS, and Apple Silicon macOS).

cmark-gfm is the default converter, and is strongly recommended.

## GitHub Markdown API

DocMaker also supports [GitHub Markdown API](https://docs.github.com/en/rest/markdown) to convert Markdown to HTML. GitHub Markdown API is a REST API endpoint provided by GitHub that converts Markdown to HTML using GitHub’s own rendering engine. Prior to the introduction of cmark-gfm, this was the default converter.

GitHub rate-limits API requests, and authenticated requests have a higher limit. A GitHub access token with no permissions is sufficient. To authenticate, set the MATLAB secret `DOCMAKER_GITHUB_TOKEN` or the environment variable of the same name. Use secrets for local development on R2024a and later, and environment variables for build runners and earlier MATLAB versions. Without a token, requests are anonymous.

GitHub Markdown API requires network access and sends document contents to GitHub. See the [GitHub API terms of service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#h-api-terms) and [privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) for further information.

*Use the GitHub Markdown API only if the cmark-gfm MEX cannot run in your environment.* cmark-gfm is faster :rocket:, and your content stays local :lock:.

The GitHub Markdown API supports GitHub.com only; private GitHub instances are not supported.

## GitLab Markdown API

DocMaker previously supported [GitLab Markdown API](https://docs.gitlab.com/api/markdown/) to convert Markdown to HTML. GitLab Markdown API is a REST API endpoint provided by GitLab that converts Markdown to HTML using GitLab’s own rendering engine.

Since the introduction of cmark-gfm, support for GitLab Markdown API has been removed.

___

[home](index.md) :house: | [convert](docconvert.md) :arrow_right: | [run](docrun.md) :runner: | [index](docindex.md) :scroll: | [delete](docdelete.md) :recycle: | [build](DocMakerTask.md) :factory: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hatching_chick: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026
