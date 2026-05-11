Add-Type -AssemblyName System.Drawing
$client = New-Object System.Net.WebClient
$imageBytes = $client.DownloadData("https://www.routeegypt.com/route.png")
$ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
$bmp = New-Object System.Drawing.Bitmap($ms)

$colors = @{}
for ($x = 0; $x -lt $bmp.Width; $x += 2) {
    for ($y = 0; $y -lt $bmp.Height; $y += 2) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.A -gt 50) {
            $hex = "#{0:X2}{1:X2}{2:X2}" -f $c.R, $c.G, $c.B
            $colors[$hex]++
        }
    }
}
$topColors = $colors.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5
foreach ($color in $topColors) {
    Write-Host "$($color.Name): $($color.Value)"
}

$dir = "c:\Users\Pc\StudioProjects\send_message\assets\images"
if (!(Test-Path -Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
$bmp.Save("$dir\route.png")
Write-Host "Image saved to $dir\route.png"
