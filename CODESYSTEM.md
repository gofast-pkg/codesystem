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


                              Do not edit, override or improve this Makefile with editing the included Makefile
                              inside resources/Makefile


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
build:                        Build packages

                              -- Dev context --

update:                       Update the generated resources
                              should generate / update the mocks and documentations in markdown format
godoc:                        Run a Go documentation server

                              -- Other commands --

codesystem:                   Codesystem update
codesystem-check:             Codesystem verify
clean:                        Cleanup the temporary resources
fclean:                       Reset the project to the initial state
                              call [clean]
help:                         List available rules to this project
```

## lib

### Makefile (lib)

Same information about [app](#makefile-for-applications) except they are not command building with dynamic rules.

## common

### .mockery.yaml

#### Configuration

``` yaml
all: false
dir: '{{.InterfaceDirRelative}}/mocks'
filename: 'mock_{{.InterfaceName}}.go'
force-file-write: true
formatter: goimports
formatter-options:
  goimports:
    all-errors: false
    comments: true
    format-only: true
    fragment: false
    local-prefix: ""
    tab-indent: true
    tab-width: 8
generate: true
include-auto-generated: false
log-level: info
structname: '{{.Mock}}{{.InterfaceName}}'
pkgname: 'mocks'
recursive: true
require-template-schema-exists: true
template: testify
template-schema: '{{.Template}}.schema.json'
packages:
  .:
    config:
      all: false
```

#### How generate your mocks

The make rule `update` invoque all //go:generate directive and invoke `mockery`.

Example to generate mock for these `Reader` interface:

``` golang
//mockery:generate: true
type Reader interface {
  // several function prototypes
}
```

this directive should generate your mock with the pathfile `your_module/mocks/mock_Reader.go`, in the package name `mocks` and interface Name `MockReader`.

### .github

Provide a powerfull ci to check code quality, test, build source code and release the pkg or the app(s)

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

#### codesystem

codesystem is step for checking if your files are up to date from the last version. If you would skip any file, use the `CODESYSTEM_IGNORED_FILES` environment variable.

[more information](https://github.com/gofast-pkg/codesystem/tree/main/README.md#environment-variable)

codesytem is duplicated in app and in pkg because the options are different.

### .golangci.yml

The golangci.yml is a configuration to have a beautifull and logic code style. It's open to purpose.
No big comments here, the best it to read the [file directly](https://github.com/gofast-pkg/codesystem/tree/main/common/.golangci.yml), all informations on each choice are documented.

This setup help you to have a minimum grade of `A` from [Codebeat](https://codebeat.co/) and [Go Report Card](https://goreportcard.com/) !

### .gitignore

Exclude environment files, binaries, generated files from Make rule(s) ...

Ignore residual stuff for the Go environment.

### Community Standars

You will find inside the common/.github folder the community standars files to have a beautifull open source repository:

- CODE_OF_CONDUCT.md
- CONTRIBUTING.md
- SECURITY.md
- ISSUE_TEMPLATE/bug_report.md - feature_request.md
- PULL_REQUEST_TEMPLATE.md

Licence are not provided because it's defined by your policy
