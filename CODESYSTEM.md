# Codesystem files

The files are separated in 3 groups (app, lib and common).

- `app` folder group all configurations files for the go applications repositories
- `lib` folder group all configurations files for the libs repositories
- `common` folder group all configurations files for the go applications and libs repositories

## app

### Makefile for applications

This makefile support any go command for building application. For example, if you have two command in the cmd folder

``` bash
# architechture repository
cmd/
  app1
  app_tester
```

#### Dynamic rules

Dynamic rules execute a rule for each command in your application repository
for example with the `build` rule

``` bash
# for build all cmd
make build
# for build only one application (app_tester for example)
make build app_tester
```

#### Overriding

If you need override values, rules or just add something, it's better to create a custom Makefile with in following destination `resources/Makefile`. This destination should loaded automaticly. In this way, you could keep the synchronisation with the future version of this repository ;)

#### Usage description

``` bash
Usage of Makefile:
                              -- CI context --

all:                          Run the ci rules
                              call [ci-tool, dep, lint, tests, build]
ci-tool:                      Install the tooling needs for run the project (ci context):
                              - golangci-lint
tool:                         Install tool needs for the development project after calling the ci-tool rule
                              - mockery
                              - swaggo
                              - golang.org/x/tools dependencies
dep:                          Install dependencies
lint:                         Run linter (golangci-lint) on the full code base
                              call ci-tool
tests:                        Run the tests suite
                              call [utest, bench]
utest:                        Run unit tests and generate coverage file
bench:                        Run benchmarks
build:                        Run the build for all commands inside the cmd folder
                              the default GOOS and GOARCH are used.
                              generate the binaries inside a 'bin' folder.
                              the binaries generated should take the name with <cmd_name>-<GOOS>-<GOARCH>
build.%: (dynamic rule)       Run the build for the specific command with 'build.<cmd_name>'
                              <cmd_name> should match with the specific folder name inside the cmd folder
                              check the build rule to have the specific behavior about the build

                              -- Dev context --

update:                       Update the generated resources
                              should generate or update mocks
godoc:                        Run a Go documentation server
swag:                         Generate the openapi for each command inside the cmd folder
                              the command need to have an openapi.go file inside the main context, else the
                              the command should skipped.
                              the process will generate the vendor folder which will removed by the 'clean' rule.
swag.%: (dynamic rule)        Run the swag generation for the specific command with 'swag.<cmd_name>'
                              <cmd_name> should match with the specific folder name inside the cmd folder
                              check the swag rule to have the specific behavior about the swag process

                              -- Other commands --

clean:                        Cleanup the temporary resources
fclean:                       Reset the project to the initial state
                              call [clean]
help:                         List available rules to this project
```

## lib

N/A

### Makefile (lib)

N/A

## common

### .mockery.yaml

Classic configuration

### golangci.yaml

The golangci.yaml is a configuration to have a beautifull and logic code style. It's open to purpose.
No big comments here, the best it to read the [file directly](https://github.com/gofast-pkg/codesystem/tree/main/common/golangci.yaml), all informations on each choice are documented.
