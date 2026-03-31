[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Drawing

$outputPath = "d:\VS_wenjian\农业风险减量业务\农业风险减量产品框架图.png"
$width = 1800
$height = 1280

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
        [float]$BorderWidth = 1.5
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

function Draw-Arrow {
    param(
        [float]$X1,
        [float]$Y1,
        [float]$X2,
        [float]$Y2,
        [System.Drawing.Color]$Color,
        [float]$Width = 3.0
    )
    $pen = New-Object System.Drawing.Pen($Color, $Width)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $graphics.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    $pen.Dispose()
}

function Draw-Tag {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Text,
        [System.Drawing.Color]$FillColor,
        [System.Drawing.Color]$TextColor
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $FillColor -BorderColor $FillColor -Radius 14 -BorderWidth 1
    Draw-CenteredText -Text $Text -X $X -Y $Y -Width $Width -Height $Height -Font $fontTag -Color $TextColor
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
        [bool]$Highlight = $false
    )

    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $FillColor -BorderColor $BorderColor -Radius 22 -BorderWidth ($(if ($Highlight) { 2.4 } else { 1.4 }))
    $accentBrush = New-Object System.Drawing.SolidBrush($AccentColor)
    $graphics.FillRectangle($accentBrush, $X + 20, $Y + 20, 8, $Height - 40)
    $accentBrush.Dispose()

    if ($Highlight) {
        Draw-Tag -X ($X + $Width - 118) -Y ($Y + 18) -Width 92 -Height 28 -Text "一期核心" -FillColor $accentColor -TextColor $white
    }

    Draw-Text -Text $Title -X ($X + 42) -Y ($Y + 18) -Width ($Width - 60) -Height 34 -Font $fontH3 -Color $ink
    Draw-Text -Text $Body -X ($X + 42) -Y ($Y + 58) -Width ($Width - 56) -Height ($Height - 72) -Font $fontBody -Color $subInk
}

function Draw-EntryCard {
    param(
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [string]$Title,
        [string]$Body
    )
    Fill-RoundedBox -X $X -Y $Y -Width $Width -Height $Height -FillColor $white -BorderColor $lineLight -Radius 20 -BorderWidth 1.3
    $dotBrush = New-Object System.Drawing.SolidBrush($cyan)
    $graphics.FillEllipse($dotBrush, $X + 18, $Y + 18, 14, 14)
    $dotBrush.Dispose()
    Draw-Text -Text $Title -X ($X + 42) -Y ($Y + 14) -Width ($Width - 54) -Height 26 -Font $fontH4 -Color $ink
    Draw-Text -Text $Body -X ($X + 20) -Y ($Y + 48) -Width ($Width - 34) -Height ($Height - 58) -Font $fontSmall -Color $subInk
}

$bg = New-Color 245 248 244
$bgTop = New-Color 236 247 243
$white = New-Color 255 255 255
$ink = New-Color 32 52 46
$subInk = New-Color 88 104 98
$lineLight = New-Color 214 224 218
$green = New-Color 44 112 74
$greenSoft = New-Color 233 244 236
$greenMid = New-Color 102 173 132
$orange = New-Color 221 152 60
$orangeSoft = New-Color 251 241 225
$blue = New-Color 88 137 193
$blueSoft = New-Color 233 241 250
$teal = New-Color 54 147 151
$tealSoft = New-Color 231 246 246
$cyan = New-Color 73 195 185
$cyanSoft = New-Color 230 249 246
$redSoft = New-Color 248 235 230
$red = New-Color 193 115 90
$gold = New-Color 191 153 68
$goldSoft = New-Color 248 243 224
$shadow = New-Color 180 196 187 70

$graphics.Clear($bg)

$headerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, $width, 220)),
    $bgTop,
    $bg,
    90
)
$graphics.FillRectangle($headerBrush, 0, 0, $width, 220)
$headerBrush.Dispose()

