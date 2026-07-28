CLASS zcl_merp_md_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_prefix_vat TYPE string VALUE 'V'.
    CONSTANTS c_prefix_wh  TYPE string VALUE 'WH'.

    "! Generates the next sequential VAT Code (e.g., V01, V02, V03).
    CLASS-METHODS get_next_vat_code
      RETURNING
        VALUE(rv_vat_code) TYPE zmerp_vat_rate-vat_code.

    "! Generates the next sequential Warehouse ID (e.g., WH001, WH002, WH003).
    CLASS-METHODS get_next_warehouse_code
      RETURNING
        VALUE(rv_wh_id) TYPE zmerp_warehouse-warehouse_code.

    "! Generates the next sequential Item Group Code (e.g., 00001, 00002, 00003).
    CLASS-METHODS get_next_item_group_code
      RETURNING
        VALUE(rv_item_group) TYPE zmerp_item_group-item_group.

  PRIVATE SECTION.
    "! Generic sequential number generator based on existing keys in active and draft tables.
    CLASS-METHODS get_next_number
      IMPORTING
        iv_prefix        TYPE string
        iv_table         TYPE string
        iv_field         TYPE string
        iv_draft_table   TYPE string OPTIONAL
        iv_draft_field   TYPE string OPTIONAL
        iv_length        TYPE i OPTIONAL
      RETURNING
        VALUE(rv_number) TYPE string.
ENDCLASS.

CLASS zcl_merp_md_util IMPLEMENTATION.

  METHOD get_next_vat_code.
    rv_vat_code = get_next_number(
      iv_prefix      = c_prefix_vat
      iv_table       = 'ZMERP_VAT_RATE'
      iv_field       = 'VAT_CODE'
      iv_draft_table = 'ZMERP_VATR_D'
      iv_draft_field = 'VATCODE'
      iv_length      = 3
    ).
  ENDMETHOD.

  METHOD get_next_warehouse_code.
    rv_wh_id = get_next_number(
      iv_prefix      = c_prefix_wh
      iv_table       = 'ZMERP_WAREHOUSE'
      iv_field       = 'WAREHOUSE_CODE'
      iv_draft_table = 'ZMERP_WHSE_D'
      iv_draft_field = 'WAREHOUSECODE'
      iv_length      = 5
    ).
  ENDMETHOD.

  METHOD get_next_item_group_code.
    rv_item_group = get_next_number(
      iv_prefix      = ''
      iv_table       = 'ZMERP_ITEM_GROUP'
      iv_field       = 'ITEM_GROUP'
      iv_draft_table = 'ZMERP_ITEM_GRP_D'
      iv_draft_field = 'ITEMGROUP'
      iv_length      = 5
    ).
  ENDMETHOD.

  METHOD get_next_number.
    DATA: lt_active_codes TYPE TABLE OF string,
          lt_draft_codes  TYPE TABLE OF string,
          lv_offset       TYPE i,
          lv_exists       TYPE abap_bool,
          lv_max_numeric  TYPE int8 VALUE 0.

    TRY.
        lv_offset = strlen( iv_prefix ).
        DATA(lv_where_clause) = |{ iv_field } LIKE '{ iv_prefix }%'|.

        " 1. Read all existing keys for this prefix into internal tables
        SELECT (iv_field)
          FROM (iv_table)
          WHERE (lv_where_clause)
          INTO TABLE @lt_active_codes.

        IF iv_draft_table IS NOT INITIAL AND iv_draft_field IS NOT INITIAL.
          DATA(lv_where_clause_d) = |{ iv_draft_field } LIKE '{ iv_prefix }%'|.
          SELECT (iv_draft_field)
            FROM (iv_draft_table)
            WHERE (lv_where_clause_d)
            INTO TABLE @lt_draft_codes.
        ENDIF.

        " 2. Process active codes (with length validation check)
        LOOP AT lt_active_codes REFERENCE INTO DATA(lr_code).
          IF strlen( lr_code->* ) > lv_offset.
            DATA(lv_num_part) = substring( val = lr_code->* off = lv_offset ).
            IF lv_num_part CO '0123456789'.
              DATA(lv_num_val) = CONV int8( lv_num_part ).
              IF lv_num_val > lv_max_numeric.
                lv_max_numeric = lv_num_val.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        " 3. Process draft codes (with length validation check)
        LOOP AT lt_draft_codes REFERENCE INTO DATA(lr_code_d).
          IF strlen( lr_code_d->* ) > lv_offset.
            DATA(lv_num_part_d) = substring( val = lr_code_d->* off = lv_offset ).
            IF lv_num_part_d CO '0123456789'.
              DATA(lv_num_val_d) = CONV int8( lv_num_part_d ).
              IF lv_num_val_d > lv_max_numeric.
                lv_max_numeric = lv_num_val_d.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

        " 4. Increment to get the next number
        lv_max_numeric += 1.

        " 5. Calculate length and pad safely
        DATA(lv_numeric_length) = nmax( val1 = 0 val2 = iv_length - strlen( iv_prefix ) ).
        DATA(lv_padded) = COND string(
          WHEN lv_numeric_length > 0
          THEN |{ lv_max_numeric WIDTH = lv_numeric_length PAD = '0' ALIGN = RIGHT }|
          ELSE |{ lv_max_numeric }|
        ).

        rv_number = |{ iv_prefix }{ lv_padded }|.

        " 6. Pre-existence check (Failsafe against race conditions)
        DATA(lv_exists_where) = |{ iv_field } = '{ rv_number }'|.
        SELECT SINGLE @abap_true
          FROM (iv_table)
          WHERE (lv_exists_where)
          INTO @lv_exists.

        IF lv_exists = abap_false AND iv_draft_table IS NOT INITIAL AND iv_draft_field IS NOT INITIAL.
          DATA(lv_exists_where_d) = |{ iv_draft_field } = '{ rv_number }'|.
          SELECT SINGLE @abap_true
            FROM (iv_draft_table)
            WHERE (lv_exists_where_d)
            INTO @lv_exists.
        ENDIF.

        IF lv_exists = abap_true.
          CLEAR rv_number.
        ENDIF.

      CATCH cx_sy_dynamic_osql_error
            cx_sy_strg_par_val
            cx_sy_conversion_error.
        CLEAR rv_number.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
