# groupmembers

[![Build Status](https://travis-ci.org/ffalor/ffalor-groupmembers.svg?branch=master)](https://travis-ci.org/ffalor/ffalor-groupmembers)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/504d380a131a46528b66c78fb67236c5)](https://www.codacy.com/app/ffalor/ffalor-groupmembers?utm_source=github.com&utm_medium=referral&utm_content=ffalor/ffalor-groupmembers&utm_campaign=Badge_Grade)
![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/ffalor/groupmembers.svg)
![GitHub issues](https://img.shields.io/github/issues/ffalor/ffalor-groupmembers.svg)
![Puppet Forge feedback score](https://img.shields.io/puppetforge/f/ffalor/groupmembers.svg?label=puppet%20score&style=plastic)
![Puppet Forge version](https://img.shields.io/puppetforge/v/ffalor/groupmembers.svg)
![Puppet Forge – PDK version](https://img.shields.io/puppetforge/pdk-version/ffalor/groupmembers.svg)

## Table of Contents

1.  [Description](#description)
2.  [Requirements](#Requirements)
3.  [Usage - Configuration options and additional functionality](#usage)
    -   [Puppet Tasks and Bolt](#Puppet-Task-and-Bolt)
    -   [Puppet Task API](#Puppet-Task-Api)
4.  [Development - Guide for contributing to the module](#development)

## Description

This module includes a puppet task to help manage local groups.

This task can be used to remove or add members to local security groups. Allowing administrators and customers to add and remove multiple users to multiple machines.

This task can be exposed as a service via the puppet task endpoint to allow remote execution and self service access management.

## Requirements

PowerShell 5.1 is recommended to ensure full functionality. The task will use net.exe if version 5.1 is not present. See the [Limitations](Limitations) section for more information.

This module is compatible with Puppet Enterprise and Puppet Bolt.

-   To run tasks with Puppet Enterprise, PE 2018.1 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.
-   To run tasks with Puppet Bolt, Bolt 1.0 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled.

## Usage

### Puppet Task and Bolt

To run an groupmembers task, use the task command, specifying the command to be executed.

-   With PE on the command line, run `puppet task run groupmembers ensure=<present|absent> group=<groupname> member=<String|Array>`.
-   With Bolt on the command line, run `bolt task run groupmembers ensure=<present|absent> group=<groupname> member=<String|Array>`.

For example, to add a example\\jdoe to administrators group, run:

-   With PE, run `puppet task run groupmembers ensure=present group=administrators member="example\\jdoe" --nodes saturn`.
-   With Bolt, run `bolt task run groupmembers ensure=present group=administrators member="example\\jdoe" --nodes saturn`.

### Puppet Task API

endpoint: `https://<puppet>:8143/orchestrator/v1/command/task`

method: `post`

body:

```json
{
  "environment": "production",
  "task": "groupmembers",
  "params": {
    "ensure": "present",
    "group": "Administrators",
    "member": ["example\\jdoe", "example\\dotterman"]
  },
  "description": "Description for task",
  "scope": {
    "nodes": ["saturn.example.com"]
  }
}
```

You can also run tasks in the PE console. See PE task documentation for complete information.

## Limitations

The task will use PowerShell if version 5.1 is present. If not net.exe will be used which has a limitation of not being able to add/remove members with names longer than 20 characters.
See this [Microsoft Support Doc](https://support.microsoft.com/en-us/help/324639/net-exe-add-command-does-not-support-names-longer-than-20-characters) for more information. 

If PowerShell 5.1 is not present, and a member with a name longer than 20 characters is passed the task will skip that member to avoid erroring and to ensure other valid members are added.

## Development

Feel free to fork it fix my crappy code and create a PR (:
