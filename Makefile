-include Makefile.local
IOQ3_IMAGE := ?=
AZ_LOCATION ?= uksouth
AZ_RESOURCEGROUP ?= ioq3-server

.PHONY: docker-build
docker-build:
	docker build . -t $(IOQ3_IMAGE)

.PHONY: docker-push
docker-push:
	docker push $(IOQ3_IMAGE)
	
output/ioq3-azure-arm-parameters.json: az/ioq3-azure-arm-parameters.json.tmpl parameters.json
	cat parameters.json | jq -f az/ioq3-azure-arm-parameters.json.tmpl > $(@)

.PHONY: create-parameters
create-parameters: output/ioq3-azure-arm-parameters.json

.PHONY: az-deploy
az-deploy: output/ioq3-azure-arm-parameters.json
	az group create --name $(AZ_RESOURCEGROUP) --location $(AZ_LOCATION) && \
	az deployment group create \
	--name $(AZ_RESOURCEGROUP)-deployment \
	--resource-group $(AZ_RESOURCEGROUP) \
	--template-file az/ioq3-azure-arm.json \
	--parameters @output/ioq3-azure-arm-parameters.json

.PHONY: az-destroy
az-destroy:
	az deployment group delete \
	--resource-group $(AZ_RESOURCEGROUP) \
	--name $(AZ_RESOURCEGROUP)-deployment && \
	az group delete --name $(AZ_RESOURCEGROUP)