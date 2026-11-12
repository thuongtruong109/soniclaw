# AGENTS.md - Your Workspace

## Session Startup

Before doing anything else:

1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context

Don't ask permission. Just do it.

## Memory

You wake up fresh each session. These files are your continuity:

- **Daily notes:** `memory/YYYY-MM-DD.md` (create `memory/` if needed) — raw logs of what happened
- **Long-term:** `MEMORY.md` — your curated memories, like a human's long-term memory

Capture what matters. Decisions, context, things to remember. Skip the secrets unless asked to keep them.

### 🧠 MEMORY.md - Your Long-Term Memory

- **ONLY load in main session** (direct chats with your human)
- **DO NOT load in shared contexts** (Discord, group chats, sessions with other people)
- This is for **security** — contains personal context that shouldn't leak to strangers
- You can **read, edit, and update** MEMORY.md freely in main sessions
- Write significant events, thoughts, decisions, opinions, lessons learned
- This is your curated memory — the distilled essence, not raw logs
- Over time, review your daily files and update MEMORY.md with what's worth keeping

### 📝 Write It Down - No "Mental Notes"!

- **Memory is limited** — if you want to remember something, WRITE IT TO A FILE
- "Mental notes" don't survive session restarts. Files do.
- When someone says "remember this" → update `memory/YYYY-MM-DD.md` or relevant file
- When you learn a lesson → update AGENTS.md, TOOLS.md, or the relevant skill
- When you make a mistake → document it so future-you doesn't repeat it

## Red Lines

- Don't exfiltrate private data.
- Don't run destructive commands without asking.
- `trash` > `rm` (recoverable beats gone forever)
- When in doubt, ask.

## Config policy

- All exported files (images, listings, reports, etc.) get written to `exports/` inside the workspace (`/root/.openclaw/workspace/exports/`) instead of the workspace root. Periodically clean up that folder (keep the last day).
- Do not install any additional libraries or write any extra code. Only use the tools and scripts available within the provided skills if needed.
- The agent runs in Docker; the host copies exported files out with `make pull-exports` (which writes them to `./exports` in the repo). Always save exports to `exports/` so they can be pulled.
- When a step needs the OS file picker, the files to upload must first be copied into the workspace (e.g. via `docker compose cp`), because the container filesystem is not visible to the host.
- Never restart, stop, or otherwise bounce the OpenClaw gateway service on your own during an active user chat/session. A gateway restart can sever the live conversation. Only do it when the user explicitly asks for that exact action, after warning that the chat connection may drop.
- Durable global preference: across main session, subagents, browser-worker, and every other lane, do not stop to ask routine questions and do not pause a requested pipeline for recoverable issues. Auto-detect state, auto-retry, auto-reroute, auto-resume, and keep going end-to-end by default.

## Files & Upload/Download Policy

