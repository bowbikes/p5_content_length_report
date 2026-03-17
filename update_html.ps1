# update_html.ps1
# Patches p5_usability_report.html with real DOM-measured screen heights
# from p5_screen_heights_raw.csv produced by measure_screens.ps1

$BaseDir = "C:\Users\user\Desktop\beta_P5_Usability_Check"
$RawCSV  = "$BaseDir\p5_screen_heights_raw.csv"
$OutHTML = "$BaseDir\p5_usability_report.html"

# ----------------------------------------------------------------
# 1. Load raw measurements
# ----------------------------------------------------------------
if (-not (Test-Path $RawCSV)) {
    Write-Error "Raw CSV not found: $RawCSV  -- run measure_screens.ps1 first"
    exit 1
}
$raw      = Import-Csv $RawCSV
$measured = $raw | Where-Object { ($_.Screens -ne '') -and ($_.Screens -ne $null) }
Write-Host "Loaded $($measured.Count) measurements from $RawCSV" -ForegroundColor Cyan

# ----------------------------------------------------------------
# 2. Compute summary statistics
# ----------------------------------------------------------------
$tutMeasured = $measured | Where-Object { $_.URL -like "*/tutorials/*" }
$exMeasured  = $measured | Where-Object { $_.URL -like "*/examples/*"  }

$tutScreens = @($tutMeasured | ForEach-Object { [double]$_.Screens })
$exScreens  = @($exMeasured  | ForEach-Object { [double]$_.Screens })

$tutAvg    = [Math]::Round(($tutScreens | Measure-Object -Average).Average, 2)
$exAvg     = [Math]::Round(($exScreens  | Measure-Object -Average).Average, 2)
$tutMax    = [Math]::Round(($tutScreens | Measure-Object -Maximum).Maximum, 1)
$tutMin    = [Math]::Round(($tutScreens | Measure-Object -Minimum).Minimum, 1)
$exMax     = [Math]::Round(($exScreens  | Measure-Object -Maximum).Maximum, 1)
$exMin     = [Math]::Round(($exScreens  | Measure-Object -Minimum).Minimum, 1)
$globalMax = [Math]::Round((($tutScreens + $exScreens) | Measure-Object -Maximum).Maximum, 1)
$globalMin = [Math]::Round((($tutScreens + $exScreens) | Measure-Object -Minimum).Minimum, 1)

function Get-Median {
    param([double[]]$arr)
    $s = $arr | Sort-Object
    $n = $s.Count
    if ($n -eq 0) { return 0 }
    if ($n % 2 -eq 0) { return [Math]::Round(($s[$n/2-1] + $s[$n/2]) / 2, 1) }
    return [Math]::Round($s[($n-1)/2], 1)
}
$tutMedian = Get-Median $tutScreens
$exMedian  = Get-Median $exScreens
$tutAvg1dp = [Math]::Round($tutAvg, 1)
$exAvg1dp  = [Math]::Round($exAvg,  1)

$longestEntry = $measured | Sort-Object { [double]$_.Screens } -Descending | Select-Object -First 1
$longestTitle = $longestEntry.Title
$longestSc    = $longestEntry.Screens

$tutLongCount = @($tutScreens | Where-Object { $_ -gt 8 }).Count
$tTotal = $tutScreens.Count
$eTotal = $exScreens.Count

Write-Host ""
Write-Host "=== Computed Stats ===" -ForegroundColor Cyan
Write-Host "Tutorials: avg=$tutAvg  max=$tutMax  min=$tutMin  median=$tutMedian"
Write-Host "Examples:  avg=$exAvg   max=$exMax   min=$exMin   median=$exMedian"
Write-Host "Global:    max=$globalMax  min=$globalMin"
$lMsg = "Longest page: $longestTitle ($longestSc sc)"
Write-Host $lMsg
Write-Host ""

# ----------------------------------------------------------------
# 3. Distribution buckets
# ----------------------------------------------------------------
# Tutorials: <=3, 3-5, 5-7, 7-9, >9
$tB1 = @($tutScreens | Where-Object { $_ -le 3  }).Count
$tB2 = @($tutScreens | Where-Object { $_ -gt 3  -and $_ -le 5 }).Count
$tB3 = @($tutScreens | Where-Object { $_ -gt 5  -and $_ -le 7 }).Count
$tB4 = @($tutScreens | Where-Object { $_ -gt 7  -and $_ -le 9 }).Count
$tB5 = @($tutScreens | Where-Object { $_ -gt 9  }).Count

# Examples: <=1, 1-2, 2-3, 3-5, >5
$eB1 = @($exScreens | Where-Object { $_ -le 1  }).Count
$eB2 = @($exScreens | Where-Object { $_ -gt 1  -and $_ -le 2 }).Count
$eB3 = @($exScreens | Where-Object { $_ -gt 2  -and $_ -le 3 }).Count
$eB4 = @($exScreens | Where-Object { $_ -gt 3  -and $_ -le 5 }).Count
$eB5 = @($exScreens | Where-Object { $_ -gt 5  }).Count

