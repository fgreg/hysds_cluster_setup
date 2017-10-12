HySDS Cluster Provisioner
=========================

Set of shell and fabric scripts to help provision a HySDS cluster.


Installation
------------
As _ops_ run:
```
cd ~
git clone https://github.jpl.nasa.gov/hysds-org/hysds_cluster_setup
cd hysds_cluster_setup
cp context.sh.example context.sh
cp cluster.py.example cluster.py
```
Update *context.sh* with info pertaining to your HySDS cluster.
Update *cluster.py* with additional code that needs to be provisioned on the workers.

Configuration
-------------
This section details how to set up the *context.sh*.

```
export MOZART_PVT_IP=172.31.27.105
export MOZART_FQDN=ec2-52-37-100-9.us-west-2.compute.amazonaws.com
```
Specify the IP address and the fully-qualified domain name of the Mozart VM instance on your cluster.

```
export OPS_USER=ops
export OPS_PASSWORD_HASH=79e10db77f0894f8fcc35f0759c734724137f579fe5c5a1f525be8f2
```
OPS_USER is the name for the login to webtools (Mozart Resource Management, FacetSearch, etc) for the operations special user. OPS_PASSWORD_HASH is a sha224sum of the password for that user. To create the hash, run the following command:

```
echo -n <password> | sha224sum
```
and copy and paste the output to the OPS_PASSWORD_HASH setting. If you do not change this setting, then the default login account is username _ops_ with the password set to _ops_.

```
export LDAP_GROUP=dumby
```
Specify the LDAP group name of the set of users that will have access to the webtools.

```
export KEY_FILENAME=/home/ops/.ssh/dumby.pem
```
Specify the path to the PEM key located on the Mozart VM instance. This PEM key is associated with the ops user that is allowed to ssh into the Mozart VM instance.

```
export METRICS_PVT_IP=172.31.21.35
export METRICS_FQDN=ec2-52-35-70-248.us-west-2.compute.amazonaws.com
```
Specify the IP address and the fully qualified domain name of the Metrics VM instance on your cluster.

```
export GRQ_PVT_IP=172.31.16.93
export GRQ_FQDN=ec2-52-37-68-70.us-west-2.compute.amazonaws.com
export GRQ_PORT=8878
```
Specify the IP address, port number, and fully qualified domain name of the GRQ VM instance on your cluster.

```
export FACTOTUM_PVT_IP=172.31.20.141
export FACTOTUM_FQDN=ec2-52-26-210-61.us-west-2.compute.amazonaws.com
```
Specify the IP address and fully qualified domain name of the Factotum VM instance on your cluster.

```
export VERDI_PVT_IP=172.31.11.165
export VERDI_FQDN=172.31.11.165
```
Specify the IP address and fully qualified domain name of the Continuous Integration VM instance on your cluster.

```
export VERDI_PVT_IP=172.31.11.160
export VERDI_FQDN=172.31.11.160
```
Specify the IP address and fully qualified domain name of the Verdi VM instance on your cluster.

```
export DATASET_AWS_ACCESS_KEY=<your AWS access key>
export DATASET_AWS_SECRET_KEY=<your AWS secret key>
export DATASET_AWS_REGION=us-west-1
export DATASET_S3_ENDPOINT=s3-us-west-1.amazonaws.com
export DATASET_S3_WEBSITE_ENDPOINT=s3-website-us-west-1.amazonaws.com
export DATASET_BUCKET=demo-product-bucket
```
These settings refer to where the output products will be stored.

Specify the access key and secret key associated with your account on Amazon Web Services (AWS). To get these keys do the following:
* Log in to AWS.
* Click on your username at the top right and select _Security Credentials_ from the drop down menu.
* Click on _Users_ on the left. Find your username then click on it.
* Under the _Security Credentials_ tab, click on the _Create Access Key_ button.
* Follow the instructions to retrieve your keys.

Specify the bucket name, S3 endpoint, and S3 website endpoint where the output products will reside. To create an S3 bucket do the following:
* Log in to AWS.
* Click on _S3_ from the Console page.
* Click the _Create Bucket_ button and follow the instructions.

The DATASET_S3_ENDPOINT and DATASET_S3_WEBSITE_ENDPOINT should essentially be the same name. Only difference is that DATASET_S3_WEBSITE_ENDPOINT has the _-website-_ in its name.

At this point, no further configuration needs to be done if you want to run HySDS. However, if you would like to configure the system further to take advantage of HySDS' auto scaling feature, then go to the Configuration for Auto Scaling section below.

# Configuration for Auto Scaling
```
export AWS_ACCESS_KEY=<your AWS access key>
export AWS_SECRET_KEY=<your AWS secret key>
export AWS_REGION=us-west-1
export S3_ENDPOINT=s3-us-west-1.amazonaws.com
export CODE_BUCKET=demo-code-bucket
export CODE_TARBALL=dumby-ops.tbz2
```
Specify the AWS_ACCESS_KEY, AWS_SECRET_KEY, AWS_REGION and S3_ENDPOINT where the CODE_BUCKET is located. In most cases, these values will be the same as those specified in DATASET_AWS_REGION, DATASET_AWS_ACCESS_KEY, DATASET_AWS_SECRET_KEY, and DATASET_S3_ENDPOINT, respectively. If the AutoScaling group is going to run in a region different from that of the S3 bucket that products will be published to, then adjust these settings accordingly. The CODE_TARBALL value is the name of the tarball placed inside the CODE_BUCKET. This tarball contains the software code needed by the Autoscale Workers.

```
export AUTOSCALE_WORKER_NAME=demo-autoscale-verdi-worker
```
Specify the name given to the Auto Scaling group in AWS that will be scaled up when needed. This name should match the _Name_ Key-Value pair set under the _Tags_ tab of the desired Auto Scaling group.

```
export MONITORED_QUEUE=dumby
```
Specify the queue name for AWS to monitor so that it can auto scale when needed. This queue name should match one of the queue names given in HySDS' orchestrator_jobs.json file.

# Configuration for Provenance
The following settings in the context.sh refer to HySDS' Provenance service:

```
export PROVES_URL=https://prov-es.jpl.nasa.gov/beta
export PROVES_IMPORT_URL=https://prov-es.jpl.nasa.gov/beta/api/v0.1/prov_es/import/json
```
These can be left as-is for now. This service will not used unless a PGE creates a _*.prov_es.json_ file.

