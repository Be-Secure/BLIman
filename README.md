![BLIman](./BLIman-logo-horizontal.png)

BLIman is a command line interface for managing [BeSLab](https://github.com/Be-Secure/BeSLab) deployments. It can be used to bring up the lab in 3 different modes. 

* Lite Mode 
<br> All shell script mode. where all installation are done using shell scripts and ideal for very low resource settings. Required Linux ubuntu host machine for this mode.
* <i>Host Mode (Work in progress)</i>
Installs BeSLab in a virtual machine on top of a hosted machine. It installs a Oah-bes VM on the host machine and Lab is installed on the VM installed by Oah-bes VM. Suitable for windows host systems.
* <i>Bare Mode (Work in progress)</i>
Install the Lab on a sytem other than the host system itself using Ansible scripts. if the system where BLIman is installed is not able to install the BeSLab locally than this mode can install the Lab on a remote machine using ansible scripts.
In addition, there are 3 deployment types for each lab mode.
* Private Lab - Owned by an organization for commercial usage.
* <i>Public Lab (Work in progress) - Community lab hosted in any public code collaboration repository.</i>
* <i>Personal Lab (Work in progress) - Owned by an individual for learning and research purpose.</i>

The default deployment of BeSlab is comprising of basic tools and configurations which are needed for any all deployment models. An Open-Source Service Provider is an entity who performs various activity on any Open-Source Software or AI Models such as security assessment for OSS and AI Models, Attestation and Assurance services, TAVOSS certification, AI models security and guardrails etc.

BLIman extends the default BeSLab deployment of BeSLab to bundle the tools for specific need.

It defines 3 type of BeSLab usage and extends the installation of BeSLab to support for these type of service providers with a single BLIman command and specific genesis file designed for each type installation. 

The 3 type of deployments defined are:

* OSPO - (Open-Source Program Office) An entity or organisation providing Open-Source assessment and security services alognwith TAVOSS version of software. 
* AIC - (AI Council) is an organisation or entity providing security services for AI models and  its deployments. This is aimed for setting up BeSLab for specific to AI requirements.
* OASP - (Open-Source Assurance Service Provider) provides assurance to various OSS and AI models and are able to offer assurance services on marketplace such as OSSVerse.

We are seeking your valuable contributions to enhance the BeSlab deployments and environments.

###  How to contribute to specialized BeSLab deployments click [here](https://github.com/Be-Secure/BLIman/blob/main/CONTRIBUTING.md)

## Genesis file
Genesis file is the configuration file for  [BeSLab](https://github.com/Be-Secure/BeSLab) deployments. It defines all the required configurations to deploy the BeSLab for various modes, types and models.

The default BeSLab is installed with only minimum tools required for BeSLab to launch. It uses the default genesis file [genesis.yaml](https://github.com/Be-Secure/BeSLab). If no launch type model is provided this default lab is deployed.

* genesis-OASP.yaml - A genesis file defining all the BeSLab tools and components required for the deployment of BeSLab in OASP model. Default genesis-OASP.yaml is defined [here](https://github.com/Be-Secure/BLIman/genesis/genesis-OASP.yaml)

* genesis-OSPO.yaml - A genesis file defining all the BeSLab tools and components required for the deployment of BeSLab in OSPO model. Default genesis-OSPO.yaml is defined
[here](https://github.com/Be-Secure/BLIman/genesis/genesis-OSPO.yaml)

* genesis-AIC.yaml - A genesis file defining all the BeSLab tools and components required for the deployment of BeSLab in AIC model. Default genesis-AIC.yaml is defined
[here](https://github.com/Be-Secure/BLIman/genesis/genesis-AIC.yaml)

It is recommended to have an understanding of [BeSLab](https://github.com/Be-Secure/BeSLab) and its genesis files before laucnhing the lab.

## Installing BLIman
Bliman version details [here](https://github.com/Be-Secure/BLIman/releases).

1. Open your terminal
2. Download the setup script
   <br>`curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/main/bliman_setup.sh`
   <br>`chmod +x bliman_setup.sh`
   <br>`source bliman_setup.sh install --version <bliman release version> --genpath <path or URL to genesis file>`
   <br>   - If no version is provided the latest released version will be taken.
   <br>   - If no genesis path is provided the default genesis file defined [here](https://github.com/Be-Secure/BeSLab/genesis.yaml) is used.
   <br>`source $HOME/.bliman/bin/bliman-init.sh`

## BLIman Usage

BLIman helps you to set up and manage the BeSLab deployments. It can bring up a BeSLab in 3 modes.

**Lite mode**

Currently, BLIman supports only Lite mode Private deployment type only. The other two modes and type of deployments are work in progress.

1. Open your terminal
2. Make sure you have bliman installed and running.
   <br>`bli help`
3. Download the required default genesis file.
   * Default Lab
   <br>`curl -o genesis.yaml https://raw.githubusercontent.com/Be-Secure/BeSLab/main/genesis.yaml`
   <br> OR
   * OASP Lab
   <br>`curl -o genesis.yaml https://raw.githubusercontent.com/Be-Secure/BLIman/main/genesis/genesis-OASP.yaml`
   <br> OR
    * OSPO Lab
   <br>`curl -o genesis.yaml https://raw.githubusercontent.com/Be-Secure/BLIman/main/genesis/genesis-OSPO.yaml`
   <br> OR
    * AIC Lab
   <br>`curl -o genesis.yaml https://raw.githubusercontent.com/Be-Secure/BLIman/main/genesis/genesis-AIC.yaml`
4. \(Optional Step\) Edit the genesis file if need. Default genesis files install the BeSLab with default configurations.
5. Prepare the lab deployment.
   <br>`bli load --genesis_path <path to genesis file>`
   <br>`bli initmode lite`
6. Launch the lab deployment.
   <br>`source $HOME/.besman/bin/besman-init.sh`
   * Default Lab
   <br>`bli launchlab`
   <br> OR
    * OASP Lab
   <br>`bli launchlab OASP`
   <br> OR
    * OSPO Lab
   <br>`bli launchlab OSPO`
   <br> OR
    * AIC Lab
   <br>`bli launchlab AIC`

## BLIman Commands

Following are the commands supported by BLIman

* bli help \<command name\> - Display help for individual bli command.
* bli load --genesis\_path \<genesis file path\> - To load the genesis file.
* bli initmode \<mode name i.e lite / bare / host\> - It initializes the BeSlab installation for the mode provided.
* bli launchlab \< OASP / OSPO / AIC \> - It installs the BeSLab as per the genesis configuration file and provided lab model in parameter. If no paramter passed default basic lab is installed.
* bli attest-OSAR - To attest the OSAR reports. use `bli help attest-OSAR` for more info.
* bli verify-OSAR - To verify the OSAR report attestation. Use `bli help verify-OSAR` for more info.
* bli create - To create the project or users in code collaboration platform. Use `bli help create` for more info.
