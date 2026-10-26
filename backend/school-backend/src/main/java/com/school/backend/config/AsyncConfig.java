package com.school.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.Semaphore;
import java.util.concurrent.ThreadPoolExecutor;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "pdfRenderExecutor")
    public Executor pdfRenderExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(4);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("pdf-render-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

    /**
     * Semaphore điều tiết tải render toàn cục (tối đa 4 render tác vụ nặng cùng lúc)
     * Dùng chung cho cả PdfPreRenderJob và MaterialPageService fallback.
     */
    @Bean(name = "pdfRenderSemaphore")
    public Semaphore pdfRenderSemaphore() {
        return new Semaphore(4, true);
    }
}
