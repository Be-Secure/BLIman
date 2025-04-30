# Managing genesis file configurations.
## Gudelines to Add or Update a genesis file.
To update the existing genesis files, follow the below guidelines.

- All configuration must be in capital letters.
- Add following two configuration for any new tool mandatory.
    - INSTALL_\<TOOLNAME\> 
        <br>Tool is installed only if this is enalbed. if disabled or not defined tool is not installed.
    - TOOLNAME_\<VESRION\>
    <br> Tells the version of tool to be installed. If not defined or blank install the latest release.
    <br> Replace the \<TOOLNAME\> with the actual name of tool in capital letters.
- For any configuration added put the comments above the configuration to specify possible values, description and reference if any.
- Configurations must have default values assigned initially.
- Keep the configuration as minimum as possible. Do not add too many parameters to be passed for a tool.

## Guidelines to add new custom genesis file.
To add any new custom genesis file, it must be grouping additional tool on top of default genesis file. [default-genesis](https://github.com/Be-Secure/BeSLab/blob/master/genesis.yaml).

1. Create a fork to BLIman to your github namespace.

2. Clone the BLIman to local machine.
<br>Go to BLIman/genesis folder.

3. Downlaod the default genesis file from BeSLab from [here](https://github.com/Be-Secure/BeSLab/blob/master/genesis.yaml)

4. Rename the genesis file to genesis-\<capital abbrevation of tools froup e.g OASP, OSPO\>.yaml
e.g genesis-OASP.yaml

5. Add the tools and there configurations by following insurction mentioned in above section [guidelines](Gudelines-to-Add-or-Update-a-genesis-file.)
6. For a new genesis file there will be code changes required.
- Copy the template script placed at src/launch-template.sh to src/bliman-launch-<Abberavation of tool group used in genesis file>.sh e.g bliman-launch-OASP.sh
- Edit the new script to call the tool installation environment or function. Please read the comments of template file carefully to wrire the module.
- Once the script is created we need to get the module called in __bli_launchlab function at src/bliman-launchlab.sh file.
- Add the if condition and call the __bliman_launchlab_<group name> function. The code snippet to add the if condition as shown.
```
   if [ ! -z $1 ];then
       if [ $1 == "OASP" ];then
          serviceprovider="OASP"
          #  call the function to install OASP here
       elif [ $1 == "OSPO" ];then
          serviceprovider="OSPO"
          # call the function to install OSPO here
       elif [ $1 == "AIC" ];then
          serviceprovider="AIC"
          # call the function to install AIC here

       ## Add additional if condition to add new group of tools and call the corresponding functions for that group.

       else
          # if no specific group is provided than install the defaul genesis file by default.
          serviceprovider="default"
       fi

    fi
```
- Update the documentation and help files if required.
6. Add and push to your namespace develop branch.
7. Raise PR to be merged from your develop branch to BLIman branch.
8. On acceptance of changes the changes can be merged to develop branch of BLIman.
