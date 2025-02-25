package com.example.cashflow.ocr.services;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.cashflow.entities.Category;
import com.example.cashflow.ocr.repositories.CategoryRepository;

@Service
public class CategoryService {
    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<Category> getAllCategories(UUID userId) {
        List<Category> categories = new ArrayList<>();
        categoryRepository.findAllByUserId(userId).forEach(categories::add);
        return categories;
    }
}
