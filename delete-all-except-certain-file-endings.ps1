Write-Output "Programm gestartet..."

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $ScriptPath

# Definiere die erlaubten Dateiendungen
$AllowedExtensions = @(".exe", ".docx", "ps1")

# Erstelle den Log-Ordner, falls er nicht existiert
$LogDir = Join-Path -Path $ScriptDir -ChildPath "Log"
if (-not (Test-Path -Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory
}

# Hol dir den Startzeitpunkt und formatiere ihn für den Dateinamen
$StartTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = Join-Path -Path $LogDir -ChildPath "Ergebnis_$StartTime.txt"

# Zähler für gelöschte Dateien
$DeletedCount = 0

# Schreibe den Startzeitpunkt in die Log-Datei
Add-Content -Path $LogFile -Value "Programm gestartet: $(Get-Date)"

# Berechne den Zeitpunkt, der 5 Minuten vor jetzt liegt
$FiveMinutesAgo = (Get-Date).AddMinutes(-5)

# Suche alle Dateien im aktuellen Verzeichnis und Unterverzeichnissen
Get-ChildItem -Path $ScriptDir -File -Recurse | ForEach-Object {
    # Verhindere, dass der Log-Ordner und die PowerShell-Datei gelöscht werden
    if ($_.FullName -ne $ScriptPath -and $_.FullName -notlike "$LogDir*" -and $AllowedExtensions -notcontains $_.Extension) {
		# Überprüfe, ob die Datei älter als 5 Minuten ist
        if ($_.LastWriteTime -lt $FiveMinutesAgo) {
            Write-Output "Lösche Datei: $($_.FullName)"
            
            # Schreibe die gelöschte Datei in die Log-Datei
            Add-Content -Path $LogFile -Value "Gelöschte Datei: $($_.FullName) - $(Get-Date)"
            
            # Lösche die Datei
            Remove-Item $_.FullName -Force
            $DeletedCount++
        }
    }
}

# Schreibe die Anzahl der gelöschten Dateien in die Log-Datei
Add-Content -Path $LogFile -Value "Insgesamt gelöschte Dateien: $DeletedCount"

Write-Output "Insgesamt gelöschte Dateien: $DeletedCount"
Write-Output "Programm beendet."

# Schreibe den Endzeitpunkt in die Log-Datei
Add-Content -Path $LogFile -Value "Programm beendet: $(Get-Date)"

