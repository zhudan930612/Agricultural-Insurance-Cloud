[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

$outputPath = "d:\VS_wenjian\农业风险减量业务\农业风险减量产品框架图.png"
$width = 1400
$height = 1120

$bitmap = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

function New-Color([int]$r, [int]$g, [int]$b, [int]$a = 255) {
    [System.Drawing.Color]::FromArgb($a, $r, $g, $b)
}

function New-RoundedPath {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [float]$Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $Radius * 2
    $path.AddArc($X, $Y, $d, $d, 180, 90)
    $path.AddArc($X + $Width - $d, $Y, $d, $d, 270, 90)
    $path.AddArc($X + $Width - $d, $Y + $Height - $d, $d, $d, 0, 90)
    $path.AddArc($X, $Y + $Height - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $path
}

function Fill-RoundedBox {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [System.Drawing.Color]$FillColor,
        [System.Drawing.Color]$BorderColor,
        [float]$Radius = 12,
        [float]$BorderWidth = 1.4
    )
    $path = New-RoundedPath -X $X -Y $Y -Width $Width -Height $Height -Radius $Radius
    $brush = New-Object System.Drawing.SolidBrush($FillColor)
    $pen = New-Object System.Drawing.Pen($BorderColor, $BorderWidth)
    $graphics.FillPath($brush, $path)
    $graphics.DrawPath($pen, $path)
    $brush.Dispose()
    $pen.Dispose()
    $path.Dispose()
}

function Draw-Text {
    param(
        [string]$Text,
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [System.Drawing.Font]$Font,
        [System.Drawing.Color]$Color,
        [System.Drawing.StringAlignment]$Align = [System.Drawing.StringAlignment]::Center,
        [System.Drawing.StringAlignment]$LineAlign = [System.Drawing.StringAlignment]::Center
    )
    $rect = New-Object System.Drawing.RectangleF($X, $Y, $Width, $Height)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = $Align
    $format.LineAlignment = $LineAlign
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $graphics.DrawString($Text, $Font, $brush, $rect, $format)
    $brush.Dispose()
    $format.Dispose()
}

function Draw-DashedCard {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Text,
        [System.Drawing.Color]$BorderColor,
        [System.Drawing.Color]$TextColor
    )
    $pen = New-Object System.Drawing.Pen($BorderColor, 1.6)
    $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    $graphics.DrawRectangle($pen, $X, $Y, $Width, $Height)
    $pen.Dispose()
    Draw-Text -Text $Text -X $X -Y $Y -Width $Width -Height $Height -Font $fontNode -Color $TextColor
}

function Draw-SolidCard {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Text,
        [System.Drawing.Color]$FillColor,
        [System.Drawing.Color]$TextColor
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $FillColor -BorderColor $FillColor -Radius 4 -BorderWidth 1
    Draw-Text -Text $Text -X $X -Y $Y -Width $Width -Height $Height -Font $fontNode -Color $TextColor
}

function Draw-SectionPanel {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height
    )
    $pen = New-Object System.Drawing.Pen($blueBorder, 1.4)
    $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    $graphics.DrawRectangle($pen, $X, $Y, $Width, $Height)
    $pen.Dispose()
}

