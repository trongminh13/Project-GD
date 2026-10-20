# Báo cáo rà soát cuối: Web, iOS, Android và API

**Dự án:** Project-GD / Astra  
**Ngày rà soát:** 20/10/2026  
**Phạm vi:** Mã Flutter dùng chung cho web, iOS, Android; cấu hình nền tảng; các luồng gọi backend liên quan.  
**Loại rà soát:** Đọc mã nguồn và đối chiếu API tĩnh. Không chạy build, test, hoặc kiểm thử trên thiết bị trong lượt rà soát này.

> Các mục dưới đây tổng hợp các phát hiện từ những lượt rà soát web/mobile trước đó và lượt rà soát cuối. Trạng thái được ghi theo mã nguồn đang có lúc tạo báo cáo; một số ghi chú trước đây đã được cải thiện và được nêu riêng ở cuối.

## Tóm tắt

| Mức độ | Số mục | Ý nghĩa |
|---|---:|---|
| P1 – chặn phát hành | 6 | Có thể làm sai cấu hình production, sai nghiệp vụ thu phí, mất phiên học sinh, hoặc khiến luồng nghiệp vụ chính không dùng được với dữ liệu thật. |
| P2 – cần xử lý trước UAT rộng | 9 | Tính năng chưa hoàn chỉnh, dữ liệu giả/cục bộ, hoặc khác biệt cấu hình giữa nền tảng. |
| P3 – cần dọn trước phát hành chính thức | 4 | Khả năng bảo trì, vận hành hoặc trải nghiệm chưa đạt mức production. |

Các mức trên là đánh giá theo rủi ro nghiệp vụ dựa trên mã nguồn, chưa phải kết quả chạy trên môi trường production.

## P1 – Chặn phát hành

### 1. Bản release có thể dùng API `localhost`

`frontend/.env` đặt `API_BASE_URL=http://localhost:8081/api` và `.env` được đóng gói thành asset. `main.dart` nạp file này; `ApiConstants.baseUrl` ưu tiên giá trị trong `.env` trước bước fail-fast cho release. Nếu build release không truyền `--dart-define=API_BASE_URL=...`, app có thể gọi localhost trên máy người dùng thay vì máy chủ production. Trên web, iOS và Android, `localhost` là thiết bị/trình duyệt của người dùng.

**Ảnh hưởng:** Đăng nhập và các API thật thất bại; cấu hình HTTP còn có thể bị chặn bởi chính sách bảo mật nền tảng/trình duyệt.

**Bằng chứng:** [frontend/.env](../../frontend/.env), [pubspec.yaml](../../frontend/pubspec.yaml), [main.dart](../../frontend/lib/main.dart), [constants.dart](../../frontend/lib/utils/constants.dart).

**Khuyến nghị:** Không đưa `.env` dev vào asset của bản release; cấu hình URL production tường minh khi build và xác thực scheme HTTPS trước khi phát hành.

### 2. Học sinh bị đăng xuất khi khởi động lại ứng dụng

Splash screen xác thực JWT qua endpoint hồ sơ dùng chung `/profile`. Backend giới hạn endpoint đó cho `ADMIN`, `TEACHER`, `PARENT`, trong khi role `STUDENT` phải dùng `/student-portal/profile`. Khi học sinh mở lại app, response 403 bị hiểu là token không hợp lệ và app xóa phiên.

**Ảnh hưởng:** Học sinh phải đăng nhập lại sau mỗi lần app khởi động; đây là lỗi chặn sử dụng trên Android/iOS và cũng ảnh hưởng phiên web được khôi phục.

**Bằng chứng:** [splash_screen.dart](../../frontend/lib/screens/splash_screen.dart), [ProfileController.java](../../backend/school-backend/src/main/java/com/school/backend/controller/ProfileController.java), [StudentPortalController.java](../../backend/school-backend/src/main/java/com/school/backend/controller/StudentPortalController.java).

**Khuyến nghị:** Xác thực phiên theo role qua endpoint đúng hoặc thêm endpoint kiểm tra phiên không phụ thuộc role; phân biệt 401/403 với lỗi mạng thay vì xóa phiên trên mọi lỗi.

