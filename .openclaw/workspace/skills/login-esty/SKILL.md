---
name: login-esty
description: Log in to Etsy via browser automation. Use when the user asks to open Etsy, fill Etsy sign-in email/password, submit login, or enter a 6-digit 2FA code during Etsy authentication.
---

# Login Esty

Use the browser-automator workflow against the remote CDP browser.

## Steps

1. Navigate to `https://www.etsy.com`.
2. If the sign-in modal is not open, click **Sign in**.
3. Fill the email field when the user provides an Etsy email.
4. Fill the password field when the user provides an Etsy password.
5. Click **Sign in**.
6. If Etsy asks for a 2FA code, fill the 6-digit code into the verification input and submit.
7. Re-run an interactive snapshot after each major page/modal change because refs are not stable.

## Commands

Use these browser commands as the default pattern:

```bash
openclaw browser navigate https://www.etsy.com
openclaw browser wait --load networkidle
openclaw browser snapshot --interactive --compact --depth 5
```

Then act on the latest refs for:
- `Sign in`
- `Email address`
- `Password`
- 2FA `tel` / verification input

## Notes

- Keep replies short: confirm each completed step.
- Do not assume refs persist after clicking Sign in or submitting forms.
- If the login form fails or changes, take a fresh interactive snapshot and continue from current page state.
