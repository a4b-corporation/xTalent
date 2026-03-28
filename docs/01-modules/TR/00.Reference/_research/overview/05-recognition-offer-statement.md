# Recognition, Offer Management & Total Rewards Statement

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR, Managers, Employees, Recruiters  
**Đọc ~20 phút**

---

## Tổng quan

Tài liệu này bao gồm 3 sub-module hướng **Employee & Candidate Experience**:

- **Recognition Programs** — Hệ thống ghi nhận point-based, đổi điểm lấy perks
- **Offer Management** — Tạo và quản lý offer package cho ứng viên
- **Total Rewards Statement** — Báo cáo tổng đãi ngộ cho nhân viên

---

## Phần 1: Recognition Programs

### Kiến trúc

```
Recognition System
├── RecognitionEventType (loại ghi nhận + điểm trao)
├── RecognitionEvent      (sự kiện ghi nhận cụ thể)
├── PointAccount          (số dư điểm của nhân viên)
├── RewardPointTransaction (ledger mọi biến động điểm)
├── PerkCategory          (nhóm perks)
├── Perk                  (item trong catalog)
└── PerkRedemption        (đổi điểm lấy perk)
```

### 3 loại Recognition Event

| Loại | Ai trao | Điểm điển hình | Ví dụ |
|------|---------|:--------------:|-------|
| **Peer Recognition** | Nhân viên ↔ đồng nghiệp | 50-100 điểm | "Cảm ơn đã hỗ trợ tôi deadline gấp" |
| **Manager Recognition** | Manager → nhân viên | 100-500 điểm | "Dự án X vượt kỳ vọng" |
| **Milestone Recognition** | Hệ thống tự động | 500-2,000 điểm | Anniversary 5 năm, project completion |

### Recognition Flow — End-to-End

```
GIVER                   SYSTEM                    RECIPIENT
  │                        │                          │
  │ Give recognition ──────→│                          │
  │                        │ Validate event type       │
  │                        │ Calculate points (lookup) │
  │                        │ Create RecognitionEvent   │
  │                        │ Update PointAccount ──────→│ (+points)
  │                        │ Create PointTransaction   │
  │                        │ Send notification ────────→│
  │                        │                          │
  │                        │    [Later: Redemption]   │
  │                        │                          │
  │                        │←── Browse catalog ────────│
  │                        │ Check inventory           │
  │                        │←── Select perk ───────────│
  │                        │ Validate balance          │
  │                        │ Deduct points (FIFO) ─────→│ (-points)
  │                        │ Create PerkRedemption     │
  │                        │ Notify Fulfillment ───────→│ (delivery)
```

### FIFO Point Expiration — Quan trọng

Điểm expire theo thứ tự FIFO (First In, First Out) sau X tháng (thường 12 tháng):

```
Ví dụ: Nhân viên có 3 transactions điểm
  Jan 2024: +200 điểm (earned 2024-01-15)
  Mar 2024: +300 điểm (earned 2024-03-10)
  Jun 2024: +150 điểm (earned 2024-06-20)

Khi nhân viên redeem 250 điểm:
  → Trước tiên dùng 200 điểm từ Jan (FIFO)
  → Rồi dùng 50 điểm từ Mar
  → Còn lại: 250 điểm từ Mar + 150 điểm từ Jun

Khi expire (Jan 2025 - sau 12 tháng):
  → Tự động expire phần điểm Jan 2024 chưa redeem
  → Create EXPIRATION transaction
  → Không cần HR can thiệp thủ công
```

**Lý do FIFO**: Khuyến khích nhân viên sử dụng điểm cũ trước, tránh giữ điểm quá lâu, giảm liability của công ty.

### Perk Catalog

```yaml
Perk Categories (ví dụ):
  Gift Cards:
    - Amazon voucher (100K, 200K, 500K điểm)
    - Shopee voucher
    - Restaurant vouchers
  
  Experiences:
    - Spa voucher 1 người
    - Movie tickets (2 vé)
    - Weekend trip package
  
  Merchandise:
    - Electronics accessories
    - Company branded items
    - Fitness equipment
  
  Charitable:
    - Donation to chosen charity

Perk attributes:
  - Point cost
  - Inventory count (có thể hết hàng)
  - Redemption limits per employee
  - Taxable value (nếu có → TaxableItem → Payroll)
```

### Fulfillment Tracking

```
PerkRedemption Status Flow:
  PENDING → PROCESSING → SHIPPED → DELIVERED

HR hoặc fulfillment vendor track delivery:
  - Vật lý: tracking number
  - Gift card: auto-issue digital code
  - Experience: confirmation email với booking details
```

---

## Phần 2: Offer Management

### Mục đích

Offer Management cho phép Recruiter/HR tạo **Offer Package** toàn diện cho ứng viên — không chỉ là mức lương mà còn bonus target, equity grant, benefits preview, và tổng giá trị ước tính.

### Kiến trúc

```
OfferTemplate (template tái sử dụng)
    └── OfferPackage (offer cụ thể cho 1 candidate)
          ├── OfferComponent[] (các thành phần: base, bonus, RSU...)
          └── OfferEvent[] (lifecycle: created, sent, viewed, accepted...)
```

