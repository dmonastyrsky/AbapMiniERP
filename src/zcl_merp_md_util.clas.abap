CLASS zcl_merp_md_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_company_codes TYPE SORTED TABLE OF zmerp_company_code WITH UNIQUE KEY table_line.

    TYPES: BEGIN OF ty_dependency_result,
             key_value TYPE string,
             msg       TYPE REF TO zcm_merp_messages,
           END OF ty_dependency_result,
           tt_dependency_results TYPE STANDARD TABLE OF ty_dependency_result WITH DEFAULT KEY.

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

    "! Checks dependencies for any BO entity against its usage CDS view.
    "! @parameter it_keys | List of key values to validate
    "! @parameter iv_usage_cds | Name of the usage CDS View (e.g. 'ZMERP_I_COMPANY_CODE_USAGE')
    "! @parameter iv_key_field_name | Key field name in CDS View (e.g. 'COMPANYCODE')
    "! @parameter is_textid | Message textid from zcm_merp_messages
    "! @parameter rt_blocked_keys | Collection of blocked key strings with prepared error message objects
    CLASS-METHODS check_dependencies
      IMPORTING
        it_keys                TYPE string_table
        iv_usage_cds           TYPE string
        iv_key_field_name      TYPE string
        is_textid              TYPE scx_t100key
      RETURNING
        VALUE(rt_blocked_keys) TYPE tt_dependency_results.

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
      FROM zmerp_r_company_code
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

  METHOD check_dependencies.
    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    TYPES: BEGIN OF ty_dep,
             key_val      TYPE string,
             usedinentity TYPE zmerp_entity_name,
           END OF ty_dep.

    TYPES tt_string_range TYPE RANGE OF string.

    DATA lt_keys TYPE SORTED TABLE OF string WITH NON-UNIQUE KEY table_line.
    DATA lt_dependencies TYPE STANDARD TABLE OF ty_dep WITH EMPTY KEY.

    " Collect key values and remove potential duplicates to optimize SQL predicate standard
    lt_keys = it_keys.
    DELETE ADJACENT DUPLICATES FROM lt_keys COMPARING table_line.

    " Single string with explicit comma separation for Open SQL dynamic SELECT clause
    DATA(lv_select_clause) = |{ iv_key_field_name }, UsedInEntity|.

    CONSTANTS lc_batch_size TYPE i VALUE 500.
    DATA lv_offset TYPE i VALUE 1.
    DATA(lv_total_lines) = lines( lt_keys ).

    TRY.
        " Process keys in chunks of 500 to prevent HANA SQL statement length overflow
        WHILE lv_offset <= lv_total_lines.
          " Construct Range for the current batch
          DATA(lt_batch_range) = VALUE tt_string_range(
            FOR idx = lv_offset WHILE idx < lv_offset + lc_batch_size AND idx <= lv_total_lines
            ( sign = 'I' option = 'EQ' low = lt_keys[ idx ] )
          ).
          DATA(lv_where_clause) = |{ iv_key_field_name } IN @lt_batch_range|.

          " Dynamic query execution per batch
          SELECT DISTINCT (lv_select_clause)
            FROM (iv_usage_cds)
            WHERE (lv_where_clause)
            APPENDING TABLE @lt_dependencies.

          lv_offset = lv_offset + lc_batch_size.
        ENDWHILE.

      CATCH cx_sy_dynamic_osql_error cx_root INTO DATA(lx_err).
        " Block deletion for all input keys if any SQL chunk fails
        LOOP AT lt_keys INTO DATA(lv_failed_key).
          INSERT VALUE #(
            key_value = lv_failed_key
            msg       = NEW zcm_merp_messages(
                          textid   = is_textid
                          attr1    = lv_failed_key
                          attr2    = CONV #( lx_err->get_text( ) )
                          severity = if_abap_behv_message=>severity-error )
          ) INTO TABLE rt_blocked_keys.
        ENDLOOP.
        RETURN.
    ENDTRY.

    IF lt_dependencies IS INITIAL.
      RETURN.
    ENDIF.

    CONSTANTS lc_max_ui_messages TYPE i VALUE 10.
    DATA lv_msg_count TYPE i VALUE 0.

    " Map found dependencies into blocked keys table (limit UI messages to top 10)
    LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep).
      lv_msg_count = lv_msg_count + 1.

      INSERT VALUE #(
        key_value = lr_dep->key_val
        msg       = COND #( WHEN lv_msg_count <= lc_max_ui_messages
                            THEN NEW zcm_merp_messages(
                                   textid   = is_textid
                                   attr1    = lr_dep->key_val
                                   attr2    = CONV #( lr_dep->usedinentity )
                                   severity = if_abap_behv_message=>severity-error ) )
      ) INTO TABLE rt_blocked_keys.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
