-- V1.0.7__create_indexes.sql
-- Speed up category lookups per user
CREATE INDEX idx_categories_user_id ON categories(user_id);

-- Speed up transaction lookups per user
CREATE INDEX idx_transactions_user_id ON transactions(user_id);

-- Speed up transactions per category
CREATE INDEX idx_transactions_category_id ON transactions(category_id);

-- Speed up budget plans per user
CREATE INDEX idx_budget_plans_user_id ON budget_plans(user_id);

-- Speed up budget splits per budget plan
CREATE INDEX idx_budget_splits_budget_plan_id ON budget_splits(budget_plan_id);
