CLASS zcl_merp_md_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_company_codes TYPE SORTED TABLE OF zmerp_company_code WITH UNIQUE KEY table_line.

    "! Retrieves the default VAT code for a specific Item Group
    CLASS-METHODS get_item_group_default_vat
      IMPORTING
        iv_item_group_code TYPE zmerp_item_group_code
      RETURNING
        VALUE(rv_vat_code) TYPE zmerp_vat_code.

    "! Validates existence of company codes and returns invalid entries
    CLASS-METHODS validate_companies
      IMPORTING
        it_company_codes        TYPE tt_company_codes
      RETURNING
        VALUE(rt_invalid_codes) TYPE tt_company_codes.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_merp_md_util IMPLEMENTATION.

  METHOD get_item_group_default_vat.
    IF iv_item_group_code IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE default_vat_code
      FROM zmerp_item_group
      WHERE item_group_code = @iv_item_group_code
      INTO @rv_vat_code.
  ENDMETHOD.

  METHOD validate_companies.
    IF it_company_codes IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_existing_db TYPE tt_company_codes.

    " Direct batch selection from CDS Root Entity into sorted table type
    SELECT CompanyCode
      FROM ZMERP_R_COMPANY_CODE
      FOR ALL ENTRIES IN @it_company_codes
      WHERE CompanyCode = @it_company_codes-table_line
      INTO TABLE @lt_existing_db.

    " Collect missing codes
    LOOP AT it_company_codes INTO DATA(lv_code).
      IF NOT line_exists( lt_existing_db[ table_line = lv_code ] ).
        INSERT lv_code INTO TABLE rt_invalid_codes.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
