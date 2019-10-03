#!/bin/bash

# Create Namespace and enable istio injection
kubectl delete ns istiosample
kubectl create ns istiosample

kubectl label namespace istiosample istio-injection=enabled

# PLEASE NOTE : For the next set of commands makes sure the change the name of the image repository depending on name and structure of your container registry

helm install -f ./productpage/chart/productpage/values.yaml --namespace=istiosample ./productpage/chart/productpage/ -n istiosamplerelease


# STEADY STATE - 100 percent traffic prod
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istioacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=72,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istioacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=72,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait istiosamplerelease ./productpage/chart/productpage

# CANARY 10 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=90,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=10 --wait istiosamplerelease ./productpage/chart/productpage

# CANARY 90 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=10,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=90 --wait istiosamplerelease ./productpage/chart/productpage

# CANARY 100 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=0,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=100 --wait istiosamplerelease ./productpage/chart/productpage

# CANARY 100 percent, rolling upgrade of prod deployment
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=39,productionDeployment.weight=0,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=100 --wait istiosamplerelease ./productpage/chart/productpage

# PROD 100 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=39,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=0 --wait istiosamplerelease ./productpage/chart/productpage

# NEW STEADY STATE : PROD 100 percent , 0 replicas of CANARY
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=39,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait istiosamplerelease ./productpage/chart/productpage

# Rollback to previous version (CAN be executed at any state of pipeline)
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=35,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait istiosamplerelease ./productpage/chart/productpage


# HELM template to generate Kubernetes resources
helm template --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.replicaCount=2,productionDeployment.weight=100,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=0  ./productpage/chart/productpage/ > ./helm-template-output_v2.yaml

# For AzureDevops Release


helm upgrade  --install --namespace istiosample --values $(System.DefaultWorkingDirectory)/_istiosampleGit/productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=35,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait istiosamplerelease $(System.DefaultWorkingDirectory)/_istiosampleGit/productpage/chart/productpage

# CANARY 10 percent
helm upgrade  --install --namespace istiosample --values $(System.DefaultWorkingDirectory)/_istiosampleGit/productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=90,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=10 --wait istiosamplerelease $(System.DefaultWorkingDirectory)/_istiosampleGit/productpage/chart/productpage


Commands used to setup my first azaks

`` az login
- Check the Azure for available regions

`` az provider list --query "[?namespace=='Microsoft.ContainerService'].resourceTypes[] | [?resourceType=='managedClusters'].locations[]" -o tsv

- Check available Kubernetes version for West US region.

`` az aks get-versions --location "West Europe" --query "orchestrators[].orchestratorVersion"

- Create a resource group in the given region

`` az group create --name istioSampleRG --location "West Europe"

- Create a cluster with a name and specify the kubernetes version and node-count as well

`` az aks create --resource-group istioSampleRG --name istioSampleCluster --node-count 3 --kubernetes-version 1.13.10 --generate-ssh-keys

- Create an ACR registry $acr
`` az acr create -n istiosampleACR -g istioSampleRG -l "West Europe" --sku Basic --admin-enabled true

{
  "adminUserEnabled": true,
  "creationDate": "2019-08-28T11:24:16.980808+00:00",
  "id": "/subscriptions/f9071d31-94c8-43c6-b511-80f41664a0f0/resourceGroups/istioSampleRG/providers/Microsoft.ContainerRegistry/registries/istiosampleACR",
  "location": "westeurope",
  "loginServer": "istiosampleacr.azurecr.io",
  "name": "istiosampleACR",
  "networkRuleSet": null,
  "provisioningState": "Succeeded",
  "resourceGroup": "istioSampleRG",
  "sku": {
    "name": "Basic",
    "tier": "Basic"
  },
  "status": null,
  "storageAccount": null,
  "tags": {},
  "type": "Microsoft.ContainerRegistry/registries"
}


