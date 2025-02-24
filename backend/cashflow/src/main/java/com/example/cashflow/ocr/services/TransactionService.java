package com.example.cashflow.ocr.services;

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
        Category category = input.getCategory();
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
