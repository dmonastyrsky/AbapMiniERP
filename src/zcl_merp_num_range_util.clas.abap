CLASS zcl_merp_num_range_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS:
      c_prefix_vat TYPE string VALUE 'V',
      c_prefix_wh  TYPE string VALUE 'WH',
      c_prefix_ig  TYPE string VALUE '',

      c_length_vat TYPE i VALUE 4,
      c_length_wh  TYPE i VALUE 5,
      c_length_ig  TYPE i VALUE 5,

      c_nro_vat    TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_VAT',
      c_nro_wh     TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_WHSE',
      c_nro_ig     TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_IG'.

    "! Generates the next sequential VAT Code formatted for configured total length.
    CLASS-METHODS get_next_vat_code
      RETURNING
        VALUE(rv_vat_code) TYPE zmerp_vat_rate-vat_code.

    "! Generates the next sequential Warehouse ID formatted for configured total length.
    CLASS-METHODS get_next_warehouse_code
      RETURNING
        VALUE(rv_wh_id) TYPE zmerp_warehouse-warehouse_code.

    "! Generates the next sequential Item Group Code formatted for configured total length.
    CLASS-METHODS get_next_item_group_code
      RETURNING
        VALUE(rv_item_group_code) TYPE zmerp_item_group-item_group_code.

    "! Generates the next sequential VAT Code using NRO API.
    CLASS-METHODS get_next_vat_code_nro
      RETURNING
        VALUE(rv_vat_code) TYPE zmerp_vat_rate-vat_code.

    "! Generates the next sequential Warehouse ID using NRO API.
    CLASS-METHODS get_next_warehouse_code_nro
      RETURNING
        VALUE(rv_wh_id) TYPE zmerp_warehouse-warehouse_code.

    "! Generates the next sequential Item Group Code using NRO API.
    CLASS-METHODS get_next_item_group_code_nro
      RETURNING
        VALUE(rv_item_group_code) TYPE zmerp_item_group-item_group_code.

    "! Formats any input value with leading zeros to specified length.
    CLASS-METHODS add_leading_zeros
      IMPORTING
        iv_value       TYPE simple
        iv_length      TYPE i
      RETURNING
        VALUE(rv_code) TYPE string.

    "! Formats numeric sequence into target length string with optional prefix and padding.
    CLASS-METHODS format_code
      IMPORTING
        iv_number       TYPE simple
        iv_prefix       TYPE string
        iv_total_length TYPE i
      RETURNING
        VALUE(rv_code)  TYPE string.

    "! Convenience formatters for seeders, tests, and initial setup
    CLASS-METHODS format_vat_code       IMPORTING iv_number TYPE simple RETURNING VALUE(rv_code) TYPE string.
    CLASS-METHODS format_warehouse_code IMPORTING iv_number TYPE simple RETURNING VALUE(rv_code) TYPE string.
    CLASS-METHODS format_item_grp_code  IMPORTING iv_number TYPE simple RETURNING VALUE(rv_code) TYPE string.

    "! BTP ABAP Cloud: Initializes number range intervals in the target client
    CLASS-METHODS setup_intervals.

    "! Resets all NRO intervals back to zero status for initial setup/seeding
    CLASS-METHODS reset_intervals.

    "! Synchronizes NRO interval levels with actual active DB record counts
    CLASS-METHODS sync_intervals_from_db.

  PRIVATE SECTION.

    "! Generic sequential number generator based on the max existing key in active and draft tables.
    CLASS-METHODS get_next_number
      IMPORTING
        iv_prefix       TYPE string
        iv_table        TYPE string
        iv_field        TYPE string
        iv_draft_table  TYPE string OPTIONAL
        iv_draft_field  TYPE string OPTIONAL
        iv_total_length TYPE i DEFAULT 10
      RETURNING
        VALUE(rv_number) TYPE string.

    "! Retrieves the single highest code from DB by prefix in descending order.
    CLASS-METHODS get_max_code_from_db
      IMPORTING
        iv_table  TYPE string
        iv_field  TYPE string
        iv_prefix TYPE string
      RETURNING
        VALUE(rv_code) TYPE string.

    "! Safely parses numeric suffix after prefix offset.
    CLASS-METHODS extract_numeric_suffix
      IMPORTING
        iv_code   TYPE string
        iv_offset TYPE i
      RETURNING
        VALUE(rv_numeric) TYPE int8.

    "! Generic number generator wrapping Standard SAP Number Range Runtime API
    CLASS-METHODS get_next_number_from_nro
      IMPORTING
        iv_nro_object   TYPE cl_numberrange_runtime=>nr_object
        iv_prefix       TYPE string
        iv_total_length TYPE i
      RETURNING
        VALUE(rv_code)  TYPE string.

