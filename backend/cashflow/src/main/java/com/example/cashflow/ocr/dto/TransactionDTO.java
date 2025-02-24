package com.example.cashflow.ocr.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import com.example.cashflow.entities.Category;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TransactionDTO {
    private Category category;
    private BigDecimal subtotal;
    private String description;
    private LocalDate transactionDate;
    private String paymentMethod;
    private String location;

}