{
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "count": 3,
      "maxPods": 110,
      "name": "nodepool1",
      "osDiskSizeGb": 100,
      "osType": "Linux",
      "storageProfile": "ManagedDisks",
      "vmSize": "Standard_DS2_v2",
      "vnetSubnetId": null
    }
  ],
  "dnsPrefix": "myaks101Cl-myaks101Resource-f9071d",
  "enableRbac": true,
  "fqdn": "myaks101cl-myaks101resource-f9071d-1a412b91.hcp.eastus.azmk8s.io",
  "id": "/subscriptions/f9071d31-94c8-43c6-b511-80f41664a0f0/resourcegroups/myaks101ResourceGroup/providers/Microsoft.ContainerService/managedClusters/myaks101Cluster",
  "kubernetesVersion": "1.12.8",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqky3bbGN4QszY2Fj3c6dRpNR9Y4ka+vbK+HlTYf2Af5dttSQmRtaa7Eu/tK+TNa7+dVqdLNy7UF0wdkyzeXbPWz1ofAUWOSwTaDF9u+oX2XNWDlFBuRjEyK0/MRtMzbxRjHVWGc+qNAg1jSfk+grrC6T7/tFmU/VqaQ6DO9wXz7hjPm/TGFqs/VUsKTfOeQV+EuEJuuuWZZHTJAxsVrXvuTY6mPMQEdaEpPUIekwQpKcyY/EXCethtiHDfBBjMT7XjsivE7zMeHDrzyVTtHRwY/BLhT7qejdynkt7T9dHxv5ULwRsGpxlMvSWxBckXzydpISfSst47ya12gaZS43D sudhakarkr@hcl.com\n"
        }
      ]
    }
  },
  "location": "eastus",
  "name": "myaks101Cluster",
  "networkProfile": {
    "dnsServiceIp": "10.0.0.10",
    "dockerBridgeCidr": "172.17.0.1/16",
    "networkPlugin": "kubenet",
    "networkPolicy": null,
    "podCidr": "10.244.0.0/16",
    "serviceCidr": "10.0.0.0/16"
  },
  "nodeResourceGroup": "MC_myaks101ResourceGroup_myaks101Cluster_eastus",
  "provisioningState": "Succeeded",
  "resourceGroup": "myaks101ResourceGroup",
  "servicePrincipalProfile": {
    "clientId": "7130a016-4d55-4a82-be6a-294d39ed264f",
    "secret": null
  },
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters"
}

-- Setup of the AKS cluster
-- latestK8sVersion=$(az aks get-versions -l $location --query 'orchestrators[-1].orchestratorVersion' -o tsv)
-- az aks create -l $location -n $name -g $rg --generate-ssh-keys -k $latestK8sVersion

- Once created (the creation could take ~10 min), get the credentials to interact with your AKS cluster

 `` az aks get-credentials -n istioSampleCluster -g istioSampleRG

- Setup tiller for Helm, we will discuss about this tool later

`` kubectl create serviceaccount tiller --namespace kube-system
`` kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

- Setup the phippyandfriends namespace, you will deploy later some apps into it

`` kubectl create namespace phippyandfriends
`` kubectl create clusterrolebinding default-view --clusterrole=view --serviceaccount=phippyandfriends:default


- 1. Grant the AKS-generated service principal pull access to our ACR, the AKS cluster will be able to pull images of our ACR

$CLIENT_ID=$(az aks show -g istioSampleRG -n istioSampleCluster --query "servicePrincipalProfile.clientId" -o tsv)
$ACR_ID=$(az acr show -n istioSampleACR -g istioSampleRG --query "id" -o tsv)

`` az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID


- 2. Create a specific Service Principal for our Azure DevOps pipelines to be able to push and pull images and charts of our ACR

$ registryPassword=$(az ad sp create-for-rbac -n istioSampleACR-push --scopes $ACR_ID --role acrpush --query password -o tsv)

# Important note: you will need this registryPassword value later in this blog article in the Create a Build pipeline and Create a Release pipeline sections

$ echo $registryPassword
03aed529-9448-47f5-ba03-a609772c0f69

az acr show -n myaks101ACR --query name

- az ad sp show --id http://myaks101ACR-push --query appId -o tsv
- registry login - 1123523c-4ba1-4bb4-b6af-73f95cb8403a

- List Docker images from your ACR


`` az acr repository list -n myaks101ACR

- List Helm charts from your ACR

`` az acr helm list -n myaks101ACR

- Show details of a specific Helm chart from your ACR

`` az acr helm show chart-name -n parrot


https://myaks101cl-myaks101resource-f9071d-1a412b91.hcp.eastus.azmk8s.io:443
kubectl get serviceaccounts <service-account-name> -n <namespace> -o jsonpath='{.secrets[0].name}'


