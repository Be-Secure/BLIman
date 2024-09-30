# Managing genesis file configurations.
## Gudelines to Add or Update a genesis file.
To update the existing genesis files, follow the below guidelines.
- Find the tool applicability to which type of lab deployment or deployments is.
- All configuration must be in capital letters.
- Add following two configuration for any new tool mandatory.
    - TOOLNAME_INSTALL 
        <br>Tool is installed only if this is enalbed. if disabled or not defined tool is not installed.
    - TOOLNAM_VESRION
    <br> Tells the version of tool to be installed. If not defined or blank install the latest release.
    <br> change the TOOLNAME with the actual name of tool in capital letters.
- For any configuration added put the comments above the configuration to specify possible values, description and reference if any.

- Configurations must have deault values and should be the values assigned initially.
- Keep the configuration minimum.

## Guidelines to add new custom genesis file.
To add any new custom genesis file, it must be grouping additional tool on top of default genesis file. [default-genesis](https://github.com/Be-Secure/BeSLab/blob/master/genesis.yaml).

1. Create a fork to BLIman to your github namespace.
2. Clone the BLIman to local machine.
2. Go to BLIman/genesis folder. 
3. Downlaod the default genesis file from BeSLab from [here](https://github.com/Be-Secure/BeSLab/blob/master/genesis.yaml)
4. Rename the genesis file to genesis-<capital abbrevation of service e.g OASP, OSPO>.yaml
5. Add the tools and there configurations by following insurction mentioned in section [guidelines](Gudelines-to-Add-or-Update-a-genesis-file.)
6. Add and push to your namespace develop branch.
7. Raise PR to be merged from your develop branch to BLIman branch.
8. On acceptance of changes the changes can be merged to develop branch of BLIman.