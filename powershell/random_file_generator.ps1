<#
.SYNOPSIS
    Script to generate a set number of files of a given size filled with random data
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> random_file_generator.ps1
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

param (
    [int]$fileLengthBytes = 1048576,
    [int]$numberOfFiles = 1000,
    [string]$writeDirectory = "C:\temp\random_files",
    [string]$filePrefix = "randomfile"
)

for ($i = 0; $i -lt $numberOfFiles; $i++) {
    $fileName = $writeDirectory + "\" + $filePrefix + ([string]($i+1)).PadLeft(([string]$numberOfFiles).Length,'0')
    $out = new-object byte[] $fileLengthBytes; (new-object Random).NextBytes($out); [IO.File]::WriteAllBytes("$fileName", $out)
}