### 3. Tạo đơn Razorpay chưa gắn với khoản phí thật và app dùng thông tin thanh toán mẫu

Màn hình phụ huynh gọi tạo order với `studentId` cố định `student123`, không truyền `feeStructureId`, dùng Razorpay key placeholder `TODO_REPLACE_WITH_LIVE_KEY`, cùng contact/email mẫu. Backend lấy số tiền từ request nếu không có `feeStructureId`; do đó giá trị gửi từ client có thể được dùng để tạo order thay vì số tiền khoản phí trong cơ sở dữ liệu.

**Ảnh hưởng:** Không thể thanh toán đúng học sinh/khoản phí trong production; order có thể sai số tiền và dữ liệu thu phí/đối soát không đáng tin cậy. Không phát hành thanh toán thật với cấu hình hiện tại.

**Bằng chứng:** [parent_fees_screen.dart](../../frontend/lib/features/parent/screens/parent_fees_screen.dart), [fee_service.dart](../../frontend/lib/core/services/fee_service.dart), [FeeService.java](../../backend/school-backend/src/main/java/com/school/backend/service/FeeService.java), [RazorpayOrderRequest.java](../../backend/school-backend/src/main/java/com/school/backend/payload/RazorpayOrderRequest.java).

**Khuyến nghị:** Lấy student ID và fee structure từ dữ liệu đã xác thực; client chỉ gửi ID khoản phí, còn backend tự xác định số tiền và kiểm tra quan hệ phụ huynh–học sinh. Đưa key theo môi trường và chỉ mở checkout khi backend trả order hợp lệ.

### 4. Luồng nhập điểm chưa hoạt động ổn định với danh sách học sinh thật

Màn hình tạo assessment dùng lớp/môn hardcode; assessment service giữ dữ liệu trong bộ nhớ. Lớp như `10-A` được dùng để lọc danh sách, trong khi model `Student` ánh xạ `schoolClass.grade` thành `className` (ví dụ `10`). So sánh chuỗi chính xác làm roster có thể rỗng. ID assessment sau đó được tạo từ timestamp; backend có thể tạo Exam tên `Assessment <timestamp>` thay vì liên kết với assessment đã chọn.

**Ảnh hưởng:** Giáo viên có thể không thấy học sinh thật để nhập điểm; khi gửi được, điểm có thể gắn vào bản ghi bài thi không đúng tên/không có liên kết nghiệp vụ.

**Bằng chứng:** [upload_marks_screen.dart](../../frontend/lib/features/teacher/screens/upload_marks_screen.dart), [assessment_service.dart](../../frontend/lib/core/services/assessment_service.dart), [student.dart](../../frontend/lib/models/student.dart), [student_service.dart](../../frontend/lib/core/services/student_service.dart), [MarksService.java](../../backend/school-backend/src/main/java/com/school/backend/service/MarksService.java).

**Khuyến nghị:** Tải teaching assignments, lớp, assessment và roster từ API; dùng ID lớp/assessment ổn định và thống nhất định dạng tên lớp giữa DTO và Flutter.

### 5. Import dữ liệu Excel từ giao diện web chưa được xác nhận tương thích

Luồng bulk import hiện dùng Flutter file picker và upload file. Các đường đi dữ liệu file trên web khác mobile; lượt rà soát trước ghi nhận nhánh web có rủi ro lấy đường dẫn/bytes không tương thích. Chưa có kiểm thử trình duyệt trong lượt rà soát này.

**Ảnh hưởng:** Quản trị viên có thể chọn được file nhưng upload thất bại hoặc gửi payload rỗng khi dùng web.

**Bằng chứng:** [bulk_import_screen.dart](../../frontend/lib/features/admin/screens/bulk_import_screen.dart), [BulkImportController.java](../../backend/school-backend/src/main/java/com/school/backend/controller/BulkImportController.java).

**Khuyến nghị:** Dùng bytes từ file picker cho web, kiểm tra file và kích thước trước upload, rồi xác nhận bằng kiểm thử trình duyệt với file hợp lệ và file lỗi.

