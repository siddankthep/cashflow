package com.example.cashflow.entities;

import jakarta.persistence.*;

import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.UuidGenerator;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "budget_splits", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "budget_plan_id", "name" })
})
public class BudgetSplit {

    @Id
    @GeneratedValue
    @UuidGenerator
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "budget_plan_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private BudgetPlan budgetPlan;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal percentage;

    // Constructors
    public BudgetSplit() {
    }

    public BudgetSplit(BudgetPlan budgetPlan, String name, BigDecimal percentage) {
        this.budgetPlan = budgetPlan;
        this.name = name;
        this.percentage = percentage;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public BudgetPlan getBudgetPlan() {
        return budgetPlan;
    }

    public void setBudgetPlan(BudgetPlan budgetPlan) {
        this.budgetPlan = budgetPlan;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getPercentage() {
        return percentage;
    }

    public void setPercentage(BigDecimal percentage) {
        this.percentage = percentage;
    }
}
