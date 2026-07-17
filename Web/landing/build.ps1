# build.ps1 - prepare static landing page assets for task 28
# Keep this file ASCII-only for Windows PowerShell 5.1 compatibility.
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.."))
$assetRoot = Join-Path $PSScriptRoot "assets"
$dataRoot = Join-Path $repoRoot "Data"
$finalRoot = Join-Path $repoRoot "Assets\final"
$sourceAssetRoot = Join-Path $PSScriptRoot "source_assets"
$bossSourceRoot = Join-Path $finalRoot "boss"
$bossOutputRoot = Join-Path $assetRoot "boss"
$uiOutputRoot = Join-Path $assetRoot "ui"
$gameplayOutputRoot = Join-Path $assetRoot "gameplay"

if (Test-Path -LiteralPath $assetRoot) {
    Remove-Item -LiteralPath $assetRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $assetRoot, $bossOutputRoot, $uiOutputRoot, $gameplayOutputRoot | Out-Null

function Copy-RequiredFile {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Required landing asset is missing: $Source"
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Save-ScaledBitmap {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Image]$SourceImage,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][int]$MaxEdge
    )

    $scale = $MaxEdge / [double][Math]::Max($SourceImage.Width, $SourceImage.Height)
    $targetWidth = [Math]::Max(1, [int][Math]::Round($SourceImage.Width * $scale))
    $targetHeight = [Math]::Max(1, [int][Math]::Round($SourceImage.Height * $scale))
    $target = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($target)

    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($SourceImage, 0, 0, $targetWidth, $targetHeight)
        $target.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $target.Dispose()
    }
}

function Save-ScaledJpeg {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Image]$SourceImage,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][int]$MaxEdge,
        [Parameter(Mandatory = $true)][long]$Quality
    )

    $scale = [Math]::Min(1.0, $MaxEdge / [double][Math]::Max($SourceImage.Width, $SourceImage.Height))
    $targetWidth = [Math]::Max(1, [int][Math]::Round($SourceImage.Width * $scale))
    $targetHeight = [Math]::Max(1, [int][Math]::Round($SourceImage.Height * $scale))
    $target = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [System.Drawing.Graphics]::FromImage($target)

    try {
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($SourceImage, 0, 0, $targetWidth, $targetHeight)

        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.MimeType -eq "image/jpeg" } |
            Select-Object -First 1
        $encoderParameters = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality,
            $Quality
        )
        $target.Save($Destination, $jpegCodec, $encoderParameters)
    }
    finally {
        if ($null -ne $encoderParameters) {
            $encoderParameters.Dispose()
        }
        $graphics.Dispose()
        $target.Dispose()
    }
}

function Save-CroppedJpeg {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Image]$SourceImage,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][System.Drawing.Rectangle]$SourceRectangle,
        [Parameter(Mandatory = $true)][int]$Width,
        [Parameter(Mandatory = $true)][int]$Height,
        [Parameter(Mandatory = $true)][long]$Quality
    )

    if ($SourceRectangle.Right -gt $SourceImage.Width -or $SourceRectangle.Bottom -gt $SourceImage.Height) {
        throw "Landing cover crop exceeds source image bounds."
    }

    $target = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [System.Drawing.Graphics]::FromImage($target)

    try {
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $destinationRectangle = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
        $graphics.DrawImage($SourceImage, $destinationRectangle, $SourceRectangle, [System.Drawing.GraphicsUnit]::Pixel)

        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.MimeType -eq "image/jpeg" } |
            Select-Object -First 1
        $encoderParameters = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality,
            $Quality
        )
        $target.Save($Destination, $jpegCodec, $encoderParameters)
    }
    finally {
        if ($null -ne $encoderParameters) {
            $encoderParameters.Dispose()
        }
        $graphics.Dispose()
        $target.Dispose()
    }
}

