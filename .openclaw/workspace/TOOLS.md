# TOOLS.md - Local Notes

## Browser Automation (Default Behavior)

- Automatically and mandatorily use the **browser-automator** skill from `/root/.openclaw/workspace/skills/public/browser-automator/`
- Always connect to **Remote CDP URL** (via openclaw.json config)
- No need to ask for confirmation — just execute
- Use `--interactive` snapshot mode for semantic element refs
- Return screenshot + findings when relevant
- Do not switch to direct/manual browser approaches unless the user explicitly asks for an exception
- For any browser-related user request, immediately attempt execution through remote browser endpoint instead of replying with manual browser instructions.
- Always start by confirming remote browser endpoint is reachable at <remote browser endpoint_REMOTE_URL_FROM_CONFIG> and then perform the requested actions flow.
- **Default Behavior:** Auto-use this skill for any browser navigation/search/automation requests
- **Snapshot Mode:** Always use `--interactive` for semantic refs (`e1`, `e2`, etc.)
- **Auto-connect:** No manual setup needed — config already in `openclaw.json`

**When to use:**

- When user asks for browser actions, or skill involves browser activity (interact with a website, navigate to a URL, search/find something, click, type, scrape, fill forms, site checks, web app actions, snapshot/scrape/monitor web pages, screenshots/page/specific area inspection, etc.)

## ⏰ Timezone Configuration & Time Handling

- ❌ Do NOT use `session_status` time (it is in UTC, not local time).
- ✅ ALWAYS use `timezone_utils.py` for time calculations.
- Current Timezone: Asia/Ho_Chi_Minh (UTC+7). Can pre-check to get current local time exactly:

```bash
bash /root/.openclaw/workspace/scripts/check-timezone.sh
```

**When to use:**

- When you need to display or process times in the local timezone.
- When you need to schedule or trigger events based on local time.

**CRITICAL:** Before answering ANYTHING about dates, times, or "X days/weeks ago":

2. **Use** `/root/.openclaw/workspace/scripts/timezone_utils.py` to get accurate current time
3. **Never assume** timezone — always check USER.md first
4. **Remember:** Session status shows UTC, but you need local time (Vietnam = UTC+7)

This ensures accuracy for any time-dependent logic
