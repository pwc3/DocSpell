# DocSpell

This package enables developers to run a spell checker on documentation comments. This is useful when publishing a well-documented library or SDK.

## Command-line interface

The simplest way to run DocSpell is via the Terminal. First clone this repo and open a Terminal in the resulting directory. You can the use `swift run DocSpell` to run the tool. This is the method of invocation used throughout this document.

You can also use [Mint][github:mint] to run DocSpell:

```
$ mint run pwc3/DocSpell
```

### Usage

Specifying the `--help` argument will print usage information:

```
$ swift run DocSpell --help
OVERVIEW: Spell check inline documentation

USAGE: DocSpell <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  swift-package           Runs the spell checker on the specified Swift package.
  xcode-build             Runs the spell checker on an Xcode project.
  individual-files        Runs the spell checker on individual Swift source files.
```

#### Spell checking Swift packages

To check the spelling of a Swift package, use the `swift-package` subcommand.

```
$ swift run DocSpell swift-package --help
OVERVIEW: Runs the spell checker on the specified Swift package.

USAGE: DocSpell swift-package [--name <name>] [--path <path>] [--whitelist <whitelist>] [<arguments> ...]

ARGUMENTS:
  <arguments>             Additional arguments to pass to `swift build`.

OPTIONS:
  -n, --name <name>       Module name. Will use some non-Test module that is part of the package if not specified.
  -p, --path <path>       Path of the directory containing the Package.swift file.
  -w, --whitelist <whitelist>
                          Whitelist file (must have .plist or .json extension).
  -h, --help              Show help information.
```

For example:

```
$ swift run DocSpell swift-package --name DocSpellFramework
```

#### Spell checking Xcode projects

To check the spelling of an Xcode project, use the `xcode-build` subcommand.

```
$ swift run DocSpell xcode-build --help
OVERVIEW: Runs the spell checker on an Xcode project.

USAGE: DocSpell xcode-build [--name <name>] [--path <path>] [--whitelist <whitelist>] [<arguments> ...]

ARGUMENTS:
  <arguments>             The arguments necessary to pass in to `xcodebuild` to build this module.

OPTIONS:
  -n, --name <name>       Module name. Will be parsed from `xcodebuild` output if not specified.
  -p, --path <path>       Path to run `xcodebuild` from.
  -w, --whitelist <whitelist>
                          Whitelist file (must have .plist or .json extension).
  -h, --help              Show help information.
```

For example:

```
$ swift run DocSpell xcode-build --name MyModule -- -workspace MyModule.xcworkspace -scheme MyModule
```

Note the arguments passed to `xcodebuild` are specified after a double-dash `--`.

#### Spell checking individual files

To check the spelling of individual files, use the `individual-files` subcommand.

```
$ swift run DocSpell individual-files --help
OVERVIEW: Runs the spell checker on individual Swift source files.

USAGE: DocSpell individual-files [--whitelist <whitelist>] [<filenames> ...]

ARGUMENTS:
  <filenames>             The files to check.

OPTIONS:
  -w, --whitelist <whitelist>
                          Whitelist file (must have .plist or .json extension).
  -h, --help              Show help information.
```

For example:

```
$ swift run DocSpell individual-files Sources/DocSpellFramework/*.swift
```

### Whitelisted strings

You can whitelist strings that would otherwise be flagged as a misspelling. A whitelist file can be provided via the `-w` or `--whitelist` option. Both JSON and property list files are supported.

An example JSON whitelist;

```
{
    "words": [
        "foo",
        "bar",
        "baz"
    ]
}
```

An example property list whitelist:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>words</key>
	<array>
        <string>foo</string>
        <string>bar</string>
        <string>baz</string>
	</array>
</dict>
</plist>
```

Note that whitelists are not case sensitive.

# Integration


# Limitations



# Technical details

DocSpell is written using [SourceKitten][github:sourcekitten].

[github:mint]: https://github.com/yonaskolb/Mint
[github:sourcekitten]: https://github.com/jpsim/SourceKitten