$tPct1 = [Math]::Round($tB1 / $tTotal * 100, 1)
$tPct2 = [Math]::Round($tB2 / $tTotal * 100, 1)
$tPct3 = [Math]::Round($tB3 / $tTotal * 100, 1)
$tPct4 = [Math]::Round($tB4 / $tTotal * 100, 1)
$tPct5 = [Math]::Round($tB5 / $tTotal * 100, 1)

$ePct1 = [Math]::Round($eB1 / $eTotal * 100, 1)
$ePct2 = [Math]::Round($eB2 / $eTotal * 100, 1)
$ePct3 = [Math]::Round($eB3 / $eTotal * 100, 1)
$ePct4 = [Math]::Round($eB4 / $eTotal * 100, 1)
$ePct5 = [Math]::Round($eB5 / $eTotal * 100, 1)

Write-Host "Tutorial distribution: <=3=$tB1  3-5=$tB2  5-7=$tB3  7-9=$tB4  >9=$tB5"
Write-Host "Example distribution:  <=1=$eB1  1-2=$eB2  2-3=$eB3  3-5=$eB4  >5=$eB5"

# ----------------------------------------------------------------
# 4. Load HTML line-by-line and patch screens: values in pages array
# ----------------------------------------------------------------
Write-Host ""
Write-Host "Patching HTML pages array..." -ForegroundColor Cyan

$lines = [System.IO.File]::ReadAllLines($OutHTML, [Text.Encoding]::UTF8)

$urlToScreens = @{}
foreach ($r in $raw) {
    if (($r.Screens -ne '') -and ($r.Screens -ne $null)) {
        $urlToScreens[$r.URL.TrimEnd('/')] = $r.Screens
    }
}

$patched = 0
for ($i = 0; $i -lt $lines.Length; $i++) {
    foreach ($kvp in $urlToScreens.GetEnumerator()) {
        if ($lines[$i] -match [regex]::Escape($kvp.Key)) {
            $before = $lines[$i]
            $lines[$i] = $lines[$i] -replace 'screens:\d+\.?\d*', "screens:$($kvp.Value)"
            $lines[$i] = $lines[$i] -replace 'note:"Estimated"', 'note:"Measured"'
            if ($lines[$i] -ne $before) { $patched++ }
            break
        }
    }
}
Write-Host "  Patched $patched page entries in JS array" -ForegroundColor Green

# ----------------------------------------------------------------
# 5. Rejoin and bulk-patch the rest of the HTML
# ----------------------------------------------------------------
$html = $lines -join "`n"

# JS maxScreens constants for bar chart scaling
$html = $html -replace "const maxScreens = \d+\.?\d*;(\s+const container = document\.getElementById\('tutorial-bars'\))", "const maxScreens = $tutMax;`$1"
$html = $html -replace "const maxScreens = \d+\.?\d*;(\s+const container = document\.getElementById\('example-bars'\))",  "const maxScreens = $exMax;`$1"

# Stat card: Avg Tutorial Length (orange)
$html = $html -replace '(<div class="value" style="color:var\(--orange\)">)\d+\.?\d*(</div>\s+<div class="label">Avg Tutorial Length)', "`${1}$tutAvg`$2"

# Stat card: Avg Example Length (green)
$html = $html -replace '(<div class="value" style="color:var\(--green\)">)\d+\.?\d*(</div>\s+<div class="label">Avg Example Length)', "`${1}$exAvg`$2"

# Stat card: Longest Page (red value)
$html = $html -replace '(<div class="value" style="color:var\(--red\)">)\d+\.?\d*(</div>\s+<div class="label">Longest Page)', "`${1}$globalMax`$2"

# Stat card: Longest Page sub label
$html = $html -replace '(<div class="label">Longest Page</div>\s+<div class="sub">)[^<]*(</div>)', "`${1}$longestTitle`$2"

# Stat card: Shortest Page (green value before "Shortest Page" label)
$html = $html -replace '(<div class="value" style="color:var\(--green\)">)\d+\.?\d*(</div>\s+<div class="label">Shortest Page)', "`${1}$globalMin`$2"

# Comparison card - Tutorials avg (orange)
$html = $html -replace '(Average length</span><span class="cvalue" style="color:var\(--orange\)">)\d+\.?\d*( screens</span>)', "`${1}$tutAvg`$2"

# Comparison card - Tutorials longest (red)
$html = $html -replace '(Longest page<\\span><span class="cvalue" style="color:var\(--red\)">)\d+\.?\d*( screens</span>)', "`${1}$tutMax`$2"

# Comparison card - Tutorials shortest (green) - first occurrence
$html = $html -replace '(Shortest page<\\span><span class="cvalue" style="color:var\(--green\)">)\d+\.?\d*( screens</span>)', "`${1}$tutMin`$2"

# Comparison card - Examples avg (green) - note: already patched green avg above (Avg Example Length); this is different pattern
$html = $html -replace '(Average length</span><span class="cvalue" style="color:var\(--green\)">)\d+\.?\d*( screens</span>)', "`${1}$exAvg`$2"

