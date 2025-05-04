package com.example.cashflow.authentication.services;

import java.math.BigDecimal;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.example.cashflow.authentication.repositories.UserRepository;
import com.example.cashflow.entities.User;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User getUserById(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    public User updateUserBalance(User user, BigDecimal newBalance) {
        user.setBalance(newBalance);
        return userRepository.save(user);
    }

}
