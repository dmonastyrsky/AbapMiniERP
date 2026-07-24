CLASS zcl_merp_initial_setup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    " Main entry point for initial setup execution
    CLASS-METHODS execute
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out OPTIONAL .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS setup_company_codes
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out OPTIONAL .

    CLASS-METHODS setup_warehouses
    IMPORTING
      out TYPE REF TO if_oo_adt_classrun_out OPTIONAL .

ENDCLASS.

CLASS zcl_merp_initial_setup IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Delegate execution from ADT console runner to the static EXECUTE method
    execute( out ).
  ENDMETHOD.

  METHOD execute.
    IF out IS BOUND.
      out->write( '==================================================' ).
      out->write( '  Starting Mini ERP Initial Setup Process         ' ).
      out->write( '==================================================' ).
    ENDIF.

    " Setup Master Data entities
    setup_company_codes( out ).
    setup_warehouses( out ).

    " Future modules described in File 08 will be integrated here:
    " setup_vat_rates( out ).
    " setup_item_groups( out ).
    " setup_product_items( out ).
    " setup_service_items( out ).
    " setup_business_partners( out ).
    " setup_purchase_documents( out ).
    " setup_sales_documents( out ).

    IF out IS BOUND.
      out->write( '==================================================' ).
      out->write( '  Initial Setup Completed Successfully!            ' ).
      out->write( '==================================================' ).
    ENDIF.
  ENDMETHOD.

  METHOD setup_company_codes.
    DATA: lt_comp_code TYPE TABLE OF zmerp_comp_code,
          lv_user      TYPE abp_creation_user,
          lv_timestamp TYPE abp_creation_tstmpl.

    " Get user technical name using ABAP Cloud API
    TRY.
        lv_user = cl_abap_context_info=>get_user_technical_name( ).
      CATCH cx_abap_context_info_error.
        lv_user = 'INITIAL_SETUP'.
    ENDTRY.

    " Get current UTC timestamp
    GET TIME STAMP FIELD lv_timestamp.

    " Delete existing data to ensure deterministic execution
    DELETE FROM zmerp_comp_code.

    " Populate Company Codes strictly following File 08 specification
    lt_comp_code = VALUE #(
      ( company_code          = '1000'
        company_name          = 'MERP Deutschland GmbH'
        currency_code         = 'EUR'
        country               = 'DE'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( company_code          = '2000'
        company_name          = 'MERP Trading GmbH'
        currency_code         = 'EUR'
        country               = 'DE'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )
    ).

    " Insert demonstration master data
    INSERT zmerp_comp_code FROM TABLE @lt_comp_code.

    IF out IS BOUND.
      out->write( |[Company Code]: Successfully inserted { sy-dbcnt } rows.| ).
    ENDIF.
  ENDMETHOD.

  METHOD setup_warehouses.
    DATA: lt_warehouses TYPE TABLE OF zmerp_warehouse,
          lv_user       TYPE abp_creation_user,
          lv_timestamp  TYPE abp_creation_tstmpl.

    TRY.
        lv_user = cl_abap_context_info=>get_user_technical_name( ).
      CATCH cx_abap_context_info_error.
        lv_user = 'INITIAL_SETUP'.
    ENDTRY.

    GET TIME STAMP FIELD lv_timestamp.

    DELETE FROM zmerp_warehouse.

    lt_warehouses = VALUE #(
      " Company Code 1000 - MERP Deutschland GmbH
      ( warehouse_code        = 'WH10'
        warehouse_name        = 'Hauptlager Frankfurt'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = 'WH11'
        warehouse_name        = 'Lager Berlin'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = 'WH12'
        warehouse_name        = 'Retourlager Frankfurt'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      " Company Code 2000 - MERP Trading GmbH
      ( warehouse_code        = 'WH20'
        warehouse_name        = 'Hauptlager Hamburg'
        company_code          = '2000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = 'WH21'
        warehouse_name        = 'Lager München'
        company_code          = '2000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = 'WH22'
        warehouse_name        = 'Transitlager Hamburg'
        company_code          = '2000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )
    ).

    INSERT zmerp_warehouse FROM TABLE @lt_warehouses.

    IF out IS BOUND.
      out->write( |[Warehouse]: Successfully inserted { sy-dbcnt } rows.| ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
