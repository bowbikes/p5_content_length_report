# restyle_p5.ps1
# Applies the p5.js website visual design system to p5_usability_report.html.
# Light theme, National Park font, p5.js brand colors, black nav/footer.

$BaseDir = "C:\Users\user\Desktop\beta_P5_Usability_Check"
$OutHTML = "$BaseDir\p5_usability_report.html"

Write-Host "Reading HTML..." -ForegroundColor Cyan
$html = [System.IO.File]::ReadAllText($OutHTML, [Text.Encoding]::UTF8)

# ----------------------------------------------------------------
# 1. Replace <style> block with p5.js design system
# ----------------------------------------------------------------
$newCSS = @'
<style>
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400&display=swap');

/* p5.js Design System — Light Theme */
:root {
  --p5-red:     #eb285f;
  --p5-red-dk:  #b20046;
  --p5-yellow:  #dfed33;
  --p5-orange:  #f56a3a;
  --p5-green:   #47b28f;
  --p5-blue:    #1b9ad1;
  --p5-blue-lt: #dbe3f5;

  --bg:       #ffffff;
  --bg-alt:   #f7f7f7;
  --surface:  #ffffff;
  --surface2: #f3f4f6;
  --border:   #e5e5e5;
  --border2:  #d1d5db;
  --text:     #0a0a0a;
  --muted:    #545454;

  /* Semantic aliases used throughout */
  --accent:  var(--p5-red);
  --accent2: var(--p5-orange);
  --green:   var(--p5-green);
  --yellow:  #ca8a04;
  --orange:  var(--p5-orange);
  --red:     var(--p5-red);
  --blue:    var(--p5-blue);
  --purple:  #7c3aed;
  --teal:    var(--p5-green);
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'National Park', 'Plus Jakarta Sans', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
}
a { color: var(--p5-blue); text-decoration: none; }
a:hover { text-decoration: underline; }

/* Layout */
.container { max-width: 1400px; margin: 0 auto; padding: 0 24px; }

