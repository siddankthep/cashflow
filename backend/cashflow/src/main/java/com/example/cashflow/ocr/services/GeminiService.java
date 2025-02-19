package com.example.cashflow.ocr.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.web.client.RestClientException;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;

import com.example.cashflow.entities.Category;
import com.example.cashflow.ocr.dto.*;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.annotation.PostConstruct;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.http.MediaType;

@Service
public class GeminiService {

  private static final Logger logger = LoggerFactory.getLogger(GeminiService.class);

  @Value("${gemini.api-key}")
  private String apiKey;

  private final WebClient webClient;
  private final ObjectMapper objectMapper;
  private final CategoryRepository categoryRepository;
  private String url;

  private String categorizePrompt = """
      Given a receipt, your task is to choose which category the purchase belongs to based on a list of categories. The categories are: %s. Please choose the category that best fits the following purchase.
      The output should be the id of the category you choose.

      Example output:
      {
          "id": 1668e79f-1822-4f20-b24e-5e446222f348
      }
      """;;
  private final String summarizePrompt = """
      Sau đây là 1 danh sách các sản phẩm bạn đã mua trong 1 hóa đơn. Nhiệm vụ của bạn là tóm tắt nội dung hóa đơn này và trả về các thông tin siêu dữ liệu của hóa đơn đó bao gồm tổng giá trị hóa đơn, ngày mua hàng, phương thức thanh toán và địa điểm mua hàng.

      Hãy trả kết quả theo format JSON với dạng sau:
      {
        "description": "Hóa đơn này được lập tại quán ăn Thiện Tân, bao gồm các món ăn như bún, mì, cơm, sườn, hủ tiếu, tôm lăn bột và nước uống (Pepsi, trà đá). Tổng cộng có 10 món ăn và 10 ly nước được đặt",
          "subtotal": 537000,
          "date": "2022-10-10",
          "paymentMethod": "Tiền mặt",
          "location": "Quán ăn Thiện Tân, 47-19 Tôn Đản, Phường 13, Quận 4, TP.HCM"
      }
      """;

  public GeminiService(CategoryRepository categoryRepository, WebClient webClient) {
    this.webClient = webClient;
    this.categoryRepository = categoryRepository;
    this.objectMapper = new ObjectMapper();

  }

  @PostConstruct
  public void init() {
    logger.info("API Key: {}", apiKey);
    this.url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key="
        + apiKey;
  }

  public JsonNode summarizeReceipt(String receiptContent) throws RuntimeException {
    return generateGemini(summarizePrompt, receiptContent);
  }

  public JsonNode categorizeReceipt(String receiptContent, UUID userId)
      throws RestClientException {
    categorizePrompt = formatCategorizePrompt(userId);

    return generateGemini(categorizePrompt, receiptContent);
  }

  private JsonNode generateGemini(String prompt, String content) {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    WebClient webClient = WebClient.create();

    try {
      GeminiGenerateContentRequest request = new GeminiGenerateContentRequest(
          List.of(new Content(List.of(new Part(prompt), new Part(content)))),
          new GenerationConfig("application/json"));
      GeminiGenerateContentResponse response = webClient.post()
          .uri(url)
          .header("Content-Type", "application/json")
          .bodyValue(objectMapper.writeValueAsString(request))
          .retrieve()
          .onStatus(HttpStatusCode::isError, res -> res.bodyToMono(String.class)
              .flatMap(error -> Mono.error(new ResponseStatusException(
                  res.statusCode(),
                  "Gemini API error: " + error))))
          .bodyToMono(GeminiGenerateContentResponse.class)
          .block();

      if (response == null || response.getCandidates() == null || response.getCandidates().isEmpty()) {
        throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "No valid response from Gemini API");
      }

      // Extract "text" field from response
      String textJsonString = response.getCandidates().get(0).getContent().getParts().get(0).getText();

      // Convert extracted string into JSON object
      return objectMapper.readTree(textJsonString);
    } catch (Exception e) {
      throw new RuntimeException("Error occurred while calling Gemini API", e);
    }
  }

  private String formatCategorizePrompt(UUID userId) {
    Optional<List<Category>> categories = categoryRepository.findAllByUserId(userId);

    List<String> categoryJsonObjects = categories.orElseThrow(() -> new RuntimeException("Categories not found"))
        .stream()
        .map(category -> String.format("{\"id\": \"%s\", \"name\": \"%s\"}", category.getId(), category.getName()))
        .toList();
    return String.format(categorizePrompt, String.join(", ", categoryJsonObjects));
  }
}
