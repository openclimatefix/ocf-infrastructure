# OCF Infrastrucutre

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[contributors-shield]: https://img.shields.io/badge/all_contributors-5-orange.svg
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![Issues](https://img.shields.io/github/issues/openclimatefix/ocf-infrastructure)](https://github.com/openclimatefix/ocf-infrastructure/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc)
[![Validation](https://img.shields.io/github/actions/workflow/status/openclimatefix/ocf-infrastructure/terraform-validate.yaml?label=validate)](https://github.com/openclimatefix/ocf-infrastructure/actions/workflows/terraform-validate.yaml)
[![Local Stack Tests](https://img.shields.io/github/actions/workflow/status/openclimatefix/ocf-infrastructure/local-stack-tests.yaml?label=local-stack)](https://github.com/openclimatefix/ocf-infrastructure/actions/workflows/local-stack-tests.yaml)
[![All Contributors][contributors-shield]](#contributors-)

Terraform infrastructure-as-code for cloud environments and services in use by OCF.


## Repository Structure

```yaml
ocf-infrastructure:
  terraform: # Contains all the terraform code for OCF's cloud infrastructure
    modules: # Portable terraform modules defining specific cloud infrastructure blocks
    nowcasting: # Specific code for the nowcasting domain's cloud infrastructure
    pvsite: # Specific code for the nowcasting domain's cloud infrastruture
    unittests: # Specific infrastructure code for a environment to test the modules
  local-stack: # Code to run the terraform stack locally for local testing/development
  .github: # Contains github-specific code for automated CI workflows
```

See the README's in the domain folders for more information on their architecture:
- [Nowcasting Domain](terraform/nowcasting/README.md)
- [PVSite Domain](terraform/pvsite/README.md)


## Terraform Overview

[Terraform](https://learn.hashicorp.com/terraform) is a declariative language which is used to specify and build cloud environments. To install the CLI locally, ensure [Homebrew](https://brew.sh/) is installed, then run

```bash
$ brew install terraform
```

If you aren't on Mac or don't want to use Homebrew,
[check out the official terraform installation instructions](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform).

## Pre-Commit

This repository implements a [pre-commit](https://pre-commit.com/#install) config that enables automatic fixes to code when you create a commit. This helps to maintin consistency in the main repo. To enable this, follow the [installation instructions on the precommit website](https://pre-commit.com/#install).

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/peterdudfield"><img src="https://avatars.githubusercontent.com/u/34686298?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Peter Dudfield</b></sub></a><br /><a href="https://github.com/openclimatefix/nowcasting_infrastructure/commits?author=peterdudfield" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/flowirtz"><img src="https://avatars.githubusercontent.com/u/6052785?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Flo</b></sub></a><br /><a href="https://github.com/openclimatefix/nowcasting_infrastructure/pulls?q=is%3Apr+reviewed-by%3Aflowirtz" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/vnshanmukh"><img src="https://avatars.githubusercontent.com/u/67438038?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Shanmukh</b></sub></a><br /><a href="https://github.com/openclimatefix/nowcasting_infrastructure/commits?author=vnshanmukh" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/lordsonfernando"><img src="https://avatars.githubusercontent.com/u/68499565?v=4?s=100" width="100px;" alt=""/><br /><sub><b>lordsonfernando</b></sub></a><br /><a href="https://github.com/openclimatefix/nowcasting_infrastructure/commits?author=lordsonfernando" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/gmlyth"><img src="https://avatars.githubusercontent.com/u/88547342?v=4?s=100" width="100px;" alt=""/><br /><sub><b>gmlyth</b></sub></a><br /><a href="https://github.com/openclimatefix/nowcasting_infrastructure/commits?author=gmlyth" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
