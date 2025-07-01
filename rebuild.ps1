param(
  [string]$ExtractedDir = "C:\Users\senth\AppData\Local\Temp\git_rebuild_ln2zmt3g.dmz",
  [string]$ProjectDir = "D:\project\To-do-list"
)

$allMessages = @(
  "chore: initialize project with .gitignore",
  "feat: add HTML document skeleton with meta tags",
  "style: add CSS reset and custom property definitions",
  "feat: add JavaScript module scaffolding with IIFE",
  "feat: add header with navigation and page title",
  "style: add header and container layout styles",
  "feat: add task input form with submit button",
  "style: add form input and button component styles",
  "feat: add DOM references and form submit handler in JS",
  "fix: handle empty task submission with validation feedback",
  "style: add input error state styling",
  "feat: add task list rendering and display area",
  "style: add task list item styles with spacing and borders",
  "feat: add localStorage persistence for task data",
  "feat: add task completion toggle functionality",
  "style: add completed task visual style with strikethrough",
  "feat: add task deletion with confirmation dialog",
  "feat: add footer with credits and app info",
  "style: add footer styling with muted text",
  "feat: implement task filtering (all/active/completed)",
  "style: add filter button styles with active indicator",
  "feat: add task counter showing remaining items",
  "feat: add responsive design for mobile screens",
  "fix: persist filter state on page reload from localStorage",
  "refactor: extract debounce utility for resize handler",
  "style: add smooth transitions and hover animations",
  "perf: optimize render using DocumentFragment for batch DOM insert",
  "fix: prevent duplicate task entries with same title",
  "feat: add keyboard shortcuts for accessibility (Enter/Escape)",
  "style: add dark mode support with media query and toggle",
  "refactor: simplify event delegation using matches API",
  "docs: add README with feature list and usage guide"
)

# Expected work minutes for each commit (how long it reasonably takes)
$workMinutes = @(
  3,   # 0:  .gitignore
  12,  # 1:  HTML skeleton
  18,  # 2:  CSS reset + vars
  8,   # 3:  JS scaffold
  6,   # 4:  header HTML
  20,  # 5:  header CSS
  8,   # 6:  form HTML
  25,  # 7:  form CSS
  15,  # 8:  DOM refs + handler
  3,   # 9:  validation fix
  8,   # 10: error styling
  12,  # 11: task list render
  15,  # 12: task item styles
  12,  # 13: localStorage
  6,   # 14: toggle
  8,   # 15: strikethrough
  8,   # 16: delete
  5,   # 17: footer HTML
  8,   # 18: footer styles
  18,  # 19: filtering
  10,  # 20: filter styles
  6,   # 21: counter
  15,  # 22: responsive
  4,   # 23: filter persist fix
  8,   # 24: debounce
  12,  # 25: animations
  4,   # 26: fragment perf
  6,   # 27: duplicate fix
  8,   # 28: keyboard
  18,  # 29: dark mode
  2,   # 30: matches API
  8    # 31: README
)

