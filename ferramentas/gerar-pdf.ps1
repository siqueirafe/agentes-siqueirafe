# Gera o PDF de uma página do radar do dia, com as cores laranja e azul,
# a partir do index.html. Uso: powershell -File ferramentas/gerar-pdf.ps1 -Data AAAA-MM-DD
# Saída: pdf/radar-AAAA-MM-DD.pdf
param([Parameter(Mandatory = $true)][string]$Data)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
$index = [System.IO.File]::ReadAllText((Join-Path $raiz 'index.html'), $utf8)

function Pegar($texto, $padrao) {
  $m = [regex]::Match($texto, $padrao, 'Singleline')
  if ($m.Success) { return $m.Groups[1].Value } else { return '' }
}

$artigo   = Pegar $index '<article>(.*?)</article>'
$dataLonga = Pegar $index '<p class="data">(.*?)</p>'
$rodape   = Pegar $index '<footer>(.*?)</footer>'
$placar   = Pegar $artigo '<p class="primeira">(.*?)</p>'
$time     = Pegar $artigo '<section class="time">(.*?)</section>'
$escrito  = Pegar $artigo '<p>(Escrito em.*?)</p>'
$time     = [regex]::Replace($time, '<h2>(.*?)</h2>', '<span class="rotulo">$1</span>', 'Singleline')
$noticias = [regex]::Replace($artigo, '<p class="primeira">.*?</p>', '', 'Singleline')
$noticias = [regex]::Replace($noticias, '<section class="time">.*?</section>', '', 'Singleline')
$noticias = [regex]::Replace($noticias, '<p>Escrito em.*?</p>', '', 'Singleline')

if (-not $placar) { throw 'Não achei o placar (<p class="primeira">) no index.html.' }
if ($dataLonga -eq '') { $dataLonga = $Data }

$colunaTime = ''
if ($time) { $colunaTime = "<section class=`"time`">$time</section>" }

$pastaPdf = Join-Path $raiz 'pdf'
New-Item -ItemType Directory -Force $pastaPdf | Out-Null
$saida = Join-Path $pastaPdf "radar-$Data.pdf"
$html = Join-Path $env:TEMP "radar-pdf-$Data.html"
$perfil = Join-Path $env:TEMP 'edge-pdf-radar'
$edge = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw 'Não achei o Edge nem o Chrome para gerar o PDF.' }

foreach ($fonte in @('8.1', '7.6', '7.1', '6.7')) {
  $pagina = @"
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><title>Radar de Recuperação de Crédito</title>
<style>
  @page { size: A4; margin: 0; }
  :root { --laranja: #EC7000; --laranja-escuro: #C75F00; --laranja-claro: #FFF1E3; --azul: #003A70; --texto: #2B2B2B; --cinza: #6B6B6B; }
  * { box-sizing: border-box; }
  body { margin: 0; font-family: Arial, "Segoe UI", Helvetica, sans-serif; color: var(--texto); font-size: ${fonte}pt; line-height: 1.3; background: #fff; }
  header { background: var(--laranja); color: #fff; padding: 7mm 9mm 5mm; }
  header .selo { font-size: 7pt; letter-spacing: .16em; text-transform: uppercase; font-weight: 700; margin: 0 0 2px; }
  header h1 { font-size: 20pt; font-weight: 700; margin: 0; line-height: 1.1; }
  header .data { margin: 2px 0 0; font-size: 8.5pt; }
  .placar { background: var(--azul); color: #fff; padding: 3.5mm 9mm; font-size: 10pt; line-height: 1.35; border-bottom: 1.2mm solid var(--laranja-escuro); }
  .corpo { display: grid; grid-template-columns: 1.15fr 1fr; gap: 6mm; padding: 5mm 9mm 0; }
  .noticias h2 { color: var(--azul); font-size: 1.16em; margin: 0 0 1.5px; line-height: 1.22; }
  .noticias p { margin: 0 0 6px; }
  a { color: var(--laranja-escuro); font-weight: 700; text-decoration: none; }
  .time { background: var(--laranja-claro); border-top: 1.2mm solid var(--laranja); padding: 3.5mm 4mm 3mm; align-self: start; }
  .time .rotulo { display: inline-block; background: var(--azul); color: #fff; font-weight: 700; font-size: 8.6pt; letter-spacing: .05em; padding: 3px 7px; margin: 0 0 6px; }
  .time h3 { color: var(--azul); font-size: 1.1em; margin: 7px 0 1.5px; }
  .time p { margin: 0 0 4px; }
  .rodape { margin: 4mm 9mm 0; padding: 2.5mm 0 6mm; border-top: .4mm solid var(--laranja); color: var(--cinza); font-size: 6.8pt; display: flex; justify-content: space-between; gap: 6mm; }
  .rodape span:last-child { white-space: nowrap; }
</style></head>
<body>
<header><p class="selo">Radar do dia</p><h1>Radar de Recuperação de Crédito</h1><p class="data">$dataLonga</p></header>
<div class="placar">$placar</div>
<div class="corpo"><section class="noticias">$noticias</section>$colunaTime</div>
<div class="rodape"><span>$rodape</span><span>$escrito</span></div>
</body></html>
"@
  [System.IO.File]::WriteAllText($html, $pagina, $utf8)
  $uri = ([System.Uri]$html).AbsoluteUri
  $argumentos = @('--headless=new', '--disable-gpu', '--no-pdf-header-footer', "`"--user-data-dir=$perfil`"", "`"--print-to-pdf=$saida`"", "`"$uri`"")
  Start-Process -FilePath $edge -ArgumentList $argumentos -Wait -WindowStyle Hidden
  Start-Sleep -Seconds 2
  $bruto = [System.IO.File]::ReadAllText($saida, [System.Text.Encoding]::GetEncoding(28591))
  $paginas = [int]([regex]::Match($bruto, '/Count (\d+)').Groups[1].Value)
  if ($paginas -le 1) { break }
}

Remove-Item $html -ErrorAction SilentlyContinue
Write-Output "PDF: $saida ($paginas página(s), letra ${fonte}pt)"
