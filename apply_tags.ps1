# apply_tags.ps1
# Updates Code_Lines + P5_Function_Count in main CSV,
# generates normalized tags, and injects tag UI into the HTML report.

$BaseDir = "C:\Users\user\Desktop\beta_P5_Usability_Check"
$CodeCSV = "$BaseDir\p5_code_raw.csv"
$MainCSV = "$BaseDir\p5_usability_report.csv"
$OutHTML = "$BaseDir\p5_usability_report.html"

if (-not (Test-Path $CodeCSV)) {
    Write-Error "Code CSV not found: $CodeCSV -- run extract_code.ps1 first"
    exit 1
}

$codeData = Import-Csv $CodeCSV
$mainData = Import-Csv $MainCSV
Write-Host "Loaded $($codeData.Count) code rows, $($mainData.Count) CSV rows" -ForegroundColor Cyan

# ----------------------------------------------------------------
# 1.  Theme -> tag mapping
# ----------------------------------------------------------------
$themeMap = [ordered]@{
    'shader'       = 'shaders'
    'glsl'         = 'shaders'
    'gpu'          = 'shaders'
    'webgl'        = '3D'
    'framebuffer'  = '3D'
    '3d'           = '3D'
    'animation'    = 'animation'
    'motion'       = 'animation'
    'interactiv'   = 'interaction'
    'mouse'        = 'mouse'
    'keyboard'     = 'keyboard'
    'mobile'       = 'mobile'
    'touch'        = 'mobile'
    'device'       = 'mobile'
    'webcam'       = 'webcam'
    'video'        = 'video'
    'audio'        = 'audio'
    'sound'        = 'audio'
    'image'        = 'images'
    'pixel'        = 'images'
    'typograph'    = 'typography'
    'font'         = 'typography'
    'color'        = 'color'
    'gradient'     = 'color'
    'noise'        = 'noise'
    'perlin'       = 'noise'
    'random'       = 'randomness'
    'generativ'    = 'generative'
    'pattern'      = 'generative'
    'recursion'    = 'recursion'
    'recursive'    = 'recursion'
    'fractal'      = 'recursion'
    'physics'      = 'physics'
    'force'        = 'physics'
    'vector'       = 'math'
    'trigonometr'  = 'math'
    'interpolat'   = 'math'
    'math'         = 'math'
    'bezier'       = 'curves'
    'curve'        = 'curves'
    'geometry'     = 'geometry'
    'shape'        = 'geometry'
    'game'         = 'games'
    'simulation'   = 'simulation'
    'particle'     = 'particles'
    'flocking'     = 'particles'
    'class'        = 'OOP'
    'object'       = 'OOP'
    'data'         = 'data'
    'json'         = 'data'
    'csv'          = 'data'
    'storage'      = 'data'
    'async'        = 'async'
    'promise'      = 'async'
    'dom'          = 'DOM'
    'html'         = 'DOM'
    'form'         = 'DOM'
    'accessib'     = 'accessibility'
    'ai'           = 'AI'
    'llm'          = 'AI'
    'chatbot'      = 'AI'
    'sentiment'    = 'AI'
    'node'         = 'Node.js'
    'debug'        = 'debugging'
    'optimiz'      = 'performance'
    'perform'      = 'performance'
    'array'        = 'arrays'
    'loop'         = 'loops'
    'variable'     = 'variables'
    'condition'    = 'conditionals'
    'beginner'     = 'beginner'
    'started'      = 'beginner'
    'intro '       = 'beginner'
    'drawing'      = 'drawing'
    'transform'    = 'transforms'
    'light'        = 'lighting'
    'material'     = 'lighting'
}

# p5.js function -> extra tag (only for functions that signal a topic not obvious from themes)
$fnTagMap = @{
    'shader'           = 'shaders'
    'createShader'     = 'shaders'
    'createFramebuffer'= '3D'
    'orbitControl'     = '3D'
    'box'              = '3D'
    'sphere'           = '3D'
    'ambientLight'     = 'lighting'
    'directionalLight' = 'lighting'
    'specularMaterial' = 'lighting'
    'texture'          = 'lighting'
    'loadImage'        = 'images'
    'loadPixels'       = 'images'
    'createVideo'      = 'video'
    'createCapture'    = 'webcam'
    'createAudio'      = 'audio'
    'loadFont'         = 'typography'
    'bezier'           = 'curves'
    'noise'            = 'noise'
    'createVector'     = 'math'
    'sin'              = 'math'
    'cos'              = 'math'
    'createButton'     = 'DOM'
    'createInput'      = 'DOM'
    'createElement'    = 'DOM'
    'loadJSON'         = 'data'
    'loadTable'        = 'data'
    'storeItem'        = 'data'
    'mousePressed'     = 'mouse'
    'mouseDragged'     = 'mouse'
    'keyPressed'       = 'keyboard'
    'deviceMoved'      = 'mobile'
    'describe'         = 'accessibility'
}

function Get-Tags {
    param([string]$themes, [string]$category, [string]$functions, [string]$type)
    $tagSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $combined = ($themes + ' ' + $category).ToLower()
    foreach ($kv in $themeMap.GetEnumerator()) {
        if ($combined -like "*$($kv.Key)*") { $tagSet.Add($kv.Value) | Out-Null }
    }
    if ($functions -ne '') {
        foreach ($fn in ($functions -split '\|')) {
            if ($fnTagMap.ContainsKey($fn)) { $tagSet.Add($fnTagMap[$fn]) | Out-Null }
        }
    }
    return (($tagSet | Sort-Object Length -Descending | Select-Object -First 6) -join ',')
}

# ----------------------------------------------------------------
# 2.  Update main CSV
# ----------------------------------------------------------------
Write-Host "Updating main CSV..." -ForegroundColor Cyan
$codeLookup = @{}
foreach ($r in $codeData) { $codeLookup[$r.URL.TrimEnd('/')] = $r }

$updatedRows = foreach ($row in $mainData) {
    $key = $row.URL.TrimEnd('/')
    $fns = ''
    if ($codeLookup.ContainsKey($key)) {
        $c = $codeLookup[$key]
        if ([int]$c.CodeLines -gt 0) {
            $row.Code_Lines        = $c.CodeLines
            $row.P5_Function_Count = $c.FnCount
        }
        $fns = $c.Functions
    }
    $tags = Get-Tags $row.Themes $row.Category $fns $row.Type
    $row | Add-Member -NotePropertyName 'Tags'    -NotePropertyValue $tags -Force
    $row | Add-Member -NotePropertyName 'FnList'  -NotePropertyValue $fns  -Force
    $row
}
$updatedRows | Export-Csv $MainCSV -NoTypeInformation -Encoding UTF8
Write-Host "CSV saved" -ForegroundColor Green

# ----------------------------------------------------------------
# 3.  Build tag lookup for HTML injection
# ----------------------------------------------------------------
$tagForUrl = @{}
$fnForUrl  = @{}
$codeForUrl = @{}
$fnCntForUrl = @{}
foreach ($row in $updatedRows) {
    $key = $row.URL.TrimEnd('/')
    $tagForUrl[$key]    = $row.Tags
    $fnForUrl[$key]     = $row.FnList
    $codeForUrl[$key]   = $row.Code_Lines
    $fnCntForUrl[$key]  = $row.P5_Function_Count
}

# ----------------------------------------------------------------
# 4.  Update JS pages array in HTML (line-by-line URL matching)
# ----------------------------------------------------------------
Write-Host "Patching HTML pages array..." -ForegroundColor Cyan
$lines = [System.IO.File]::ReadAllLines($OutHTML, [Text.Encoding]::UTF8)

