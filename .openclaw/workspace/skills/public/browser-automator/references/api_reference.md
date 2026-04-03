# Browser Automator - API Reference

Complete reference for all OpenClaw browser commands.

## Navigation

### `navigate <URL>`

Navigate to a URL.

```bash
openclaw browser navigate https://example.com
```

## Inspection

### `snapshot [--format ai|aria] [--interactive] [--compact] [--depth N] [--selector SELECTOR] [--labels]`

Get a page snapshot for inspection.

**Modes:**

- No options: AI snapshot with numeric refs (default)
- `--interactive`: Role snapshot with semantic refs (`[ref=e1]`)
- `--compact`: Compact output
- `--depth N`: Limit tree depth
- `--labels`: Add visual ref labels to screenshot
- `--selector SELECTOR`: Scope to CSS selector
- `--frame SELECTOR`: Scope to iframe

**Example:**

```bash
# Interactive semantic refs (recommended)
openclaw browser snapshot --interactive

# With visual labels
openclaw browser snapshot --interactive --labels

# Compact output
openclaw browser snapshot --interactive --compact
```

### `screenshot [--full-page] [--ref REF] [--selector SELECTOR]`

Take a screenshot. Use `--ref` or `--selector` if a specific region or element needs a screenshot, instead of `--full-page`.

```bash
# Full page
openclaw browser screenshot --full-page

# Element by ref (use for capturing specific regions)
openclaw browser screenshot --ref e5

# By selector (use for specific regions)
openclaw browser screenshot --selector "#main-image"

# Just the viewport
openclaw browser screenshot
```

### `tabs`

List open tabs.

```bash
openclaw browser tabs
```

## Interaction

### `click <REF> [--double]`

Click an element.

```bash
openclaw browser click e1
openclaw browser click e2 --double  # Double-click
```

### `type <REF> <TEXT> [--submit]`

Type text into an element.

```bash
openclaw browser type e2 "John Doe"
openclaw browser type e3 "search term" --submit  # Press Enter after
```

### `press <KEY>`

Press a keyboard key.

```bash
openclaw browser press Enter
openclaw browser press Escape
openclaw browser press Tab
```

### `select <REF> <OPTION> [<OPTION2> ...]`

Select options from a dropdown.

```bash
openclaw browser select e4 "Option A" "Option B"
```

### `hover <REF>`

Hover over an element.

```bash
openclaw browser hover e5
```

### `scrollintoview <REF>`

Scroll element into view.

```bash
openclaw browser scrollintoview e6
```

### `drag <SRC_REF> <DEST_REF>`

Drag one element to another.

```bash
openclaw browser drag e7 e8
```

### `evaluate [--fn FUNCTION] [--ref REF]`

Execute JavaScript in page context.

```bash
openclaw browser evaluate --fn 'window.location.href'
openclaw browser evaluate --fn '(el) => el.innerText' --ref e5
```

## Waiting

### `wait [SELECTOR] [--url GLOB] [--text TEXT] [--load STATE] [--fn PREDICATE] [--timeout-ms MS]`

Wait for conditions.

**Conditions:**

- `SELECTOR`: CSS selector to be visible
- `--url GLOB`: URL to match (glob pattern)
- `--text TEXT`: Text to appear on page
- `--load STATE`: Network state (`networkidle`, `domcontentloaded`, `load`)
- `--fn PREDICATE`: JavaScript condition
- `--timeout-ms MS`: Timeout in milliseconds

**Examples:**

```bash
# Wait for element
openclaw browser wait "#main"

# Wait for URL
openclaw browser wait --url "**/dashboard"

# Wait for text
openclaw browser wait --text "Success"

# Wait for network idle
openclaw browser wait --load networkidle

# Wait for JS condition
openclaw browser wait --fn "window.app.ready === true"

# Combine conditions
openclaw browser wait "#main" --url "**/dashboard" --load networkidle --timeout-ms 15000
```

## State Management

### Cookies

#### `cookies`

List all cookies.

```bash
openclaw browser cookies
```

#### `cookies set <NAME> <VALUE> [--url URL] [--expires TIMESTAMP] [--secure] [--httponly] [--samesite POLICY]`

Set a cookie.

```bash
openclaw browser cookies set session abc123 --url "https://example.com"
openclaw browser cookies set theme dark --url "https://example.com"
```

#### `cookies clear`

Clear all cookies.

```bash
openclaw browser cookies clear
```

### Storage

#### `storage local|session get`

Get localStorage or sessionStorage.

```bash
openclaw browser storage local get
openclaw browser storage session get
```

#### `storage local|session set <KEY> <VALUE>`

Set a storage value.

```bash
openclaw browser storage local set theme dark
openclaw browser storage session set temp-data '{"x":1}'
```

#### `storage local|session clear`

Clear storage.

```bash
openclaw browser storage local clear
```

## Environment Settings

### `set offline on|off`

Toggle offline mode.

```bash
openclaw browser set offline on
```

### `set headers [--headers-json JSON]`

Set custom HTTP headers.

```bash
openclaw browser set headers --headers-json '{"X-Custom":"value"}'
```

### `set credentials <USER> <PASS> [--clear]`

Set HTTP Basic auth credentials.

```bash
openclaw browser set credentials user password
openclaw browser set credentials --clear  # Remove
```