function Draw-Arrow {
    param(
        [float]$X1,
        [float]$Y1,
        [float]$X2,
        [float]$Y2
    )
    $pen = New-Object System.Drawing.Pen($orange, 6)
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

function Draw-LayerTag {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Text,
        [System.Drawing.Color]$FillColor
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $FillColor -BorderColor $FillColor -Radius 4 -BorderWidth 1
    Draw-Text -Text $Text -X $X -Y $Y -Width $Width -Height $Height -Font $fontLayer -Color $white
}

function Draw-SimpleIcon {
    param(
        [float]$CenterX,
        [float]$Y,
        [string]$Label
    )
    $shadowBrush = New-Object System.Drawing.SolidBrush((New-Color 165 235 241 120))
    $mainBrush = New-Object System.Drawing.SolidBrush($cyan)
    $pen = New-Object System.Drawing.Pen($cyan, 3)
    $graphics.FillEllipse($shadowBrush, $CenterX - 42, $Y + 34, 84, 18)
    $graphics.DrawRectangle($pen, $CenterX - 20, $Y, 40, 28)
    $graphics.DrawLine($pen, $CenterX - 8, $Y + 33, $CenterX + 8, $Y + 33)
    $graphics.DrawLine($pen, $CenterX, $Y + 28, $CenterX, $Y + 38)
    $graphics.DrawLine($pen, $CenterX - 16, $Y + 38, $CenterX + 16, $Y + 38)
    $shadowBrush.Dispose()
    $mainBrush.Dispose()
    $pen.Dispose()
    Draw-Text -Text $Label -X ($CenterX - 70) -Y ($Y + 44) -Width 140 -Height 28 -Font $fontLabel -Color $cyanText
}

$white = New-Color 255 255 255
$text = New-Color 79 91 107
$titleColor = New-Color 68 93 128
$cyan = New-Color 44 207 214
$cyanText = New-Color 60 190 200
$orange = New-Color 255 180 57
$orangeSoft = New-Color 255 236 208
$orangeText = New-Color 242 170 48
$blue = New-Color 80 132 216
$blueSoft = New-Color 84 136 220
$blueBorder = New-Color 166 202 255
$green = New-Color 40 209 144
$greenSoft = New-Color 41 211 145
$greenFill = New-Color 226 255 242
$resourceFill = New-Color 235 255 244
$purple = New-Color 72 96 228
$lightGold = New-Color 255 243 224
$panelBg = New-Color 250 252 255

$graphics.Clear($white)

$fontTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 24, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Regular)
$fontLayer = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Bold)
$fontNode = New-Object System.Drawing.Font("Microsoft YaHei UI", 12, [System.Drawing.FontStyle]::Regular)
$fontNodeSmall = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Regular)
$fontLabel = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$fontMini = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Regular)
$fontGreen = New-Object System.Drawing.Font("Microsoft YaHei UI", 12, [System.Drawing.FontStyle]::Bold)

Draw-Text -Text "农业风险减量产品业务架构图" -X 330 -Y 16 -Width 760 -Height 32 -Font $fontTitle -Color $titleColor
Draw-Text -Text "参考业务架构参考图样式重构：分层展示客户端、应用能力、服务支撑、资源底座与采集体系" -X 280 -Y 48 -Width 860 -Height 20 -Font $fontSub -Color $text

# Left layer labels
Draw-LayerTag -X 28 -Y 90 -Width 78 -Height 95 -Text "客`n户`n端" -FillColor $cyan
Draw-LayerTag -X 28 -Y 200 -Width 78 -Height 240 -Text "应`n用`n层" -FillColor $orange
Draw-LayerTag -X 28 -Y 455 -Width 78 -Height 245 -Text "服`n务`n层" -FillColor $blue
Draw-LayerTag -X 28 -Y 715 -Width 78 -Height 150 -Text "资`n源`n层" -FillColor $greenSoft
Draw-LayerTag -X 28 -Y 880 -Width 78 -Height 150 -Text "采`n集`n层" -FillColor $purple

# Client row
Draw-SimpleIcon -CenterX 290 -Y 94 -Label "农户端"
Draw-SimpleIcon -CenterX 560 -Y 94 -Label "业务员端"
Draw-SimpleIcon -CenterX 850 -Y 94 -Label "农险业务平台"
Draw-SimpleIcon -CenterX 1140 -Y 94 -Label "农险监管平台"

# App layer columns
Fill-RoundedBox -X 160 -Y 220 -Width 56 -Height 195 -FillColor $lightGold -BorderColor $orange -Radius 4 -BorderWidth 1
Draw-Text -Text "精`n准`n承`n保" -X 160 -Y 220 -Width 56 -Height 195 -Font $fontLayer -Color $orangeText

$boxW = 110
$boxH = 42
$boxGap = 10
$yStart = 216
$xStart1 = 240
Draw-DashedCard -X $xStart1 -Y $yStart -Width $boxW -Height $boxH -Text "保单导入" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart1 -Y ($yStart + 52) -Width $boxW -Height $boxH -Text "地块映射" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart1 -Y ($yStart + 104) -Width $boxW -Height $boxH -Text "风险区划" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart1 -Y ($yStart + 156) -Width $boxW -Height $boxH -Text "按图承保" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart1 -Y ($yStart + 208) -Width $boxW -Height $boxH -Text "承保核验" -BorderColor $orange -TextColor $orangeText

Draw-Arrow -X1 390 -Y1 322 -X2 520 -Y2 322

