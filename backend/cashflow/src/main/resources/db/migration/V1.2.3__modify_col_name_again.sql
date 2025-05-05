-- V1.2.2__rename_budget_column.sql

ALTER TABLE users
RENAME COLUMN monthly_budget TO balance;