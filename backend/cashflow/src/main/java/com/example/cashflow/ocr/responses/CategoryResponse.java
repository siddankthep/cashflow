package com.example.cashflow.ocr.responses;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class CategoryResponse {
    private UUID id;
    private String name;
    private String icon;
    private String color;

}
