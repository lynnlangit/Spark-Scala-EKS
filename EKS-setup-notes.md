# Using AWS EKS (Kubernetes)

## Setup Process

A number of these steps need to be performed ONLY ONCE during setup on a particular client machine.  Also please verify that all objects are removed when you tear down a cluster.  

 - Plan for 2-3 hours for the **intial** set up and test.
 - Plan for 5-15 minutes to subsequent setup on same client machine.
 - Plan for for 3-4 minutes for small-sized SparkML job runs.
 - Plan for 20-30 minutes for cluster tear down.

 --- 

----- ONE TIME INSTALLATIONS ----
1. General Prereqs
    - **AWS account & tools** - create / configure
        - AWS Account  (currently using lynnlangit's demo AWS account)
        - AWS IAM user (currently using lynnlangit's demo IAM user)
        - AWS cli 
            - run `aws configure` to verify configuration for `--default` profile
            - could use IAM user with use non-default (named) profile  

    
2. Service Prereqs (instructions for Mac/OSX)
    - **Homebrew** - install and update package manager
        - install homebrew (then `brew update` & then `brew upgrade`)
        - this may take 10-15 minutes
    - **Terraform** - `brew install terraform`
    - **Docker** - can get Kitematic (GUI for Docker as well)
    - **Kubernetes** - due to IAM requirement, do **NOT** use 'brew install', need latest version, install from this link --  

        `wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl`  

        `chmod +x ./kubectl`   
        
        `sudo mv ./kubectl /usr/local/bin/kubectl`  

        NOTE: Requires version 1.10+ (verify with kubectl version) - might have version conflict if older version installed (tip look at gcloud as well)  

    - **Heptio** - Authentication for IAM - https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html to install Heptio (do NOT use Go-Get)
        - get it
        - set permission
        - set path
        - verify install

    It's important to verify the version of Kubernetes 1.10+, which is needed to interoperate with another requirement, which is to use Heptio/AWS IAM with EKS.  You should verify the following text after you run `kubectl version` :   
     
        `Client Version: version.Info{Major:"1", Minor:"11", GitVersion:"v1.11.0",   GitCommit:"91e7b4fd31fcd3d5f436da26c980becec37ceefe", GitTreeState:"clean", BuildDate:"2018-06-27T20:17:28Z", GoVersion:"go1.10.2", Compiler:"gc", Platform:"darwin/amd64"}`
        `Server Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.3",   GitCommit:"2bba0127d85d5a46ab4b778548be28623b32d0b0", GitTreeState:"clean", BuildDate:"2018-05-28T20:13:43Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}`  

-------

## To Setup a EKS cluster

We are running in `us-west-2` (Oregon).  AWS EKS is only available in `us-west-2` or `us-east-1` currently.  NOTE: When we tested on `us-east-1`, we got 'out of resources' errors messages from EKS.

### 1. Prepare the S3 bucket     
- create AWS s3 bucket in us-west-1 (should be in same region as cluster, currently using `us-west-2`,) note the bucket name - this will hold the Terraform state file  -> **1-time step**

### 2. Update the Terrform Templates
- update `main.tf` (line 3) with bucket name - line 6 (IAM user) profile if using something other than `[default]`, and also region (if using something other than `us-west-2`)
 - update `variables.tf` - change profie and region as above

### 3. Prepare and run Terraform Templates
- navigate to `/infrastructure/tf/`directory -> 

    - run `terraform init` - (only have to do this the first time, or if terraform templte changes)
    - run `terraform plan -out /tmp/tfplan` - verify no errors after it's run
    - run `terraform apply "/tmp/tfplan"` - this can take up to 15 minutes

TIPS: 
- if error on re-run `terraform plan`, the `terraform apply...`
 - you may need to edit the region for the VPCs in the modules folder -> eks-vpc -> `main.tf` section if using other AWS region.


### 4. Verify kubernetes cluster
    --- First Time Only (below) ---
    - then `mkdir ~/.kube`
    - then `cp infrastructure/tf/out/config ~/.kube`  
    --- First Time Only (above) ---

 - from your open terminal run `kubectl cluster-info` 
    - you should see a cluster address
    - you can also look in AWS EC2 to see two running instances

### 5. Add the nodes, dashboard, RBAC
 - from your open terminal run `kubectl get nodes`
 - there should be no nodes at this point - `No resources found.`
 - verify your directory, change if needed `cd infrastructure/tf`
 - run `kubectl apply -f out/setup.yaml` and wait for 'ready' in state to add the resources to your cluster
 - run `kubectl proxy` 
    - connect using this proxy address:
    -`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
    - **IMPORTANT** leave your terminal window open
    - **IMPORTANT** leave the Kubernetes dashboard (web page) open


 -----

## Run the Kubernetes Dashboard

#### 1. Add data to S3
 - naviage to your S3 bucket that was created during setup
 - upload data files for analysis 
#### 2. Run Spark analysis
 - View your example notebook, read notebook and RUN  -or-
 - Update notebook lines 29 - 46 for customized job run 
 - View kubernetes dashboard - watch pods get created (red -> green)
     - wait 3-4 minutes for job to complete
 - Verify job completion in notebook

 ***TIPS:*** 
 1. To stop a running job
    - Search for the pod which is the 'driver' on the Kubernetes dashboard
    - Kill that pod
    - Wait for all pods in that job to terminate
 2. To connect to the Spark Dashboard
    - Start a Spark job run
    - Search for the pod which is the 'driver' on the Kubernetes dashboard
    - Proxy - `kubectl port-forward <driver-pod-name> 4040:4040`
    and LEAVE that terminal window open
    - Access the Spark dashboard, while the job is running at `http://localhost:4040`

***IMPORTANT:*** At this time, due to security simplification at this phase, you must DOWNLOAD your notebook, BEFORE you terminate your kubernetes cluster 

----

## Tear Down the Cluster

- from **spark** open terminal window
    - `terraform plan --destroy -out /tmp/tfplan` (verify no errors!)
    - `terraform apply /tmp/tfplan`
- manually delete s3 buckets with data (optional)
    - state-storage and data

-----

### Other Information and Notes
 - Heptio tokens time-out, if the connection to the Kubernetes dashboard fails, simply re-fresh the page.
 - We initially worked with Kops, rather than Kubernetes.  See `Guide.md` for step-by-step instructions using kops.