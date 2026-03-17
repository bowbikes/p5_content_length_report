# extract_code.ps1
# Uses Chrome CDP to extract rendered code from each page,
# count lines, and detect p5.js function calls.
# Output: p5_code_raw.csv

param(
    [string]$Chrome  = "C:/Program Files/Google/Chrome/Application/chrome.exe",
    [int]$Port       = 9222,
    [int]$WaitMs     = 6000,
    [int]$ViewW      = 1440,
    [int]$ViewH      = 950
)

$BaseDir = "C:\Users\user\Desktop\beta_P5_Usability_Check"
$OutCSV  = "$BaseDir\p5_code_raw.csv"

# ----------------------------------------------------------------
# Pages (same order as main CSV)
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
    $buf = [byte[]]::new(2097152)   # 2 MB buffer for large code payloads
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

# ----------------------------------------------------------------
# The JavaScript injected into each page
# ----------------------------------------------------------------
$extractJS = @'
(() => {
    // Try selectors from most to least specific for code blocks
    var sels = [
        'pre.astro-code',
        'pre[data-language]',
        '.cm-content',
        '.CodeMirror-code',
        'pre code',
        'code[class*="language-"]',
        '.hljs',
        'pre'
    ];

    var codeBlocks = [];
    var usedSel = 'none';

    for (var si = 0; si < sels.length; si++) {
        var els = document.querySelectorAll(sels[si]);
        if (els.length > 0) {
            for (var ei = 0; ei < els.length; ei++) {
                var t = els[ei].innerText || els[ei].textContent || '';
                if (t.trim().length > 10) { codeBlocks.push(t); }
            }
            if (codeBlocks.length > 0) { usedSel = sels[si] + '(' + els.length + ')'; break; }
        }
    }

    var allCode = codeBlocks.join('\n');
    var codeLines = allCode.split('\n').filter(function(l){ return l.trim().length > 0; }).length;

    // p5.js function list
    var p5fns = [
        'setup','draw','createCanvas','background','fill','noFill','stroke','noStroke','strokeWeight',
        'ellipse','circle','rect','square','line','point','arc','triangle','quad',
        'bezier','bezierVertex','curveVertex','vertex','beginShape','endShape','contour','curve',
        'push','pop','translate','rotate','scale','shearX','shearY','applyMatrix','resetMatrix',
        'mouseX','mouseY','pmouseX','pmouseY','mouseIsPressed',
        'mousePressed','mouseReleased','mouseClicked','mouseMoved','mouseDragged','mouseWheel',
        'keyPressed','keyReleased','keyTyped','key','keyCode','keyIsDown',
        'touchStarted','touchMoved','touchEnded','touches',
        'deviceMoved','deviceTurned','deviceShaken','accelerationX','accelerationY','accelerationZ',
        'text','textSize','textFont','textAlign','textLeading','textStyle','textWidth','textBounds',
        'loadImage','image','imageMode','tint','noTint','copy','filter','get','set','loadPixels','updatePixels',
        'loadFont','loadModel','model',
        'color','colorMode','lerpColor','red','green','blue','alpha','hue','saturation','brightness',
        'map','constrain','lerp','norm','dist','abs','ceil','floor','round','min','max','sq','sqrt',
        'pow','exp','log','random','randomGaussian','randomSeed','noise','noiseDetail','noiseSeed',
        'sin','cos','tan','asin','acos','atan','atan2','degrees','radians','angleMode',
        'width','height','frameRate','frameCount','millis','deltaTime','loop','noLoop','redraw',
        'second','minute','hour','day','month','year',
        'createGraphics','blendMode','createFramebuffer','drawingContext','clear',
        'loadJSON','loadStrings','loadTable','loadXML','loadBytes','httpGet','httpPost',
        'saveJSON','saveTable','saveStrings','saveCanvas','save','saveFrames',
        'createButton','createInput','createSelect','createSlider','createCheckbox',
        'createElement','select','selectAll','removeElements','createDiv','createP','createSpan',
        'createImg','createA','createVideo','createCapture','createAudio','createFileInput',
        'shader','createShader','resetShader',
        'box','sphere','cone','cylinder','torus','plane','buildGeometry',
        'ambientLight','directionalLight','pointLight','spotLight',
        'ambientMaterial','normalMaterial','emissiveMaterial','specularMaterial','shininess','texture',
        'textureMode','textureWrap','specularColor',
        'camera','perspective','ortho','frustum','createCamera','setCamera','orbitControl',
        'debugMode','noDebugMode',
        'createVector','p5.Vector',
        'print','nf','nfc','nfp','nfs','join','split','splitTokens','trim',
        'append','concat','reverse','shorten','shuffle','sort','splice','subset',
        'storeItem','getItem','clearStorage','removeItem',
        'describe','describeElement','gridOutput','textOutput'
    ];

    var foundFns = [];
    for (var fi = 0; fi < p5fns.length; fi++) {
        var fn = p5fns[fi];
        var escaped = fn.replace('.', '\\.');
        // Match function call or property access but not inside another word
        var re = new RegExp('(?:^|[^a-zA-Z0-9_$])' + escaped + '\\s*[\\.(\\[]', 'm');
        if (re.test(allCode)) { foundFns.push(fn); }
    }

    // Grab all visible text headings for topic analysis
    var hEls = document.querySelectorAll('h1,h2,h3');
    var headings = [];
    for (var hi = 0; hi < hEls.length && hi < 8; hi++) {
        var ht = (hEls[hi].innerText || hEls[hi].textContent || '').trim();
        if (ht.length > 1) { headings.push(ht); }
    }

    return {
        codeLines: codeLines,
        blockCount: codeBlocks.length,
        functions: foundFns.join('|'),
        fnCount: foundFns.length,
        selector: usedSel,
        headings: headings.join(' | ')
    };
})()
'@

