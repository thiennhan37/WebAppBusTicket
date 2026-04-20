package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, String> {

}
