"! Local behavior handler for Purchase Order root entity.
CLASS lhc_zmerp_r_purchaseorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_state_area_header TYPE string VALUE 'VALIDATE_HEADER',
      c_state_area_dates  TYPE string VALUE 'VALIDATE_DATES',
      c_default_status    TYPE zmerp_po_status VALUE 'N'.

    "! Evaluates global authorizations for CUD operations.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR PurchaseOrder
      RESULT result.

    "! Evaluates dynamic instance features for actions based on status.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING
                keys   REQUEST requested_features FOR PurchaseOrder
      RESULT    result.

    "! Pre-checks deletion conditions and status restrictions.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING
        keys FOR DELETE PurchaseOrder.

    "! Releases the Purchase Order.
    METHODS releaseDocument FOR MODIFY
      IMPORTING
                keys   FOR ACTION PurchaseOrder~releaseDocument
      RESULT    result.

    "! Cancels the Purchase Order.
    METHODS cancelDocument FOR MODIFY
      IMPORTING
                keys   FOR ACTION PurchaseOrder~cancelDocument
      RESULT    result.

    "! Sets default header values on document creation.
    METHODS setHeaderDefaults FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrder~setHeaderDefaults.

    "! Validates document date and delivery date consistency.
    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING
        keys FOR PurchaseOrder~validateDates.

    "! Validates mandatory header fields before saving.
    METHODS validateHeaderFields FOR VALIDATE ON SAVE
      IMPORTING
        keys FOR PurchaseOrder~validateHeaderFields.
ENDCLASS.

CLASS lhc_zmerp_r_purchaseorder IMPLEMENTATION.

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

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD precheck_delete.
  ENDMETHOD.

  METHOD releaseDocument.
  ENDMETHOD.

  METHOD cancelDocument.
  ENDMETHOD.

  METHOD setHeaderDefaults.
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( DocumentDate Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_generic_defaults) = zcl_merp_doc_util=>get_generic_header_defaults( ).
    DATA lt_update TYPE TABLE FOR UPDATE zmerp_r_purchaseorder.

    LOOP AT lt_headers REFERENCE INTO DATA(lr_header)
      WHERE DocumentDate IS INITIAL OR Status IS INITIAL.

      APPEND VALUE #(
        %tky         = lr_header->%tky
        DocumentDate = COND #( WHEN lr_header->DocumentDate IS INITIAL
                               THEN ls_generic_defaults-document_date
                               ELSE lr_header->DocumentDate )
        Status       = COND #( WHEN lr_header->Status IS INITIAL
                               THEN c_default_status
                               ELSE lr_header->Status )
      ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrder
        UPDATE FIELDS ( DocumentDate Status )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD validateHeaderFields.
    DATA lv_has_error TYPE abap_bool.

    " Clear previous validation messages for this state area to prevent duplicate errors in UI
    reported-purchaseorder = VALUE #(
      BASE reported-purchaseorder
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_state_area_header )
    ).

    " Read entity fields in local mode to bypass global authorization checks during validation
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( CompanyCode BusinessPartnerCode WarehouseCode CurrencyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_headers REFERENCE INTO DATA(lr_header).
      lv_has_error = abap_false.

      IF lr_header->CompanyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_header->%tky
          %state_area          = c_state_area_header
          %msg                 = NEW zcx_merp_po(
                                   textid   = zcx_merp_po=>select_company
                                   severity = if_abap_behv_message=>severity-error )
          %element-CompanyCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->BusinessPartnerCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                        = lr_header->%tky
          %state_area                 = c_state_area_header
          %msg                        = NEW zcx_merp_po(
                                          textid   = zcx_merp_po=>select_business_partner
                                          severity = if_abap_behv_message=>severity-error )
          %element-BusinessPartnerCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->WarehouseCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_header->%tky
          %state_area            = c_state_area_header
          %msg                   = NEW zcx_merp_po(
                                     textid   = zcx_merp_po=>select_warehouse
                                     severity = if_abap_behv_message=>severity-error )
          %element-WarehouseCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->CurrencyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_header->%tky
          %state_area           = c_state_area_header
          %msg                  = NEW zcx_merp_po(
                                    textid   = zcx_merp_po=>select_currency
                                    severity = if_abap_behv_message=>severity-error )
          %element-CurrencyCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lv_has_error = abap_true.
        " Mark entity instance as failed to prevent transaction commit
        APPEND VALUE #(
          %tky        = lr_header->%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-purchaseorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    DATA lv_has_error TYPE abap_bool.

    " Clear previous validation messages for this state area to prevent duplicate errors in UI
    reported-purchaseorder = VALUE #(
      BASE reported-purchaseorder
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_state_area_dates )
    ).

    " Read entity fields in local mode to bypass global authorization checks during validation
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( DocumentDate PostingDate DeliveryDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_headers REFERENCE INTO DATA(lr_header).
      lv_has_error = abap_false.

      IF lr_header->DocumentDate IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_header->%tky
          %state_area           = c_state_area_dates
          %msg                  = NEW zcx_merp_po(
                                    textid   = zcx_merp_po=>enter_document_date
                                    severity = if_abap_behv_message=>severity-error )
          %element-DocumentDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ELSEIF lr_header->DocumentDate > lv_today.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_header->%tky
          %state_area           = c_state_area_dates
          %msg                  = NEW zcx_merp_po(
                                    textid   = zcx_merp_po=>document_date_future_invalid
                                    severity = if_abap_behv_message=>severity-error )
          %element-DocumentDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->PostingDate IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_header->%tky
          %state_area          = c_state_area_dates
          %msg                 = NEW zcx_merp_po(
                                    textid   = zcx_merp_po=>enter_posting_date
                                    severity = if_abap_behv_message=>severity-error )
          %element-PostingDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ELSEIF lr_header->DocumentDate IS NOT INITIAL AND lr_header->PostingDate < lr_header->DocumentDate.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_header->%tky
          %state_area          = c_state_area_dates
          %msg                 = NEW zcx_merp_po(
                                    textid   = zcx_merp_po=>posting_date_sequence_invalid
                                    severity = if_abap_behv_message=>severity-error )
          %element-PostingDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->DeliveryDate IS NOT INITIAL.
        IF lr_header->DeliveryDate < lv_today.
          lv_has_error = abap_true.
          APPEND VALUE #(
            %tky                  = lr_header->%tky
            %state_area           = c_state_area_dates
            %msg                  = NEW zcx_merp_po(
                                      textid   = zcx_merp_po=>delivery_date_past_invalid
                                      severity = if_abap_behv_message=>severity-error )
            %element-DeliveryDate = if_abap_behv=>mk-on
          ) TO reported-purchaseorder.
        ENDIF.

        IF lr_header->DocumentDate IS NOT INITIAL AND lr_header->DeliveryDate < lr_header->DocumentDate.
          lv_has_error = abap_true.
          APPEND VALUE #(
            %tky                  = lr_header->%tky
            %state_area           = c_state_area_dates
            %msg                  = NEW zcx_merp_po(
                                      textid   = zcx_merp_po=>delivery_date_sequence_invalid
                                      severity = if_abap_behv_message=>severity-error )
            %element-DeliveryDate = if_abap_behv=>mk-on
          ) TO reported-purchaseorder.
        ENDIF.
      ENDIF.

      IF lv_has_error = abap_true.
        " Mark entity instance as failed to prevent transaction commit
        APPEND VALUE #(
          %tky        = lr_header->%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-purchaseorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


