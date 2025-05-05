package com.example.cashflow.ocr.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.dto.TransactionDTO;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.example.cashflow.ocr.repositories.TransactionRepository;
import com.example.cashflow.ocr.responses.CategoryResponse;

@Service
public class TransactionService {
    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;

    public TransactionService(TransactionRepository transactionRepository,
            CategoryRepository categoryRepository) {
        this.transactionRepository = transactionRepository;
        this.categoryRepository = categoryRepository;
    }

    public List<Transaction> getAllTransactions() {
        List<Transaction> transactions = new ArrayList<>();
        transactionRepository.findAllWithCategory().forEach(transactions::add);
        return transactions;
    }

    public List<Transaction> getTransactionsByUserId(UUID userId) {
        List<Transaction> transactions = new ArrayList<>();
        transactionRepository.findAllByUserIdWithCategory(userId).forEach(transactions::add);
        return transactions;
    }

    public Transaction saveTransaction(TransactionDTO input, User user) {
        CategoryResponse categoryResponse = input.getCategory();
        Category category = categoryRepository.findByName(categoryResponse.getName())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

        // Validate the user
        if (user == null) {
            throw new IllegalArgumentException("User cannot be null");
        }
        // Validate the transaction date
        if (input.getTransactionDate().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Transaction date cannot be in the future");
        }

        // Validate the subtotal
        if (input.getSubtotal().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Subtotal must be positive");
        }
        Transaction newTransaction = new Transaction(
                user,
                category,
                input.getSubtotal(),
                input.getDescription(),
                input.getTransactionDate(),
                input.getPaymentMethod(),
                input.getLocation());
        return transactionRepository.save(newTransaction);
        // return newTransaction;
    }
}