ENDCLASS.



CLASS zcl_merp_num_range_util IMPLEMENTATION.

  METHOD get_next_vat_code.
    rv_vat_code = get_next_number(
      iv_prefix       = c_prefix_vat
      iv_table        = 'ZMERP_VAT_RATE'
      iv_field        = 'VAT_CODE'
      iv_draft_table  = 'ZMERP_VATR_D'
      iv_draft_field  = 'VATCODE'
      iv_total_length = c_length_vat ).
  ENDMETHOD.


  METHOD get_next_warehouse_code.
    rv_wh_id = get_next_number(
      iv_prefix       = c_prefix_wh
      iv_table        = 'ZMERP_WAREHOUSE'
      iv_field        = 'WAREHOUSE_CODE'
      iv_draft_table  = 'ZMERP_WHSE_D'
      iv_draft_field  = 'WAREHOUSECODE'
      iv_total_length = c_length_wh ).
  ENDMETHOD.


  METHOD get_next_item_group_code.
    rv_item_group_code = get_next_number(
      iv_prefix       = c_prefix_ig
      iv_table        = 'ZMERP_ITEM_GROUP'
      iv_field        = 'ITEM_GROUP_CODE'
      iv_draft_table  = 'ZMERP_ITEM_GRP_D'
      iv_draft_field  = 'ITEMGROUPCODE'
      iv_total_length = c_length_ig ).
  ENDMETHOD.


  METHOD get_next_vat_code_nro.
    rv_vat_code = get_next_number_from_nro(
      iv_nro_object   = c_nro_vat
      iv_prefix       = c_prefix_vat
      iv_total_length = c_length_vat ).
  ENDMETHOD.


  METHOD get_next_warehouse_code_nro.
    rv_wh_id = get_next_number_from_nro(
      iv_nro_object   = c_nro_wh
      iv_prefix       = c_prefix_wh
      iv_total_length = c_length_wh ).
  ENDMETHOD.


  METHOD get_next_item_group_code_nro.
    rv_item_group_code = get_next_number_from_nro(
      iv_nro_object   = c_nro_ig
      iv_prefix       = c_prefix_ig
      iv_total_length = c_length_ig ).
  ENDMETHOD.


  METHOD add_leading_zeros.
    rv_code = |{ iv_value WIDTH = iv_length PAD = '0' ALIGN = RIGHT }|.
  ENDMETHOD.


  METHOD format_code.
    DATA(lv_numeric_length) = iv_total_length - strlen( iv_prefix ).

    TRY.
        IF lv_numeric_length > 0
           AND CONV int8( iv_number ) >= ipow(
                 base = 10
                 exp  = lv_numeric_length ).
          RETURN.
        ENDIF.
      CATCH cx_sy_arithmetic_overflow cx_sy_conversion_error.
        RETURN.
    ENDTRY.

    DATA(lv_padded) = COND string(
      WHEN lv_numeric_length > 0
      THEN add_leading_zeros(
             iv_value  = iv_number
             iv_length = lv_numeric_length )
      ELSE |{ iv_number }| ).

    rv_code = |{ iv_prefix }{ lv_padded }|.
  ENDMETHOD.


  METHOD format_vat_code.
    rv_code = format_code(
      iv_number       = iv_number
      iv_prefix       = c_prefix_vat
      iv_total_length = c_length_vat ).
  ENDMETHOD.


  METHOD format_warehouse_code.
    rv_code = format_code(
      iv_number       = iv_number
      iv_prefix       = c_prefix_wh
      iv_total_length = c_length_wh ).
  ENDMETHOD.


  METHOD format_item_grp_code.
    rv_code = format_code(
      iv_number       = iv_number
      iv_prefix       = c_prefix_ig
      iv_total_length = c_length_ig ).
  ENDMETHOD.


  METHOD get_next_number.
    DATA(lv_prefix_length) = strlen( iv_prefix ).

    DATA(lv_max_active) = get_max_code_from_db(
      iv_table  = iv_table
      iv_field  = iv_field
      iv_prefix = iv_prefix ).

    DATA(lv_max_draft) = COND string(
      WHEN iv_draft_table IS NOT INITIAL
       AND iv_draft_field IS NOT INITIAL
      THEN get_max_code_from_db(
             iv_table  = iv_draft_table
             iv_field  = iv_draft_field
             iv_prefix = iv_prefix ) ).

    DATA(lv_max_numeric) = nmax(
      val1 = extract_numeric_suffix(
               iv_code   = lv_max_active
               iv_offset = lv_prefix_length )
      val2 = extract_numeric_suffix(
               iv_code   = lv_max_draft
               iv_offset = lv_prefix_length ) ).

    lv_max_numeric += 1.

    rv_number = format_code(
      iv_prefix       = iv_prefix
      iv_number       = lv_max_numeric
      iv_total_length = iv_total_length ).
  ENDMETHOD.


  METHOD get_max_code_from_db.
    DATA: BEGIN OF ls_result,
            val TYPE string,
          END OF ls_result.

    TRY.
        DATA(lv_where) = |{ iv_field } LIKE '{ iv_prefix }%'|.
        DATA(lv_order) = |{ iv_field } DESCENDING|.

        SELECT (iv_field)
          FROM (iv_table)
          WHERE (lv_where)
          ORDER BY (lv_order)
          INTO @ls_result
          UP TO 1 ROWS.
        ENDSELECT.

        rv_code = ls_result-val.

      CATCH cx_sy_dynamic_osql_error.
        CLEAR rv_code.
    ENDTRY.
  ENDMETHOD.


  METHOD extract_numeric_suffix.
    IF iv_code IS INITIAL OR strlen( iv_code ) <= iv_offset.
      RETURN.
    ENDIF.

    DATA(lv_num_part) = substring(
      val = iv_code
      off = iv_offset ).

    IF lv_num_part CO '0123456789'.
      TRY.
          rv_numeric = CONV int8( lv_num_part ).
        CATCH cx_sy_conversion_error cx_sy_arithmetic_overflow.
          CLEAR rv_numeric.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD get_next_number_from_nro.
    DATA: lv_raw_number TYPE cl_numberrange_runtime=>nr_number.

    TRY.
        " Fetch the next sequential number from the respective Number Range Object
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr = '01'
            object      = iv_nro_object
          IMPORTING
            number      = lv_raw_number ).

        " Format the raw number with prefix and padding
        rv_code = format_code(
          iv_number       = CONV int8( lv_raw_number )
          iv_prefix       = iv_prefix
          iv_total_length = iv_total_length ).

      CATCH cx_number_ranges.
        CLEAR rv_code.
    ENDTRY.
  ENDMETHOD.


  METHOD setup_intervals.
    DATA: lt_interval TYPE TABLE OF cl_numberrange_intervals=>nr_nriv_line,
          ls_interval LIKE LINE OF lt_interval,
          lv_error    TYPE cl_numberrange_intervals=>nr_error,
          ls_error    TYPE cl_numberrange_intervals=>nr_error_inf.

    ls_interval-nrrangenr  = '01'.
    ls_interval-fromnumber = '0000000001'.
    ls_interval-tonumber   = '9999999999'.
    APPEND ls_interval TO lt_interval.

    " List all distinct Number Range Objects to initialize intervals for each
    DATA(lt_objects) = VALUE string_table(
      ( CONV string( c_nro_vat ) )
      ( CONV string( c_nro_wh ) )
      ( CONV string( c_nro_ig ) )
    ).

    LOOP AT lt_objects INTO DATA(lv_object).
      TRY.
          cl_numberrange_intervals=>create(
            EXPORTING
              object    = CONV #( lv_object )
              interval  = lt_interval
            IMPORTING
              error     = lv_error
              error_inf = ls_error ).
        CATCH cx_number_ranges.
          " Ignore exception if interval '01' already exists for this object
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD reset_intervals.
    DATA: lt_interval TYPE TABLE OF cl_numberrange_intervals=>nr_nriv_line,
          ls_interval LIKE LINE OF lt_interval,
          lv_error    TYPE cl_numberrange_intervals=>nr_error,
          ls_error    TYPE cl_numberrange_intervals=>nr_error_inf.

    ls_interval-nrrangenr  = '01'.
    ls_interval-fromnumber = '0000000001'.
    ls_interval-tonumber   = '9999999999'.
    ls_interval-nrlevel    = '0000000000'. " Reset current number status to 0
    APPEND ls_interval TO lt_interval.

    " List all distinct Number Range Objects
    DATA(lt_objects) = VALUE string_table(
      ( CONV string( c_nro_vat ) )
      ( CONV string( c_nro_wh ) )
      ( CONV string( c_nro_ig ) )
    ).

    LOOP AT lt_objects INTO DATA(lv_object).
      TRY.
          " Try updating existing interval level to 0
          cl_numberrange_intervals=>update(
            EXPORTING
              object    = CONV #( lv_object )
              interval  = lt_interval
            IMPORTING
              error     = lv_error
              error_inf = ls_error ).
        CATCH cx_number_ranges.
          TRY.
              " If interval '01' doesn't exist yet, create it
              cl_numberrange_intervals=>create(
                EXPORTING
                  object    = CONV #( lv_object )
                  interval  = lt_interval
                IMPORTING
                  error     = lv_error
                  error_inf = ls_error ).
            CATCH cx_number_ranges.
              " Ignore creation error
          ENDTRY.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD sync_intervals_from_db.
    DATA: lt_interval TYPE TABLE OF cl_numberrange_intervals=>nr_nriv_line,
          ls_interval LIKE LINE OF lt_interval,
          lv_error    TYPE cl_numberrange_intervals=>nr_error,
          ls_error    TYPE cl_numberrange_intervals=>nr_error_inf.

    SELECT COUNT( * ) FROM zmerp_vat_rate INTO @DATA(lv_vat_count).
    SELECT COUNT( * ) FROM zmerp_warehouse INTO @DATA(lv_wh_count).
    SELECT COUNT( * ) FROM zmerp_item_group INTO @DATA(lv_ig_count).

    TYPES: BEGIN OF ty_nro_sync,
             object TYPE cl_numberrange_intervals=>nr_object,
             count  TYPE i,
           END OF ty_nro_sync.

    TYPES: ty_nro_sync_tt TYPE STANDARD TABLE OF ty_nro_sync WITH EMPTY KEY.

    DATA(lt_sync) = VALUE ty_nro_sync_tt(
      ( object = c_nro_vat count = lv_vat_count )
      ( object = c_nro_wh  count = lv_wh_count )
      ( object = c_nro_ig  count = lv_ig_count )
    ).

    LOOP AT lt_sync INTO DATA(ls_sync).
      CLEAR: lt_interval, ls_interval.

      ls_interval-nrrangenr  = '01'.
      ls_interval-fromnumber = '0000000001'.
      ls_interval-tonumber   = '9999999999'.
      ls_interval-nrlevel    = CONV #( ls_sync-count ).
      APPEND ls_interval TO lt_interval.

      TRY.
          cl_numberrange_intervals=>update(
            EXPORTING
              object    = CONV #( ls_sync-object )
              interval  = lt_interval
            IMPORTING
              error     = lv_error
              error_inf = ls_error ).
        CATCH cx_number_ranges.
          TRY.
              cl_numberrange_intervals=>create(
                EXPORTING
                  object    = CONV #( ls_sync-object )
                  interval  = lt_interval
                IMPORTING
                  error     = lv_error
                  error_inf = ls_error ).
            CATCH cx_number_ranges.
          ENDTRY.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