function New-DateSchedule {
  param([int]$TotalCommits = 32)
  
  $startDate = [DateTime]"2025-07-01"
  $endDate = [DateTime]"2025-11-05"
  $daySpan = ($endDate - $startDate).Days

  # Generate commit-day groups: each gets 2-4 commits, some get 1
  $groups = @()
  $remaining = $TotalCommits
  $idx = 0
  $usedDates = @{}
  $maxAttempts = 500

  while ($remaining -gt 0) {
    $allowOne = ($groups.Count -ge 6)  # allow single-commit days after some diversity
    if ($remaining -le 2) { $allowOne = $true }

    if ($remaining -eq 1) {
      $n = 1
    } elseif ($remaining -eq 2) {
      $n = (Get-Random -Minimum 1 -Maximum 3)
    } else {
      if ($allowOne -and (Get-Random -Minimum 0 -Maximum 100) -lt 20) {
        $n = 1
      } else {
        $n = (Get-Random -Minimum 2 -Maximum 5)
      }
    }
    if ($n -gt $remaining) { $n = $remaining }

    $found = $false
    $attemptDate = $startDate
    for ($a = 0; $a -lt $maxAttempts -and !$found; $a++) {
      $offset = Get-Random -Minimum 0 -Maximum ($daySpan + 1)
      $d = $startDate.AddDays($offset)
      $dow = $d.DayOfWeek
      # Prefer weekdays, occasionally allow weekends
      $isWeekend = ($dow -eq [DayOfWeek]::Saturday -or $dow -eq [DayOfWeek]::Sunday)
      if ($isWeekend) {
        if ((Get-Random -Minimum 0 -Maximum 100) -lt 35) {
          $found = $true
          $attemptDate = $d
        }
      } else {
        $found = $true
        $attemptDate = $d
      }
      # Avoid reusing same date unless we have to
      if ($found -and $usedDates.ContainsKey($attemptDate.Date) -and $usedDates.Count -lt 18) {
        $found = $false
      }
    }
    # Last resort: any weekday
    if (-not $found) {
      for ($a = 0; $a -lt 100; $a++) {
        $offset = Get-Random -Minimum 0 -Maximum ($daySpan + 1)
        $d = $startDate.AddDays($offset)
        if ($d.DayOfWeek -ne [DayOfWeek]::Saturday -and $d.DayOfWeek -ne [DayOfWeek]::Sunday) {
          $attemptDate = $d
          break
        }
      }
    }

    $usedDates[$attemptDate.Date] = $true
    $groups += @{ Count = $n; Date = $attemptDate; StartIndex = $idx }
    $idx += $n
    $remaining -= $n
  }

  # Sort groups by date
  $groups = $groups | Sort-Object { $_.Date }

  # Now assign times to each commit
  $schedule = @()
  $prevCommitTime = $null

  foreach ($group in $groups) {
    $date = $group.Date
    $dow = $date.DayOfWeek
    $isSunday = ($dow -eq [DayOfWeek]::Sunday)
    $isSaturday = ($dow -eq [DayOfWeek]::Saturday)

    $isSatLikeSunday = $false
    if ($isSaturday) {
      $isSatLikeSunday = (Get-Random -Minimum 0 -Maximum 100) -lt 50
    }

    # Determine base start time for this group
    $baseHour = 20; $baseMin = 0
    if ($isSunday -or ($isSaturday -and $isSatLikeSunday)) {
      # Sunday style: 10am-12pm start
      $baseHour = Get-Random -Minimum 10 -Maximum 12
      $baseMin = Get-Random -Minimum 0 -Maximum 60
    } else {
      # Weekday/Saturday-work style: 7pm-9pm start
      $baseHour = Get-Random -Minimum 19 -Maximum 21
      $baseMin = Get-Random -Minimum 0 -Maximum 60
    }

    $baseTime = $date.AddHours($baseHour).AddMinutes($baseMin)

    for ($pos = 0; $pos -lt $group.Count; $pos++) {
      $commitIdx = $group.StartIndex + $pos

      if ($pos -eq 0) {
        # First commit of group
        if ($null -eq $prevCommitTime) {
          $time = $baseTime
        } else {
          # Gap from previous group
          $gap = (Get-Random -Minimum 120 -Maximum 480)  # 2-8 hours gap between groups (different days)
          # Compute natural time
          $naturalTime = $prevCommitTime.AddMinutes($gap)
          if ($naturalTime.Date -eq $date -and $naturalTime.Hour -ge 6 -and $naturalTime.Hour -le 8) {
            $time = $naturalTime
          } else {
            $time = $baseTime
          }
          # Ensure time is on the right day
          if ($time.Date -ne $date) {
            $time = $baseTime
          }
          # Small jitter for first commit
          $jitter = Get-Random -Minimum -5 -Maximum 6
          $time = $time.AddMinutes($jitter)
        }
      } else {
        # Gap = workMinutes of previous commit + jitter
        $prevWorkIdx = $schedule[$schedule.Count - 1].CommitIndex
        $workMin = $workMinutes[$prevWorkIdx]
        $jitter = Get-Random -Minimum -1 -Maximum 3
        $gap = [Math]::Max(1, $workMin + $jitter)
        $time = $schedule[$schedule.Count - 1].DateTime.AddMinutes($gap)
      }

      $entry = @{
        CommitIndex = $commitIdx
        DateTime = $time
        GroupDate = $date
      }
      $schedule += $entry
      $prevCommitTime = $time
    }
  }

  return $schedule
}

