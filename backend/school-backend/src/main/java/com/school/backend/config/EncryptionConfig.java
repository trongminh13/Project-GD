package com.school.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.SecureRandom;
import java.util.Base64;

@Configuration
public class EncryptionConfig {

    private static final String AES_ALGORITHM = "AES";
    private static final String AES_TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int GCM_TAG_LENGTH = 128;
    private static final int GCM_IV_LENGTH = 12;
    private static final int AES_KEY_LENGTH = 256;

    @Value("${school.app.dbEncryptionKey:#{null}}")
    private String base64Key;

    @Bean
    public SecretKey secretKey() {
        if (base64Key != null && !base64Key.isEmpty()) {
            byte[] decodedKey = Base64.getDecoder().decode(base64Key);
            return new SecretKeySpec(decodedKey, AES_ALGORITHM);
        }
        // Generate a new key if not configured (for development)
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance(AES_ALGORITHM);
            keyGen.init(AES_KEY_LENGTH);
            SecretKey key = keyGen.generateKey();
            System.out.println("WARNING: No encryption key configured. Generated temporary key: "
                    + Base64.getEncoder().encodeToString(key.getEncoded()));
            System.out.println("Set school.app.dbEncryptionKey in application.properties or DB_ENCRYPTION_KEY env var");
            return key;
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate encryption key", e);
        }
    }

    @Bean
    public StringEncryptor stringEncryptor(SecretKey secretKey) {
        return new StringEncryptor(secretKey);
    }

    public static class StringEncryptor {

        private final SecretKey secretKey;
        private final SecureRandom secureRandom;

        public StringEncryptor(SecretKey secretKey) {
            this.secretKey = secretKey;
            this.secureRandom = new SecureRandom();
        }

        public String encrypt(String plainText) {
            if (plainText == null || plainText.isEmpty()) {
                return plainText;
            }
            try {
                byte[] iv = new byte[GCM_IV_LENGTH];
                secureRandom.nextBytes(iv);

                Cipher cipher = Cipher.getInstance(AES_TRANSFORMATION);
                GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
                cipher.init(Cipher.ENCRYPT_MODE, secretKey, parameterSpec);

                byte[] encrypted = cipher.doFinal(plainText.getBytes());

                // Combine IV + encrypted data
                byte[] combined = new byte[iv.length + encrypted.length];
                System.arraycopy(iv, 0, combined, 0, iv.length);
                System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);

                return Base64.getEncoder().encodeToString(combined);
            } catch (Exception e) {
                throw new RuntimeException("Encryption failed", e);
            }
        }

        public String decrypt(String cipherText) {
            if (cipherText == null || cipherText.isEmpty()) {
                return cipherText;
            }
            try {
                byte[] combined = Base64.getDecoder().decode(cipherText);

                // Extract IV
                byte[] iv = new byte[GCM_IV_LENGTH];
                System.arraycopy(combined, 0, iv, 0, iv.length);

                // Extract encrypted data
                byte[] encrypted = new byte[combined.length - iv.length];
                System.arraycopy(combined, iv.length, encrypted, 0, encrypted.length);

                Cipher cipher = Cipher.getInstance(AES_TRANSFORMATION);
                GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
                cipher.init(Cipher.DECRYPT_MODE, secretKey, parameterSpec);

                byte[] decrypted = cipher.doFinal(encrypted);
                return new String(decrypted);
            } catch (Exception e) {
                // If decryption fails, assume data is unencrypted legacy data
                // This allows mixed encrypted/unencrypted data during migration
                System.out.println("Warning: Could not decrypt value, returning as-is (legacy unencrypted data): " + e.getMessage());
                return cipherText;
            }
        }
    }
}
