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
        IMPORTING entities FOR CREATE VatRate,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE VatRate.
ENDCLASS.

CLASS lhc_zmerp_r_vat_rate IMPLEMENTATION.

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
    " Clear state messages before performing validation checks
    LOOP AT keys REFERENCE INTO DATA(lr_key).
      APPEND VALUE #( %tky        = lr_key->%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-vatrate.
    ENDLOOP.

    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( Description )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates REFERENCE INTO DATA(lr_vat).

      DATA(lv_has_error) = abap_false.

      " Validate Description
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
    " Clear state messages before performing validation checks
    LOOP AT keys REFERENCE INTO DATA(lr_key).
      APPEND VALUE #( %tky        = lr_key->%tky
                      %state_area = 'VALIDATE_PERCENTAGE' ) TO reported-vatrate.
    ENDLOOP.

    READ ENTITIES OF zmerp_r_vat_rate IN LOCAL MODE
      ENTITY VatRate
      FIELDS ( Percentage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vat_rates).

    LOOP AT lt_vat_rates REFERENCE INTO DATA(lr_vat).

      DATA(lv_has_error) = abap_false.

      " Validate Percentage range (0 - 100%)
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

    LOOP AT entities REFERENCE INTO DATA(lr_entity).

      IF lr_entity->VatCode IS INITIAL.
        lv_next_vat_code = zcl_merp_num_range_util=>get_next_vat_code_nro( ).

        IF lv_next_vat_code IS NOT INITIAL.
          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
            VatCode   = lv_next_vat_code
          ) TO mapped-vatrate.
        ELSE.
          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
          ) TO failed-vatrate.

          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
            %msg      = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Could not generate next VAT Code sequence.' )
          ) TO reported-vatrate.
        ENDIF.

      ELSE.
        APPEND VALUE #(
          %cid      = lr_entity->%cid
          %is_draft = lr_entity->%is_draft
          VatCode   = lr_entity->VatCode
        ) TO mapped-vatrate.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    " 1. Extract keys via %tky structure
    DATA lt_keys TYPE STANDARD TABLE OF zmerp_vat_rate-vat_code WITH DEFAULT KEY.
    lt_keys = VALUE #( FOR key IN keys ( key-%tky-VatCode ) ).

    IF lt_keys IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Query usage CDS view
    SELECT DISTINCT VatCode, UsedInEntity
      FROM ZMERP_I_VAT_RATE_USAGE
      FOR ALL ENTRIES IN @lt_keys
      WHERE VatCode = @lt_keys-table_line
      INTO TABLE @DATA(lt_dependencies).

    IF lt_dependencies IS INITIAL.
      RETURN.
    ENDIF.

    " 3. Block instances and pass messages
    LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep).
      READ TABLE keys WITH KEY %tky-VatCode = lr_dep->VatCode REFERENCE INTO DATA(lr_key).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = lr_key->%tky ) TO failed-vatrate.

        APPEND VALUE #(
          %tky = lr_key->%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |VAT Rate '{ lr_dep->VatCode }' used in '{ lr_dep->UsedInEntity }'.| )
        ) TO reported-vatrate.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
