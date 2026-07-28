CLASS zcl_merp_initial_setup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

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

    CLASS-METHODS setup_vat_rates
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out OPTIONAL .

    CLASS-METHODS setup_item_groups
      IMPORTING
        out TYPE REF TO if_oo_adt_classrun_out OPTIONAL .

ENDCLASS.



CLASS zcl_merp_initial_setup IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    execute( out ).
  ENDMETHOD.


  METHOD execute.
    IF out IS BOUND.
      out->write( '==================================================' ).
      out->write( '  Starting Mini ERP Initial Setup Process         ' ).
      out->write( '==================================================' ).
    ENDIF.

    " Insert seed data using formatted keys
    setup_company_codes( out ).
    setup_vat_rates( out ).
    setup_warehouses( out ).
    setup_item_groups( out ).

    " Dynamically sync NRO levels with real DB record counts
    zcl_merp_num_range_util=>sync_intervals_from_db( ).

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

    TRY.
        lv_user = cl_abap_context_info=>get_user_technical_name( ).
      CATCH cx_abap_context_info_error.
        lv_user = 'INITIAL_SETUP'.
    ENDTRY.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear active and draft tables
    DELETE FROM zmerp_comp_code.

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

    INSERT zmerp_comp_code FROM TABLE @lt_comp_code.

    IF out IS BOUND.
      out->write( |[Company Code]: Successfully inserted { sy-dbcnt } rows.| ).
    ENDIF.
  ENDMETHOD.


  METHOD setup_vat_rates.
    DATA: lt_vat_rates TYPE TABLE OF zmerp_vat_rate,
          lv_user      TYPE abp_creation_user,
          lv_timestamp TYPE abp_creation_tstmpl.

    TRY.
        lv_user = cl_abap_context_info=>get_user_technical_name( ).
      CATCH cx_abap_context_info_error.
        lv_user = 'INITIAL_SETUP'.
    ENDTRY.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear active and draft tables
    DELETE FROM zmerp_vat_rate.
    DELETE FROM zmerp_vatr_d.

    lt_vat_rates = VALUE #(
      ( vat_code              = zcl_merp_num_range_util=>format_vat_code( 1 )
        description           = 'VAT 0%'
        percentage            = '0.00'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( vat_code              = zcl_merp_num_range_util=>format_vat_code( 2 )
        description           = 'VAT 7%'
        percentage            = '7.00'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( vat_code              = zcl_merp_num_range_util=>format_vat_code( 3 )
        description           = 'VAT 19%'
        percentage            = '19.00'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp )
    ).

    INSERT zmerp_vat_rate FROM TABLE @lt_vat_rates.

    IF out IS BOUND.
      out->write( |[VAT Rate]: Successfully inserted { sy-dbcnt } rows.| ).
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

    " Clear active and draft tables
    DELETE FROM zmerp_warehouse.
    DELETE FROM zmerp_whse_d.

    lt_warehouses = VALUE #(
      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 1 )
        warehouse_name        = 'Hauptlager Kusel'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 2 )
        warehouse_name        = 'Hauptlager Frankfurt'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 3 )
        warehouse_name        = 'Lager Berlin'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 4 )
        warehouse_name        = 'Retourlager Frankfurt'
        company_code          = '1000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 5 )
        warehouse_name        = 'Hauptlager Hamburg'
        company_code          = '2000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 6 )
        warehouse_name        = 'Lager München'
        company_code          = '2000'
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( warehouse_code        = zcl_merp_num_range_util=>format_warehouse_code( 7 )
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


  METHOD setup_item_groups.
    DATA: lt_item_groups TYPE TABLE OF zmerp_item_group,
          lv_user        TYPE abp_creation_user,
          lv_timestamp   TYPE abp_creation_tstmpl.

    TRY.
        lv_user = cl_abap_context_info=>get_user_technical_name( ).
      CATCH cx_abap_context_info_error.
        lv_user = 'INITIAL_SETUP'.
    ENDTRY.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear active and draft tables
    DELETE FROM zmerp_item_group.
    DELETE FROM zmerp_item_grp_d.

    DATA(lv_vat19) = zcl_merp_num_range_util=>format_vat_code( 3 ).

    lt_item_groups = VALUE #(
      ( item_group_code       = zcl_merp_num_range_util=>format_item_grp_code( 1 )
        description           = 'Major Home Appliances'
        default_vat_code      = lv_vat19
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( item_group_code       = zcl_merp_num_range_util=>format_item_grp_code( 2 )
        description           = 'Small Kitchen Appliances'
        default_vat_code      = lv_vat19
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( item_group_code       = zcl_merp_num_range_util=>format_item_grp_code( 3 )
        description           = 'Consumer Electronics'
        default_vat_code      = lv_vat19
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( item_group_code       = zcl_merp_num_range_util=>format_item_grp_code( 4 )
        description           = 'Accessories & Supplies'
        default_vat_code      = lv_vat19
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )

      ( item_group_code       = zcl_merp_num_range_util=>format_item_grp_code( 5 )
        description           = 'Installation & Support Services'
        default_vat_code      = lv_vat19
        created_by            = lv_user
        created_at            = lv_timestamp
        local_last_changed_by = lv_user
        local_last_changed_at = lv_timestamp
        last_changed_at       = lv_timestamp )
    ).

    INSERT zmerp_item_group FROM TABLE @lt_item_groups.

    IF out IS BOUND.
      out->write( |[Item Group]: Successfully inserted { sy-dbcnt } rows.| ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
