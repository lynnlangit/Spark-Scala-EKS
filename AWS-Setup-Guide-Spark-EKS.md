# How to run Spark on AWS using Kops and Kubernetes

![EKS-Spark](/images/EKS-Spark-Scala.png)

## Table of Contents

1. Prerequisites
1. Task 1 - Update terraform template config
1. Task 2 - Use terraform to provision resources
1. Task 3 - Update kops config
1. Task 4 - Create cluster with kops
1. Task 5 - Configure kubernetes
1. Task 6 - Connect to the kubernetes dashboard
1. Task 7 - Submit a Spark job
1. Task 8 - View results
1. Task 9 - Cleanup

## Prerequisites

1. AWS
    1. Account - [Sign Up](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
    1. AWS CLI (configured with an admin profile)
        1. [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
        1. [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration)
            > Note that your profile name will be "default" if you configure with `aws configure` without using a `--profile` argument. This will be important later.

1. `terraform`
    1. Manual install
        1. [Download](https://www.terraform.io/downloads.html)
        1. [Install](https://www.terraform.io/intro/getting-started/install.html)
    1. OSX alternative - use homebrew
        1. `brew update`
        1. `brew upgrade`
        1. `brew install terraform`

1. `kops`
    1. [Install](https://github.com/kubernetes/kops/blob/master/docs/install.md) - OSX users use homebrew (which also installs kubectl as a dependency)
        1. `brew update`
        1. `brew install kops`

1. `kubectl` if not provided by homebrew in the previous step
    1. [Install](https://github.com/kubernetes/kops/blob/master/docs/install.md#macos-1)

## Task 1 - Update terraform template config

The source code repository contains a terraform template which provisions the necessary user, buckets, and keys needed to run the `kops` tool.  There is one small piece to customize, which is the user profile to use when running terraform.  You should have set up a profile and noted the profile name (probably `default`) while going through the prerequisites.  If not, do so now.

* Once you have the profile name, edit the file `infrastructure/tf/variables.tf`.

    1. Find the profile variable which looks like the example below:

        ```hcl
        variable "profile" {
        default = "default"
        }
        ```

    1. Update the default value if needed to match the aws cli profile you setup.  For example, if I called my cli profile `terraform-user` then my variable would look like this:

        ```hcl
        variable "profile" {
            default = "terraform-user"
        }
        ```

* Next you will update the backend configuration where terraform stores its state by editing the file `infrastructure/tf/main/tf`.

    1. Find the backend that looks like the example below:

        ```hcl
        terraform {
            backend "s3" {
                bucket  = "jamescounts-tfstate"
                key     = "variantspark-k/tfstate"
                region  = "us-west-1"
                profile = "default"
            }
        }
        ```

    1. Update the configuration, like the example below:
        1. `bucket` - create a unique name by prefixing or suffixing your own handle.  Example: `johndoe-tfstate`
        1. `region` - Chose a region near you to minimize latency.
        1. `profile` - Use the same profile you used previously for the profile variable.

        ```hcl
        terraform {
            backend "s3" {
                bucket  = "johndoe-tfstate"
                key     = "variantspark-k/tfstate"
                region  = "ap-southeast-2"
                profile = "default"
            }
        }
        ```

## Task 2 - Use terraform to provision resources

Now that terraform is configured, you can bootstrap terraform, generate an infrastructure plan, and apply it.

1. Navigate to the terraform project folder

    ```bash
    cd variantspark-k/infrastructure/tf/
    ```
1. Bootstrap terraform

    1. First use the aws cli to create the S3 bucket you configured

        ```bash
        aws s3api create-bucket --bucket jamescounts-tfstate --region us-west-1 --create-bucket-configuration LocationConstraint=us-west-1
        ```

        Output:

        ```bash
        {
            "Location": "http://jamescounts-tfstate.s3.amazonaws.com/"
        }
        ```

    1. It is highly desirable to use versioning on the terraform state bucket.

        ```bash
        aws s3api put-bucket-versioning --bucket jamescounts-tfstate --versioning-configuration Status=Enabled
        ```

        This command produces no output.

    1. Now you can initialize your terraform project directory

        ```bash
        terraform init
        ```

        Output:

        ```text
        Initializing modules...
        - module.kops-user
        - module.state-storage
        - module.input-bucket
        - module.kops-ssh

        Initializing the backend...

        Initializing provider plugins...
        - Checking for available provider plugins on https://releases.hashicorp.com...
        - Downloading plugin for provider "local" (1.1.0)...
        - Downloading plugin for provider "aws" (1.20.0)...
        - Downloading plugin for provider "template" (1.0.0)...
        - Downloading plugin for provider "tls" (1.1.0)...

        The following providers do not have any version constraints in configuration,
        so the latest version was installed.

        To prevent automatic upgrades to new major versions that may contain breaking
        changes, it is recommended to add version = "..." constraints to the
        corresponding provider blocks in configuration, with the constraint strings
        suggested below.

        * provider.aws: version = "~> 1.20"
        * provider.local: version = "~> 1.1"
        * provider.template: version = "~> 1.0"
        * provider.tls: version = "~> 1.1"

        Terraform has been successfully initialized!

        You may now begin working with Terraform. Try running "terraform plan" to see
        any changes that are required for your infrastructure. All Terraform commands
        should now work.

        If you ever set or change modules or backend configuration for Terraform,
        rerun this command to reinitialize your working directory. If you forget, other
        commands will detect it and remind you to do so if necessary.
        ```

1. Generate infrastructure plan.  The `-out` parameter will store the plan in a temporary location outside the project folder.

    ```bash
    terraform plan -out /tmp/tfplan
    ```

    Terraform will query the AWS API for existing resources, and at this stage, there should be none.  The output should indicate that 16 resources need to be created.

1. Apply the plan.

    ```bash
    terraform apply /tmp/tfplan
    ```

    Terraform will create the resources, this will take a few minutes.

## Task 3 - Update kops config

Now that terraform has laid the ground work, we can switch to `kops` to deploy a kubernetes cluster.  Terraform has produced some output files that help when working with kops

1. Copy the terraform output to the kops "project" input folder `infrastructure/kops/input` (first remove any existing input folder)

    ```bash
    cd infrastructure/kops
    rm -rf input
    mkdir input
    cp -R ../tf/out/* ./input/
    ```

The three files now in the input folder are a public/private key pair generated by terraform for use with kops, and an `env` file which contains an AWS access key id and secret, as well as some other information about the generated infrastructure.

> Note that none of this setup is secure, keys generated by terraform are meant for "throw away dev environments" only.

## Task 4 - Create cluster with kops

Now that you have your configuration in place you can run the provided scripts to create the kubernetes cluster.

1. Run `kops-init.sh`

    ```bash
    ./kops-init.sh input
    ```

    When you run the kops-init script you pass the input folder that contains the information produced by terraform.  The kops-init script then performs the following operations using kops

    1. Create the cluster configuration with `kops create cluster`
    1. Create a secret to hold the ssh public key with `kops create secret`
    1. Customize the cluster configuration to append an additional IAM policy that allows S3 access.
    1. Finally, create the cluster using `kops update cluster`

    Part of the `kops update cluster` process automatically updates your kubectl config with the info needed to manage the cluster.

## Task 5 - Configure kubernetes

In this task you will add the kubernetes dashboard components to your cluster, and create a kubernetes RBAC role for `spark-submit`.

1. Confirm kubernetes is ready.  It can take a few minutes for the cluster to warm up.  When the following command succeeds, your cluster should be ready.

    ```bash
    kubectl get nodes
    ```

    Output:

    ```text
    NAME                                          STATUS    ROLES     AGE       VERSION
    ip-172-20-37-140.us-west-1.compute.internal   Ready     node      5m        v1.9.3
    ip-172-20-40-238.us-west-1.compute.internal   Ready     master    6m        v1.9.3
    ip-172-20-44-74.us-west-1.compute.internal    Ready     node      5m        v1.9.3
    ```

1. Now run `kubernetes-init.sh` to deploy the necessary kubernetes resources.

    ```bash
    ./kubernetes-init.sh
    ```

    Output:

    ```text
    secret "kubernetes-dashboard-certs" created
    serviceaccount "kubernetes-dashboard" created
    role.rbac.authorization.k8s.io "kubernetes-dashboard-minimal" created
    rolebinding.rbac.authorization.k8s.io "kubernetes-dashboard-minimal" created
    deployment.apps "kubernetes-dashboard" created
    service "kubernetes-dashboard" created
    clusterrolebinding.rbac.authorization.k8s.io "kubernetes-dashboard" created
    serviceaccount "spark" created
    clusterrolebinding.rbac.authorization.k8s.io "spark-role" created
    ```

    This script will:

    1. Create the kubernetes dashboard ui.
    1. Unlock the UI so that the default account can access it. _This is insecure_
    1. Create a service account called `spark`.
    1. Bind the `spark` account to the `edit` role.

## Task 6 - Connect to the kubernetes dashboard

The kubernetes cluster is now ready to run spark jobs, but before submitting your first job, connect to the dashboard so you can monitor it's progress.

```bash
kubectl proxy
```

Output

```text
Starting to serve on 127.0.0.1:8001
```

This command will not terminate and while it runs it will maintain a tunnel to your kubernetes API.  You can open a browser and navigate to the dashboard at http://localhost:8001/ui.

You will be prompted to sign-in, click `SKIP` instead of trying to sign in.  You will be able to access the dashboard because we have given the default service account access when configuring the cluster.

## Task 7 - Submit a Spark job

There are currently two scripts to help you submit spark jobs, one which submits a pi-estimator, and another which runs a linear regression.  In this task you will submit the linear regression job.

1. Navigate to the `/tools/spark` folder (from the project root)

    ```bash
    cd tools/spark/
    ```

1. Determine your kubernetes API DNS name

    ```bash
    kubectl cluster-info
    ```

    Output:

    ```text
    Kubernetes master is running at https://api-kops1-k8s-local-u6p60a-949011115.us-west-1.elb.amazonaws.com
    KubeDNS is running at https://api-kops1-k8s-local-u6p60a-949011115.us-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    ```

    Copy the URL for the kubernetes master.

1. Edit `submit-sagemaker-spark.sh`

    1. Update line 7
    1. Set the `MASTER` variable to the URL you just copied.

    > Note that the scripts included in this repo refer to docker images on my github account `jamesrcounts`.  This is fine because the images are public.  You could use the Dockerfiles under the `src` directory to create your own versions of these images.

1. Review the script

    1. We can see that the master is specified with two protocols `k8s` and `https`
    1. Notice that the deploy mode is cluster
    1. The service account is specified as a `conf` property
    1. As is the container image containing our job
    1. We use a custom property to pass the bucket name for the linear regression algorithm to read and write.
    1. Additional jars must be specified to allow S3 access.

1. Run the `get-spark` script to download a spark distribution.

    ```bash
    ./get-spark
    ```

1. Submit the linear regression spark job

    ```bash
    ./submit-sagemaker-spark.sh
    ```

1. While the job runs, visit your kubernetes dashboard in the browser and refresh several times.

    1. Observe the a driver pod is deployed first.
    1. Several executor pods then run.
    1. Finally the executors shut down and are cleaned.
    1. The driver pod remains after it terminates, and you can inspect its log.

## Task 8 - View results

Terraform created a read/write bucket for spark jobs that starts with the prefix `sagemaker-spark-scala-storage` and ends with a timestamp.  Visit this bucket in the AWS web console and navigate to the `output` folder.

The spark job has serialized the linear regression model in parquet format to the `model` folder.

The spark job has serialized the model predictions in csv format to the `predictions` folder.

You may download the predictions and view them in a text editor.

## Task 9 - Cleanup

You can run more spark jobs as you like, when you are finished you can clean up the resources by following these steps:

1. Empty the `sagemaker-spark-scala-storage` bucket.  Terraform will not delete a bucket with unmanaged objects in it.

    1. Select the bucket's row in the S3 web interface.
    1. Click `Empty bucket`
    1. Paste the bucket name in the confirmation prompt.
    1. Empty the bucket.

1. Remove the kops cluster.

    1. In your terminal navigate to the `infrastructure/kops` folder.

    1. Run `./kops-delete.sh input`

1. Empty the `sagemaker-spark-scala-store` bucket.

1. Remove the terraform resources.

    1. In your terminal, navigate to the `infrastructure/tf` folder.

    1. Create a plan to destroy the infrastructure by running `terraform plan -destroy -out /tmp/tfplan`

    1. Apply the plan `terraform apply /tmp/tfplan`

> Note to completely remove all resources, you can also remove your terraform backend state bucket, and your kops admin user if you created one.

