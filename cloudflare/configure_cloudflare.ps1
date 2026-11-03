$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $projectRoot

Write-Host "Configuracao segura do relogio Cloudflare" -ForegroundColor Cyan
Write-Host "Cole o token GitHub de acesso fino. A digitacao fica oculta."
$secureToken = Read-Host "Token GitHub" -AsSecureString

$tokenPointer = [IntPtr]::Zero
try {
    $tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
    $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
    $plainToken = $plainToken.Trim()

    if ([string]::IsNullOrWhiteSpace($plainToken)) {
        throw "O token nao pode ficar vazio."
    }

    $headers = @{
        Accept = "application/vnd.github+json"
        Authorization = "Bearer $plainToken"
        "User-Agent" = "b3-options-clock-setup"
        "X-GitHub-Api-Version" = "2026-03-10"
    }
    $workflowUrl = "https://api.github.com/repos/jkondi18/b3-options-scheduler/actions/workflows/daily-monitor.yml"
    $null = Invoke-RestMethod -Method Get -Uri $workflowUrl -Headers $headers
    Write-Host "Token validado para o agendador GitHub." -ForegroundColor Green

    $plainToken | npx --yes wrangler@latest secret put GITHUB_TOKEN
    if ($LASTEXITCODE -ne 0) {
        throw "Nao foi possivel salvar o token como Secret do Cloudflare."
    }

    npx --yes wrangler@latest deploy
    if ($LASTEXITCODE -ne 0) {
        throw "O deploy do Worker falhou."
    }
}
finally {
    if ($tokenPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
    }
    $plainToken = $null
    $secureToken = $null
}

Write-Host "Cloudflare configurado. Avise no chat que terminou." -ForegroundColor Green
