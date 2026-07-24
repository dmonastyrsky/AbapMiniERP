# Mini ERP — Core Master Data (SAP RAP)

![SAP S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA%20Cloud-008FD3?style=flat&logo=sap)
![ABAP Cloud](https://img.shields.io/badge/Language-ABAP%20Cloud-blue?style=flat)
![RAP Framework](https://img.shields.io/badge/Framework-SAP%20RAP%20(Strict%202)-green?style=flat)
![OData V4](https://img.shields.io/badge/Protocol-OData%20V4-orange?style=flat)

Modular **Mini ERP** demonstration project built on ABAP Cloud and the **SAP RESTful Application Programming Model (RAP)**. The project showcases Clean Core architecture, transactional processing with full Draft capabilities, and OData V4 Fiori Elements integration.

---

## 🏢 Business Objects

The system currently manages core enterprise master data:

* **Company Code (Балансова одиниця)**
  * Master data management with standard text associations (`I_Currency`, `I_Country`).
  * Custom validations for mandatory fields and code uniqueness.
* **Warehouse (Склад)**
  * Foreign key association to Company Code with automated OData V4 validation.
  * Fiori Elements Text Arrangement (`#TEXT_FIRST`) displaying `Company Name (Code)`.
  * Multi-field search capabilities (Fuzzy Search threshold enabled).

---

## 🛠 Technical Highlights & Architecture

* **RAP Strict Mode 2**: Developed following modern S/4HANA transactional standards.
* **Draft Enablement**: Full draft support across all business objects for seamless stateful UI processing in SAP Fiori.
* **Clean Core & OData V4**: Built with `@Consumption.valueHelpDefinition` and `useForValidation: true` to leverage built-in framework checks instead of redundant SQL queries.
* **User Experience (UX)**: State area error messaging mapped directly to UI input fields.

---

## 🚀 How to Run

1. Clone the repository into your ABAP package using **abapGit** in Eclipse ADT.
2. Activate all project objects (`Ctrl + Shift + F3`).
3. Execute class `ZCL_MERP_INITIAL_SETUP` (`F9`) to generate initial demo datasets.
4. Launch the **Fiori Elements Preview** via Service Binding `ZUI_MERP_O4`.
