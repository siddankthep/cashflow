package com.example.cashflow.ocr.controllers;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.dto.TransactionDTO;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.example.cashflow.ocr.responses.TransactionResponse;
import com.example.cashflow.ocr.services.TransactionService;

@RestController
@RequestMapping("/transactions")
public class TransactionController {
    private final TransactionService transactionService;
    private final CategoryRepository categoryRepository;

    public TransactionController(TransactionService transactionService, CategoryRepository categoryRepository) {
        this.transactionService = transactionService;
        this.categoryRepository = categoryRepository;
    }

    @GetMapping("/")
    public List<Transaction> getTransactions() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();
        return transactionService.getTransactionsByUserId(user.getId());
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveTransaction(@RequestBody TransactionDTO input) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            User user = (User) authentication.getPrincipal();
            Transaction newTransaction = transactionService.saveTransaction(input, user);
            TransactionResponse transactionResponse = new TransactionResponse(
                    newTransaction.getId(),
                    newTransaction.getUser().getId(),
                    newTransaction.getCategory(),
                    newTransaction.getSubtotal(),
                    newTransaction.getDescription(),
                    newTransaction.getTransactionDate(),
                    newTransaction.getPaymentMethod(),
                    newTransaction.getLocation());

            return ResponseEntity.ok(transactionResponse);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error saving transaction:" + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