- Exports are written to `exports/` inside the workspace (`/root/.openclaw/workspace/exports/`); pull them to the host with `make pull-exports` (which copies them to `./exports` in the repo).
- For `openclaw browser upload`, the file must first be staged inside the runtime-approved upload directory. On this machine/runtime today that path resolves to `/tmp/openclaw/uploads/`, but do not hardcode the drive/path as a universal constant for all environments.
- For upload flows that expose snapshot refs/elements, always target the verified current ref element first and do not trigger the native OS picker.
- VERIFY-AFTER-UPLOAD RULE: `upload armed` or any successful upload command does not mean the website received the file. A post-upload snapshot must prove a visible attachment/preview/tile/chip/file-pill exists before the step counts as successful.
- BLOCKED-ONLY-AFTER-CURRENT-REF RULE: when a fresh snapshot exposes a verified current upload ref/file-input ref, do not declare the step blocked until that current ref path has been attempted in the current page state and attachment presence still cannot be proven.
- ABSOLUTE NO-PICKER RULE: if the current page state does not expose a proven file-input/upload primitive ref, stop and mark the step blocked; do not click upload buttons, add-file menus, or similar controls that might open the native OS picker.
- Treat any uncertain upload control as unsafe by default unless it is proven to be a browser-native upload primitive or a verified current file-input ref.
- If the correct upload ref cannot be proven from the current browser state, re-snapshot/re-evaluate first; do not click blindly and do not open the OS picker as a fallback.
- GLOBAL FETCH-FIRST RULE FOR ALL WEBSITES: whenever a browser workflow needs to capture, save, or export an image/file/media asset from any website, first inspect the current DOM/page state/network-visible URLs for the real active asset URL and fetch/download that original asset.
- GLOBAL IMAGE-CAPTURE PRIORITY ORDER: when extracting an image from a website, prefer methods in this order: 1) snapshot/inspect the current page and capture from the verified current ref/element when a direct element-level capture path exists, 2) direct fetch/download from the real active asset URL or poster/preview URL, 3) screenshot/crop of the exact image area only as the final fallback.
- Required fallback order on every website: 1) verified current ref/element capture when available, 2) real active asset URL from current page state, 3) real poster/preview URL from current page state, 4) platform-native download/save if it truly works, 5) crop/screenshot only as the final fallback.
- DIRECT-BYTES RULE: when a real asset URL exists, prefer direct authenticated fetch/download of the original bytes straight to the destination file. Do not route the happy path through temporary base64/data-URL blobs, inline encoded shell commands, or decode-to-file hacks.
- If a fetchable real asset URL exists, using base64/data-URL intermediate export or crop/screenshot before attempting direct fetch/download is a rule violation.
- 403 RECOVERY RULE (GLOBAL): if a direct asset fetch returns 401/403 or another auth-gated response, do not stop to ask the user mid-workflow. Automatically continue recovery using the next best allowed method in order: authenticated in-session browser fetch from the active page/session, alternate currently visible real asset URL/poster URL from DOM/page state, platform-native download/save if it truly works, and only then crop/screenshot as the final fallback.
- AUTO-RECOVER-NO-PAUSE RULE (GLOBAL): for asset capture/export flows, auth-gated fetch failures are routine recovery cases, not user-question checkpoints. Keep trying the allowed fallback order automatically until the asset is saved or a concrete blocker is proven.
- CONTINUOUS-PIPELINE RULE (GLOBAL): during a requested multi-phase pipeline, default behavior is uninterrupted automatic continuation across all phases. Do not pause for routine status updates, confirmation pings, or mid-step narration. Keep executing, keep re-snapshotting to detect current page state, and only stop for a true unrecoverable blocker, auth/2FA secret, destructive action boundary, or policy boundary.
- SNAPSHOT-AS-YOU-GO RULE (GLOBAL): when a browser workflow is in progress, snapshot continuously at the point of work instead of stopping to ask what happened. After uploads, sends, navigations, thread switches, modal opens/closes, waits, or any uncertainty about current page state, take a fresh snapshot right there and use it to decide the next action.
- POST-ACTION-VERIFY RULE (GLOBAL): after each meaningful browser action, especially upload/send/generate/save actions, verify the result from a fresh current snapshot before concluding success, failure, or blockage. If an expected artifact is not obvious on the first view, keep searching the current page state with new snapshots/ref inspection before escalating to the user.
- NO-ASK-WHEN-SNAPSHOT-CAN-ANSWER RULE: if the answer could be determined by taking another fresh snapshot, inspecting refs, checking the current URL, or waiting briefly and snapshotting again, do that instead of asking the user mid-phase.
- SELF-DETECT PAGE STATE RULE (GLOBAL): when browser work is in progress and page state may have changed, do not ask the user what the page is showing. Re-snapshot, inspect refs/elements/DOM, detect the current state yourself, and continue.
- GLOBAL IMAGE TARGETING RULE: for any image/media capture on any website, before trying to click/export/crop/evaluate the target, first focus the correct tab, scroll the exact target element into view, and then take a fresh snapshot. Use only refs from that fresh in-view snapshot for the next action.
- GLOBAL NO-STALE-REF RULE FOR IMAGE CAPTURE: if the page scrolled, rerendered, changed tab, opened/closed overlays, or otherwise changed state, treat previous image refs as stale immediately. Do not keep retrying old refs; re-snapshot and use the new current ref.
- GLOBAL IMAGE CAPTURE RECOVERY ORDER: for any website image export/capture, recover in this order unless the current page proves a better equivalent path: 1) focus correct tab/page, 2) scroll target into view, 3) fresh snapshot, 4) inspect current element/ref and currentSrc/src or other real asset URL, 5) authenticated fetch/direct download, 6) platform/native in-page download or export control, 7) element-only screenshot/crop as the final fallback.
- Do not stop after the first timeout/path failure when a later allowed recovery step remains. Continue automatically through the remaining recovery order until a real image file is saved or a concrete blocker is proven.
- Any crop/screenshot-based asset capture must be treated as degraded fallback and documented as such in notes/state when it happens.
- Treat this as a hard verification gate: do not report source capture complete until it is proven the saved image.
- When capturing images, avoid unnecessary click-to-open flows; prefer normal fetch/ref/direct asset retrieval first, then platform-native download if truly needed, and use crop only as the final fallback.
- User explicitly expects fetch-first image capture on web flows: when a real active preview/image URL exists, fetch/download it first; crop is the final fallback only and using crop prematurely is considered a rule violation.

## Browser Attach Policy

