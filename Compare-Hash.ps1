  <#
    .SYNOPSIS
     Compare hash in clipboard.
    .DESCRIPTION
    .PARAMETER -filepath
    .EXAMPLE
    .EXAMPLE
  #>

param (
    [Parameter(Mandatory=$true)]
    [string]
    $filepath
)

function toClip {
  if ($large -eq $true) {
"
$sha256hash -SHA256
" | clip
  }else {
"
$md5hash - MD5
$sha1hash - SHA1
$sha256hash - SHA256
" | clip
  }
}

function Show-Popup {
  param (
    [string]$comparedHash,
    [string]$algorithm
  )
  $hashwindow = New-Object -ComObject Wscript.shell
$hashtext = "$filepath
  
$comparedHash -file
$clippedHash -clipboard
  
MATCH with $algorithm file hash."
  $answer = $hashwindow.popup($hashtext,0, 'Compare Hash',0x0)
  if ($answer -eq 6) {
    toClip
  }
}

$clippedHash = (Get-Clipboard | Out-String).trim().ToUpper()
$fileSize = (Get-Item -Path $filepath).Length

if ($fileSize -ge 1GB) {
  $sha256hash = (Get-FileHash -Path $filepath -Algorithm SHA256).Hash
  $large = $true
}else {
  $md5hash = (Get-FileHash -Path $filepath -Algorithm MD5).Hash
  $sha1hash = (Get-FileHash -Path $filepath -Algorithm SHA1).Hash
  $sha256hash = (Get-FileHash -Path $filepath -Algorithm SHA256).Hash
  $large = $false
}

if ($large -eq $false) {
  if ($md5hash -eq $clippedHash) {
    Show-Popup -comparedHash $md5hash -algorithm 'MD5'
  }elseif ($sha1hash -eq $clippedHash) {
    Show-Popup -comparedHash $sha1hash -algorithm 'SHA1'
  }elseif ($sha256hash -eq $clippedHash) {
    Show-Popup -comparedHash $sha256hash -algorithm 'SHA256'
  }else {
    $hashwindow = New-Object -ComObject Wscript.shell
  $hashtext = "$filepath

$clippedHash -clipboard

$md5hash - MD5
$sha1hash - SHA1
$sha256hash - SHA256

DOES NOT match file hash. Copy hash value(S) to clipboard?"
    $answer = $hashwindow.popup($hashtext,0, 'Compare Hash',0x00000104L)
    if ($answer -eq 6) {
      toClip
    }
  }

}else{ #large file
  if ($sha256hash -eq $clippedHash) {
    Show-Popup -comparedHash $sha256hash -algorithm 'SHA256'
  }else {
    $hashwindow = New-Object -ComObject Wscript.shell
  $hashtext = "$filepath

$clippedHash -clipboard

$sha256hash - SHA256

DOES NOT match file hash. Copy hash value to clipboard?"
    $answer = $hashwindow.popup($hashtext,0, 'Compare Hash',0x00000104L)
    if ($answer -eq 6) {
      toClip
    }
  }
}

