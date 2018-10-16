#!/bin/bash

set -euo pipefail

SA=~/.gke_sa.json
HELM_VERSION=2.10.0

function install_dependencies() {
	wget https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz
	tar xvf jx-linux-amd64.tar.gz
	rm jx-linux-amd64.tar.gz

	mkdir -p ~/.jx/bin

	echo "DOWNLOADED JX "

	ls -la ~/.jx/bin

 	wget https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz	
 	tar xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz	
 	rm helm-v${HELM_VERSION}-linux-amd64.tar.gz	
 	mv linux-amd64/helm ~/.jx/bin
	rm -fr linux-amd64
	
	~/.jx/bin/helm init --client-only
}

function configure_environment() {
	echo ${GKE_SA_JSON} > ${SA}
	git config --global --add user.name "${GIT_USER}"
	git config --global --add user.email "${GIT_EMAIL}"
}

function apply() {
	OLDIFS=$IFS
	CLUSTER_COMMAND=""
	IFS=$','
	for ENVIRONMENT in $ENVIRONMENTS; do
		CLUSTER_COMMAND="${CLUSTER_COMMAND} -c ${ENVIRONMENT}"
	done
	IFS=$OLDIFS

	git status

	
	if [[ "${CI_BRANCH}" == "master" ]]; then
		echo "Running master build"
		./jx create terraform --verbose ${CLUSTER_COMMAND} -b --install-dependencies -o ${ORG} --gke-service-account ${SA}
	else
		echo "Running PR build for ${CI_BRANCH}"
		./jx create terraform --verbose ${CLUSTER_COMMAND} -b --install-dependencies -o ${ORG} --gke-service-account ${SA} --skip-terraform-apply --local-organisation-repository .
	fi
}

install_dependencies
configure_environment
apply
