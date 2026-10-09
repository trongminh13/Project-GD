package com.school.backend.util;

import com.school.backend.config.EncryptionConfig;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class EncryptedStringConverter implements AttributeConverter<String, String> {

    // Static instance - will be set during application startup
    private static EncryptionConfig.StringEncryptor encryptor;

    public static void setEncryptor(EncryptionConfig.StringEncryptor enc) {
        encryptor = enc;
    }

    @Override
    public String convertToDatabaseColumn(String attribute) {
        if (encryptor == null) {
            return attribute;
        }
        return encryptor.encrypt(attribute);
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        if (encryptor == null) {
            return dbData;
        }
        return encryptor.decrypt(dbData);
    }
}
