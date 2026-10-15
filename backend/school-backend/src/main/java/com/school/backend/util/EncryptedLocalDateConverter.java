package com.school.backend.util;

import com.school.backend.config.EncryptionConfig;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Converter
public class EncryptedLocalDateConverter implements AttributeConverter<LocalDate, String> {

    private static final Logger log = LoggerFactory.getLogger(EncryptedLocalDateConverter.class);
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE;
    private static EncryptionConfig.StringEncryptor encryptor;

    public static void setEncryptor(EncryptionConfig.StringEncryptor enc) {
        encryptor = enc;
    }

    @Override
    public String convertToDatabaseColumn(LocalDate attribute) {
        if (attribute == null) {
            return null;
        }
        if (encryptor == null) {
            return attribute.format(FORMATTER);
        }
        return encryptor.encrypt(attribute.format(FORMATTER));
    }

    @Override
    public LocalDate convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isEmpty()) {
            return null;
        }
        if (encryptor == null) {
            return parseDate(dbData);
        }
        String decrypted = encryptor.decrypt(dbData);
        return parseDate(decrypted);
    }

    private LocalDate parseDate(String dateStr) {
        try {
            return LocalDate.parse(dateStr, FORMATTER);
        } catch (Exception e) {
            // Try alternative formats for legacy data
            try {
                // Try dd/MM/yyyy format
                return LocalDate.parse(dateStr, DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            } catch (Exception e2) {
                try {
                    // Try MM/dd/yyyy format
                    return LocalDate.parse(dateStr, DateTimeFormatter.ofPattern("MM/dd/yyyy"));
                } catch (Exception e3) {
                    log.warn("Could not parse date string: '{}' with any supported format (ISO, dd/MM/yyyy, MM/dd/yyyy). Returning null.", dateStr);
                    return null;
                }
            }
        }
    }
}
