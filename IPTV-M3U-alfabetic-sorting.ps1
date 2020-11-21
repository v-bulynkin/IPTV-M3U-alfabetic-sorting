$url = (Read-Host "Enter an IPTV playlist URL").trim()
$file = "$env:userprofile\Downloads\$(([uri]$url).segments[-1])"
curl $url -OutFile "$file"

$l = ((gc "$file" -encoding utf8) -split '#EXTINF:-1 ,' -notmatch "EXTM3U|^$").Trim()
$names,$links = $l.where({$_ -notmatch "^https?://"}, 'split')

# Making ordered object
$data = @()
$c = 0

$names|% {
    $obj = [pscustomobject]@{
    Name = $_
    Link = $links[$c]
    }
$c++
$data += $obj
}

$data = $data |sort Name

# Output
"#EXTM3U" |Out-File "$file" -Encoding utf8 -Force -Confirm:$false

$data |% {
"#EXTINF:-1 ," + $_.name + "`n" + $_.link |Out-File "$file" -Encoding utf8 -Append
}
