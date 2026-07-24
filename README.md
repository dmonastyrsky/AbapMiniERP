# Mini ERP — Core Master Data Management (SAP RAP)

![SAP S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA%20Cloud-008FD3?style=flat&logo=sap)
![ABAP Cloud](https://img.shields.io/badge/Language-ABAP%20Cloud-blue?style=flat)
![RAP Framework](https://img.shields.io/badge/Framework-SAP%20RAP%20(Strict%202)-green?style=flat)
![OData V4](https://img.shields.io/badge/Protocol-OData%20V4-orange?style=flat)

Source code and architecture specification for the core Master Data business objects (**Company Code** and **Warehouse**) within the **Mini ERP** demonstration project. The solution is built in accordance with Clean Core principles and the SAP RESTful Application Programming Model (RAP) architecture, featuring full Draft enablement and OData V4 UI service endpoints.

---

## 📐 Architecture & Project Components

The business objects are developed following a strict layered architecture (`strict ( 2 )`):

### 1. Database & Dictionary Layer
* **`ZMERP_COMP_CODE`**: Primary transparent table for Company Code master data.
* **`ZMERP_COMP_D`**: Draft table for Company Code with `SYCH_BDL_DRAFT_ADMIN_INC`.
* **`ZMERP_WAREHOUSE`**: Primary transparent table for Warehouse master data.
* **`ZMERP_WHSE_D`**: Draft table for Warehouse data.
* **`ZMERP_S_ADMIN`**: Reusable administrative fields structure (`created_by`, `created_at`, `local_last_changed_by`, `local_last_changed_at`, `last_changed_at`).

### 2. Data & Presentation Layer (CDS Views & UI)
* **Company Code Entities**:
  * `ZMERP_R_COMPANY_CODE`: Root View Entity with associations to `I_Currency` and `I_Country`.
  * `ZMERP_C_COMPANY_CODE`: Projection View for transactional queries and UI binding.
  * Metadata Extension: UI annotations with facet references and field groups.
* **Warehouse Entities**:
  * `ZMERP_R_WAREHOUSE`: Root View Entity featuring association `_CompanyCode` to `ZMERP_R_COMPANY_CODE` with `@Consumption.valueHelpDefinition` and `useForValidation: true`.
  * `ZMERP_C_WAREHOUSE`: Projection View configured with Fuzzy Search (`@Search.fuzzinessThreshold: 0.7`) and text element linking (`@ObjectModel.text.element`).
  * Metadata Extension: UI annotations including `@UI.headerInfo` and `@UI.textArrangement: #TEXT_FIRST` to display Company Name alongside the code (e.g., `MERP Trading GmbH (2000)`).

### 3. Business Logic & Behavior Layer
* **Behavior Definitions (Root & Projection)**:
  * Declaration of CRUD operations, ETag master definitions (`LocalLastChangedAt`), draft capabilities (`Edit`, `Activate`, `Discard`, `Resume`, `Prepare`), and mapping rules.
* **Behavior Handlers**:
  * `ZBP_MERP_R_COMPANY_CODE` / `LHC_ZMERP_R_COMPANY_CODE`: EML handling, mandatory fields, and primary key validation for Company Code.
  * `ZBP_MERP_R_WAREHOUSE` / `LHC_ZMERP_R_WAREHOUSE`: Field validations (`validateMandatoryFields`, `validateWarehouseCode`) and state area message mappings for Warehouse.

### 4. Infrastructure & Helper Classes
* **Access Control (DCL)**:
  * `ZMERP_R_COMPANY_CODE` / `ZMERP_C_COMPANY_CODE`: DCL roles with condition inheritance.
  * `ZMERP_R_WAREHOUSE` / `ZMERP_C_WAREHOUSE`: DCL roles for Warehouse data access control.
* **`ZUI_MERP` (Service Definition)**: Single UI service contract exposing both `CompanyCode` and `Warehouse` entities for OData V4 Fiori Elements.
* **`ZCM_MERP_MESSAGES`**: Unified message class wrapper implementing `IF_T100_DYN_MSG` and `IF_ABAP_BEHV_MESSAGE` mapped to message class `ZMC_MERP`.
* **`ZCL_MERP_INITIAL_SETUP`**: Executable setup class (`IF_OO_ADT_CLASSRUN`) for populating initial demo datasets for companies and warehouses.

---

## ✨ Key Technical Features

* **Strict Mode (2) Compliance**: Fully compliant with modern SAP S/4HANA Clean Core architecture standards.
* **Optimized OData V4 Validations**: Leverages `useForValidation: true` on foreign keys to eliminate unnecessary SQL validation queries in ABAP code.
* **User-Friendly Text Arrangement**: Configured `@UI.textArrangement: #TEXT_FIRST` on relational fields to display entity descriptions with technical keys in parentheses without duplicating list columns.
* **Safe Key Validation**: Uniqueness checks trigger strictly `on save { create; }`, avoiding self-referential lockouts during draft updates.
* **Fuzzy Search Capabilities**: Search configured on text fields (`WarehouseName`, `CompanyName`) to handle typographical variations in UI filters.
* **State Area Messaging**: Precise state area target routing (`%state_area`, `%element`) for dynamic field highlighting in SAP Fiori Elements.

---

## 🚀 Deployment & Getting Started

1. Clone the repository into your ABAP package using **abapGit** in Eclipse ADT.
2. Activate all project objects (**Ctrl + Shift + F3**).
3. Run the setup class `ZCL_MERP_INITIAL_SETUP` as an ABAP Application (`F9`) to generate initial test master data.
4. Publish/open the Service Binding `ZUI_MERP_O4` and launch the **Fiori Elements Preview** for Company Code or Warehouse entities.
