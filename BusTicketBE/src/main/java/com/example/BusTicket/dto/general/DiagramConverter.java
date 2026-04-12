package com.example.BusTicket.dto.general;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper; // Sử dụng đúng thư viện chuẩn
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class DiagramConverter implements AttributeConverter<BusDiagram, String> {

    // Sử dụng Static để tối ưu hiệu năng và cấu hình một lần
    private static final ObjectMapper objectMapper = new ObjectMapper()
            .configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
            // Giúp bỏ qua nếu trong JSON có trường cũ, class hiện tại đã xóa

    @Override
    public String convertToDatabaseColumn(BusDiagram busDiagram) {
        if (busDiagram == null) return null;
        try {
            return objectMapper.writeValueAsString(busDiagram);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("JSON Writing Error", e);
        }
    }

    @Override
    public BusDiagram convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) return null;
        try {
            // Ép kiểu tường minh cho Jackson
            return objectMapper.readValue(dbData, BusDiagram.class);
        } catch (JsonProcessingException e) {
            // In ra log để bạn nhìn thấy lỗi thực sự là gì (Ví dụ: sai định dạng mảng)
            System.err.println("Dữ liệu lỗi trong DB: " + dbData);
            throw new RuntimeException("JSON Reading Error: " + e.getMessage(), e);
        }
    }
}