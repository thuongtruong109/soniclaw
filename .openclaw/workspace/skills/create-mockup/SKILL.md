---
name: create-mockup
description: Use when the user wants to repeat the workflow of opening an AliExpress product page, capturing the main product image, sending it into ChatGPT web, asking for Etsy mockup ideas, generating follow-up images for numbered ideas, and saving only the final/main generated pictures to exports. Best for browser automation tasks involving AliExpress product image extraction and ChatGPT mockup ideation/image generation capture.
---

# AliExpress → ChatGPT Mockup Capture

Use this skill for the exact browser workflow below:

- Open an AliExpress product page.
- Find and capture the main product image area only.
- Save output files into `/root/.openclaw/workspace/exports/`.
- Copy the product title and description
- Open ChatGPT web in a new tab.
- Find the chat input.
- If the user explicitly asks, upload the saved product image from `/exports`.
- Send prompts asking for Etsy mockup ideas.
- Send follow-up prompts like `Nice, hãy dùng ảnh sản phẩm đã đính kèm phía trên, hãy tạo ảnh cho ý tưởng N. Hình ảnh phải khác nhau giữa các lần tạo, không được lặp lại ý tưởng cũ. Tên sản phẩm: [PRODUCT_TITLE]. Mô tả sản phẩm: [PRODUCT_DESCRIPTION]`.
- Wait for image generation to finish before capturing results.
- Keep only main/final pictures when asked to clean up.

## Required behavior

- Always use browser automation via `openclaw browser`.
- Always save exports in `/root/.openclaw/workspace/exports/`.
- Prefer image-only captures over full-page screenshots when possible.
- Re-run `openclaw browser snapshot --interactive --compact` after any page state change because refs are unstable.
- Before saying an image is captured, verify it is not still blurred/loading.
- If ChatGPT generates multiple images in the chat, scroll and inspect the whole thread; do not assume only the latest visible image is the final result.
- When cleaning files, confirm which files are true main pictures vs full-page screenshots; do not delete the main pictures by mistake.

## Model orchestration

This skill supports multi-model execution by step, but SKILL.md itself does not switch models automatically.
Use delegation/orchestration when the runtime supports model override.

### Recommended split

**Default model / main agent**
Use for:

- browser automation
- page navigation
- clicking, typing, downloads
- DOM inspection
- screenshot capture
- file cleanup and export verification

**Stronger model such as `sonnet`**
Use for:

- uploading images
- interpreting messy ChatGPT chat history
- mapping generated images back to idea numbers when the thread is ambiguous
- ranking or refining Etsy mockup ideas
- deciding which images are true final pictures vs temporary or duplicate outputs
- writing a polished final summary if needed

### Practical routing rule

- If the step is mostly mechanical browser work, keep it on the default model.
- If the step requires judgment, synthesis, ambiguity resolution, or ranking, delegate that step to a stronger model like `sonnet`.
- Keep final verification and any destructive file cleanup under main-agent supervision.

### Example split for this skill

1. Open AliExpress and crop the main product image → default model
2. Open ChatGPT, upload image, send prompts, wait for generation → default model
3. Analyze the returned ideas and decide which are best or which images map to which idea → `sonnet`
4. Save final files and clean temporary files → main agent/default model with explicit verification

## Workflow

### 1) Capture AliExpress main product image

1. Open the product page.
2. Use `evaluate` to find the visible main product image with the largest reasonable area.
3. Take a browser screenshot and crop it to the image bounds if element-region screenshot is unavailable.
4. Save as a product image in `/exports/`.

Suggested filename:

- `aliexpress-main-product.png`

### 2) Open ChatGPT and locate input

1. Open a new tab and navigate to `https://chatgpt.com/`.
2. Run interactive snapshot.
3. Find:
   - chat input textbox
   - add files / upload button if needed
   - send button if present

### 3) Upload product image when explicitly requested

1. Copy the chosen image into `/tmp/openclaw/uploads/`.
2. Arm upload with `openclaw browser upload /tmp/openclaw/uploads/<file>`.
3. Trigger the upload chooser from the proper ChatGPT button/menu.
4. Confirm the uploaded file appears in chat composer before sending prompts.

### 4) Send prompts

Common prompts:

- `Tôi muốn bán item này, cho tôi ý tưởng để tạo hình mockup thu hút bán Etsy`
- `Hãy tạo ảnh cho ý tưởng 1`
- `Hãy tạo ảnh cho ý tưởng 2`
- ...

Rules:

- Refresh refs before typing/clicking.
- If send button is absent, use Enter.
- Wait for the model to finish before moving on.

### 5) Wait for image generation correctly

Do not capture immediately.
Use a combination of:

- `openclaw browser wait --load networkidle`
- extra sleep buffer
- fresh snapshot / DOM check for image controls like:
  - `Open image in full view`
  - `Download this image`
  - visible generated `img` elements with large dimensions

If images are blurred/loading, wait longer and retry.

### 6) Capture final pictures

Preferred order:

1. Open image in full view if available.
2. Wait until fully rendered.
3. Capture the image or modal view.
4. Save each final image with stable filenames.

Suggested filenames:

- `etsy_mockup_idea_1.png`
- `etsy_mockup_idea_2.png`
- `etsy_mockup_idea_3.png`
- `etsy_mockup_idea_4.png`
- `etsy_mockup_idea_5.png`

If ChatGPT returns more than one image per idea or many images across the thread:

- inspect all unique large `img` elements,
- scroll through the thread,
- map them carefully,
- save only the actual generated mockup pictures, not full chat screenshots.

### 7) Cleanup

When asked to keep only main pictures:

- keep the cropped product image plus final mockup image files,
- delete temporary full-page screenshots, intermediate captures, debug files, and response screenshots,
- prefer recoverable deletion if available,
- verify the keep-list before deleting.

## Safety / quality notes

- Never use fake test files in the real user workflow.
- Do not claim upload or capture succeeded unless the page visibly reflects it.
- Distinguish clearly between:
  - cropped product images,
  - final mockup pictures,
  - full-page/browser screenshots.
- If a step is ambiguous, inspect DOM/image counts before deleting or reporting success.
