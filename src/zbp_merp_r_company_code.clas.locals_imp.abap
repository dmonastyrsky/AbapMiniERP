CLASS LHC_ZMERP_R_COMPANY_CODE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR CompanyCode
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
            IMPORTING keys FOR CompanyCode~validateMandatoryFields,
      validateCompanyCode FOR VALIDATE ON SAVE
            IMPORTING keys FOR CompanyCode~validateCompanyCode.
ENDCLASS.

CLASS LHC_ZMERP_R_COMPANY_CODE IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.

  ENDMETHOD.

  METHOD validateMandatoryFields.
    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyName CurrencyCode Country )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    LOOP AT lt_comp_codes INTO DATA(ls_comp_code).

      APPEND VALUE #( %tky        = ls_comp_code-%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-companycode.

      " Validate Company Name
      IF ls_comp_code-CompanyName IS INITIAL.
        APPEND VALUE #( %tky = ls_comp_code-%tky ) TO failed-companycode.

        APPEND VALUE #( %tky                  = ls_comp_code-%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                  textid   = zcm_merp_messages=>enter_company_name
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-CompanyName  = if_abap_behv=>mk-on ) TO reported-companycode.
      ENDIF.

      " Validate Currency Code
      IF ls_comp_code-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = ls_comp_code-%tky ) TO failed-companycode.

        APPEND VALUE #( %tky                  = ls_comp_code-%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                  textid   = zcm_merp_messages=>enter_currency
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-CurrencyCode = if_abap_behv=>mk-on ) TO reported-companycode.
      ENDIF.

      " Validate Country
      IF ls_comp_code-Country IS INITIAL.
        APPEND VALUE #( %tky = ls_comp_code-%tky ) TO failed-companycode.

        APPEND VALUE #( %tky              = ls_comp_code-%tky
                        %state_area       = 'VALIDATE_MANDATORY'
                        %msg              = NEW zcm_merp_messages(
                                              textid   = zcm_merp_messages=>enter_country
                                              severity = if_abap_behv_message=>severity-error )
                        %element-Country  = if_abap_behv=>mk-on ) TO reported-companycode.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateCompanyCode.
    READ ENTITIES OF zmerp_r_company_code IN LOCAL MODE
      ENTITY CompanyCode
      FIELDS ( CompanyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_comp_codes).

    LOOP AT lt_comp_codes INTO DATA(ls_comp_code).

      APPEND VALUE #( %tky        = ls_comp_code-%tky
                      %state_area = 'VALIDATE_EXISTENCE' ) TO reported-companycode.

      IF ls_comp_code-CompanyCode IS NOT INITIAL.

        SELECT SINGLE FROM zmerp_comp_code
          FIELDS company_code
          WHERE company_code = @ls_comp_code-CompanyCode
          INTO @DATA(lv_exists).

        IF lv_exists IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_comp_code-%tky ) TO failed-companycode.

          APPEND VALUE #( %tky                 = ls_comp_code-%tky
                          %state_area          = 'VALIDATE_EXISTENCE'
                          %msg                 = NEW zcm_merp_messages(
                                                   textid   = zcm_merp_messages=>company_code_exists
                                                   attr1    = |{ ls_comp_code-CompanyCode }|
                                                   severity = if_abap_behv_message=>severity-error )
                          %element-CompanyCode = if_abap_behv=>mk-on ) TO reported-companycode.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