# Comparison card - Examples longest (yellow)
$html = $html -replace '(Longest page<\\span><span class="cvalue" style="color:var\(--yellow\)">)\d+\.?\d*( screens</span>)', "`${1}$exMax`$2"

# Comparison card - Examples shortest (green second occurrence) - already done above; check if tut/ex use same color
# tut shortest = green, ex shortest = green too. Both match the same pattern; first replace handles tut, second handles ex.
# Re-run for the second occurrence:
$html = $html -replace '(Shortest page<\\span><span class="cvalue" style="color:var\(--green\)">)\d+\.?\d*( screens</span>)', "`${1}$exMin`$2"

# Verdict box - tutorial avg screens
$html = $html -replace 'avg <span class="highlight">\d+\.?\d* screens</span>, \d+ of 29', "avg <span class=`"highlight`">$tutAvg1dp screens</span>, $tutLongCount of 29"

# Verdict box - examples avg screens
$html = $html -replace '\(avg <span class="highlight">\d+\.?\d* screens</span>\)', "(avg <span class=`"highlight`">$exAvg1dp screens</span>)"

# Tutorial distribution chart bars
$html = $html -replace '(=3 screens</div><div class="bar-track"><div class="bar-fill screens-low" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$tPct1`${2}$tB1`${3}$tB1`$4"
$html = $html -replace '(3 .- 5 screens</div><div class="bar-track"><div class="bar-fill screens-ok" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$tPct2`${2}$tB2`${3}$tB2`$4"
$html = $html -replace '(5 .- 7 screens</div><div class="bar-track"><div class="bar-fill screens-medium" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$tPct3`${2}$tB3`${3}$tB3`$4"
$html = $html -replace '(7 .- 9 screens</div><div class="bar-track"><div class="bar-fill screens-high" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$tPct4`${2}$tB4`${3}$tB4`$4"
$html = $html -replace '(&gt; 9 screens</div><div class="bar-track"><div class="bar-fill screens-critical" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$tPct5`${2}$tB5`${3}$tB5`$4"

# Tutorial distribution footer
$html = $html -replace 'Median: \d+\.?\d* screens . Mean: \d+\.?\d* . Max: \d+\.?\d*(?=</p>\s+</div>\s+<div class="chart-container")', "Median: $tutMedian screens · Mean: $tutAvg1dp · Max: $tutMax"

# Example distribution chart bars
$html = $html -replace '(=1 screen</div><div class="bar-track"><div class="bar-fill screens-low" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$ePct1`${2}$eB1`${3}$eB1`$4"
$html = $html -replace '(1 .- 2 screens</div><div class="bar-track"><div class="bar-fill screens-ok" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$ePct2`${2}$eB2`${3}$eB2`$4"
$html = $html -replace '(2 .- 3 screens</div><div class="bar-track"><div class="bar-fill screens-medium" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$ePct3`${2}$eB3`${3}$eB3`$4"
$html = $html -replace '(3\+ screens</div><div class="bar-track"><div class="bar-fill screens-high" style="width:)\d+\.?\d*(%">)\d*(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$ePct4`${2}$eB4`${3}$eB4`$4"
$html = $html -replace '(&gt; 5 screens</div><div class="bar-track"><div class="bar-fill screens-critical" style="width:)\d+\.?\d*(%">)(</div></div><div class="bar-value">)\d*( pages</div></div>)', "`${1}$ePct5`${2}`${3}$eB5`$4"

# Example distribution footer
$html = $html -replace 'Median: \d+\.?\d* screens . Mean: \d+\.?\d* . Max: \d+\.?\d*(?=</p>\s+</div>\s+</div>\s+</div>\s+</section>)', "Median: $exMedian screens · Mean: $exAvg1dp · Max: $exMax"

# Tutorial chart section subtitle
$html = $html -replace 'Max bar = \d+\.?\d* screens', "Max bar = $tutMax screens"

# Methodology note: update "estimated" to "measured"
$html = $html -replace 'Screen length was <em>estimated</em> using a proxy formula[^<]*', 'Screen length was <em>measured</em> using Chrome DevTools Protocol (CDP) at 1440x950 viewport'
$html = $html -replace 'Proxy formula: \(\(paragraphs.*?\) / 950</li>', 'Selector: <code>.md:mx-lg.mt-md.mx-5</code> via getBoundingClientRect().height; fallback: documentElement.scrollHeight</li>'

# ----------------------------------------------------------------
# 6. Write patched HTML
# ----------------------------------------------------------------
[System.IO.File]::WriteAllText($OutHTML, $html, [Text.Encoding]::UTF8)
Write-Host ""
Write-Host "HTML report updated: $OutHTML" -ForegroundColor Green
Write-Host ""
Write-Host "=== Final Stats (measured) ===" -ForegroundColor Cyan
Write-Host "  Tutorial avg : $tutAvg sc  |  max: $tutMax sc  |  min: $tutMin sc  |  median: $tutMedian sc"
Write-Host "  Example  avg : $exAvg sc   |  max: $exMax sc   |  min: $exMin sc   |  median: $exMedian sc"
Write-Host "  Longest page : $longestTitle  ($longestSc sc)"
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
