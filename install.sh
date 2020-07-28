#!/bin/bash
PROJ_NAME="java-testingv1"
echo "Start installation '$PROJ_NAME'..."

eval $(crc oc-env)

CRC_REGISTRY=default-route-openshift-image-registry.apps-crc.testing
export CRC_REGISTRY

docker login -u kubeadmin -p $(oc whoami -t) $CRC_REGISTRY

DEL_RES="$(oc get project.project.openshift.io/$PROJ_NAME --show-kind --ignore-not-found)"
if [ ${#DEL_RES} != 0 ]; 
then 
   oc delete project $PROJ_NAME

   DEL_RES="$(oc get project.project.openshift.io/$PROJ_NAME --show-kind --ignore-not-found)"
   echo "Waiting for delete project '$PROJ_NAME'..."
   while [ ${#DEL_RES} != 0 ]
   do
       echo "Waiting...";
       sleep 3;
       DEL_RES="$(oc get project.project.openshift.io/$PROJ_NAME --show-kind --ignore-not-found)";
   done && echo "Finish waiting for project deletion.\n";
fi

oc new-project $PROJ_NAME

cd ./javaapp

docker build -t $PROJ_NAME/java_app ./
docker tag $PROJ_NAME/java_app $CRC_REGISTRY/$PROJ_NAME/java_app
docker push $CRC_REGISTRY/$PROJ_NAME/java_app

docker tag fluent/fluent-bit:latest $CRC_REGISTRY/$PROJ_NAME/fluent-bit
docker push $CRC_REGISTRY/$PROJ_NAME/fluent-bit

cd ./../yamls

oc create configmap my-config --from-file=td-agent-bit.conf
oc apply -f Deployment -n $PROJ_NAME
oc apply -f Service -n $PROJ_NAME
oc expose svc/javatestservice -n $PROJ_NAME

echo "Finish"

