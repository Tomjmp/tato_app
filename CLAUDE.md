# CLAUDE.md

# TÁTO — AI Development Guide

## Project Overview

TÁTO is a real university capstone project developed for the course **TI3-701 - Desarrollo de Aplicaciones de Dispositivos Móviles** at Universidad Iberoamericana (UNIBE).

The goal is **not** to build a generic inventory CRUD.

TÁTO is an **Inventory Intelligence Mobile App** designed for micro and small businesses in the Dominican Republic.

Core value proposition:

> "TÁTO doesn't just record inventory; it watches inventory and tells users what matters."

The application should look like a commercial SaaS product suitable for a professional portfolio.

---

# Product Vision

Target users are owners of small businesses that currently manage inventory using:

- Paper
- Excel
- WhatsApp
- Memory

Examples:

- Beauty stores
- Instagram sellers
- Small grocery stores
- Small cafés
- Bakeries
- Home businesses
- Accessories stores
- Clothing stores
- Skincare shops

The biggest pain point is **lack of visibility**, not inventory registration itself.

Users need to know:

- What is about to run out
- What sells quickly
- What hasn't sold
- How much money is locked in inventory

---

# MVP Scope

The MVP includes:

- Authentication
- Business creation
- Product management
- Inventory movements
- Inventory history
- Dashboard
- Insights
- Offline mode
- Cloud synchronization
- Edge AI category suggestion

Do NOT implement:

- POS
- Accounting
- Payroll
- Billing
- NCF
- Marketplace
- Delivery
- ERP features
- Employee management
- Payment gateways

Always protect the MVP scope.

---

# Tech Stack

Frontend

- Flutter
- Dart
- Material Design 3

Backend

- Supabase
- PostgreSQL
- Authentication
- Storage
- Row Level Security

Offline

- Hive

State Management

- Riverpod

Navigation

- GoRouter

Dependency Injection

- Riverpod Providers

Edge AI

- Google ML Kit
- TensorFlow Lite (future)

Version Control

- Git
- GitHub
- GitHub Projects

---

# Architecture

Use Clean Architecture.

Every feature must be organized as:

feature/

    data/

        datasource/

        models/

        repositories/

    domain/

        entities/

        repositories/

        usecases/

    presentation/

        controllers/

        providers/

        screens/

        widgets/

Never mix UI and data logic.

Business rules belong inside use cases.

---

# Project Structure

lib/

core/

    constants/

    errors/

    extensions/

    routes/

    services/

    theme/

    utils/

shared/

    widgets/

    models/

    extensions/

features/

    auth/

    business/

    dashboard/

    inventory/

    movements/

    insights/

    scanner/

    profile/

main.dart

---

# Code Style

Always:

- Use null safety.
- Use immutable models.
- Use const constructors.
- Prefer composition over inheritance.
- Keep widgets small.
- Extract reusable widgets.
- Use meaningful names.
- Follow Flutter lints.
- Write readable code.

Never generate overly complex code.

Avoid premature optimization.

---

# State Management

Use Riverpod.

Preferred providers:

- AsyncNotifier
- Notifier
- FutureProvider

Avoid global mutable variables.

---

# Repository Pattern

Repositories should expose interfaces.

Example:

ProductRepository

Implementations:

MockProductRepository

SupabaseProductRepository

LocalProductRepository

Presentation layer must never know which implementation is being used.

---

# Offline First

Every write operation must:

1.

Save locally.

2.

Mark record as

synced = false

3.

Trigger synchronization if internet exists.

Never depend exclusively on internet.

---

# Database

Main tables:

users

businesses

categories

products

inventory_movements

Never delete movement history.

Stock must always be calculated from inventory movements or safely maintained.

Prevent negative stock.

---

# Sync Rules

Every entity should contain:

localId

cloudId

createdAt

updatedAt

synced

Conflict strategy:

Latest updatedAt wins unless business rules require otherwise.

---

# Insights Engine

The most important feature.

Must calculate:

Low stock

Fast-moving products

Slow-moving products

Products with no movement

Estimated days until depletion

Money locked in inventory

The dashboard should explain results in natural language.

Example:

"TÁTO noticed that this product could run out in approximately 3 days."

---

# Edge AI

Edge AI only assists users.

Never claim perfect recognition.

Workflow:

Camera

↓

Classification

↓

Suggested category

↓

User confirmation

↓

Save

User always has the final decision.

---

# UI Guidelines

Use Material Design 3.

Modern.

Minimal.

Clean.

Rounded corners.

Consistent spacing.

Professional colors.

Avoid excessive animations.

The app should feel trustworthy.

---

# Branding

Correct name:

TÁTO

Repository:

tato_app

Never write:

TATÓ

Primary slogan:

Tu inventario, sin complicarte.

---

# Dashboard Philosophy

The dashboard should NOT be a statistics page.

It should answer:

What needs attention today?

Prioritize cards such as:

Low stock

Fast sellers

Slow sellers

Money locked

Suggested actions

---

# Error Handling

Always provide friendly error messages.

Never expose raw exceptions.

Examples:

Unable to connect.

Product could not be saved.

Synchronization failed.

Retry later.

---

# Security

Every business belongs to one authenticated user.

Never expose another user's data.

Use Row Level Security.

---

# Testing

Prefer:

Unit tests

Repository tests

Widget tests

Critical flows:

Authentication

Inventory movements

Stock validation

Offline synchronization

Insights calculations

---

# Performance

Optimize for mobile devices.

Avoid rebuilding entire screens.

Lazy load lists.

Cache images.

Keep memory usage low.

---

# Git Workflow

Small commits.

Clear commit messages.

Example:

feat(auth): implement login screen

feat(products): create inventory list

fix(sync): prevent duplicate movements

refactor(insights): improve stock calculation

---

# Documentation

Every major feature should include:

Purpose

Architecture

Flow

Dependencies

Known limitations

---

# AI Assistant Rules

When generating code:

- Never invent APIs.
- Never assume backend exists.
- Ask for clarification if requirements conflict.
- Respect Clean Architecture.
- Respect project scope.
- Prioritize maintainability over cleverness.
- Prefer simple implementations suitable for a 15-week university project.
- Generate production-quality code whenever possible.

Always think before coding.

If a feature seems outside the MVP, explicitly warn about scope creep and propose a simpler alternative.