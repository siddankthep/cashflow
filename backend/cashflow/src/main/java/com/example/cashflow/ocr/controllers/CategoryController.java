package com.example.cashflow.ocr.controllers;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.responses.CategoryResponse;
import com.example.cashflow.ocr.services.CategoryService;

@RestController
@RequestMapping("/categories")
public class CategoryController {
    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping("/")
    public List<CategoryResponse> getAllCategories() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();
        List<Category> categories = categoryService.getAllCategories(user.getId());
        List<CategoryResponse> categoryResponses = new ArrayList<>();
        for (Category category : categories) {
            categoryResponses.add(new CategoryResponse(
                    category.getId(),
                    category.getName(),
                    category.getIcon(),
                    category.getColor()));
        }
        return categoryResponses;
    }

}
