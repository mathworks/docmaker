# Markdown conversion

DocMaker supports conversion from Markdown to HTML using services from GitHub and GitLab.

## GitHub

By default, DocMaker converts Markdown to HTML using the [GitHub Markdown API](https://docs.github.com/en/rest/markdown).

You can use `api.github.com` or your own private instance.  To override the default GitHub hostname:

1. set the environment variable `DOCMAKER_GITHUB_HOSTNAME` (recommended for build runners :infinity:), or
2. set the preference `github_hostname` in the group `docmaker` (recommended for local machines :computer:)

Requests to this service are rate limited, and [authenticated requests](https://docs.github.com/en/rest/authentication/authenticating-to-the-rest-api) get a higher limit.  To authenticate, [generate a GitHub access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) (with no permissions), and register the token with MATLAB:

1. set the environment variable `DOCMAKER_GITHUB_TOKEN` (recommended for build runners :infinity:), or
2. set the secret `DocMaker GitHub token` (recommended for local machines :computer: from R2024a), or
3. set the preference `github_hostname` in the group `docmaker` (recommended for local machines :computer: prior to R2024a)

See the [GitHub API terms of service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#h-api-terms) and [privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) for further information.

## GitLab

As an alternative, DocMaker can convert Markdown to HTML using the [GitLab Markdown API](https://docs.gitlab.com/api/markdown/).

To use GitLab for Markdown conversion:

1. set the environment variable `DOCMAKER_CONVERTER` (recommended for build runners :infinity:), or
2. set the preference `converter` in the group `docmaker` (recommended for local machines :computer:)

You can use `gitlab.com` or your own private instance.  To override the default GitLab hostname:

1. set the environment variable `DOCMAKER_GITLAB_HOSTNAME` (recommended for build runners :infinity:), or
2. set the preference `gitlab_hostname` in the group `docmaker` (recommended for local machines :computer:)

Requests to this service require [authentication](https://docs.gitlab.com/api/rest/authentication/).  To authenticate, [generate a GitLab access token](https://docs.gitlab.com/user/profile/personal_access_tokens/) (with API permissions), and register the token with MATLAB:

1. set the environment variable `DOCMAKER_GITLAB_TOKEN` (recommended for build runners :infinity:), or
2. set the secret `DocMaker GitLab token` (recommended for local machines :lock: from R2024a), or
3. set the preference `gitlab_hostname` in the group `docmaker` (recommended for local machines :unlock: prior to R2024a)

See the [GitLab API terms of use](https://handbook.gitlab.com/handbook/legal/api-terms/) and [privacy statement](https://about.gitlab.com/privacy/) for further information.

## Example

You can configure your local machine to use your own private GitLab instance to convert Markdown to HTML with:

```matlab
setpref("docmaker","converter","GitLab") % use GitLab
setpref("docmaker","gitlab_hostname","gitlab.acme.com") % your GitLab
setSecret("DocMaker GitLab token") % and enter your token 
```

You can debug your DocMaker converter settings using `docmaker.converter` :test_tube::

```matlab
docmaker.converter
```

## Summary

You can use various settings mechanisms to control the converter technology, service instance, and authentication:

| Description | Environment variable :infinity: | Secret :computer::lock: | Preference :computer::unlock: | Default |
| --- | --- | --- | --- | --- |
| converter | `DOCMAKER_CONVERTER` | `DocMaker converter` | `converter` | `GitHub` |
| GitHub hostname | `DOCMAKER_GITHUB_HOSTNAME` | `DocMaker GitHub hostname` | `github_hostname` | `api.github.com` |
| GitHub access token | `DOCMAKER_GITHUB_TOKEN` | `DocMaker GitHub token` | `github_token` | |
| GitLab hostname | `DOCMAKER_GITLAB_HOSTNAME` | `DocMaker GitLab hostname` | `gitlab_hostname` | `gitlab.com` |
| GitLab access token | `DOCMAKER_GITLAB_TOKEN` | `DocMaker GitLab token` | `gitlab_token` | |

Use environment variables for build runners, secrets for tokens on local computers, and preferences for non-sensitive data on local computers.  In case of conflict, environment variables trump secrets, which trump preferences.

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026