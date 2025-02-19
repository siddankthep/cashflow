package com.example.cashflow.ocr.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GeminiGenerateContentRequest {
    private List<Content> contents;
    private GenerationConfig generationConfig;
}
