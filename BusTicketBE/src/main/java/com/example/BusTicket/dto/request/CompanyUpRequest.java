package com.example.BusTicket.dto.request;

import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.entity.RouteStop;
import com.example.BusTicket.entity.Trip;
import com.example.BusTicket.validatior.BirthConstraint;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
public class BookingOrderCrRequest {

    @NotNull(message = "BookingOrder Id không được rỗng")
    private String id;
    @NotNull
    private String customerName;
    @NotNull
    private String customerPhone;
    @NotNull @Email(message = "Email không hợp lệ")
    private String customerEmail;
    private String bookingUserId;
    @NotNull
    private Long arrivalId;
    @NotNull
    private List<String> tripSeatIdList;
    @NotNull
    private Long destinationId;

}
