<#PSScriptInfo

.VERSION 1.0

.GUID c6ff2af7-aa1a-464e-be13-090393906847

.AUTHOR braveripple

.COMPANYNAME

.COPYRIGHT © 2022 braveripple

.TAGS touch

.LICENSEURI

.PROJECTURI https://github.com/braveripple/PowerShell

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Version 1.0:  ドキュメントを作成

.PRIVATEDATA

#>

<#
.SYNOPSIS
ファイルのタイムスタンプを変更する

.DESCRIPTION
ファイルの作成日時、更新日時、アクセス日時を更新する。
パラメーターを何も指定しない場合は更新日時とアクセス日時を現在の日時で更新する。
ファイルが存在しない場合はファイルを作成する。
このコマンドレットのパラメーターはGNU版touchを踏襲している。

.PARAMETER Path
.PARAMETER LiteralPath
.PARAMETER NoCreate
ファイルが存在しない場合、ファイルを作成しない。
.PARAMETER Reference
指定したファイルの日時を使ってファイルのタイムスタンプを変更する。
.PARAMETER AccessTimeUpdate
アクセス日時を変更する。
.PARAMETER WriteTimeUpdate
更新日時を変更する。
.PARAMETER CreationTimeUpdate
作成日時を変更する。
.PARAMETER DateTime
指定したDateTimeオブジェクトの日時を使ってファイルのタイムスタンプを変更する

.EXAMPLE
Touch-Item.ps1 test.txt
'test.txt'のアクセス日時と更新日時を現在時刻で更新する。
'test.txt'が存在しない場合はファイルを作成する。

.EXAMPLE
Touch-Item.ps1 test.txt -DateTime (Get-Date "2020/03/14 11:22:33")
'test.txt'のアクセス日時と更新日時を"2020/03/14 11:22:33"で更新する。
'test.txt'が存在しない場合はファイルを作成する。

.EXAMPLE
Touch-Item.ps1 test.txt -Reference test2.txt
'test.txt'のアクセス日時と更新日時を'test2.txt'のアクセス日時と更新日時で更新する。
'test.txt'が存在しない場合はファイルを作成する。

#>

[CmdletBinding(
    SupportsShouldProcess,
    DefaultParameterSetName = 'Path'
)]
param (
    [SupportsWildCards()]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'Path',
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]$Path,

    [Alias('LP')]
    [Alias('PSPath')]
    [Parameter(Mandatory = $True, Position = 0, ParameterSetName = 'LiteralPath',
        ValueFromPipeline = $False, ValueFromPipelineByPropertyName = $True)]
    [string[]]$LiteralPath,

    [Parameter()]
    [switch]$NoCreate,

    [Parameter()]
    [string]$Reference,

    [Parameter()]
    [switch]$AccessTimeUpdate,

    [Alias('ModifyTimeUpdate')]
    [Parameter()]
    [switch]$WriteTimeUpdate,

    [Parameter()]
    [switch]$CreationTimeUpdate,

    [Alias('Timestamp')]
    [Parameter()]
    [datetime]$DateTime
)
begin {
    if ($PSBoundParameters.ContainsKey('Reference') -and $PSBoundParameters.ContainsKey('DateTime')) {
        throw "cannot specify times from more than one source"
    }
    elseif ($PSBoundParameters.ContainsKey('Reference')) {
        if (!(Test-Path -LiteralPath $Reference -PathType Any)) {
            throw "failed to get attlibutes of '${Reference}': No such file or directory"
        }
        $referenceFile = Get-Item -LiteralPath $Reference
        $lastWriteTime = $referenceFile.LastWriteTime
        $lastAccessTime = $referenceFile.LastAccessTime
        $creationTime = $referenceFile.CreationTime
    }
    elseif ($PSBoundParameters.ContainsKey('DateTime')) {
        $lastWriteTime = $DateTime
        $lastAccessTime = $DateTime
        $creationTime = $DateTime
    }
    else {
        $timestamp = Get-Date
        $lastWriteTime = $timestamp
        $lastAccessTime = $timestamp
        $creationTime = $timestamp
    }

    if ((!$AccessTimeUpdate) -and (!$WriteTimeUpdate) -and (!$CreationTimeUpdate)) {
        $AccessTimeUpdate = $True
        $WriteTimeUpdate = $True
    }

    if ($AccessTimeUpdate) {
        Write-Debug "AccessTimeUpdate:$($lastAccessTime.ToString('yyyy/MM/dd HH:mm:ss'))"
    }
    if ($WriteTimeUpdate) {
        Write-Debug "WriteTimeUpdate:$($lastWriteTime.ToString('yyyy/MM/dd HH:mm:ss'))"
    }
    if ($CreationTimeUpdate) {
        Write-Debug "CreationTimeUpdate:$($creationTime.ToString('yyyy/MM/dd HH:mm:ss'))"
    }

}
process {
    $InputPath = if ($PSBoundParameters.ContainsKey('Path')) { $Path } else { $LiteralPath }
    foreach ($p in $InputPath) {
        $targets = @()
        try {
            if ($PSBoundParameters.ContainsKey('Path')) {
                $targets = Convert-Path -Path $p -ErrorAction Stop
            }
            else {
                $targets = Convert-Path -LiteralPath $p -ErrorAction Stop
            }
        } catch [System.Management.Automation.ItemNotFoundException] {
            # itemが見つからない場合は新規ファイルを作成するため、絶対パスに変換する
            $parent = Split-Path -Path $p -Parent
            $child = Split-Path -Path $p -Leaf
            if (Test-Path -LiteralPath $parent -PathType Container) {
                $targets += Join-Path -Path (Convert-Path $parent) -ChildPath $child
            }
            else {
                $targets += Join-Path -Path (Get-Location) -ChildPath $child
            }
        } catch {
            Write-Error $_.Exception.Message -ErrorAction Continue
            if ($ErrorActionPreference -eq "Stop") {
                return
            }
        }
        foreach ($target in $targets) {
            if (Test-Path -LiteralPath $target -PathType Any) {
                $file = Get-Item -LiteralPath $target
                $operation = "Change {0} Timestamp" -f $(if($file){ "File" }else{ "Directory" })
            } else {
                if ($NoCreate) {
                    $operation = "Do Nothing (because -NoCreate is enabled)"
                } else {
                    $operation = "Create File And Change Timestamp"
                }
            }
            if ($PSCmdlet.ShouldProcess($target, $operation)) {
                If (Test-Path -LiteralPath $target -PathType Any) {
                    $file = (Get-Item -LiteralPath $target)
                    if ($AccessTimeUpdate) {
                        $file.LastAccessTime = $lastAccessTime
                    }
                    if ($WriteTimeUpdate) {
                        $file.LastWriteTime = $lastWriteTime
                    }
                    if ($CreationTimeUpdate) {
                        $file.CreationTime = $creationTime
                    }
                    $file
                }
                else {
                    if ($NoCreate) {
                    }
                    else {
                        $file = New-Item -Path $target -ItemType File
                        if ($AccessTimeUpdate) {
                            $file.LastAccessTime = $lastAccessTime
                        }
                        if ($WriteTimeUpdate) {
                            $file.LastWriteTime = $lastWriteTime
                        }
                        if ($CreationTimeUpdate) {
                            $file.CreationTime = $creationTime
                        }
                        $file
                    }
                }
            }
        }
    }
}
