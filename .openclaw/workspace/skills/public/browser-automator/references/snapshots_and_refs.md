# Snapshots and Element References

Understanding how to capture page state and interact with elements.

## What is a Snapshot?

A **snapshot** is a text representation of the current page state, including:
- DOM structure (interactive elements)
- Element types (button, textbox, link, etc.)
- Element labels and accessibility properties
- Element references (refs) for targeting in actions

Snapshots let you:
1. Inspect page structure without screenshots
2. Get stable refs to click/type into specific elements
3. Understand what's interactive on the page

## Two Snapshot Modes

### Mode 1: AI Snapshot (Numeric Refs)

```bash
openclaw browser snapshot
```

**Output format:**
```
[aria-ref="1"] button "Sign Up"
[aria-ref="2"] textbox "Email" (required)
[aria-ref="3"] textbox "Password" (required)
[aria-ref="4"] link "Privacy Policy"
```

**Usage in actions:**
```bash
openclaw browser click 1
openclaw browser type 2 "user@example.com"
```

**Characteristics:**
- Numeric refs: `1`, `2`, `3`, etc.
- Works with numeric `--format ai`
- Default when Playwright is available

### Mode 2: Role Snapshot (Semantic Refs) ⭐ Recommended

```bash
openclaw browser snapshot --interactive
```

**Output format:**
```
[ref=e1] button: "Sign Up"
[ref=e2] textbox: "Email"
[ref=e3] textbox: "Password"
[ref=e4] link: "Privacy Policy"
```

**Usage in actions:**
```bash
openclaw browser click e1
openclaw browser type e2 "user@example.com"
```

**Characteristics:**
- Semantic refs: `e1`, `e2`, `e3`, etc.
- Maps to accessibility roles (button, textbox, link, form, etc.)
- Flat, easy-to-scan output
- **Better for automation** — refs are meaningful

## Choosing the Right Mode

| Feature | AI (`snapshot`) | Role (`--interactive`) |
|---------|-----------------|----------------------|
| Ref style | Numeric (1, 2) | Semantic (e1, e2) |
| Output format | Structured tree | Flat list |
| Element semantics | Less clear | Clear (role-based) |
| Scanning | Harder for humans | Easy to scan |
| Automation | Good | **Best** |
| Compact | No | Yes with `--compact` |
| Visual overlay | No | Yes with `--labels` |

**Recommendation:** Use `--interactive` for automation tasks. It's more semantically meaningful and easier to parse.

## Interactive Snapshot Options

### `--interactive`
Flat list of interactive elements only (best for scanning):

```bash
openclaw browser snapshot --interactive
```

Output:
```
[ref=e1] button: "Click Me"
[ref=e2] textbox: "Enter name"
[ref=e3] combobox: "Select option"
```

### `--compact`
Condensed output (fewer lines):

```bash
openclaw browser snapshot --interactive --compact
```

### `--depth N`
Limit tree depth (useful for complex pages):

```bash
openclaw browser snapshot --interactive --depth 4
```

### `--selector SELECTOR`
Scope to a CSS selector:

```bash
openclaw browser snapshot --interactive --selector "#main-form"
```

### `--frame SELECTOR`
Scope to an iframe:

```bash
openclaw browser snapshot --interactive --frame "iframe#chat"
```

### `--labels`
Add visual ref labels to screenshot:

```bash
openclaw browser snapshot --interactive --labels
openclaw browser screenshot --full-page
```

This overlays `[e1]`, `[e2]`, etc. directly on the page screenshot. Very useful for debugging!

## When Refs Become Invalid

**Refs are NOT stable across:**
- Page navigations
- DOM updates
- User interactions that change the DOM
- Time (dynamic content may load/unload)

**Solution:** Re-run `snapshot` after any significant page change:

```bash
openclaw browser click e5  # Click a button
# ^ This may change the page
openclaw browser snapshot --interactive  # Get fresh refs!
openclaw browser click e3  # Use new refs
```

## Common Ref Patterns

### Finding Elements in Snapshots

When parsing a snapshot, look for keywords:

**Buttons:**
```
[ref=e1] button: "Submit"
[ref=e2] button: "Cancel"
[ref=e3] button: "Next"
```

**Text inputs:**
```
[ref=e4] textbox: "Name"
[ref=e5] textbox: "Email"
[ref=e6] textbox: "Message"
```

**Dropdowns:**
```
[ref=e7] combobox: "Select option"
[ref=e8] combobox: "Country"
```

**Checkboxes:**
```
[ref=e9] checkbox: "I agree"
[ref=e10] checkbox: "Subscribe"
```

**Radio buttons:**
```
[ref=e11] radio: "Option A"
[ref=e12] radio: "Option B"
```

**Links:**
```
[ref=e13] link: "Learn more"
[ref=e14] link: "Privacy"
```

## Workflow: From Snapshot to Action

### Step 1: Take Snapshot
```bash
openclaw browser snapshot --interactive
```

### Step 2: Parse Output
Find the elements you need. Example output:

```
[ref=e1] form: ""
  [ref=e2] textbox: "Name" (required)
  [ref=e3] textbox: "Email" (required)
  [ref=e4] combobox: "Country"
  [ref=e5] checkbox: "I agree to terms"
  [ref=e6] button: "Submit"
```

