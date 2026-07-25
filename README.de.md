# Mini ERP — Core Master Data & Enterprise Engine (SAP RAP)

[English](README.md) | [Українська](README.uk.md) | [Deutsch](README.de.md)

![SAP S/4HANA](https://img.shields.io/badge/SAP-S%2F4HANA%20Cloud-008FD3?style=flat&logo=sap)
![ABAP Cloud](https://img.shields.io/badge/Language-ABAP%20Cloud-blue?style=flat)
![RAP Framework](https://img.shields.io/badge/Framework-SAP%20RAP%20(Strict%202)-green?style=flat)
![OData V4](https://img.shields.io/badge/Protocol-OData%20V4-orange?style=flat)

---

## 📌 Über das Projekt

**Mini ERP** ist ein Demonstrationsprojekt eines Kern-ERP-Systems, entwickelt auf Basis von **ABAP Cloud** und dem **SAP RESTful Application Programming Model (RAP)**.

Das Projekt demonstriert die moderne Anwendungsentwicklung nach **Clean Core**-Prinzipien mit vollständiger **Draft-Unterstützung** für eine gewohnte UX in SAP Fiori, Validierung der Geschäftslogik und Anbindung von **OData V4**-Diensten.

---

## 🏢 Stammdaten & Geschäftsobjekte (Master Data)

Das Repository umfasst derzeit die grundlegenden Stammdaten-Entitäten:

### 1. Company Code (Buchungskreis)
* **Zweck**: Verwaltung von juristischen Personen und Organisationsstrukturen des Unternehmens.
* **Funktionen**:
  * Verknüpfung mit Standard-CDS-Views (`I_Currency`, `I_Country`).
  * Validierung von Pflichtfeldern und Eindeutigkeit des Buchungskreiscodes.

### 2. Warehouse (Lagerverwaltung)
* **Zweck**: Verwaltung von Lagerorten mit Zuordnung zu Buchungskreisen.
* **Funktionen**:
  * Fremdschlüssel-Assoziation zum `Company Code` mit automatischer OData V4-Validierung (`useForValidation: true`).
  * Fiori Text Arrangement (`#TEXT_FIRST`) zur Anzeige von `Firmenname (Code)` in Tabellen und Objektseiten.
  * Mehrfeld-Suchfunktion mit aktivierter Unscharfer Suche (Fuzzy Search).

### 3. VAT Rate (Umsatzsteuersätze)
* **Zweck**: Verwaltung von Steuerkennzeichen und Steuersätzen für Finanzberechnungen im Verkauf und Einkauf.
* **Funktionen**:
  * Pflege von Steuerkennzeichen, Beschreibungen (`Standard Rate 19%`, `Reduced Rate 7%`, `Zero Rate 0%`) und Prozentsätzen.
  * Bereichsvalidierung des Steuersatzes (Werte zwischen `0,00` und `100,00 %`).
  * Prüfung auf Pflichtfelder und doppelte Schlüssel.

---

## 🗺 Roadmap

Geplante Module für zukünftige Erweiterungen:

* 📦 **Item Groups & Products/Services**: Warengruppen, Materialstammdaten und Dienstleistungen.
* 🤝 **Business Partners**: Kunden- und Lieferantenstammdaten.
* 🧾 **Sales & Purchase Documents**: Transaktionale Belegverarbeitung (Einkaufsbestellungen, Kundenaufträge, Rechnungen).

---

## 🛠 Technische Architektur & UX

* **RAP Strict Mode 2**: Einhaltung moderner Transaktionsstandards in SAP S/4HANA Cloud.
* **Full Draft Support**: Vollständige Entwurfsunterstützung für statusbehaftete Bearbeitung in SAP Fiori Elements.
* **State Area Messaging**: Feldbezogene Fehlermeldungen direkt an den UI-Steuerelementen (`%element`).
* **Automated Data Seed**: Zentrale Initialisierungsklasse (`ZCL_MERP_INITIAL_SETUP`) zum Befüllen von Testdaten.

---

## 🚀 Ausführung & Testen

1. Klonen Sie das Repository über **abapGit** in Eclipse ADT in Ihr ABAP-Paket.
2. Aktivieren Sie alle Projektobjekte (`Ctrl + Shift + F3`).
3. Führen Sie die Klasse `ZCL_MERP_INITIAL_SETUP` aus (`F9`), um Testdaten zu generieren.
4. Starten Sie die **Fiori Elements Preview** über das Service Binding `ZUI_MERP_O4`.
