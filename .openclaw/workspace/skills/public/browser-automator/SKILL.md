---
name: browser-automator
description: Automate browser actions and workflows using OpenClaw's managed browser. Use when you need to (1) Navigate websites and extract data, (2) Fill forms and submit information, (3) Click buttons and interact with page elements, (4) Take screenshots or perform complex multi-step sequences, (5) Scrape or monitor web pages, (6) Simulate user interactions, or (7) Manage browser state (cookies, storage, auth). Supports snapshots with semantic element references, waiting for page conditions, and advanced Playwright-based actions.
---

# Browser Automator

Automate web browser interactions using OpenClaw's managed browser via the `openclaw browser` CLI.

## 📋 CLI Quick Reference

All commands accept `--browser-profile <name>` to target a specific profile.
All commands also accept `--json` for machine-readable output.

### Basics

```bash
openclaw browser status
openclaw browser start
openclaw browser stop
openclaw browser tabs
openclaw browser tab
openclaw browser tab new
openclaw browser tab select 2
openclaw browser tab close 2
openclaw browser open https://example.com
openclaw browser focus abcd1234
openclaw browser close abcd1234
openclaw browser back
openclaw browser run
```

### Inspection

```bash
openclaw browser screenshot
openclaw browser screenshot --full-page
openclaw browser screenshot --ref 12
openclaw browser screenshot --ref e12
openclaw browser snapshot
openclaw browser snapshot --format aria --limit 200
openclaw browser snapshot --interactive --compact --depth 6
openclaw browser snapshot --efficient
openclaw browser snapshot --labels
openclaw browser snapshot --selector "#main" --interactive
openclaw browser snapshot --frame "iframe#main" --interactive
openclaw browser console --level error
openclaw browser errors --clear
openclaw browser requests --filter api --clear
openclaw browser pdf
openclaw browser responsebody "**/api" --max-chars 5000
```

### Actions

```bash
openclaw browser navigate https://example.com
openclaw browser resize 1280 720
openclaw browser click 12 --double
openclaw browser click e12 --double
openclaw browser type 23 "hello" --submit
openclaw browser press Enter
openclaw browser hover 44
openclaw browser scrollintoview e12
openclaw browser drag 10 11
openclaw browser select 9 OptionA OptionB
openclaw browser download e12 report.pdf
openclaw browser waitfordownload report.pdf
openclaw browser upload /tmp/openclaw/uploads/file.pdf
openclaw browser fill --fields '[{"ref":"1","type":"text","value":"Ada"}]'
openclaw browser dialog --accept
openclaw browser wait --text "Done"
openclaw browser wait "#main" --url "**/dash" --load networkidle --fn "window.ready===true"
openclaw browser evaluate --fn '(el) => el.textContent' --ref 7
openclaw browser highlight e12
openclaw browser trace start
openclaw browser trace stop
```

### State

```bash
openclaw browser cookies
openclaw browser cookies set session abc123 --url "https://example.com"
openclaw browser cookies clear
openclaw browser storage local get
openclaw browser storage local set theme dark
openclaw browser storage session clear
openclaw browser set offline on
openclaw browser set headers --headers-json '{"X-Debug":"1"}'
openclaw browser set credentials user pass
openclaw browser set credentials --clear
openclaw browser set geo 37.7749 -122.4194 --origin "https://example.com"
openclaw browser set geo --clear
openclaw browser set media dark
openclaw browser set timezone America/New_York
openclaw browser set locale en-US
openclaw browser set device "iPhone 14"
```

---

## 📌 Important Notes

- **`upload` và `dialog`** là arming calls — chạy chúng **trước** khi click/press trigger chooser/dialog.
- **Download & trace** output paths bị giới hạn trong OpenClaw temp roots:
  - traces: `/tmp/openclaw`
  - downloads: `/tmp/openclaw/downloads`
- **Upload** paths bị giới hạn trong: `/tmp/openclaw/uploads`
- `upload` cũng có thể set file inputs trực tiếp via `--input-ref` hoặc `--element`.

---

## 🔍 Snapshots & Element References

OpenClaw hỗ trợ hai kiểu snapshot:

### AI Snapshot (Numeric refs) — default

```bash
openclaw browser snapshot
```

- Output: numeric refs như `aria-ref="12"`
- Actions: `openclaw browser click 12`, `openclaw browser type 23 "text"`

### Role Snapshot (Role refs `e12`) ⭐ Recommended for automation

