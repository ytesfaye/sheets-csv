IMAGE ?= trav/terraform
JENKINS_BUILD ?= test
FOLDER_MNT ?= tf_code
FOLDERS ?= tf_code
GOOGLE_CREDENTIALS ?= $(< YOUR_FILE)

terraentry:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} --entrypoint "/bin/bash" ${IMAGE}:${JENKINS_BUILD}

terrafmt-check:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} ${IMAGE}:${JENKINS_BUILD} fmt-check

terrafmt:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} ${IMAGE}:${JENKINS_BUILD} fmt

terrainit:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} \
	${IMAGE}:${JENKINS_BUILD} init ${FOLDERS}

terravalidate:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} ${IMAGE}:${JENKINS_BUILD} validate ${FOLDERS}

terraplan:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} \
	-e GOOGLE_CREDENTIALS \
	${IMAGE}:${JENKINS_BUILD} plan \
	"-var-file=terraform.tfvars" ${FOLDERS} 

terraapply:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} \
	-e GOOGLE_CREDENTIALS \
	${IMAGE}:${JENKINS_BUILD} apply \
	"-auto-approve -var-file=terraform.tfvars" ${FOLDERS} 

terradestroy:
	@docker run -it --mount type=bind,source=$(PWD),target=/apps/${FOLDER_MNT} \
	--mount type=bind,source=$(PWD)/.terraformrc,target=/home/terra/.terraformrc \
	-e GOOGLE_CREDENTIALS \
	${IMAGE}:${JENKINS_BUILD} destroy \
	"-auto-approve -var-file=terraform.tfvars" ${FOLDERS}

localpipeline: terrafmt-check terrainit terravalidate terraapply

localplan: terrafmt-check terrainit terravalidate terraplan

validate:
	rm -rf terraform.tfplan; \
	rm -rf terraform.tfplan.json; \
	terraform plan --out=terraform.tfplan -var-file=terraform.tfvars; \
	terraform show -json ./terraform.tfplan > ./terraform.tfplan.json; 
