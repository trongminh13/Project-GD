# 05 — Bộ Kịch bản Kiểm thử Tự động (Automation API Collection)

**Công cụ sử dụng:** VS Code REST Client (tập tin `.http`) hoặc `curl` / Postman / Newman.  
**Mục tiêu:** Cho phép AI Lead và Tester chạy tự động 100% các endpoint API của Phase 1, xác thực mã phản hồi HTTP, kiểm tra phân quyền ReBAC và kiểm tra tính toàn vẹn dữ liệu.

---

## 1. Cấu trúc thư mục

```
qa/05-automation/
├── README.md                              Hướng dẫn cấu hình và chạy
└── api-collection/
    ├── 01-auth-and-profile.http           Kiểm thử Đăng nhập, Khóa tài khoản, Phiên JWT, Profile
    ├── 02-security-rebac.http             Kiểm thử 54 ca ReBAC & Ma trận phân quyền chéo lớp
    ├── 03-core-and-classes.http           Kiểm thử Năm học, Lớp, Học sinh, Phân công giảng dạy
    ├── 04-attendance-and-leave.http       Kiểm thử Điểm danh hàng loạt, Đơn xin nghỉ phép
    ├── 05-homework-and-materials.http     Kiểm thử Soạn bài, Giao bài, Làm bài, Chấm điểm, Tải file
    └── 06-fees-and-import.http            Kiểm thử Sao kê học phí, Thanh toán Sandbox, Import Excel
```

---

## 2. Cách chạy kiểm thử

### Cách 1: Sử dụng Extension REST Client trong VS Code / Antigravity IDE (Khuyến nghị)
1. Mở bất kỳ file `.http` nào trong thư mục `api-collection/`.
2. Bấm vào chữ **`Send Request`** hiển thị ngay phía trên mỗi request.
3. Cửa sổ bên phải sẽ hiển thị trực quan HTTP Status Code, Headers và JSON Response Body.

### Cách 2: Chạy kiểm thử tự động toàn diện qua JUnit / Maven
Toàn bộ logic bảo mật ReBAC và Rollback giao dịch đã được tích hợp sẵn trong bộ test tự động của Backend:
```bash
cd backend/school-backend
./mvnw test -Dtest=SecurityReBACTest,StudentSecurityMatrixTest,TransactionRollbackRealTest
```

---

## 3. Khai báo Biến môi trường mẫu (`.env` hoặc REST Client Environment)

```http
@baseUrl = http://localhost:8081
@adminUser = admin
@teacherUserCN = gv_chunhiem_3a
@teacherUserBM = gv_bomon_3a
@teacherUserOther = gv_lop_khac
@parentUser = ph_con_3a
@studentUser = hs_3a_01
@studentUserOther = hs_3b_01
```
