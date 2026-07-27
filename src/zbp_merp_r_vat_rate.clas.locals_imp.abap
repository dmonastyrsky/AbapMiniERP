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
        IMPORTING keys FOR VatRate~validatePercentage,
      earlynumbering_create FOR NUMBERING
            IMPORTING entities FOR CREATE VatRate.
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

  METHOD earlynumbering_create.
    DATA: lv_next_vat_code TYPE zmerp_vat_rate-vat_code.

    LOOP AT entities INTO DATA(ls_entity).

      IF ls_entity-VatCode IS INITIAL.
        lv_next_vat_code = zcl_merp_md_util=>get_next_vat_code( ).

        IF lv_next_vat_code IS NOT INITIAL.
          APPEND VALUE #(
            %cid      = ls_entity-%cid
            %is_draft = ls_entity-%is_draft
            VatCode   = lv_next_vat_code
          ) TO mapped-vatrate.
        ELSE.
          APPEND VALUE #(
            %cid      = ls_entity-%cid
            %is_draft = ls_entity-%is_draft
          ) TO failed-vatrate.

         APPEND VALUE #(
            %cid      = ls_entity-%cid
            %is_draft = ls_entity-%is_draft
            %msg      = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Could not generate next VAT Code sequence.' )
          ) TO reported-vatrate.
        ENDIF.

      ELSE.
        " If user provided ID manually, map it back with draft flag
        APPEND VALUE #(
          %cid      = ls_entity-%cid
          %is_draft = ls_entity-%is_draft
          VatCode   = ls_entity-VatCode
        ) TO mapped-vatrate.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
