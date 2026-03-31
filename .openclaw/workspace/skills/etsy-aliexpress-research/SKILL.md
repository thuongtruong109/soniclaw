---
name: etsy-aliexpress-research
description: Tìm và phân tích sản phẩm từ AliExpress phù hợp để bán trên Etsy cho người mới, có scoring, filtering và output chuẩn.
---

# Etsy x AliExpress Research

## 🎯 Mục tiêu

Giúp người dùng tìm sản phẩm từ AliExpress có thể bán trên Etsy bằng cách:

- lọc theo “gu Etsy”
- tránh sản phẩm đại trà
- tối ưu cho người mới
- đưa ra sản phẩm có thể test ngay

Tự động tạo **listing Etsy chuẩn SEO + chuyển đổi cao** từ sản phẩm đã research:

- Title chuẩn SEO (click + search)
- Tags đúng keyword buyer
- Description có storytelling + conversion
- Hook rõ ràng (bán cảm xúc, không bán sản phẩm)

---

## 🧠 Khi nào dùng skill này

Khi user nói về:

- tìm sản phẩm AliExpress
- bán trên Etsy
- dropship Etsy
- tìm niche / sản phẩm tiềm năng
- research sản phẩm

---

## ⚙️ FLOW LÀM VIỆC

### 🚀 CHẾ ĐỘ “ONE-SHOT” (KHÔNG HỎI GIỮA CHỪNG)

Nếu user nhập theo format kiểu:

- `Nhiệm vụ: dropship`
- `Links: [ ... ]` (hoặc nhiều link xuống dòng)

thì skill phải **tự động chạy một mạch** theo Link mode:

1. Parse links → 2) Extract đầy đủ thông tin (gồm Description tab) → 3) Scoring + lọc → 4) Chọn TOP 3 → 5) Auto Listing (SEO + ảnh) cho TOP.

**Không được dừng lại để hỏi** các câu như niche/target/giá… trong lúc chạy.

Chỉ khi hoàn tất output mới được hỏi dạng follow-up (tuỳ chọn) để refine vòng sau.

---

### Bước 0: Xác định chế độ input (QUAN TRỌNG)

Skill này có **2 chế độ**:

**A) Research mode (mặc định)**

- Khi user **không đưa link sản phẩm AliExpress** (chỉ hỏi bình thường / chỉ đưa niche, tiêu chí…)
- ➜ Làm mọi thứ **như hiện tại**: tự tìm sản phẩm trên AliExpress theo tiêu chí + gu Etsy.

**B) Link mode (user đưa sẵn link)**

- Khi user **dán một danh sách link AliExpress** (nhiều link, 1 link cũng tính)
- ➜ **Bỏ bước tìm kiếm link trên AliExpress**.
- ➜ Dùng **chính các link đó** để lấy thông tin sản phẩm và chấm điểm/scoring như bình thường.

Quy tắc nhận diện nhanh “Link mode”:

- Có ít nhất 1 URL chứa `aliexpress.com` (ví dụ: `https://www.aliexpress.com/item/...`)
- Hoặc user nói rõ: “đây là list link”, “mình có link rồi”, “analyze các link này”…

**Ghi chú:** Nếu user đưa `Nhiệm vụ: dropship` + `Links:` thì luôn ưu tiên One-shot (Link mode) và dùng preset dropship bên dưới.

### Bước 1: Hiểu user

Nếu user chưa cung cấp đủ, hỏi NGẮN GỌN:

- Bạn muốn bán niche gì?
- Khách hàng mục tiêu là ai?
- Giá nhập tối đa?
- Giá bán mong muốn trên Etsy?
- Có muốn tập trung vào quà tặng / cá nhân hóa không?

Nếu user không biết niche → đề xuất:

1. Quà tặng (gift)
2. Trang sức tối giản (jewelry)
3. Pet / quà cho thú cưng

**Nếu đang ở Link mode:**

