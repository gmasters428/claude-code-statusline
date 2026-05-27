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

1. Copy both files into the **same folder** (they must stay together — the
   script locates the parser next to itself). `~/.claude/` is the convention:
   ```
   cp statusline.sh statusline_parse.py ~/.claude/
   ```
2. Add this to your `settings.json`, pointing at `statusline.sh` with an
   **absolute path** (see the important note below — do not rely on `~`):
   ```json
   "statusLine": {
     "type": "command",
     "command": "bash /ABSOLUTE/PATH/TO/.claude/statusline.sh"
   }
   ```
   - **macOS / Linux:** `bash /home/you/.claude/statusline.sh`
   - **Windows (Git Bash):** `bash /c/Users/YOU/.claude/statusline.sh`
3. Restart Claude Code (or start a new session). The line refreshes live.

> **Important — why an absolute path?** Claude Code runs the status-line
> command in a bash subshell whose `HOME` is **not guaranteed** to be your
> user folder (on some Windows setups it is `/z/`). When that happens,
> `bash ~/.claude/statusline.sh` expands `~` to the wrong place and the
> command silently fails, leaving the status line **blank**. An absolute path
> in `settings.json` avoids this. (The script itself no longer depends on `~`
> — it finds `statusline_parse.py` relative to its own location.)

## Troubleshooting

**Status line is blank / empty:**
1. Confirm `bash` and `python3` are on `PATH`: `bash -lc 'python3 --version'`.
2. The `command` path in `settings.json` almost certainly uses `~` or a wrong
   path. Replace it with the **absolute** path to `statusline.sh` (see above).
   On Windows, find yours with: `bash -lc 'echo /c/Users/$USERNAME/.claude/statusline.sh'`.
3. Test it directly with a broken `HOME` to mimic Claude Code's subshell:
   ```bash
   HOME=/z/ bash /c/Users/YOU/.claude/statusline.sh <<< '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/tmp"},"context_window":{"used_percentage":5},"cost":{"total_cost_usd":0.1}}'
   ```
   If that prints a line, the script is fine and the issue is the `settings.json` path.

## Customizing

- **Colors:** edit the truecolor escape codes at the top of `statusline.sh`.
- **Bar thresholds:** the `pct_color` function (green `<50`, peach `50–79`, red `>=80`).
- **Bar width:** the `width` variable in the `bar` function (default 10 segments).
