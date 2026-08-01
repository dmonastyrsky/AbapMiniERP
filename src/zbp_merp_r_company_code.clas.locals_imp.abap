"! <p>p_task</p> Local behavior handler for Company Code BO entity.
CLASS lhc_zmerp_r_company_code DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS c_state_area_mandatory TYPE string VALUE 'VALIDATE_MANDATORY'.

    "! <p>p_task</p> Evaluates global authorizations for CUD operations.
    "! @parameter requested_authorizations | Mandatory RAP requested authorization flags
    "! @parameter result | Resulting authorization statuses
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
        REQUEST requested_authorizations FOR CompanyCode
        RESULT result.

    "! <p>p_task</p> Validates mandatory fields before saving.
    "! @parameter keys | Entity keys for validation
    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR CompanyCode~validateMandatoryFields.

    "! <p>p_task</p> Pre-checks deletion dependencies in referenced entities.
    "! @parameter keys | Keys requested for deletion
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE CompanyCode.
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

  METHOD validateMandatoryFields.
    reported-companycode = VALUE #(
      BASE reported-companycode
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_state_area_mandatory )
    ).

    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyName CurrencyCode Country )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    LOOP AT lt_comp_codes REFERENCE INTO DATA(lr_comp_code).
      DATA(lv_has_error) = abap_false.

      IF lr_comp_code->CompanyName IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_comp_code->%tky
          %state_area          = c_state_area_mandatory
          %msg                 = NEW zcm_merp_messages(
                                   textid   = zcm_merp_messages=>enter_company_name
                                   severity = if_abap_behv_message=>severity-error )
          %element-CompanyName = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ENDIF.

      IF lr_comp_code->CurrencyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_comp_code->%tky
          %state_area           = c_state_area_mandatory
          %msg                  = NEW zcm_merp_messages(
                                    textid   = zcm_merp_messages=>enter_currency
                                    severity = if_abap_behv_message=>severity-error )
          %element-CurrencyCode = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ENDIF.

      IF lr_comp_code->Country IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky              = lr_comp_code->%tky
          %state_area       = c_state_area_mandatory
          %msg              = NEW zcm_merp_messages(
                                textid   = zcm_merp_messages=>enter_country
                                severity = if_abap_behv_message=>severity-error )
          %element-Country  = if_abap_behv=>mk-on
        ) TO reported-companycode.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_comp_code->%tky ) TO failed-companycode.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    TYPES: BEGIN OF ty_key,
             companycode TYPE zmerp_comp_code-company_code,
           END OF ty_key.

    TYPES: BEGIN OF ty_dependency,
             companycode  TYPE zmerp_comp_code-company_code,
             usedinentity TYPE char30,
           END OF ty_dependency.

    DATA lt_keys TYPE STANDARD TABLE OF ty_key WITH EMPTY KEY.
    DATA lt_dependencies TYPE SORTED TABLE OF ty_dependency WITH NON-UNIQUE KEY companycode.

    lt_keys = VALUE #( FOR key IN keys ( companycode = key-%tky-CompanyCode ) ).

    SELECT DISTINCT usage~CompanyCode, usage~UsedInEntity
      FROM zmerp_i_company_code_usage AS usage
      INNER JOIN @lt_keys AS key ON usage~CompanyCode = key~companycode
      INTO TABLE @lt_dependencies.

    IF lt_dependencies IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT keys REFERENCE INTO DATA(lr_key).
      LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep)
        WHERE companycode = lr_key->%tky-CompanyCode.

        APPEND VALUE #( %tky = lr_key->%tky ) TO failed-companycode.

        APPEND VALUE #(
          %tky = lr_key->%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Company Code '{ lr_dep->companycode }' used in '{ lr_dep->usedinentity }'.| )
        ) TO reported-companycode.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
