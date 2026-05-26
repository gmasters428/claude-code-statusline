# Claude Code Status Line

A custom [Claude Code](https://claude.com/claude-code) status line showing, on two lines:

```
~/My Drive  Opus 4.7 (1M context) [high]
Ctx 5%  $0.74  5h █████░░░░░ 49% ⟳6m  Wk █████████░ 88% ⟳16h06m
```

- **Line 1:** working directory · model · thinking effort
- **Line 2:** context-window usage % · session cost · 5-hour and weekly usage bars (color-coded green → peach → red by threshold) with a reset countdown

All data comes from the native JSON Claude Code pipes to the status-line command — including `rate_limits.five_hour` / `rate_limits.seven_day` for the usage bars.

## Files

| File | Role |
|---|---|
| `statusline.sh` | Bash renderer — draws the line, colors, and usage bars |
| `statusline_parse.py` | Parses the status-line JSON from stdin into pipe-delimited fields |

## Requirements

- `bash` and `python3` on `PATH` (on Windows: Git Bash + Python)

## Install

1. Copy both files into your Claude Code config dir:
   ```
   cp statusline.sh statusline_parse.py ~/.claude/
   ```
2. Add this to `~/.claude/settings.json`:
   ```json
   "statusLine": {
     "type": "command",
     "command": "bash ~/.claude/statusline.sh"
   }
   ```
3. Restart Claude Code (or start a new session). The line refreshes live.

## Customizing

- **Colors:** edit the truecolor escape codes at the top of `statusline.sh`.
- **Bar thresholds:** the `pct_color` function (green `<50`, peach `50–79`, red `>=80`).
- **Bar width:** the `width` variable in the `bar` function (default 10 segments).
