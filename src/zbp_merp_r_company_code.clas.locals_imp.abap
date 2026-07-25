CLASS lhc_zmerp_r_company_code DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR CompanyCode
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR CompanyCode~validateMandatoryFields.
ENDCLASS.

CLASS lhc_zmerp_r_company_code IMPLEMENTATION.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD validateMandatoryFields.

    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyName CurrencyCode Country )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    LOOP AT lt_comp_codes REFERENCE INTO DATA(lr_comp_code).

      DATA(lv_has_error) = abap_false.

      APPEND VALUE #( %tky        = lr_comp_code->%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-companycode.

      " Validate Company Name
      IF lr_comp_code->CompanyName IS INITIAL.

        lv_has_error = abap_true.

        APPEND VALUE #( %tky                 = lr_comp_code->%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_company_name
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-CompanyName = if_abap_behv=>mk-on ) TO reported-companycode.

      ENDIF.

      " Validate Currency Code
      IF lr_comp_code->CurrencyCode IS INITIAL.

        lv_has_error = abap_true.

        APPEND VALUE #( %tky                  = lr_comp_code->%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_currency
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-CurrencyCode = if_abap_behv=>mk-on ) TO reported-companycode.

      ENDIF.

      " Validate Country
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

ENDCLASS.
