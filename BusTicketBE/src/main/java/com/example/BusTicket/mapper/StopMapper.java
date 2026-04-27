package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.StopResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.TripSimpleResponse;
import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.entity.Trip;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {})
public interface StopMapper {
    StopResponse toStopResponse(Stop stop);

}
