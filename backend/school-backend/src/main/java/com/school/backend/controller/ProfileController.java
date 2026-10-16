package com.school.backend.controller;

import com.school.backend.entity.Parent;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import com.school.backend.payload.dto.ProfileDto;
import com.school.backend.payload.response.MessageResponse;
import com.school.backend.repository.ParentRepository;
import com.school.backend.repository.UserRepository;
import com.school.backend.security.services.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    @Autowired
    UserRepository userRepository;

    @Autowired
    ParentRepository parentRepository;

    @GetMapping
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<?> getProfile() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        Optional<User> userOpt = userRepository.findById(userDetails.getId());
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Error: User not found."));
        }
        User user = userOpt.get();
        ProfileDto profileDto = new ProfileDto();
        profileDto.setRole(user.getRole().name());

        if (user.getRole() == Role.PARENT) {
            Optional<Parent> parentOpt = parentRepository.findByUserId(user.getId());
            if (parentOpt.isPresent()) {
                Parent parent = parentOpt.get();
                profileDto.setName(parent.getName());
                profileDto.setPhone(parent.getPhone());
                profileDto.setAddress(parent.getAddress());
                profileDto.setEmail(parent.getPhone() + "@placeholder.com");
            }
        } else if (user.getRole() == Role.ADMIN) {
            profileDto.setName("System Administrator");
            profileDto.setPhone("N/A");
            profileDto.setEmail(user.getUsername() + "@school.admin");
            profileDto.setAddress("School Main Office");
        } else if (user.getRole() == Role.TEACHER) {
            profileDto.setName("Teacher " + user.getUsername());
            profileDto.setPhone("N/A");
            profileDto.setEmail(user.getUsername() + "@school.teacher");
            profileDto.setAddress("Staff Room");
        }

        return ResponseEntity.ok(profileDto);
    }

    @PutMapping
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<?> updateProfile(@RequestBody ProfileDto profileDto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        Optional<User> userOpt = userRepository.findById(userDetails.getId());
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(new MessageResponse("Error: User not found."));
        }
        User user = userOpt.get();

        if (user.getRole() == Role.PARENT) {
            Optional<Parent> parentOpt = parentRepository.findByUserId(user.getId());
            if (parentOpt.isPresent()) {
                Parent parent = parentOpt.get();
                if (profileDto.getName() != null)
                    parent.setName(profileDto.getName());
                if (profileDto.getPhone() != null && !profileDto.getPhone().isEmpty()) {
                    parent.setPhone(profileDto.getPhone());
                    user.setUsername(profileDto.getPhone());
                    userRepository.save(user);
                }
                if (profileDto.getAddress() != null)
                    parent.setAddress(profileDto.getAddress());

                parentRepository.save(parent);
                return ResponseEntity.ok(new MessageResponse("Parent profile updated successfully!"));
            }
        }

        return ResponseEntity.ok(new MessageResponse("Profile updated successfully!"));
    }
}
