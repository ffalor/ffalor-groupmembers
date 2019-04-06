# groupmembers

[![Build Status](https://travis-ci.org/ffalor/ffalor-groupmembers.svg?branch=master)](https://travis-ci.org/ffalor/ffalor-groupmembers)

#### Table of Contents

1. [Description](#description)
2. [Requirements](#Requirements)
3. [Usage - Configuration options and additional functionality](#usage)
   - [Puppet Tasks and Bolt](#Puppet-Task-and-Bolt)
   - [Puppet Task API](#Puppet-Task-Api)
4. [Development - Guide for contributing to the module](#development)

## Description

This module includes a puppet task to help manage local groups.

This task can be used to remove or add members to local security groups. Allowing administrators and customers to add and remove multiple users to multiple machines.

This task can be exposed as a service via the puppet task endpoint to allow remote execution and self service access management.

## Requirements

This module is compatible with Puppet Enterprise and Puppet Bolt.

- To run tasks with Puppet Enterprise, PE 2018.1 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.
- To run tasks with Puppet Bolt, Bolt 1.0 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled.

## Usage

### Puppet Task and Bolt

To run an groupmembers task, use the task command, specifying the command to be executed.

- With PE on the command line, run `puppet task run groupmembers ensure=<present|absent> group=<groupname> member=<String|Array>`.
- With Bolt on the command line, run `bolt task run groupmembers ensure=<present|absent> group=<groupname> member=<String|Array>`.

For example, to add a example\jdoe to administrators group, run:

- With PE, run `puppet task run groupmembers ensure=present group=administrators member="example\\jdoe" --nodes saturn`.
- With Bolt, run `bolt task run groupmembers ensure=present group=administrators member="example\\jdoe" --nodes saturn`.

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

Only tested on 2016 and 2012 R2 window servers.

## Development

Feel free to fork it fix my crappy code and create a PR (:
