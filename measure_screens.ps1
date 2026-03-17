param(
    [string]$Chrome   = "C:/Program Files/Google/Chrome/Application/chrome.exe",
    [int]$Port        = 9222,
    [int]$WaitMs      = 5000,   # ms to wait after navigation for JS to settle
    [int]$ViewW       = 1440,
    [int]$ViewH       = 950
)

$BaseDir  = "C:\Users\user\Desktop\beta_P5_Usability_Check"
$OutCSV   = "$BaseDir\p5_usability_report.csv"
$OutHTML  = "$BaseDir\p5_usability_report.html"
$TempCSV  = "$BaseDir\p5_screen_heights_raw.csv"

# ----------------------------------------------------------------
# ALL 91 page URLs  (same order as the CSV / HTML data array)
# ----------------------------------------------------------------
$pages = @(
 @{url="https://beta.p5js.org/tutorials/intro-to-p5-strands/";             title="p5.strands: Introduction to Shaders"},
 @{url="https://beta.p5js.org/tutorials/typography-20/";                   title="Typography 2.0"},
 @{url="https://beta.p5js.org/tutorials/setting-up-your-environment/";     title="Setting Up Your Environment"},
 @{url="https://beta.p5js.org/tutorials/get-started/";                     title="Get Started"},
 @{url="https://beta.p5js.org/tutorials/variables-and-change/";            title="Variables and Change"},
 @{url="https://beta.p5js.org/tutorials/conditionals-and-interactivity/";  title="Conditionals and Interactivity"},
 @{url="https://beta.p5js.org/tutorials/organizing-code-with-functions/";  title="Organizing Code with Functions"},
 @{url="https://beta.p5js.org/tutorials/repeating-with-loops/";            title="Repeating with Loops"},
 @{url="https://beta.p5js.org/tutorials/data-structure-garden/";           title="Data Structure Garden"},
 @{url="https://beta.p5js.org/tutorials/animating-with-media-objects/";    title="Animating with Media Objects"},
 @{url="https://beta.p5js.org/tutorials/color-gradients/";                 title="Color Gradients"},
 @{url="https://beta.p5js.org/tutorials/custom-shapes-and-smooth-curves/"; title="Custom Shapes and Smooth Curves"},
 @{url="https://beta.p5js.org/tutorials/creating-styling-html/";           title="Creating and Styling HTML"},
 @{url="https://beta.p5js.org/tutorials/loading-and-selecting-fonts/";     title="Loading and Selecting Fonts"},
 @{url="https://beta.p5js.org/tutorials/p5js-with-screen-reader/";         title="How to Use p5.js with a Screen Reader"},
 @{url="https://beta.p5js.org/tutorials/writing-accessible-canvas-descriptions/"; title="Writing Accessible Canvas Descriptions"},
 @{url="https://beta.p5js.org/tutorials/criticalai1-chatting-with-about-code/";   title="Chatting with/about Code"},
 @{url="https://beta.p5js.org/tutorials/criticalai2-prompt-battle/";              title="Critical AI Prompt Battle"},
 @{url="https://beta.p5js.org/tutorials/criticalai3-sentiment-dataset-explorer/"; title="Critical AI Sentiment Dataset Explorer"},
 @{url="https://beta.p5js.org/tutorials/criticalai4-no-ai-chatbot/";              title="Critical AI No-AI Chatbot"},
 @{url="https://beta.p5js.org/tutorials/coordinates-and-transformations/";        title="Coordinates and Transformations"},
 @{url="https://beta.p5js.org/tutorials/custom-geometry/";                        title="Creating Custom Geometry in WebGL"},
 @{url="https://beta.p5js.org/tutorials/lights-camera-materials/";                title="Lights Camera Materials"},
 @{url="https://beta.p5js.org/tutorials/intro-to-glsl/";                          title="Introduction to GLSL"},
 @{url="https://beta.p5js.org/tutorials/layered-rendering-with-framebuffers/";    title="Layered Rendering with Framebuffers"},
 @{url="https://beta.p5js.org/tutorials/optimizing-webgl-sketches/";              title="Optimizing WebGL Sketches"},
 @{url="https://beta.p5js.org/tutorials/field-guide-to-debugging/";               title="Field Guide to Debugging"},
 @{url="https://beta.p5js.org/tutorials/how-to-optimize-your-sketches/";          title="How to Optimize Your Sketches"},
 @{url="https://beta.p5js.org/tutorials/getting-started-with-nodejs/";            title="Getting Started with Node.js"},
 @{url="https://beta.p5js.org/examples/shapes-and-color-shape-primitives/";       title="Shape Primitives"},
 @{url="https://beta.p5js.org/examples/shapes-and-color-color/";                  title="Color"},
 @{url="https://beta.p5js.org/examples/animation-and-variables-drawing-lines/";   title="Drawing Lines"},
 @{url="https://beta.p5js.org/examples/animation-and-variables-animation-with-events/"; title="Animation with Events"},
 @{url="https://beta.p5js.org/examples/animation-and-variables-mobile-device-movement/"; title="Mobile Device Movement"},
 @{url="https://beta.p5js.org/examples/animation-and-variables-conditions/";      title="Conditions"},
 @{url="https://beta.p5js.org/examples/imported-media-words/";                    title="Words"},
 @{url="https://beta.p5js.org/examples/imported-media-copy-image-data/";          title="Copy Image Data"},
 @{url="https://beta.p5js.org/examples/imported-media-alpha-mask/";               title="Alpha Mask"},
 @{url="https://beta.p5js.org/examples/imported-media-image-transparency/";       title="Image Transparency"},
 @{url="https://beta.p5js.org/examples/imported-media-create-audio/";             title="Audio Player"},
 @{url="https://beta.p5js.org/examples/imported-media-video/";                    title="Video Player"},
 @{url="https://beta.p5js.org/examples/imported-media-video-canvas/";             title="Video on Canvas"},
 @{url="https://beta.p5js.org/examples/imported-media-video-capture/";            title="Video Capture"},
 @{url="https://beta.p5js.org/examples/input-elements-image-drop/";               title="Image Drop"},
 @{url="https://beta.p5js.org/examples/input-elements-input-button/";             title="Input and Button"},
 @{url="https://beta.p5js.org/examples/input-elements-dom-form-elements/";        title="Form Elements"},
 @{url="https://beta.p5js.org/examples/transformation-translate/";                title="Translate"},
 @{url="https://beta.p5js.org/examples/transformation-rotate/";                   title="Rotate"},
 @{url="https://beta.p5js.org/examples/transformation-scale/";                    title="Scale"},
 @{url="https://beta.p5js.org/examples/calculating-values-interpolate/";          title="Linear Interpolation"},
 @{url="https://beta.p5js.org/examples/calculating-values-map/";                  title="Map"},
 @{url="https://beta.p5js.org/examples/calculating-values-random/";               title="Random"},
 @{url="https://beta.p5js.org/examples/calculating-values-constrain/";            title="Constrain"},
 @{url="https://beta.p5js.org/examples/calculating-values-clock/";                title="Clock"},
 @{url="https://beta.p5js.org/examples/repetition-color-interpolation/";          title="Color Interpolation"},
 @{url="https://beta.p5js.org/examples/repetition-color-wheel/";                  title="Color Wheel"},
 @{url="https://beta.p5js.org/examples/repetition-bezier/";                       title="Bezier"},
 @{url="https://beta.p5js.org/examples/repetition-kaleidoscope/";                 title="Kaleidoscope"},
 @{url="https://beta.p5js.org/examples/repetition-noise/";                        title="Noise"},
 @{url="https://beta.p5js.org/examples/repetition-recursive-tree/";               title="Recursive Tree"},
 @{url="https://beta.p5js.org/examples/listing-data-with-arrays-random-poetry/";  title="Random Poetry"},
 @{url="https://beta.p5js.org/examples/angles-and-motion-sine-cosine/";           title="Sine and Cosine"},
 @{url="https://beta.p5js.org/examples/angles-and-motion-aim/";                   title="Aim"},
 @{url="https://beta.p5js.org/examples/angles-and-motion-triangle-strip/";        title="Triangle Strip"},
 @{url="https://beta.p5js.org/examples/games-circle-clicker/";                    title="Circle Clicker"},
 @{url="https://beta.p5js.org/examples/games-ping-pong/";                         title="Ping Pong"},
 @{url="https://beta.p5js.org/examples/games-snake/";                             title="Snake"},
 @{url="https://beta.p5js.org/examples/3d-geometries/";                           title="Geometries"},
 @{url="https://beta.p5js.org/examples/3d-custom-geometry/";                      title="Custom Geometry"},
 @{url="https://beta.p5js.org/examples/3d-materials/";                            title="Materials"},
 @{url="https://beta.p5js.org/examples/3d-orbit-control/";                        title="Orbit Control"},
 @{url="https://beta.p5js.org/examples/3d-filter-shader/";                        title="Filter Shader"},
 @{url="https://beta.p5js.org/examples/3d-adjusting-positions-with-a-shader/";    title="Adjusting Positions with a Shader"},
 @{url="https://beta.p5js.org/examples/3d-framebuffer-blur/";                     title="Framebuffer Blur"},
 @{url="https://beta.p5js.org/examples/advanced-canvas-rendering-create-graphics/";       title="Create Graphics"},
 @{url="https://beta.p5js.org/examples/advanced-canvas-rendering-multiple-canvases/";     title="Multiple Canvases"},
 @{url="https://beta.p5js.org/examples/advanced-canvas-rendering-shader-as-a-texture/";   title="Shader as a Texture"},
 @{url="https://beta.p5js.org/examples/classes-and-objects-snowflakes/";                  title="Snowflakes"},
 @{url="https://beta.p5js.org/examples/classes-and-objects-shake-ball-bounce/";           title="Shake Ball Bounce"},
 @{url="https://beta.p5js.org/examples/classes-and-objects-connected-particles/";         title="Connected Particles"},
 @{url="https://beta.p5js.org/examples/classes-and-objects-flocking/";                    title="Flocking"},
 @{url="https://beta.p5js.org/examples/loading-and-saving-data-local-storage/";           title="Local Storage"},
 @{url="https://beta.p5js.org/examples/loading-and-saving-data-json/";                    title="JSON"},
 @{url="https://beta.p5js.org/examples/loading-and-saving-data-table/";                   title="Table"},
 @{url="https://beta.p5js.org/examples/math-and-physics-non-orthogonal-reflection/";      title="Non-Orthogonal Reflection"},
 @{url="https://beta.p5js.org/examples/math-and-physics-soft-body/";                      title="Soft Body"},
 @{url="https://beta.p5js.org/examples/math-and-physics-forces/";                         title="Forces"},
 @{url="https://beta.p5js.org/examples/math-and-physics-smoke-particle-system/";          title="Smoke Particles"},
 @{url="https://beta.p5js.org/examples/math-and-physics-game-of-life/";                   title="Game of Life"},
 @{url="https://beta.p5js.org/examples/math-and-physics-mandelbrot/";                     title="Mandelbrot Set"},
 @{url="https://beta.p5js.org/examples/parallel-loading-promise-async-image-loader/";     title="Async Await with Promise.all"}
)

# ----------------------------------------------------------------
# CDP helpers
# ----------------------------------------------------------------
$script:cmdId = 0

function cdp-send {
    param($ws, [string]$method, [hashtable]$params = @{})
    $script:cmdId++
    $id = $script:cmdId
    $body = @{id=$id; method=$method; params=$params} | ConvertTo-Json -Depth 10 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($body)
    $ws.SendAsync([ArraySegment[byte]]::new($bytes), 'Text', $true,
                  [Threading.CancellationToken]::None).Wait() | Out-Null
    return $id
}

function cdp-recv {
    param($ws, [int]$targetId, [int]$timeoutSec = 20)
    $deadline = [DateTime]::Now.AddSeconds($timeoutSec)
    $buf = [byte[]]::new(524288)   # 512 KB buffer
    while ([DateTime]::Now -lt $deadline) {
        $seg  = [ArraySegment[byte]]::new($buf)
        $task = $ws.ReceiveAsync($seg, [Threading.CancellationToken]::None)
        if ($task.Wait([TimeSpan]::FromMilliseconds(800))) {
            $text = [Text.Encoding]::UTF8.GetString($buf, 0, $task.Result.Count)
            try {
                $obj = $text | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($null -ne $obj -and $null -ne $obj.id -and [int]$obj.id -eq $targetId) {
                    return $obj
                }
            } catch {}
        }
    }
    return $null
}

function Measure-Page {
    param([string]$url)

    # Open a new tab via HTTP
    $tab = Invoke-RestMethod "http://localhost:$Port/json/new" -Method PUT -ErrorAction Stop
    $tabId = $tab.id

    $ws = $null
    try {
        $ws = [Net.WebSockets.ClientWebSocket]::new()
        $ws.ConnectAsync([uri]$tab.webSocketDebuggerUrl,
                         [Threading.CancellationToken]::None).Wait() | Out-Null

        # Set viewport to exactly 1440x950
        $id = cdp-send $ws "Emulation.setDeviceMetricsOverride" @{
            width=1440; height=950; deviceScaleFactor=1; mobile=$false
        }
        cdp-recv $ws $id 5 | Out-Null

        # Navigate
        $id = cdp-send $ws "Page.navigate" @{ url = $url }
        cdp-recv $ws $id 20 | Out-Null

        # Wait for Astro hydration + any lazy-load images
        Start-Sleep -Milliseconds $WaitMs

        # Measure the main content wrapper.
        # Primary:  element matching the Tailwind classes md:mx-lg  mt-md  mx-5
        # Fallback: document.documentElement.scrollHeight
        $js = @'
(() => {
    // Try the specific content wrapper the user identified
    const sel = '.md\\:mx-lg.mt-md.mx-5';
    const el = document.querySelector(sel);
    if (el) {
        const r = el.getBoundingClientRect();
        return { height: Math.round(r.height * 10) / 10, method: 'selector' };
    }
    // Fallback: full document scroll height
    return {
        height: Math.round(document.documentElement.scrollHeight * 10) / 10,
        method: 'documentScrollHeight'
    };
})()
'@
        $id   = cdp-send $ws "Runtime.evaluate" @{ expression=$js; returnByValue=$true; awaitPromise=$false }
        $resp = cdp-recv $ws $id 10

        if ($null -eq $resp) { return $null }
        $inner = $resp.result
        if ($null -eq $inner) { return $null }
        $inner2 = $inner.result
        if ($null -eq $inner2) { return $null }
        $val = $inner2.value
        if ($null -eq $val) { return $null }
        return $val
    }
    catch {
        Write-Warning "  ERROR on $url : $_"
        return $null
    }
    finally {
        if ($null -ne $ws) { $ws.Dispose() }
        Invoke-RestMethod "http://localhost:$Port/json/close/$tabId" -ErrorAction SilentlyContinue | Out-Null
    }
}

# ----------------------------------------------------------------
# Boot Chrome headless
# ----------------------------------------------------------------
Write-Host ""
Write-Host "=== p5.js DOM Screen-Height Measurement ===" -ForegroundColor Cyan
Write-Host "Viewport: ${ViewW}x${ViewH} px   Standard screen height: ${ViewH} px"
Write-Host "Measuring $($pages.Count) pages..."
Write-Host ""

# Kill any stale Chrome debug instances on that port
$staleConn = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($staleConn) {
    $stalePid = $staleConn | Select-Object -ExpandProperty OwningProcess -First 1
    Stop-Process -Id $stalePid -Force -ErrorAction SilentlyContinue
    Start-Sleep 1
}

$chromeProc = Start-Process $Chrome `
    -ArgumentList "--headless=new --remote-debugging-port=$Port --disable-gpu --window-size=${ViewW},${ViewH} --no-first-run --no-default-browser-check --disable-extensions" `
    -PassThru
Start-Sleep -Milliseconds 2500

if (-not (Invoke-RestMethod "http://localhost:$Port/json" -ErrorAction SilentlyContinue)) {
    Write-Error "Chrome didn't start or isn't listening on port $Port"
    exit 1
}

# ----------------------------------------------------------------
# Measure all pages
# ----------------------------------------------------------------
$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$i = 0

foreach ($page in $pages) {
    $i++
    $label = $page.title.PadRight(52).Substring(0,52)
    Write-Host -NoNewline "[$($i.ToString().PadLeft(2))/$($pages.Count)] $label " -ForegroundColor Gray

    $data = Measure-Page $page.url
    $heightPx = $null
    $screens   = $null
    $method    = "failed"

    if ($null -ne $data) {
        $heightPx = $data.height
        $screens  = [Math]::Round($heightPx / $ViewH, 1)
        $method   = $data.method
    }

    $color = if     ($null -eq $screens)   { 'DarkGray' }
             elseif ($screens -gt 12)      { 'Red' }
             elseif ($screens -gt 8)       { 'Yellow' }
             elseif ($screens -gt 4)       { 'Cyan' }
             else                          { 'Green' }

    $screenStr = if ($null -ne $screens) { "${screens} sc (${heightPx}px) [$method]" } else { "FAILED" }
    Write-Host $screenStr -ForegroundColor $color

    $results.Add([PSCustomObject]@{
        Title    = $page.title
        URL      = $page.url
        HeightPx = $heightPx
        Screens  = $screens
        Method   = $method
    })

    Start-Sleep -Milliseconds 300  # brief gap between tabs
}

# ----------------------------------------------------------------
# Stop Chrome
# ----------------------------------------------------------------
$chromeProc | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "Chrome closed." -ForegroundColor DarkGray

# ----------------------------------------------------------------
# Write raw results CSV
# ----------------------------------------------------------------
$results | Export-Csv $TempCSV -NoTypeInformation -Encoding UTF8
Write-Host "Raw heights saved to: $TempCSV" -ForegroundColor Green

# ----------------------------------------------------------------
# Update main CSV  (patch Estimated_Screens column)
# ----------------------------------------------------------------
Write-Host "Updating main CSV..." -ForegroundColor Cyan

$csv = Import-Csv $OutCSV
$heightLookup = @{}
foreach ($r in $results) { $heightLookup[$r.URL.TrimEnd('/')] = $r }

foreach ($row in $csv) {
    $key = $row.URL.TrimEnd('/')
    if ($heightLookup.ContainsKey($key) -and $null -ne $heightLookup[$key].Screens) {
        $row.Estimated_Screens = $heightLookup[$key].Screens
    }
}
# Re-export (preserve all columns, add HeightPx if not present)
$csv | Export-Csv $OutCSV -NoTypeInformation -Encoding UTF8
Write-Host "CSV updated: $OutCSV" -ForegroundColor Green

# ----------------------------------------------------------------
# Summary to console
# ----------------------------------------------------------------
Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
$tuts = $results | Where-Object { $_.URL -like "*/tutorials/*" }
$exs  = $results | Where-Object { $_.URL -like "*/examples/*" }

$tutAvg = if ($tuts) { [Math]::Round(($tuts | Where-Object Screens | Measure-Object Screens -Average).Average, 1) } else { "N/A" }
$exAvg  = if ($exs)  { [Math]::Round(($exs  | Where-Object Screens | Measure-Object Screens -Average).Average, 1) } else { "N/A" }

Write-Host "Tutorials avg: $tutAvg screens"
Write-Host "Examples  avg: $exAvg screens"
Write-Host ""
Write-Host "Top 10 longest pages:" -ForegroundColor Yellow
$results | Where-Object Screens | Sort-Object Screens -Descending | Select-Object -First 10 |
    ForEach-Object { Write-Host ("  {0,5} sc  {1}" -f $_.Screens, $_.Title) }

Write-Host ""
Write-Host "Done! Now run update_html.ps1 to patch the HTML report." -ForegroundColor Green
