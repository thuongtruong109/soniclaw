# Advanced Browser Actions

Beyond basic navigation and clicking — advanced automation techniques.

## Chrome DevTools Protocol (CDP) Integration

### Connect to Your Chrome Browser (Chrome MCP)

Use your **already-running Chrome** with your logins and sessions intact.

#### Quick Setup (3 Steps)

**Step 1: Enable Remote Debugging in Chrome**

Go to one of these URLs in Chrome:

- Chrome: `chrome://inspect`
- Edge: `edge://inspect`
- Brave: `brave://inspect`

Enable "Remote debugging" if not already enabled.

**Step 2: Configure in openclaw.json**

Add to `~/.openclaw/openclaw.json`:

```json
{
  "browser": {
    "profiles": {
      "user": {
        "driver": "existing-session",
        "attachOnly": true,
        "color": "#00AA00"
      }
    }
  }
}
```

**Step 3: Use It**

```bash
# First time - Chrome will show approval prompt
openclaw browser --browser-profile user navigate https://gmail.com

# Click "Allow" in Chrome when prompted
# Then continue:
openclaw browser --browser-profile user snapshot --interactive
openclaw browser --browser-profile user screenshot --full-page
```

#### Benefits

✅ **No Login Needed** — Already signed in
✅ **Real Sessions** — Your saved logins, cookies, extensions
✅ **Faster Automation** — Skip authentication steps
✅ **Real-World Testing** — Test with actual user data

#### How It Works

1. **Chrome MCP (Model Context Protocol)** connects to your browser
2. Chrome must be **running** with remote debugging enabled
3. First attach requires your approval ("Allow" in browser)
4. After approval, can use freely as long as Chrome is running

#### Troubleshooting Chrome MCP

**Issue: "Chrome not found"**

```bash
# 1. Make sure Chrome is running
ps aux | grep chrome

# 2. Verify Chrome version is 144+
google-chrome --version

# 3. Enable remote debugging (chrome://inspect)
```

**Issue: "Allow" prompt never appears**

```bash
# 1. Chrome might be minimized
# 2. Click Chrome window to focus
# 3. The prompt should appear in the address bar area
# 4. Click "Allow"
```

**Issue: "Connection refused" or "Cannot attach"**

```bash
# 1. Verify Chrome is still running
# 2. Check chrome://inspect - your instance should be listed
# 3. Restart Chrome and try again
# 4. Make sure no other tool is connected
```

#### Full Example: Login & Automate Gmail

```bash
# 1. Chrome is already open with Gmail logged in

# 2. Enable remote debugging in Chrome
# chrome://inspect → Enable remote debugging

# 3. Configure in openclaw.json (as above)

# 4. First use - approve the connection
openclaw browser --browser-profile user navigate https://gmail.com
# → Chrome shows: "Allow Chrome DevTools?"
# → Click "Allow"

# 5. Now you can automate with existing login
openclaw browser --browser-profile user snapshot --interactive
# Output shows Gmail interface with your inbox

# 6. Click on something
openclaw browser --browser-profile user click e5  # Click email

# 7. Type a reply
openclaw browser --browser-profile user type e10 "Thank you!" --submit

# No login step needed! 🎉
```

#### Multiple Browsers (Chrome, Brave, Edge)

Setup different profiles for each:

```json
{
  "browser": {
    "profiles": {
      "chrome": {
        "driver": "existing-session",
        "attachOnly": true,
        "color": "#4285F4" // Google blue
      },
      "brave": {
        "driver": "existing-session",
        "attachOnly": true,
        "userDataDir": "~/Library/Application Support/BraveSoftware/Brave-Browser",
        "color": "#FB542B"
      },
      "edge": {
        "driver": "existing-session",
        "attachOnly": true,
        "userDataDir": "~/AppData/Local/Microsoft/Edge/User Data",
        "color": "#00A4EF"
      }
    }
  }
}
```

Then use:

```bash
openclaw browser --browser-profile chrome navigate https://example.com
openclaw browser --browser-profile brave navigate https://example.com
openclaw browser --browser-profile edge navigate https://example.com
```

#### Chrome DevTools MCP vs Isolated Browser