$patched = 0
for ($i = 0; $i -lt $lines.Length; $i++) {
    foreach ($key in $tagForUrl.Keys) {
        if ($lines[$i] -match [regex]::Escape($key)) {
            $cl  = $codeForUrl[$key]
            $fc  = $fnCntForUrl[$key]
            $fns = ($fnForUrl[$key]  -replace '"', '') -replace "'", ''
            $tgs = ($tagForUrl[$key] -replace '"', '') -replace "'", ''

            if ([int]$cl -gt 0) {
                $lines[$i] = $lines[$i] -replace 'code:\d+', "code:$cl"
                $lines[$i] = $lines[$i] -replace 'fns:\d+',  "fns:$fc"
            }
            # Inject tags and fnList if not already present
            if ($lines[$i] -notmatch 'tags:"') {
                $lines[$i] = $lines[$i] -replace '(,note:"[^"]*")', ",tags:""$tgs"",fnList:""$fns""`$1"
            }
            $patched++
            break
        }
    }
}
Write-Host "  Patched $patched page entries" -ForegroundColor Green

# ----------------------------------------------------------------
# 5.  Add Tags <th> to the table header
# ----------------------------------------------------------------
$lines = $lines | ForEach-Object {
    $_ -replace '(<th>Themes</th>)', '<th onclick="sortTable(7)">Tags <span class="sort-arrow">+</span></th>$1'
}
Write-Host "  Tags column header added" -ForegroundColor Green

# ----------------------------------------------------------------
# 6.  Build tag injection script (pure JS, injected before </body>)
# ----------------------------------------------------------------
$tagScript = @'

