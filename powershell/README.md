To run powershell script without changing execution policy:
`powershell -executionpolicy bypass -File .\JumbleSolver.ps1 [-Idiomatic] [-Fast] DICT_FILE1 [DICT_FILE2] [...]`

To enable running powershell scripts directly, run/double-click
`enable_running_powershell_directly.bat` and then usage simplifies to:
`.\JumbleSolver.ps1 [-Idiomatic] [-Fast] DICT_FILE1 [DICT_FILE2] [...]`

If you invoke JumbleSolver.ps1 from a powershell session, it should
autocomplete/help with the command line arguments.
