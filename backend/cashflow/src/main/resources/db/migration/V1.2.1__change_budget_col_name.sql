-- V1.2.1__rename_budget_column.sql

ALTER TABLE users
RENAME COLUMN budget TO monthly_budget;