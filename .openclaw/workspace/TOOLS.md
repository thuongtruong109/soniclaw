# TOOLS.md - Local Notes

## Browser Automation

- **Skill:** browser-automator (in `/root/.openclaw/workspace/skills/public/browser-automator/`)
- **Remote CDP:** `http://host.docker.internal:9222`
- **Chrome Setup:** Launched with `--remote-debugging-port=9222` on Windows
- **Default Behavior:** Auto-use this skill for any browser navigation/search/automation requests
- **Snapshot Mode:** Always use `--interactive` for semantic refs (`e1`, `e2`, etc.)
- **Auto-connect:** No manual setup needed — config already in `openclaw.json`

**When to use:**

- Users asks to interact with a website, navigate to a URL, search/find something, click, type, fill forms, snapshot/scrape/monitor web pages, screenshots/page/specific area inspection...

## ⏰ Timezone Configuration

- ❌ Do NOT use `session_status` time (it is in UTC, not local time).
- ✅ ALWAYS use `timezone_utils.py` for time calculations.
- Current Timezone: Asia/Ho_Chi_Minh (UTC+7). Can pre-check to get current local time exactly:

```bash
bash /root/.openclaw/workspace/scripts/check-timezone.sh
```

**When to use:**

- When you need to display or process times in the local timezone.
- When you need to schedule or trigger events based on local time.