### Offer Package — Nội dung

```yaml
OfferPackage Components (ví dụ):
  Base Salary:      80,000,000 VND/month
  Annual Bonus:     Target 15% = 12,000,000 VND/year (ước tính)
  Sign-On Bonus:    30,000,000 VND (one-time)
  RSU Grant:        500 units, vest 4 năm = ~150M VND (market FMV ước tính)
  Benefits Value:   ~36,000,000 VND/year (health + dental + wellness)
  ─────────────────────────────────────
  Total Est. Value: ~1,278,000,000 VND/year
```

Tổng giá trị được tính tự động — giúp ứng viên thấy full picture, không chỉ nhìn vào take-home salary.

### Offer Lifecycle

```
OfferEvent flow:
  CREATED   → Recruiter tạo offer package
  SENT      → Gửi link đến candidate
  VIEWED    → Candidate open link (tracked)
  ACCEPTED  → Candidate ký chấp nhận (e-signature)
      hoặc
  REJECTED  → Candidate từ chối (ghi nhận lý do)
      hoặc
  COUNTERED → Candidate đề xuất counter terms
      └── REVISED → HR/Recruiter chỉnh sửa lại
          └── SENT → Gửi lại candidate
```

### E-Signature Integration

```yaml
Offer acceptance qua e-signature:
  - Candidate nhận link secure
  - Xem offer document đầy đủ
  - Ký điện tử trực tiếp trên platform
  - Timestamp + IP recorded
  - PDF bản ký tải về / lưu trữ

Không cần:
  - In ra, ký tay, scan
  - Email document qua lại
```

### Counter-Offer Workflow

```yaml
Ví dụ counter-offer:
  HR gửi: Base 80M + RSU 500 units
  Candidate counter: Base 85M + RSU 600 units

  HR response options:
    Accept counter:  Tạo REVISED offer
    Partial accept:  Base 82M + RSU 550 units (negotiate)
    Decline:         Giữ nguyên hoặc withdraw offer

Mỗi version counter được lưu lại → audit trail đầy đủ
```

---

## Phần 3: Total Rewards Statement

### Mục đích

**Total Rewards Statement** là báo cáo hàng năm cho nhân viên thấy **toàn bộ giá trị đãi ngộ họ nhận được** — vì nhiều nhân viên chỉ nhìn vào take-home pay và không nhận ra employer đang đầu tư bao nhiêu vào họ.

> **Thực tế**: Tổng rewards value thường cao hơn take-home pay 40-60% khi tính đủ employer contributions, benefits, equity, training...

### Statement Sections

```yaml
Section 1: Cash Compensation
  Base Salary:          960,000,000 VND/year
  Annual Bonus (paid):  96,000,000 VND
  Overtime (nếu có):    N/A
  Subtotal:           1,056,000,000 VND

Section 2: Benefits (Employer Contribution)
  Health Insurance (employer share): 36,000,000 VND
  Dental Insurance (employer share):  6,000,000 VND
  Life Insurance (employer paid):     2,400,000 VND
  Wellness allowance:                 5,000,000 VND
  Subtotal:                          49,400,000 VND

Section 3: Equity Compensation
  RSU vested this year (250 units × FMV):  30,000,000 VND
  Unvested RSU (future value estimate):   ~90,000,000 VND
  Subtotal (vested only):                  30,000,000 VND

Section 4: Employer Statutory Contributions
  Social Insurance (employer 17.5%):     32,760,000 VND
  Health Insurance (employer 3%):         5,616,000 VND
  Subtotal:                              38,376,000 VND

Section 5: Recognition & Perks
  Recognition points awarded:            500 points (~500,000 VND)
  Perks redeemed:                        300,000 VND

─────────────────────────────────────────────────
TOTAL REWARDS VALUE:                  1,174,076,000 VND/year
Take-Home Comparison:                   720,000,000 VND (est)
Employer Investment Beyond Salary:      454,076,000 VND (63%)
```

### Statement Generation

```yaml
Individual Generation:
  HR chọn nhân viên → Generate → PDF → Gửi qua email
  Employee tự access qua self-service portal

Batch Generation:
  HR chọn nhóm (all employees, by department, by grade)
  Thiết lập template và effective date (annual: 31/12)
  System batch generate → queue → send automatically

Distribution channels:
  - Email với secure PDF attachment
  - Employee self-service portal (download anytime)
  - Print (for special cases)
```

### Statement Template Configuration

```yaml
HR có thể customize:
  - Logo & branding
  - Sections hiển thị (chọn bỏ section nào)
  - Equity: hiển thị vested only vs cả unvested estimate
  - Benefits: hiển thị total premium vs employer contribution only
  - Currency / language
  - Comparison benchmarks (nếu muốn show vs market)
```

---

*Nguồn: `06-recognition-programs-guide.md` · `07-offer-management-guide.md` · `08-total-rewards-statements-guide.md` · Workflow 4 (`02-conceptual-guide.md`)*  
*← [04 Benefits Administration](./04-benefits-administration.md) · [06 Calculation & Compliance →](./06-calculation-compliance.md)*
