param (
    [Parameter(Mandatory=$true)]
    [string]$setCode,
    [int]$minFinishes = 1
)

function Invoke-ScryfallAPI {
    param (
        [string]$url
    )

    $headers = @{
        "User-Agent" = "Chrome/42.0.0.0"
        "Accept" = "application/json"
    }

    $response = Invoke-WebRequest -Uri $url -Headers $headers
    $json = $response.Content | ConvertFrom-Json

    return $json
}

function Process-Cards {
    param (
        [string]$url,
        [int]$totalFinishes,
        [int]$totalCards,
        [int]$minFinishes,
        [hashtable]$finishCountTable
    )

    $json = Invoke-ScryfallAPI -url $url
    $cards = $json.data

    $totalCards += $cards.Count

    foreach ($card in $cards) {
        $name = $card.name
        $finishes = $card.finishes.Count
        $collectorNumber = $card.collector_number

        if ($finishes -ge $minFinishes) {
            $formattedString = "{0,-5} {1,-40} {2,3} finishes" -f "#$collectorNumber", $name, $finishes
            Write-Host $formattedString
        }

        if ($finishCountTable.ContainsKey($finishes)) {
            $finishCountTable[$finishes]++
        } else {
            $finishCountTable[$finishes] = 1
        }

        $totalFinishes += $finishes
    }

    if ($json.has_more) {
        $totalFinishes, $totalCards = Process-Cards -url $json.next_page -totalFinishes $totalFinishes -totalCards $totalCards -minFinishes $minFinishes -finishCountTable $finishCountTable
    }

    return $totalFinishes, $totalCards
}

$apiUrl = "https://api.scryfall.com/cards/search?as=checklist&dir=asc&order=set&q=set%3A$setCode&unique=prints&include_extras=true&format=json"

$totalCards = 0
$totalFinishes = 0
$finishCountTable = @{}
$totalFinishes, $totalCards = Process-Cards -url $apiUrl -totalFinishes $totalFinishes -totalCards $totalCards -minFinishes $minFinishes -finishCountTable $finishCountTable

Write-Host "`n$totalCards cards`n$totalFinishes finishes" -BackgroundColor Yellow -ForegroundColor Black

Write-Host "`nFinish Count`tCard Count"
foreach ($finishCount in $finishCountTable.Keys | Sort-Object) {
    $cardCount = $finishCountTable[$finishCount]
    Write-Host "$finishCount`t`t$cardCount"
}
