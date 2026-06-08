package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.entity.Message;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface MessageMapper {
    @Mapping(target = "conversationId", source = "conversation.id")
    MessageResponse toMessageResponse(Message message);

}
