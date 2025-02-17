package com.example.cashflow.ocr.repositories;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;

public interface TransactionRepository extends JpaRepository<Transaction, UUID> {

}
