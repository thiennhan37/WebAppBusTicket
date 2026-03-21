package com.example.BusTicket.validatior;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Objects;

public class BirthValidator implements ConstraintValidator<BirthConstraint, LocalDate> {
    private int min;
    @Override
    public void initialize(BirthConstraint constraintAnnotation) {
        ConstraintValidator.super.initialize(constraintAnnotation);
        min = constraintAnnotation.min();
    }

    @Override
    public boolean isValid(LocalDate localDate, ConstraintValidatorContext constraintValidatorContext) {
        if(Objects.isNull(localDate)) return true;
        long year = ChronoUnit.YEARS.between(localDate, LocalDate.now());
        return year >= min;
    }
}
