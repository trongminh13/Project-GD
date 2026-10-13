package com.school.backend.service;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;
import com.school.backend.entity.FeePayment;
import com.school.backend.entity.FeeStructure;
import com.school.backend.entity.Student;
import com.school.backend.payload.FeeStatement;
import com.school.backend.payload.RazorpayOrderRequest;
import com.school.backend.payload.RazorpayVerifyRequest;
import com.school.backend.repository.FeePaymentRepository;
import com.school.backend.repository.FeeStructureRepository;
import com.school.backend.repository.StudentRepository;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FeeService {

    @Autowired
    private FeePaymentRepository feePaymentRepository;

    @Autowired
    private FeeStructureRepository feeStructureRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Value("${razorpay.key.id:rzp_test_placeholder}")
    private String razorpayKeyId;

    @Value("${razorpay.key.secret:rzp_secret_placeholder}")
    private String razorpayKeySecret;

    public FeeStatement getFeeStatement(Long studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        List<FeePayment> paidFees = feePaymentRepository.findByStudentId(studentId).stream()
                .filter(p -> "PAID".equalsIgnoreCase(p.getStatus()))
                .collect(Collectors.toList());

        List<FeeStructure> allClassFees = (student.getSchoolClass() != null)
                ? feeStructureRepository.findBySchoolClassId(student.getSchoolClass().getId())
                : List.of();

        List<Long> paidStructureIds = paidFees.stream()
                .filter(p -> p.getFeeStructure() != null)
                .map(p -> p.getFeeStructure().getId())
                .collect(Collectors.toList());

        List<FeeStructure> pendingFees = allClassFees.stream()
                .filter(f -> !paidStructureIds.contains(f.getId()))
                .collect(Collectors.toList());

        BigDecimal totalPending = pendingFees.stream()
                .map(FeeStructure::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        FeeStatement statement = new FeeStatement();
        statement.setPaidFees(paidFees);
        statement.setPendingFees(pendingFees);
        statement.setTotalPending(totalPending);
        return statement;
    }

    @Transactional
    public String createRazorpayOrder(RazorpayOrderRequest request) throws RazorpayException {
        if (request == null || request.getStudentId() == null) {
            throw new IllegalArgumentException("Student ID is required to create order");
        }

        Student student = studentRepository.findById(request.getStudentId())
                .orElseThrow(() -> new RuntimeException("Student not found with ID: " + request.getStudentId()));

        FeeStructure feeStructure = null;
        BigDecimal finalAmount = request.getAmount();

        if (request.getFeeStructureId() != null) {
            feeStructure = feeStructureRepository.findById(request.getFeeStructureId()).orElse(null);
            if (feeStructure != null) {
                // Server-Authoritative: Override amount with DB source of truth
                finalAmount = feeStructure.getAmount();
            }
        }

        if (finalAmount == null || finalAmount.compareTo(BigDecimal.ZERO) <= 0) {
            finalAmount = BigDecimal.valueOf(100); // Minimum fallback
        }

        RazorpayClient razorpay = new RazorpayClient(razorpayKeyId, razorpayKeySecret);

        JSONObject orderRequest = new JSONObject();
        // Amount is in paise (1 INR = 100 paise)
        orderRequest.put("amount", finalAmount.multiply(new BigDecimal("100")).intValue());
        orderRequest.put("currency", "INR");
        orderRequest.put("receipt", "fee_rcpt_" + System.currentTimeMillis());

        Order order = razorpay.orders.create(orderRequest);
        String orderId = order.get("id");

        // Server saves PENDING transaction
        FeePayment pendingPayment = new FeePayment();
        pendingPayment.setStudent(student);
        pendingPayment.setFeeStructure(feeStructure);
        pendingPayment.setAmountPaid(finalAmount);
        pendingPayment.setTransactionId(orderId);
        pendingPayment.setStatus("PENDING");
        pendingPayment.setMode("ONLINE");
        pendingPayment.setPaymentDate(LocalDate.now());
        feePaymentRepository.save(pendingPayment);

        return orderId;
    }

    @Transactional
    public FeePayment verifyRazorpayPayment(RazorpayVerifyRequest request) throws RazorpayException {
        if (request.getRazorpayOrderId() == null || request.getRazorpayPaymentId() == null || request.getRazorpaySignature() == null) {
            throw new IllegalArgumentException("Missing Razorpay signature or payment details");
        }

        JSONObject options = new JSONObject();
        options.put("razorpay_order_id", request.getRazorpayOrderId());
        options.put("razorpay_payment_id", request.getRazorpayPaymentId());
        options.put("razorpay_signature", request.getRazorpaySignature());

        boolean status = Utils.verifyPaymentSignature(options, razorpayKeySecret);

        if (status) {
            // Server-authoritative lookup by order ID
            FeePayment payment = feePaymentRepository.findFirstByTransactionId(request.getRazorpayOrderId()).orElse(null);

            if (payment != null) {
                payment.setStatus("PAID");
                payment.setTransactionId(request.getRazorpayPaymentId());
                payment.setPaymentDate(LocalDate.now());
                return feePaymentRepository.save(payment);
            }

            // Fallback for legacy requests with studentId
            if (request.getStudentId() != null) {
                Student student = studentRepository.findById(request.getStudentId()).orElseThrow();
                FeeStructure feeStructure = null;
                if (request.getFeeStructureId() != null) {
                    feeStructure = feeStructureRepository.findById(request.getFeeStructureId()).orElse(null);
                }

                FeePayment fallbackPayment = new FeePayment();
                fallbackPayment.setStudent(student);
                fallbackPayment.setFeeStructure(feeStructure);
                fallbackPayment.setAmountPaid(feeStructure != null ? feeStructure.getAmount() : BigDecimal.ZERO);
                fallbackPayment.setPaymentDate(LocalDate.now());
                fallbackPayment.setTransactionId(request.getRazorpayPaymentId());
                fallbackPayment.setStatus("PAID");
                fallbackPayment.setMode("ONLINE");
                return feePaymentRepository.save(fallbackPayment);
            }

            throw new RuntimeException("Payment record not found for Order ID: " + request.getRazorpayOrderId());
        } else {
            throw new RuntimeException("Invalid Razorpay Signature");
        }
    }

    public List<FeePayment> getFeesByStudent(Long studentId) {
        return feePaymentRepository.findByStudentId(studentId);
    }

    public FeePayment saveFeePayment(FeePayment feePayment) {
        return feePaymentRepository.save(feePayment);
    }
}
