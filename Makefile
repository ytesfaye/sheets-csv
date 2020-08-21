IMAGE ?= mw/sheets-csv
JENKINS_BUILD ?= test
TEMP ?= '[{"id":"tic-nt-host-project-ece","network":"tic-dev-private-net"}, {"id":"tic-iac-transit-network-7962","network":"tic-dr"}]'

zip:
	zip -x Dockerfile README.md Makefile -j -r -X "Archive.zip" *

build:
	docker build . -t ${IMAGE}:${JENKINS_BUILD};

entrypoint: build
	@docker run -it --entrypoint "/bin/bash" ${IMAGE}:${JENKINS_BUILD} 

execute: build
	@docker run ${IMAGE}:${JENKINS_BUILD}

pylint: build
	@docker run -it --entrypoint "/bin/bash" ${IMAGE}:${JENKINS_BUILD} -c "pip install pylint; pylint sheets.py"  