### 6. Thời khóa biểu học sinh gọi API backend chưa có

Flutter gọi `GET /student-portal/timetable`, nhưng controller hiện chỉ có profile, attendance và marks. Hàm service bắt lỗi rồi trả danh sách rỗng; tab thời khóa biểu không thể phân biệt “chưa có lịch” với “API không tồn tại”.

**Ảnh hưởng:** Thời khóa biểu học sinh trống với dữ liệu thật trên các nền tảng.

**Bằng chứng:** [student_portal_service.dart](../../frontend/lib/core/services/student_portal_service.dart), [StudentPortalController.java](../../backend/school-backend/src/main/java/com/school/backend/controller/StudentPortalController.java), [student_dashboard_screen.dart](../../frontend/lib/features/student/screens/student_dashboard_screen.dart).

**Khuyến nghị:** Triển khai endpoint và quyền truy cập tương ứng, hoặc ẩn tab cho đến khi API sẵn sàng; không chuyển lỗi API thành trạng thái rỗng im lặng.

## P2 – Cần xử lý trước UAT rộng

### 7. Màn hình phụ huynh còn dùng ID mặc định hoặc dữ liệu tĩnh

Một số màn hình có giá trị mặc định như student ID `1`/`51`; trang chi tiết và các phần thời khóa biểu còn dựng dữ liệu trong UI. Dù dashboard có gọi danh sách wards, các màn hình con không phải luồng nào cũng nhận đúng ID học sinh đã chọn.

**Ảnh hưởng:** Có thể hiển thị nhầm hồ sơ/học phí/bài tập của học sinh khác hoặc nội dung mẫu; đây cũng là rủi ro riêng tư và sai nghiệp vụ.

**Bằng chứng:** [parent_dashboard_screen.dart](../../frontend/lib/features/parent/screens/parent_dashboard_screen.dart), [parent_ward_details_screen.dart](../../frontend/lib/features/parent/screens/parent_ward_details_screen.dart), [parent_marks_screen.dart](../../frontend/lib/features/parent/screens/parent_marks_screen.dart), [parent_fees_screen.dart](../../frontend/lib/features/parent/screens/parent_fees_screen.dart), [parent_homework_screen.dart](../../frontend/lib/features/parent/screens/parent_homework_screen.dart), [parent_timetable_screen.dart](../../frontend/lib/features/parent/screens/parent_timetable_screen.dart).

**Khuyến nghị:** Truyền ward ID đã chọn xuyên suốt navigation; bỏ ID fallback ở production và kiểm tra quyền sở hữu ở backend cho từng API.

### 8. Dashboard/báo cáo và một số nghiệp vụ còn dùng dữ liệu demo

Các màn hình dashboard có nhánh dữ liệu mẫu; một số báo cáo quản trị hiển thị số liệu/nhận xét cố định. Feature flag demo mặc định theo `kDebugMode`, nên bản release mặc định tắt; tuy vậy cấu hình bật demo tường minh vẫn có thể đưa dữ liệu giả vào giao diện.

**Ảnh hưởng:** Người dùng có thể hiểu nhầm số liệu mẫu là dữ liệu trường; các màn hình chưa đủ cơ sở để dùng làm báo cáo nghiệp vụ.

**Bằng chứng:** [feature_flags.dart](../../frontend/lib/core/config/feature_flags.dart), [student_dashboard_screen.dart](../../frontend/lib/features/student/screens/student_dashboard_screen.dart), [teacher_full_report_screen.dart](../../frontend/lib/features/admin/screens/teacher_full_report_screen.dart), [dashboard_screen.dart](../../frontend/lib/features/admin/screens/dashboard_screen.dart).

**Khuyến nghị:** Tách rõ demo build flavor; ở production hiển thị trạng thái “chưa có dữ liệu” thay vì số liệu giả và kiểm tra không bật demo flag trong pipeline phát hành.

### 9. Dữ liệu lớp/phân công giáo viên còn phụ thuộc cache cục bộ

