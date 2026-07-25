# Mini ERP — Core Master Data & Enterprise Engine (SAP RAP)

[English](README.md) | [Українська](README.uk.md) | [Deutsch](README.de.md)

![SAP S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA%20Cloud-008FD3?style=flat&logo=sap)
![ABAP Cloud](https://img.shields.io/badge/Language-ABAP%20Cloud-blue?style=flat)
![RAP Framework](https://img.shields.io/badge/Framework-SAP%20RAP%20(Strict%202)-green?style=flat)
![OData V4](https://img.shields.io/badge/Protocol-OData%20V4-orange?style=flat)

---

## 📌 About the Project

**Mini ERP** is a demonstration project of a core enterprise system built on **ABAP Cloud** and the **SAP RESTful Application Programming Model (RAP)**.

The project demonstrates modern enterprise application development following **Clean Core** principles, featuring full **Draft capabilities** for stateful UX in SAP Fiori, transactional business logic validations, and **OData V4** service integration.

---

## 🏢 Business Objects (Master Data)

The repository currently includes the foundational Master Data entities:

### 1. Company Code
* **Purpose**: Management of corporate legal entities and organizational structures.
* **Features**:
  * Associations with standard released CDS views (`I_Currency`, `I_Country`).
  * Custom validations for mandatory fields and code uniqueness.

### 2. Warehouse
* **Purpose**: Storage location management associated with company codes.
* **Features**:
  * Foreign key association to `Company Code` with automated OData V4 framework validation (`useForValidation: true`).
  * Fiori Text Arrangement (`#TEXT_FIRST`) displaying `Company Name (Code)` in lists and object pages.
  * Multi-field search capabilities with Fuzzy Search threshold enabled.

### 3. VAT Rate
* **Purpose**: Tax code and rate management for financial calculations in sales and procurement.
* **Features**:
  * Maintenance of tax codes, business descriptions (`Standard Rate 19%`, `Reduced Rate 7%`, `Zero Rate 0%`), and tax percentages.
  * Range validation ensuring the tax percentage stays between `0.00` and `100.00%`.
  * Mandatory field and duplicate key checks.

---

## 🗺 Roadmap

Upcoming modules planned for integration:

* 📦 **Item Groups & Products/Services**: Material groups, product master data, and service items.
* 🤝 **Business Partners**: Customers and Vendors master data.
* 🧾 **Sales & Purchase Documents**: Transactional processing (Purchase Orders, Sales Orders, Invoices).

---

## 🛠 Technical Architecture & UX

* **RAP Strict Mode 2**: Compliance with modern transactional standards in SAP S/4HANA Cloud.
* **Full Draft Support**: Seamless stateful editing and session handling in SAP Fiori Elements.
* **State Area Messaging**: Field-bound error messages directly mapped to UI controls (`%element`).
* **Automated Data Seed**: Unified initial setup class (`ZCL_MERP_INITIAL_SETUP`) for quick test environment seeding.

---

## 🚀 How to Run

1. Clone the repository into your ABAP package using **abapGit** in Eclipse ADT.
2. Activate all project objects (`Ctrl + Shift + F3`).
3. Run class `ZCL_MERP_INITIAL_SETUP` (`F9`) to generate initial demo datasets.
4. Launch the **Fiori Elements Preview** via Service Binding `ZUI_MERP_O4`.
