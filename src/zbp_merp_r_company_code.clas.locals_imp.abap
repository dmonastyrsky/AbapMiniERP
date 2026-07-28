CLASS lhc_zmerp_r_company_code DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR CompanyCode
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR CompanyCode~validateMandatoryFields,
      precheck_delete FOR PRECHECK
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

    LOOP AT keys REFERENCE INTO DATA(lr_key).
      APPEND VALUE #( %tky        = lr_key->%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-companycode.
    ENDLOOP.

    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyName CurrencyCode Country )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    LOOP AT lt_comp_codes REFERENCE INTO DATA(lr_comp_code).
      DATA(lv_has_error) = abap_false.

      IF lr_comp_code->CompanyName IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                 = lr_comp_code->%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_company_name
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-CompanyName = if_abap_behv=>mk-on ) TO reported-companycode.
      ENDIF.

      IF lr_comp_code->CurrencyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                  = lr_comp_code->%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_currency
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-CurrencyCode = if_abap_behv=>mk-on ) TO reported-companycode.
      ENDIF.

      IF lr_comp_code->Country IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky              = lr_comp_code->%tky
                        %state_area       = 'VALIDATE_MANDATORY'
                        %msg              = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_country
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Country  = if_abap_behv=>mk-on ) TO reported-companycode.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_comp_code->%tky ) TO failed-companycode.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD precheck_delete.
    " 1. Extract keys via %tky structure
    DATA lt_keys TYPE STANDARD TABLE OF zmerp_comp_code-company_code WITH DEFAULT KEY.
    lt_keys = VALUE #( FOR key IN keys ( key-%tky-CompanyCode ) ).

    IF lt_keys IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Query usage CDS view
    SELECT DISTINCT CompanyCode, UsedInEntity
      FROM ZMERP_I_COMPANY_CODE_USAGE
      FOR ALL ENTRIES IN @lt_keys
      WHERE CompanyCode = @lt_keys-table_line
      INTO TABLE @DATA(lt_dependencies).

    IF lt_dependencies IS INITIAL.
      RETURN.
    ENDIF.

    " 3. Block instances and pass messages
    LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep).
      READ TABLE keys WITH KEY %tky-CompanyCode = lr_dep->CompanyCode REFERENCE INTO DATA(lr_key).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = lr_key->%tky ) TO failed-companycode.

        APPEND VALUE #(
          %tky = lr_key->%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Company Code '{ lr_dep->CompanyCode }' cannot be deleted because it is referenced in '{ lr_dep->UsedInEntity }'.| )
        ) TO reported-companycode.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
