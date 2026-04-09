package com.example.BusTicket.service;

import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.BusTypeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class BusService {
    private final BusTypeRepository busTypeRepository;

    public BusType createBusType(BusType request){
        BusType busType = BusType.builder()
                .name(request.getName())
                .diagram(request.getDiagram())
                .build();
        log.info(busType.getDiagram().toString());
        return busTypeRepository.save(busType);
    }
    public BusType getBusType(Long id){
        return busTypeRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
    }

}
