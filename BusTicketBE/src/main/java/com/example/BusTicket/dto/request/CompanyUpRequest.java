package com.example.BusTicket.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

@Getter
@Setter
@NoArgsConstructor
// với @ModelAttribute cần có obecjt rỗng và setter để map vào
public class CompanyUpRequest {

    private String policy;
    private MultipartFile avatarFile;

}
