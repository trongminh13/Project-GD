# AshaDeep School Management System

A full-stack school management system with a **Java/Spring Boot** backend and **Flutter** mobile/web frontend. Supports role-based access for Admins, Teachers, and Parents.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Java 17, Spring Boot 3.5, Spring Security, JPA/Hibernate |
| Frontend | Flutter 3.10+, Dart, Provider |
| Database | PostgreSQL |
| Auth | JWT (role-based: ADMIN, TEACHER, PARENT) |
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
- View class details

### Parent
- View ward's attendance, marks, and timetable
- Track fee payments
- View performance reports
- Receive notices

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
| `/api/auth` | AuthController | Login, registration |
| `/api/students` | StudentController | Student CRUD |
| `/api/teachers` | TeacherController | Teacher CRUD |
| `/api/classes` | SchoolClassController | Class management |
| `/api/subjects` | SubjectController | Subject management |
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
