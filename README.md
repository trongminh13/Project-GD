# AshaDeep School Management System

A full-stack school management system with a **Java/Spring Boot** backend and **Flutter** mobile/web frontend. Supports role-based access for Admins, Teachers, Parents, and Students.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java 17, Spring Boot 3.5, Spring Security, JPA/Hibernate |
| Frontend | Flutter 3.10+, Dart, Provider |
| Database | PostgreSQL |
| Auth | JWT (role-based: ADMIN, TEACHER, PARENT, STUDENT) |
| Payments | Razorpay |
| SMS | Fast2SMS |

## Features

### Admin
- Student & teacher enrollment and management
- Class and subject management
- Timetable editing
- Fee structure setup and payment tracking
- Bulk import from Excel/CSV
- Attendance reports and analytics
- Audit log
- Send notices to parents

### Teacher
- View dashboard and timetable
- Mark student attendance
- Enter and upload marks
- Manage homework assignments and grading
- Review leave applications (Homeroom teachers)
- View class details

### Parent
- View ward's attendance, marks, and timetable
- Track fee payments
- Submit and track leave applications
- View performance reports
- Receive notices

### Student
- View personal timetable, subjects, and study materials
- View assigned homework and submit solutions
- Track personal attendance and grades
- Update password on initial login

## Default Credentials (Demo Accounts & Multi-Level Testing)

Hệ thống được cấu hình sẵn các tài khoản thử nghiệm cho toàn bộ các vai trò và cấp học để phục vụ kiểm thử nhanh (cả chế độ **Online Backend** và **Offline/Demo Fallback**):

### Bảng Danh Sách Tài Khoản Thử Nghiệm

| Vai trò (Role) | Username / Số ĐT | Mật khẩu | Cấp học & Khối lớp | Họ tên & Phạm vi kiểm thử (Scope) |
|----------------|------------------|----------|-------------------|-----------------------------------|
| **ADMIN** | `admin` | `admin123` | Toàn trường | **Quản trị viên Đại Việt** — Toàn quyền quản trị hệ thống, quản lý giáo viên, phân công lớp, gửi thông báo toàn trường, cấu hình học phí, nhập liệu Excel |
| **TEACHER** | `T001` | `teacher123` | Lớp 1A (Tiểu học) | **Thầy Rajesh Sharma** — GV Chủ nhiệm & GV bộ môn Toán Lớp 1A. Điểm danh học sinh, tạo/chấm bài tập, duyệt đơn xin nghỉ, xem danh sách lớp |
| **TEACHER** | `T002` | `teacher123` | Lớp 1A (Tiểu học) | **Cô Priya Singh** — GV bộ môn Tiếng Anh Lớp 1A. Quản lý và giao bài tập bộ môn |
| **TEACHER** | `T003` | `teacher123` | Chưa phân công | **Thầy Amit Patel** — GV bộ môn Khoa học (Dùng để kiểm thử phân quyền IDOR khi giáo viên truy cập lớp chưa được phân công) |
| **STUDENT (Cấp 1)** | `student01` | `student123` | **Cấp 1 - Lớp 1A** (Tiểu học) | **Em Nguyễn Minh Anh** (Mã HS: `STU001`) — Badge **Tiểu học**, nạp động môn học GDPT 2018 Cấp 1 (*Toán, Tiếng Việt, Đạo đức, TN&XH...*), xếp loại theo **Thông tư 27/2020/TT-BGDĐT** (*Hoàn thành xuất sắc/tốt/hoàn thành*) |
| **STUDENT (Cấp 2)** | `student02` | `student123` | **Cấp 2 - Lớp 6A** (THCS) | **Em Trần Bảo Nam** (Mã HS: `STU002`) — Badge **THCS**, nạp động môn học GDPT 2018 Cấp 2 (*Toán, Ngữ văn, KHTN, Lịch sử & Địa lí, GDCD...*), xếp loại theo **Thông tư 22/2021/TT-BGDĐT** (*Tốt, Khá, Đạt, Chưa đạt*) |
| **STUDENT (Cấp 3)** | `student03` | `student123` | **Cấp 3 - Lớp 10A** (THPT) | **Em Lê Hoàng Long** (Mã HS: `STU003`) — Badge **THPT**, nạp động môn học GDPT 2018 Cấp 3 (*Toán, Ngữ văn, Vật lí, Hóa học, Sinh học, Lịch sử, Địa lí, Tin học, GDKT&PL...*), xếp loại theo **Thông tư 22/2021/TT-BGDĐT** (*Tốt, Khá, Đạt, Chưa đạt*) |
| **STUDENT (Mẫu API)** | `ADM-2026-TEST` | `ADM-2026-TEST@School` | Theo hồ sơ tạo mới | Tài khoản học sinh mẫu tạo qua API/Import — Bắt buộc đổi mật khẩu ở lần đăng nhập đầu tiên (`must_change_password = true`) |
| **PARENT** | `9910157611` | `123456` | Toàn bộ 3 cấp | **Phụ huynh Nguyễn Văn Hùng** — Phụ huynh liên kết của cả 3 học sinh (`student01`, `student02`, `student03`). Theo dõi điểm danh, điểm số, bài tập, đơn xin nghỉ và nhận thông báo con em |

