# BLIman Contribution Guidelines

Welcome to BLIman a Be-Secure community initiative for setting up [BeSLab](https://github.com/Be-Secure/BeSLab) used by security analysts to assess open source Projects, AI Models, Model Datasets etc.

You are here which means you intented to contributing to this project. So, thanks for considering contributing to this project. Hope this guide will help you to start your good first contribution to the project. 

Since being an open source community we are grouped together from different skill sets and background and have our own ways of software writing, testing documentation etc. which can make it dofficult for the fellow contributors to contribute in the project. This guide is effort to define a common practice expected to be followed by the mainainers, contributors so that it saves time and efforts for all fellow contributors and mantainers.

# Table of content

[__TOC__]

# Understand BLIman (B-L-I-man) - Why, Where and How to use

Primary focus of BLIman is to provide a command line utility for [BeSLab](https://github.com/Be-Secure/BeSLab). It helps a Lab Admin to set up a security lab using the command line commands. BLIman helps in setting mode, installing lab tools and loading [genesis file](https://github.com/Be-Secure/BeSLab/blob/master/genesis.yaml)

It is recommended to go through the [BeSLab](https://github.com/Be-Secure/BeSLab) and [BeSman](https://github.com/Be-Secure/BeSman) to understand the role of BLIman better.

Mode details regarding BLIman can be found [here](https://github.com/Be-Secure/BLIman/blob/master/README.md).

# Contributing to enhance BeSLab deployments.

Although BeSLab projects designed to install the core lab components by default, In BLIman we are enhancing the deployments of BeSLab for various targeted deployments. These deployments are to enahnce the BeSLab default installation for various use cases and helps the OSS Security providers quick, easy and targeted installed of tools required for a specific use with the BeSLab.

For any OSS security assessment and making the reports available on marketplaces such as OSSVerse, there are multiple tools and utilities are needed for a security analysts to use.

Although these tools can be installed on security analysts local machine itself usinf the BeS Playbooks itself, but its good idea to get them installed on a centrally hosted system with the BeSLab. By installing these tools centrally hosted rather than individual machines of security analysts, it enahnces resource utilization, saves time for installation and optimal usage of resources.

For this to achieve BLIman is defining the 3 type of deployments targeted for specific usages.

* OSPO - (Open-Source Program Office) An entity or organisation providing Open-Source assessment and security services alognwith TAVOSS version of software. 
* AIC - (AI Council) is an organisation or entity providing security services for AI models and  its deployments. This is aimed for setting up BeSLab for specific to AI requirements.
* OASP - (Open-Source Assurance Service Provider) provides assurance to various OSS and AI models and are able to offer assurance services on marketplace such as OSSVerse.

To make this possible BLIman contains a folder called \"gensis\". under which a specialized genesis file is created which contains the configurations for tools required for a specific targeted type of deployment e.g OSPO, OASP or AIC.

Genesis file is the configuration file for  [BeSLab](https://github.com/Be-Secure/BeSLab) deployments. It defines all the required configurations to deploy the BeSLab for various modes, types and models.

* genesis-OASP.yaml - A genesis file defining all the BeSLab tools and components required for the deployment of BeSLab in OASP model. Default genesis-OASP.yaml is defined [here](https://github.com/Be-Secure/BLIman/genesis/genesis-OASP.yaml)

* genesis-OSPO.yaml - A genesis file defining all the BeSLab tools and components required for the deployment of BeSLab in OSPO model. Default genesis-OSPO.yaml is defined
[here](https://github.com/Be-Secure/BLIman/genesis/genesis-OSPO.yaml)

* genesis-AIC.yaml - A genesis file defining all the BeSLab tools and components required for the deployment of BeSLab in AIC model. Default genesis-AIC.yaml is defined
[here](https://github.com/Be-Secure/BLIman/genesis/genesis-AIC.yaml)

Click [here](https://github.com/Be-Secure/BLIman/genesis/contributing.md) for detailed instructions for adding a new tool.

## Installation of BLIman and BeSLab
1. Download the bliman_setup.sh

```shell
curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/main/bliman_setup.sh
```

2. Chmod to bliman_setup.sh

```shell
chmod +x bliman_setup.sh
```

3. Execute and install BLIman

```shell
source bliman_setup.sh install --version dev --genPath <Path/URL for the genesis file to be used>
```

Dev is used for development branch. For particular version to chechout use the released version on [BLIMan Releases](https://github.com/Be-Secure/BLIman/releases) and provide the specific version in --version option above.

This will install the BLIman in HOME/.bliman folder.

Since BLIman is a command line utility for BeSLab so just installing BLIman is not enough the lab admin needs to execute following commands to install the security lab completely on the local machine.

4. On execution of step 3 above. A file named genesis.yaml is created automatically in the current working directory. This file contains the default configurations for the lab to be installed as provided in the genesis file passed with --genPath option. If no --genPath option is given the default genesis.yaml file store at BeSLab will be used. 

Please go through the file and change if anything needs to change for example changing the Lab Owner name, Lab Type etc. If not changed by default private lab with lite mode and default tools will be installed.

5. Make the bliman command visible. To bring the bliman command available eigther do close the terminal and open a new terminal or use following command.

```shell
source $HOME/.bliman/bin/bliman-init.sh
```

5. Load the genesis.yaml file to memory using.

```shell
bli load --genesis_path <path to genesis file to load>
```

6. Initialize the lab mode. A lab mode needs to be set before lab installation. This make the required scripts available on local system based on mode provied in command.

```shell
bli inimode <modename>
```

Modename can be any one of among host, bare and lite. For more information on modes refer to [BeSLab Contributors Guide](https://github.com/Be-Secure/BeSlab/blob/master/CONTRBUTING.md)

7. The above command installs BeSMan and BeSLab to local system as home directory. To make the bes commands accesible either close the terminal and open it again or use the below command on same terminal.

```shell
source $HOME/.besman/bin/besman-init.sh
```

8. Once the besman is available, execute following command to install the lab.

```shell
bli launchlab <type of lab i.e OSPO, OASP, AIC>
```

This will take several minutes deoending upon the code collaboration tool, dashboard tool and other tools configured so wait for the execution of scripts completely.

9. Access the various lab components such as code collaoration tool, dashboard tool etc on browser as instructed on screen


# How to contribute

1. Create a fork of [BLIman](https://github.com/Be-Secure/BLIman) to you namespace.

2. Clone the forked repository to local system. use

```shell
git clone https://github.com/<younamespace>/BLIman.git
```

3. To add a new genesis file, follow instructions in [genesis-add-update](https://github.com/Be-Secure/BLIman/blob/main/genesis/ADD-UPDATE-GENESIS.md)

4. update the BeSLab code as instructed in [BeSLab-contribution](https://github.com/Be-Secure/BeSLab/blob/master/CONTRIBUTING.md)

5. Push the tested and passed code changes to your forked branch.

6. Raise a PR from your forked repository to BLIman repository in Be-Seucure namespace. 

Note: DO NOT raise PR request on main branch but use develop branch to raise PR for Be-Secure namespace.

7. Notify the maintainers for review. If required do the discussions for feature and modifications if any over email or discussions section.

8. On approval of PR merge the code to develop branch with all conflicts resolved.

# Where to get help

If you are need any help or support from community raise discussion in discussion forum and for any bugs raise issue in issues section or write down to Be-Secure community at we will get back as soon as possible.

We use GitHub [issues](https://github.com/Be-Secure/BLIman/issues) to track bugs and enhancements. If you have a general question, you can start a discussion [here](https://github.com/Be-Secure/BLIman/discussions).

If you are reporting a bug, please help to speed up problem diagnosis by providing as much information as possible. Ideally, that would include a small sample project that reproduces the problem.

# Code Of Conduct
This project adheres to the Contributor Covenant code of [conduct](https://github.com/Be-Secure/BLIman/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

# Maintainers

Maintainers are key contributors to our community project.

For code that has a listed maintainer or maintainers in our [CODEOWNERS](./CODEOWNERS) file, the Be-Secure team will highlight them for participation in PRs which relate to the area of code they maintain. The expectation is that a maintainer will review the code and work with the PR contributor before the code is merged by the Be-Secure team.

If an an unmaintained area of code interests you and you'd like to become a maintainer, you may simply make a PR against our [CODEOWNERS](./CODEOWNERS) file with your github handle attached to the appropriate area. If there is a maintainer or team of maintainers for that area, please coordinate with them as necessary.

# Proposing a Change

In order to be respectful of the time of community contributors, we aim to discuss potential changes in GitHub issues prior to implementation. That will allow us to give design feedback up front and set expectations about the scope of the change, and, for larger changes, how best to approach the work such that the BLIman team can review it and merge it along with other concurrent work.

If the bug you wish to fix or enhancement you wish to implement isn't already covered by a GitHub issue that contains feedback from the BeSLab team, please do start a discussion (either in a new GitHub issue or an existing one, as appropriate) before you invest significant development time. If you mention your intent to implement the change described in your issue, the BLIman team can, as best as possible, prioritize including implementation-related feedback in the subsequent discussion.

Please also look at the [review checklist](./checklist.md) to understand the code standards that we follow.

# Reporting Security Vulnerabilities

If you think you have found a security vulnerability in our project please DO NOT disclose it publicly until we’ve had a chance to fix it. Please don’t report security vulnerabilities using GitHub issues, instead please reach out to anil.singla@wipro.com.

# Pull Request Lifecycle

1. You are welcome to submit a [draft pull request](https://github.blog/2019-02-14-introducing-draft-pull-requests/) for commentary or review before it is fully completed. It's also a good idea to include specific questions or items you'd like feedback on.
2. Once you believe your pull request is ready to be merged you can create your pull request.
3. When time permits BLIman's core team members will look over your contribution and either merge, or provide comments letting you know if there is anything left to do. It may take some time for us to respond. We may also have questions that we need answers about the code, either because something doesn't make sense to us or because we want to understand your thought process. We kindly ask that you do not target specific team members.
4. If we have requested changes, you can either make those changes or, if you disagree with the suggested changes, we can have a conversation about our reasoning and agree on a path forward. This may be a multi-step process. Our view is that pull requests are a chance to collaborate, and we welcome conversations about how to do things better. It is the contributor's responsibility to address any changes requested. While reviewers are happy to give guidance, it is unsustainable for us to perform the coding work necessary to get a PR into a mergeable state.
5. In some cases, we might decide that a PR should be closed without merging. We'll make sure to provide clear reasoning when this happens. Following the recommended process above is one of the ways to ensure you don't spend time on a PR we can't or won't merge.

## Getting Your Pull Requests Merged Faster

It is much easier to review pull requests that are:

1. Well-documented: Try to explain in the pull request comments what your change does, why you have made the change, and provide instructions for how to produce the new behavior introduced in the pull request. If you can, provide screen captures or terminal output to show what the changes look like. This helps the reviewers understand and test the change.
2. Small: Try to only make one change per pull request. If you found two bugs and want to fix them both, that's awesome, but it's still best to submit the fixes as separate pull requests. This makes it much easier for reviewers to keep in their heads all of the implications of individual code changes, and that means the PR takes less effort and energy to merge. In general, the smaller the pull request, the sooner reviewers will be able to make time to review it.
3. Passing checks: Based on how much time we have, we may not review pull requests which aren't passing our checks. If you need help figuring out why checks are failing, please feel free to ask, but while we're happy to give guidance it is generally your responsibility to make sure that checks are passing. If your pull request changes an interface or invalidates an assumption that causes a bunch of checks to fail, then you need to fix those checks before we can merge your PR.

If we request changes, try to make those changes in a timely manner. Otherwise, PRs can go stale and be a lot more work for all of us to merge in the future.

Even with everyone making their best effort to be responsive, it can be time-consuming to get a PR merged. It can be frustrating to deal with the back-and-forth as we make sure that we understand the changes fully. Please bear with us, and please know that we appreciate the time and energy you put into the project.

# PR Checks

The following checks run when a PR is opened:

1. Contributor License Agreement (CLA): If this is your first contribution to BLIman you will be asked to sign the CLA.
2. Checks: Some automated checks are triggered to verify whether the contents in the pr follow our [guidelines](./checklist.md) and linting.

# Contributing Steps

- Identify an existing issue you would like to work on, or submit an issue describing your proposed change to the repo in question.
- The repo owners will respond to your issue promptly.
- Fork the desired repo, develop and test your code changes.
- Submit a pull request with a link to the issue.

# Branching and Release Strategy

Here we discuss the branching and release strategy for our projects. It ensures a structured approach to development, testing, and release management, leading to stable and reliable software releases.

## Branches

1. **Main Branch (main)**:

    - The `main` branch represents the stable version of the software.
    - Only production-ready code is merged into this branch.
    - Stable releases are tagged from this branch.

2. **Development Branch (develop)**:

    - The `develop` branch serves as the integration branch for ongoing development work.
    - Automated testing is conducted when the pull request is raised to the `develop` branch.
    - All feature branches are merged into `develop` via pull requests.
    - Once changes are validated, an RC (Release Candidate) is prepared for testing.

## Pull request process

1. **Feature Development**:

    - Create a feature branch off `develop` for each new feature or bug fix.
    - Name the branch descriptively (e.g., `feature/new-feature`).
    - Implement the changes in the feature branch.

2. **Pull Requests**:

    - Once the feature is ready, open a pull request from the feature branch to `develop`.
    - Ensure the PR title and description are clear and descriptive.
    - Various automated checks will be done on the files changed.
    - Resolve any failing checks promptly.
    - Reviewers will provide feedback and approve the PR.

3. **Release Candidate (RC)**:

    - When `develop` is stable, prepare an RC from the `develop` branch for testing.
    - The RC undergoes end-to-end testing to ensure it meets quality standards.

4. **Stable Release**:

   - After successful testing, the changes will be merged from `develop` into `main`.
   - Merge commit will be tagged as a stable release.

## Other guidelines

1. **Branch Naming**:

    - Use meaningful names for branches (e.g., `feature/issue-123`).
    - Prefix feature branches with `feature/`, bug fix branches with `bugfix/`, etc.

2. **Pull Requests**:

    - Assign appropriate reviewers to PRs.
    - Provide a clear description of the changes in the PR.
    - Link the PR to an existing issue.

3. **Testing**:

    - Test changes locally before opening a PR.

4. **Communication**:

    - Discuss major changes or architectural decisions with the community.
    - Communicate any delays or blockers promptly.

