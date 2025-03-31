package com.example.cashflow.authentication.services;

import com.example.cashflow.authentication.dto.LoginUserDTO;
import com.example.cashflow.authentication.dto.RegisterUserDTO;
import com.example.cashflow.authentication.repositories.UserRepository;
import com.example.cashflow.entities.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class AuthenticationServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private AuthenticationManager authenticationManager;

    @InjectMocks
    private AuthenticationService authenticationService;

    @BeforeEach
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    // Tests for signup
    @Test
    public void testSignup_Success() {
        // Arrange
        RegisterUserDTO input = new RegisterUserDTO();
        input.setEmail("test@example.com");
        input.setUsername("testuser");
        input.setPassword("password123");
        input.setFirstName("John");
        input.setLastName("Doe");

        String encodedPassword = "encodedPassword123";
        User savedUser = new User("test@example.com", "testuser", encodedPassword, "John", "Doe");
        savedUser.setId(UUID.randomUUID()); // Simulate JPA-generated ID

        when(passwordEncoder.encode("password123")).thenReturn(encodedPassword);
        when(userRepository.save(any(User.class))).thenReturn(savedUser);

        // Act
        User result = authenticationService.signup(input);

        // Assert
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        assertEquals(encodedPassword, result.getPasswordHash());
        assertEquals("test@example.com", result.getEmail());
        assertEquals("John", result.getFirstName());
        assertEquals("Doe", result.getLastName());
        assertEquals("VND", result.getPreferredCurrency()); // Default value
        verify(userRepository, times(1)).save(any(User.class));
        verify(passwordEncoder, times(1)).encode("password123");
    }

    @Test
    public void testSignup_NullInputFields_StillWorks() {
        // Arrange
        RegisterUserDTO input = new RegisterUserDTO();
        input.setEmail("test@example.com");
        input.setUsername("testuser");
        input.setPassword("password123");
        // firstName and lastName are null

        String encodedPassword = "encodedPassword123";
        User savedUser = new User("test@example.com", "testuser", encodedPassword, null, null);
        savedUser.setId(UUID.randomUUID());

        when(passwordEncoder.encode("password123")).thenReturn(encodedPassword);
        when(userRepository.save(any(User.class))).thenReturn(savedUser);

        // Act
        User result = authenticationService.signup(input);

        // Assert
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        assertNull(result.getFirstName());
        assertNull(result.getLastName());
        verify(userRepository, times(1)).save(any(User.class));
    }

    // Tests for authenticate
    @Test
    public void testAuthenticate_Success() {
        // Arrange
        LoginUserDTO input = new LoginUserDTO();
        input.setUsername("testuser");
        input.setPassword("password123");

        User user = new User("test@example.com", "testuser", "encodedPassword123", "John", "Doe");
        user.setId(UUID.randomUUID());

        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("password123", "encodedPassword123")).thenReturn(true);
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(null); // Mock successful authentication

        // Act
        User result = authenticationService.authenticate(input);

        // Assert
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        assertEquals("encodedPassword123", result.getPasswordHash());
        verify(userRepository, times(1)).findByUsername("testuser");
        verify(passwordEncoder, times(1)).matches("password123", "encodedPassword123");
        verify(authenticationManager, times(1))
                .authenticate(new UsernamePasswordAuthenticationToken("testuser", "password123"));
    }

    @Test
    public void testAuthenticate_UserNotFound_ThrowsException() {
        // Arrange
        LoginUserDTO input = new LoginUserDTO();
        input.setUsername("testuser");
        input.setPassword("password123");

        when(userRepository.findByUsername("testuser")).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authenticationService.authenticate(input);
        });
        assertEquals("User not found", exception.getMessage());
        verify(userRepository, times(1)).findByUsername("testuser");
        verify(passwordEncoder, never()).matches(anyString(), anyString());
        verify(authenticationManager, never()).authenticate(any());
    }

    @Test
    public void testAuthenticate_InvalidPassword_ThrowsException() {
        // Arrange
        LoginUserDTO input = new LoginUserDTO();
        input.setUsername("testuser");
        input.setPassword("wrongpassword");

        User user = new User("test@example.com", "testuser", "encodedPassword123", "John", "Doe");
        user.setId(UUID.randomUUID());

        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrongpassword", "encodedPassword123")).thenReturn(false);

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authenticationService.authenticate(input);
        });
        assertEquals("Invalid password", exception.getMessage());
        verify(userRepository, times(1)).findByUsername("testuser");
        verify(passwordEncoder, times(1)).matches("wrongpassword", "encodedPassword123");
        verify(authenticationManager, never()).authenticate(any());
    }

    @Test
    public void testAuthenticate_NullInput_ThrowsException() {
        // Arrange
        LoginUserDTO input = new LoginUserDTO(); // username and password are null

        when(userRepository.findByUsername(null)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authenticationService.authenticate(input);
        });
        assertEquals("User not found", exception.getMessage());
        verify(userRepository, times(1)).findByUsername(null);
        verify(authenticationManager, never()).authenticate(any());
    }
}