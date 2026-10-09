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

    @Value("${razorpay.key.id}")
    private String razorpayKeyId;

    @Value("${razorpay.key.secret}")
    private String razorpayKeySecret;

    public FeeStatement getFeeStatement(Long studentId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        List<FeePayment> paidFees = feePaymentRepository.findByStudentId(studentId);
        List<FeeStructure> allClassFees = feeStructureRepository.findBySchoolClassId(student.getSchoolClass().getId());

        // Find which fees are NOT paid
        List<Long> paidStructureIds = paidFees.stream()
                .filter(p -> "PAID".equals(p.getStatus()))
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

    public String createRazorpayOrder(RazorpayOrderRequest request) throws RazorpayException {
        RazorpayClient razorpay = new RazorpayClient(razorpayKeyId, razorpayKeySecret);

        JSONObject orderRequest = new JSONObject();
        // Amount is in paise
        orderRequest.put("amount", request.getAmount().multiply(new BigDecimal("100")).intValue());
        orderRequest.put("currency", "INR");
        orderRequest.put("receipt", "fee_receipt_" + System.currentTimeMillis());

        Order order = razorpay.orders.create(orderRequest);
        return order.get("id");
    }

    public FeePayment verifyRazorpayPayment(RazorpayVerifyRequest request) throws RazorpayException {
        RazorpayClient razorpay = new RazorpayClient(razorpayKeyId, razorpayKeySecret);

        JSONObject options = new JSONObject();
        options.put("razorpay_order_id", request.getRazorpayOrderId());
        options.put("razorpay_payment_id", request.getRazorpayPaymentId());
        options.put("razorpay_signature", request.getRazorpaySignature());

        boolean status = Utils.verifyPaymentSignature(options, razorpayKeySecret);

        if (status) {
            // Safe to mark as paid
            Student student = studentRepository.findById(request.getStudentId()).orElseThrow();
            FeeStructure feeStructure = null;
            if (request.getFeeStructureId() != null) {
                feeStructure = feeStructureRepository.findById(request.getFeeStructureId()).orElse(null);
            }

            FeePayment payment = new FeePayment();
            payment.setStudent(student);
            payment.setFeeStructure(feeStructure);

            // Amount lookup (if strict, we'd lookup from FeeStructure or Order)
            // Assuming this is handled via UI for now. If feeStructure is given:
            if (feeStructure != null) {
                payment.setAmountPaid(feeStructure.getAmount());
            } else {
                payment.setAmountPaid(BigDecimal.ZERO); // Fallback
            }

            payment.setPaymentDate(LocalDate.now());
            payment.setTransactionId(request.getRazorpayPaymentId());
            payment.setStatus("PAID");
            payment.setMode("ONLINE");

            return feePaymentRepository.save(payment);
        } else {
            throw new RuntimeException("Invalid Razorpay Signature");
        }
    }

    // Keep legacy
    public List<FeePayment> getFeesByStudent(Long studentId) {
        return feePaymentRepository.findByStudentId(studentId);
    }

    public FeePayment saveFeePayment(FeePayment feePayment) {
        return feePaymentRepository.save(feePayment);
    }
}
