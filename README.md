# Architecture Image

![alt text](https://github.com/scn2016/cn-solution/blob/aws-eks-terraform/eks-architecture.png)

# Infrastructure

Creates an EKS Cluster on the AWS by using the given terraform code.

* IAC using terraform (VPC,Subnets,route tables, nat gateway , internet gw , EKS cluster & node pool , security groups/rules)
* Deployment Can be done in many different ways . 
  1. Gitlab CI/CD
  2. Jenkins
  3. helmfile and helm 
  4. Spinnaker

* Monitoring can be done by using the helm charts of prometheus and grafana in cluster.
   
  #Follow the below steps to enable monitoring
	1. helm repo add bitnami https://charts.bitnami.com/bitnami
  	2. helm repo update && helm repo list
  	3. helm install my-release bitnami/kube-prometheus -n prometheus 
  	4. add entry in to the ingress or use the port-forward with k8's to check it locally.
  	   * kubectl port-forward --namespace prometheus svc/my-release-kube-prometheus-prometheus 9090:9090
  	5. helm install my-release bitnami/grafana 
  	6. add entry in to the ingress or use the port-forward with k8's to check it locally.
   	   * kubectl port-forward --namespace prometheus svc/my-release-grafana-grafana 3000:3000

## Pre Requisites

* kubectl 
* AWS IAM Authenticator
* Helm2 version 

## Requirements
* Git 
* Terraform Version : ">= 0.12.16"
* AWS provider Version : ">= 2.38.0"
* http provider

## Please follow the below step to use this solution.

1) git clone https://github.com/scn2016/cn-solution.git 

2) terraform init (To initialise plugins and backend)

3) terraform plan -out="/tmp/eks.plan" ( It will create the execution plan and store in the given location)   

4) terraform apply "/tmp/eks.plan"  (It will apply the mentioned plan and cretate the infrastructure)


## Required Parameters 
* vpc_cidr (str): Desired CIDR of the VPC
* aws_region (str): Region to create infrastructure
* cluster-name (str): Name of the Cluster
* external_ip_addr_cidrs (list): Ips to be whitelisted on Nginx Ingress 


## Outputs
* vpc_id (str): The platform VPC ID
* vpc_cidr (str): The platform VPC CIDR block
* public_subnet_ids (list): The public subnet IDs
* private_subnet_ids (list): The private subnet IDs
* cluster_security_group_id (str): Cluster Master security group for accessing from workstations
* vpc_route_table_ids (list): Cluster route tables ids
* config_map_aws_auth (str): Configmap for authentication of worker nodes
* kubeconfig (str): Kubeconfig file to connect via kubectl to EKS cluster


## Application Deployment 

To Create the Automation of the entire pipeline with Spinnaker and deploy the helm you can follow the below steps.

1. First we created Dockerfile and build an image Pushed it to dockerhub.

2. Clone Nginx stable repo from helm chart and Create package with given command and store the packgaes in the any object storage like S3 or GCS 

* helm package my-nginx-controller

3. Create the Required entities in the spinnaker like application, pipeline add artifact account and add your k8's cluster with service account

4. Pipeline consists of the 3 stages
  *  configuration :- It required the Expected artefact package and values.yaml.
  *  Bake Manifest :- You need to select the rendering template with expected artefact and also you have to produces artefact with base64 encoded format.
  *  Deploy Manifest:- In the 3rd stage you need to select your configured k8's account need to give the source of the artifact from the last stage which needs to be deploy.

## Application url can be registered for any domain and can be accessed

* This can be tested by accessing url of ELB/ALB

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes servers. Feel free to replace this as necessary.
