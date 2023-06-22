# codesystem action

![Build assets](https://github.com/gofast-pkg/codesystem/actions/workflows/bundle-asset.yml/badge.svg)
![Git action test](https://github.com/gofast-pkg/codesystem/actions/workflows/test-gitaction.yml/badge.svg)
[![Marketplace](https://img.shields.io/badge/git%20action-marketplace-informational?style=flat-square)](https://github.com/marketplace/actions/codesystem)
[![License](http://img.shields.io/badge/license-mit-blue.svg?style=flat-square)](https://raw.githubusercontent.com/gofast-pkg/codesystem/blob/main/LICENSE)

Code system define a set of resources for manage Golang applications and libraries with a common configuration files like Makefile, golangci.yml ...

- `app` folder group all configurations files for the go applications repositories
- `lib` folder group all configurations files for the libs repositories
- `common` folder group all configurations files for the go applications and libs repositories

To have more information about the files, please read the associated [notes](https://github.com/gofast-pkg/codesystem/tree/main/CODESYSTEM.md)

This repository provide theses files and a github action to integrate it in your workflow and check if your configuration files are up to date.

Read the next for Github action details.

## Inputs

### `type`

**Required** The type name repository (`app` or `lib`). Default `"app"`.

### `context`

**Required** The context path to find your files inside the repository. Default `.`

## Outputs

## `valid`

Return `files are verified` if all are up to date.

## Example usage

``` yaml
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: check codesystem files
        uses: gofast-pkg/codesystem@latest
          with:
            type: 'app'
            context: '.'
```

## Install or update

From your repository execute the following command:

``` bash
# For the applications repositories
# if you have already files in your repository, prompt will ask you for replacing
curl -LO https://github.com/gofast-pkg/codesystem/releases/latest/download/app-codesystem.zip && \
unzip -q app-codesystem.zip && \
rm app-codesystem.zip
```

``` bash
# For the libs repositories
# if you have already files in your repository, prompt will ask you for replacing
curl -LO https://github.com/gofast-pkg/codesystem/releases/latest/download/lib-codesystem.zip && \
unzip -q lib-codesystem.zip && \
rm lib-codesystem.zip
```

If you want test which files ares up to date, you can download and run the `entrypoint.sh` localy

``` bash
# For the applications repositories
./entrypoint.sh app .
> check .mockery.yaml
> check Makefile
> check golangci.yaml
> files are verified
```

``` bash
# For the applications repositories
./entrypoint.sh lib .
> check .mockery.yaml
> check Makefile
> check golangci.yaml
> files are verified
```

&nbsp;:grey_exclamation:&nbsp; the zip package will download files and create a folder, don't forget to cleanup

``` bash
rm -rf verified_files
rm lib-codesystem.zip
rm app-codesystem.zip
```

## Contributing

&nbsp;:grey_exclamation:&nbsp; Use issues for everything

- For a small change, just send a PR.
- For bigger changes open an issue for discussion before sending a PR.
- PR should have:
  - Test case
  - Documentation
  - Example (If it makes sense)
- You can also contribute by:
  - Reporting issues
  - Suggesting new features or enhancements
  - Improve/fix documentation

For all changes, please update the CHANGELOG.txt file by replacing the existant content.

Thank you &nbsp;:pray:&nbsp;&nbsp;:+1:&nbsp;

<a href="https://github.com/gofast-pkg/codesystem/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=gofast-pkg/codesystem" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## Licence

[MIT](https://github.com/gofast-pkg/codesystem/blob/main/LICENSE)