# ----------------------------------------------------------------
# Per-page extraction function
# ----------------------------------------------------------------
function Extract-Page {
    param([string]$url)

    $tab   = Invoke-RestMethod "http://localhost:$Port/json/new" -Method PUT -ErrorAction Stop
    $tabId = $tab.id
    $ws    = $null

    try {
        $ws = [Net.WebSockets.ClientWebSocket]::new()
        $ws.ConnectAsync([uri]$tab.webSocketDebuggerUrl,
                         [Threading.CancellationToken]::None).Wait() | Out-Null

        $id = cdp-send $ws "Emulation.setDeviceMetricsOverride" @{
            width=1440; height=950; deviceScaleFactor=1; mobile=$false
        }
        cdp-recv $ws $id 5 | Out-Null

        $id = cdp-send $ws "Page.navigate" @{ url = $url }
        cdp-recv $ws $id 20 | Out-Null

        Start-Sleep -Milliseconds $WaitMs   # wait for Astro hydration

        $id   = cdp-send $ws "Runtime.evaluate" @{
            expression    = $extractJS
            returnByValue = $true
            awaitPromise  = $false
        }
        $resp = cdp-recv $ws $id 15

        if ($null -eq $resp) { return $null }
        $inner = $resp.result
        if ($null -eq $inner) { return $null }
        $inner2 = $inner.result
        if ($null -eq $inner2) { return $null }
        return $inner2.value
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
Write-Host "=== p5.js Code + Function Extractor ===" -ForegroundColor Cyan
Write-Host "Extracting from $($pages.Count) pages..."
Write-Host ""

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
    Write-Error "Chrome did not start on port $Port"
    exit 1
}

# ----------------------------------------------------------------
# Extract all pages
# ----------------------------------------------------------------
$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$i = 0

foreach ($page in $pages) {
    $i++
    $label = $page.title.PadRight(52).Substring(0,52)
    Write-Host -NoNewline "[$($i.ToString().PadLeft(2))/$($pages.Count)] $label " -ForegroundColor Gray

    $data = Extract-Page $page.url

    if ($null -ne $data) {
        $cl   = $data.codeLines
        $fnc  = $data.fnCount
        $fns  = $data.functions
        $sel  = $data.selector
        $color = if ($cl -gt 100) { 'Green' } elseif ($cl -gt 20) { 'Cyan' } else { 'DarkGray' }
        Write-Host "$cl lines, $fnc fns [$sel]" -ForegroundColor $color
    } else {
        $cl = 0; $fnc = 0; $fns = ''; $sel = 'failed'
        Write-Host "FAILED" -ForegroundColor Red
    }

    $results.Add([PSCustomObject]@{
        Title     = $page.title
        URL       = $page.url
        CodeLines = $cl
        FnCount   = $fnc
        Functions = $fns
        Selector  = $sel
        Headings  = if ($null -ne $data) { $data.headings } else { '' }
    })

    Start-Sleep -Milliseconds 300
}

# ----------------------------------------------------------------
# Stop Chrome and save
# ----------------------------------------------------------------
$chromeProc | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "Chrome closed." -ForegroundColor DarkGray

$results | Export-Csv $OutCSV -NoTypeInformation -Encoding UTF8
Write-Host "Saved: $OutCSV" -ForegroundColor Green

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Pages with code found : $(($results | Where-Object { $_.CodeLines -gt 0 }).Count)"
Write-Host "Pages with 0 lines    : $(($results | Where-Object { $_.CodeLines -eq 0 }).Count)"
Write-Host ""
Write-Host "Top 10 by code lines:" -ForegroundColor Yellow
$results | Where-Object { $_.CodeLines -gt 0 } | Sort-Object CodeLines -Descending | Select-Object -First 10 |
    ForEach-Object { Write-Host ("  {0,4} lines  {1}" -f $_.CodeLines, $_.Title) }

Write-Host ""
Write-Host "Done! Now run apply_tags.ps1 to update the report." -ForegroundColor Green
