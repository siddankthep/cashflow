package com.example.cashflow.ocr.services;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.dto.CategoryDTO;
import com.example.cashflow.ocr.repositories.CategoryRepository;

@Service
public class CategoryService {
    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<Category> getAllCategories(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        List<Category> categories = new ArrayList<>();
        categoryRepository.findAllByUserId(userId).forEach(categories::add);
        return categories;
    }

    public Category saveCategory(CategoryDTO input, User user) {
        if (input == null) {
            throw new IllegalArgumentException("Category input cannot be null");
        }
        if (user == null) {
            throw new IllegalArgumentException("User cannot be null");
        }
        if (input.getName() == null || input.getName().isEmpty()) {
            throw new IllegalArgumentException("Category name cannot be empty");
        }
        Category category = new Category(
                user,
                input.getName(),
                input.getIcon(),
                input.getColorCode());

        return categoryRepository.save(category);
    }
}
