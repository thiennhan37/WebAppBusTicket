package com.example.BusTicket.validatior;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(
        validatedBy = {BirthValidator.class}
)
public @interface BirthConstraint {
    String message() default "{jakarta.validation.constraints.Size.message}";
    int min();
    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
