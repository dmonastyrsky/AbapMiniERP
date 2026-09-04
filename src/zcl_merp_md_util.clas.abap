CLASS zcl_merp_md_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    " Fixed: Changed WITH EMPTY KEY to WITH NON-UNIQUE KEY table_line to allow standard SORT and DELETE ADJACENT DUPLICATES
    TYPES tt_item_group_codes TYPE STANDARD TABLE OF zmerp_item_group_code WITH NON-UNIQUE KEY table_line.

    TYPES: BEGIN OF ty_item_group_vat,
             item_group_code  TYPE zmerp_item_group_code,
             default_vat_code TYPE zmerp_vat_code,
           END OF ty_item_group_vat,
           tt_item_group_vats TYPE SORTED TABLE OF ty_item_group_vat WITH UNIQUE KEY item_group_code.

    " Fixed: Changed WITH EMPTY KEY to WITH NON-UNIQUE KEY table_line to allow standard SORT and DELETE ADJACENT DUPLICATES
    TYPES tt_company_codes TYPE STANDARD TABLE OF zmerp_company_code WITH NON-UNIQUE KEY table_line.

    TYPES: BEGIN OF ty_company_prefix,
             company_code   TYPE zmerp_company_code,
             company_prefix TYPE zmerp_company_prefix,
           END OF ty_company_prefix,
           tt_company_prefixes TYPE SORTED TABLE OF ty_company_prefix WITH UNIQUE KEY company_code.

    TYPES: BEGIN OF ty_dependency_result,
             key_value TYPE string,
             msg       TYPE REF TO zcm_merp_messages,
           END OF ty_dependency_result,
           tt_dependency_results TYPE STANDARD TABLE OF ty_dependency_result WITH EMPTY KEY.

    "! Retrieves the default VAT code for a single Item Group
    CLASS-METHODS get_item_group_default_vat
      IMPORTING
        iv_item_group_code TYPE zmerp_item_group_code
      RETURNING
        VALUE(rv_vat_code) TYPE zmerp_vat_code.

    "! Retrieves default VAT codes for multiple Item Groups at once (Bulk Mode)
    CLASS-METHODS get_item_groups_default_vat
      IMPORTING
        it_item_group_codes TYPE tt_item_group_codes
      RETURNING
        VALUE(rt_vat_codes) TYPE tt_item_group_vats.

    "! Retrieves company prefix for a single Company Code
    CLASS-METHODS get_company_prefix
      IMPORTING
        iv_company_code  TYPE zmerp_company_code
      RETURNING
        VALUE(rv_prefix) TYPE zmerp_company_prefix.

    "! Retrieves company prefixes for multiple Company Codes at once (Bulk Mode)
    CLASS-METHODS get_companies_prefixes
      IMPORTING
        it_company_codes   TYPE tt_company_codes
      RETURNING
        VALUE(rt_prefixes) TYPE tt_company_prefixes.

    "! Validates existence of company codes and returns invalid entries
    CLASS-METHODS validate_companies
      IMPORTING
        it_company_codes        TYPE tt_company_codes
      RETURNING
        VALUE(rt_invalid_codes) TYPE tt_company_codes.

    "! Checks dependencies for any BO entity against its usage CDS view.
    "! @parameter it_keys | List of key values to validate
    "! @parameter iv_usage_cds | Name of the usage CDS View
    "! @parameter iv_key_field_name | Key field name in CDS View
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

    DATA(lt_vats) = get_item_groups_default_vat( VALUE #( ( iv_item_group_code ) ) ).

    ASSIGN lt_vats[ item_group_code = iv_item_group_code ] TO FIELD-SYMBOL(<ls_vat>).
    IF sy-subrc = 0.
      rv_vat_code = <ls_vat>-default_vat_code.
    ENDIF.
  ENDMETHOD.


  METHOD get_item_groups_default_vat.
    IF it_item_group_codes IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_local) = it_item_group_codes.
    DELETE lt_local WHERE table_line IS INITIAL.

    SORT lt_local.
    DELETE ADJACENT DUPLICATES FROM lt_local.

    IF lt_local IS INITIAL.
      RETURN.
    ENDIF.

    SELECT item_group_code, default_vat_code
      FROM zmerp_item_group
      WHERE item_group_code IN ( SELECT table_line FROM @lt_local AS input )
      INTO TABLE @rt_vat_codes.
  ENDMETHOD.

  METHOD get_company_prefix.
    IF iv_company_code IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_prefixes) = get_companies_prefixes( VALUE #( ( iv_company_code ) ) ).

    ASSIGN lt_prefixes[ company_code = iv_company_code ] TO FIELD-SYMBOL(<ls_prefix>).
    IF sy-subrc = 0.
      rv_prefix = <ls_prefix>-company_prefix.
    ENDIF.
  ENDMETHOD.


  METHOD get_companies_prefixes.
    IF it_company_codes IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_local) = it_company_codes.
    DELETE lt_local WHERE table_line IS INITIAL.

    SORT lt_local.
    DELETE ADJACENT DUPLICATES FROM lt_local.

    IF lt_local IS INITIAL.
      RETURN.
    ENDIF.

    SELECT company_code,
           company_prefix
      FROM zmerp_comp_code
      WHERE company_code IN ( SELECT table_line FROM @lt_local AS input )
      INTO TABLE @rt_prefixes.

    LOOP AT rt_prefixes ASSIGNING FIELD-SYMBOL(<ls_prefix>).
      <ls_prefix>-company_prefix = condense( val = <ls_prefix>-company_prefix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_companies.
    IF it_company_codes IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_local) = it_company_codes.
    DELETE lt_local WHERE table_line IS INITIAL.

    SORT lt_local.
    DELETE ADJACENT DUPLICATES FROM lt_local.

    IF lt_local IS INITIAL.
      RETURN.
    ENDIF.

    " Optimized: Fetching only key field into lightweight key table
    DATA lt_existing_db TYPE tt_company_codes.

    SELECT company_code
      FROM zmerp_comp_code
      WHERE company_code IN ( SELECT table_line FROM @lt_local AS input )
      INTO TABLE @lt_existing_db.

    LOOP AT lt_local INTO DATA(lv_code).
      IF NOT line_exists( lt_existing_db[ table_line = lv_code ] ).
        INSERT lv_code INTO TABLE rt_invalid_codes.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD check_dependencies.
    IF it_keys IS INITIAL OR iv_usage_cds IS INITIAL OR iv_key_field_name IS INITIAL.
      RETURN.
    ENDIF.

    TYPES: BEGIN OF ty_dep,
             key_field    TYPE string,
             usedinentity TYPE zmerp_entity_name,
           END OF ty_dep.

    TYPES tt_string_range TYPE RANGE OF string.

    " Safe key table with non-unique key to avoid dump on assignment
    DATA lt_keys         TYPE SORTED TABLE OF string WITH NON-UNIQUE KEY table_line.
    DATA lt_dependencies TYPE STANDARD TABLE OF ty_dep WITH EMPTY KEY.

    lt_keys = it_keys.
    DELETE ADJACENT DUPLICATES FROM lt_keys.

    DATA(lv_select_clause) = |{ iv_key_field_name } AS key_field, UsedInEntity|.
    DATA(lv_total_lines)   = lines( lt_keys ).
    DATA(lv_offset)        = 1.

    CONSTANTS lc_batch_size TYPE i VALUE 500.

    TRY.
        WHILE lv_offset <= lv_total_lines.

          DATA(lt_batch_range) = VALUE tt_string_range(
            FOR idx = lv_offset WHILE idx < lv_offset + lc_batch_size AND idx <= lv_total_lines
            ( sign = 'I' option = 'EQ' low = lt_keys[ idx ] )
          ).

          DATA(lv_where_clause) = |{ iv_key_field_name } IN @lt_batch_range|.

          SELECT DISTINCT (lv_select_clause)
            FROM (iv_usage_cds)
            WHERE (lv_where_clause)
            APPENDING TABLE @lt_dependencies.

          lv_offset = lv_offset + lc_batch_size.
        ENDWHILE.

      CATCH cx_sy_dynamic_osql_error cx_root INTO DATA(lx_err).
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

    LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep).
      INSERT VALUE #(
        key_value = lr_dep->key_field
        msg       = NEW zcm_merp_messages(
                      textid   = is_textid
                      attr1    = lr_dep->key_field
                      attr2    = CONV #( lr_dep->usedinentity )
                      severity = if_abap_behv_message=>severity-error )
      ) INTO TABLE rt_blocked_keys.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
