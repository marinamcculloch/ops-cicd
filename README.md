# ops-cicd
# a template project for k8s cicd projects
# based on GitOps 

This repository contains environment configuration templates and build/deploy scripts
that can be used as templates for yaml based build tools i.e Bamboo or CircleCI

Build and deployment logic is written in Powershell but can easily be refactored into
Bash, Python or any scripting language of your choice

### This template requires:
* Build Server 
* Deployment Server
* Image Registry
* K8s Cluster 
* Separate repository for Terraform module code

Based on [WeaveWorks GitOps](https://)

### What tools does it use

* Terraform
* Powershell
* YAML
* Terragrunt 

# Structure

- Directory ```scripts``` contains scripts that are used for building & deploying environments.
- Directory ```environments``` contains other directories that represent environment types (dev, uat, prod) and kubernetes namespaces on those environments (dev_1). The files ```global_config.yaml``` (shared properties for all environments), ```environment_config.yaml``` (properties specific to an environment) and ```namespace.yaml``` (properties specific to k8s namespace).
- Directory ```cicd-specs```. This contains the configuration files for your infrastructure as code. Generates your infrastructure based on templates. (recommended to commit them back for historical purpose). See build file[bamboo.yaml](./cicd-specs/bamboo.yaml).

## Scripts

- `build.ps1`
- `deploy.ps1`
- `environment-cicd.ps1`

### terragrunt

Terragrunt templates are used when building and scaffolding environments to avoid duplication, tedious copy & paste for ops and merging environment config values.

The script `build.ps1` copies the terragrunt template in the suitable environment directory within `/environments` with correct string substitution.
This minimises the need for ops teams to input manual configuration when deploying apps in several environments.
For example, if creating a module 'reactjsapp' in dev/dev_1, then configuring the terragrunt.hcl files can become complicated so it is done in `build.ps1` instead. 
Everything that is deployed in an environment is driven by the environment config file (`namespace.yaml`) and `build.ps1` will drive everything.

# Working with environments

### Usage

## Enabling or disabling a component
Components are terraform modules and represent what is deployed in each environment. The applications ```reactjsapp``` & ```pythonapp``` are enabled in all example environments.
This means they will always be deployed in cicd when the infra project is run.

All other components can be enabled/disabled by default, as a developer or ops team member should enable/disable component deployments according to each environment needs.

You can toggle the components using ```<<component_name>>_enable: true``` or ```<<component_name>>_enable: false```

The enable true/false toggle decides whether the cicd tool is going to run a deployment for this component.

### Usage
- Add ```<<component_name>>_enable: true``` if you want the component to be deployed in cicd
- Add ```<<component_name>>_enable: false``` if you don't want the component to be deployed in cicd

### Example
```yaml
# CORE #
reactjsapp_enable: false
postgres_enable: true
pythonapp_enable: true 
```

# Testing locally

## Running terragrunt commands locally
If you want to run [terragrunt command](https://terragrunt.gruntwork.io/docs/reference/cli-options/) for example:
- ```terragrunt plan-all```
- ```terragrunt validate-all```
- ```terragrunt apply```

4. To run terragrunt command on given environment:
```PowerShell
# Set up modules in namespaces based on namespace.yaml
.\scripts\build.ps1
# Change dir to your env (--terragrunt-working-dir can be used instead)
cd .\environments\dev\dev_1\
# Assign K8s Auth Bearer Token to a variable
$CI_CD_UNENCRYPTED_TOKEN=<<Your_Bearer_Token>>
# Run any valid terragrunt command
terragrunt plan-all -no-color -var="k8s_token=$CI_CD_UNENCRYPTED_TOKEN"
# plan-all will run plan against all children directories which contain .hcl files
```
**Useful commands**
- ```terragrunt plan```
- ```terragrunt validate```
- ```terragrunt output```
- ```terragrunt apply``` **# Take care when running this**
- ```terragrunt destroy``` **# Take care when running this**

For more commands see:
- [terraform docs](https://www.terraform.io/docs/commands/index.html)
- [terragrunt docs](https://terragrunt.gruntwork.io/docs/reference/cli-options/)

## Cloning namespace
Since all logic is handled by ```namespace.yaml``` and ```build.ps1``` you just need to copy paste rename appropriate namespace directory.

**Remember to change value of ```shared_namespace``` parameter in namespace.yaml of new namespace.**
