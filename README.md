![BLIman](./BLIman-logo-horizontal.png)

BLIman is a command line interface for managing [BeSLab](https://github.com/Be-Secure/BeSLab) deployments. It can be used to bring up the lab in 3 different modes. 

* Lite Mode 
* <i>Host Mode (Work in progress)</i>
* <i>Bare Mode (Work in progress)</i>

In addition, there are 3 deployment types for each lab mode.
* Private Lab - Owned by an organization for commercial usage.
* <i>Public Lab (Work in progress) - Community lab hosted in any public code collaboration repository.</i>
* <i>Personal Lab (Work in progress) - Owned by an individual for learning and research purpose.</i>

The default deployment of BeSlab is comprising of basic tools and configurations which are needed for any type of Open-Source service provider. An Open-Source Service Provider is an entity who performs various activity on any Open-source Software or AI models such as security assessment for OSS and AI models, Attestation and Assurance services, TAVOSS versio of OSS or AI models, AI models security and guardrails etc.

BLIman extends the default BeSLab deployment for various service type of service providers for quick and easy setup of BeSLab as per service provider requirements.
BLImand defines 3 type of service providers and extends the installation of BeSLab support for these type of service providers with a single BLIman command and specific genesis file designed for each type of service provider. 

The 3 type of service providers models defined are:
* OSPO - An entity or organisation providing Open-Source assessment and security services alognwith TAVOSS version of software.
* AIC - Called as AI Council, is an organisation or entity providing security services for AI models and Securing AI model deployments.
* OASP - Open-source Assurance Service Provider, provides assurance to various OSS and AI models and are able to offer assurance services on marketplace such as OSSVerse.

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
   <br>`source bliman_setup.sh install --version <bliman release version> --gensis_path <path or URL to genesis file>`
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
4. /(Optional Step/) Edit the genesis file if need. Default genesis files install the BeSLab with default configurations.
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
