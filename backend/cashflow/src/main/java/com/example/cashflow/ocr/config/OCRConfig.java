package com.example.cashflow.ocr.config;

import net.sourceforge.tess4j.Tesseract;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OCRConfig {

    @Bean
    public Tesseract tesseract() {
        return new Tesseract();
    }
}