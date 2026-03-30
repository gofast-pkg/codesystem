## Do not edit, override or improve this Makefile with editing the included Makefile
## inside resources/Makefile
# Global variables overridable from the included Makefile
DOC_SERVER=localhost:4242
BIN_FOLDER=bin
IGNORED_FOLDER=.ignore
VENDOR_FOLDER=vendor
COVERAGE_FILE=coverage.txt
TESTREPORT_FILE=test_report.txt
BENCHREPORT_FILE=bench_report.txt
GODOC_PROCESS=godoc_process.txt
LINTER_VERSION=v2.11.4
SWAGGO_VERSION=v2.0.0-rc5
# SWAGGER_SOURCE_DEPENDENCIES allow to include source files that have swaggo/swag annotations
# Values should be start by a comma and should separated by comma
# Example:
# SWAGGER_SOURCE_DEPENDENCIES=,vendor/github.com/gofast-pkg/api,other_dependency
# Define this VAR in your $PATH_INCLUDED_MAKEFILE for override the default value
# and keep the synchronization with the codesystem
SWAGGER_SOURCE_DEPENDENCIES=
MOCKERY_VERSION=v3.7.0
MODULE_NAME := $(shell go list -m)
PKGS := $(shell go list ./... | grep -v mocks)
# CODESYSTEM UPDATER
CODESYSTEM=app-codesystem.zip
CODESYSTEM_CHECKER=codesystem-checker.zip
CODESYSTEM_VERIFIED_FILES=verified_files
CODESYSTEM_CHECKER_SH=cs-checker.sh
# CODESYSTEM_IGNORED_FILES to skip some checks separated by space.
# Example:
# CODESYSTEM_IGNORED_FILES=.mockery.yml .golangci.yml
# Define this VAR in your $PATH_INCLUDED_MAKEFILE for override the default value
# and keep the synchronization with the codesystem
CODESYSTEM_IGNORED_FILES=