---

### Hướng Dẫn Kiểm Thử Nhanh (Fast Testing Guide)

#### 1. Đăng Nhập 1-Chạm Trên Ứng Dụng Flutter (1-Click Demo Chips)
- Mở màn hình Đăng nhập trên Mobile hoặc Web:
  - Phía trên nút Đăng nhập có sẵn khu vực **"Chạm để điền nhanh tài khoản Demo"** gồm 6 nút bấm tiện lợi:
    - `[HS Cấp 1]`: Tự điền `student01` / `student123`, chọn tab Học sinh.
    - `[HS Cấp 2]`: Tự điền `student02` / `student123`, chọn tab Học sinh.
    - `[HS Cấp 3]`: Tự điền `student03` / `student123`, chọn tab Học sinh.
    - `[Giáo viên]`: Tự điền `T001` / `teacher123`, chọn tab Giáo viên.
    - `[Admin]`: Tự điền `admin` / `admin123`, chọn tab Admin.
    - `[Phụ huynh]`: Tự điền `9910157611` / `123456`, chọn tab Phụ huynh.
- Bấm **"Đăng nhập"** để truy cập ngay vào giao diện tương ứng của từng vai trò.

#### 2. Cơ Chế Offline / Demo Fallback Tự Động
- Ứng dụng tích hợp cơ chế **Demo Fallback thông minh**:
  - Nếu Backend Spring Boot đang chạy: Hệ thống xác thực trực tiếp qua cơ sở dữ liệu PostgreSQL.
  - Nếu Backend chưa khởi động hoặc gặp sự cố mạng: Ứng dụng tự động chuyển sang chế độ Demo Fallback mượt mà, cấp phát JWT giả lập và nạp đầy đủ dữ liệu thích ứng để bạn có thể kiểm thử toàn bộ giao diện và luồng nghiệp vụ mà không bị gián đoạn.

#### 3. Đăng Nhập Phụ Huynh Bằng OTP (Parent OTP Flow)
- Trên giao diện Flutter, chuyển sang tab **Phụ huynh**.
- Nhập số điện thoại: `9910157611` rồi bấm gửi mã OTP.
- Ở môi trường phát triển (Local Dev), mã OTP 6 số ngẫu nhiên được in trực tiếp ra log màn hình console của Backend Spring Boot. Nhập mã này để xác thực đăng nhập.

#### 4. Quy Chuẩn Đổi Mật Khẩu Bắt Buộc Của Học Sinh Mới
- Khi Admin tạo học sinh mới qua API hoặc tính năng Import Excel:
  - Mật khẩu mặc định được sinh tự động theo quy tắc: `<admission_number>@School` (Ví dụ: mã `STU-DUAL-001` sẽ có pass là `STU-DUAL-001@School`).
  - Cờ `must_change_password` được thiết lập `true`. Khi học sinh đăng nhập lần đầu, ứng dụng tự động hiển thị màn hình yêu cầu cập nhật mật khẩu mới trước khi vào Dashboard chính.

---

### Kiểm Thử API Trực Tiếp Bằng cURL

Dưới đây là các lệnh cURL mẫu để kiểm tra nhanh các API chính từ dòng lệnh:

```bash
# 1. Đăng nhập Quản trị viên (Admin)
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# 2. Đăng nhập Giáo viên chủ nhiệm Lớp 1A (T001)
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "T001", "password": "teacher123"}'

# 3. Đăng nhập Học sinh Cấp 1 (student01)
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "student01", "password": "student123"}'

# 4. Lấy thông tin hồ sơ học sinh & Cấp học thích ứng (EducationLevel)
# (Thay <JWT_TOKEN> bằng token nhận được từ bước đăng nhập học sinh)
curl -X GET http://localhost:8081/api/student-portal/profile \
  -H "Authorization: Bearer <JWT_TOKEN>"

# 5. Phụ huynh xem danh sách tất cả con em của mình (/my-wards)
# (Thay <PARENT_JWT_TOKEN> bằng token nhận được từ đăng nhập 9910157611)
curl -X GET http://localhost:8081/api/students/my-wards \
  -H "Authorization: Bearer <PARENT_JWT_TOKEN>"

# 6. Xem danh sách thông báo & Đánh dấu đọc tất cả
curl -X GET http://localhost:8081/api/notifications/my-notifications \
  -H "Authorization: Bearer <JWT_TOKEN>"

curl -X PUT http://localhost:8081/api/notifications/read-all \
  -H "Authorization: Bearer <JWT_TOKEN>"
```


