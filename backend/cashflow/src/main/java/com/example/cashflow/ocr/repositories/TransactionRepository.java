package com.example.cashflow.ocr.repositories;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Repository;

import com.example.cashflow.entities.Transaction;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, UUID> {
    @NonNull
    Optional<Transaction> findById(@NonNull UUID transactionId);

    Optional<Transaction> findByUserId(UUID userId);

    List<Transaction> findAllByUserId(UUID userId);

    @Query("SELECT t FROM Transaction t JOIN FETCH t.category")
    List<Transaction> findAllWithCategory();

    @Query("SELECT t FROM Transaction t JOIN FETCH t.category WHERE t.user.id = :userId")
    List<Transaction> findAllByUserIdWithCategory(@Param("userId") UUID userId);

}
