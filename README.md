[![Build Status](https://travis-ci.org/fromkk/TestSummaries.svg?branch=master)](https://travis-ci.org/fromkk/TestSummaries)

# TestSummaries

`TestSummaries` is able to generate HTML file from `TestSummaries.plist` to `--outputPath` on `Terminal` of osx.

![capture](./Resources/capture.png)

# Install

## from homebrew

in `Terminal`

```sh
brew install fromkk/TestSummaries/testsummaries
```

## from source code

in `Terminal`

```sh
git clone git@github.com:fromkk/TestSummaries.git
cd ./TestSummaries
make install
```

# Usage

```sh
test-summaries [--resultDirectory <resultDirectory>] | [--bundlePath <bundlePath>] --outputPath <outputPath> --outputType <outputType> --imageScale <imageScale> --backgroundColor <backgroundColor> --textColor <textColor>
```

Options | Description
-------|--------------
--resultDirectory | set the directory path that has multiple test results
--bundlePath | set the bundle path for single test result
--outputPath | set the path for output the generated HTML file
--outputType | set output type `HTML` or `PNG`
--imageScale | set write image scale
--backgroundColor | set background color(RGB) e.g. #FFFFFF
--textColor | set text color(RGB) e.g. #000000

