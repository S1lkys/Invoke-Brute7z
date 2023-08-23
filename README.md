# Invoke-Brute7z
PowerShell Script to BruteForce 7 Zip password protected files 

Parameters
-SevenZipPath: Path to 7z.exe default "C:\Program Files\7-Zip\7z.exe"#
-$zipFile: Path to zip file
-$minLen: password minimal length default 3
-$minLen: password max length default 3
-$updateInterval: How often the Status on screen should update 0.1-n default 1 - every second. 

```
. .\PowerShell-Zipcracker v2.ps1
Invoke-Brute7z -SevenZipPath "C:\Program Files\7-Zip\7z.exe" -zipFile "C:\Users\mbzra\Dropbox\PC\Desktop\CrackMe.7z" -updateInterval 1 -minLen 2 -maxLen 2
```