Fill-RoundedBox -X 570 -Y 220 -Width 56 -Height 195 -FillColor $lightGold -BorderColor $orange -Radius 4 -BorderWidth 1
Draw-Text -Text "风`n险`n减`n量" -X 570 -Y 220 -Width 56 -Height 195 -Font $fontLayer -Color $orangeText

$xStart2 = 652
Draw-DashedCard -X $xStart2 -Y $yStart -Width $boxW -Height $boxH -Text "长势监测" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart2 -Y ($yStart + 52) -Width $boxW -Height $boxH -Text "产量预估" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart2 -Y ($yStart + 104) -Width $boxW -Height $boxH -Text "灾害预警" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart2 -Y ($yStart + 156) -Width $boxW -Height $boxH -Text "过程巡查" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart2 -Y ($yStart + 208) -Width $boxW -Height $boxH -Text "风险地图" -BorderColor $orange -TextColor $orangeText

Draw-Arrow -X1 804 -Y1 322 -X2 930 -Y2 322

Fill-RoundedBox -X 988 -Y 220 -Width 56 -Height 195 -FillColor $lightGold -BorderColor $orange -Radius 4 -BorderWidth 1
Draw-Text -Text "定`n损`n理`n赔" -X 988 -Y 220 -Width 56 -Height 195 -Font $fontLayer -Color $orangeText

$xStart3 = 1070
Draw-DashedCard -X $xStart3 -Y $yStart -Width $boxW -Height $boxH -Text "实地查勘" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart3 -Y ($yStart + 52) -Width $boxW -Height $boxH -Text "灾情评估" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart3 -Y ($yStart + 104) -Width $boxW -Height $boxH -Text "查勘定损" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart3 -Y ($yStart + 156) -Width $boxW -Height $boxH -Text "按图理赔" -BorderColor $orange -TextColor $orangeText
Draw-DashedCard -X $xStart3 -Y ($yStart + 208) -Width $boxW -Height $boxH -Text "理赔报告" -BorderColor $orange -TextColor $orangeText

# Service layer panels
Draw-SectionPanel -X 160 -Y 455 -Width 1185 -Height 95
Draw-SectionPanel -X 160 -Y 595 -Width 1185 -Height 95

$serviceTop = @(
    @{X=175; T="保单接入接口"},
    @{X=350; T="地图服务接口"},
    @{X=525; T="任务调度接口"},
    @{X=700; T="统计分析接口"},
    @{X=875; T="业务分类接口"},
    @{X=1050; T="消息通知接口"}
)

foreach ($item in $serviceTop) {
    Draw-Text -Text "◉" -X $item.X -Y 468 -Width 120 -Height 18 -Font $fontMini -Color $blueSoft
    Draw-Text -Text $item.T -X ($item.X - 10) -Y 495 -Width 140 -Height 24 -Font $fontMini -Color $blue
}

$capsTop = @(
    @{X=172; T="保单导入"},
    @{X=343; T="地块分割"},
    @{X=514; T="作物识别"},
    @{X=685; T="作物监测"},
    @{X=856; T="灾害评估"},
    @{X=1027; T="灾害预警"},
    @{X=1198; T="产量预估"}
)
foreach ($item in $capsTop) {
    Draw-SolidCard -X $item.X -Y 525 -Width 140 -Height 32 -Text $item.T -FillColor $blueSoft -TextColor $white
}

$capsBottom = @(
    @{X=172; T="目标监测"},
    @{X=343; T="地物分类"},
    @{X=514; T="场景分类"},
    @{X=685; T="变化监测"},
    @{X=856; T="模型训练"},
    @{X=1027; T="深度学习"}
)
foreach ($item in $capsBottom) {
    Draw-Text -Text "◎" -X $item.X -Y 610 -Width 140 -Height 20 -Font $fontMini -Color $blueSoft
    Draw-Text -Text $item.T -X $item.X -Y 650 -Width 140 -Height 24 -Font $fontMini -Color $blue
}

# Resource layer
Draw-SolidCard -X 160 -Y 715 -Width 310 -Height 36 -Text "地理空间与承保资源" -FillColor $greenSoft -TextColor $white
Draw-SolidCard -X 915 -Y 715 -Width 300 -Height 36 -Text "业务与经营数据资源" -FillColor $greenSoft -TextColor $white