Một số màn hình quản lý lớp/phân công làm việc với state/cache trong app; dashboard giáo viên đọc assignment từ `SchoolClassService` cục bộ, không thấy luồng tải dữ liệu assignment từ backend trong quá trình khởi tạo màn hình.

**Ảnh hưởng:** Dữ liệu có thể mất sau khi app khởi động lại, không đồng bộ giữa web/mobile hoặc không xuất hiện trên thiết bị mới; dashboard giáo viên có thể hiện trạng thái chưa có lớp.

**Bằng chứng:** [school_class_service.dart](../../frontend/lib/core/services/school_class_service.dart), [class_management_screen.dart](../../frontend/lib/features/admin/screens/class_management_screen.dart), [teacher_dashboard_screen.dart](../../frontend/lib/features/teacher/screens/teacher_dashboard_screen.dart).

**Khuyến nghị:** Dùng API làm nguồn dữ liệu chính cho lớp và phân công; cache chỉ hỗ trợ offline, có quy tắc đồng bộ và xử lý lỗi rõ ràng.

### 10. Push notification chưa được gửi qua Firebase Cloud Messaging

Backend có lưu thông báo và tạo FCM payload, nhưng code gửi hiện ghi payload vào log; chưa thấy thực hiện HTTP/API call tới FCM. Có API đăng ký device token và API danh sách thông báo, nhưng chúng không thay thế được push tới thiết bị.

**Ảnh hưởng:** Thông báo trong ứng dụng có thể xem khi mở app, nhưng thông báo nền/lock screen không được gửi như kỳ vọng.

**Bằng chứng:** [NotificationService.java](../../backend/school-backend/src/main/java/com/school/backend/service/NotificationService.java), [StudentPortalService.java](../../frontend/lib/core/services/student_portal_service.dart), [NotificationController.java](../../backend/school-backend/src/main/java/com/school/backend/controller/NotificationController.java).

**Khuyến nghị:** Tích hợp FCM Admin SDK hoặc HTTP v1 có xác thực server-side, xử lý token hết hạn và kết quả gửi; không log token/payload nhạy cảm.

### 11. Firebase cho iOS chưa có cấu hình nền tảng đi kèm

Android có `google-services.json`; trong thư mục iOS không thấy `GoogleService-Info.plist`. `main.dart` gọi `Firebase.initializeApp()` trên mobile nhưng không dùng Firebase options sinh tự động. Khởi tạo có thể lỗi và bị catch, khiến các chức năng dựa trên Firebase không hoạt động mà app vẫn chạy tiếp.

**Ảnh hưởng:** OTP/Firebase Auth hoặc push notification trên iOS có thể không khởi tạo; lỗi bị hạ thành log.

**Bằng chứng:** [main.dart](../../frontend/lib/main.dart), [android/app/google-services.json](../../frontend/android/app/google-services.json), thư mục [ios/Runner](../../frontend/ios/Runner).

**Khuyến nghị:** Thêm cấu hình iOS đúng Firebase project/bundle ID, cấu hình capabilities/APNs và báo lỗi rõ khi tính năng Firebase bắt buộc nhưng chưa khởi tạo.

### 12. Cấu hình Firebase Android và định danh ứng dụng còn mang tính mẫu

Android đang dùng application ID `com.example.admin_app`. Cần đối chiếu package name trong `google-services.json`, Firebase project, domain phát hành và application ID dự kiến trước khi phát hành.

**Ảnh hưởng:** App có thể không khớp Firebase app đã đăng ký; package ID mẫu cũng không phù hợp làm định danh sản phẩm chính thức.

**Bằng chứng:** [build.gradle.kts](../../frontend/android/app/build.gradle.kts), [google-services.json](../../frontend/android/app/google-services.json).

**Khuyến nghị:** Chọn application ID ổn định theo tổ chức và đăng ký riêng cho từng môi trường Firebase.

### 13. Lưu trạng thái đăng nhập chia giữa secure storage và SharedPreferences

