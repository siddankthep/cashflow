-- V1.0.0__create_initial_schema.sql
-- Initial schema creation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    preferred_currency VARCHAR(3) DEFAULT 'VND',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- V1.0.1__create_categories_table.sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(7),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, name)
);

-- V1.0.2__create_transactions_table.sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    category_id UUID REFERENCES categories(id),
    subtotal DECIMAL(12,2) NOT NULL,
    description TEXT,
    transaction_date DATE NOT NULL,
    payment_method VARCHAR(50),
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- V1.0.3__create_budget_plans_table.sql
CREATE TABLE budget_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    name VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- V1.0.4__create_budget_splits_table.sql
CREATE TABLE budget_splits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    budget_plan_id UUID REFERENCES budget_plans(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
    UNIQUE (budget_plan_id, name)
);

-- V1.0.5__add_timestamp_triggers.sql
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_timestamp
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_transactions_timestamp
    BEFORE UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();


-- V1.0.6__add_check_percentage_trigger.sql
CREATE OR REPLACE FUNCTION check_total_percentage()
RETURNS TRIGGER AS $$
DECLARE
    total_percentage NUMERIC;
BEGIN
    -- Calculate the total percentage
    SELECT SUM(percentage) INTO total_percentage 
    FROM budget_splits 
    WHERE budget_plan_id = NEW.budget_plan_id;

    -- Check if it exceeds 100%
    IF total_percentage > 100 THEN
        RAISE EXCEPTION 'Total percentage must not exceed 100%%';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

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

-- V1.1.0__insert_default_categories.sql
INSERT INTO users (email, username, password_hash, first_name, last_name) VALUES
    ('sid@admin.com', 'admin', 'password', 'Sid', 'Nguyen');

-- V1.1.0__insert_default_categories.sql
INSERT INTO categories (user_id, name, icon, color) VALUES
    (NULL, 'Food & Dining', 'restaurant', '#FF5733'),
    (NULL, 'Transportation', 'car', '#33FF57'),
    (NULL, 'Shopping', 'shopping-bag', '#3357FF'),
    (NULL, 'Bills & Utilities', 'file-text', '#FF33F5'),
    (NULL, 'Entertainment', 'tv', '#33FFF5'),
    (NULL, 'Healthcare', 'heart', '#F5FF33'),
    (NULL, 'Income', 'dollar-sign', '#33FF57');

