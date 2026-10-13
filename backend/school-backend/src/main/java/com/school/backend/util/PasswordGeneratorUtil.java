package com.school.backend.util;

import java.security.SecureRandom;

public class PasswordGeneratorUtil {

    // Ký tự an toàn, loại bỏ các ký tự dễ nhầm lẫn như 0, O, o, 1, l, I
    private static final String CHAR_POOL = "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz@#$";
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String generateRandomPassword(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            int index = RANDOM.nextInt(CHAR_POOL.length());
            sb.append(CHAR_POOL.charAt(index));
        }
        return sb.toString();
    }

    public static String generateRandomPassword() {
        return generateRandomPassword(8);
    }
}
