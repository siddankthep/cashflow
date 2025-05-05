-- V1.2.0__add_user_budget.sql

ALTER TABLE users 
ADD COLUMN budget NUMERIC(10, 2) DEFAULT 0.00;