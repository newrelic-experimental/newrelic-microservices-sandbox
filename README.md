# newrelic-microservices-sandbox
### From zero to Observability while you brew coffee

## What is this?
A set of Terraform modules that will deploy a fully-instrumented microservices stack using AWS and New Relic.

## Quickstart
### Prerequisites
1. A New Relic account and License Key
2. An AWS account
3. Terraform installed

### Directions
1. begin by cloning this repository
2. cd into the `terraform` directory
3. make a copy of the file `terraform.tfvars.sample` and rename it `terraform.tfvars`
4. Open the file and edit the variables for your own configuration and deployment.
    
    _Notes_: The Terraform module uses the [AWS resource provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs))
    to create AWS resources on your behalf. In order to do this, it must be configured properly with credentials, region, etc.
    There are several ways you can do this - using environment variables, or if you have installed the AWS cli, the Terraform provider
    will use the credentials stored in you home dir, as well as several other methods.  Configuring the module is out of the scope
    of this doc.  Recommend reading the link above to use the method that works best for you.

    Similarly, your New Relic license key is used in several places and is provided as a standard Terraform variable.  You
    may set it in the .tfvars file for convenience, or you can use any of the standard methods for setting and overriding variables
    according to the [Terraform docs](https://www.terraform.io/language/values/variables#variables-on-the-command-line)
5. run `terraform init`
6. When you are ready to deploy run `terraform apply`.  Terraform will provide a list of all of the resources its going to create
    and will prompt you for confirmation

    _Notes_:  This is going to create a 3-node Kubernetes cluster in EKS, and ALB, a VPC, and all of the necessary supporting
    resources (roles, auto-scaling groups, etc).  All resources will be tagged with `project=<your cluster name>` and `owner=<owner>`
    that you provided in the configuration, should you need to identify them outside of Terraform
    
    The default limit for the number of VPCs in each region per AWS account is usually in the single digits.  If you are using
    a shared account, it's possible that you may run into this limit.  In that case, recommend choosing another region,
    or requesting a quota increase.
7. After 20-30 minutes, your cluster should be completely deployed.  Terraform will display the output from the module, which will
    include the hostname of the loadbalancer as well as the path to the kubeconfig file it created, should you want to interface with the
    cluster directly via `kubectl`, etc.  At any time you can run `terraform output` from this directory to view those values.  Note that
    Terraform will have created a `terraform.tfstate` file.  This is how Terraform keeps track of what it has deployed.  Don't
    delete this file, otherwise Terraform will not be able to clean up when you are done!
8. You can visit the loadbalancer host in a browser and you should be directed to the OpenApi/Swagger documentation for the Api.
    You can also visit New Relic One to see the mircroservices working together, complete with Kubernetes Cluster Explorer,
    Distributed Tracing, and Logs-in-context.
9.  Run `terraform destroy` when you are done, and all created resources will be removed.