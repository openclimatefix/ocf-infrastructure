<h2 align="center">
OCF Infrastructure
<br>
<br>
Terraform infrastructure-as-code for cloud environments.
</h2>

<p align="center">

[![ease of contribution: medium](https://img.shields.io/badge/ease%20of%20contribution:%20medium-f4900c)](https://github.com/openclimatefix/ocf-meta-repo?tab=readme-ov-file#how-easy-is-it-to-get-involved)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-13-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

  <a href="https://app.terraform.io/app/openclimatefix/workspaces" alt="Terraform Cloud">
        <img src="https://img.shields.io/badge/console-terraform.io-blue?style=for-the-badge"/></a>
  <a href="https://github.com/openclimatefix/ocf-infrastructure/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc" alt="Issues">
        <img src="https://img.shields.io/github/issues/openclimatefix/ocf-infrastructure?style=for-the-badge"/></a>
  <a href="https://github.com/openclimatefix/ocf-infrastructure/actions/workflows/terraform-validate.yaml" alt="Validate">
        <img src="https://img.shields.io/github/actions/workflow/status/openclimatefix/ocf-infrastructure/terraform-validate.yaml?label=validate&style=for-the-badge"/></a>
  <a href="https://github.com/openclimatefix/ocf-infrastructure/graphs/contributors" alt="Contributors">
        <img src="https://img.shields.io/github/contributors/openclimatefix/ocf-infrastructure?style=for-the-badge"/></a>
</p>

<br>

A repository for managing the cloud infrastructure for the Open Climate Fix organisation. Contains terraform code for
defining services and describing environments. Each contextual domain and each deployment environment are specified in
folders within the `terraform` directory, along with reusable modules and unittests.


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
- [Modules](terraform/modules/README.md)


## Terraform Overview

[Terraform](https://learn.hashicorp.com/terraform) is a declarative language which is used to specify and build cloud environments. To install the CLI locally, ensure [Homebrew](https://brew.sh/) is installed, then run

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
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/peterdudfield"><img src="https://avatars.githubusercontent.com/u/34686298?v=4?s=100" width="100px;" alt="Peter Dudfield"/><br /><sub><b>Peter Dudfield</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=peterdudfield" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/flowirtz"><img src="https://avatars.githubusercontent.com/u/6052785?v=4?s=100" width="100px;" alt="Flo"/><br /><sub><b>Flo</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/pulls?q=is%3Apr+reviewed-by%3Aflowirtz" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/vnshanmukh"><img src="https://avatars.githubusercontent.com/u/67438038?v=4?s=100" width="100px;" alt="Shanmukh"/><br /><sub><b>Shanmukh</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=vnshanmukh" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lordsonfernando"><img src="https://avatars.githubusercontent.com/u/68499565?v=4?s=100" width="100px;" alt="lordsonfernando"/><br /><sub><b>lordsonfernando</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=lordsonfernando" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gmlyth"><img src="https://avatars.githubusercontent.com/u/88547342?v=4?s=100" width="100px;" alt="gmlyth"/><br /><sub><b>gmlyth</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=gmlyth" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://bio.link/klj"><img src="https://avatars.githubusercontent.com/u/2559382?v=4?s=100" width="100px;" alt="Keenan Johnson"/><br /><sub><b>Keenan Johnson</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=keenanjohnson" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/devsjc"><img src="https://avatars.githubusercontent.com/u/47188100?v=4?s=100" width="100px;" alt="devsjc"/><br /><sub><b>devsjc</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=devsjc" title="Code">💻</a> <a href="#design-devsjc" title="Design">🎨</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/wsharpe41"><img src="https://avatars.githubusercontent.com/u/122390836?v=4?s=100" width="100px;" alt="wsharpe41"/><br /><sub><b>wsharpe41</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=wsharpe41" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.pgarcia.dev"><img src="https://avatars.githubusercontent.com/u/10740572?v=4?s=100" width="100px;" alt="Pedro Garcia Rodriguez"/><br /><sub><b>Pedro Garcia Rodriguez</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=BreakingPitt" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/erikg16"><img src="https://avatars.githubusercontent.com/u/81220397?v=4?s=100" width="100px;" alt="erikg16"/><br /><sub><b>erikg16</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=erikg16" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://aatmanvaidya.github.io/"><img src="https://avatars.githubusercontent.com/u/56875084?v=4?s=100" width="100px;" alt="Aatman Vaidya"/><br /><sub><b>Aatman Vaidya</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=aatmanvaidya" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ACSE-vg822"><img src="https://avatars.githubusercontent.com/u/82698606?v=4?s=100" width="100px;" alt="Vidushee Geetam"/><br /><sub><b>Vidushee Geetam</b></sub></a><br /><a href="#maintenance-ACSE-vg822" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mahmoud-40"><img src="https://avatars.githubusercontent.com/u/116794637?v=4?s=100" width="100px;" alt="Mahmoud Abdulmawlaa"/><br /><sub><b>Mahmoud Abdulmawlaa</b></sub></a><br /><a href="https://github.com/openclimatefix/ocf-infrastructure/commits?author=mahmoud-40" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
