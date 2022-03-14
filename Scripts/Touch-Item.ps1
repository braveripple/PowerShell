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
    } elseif ($PSBoundParameters.ContainsKey('Reference')) {
        if (!(Test-Path -LiteralPath $Reference -PathType Any)) {
            throw "failed to get attlibutes of '${Reference}': No such file or directory"
        }
        $referenceFile = Get-Item -LiteralPath $Reference
        $lastWriteTime = $referenceFile.LastWriteTime
        $lastAccessTime = $referenceFile.LastAccessTime
        $creationTime = $referenceFile.CreationTime
    } elseif ($PSBoundParameters.ContainsKey('DateTime')) {
        $lastWriteTime = $DateTime
        $lastAccessTime = $DateTime
        $creationTime = $DateTime
    } else {
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
    $targets = @()
    if ($PSBoundParameters.ContainsKey('Path')) {
        Write-Debug "Path:${Path}"
        $Path | ForEach-Object {
            if (Test-Path -Path $_ -PathType Any) {
                Write-Debug "P:$(${_}) is exist"
                $targets += Convert-Path -Path $_
            } else {
                Write-Debug "P:$(${_}) is not exist"
                $parent = Split-Path -Path $_ -Parent
                $child = Split-Path -Path $_ -Leaf
                if (Test-Path -LiteralPath $parent -PathType Container) {
                    $targets += Join-Path -Path (Convert-Path $parent) -ChildPath $child
                } else {
                    $targets += Join-Path -Path (Get-Location) -ChildPath $child
                }
            }
        }
    }
    else {
        Write-Debug "LiteralPath:${LiteralPath}"
        $LiteralPath | ForEach-Object {
            if (Test-Path -LiteralPath $_ -PathType Any) {
                Write-Debug "LP:$(${_}) is exist."
                $targets += Convert-Path -LiteralPath $_
            } else {
                Write-Debug "LP:$(${_}) is not exist."
                $parent = Split-Path -Path $_ -Parent
                $child = Split-Path -Path $_ -Leaf
                if (Test-Path -LiteralPath $parent -PathType Container) {
                    $targets += Join-Path -Path (Convert-Path $parent) -ChildPath $child
                } else {
                    $targets += Join-Path -Path (Get-Location) -ChildPath $child
                }
            }
        }
    }
    $targets | Foreach-Object {
        if ($PSCmdlet.ShouldProcess($_, 'touch')) {
            If (Test-Path -LiteralPath $_ -PathType Any) {
                $file = (Get-Item -LiteralPath $_)
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
            } else {
                if($NoCreate) {
                } else {
                    $file = New-Item -Path $_ -ItemType File
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
