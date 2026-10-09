package com.school.backend.controller;

import com.school.backend.entity.User;
import com.school.backend.enums.Role;
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
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
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

    @PostMapping("/signin")
    public ResponseEntity<?> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(item -> item.getAuthority())
                .collect(Collectors.toList());

        return ResponseEntity.ok(new JwtResponse(jwt,
                userDetails.getId(),
                userDetails.getUsername(),
                roles));
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

        // Handle Role
        Set<String> strRoles = signUpRequest.getRole();
        Role role;

        if (strRoles == null || strRoles.isEmpty()) {
            role = Role.PARENT; // Default role
        } else {
            String roleStr = strRoles.iterator().next();
            try {
                role = Role.valueOf(roleStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                return ResponseEntity.badRequest().body(new MessageResponse("Error: Invalid Role!"));
            }
        }
        user.setRole(role);

        userRepository.save(user);

        return ResponseEntity.ok(new MessageResponse("User registered successfully!"));
    }

    @PostMapping("/send-otp")
    public ResponseEntity<?> sendOtp(@RequestBody OtpRequest request) {
        String phone = request.getPhone();
        System.out.println("Login Debug: Received phone: '" + phone + "'");

        // Debug: Check if parent exists
        if (parentRepository.findByPhone(phone).isPresent()) {
            System.out.println("Login Debug: Phone found in DB.");
            String otp = otpService.generateOtp(phone);
            System.out.println("OTP for " + phone + ": " + otp);
            return ResponseEntity.ok(new MessageResponse("OTP sent successfully to " + phone));
        } else {
            System.out.println("Login Debug: Phone NOT found in DB.");
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

            // Auto-create a User account for Excel-imported parents who don't have one
            if (user == null) {
                user = new User();
                user.setUsername(phone); // phone number is the username
                user.setPassword(encoder.encode(phone)); // default password = phone (won't be used for OTP login)
                user.setRole(Role.PARENT);
                user = userRepository.save(user);

                // Link the new User to the Parent record
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
