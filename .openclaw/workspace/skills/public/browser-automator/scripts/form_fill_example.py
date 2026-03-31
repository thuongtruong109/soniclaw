#!/usr/bin/env python3
"""
Form Fill Example: Complete workflow for automated form submission.

This script demonstrates a multi-step browser automation workflow:
1. Navigate to a form page
2. Inspect the form elements
3. Fill in fields
4. Submit the form
5. Wait for confirmation

Usage:
    python3 form_fill_example.py <form_url>

Example:
    python3 form_fill_example.py https://example.com/contact-form
"""

import subprocess, json, sys, time
from typing import Optional, Dict, List, Tuple


class BrowserAutomator:
    """Helper class to run OpenClaw browser commands."""

    def __init__(self, profile: str = "openclaw"):
        self.profile = profile

    def run_command(self, *args, json_output: bool = False) -> str:
        """Run an openclaw browser command and return output."""
        cmd = ["openclaw", "browser", "--browser-profile", self.profile]
        cmd.extend(args)

        if json_output:
            cmd.append("--json")

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            raise RuntimeError(f"Command failed: {' '.join(cmd)}\nError: {result.stderr}")

        return result.stdout

    def navigate(self, url: str) -> None:
        """Navigate to a URL."""
        print(f"[→] Navigating to {url}")
        self.run_command("navigate", url)
        time.sleep(2)  # Wait for page to load

    def snapshot(self, interactive: bool = True, labels: bool = False) -> str:
        """Get a snapshot of the page."""
        args = ["snapshot"]
        if interactive:
            args.append("--interactive")
        if labels:
            args.append("--labels")

        print(f"[📸] Taking snapshot...")
        return self.run_command(*args)

    def click(self, ref: str) -> None:
        """Click an element by ref."""
        print(f"[👆] Clicking element {ref}")
        self.run_command("click", ref)
        time.sleep(0.5)

    def type_text(self, ref: str, text: str, submit: bool = False) -> None:
        """Type text into an element."""
        args = ["type", ref, text]
        if submit:
            args.append("--submit")

        print(f"[⌨️] Typing into {ref}: {text[:50]}...")
        self.run_command(*args)
        time.sleep(0.5)

    def select(self, ref: str, options: List[str]) -> None:
        """Select options from a dropdown."""
        args = ["select", ref] + options
        print(f"[✓] Selecting {', '.join(options)}")
        self.run_command(*args)
        time.sleep(0.5)

    def wait(self, conditions: Dict[str, str], timeout_ms: int = 10000) -> None:
        """Wait for conditions to be met."""
        args = ["wait"]

        # Add selector if provided
        if "selector" in conditions:
            args.append(conditions["selector"])

        # Add URL if provided
        if "url" in conditions:
            args.extend(["--url", conditions["url"]])

        # Add load state if provided
        if "load" in conditions:
            args.extend(["--load", conditions["load"]])

        # Add text if provided
        if "text" in conditions:
            args.extend(["--text", conditions["text"]])

        # Add timeout
        args.extend(["--timeout-ms", str(timeout_ms)])

        print(f"[⏳] Waiting for conditions: {conditions}")
        self.run_command(*args)

    def screenshot(self, full_page: bool = False, ref: Optional[str] = None) -> None:
        """Take a screenshot."""
        args = ["screenshot"]
        if full_page:
            args.append("--full-page")
        if ref:
            args.extend(["--ref", ref])

        print(f"[📷] Taking screenshot...")
        self.run_command(*args)


def parse_snapshot(snapshot_text: str) -> Dict[str, str]:
    """
    Parse a snapshot to extract element refs.

    Snapshot format includes lines like:
        [ref=e1] button: "Submit"
        [ref=e2] textbox: "Email" (required)
        [ref=e3] textbox: "Message"

    Returns a dict mapping element identifiers to refs.
    """
    refs = {}
    for line in snapshot_text.split("\n"):
        if "[ref=" in line:
            # Extract ref (e.g., "e1")
            ref_start = line.find("[ref=") + 5
            ref_end = line.find("]", ref_start)
            ref = line[ref_start:ref_end]

            # Extract element type and name
            # Example: "[ref=e1] button: "Submit""
            remainder = line[ref_end+2:]  # Skip '] '

            refs[remainder.strip()] = ref

    return refs


