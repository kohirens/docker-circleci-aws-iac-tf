# Alpine AWS & Terraform

When you need to run Terraform (deploy IaC) and call the AWS API from the CLI.
Approximate size is 461MB.

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/kohirens/docker-circleci-aws-iac-tf/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/kohirens/docker-circleci-aws-iac-tf/tree/main)

## Features

* Alpine
* AWS CLI v2
* Terraform
* TerraGrunt
* TfLint

## Usage

```shell
docker pull kohirens/circleci-aws-iac-tf
```

* Running AWS and Terraform CLI commands from build systems.
* Running AWS and Terraform CLI commands locally if you have a container engine
  installed already.

See Docker Hub image tags at [kohirens/circleci-aws-iac-tf]

## Pre-installed tools

Additional tools, installed apk

* bash
* curl
* git
* gnupg
* gzip
* openssh
* openssl
* tar
* wget
* unzip
* zip

---

[kohirens/circleci-aws-iac-tf]: https://hub.docker.com/repository/docker/kohirens/circleci-aws-iac-tf/general