$halo1 = New-Object System.Drawing.SolidBrush((New-Color 208 236 222 130))
$halo2 = New-Object System.Drawing.SolidBrush((New-Color 245 228 194 110))
$graphics.FillEllipse($halo1, -120, -40, 560, 260)
$graphics.FillEllipse($halo2, 1280, -50, 420, 220)
$halo1.Dispose()
$halo2.Dispose()

$fontTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 12, [System.Drawing.FontStyle]::Regular)
$fontTag = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$fontH3 = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Bold)
$fontH4 = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold)
$fontBody = New-Object System.Drawing.Font("Microsoft YaHei UI", 11.5, [System.Drawing.FontStyle]::Regular)
$fontSmall = New-Object System.Drawing.Font("Microsoft YaHei UI", 10.5, [System.Drawing.FontStyle]::Regular)
$fontMini = New-Object System.Drawing.Font("Microsoft YaHei UI", 9.5, [System.Drawing.FontStyle]::Regular)

Draw-CenteredText -Text "农业风险减量产品框架图" -X 0 -Y 34 -Width $width -Height 40 -Font $fontTitle -Color $ink
Draw-CenteredText -Text "基于《产品上下文》《产品规划》重构：以保单地图化为底座，以精准核保为一期核心，向风险减量、精准理赔与数据经营延展" -X 220 -Y 84 -Width 1360 -Height 24 -Font $fontSub -Color $subInk

Draw-Tag -X 140 -Y 134 -Width 140 -Height 34 -Text "角色触达层" -FillColor $cyanSoft -TextColor $teal
Draw-Tag -X 300 -Y 134 -Width 140 -Height 34 -Text "核心产品层" -FillColor $greenSoft -TextColor $green
Draw-Tag -X 460 -Y 134 -Width 140 -Height 34 -Text "平台支撑层" -FillColor $blueSoft -TextColor $blue
Draw-Tag -X 620 -Y 134 -Width 140 -Height 34 -Text "数据资源层" -FillColor $goldSoft -TextColor $gold
Draw-Tag -X 780 -Y 134 -Width 140 -Height 34 -Text "业务价值层" -FillColor $orangeSoft -TextColor $orange

# Entry layer
$entryY = 210
$entryW = 360
$entryH = 92
Draw-EntryCard -X 90 -Y $entryY -Width $entryW -Height $entryH -Title "保险公司业务端" -Body "农险业务负责人、招投标人员、理赔审核人员"
Draw-EntryCard -X 500 -Y $entryY -Width $entryW -Height $entryH -Title "平台运营端" -Body "平台管理员、运营管理员、数据分析员"
Draw-EntryCard -X 910 -Y $entryY -Width $entryW -Height $entryH -Title "移动执行端" -Body "外勤/协保人员、灾害信息员、地面核验队伍"
Draw-EntryCard -X 1320 -Y $entryY -Width 390 -Height $entryH -Title "外部协同端" -Body "保险核心系统、国家减灾中心、气象数据平台、无人机资源方"

# Core platform container
Fill-RoundedBox -X 90 -Y 340 -Width 1380 -Height 540 -FillColor (New-Color 255 255 255 180) -BorderColor $lineLight -Radius 28 -BorderWidth 1.4
Draw-Text -Text "农保云平台" -X 120 -Y 360 -Width 220 -Height 34 -Font $fontH3 -Color $ink
Draw-Text -Text '围绕[精准承保 + 风险区划 + 风险减量 + 精准理赔]的一体化科技服务平台' -X 120 -Y 394 -Width 540 -Height 22 -Font $fontSmall -Color $subInk

# Process backbone arrow
Draw-Arrow -X1 210 -Y1 500 -X2 1310 -Y2 500 -Color (New-Color 190 203 196) -Width 5.5

$cardW = 300
$cardH = 145
$gap = 35
$x1 = 130
$x2 = $x1 + $cardW + $gap
$x3 = $x2 + $cardW + $gap
$x4 = $x3 + $cardW + $gap
$yTop = 445
$yBottom = 620

Draw-Card -X $x1 -Y $yTop -Width $cardW -Height $cardH -Title "基础地图平台" -Body "保单导入与地址匹配`n行政区划/地块映射`n影像叠加浏览`n承保分布可视化" -FillColor $greenSoft -BorderColor $greenMid -AccentColor $green
Draw-Card -X $x2 -Y $yTop -Width $cardW -Height $cardH -Title "风险区划地图" -Body "历史灾害沉淀`n风险等级区划`n高/中/低风险区域展示`n风险报告输出" -FillColor $goldSoft -BorderColor (New-Color 214 190 121) -AccentColor $gold
Draw-Card -X $x3 -Y $yTop -Width $cardW -Height $cardH -Title "精准核保服务" -Body "核保任务创建与分发`n卫星初筛 + 无人机核保`n人工核验与现场取证`n结果审核与异常处理" -FillColor $orangeSoft -BorderColor (New-Color 226 186 119) -AccentColor $orange -Highlight $true
Draw-Card -X $x4 -Y $yTop -Width $cardW -Height $cardH -Title "精准理赔辅助" -Body "理赔核查任务`n遥感定损 + 无人机核查`n现场核验`n定损报告与证据链输出" -FillColor $redSoft -BorderColor (New-Color 217 168 149) -AccentColor $red

Draw-Card -X 315 -Y $yBottom -Width 330 -Height 150 -Title "风险减量服务" -Body "自然灾害预警`n病虫害监测`n过程展示监测`n道德风险预警与过程留痕" -FillColor $tealSoft -BorderColor (New-Color 142 199 201) -AccentColor $teal
Draw-Card -X 735 -Y $yBottom -Width 330 -Height 150 -Title "协保人员管理" -Body "人员档案`n任务调度`n移动端接单与上报`n服务质量评价" -FillColor $cyanSoft -BorderColor (New-Color 147 219 211) -AccentColor $cyan
Draw-Card -X 1155 -Y $yBottom -Width 260 -Height 150 -Title "数据分析与报告" -Body "核保成效分析`n风险减量分析`n理赔辅助分析`n招投标/经营报告" -FillColor $blueSoft -BorderColor (New-Color 170 198 229) -AccentColor $blue

# Support layer
Fill-RoundedBox -X 90 -Y 915 -Width 1380 -Height 150 -FillColor (New-Color 250 252 255) -BorderColor $lineLight -Radius 24 -BorderWidth 1.2
Draw-Text -Text "平台支撑能力" -X 120 -Y 935 -Width 220 -Height 28 -Font $fontH4 -Color $ink

$supportTitles = @(
    "任务调度引擎",
    "GIS / 影像服务",
    "规则与分级服务",
    "证据链留痕",
    "多租户权限隔离",
    "消息通知 / 报告输出"
)
$supportBodies = @(
    "核保/理赔/巡查任务流转",
    "行政区划、遥感影像、地图可视化",
    "卫星/无人机/人工适用边界与策略",
    "影像、坐标、日志、结论归档",
    "多家保险公司数据安全隔离",
    "预警推送、报告导出、经营输出"
)

for ($i = 0; $i -lt $supportTitles.Count; $i++) {
    $sx = 125 + ($i * 220)
    Fill-RoundedBox -X $sx -Y 975 -Width 190 -Height 64 -FillColor $white -BorderColor $lineLight -Radius 16 -BorderWidth 1.2
    Draw-CenteredText -Text $supportTitles[$i] -X $sx -Y 986 -Width 190 -Height 22 -Font $fontSmall -Color $blue
    Draw-CenteredText -Text $supportBodies[$i] -X ($sx + 10) -Y 1010 -Width 170 -Height 20 -Font $fontMini -Color $subInk
}

# Data/resources layer
Fill-RoundedBox -X 90 -Y 1090 -Width 1380 -Height 140 -FillColor (New-Color 255 255 255 190) -BorderColor $lineLight -Radius 24 -BorderWidth 1.2
Draw-Text -Text "数据与资源底座" -X 120 -Y 1110 -Width 220 -Height 28 -Font $fontH4 -Color $ink