- Mặc định **không hỏi giữa chừng**.
- Nếu user không cung cấp các thông tin như khách hàng mục tiêu / giá bán / personalization… thì:
  - Tự suy luận từ sản phẩm + gu Etsy
  - Dùng preset mặc định (Bước 2)
  - Trường nào thiếu dữ liệu thật sự thì ghi `Unknown`
- Chỉ hỏi tối đa 1–2 câu **sau khi đã trả output**, để refine vòng sau.

---

### Bước 2: Xác định tiêu chí mặc định (nếu user không nói)

- Giá nhập: < $8
- Giá bán Etsy: $20–$35
- Nhẹ, dễ ship
- Không dễ vỡ
- Có thể làm quà
- Có khả năng cá nhân hóa hoặc storytelling

#### Preset mặc định khi `Nhiệm vụ: dropship`

Áp dụng khi user ghi rõ “dropship” và không cung cấp thêm:

- Ưu tiên sản phẩm **nhẹ, nhỏ, không dễ vỡ**, ít rủi ro hoàn hàng
- Tránh: đồ điện tử, đồ có size quá phức tạp (nhiều size chart khó), sản phẩm dễ lỗi chất lượng
- Shipping: ưu tiên có tùy chọn nhanh/ổn định (nếu thấy) và ghi ETA; nếu không thấy thì `Unknown`
- Pricing mặc định:
  - Giá nhập mục tiêu: < $8 (giữ nguyên)
  - Giá bán Etsy gợi ý: $20–$35 (giữ nguyên)
  - Nếu sản phẩm là “party supplies / decor” có thể bán theo **bundle/pack** để tăng AOV

**Nếu đang ở Link mode:** vẫn áp dụng tiêu chí mặc định để chấm điểm và lọc (ví dụ loại đồ quá generic, quá rẻ tiền…).

---

### Bước 3A: Tìm sản phẩm (chỉ dùng cho Research mode)

- Tìm trên AliExpress theo niche/keyword/criteria.
- Lọc theo “gu Etsy” và nguyên tắc bên dưới.

**Bắt buộc khi đã chọn candidate:**

- Mở trang sản phẩm và lấy thêm thông tin ở **tab/section “Description”** (và/hoặc Product Details) để có dữ liệu viết listing:
  - material/chất liệu
  - kích thước/size chart
  - package includes (trong hộp có gì)
  - hướng dẫn sử dụng/care (nếu có)
  - ghi chú cá nhân hoá/tuỳ chọn (nếu có)
  - warning/compliance (nếu có)

### Bước 3B: Lấy thông tin từ link (chỉ dùng cho Link mode)

Khi user dán link AliExpress, hãy:

1. **Parse danh sách link**

- Chấp nhận định dạng: mỗi dòng 1 link, hoặc phân tách bằng dấu phẩy.
- Khuyến nghị: 3–20 link/lần (nếu nhiều hơn, tự chọn 20 link đầu và nói rõ).

2. **Chuẩn hoá link**

- Giữ link gốc, không cần affiliate.
- Nếu link có tham số tracking dài, có thể rút gọn nhưng phải giữ được item.

3. **Extract thông tin cho từng link** (MỤC TIÊU: ĐỦ RICH như Research mode)

Yêu cầu tối thiểu cho mỗi sản phẩm (cố gắng lấy từ trang AliExpress; nếu không thấy thì ghi rõ `Unknown`):

- **Tên sản phẩm** (title)
- **Giá** (hoặc khoảng giá) + **currency**
- **Shipping fee** / ETA (nếu có) + ghi chú free shipping?
- **Số đơn/đã bán** (orders) (nếu có)
- **Rating** + **số review** (nếu có)
- **Biến thể chính**: size, color, set/pack (nếu có)
- **Thông tin chi tiết** (specs) (nếu có):
- **Thông tin từ tab/section “Description”** (BẮT BUỘC cố gắng lấy):
  - size chart / kích thước chi tiết
  - material/chất liệu
  - package includes (trong hộp có gì)
  - usage/care instructions
  - notes về custom/personalization (nếu có)
  - any warnings/disclaimers (nếu có)

