package com.school.backend.security.jwt;

import com.school.backend.security.services.UserDetailsImpl;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class MustChangePasswordFilter extends OncePerRequestFilter {

    private static final List<String> ALLOWED_PREFIXES = List.of(
            "/api/auth/change-password",
            "/api/auth/signout",
            "/api/auth/signin",
            "/api/auth/send-otp",
            "/api/auth/verify-otp",
            "/api/test"
    );

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof UserDetailsImpl userDetails) {
            if (userDetails.isMustChangePassword()) {
                String uri = request.getRequestURI();
                boolean isAllowed = ALLOWED_PREFIXES.stream().anyMatch(uri::startsWith);

                if (!isAllowed) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("""
                        {
                            "status": 403,
                            "error": "PASSWORD_CHANGE_REQUIRED",
                            "message": "Bạn bắt buộc phải đổi mật khẩu khởi tạo trước khi truy cập các tính năng khác."
                        }
                    """);
                    return;
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}
