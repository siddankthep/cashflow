package com.example.cashflow.services;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.cashflow.dto.LoginUserDTO;
import com.example.cashflow.dto.RegisterUserDTO;
import com.example.cashflow.entities.User;
import com.example.cashflow.repositories.UserRepository;

@Service
public class AuthenticationService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    public AuthenticationService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager) {

        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
    }

    public User signup(RegisterUserDTO input) {
        User user = new User(input.getEmail(), input.getUsername(), passwordEncoder.encode(input.getPassword()),
                input.getFirstName(), input.getLastName());
        return userRepository.save(user);
    }

    public User authenticate(LoginUserDTO input) {
        User user = userRepository.findByUsername(input.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(input.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid password");
        }

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(input.getUsername(), input.getPassword()));

        return user;
    }

    
}
