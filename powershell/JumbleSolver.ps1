# I have tried to conform to the most official powershell style guide I know of:
# https://github.com/PoshCode/PowerShellPracticeAndStyle
# this file is overcommented because I am deliberately explaining language features
# to my future self and other people who are not fluent in powershell;

# Here are some things I just find interesting...
#
# how to do your own custom parameter conversion:
# https://rohnspowershellblog.wordpress.com/2017/03/29/custom-parameter-coercion-with-the-argumenttransformationattribute/
#
# understanding powershell automatic type conversion
# https://devblogs.microsoft.com/powershell/understanding-powershells-type-conversion-magic/

using namespace System.Collections.Generic
$accelerators = [PowerShell].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$accelerators::Add("StringSet","SortedSet[string]")
$accelerators::Add("StringToStrings",'Dictionary[string,StringSet]')

# note: normally for specifying dotnet types outside of accelerators, there must be no spaces within the type
# and commas must be escaped with the backtick (`); example on line below...
#$someVar = New-Object System.Collections.Generic.Dictionary[int`,int]

function Main {
    [CmdletBinding()]
    param (
        [Switch]
        $Simple,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Files
    )

    # switch parameters are better than bool parameters:
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.1#switch-parameters

    if($Files.Count -eq 0) {
        Write-Output "usage: powershell -executionpolicy bypass -File .\JumbleSolver.ps1 [-Simple] DICT_FILE1 [DICT_FILE2] [...]"
        Write-Output "alt usage: pwsh -executionpolicy bypass -File .\JumbleSolver.ps1 [-Simple] DICT_FILE1 [DICT_FILE2] [...]"
        exit 1
    }

    $sortedToOrigs = New-Object StringToStrings

    # alternatively, I could have gone with "$sortedToOrigs = @{}" to use
    # powershell's builtin hash table type, which is dotnet's
    # System.Collections.Hashtable, but I chose the verbose Dictionary<K,V> way to have
    # better type safety (not so verbose once you set up type accelerators);
    # hash table reference:
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.1

    Write-Output "Measuring time as we read and process dictionary files..."

    [TimeSpan] $preparationSpan = 0

    if($Silly) {
        # actually slower than the nonsilly way because file operations are not the bottleneck
        $preparationSpan = Measure-Command { AddDictionaryFile $sortedToOrigs $Files }
    }
    else {
        # this takes advantage of pipeline support, which is fastest way I've done it;
        $preparationSpan = Measure-Command { Get-Content $Files | AddWord $sortedToOrigs }

        # this is slower and "simpler" way where AddWord could just take a single
        # (nonarray) string param for the original word;
        #Measure-Command { Get-Content $Files | ForEach-Object { AddWord $sortedToOrigs $_ } }

        # even the fastest way with powershell 7 takes ~20s to process twl06.txt,
        # which is surprisingly slow; I also measured that sorting 100K 9char
        # strings takes ~6.5s which is also surprisingly slow to me;
        # maybe powershell is just slow;
    }

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

# inspired by article on "script authoring considerations", section "processing large files"
# https://docs.microsoft.com/en-us/windows-server/administration/performance-tuning/powershell/script-authoring-considerations#processing-large-files
# however, it actually made things slower because file operations were
# not the bottle neck; looks like computation is the bottleneck and it is better
# to use the pipelining support of AddWord
function AddDictionaryFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [StringToStrings]
        $SortedToOrigs,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $DictionaryPaths
    )
    Begin {}
    Process {
        foreach($path in $DictionaryPaths) {
            try {
                $stream = [System.IO.StreamReader]::new($path)
                while ($line = $stream.ReadLine()) {
                    AddWord $SortedToOrigs $line
                }
            }
            finally {
                $stream.Dispose()
            }
        }
    }
    End {}
}

# for functions that support pipelining, you need one parameter designated as
# accepting pipeline input; you should declare that parameter as an array;
# you'll need to actually specify the three parts of a function (Begin, Process, End);
# when function is part of pipeline, Begin block is executed once, then Process block
# is executed repeatedly for every pipelined item (and the pipelined array parameter will have
# that one item), then End block is executed once.
# note that this function might also be called outside of a pipeline and the "pipelined"
# array parameter will have the entire array you passed it;
# for more reading:
# https://learn-powershell.net/2013/05/07/tips-on-implementing-pipeline-support/
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.1
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

            # "[void]" added so console doesn't have a bunch of True/False output lines;
            # also could have added ">$null" to end; see https://stackoverflow.com/a/5263780
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
    # I also liked "[string]::Join(($word.ToCharArray() | Sort-Object))"
    # from "Conclusion" of this post:
    # https://softwaresalariman.blogspot.com/2007/12/powershell-string-and-char-sort-and.html
    # but I probably liked it because it is a very C# way of doing things;
    # the code below is semi-self-discovered, a tiny bit faster, and may be more powershell-fluent?
    return ([char[]]$Word | Sort-Object) -join ''
}

# END OF FUNCTIONS #############################################################

# we are array splatting: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.1#splatting-with-arrays
Main @args
