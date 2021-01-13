$build = Start-Process -FilePath "${Env:ProgramFiles(x86)}\NSIS\makensis.exe" -ArgumentList "$PSScriptRoot\..\flash-enable.nsi" -Wait -PassThru

if ($build.ExitCode -eq 0) {
    Write-Host "Build succeeded"
} else {
    $ExitCode = $build.ExitCode
    Throw "Build failed with $ExitCode"
}

Compress-Archive -Path "$PSScriptRoot\..\OpenUnlight-FlashEnable-Tool.exe" -DestinationPath "$PSScriptRoot\..\OpenUnlight-FlashEnable-Tool.zip" -Force