<script>
// ============================================================
// TAG ENHANCEMENT — Injected after main script
// ============================================================
(function() {
  var activeTag = null;

  function tagColor(tag) {
    var h = 0;
    for (var i = 0; i < tag.length; i++) { h = (h * 31 + tag.charCodeAt(i)) & 0xffff; }
    return 'tc' + (h % 8);
  }

  function renderTags(tagStr) {
    if (!tagStr) return '';
    return tagStr.split(',').map(function(t) {
      t = t.trim();
      if (!t) return '';
      return '<span class="tag ' + tagColor(t) + '" onclick="window._filterByTag(\'' + t + '\')" title="Filter: ' + t + '">' + t + '</span>';
    }).join('');
  }

  window._filterByTag = function(tag) {
    activeTag = (activeTag === tag) ? null : tag;
    document.querySelectorAll('.tag-pill').forEach(function(p) {
      p.classList.toggle('active', p.dataset.tag === activeTag);
    });
    renderTable();
  };

  window._clearTagFilter = function() {
    activeTag = null;
    document.querySelectorAll('.tag-pill').forEach(function(p) { p.classList.remove('active'); });
    renderTable();
  };

  // Replace renderTable with tag-aware version
  var _orig = renderTable;
  window.renderTable = renderTable = function() {
    var filtered = pages.filter(function(p) {
      var matchType   = filterType === 'all' || p.type === filterType;
      var matchSearch = !searchTerm ||
        p.title.toLowerCase().indexOf(searchTerm) !== -1 ||
        p.cat.toLowerCase().indexOf(searchTerm) !== -1 ||
        (p.themes && p.themes.toLowerCase().indexOf(searchTerm) !== -1) ||
        (p.tags && p.tags.toLowerCase().indexOf(searchTerm) !== -1);
      var matchTag = !activeTag || (p.tags &&
        p.tags.split(',').map(function(t){return t.trim();}).indexOf(activeTag) !== -1);
      return matchType && matchSearch && matchTag;
    });

    filtered.sort(function(a, b) {
      var cols = ['type','cat','title','screens','words','code','fns','tags','themes','note'];
      var key  = cols[sortCol] || 'screens';
      var va = a[key], vb = b[key];
      if (typeof va === 'number') return sortDir * (va - vb);
      return sortDir * String(va || '').localeCompare(String(vb || ''));
    });

    var tbody = document.getElementById('tableBody');
    tbody.innerHTML = '';
    filtered.forEach(function(p) {
      var color = screenColor(p.screens, p.type);
      var nc = p.note === 'Scraped' ? 'note-scraped' : p.note === 'Measured' ? 'note-measured' : 'note-estimated';
      tbody.innerHTML += '<tr>' +
        '<td><span class="type-badge type-' + p.type.toLowerCase() + '">' + p.type + '</span></td>' +
        '<td style="color:var(--muted);font-size:0.8rem">' + p.cat + '</td>' +
        '<td><a href="' + p.url + '" target="_blank" class="title-link">' + p.title + '</a></td>' +
        '<td><span class="screens-badge" style="background:' + color + '20;color:' + color + '">' + p.screens + '</span></td>' +
        '<td>' + p.words.toLocaleString() + '</td>' +
        '<td>' + p.code + '</td>' +
        '<td>' + p.fns + '</td>' +
        '<td>' + renderTags(p.tags) + '</td>' +
        '<td style="font-size:0.75rem;color:var(--muted)">' + (p.themes || '') + '</td>' +
        '<td><span class="' + nc + '">' + p.note + '</span></td>' +
        '</tr>';
    });
    var tc = document.getElementById('tableCount');
    if (tc) tc.textContent = 'Showing ' + filtered.length + ' of ' + pages.length + ' pages';
  };

  // Build and inject tag filter bar
  var allTags = {};
  pages.forEach(function(p) {
    if (!p.tags) return;
    p.tags.split(',').forEach(function(t) {
      t = t.trim();
      if (t) allTags[t] = (allTags[t] || 0) + 1;
    });
  });
  var sorted = Object.keys(allTags).sort();
  var bar = document.createElement('div');
  bar.className = 'tag-filter-bar';
  bar.id = 'tagFilterBar';
  var label = document.createElement('span');
  label.className = 'tf-label';
  label.textContent = 'Filter by tag:';
  bar.appendChild(label);
  sorted.forEach(function(tag) {
    var btn = document.createElement('button');
    btn.className = 'tag-pill';
    btn.dataset.tag = tag;
    btn.onclick = function() { window._filterByTag(tag); };
    btn.innerHTML = tag + ' <span style="opacity:0.55;font-size:0.65rem">(' + allTags[tag] + ')</span>';
    bar.appendChild(btn);
  });
  var clear = document.createElement('button');
  clear.className = 'tag-pill clear-btn';
  clear.textContent = 'clear';
  clear.onclick = window._clearTagFilter;
  bar.appendChild(clear);

  var controls = document.querySelector('.table-controls');
  if (controls) controls.parentNode.insertBefore(bar, controls);

  // Re-render with enhanced version
  renderTable();
})();
</script>
'@

# Inject before </body>
$html = ($lines -join "`n") -replace '</body>', "$tagScript`n</body>"
Write-Host "  Tag script injected before </body>" -ForegroundColor Green

# ----------------------------------------------------------------
# 7.  Write
# ----------------------------------------------------------------
[System.IO.File]::WriteAllText($OutHTML, $html, [Text.Encoding]::UTF8)
Write-Host ""
Write-Host "HTML updated: $OutHTML" -ForegroundColor Green

# ----------------------------------------------------------------
# 8.  Console tag summary
# ----------------------------------------------------------------
Write-Host ""
Write-Host "=== Tag Distribution ===" -ForegroundColor Cyan
$tc = @{}
foreach ($row in $updatedRows) {
    foreach ($t in ($row.Tags -split ',')) {
        $t2 = $t.Trim()
        if ($t2) { $tc[$t2] = ($tc[$t2] -as [int]) + 1 }
    }
}
$tc.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20 | ForEach-Object {
    Write-Host ("  {0,3}  {1}" -f $_.Value, $_.Key)
}
Write-Host ""
Write-Host "Done! Now run restyle_p5.ps1" -ForegroundColor Green
