package com.school.backend.config;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.ShallowEtagHeaderFilter;

@Configuration
public class WebNetworkConfig {

    /**
     * Đăng ký ShallowEtagHeaderFilter để tự động sinh ETag cho các phản hồi API.
     * Khi Client gửi header If-None-Match trùng với ETag, Filter sẽ tự động
     * phản hồi HTTP 304 Not Modified mà không cần gửi lại toàn bộ JSON payload.
     */
    @Bean
    public FilterRegistrationBean<ShallowEtagHeaderFilter> shallowEtagHeaderFilter() {
        FilterRegistrationBean<ShallowEtagHeaderFilter> filterRegistrationBean =
                new FilterRegistrationBean<>(new ShallowEtagHeaderFilter());
        filterRegistrationBean.addUrlPatterns("/api/*");
        filterRegistrationBean.setName("etagFilter");
        return filterRegistrationBean;
    }
}
