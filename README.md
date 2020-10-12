# CompressDependency

Like a self-extracting zip, but in a .ps1 script!

## Problem

- You run Powershell through a remote execution platform that does not support copying packages
- You run Powershell on machines with no access to package repositories

Under these constraints, you write long .ps1 files, with cut-n-paste code.

One script needs a function from another script? Just copy it, and hope you've got the latest version.

Maintenance is a chore, and you get RSI from scrolling so much in large vertical files.

**No more!**

Now you can fetch dependencies on your own machine and bundle them into a single script. When you run the script on a remote machine, the dependencies are re-inflated into files in the original folder structure.

You can develop modular code. You can use other people's code.

You can stream binaries too... want to use a Sysinternals or GNU tool? Now you can!

## How it works

When you tell `CompressDependency` about the modules and files you want to include, it searches the paths for all the applicable files. It reads them as a byte stream and encodes them in Base64. It wraps the bytes up with the relative filepaths, so that the folder structure can be recreated.

Because we're working with bytes, text files are recreated with the original encoding. It's a byte match. No UTF-16 / BigEndian / CRLF woes.

If your dependency works on the target machine, CompressDependency will not break it.

_Coming soon_

> The following refers to planned functionality

CompressDependency can export these bytestream dependencies in Powershell object notation, so it's literally runnable code. You can have CompressDependency pre-pend a script file of your choice with this data, so that the script file contains its own dependencies.

## Pre-requisites

- Your own machine needs to be running at least Powershell 5.
- The target machine needs to be running at least Powershell 2 on .NET 3.5. Powershell 1 and earlier .NET versions may work, but they are not supported.

## How to get it

To install from the gallery, run

``` powershell
Install-Module CompressDependency
```

Alternatively, download the zipped module from the [Releases](https://github.com/fsackur/CompressDependency/releases) page.

## Usage

``` powershell
# Install the DBATools module on your own machine
Install-Module DBATools

# Stream the DBATools module into a .ps1 file
Compress-Dependency -RequiredModules DBATools -OutputFile script.ps1
```

## How do I get help?

Log an [issue](https://github.com/fsackur/CompressDependency/issues)!
