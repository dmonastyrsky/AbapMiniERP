# Mini ERP — Company Code Master Data Management (SAP RAP)

![SAP S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA%20Cloud-008FD3?style=flat&logo=sap)
![ABAP Cloud](https://img.shields.io/badge/Language-ABAP%20Cloud-blue?style=flat)
![RAP Framework](https://img.shields.io/badge/Framework-SAP%20RAP%20(Strict%202)-green?style=flat)
![OData V4](https://img.shields.io/badge/Protocol-OData%20V4-orange?style=flat)

Source code and architecture specification for the **Company Code** business object within the **Mini ERP** demonstration project. The object is built in accordance with Clean ABAP principles and the SAP RESTful Application Programming Model (RAP) architecture, featuring full Draft enablement and OData V4 UI service endpoints.

---

## 📐 Architecture & Project Components

The business object is developed following a strict layered architecture (`strict ( 2 )`):

### 1. Database & Dictionary Layer
* **`ZMERP_COMP_CODE`**: Primary transparent master data table utilizing custom Data Elements (`ZMERP_COMPANY_CODE`, `ZMERP_COMPANY_NAME`).
* **`ZMERP_COMP_D`**: Draft table with standard system inclusion `SYCH_BDL_DRAFT_ADMIN_INC`.
* **`ZMERP_S_ADMIN`**: Reusable administrative fields structure (`created_by`, `created_at`, `local_last_changed_by`, `local_last_changed_at`, `last_changed_at`).

### 2. Data & Presentation Layer (CDS Views & UI)
* **`ZMERP_R_COMPANY_CODE`**: Data Model (Root View Entity) featuring associations to standard system entities `I_Currency` and `I_Country`, semantic annotations, and `@ObjectModel.foreignKey.association` bindings.
* **`ZMERP_C_COMPANY_CODE`**: Consumption Layer (Projection View) optimized for transactional OData V4 queries, configured with Fuzzy Search (`@Search.fuzzinessThreshold: 0.8`) and high search ranking (`#HIGH`).
* **`ZMERP_C_COMPANY_CODE` (Metadata Extension)**: SAP Fiori Elements UI annotations (facet grouping, list view line items, hidden administrative section).

### 3. Business Logic & Behavior Layer
* **`ZMERP_R_COMPANY_CODE` (Behavior Definition - Root)**: Declaration of CRUD operations, ETag master definitions, full draft capabilities (`draft action Edit, Activate, Discard, Resume, Prepare`), and custom validations.
* **`ZMERP_C_COMPANY_CODE` (Behavior Definition - Projection)**: Projection behavior supporting `use draft` and `use side effects`.
* **`ZBP_MERP_R_COMPANY_CODE` / `LHC_ZMERP_R_COMPANY_CODE`**: Behavior Handler class implementing EML operations, mandatory field validations, and primary key uniqueness checks.

### 4. Infrastructure & Helper Classes
* **`ZMERP_R_COMPANY_CODE` / `ZMERP_C_COMPANY_CODE` (DCL)**: Access Control definitions for authorization checks and condition inheritance.
* **`ZUI_MERP` (Service Definition)**: Exposure of the UI service contract for OData V4 Fiori Elements.
* **`ZCM_MERP_MESSAGES`**: Custom message class implementing `IF_T100_DYN_MSG` and `IF_ABAP_BEHV_MESSAGE`.
* **`ZCL_MERP_INITIAL_SETUP`**: Executable setup class (`IF_OO_ADT_CLASSRUN`) for populating initial demo data.

---

## ✨ Key Technical Features

* **Strict Mode (2) Compliance**: Fully compliant with modern SAP S/4HANA Clean Core architecture standards.
* **Safe Key Validation**: Primary key uniqueness validation is triggered exclusively `on save { create; }`, preventing lockouts during object updates.
* **Enhanced UX/Fiori Integration**: Text associations integrated for automatic display of country and currency descriptions alongside technical keys (e.g., `DE (Germany)`, `EUR (Euro)`).
* **Fuzzy Search Capabilities**: Search configured to handle potential user typographical errors in search filters.
* **State Area Messaging**: Precise mapping of validation error messages to specific UI input fields in SAP Fiori.

---

## 🚀 Deployment & Getting Started

1. Clone the repository into your ABAP package using **abapGit** in Eclipse ADT.
2. Activate all project objects (**Ctrl + Shift + F3**).
3. Run the setup class `ZCL_MERP_INITIAL_SETUP` as an ABAP Application (`F9`) to generate initial test master data (`1000`, `2000`).
4. Publish/open the Service Binding `ZUI_MERP_O4` and launch the **Fiori Elements Preview**.
