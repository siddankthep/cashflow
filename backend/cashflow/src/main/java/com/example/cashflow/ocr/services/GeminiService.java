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
import com.example.cashflow.ocr.dto.gemini.Content;
import com.example.cashflow.ocr.dto.gemini.GeminiGenerateContentRequest;
import com.example.cashflow.ocr.dto.gemini.GeminiGenerateContentResponse;
import com.example.cashflow.ocr.dto.gemini.GenerationConfig;
import com.example.cashflow.ocr.dto.gemini.Part;
import com.example.cashflow.ocr.repositories.CategoryRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.annotation.PostConstruct;
import reactor.core.publisher.Mono;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
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
      Here is a list of products you purchased in a receipt received from an OCR scanner. Your task is to summarize the content of this receipt and return the metadata of that receipt including the total value of the receipt, the date of purchase, the payment method, and the location of purchase.
      The fields in the JSON response should be:
      - description: A description of the receipt
      - subtotal: The total value of the receipt
      - date: The date of purchase in the format YYYY-MM-DD
      - paymentMethod: The payment method used. Can be either cash, credit card, or mobile payment
      - location: The location of the purchase


      Here is an example of the expected output. The output should be in Vietnamese.:
      {
        "description": "Hóa đơn này được lập tại quán ăn Thiện Tân, bao gồm các món ăn như bún, mì, cơm, sườn, hủ tiếu, tôm lăn bột và nước uống (Pepsi, trà đá). Tổng cộng có 10 món ăn và 10 ly nước được đặt",
          "subtotal": 537000, 
          "date": "2022-10-10",
          "paymentMethod": "Tiền mặt",
          "location": "Quán ăn Thiện Tân, 47-19 Tôn Đản, Phường 13, Quận 4, TP.HCM"
      }

      Sometimes, the receipt OCR scan may return gibberish (due to the image not being clear or the OCR engine not being able to recognize the text). In this case, you can return the following response with null in every field:
      {
        "description": null,
          "subtotal": null,
          "date": null,
          "paymentMethod": null,
          "location": null
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
      logger.info("Gemini API response: {}", textJsonString);

      // Convert extracted string into JSON object
      JsonNode jsonResponse = objectMapper.readTree(textJsonString);

      // Check if all fields are null
      boolean allFieldsNull = true;
      Iterator<Map.Entry<String, JsonNode>> fields = jsonResponse.fields();
      while (fields.hasNext()) {
        Map.Entry<String, JsonNode> field = fields.next();
        if (!field.getValue().isNull()) {
          allFieldsNull = false;
          break;
        }
      }

      // Return null if all fields are null, otherwise return the JSON response
      return allFieldsNull ? null : jsonResponse;
    } catch (Exception e) {
      throw new RuntimeException("Error occurred while calling Gemini API", e);
    }
  }

  private String formatCategorizePrompt(UUID userId) {
    List<Category> categories = categoryRepository.findAllByUserId(userId);

    List<String> categoryJsonObjects = categories
        .stream()
        .map(category -> String.format("{\"id\": \"%s\", \"name\": \"%s\"}", category.getId(), category.getName()))
        .toList();
    return String.format(categorizePrompt, String.join(", ", categoryJsonObjects));
  }
}