### `set geo <LAT> <LON> [--origin URL] [--clear]`

Set geolocation.

```bash
openclaw browser set geo 37.7749 -122.4194 --origin "https://example.com"
openclaw browser set geo --clear
```

### `set timezone <TIMEZONE>`

Set timezone.

```bash
openclaw browser set timezone America/New_York
openclaw browser set timezone Europe/London
```

### `set locale <LOCALE>`

Set locale.

```bash
openclaw browser set locale en-US
openclaw browser set locale de-DE
```

### `set media <dark|light|no-preference|none>`

Set media preference.

```bash
openclaw browser set media dark
```

### `set device <DEVICE>`

Emulate a device.

```bash
openclaw browser set device "iPhone 14"
```

### `set viewport <WIDTH> <HEIGHT>`

Set viewport size.

```bash
openclaw browser set viewport 1280 720
```

## Advanced

### `pdf [--path PATH]`

Export page as PDF.

```bash
openclaw browser pdf
openclaw browser pdf --path /tmp/page.pdf
```

### `download <REF> [--path PATH]`

Download file triggered by element click.

```bash
# Arm download, then click link
openclaw browser download e10
openclaw browser click e10
```

### `waitfordownload <FILENAME> [--timeout-ms MS]`

Wait for download to complete.

```bash
openclaw browser waitfordownload report.pdf --timeout-ms 10000
```

### `upload [--input-ref REF | --element SELECTOR] [--files FILE ...]`

Arm file upload.

```bash
# Set file input before triggering file chooser
openclaw browser upload --input-ref e5
# Then click the chooser button
```

### `dialog [--accept | --dismiss] [--prompt TEXT]`

Handle dialogs (alert, confirm, prompt).

```bash
openclaw browser dialog --accept     # Click OK
openclaw browser dialog --dismiss    # Click Cancel
openclaw browser dialog --prompt "response"
```

### `errors [--clear]`

Get browser console errors.

```bash
openclaw browser errors
openclaw browser errors --clear
```

### `console [--level LEVEL]`

Get console logs.

```bash
openclaw browser console
openclaw browser console --level error
```

### `requests [--filter FILTER] [--clear]`

Get network requests.

```bash
openclaw browser requests
openclaw browser requests --filter api
openclaw browser requests --clear
```

### `responsebody <PATTERN> [--max-chars N]`

Get response body for matching requests.

```bash
openclaw browser responsebody "**/api/users" --max-chars 5000
```

### `trace start`

Start performance trace.

```bash
openclaw browser trace start
```

### `trace stop`

Stop trace and save.

```bash
openclaw browser trace stop
```

### `highlight <REF>`

Highlight element on page (for debugging).

```bash
openclaw browser highlight e5
```

## Tab Management

### `tab new`

Open new tab.

```bash
openclaw browser tab new
```

### `tab select <INDEX>`

Select a tab by index (1-based).

```bash
openclaw browser tab select 2
```

### `tab close [<INDEX>]`

Close a tab.

```bash
openclaw browser tab close 2
```

### `focus <TARGET_ID>`

Focus a tab by target ID.

```bash
openclaw browser focus abcd1234
```

## Profile Selection

All commands accept `--browser-profile <NAME>`:

```bash
openclaw browser --browser-profile openclaw navigate https://example.com
openclaw browser --browser-profile user snapshot --interactive
openclaw browser --browser-profile work click e1
```

Profiles:

- `openclaw` (default) — isolated managed browser
- `user` — your logged-in Chrome session
- Custom profiles configured in `~/.openclaw/openclaw.json`

## Output Formats

### JSON Output

Most commands support `--json` for structured output:

```bash
openclaw browser snapshot --interactive --json
openclaw browser tabs --json
openclaw browser cookies --json
```

### Status

Check browser status:

```bash
openclaw browser status
openclaw browser status --json
```

## Common Patterns

### Form Submission

```bash
openclaw browser navigate https://form.example.com
openclaw browser wait --load networkidle
openclaw browser snapshot --interactive
# Parse snapshot, get refs
openclaw browser type e1 "Name"
openclaw browser type e2 "email@example.com"
openclaw browser click e3  # Submit button
openclaw browser wait --text "Thank you"
```

### Login Workflow

```bash
openclaw browser navigate https://login.example.com
openclaw browser snapshot --interactive
openclaw browser type e1 "username"
openclaw browser type e2 "password"
openclaw browser click e3  # Login button
openclaw browser wait --url "**/dashboard" --load networkidle
```

### Data Extraction

```bash
openclaw browser navigate https://example.com/search?q=term
openclaw browser wait --load networkidle
openclaw browser snapshot --interactive
# Parse snapshot text to extract data
openclaw browser click e5  # Next page
openclaw browser wait --text "Page 2"
# Repeat
```

### Screenshot Verification

```bash
openclaw browser navigate https://example.com
openclaw browser wait --load networkidle
openclaw browser screenshot --full-page
# Visual verification
```

## Error Handling

If a command fails:

1. Check page state: `openclaw browser snapshot --interactive`
2. Look for errors: `openclaw browser errors`
3. Check network: `openclaw browser requests --filter api`
4. Re-run snapshot (refs change on DOM updates)
5. Verify element visibility: `openclaw browser highlight e1`
6. Record trace: `openclaw browser trace start`, reproduce, `openclaw browser trace stop`
