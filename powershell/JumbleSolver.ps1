﻿# I have tried to conform to the most official powershell style guide I know of:
# https://github.com/PoshCode/PowerShellPracticeAndStyle
# this file is overcommented because I am deliberately explaining language features
# to my future self and other people who are not fluent in powershell;

# My thanks to reddit user bis (https://www.reddit.com/u/bis/) for his help via this reddit discussion:
# https://www.reddit.com/r/PowerShell/comments/k3eua6/jumblesolver_script_surprisingly_slow/

# Here are some things I just find interesting...
#
# how to do your own custom parameter conversion:
# https://rohnspowershellblog.wordpress.com/2017/03/29/custom-parameter-coercion-with-the-argumenttransformationattribute/
#
# understanding powershell automatic type conversion
# https://devblogs.microsoft.com/powershell/understanding-powershells-type-conversion-magic/
#
# powershell functions have powerful parameter processing, but methods are
# simpler and faster:
# https://itnext.io/new-to-powershell-use-classes-ab7b1e6f72ec

using namespace System.Collections.Generic

# putting param here (instead of inside of an explicit helper Main function)
# means that the user gets flag autocomplete inside a powershell session
[CmdletBinding()]
param (
    [Switch]
    $NoPrompt,

    [Switch]
    $Idiomatic,

    [Switch]
    $Fast,

    [Parameter(Mandatory,ValueFromRemainingArguments)]
    [ValidateCount(1,[int]::MaxValue)]
    [string[]]
    $Paths
)

# switch parameters are better than bool parameters:
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.1#switch-parameters

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$accelerators = [PowerShell].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$accelerators::Add("StringToStrings", 'Dictionary[string,SortedSet[string]]')

# begin functions ##############################################################

# note: normally for specifying dotnet types outside of accelerators and
# outside of [] braces, there must be no spaces within the type and commas must
# be escaped with the backtick (`); example on line below...
#$someVar = New-Object System.Collections.Generic.Dictionary[int`,int]

# this is only written to show how removing function calls (AddFile is a
# function call but [array]::Sort and someString.ToCharArray are methods) and
# pipelines makes powershell so much faster (~7s to ~0.2s for twl06.txt)
function AddFile {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [StringToStrings]
        $SortedToOrigs,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $Paths
    )
    foreach($path in $Paths) {
        $stream = [System.IO.StreamReader]::new($path)

        while($origWord = $stream.ReadLine()) {
            $origWord = $origWord.ToLowerInvariant()

            $chars = $origWord.ToCharArray()
            [array]::Sort($chars)
            $sortedWord = [string]::new($chars)

            $otherOrigs = $SortedToOrigs[$sortedWord]

            if($null -eq $otherOrigs) {
                $otherOrigs = [SortedSet[string]]::new()
                $SortedToOrigs[$sortedWord] = $otherOrigs
            }

            [void] $otherOrigs.Add($origWord)
        }

        $stream.Dispose();
    }
}

# for functions that support pipelining, you need one parameter designated as
# accepting pipeline input; you should declare that parameter as an array;
# you'll need to actually specify the three parts of a function (Begin,
# Process, End); when function is part of pipeline, Begin block is executed
# once, then Process block is executed repeatedly for every pipelined item (and
# the pipelined array parameter will have that one item), then End block is
# executed once.
#
# note that this function might also be called outside of a pipeline and the
# "pipelined" array parameter will have the entire array you passed it;
#
# the pipeline parameter being an array is nice so that you can use your
# function 3 ways:
# 1: "SomeSourceOfItems | Func"
# 2: "Func $arrayOfItems"
# 3: "Func $justOneItem"
#
# for more reading:
# https://learn-powershell.net/2013/05/07/tips-on-implementing-pipeline-support/
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.1
function AddWord {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [StringToStrings]
        $SortedToOrigs,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $OrigWords
    )
    Begin {}
    Process {
        foreach ($origWord in $OrigWords) {
            $lowerWord = $origWord.ToLowerInvariant()
            $sortedWord = SortWord $lowerWord

            # doing a "$SortedToOrigs.TryGetValue($sortedWord, [ref] $otherOrigs)"
            # is really slow in PowerShell, probably because of the [ref]
            # feature, so we are avoiding TryGetValue

            $otherOrigs = $SortedToOrigs[$sortedWord]

            if($null -eq $otherOrigs) {
                $otherOrigs = [SortedSet[string]]::new()
                $SortedToOrigs[$sortedWord] = $otherOrigs
            }

            ## "[void]" added so console doesn't have a bunch of True/False output lines;
            ## also could have added ">$null" to end; see https://stackoverflow.com/a/5263780
            [void] $otherOrigs.Add($lowerWord)
        }
    }
    End {}
}

function SortWord {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [string]
        $Word
    )
    # Idiomatic way courtesy of reddit user "bis":
    # -join([char[]]$Word | Sort-Object)
    # 
    # bis also came up with the following, which is way faster,
    # probably because it uses [array]::Sort instead of Sort-Object;
    [char[]] $chars = $Word.ToCharArray()
    [array]::Sort($chars)
    return [string]::new($chars)
}

# end functions ################################################################

# the Fast way and the nonFast-nonIdiomatic way both use
# System.Collections.Generic.Dictionary<K,V> for better type safety; the
# Idiomatic way uses powershell's builtin hash table which is dotnet's
# System.Collections.HashTable

Write-Output "Measuring time as we read and process dictionary files..."
[TimeSpan] $preparationSpan = 0

if($Idiomatic) {
    # this is the idiomatic way, but unfortunately the "Sort-Object
    # -Unique" means all file contents are held in RAM, which I'm trying
    # to avoid across my JumblerSolver implementations, but it is
    # interesting to see an idiomatic one-liner even if it violates that
    # desire; takes ~17s to process twl06.txt
    $preparationSpan = Measure-Command {
        $sortedToOrigs = Get-Content $Paths |
        Sort-Object -Unique |
        Group-Object { -join($_.ToCharArray() | Sort-Object)} -AsHashTable -AsString
    }
}
elseif($Fast) {
    # takes ~0.2s to process twl06.txt and much faster than everything else
    # because it doesn't use pipelines or call functions (methods are fine)
    $sortedToOrigs = [StringToStrings]::new()
    $preparationSpan = Measure-Command { AddFile $sortedToOrigs $Paths}
}
else {
    # this way uses pipelines (and AddWord has explicit pipeline support), which
    # is a neat powershell thing;
    $sortedToOrigs = [StringToStrings]::new()
    $preparationSpan = Measure-Command { Get-Content $Paths | AddWord $sortedToOrigs }

    # below is "simpler" (and >2x slower) way where AddWord could just take a single
    # (nonarray) string param for the original word; note that "ForEach-Object" has
    # "%" as an alias, so it is common to see "%{...}" in powershell;
    #
    #$preparationSpan = Measure-Command { Get-Content $Paths | ForEach-Object { AddWord $sortedToOrigs $_ } }
}

Write-Output "took $($preparationSpan.TotalSeconds) seconds"

if($NoPrompt) {
    exit 0
}

[string] $jumbledWord = ""
while(($jumbledWord = Read-Host "$").Length -gt 0) {

    $jumbledWord = $jumbledWord.ToLowerInvariant()
    [string] $sortedWord = SortWord $jumbledWord

    if($sortedToOrigs.ContainsKey($sortedWord)) {
        Write-Output ($sortedToOrigs[$sortedWord] -join ' ').ToLowerInvariant()
    }
    else {
        Write-Output "no anagram in dictionary"
    }
}

exit 0

