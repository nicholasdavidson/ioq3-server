-include Makefile.local
IOQ3_IMAGE ?=
AZ_LOCATION ?= uksouth
AZ_RESOURCEGROUP ?= ioq3-server
RCON_PASSWORD ?= $(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n1)
DOCKER ?= docker
.PHONY: docker-build
docker-build: output/q3config_server.cfg
	"$(DOCKER)" build . -t $(IOQ3_IMAGE)

.PHONY: docker-push
docker-push:
	"$(DOCKER)" push $(IOQ3_IMAGE)
	
output/ioq3-azure-arm-parameters.json: az/ioq3-azure-arm-parameters.json.tmpl parameters.json
	cat parameters.json | jq -f az/ioq3-azure-arm-parameters.json.tmpl > $(@) || rm $(@)


output/q3config_server.cfg: cfg/q3config_server.cfg.tmpl Makefile.local
	sed -e 's|//\(seta rconPassword\) "changeme"|\1 "$(RCON_PASSWORD)"|' cfg/q3config_server.cfg.tmpl > $(@) || rm $(@)

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
	@echo Server running on IP:
	az container show --name $(AZ_RESOURCEGROUP) --resource-group $(AZ_RESOURCEGROUP) | jq -r '.ipAddress.ip'

.PHONY: az-destroy
az-destroy:
	az deployment group delete \
	--resource-group $(AZ_RESOURCEGROUP) \
	--name $(AZ_RESOURCEGROUP)-deployment && \
	az group delete --name $(AZ_RESOURCEGROUP)

.PHONY: start-local
local-deploy: docker-build
	"$(DOCKER)" run --rm -d \
	-p 27961:27960/udp \
	--name ioq3-debug $(IOQ3_IMAGE)

.PHONY: local destroy
local-destroy:
	"$(DOCKER)" stop ioq3-debug
