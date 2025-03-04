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
import com.example.cashflow.ocr.responses.CategoryResponse;
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
    public ResponseEntity<?> uploadImage(@RequestParam("image") MultipartFile image) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();
        try {
            Transaction newTransaction = ocrService.processReceipt(image, user.getId());
            CategoryResponse categoryResponse = new CategoryResponse(
                    newTransaction.getCategory().getId(),
                    newTransaction.getCategory().getName(),
                    newTransaction.getCategory().getIcon(),
                    newTransaction.getCategory().getColor());
            TransactionResponse response = new TransactionResponse(
                    newTransaction.getId(),
                    newTransaction.getUser().getId(),
                    categoryResponse,
                    newTransaction.getSubtotal(),
                    newTransaction.getDescription(),
                    newTransaction.getTransactionDate(),
                    newTransaction.getPaymentMethod(),
                    newTransaction.getLocation());
            return ResponseEntity.ok(response);

        } catch (IOException | TesseractException | RestClientException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error processing image: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(e.getMessage());
        }
    }
}