JWT backend hiện ghi vào `FlutterSecureStorage`, đây là cải thiện so với ghi token trực tiếp trong SharedPreferences. Tuy nhiên splash screen vẫn giữ user data trong SharedPreferences và dùng nó để dựng phiên; cần đảm bảo dữ liệu cache không được xem là nguồn xác thực độc lập và được xóa đồng bộ khi token hết hạn/đăng xuất.

**Ảnh hưởng:** Có nguy cơ trạng thái người dùng cũ còn lại hoặc không đồng nhất với token, đặc biệt sau logout, đổi tài khoản hoặc lỗi xác thực.

**Bằng chứng:** [auth_service.dart](../../frontend/lib/core/services/auth_service.dart), [splash_screen.dart](../../frontend/lib/screens/splash_screen.dart).

**Khuyến nghị:** Giữ JWT trong secure storage; coi `user_data` chỉ là cache, ràng buộc cache với phiên hiện tại và xóa đồng bộ ở mọi nhánh logout/invalid session.

### 14. iOS thiếu Podfile trong checkout hiện tại

Thư mục `frontend/ios` hiện không có `Podfile`, trong khi app dùng plugin native như Firebase, secure storage và Razorpay. Điều này làm quy trình cài CocoaPods/build iOS trên máy CI hoặc máy mới không tái lập được từ checkout hiện tại.

**Ảnh hưởng:** Build iOS có thể dừng ở bước CocoaPods hoặc phụ thuộc file sinh ra trên máy cá nhân.

**Bằng chứng:** [frontend/ios](../../frontend/ios), [pubspec.yaml](../../frontend/pubspec.yaml).

**Khuyến nghị:** Khôi phục/commit Podfile và lockfile phù hợp với Flutter project; xác nhận `pod install` trong môi trường CI macOS.

### 15. Release Android đang ký bằng debug key

`build.gradle.kts` gán `signingConfig` release thành debug signing config.

**Ảnh hưởng:** Không đáp ứng phát hành chính thức; không thể dùng an toàn cho cập nhật Play Store và quản lý khóa phát hành.

**Bằng chứng:** [build.gradle.kts](../../frontend/android/app/build.gradle.kts).

**Khuyến nghị:** Thiết lập signing key riêng qua secret của CI/keystore được quản lý; không commit khóa hoặc mật khẩu vào repository.

## P3 – Cần dọn trước phát hành chính thức

### 16. Nhiều service tự bắt lỗi rồi trả dữ liệu rỗng

Một số service bắt mọi exception và trả `[]`, `null` hoặc map mặc định. UI vì thế không phân biệt lỗi mạng, 401/403, 404 và dữ liệu thật sự chưa có.

**Ảnh hưởng:** Lỗi tích hợp bị che khuất, gây chẩn đoán chậm và tạo cảm giác dữ liệu bị mất.

**Bằng chứng:** [fee_service.dart](../../frontend/lib/core/services/fee_service.dart), [student_portal_service.dart](../../frontend/lib/core/services/student_portal_service.dart) và các service Flutter liên quan.

**Khuyến nghị:** Chuẩn hóa lỗi trong API client/service; UI hiển thị retry, session expired, forbidden, empty state riêng biệt; log mã request và status mà không ghi PII/token.

### 17. Truy cập HTTP/local API chưa được tách rõ theo môi trường

URL dev dùng HTTP và localhost; môi trường production cần HTTPS. Các hạn chế cleartext và chính sách mixed content khác nhau giữa Android, iOS và trình duyệt.

**Ảnh hưởng:** Kết nối có thể hoạt động ở debug nhưng thất bại ở release hoặc trên một nền tảng cụ thể.

**Bằng chứng:** [constants.dart](../../frontend/lib/utils/constants.dart), [frontend/.env](../../frontend/.env), [Info.plist](../../frontend/ios/Runner/Info.plist), [AndroidManifest.xml](../../frontend/android/app/src/main/AndroidManifest.xml).

**Khuyến nghị:** Cho phép HTTP chỉ trong cấu hình dev; production buộc HTTPS và xác nhận chính sách ATS/Cleartext theo đúng domain backend.

### 18. Giao diện và nội dung còn dấu vết demo/placeholder

