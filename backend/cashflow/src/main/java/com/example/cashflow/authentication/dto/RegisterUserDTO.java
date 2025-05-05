package com.example.cashflow.authentication.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterUserDTO {
    private String email;
    private String username;
    private String password;
    private String firstName;
    private String lastName;
}