/* Header */
header {
  background: #000000;
  border-bottom: 4px solid var(--p5-red);
  padding: 40px 0 32px;
}
.header-inner { display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 16px; }
header h1 { font-size: 1.85rem; font-weight: 800; color: #ffffff; letter-spacing: -0.02em; }
header h1 span { color: var(--p5-red); }
header p { color: #999999; margin-top: 8px; font-size: 0.9rem; }
.header-meta { color: #777777; font-size: 0.82rem; text-align: right; line-height: 1.8; }

/* Nav */
nav { background: #000000; border-bottom: 1px solid #222222; position: sticky; top: 0; z-index: 100; }
nav ul { display: flex; gap: 0; list-style: none; overflow-x: auto; }
nav a { display: block; padding: 12px 16px; color: #999999; font-size: 0.75rem; font-weight: 700;
        white-space: nowrap; border-bottom: 3px solid transparent; transition: all 0.15s;
        text-transform: uppercase; letter-spacing: 0.06em; }
nav a:hover { color: #ffffff; text-decoration: none; border-bottom-color: var(--p5-red); }

/* Sections */
section { padding: 56px 0; border-bottom: 1px solid var(--border); }
section:nth-child(even) { background: var(--bg-alt); }
section:last-child { border-bottom: none; }
.section-title { font-size: 1.5rem; font-weight: 800; margin-bottom: 8px; letter-spacing: -0.02em; }
.section-sub { color: var(--muted); margin-bottom: 28px; font-size: 0.95rem; }

/* Stat cards */
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 32px; }
.stat-card { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 20px 24px; }
.stat-card .value { font-size: 2.2rem; font-weight: 800; line-height: 1.1; }
.stat-card .label { color: var(--muted); font-size: 0.75rem; margin-top: 4px; text-transform: uppercase; letter-spacing: 0.07em; font-weight: 700; }
.stat-card .sub { font-size: 0.75rem; color: var(--muted); margin-top: 6px; }

/* Hypothesis verdict */
.verdict-box { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 24px 28px; margin-bottom: 24px; border-left: 5px solid var(--p5-red); }
.verdict-box h3 { color: var(--p5-red); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.12em; font-weight: 800; margin-bottom: 10px; }
.verdict-box p { font-size: 1.05rem; line-height: 1.75; }
.verdict-box .highlight { color: var(--p5-red); font-weight: 700; }

/* Bar charts */
.chart-container { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 24px; margin-bottom: 24px; }
.chart-title { font-weight: 700; margin-bottom: 18px; font-size: 0.95rem; letter-spacing: -0.01em; }
.bar-row { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
.bar-label { width: 240px; font-size: 0.8rem; color: var(--muted); text-align: right; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex-shrink: 0; }
.bar-label a { color: var(--muted); }
.bar-label a:hover { color: var(--text); }
.bar-track { flex: 1; background: var(--surface2); border-radius: 3px; height: 22px; overflow: hidden; }
.bar-fill { height: 100%; border-radius: 3px; display: flex; align-items: center; padding-left: 8px; font-size: 0.72rem; font-weight: 700; color: #fff; white-space: nowrap; min-width: 30px; transition: width 0.3s; }
.bar-value { width: 56px; font-size: 0.82rem; color: var(--text); text-align: left; flex-shrink: 0; font-weight: 700; }

/* Screen bar colors */
.screens-low      { background: var(--p5-green); }
.screens-ok       { background: var(--p5-blue); }
.screens-medium   { background: #ca8a04; }
.screens-high     { background: var(--p5-orange); }
.screens-critical { background: var(--p5-red); }

/* Legend */
.legend { display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 20px; }
.legend-item { display: flex; align-items: center; gap: 6px; font-size: 0.78rem; color: var(--muted); }
.legend-dot { width: 12px; height: 12px; border-radius: 2px; flex-shrink: 0; }

/* Distribution chart */
.dist-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
.dist-bucket { background: var(--bg-alt); border-radius: 8px; padding: 16px; text-align: center; border: 2px solid var(--border); }
.dist-bucket .count { font-size: 2rem; font-weight: 800; }
.dist-bucket .range { font-size: 0.78rem; color: var(--muted); margin-top: 2px; }
.dist-bucket .desc { font-size: 0.72rem; color: var(--muted); margin-top: 6px; }

/* Table */
.table-controls { display: flex; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; align-items: center; }
.search-box { background: #fff; border: 2px solid var(--border); border-radius: 6px; padding: 8px 14px; color: var(--text); font-size: 0.88rem; width: 260px; font-family: inherit; transition: border-color 0.15s; }
.search-box:focus { outline: none; border-color: var(--p5-red); }
.search-box::placeholder { color: #bbb; }
.filter-btn { background: #fff; border: 2px solid var(--border); border-radius: 6px; padding: 7px 14px; color: var(--muted); font-size: 0.78rem; cursor: pointer; transition: all 0.15s; font-weight: 700; font-family: inherit; text-transform: uppercase; letter-spacing: 0.04em; }
.filter-btn:hover, .filter-btn.active { background: var(--p5-red); border-color: var(--p5-red); color: #fff; }
.table-wrap { overflow-x: auto; border-radius: 8px; border: 2px solid var(--border); }
table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
th { background: #000; padding: 11px 14px; text-align: left; color: #888; font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.08em; border-bottom: 2px solid #000; cursor: pointer; user-select: none; white-space: nowrap; font-family: inherit; font-weight: 700; }
th:hover { color: #fff; }
th .sort-arrow { display: inline-block; margin-left: 4px; opacity: 0.35; }
th.sorted .sort-arrow { opacity: 1; color: var(--p5-yellow); }
td { padding: 10px 14px; border-bottom: 1px solid var(--border); vertical-align: top; background: #fff; }
tr:last-child td { border-bottom: none; }
tr:hover td { background: var(--bg-alt); }
.type-badge { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 0.68rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; }
.type-tutorial { background: #ede9fe; color: #5b21b6; }
.type-example  { background: #d1fae5; color: #065f46; }
.screens-badge { display: inline-block; padding: 3px 9px; border-radius: 5px; font-weight: 800; font-size: 0.85rem; }
.note-scraped  { color: var(--p5-green); font-size: 0.68rem; font-weight: 600; }
.note-estimated{ color: #ca8a04; font-size: 0.68rem; font-weight: 600; }
.note-measured { color: var(--p5-blue); font-size: 0.68rem; font-weight: 600; }
.title-link { color: var(--text); font-weight: 500; }
.title-link:hover { color: var(--p5-red); }
td .themes { color: var(--muted); font-size: 0.72rem; margin-top: 3px; }

/* Functions */
.functions-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.fn-card { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 20px 24px; display: flex; align-items: center; gap: 16px; }
.fn-rank { font-size: 2rem; font-weight: 800; color: var(--border2); line-height: 1; width: 36px; flex-shrink: 0; }
.fn-name { font-family: 'Courier New', Courier, monospace; font-size: 1.05rem; font-weight: 700; color: var(--p5-red); }
.fn-count { font-size: 0.8rem; color: var(--muted); margin-top: 2px; }

/* Major themes */
.themes-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
.theme-card { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 18px 20px; border-left: 4px solid; }
.theme-card h3 { font-size: 0.95rem; font-weight: 700; margin-bottom: 8px; }
.theme-card p { color: var(--muted); font-size: 0.8rem; line-height: 1.5; }
.theme-count { float: right; background: var(--surface2); border-radius: 5px; padding: 2px 8px; font-size: 0.72rem; color: var(--muted); font-weight: 700; border: 1px solid var(--border); }

/* Resources */
.resource-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 10px; }
.resource-item { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.resource-item .url { font-family: 'Courier New', Courier, monospace; font-size: 0.76rem; color: var(--p5-blue); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.resource-item .badge { background: var(--surface2); border-radius: 5px; padding: 2px 8px; font-size: 0.7rem; color: var(--muted); white-space: nowrap; flex-shrink: 0; font-weight: 700; border: 1px solid var(--border); }

/* Site map */
.sitemap { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
.sitemap-section { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 20px; }
.sitemap-section h3 { font-size: 1rem; font-weight: 700; margin-bottom: 12px; color: var(--p5-orange); }
.sitemap-category { margin-bottom: 14px; }
.sitemap-category h4 { font-size: 0.73rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.07em; font-weight: 700; margin-bottom: 6px; border-top: 1px solid var(--border); padding-top: 10px; }
.sitemap-links { list-style: none; }
.sitemap-links li { padding: 3px 0; font-size: 0.8rem; display: flex; justify-content: space-between; align-items: center; }
.sitemap-links li a { color: var(--text); }
.sitemap-links li a:hover { color: var(--p5-red); }
.screens-pill { font-size: 0.68rem; padding: 1px 6px; border-radius: 4px; font-weight: 700; flex-shrink: 0; }

/* Methodology */
.method-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
.method-card { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 18px 20px; }
.method-card h4 { font-size: 0.88rem; font-weight: 700; margin-bottom: 8px; color: var(--p5-orange); }
.method-card p, .method-card ul { color: var(--muted); font-size: 0.8rem; line-height: 1.6; }
.method-card ul { padding-left: 18px; }
code { font-family: 'Courier New', Courier, monospace; background: var(--surface2); padding: 1px 5px; border-radius: 3px; font-size: 0.85em; color: var(--p5-red); border: 1px solid var(--border); }

/* Compare cards */
.compare-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 32px; }
.compare-card { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 24px; }
.compare-card h3 { font-size: 1rem; font-weight: 700; margin-bottom: 16px; }
.compare-stat { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid var(--border); }
.compare-stat:last-child { border-bottom: none; }
.compare-stat .clabel { color: var(--muted); font-size: 0.82rem; }
.compare-stat .cvalue { font-weight: 800; font-size: 0.95rem; }

/* Recommendations */
.rec-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; }
.rec-card { background: #fff; border: 2px solid var(--border); border-radius: 8px; padding: 18px 20px; border-left: 4px solid; }
.rec-card.priority-high   { border-left-color: var(--p5-red); }
.rec-card.priority-medium { border-left-color: var(--p5-orange); }
.rec-card.priority-low    { border-left-color: var(--p5-blue); }
.rec-card .priority-label { font-size: 0.68rem; text-transform: uppercase; letter-spacing: 0.09em; font-weight: 800; margin-bottom: 6px; }
.priority-high   .priority-label { color: var(--p5-red); }
.priority-medium .priority-label { color: var(--p5-orange); }
.priority-low    .priority-label { color: var(--p5-blue); }
.rec-card h4 { font-size: 0.9rem; font-weight: 700; margin-bottom: 8px; }
.rec-card p { color: var(--muted); font-size: 0.8rem; line-height: 1.5; }

/* Footer */
footer { background: #000000; border-top: none; padding: 36px 0; }
footer p { color: #666666; font-size: 0.82rem; }
footer a { color: var(--p5-red); }

/* Tag chips */
.tag { display:inline-block; padding:2px 9px; border-radius:12px; font-size:0.67rem; font-weight:700;
       margin:2px 2px 2px 0; cursor:pointer; border:1px solid transparent; transition:opacity 0.15s; letter-spacing:0.03em; }
.tag:hover { opacity:0.72; }
.tag-filter-bar { display:flex; flex-wrap:wrap; gap:6px; margin-bottom:16px; align-items:center;
                  padding:12px 16px; background:var(--bg-alt); border-radius:8px; border:2px solid var(--border); }
.tag-filter-bar .tf-label { font-size:0.72rem; color:var(--muted); font-weight:800; margin-right:6px;
                             flex-shrink:0; text-transform:uppercase; letter-spacing:0.07em; }
.tag-pill { background:#fff; border:2px solid var(--border); border-radius:14px; padding:4px 12px;
            font-size:0.72rem; color:var(--muted); cursor:pointer; transition:all 0.15s; font-weight:700; font-family:inherit; }
.tag-pill:hover, .tag-pill.active { background:var(--p5-red); border-color:var(--p5-red); color:#fff; }
.tag-pill.clear-btn { background:transparent; border-color:var(--border2); }

/* Tag palette — light colors for light background */
.tc0{background:#dbeafe;color:#1d4ed8;border-color:#bfdbfe}
.tc1{background:#ede9fe;color:#5b21b6;border-color:#ddd6fe}
.tc2{background:#d1fae5;color:#065f46;border-color:#a7f3d0}
.tc3{background:#ffedd5;color:#9a3412;border-color:#fed7aa}
.tc4{background:#fef9c3;color:#713f12;border-color:#fde68a}
.tc5{background:#fee2e2;color:#991b1b;border-color:#fecaca}
.tc6{background:#dcfce7;color:#14532d;border-color:#bbf7d0}
.tc7{background:#fce7f3;color:#831843;border-color:#fbcfe8}

@media (max-width: 900px) {
  .sitemap { grid-template-columns: 1fr; }
  .compare-grid { grid-template-columns: 1fr; }
  .bar-label { width: 160px; }
}
@media (max-width: 600px) {
  header h1 { font-size: 1.3rem; }
  .bar-label { width: 120px; font-size: 0.75rem; }
}
</style>
'@

# Replace the existing <style>…</style> block
$html = $html -replace '(?s)<style>.*?</style>', $newCSS
Write-Host "  CSS replaced" -ForegroundColor Green

# ----------------------------------------------------------------
# 2. Update screenColor() to use p5.js palette
# ----------------------------------------------------------------
$newScreenColor = @'
function screenColor(s, type) {
  if (type === 'Tutorial') {
    if (s < 10)  return '#47b28f';
    if (s < 15)  return '#1b9ad1';
    if (s < 25)  return '#ca8a04';
    if (s < 35)  return '#f56a3a';
    return '#eb285f';
  } else {
    if (s < 2)   return '#47b28f';
    if (s < 3.5) return '#1b9ad1';
    if (s < 5)   return '#ca8a04';
    return '#f56a3a';
  }
}
'@
$html = $html -replace '(?s)function screenColor\(s, type\) \{.*?\}(?=\s*function screenClass)', $newScreenColor
Write-Host "  screenColor() updated" -ForegroundColor Green

# ----------------------------------------------------------------
# 3. Update screenClass() thresholds for real data ranges
# ----------------------------------------------------------------
$newScreenClass = @'
function screenClass(s, type) {
  if (type === 'Tutorial') {
    if (s < 10)  return 'screens-low';
    if (s < 15)  return 'screens-ok';
    if (s < 25)  return 'screens-medium';
    if (s < 35)  return 'screens-high';
    return 'screens-critical';
  } else {
    if (s < 2)   return 'screens-low';
    if (s < 3.5) return 'screens-ok';
    if (s < 5)   return 'screens-medium';
    return 'screens-high';
  }
}
'@
$html = $html -replace '(?s)function screenClass\(s, type\) \{.*?\}(?=\s*//)' , $newScreenClass
Write-Host "  screenClass() updated" -ForegroundColor Green

# ----------------------------------------------------------------
# 4. Update static HTML color inline-styles to use p5 vars
# ----------------------------------------------------------------
# Stat card value colors — map old vars to p5 equivalents
$html = $html -replace 'color:var\(--accent\)'  , 'color:var(--p5-red)'
$html = $html -replace 'color:var\(--accent2\)' , 'color:var(--p5-orange)'
$html = $html -replace 'color:var\(--purple\)'  , 'color:#7c3aed'
$html = $html -replace 'color:var\(--teal\)'    , 'color:var(--p5-green)'

# Chart title colors already handled by the vars above

# ----------------------------------------------------------------
# 5. Update section subtitles that still say "estimated"
# ----------------------------------------------------------------
$html = $html -replace 'estimated scroll length', 'measured scroll length'
$html = $html -replace 'estimated\)', 'measured)'

# ----------------------------------------------------------------
# 6. Update legend colors to match new bar classes
# ----------------------------------------------------------------
# Tutorial legend thresholds changed (old: 4/6/8/10, new: 10/15/25/35)
$html = $html -replace '&lt; 4 screens', '&lt; 10 screens'
$html = $html -replace '4.6 screens', '10.15 screens'
$html = $html -replace '6.8 screens', '15.25 screens'
$html = $html -replace '8.10 screens', '25.35 screens'
$html = $html -replace '&gt; 10 screens', '&gt; 35 screens'

# ----------------------------------------------------------------
# 7. Write result
# ----------------------------------------------------------------
[System.IO.File]::WriteAllText($OutHTML, $html, [Text.Encoding]::UTF8)
Write-Host ""
Write-Host "Done! Styling applied to: $OutHTML" -ForegroundColor Green