# Global colors for output
BLUE=\033[0;34m
BLACK=\033[0;30m
RED=\033[0;31m
CYAN=\033[0;36m
PURPLE=\033[0;35m
YELLOW=\033[0;33m
GREEN=\033[0;32m
# No Color
NC=\033[0m

# Default rule called `make` is invoked alone
# Overridable from the included Makefile
.DEFAULT_GOAL := all

# Custom Makefile rules
PATH_INCLUDED_MAKEFILE=resources/Makefile

# Load the included Makefile if exists
ifneq (,$(wildcard ${PATH_INCLUDED_MAKEFILE}))
	include ${PATH_INCLUDED_MAKEFILE}
endif

## -- CI context --

## Run the ci rules
## call [ci-tool, dep, lint, tests, build]
.PHONY: all
all: ci-tool dep lint tests build

## Install the tooling needs for run the project (ci context):
## - golangci-lint
.PHONY: ci-tool
ci-tool:
	@VERSION=$$(golangci-lint version --short 2>/dev/null); \
	if [ "v$$VERSION" != ${LINTER_VERSION} ]; then \
		curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $$(go env GOPATH)/bin ${LINTER_VERSION}; \
		golangci-lint version; \
	else \
		echo "golangci-lint already installed (current: v$$VERSION, expected: ${LINTER_VERSION})"; \
	fi

## Install tool needs for the development project after calling the ci-tool rule
## - mockery
## - swaggo
## - golang.org/x/tools dependencies
.PHONY: tool
tool:: ci-tool
	@go install golang.org/x/tools/...@latest
	@VERSION=$$(mockery version 2>/dev/null); \
	if [ $$VERSION != ${MOCKERY_VERSION} ]; then \
		go install github.com/vektra/mockery/v3@${MOCKERY_VERSION}; \
		mockery version; \
	else \
		echo "mockery already installed (current: $$VERSION, expected: ${MOCKERY_VERSION})"; \
	fi
	@VERSION=$$(swag --version 2>/dev/null | sed 's/^swag version //'); \
	EXPECTED_VERSION=$$(echo "${SWAGGO_VERSION}" | sed 's/-.*//'); \
	if [ $$VERSION != $$EXPECTED_VERSION ]; then \
		go install github.com/swaggo/swag/v2/cmd/swag@${SWAGGO_VERSION}; \
		swag --version; \
	else \
		echo "swaggo already installed (current: $$VERSION, expected: ${SWAGGO_VERSION})"; \
	fi

## Install dependencies
.PHONY: dep
dep:
	go mod download

## Run linter (golangci-lint) on the full code base
## call ci-tool
.PHONY: lint
lint: ci-tool
	golangci-lint run

## Run the tests suite
## call [utest, bench]
.PHONY: tests
tests: utest bench

## Run unit tests and generate coverage file
.PHONY: utest
utest: --create-tmp-folders
	@echo "tests running ..."
	@go test -v -count=1 -race -coverprofile=${IGNORED_FOLDER}/${COVERAGE_FILE} -covermode=atomic ${PKGS} \
	> ${IGNORED_FOLDER}/${TESTREPORT_FILE} || {	cat ${IGNORED_FOLDER}/${TESTREPORT_FILE} \
	| sed ''/PASS/s//`printf "\033[32mPASS\033[0m"`/'' \
	| sed ''/FAIL/s//`printf "\033[35mFAIL\033[0m"`/'' \
	| sed ''/RUN/s//`printf "\033[36mRUN\033[0m"`/''; exit 1; }
	@echo "tests are a success ! report generated in ${IGNORED_FOLDER}/${COVERAGE_FILE} and ${IGNORED_FOLDER}/${TESTREPORT_FILE}"
	@echo "coverage rate reported: $$(go tool cover -func ${IGNORED_FOLDER}/${COVERAGE_FILE} | grep total: | awk '{print $$3}')"

## Run benchmarks
.PHONY: bench
bench:
	@echo "benchmarks running ..."
	@go test -run "^$$" -benchmem -benchtime 1000x -bench "^(Benchmark).*" ./... \
	> ${IGNORED_FOLDER}/${BENCHREPORT_FILE} || { cat ${IGNORED_FOLDER}/${BENCHREPORT_FILE} \
	| sed ''/PASS/s//`printf "\033[32mPASS\033[0m"`/'' \
	| sed ''/FAIL/s//`printf "\033[35mFAIL\033[0m"`/'' \
	| sed ''/RUN/s//`printf "\033[36mRUN\033[0m"`/''; exit 1; }
	@echo "benchmarks are a success ! report generated in ${IGNORED_FOLDER}/${BENCHREPORT_FILE}"

## Run the build for all commands inside the cmd folder
## the default GOOS and GOARCH are used.
## generate the binaries inside a 'bin' folder.
## the binaries generated should take the name with <cmd_name>-<GOOS>-<GOARCH>
.PHONY: build
build: $(shell ls -d cmd/* | sed -e 's/cmd\//build./')
	@

## Run the build for the specific command with 'build.<cmd_name>'
## <cmd_name> should match with the specific folder name inside the cmd folder
## check the build rule to have the specific behavior about the build
.PHONY: build.%
build.%:
	$(eval APP_NAME := $*)
	$(eval GOOS := $(shell go env GOOS))
	$(eval GOARCH := $(shell go env GOARCH))
	CGO_ENABLED=1 go build -tags static -ldflags "-s -w -X main.appName=${APP_NAME}" \
		-o ${BIN_FOLDER}/${APP_NAME}-${GOOS}-${GOARCH} ./cmd/${APP_NAME}
	@echo "${GREEN}build success" `ls ./${BIN_FOLDER}/${APP_NAME}-${GOOS}-${GOARCH}` "!${NC}"

## -- Dev context --

## Update the generated resources
## should generate or update mocks
## Update the dependencies (go.mod)
## Update codesystem
.PHONY: update
update:: codesystem
	go get -u ./...
	GOMODLOCATION=$$PWD go generate ./...
	mockery

## Run a Go documentation server
.PHONY: godoc
godoc: --create-tmp-folders
	$(eval pid := ${shell nohup godoc -http=${DOC_SERVER} >> /dev/null & echo $$! ; })
	@echo "Server Go doc started at: ${GREEN}http://${DOC_SERVER}/pkg/${MODULE_NAME}${NC}"
	@echo "\tTo turn off serveur execute '${RED}kill ${pid}${NC}'"
	@echo ${pid} >> ${IGNORED_FOLDER}/${GODOC_PROCESS}
	@echo "pid save in ${IGNORED_FOLDER}/${GODOC_PROCESS}"

## Generate the openapi for each command inside the cmd folder
## the command need to have an openapi.go file inside the main context, else the
## the command should skipped.
## the process will generate the vendor folder which will removed by the 'clean' rule.
.PHONY: swag
swag: $(shell ls -d cmd/* | sed -e 's/cmd\//swag./')
	@rm -rf ${VENDOR_FOLDER}

## Run the swag generation for the specific command with 'swag.<cmd_name>'
## <cmd_name> should match with the specific folder name inside the cmd folder
## check the swag rule to have the specific behavior about the swag process
.PHONY: swag.%
swag.%:
	$(eval APP_NAME := $*)
	@go mod vendor
	@if [ -f "cmd/${APP_NAME}/openapi.go" ]; then \
		swag init -o "cmd/${APP_NAME}/docs" -g "openapi.go" \
			--dir cmd/${APP_NAME}${SWAGGER_SOURCE_DEPENDENCIES} ; \
	fi

## -- Other commands --

## Codesystem update.
.PHONY: codesystem
codesystem:
	@curl -LO https://github.com/gofast-pkg/codesystem/releases/latest/download/${CODESYSTEM_CHECKER} && \
	unzip -q ${CODESYSTEM_CHECKER}
	chmod +x ${CODESYSTEM_CHECKER_SH}
	@CODESYSTEM_IGNORED_FILES=${CODESYSTEM_IGNORED_FILES} ./${CODESYSTEM_CHECKER_SH} app . --auto-replace

## Cleanup the temporary resources
.PHONY: clean
clean:
	@if [ -f ${IGNORED_FOLDER}/${GODOC_PROCESS} ]; then \
		echo "${RED}don't forget to close godoc pid: `cat ${IGNORED_FOLDER}/${GODOC_PROCESS}`${NC}"; \
	fi
	rm -rf ${IGNORED_FOLDER}
	rm -rf ${VENDOR_FOLDER}
	rm -f ${CODESYSTEM}
	rm -f ${CODESYSTEM_CHECKER}
	rm -rf ${CODESYSTEM_VERIFIED_FILES}
	rm -f ${CODESYSTEM_CHECKER_SH}

## Reset the project to the initial state
## call [clean]
.PHONY: fclean
fclean: clean
	rm -rf ${BIN_FOLDER}

# Private rules

--create-tmp-folders:
	@if [ ! -d ${IGNORED_FOLDER} ]; then \
		mkdir -p ${IGNORED_FOLDER}; \
	fi

## List available rules to this project
.PHONY: help
help:
# script awk behavior:
#	skip the .Phony rules
#	skip the --private rules
#	detect and record rules
#	detect and record the comment's rules and section delimeter starting by '##' (multi line support)
#	inpired by the topic https://gist.github.com/prwhite/8168133?permalink_comment_id=2749866#gistcomment-2749866
	@for file in $(MAKEFILE_LIST); do \
		printf "\nUsage of $$file:\n\n"; \
		awk -v color="true" 'function print_help(){ \
				if (helpCommand && helpMessage) { \
					if (color == "true") { \
						printf "${CYAN}%-30s${NC}${CYAN}%s${NC}\n", helpCommand, helpMessage; \
						color = "false"; \
					} else { \
						printf "${GREEN}%-30s${NC}${GREEN}%s${NC}\n", helpCommand, helpMessage; \
						color = "true"; \
					} \
				} else if (helpMessage) { \
					printf "${CYAN}\n%-30s${NC}%s\n\n", "", helpMessage; \
				} else if (helpCommand) { \
					printf "${CYAN}%-30s${NC}%s\n", helpCommand, "missing rule description"; \
				} else { \
					return; \
				} \
				helpCommand = ""; \
				helpMessage = ""; \
			} \
			{ \
				if ($$0 ~ /^.PHONY: .*$$/) { \
					; \
				} else if ($$0 ~ /^\-\-[a-zA-Z\-\_0-9.]+:/) { \
					; \
				} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
					helpCommand = substr($$0, 0, index($$0, ":")); \
					print_help(); \
				} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+.\%:/) { \
					helpCommand = substr($$0, 0, index($$0, ":")); \
					helpCommand = sprintf("%s \(dynamic rule\)", helpCommand); \
					print_help(); \
				} else if ($$0 ~ /^##/) { \
					if (helpMessage) { \
						helpMessage = sprintf("%s\n%-30s%s", helpMessage, "", substr($$0, 4)); \
					} else { \
						helpMessage = substr($$0, 4); \
					} \
				} else { \
					print_help(); \
				} \
			}' \
			$$file; \
	done