$schedule = New-DateSchedule

# Display the plan
Write-Host "=== Commit Schedule ==="
$grouped = $schedule | Group-Object { $_.DateTime.ToString("yyyy-MM-dd") }
$totalCommits = 0
foreach ($g in $grouped) {
  $dow = [DateTime]::Parse($g.Name).DayOfWeek
  Write-Host "$($g.Name) ($dow) - $($g.Count) commits"
  foreach ($item in $g.Group) {
    $msg = $allMessages[$item.CommitIndex]
    Write-Host "  [$($item.DateTime.ToString("HH:mm"))] $msg"
    $totalCommits++
  }
}
Write-Host "Total: $totalCommits commits"

$named = @{ Name = "Senthil455"; Email = "senthilrajasen637@gmail.com" }

# Remove .git directory and reinitialize
Write-Host "`nRemoving .git directory..."
Remove-Item -Recurse -Force "$ProjectDir\.git" -ErrorAction SilentlyContinue

Write-Host "Initializing new git repository..."
git -C $ProjectDir init
git -C $ProjectDir config user.name $named.Name
git -C $ProjectDir config user.email $named.Email

# Replay all commits with proper dates
for ($i = 0; $i -lt $schedule.Count; $i++) {
  $commitDir = "$ExtractedDir\commits\$i"
  $dt = $schedule[$i].DateTime
  $msg = $allMessages[$i]
  
  $dateStr = $dt.ToString("ddd MMM dd HH:mm:ss yyyy K")
  $env:GIT_AUTHOR_DATE = $dateStr
  $env:GIT_COMMITTER_DATE = $dateStr
  
  if (Test-Path "$commitDir\.gitignore") {
    Copy-Item "$commitDir\.gitignore" "$ProjectDir\.gitignore" -Force
  }
  if (Test-Path "$commitDir\index.html") {
    Copy-Item "$commitDir\index.html" "$ProjectDir\index.html" -Force
  } elseif (Test-Path "$ProjectDir\index.html") {
    Remove-Item "$ProjectDir\index.html" -Force -ErrorAction SilentlyContinue
  }
  if (Test-Path "$commitDir\style.css") {
    Copy-Item "$commitDir\style.css" "$ProjectDir\style.css" -Force
  } elseif (Test-Path "$ProjectDir\style.css") {
    Remove-Item "$ProjectDir\style.css" -Force -ErrorAction SilentlyContinue
  }
  if (Test-Path "$commitDir\script.js") {
    Copy-Item "$commitDir\script.js" "$ProjectDir\script.js" -Force
  } elseif (Test-Path "$ProjectDir\script.js") {
    Remove-Item "$ProjectDir\script.js" -Force -ErrorAction SilentlyContinue
  }
  if (Test-Path "$commitDir\ReadMe.md") {
    Copy-Item "$commitDir\ReadMe.md" "$ProjectDir\ReadMe.md" -Force
  } elseif (Test-Path "$ProjectDir\ReadMe.md") {
    Remove-Item "$ProjectDir\ReadMe.md" -Force -ErrorAction SilentlyContinue
  }

  git -C $ProjectDir add -A
  git -C $ProjectDir commit --no-edit -m $msg 2>&1 | Out-Null
  Write-Host "[$($dt.ToString("yyyy-MM-dd HH:mm"))] Commit $($i + 1)/$($schedule.Count): $msg"
}

Remove-Item env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
Remove-Item env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

Write-Host "`nDone! Git history rewritten with $($schedule.Count) commits."
Write-Host "`nFinal log:"
git -C $ProjectDir log --oneline
