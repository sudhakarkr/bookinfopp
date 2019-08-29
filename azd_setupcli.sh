#!/bin/bash

echo "Login into AKS"
az aks get-credentials -n istioSampleCluster -g istioSampleRG

echo "Setup tiller for Helm, we will discuss about this tool later"
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

#ISTIO_VERSION=1.2.5

#curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.5 sh -

#cd istio-$ISTIO_VERSION
#sudo cp ./bin/istioctl /usr/local/bin/istioctl
#sudo chmod +x /usr/local/bin/istioctl

#helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system

#kubectl get jobs -n istio-system

#GRAFANA_USERNAME=$(echo -n "grafana" | base64)
#GRAFANA_PASSPHRASE=$(echo -n "grAfAnA" | base64)

#apiVersion: v1
#cat <<EOF | kubectl apply -f -
#kind: Secret
#metadata:
#  name: grafana
#  namespace: istio-system
#  labels:
#    app: grafana
#type: Opaque
#data:
#  username: $GRAFANA_USERNAME
#  passphrase: $GRAFANA_PASSPHRASE
#EOF

#KIALI_USERNAME=$(echo -n "kiali" | base64)
#KIALI_PASSPHRASE=$(echo -n "kIalI" | base64)

#cat <<EOF | kubectl apply -f -
#apiVersion: v1
#metadata:
##kind: Secret
#  name: kiali
#  namespace: istio-system
#  labels:
#    app: kiali
#type: Opaque
#data:
#  username: $KIALI_USERNAME
#  passphrase: $KIALI_PASSPHRASE
#EOF

#helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
 # --set global.controlPlaneSecurityEnabled=true \
 # --set mixer.adapters.useAdapterCRDs=false \
 # --set grafana.enabled=true --set grafana.security.enabled=true \
 # --set tracing.enabled=true \
 # --set kiali.enabled=true


