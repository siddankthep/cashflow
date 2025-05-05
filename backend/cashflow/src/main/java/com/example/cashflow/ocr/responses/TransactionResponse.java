package com.example.cashflow.ocr.responses;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class TransactionResponse {
    private UUID id;
    private UUID userId;
    private CategoryResponse category;
    private BigDecimal subtotal;
    private String description;
    private LocalDate transactionDate;
    private String paymentMethod;
    private String location;

}
