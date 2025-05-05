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

