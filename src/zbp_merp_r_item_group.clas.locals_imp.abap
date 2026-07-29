CLASS lhc_zmerp_r_item_group DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ItemGroup
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR ItemGroup~validateMandatoryFields,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE ItemGroup,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE ItemGroup.
ENDCLASS.

CLASS lhc_zmerp_r_item_group IMPLEMENTATION.

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
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-itemgroup.
    ENDLOOP.

    READ ENTITIES OF zmerp_r_item_group IN LOCAL MODE
      ENTITY ItemGroup
      FIELDS ( Description DefaultVatCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_groups).

    LOOP AT lt_groups REFERENCE INTO DATA(lr_group).
      DATA(lv_has_error) = abap_false.

      " 1. Validate Description
      IF lr_group->Description IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                 = lr_group->%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_item_grp_desc
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on ) TO reported-itemgroup.
      ENDIF.

      " 2. Validate Default VAT Code
      IF lr_group->DefaultVatCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                    = lr_group->%tky
                        %state_area             = 'VALIDATE_MANDATORY'
                        %msg                    = NEW zcm_merp_messages(
                                                    textid   = zcm_merp_messages=>select_default_vat_code
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-DefaultVatCode = if_abap_behv=>mk-on ) TO reported-itemgroup.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_group->%tky ) TO failed-itemgroup.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: lv_next_ig_code TYPE zmerp_item_group-item_group_code.

    LOOP AT entities REFERENCE INTO DATA(lr_entity).

      IF lr_entity->ItemGroupCode IS INITIAL.
        lv_next_ig_code = zcl_merp_num_range_util=>get_next_item_group_code_nro( ).

        IF lv_next_ig_code IS NOT INITIAL.
          APPEND VALUE #(
            %cid          = lr_entity->%cid
            %is_draft     = lr_entity->%is_draft
            ItemGroupCode = lv_next_ig_code
          ) TO mapped-itemgroup.
        ELSE.
          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
          ) TO failed-itemgroup.

          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
            %msg      = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Could not generate next Item Group Code sequence.' )
          ) TO reported-itemgroup.
        ENDIF.

      ELSE.
        " Manual key assignment fallback
        APPEND VALUE #(
          %cid          = lr_entity->%cid
          %is_draft     = lr_entity->%is_draft
          ItemGroupCode = lr_entity->ItemGroupCode
        ) TO mapped-itemgroup.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    " 1. Extract keys via %tky structure
    DATA lt_keys TYPE STANDARD TABLE OF zmerp_item_group-item_group_code WITH DEFAULT KEY.
    lt_keys = VALUE #( FOR key IN keys ( key-%tky-ItemGroupCode ) ).

    IF lt_keys IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Query usage CDS view
    SELECT DISTINCT ItemGroupCode, UsedInEntity
      FROM zmerp_i_item_group_usage
      FOR ALL ENTRIES IN @lt_keys
      WHERE ItemGroupCode = @lt_keys-table_line
      INTO TABLE @DATA(lt_dependencies).

    IF lt_dependencies IS INITIAL.
      RETURN.
    ENDIF.

    " 3. Block instances and pass messages
    LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep).
      READ TABLE keys WITH KEY %tky-ItemGroupCode = lr_dep->ItemGroupCode REFERENCE INTO DATA(lr_key).
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = lr_key->%tky ) TO failed-itemgroup.

        APPEND VALUE #(
          %tky = lr_key->%tky
          %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |Item Group '{ lr_dep->ItemGroupCode }' used in '{ lr_dep->UsedInEntity }'.| )
        ) TO reported-itemgroup.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
