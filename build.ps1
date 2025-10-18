$extName = "ChatlogViewer"
$zipName = $extName + '.zip'
$fgPath = 'C:\Users\matte\Fantasy Grounds\extensions\' + $extName + '.ext' 
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}
Set-Alias 7z $7zipPath


Write-Output "Creating ext file"

7z a $zipName '.\src\*'
Move-Item -Path $zipName -Destination $fgPath -Force