Một số nhãn, giá trị mặc định, thông tin liên hệ, dữ liệu mẫu và nội dung tiếng Anh còn trong màn hình nghiệp vụ tiếng Việt.

**Ảnh hưởng:** Giảm độ tin cậy và có thể gây hiểu nhầm khi demo/UAT; nội dung mẫu trong màn hình thanh toán đặc biệt cần thay.

**Bằng chứng:** [parent_fees_screen.dart](../../frontend/lib/features/parent/screens/parent_fees_screen.dart), [login_screen.dart](../../frontend/lib/screens/login_screen.dart), [teacher_full_report_screen.dart](../../frontend/lib/features/admin/screens/teacher_full_report_screen.dart), [bulk_import_screen.dart](../../frontend/lib/features/admin/screens/bulk_import_screen.dart).

**Khuyến nghị:** Rà soát localization, dữ liệu mặc định và placeholder theo từng role; chặn phát hành nếu còn dữ liệu liên hệ/đơn hàng demo.

### 19. Luồng thông báo quản trị cần đối chiếu audience UI với API

Màn hình gửi thông báo còn danh sách audience tĩnh như `All Parents`, `Class 10 Only`, `Teachers`, `Staff`; backend có kiểu audience và mục tiêu phân phối riêng. Cần xác nhận mapping UI → request → người nhận thực tế và quyền gửi theo role.

**Ảnh hưởng:** Thông báo có thể không đến đúng nhóm hoặc UI cho chọn đối tượng mà backend không hỗ trợ đúng nghĩa.

**Bằng chứng:** [send_notices_screen.dart](../../frontend/lib/features/admin/screens/send_notices_screen.dart), [NotificationService.java](../../backend/school-backend/src/main/java/com/school/backend/service/NotificationService.java), [SendNotificationRequest.java](../../backend/school-backend/src/main/java/com/school/backend/payload/request/SendNotificationRequest.java).

**Khuyến nghị:** Dùng enum/API metadata chung cho danh sách audience, xác thực quyền và kiểm tra số lượng/đối tượng nhận trước khi gửi.

## Ghi nhận các điểm đã cải thiện

- JWT backend hiện được ghi bằng `FlutterSecureStorage`; không nên mô tả hiện trạng là JWT lưu trong SharedPreferences.
- `FeatureFlags.useDemoFallback` mặc định theo `kDebugMode`, nên false ở release nếu không bật demo rõ ràng.
- Cấu hình API có hỗ trợ `--dart-define=API_BASE_URL` và fail-fast; tuy nhiên `.env` được đóng gói/nạp trước nhánh fail-fast, nên URL localhost vẫn có thể được chọn nếu build thiếu define.
- Backend đã có endpoint `/student-portal/profile` dành cho học sinh; lỗi nằm ở luồng khôi phục phiên đang gọi endpoint profile chung.
- Backend đã có API lưu thông báo/device token; phần gửi push FCM thực tế vẫn cần hoàn thiện.

## Thứ tự xử lý đề xuất

1. Sửa cấu hình API release và quy trình build web/iOS/Android theo môi trường.
2. Sửa khôi phục phiên role STUDENT.
3. Chặn luồng thanh toán placeholder; xác định phí và số tiền ở backend.
4. Nối roster/assessment thật cho nhập điểm; bổ sung endpoint timetable hoặc tắt chức năng chưa có API.
5. Hoàn thiện mapping phụ huynh–học sinh, báo cáo thật, import web và push notification.
6. Hoàn thiện Firebase iOS, Podfile, Android package ID và release signing.
7. Chuẩn hóa lỗi API, empty state và nội dung demo/placeholder.

## Giới hạn kiểm định

Đây là tổng hợp rà soát mã nguồn, không phải chứng nhận QA sign-off. Không thực hiện build web, Android APK/AAB, iOS archive, chạy test suite, kiểm thử thiết bị, kiểm thử thanh toán sandbox hoặc kiểm thử push notification trong lượt tạo tài liệu. Các mục có ghi “cần xác nhận” cần được kiểm thử trên môi trường tương ứng trước khi đóng.