### Step 3: Use Refs in Actions
```bash
# Fill Name
openclaw browser type e2 "John Doe"

# Fill Email
openclaw browser type e3 "john@example.com"

# Select Country
openclaw browser click e4
openclaw browser select e4 "United States"

# Check checkbox
openclaw browser click e5

# Submit
openclaw browser click e6
```

## Debugging with Visual Labels

When you can't find the right element:

```bash
# Get snapshot with visual labels
openclaw browser snapshot --interactive --labels
# This outputs: MEDIA:<path> (path to screenshot with labels)

# Take the labeled screenshot
openclaw browser screenshot --full-page

# The screenshot shows [e1], [e2], etc. overlaid on the page
```

Example output:
```
MEDIA:/tmp/openclaw/labeled_snapshot.png
```

Open this image to see which ref corresponds to which element!

## Advanced: Scoped Snapshots

### Snapshot Inside an Element
```bash
# Only snapshot the #form container
openclaw browser snapshot --interactive --selector "#form"
```

Useful for complex pages with multiple sections.

### Snapshot Inside an IFrame
```bash
# Snapshot inside iframe#chat
openclaw browser snapshot --interactive --frame "iframe#chat"

# Then interactions are scoped to that frame
openclaw browser click e1  # Clicks inside the iframe
```

## Performance Tips

### Use `--interactive` for Large Pages
For complex pages with many elements, `--interactive` gives a flat, manageable list:

```bash
# This page has 500+ elements
openclaw browser snapshot --interactive
# Returns ~20 interactive elements (much easier to work with)
```

### Use `--compact` for Token Efficiency
If you're embedding snapshots in prompts:

```bash
openclaw browser snapshot --interactive --compact
```

Reduces output size significantly.

### Use `--depth` to Limit Tree Nesting
For deeply nested pages:

```bash
openclaw browser snapshot --interactive --depth 3
```

Only shows 3 levels deep in the tree.

## Snapshot Formats (AI vs Role)

### AI Snapshot Details

**Output:**
```
[aria-ref="1"] button "Click" (enabled)
```

**Pros:**
- Direct numeric refs
- Works without semantic information
- Playwright-native

**Cons:**
- Less semantic (just knows it's an element)
- Harder to parse
- Refs change on DOM reorder

### Role Snapshot Details

**Output:**
```
[ref=e1] button: "Click"
[ref=e2] textbox: "Enter"
```

**Pros:**
- Semantic roles (button, textbox, form, etc.)
- Flat list (easy to scan)
- More stable ordering
- Works with Playwright

**Cons:**
- Requires Playwright
- Stricter role-based (e.g., a `<div>` button won't have a button role)

## Troubleshooting Snapshots

### No Elements Showing Up
```bash
# Page might be loading
openclaw browser wait --load networkidle
openclaw browser snapshot --interactive
```

### Can't Find Expected Element
```bash
# Element might be in an iframe
openclaw browser snapshot --interactive --frame "iframe#content"

# Or hidden/inside a collapsed container
openclaw browser snapshot  # Full snapshot to see all
```

### Refs Are Changing Unexpectedly
```bash
# DOM is updating. Re-snapshot after waiting:
openclaw browser wait --text "Loaded"
openclaw browser snapshot --interactive
```

### Too Many Elements (Hard to Read)
```bash
# Use --compact and --selector
openclaw browser snapshot --interactive --compact --selector "#main-form"
```

## Best Practices

1. **Always use `--interactive`** — It's more semantic and easier to work with
2. **Re-snapshot after changes** — Refs become invalid when DOM updates
3. **Use `--labels` to debug** — Visual overlay makes debugging much easier
4. **Scope with `--selector`** for large pages — Focus on the relevant section
5. **Check `--compact` output first** — See overview before diving into details
6. **Highlight before clicking** — Use `highlight e1` to verify you're targeting the right element

## Examples

### Example 1: Login Form
```bash
# Navigate and wait
openclaw browser navigate https://example.com/login
openclaw browser wait --load networkidle

# Snapshot
openclaw browser snapshot --interactive
# Output:
# [ref=e1] textbox: "Username"
# [ref=e2] textbox: "Password"
# [ref=e3] button: "Log In"

# Actions
openclaw browser type e1 "myuser"
openclaw browser type e2 "mypass"
openclaw browser click e3

# Wait for result
openclaw browser wait --url "**/dashboard"
```

### Example 2: Multi-step Form
```bash
openclaw browser navigate https://example.com/signup
openclaw browser wait --load networkidle
openclaw browser snapshot --interactive

# Step 1: Fill personal info
openclaw browser type e1 "John Doe"
openclaw browser type e2 "john@example.com"
openclaw browser click e5  # Next button

# Page changed, snapshot again
openclaw browser wait --text "Step 2"
openclaw browser snapshot --interactive

# Step 2: Fill address
openclaw browser type e10 "123 Main St"
openclaw browser click e15  # Submit
```

### Example 3: Complex Page with IFrame
```bash
openclaw browser navigate https://example.com
openclaw browser wait --load networkidle

# Main form
openclaw browser snapshot --interactive --selector "#contact-form"

# IFrame content
openclaw browser snapshot --interactive --frame "iframe#embedded-form"
openclaw browser click e1  # Inside iframe
```
