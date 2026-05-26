# retest-bug

Claude Code plugin ที่ทำให้การรีเทสบัคจาก Jira เสร็จใน **1 คำสั่ง** — แค่ให้ ticket มา ที่เหลือทำให้หมด

## ทำไมต้องใช้

| เดิม (manual) | ใช้ plugin |
|---------------|-----------|
| เปิด ticket อ่าน → login portal → ทดสอบเอง → จด evidence → เขียน comment → copy ลง Jira → move status → assign dev | พิมพ์ `/retest-bug CP-12345` แล้วรอ approve comment ที่เดียว |
| ใช้เวลา **30-60 นาที** ต่อ ticket | ใช้เวลา **5-10 นาที** ต่อ ticket |
| ลืม transition / ลืม assign / format ไม่ consistent | ทำให้ครบทุกขั้นตอน ทุกครั้ง format เดียวกันหมด |

## สิ่งที่ได้

- **ทดสอบให้อัตโนมัติ** — login portal, เรียก API, เทียบ Swagger spec, จับ screenshot (Bug FE)
- **Comment สำเร็จรูป** — evidence ครบ, format ตาม guide, รอแค่กด approve
- **ปิดงานให้จบ** — transition (PASSED → Ready to Demo / FAILED → In Progress) + assign กลับ dev อัตโนมัติ
- **ไม่ต้องจำขั้นตอน** — อ่าน retest guide + เลือก test strategy + เก็บหลักฐาน ทำให้หมด

## Install

```
/install-plugin https://github.com/Thitic9203/retest-bug-plugin
```

## Usage

```
/retest-bug CP-12345
/retest-bug https://humanintelligence.atlassian.net/browse/CP-12345
```

## Prerequisites

- **VPN:** OpenVPN Connect → `ovpn.mycreditport.com` (ต้อง connect ก่อน)
- **Jira:** login `humanintelligence.atlassian.net` ใน Chrome (ขอครั้งเดียวต่อ session)