```bash
openclaw browser snapshot --interactive
```

- Output: flat list với `[ref=e12]`
- Actions: `openclaw browser click e12`, `openclaw browser highlight e12`
- Internally resolved via `getByRole(...)` (plus `nth()` for duplicates)
- Thêm `--labels` để overlay ref labels lên screenshot

**Options cho role snapshot:**

- `--interactive` — chỉ interactive elements (best for actions)
- `--compact` — rút gọn output
- `--depth 6` — limit tree depth
- `--selector "#main"` — scope to CSS selector
- `--frame "iframe#main"` — scope to iframe (role refs sẽ scoped đến iframe đó)
- `--efficient` (hoặc `--mode efficient`) — compact preset, thấp maxChars

> ⚠️ **Refs không stable qua navigations** — re-run `snapshot` sau mỗi page change.

---

## ⏳ Wait Power-ups

Combine nhiều conditions trong một lệnh:

```bash
openclaw browser wait "#main" \
  --url "**/dash" \
  --load networkidle \
  --fn "window.ready===true"
```

| Condition            | Example                                            |
| -------------------- | -------------------------------------------------- |
| CSS selector visible | `openclaw browser wait "#main"`                    |
| URL glob             | `openclaw browser wait --url "**/dash"`            |
| Load state           | `openclaw browser wait --load networkidle`         |
| JS predicate         | `openclaw browser wait --fn "window.ready===true"` |
| Text appears         | `openclaw browser wait --text "Done"`              |

---

## 🔄 Core Workflows

### Workflow 1: Form Filling & Submission

```bash
openclaw browser navigate https://form.example.com
openclaw browser snapshot --interactive
openclaw browser type e1 "Ada Lovelace"
openclaw browser type e2 "ada@example.com"
openclaw browser click e3
openclaw browser wait --text "Success"
```

### Workflow 2: Web Scraping

```bash
openclaw browser navigate https://example.com
openclaw browser snapshot --interactive
# Extract data from snapshot output
openclaw browser click e5  # next page button
openclaw browser wait --load networkidle
# Repeat
```

### Workflow 3: Screenshot & Monitoring

```bash
openclaw browser screenshot --full-page                   # full page screenshot (Do NOT use this for specific regions)
openclaw browser snapshot --interactive --labels          # overlay refs on screenshot
openclaw browser screenshot --ref e12                     # specific element/region screenshot (Use this when user asks to capture a specific area)
openclaw browser screenshot --selector ".my-class"        # specific region via CSS selector
```

### Workflow 4: File Download & Image Fetching

```bash
openclaw browser download e12 report.pdf                  # arm download, click triggers it
openclaw browser waitfordownload report.pdf               # wait for completion
# File at: /tmp/openclaw/downloads/report.pdf
```

**Note on downloading images directly from a webpage without a download button:**
Nếu user yêu cầu tải ảnh từ web (không có nút download), hãy parse URL của ảnh qua HTML hoặc snapshot, sau đó dùng `curl` hoặc `wget` để tải ảnh đó về server thay vì dùng lệnh browser download.
Ví dụ:

```bash
openclaw browser evaluate --fn '(el) => el.src' --ref e5
curl -o /tmp/openclaw/downloads/image.jpg "<URL_TỪ_KẾT_QUẢ_TRÊN>"
```

### Workflow 5: File Upload

```bash
# Copy file to uploads folder first
cp myfile.pdf /tmp/openclaw/uploads/
openclaw browser upload /tmp/openclaw/uploads/myfile.pdf   # arm upload
openclaw browser click e5                                   # trigger file chooser
```

### Workflow 6: Dialog Handling

```bash
openclaw browser dialog --accept                  # arm acceptance
openclaw browser click e8                         # trigger dialog
```

---

## 🔒 Security

- **`openclaw` profile** never touches your personal browser data
- **`user` profile** has full access to your logged-in sessions (high-trust)
- Avoid hardcoding passwords — use cookies, env vars, or config
- Keep Gateway on private network (Tailscale / loopback)

---

## Resources

- **`scripts/form_fill_example.py`** — Complete form automation example
- **`references/api_reference.md`** — All CLI commands (extended)
- **`references/snapshots_and_refs.md`** — Deep dive into snapshot modes
- **`references/advanced_actions.md`** — PDF, downloads, file upload, tracing
- **`references/configuration.md`** — Multi-profile, remote CDP, Playwright setup
