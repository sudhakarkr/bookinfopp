#!/bin/bash

AZ_RELEASE_GROUP=istioRG
AZ_LOCATION="West Europe"
AZ_AKS_CLUSTER_NAME=istioAKSCluster
AZ_K8S_NODECOUNT=3
AZ_K8S_VERSION=1.13.10
AZ_ACR_NAME=istioACR

echo "Create a Resource Group"
az group create --name istioRG --location "West Europe"

echo "Create a cluster"
az aks create --resource-group istioRG --name istioAKSCluster --node-count 3 --kubernetes-version 1.13.10 --generate-ssh-keys

echo "Create an  Azure Container Registry"
az acr create -n istioACR -g istioRG -l "West Europe" --sku Basic --admin-enabled true

echo "Login into AKS"
az aks get-credentials -n istioAKSCluster -g istioRG --overwrite-existing 

helm init --wait

echo "Setup tiller for Helm, we will discuss about this tool later"
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller



ISTIO_VERSION=1.2.5

curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.5 sh -

cd istio-$ISTIO_VERSION
sudo cp ./bin/istioctl /usr/local/bin/istioctl
sudo chmod +x /usr/local/bin/istioctl

helm init --service-account tiller --upgrade

helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system

kubectl get jobs -n istio-system

GRAFANA_USERNAME=$(echo -n "grafana" | base64)
GRAFANA_PASSPHRASE=$(echo -n "grAfAnA" | base64)

apiVersion: v1
cat <<EOF | kubectl apply -f -
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
metadata:
kind: Secret
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


1. Grant the AKS-generated service principal pull access to our ACR, the AKS cluster will be able to pull images of our ACR

$CLIENT_ID=$(az aks show -g istioSampleRG -n istioSampleCluster --query "servicePrincipalProfile.clientId" -o tsv)
$ACR_ID=$(az acr show -n istioSampleACR -g istioSampleRG --query "id" -o tsv)

`` az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID


- 2. Create a specific Service Principal for our Azure DevOps pipelines to be able to push and pull images and charts of our ACR

$ registryPassword=$(az ad sp create-for-rbac -n istioSampleACR-push --scopes $ACR_ID --role acrpush --query password -o tsv)

# Important note: you will need this registryPassword value later in this blog article in the Create a Build pipeline and Create a Release pipeline sections

$ echo $registryPassword


40.118.26.184:81

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')


kubectl exec -it $(kubectl get pod -l app=productpage -o jsonpath='{.items[0].metadata.name}') -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
<title>Simple Bookstore App</title>


kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl localhost:9080/productpage | grep -o "<title>.*</title>"

kubectl get svc istio-ingressgateway -n istio-system


