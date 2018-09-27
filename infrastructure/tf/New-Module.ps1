#!/usr/bin/env pwsh

param([Parameter(Mandatory=$true)][String] $moduleName)

$moduleRoot = "./modules/${moduleName}"

New-Item -Path $moduleRoot -ItemType Directory
New-Item -Path "$moduleRoot/README.md" -ItemType File
New-Item -Path "$moduleRoot/main.tf" -ItemType File
New-Item -Path "$moduleRoot/outputs.tf" -ItemType File
New-Item -Path "$moduleRoot/variables.tf" -ItemType File
