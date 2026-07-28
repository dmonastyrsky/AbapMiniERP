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
      c_length_ig  TYPE i VALUE 5.

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

    "! Formats any input value with leading zeros to specified length.
    CLASS-METHODS add_leading_zeros
      IMPORTING
        iv_value       TYPE simple
        iv_length      TYPE i
      RETURNING
        VALUE(rv_code) TYPE string.

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

    "! Formats numeric sequence into target length string with optional prefix and padding.
    CLASS-METHODS format_number_with_padding
      IMPORTING
        iv_prefix       TYPE string
        iv_numeric      TYPE int8
        iv_total_length TYPE i
      RETURNING
        VALUE(rv_code) TYPE string.

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


  METHOD add_leading_zeros.
    rv_code = |{ iv_value WIDTH = iv_length PAD = '0' ALIGN = RIGHT }|.
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

    rv_number = format_number_with_padding(
      iv_prefix       = iv_prefix
      iv_numeric      = lv_max_numeric
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


  METHOD format_number_with_padding.
    DATA(lv_numeric_length) = iv_total_length - strlen( iv_prefix ).

    TRY.
        IF lv_numeric_length > 0
           AND iv_numeric >= ipow(
                 base = 10
                 exp  = lv_numeric_length ).
          RETURN.
        ENDIF.
      CATCH cx_sy_arithmetic_overflow.
        RETURN.
    ENDTRY.

    DATA(lv_padded) = COND string(
      WHEN lv_numeric_length > 0
      THEN add_leading_zeros(
             iv_value  = iv_numeric
             iv_length = lv_numeric_length )
      ELSE |{ iv_numeric }| ).

    rv_code = |{ iv_prefix }{ lv_padded }|.
  ENDMETHOD.

ENDCLASS.