## Project Structure

```
├── backend/school-backend/       # Spring Boot API
│   ├── src/main/java/com/school/backend/
│   │   ├── controller/           # REST endpoints
│   │   ├── entity/               # JPA entities
│   │   ├── service/              # Business logic
│   │   ├── repository/           # Data access
│   │   ├── dto/                  # Request/response objects
│   │   ├── security/             # JWT config
│   │   └── util/                 # Encryption converters
│   └── src/main/resources/
│       └── application.properties
├── frontend/                     # Flutter app
│   └── lib/
│       ├── core/services/        # API service classes
│       ├── core/models/          # Data models
│       ├── features/admin/       # Admin screens
│       ├── features/teacher/     # Teacher screens
│       ├── features/parent/      # Parent screens
│       └── screens/              # Shared screens (login, splash)
├── database/
│   └── schema.sql                # PostgreSQL schema
└── VERSION
```

## Prerequisites

- **JDK 17**
- **Flutter SDK 3.10+**
- **PostgreSQL**
- **Maven** (wrapper included)

## Setup

### 1. Database

```bash
# Create the database
createdb ashadeep_school_db

# Run the schema
psql -d ashadeep_school_db -f database/schema.sql
```

### 2. Backend

```bash
cd backend/school-backend

# Set required environment variables
export DB_PASSWORD=your_postgres_password
export JWT_SECRET=$(openssl rand -base64 64)
export DB_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Optional
export DB_URL=jdbc:postgresql://localhost:5432/ashadeep_school_db
export DB_USERNAME=postgres
export FAST2SMS_KEY=your_key
export RAZORPAY_KEY_ID=your_key
export RAZORPAY_KEY_SECRET=your_secret

# Build and run
./mvnw spring-boot:run
```

The API runs on `http://localhost:8081`.

### 3. Frontend

```bash
cd frontend

# Copy env file and update with your backend URL
cp .env.example .env
# Edit .env: API_BASE_URL=http://YOUR_IP:8081/api

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Environment Variables

See `backend/school-backend/src/main/resources/application.properties.example` for the full list.

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_PASSWORD` | Yes | PostgreSQL password |
| `JWT_SECRET` | Yes | Base64-encoded JWT signing key (256+ bits) |
| `DB_ENCRYPTION_KEY` | Yes | Base64-encoded AES-256 key for field encryption |
| `DB_URL` | No | JDBC URL (default: localhost:5432/ashadeep_school_db) |
| `DB_USERNAME` | No | Database user (default: postgres) |
| `FAST2SMS_KEY` | No | Fast2SMS API key for SMS notifications |
| `RAZORPAY_KEY_ID` | No | Razorpay merchant key ID |
| `RAZORPAY_KEY_SECRET` | No | Razorpay merchant secret |

## Security

- **JWT authentication** with role-based access control
- **AES-256-GCM field-level encryption** for sensitive data (Aadhaar, DOB, address, email)
- Passwords hashed with BCrypt
- Secrets loaded from environment variables (not hardcoded)

## API Endpoints

| Prefix | Controller | Description |
|--------|-----------|-------------|
| `/api/auth` | AuthController | Login, registration, password update, OTP flow |
| `/api/student-portal` | StudentPortalController | Student profile (với EducationLevel), bảng điểm, điểm danh, thông báo học sinh |
| `/api/students` | StudentController | Student CRUD, `/api/students/my-wards` cho phụ huynh |
| `/api/teachers` | TeacherController | Teacher CRUD |
| `/api/classes` | SchoolClassController | Class management & timetable |
| `/api/subjects` | SubjectController | Subject management |
| `/api/materials` | MaterialController | Sách giáo khoa tương tác (SGK Flip Reader), bài giảng PDF/Video |
| `/api/homework` | HomeworkController | Kho bài tập, giao bài tập lớp, làm trắc nghiệm & tự luận, chấm điểm |
| `/api/notifications` | NotificationController | Phát thông báo đa tầng (Toàn trường, Khối, Lớp), đánh dấu đã đọc (`/read-all`) |
| `/api/fees` | FeeController | Fee structure & payments |
| `/api/attendance` | AttendanceController | Attendance tracking |
| `/api/bulk-import` | BulkImportController | Excel/CSV import |

## Building for Production

```bash
# Backend
cd backend/school-backend
./mvnw clean package -DskipTests

# Frontend
cd frontend
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

## License

See [LICENSE](LICENSE) for details.
