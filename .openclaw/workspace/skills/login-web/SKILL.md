---
name: login-web
description: Handles logging into a website using browser automation
---

# Login Website

When the user wants to log into a website, use the browser-automator workflow against the remote CDP browser.

1. Navigate to the login page URL provided by the user
2. If the sign-in modal is not open, click **Sign in**.
3. Fill the username/email field and type username/email with user provides
4. Fill the password field and type the password with user provides
5. Click the login/sign in/submit button
6. If website asks for a 2FA verification, open and switch to new tab -> fill the 2FA keycode with user provides into the verification input -> submit -> copy 6-digit code
7. Paste the 6-digit code into the 2FA input field on the original tab

## Commands

Use these browser commands as the default pattern:

```bash
openclaw browser navigate <LOGIN_PAGE_URL>
openclaw browser wait --load networkidle
openclaw browser snapshot --interactive --compact --depth 5
```

Then act on the latest refs for:

- `Sign in`
- `Email address`
- `Password`
- 2FA `tel` / verification input

## Notes

- Do not assume refs persist after clicking Sign in or submitting forms.
- If the login form fails or changes, take a fresh interactive snapshot and continue from current page state.
- When this skill is used inside a larger workflow, keep the same browser session for all later steps in that job unless the workflow explicitly switches account/session.
- Do not treat browser profile name alone as proof of which account is in use.
- After login is verified or found already active, return to the current pipeline task instead of treating login as the endpoint.
- Before reporting success, verify that the session is now on the authenticated UI rather than an auth screen.
