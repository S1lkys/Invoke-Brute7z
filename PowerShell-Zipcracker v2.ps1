function Show-AsciiBanner {
    cls
    Write-Host @"
       _______________________
      | How does a duck crack  |
      | a password? One quack  |
      | at a time!             |
      /------------------------
  __
<(o )___   
 ( ._> /  
  ``---'   

---[ 7-Zip Password Cracker by Maximilian Barz & ChatGPT ]---

"@
}

function Invoke-Brute7z {
    param(
        [string]$7zipPath = "C:\Program Files\7-Zip\7z.exe",
        [string]$zipFile = "C:\Users\mbzra\Dropbox\PC\Desktop\CrackMe.7z",
        [int]$minLen = 3,
        [int]$maxLen = 3,
        [int]$updateInterval
    )


# Vars für das Script
$script:attempts =0
$intervalAttempts = 0  # Versuche im aktuellen Intervall
$lastUpdateTime = Get-Date
$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

$intervalStart = Get-Date

# Berechnen Sie die maximale Anzahl von Kombinationen
$maxCombinations = 0
for ($i = $minLen; $i -le $maxLen; $i++) {
    $maxCombinations += [Math]::Pow($chars.Length, $i)
}

function Get-Progress {
    param (
        [char[]]$password
    )

    $totalChars = $chars.Length
    $progress = 0

    for ($i = 0; $i -lt $password.Length; $i++) {
        $charIndex = $chars.IndexOf($password[$i])
        $progress += $charIndex * [Math]::Pow($totalChars, $password.Length - $i - 1)
    }

    # Berechnen Sie den Fortschrittsprozentsatz basierend auf der maximalen Anzahl von Kombinationen
    return $progress / $maxCombinations
}

function Test-ZipPassword {
    param (
        [string]$password
    )

    # Zugriff auf die außerhalb der Funktion deklarierte Variable
    $script:attempts += 1
    $script:intervalAttempts += 1
    $currentTime = Get-Date

    # Überprüfen, ob das Aktualisierungsintervall erreicht ist
   $elapsedTime = ($currentTime - $script:lastUpdate).TotalSeconds
if ($elapsedTime -ge $updateInterval) {
        $progressPercentage = Get-Progress -password $password.ToCharArray()
        $progressBarLength = 30
        $filledLength = [Math]::Round($progressPercentage * $progressBarLength)
        $progressBar = ('#' * $filledLength).PadRight($progressBarLength, ' ')

        Show-AsciiBanner
        Write-Host ("Attempt # $($script:attempts)/${maxCombinations}: '$password' [$progressBar] {0:P2}" -f $progressPercentage)

        $elapsedTime = ($currentTime - $script:intervalStart).TotalSeconds
        $speed = $script:intervalAttempts / $elapsedTime

        Write-Host ("Speed: {0:N2} p/s" -f $speed)

        $script:lastUpdate = $currentTime
        $script:intervalStart = $currentTime
        $script:intervalAttempts = 0
   
    
    }

    $output = & $7zipPath e -p"$password" $zipFile -oC:\temp\testunzip -y 2>&1
    Remove-Item -Path "C:\temp\testunzip\*" -Recurse -Force 2>$null

    # Überprüfen Sie, ob die Ausgabe "Everything is Ok" enthält
    if ($output -like '*Everything is Ok*') {
        return $true
    } else {
        return $false
    }
}

function BruteForce-ZipPassword {
    param (
        [int]$length
    )

    $pass = [char[]]@($chars[0]) * $length
    $lastCharIndex = $length - 1

    do {
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $pass[$lastCharIndex] = $chars[$i]
            $currentPass = -join $pass

            if (Test-ZipPassword -password $currentPass) {
                return $currentPass  # Rückgabe des gefundenen Passworts
            }
        }

        $incremented = $false
        for ($j = $lastCharIndex; $j -ge 0; $j--) {
            if ($pass[$j] -ne $chars[-1]) {
                $pass[$j] = $chars[$chars.IndexOf($pass[$j]) + 1]
                $incremented = $true
                break
            } else {
                $pass[$j] = $chars[0]
            }
        }

        if (-not $incremented) {
            return $null
        }
    } while ($true)
}

$startDate = Get-Date

$foundPassword = $null
for ($len = $minLen; $len -le $maxLen; $len++) {
    $foundPassword = BruteForce-ZipPassword -length $len
    if ($foundPassword) {
        break
    }
}

$endDate = Get-Date

# Ausgabe der Startzeit, Endzeit, Dauer und Gesamtversuche
Write-Host "---------------------------------------------------------------------------------------------"
Write-Host "Start time: $startDate"
Write-Host "End time: $endDate"

$duration = $endDate - $startDate
Write-Host "Duration: $($duration.Days) days $($duration.Hours) hours $($duration.Minutes) minutes $($duration.Seconds) seconds"
Write-Host "Total attempts: $script:attempts"
Write-Host "---------------------------------------------------------------------------------------------"

if ($foundPassword) {
    Write-Host "Password found: $foundPassword"
} else {
    Write-Host "Password not found."
}

}