package com.logitrack.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank
    private String username;
    @NotBlank
    private String password;
    @NotBlank
    private String rol;
    @NotBlank
    private String nombreCompleto;
    @Email
    @NotBlank
    private String email;
}