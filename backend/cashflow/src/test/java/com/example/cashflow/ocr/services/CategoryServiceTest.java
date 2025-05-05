package com.example.cashflow.ocr.services;

import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.dto.CategoryDTO;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class CategoryServiceTest {

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private CategoryService categoryService;

    private User user;
    private CategoryDTO categoryDTO;
    private Category category;
    private UUID userId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        user = new User();
        user.setId(userId);
        user.setEmail("test@student.com");
        user.setUsername("testuser");

        categoryDTO = new CategoryDTO();
        categoryDTO.setName("Food & Dining");
        categoryDTO.setIcon("e533");
        categoryDTO.setColorCode(4294198070L);

        category = new Category();
        category.setId(UUID.randomUUID());
        category.setUser(user);
        category.setName("Food & Dining");
        category.setIcon("e533");
        category.setColor(4294198070L);
    }

    @Test
    void getAllCategories_ReturnsCategoriesForUser() {
        // Arrange
        List<Category> categories = List.of(category);
        when(categoryRepository.findAllByUserId(userId)).thenReturn(categories);

        // Act
        List<Category> result = categoryService.getAllCategories(userId);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Food & Dining", result.get(0).getName());
        verify(categoryRepository, times(1)).findAllByUserId(userId);
    }

    @Test
    void getAllCategories_NoCategories_ReturnsEmptyList() {
        // Arrange
        when(categoryRepository.findAllByUserId(userId)).thenReturn(Collections.emptyList());

        // Act
        List<Category> result = categoryService.getAllCategories(userId);

        // Assert
        assertNotNull(result);
        assertTrue(result.isEmpty());
        verify(categoryRepository, times(1)).findAllByUserId(userId);
    }

    @Test
    void getAllCategories_NullUserId_ThrowsIllegalArgumentException() {
        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            categoryService.getAllCategories(null));
        assertEquals("User ID cannot be null", exception.getMessage());
        verify(categoryRepository, never()).findAllByUserId(any());
    }

    @Test
    void saveCategory_ValidInput_SavesAndReturnsCategory() {
        // Arrange
        when(categoryRepository.save(any(Category.class))).thenReturn(category);

        // Act
        Category result = categoryService.saveCategory(categoryDTO, user);

        // Assert
        assertNotNull(result);
        assertEquals("Food & Dining", result.getName());
        assertEquals(user, result.getUser());
        verify(categoryRepository, times(1)).save(any(Category.class));
    }

    @Test
    void saveCategory_NullCategoryDTO_ThrowsIllegalArgumentException() {
        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            categoryService.saveCategory(null, user));
            assertEquals("Category input cannot be null", exception.getMessage());
        verify(categoryRepository, never()).save(any());
    }

    @Test
    void saveCategory_NullUser_ThrowsIllegalArgumentException() {
        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            categoryService.saveCategory(categoryDTO, null));
        assertEquals("User cannot be null", exception.getMessage());
        verify(categoryRepository, never()).save(any());
    }

    @Test
    void saveCategory_DuplicateCategoryName_ThrowsDataIntegrityViolationException() {
        // Arrange
        when(categoryRepository.save(any(Category.class)))
            .thenThrow(new org.springframework.dao.DataIntegrityViolationException("Duplicate category name"));

        // Act & Assert
        assertThrows(org.springframework.dao.DataIntegrityViolationException.class, () -> 
            categoryService.saveCategory(categoryDTO, user));
        verify(categoryRepository, times(1)).save(any(Category.class));
    }

    @Test
    void saveCategory_EmptyName_ThrowsIllegalArgumentException() {
        // Arrange
        categoryDTO.setName("");

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            categoryService.saveCategory(categoryDTO, user));
        assertEquals("Category name cannot be empty", exception.getMessage());
        verify(categoryRepository, never()).save(any());
    }
}