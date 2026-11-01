"! Local behavior handler for Company Code BO entity.
CLASS lhc_zmerp_r_company_code DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_val_name   TYPE string VALUE 'VALIDATE_COMPANY_NAME',
      c_val_prefix TYPE string VALUE 'VALIDATE_COMPANY_PREFIX',
      c_val_curr   TYPE string VALUE 'VALIDATE_CURRENCY',
      c_val_cntr   TYPE string VALUE 'VALIDATE_COUNTRY'.

    TYPES:
      BEGIN OF ty_prefix_check,
        company_code   TYPE zmerp_company_code,
        company_prefix TYPE zmerp_company_prefix,
      END OF ty_prefix_check,
      tt_prefix_checks TYPE STANDARD TABLE OF ty_prefix_check WITH EMPTY KEY,

      BEGIN OF ty_prefix_conflict,
        company_code TYPE zmerp_company_code,
        owner_code   TYPE zmerp_company_code,
      END OF ty_prefix_conflict,
      tt_prefix_conflicts TYPE SORTED TABLE OF ty_prefix_conflict WITH UNIQUE KEY company_code.

    "! Evaluates global authorizations for CUD operations.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
        REQUEST requested_authorizations FOR CompanyCode
        RESULT result.

    "! Companies in use keep their currency (stock valuation) and prefix (document numbers).
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING
        keys   REQUEST requested_features FOR CompanyCode
      RESULT   result.

    "! Clears validation messages for fields that have been filled in.
    "! CompanyPrefix is handled by handlePrefixChange (clear and re-check in one place).
    METHODS clearMessagesForFilledFields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CompanyCode~clearMessagesForFilledFields.

    "! Validates mandatory fields, prefix length and prefix uniqueness before saving.
    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR CompanyCode~validateMandatoryFields.

    "! Pre-checks deletion dependencies in referenced entities.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE CompanyCode.

    "! Converts the company prefix to upper case and interactively checks
    "! its length and uniqueness. Owns the prefix state area.
    METHODS handlePrefixChange FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CompanyCode~handlePrefixChange.

    "! Returns the companies whose prefix is already used by another company
    "! (active record or draft). The same prefix would give equal document numbers.
    "! @parameter it_checks    | Company codes with the prefixes to check (upper case)
    "! @parameter rt_conflicts | Company code with the code of the company that already uses its prefix
    METHODS find_prefix_conflicts
      IMPORTING it_checks           TYPE tt_prefix_checks
      RETURNING VALUE(rt_conflicts) TYPE tt_prefix_conflicts.

ENDCLASS.

