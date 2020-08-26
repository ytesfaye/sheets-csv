IMAGE ?= mw/sheets-csv
JENKINS_BUILD ?= test

zip:
	zip -x credentials.json Dockerfile README.md Makefile *tf-code\* *.csv -j -r -X "Archive.zip" * ; \
	mv Archive.zip tf-code/files/

build:
	docker build . -t ${IMAGE}:${JENKINS_BUILD};

entrypoint: build
	@docker run -it --entrypoint "/bin/bash" \
	-e GOOGLE_APPLICATION_CREDENTIALS \
	${IMAGE}:${JENKINS_BUILD} 

execute: build
	@docker run --mount type=bind,source=$(PWD),target=/apps \
	-e GOOGLE_APPLICATION_CREDENTIALS \
	${IMAGE}:${JENKINS_BUILD}

pylint: build
	@docker run -it --entrypoint "/bin/bash" ${IMAGE}:${JENKINS_BUILD} -c "pip install pylint; pylint main.py"  

