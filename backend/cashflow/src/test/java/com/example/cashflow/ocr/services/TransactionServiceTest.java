package com.example.cashflow.ocr.services;

import com.example.cashflow.authentication.repositories.UserRepository;
import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.dto.TransactionDTO;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.example.cashflow.ocr.repositories.TransactionRepository;
import com.example.cashflow.ocr.responses.CategoryResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private TransactionService transactionService;

    private User user;
    private Category category;
    private TransactionDTO transactionDTO;

    @BeforeEach
    void setUp() {
        // Initialize test data
        user = new User();
        user.setId(UUID.randomUUID());
        user.setEmail("test@student.com");
        user.setUsername("testuser");

        category = new Category();
        category.setId(UUID.randomUUID());
        category.setName("Food & Dining");
        category.setIcon("e533");
        category.setColor(4294198070L);

        CategoryResponse categoryResponse = new CategoryResponse();
        categoryResponse.setName("Food & Dining");

        transactionDTO = new TransactionDTO();
        transactionDTO.setCategory(categoryResponse);
        transactionDTO.setSubtotal(new BigDecimal("100.00"));
        transactionDTO.setDescription("Lunch");
        transactionDTO.setTransactionDate(LocalDate.parse("2025-03-01"));
        transactionDTO.setPaymentMethod("Cash");
        transactionDTO.setLocation("Cafe");
    }

    @Test
    void getAllTransactions_ReturnsAllTransactions() {
        // Arrange
        Transaction transaction = new Transaction(user, category, new BigDecimal("100.00"), 
            "Lunch", LocalDate.parse("2025-03-01"), "Cash", "Cafe");
        List<Transaction> transactions = List.of(transaction);
        when(transactionRepository.findAllWithCategory()).thenReturn(transactions);

        // Act
        List<Transaction> result = transactionService.getAllTransactions();

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Lunch", result.get(0).getDescription());
        verify(transactionRepository, times(1)).findAllWithCategory();
    }

    @Test
    void getAllTransactions_EmptyList_ReturnsEmptyList() {
        // Arrange
        when(transactionRepository.findAllWithCategory()).thenReturn(Collections.emptyList());

        // Act
        List<Transaction> result = transactionService.getAllTransactions();

        // Assert
        assertNotNull(result);
        assertTrue(result.isEmpty());
        verify(transactionRepository, times(1)).findAllWithCategory();
    }

    @Test
    void getTransactionsByUserId_ReturnsUserTransactions() {
        // Arrange
        UUID userId = user.getId();
        Transaction transaction = new Transaction(user, category, new BigDecimal("100.00"), 
            "Lunch", LocalDate.parse("2025-03-01"), "Cash", "Cafe");
        List<Transaction> transactions = List.of(transaction);
        when(transactionRepository.findAllByUserIdWithCategory(userId)).thenReturn(transactions);

        // Act
        List<Transaction> result = transactionService.getTransactionsByUserId(userId);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Lunch", result.get(0).getDescription());
        verify(transactionRepository, times(1)).findAllByUserIdWithCategory(userId);
    }

    @Test
    void getTransactionsByUserId_NoTransactions_ReturnsEmptyList() {
        // Arrange
        UUID userId = UUID.randomUUID();
        when(transactionRepository.findAllByUserIdWithCategory(userId)).thenReturn(Collections.emptyList());

        // Act
        List<Transaction> result = transactionService.getTransactionsByUserId(userId);

        // Assert
        assertNotNull(result);
        assertTrue(result.isEmpty());
        verify(transactionRepository, times(1)).findAllByUserIdWithCategory(userId);
    }

    @Test
    void saveTransaction_ValidInput_SavesAndReturnsTransaction() {
        // Arrange
        when(categoryRepository.findByName("Food & Dining")).thenReturn(Optional.of(category));
        Transaction savedTransaction = new Transaction(user, category, new BigDecimal("100.00"), 
            "Lunch", LocalDate.parse("2025-03-01"), "Cash", "Cafe");
        when(transactionRepository.save(any(Transaction.class))).thenReturn(savedTransaction);

        // Act
        Transaction result = transactionService.saveTransaction(transactionDTO, user);

        // Assert
        assertNotNull(result);
        assertEquals(new BigDecimal("100.00"), result.getSubtotal());
        assertEquals("Lunch", result.getDescription());
        verify(categoryRepository, times(1)).findByName("Food & Dining");
        verify(transactionRepository, times(1)).save(any(Transaction.class));
    }

    @Test
    void saveTransaction_CategoryNotFound_ThrowsIllegalArgumentException() {
        // Arrange
        when(categoryRepository.findByName("Food & Dining")).thenReturn(Optional.empty());

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            transactionService.saveTransaction(transactionDTO, user));
        assertEquals("Category not found", exception.getMessage());
        verify(categoryRepository, times(1)).findByName("Food & Dining");
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void saveTransaction_NullTransactionDTO_ThrowsNullPointerException() {
        // Act & Assert
        assertThrows(NullPointerException.class, () -> 
            transactionService.saveTransaction(null, user));
        verify(categoryRepository, never()).findByName(any());
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void saveTransaction_NullUser_ThrowsIllegalArgumentException() {
        // Arrange
        when(categoryRepository.findByName("Food & Dining")).thenReturn(Optional.of(category));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            transactionService.saveTransaction(transactionDTO, null));
        assertEquals("User cannot be null", exception.getMessage());
        verify(categoryRepository, times(1)).findByName("Food & Dining");
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void saveTransaction_NegativeSubtotal_ThrowsIllegalArgumentException() {
        // Arrange
        transactionDTO.setSubtotal(new BigDecimal("-10.00"));
        when(categoryRepository.findByName("Food & Dining")).thenReturn(Optional.of(category));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            transactionService.saveTransaction(transactionDTO, user));
        assertEquals("Subtotal must be positive", exception.getMessage());
        verify(categoryRepository, times(1)).findByName("Food & Dining");
        verify(transactionRepository, never()).save(any());
    }

    @Test
    void saveTransaction_FutureTransactionDate_ThrowsIllegalArgumentException() {
        // Arrange
        transactionDTO.setTransactionDate(LocalDate.now().plusDays(1));
        when(categoryRepository.findByName("Food & Dining")).thenReturn(Optional.of(category));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> 
            transactionService.saveTransaction(transactionDTO, user));
        assertEquals("Transaction date cannot be in the future", exception.getMessage());
        verify(categoryRepository, times(1)).findByName("Food & Dining");
        verify(transactionRepository, never()).save(any());
    }
}