CLASS lhc_zmerp_r_company_code IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    TYPES: BEGIN OF ty_key,
             companycode TYPE zmerp_company_code,
           END OF ty_key.

    DATA lt_keys TYPE SORTED TABLE OF ty_key WITH UNIQUE KEY companycode.
    DATA lt_used TYPE SORTED TABLE OF ty_key WITH UNIQUE KEY companycode.

    LOOP AT keys REFERENCE INTO DATA(lr_key) WHERE CompanyCode IS NOT INITIAL.
      INSERT VALUE #( companycode = lr_key->CompanyCode ) INTO TABLE lt_keys.
    ENDLOOP.

    IF lt_keys IS NOT INITIAL.
      SELECT DISTINCT usage~CompanyCode AS companycode
        FROM zmerp_i_company_code_usage AS usage
        INNER JOIN @lt_keys AS key ON usage~CompanyCode = key~companycode
        INTO TABLE @lt_used.
    ENDIF.

    result = VALUE #(
      FOR key IN keys
      LET lv_control = COND #( WHEN line_exists( lt_used[ companycode = key-CompanyCode ] )
                               THEN if_abap_behv=>fc-f-read_only
                               ELSE if_abap_behv=>fc-f-mandatory ) IN
      ( %tky                 = key-%tky
        %field-CurrencyCode  = lv_control
        %field-CompanyPrefix = lv_control )
    ).
  ENDMETHOD.

  METHOD validateMandatoryFields.
    DATA lv_has_error TYPE abap_bool.

    " Clear previous validation messages for individual state areas to prevent duplicate errors in UI
    reported-companycode = VALUE #(
      BASE reported-companycode
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_val_name )
      ( %tky        = key-%tky
        %state_area = c_val_prefix )
      ( %tky        = key-%tky
        %state_area = c_val_curr )
      ( %tky        = key-%tky
        %state_area = c_val_cntr )
    ).

    " Read entity fields in local mode to bypass global authorization checks during validation
    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyName CompanyPrefix CurrencyCode Country )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    IF lt_comp_codes IS INITIAL.
      RETURN.
    ENDIF.

    " The prefix is already upper case here (handlePrefixChange converts it on every change)
    DATA(lt_conflicts) = find_prefix_conflicts(
      VALUE #( FOR comp IN lt_comp_codes
               ( company_code   = comp-CompanyCode
                 company_prefix = comp-CompanyPrefix ) ) ).

    LOOP AT lt_comp_codes REFERENCE INTO DATA(lr_comp_code).
      lv_has_error = abap_false.

      " 1. Company Name Mandatory Validation
      IF lr_comp_code->CompanyName IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_comp_code->%tky
          %state_area          = c_val_name
          %msg                 = NEW zcx_merp_md(
                                   textid   = zcx_merp_md=>enter_company_name
                                   severity = if_abap_behv_message=>severity-error )
          %element-CompanyName = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ENDIF.

      " 2. Company Prefix Mandatory, Length & Uniqueness Validation
      IF lr_comp_code->CompanyPrefix IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_comp_code->%tky
          %state_area            = c_val_prefix
          %msg                   = NEW zcx_merp_md(
                                     textid   = zcx_merp_md=>enter_company_prefix
                                     severity = if_abap_behv_message=>severity-error )
          %element-CompanyPrefix = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ELSEIF zcl_merp_md_validator=>is_company_prefix_valid( lr_comp_code->CompanyPrefix ) = abap_false.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_comp_code->%tky
          %state_area            = c_val_prefix
          %msg                   = NEW zcx_merp_md(
                                     textid   = zcx_merp_md=>invalid_prefix_length
                                     severity = if_abap_behv_message=>severity-error )
          %element-CompanyPrefix = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ELSE.
        ASSIGN lt_conflicts[ company_code = lr_comp_code->CompanyCode ] TO FIELD-SYMBOL(<ls_conflict>).
        IF sy-subrc = 0.
          lv_has_error = abap_true.
          APPEND VALUE #(
            %tky                   = lr_comp_code->%tky
            %state_area            = c_val_prefix
            %msg                   = NEW zcx_merp_md(
                                       textid   = zcx_merp_md=>company_prefix_not_unique
                                       attr1    = CONV #( lr_comp_code->CompanyPrefix )
                                       attr2    = CONV #( <ls_conflict>-owner_code )
                                       severity = if_abap_behv_message=>severity-error )
            %element-CompanyPrefix = if_abap_behv=>mk-on
          ) TO reported-companycode.
        ENDIF.
      ENDIF.

      " 3. Currency Code Mandatory Validation
      IF lr_comp_code->CurrencyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_comp_code->%tky
          %state_area           = c_val_curr
          %msg                  = NEW zcx_merp_md(
                                    textid   = zcx_merp_md=>select_currency
                                    severity = if_abap_behv_message=>severity-error )
          %element-CurrencyCode = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ENDIF.

      " 4. Country Mandatory Validation
      IF lr_comp_code->Country IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky              = lr_comp_code->%tky
          %state_area       = c_val_cntr
          %msg              = NEW zcx_merp_md(
                                textid   = zcx_merp_md=>select_country
                                severity = if_abap_behv_message=>severity-error )
          %element-Country  = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ENDIF.

      IF lv_has_error = abap_true.
        " Mark entity instance as failed to prevent transaction commit
        APPEND VALUE #(
          %tky        = lr_comp_code->%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-companycode.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clearMessagesForFilledFields.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    " Read entity state in local mode
    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyName CurrencyCode Country )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    LOOP AT lt_comp_codes REFERENCE INTO DATA(lr_comp_code).
      " Clear message area for Company Name
      IF lr_comp_code->CompanyName IS NOT INITIAL.
        APPEND VALUE #( %tky = lr_comp_code->%tky %state_area = c_val_name ) TO reported-companycode.
      ENDIF.

      " Clear message area for Currency Code
      IF lr_comp_code->CurrencyCode IS NOT INITIAL.
        APPEND VALUE #( %tky = lr_comp_code->%tky %state_area = c_val_curr ) TO reported-companycode.
      ENDIF.

      " Clear message area for Country
      IF lr_comp_code->Country IS NOT INITIAL.
        APPEND VALUE #( %tky = lr_comp_code->%tky %state_area = c_val_cntr ) TO reported-companycode.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD handlePrefixChange.
    DATA lt_update TYPE TABLE FOR UPDATE zmerp_r_company_code.

    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyPrefix )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    IF lt_comp_codes IS INITIAL.
      RETURN.
    ENDIF.

    " Uniqueness is checked on the upper-case value that will be stored
    DATA(lt_conflicts) = find_prefix_conflicts(
      VALUE #( FOR comp IN lt_comp_codes
               ( company_code   = comp-CompanyCode
                 company_prefix = to_upper( comp-CompanyPrefix ) ) ) ).

    LOOP AT lt_comp_codes REFERENCE INTO DATA(lr_comp_code).
      " This determination owns the prefix state area: clear it before re-checking
      APPEND VALUE #( %tky = lr_comp_code->%tky %state_area = c_val_prefix ) TO reported-companycode.

      " An empty prefix is reported on save, like all other mandatory fields
      IF lr_comp_code->CompanyPrefix IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_upper_prefix) = CONV zmerp_company_prefix( to_upper( lr_comp_code->CompanyPrefix ) ).

      IF zcl_merp_md_validator=>is_company_prefix_valid( lv_upper_prefix ) = abap_false.
        APPEND VALUE #(
          %tky                   = lr_comp_code->%tky
          %state_area            = c_val_prefix
          %msg                   = NEW zcx_merp_md(
                                     textid   = zcx_merp_md=>invalid_prefix_length
                                     severity = if_abap_behv_message=>severity-error )
          %element-CompanyPrefix = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ELSE.
        ASSIGN lt_conflicts[ company_code = lr_comp_code->CompanyCode ] TO FIELD-SYMBOL(<ls_conflict>).
        IF sy-subrc = 0.
          APPEND VALUE #(
            %tky                   = lr_comp_code->%tky
            %state_area            = c_val_prefix
            %msg                   = NEW zcx_merp_md(
                                       textid   = zcx_merp_md=>company_prefix_not_unique
                                       attr1    = CONV #( lv_upper_prefix )
                                       attr2    = CONV #( <ls_conflict>-owner_code )
                                       severity = if_abap_behv_message=>severity-error )
            %element-CompanyPrefix = if_abap_behv=>mk-on
          ) TO reported-companycode.
        ENDIF.
      ENDIF.

      " Store the prefix in upper case (document numbers start with it)
      IF lr_comp_code->CompanyPrefix <> lv_upper_prefix.
        APPEND VALUE #(
          %tky                   = lr_comp_code->%tky
          CompanyPrefix          = lv_upper_prefix
          %control-CompanyPrefix = if_abap_behv=>mk-on
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_company_code IN LOCAL MODE
        ENTITY CompanyCode
        UPDATE FIELDS ( CompanyPrefix )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_delete.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    TYPES: BEGIN OF ty_key,
             companycode TYPE zmerp_company_code,
           END OF ty_key.

    TYPES: BEGIN OF ty_dependency,
             companycode  TYPE zmerp_company_code,
             usedinentity TYPE zmerp_entity_name,
           END OF ty_dependency.

    DATA lt_keys TYPE SORTED TABLE OF ty_key WITH NON-UNIQUE KEY companycode.
    DATA lt_dependencies TYPE SORTED TABLE OF ty_dependency WITH NON-UNIQUE KEY companycode.
    DATA lv_failed_added TYPE abap_bool.

    " Collect unique non-initial keys for one bulk usage check
    lt_keys = VALUE #( FOR key IN keys WHERE ( CompanyCode IS NOT INITIAL ) ( companycode = key-CompanyCode ) ).
    DELETE ADJACENT DUPLICATES FROM lt_keys COMPARING companycode.

    IF lt_keys IS INITIAL.
      RETURN.
    ENDIF.

    " Bulk check database dependencies for collected key set
    SELECT DISTINCT
           usage~CompanyCode  AS companycode,
           usage~UsedInEntity AS usedinentity
      FROM zmerp_i_company_code_usage AS usage
      INNER JOIN @lt_keys AS key ON usage~CompanyCode = key~companycode
      INTO TABLE @lt_dependencies.

    IF lt_dependencies IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT keys REFERENCE INTO DATA(lr_key).
      lv_failed_added = abap_false.

      " Dependencies of this key (sorted table: WHERE uses the table key)
      LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep)
        WHERE companycode = lr_key->CompanyCode.

        " Record entity failure state ONCE per key
        IF lv_failed_added = abap_false.
          APPEND VALUE #(
            %tky        = lr_key->%tky
            %fail-cause = if_abap_behv=>cause-dependency
          ) TO failed-companycode.
          lv_failed_added = abap_true.
        ENDIF.

        " Report explicit dependency error message to UI
        APPEND VALUE #(
          %tky                 = lr_key->%tky
          %element-CompanyCode = if_abap_behv=>mk-on
          %msg                  = NEW zcx_merp_md(
                                      textid   = zcx_merp_md=>company_code_in_use
                                      attr1    = CONV #( lr_dep->companycode )
                                      attr2    = CONV #( lr_dep->usedinentity )
                                      severity = if_abap_behv_message=>severity-error )
        ) TO reported-companycode.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD find_prefix_conflicts.
    TYPES: BEGIN OF ty_prefix,
             company_prefix TYPE zmerp_company_prefix,
           END OF ty_prefix.

    DATA lt_prefixes TYPE SORTED TABLE OF ty_prefix WITH UNIQUE KEY company_prefix.
    DATA lt_owners   TYPE tt_prefix_checks.

    LOOP AT it_checks REFERENCE INTO DATA(lr_check) WHERE company_prefix IS NOT INITIAL.
      INSERT VALUE #( company_prefix = lr_check->company_prefix ) INTO TABLE lt_prefixes.
    ENDLOOP.

    IF lt_prefixes IS INITIAL.
      RETURN.
    ENDIF.

    " Only active companies are checked: a draft with the same prefix fails on its own activation
    SELECT comp~CompanyCode   AS company_code,
           comp~CompanyPrefix AS company_prefix
      FROM zmerp_r_company_code AS comp
      INNER JOIN @lt_prefixes AS pref ON comp~CompanyPrefix = pref~company_prefix
      INTO CORRESPONDING FIELDS OF TABLE @lt_owners.

    " A company's own active record is not a conflict
    LOOP AT it_checks REFERENCE INTO lr_check WHERE company_prefix IS NOT INITIAL.
      LOOP AT lt_owners REFERENCE INTO DATA(lr_owner)
           WHERE company_prefix = lr_check->company_prefix
             AND company_code  <> lr_check->company_code.
        INSERT VALUE #( company_code = lr_check->company_code
                        owner_code   = lr_owner->company_code ) INTO TABLE rt_conflicts.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