**Ghi chú:** nếu AliExpress chỉ hiển thị “Description” dưới dạng hình ảnh/text dài, hãy tóm tắt lại thành bullet points ngắn.

Ngoài ra vẫn lấy specs thường gặp:

- chất liệu/material
- kích thước
- kiểu đóng gói
- dùng cho dịp nào (wedding, birthday, mother’s day…)
- **Ảnh/visual cues**: mô tả 2–3 điểm nhìn “Etsy vibe” từ hình (aesthetic, minimal, giftable…) (không bịa chi tiết kỹ thuật)
- **Rủi ro & compliance** (quick check): dễ vỡ? brand/trademark? adult content? chất liệu nhạy cảm? hàng quá mass?

Sau khi extract, phải **chuẩn hoá về cùng schema output** như phần “OUTPUT FORMAT” bên dưới.

4. **Suy luận keyword**

- `Keyword AliExpress`: rút ra 2–5 keyword từ title (không bịa).
- `Keyword Etsy`: chuyển sang buyer-intent keyword + gift intent (ví dụ “gift for her”, “custom name”, “minimalist”).

5. **Chấm điểm & lọc**

- Dùng scoring model y như Research mode.
- Nếu link không truy cập được/thiếu thông tin: vẫn giữ trong danh sách nhưng đánh dấu “thiếu dữ liệu” và trừ điểm.

6. **Bắt buộc tạo “Etsy-ready insights” cho Link mode**

Vì Link mode không có bước “tự search”, nên phải bù lại bằng phần phân tích sâu để output không bị “thiếu thông tin”:

- `Khách hàng`: xác định audience cụ thể (gift buyer / bride-to-be / pet owner / mom…)
- `Vì sao hợp Etsy`: liên hệ với “gu Etsy” (emotional, giftable, handmade vibe)
- `Cách nâng cấp`: personalization/story/packaging/mockup angle
- `Rủi ro`: rủi ro cạnh tranh, chất lượng, vi phạm, shipping,

7. **AUTO LISTING GENERATOR (khuyến nghị mặc định)**

Nếu user dán link và muốn “ra đủ thông tin như bình thường”, mặc định sau phần research/scoring hãy tạo thêm **mini listing block** cho TOP 1–3:

- 1 Title chuẩn SEO
- 13 Tags
- Description theo cấu trúc HOOK → VALUE → PERSONALIZATION → DETAILS → CTA

(Phần template chi tiết đã có ở mục "AI AUTO LISTING GENERATOR" bên dưới.)

---

### Quy tắc xử lý khi thiếu dữ liệu (Link mode)

- Nếu thiếu specs/shipping/rating: ghi `Unknown` và **hỏi tối đa 1–2 câu** để lấp chỗ trống (ví dụ: “bạn nhắm bán giá bao nhiêu?”, “sản phẩm có personalizable không?”).
- Không tự bịa rating/reviews/material/kích thước.
- Nếu chỉ có link kiểu `item/1005...` (như screenshot), hãy coi đó là AliExpress item path.

---

## 🎨 GU ETSY (QUAN TRỌNG)

Luôn ưu tiên sản phẩm có:

- cảm xúc (emotional)
- làm quà được
- tối giản / aesthetic
- handmade vibe
- có thể cá nhân hóa

Tránh:

- đồ điện tử
- hàng “chợ online”
- sản phẩm quá generic
- hàng nhìn rẻ tiền

---

## 🔍 NGUYÊN TẮC TÌM SẢN PHẨM

Chỉ chọn sản phẩm:

- có thể viết story (gift, memory, relationship)
- có margin tối thiểu x2–x3
- không phụ thuộc brand
- có thể cải thiện bằng:
  - mockup
  - title
  - personalization
  - packaging

---

## 📊 SCORING MODEL

Chấm điểm mỗi sản phẩm theo:

- Etsy fit (0–10)
- Gift potential (0–10)
- Profit margin (0–10)
- Competition (0–10, điểm cao = dễ cạnh tranh)
- Beginner friendly (0–10)

👉 Tổng điểm /50 → convert sang /10

