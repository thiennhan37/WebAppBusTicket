package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.entity.Message;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface MessageMapper {
    @Mapping(target = "conversationId", source = "conversation.id")
    @Mapping(target = "unreadCustomerCount", source = "unreadCustomerCount")
    @Mapping(target = "unreadCompanyCount", source = "unreadCompanyCount")
    MessageResponse toMessageResponse(Message message);

}
