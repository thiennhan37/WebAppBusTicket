package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.enums.StatusEnum;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-22T19:38:48+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class CustomerMapperImpl implements CustomerMapper {

    @Override
    public CustomerInfoResponse toCustomerInfoResponse(Customer customer) {
        if ( customer == null ) {
            return null;
        }

        CustomerInfoResponse.CustomerInfoResponseBuilder customerInfoResponse = CustomerInfoResponse.builder();

        customerInfoResponse.id( customer.getId() );
        customerInfoResponse.email( customer.getEmail() );
        customerInfoResponse.phone( customer.getPhone() );
        customerInfoResponse.fullName( customer.getFullName() );
        customerInfoResponse.dob( customer.getDob() );
        customerInfoResponse.gender( customer.getGender() );
        if ( customer.getStatus() != null ) {
            customerInfoResponse.status( Enum.valueOf( StatusEnum.class, customer.getStatus() ) );
        }
        customerInfoResponse.createdAt( customer.getCreatedAt() );

        return customerInfoResponse.build();
    }

    @Override
    public List<CustomerInfoResponse> toCustomerInfoResponseList(List<Customer> customerList) {
        if ( customerList == null ) {
            return null;
        }

        List<CustomerInfoResponse> list = new ArrayList<CustomerInfoResponse>( customerList.size() );
        for ( Customer customer : customerList ) {
            list.add( toCustomerInfoResponse( customer ) );
        }

        return list;
    }
}