{
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "count": 3,
      "maxPods": 110,
      "name": "nodepool1",
      "osDiskSizeGb": 100,
      "osType": "Linux",
      "storageProfile": "ManagedDisks",
      "vmSize": "Standard_DS2_v2",
      "vnetSubnetId": null
    }
  ],
  "dnsPrefix": "istioSampl-istioSampleRG-f9071d",
  "enableRbac": true,
  "fqdn": "istiosampl-istiosamplerg-f9071d-526882f9.hcp.westeurope.azmk8s.io",
  "id": "/subscriptions/f9071d31-94c8-43c6-b511-80f41664a0f0/resourcegroups/istioSampleRG/providers/Microsoft.ContainerService/managedClusters/istioSampleCluster",
  "kubernetesVersion": "1.13.10",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqky3bbGN4QszY2Fj3c6dRpNR9Y4ka+vbK+HlTYf2Af5dttSQmRtaa7Eu/tK+TNa7+dVqdLNy7UF0wdkyzeXbPWz1ofAUWOSwTaDF9u+oX2XNWDlFBuRjEyK0/MRtMzbxRjHVWGc+qNAg1jSfk+grrC6T7/tFmU/VqaQ6DO9wXz7hjPm/TGFqs/VUsKTfOeQV+EuEJuuuWZZHTJAxsVrXvuTY6mPMQEdaEpPUIekwQpKcyY/EXCethtiHDfBBjMT7XjsivE7zMeHDrzyVTtHRwY/BLhT7qejdynkt7T9dHxv5ULwRsGpxlMvSWxBckXzydpISfSst47ya12gaZS43D sudhakarkr@hcl.com\n"
        }
      ]
    }
  },
  "location": "westeurope",
  "name": "istioSampleCluster",
  "networkProfile": {
    "dnsServiceIp": "10.0.0.10",
    "dockerBridgeCidr": "172.17.0.1/16",
    "networkPlugin": "kubenet",
    "networkPolicy": null,
    "podCidr": "10.244.0.0/16",
    "serviceCidr": "10.0.0.0/16"
  },
  "nodeResourceGroup": "MC_istioSampleRG_istioSampleCluster_westeurope",
  "provisioningState": "Succeeded",
  "resourceGroup": "istioSampleRG",
  "servicePrincipalProfile": {
    "clientId": "7130a016-4d55-4a82-be6a-294d39ed264f",
    "secret": null
  },
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters"
}

istiosampleACR
istiosampleacr.azurecr.io

istiosampleACR
0NT=xo8hbAzXmUu2C6iEtmK2v20i+T5R
WuH=O5ztWjcX2dVtpKKvTmEh5IEafr4C


Setup AKS and Istio in Azure

ISTIO_VERSION=1.2.5

curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.5 sh -

cd istio-$ISTIO_VERSION
sudo cp ./bin/istioctl /usr/local/bin/istioctl
sudo chmod +x /usr/local/bin/istioctl

helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
kubectl get jobs -n istio-system


GRAFANA_USERNAME=$(echo -n "grafana" | base64)
GRAFANA_PASSPHRASE=$(echo -n "grAfAnA" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: grafana
  namespace: istio-system
  labels:
    app: grafana
type: Opaque
data:
  username: $GRAFANA_USERNAME
  passphrase: $GRAFANA_PASSPHRASE
EOF

KIALI_USERNAME=$(echo -n "kiali" | base64)
KIALI_PASSPHRASE=$(echo -n "kIalI" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF


helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set global.controlPlaneSecurityEnabled=true \
  --set mixer.adapters.useAdapterCRDs=false \
  --set grafana.enabled=true --set grafana.security.enabled=true \
  --set tracing.enabled=true \
  --set kiali.enabled=true


kubectl apply -f helm-template-output_v2.yaml --namespace istiosample
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard


az aks browse --resource-group istioSampleRG --name istioSampleCluster

kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
<title>Simple Bookstore App</title>


kubectl delete ns istiosample
kubectl create namespace istiosample
kubectl label namespace istiosample istio-injection=enabled
kubectl apply -f bookinfo.yaml --namespace istiosample
kubectl apply -f bookinfo-gateway.yaml --namespace istiosample
kubectl get gateway --namespace istiosample

40.118.26.184:81

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')


kubectl exec -it $(kubectl get pod -l app=productpage -o jsonpath='{.items[0].metadata.name}') -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
<title>Simple Bookstore App</title>


kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl localhost:9080/productpage | grep -o "<title>.*</title>"

kubectl get svc istio-ingressgateway -n istio-system



kubectl get svc istio-ingressgateway -n istio-system

kubectl delete ns istiosample
kubectl create namespace istiosample
kubectl label namespace istiosample istio-injection=enabled
kubectl apply -f helm-template-output_v2.yaml --namespace istiosample
kubectl get gateway --namespace istiosample

while : ;do export GREP_COLOR='1;33';curl -s  40.118.26.184 \
 |  grep --color=always "version2" ; export GREP_COLOR='1;36';\
 while : ;curl -s  40.118.26.184 \
 | grep --color=always "version3" ; sleepwp 1; done

 while : ;do curl -s  40.118.26.184 | grep -o '<title>.*</title>'; sleep 1; done

while : ;do export GREP_COLOR='1;33';curl -s  104.42.142.214 | grep --color=always -o '<title>.*</title>'; sleep 1; done

while : ;do export GREP_COLOR='1;33';curl -s  104.42.142.214 \
| grep --color=always -o '<title>.*</title>' "<title>Simple Bookstore App v1</title>"; export GREP_COLOR='1;36'; \
| curl -s  104.42.142.214 \
| grep --color=always -o '<title>.*</title>' "<title>Simple Bookstore App v2</title>"; sleep 1;\ done



helm del --purge istiosamplerelease;

helm status istiosamplerelease;




104.209.33.171

while : ;do curl -s  104.209.33.171 | grep -o '<title>.*</title>'; sleep 1; done