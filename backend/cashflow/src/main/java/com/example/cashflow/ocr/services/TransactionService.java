package com.example.cashflow.ocr.services;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.cashflow.entities.Transaction;
import com.example.cashflow.ocr.repositories.TransactionRepository;

@Service
public class TransactionService {
    private final TransactionRepository transactionRepository;

    public TransactionService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    public List<Transaction> getAllTransactions() {
        List<Transaction> transactions = new ArrayList<>();
        transactionRepository.findAll().forEach(transactions::add);
        return transactions;
    }

    public List<Transaction> getTransactionsByUserId(UUID userId) {
        List<Transaction> transactions = new ArrayList<>();
        transactionRepository.findAllByUserId(userId).forEach(transactions::add);
        return transactions;
    }
}