---

## 📦 OUTPUT FORMAT

### 🥇 Sản phẩm #1

- Tên:
- Link AliExpress:
- Keyword AliExpress:
- Keyword Etsy:
- Khách hàng:
- Giá nhập:
- Giá bán gợi ý:
- Lợi nhuận:
- Vì sao hợp Etsy:
- Cách nâng cấp (important):
- Rủi ro:
- Điểm: x/10
- Verdict: NÊN TEST / KHÔNG

---

## 🧠 NÂNG CẤP SẢN PHẨM (BẮT BUỘC)

Luôn thêm phần:

**Cách biến sản phẩm này thành “chuẩn Etsy”:**

- cá nhân hóa gì?
- viết story kiểu gì?
- dùng ảnh ra sao?

---

## 🏆 CHỌN TOP

Sau khi list:

- chọn TOP 3
- giải thích vì sao phù hợp cho người mới
- chỉ ra sản phẩm dễ win nhất

---

## 🚀 FOLLOW-UP TỰ ĐỘNG

Sau khi trả kết quả, đề xuất 1 bước tiếp:

- viết listing Etsy
- tạo title + tag
- làm mockup idea
- kế hoạch test 7 ngày

---

# 🤖 AI AUTO LISTING GENERATOR (ETSY SEO)

## 🎯 Mục tiêu

Tự động tạo **listing Etsy chuẩn SEO + chuyển đổi cao** từ sản phẩm đã research trên AliExpress (đảm bảo tiêu chuẩn handmade, vintage hoặc craft supply của Etsy):

- Title chuẩn SEO (click + search)
- Tags đúng keyword buyer
- Description có storytelling + conversion
- Hook rõ ràng (bán cảm xúc, không bán sản phẩm)

---

## ⚙️ INPUT

Dùng từ output research:

- Tên sản phẩm
- Khách hàng
- Use case (khi nào mua)
- Điểm mạnh (gift / emotional / aesthetic)
- Khả năng personalization
- Keyword Etsy

---

## 📦 OUTPUT FORMAT CHO LISTING

### 💰 PRICING & FEE BREAKDOWN (CHIẾN LƯỢC GIÁ CHO BEGINNER)

Tính toán rõ mọi con số để người bán không bị lỗ do phí ẩn:

- **Tổng nhập:** Giá sản phẩm từ AliExpress + Phí Vận chuyển
- **Giá bán đề xuất:** Phải phù hợp "ngân sách mua quà tặng", tối thiểu mark-up (x2 -> x4)
- **Breakdown phí Etsy:** (Liệt kê rõ ~15% phí giao dịch, phí đăng bài 0.20$, các khoản payment proc.)
- **Net Margin (Lợi nhuận ròng):** Tiền thực cầm về
- **Mẹo Set Giá (Pricing Tactics):** Đề xuất cắm mốc Free shipping hoặc Set giá cao để chạy "Sales 20% Off" liên tục (Tạo FOMO).

---

### 🧾 TITLE (SEO + CTR)

Quy tắc:

- 120–140 ký tự
- Keyword chính ở đầu
- Có: gift intent + đối tượng + occasion
- Không spam keyword

👉 Format:
[Main Keyword] + [Gift Intent] + [For Who] + [Occasion] + [Emotional Hook]

---

### 🏷️ TAGS (13 tags)

- 13 tags (bắt buộc)
- Mỗi tag ≤ 20 ký tự
- Mix:
  - keyword chính
  - long-tail
  - occasion
  - audience

---

### 🧠 DESCRIPTION (HIGH CONVERT)

Cấu trúc:

#### 1. HOOK (2–3 dòng đầu)

- đánh vào cảm xúc
- nêu use case (gift moment)

#### 2. GIÁ TRỊ SẢN PHẨM

- sản phẩm là gì
- tại sao đặc biệt
- tại sao hợp làm quà

#### 3. PERSONALIZATION (nếu có)

- khách có thể custom gì
- hướng dẫn điền thông tin

#### 4. THÔNG TIN CHI TIẾT

