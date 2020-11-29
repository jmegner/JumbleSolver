using namespace System.Collections.Generic
$accelerators = [PowerShell].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$accelerators::Add("StringSet","SortedSet[string]")
$accelerators::Add("StringToStrings",'Dictionary[string,StringSet]')

function Main {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Files
    )

    if($Files.Count -eq 0) {
        Write-Output "usage: powershell -executionpolicy bypass -File .\JumbleSolver.ps1 [-Simple] DICT_FILE1 [DICT_FILE2] [...]"
        exit 1
    }

    $sortedToOrigs = New-Object StringToStrings

    Write-Output "Measuring time as we read and process dictionary files..."
    [TimeSpan] $preparationSpan = Measure-Command { Get-Content $Files | AddWord $sortedToOrigs }
    Write-Output "took $($preparationSpan.TotalSeconds) seconds"

    [string] $jumbledWord = ""
    while(($jumbledWord = Read-Host "$").Length -gt 0) {

        $jumbledWord = $jumbledWord.ToLowerInvariant()
        [string] $sortedWord = SortWord $jumbledWord

        $origWords = $null
        if($sortedToOrigs.TryGetValue($sortedWord, [ref] $origWords)) {
            Write-Output ($origWords -join ' ')
        }
        else {
            Write-Output "no anagram in dictionary"
        }
    }

    exit 0
}

function AddWord {
    [CmdletBinding()]
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
            [string] $lowerWord = $origWord.ToLowerInvariant()
            $sortedWord = SortWord $lowerWord
            $otherOrigs = $null

            if(!$SortedToOrigs.TryGetValue($sortedWord, [ref] $otherOrigs)) {
                $otherOrigs = New-Object StringSet
                $SortedToOrigs.Add($sortedWord, $otherOrigs)
            }

            [void] $otherOrigs.Add($lowerWord)
        }
    }
    End {}
}

function SortWord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Word
    )
    return ([char[]]$Word | Sort-Object) -join ''
}

Main @args
