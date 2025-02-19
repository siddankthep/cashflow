package com.example.cashflow.authentication.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.cashflow.authentication.dto.LoginUserDTO;
import com.example.cashflow.authentication.dto.RegisterUserDTO;
import com.example.cashflow.authentication.responses.LoginResponse;
import com.example.cashflow.authentication.responses.RegisterResponse;
import com.example.cashflow.authentication.services.AuthenticationService;
import com.example.cashflow.authentication.services.JwtService;
import com.example.cashflow.entities.User;

@RequestMapping("/auth")
@RestController
public class AuthenticationController {
    private final JwtService jwtService;
    private final AuthenticationService authenticationService;

    public AuthenticationController(JwtService jwtService, AuthenticationService authenticationService) {
        this.jwtService = jwtService;
        this.authenticationService = authenticationService;
    }

    @PostMapping("/signup")
    public ResponseEntity<RegisterResponse> signup(@RequestBody RegisterUserDTO input) {
        User registeredUser = authenticationService.signup(input);
        RegisterResponse registerResponse = new RegisterResponse(registeredUser.getId(), registeredUser.getEmail(),
                registeredUser.getUsername(), registeredUser.getFirstName(), registeredUser.getLastName());
        return ResponseEntity.ok(registerResponse);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> authenticate(@RequestBody LoginUserDTO input) {
        User authenticatedUser = authenticationService.authenticate(input);
        String token = jwtService.generateToken(authenticatedUser);
        LoginResponse loginResponse = new LoginResponse(token, jwtService.getExpirationTime());
        return ResponseEntity.ok(loginResponse);
    }
}
