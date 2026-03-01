# Smarter Budget

Aleksandra's SmartBudget application fork with slight modifications to make application more
suitable for daily usage.

Smarter Budget is a budget monitor application which helps track your incomes and expenses with and
ease. Beside list of transactions, application features basic statistics panel and modifiable
categories which bring to user some flexibility.

Currently added features:

* Modifiable categories (WIP)

---

Original README.md below:

# SmartBudget – Final Documentation

**Author:** Aleksandra Zawadka  
**Date:** 2026-01-14

---

## 1. Project Description

**SmartBudget** is a multi-platform application (Mobile & Desktop) developed in Flutter for personal
finance management. It operates as an offline-first solution, storing all data locally on the device
to ensure privacy and accessibility without an internet connection.

The application supports multiple users (separate accounts on one device), allowing them to track
income and expenses, analyze spending via charts, and manage monthly budgets.

---

## 2. Integrations & Architecture

* **Architecture:** The project follows a layered architecture (MVVM-like) using the Provider
  pattern for state management.
* **Logic Separation:** It separates logic (`UserProvider`, `AppSettingsProvider`) from the UI (
  `Screens`, `Widgets`) and data models.
* **Key Libraries:**
    * **Hive & Hive Flutter:** Fast, NoSQL local database for persisting users and transactions.
    * **UUID:** Generation of unique identifiers for users and transaction records.
    * **Provider:** State management and dependency injection.
    * **FL Chart:** Interactive bar and pie charts for financial statistics.
    * **Intl:** Date formatting and localization support.
    * **CSV & File Saver:** Exporting transaction history to `.csv` files.
    * **Crypto:** SHA-256 hashing for securing user passwords.
    * **Marquee:** Animation package for scrolling long text descriptions.

---

## 3. Implemented Optional Requirements

The application fulfills several optional requirements outlined in the initial plan:

1. **Platform Support:** Designed to run on Mobile (Android) and Desktop (Windows).
2. **Custom Authentication:** Secure, local registration and login system with password hashing and
   persistent session mechanism.
3. **Internationalization:** Complete support for English and Polish languages, switchable at
   runtime.
4. **Dark Mode:** Support for both Light and Dark visual themes.
5. **Interactive Charts:** Dynamic visualization of expenses by category and over time.
6. **Export Data:** Ability to save transaction history to a CSV file.
7. **Local Data Persistence:** Full offline support using Hive boxes with session recovery.
8. **Animations:** Smooth swipe-to-delete/edit interactions and Marquee effect for titles.
9. **Multi-step Form:** Guided 3-step transaction creation (Type, Details, Review).

---

## 4. Database Schema (Hive)

Data is stored in Hive "Boxes" (key-value stores).

### Box: `users`

Stores registered user accounts and session state:

* `userId` (String, UUID)
* `username` (String)
* `password` (String, Hashed)
* `theme`, `language`, `currency` (Enums)
* `monthlyLimit` (Double)
* `lastLoggedInUserId` (String, session persistence)

### Box: `transactions_{userId}`

A separate box for each user to ensure data isolation:

* `id` (String, UUID)
* `title` (String)
* `amount` (Double)
* `date` (DateTime)
* `category` (String)
* `type` (String: 'income'/'expense')

---

## 5. Instruction

### 5.1. Authentication

* On first launch, tap "Register" to create a secure local account.
* Select your preferred currency (PLN or EUR).
* The app "remembers" the user and skips the login screen on restart.

### 5.2. Usage

* **Transactions:** Add records via a 3-step form. Swipe list items to delete or edit.
* **Statistics:** View spending breakdowns via Bar and Pie charts in the "Statistics" tab.
* **Settings:** Change theme, language, currency, set a monthly limit, or export data to CSV.