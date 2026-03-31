[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

$outputPath = "d:\VS_wenjian\农业风险减量业务\农业风险减量产品框架图.png"
$width = 1800
$height = 1180

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
        [float]$Radius = 18,
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
        [System.Drawing.StringAlignment]$Align = [System.Drawing.StringAlignment]::Near,
        [System.Drawing.StringAlignment]$LineAlign = [System.Drawing.StringAlignment]::Near
    )
    $rect = New-Object System.Drawing.RectangleF($X, $Y, $Width, $Height)
    $brush = New-Object System.Drawing.SolidBrush($Color)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = $Align
    $format.LineAlignment = $LineAlign
    $graphics.DrawString($Text, $Font, $brush, $rect, $format)
    $brush.Dispose()
    $format.Dispose()
}

function Draw-CenteredText {
    param(
        [string]$Text,
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [System.Drawing.Font]$Font,
        [System.Drawing.Color]$Color
    )
    Draw-Text -Text $Text -X $X -Y $Y -Width $Width -Height $Height -Font $Font -Color $Color -Align ([System.Drawing.StringAlignment]::Center) -LineAlign ([System.Drawing.StringAlignment]::Center)
}

function Draw-LayerBar {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Text,
        [System.Drawing.Color]$FillColor
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $FillColor -BorderColor $FillColor -Radius 18 -BorderWidth 1
    Draw-CenteredText -Text $Text -X $X -Y $Y -Width $Width -Height $Height -Font $fontBar -Color $white
}

function Draw-Card {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Title,
        [string]$Body,
        [System.Drawing.Color]$FillColor,
        [System.Drawing.Color]$BorderColor,
        [System.Drawing.Color]$AccentColor,
        [string]$Badge = ""
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $FillColor -BorderColor $BorderColor -Radius 20 -BorderWidth 1.5
    $accentBrush = New-Object System.Drawing.SolidBrush($AccentColor)
    $graphics.FillRectangle($accentBrush, $X + 18, $Y + 18, 7, $Height - 36)
    $accentBrush.Dispose()
    if ($Badge -ne "") {
        Fill-RoundedBox -X ($X + $Width - 104) -Y ($Y + 14) -Width 84 -Height 24 -FillColor $AccentColor -BorderColor $AccentColor -Radius 12 -BorderWidth 1
        Draw-CenteredText -Text $Badge -X ($X + $Width - 104) -Y ($Y + 14) -Width 84 -Height 24 -Font $fontBadge -Color $white
    }
    Draw-Text -Text $Title -X ($X + 38) -Y ($Y + 14) -Width ($Width - 54) -Height 30 -Font $fontH3 -Color $ink
    Draw-Text -Text $Body -X ($X + 38) -Y ($Y + 48) -Width ($Width - 50) -Height ($Height - 56) -Font $fontBody -Color $subInk
}

function Draw-SmallCard {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Title,
        [string]$Body,
        [System.Drawing.Color]$TitleColor
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $white -BorderColor $line -Radius 16 -BorderWidth 1.2
    Draw-CenteredText -Text $Title -X $X -Y ($Y + 10) -Width $Width -Height 20 -Font $fontSmallBold -Color $TitleColor
    Draw-CenteredText -Text $Body -X ($X + 10) -Y ($Y + 34) -Width ($Width - 20) -Height ($Height - 40) -Font $fontMini -Color $subInk
}

function Draw-Arrow {
    param(
        [float]$X1,
        [float]$Y1,
        [float]$X2,
        [float]$Y2,
        [System.Drawing.Color]$Color,
        [float]$Width = 2.6
    )
    $pen = New-Object System.Drawing.Pen($Color, $Width)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $graphics.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

$bg = New-Color 246 249 246
$bg2 = New-Color 234 245 240
$white = New-Color 255 255 255
$ink = New-Color 34 49 44
$subInk = New-Color 98 110 105
$line = New-Color 214 223 217
$green = New-Color 48 123 81
$greenSoft = New-Color 233 244 237
$greenBorder = New-Color 162 205 178
$orange = New-Color 224 153 61
$orangeSoft = New-Color 252 241 224
$orangeBorder = New-Color 230 195 138
$blue = New-Color 95 137 201
$blueSoft = New-Color 235 242 252
$blueBorder = New-Color 178 198 232
$teal = New-Color 69 170 173
$tealSoft = New-Color 233 247 247
$tealBorder = New-Color 170 217 219
$gold = New-Color 191 157 70
$goldSoft = New-Color 248 243 223
$goldBorder = New-Color 224 206 147
$red = New-Color 197 119 92
$redSoft = New-Color 248 236 231
$redBorder = New-Color 225 184 169
$purple = New-Color 122 125 203
$purpleSoft = New-Color 239 239 252
$purpleBorder = New-Color 191 193 232

$graphics.Clear($bg)
$headerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, $width, 180)),
    $bg2,
    $bg,
    90
)
$graphics.FillRectangle($headerBrush, 0, 0, $width, 180)
$headerBrush.Dispose()

$fontTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 28, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Regular)
$fontBar = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold)
$fontH3 = New-Object System.Drawing.Font("Microsoft YaHei UI", 17, [System.Drawing.FontStyle]::Bold)
$fontBody = New-Object System.Drawing.Font("Microsoft YaHei UI", 11.2, [System.Drawing.FontStyle]::Regular)
$fontSmallBold = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$fontMini = New-Object System.Drawing.Font("Microsoft YaHei UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fontBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 9.5, [System.Drawing.FontStyle]::Bold)

Draw-CenteredText -Text "农业风险减量产品框架图" -X 0 -Y 28 -Width $width -Height 36 -Font $fontTitle -Color $ink
Draw-CenteredText -Text "突出系统结构、功能模块与支撑关系：管理端 + 移动端 + 外部系统 → 业务应用层 → 平台支撑层 → 数据层 → 资源接入层" -X 220 -Y 72 -Width 1360 -Height 22 -Font $fontSub -Color $subInk

# Layer bars
Draw-LayerBar -X 60 -Y 130 -Width 120 -Height 36 -Text "终端层" -FillColor $teal
Draw-LayerBar -X 60 -Y 245 -Width 120 -Height 36 -Text "业务应用层" -FillColor $green
Draw-LayerBar -X 60 -Y 650 -Width 120 -Height 36 -Text "平台支撑层" -FillColor $blue
Draw-LayerBar -X 60 -Y 830 -Width 120 -Height 36 -Text "数据层" -FillColor $gold
Draw-LayerBar -X 60 -Y 990 -Width 120 -Height 36 -Text "资源接入层" -FillColor $purple

# Terminal layer
Draw-Card -X 210 -Y 115 -Width 440 -Height 74 -Title "管理端" -Body "保险公司业务人员 / 平台运营管理员 / 数据分析员" -FillColor $tealSoft -BorderColor $tealBorder -AccentColor $teal
Draw-Card -X 690 -Y 115 -Width 360 -Height 74 -Title "移动端" -Body "外勤 / 协保人员 / 灾害信息员" -FillColor $tealSoft -BorderColor $tealBorder -AccentColor $teal
Draw-Card -X 1090 -Y 115 -Width 580 -Height 74 -Title "外部系统" -Body "保险核心系统 / 国家减灾中心 / 气象平台 / 无人机资源平台 / GIS 数据服务" -FillColor $tealSoft -BorderColor $tealBorder -AccentColor $teal

# App layer container
Fill-RoundedBox -X 210 -Y 225 -Width 1460 -Height 390 -FillColor (New-Color 255 255 255 195) -BorderColor $line -Radius 24 -BorderWidth 1.2
Draw-Text -Text "农保云平台业务应用" -X 235 -Y 242 -Width 260 -Height 28 -Font $fontH3 -Color $ink
Draw-Text -Text "业务主线：以前段精准核保、中段风险减量、后段精准理赔为核心；协保人员管理和数据分析横向支撑全流程。" -X 235 -Y 272 -Width 1080 -Height 18 -Font $fontMini -Color $subInk

Draw-Arrow -X1 420 -Y1 382 -X2 710 -Y2 382 -Color $line -Width 5
Draw-Arrow -X1 905 -Y1 382 -X2 1195 -Y2 382 -Color $line -Width 5

Draw-Card -X 250 -Y 315 -Width 430 -Height 150 -Title "精准核保（前段）" -Body "保单导入与地图关联`n风险区划与承保决策支撑`n核保任务创建与分发`n卫星初筛 / 无人机核保 / 人工核验`n核保结果审核与异常处理" -FillColor $orangeSoft -BorderColor $orangeBorder -AccentColor $orange -Badge "一期核心"
Draw-Card -X 735 -Y 315 -Width 430 -Height 150 -Title "风险减量（中段）" -Body "自然灾害预警`n病虫害监测`n过程展示监测`n道德风险预警`n风险减量服务归档" -FillColor $tealSoft -BorderColor $tealBorder -AccentColor $teal
Draw-Card -X 1220 -Y 315 -Width 390 -Height 150 -Title "精准理赔（后段）" -Body "理赔核查任务`n遥感定损 / 无人机核查 / 现场核验`n定损报告输出`n证据链归档与结果回传" -FillColor $redSoft -BorderColor $redBorder -AccentColor $red

Draw-Card -X 430 -Y 485 -Width 380 -Height 95 -Title "协保人员管理" -Body "人员档案、任务调度、移动端接单与上报、服务质量评价" -FillColor $greenSoft -BorderColor $greenBorder -AccentColor $green
Draw-Card -X 890 -Y 485 -Width 420 -Height 95 -Title "数据分析与报告" -Body "核保分析、风险减量分析、理赔分析、招投标/经营报告" -FillColor $blueSoft -BorderColor $blueBorder -AccentColor $blue

Draw-Arrow -X1 680 -Y1 505 -X2 734 -Y2 505 -Color $line -Width 3.2
Draw-Arrow -X1 1165 -Y1 505 -X2 1218 -Y2 505 -Color $line -Width 3.2

# Support layer
Fill-RoundedBox -X 210 -Y 630 -Width 1460 -Height 150 -FillColor (New-Color 250 252 255) -BorderColor $line -Radius 24 -BorderWidth 1.2
Draw-Text -Text "平台支撑能力" -X 235 -Y 648 -Width 220 -Height 24 -Font $fontH3 -Color $ink

$supportTitles = @(
    '任务调度引擎',
    '地图 / GIS 服务',
    '影像服务',
    '规则引擎',
    '权限 / 多租户',
    '消息通知',
    '报表输出'
)
$supportBodies = @(
    '核保/理赔/巡查任务流转',
    '行政区划、地块、地图展示',
    '卫星/无人机影像接入与浏览',
    '分级核验与异常规则',
    '多家保险公司数据隔离',
    '预警推送与任务提醒',
    '分析报告与结果导出'
)

for ($i = 0; $i -lt $supportTitles.Count; $i++) {
    $sx = 235 + ($i * 200)
    Draw-SmallCard -X $sx -Y 695 -Width 180 -Height 64 -Title $supportTitles[$i] -Body $supportBodies[$i] -TitleColor $blue
}

# Data layer
Fill-RoundedBox -X 210 -Y 810 -Width 1460 -Height 130 -FillColor (New-Color 255 253 247) -BorderColor $line -Radius 24 -BorderWidth 1.2
Draw-Text -Text "核心数据仓与证据链" -X 235 -Y 828 -Width 240 -Height 24 -Font $fontH3 -Color $ink

$dataTitles = @(
    '保单库',
    '地理信息库',
    '影像库',
    '风险库',
    '任务库',
    '证据链库'
)
$dataBodies = @(
    '保单、险种、面积、投保主体',
    '行政区划、地块、坐标',
    '卫星/无人机/过程影像',
    '历史灾害、预警、病虫害',
    '核保/理赔/巡查任务',
    '照片、坐标、日志、结论'
)

for ($i = 0; $i -lt $dataTitles.Count; $i++) {
    $sx = 245 + ($i * 228)
    Draw-SmallCard -X $sx -Y 872 -Width 195 -Height 48 -Title $dataTitles[$i] -Body $dataBodies[$i] -TitleColor $gold
}

# Resource layer
Fill-RoundedBox -X 210 -Y 970 -Width 1460 -Height 130 -FillColor (New-Color 250 249 255) -BorderColor $line -Radius 24 -BorderWidth 1.2
Draw-Text -Text "外部资源与能力接入" -X 235 -Y 988 -Width 240 -Height 24 -Font $fontH3 -Color $ink

$resTitles = @(
    '保险核心系统',
    '卫星遥感',
    '无人机平台',
    '气象平台',
    '地面核验资源',
    'GIS 数据服务'
)
$resBodies = @(
    '保单导入 / 结果回传',
    '大范围监测与初筛',
    '重点区域精细核验',
    '灾害预警接入',
    '协保人员 / 灾害信息员',
    '行政区划 / 底图 / 空间数据'
)

for ($i = 0; $i -lt $resTitles.Count; $i++) {
    $sx = 245 + ($i * 228)
    Draw-SmallCard -X $sx -Y 1032 -Width 195 -Height 48 -Title $resTitles[$i] -Body $resBodies[$i] -TitleColor $purple
}

# Footer
$pen = New-Object System.Drawing.Pen((New-Color 212 220 215), 1.0)
$graphics.DrawLine($pen, 210, 1128, 1670, 1128)
$pen.Dispose()
Draw-Text -Text "结构主线：终端入口 → 业务应用 → 平台支撑 → 数据沉淀 → 资源接入" -X 215 -Y 1138 -Width 700 -Height 18 -Font $fontMini -Color $subInk
Draw-Text -Text "依据：农业风险减量产品上下文 / 农业风险减量产品规划" -X 1120 -Y 1138 -Width 545 -Height 18 -Font $fontMini -Color $subInk -Align ([System.Drawing.StringAlignment]::Far)

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$fontTitle.Dispose()
$fontSub.Dispose()
$fontBar.Dispose()
$fontH3.Dispose()
$fontBody.Dispose()
$fontSmallBold.Dispose()
$fontMini.Dispose()
$fontBadge.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Output "Generated: $outputPath"
