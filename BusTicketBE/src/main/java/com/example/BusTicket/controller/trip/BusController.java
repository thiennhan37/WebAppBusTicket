package com.example.BusTicket.controller.trip;


import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.service.BusService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController

@RequiredArgsConstructor
@Slf4j
public class BusController {
    private final BusService busService;

    @PostMapping("/bus-type")
    ApiResponse<BusType> createBusType(@RequestBody  BusType request){
        return ApiResponse.success(busService.createBusType(request));
    }
    @GetMapping("/bus-type/{id}")
    ApiResponse<BusType> getBusType(@PathVariable("id") Long id){
        return ApiResponse.success(busService.getBusType(id));
    }
    @GetMapping("/bus-type")
    ApiResponse<List<BusType>> getBusTypeList(){
        return ApiResponse.success(busService.getBusTypeList());
    }
}
