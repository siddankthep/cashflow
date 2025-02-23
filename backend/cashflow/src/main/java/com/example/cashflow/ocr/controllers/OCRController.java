package com.example.cashflow.ocr.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestClientException;
import org.springframework.web.multipart.MultipartFile;

import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.responses.TransactionResponse;
import com.example.cashflow.ocr.services.OCRService;

import net.sourceforge.tess4j.TesseractException;

import java.io.IOException;

@RestController
@RequestMapping("/ocr")
public class OCRController {

    private final OCRService ocrService;

    public OCRController(OCRService ocrService) {
        this.ocrService = ocrService;
    }

    @PostMapping("/scan")
    public ResponseEntity<Transaction> uploadImage(@RequestParam("image") MultipartFile image) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();
        try {
            Transaction newTransaction = ocrService.processReceipt(image, user.getId());
            return ResponseEntity.ok(newTransaction);

        } catch (IOException | TesseractException | RestClientException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/save")
    public ResponseEntity<TransactionResponse> saveTransaction(@RequestBody Transaction transaction) {
        Transaction newTransaction = ocrService.saveTransaction(transaction);
        TransactionResponse transactionResponse = new TransactionResponse(newTransaction.getId(),
                newTransaction.getUser().getId(), newTransaction.getCategory().getId(),
                newTransaction.getSubtotal(),
                newTransaction.getDescription(), newTransaction.getTransactionDate(),
                newTransaction.getPaymentMethod(), newTransaction.getLocation());
        return ResponseEntity.ok(transactionResponse);
    }
}