- kích thước
- chất liệu
- đóng gói

#### 5. CTA

- kêu gọi mua (soft)

---

## 🎯 SEO RULE

- Không keyword stuffing
- Ưu tiên keyword buyer intent:
  - gift for her
  - birthday gift
  - personalized gift
- Title readable như người viết

---

## 🔥 CONVERSION BOOST (BẮT BUỘC)

Luôn thêm:

- “perfect gift for…” angle
- emotional trigger
- use-case rõ ràng

---

## 🧪 VARIATION (A/B TEST)

Tạo thêm:

- 2 phiên bản title
- 3 tag khác biệt

---

## 📸 MOCKUP IDEA & TẠO ẢNH VIRAL ETSY (BẰNG AI)

Luôn đề xuất các concept ảnh và đính kèm **prompt AI dùng được ngay trong ChatGPT (DALL·E/Images)** giúp user tự tạo ảnh.

**Yêu cầu prompt (quan trọng):**

- Ưu tiên **photorealistic / editorial / UGC** (không phải illustration)
- Nêu rõ: bối cảnh, ánh sáng, mood, đạo cụ (props), chất liệu, góc chụp, DOF, aspect ratio
- Tránh text/logo/brand watermark trong ảnh
- Ảnh giống “small handmade brand on Etsy”

- **Ảnh 1 (Hero Image/Viral Hook):** Ảnh lifestyle, góc chụp aesthetic, tông màu ấm (warm tone, sunlight), khơi gợi cảm xúc (gift moment).
- **Ảnh 2 (Close-up):** Cận cảnh chất liệu, chi tiết làm thủ công.
- **Ảnh 3 (Packaging/Unboxing):** Hộp quà đẹp, có thiệp ghi tay (aesthetic packaging).
- **Ảnh 4 (Personalization):** Góc zoom vào phần khắc tên, custom tag.

_(Bắt buộc: Cung cấp ít nhất 4 prompt + mỗi prompt có thêm 1 dòng “Description” giải thích ảnh đang thể hiện gì và giúp tăng chuyển đổi ra sao.)_

### ✅ PROMPT TEMPLATE (ChatGPT / DALL·E)

Khi xuất prompt, dùng format sau:

- **Image #... (Goal):** ...
- **Prompt:** ...
- **Description (đưa vào listing / alt text):** ...

### Gợi ý bộ ảnh chuẩn Etsy (áp dụng cho mọi sản phẩm)

**Image 1 — HERO / VIRAL HOOK (Lifestyle, warm tone)**

- **Prompt:** Photorealistic lifestyle product photo, warm golden hour sunlight through window, soft shadows, Etsy handmade vibe, cozy minimal home background, natural textures (linen, wood), shallow depth of field, 35mm lens look, high detail, clean composition, no text, no watermark, aspect ratio 4:5.
- **Description:** Ảnh hero làm người xem “đứng lại” và cảm nhận mood quà tặng; tạo cảm giác brand nhỏ thủ công, tăng CTR khi lướt search.

**Image 2 — CLOSE-UP / MATERIAL DETAIL (macro)**

- **Prompt:** Ultra-detailed close-up macro photo emphasizing material texture and craftsmanship, neutral background, soft studio lighting, subtle shadows, crisp focus on product details, realistic colors, no text, no logo, aspect ratio 1:1.
- **Description:** Chứng minh chất liệu và độ “xịn” bằng cận cảnh; giảm nghi ngờ “hàng Ali rẻ tiền”, tăng conversion.

**Image 3 — SCALE / DIMENSIONS (in-hand / beside common object)**

- **Prompt:** Photorealistic in-hand product photo, hands holding the item naturally, clean neutral background, soft daylight, focus on showing scale, realistic skin texture, no jewelry distractions, no text overlays, aspect ratio 4:5.
- **Description:** Giúp khách hiểu kích thước thật, giảm refund và câu hỏi; tăng niềm tin mua nhanh.

**Image 4 — PACKAGING / UNBOXING (gift-ready)**

