package com.example.cashflow.ocr.services;

import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.multipart.MultipartFile;

import com.example.cashflow.authentication.repositories.UserRepository;
import com.example.cashflow.entities.Category;
import com.example.cashflow.entities.Transaction;
import com.example.cashflow.entities.User;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.example.cashflow.ocr.repositories.TransactionRepository;
import com.fasterxml.jackson.databind.JsonNode;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.UUID;

@Service
public class OCRService {

    private static final Logger logger = LoggerFactory.getLogger(GeminiService.class);
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final GeminiService geminiService;
    private final String UPLOAD_DIRECTORY = "/home/sid/Sid/2.Spring_2025/SWE/Projects/cashflow/receipt-images";
    private final String TESSDATA_PATH = "/usr/share/tesseract-ocr/5/tessdata/";

    public OCRService(GeminiService geminiService,
            CategoryRepository categoryRepository,
            UserRepository userRepository) {
        this.geminiService = geminiService;
        this.categoryRepository = categoryRepository;
        this.userRepository = userRepository;
    }

    public Transaction processReceipt(MultipartFile image, UUID userId)
            throws IOException, TesseractException, RestClientException {

        String filePath = storeImage(image);
        String ocrResult = performOcr(filePath);
        logger.info("OCR Result: " + ocrResult);
        logger.info("OCR Result Length: " + ocrResult.length());

        if (ocrResult.length() < 1) {
            throw new IllegalArgumentException("Failed to dectect information from receipt");
        }
        JsonNode categoryResponse = geminiService.categorizeReceipt(ocrResult, userId);

        UUID categoryId = UUID.fromString(categoryResponse.get("id").asText());

        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));

        JsonNode metadata = geminiService.summarizeReceipt(ocrResult);

        if (metadata == null) {
            throw new IllegalArgumentException("Failed to detect information from receipt");
        }

        String description = metadata.get("description").asText();
        BigDecimal subtotal = new BigDecimal(metadata.get("subtotal").asDouble());
        LocalDate date = LocalDate.parse(metadata.get("date").asText());
        String paymentMethod = metadata.get("paymentMethod").asText();
        String location = metadata.get("location").asText();

        Transaction transaction = new Transaction(
                user,
                category,
                subtotal,
                description,
                date,
                paymentMethod,
                location);

        return transaction;
    }

    private String storeImage(MultipartFile image) throws IOException {
        if (image.isEmpty()) {
            throw new IllegalArgumentException("No image uploaded"); // Or handle differently
        }

        String fileName = UUID.randomUUID().toString() + "." + getFileExtension(image.getOriginalFilename());
        Path uploadPath = Paths.get(UPLOAD_DIRECTORY);
        Files.createDirectories(uploadPath);
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(image.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return filePath.toString();
    }

    private String performOcr(String imagePath) throws TesseractException {
        Tesseract tesseract = new Tesseract();
        tesseract.setDatapath(TESSDATA_PATH); // Set path to Tesseract data files
        return tesseract.doOCR(new java.io.File(imagePath));
    }

    private String getFileExtension(String fileName) {
        if (fileName == null) {
            return "";
        }
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex == -1 || dotIndex == fileName.length() - 1) {
            return ""; // No extension or dot is the last character
        }
        return fileName.substring(dotIndex + 1);
    }

}
