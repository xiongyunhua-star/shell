#!/bin/bash

# UNCOMMENT this line to enable debugging
# set -xv

## Get resources requests and limits per container in a Kubernetes cluster.

HPAOUT=hpa.out
NAMESPACE=--all-namespaces
OUTFILE=hpa.csv
CONFIG='/root/.kube/config'

######### Functions #########

errorExit () {
    echo -e "\nERROR: $1\n"
    exit 1
}





# Test connection to a cluster by kubectl
testConnection () {
    kubectl --kubeconfig ${CONFIG} cluster-info > /dev/null || errorExit "Connection to cluster failed"
}

#获取所有ns的HPA到文件中
getHpaToFile() {
  kubectl get hpa -A > $HPAOUT
}


#改造文件
formatHpa() {
  sed -i 's/, /|/' $HPAOUT
  sed -i '/NAME/d' $HPAOUT
}
#导出最终文件
toCsvFile() {
  awk 'BEGIN {printf "%s","namespace,name,reference,targets,minpods,maxpods,replicas\n"}{printf "%s,%s,%s,%s,%s,%s,%s\n",$1,$2,$3,$4,$5,$6,$7}' $HPAOUT | tee $OUTFILE

}
main () {
    testConnection
    getHpaToFile
    formatHpa
    toCsvFile
}

######### Main #########

main "$@"
#删除临时文件
rm -f $HPAOUT
