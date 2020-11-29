using namespace System.Collections.Generic
$accelerators = [PowerShell].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$accelerators::Add("SortedStrings","SortedSet[string]")
$accelerators::Add("SortedToOrigs",'Dictionary[string,SortedStrings]')

# note: normally for specifying dotnet types outside of accelerators, there must be no spaces within the type
# and commas must be escaped with the backtick (`); example on line below...
#$someVar = New-Object System.Collections.Generic.Dictionary[int`,int]

function Main {
    [string[]] $files = $args

    if($files.Count -eq 0) {
        Write-Output "usage: JumbleSolver.bat DICT_FILE [DICT_FILE] [...]"
        Write-Output "alt usage: powershell -executionpolicy bypass -File .\JumbleSolver.ps1 DICT_FILE [DICT_FILE] [...]"
        exit 1
    }

    $sortedToOrigs = New-Object SortedToOrigs

    # alternatively, I could have gone with "$sortedToOrigs = @{}" to use
    # powershell's builtin hash table type, which is dotnet's
    # System.Collections.Hashtable, but I chose the verbose dotnet way to have
    # better type safety; hash table reference:
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.1

    # let's do things the powershell way with pipeline-oriented functions (AddWords);
    # also, creating $sortedToOrigs takes ~31s on twl06.txt, which is surprisingly slow;
    # I also measured that sorting 100K small (~9char) strings takes ~6.5s
    # which is surprisingly slow to me.
    Measure-Command { Get-Content $files | AddWords $sortedToOrigs }

    # alternative simpler and slower way using AddWord
    #Get-Content $args | ForEach-Object { AddWord $sortedToOrigs $_ }

    [string] $jumbledWord = ""
    while(($jumbledWord = Read-Host "$").Length -gt 0) {

        $jumbledWord = $jumbledWord.ToLowerInvariant()
        [string] $sortedWord = SortWord $jumbledWord

        $origWords = $null
        if($sortedToOrigs.TryGetValue($sortedWord, [ref] $origWords))
        {
            Write-Output ($origWords -join ' ')
        }
        else
        {
            Write-Output "no anagram in dictionary"
        }
    }

    exit 0
}

function AddWord {
    param
        ( [Parameter(Mandatory)] [SortedToOrigs] $sortedToOrigs
        , [Parameter(Mandatory)] [string] $origWord
        )
    $origWord = $origWord.ToLowerInvariant()
    $sortedWord = Sort-Word $origWord
    $origs = $null

    if(!$sortedToOrigs.TryGetValue($sortedWord, [ref] $origs)) {
        $origs = New-Object SortedStrings
        $sortedToOrigs.Add($sortedWord, $origs)
    }

    # "[void]" added so console doesn't have a bunch of True/False output lines;
    # also could have added ">$null" to end; see https://stackoverflow.com/a/5263780
    [void] $origs.Add($origWord)
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
function AddWords {
    [CmdletBinding()]
    param
        ( [Parameter(Mandatory)] [SortedToOrigs] $sortedToOrigs
        , [Parameter(Mandatory, ValueFromPipeline)] [string[]] $origWords
        )
    Begin {}
    Process {
        foreach ($origWord in $origWords) {
            [string] $lowerWord = $origWord.ToLowerInvariant()
            $sortedWord = SortWord $lowerWord
            $otherOrigs = $null

            if(!$sortedToOrigs.TryGetValue($sortedWord, [ref] $otherOrigs)) {
                $otherOrigs = New-Object SortedStrings
                $sortedToOrigs.Add($sortedWord, $otherOrigs)
            }

            # "[void]" added so console doesn't have a bunch of True/False output lines;
            # also could have added ">$null" to end; see https://stackoverflow.com/a/5263780
            [void] $otherOrigs.Add($lowerWord)
        }
    }
    End {}
}

function SortWord {
    param
        ( [Parameter(Mandatory)] [string] $word
        )
    # I also liked "[string]::Join(($word.ToCharArray() | Sort-Object))"
    # from "Conclusion" of this post:
    # https://softwaresalariman.blogspot.com/2007/12/powershell-string-and-char-sort-and.html
    # but I probably liked it because it is a very C# way of doing things;
    # the code below is semi-self-discovered and may be more powershell-fluent?
    return ([char[]]$word | Sort-Object) -join ''
}

# END OF FUNCTIONS #############################################################

# we are array splatting: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.1#splatting-with-arrays
Main @args



