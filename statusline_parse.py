
import sys, json, os, time

d = json.load(sys.stdin)
model  = d.get('model', {}).get('display_name', '?')
ctx    = round(d.get('context_window', {}).get('used_percentage', 0))
cost   = d.get('cost', {}).get('total_cost_usd', 0)
effort = d.get('effort', {}).get('level', '') or d.get('model', {}).get('thinking_level', '') or ''
raw    = d.get('workspace', {}).get('current_dir', os.getcwd())
raw    = raw.replace(chr(92), '/')
home   = os.path.expanduser('~').replace(chr(92), '/')
if raw.startswith(home):
    raw = '~' + raw[len(home):]
parts  = raw.split('/')
short  = ('.../' + '/'.join(parts[-2:])) if len(parts) > 3 else raw

rl = d.get('rate_limits', {})

def reset_in(block):
    ts = block.get('resets_at')
    if not ts:
        return ''
    secs = int(ts) - int(time.time())
    if secs <= 0:
        return 'now'
    days, rem = divmod(secs, 86400)
    hrs, rem  = divmod(rem, 3600)
    mins      = rem // 60
    if days:
        return f'{days}d{hrs}h'
    if hrs:
        return f'{hrs}h{mins:02d}m'
    return f'{mins}m'

fh = rl.get('five_hour', {})
wk = rl.get('seven_day', {})
fh_pct   = round(fh.get('used_percentage', 0))
wk_pct   = round(wk.get('used_percentage', 0))
fh_reset = reset_in(fh)
wk_reset = reset_in(wk)

print(f"{model}|{ctx}|{cost:.2f}|{short}|{effort}|{fh_pct}|{fh_reset}|{wk_pct}|{wk_reset}")
