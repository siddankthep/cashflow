package com.example.cashflow.ocr.services;

import com.example.cashflow.authentication.repositories.UserRepository;
import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import net.sourceforge.tess4j.Tesseract;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class OCRServiceTest {

    @Mock
    private GeminiService geminiService;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private Tesseract tesseract;

    @InjectMocks
    private OCRService ocrService;

    private ObjectMapper objectMapper;
    private Path tempDir;

    @BeforeEach
    void setUp() throws IOException {
        MockitoAnnotations.openMocks(this);
        objectMapper = new ObjectMapper();
        tempDir = Files.createTempDirectory("ocr-test");
        ocrService = new OCRService(geminiService, categoryRepository, userRepository, tesseract, tempDir.toString(),
                "/mock/tessdata");
    }

    @AfterEach
    void tearDown() throws IOException {
        Files.walk(tempDir)
                .map(Path::toFile)
                .forEach(File::delete);
        Files.deleteIfExists(tempDir);
    }

    @Test
    void processReceipt_SuccessfulProcessing_ReturnsTransaction() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID categoryId = UUID.randomUUID();
        byte[] validJpeg = {
                (byte) 0xFF, (byte) 0xD8, // SOI
                (byte) 0xFF, (byte) 0xE0, 0x00, 0x10, 'J', 'F', 'I', 'F', 0x00,
                0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
                (byte) 0xFF, (byte) 0xD9 // EOI
        };
        MultipartFile mockFile = new MockMultipartFile("image", "receipt.jpg", "image/jpeg", validJpeg);

        when(tesseract.doOCR(any(File.class))).thenReturn("Sample receipt text");

        JsonNode categoryNode = objectMapper.createObjectNode().put("id", categoryId.toString());
        when(geminiService.categorizeReceipt("Sample receipt text", userId)).thenReturn(categoryNode);

        JsonNode metadata = objectMapper.createObjectNode()
                .put("description", "Groceries")
                .put("subtotal", 47)
                .put("date", "2025-04-01")
                .put("paymentMethod", "Credit Card")
                .put("location", "Store XYZ");
        when(geminiService.summarizeReceipt("Sample receipt text")).thenReturn(metadata);

        User user = new User();
        Category category = new Category();
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(category));

        // Act
        Transaction result = ocrService.processReceipt(mockFile, userId);

        // Assert
        assertNotNull(result);
        assertEquals(user, result.getUser());
        assertEquals(category, result.getCategory());
        assertEquals(new BigDecimal("47"), result.getSubtotal());
        assertEquals("Groceries", result.getDescription());
        assertEquals(LocalDate.of(2025, 4, 1), result.getTransactionDate());
        assertEquals("Credit Card", result.getPaymentMethod());
        assertEquals("Store XYZ", result.getLocation());

        File[] files = tempDir.toFile().listFiles();
        assertNotNull(files);
        assertEquals(1, files.length);
        assertTrue(files[0].getName().endsWith(".jpg"));
    }

    @Test
    void processReceipt_EmptyImage_ThrowsIllegalArgumentException() throws Exception {
        // Arrange
        MultipartFile mockFile = new MockMultipartFile("image", "receipt.jpg", "image/jpeg", new byte[0]);
        UUID userId = UUID.randomUUID();

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> ocrService.processReceipt(mockFile, userId));
    }

    @Test
    void processReceipt_NoOcrResult_ThrowsIllegalArgumentException() throws Exception {
        // Arrange
        byte[] validJpeg = { (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xD9 };
        MultipartFile mockFile = new MockMultipartFile("image", "receipt.jpg", "image/jpeg", validJpeg);
        UUID userId = UUID.randomUUID();
        when(tesseract.doOCR(any(File.class))).thenReturn("");

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> ocrService.processReceipt(mockFile, userId));
    }

    @Test
    void processReceipt_CategoryNotFound_ThrowsIllegalArgumentException() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID categoryId = UUID.randomUUID();
        byte[] validJpeg = { (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xD9 };
        MultipartFile mockFile = new MockMultipartFile("image", "receipt.jpg", "image/jpeg", validJpeg);

        when(tesseract.doOCR(any(File.class))).thenReturn("Sample receipt text");
        JsonNode categoryNode = objectMapper.createObjectNode().put("id", categoryId.toString());
        when(geminiService.categorizeReceipt("Sample receipt text", userId)).thenReturn(categoryNode);
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.empty());
        when(userRepository.findById(userId)).thenReturn(Optional.of(new User()));

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> ocrService.processReceipt(mockFile, userId));
    }

    @Test
    void processReceipt_NullMetadata_ThrowsIllegalArgumentException() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID categoryId = UUID.randomUUID();
        byte[] validJpeg = { (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xD9 };
        MultipartFile mockFile = new MockMultipartFile("image", "receipt.jpg", "image/jpeg", validJpeg);

        when(tesseract.doOCR(any(File.class))).thenReturn("Sample receipt text");
        JsonNode categoryNode = objectMapper.createObjectNode().put("id", categoryId.toString());
        when(geminiService.categorizeReceipt("Sample receipt text", userId)).thenReturn(categoryNode);
        when(geminiService.summarizeReceipt("Sample receipt text")).thenReturn(null);
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(new Category()));
        when(userRepository.findById(userId)).thenReturn(Optional.of(new User()));

        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> ocrService.processReceipt(mockFile, userId));
    }
}