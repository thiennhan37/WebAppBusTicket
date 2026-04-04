package com.example.BusTicket.service;

import com.example.BusTicket.entity.Province;
import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.repository.jpa.ProvinceRepository;
import com.example.BusTicket.repository.jpa.StopRepository;
import com.example.BusTicket.specification.StopSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProvinceService {
    private final ProvinceRepository provinceRepository;
    private final StopRepository stopRepository;

    public List<Province> searchProvinces(String keyword, Pageable pageable){
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5);
        if(keyword == null) keyword = "";
        return provinceRepository.findByNameContainingIgnoreCase(keyword, fixedPageable);
    }
    public List<Stop> findAllStops(String company, String keyword, Pageable pageable){
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5);
        Specification<Stop> spec = Specification.where(StopSpecification.hasProvinceId(company))
                .and(StopSpecification.containsKeyword(keyword));
        Page<Stop> stopPage =  stopRepository.findAll(spec, fixedPageable);
        return stopPage.getContent();
    }

}