Draw-Card -X 120 -Y 1145 -Width 280 -Height 65 -Title "承保与地理数据" -Body "保单数据、行政区划、村级地址、地块/区域信息" -FillColor $greenSoft -BorderColor $greenMid -AccentColor $green
Draw-Card -X 430 -Y 1145 -Width 280 -Height 65 -Title "风险与预警数据" -Body "历史灾害、气象预警、病虫害线索、过程监测影像" -FillColor $goldSoft -BorderColor (New-Color 214 190 121) -AccentColor $gold
Draw-Card -X 740 -Y 1145 -Width 280 -Height 65 -Title "采集执行资源" -Body "卫星遥感、无人机平台、外勤/协保人员、灾害信息员" -FillColor $tealSoft -BorderColor (New-Color 142 199 201) -AccentColor $teal
Draw-Card -X 1050 -Y 1145 -Width 390 -Height 65 -Title "长期数据资产" -Body "区域承保图谱、核保结果、理赔证据链、经营分析沉淀" -FillColor $blueSoft -BorderColor (New-Color 170 198 229) -AccentColor $blue

# Value panel
Fill-RoundedBox -X 1490 -Y 340 -Width 250 -Height 890 -FillColor (New-Color 255 252 246) -BorderColor (New-Color 231 220 199) -Radius 28 -BorderWidth 1.4
Draw-Text -Text "业务价值输出" -X 1520 -Y 364 -Width 190 -Height 30 -Font $fontH3 -Color $ink
Draw-Text -Text "Value" -X 1520 -Y 398 -Width 80 -Height 18 -Font $fontMini -Color $subInk

Draw-Card -X 1515 -Y 436 -Width 200 -Height 132 -Title "对保险公司" -Body "提升承保真实性`n降低经营风险`n增强招投标竞争力" -FillColor $orangeSoft -BorderColor (New-Color 226 186 119) -AccentColor $orange
Draw-Card -X 1515 -Y 584 -Width 200 -Height 122 -Title "对监管/政府" -Body "提升补贴真实性`n支撑监管合规`n增强透明度" -FillColor $goldSoft -BorderColor (New-Color 214 190 121) -AccentColor $gold
Draw-Card -X 1515 -Y 722 -Width 200 -Height 122 -Title "对农户" -Body "提升理赔公平性`n缩短理赔周期`n改善赔付体验" -FillColor $cyanSoft -BorderColor (New-Color 147 219 211) -AccentColor $cyan
Draw-Card -X 1515 -Y 860 -Width 200 -Height 148 -Title "对平台方" -Body '沉淀区域数据资产`n形成服务壁垒`n构建[科技 + 服务]商业闭环' -FillColor $greenSoft -BorderColor $greenMid -AccentColor $green

Draw-Tag -X 1515 -Y 1034 -Width 200 -Height 30 -Text "首单切入建议" -FillColor $orangeSoft -TextColor $orange
Draw-Text -Text '优先围绕[招投标支撑包]`n[精准核保服务包]`n[试点交付项目]成交，而非默认整平台一次性售卖。' -X 1524 -Y 1076 -Width 184 -Height 104 -Font $fontSmall -Color $subInk

# Footer
$footerPen = New-Object System.Drawing.Pen((New-Color 210 221 214), 1.1)
$graphics.DrawLine($footerPen, 90, 1248, 1710, 1248)
$footerPen.Dispose()
Draw-Text -Text "主线逻辑：保单地图化 → 风险区划 → 精准核保 → 风险减量 / 精准理赔 → 数据分析与经营输出" -X 92 -Y 1255 -Width 1000 -Height 18 -Font $fontSmall -Color $subInk
Draw-Text -Text "依据：农业风险减量产品上下文 / 农业风险减量产品规划" -X 1290 -Y 1255 -Width 410 -Height 18 -Font $fontSmall -Color $subInk -Align ([System.Drawing.StringAlignment]::Far)

$bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$fontTitle.Dispose()
$fontSub.Dispose()
$fontTag.Dispose()
$fontH3.Dispose()
$fontH4.Dispose()
$fontBody.Dispose()
$fontSmall.Dispose()
$fontMini.Dispose()
$graphics.Dispose()
$bitmap.Dispose()

Write-Output "Generated: $outputPath"
