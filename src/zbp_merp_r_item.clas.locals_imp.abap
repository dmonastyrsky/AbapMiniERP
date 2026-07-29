"! Local behavior handler class for Item entity logic
CLASS lhc_zmerp_r_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    "! Checks global authorizations for CRUD operations on Item instance.
    "! @parameter requested_authorizations | Requested operation permissions
    "! @parameter result | Output structure containing authorization status
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
        REQUEST requested_authorizations FOR Item
      RESULT result.

    "! Validates that mandatory fields are filled prior to saving the instance.
    "! @parameter keys | Keys of Item instances to be validated
    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateMandatoryFields.

    "! Assigns unique Item Code from number range object before creation.
    "! @parameter entities | Incoming entity data for creation
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Item.

    "! Automatically sets Default VAT Code based on the selected Item Group.
    "! @parameter keys | Keys of Item instances triggered by ItemGroupCode change
    METHODS setDefaultVatCode FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Item~setDefaultVatCode.

ENDCLASS.

CLASS lhc_zmerp_r_item IMPLEMENTATION.

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
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-item.
    ENDLOOP.

    READ ENTITIES OF zmerp_r_item IN LOCAL MODE
      ENTITY Item
      FIELDS ( Description ItemTypeCode ItemGroupCode DefaultVatCode BaseUnitOfMeasure )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items REFERENCE INTO DATA(lr_item).
      DATA(lv_has_error) = abap_false.

      " 1. Validate Description
      IF lr_item->Description IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                 = lr_item->%tky
                        %state_area          = 'VALIDATE_MANDATORY'
                        %msg                 = NEW zcm_merp_messages(
                                                 textid   = zcm_merp_messages=>enter_item_desc
                                                 severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

      " 2. Validate Item Type
      IF lr_item->ItemTypeCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky              = lr_item->%tky
                        %state_area       = 'VALIDATE_MANDATORY'
                        %msg              = NEW zcm_merp_messages(
                                              textid   = zcm_merp_messages=>select_item_type
                                              severity = if_abap_behv_message=>severity-error )
                        %element-ItemTypeCode = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

      " 3. Validate Item Group Code
      IF lr_item->ItemGroupCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                   = lr_item->%tky
                        %state_area            = 'VALIDATE_MANDATORY'
                        %msg                   = NEW zcm_merp_messages(
                                                   textid   = zcm_merp_messages=>select_item_group
                                                   severity = if_abap_behv_message=>severity-error )
                        %element-ItemGroupCode = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

      " 4. Validate Default VAT Code
      IF lr_item->DefaultVatCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                    = lr_item->%tky
                        %state_area             = 'VALIDATE_MANDATORY'
                        %msg                    = NEW zcm_merp_messages(
                                                    textid   = zcm_merp_messages=>select_default_vat_code
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-DefaultVatCode = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

      " 5. Validate Base Unit of Measure
      IF lr_item->BaseUnitOfMeasure IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #( %tky                       = lr_item->%tky
                        %state_area                = 'VALIDATE_MANDATORY'
                        %msg                       = NEW zcm_merp_messages(
                                                       textid   = zcm_merp_messages=>select_base_unit
                                                       severity = if_abap_behv_message=>severity-error )
                        %element-BaseUnitOfMeasure = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_item->%tky ) TO failed-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD earlynumbering_create.
    DATA: lv_next_code TYPE zmerp_item_code.

    LOOP AT entities REFERENCE INTO DATA(lr_entity).
      IF lr_entity->ItemCode IS INITIAL.
        lv_next_code = zcl_merp_num_range_util=>get_next_item_code_nro( ).

        IF lv_next_code IS NOT INITIAL.
          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
            ItemCode  = lv_next_code
          ) TO mapped-item.
        ELSE.
          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
          ) TO failed-item.
        ENDIF.
      ELSE.
        APPEND VALUE #(
          %cid      = lr_entity->%cid
          %is_draft = lr_entity->%is_draft
          ItemCode  = lr_entity->ItemCode
        ) TO mapped-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD setDefaultVatCode.
    " 1. Read ItemGroupCode from current draft instance
    READ ENTITIES OF zmerp_r_item IN LOCAL MODE
      ENTITY Item
      FIELDS ( ItemGroupCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DELETE lt_items WHERE ItemGroupCode IS INITIAL.
    IF lt_items IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Fetch Default VAT Code using the central Master Data Utility Class
    DATA: lt_update TYPE TABLE FOR UPDATE zmerp_r_item.

    LOOP AT lt_items REFERENCE INTO DATA(lr_item).
      DATA(lv_vat_code) = zcl_merp_md_util=>get_item_group_default_vat( lr_item->ItemGroupCode ).

      IF lv_vat_code IS NOT INITIAL.
        APPEND VALUE #(
          %tky                    = lr_item->%tky
          DefaultVatCode          = lv_vat_code
          %control-DefaultVatCode = if_abap_behv=>mk-on
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    " 3. Update Item draft
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_item IN LOCAL MODE
        ENTITY Item
        UPDATE FIELDS ( DefaultVatCode )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