| Feature                     | Chrome MCP (`user`)         | Isolated (`openclaw`) |
| --------------------------- | --------------------------- | --------------------- |
| Requires Chrome running     | Yes                         | No                    |
| Uses your logins            | Yes                         | No                    |
| Needs approval first        | Yes                         | No                    |
| Can access all sites        | Yes                         | Yes                   |
| Isolated from personal data | No                          | Yes                   |
| Best for                    | Your own accounts           | Testing, untrusted    |
| Risk                        | High (access to everything) | Low (isolated)        |

---

## File Operations

### Download Files (Buttons/Links)

Trigger file downloads:

```bash
# Get snapshot to find download link ref
openclaw browser snapshot --interactive
# [ref=e5] link: "Download Report.pdf"

# Trigger download
openclaw browser click e5

# Wait for completion
openclaw browser waitfordownload "Report.pdf" --timeout-ms 10000
```

Downloads go to `/tmp/openclaw/downloads/`.

### Download Images (Direct URL/No Button)

If analyzing an image that doesn't have a download file action, fetch its `src` and download it directly via standard CLI tools (e.g. `curl`):

```bash
openclaw browser snapshot --interactive
# [ref=e12] img: "Product Picture"

openclaw browser evaluate --fn '(el) => el.src' --ref e12
# https://example.com/images/prod123.jpg

curl -o /tmp/openclaw/downloads/prod123.jpg "https://example.com/images/prod123.jpg"
```

### Upload Files

Handle file input fields:

```bash
# Get snapshot
openclaw browser snapshot --interactive
# [ref=e10] input (file)

# Upload before clicking chooser
openclaw browser upload --input-ref e10

# Now click button that triggers chooser
openclaw browser click e8

# Or specify file path directly
openclaw browser upload /path/to/file.pdf
```

Uploads are constrained to `/tmp/openclaw/uploads/`.

## Dialog Handling

### Alert, Confirm, Prompt

```bash
# Accept alert
openclaw browser dialog --accept

# Dismiss confirm
openclaw browser dialog --dismiss

# Respond to prompt
openclaw browser dialog --prompt "my response"
```

**Workflow:**

1. Arm the dialog handler
2. Click button that triggers dialog
3. Dialog is automatically handled

```bash
# Example: Click button with confirmation
openclaw browser dialog --accept  # Arm first
openclaw browser click e5         # Click button (triggers confirm)
```

## JavaScript Execution

### Evaluate JavaScript

Execute arbitrary JS in page context:

```bash
# Get a value
openclaw browser evaluate --fn 'window.location.href'

# Get element property
openclaw browser evaluate --fn '(el) => el.innerText' --ref e5

# Check condition
openclaw browser evaluate --fn 'document.querySelectorAll(".item").length'
```

**Note:** `evaluate` is powerful but can be tricky. Use it for:

- Querying JS state
- Getting computed values
- Checking window conditions

Avoid using it for clicking/typing (use `click`/`type` instead).

## Advanced Waiting

### Wait for JavaScript Condition

```bash
# Wait for custom condition
openclaw browser wait --fn "window.app && window.app.loaded === true"

# Multiple conditions together
openclaw browser wait \
  "#main" \
  --url "**/dashboard" \
  --load networkidle \
  --fn "window.ready === true" \
  --timeout-ms 20000
```

### Wait for Specific Load State

```bash
# Wait for DOMContentLoaded
openclaw browser wait --load domcontentloaded

# Wait for full page load
openclaw browser wait --load load

# Wait for network idle (default for most)
openclaw browser wait --load networkidle
```

## PDF Export

Export page as PDF:

```bash
# Default location
openclaw browser pdf

# Specify path
openclaw browser pdf --path /tmp/page.pdf
```

PDF output goes to stdout or specified path. Useful for:

- Archiving pages
- Creating reports
- Document processing

## Network Inspection

### Get Network Requests

```bash
# All requests
openclaw browser requests

# Filter by type
openclaw browser requests --filter api

# Clear log
openclaw browser requests --clear
```

### Get Response Body

```bash
# Get response for matching pattern
openclaw browser responsebody "**/api/users" --max-chars 5000

# Pattern matching (glob)
openclaw browser responsebody "**/api/**" --max-chars 10000
```

Useful for:

- Scraping API data
- Verifying API responses
- Debugging network issues

## Console & Errors

