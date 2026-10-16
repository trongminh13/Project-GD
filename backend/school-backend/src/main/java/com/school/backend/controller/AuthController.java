package com.school.backend.controller;

import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import com.school.backend.payload.request.ChangePasswordRequest;
import com.school.backend.payload.request.LoginRequest;
import com.school.backend.payload.request.SignupRequest;
import com.school.backend.payload.response.JwtResponse;
import com.school.backend.payload.response.MessageResponse;
import com.school.backend.repository.UserRepository;
import com.school.backend.security.jwt.JwtUtils;
import com.school.backend.security.services.UserDetailsImpl;
import com.school.backend.service.OtpService;
import com.school.backend.repository.ParentRepository;
import com.school.backend.payload.request.OtpRequest;
import com.school.backend.entity.Parent;
import java.util.Map;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    PasswordEncoder encoder;

    @Autowired
    JwtUtils jwtUtils;

    @Autowired
    OtpService otpService;

    @Autowired
    ParentRepository parentRepository;

    // In-memory rate limiting cho OTP: phone -> timestamp gửi lần cuối
    private static final java.util.concurrent.ConcurrentHashMap<String, Long> OTP_LAST_SENT = new java.util.concurrent.ConcurrentHashMap<>();
    private static final java.util.concurrent.ConcurrentHashMap<String, Integer> OTP_HOURLY_COUNT = new java.util.concurrent.ConcurrentHashMap<>();

    @PostMapping("/signin")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        String username = loginRequest.getUsername();
        Optional<User> userOpt = userRepository.findByUsername(username)
                .or(() -> parentRepository.findByPhone(username).map(Parent::getUser));

        // 1. Kiểm tra trạng thái khóa tài khoản (Miễn trừ khóa cứng cho ADMIN chống DoS)
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getRole() != Role.ADMIN && user.getLockTime() != null) {
                if (user.getLockTime().plusMinutes(15).isBefore(LocalDateTime.now())) {
                    // Khóa đã hết hạn: Reset tự động
                    user.setFailedAttempts(0);
                    user.setLockTime(null);
                    userRepository.save(user);
                } else {
                    long minutesLeft = Duration.between(LocalDateTime.now(), user.getLockTime().plusMinutes(15)).toMinutes() + 1;
                    return ResponseEntity.status(423).body(new MessageResponse(
                            "Tài khoản đang bị tạm khóa. Vui lòng thử lại sau " + minutesLeft + " phút."));
                }
            }
        }

        try {
            String authUsername = userOpt.map(User::getUsername).orElse(loginRequest.getUsername());
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(authUsername, loginRequest.getPassword()));

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = jwtUtils.generateJwtToken(authentication);

            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
            List<String> roles = userDetails.getAuthorities().stream()
                    .map(item -> item.getAuthority())
                    .collect(Collectors.toList());

            // Đăng nhập thành công: Reset số lần sai và thời gian khóa
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                user.setFailedAttempts(0);
                user.setLockTime(null);
                userRepository.save(user);
            }

            return ResponseEntity.ok(new JwtResponse(jwt,
                    userDetails.getId(),
                    userDetails.getUsername(),
                    roles,
                    userDetails.isMustChangePassword()));
        } catch (BadCredentialsException e) {
            if (userOpt.isPresent() && userOpt.get().getRole() != Role.ADMIN) {
                User user = userOpt.get();
                int currentAttempts = (user.getFailedAttempts() != null ? user.getFailedAttempts() : 0) + 1;
                user.setFailedAttempts(currentAttempts);
                if (currentAttempts >= 5) {
                    user.setLockTime(LocalDateTime.now());
                    userRepository.save(user);
                    return ResponseEntity.status(423).body(new MessageResponse(
                            "Tài khoản đã bị tạm khóa 15 phút do nhập sai mật khẩu 5 lần liên tiếp."));
                } else {
                    userRepository.save(user);
                }
            }
            return ResponseEntity.status(401).body(new MessageResponse("Tên đăng nhập hoặc mật khẩu không chính xác."));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body(new MessageResponse("Xác thực không thành công: " + e.getMessage()));
        }
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return ResponseEntity.status(401).body(new MessageResponse("Chưa xác thực."));
        }

        String username = auth.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));

        // Kiểm tra lockout nếu tài khoản đang bị khóa
        if (user.getRole() != Role.ADMIN && user.getLockTime() != null) {
            if (user.getLockTime().plusMinutes(15).isBefore(LocalDateTime.now())) {
                user.setFailedAttempts(0);
                user.setLockTime(null);
                userRepository.save(user);
            } else {
                long minutesLeft = Duration.between(LocalDateTime.now(), user.getLockTime().plusMinutes(15)).toMinutes() + 1;
                return ResponseEntity.status(423).body(new MessageResponse(
                        "Tài khoản đang bị tạm khóa. Vui lòng thử lại sau " + minutesLeft + " phút."));
            }
        }

        // Kiểm tra mật khẩu cũ; nếu sai thì tăng failedAttempts để chống brute-force qua change-password
        if (!encoder.matches(request.getOldPassword(), user.getPassword())) {
            if (user.getRole() != Role.ADMIN) {
                int attempts = (user.getFailedAttempts() != null ? user.getFailedAttempts() : 0) + 1;
                user.setFailedAttempts(attempts);
                if (attempts >= 5) {
                    user.setLockTime(LocalDateTime.now());
                    userRepository.save(user);
                    return ResponseEntity.status(423).body(new MessageResponse(
                            "Tài khoản đã bị tạm khóa 15 phút do nhập sai mật khẩu 5 lần liên tiếp."));
                } else {
                    userRepository.save(user);
                }
            }
            return ResponseEntity.badRequest().body(new MessageResponse("Mật khẩu hiện tại không chính xác."));
        }

        if (encoder.matches(request.getNewPassword(), user.getPassword())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Mật khẩu mới không được trùng với mật khẩu cũ."));
        }

        // Kiểm tra độ mạnh mật khẩu mới: tối thiểu 8 ký tự, có chữ và số
        String newPass = request.getNewPassword();
        if (newPass.length() < 8 || !newPass.matches(".*[a-zA-Z].*") || !newPass.matches(".*[0-9].*")) {
            return ResponseEntity.badRequest().body(new MessageResponse(
                    "Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm cả chữ cái và chữ số."));
        }

        user.setPassword(encoder.encode(newPass));
        user.setMustChangePassword(false);
        user.setFailedAttempts(0);
        user.setLockTime(null);
        userRepository.save(user);

        return ResponseEntity.ok(new MessageResponse("Đổi mật khẩu thành công!"));
    }

    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Valid @RequestBody SignupRequest signUpRequest) {
        if (userRepository.findByUsername(signUpRequest.getUsername()).isPresent()) {
            return ResponseEntity
                    .badRequest()
                    .body(new MessageResponse("Error: Username is already taken!"));
        }

        // Create new user's account
        User user = new User();
        user.setUsername(signUpRequest.getUsername());
        user.setPassword(encoder.encode(signUpRequest.getPassword()));

        // Security Hardening (P0): Chặn leo thang đặc quyền (Privilege Escalation)
        // Đăng ký công khai chỉ áp dụng cho vai trò PARENT.
        // Các vai trò đặc quyền (ADMIN, TEACHER, STUDENT) bắt buộc phải do Quản trị viên cấp nội bộ.
        Set<String> strRoles = signUpRequest.getRole();
        if (strRoles != null && !strRoles.isEmpty()) {
            for (String r : strRoles) {
                if (!Role.PARENT.name().equalsIgnoreCase(r)) {
                    return ResponseEntity.badRequest().body(new MessageResponse(
                            "Lỗi bảo mật: Đăng ký công khai chỉ áp dụng cho tài khoản Phụ huynh (PARENT)."));
                }
            }
        }
        user.setRole(Role.PARENT);

        userRepository.save(user);

        return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
    }

    @PostMapping("/send-otp")
    public ResponseEntity<?> sendOtp(@RequestBody OtpRequest request) {
        String phone = request.getPhone();
        System.out.println("Login Debug: Received phone: '" + phone + "'");

        // Rate limit: Tối thiểu cách nhau 60 giây giữa 2 lần gửi cho 1 SĐT
        Long lastSent = OTP_LAST_SENT.get(phone);
        long now = System.currentTimeMillis();
        if (lastSent != null && (now - lastSent) < 60000) {
            long waitSeconds = (60000 - (now - lastSent)) / 1000;
            return ResponseEntity.status(429).body(new MessageResponse(
                    "Vui lòng đợi " + waitSeconds + " giây trước khi yêu cầu lại mã OTP."));
        }

        if (parentRepository.findByPhone(phone).isPresent()) {
            OTP_LAST_SENT.put(phone, now);
            String otp = otpService.generateOtp(phone);
            // In dev environment only, masked log
            // System.out.println("OTP generated for phone: " + phone.replaceAll(".(?=.{3})", "*"));
            return ResponseEntity.ok(new MessageResponse("OTP sent successfully to " + phone));
        } else {
            return ResponseEntity.badRequest().body(new MessageResponse(
                    "This number is not registered with the school, please double-check the number before logging in again."));
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody OtpRequest request) {
        String phone = request.getPhone();
        String otp = request.getOtp();

        if (otpService.validateOtp(phone, otp)) {
            Parent parent = parentRepository.findByPhone(phone)
                    .orElseThrow(() -> new RuntimeException("Error: Parent not found."));

            User user = parent.getUser();

            if (user == null) {
                user = new User();
                user.setUsername(phone);
                user.setPassword(encoder.encode(phone));
                user.setRole(Role.PARENT);
                user = userRepository.save(user);

                parent.setUser(user);
                parentRepository.save(parent);
                System.out.println("Auto-created User with PARENT role for phone: " + phone);
            }

            String token = jwtUtils.generateTokenFromUsername(user.getUsername());

            return ResponseEntity.ok(new JwtResponse(token,
                    user.getId(),
                    user.getUsername(),
                    List.of("ROLE_PARENT")));
        } else {
            return ResponseEntity.badRequest().body(new MessageResponse("Error: Invalid OTP"));
        }
    }
}