def fill_contact_form(form_url: str) -> None:
    """
    Example: Fill a contact form with sample data.

    This demonstrates a typical form-filling workflow:
    1. Navigate to form
    2. Inspect with snapshot
    3. Identify fields
    4. Fill in data
    5. Submit
    6. Wait for confirmation
    """
    bot = BrowserAutomator(profile="openclaw")

    try:
        # Step 1: Navigate
        bot.navigate(form_url)

        # Step 2: Wait for page to load
        bot.wait({"load": "networkidle"}, timeout_ms=10000)

        # Step 3: Take snapshot
        snapshot = bot.snapshot(interactive=True)
        print("\n=== PAGE SNAPSHOT ===")
        print(snapshot[:500])  # Print first 500 chars
        print("=== END SNAPSHOT ===\n")

        # Step 4: Parse snapshot to find refs
        refs = parse_snapshot(snapshot)
        print(f"Found {len(refs)} interactive elements")

        # Step 5: Fill form fields (adjust these based on actual form)
        # Example patterns:

        # Find and fill "Name" field
        name_ref = None
        for field, ref in refs.items():
            if "name" in field.lower():
                name_ref = ref
                break

        if name_ref:
            bot.type_text(name_ref, "John Doe")
        else:
            print("⚠️  Could not find Name field")

        # Find and fill "Email" field
        email_ref = None
        for field, ref in refs.items():
            if "email" in field.lower():
                email_ref = ref
                break

        if email_ref:
            bot.type_text(email_ref, "john@example.com")
        else:
            print("⚠️  Could not find Email field")

        # Find and fill "Message" field
        message_ref = None
        for field, ref in refs.items():
            if "message" in field.lower() or "comment" in field.lower():
                message_ref = ref
                break

        if message_ref:
            bot.type_text(message_ref, "This is an automated test message.")
        else:
            print("⚠️  Could not find Message field")

        # Step 6: Find and click Submit button
        submit_ref = None
        for field, ref in refs.items():
            if "submit" in field.lower() or "send" in field.lower():
                submit_ref = ref
                break

        if submit_ref:
            bot.click(submit_ref)
            print("[✓] Form submitted")

            # Step 7: Wait for success confirmation
            bot.wait(
                {
                    "text": "Thank you",  # Adjust based on actual response
                    "load": "networkidle"
                },
                timeout_ms=10000
            )

            # Step 8: Take final screenshot
            bot.screenshot(full_page=True)
            print("[✓] Workflow completed successfully")
        else:
            print("⚠️  Could not find Submit button")

    except Exception as e:
        print(f"[✗] Error: {e}")
        sys.exit(1)


def fill_login_form(login_url: str, username: str, password: str) -> None:
    """
    Example: Automated login workflow.

    This demonstrates:
    1. Navigate to login page
    2. Find username/password fields
    3. Fill and submit
    4. Wait for dashboard redirect
    """
    bot = BrowserAutomator(profile="openclaw")

    try:
        # Navigate
        bot.navigate(login_url)
        bot.wait({"load": "networkidle"})

        # Get snapshot
        snapshot = bot.snapshot(interactive=True)
        refs = parse_snapshot(snapshot)

        # Find fields
        username_ref = next(
            (ref for field, ref in refs.items() if "username" in field.lower() or "email" in field.lower()),
            None
        )
        password_ref = next(
            (ref for field, ref in refs.items() if "password" in field.lower()),
            None
        )
        login_ref = next(
            (ref for field, ref in refs.items() if "login" in field.lower() or "sign in" in field.lower()),
            None
        )

        # Fill and submit
        if username_ref:
            bot.type_text(username_ref, username)
        if password_ref:
            bot.type_text(password_ref, password)
        if login_ref:
            bot.click(login_ref)

        # Wait for dashboard
        bot.wait(
            {"url": "**/dashboard", "load": "networkidle"},
            timeout_ms=10000
        )

        print("[✓] Login successful")

    except Exception as e:
        print(f"[✗] Login failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 form_fill_example.py <form_url>")
        print("\nExample:")
        print("  python3 form_fill_example.py https://example.com/contact")
        sys.exit(1)

    form_url = sys.argv[1]
    fill_contact_form(form_url)