### Browser Console Logs

```bash
# All logs
openclaw browser console

# Only errors
openclaw browser console --level error

# Only warnings
openclaw browser console --level warning
```

### Console Errors

```bash
# Get errors
openclaw browser errors

# Clear errors
openclaw browser errors --clear
```

Useful for:

- Debugging page issues
- Verifying no JS errors
- Understanding page state

## Performance & Debugging

### Performance Tracing

Record a Playwright trace for deep debugging:

```bash
# Start trace
openclaw browser trace start

# Reproduce issue
openclaw browser navigate https://example.com
openclaw browser click e1

# Stop and save
openclaw browser trace stop
# Outputs: TRACE:/tmp/openclaw/trace.zip
```

Open trace in [Playwright Inspector](https://playwright.dev/docs/trace-viewer):

```bash
npx playwright show-trace /tmp/openclaw/trace.zip
```

Trace includes:

- Network timeline
- Screenshots at each step
- DOM snapshots
- Console logs
- JavaScript timings

### Highlight Element (Visual Debugging)

```bash
# Highlight element on page
openclaw browser highlight e5
```

Shows what Playwright is targeting. Useful when:

- Click/type fails
- You're not sure which element is `e5`
- Multiple similar elements exist

## Screen Recording & Screenshots

### Element Screenshot

```bash
# Screenshot by ref
openclaw browser screenshot --ref e5

# Shows just that element
```

### Full Page Screenshot

```bash
# Screenshot entire page (including below fold)
openclaw browser screenshot --full-page
```

### Screenshot with Snapshot Labels

```bash
# Get snapshot with visual labels
openclaw browser snapshot --interactive --labels

# Take screenshot
openclaw browser screenshot --full-page

# Screenshot now has ref labels overlaid: [e1], [e2], etc.
```

## Keyboard & Mouse Advanced

### Press Keys

```bash
# Single key
openclaw browser press Enter

# Modifier keys
openclaw browser press Control+A
openclaw browser press Shift+Tab

# Multiple keys
openclaw browser press Control+C
```

### Mouse Actions

```bash
# Hover over element
openclaw browser hover e5

# Drag element to target
openclaw browser drag e5 e6

# Scroll element into view
openclaw browser scrollintoview e7

# Double-click
openclaw browser click e8 --double
```

## Form Advanced

### Bulk Fill Form

Fill multiple fields at once:

```bash
openclaw browser fill --fields '[
  {"ref":"e1","type":"text","value":"John"},
  {"ref":"e2","type":"text","value":"john@example.com"},
  {"ref":"e3","type":"select","value":"USA"}
]'
```

### Select Multiple Options

```bash
# Combobox with multiple selection
openclaw browser select e4 "Option1" "Option2" "Option3"
```

## Browser State Advanced

### Geolocation

```bash
# Set location (latitude, longitude)
openclaw browser set geo 37.7749 -122.4194 --origin "https://example.com"

# Clear
openclaw browser set geo --clear
```

### Custom Headers

```bash
# Set for all requests
openclaw browser set headers --headers-json '{"X-API-Key":"secret123","X-Custom":"value"}'
```

### HTTP Basic Auth

```bash
# Set credentials
openclaw browser set credentials user password

# Applies to all requests
# User: user
# Pass: password

# Clear
openclaw browser set credentials --clear
```

### Offline Mode

```bash
# Go offline
openclaw browser set offline on

# Go online
openclaw browser set offline off
```

Simulates network disconnection.

### Device Emulation

```bash
# Emulate iPhone 14
openclaw browser set device "iPhone 14"

# Available devices: iPhone 12, iPad, Samsung Galaxy S9, etc.
```

### Viewport Size

```bash
# Set viewport
openclaw browser set viewport 1280 720

# Mobile viewport
openclaw browser set viewport 375 667
```

### Timezone & Locale

```bash
# Set timezone
openclaw browser set timezone America/New_York

# Set locale
openclaw browser set locale en-US
```

### Media Preference

```bash
# Dark mode
openclaw browser set media dark

# Light mode
openclaw browser set media light

# No preference
openclaw browser set media no-preference
```

## Practical Workflows

### Multi-Page Form with Progress Tracking

```bash
# Page 1
openclaw browser navigate https://form.example.com/step1
openclaw browser snapshot --interactive
openclaw browser type e1 "John"
openclaw browser click e5  # Next

# Page 2
openclaw browser wait --text "Step 2"
openclaw browser snapshot --interactive
openclaw browser type e1 "john@example.com"
openclaw browser click e5  # Next

# Page 3
openclaw browser wait --text "Step 3"
openclaw browser snapshot --interactive
openclaw browser click e1  # Confirm/Submit
openclaw browser wait --text "Thank you"

# Verify success
openclaw browser screenshot --full-page
```

### Scrape with API Inspection

```bash
# Navigate and wait
openclaw browser navigate https://example.com/api-test
openclaw browser wait --load networkidle

# Inspect network
openclaw browser requests --clear
openclaw browser click e1  # Trigger API call

# Wait for network
openclaw browser wait --load networkidle

# Get response
openclaw browser responsebody "**/api/users" --max-chars 5000
```

### Screenshot Verification Test

```bash
# Navigate
openclaw browser navigate https://example.com

# Wait for content
openclaw browser wait --load networkidle

# Take labeled screenshot
openclaw browser snapshot --interactive --labels
openclaw browser screenshot --full-page

# Visual inspection
# (compare against expected screenshot)
```

### Login with Auth & Session Verification

```bash
# Navigate to login
openclaw browser navigate https://example.com/login
openclaw browser snapshot --interactive

# Login
openclaw browser type e1 "user"
openclaw browser type e2 "pass"
openclaw browser click e3  # Login

# Wait for redirect
openclaw browser wait --url "**/dashboard"

# Get session cookies
openclaw browser cookies

# Verify auth state
openclaw browser evaluate --fn 'window.user.authenticated'
```

### Download & Verify

```bash
# Navigate to download page
openclaw browser navigate https://example.com/downloads

# Take snapshot
openclaw browser snapshot --interactive
# [ref=e5] link: "Download Report"

# Clear download history
openclaw browser requests --clear

# Trigger download
openclaw browser click e5

# Wait for completion
openclaw browser waitfordownload "Report.pdf"

# Verify network
openclaw browser responsebody "**/api/report" --max-chars 1000
```

## Error Recovery Patterns

### Handle Dynamic Content

```bash
# Wait for AJAX/dynamic content
openclaw browser wait --load networkidle

# Re-snapshot (refs may have changed)
openclaw browser snapshot --interactive

# Use new refs
openclaw browser click e1
```

### Handle Dialogs

```bash
# Arm handler before click
openclaw browser dialog --accept
openclaw browser click e5  # Might trigger alert

# Continue
openclaw browser snapshot --interactive
```

### Handle Slow Pages

```bash
# Longer timeout
openclaw browser wait \
  --load networkidle \
  --timeout-ms 30000

# Snapshot
openclaw browser snapshot --interactive
```

### Handle Missing Elements

```bash
# If element not found, check state
openclaw browser console --level error

# Verify page loaded correctly
openclaw browser screenshot --full-page

# Re-snapshot
openclaw browser snapshot --interactive --selector "#main"
```

## Performance Tips

1. **Reuse snapshots** — Don't snapshot every action, only when DOM changes significantly
2. **Use `--compact`** — Reduces output for large pages
3. **Scope with `--selector`** — Focus on relevant sections
4. **Batch operations** — Click → Type → Click → wait once, don't wait between each
5. **Use `--load networkidle`** — Wait for async operations
6. **Cache cookies/storage** — Reuse after first login

## Limitations

- `evaluate` is powerful but can be blocked by CSP (Content Security Policy)
- File upload requires proper HTML `<input type="file">`
- Some sites detect automation; consider using real-world user agents
- Geolocation requires HTTPS (or localhost)
- JavaScript execution is sandboxed to page context

## Debugging

When something goes wrong:

1. **Take screenshot:** `openclaw browser screenshot --full-page`
2. **Check errors:** `openclaw browser errors`
3. **Inspect network:** `openclaw browser requests`
4. **Get console:** `openclaw browser console`
5. **Use labels:** `openclaw browser snapshot --interactive --labels`
6. **Record trace:** `openclaw browser trace start` → reproduce → `openclaw browser trace stop`
7. **Highlight element:** `openclaw browser highlight e1`