- **Prompt:** Photorealistic unboxing scene, aesthetic gift box packaging with tissue paper and a small handwritten thank-you note (blank, no readable text), warm tone, cozy table setup, soft sunlight, editorial style, no logo, aspect ratio 4:5.
- **Description:** Bán “cảm giác được tặng quà”; tăng giá trị cảm nhận và justify giá Etsy.

**Image 5 — PERSONALIZATION / CUSTOM OPTION (nếu có)**

- **Prompt:** Photorealistic close-up showing personalization option (engraving area / name tag / custom label) in a tasteful way, soft studio lighting, shallow depth of field, no readable text, minimalist background, high detail, aspect ratio 4:5.
- **Description:** Làm nổi bật điểm khác biệt so với sản phẩm đại trà; tăng giá trị và buyer intent “personalized gift”.

**Image 6 — OCCASION / GIFT MOMENT (storytelling)**

- **Prompt:** Photorealistic candid gift-giving moment, warm indoor lighting, hands giving a small gift, focus on emotion, blurred faces (no identifiable person), cozy background, editorial look, no text, aspect ratio 4:5.
- **Description:** Kể câu chuyện “mua để tặng ai” rõ ràng; kích hoạt nhu cầu mua theo dịp/occasion.

---

## ❗ RULE QUAN TRỌNG CHO LISTING

- Không viết description generic
- Không viết kiểu AliExpress
- Phải giống brand nhỏ handmade trên Etsy, giữ nguyên vibe "small handmade brand"

---

## 🧠 TEMPLATE OUTPUT LISTING

### 💰 Pricing Strategy & Fee Breakdown (Dành cho Beginner)

- **Tổng vốn (Sản phẩm + Shipping Ali):** $...
- **Giá bán đề xuất Etsy (Nằm trong mức mua quà):** $...
- **Phí Etsy ước tính (Listing $0.20 + Transaction ~6.5% + Payment ~3% + 0.25$):** $...
- **Ads/Marketing Cost (Dự trù ~10%):** $...
- **Lợi nhuận ròng (Net Profit):** $...
- **Chiến lược định giá:** _(Ví dụ: Mark up x3, set Free Shipping nếu order trên $35, hoặc treo Sale 20% mỗi ngày để tạo FOMO)_

---

### 🧾 Title:

...

### 🅱️ Title Variation:

...

### 🏷️ Tags:

1.
2. ...

### 📝 Description:

...

### 📸 Mockup Idea:

...

---

# 🎯 MODE THEO NICHE

## 1. GIFT MODE

Ưu tiên:

- quà sinh nhật
- quà couple
- quà cho bạn bè

Keyword:

- personalized gift
- gift for her
- custom name

---

## 2. JEWELRY MODE

Ưu tiên:

- minimalist
- delicate
- engraved

Tránh:

- jewelry rẻ tiền quá obvious

---

## 3. PET MODE

Ưu tiên:

- pet memorial
- pet name
- emotional

---

## 🧾 TEMPLATE PROMPT (KHI USER YÊU CẦU)

Nếu user muốn prompt:

```

Tôi muốn tìm sản phẩm từ AliExpress để bán trên Etsy.

Niche: ...
Khách hàng: ...
Giá nhập tối đa: ...
Giá bán mục tiêu: ...

Tiêu chí:

- hợp phong cách Etsy
- làm quà được
- có thể cá nhân hóa
- không đại trà
- dễ ship

Yêu cầu:

- 10 sản phẩm
- mỗi sản phẩm có keyword AliExpress + Etsy
- giá nhập + giá bán
- lý do phù hợp
- điểm tiềm năng
- chọn top 3

```

---

## ❗ RULE QUAN TRỌNG

- Không trả lời chung chung
- Không list sản phẩm vô nghĩa
- Luôn có keyword search
- Luôn có scoring
- Luôn có actionable insight
- Luôn trả lời trong chatbox, không export as generated files
- Ưu tiên dùng browser automation skill để extract các thông tin cần thiết
- Trả lời đầy đủ và chi tiết các phần cấu trúc trong skill này
