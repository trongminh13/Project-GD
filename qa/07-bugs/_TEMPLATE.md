# 07-bugs — Template Báo Lỗi

Sao chép file này, đặt tên theo mẫu `BUG-NNN-<mo-ta-ngan>.md`.

---

# BUG-NNN — <tiêu đề ngắn, rõ ràng>

- **Mức độ:** Nghiêm trọng / Cao / Trung bình / Thấp
- **Module:** AUTH / SEC / CORE / ATT / HW / MAT / IMP / PAY / NOTI / UI / NFR
- **Môi trường / thiết bị / phiên bản:** localhost:8081 / Android 12 / Spring Boot 3.5
- **Test case liên quan:** TC-XXX-NNN
- **Ngày phát hiện:** YYYY-MM-DD
- **Người phát hiện:** AI QA Senior

---

## Các bước tái hiện

1. Đăng nhập với tài khoản `<vai_tro>` (username: `<username>`)
2. Gọi endpoint `<PHƯƠNG_THỨC> <URL>` với body: `<json>`
3. ...

## Kết quả thực tế

```
HTTP <status_code>
<response body>
```

## Kết quả mong đợi

```
HTTP <status_code mong đợi>
<response body mong đợi>
```

## Bằng chứng

- Log file: `06-execution-reports/YYYY-MM-DD-lan-01.md`
- Curl output: `(dán vào đây)`

## Trạng thái

- [ ] **Mới** — Phát hiện, chưa giao cho developer
- [ ] **Đã giao** — Developer đang xử lý
- [ ] **Đã sửa** — Developer báo sửa xong
- [ ] **Đã kiểm tra lại** — QA chạy lại, xác nhận sửa đúng
- [ ] **Đóng** — Đã xác nhận, không còn tái hiện được
- [ ] **Không sửa** — Được Product Owner chấp nhận rủi ro

---

## Mức độ nghiêm trọng — Định nghĩa

| Mức | Ví dụ |
|---|---|
| **Nghiêm trọng** | Rò rỉ dữ liệu cá nhân, mất tiền, xóa dữ liệu không thể phục hồi |
| **Cao** | Bảo mật IDOR, chức năng nghiệp vụ chính không hoạt động, dữ liệu sai |
| **Trung bình** | Chức năng phụ sai, thông báo lỗi không rõ, UX xấu |
| **Thấp** | Lỗi chính tả, layout lệch nhẹ, không ảnh hưởng chức năng |
