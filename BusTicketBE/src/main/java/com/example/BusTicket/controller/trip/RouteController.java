package com.example.BusTicket.controller.trip;


import com.example.BusTicket.dto.request.RouteCrRequest;
import com.example.BusTicket.dto.request.RouteUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.dto.response.RouteStopResponse;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.service.RouteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController

@RequiredArgsConstructor
@Slf4j
@RequestMapping("/nhaxe")
public class RouteController {
    private final RouteService routeService;

    @PostMapping("/routes")
    ApiResponse<Route> createRoute(@RequestBody RouteCrRequest request){
        return ApiResponse.success(routeService.createRoute(request));
    }
    @GetMapping("/routes")
    ApiResponse<PagedModel<RouteResponse>> getRoutePage(@RequestParam(required = false) String arrival,
                                                        @RequestParam(required = false) String destination,
                                                        @RequestParam(required = false) String keyword,  Pageable pageable){
        Page<RouteResponse> responsePage = routeService.getRoutePage(arrival, destination, keyword, pageable);
        return ApiResponse.success(new PagedModel<>(responsePage));
    }
    @GetMapping("/routes/all-routes")
    ApiResponse<List<RouteResponse>> getRouteList(){
        List<RouteResponse> responseList = routeService.getRouteList();
        return ApiResponse.success(responseList);
    }
    @GetMapping("/routes/{id}")
    ApiResponse<List<RouteStopResponse>> getRouteStopList(@PathVariable("id") Long routeId, @RequestParam(required = true) String type){
        return ApiResponse.success(routeService.getRouteStopList(routeId, type));
    }
    @PutMapping("/routes/{id}")
    ApiResponse<RouteResponse> updateRoute(@RequestBody RouteUpRequest request, @PathVariable("id") Long routeId){
        return ApiResponse.success(routeService.updateRoute(request, routeId));
    }

//    @GetMapping("/stops")
//    ApiResponse<List<Stop>> findAllStops(@RequestParam(required = true) String province,
//                                         @RequestParam(required = false) String keyword,
//                                         Pageable pageable){
//        return ApiResponse.success(provinceService.findAllStops(province, keyword, pageable));
//    }
}