function Export-FirstFrame {
    param(
        [Parameter(Mandatory = $true)][string]$PngPath,
        [Parameter(Mandatory = $true)][string]$JsonPath,
        [Parameter(Mandatory = $true)][string]$AssetId,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $json = Get-Content -Raw -Encoding UTF8 -LiteralPath $JsonPath | ConvertFrom-Json
    $animationProperty = $json.meta.animations.PSObject.Properties[$AssetId]
    $frameName = $null

    if ($null -ne $animationProperty) {
        $frameName = [string]@($animationProperty.Value)[0]
    }
    if ([string]::IsNullOrWhiteSpace($frameName)) {
        $frameName = [string]$json.frames.PSObject.Properties[0].Name
    }

    $frameProperty = $json.frames.PSObject.Properties[$frameName]
    if ($null -eq $frameProperty) {
        throw "Frame $frameName was not found in $JsonPath"
    }

    $frame = $frameProperty.Value.frame
    $source = [System.Drawing.Image]::FromFile($PngPath)
    $crop = New-Object System.Drawing.Bitmap([int]$frame.w, [int]$frame.h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($crop)

    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $destinationRect = New-Object System.Drawing.Rectangle(0, 0, [int]$frame.w, [int]$frame.h)
        $sourceRect = New-Object System.Drawing.Rectangle([int]$frame.x, [int]$frame.y, [int]$frame.w, [int]$frame.h)
        $graphics.DrawImage($source, $destinationRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
        Save-ScaledBitmap -SourceImage $crop -Destination $Destination -MaxEdge 512
    }
    finally {
        $graphics.Dispose()
        $crop.Dispose()
        $source.Dispose()
    }
}

Copy-RequiredFile (Join-Path $dataRoot "monsters.json") (Join-Path $assetRoot "monsters.json")
Copy-RequiredFile (Join-Path $dataRoot "ui_text.json") (Join-Path $assetRoot "ui_text.json")
Copy-RequiredFile (Join-Path $dataRoot "game_balance.json") (Join-Path $assetRoot "game_balance.json")
Copy-RequiredFile (Join-Path $PSScriptRoot "Baloo2-latin.woff2") (Join-Path $assetRoot "Baloo2-latin.woff2")

$logoSource = [System.Drawing.Image]::FromFile((Join-Path $finalRoot "logo.png"))
try {
    Save-ScaledBitmap -SourceImage $logoSource -Destination (Join-Path $assetRoot "logo.png") -MaxEdge 640
    Save-ScaledBitmap -SourceImage $logoSource -Destination (Join-Path $assetRoot "logo_mobile.png") -MaxEdge 420
}
finally {
    $logoSource.Dispose()
}

$heroCoverSource = [System.Drawing.Image]::FromFile((Join-Path $finalRoot "title_banner.jpg"))
try {
    Save-CroppedJpeg `
        -SourceImage $heroCoverSource `
        -Destination (Join-Path $assetRoot "hero_cover.jpg") `
        -SourceRectangle (New-Object System.Drawing.Rectangle(92, 780, 896, 1120)) `
        -Width 800 `
        -Height 1000 `
        -Quality 86
}
finally {
    $heroCoverSource.Dispose()
}

$jpegAssets = @(
    @{ Name = "title_banner.jpg"; Quality = 74; MaxEdge = 1280 },
    @{ Name = "background_battle_001.jpg"; Quality = 76; MaxEdge = 1920 },
    @{ Name = "background_battle_002.jpg"; Quality = 76; MaxEdge = 1920 },
    @{ Name = "background_battle_003.jpg"; Quality = 76; MaxEdge = 1920 }
)

foreach ($jpegAsset in $jpegAssets) {
    $jpegSource = [System.Drawing.Image]::FromFile((Join-Path $finalRoot $jpegAsset.Name))
    try {
        Save-ScaledJpeg `
            -SourceImage $jpegSource `
            -Destination (Join-Path $assetRoot $jpegAsset.Name) `
            -MaxEdge $jpegAsset.MaxEdge `
            -Quality $jpegAsset.Quality
    }
    finally {
        $jpegSource.Dispose()
    }
}

$mobileBackgroundSource = [System.Drawing.Image]::FromFile((Join-Path $finalRoot "background_battle_001.jpg"))
try {
    Save-ScaledJpeg `
        -SourceImage $mobileBackgroundSource `
        -Destination (Join-Path $assetRoot "background_battle_001_mobile.jpg") `
        -MaxEdge 1280 `
        -Quality 68
}
finally {
    $mobileBackgroundSource.Dispose()
}

$mysterySource = [System.Drawing.Image]::FromFile((Join-Path $sourceAssetRoot "mystery_encounter.png"))
try {
    Save-ScaledBitmap -SourceImage $mysterySource -Destination (Join-Path $assetRoot "mystery_encounter.png") -MaxEdge 512
}
finally {
    $mysterySource.Dispose()
}

$ogPath = Join-Path $sourceAssetRoot "og.png"
$ogSource = [System.Drawing.Image]::FromFile($ogPath)
try {
    if ($ogSource.Width -ne 1200 -or $ogSource.Height -ne 630) {
        throw "Open Graph image must be exactly 1200x630: $ogPath"
    }
}
finally {
    $ogSource.Dispose()
}
Copy-RequiredFile $ogPath (Join-Path $assetRoot "og-benz-cat-v2.png")

$gameplayAssets = @(
    "01-bet.jpg",
    "02-battle.jpg",
    "03-decision.jpg",
    "04-result.jpg"
)

foreach ($fileName in $gameplayAssets) {
    $sourcePath = Join-Path $sourceAssetRoot (Join-Path "gameplay" $fileName)
    $sourceImage = [System.Drawing.Image]::FromFile($sourcePath)
    try {
        if ($sourceImage.Width -ne 640 -or $sourceImage.Height -ne 800) {
            throw "Gameplay preview must be exactly 640x800: $sourcePath"
        }
    }
    finally {
        $sourceImage.Dispose()
    }
    Copy-RequiredFile $sourcePath (Join-Path $gameplayOutputRoot $fileName)
}

$uiAssets = @(
    "icon_paw.png",
    "icon_cloud.png",
    "icon_backpack.png",
    "icon_warning.png",
    "icon_multiplier.png",
    "icon_trophy.png",
    "icon_coin.png",
    "icon_stage.png",
    "risk_star.png"
)

foreach ($fileName in $uiAssets) {
    $uiSource = [System.Drawing.Image]::FromFile((Join-Path $finalRoot (Join-Path "ui" $fileName)))
    try {
        Save-ScaledBitmap -SourceImage $uiSource -Destination (Join-Path $uiOutputRoot $fileName) -MaxEdge 160
    }
    finally {
        $uiSource.Dispose()
    }
}

$faviconSource = [System.Drawing.Image]::FromFile((Join-Path $finalRoot "ui\icon_paw.png"))
try {
    Save-ScaledBitmap -SourceImage $faviconSource -Destination (Join-Path $assetRoot "favicon.png") -MaxEdge 64
}
finally {
    $faviconSource.Dispose()
}

for ($index = 1; $index -le 3; $index += 1) {
    $assetId = "boss${index}_idle"
    $pngPath = Join-Path $bossSourceRoot "${assetId}.png"
    $jsonPath = Join-Path $bossSourceRoot "${assetId}.json"

    if (-not (Test-Path -LiteralPath $pngPath) -or -not (Test-Path -LiteralPath $jsonPath)) {
        Write-Warning "Optional boss asset is missing: $assetId"
        continue
    }

    Copy-Item -LiteralPath $pngPath -Destination (Join-Path $bossOutputRoot "${assetId}.png") -Force
    Copy-Item -LiteralPath $jsonPath -Destination (Join-Path $bossOutputRoot "${assetId}.json") -Force

    try {
        Export-FirstFrame `
            -PngPath $pngPath `
            -JsonPath $jsonPath `
            -AssetId $assetId `
            -Destination (Join-Path $assetRoot "boss${index}_card.png")
    }
    catch {
        Write-Warning "Unable to create preview for ${assetId}: $($_.Exception.Message)"
    }
}

Write-Output "Landing assets prepared: $assetRoot"
