Thank you for interest in contributing to the enhancments of BeSLab capabilities.

To add any tool for the BeSLab enhancements, it must qualify with the following conditions.

1. It must be providing any of the use cases.
    - Providing OSS assessment service
    - Do aseess the AI model security.
    - Help in security for BeSlab deployment.
    - Enhance AI prompt security.
    - Secure AI datasets.
    - Able to mitigate any risk for OSS or AI Model or AI dataset.

2. It should meet following all conditions to qualify.
    - It should be able to install centralised.
    - It must contain a environment created and published at [Be-Secure/besecure-ce-env-repo](https://github.com/Be-Secure/besecure-ce-env-repo)

    For understanding the environment refer to [besecure-env-readme](https://github.com/Be-Secure/besecure-ce-env-repo/blob/main/README.md)
    
    For creating new environment refer to [creating-new-env] (https://github.com/Be-Secure/besecure-ce-env-repo/blob/main/developer-guide.md)

    - There must be a corresponding playbook created for the tool to qualify.

    For understanding of playbook refer to [playbook-readme] (https://github.com/Be-Secure/besecure-playbooks-store/blob/main/CONTRIBUTING.md)

     For creating new playbook refer to [creating-new-playbook] (https://github.com/Be-Secure/besecure-playbooks-store/blob/main/CONTRIBUTING.md)

3. Once the tool is qualified and environment and playbook are in place than identify the tool is qualifying for OSPO, OASP or AIC. It is possible that a tool can qualify to all of them or few of them.

4. Edit the coressponding genesis file/files to add the required configurations in the genesis file/files. The configuration parameters should have some default values which will be able to install the tool with default configurations if not edited by the user.

5. Add the commets on genesis file and provide the documentation for the description and usage guide of new tool using bes commands.

Clearly specify the dependency requirements of the tool in documentation or install the dependencies with environment itself.