"! Local behavior handler for Purchase Order Item child entity.
CLASS lhc_zmerp_r_purchaseorderitm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_state_area_item TYPE string VALUE 'VALIDATE_ITEM'.

    "! Recalculates total header net and gross amounts.
    METHODS calculateHeaderTotals FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrderItem~calculateHeaderTotals.

    "! Calculates net, VAT, and gross amounts for the item.
    METHODS calculateItemAmounts FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrderItem~calculateItemAmounts.

    "! Sets item defaults (UoM, Price, VatCode) based on selected ItemCode.
    METHODS setItemDefaults FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrderItem~setItemDefaults.

    "! Validates mandatory item fields, prices, and quantities before saving.
    METHODS validateItemFields FOR VALIDATE ON SAVE
      IMPORTING
        keys FOR PurchaseOrderItem~validateItemFields.
ENDCLASS.

CLASS lhc_zmerp_r_purchaseorderitm IMPLEMENTATION.

  METHOD calculateHeaderTotals.
  ENDMETHOD.

  METHOD calculateItemAmounts.
  ENDMETHOD.

  METHOD setItemDefaults.
  ENDMETHOD.

  METHOD validateItemFields.
    DATA lv_has_error TYPE abap_bool.

    " Clear previous validation messages for this state area to prevent duplicate errors in UI
    reported-purchaseorderitem = VALUE #(
      BASE reported-purchaseorderitem
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_state_area_item )
    ).

    " Read entity fields in local mode to bypass global authorization checks during validation
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrderItem
      FIELDS ( ItemCode Quantity Price UnitOfMeasure VatCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_items REFERENCE INTO DATA(lr_item).
      lv_has_error = abap_false.

      IF lr_item->ItemCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky              = lr_item->%tky
          %state_area       = c_state_area_item
          %msg              = NEW zcx_merp_po(
                                textid   = zcx_merp_po=>select_item
                                severity = if_abap_behv_message=>severity-error )
          %element-ItemCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->Quantity <= 0.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky              = lr_item->%tky
          %state_area       = c_state_area_item
          %msg              = NEW zcx_merp_po(
                                textid   = zcx_merp_po=>quantity_must_be_positive
                                severity = if_abap_behv_message=>severity-error )
          %element-Quantity = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->Price <= 0.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky           = lr_item->%tky
          %state_area    = c_state_area_item
          %msg           = NEW zcx_merp_po(
                             textid   = zcx_merp_po=>price_must_be_positive
                             severity = if_abap_behv_message=>severity-error )
          %element-Price = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->UnitOfMeasure IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_item->%tky
          %state_area            = c_state_area_item
          %msg                   = NEW zcx_merp_po(
                                     textid   = zcx_merp_po=>select_unit_of_measure
                                     severity = if_abap_behv_message=>severity-error )
          %element-UnitOfMeasure = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->VatCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky              = lr_item->%tky
          %state_area       = c_state_area_item
          %msg              = NEW zcx_merp_po(
                                textid   = zcx_merp_po=>select_vat_code
                                severity = if_abap_behv_message=>severity-error )
          %element-VatCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lv_has_error = abap_true.
        " Mark entity instance as failed to prevent transaction commit
        APPEND VALUE #(
          %tky        = lr_item->%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-purchaseorderitem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
