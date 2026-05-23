package com.example.BusTicket.service;

import com.example.BusTicket.dto.response.adminReport.*;
import com.example.BusTicket.mapper.CompanyRegisterMapper;
import com.example.BusTicket.repository.jpa.AdminRepository;
import com.example.BusTicket.repository.jpa.BusCompanyRepository;
import com.example.BusTicket.repository.jpa.CompanyRegisterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.BusTicket.repository.jpa.CustomerRepository;
import com.example.BusTicket.repository.jpa.TicketRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminReportService {
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyRegisterMapper companyRegisterMapper;
    private final CompanyRegisterRepository companyRegisterRepository;
    private final CustomerRepository customerRepository;
    private final TicketRepository ticketRepository;

    public AdminRevenueReport getRevenueReport(){
        LocalDate now = LocalDate.now();
        LocalDateTime startCurrentMonth = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime endCurrentMonth = startCurrentMonth.plusMonths(1);

        Long totalRevenueCurrentMonth = busCompanyRepository.getSystemRevenueInMonth(startCurrentMonth, endCurrentMonth);
        if (totalRevenueCurrentMonth == null) {
            totalRevenueCurrentMonth = 0L;
        }

        List<RevenueMonth> revenueByMonth = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/yyyy");
        for (int i = 6; i >= 0; i--) {
            LocalDateTime start = now.minusMonths(i).withDayOfMonth(1).atStartOfDay();
            LocalDateTime end = start.plusMonths(1);
            Long amount = busCompanyRepository.getSystemRevenueInMonth(start, end);
            revenueByMonth.add(RevenueMonth.builder()
                    .month(start.format(formatter))
                    .amount(amount != null ? amount : 0L)
                    .build());
        }

        List<Object[]> topCompaniesObj = busCompanyRepository.getTop7CompaniesByRevenue();
        List<RevenueCompany> revenueCompanyList = new ArrayList<>();
        for (Object[] obj : topCompaniesObj) {
            String companyName = obj[0].toString();
            Long ticketCount = Long.parseLong(obj[1].toString());
            Long amount = Long.parseLong(obj[2].toString());
            revenueCompanyList.add(RevenueCompany.builder()
                    .companyName(companyName)
                    .ticketCount(ticketCount)
                    .amount(amount)
                    .build());
        }

        return AdminRevenueReport.builder()
                .totalRevenueCurrentMonth(totalRevenueCurrentMonth)
                .revenueByMonth(revenueByMonth)
                .revenueCompanyList(revenueCompanyList)
                .build();
    }
    public AdminCustomerReport getCustomerReport(){
        Long totalCustomer = customerRepository.count();
        if (totalCustomer == null) {
            totalCustomer = 0L;
        }

        List<CustomerMonth> customerByMonth = new ArrayList<>();
        LocalDate now = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/yyyy");

        for (int i = 6; i >= 0; i--) {
            LocalDateTime start = now.minusMonths(i).withDayOfMonth(1).atStartOfDay();
            LocalDateTime end = start.plusMonths(1);
            Long count = customerRepository.countNewCustomersInPeriod(start, end);
            customerByMonth.add(CustomerMonth.builder()
                    .month(start.format(formatter))
                    .customerCount(count != null ? count : 0L)
                    .build());
        }

        return AdminCustomerReport.builder()
                .totalCustomer(totalCustomer)
                .customerByMonth(customerByMonth)
                .build();
    }
    public AdminTicketReport getTicketReport(){
        List<TicketMonth> ticketByMonth = new ArrayList<>();
        LocalDate now = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/yyyy");

        List<String> bookedStatuses = List.of("HOLDING", "PAID");
        List<String> canceledStatuses = List.of("CANCELLED");

        for (int i = 6; i >= 0; i--) {
            LocalDateTime start = now.minusMonths(i).withDayOfMonth(1).atStartOfDay();
            LocalDateTime end = start.plusMonths(1);
            Long count = ticketRepository.countSystemTicketsByStatusesInPeriod(start, end, bookedStatuses);
            ticketByMonth.add(TicketMonth.builder()
                    .month(start.format(formatter))
                    .ticketCount(count != null ? count : 0L)
                    .build());
        }

        LocalDateTime startCurrentMonth = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime endCurrentMonth = startCurrentMonth.plusMonths(1);

        Long totalTicketCurrentMonth = ticketRepository.countSystemTicketsByStatusesInPeriod(startCurrentMonth, endCurrentMonth, bookedStatuses);
        Long canceledTicketCurrentMonth = ticketRepository.countSystemTicketsByStatusesInPeriod(startCurrentMonth, endCurrentMonth, canceledStatuses);

        return AdminTicketReport.builder()
                .ticketByMonth(ticketByMonth)
                .totalTicketCurrentMonth(totalTicketCurrentMonth != null ? totalTicketCurrentMonth : 0L)
                .canceledTicketCurrentMonth(canceledTicketCurrentMonth != null ? canceledTicketCurrentMonth : 0L)
                .build();
    }

}
