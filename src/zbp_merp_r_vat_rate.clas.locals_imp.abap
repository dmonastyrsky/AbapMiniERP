CLASS lhc_zmerp_r_vat_rate DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
          REQUEST requested_authorizations FOR VatRate
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR VatRate~validateMandatoryFields,
      validatePercentage FOR VALIDATE ON SAVE
        IMPORTING keys FOR VatRate~validatePercentage.
ENDCLASS.

CLASS lhc_zmerp_r_vat_rate IMPLEMENTATION.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD validateMandatoryFields.
    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( Description Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates REFERENCE INTO DATA(lr_vat).

      DATA(lv_has_error) = abap_false.

      APPEND VALUE #( %tky        = lr_vat->%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-vatrate.

      IF lr_vat->Description IS INITIAL.
        lv_has_error = abap_true.

        APPEND VALUE #( %tky                 = lr_vat->%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_vat_name
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on ) TO reported-vatrate.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_vat->%tky ) TO failed-vatrate.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validatePercentage.
    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates REFERENCE INTO DATA(lr_vat).

      DATA(lv_has_error) = abap_false.

      APPEND VALUE #( %tky        = lr_vat->%tky
                      %state_area = 'VALIDATE_PERCENTAGE' ) TO reported-vatrate.

      IF lr_vat->Percentage < 0 OR lr_vat->Percentage > 100.
        lv_has_error = abap_true.

        APPEND VALUE #( %tky                = lr_vat->%tky
                        %state_area         = 'VALIDATE_PERCENTAGE'
                        %msg                = NEW zcm_merp_messages(
                                                textid   = zcm_merp_messages=>invalid_vat_percentage
                                                severity = if_abap_behv_message=>severity-error )
                        %element-Percentage = if_abap_behv=>mk-on ) TO reported-vatrate.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_vat->%tky ) TO failed-vatrate.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