Draw-DashedCard -X 162 -Y 765 -Width 145 -Height 38 -Text "行政区划地图" -BorderColor $greenSoft -TextColor $green
Draw-DashedCard -X 325 -Y 765 -Width 145 -Height 38 -Text "栅格影像数据" -BorderColor $greenSoft -TextColor $green
Draw-DashedCard -X 162 -Y 814 -Width 145 -Height 38 -Text "DEM 数据" -BorderColor $greenSoft -TextColor $green
Draw-DashedCard -X 325 -Y 814 -Width 145 -Height 38 -Text "倾斜三维数据" -BorderColor $greenSoft -TextColor $green

Draw-DashedCard -X 915 -Y 765 -Width 145 -Height 38 -Text "业务专题数据" -BorderColor $greenSoft -TextColor $green
Draw-DashedCard -X 1078 -Y 765 -Width 145 -Height 38 -Text "业务实时数据" -BorderColor $greenSoft -TextColor $green
Draw-DashedCard -X 915 -Y 814 -Width 145 -Height 38 -Text "业务基础数据" -BorderColor $greenSoft -TextColor $green
Draw-DashedCard -X 1078 -Y 814 -Width 145 -Height 38 -Text "非结构化数据" -BorderColor $greenSoft -TextColor $green

Draw-Arrow -X1 495 -Y1 788 -X2 590 -Y2 788
Draw-Arrow -X1 890 -Y1 788 -X2 800 -Y2 788

Fill-RoundedBox -X 610 -Y 735 -Width 190 -Height 120 -FillColor $resourceFill -BorderColor $greenSoft -Radius 8 -BorderWidth 1.2
Draw-SolidCard -X 638 -Y 748 -Width 135 -Height 26 -Text "数据驱动" -FillColor $greenSoft -TextColor $white
Draw-SolidCard -X 638 -Y 784 -Width 135 -Height 26 -Text "空间数据引擎" -FillColor $greenSoft -TextColor $white
Draw-SolidCard -X 638 -Y 820 -Width 135 -Height 26 -Text "GIS 扩展引擎" -FillColor $greenSoft -TextColor $white

# Collection layer
$imgW = 150
$imgH = 82
$imgY = 890
$imgXs = @(160, 360, 560, 760, 960, 1160)
$imgLabels = @(
    @{Title='保单/承保数据'; Sub='保险公司核心系统导入'},
    @{Title='遥感卫星'; Sub='高频回访区域监测'},
    @{Title='固定翼无人机'; Sub='高分辨率航飞采集'},
    @{Title='多旋翼无人机'; Sub='重点区域精细核验'},
    @{Title='地面协保人员'; Sub='定位拍照取证'},
    @{Title='灾害信息员'; Sub='现场勘验与灾情上报'}
)

for ($i = 0; $i -lt $imgXs.Count; $i++) {
    Fill-RoundedBox -X $imgXs[$i] -Y $imgY -Width $imgW -Height $imgH -FillColor $panelBg -BorderColor $blueBorder -Radius 4 -BorderWidth 1
    $brush = New-Object System.Drawing.SolidBrush((New-Color (90 + $i * 12) (135 + $i * 8) 210))
    $graphics.FillRectangle($brush, $imgXs[$i] + 1, $imgY + 1, $imgW - 2, $imgH - 2)
    $brush.Dispose()
    Draw-Text -Text $imgLabels[$i].Title -X ($imgXs[$i] - 5) -Y ($imgY + 90) -Width ($imgW + 10) -Height 20 -Font $fontLabel -Color $blue
    Draw-Text -Text $imgLabels[$i].Sub -X ($imgXs[$i] - 10) -Y ($imgY + 112) -Width ($imgW + 20) -Height 18 -Font $fontMini -Color $text
}

Draw-Text -Text "产品主线：保单地图化 → 精准核保 → 风险减量 → 定损理赔 → 数据沉淀与经营分析" -X 190 -Y 1060 -Width 1040 -Height 20 -Font $fontSub -Color $text

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$fontTitle.Dispose()
$fontSub.Dispose()
$fontLayer.Dispose()
$fontNode.Dispose()
$fontNodeSmall.Dispose()
$fontLabel.Dispose()
$fontMini.Dispose()
$fontGreen.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Output "Generated: $outputPath"

