package com.example.cashflow.authentication.responses;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class RegisterResponse {
    private UUID id;
    private String email;
    private String username;
    private String firstName;
    private String lastName;
}