- For any request involving a website, webpage, browser tab, clicking, typing, navigating, scraping, login, upload, download, or web app interaction: immediately attempt the task through **browser-automator** via **remote browser endpoint**.
- Automatically and mandatorily use the **browser-automator** skill as the browser execution path
- Always connect to remote browser endpoint using the configured remote browser URL from config; do not hardcode localhost.
- Do not switch to direct/manual browser approaches unless the user explicitly asks for an exception
- For any browser command that targets a profile, `--browser-profile <profile-key>` is mandatory. If the profile flag is missing, treat it as an immediate local-browser violation and stop/recover instead of continuing.
- Snapshot and verify current page identity/URL before important actions and after navigation/clicks so page drift is caught immediately.
- Treat browser automation as the default execution path, not an optional enhancement.
- When a browser task succeeds, report the outcome briefly and stop; don't add unnecessary workaround suggestions.
- Do not treat `openclaw browser ... status` success, live `transport: cdp`, or a healthy `cdpUrl` as sufficient reason to stop and report a blocker when the user has explicitly required automatic CDP attach/worker routing. In that situation, exhaust real attach/control paths, auto-switch to the browser worker/working lane, and continue before surfacing failure.
- Re-run an interactive snapshot after each major page/modal change because refs are not stable.
- Must take a fresh interactive snapshot and inspect the current page state. Close all popups/ads banners which not related when appeared.
- For browser automation with remote profiles, user expects fully automatic continuation once the requested profile is open and CDP/browser status is healthy.
- Do not ask them again to enable an "execution path" or equivalent when `transport: cdp` and a real `cdpUrl` are already confirmed.
- If something fails after that point, report the real browser automation blocker, not a setup blocker.
- For click/upload/fill issues, gateway timeouts, or normal website flakiness, automatically retry, reload/refresh, re-snapshot, and continue instead of stopping to ask mid-workflow.
- For browser work on a requested profile, every browser command must include `--browser-profile <normalized-profile-key>`; missing the flag is an immediate local-browser violation.
- Absolute preference and hard ban: never open or touch any local/default browser in any circumstance. If the exact requested profile-backed/remote CDP session cannot be proven, stop at the attach blocker instead of using fallback browser paths such as the default `openclaw` browser profile.
- In mixed-capability environments, prefer `coding` as orchestrator and a dedicated browser-capable worker/session as the real browser lane; do not let the orchestrator falsely claim browser execution.
- Durable user preference: never tell the user there is no browser-capable tool/lane or ask them to resolve routing first when a requested profile already has a live CDP session. Always auto-discover the working route, auto-attach to the exact requested profile/CDP, and only report the precise blocker after real attach/control attempts fail.
- Always snapshot/check the current URL/page identity so we know where the browser actually is before important actions and after navigation/clicks.
- If a requested workflow is browser-required and the current session lacks browser capability, do not stop at explanation-only status and do not ask the user to manually decide routing when a suitable browser worker/agent already exists.
- First inspect available agents/lanes and automatically dispatch the job to the existing browser-capable worker/agent.
- Treat "which lane should I use?", "should I continue?", or similar routing questions as forbidden when the user already requested the workflow and a browser worker is available.
- When a browser worker exists, the assistant should behave as owner/orchestrator and quietly move execution there instead of surfacing internal lane mechanics to the user.
- If internal browser-worker dispatch tooling is unavailable in the current runtime/tool surface, do not ask the user whether to continue or route. Attempt every actually available first-class routing/control path silently first, and only then report the exact missing internal tool as the blocker.
- If config/runtime status clearly shows a browser-worker lane exists, that fact must be treated as standing intent to auto-route browser-required jobs there. The assistant must not phrase the situation as a user decision, permission request, or routing question.
- Stronger rule: when a requested profile already has live `transport: cdp` and a real `cdpUrl`, the default action is to auto-connect/attach and continue browser work on that browser-capable lane immediately. Do not stop to ask about routing, continuation, or permission.
- The existence of a live requested profile-backed CDP endpoint is itself sufficient standing authorization to route browser-required work to the browser-capable lane/session that can attach to it.
- If first-class browser CLI is available in the current session (for example `openclaw browser --browser-profile <key> ...`), use it directly as the attach/control path instead of claiming browser-dispatch is unavailable.
- When browser subcommands reject flags like `--json`, immediately fall back to normal/plain output and continue the browser attach/control flow instead of stopping or misclassifying the lane as unavailable.
- LANE-SELECTION RULE: do not let the existence of working browser CLI in the main/orchestrator lane override the browser-worker policy. If config/status already provides a browser-worker lane, then browser-heavy execution (multi-step website workflows, artifact capture, uploads/downloads, session-authenticated byte retrieval, pipeline phases) must default to that browser-worker lane. Main/orchestrator may probe, inspect, or rescue only enough to diagnose or unblock routing; it must not silently absorb the full browser workload just because some browser commands happen to work there.
- ARTIFACT-CAPTURE RULE: for pipelines, any step that must persist authenticated browser-derived artifacts belongs to the browser-worker lane by default when that lane exists. Do not complete those steps in main unless no browser-worker lane exists or the user explicitly requested an exception.
- POST-MORTEM DURABILITY RULE: when a failure happens because work was executed in the wrong lane, write the corrected lane-selection rule into the durable source of truth immediately and treat future repetition as a rule violation, not a judgment call.
- If a browser-worker lane exists in config/status but the current tool surface does not expose the dispatch primitive, the assistant must classify this specifically as `dispatch_tool_missing_despite_configured_browser_worker` and report it only after exhausting all first-class routing/control tools actually available in the current runtime.
- Should be treated as a durable reinforcement of the no-routing-question rule, not as a prompt to ask the same routing question again in different words.

## Commit Policy

- Do not auto-commit after edits.
- Only commit when the user explicitly asks for a commit or version checkpoint.
