package com.example.BusTicket.controller;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.service.S3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
public class UploadController {

    private final S3Service s3Service;

    @PostMapping
    public ApiResponse<String> uploadImage(
            @RequestParam("file") MultipartFile file
    ) {
        try {
            String imageUrl = s3Service.uploadFile(file);
            return ApiResponse.success(imageUrl);

        } catch (Exception e) {
            return ApiResponse.success(ErrorCode.ERROR_S3.getMessage());
        }
    }
}