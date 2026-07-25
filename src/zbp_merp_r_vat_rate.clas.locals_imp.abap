CLASS LHC_ZMERP_R_VAT_RATE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR VatRate
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
            IMPORTING keys FOR VatRate~validateMandatoryFields,
      validateVatCode FOR VALIDATE ON SAVE
            IMPORTING keys FOR VatRate~validateVatCode,
      validatePercentage FOR VALIDATE ON SAVE
            IMPORTING keys FOR VatRate~validatePercentage.
ENDCLASS.

CLASS LHC_ZMERP_R_VAT_RATE IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.

  ENDMETHOD.

  METHOD validateMandatoryFields.
    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( Description Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates INTO DATA(ls_vat).

      APPEND VALUE #( %tky        = ls_vat-%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-vatrate.

      IF ls_vat-Description IS INITIAL.
        APPEND VALUE #( %tky = ls_vat-%tky ) TO failed-vatrate.

        APPEND VALUE #( %tky                 = ls_vat-%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_vat_name
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on ) TO reported-vatrate.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateVatCode.
    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( VatCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates INTO DATA(ls_vat).

      APPEND VALUE #( %tky        = ls_vat-%tky
                      %state_area = 'VALIDATE_EXISTENCE' ) TO reported-vatrate.

      IF ls_vat-VatCode IS NOT INITIAL.

        SELECT SINGLE FROM zmerp_vat_rate
          FIELDS vat_code
          WHERE vat_code = @ls_vat-VatCode
          INTO @DATA(lv_exists).

        IF lv_exists IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_vat-%tky ) TO failed-vatrate.

          APPEND VALUE #( %tky                 = ls_vat-%tky
                          %state_area          = 'VALIDATE_EXISTENCE'
                          %msg                 = NEW zcm_merp_messages(
                                                   textid   = zcm_merp_messages=>vat_code_exists
                                                   attr1    = |{ ls_vat-VatCode }|
                                                   severity = if_abap_behv_message=>severity-error )
                          %element-VatCode     = if_abap_behv=>mk-on ) TO reported-vatrate.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validatePercentage.
    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates INTO DATA(ls_vat).

      APPEND VALUE #( %tky        = ls_vat-%tky
                      %state_area = 'VALIDATE_PERCENTAGE' ) TO reported-vatrate.

      IF ls_vat-Percentage < 0 OR ls_vat-Percentage > 100.
        APPEND VALUE #( %tky = ls_vat-%tky ) TO failed-vatrate.

        APPEND VALUE #( %tky                 = ls_vat-%tky
                        %state_area          = 'VALIDATE_PERCENTAGE'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>invalid_vat_percentage
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Percentage  = if_abap_behv=>mk-on ) TO reported-vatrate.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
