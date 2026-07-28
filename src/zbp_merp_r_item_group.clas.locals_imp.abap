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
        IMPORTING entities FOR CREATE ItemGroup.
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
    READ ENTITIES OF zmerp_r_item_group IN LOCAL MODE
      ENTITY ItemGroup
      FIELDS ( Description )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_item_groups).

    LOOP AT lt_item_groups REFERENCE INTO DATA(lr_grp).

      DATA(lv_has_error) = abap_false.

      APPEND VALUE #( %tky        = lr_grp->%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-itemgroup.

      IF lr_grp->Description IS INITIAL.
        lv_has_error = abap_true.

        APPEND VALUE #( %tky                 = lr_grp->%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_item_group_desc
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on ) TO reported-itemgroup.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_grp->%tky ) TO failed-itemgroup.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: lv_next_ig_code TYPE zmerp_item_group-item_group_code.

    LOOP AT entities REFERENCE INTO DATA(lr_entity).

      IF lr_entity->ItemGroupCode IS INITIAL.
        lv_next_ig_code = zcl_merp_num_range_util=>get_next_item_group_code( ).

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

ENDCLASS.
