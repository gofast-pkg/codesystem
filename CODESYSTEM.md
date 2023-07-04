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

### Makefile (lib)

Same information about [app](#makefile-for-applications) except they are not command building with dynamic rules.

### .github

Provide a powerfull ci to check code quality, test, build source code and release the pkg

#### ci.yml

For the unit tests, this ci use the [codecov service](https://about.codecov.io/) and need to setup your repository to work properly. It seems important for a public repository to give a good coverage.

#### release.yml

The release action, create a new release if the code was merge in the `main branch`. To work, you need keep a `CHANGELOG.md` file in the root repository with this criterias:

- subtitle with double '#' and [semver versionning](https://semver.org/)
- a content release with an unordered list
- replace the content for each release (history is keeping in old release)

Example CHANGELOG.md file:

``` markdown
# CHANGELOG

## v0.0.9

- renaming git actions files
- clean commit(s) repository
- remove useless comments
```

## common

### .mockery.yaml

#### Configuration

``` yaml
# create the mock out of the root package (could to have module_name/mocks/your_mock.go)
inpackage: False
# create mock without the suffix `_test` package name
testonly: False
# create expector for your mocked interface
with-expecter: True
# keep tree of your project to avoid conflict between identical interface name from different subpackage
keeptree: True
# could import mock from an other package
exported: True
```

#### How generate your mocks

The make rule `update` invoque all //go:generate directive. It's better to prefer use this directive to generate your mocks for these benefits:

- custom mock generation for your execptions
- avoid to parse all interfaces from your project
- write in the code your needs explicitly

Example to generate mock for these `Reader` interface:

``` golang
//go:generate mockery --name=Reader --output=mocks --filename=reader.go --outpkg=mocks
type Reader interface {
  // several function prototypes
}
```

this directive should generate your mock with the pathfile `your_module/mocks/reader.go` and keep the package name `mocks`

### golangci.yaml

The golangci.yaml is a configuration to have a beautifull and logic code style. It's open to purpose.
No big comments here, the best it to read the [file directly](https://github.com/gofast-pkg/codesystem/tree/main/common/.golangci.yaml), all informations on each choice are documented.

This setup help you to have a minimum grade of `A` from [Codebeat](https://codebeat.co/) and [Go Report Card](https://goreportcard.com/) !

### Community Standars

You will find inside the common/.github folder the community standars files to have a beautifull open source repository:

- CODE_OF_CONDUCT.md
- CONTRIBUTING.md
- SECURITY.md
- ISSUE_TEMPLATE/bug_report.md - feature_request.md
- PULL_REQUEST_TEMPLATE.md

Licence are not provided because it's defined by your policy
