package com.example.cashflow.ocr.repositories;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Repository;

import com.example.cashflow.entities.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, UUID> {
    @NonNull
    Optional<Category> findById(@NonNull UUID categoryId);

    @Query("SELECT c FROM Category c WHERE c.user.id = :userId OR c.user.id IS NULL")
    Optional<List<Category>> findAllByUserId(@Param("userId") UUID userId);

    Optional<Category> findByUserId(UUID userId);

    Optional<Category> findByName(String categoryName);
}
