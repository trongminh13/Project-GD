package com.school.backend.config;

import com.school.backend.util.EncryptedLocalDateConverter;
import com.school.backend.util.EncryptedStringConverter;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

@Configuration
public class EncryptionInitializer {

    @Autowired
    private EncryptionConfig.StringEncryptor stringEncryptor;

    @PostConstruct
    public void init() {
        EncryptedStringConverter.setEncryptor(stringEncryptor);
        EncryptedLocalDateConverter.setEncryptor(stringEncryptor);
        System.out.println("Encryption converters initialized successfully");
    }
}
