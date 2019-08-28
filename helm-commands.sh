#!/bin/bash

# Create Namespace and enable istio injection
kubectl create ns istiosample

kubectl label namespace istiosample istio-injection=enabled

# PLEASE NOTE : For the next set of commands makes sure the change the name of the image repository depending on name and structure of your container registry

helm install -f ./productpage/chart/productpage/values.yaml --namespace=istiosample ./productpage/chart/productpage

# STEADY STATE - 100 percent traffic prod
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=35,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait cantankerous-swan ./productpage/chart/productpage

# CANARY 10 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=90,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=10 --wait cantankerous-swan ./productpage/chart/productpage

# CANARY 90 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=10,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=90 --wait cantankerous-swan ./productpage/chart/productpage

# CANARY 100 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=0,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=100 --wait cantankerous-swan ./productpage/chart/productpage

# CANARY 100 percent, rolling upgrade of prod deployment
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=39,productionDeployment.weight=0,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=100 --wait cantankerous-swan ./productpage/chart/productpage

# PROD 100 percent
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=39,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=0 --wait cantankerous-swan ./productpage/chart/productpage

# NEW STEADY STATE : PROD 100 percent , 0 replicas of CANARY
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=39,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait cantankerous-swan ./productpage/chart/productpage

# Rollback to previous version (CAN be executed at any state of pipeline)
helm upgrade  --install --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.weight=100,productionDeployment.replicaCount=2,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=35,canaryDeployment.replicaCount=0,canaryDeployment.weight=0 --wait cantankerous-swan ./productpage/chart/productpage


# HELM template to generate Kubernetes resources
helm template --namespace istiosample --values ./productpage/chart/productpage/values.yaml --set productionDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,productionDeployment.image.tag=35,productionDeployment.replicaCount=2,productionDeployment.weight=100,canaryDeployment.image.repository=istiosampleacr.azurecr.io/istiosample/productpage,canaryDeployment.image.tag=39,canaryDeployment.replicaCount=2,canaryDeployment.weight=0  ./productpage/chart/productpage/ > ./helm-template-output_v2.yaml


