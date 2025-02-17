-- V1.0.4__create_budget_splits_table.sql
CREATE TABLE budget_splits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_plan_id UUID REFERENCES budget_plans(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
    UNIQUE (budget_plan_id, name)
);