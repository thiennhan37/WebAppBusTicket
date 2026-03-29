package com.example.BusTicket.controller;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.service.MailService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
@RequestMapping("/mail")
public class MailController {
    private final MailService mailService;
    @PostMapping("/simple")
    ApiResponse<Boolean> sendSimpleMail(@RequestBody String toEmail){
        mailService.sendSimpleMail(toEmail, "new email", "this is new body email");
        return ApiResponse.success(true);
    }
}
