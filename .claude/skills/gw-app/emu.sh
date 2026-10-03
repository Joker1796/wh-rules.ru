#!/bin/bash
# Drive "Warhammer 40,000: The App" in the Android emulator by on-screen TEXT, not coordinates.
# See SKILL.md next to this file. Usage:
#   emu.sh start                    # boot the AVD headless (blocks until booted), launch the app
#   emu.sh tap "<regex>" [nth] [s]  # tap the nth (0-based) node whose text/content-desc matches; wait s sec (3)
#   emu.sh texts [width]            # every visible text node, one per line (cut to width, 160)
#   emu.sh shot <name>              # screenshot → $OUT/<name>.png, plus a half-size <name>s.png to read
#   emu.sh swipe-up [toY]           # scroll down a screen (finger 1900 → toY, default 700)
#   emu.sh swipe-down               # scroll back up a screen
#   emu.sh type "<text>"            # type into the focused field, then hide the keyboard
#   emu.sh back                     # system Back
#   emu.sh stop                     # shut the emulator down
# $OUT defaults to the session scratchpad if set, else /tmp/gw-app.
A=~/Library/Android/sdk/platform-tools/adb
EMU=~/Library/Android/sdk/emulator/emulator
AVD=${GW_AVD:-playstore36}
OUT=${OUT:-${SCRATCH:-/tmp/gw-app}}
mkdir -p "$OUT"
dump() { $A shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1; $A exec-out cat /sdcard/ui.xml > "$OUT/ui.xml"; }
case "$1" in
  start)
    if ! $A devices | grep -q emulator; then
      nohup $EMU -avd "$AVD" -no-window -no-audio -no-boot-anim -no-snapshot-save -gpu swiftshader_indirect >"$OUT/emulator.log" 2>&1 &
    fi
    $A wait-for-device
    until [ "$($A shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 3; done
    $A shell monkey -p com.gamesworkshop.w40k -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    sleep 20; echo "booted; app $($A shell dumpsys package com.gamesworkshop.w40k | grep -m1 versionName | tr -d ' ')";;
  tap) dump; python3 - "$2" "${3:-0}" "$A" "$OUT/ui.xml" <<'PY'
import re, sys, subprocess
pat, nth, adb, xml = re.compile(sys.argv[1], re.I), int(sys.argv[2] or 0), sys.argv[3], sys.argv[4]
hits = []
for m in re.finditer(r'<node [^>]*>', open(xml, encoding='utf-8').read()):
    n = m.group(0)
    t = re.search(r' text="([^"]*)"', n); d = re.search(r'content-desc="([^"]*)"', n)
    s = ((t.group(1) if t else '') + ' ' + (d.group(1) if d else '')).strip()
    b = re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', n)
    if s and pat.search(s) and b: hits.append((s, [int(v) for v in b.groups()]))
if len(hits) <= nth:
    print('NOT FOUND', sys.argv[1], [h[0][:40] for h in hits][:5]); sys.exit(1)
s, (x1, y1, x2, y2) = hits[nth]
print('tap', s[:70]); subprocess.run([adb, 'shell', 'input', 'tap', str((x1 + x2) // 2), str((y1 + y2) // 2)])
PY
    r=$?; sleep "${4:-3}"; exit $r;;
  texts) dump; python3 - "$OUT/ui.xml" "${2:-160}" <<'PY'
import re, sys, html
w = int(sys.argv[2])
for m in re.finditer(r'<node [^>]*>', open(sys.argv[1], encoding='utf-8').read()):
    n = m.group(0)
    t = re.search(r' text="([^"]*)"', n); d = re.search(r'content-desc="([^"]*)"', n)
    s = html.unescape((t.group(1) if t and t.group(1) else (d.group(1) if d else '')).strip())
    if s and s != 'Datasheet image': print(s.replace('\n', ' | ')[:w])
PY
    ;;
  shot) $A exec-out screencap -p > "$OUT/$2.png"
    python3 -c "from PIL import Image; im=Image.open('$OUT/$2.png'); im.resize((im.width//2, im.height//2)).save('$OUT/${2}s.png')" 2>/dev/null
    echo "$OUT/${2}s.png";;
  swipe-up) $A shell input swipe 540 1900 540 "${2:-700}" 500; sleep 1.5;;
  swipe-down) $A shell input swipe 540 700 540 1900 500; sleep 1.5;;
  type) $A shell input text "$(printf '%s' "$2" | sed 's/ /%s/g')"; sleep 1; $A shell input keyevent 4; sleep 1;;
  back) $A shell input keyevent 4; sleep 2;;
  stop) $A emu kill >/dev/null 2>&1; echo stopped;;
  *) sed -n 2,13p "$0";;
esac
