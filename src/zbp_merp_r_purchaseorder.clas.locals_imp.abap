"! Local behavior handler for Purchase Order root entity.
CLASS lhc_zmerp_r_purchaseorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_state_area_header  TYPE string VALUE 'VALIDATE_HEADER',
      c_state_area_dates   TYPE string VALUE 'VALIDATE_DATES',
      c_status_new         TYPE zmerp_po_status VALUE 'N',
      c_status_approved    TYPE zmerp_po_status VALUE 'A',
      c_status_in_delivery TYPE zmerp_po_status VALUE 'P',
      c_status_completed   TYPE zmerp_po_status VALUE 'C',
      c_status_cancelled   TYPE zmerp_po_status VALUE 'X'.

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

    "! Keeps the currency of all items in sync with the header currency.
    METHODS syncItemCurrency FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrder~syncItemCurrency.

    "! Assigns the document number from the number range on first save.
    METHODS assignDocumentNumber FOR DETERMINE ON SAVE
      IMPORTING
        keys FOR PurchaseOrder~assignDocumentNumber.

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

    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    " Only saved (active) documents can be edited or processed; draft instances get no actions
    result = VALUE #(
      FOR header IN lt_headers
      LET lv_active = xsdbool( header-%is_draft = if_abap_behv=>mk-off )
          lv_new    = xsdbool( header-Status = c_status_new )
          lv_open   = xsdbool( header-Status = c_status_new OR header-Status = c_status_approved ) IN
      ( %tky                    = header-%tky
        %action-Edit            = COND #( WHEN lv_active = abap_true AND lv_new = abap_true
                                          THEN if_abap_behv=>fc-o-enabled
                                          ELSE if_abap_behv=>fc-o-disabled )
        %action-releaseDocument = COND #( WHEN lv_active = abap_true AND lv_new = abap_true
                                          THEN if_abap_behv=>fc-o-enabled
                                          ELSE if_abap_behv=>fc-o-disabled )
        %action-cancelDocument  = COND #( WHEN lv_active = abap_true AND lv_open = abap_true
                                          THEN if_abap_behv=>fc-o-enabled
                                          ELSE if_abap_behv=>fc-o-disabled ) )
    ).
  ENDMETHOD.

  METHOD precheck_delete.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    TYPES: BEGIN OF ty_key,
             documentuuid TYPE sysuuid_x16,
           END OF ty_key.

    TYPES: BEGIN OF ty_dependency,
             documentuuid TYPE sysuuid_x16,
             usedinentity TYPE zmerp_entity_name,
           END OF ty_dependency.

    DATA lt_keys TYPE SORTED TABLE OF ty_key WITH NON-UNIQUE KEY documentuuid.
    DATA lt_dependencies TYPE SORTED TABLE OF ty_dependency WITH NON-UNIQUE KEY documentuuid.
    DATA lv_failed_added TYPE abap_bool.

    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    lt_keys = VALUE #( FOR hdr IN lt_headers WHERE ( documentuuid IS NOT INITIAL ) ( documentuuid = hdr-documentuuid ) ).
    DELETE ADJACENT DUPLICATES FROM lt_keys COMPARING documentuuid.

    IF lt_keys IS NOT INITIAL.
      SELECT DISTINCT
             usage~DocumentUUID AS documentuuid,
             usage~UsedInEntity AS usedinentity
        FROM zmerp_i_purchaseorder_usage AS usage
        INNER JOIN @lt_keys AS key ON usage~DocumentUUID = key~documentuuid
        INTO TABLE @lt_dependencies.
    ENDIF.

    LOOP AT lt_headers REFERENCE INTO DATA(lr_hdr).
      lv_failed_added = abap_false.

      " Lifecycle status check: allow deletion only for new or cancelled documents
      IF lr_hdr->status <> c_status_new AND lr_hdr->status <> c_status_cancelled.
        APPEND VALUE #(
          %tky        = lr_hdr->%tky
          %fail-cause = if_abap_behv=>cause-conflict
        ) TO failed-purchaseorder.

        APPEND VALUE #(
          %tky = lr_hdr->%tky
          %msg = NEW zcx_merp_pur(
                   textid   = zcx_merp_pur=>delete_not_allowed
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-purchaseorder.
        CONTINUE.
      ENDIF.

      " Database dependency check
      LOOP AT lt_dependencies REFERENCE INTO DATA(lr_dep)
        WHERE documentuuid = lr_hdr->documentuuid.

        IF lv_failed_added = abap_false.
          APPEND VALUE #(
            %tky        = lr_hdr->%tky
            %fail-cause = if_abap_behv=>cause-dependency
          ) TO failed-purchaseorder.
          lv_failed_added = abap_true.
        ENDIF.

        APPEND VALUE #(
          %tky            = lr_hdr->%tky
          %element-status = if_abap_behv=>mk-on
          %msg            = NEW zcx_merp_pur(
                               textid   = zcx_merp_pur=>purchase_order_in_use
                               attr1    = CONV #( lr_hdr->documentuuid )
                               attr2    = CONV #( lr_dep->usedinentity )
                               severity = if_abap_behv_message=>severity-error )
        ) TO reported-purchaseorder.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD releaseDocument.
    DATA lt_update  TYPE TABLE FOR UPDATE zmerp_r_purchaseorder.
    DATA lo_message TYPE REF TO zcx_merp_pur.

    " Bulk read: headers and links to their items (needed only to check that items exist)
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers)
      ENTITY PurchaseOrder BY \_Items
        FIELDS ( ItemNo )
        WITH CORRESPONDING #( keys )
        LINK DATA(lt_links).

    LOOP AT lt_headers REFERENCE INTO DATA(lr_header).
      CLEAR lo_message.

      IF lr_header->Status <> c_status_new.
        lo_message = NEW #( textid   = zcx_merp_pur=>release_not_allowed
                            severity = if_abap_behv_message=>severity-error ).
      ELSEIF NOT line_exists( lt_links[ source-%tky = lr_header->%tky ] ).
        lo_message = NEW #( textid   = zcx_merp_pur=>document_empty_items_invalid
                            severity = if_abap_behv_message=>severity-error ).
      ENDIF.

      IF lo_message IS BOUND.
        APPEND VALUE #(
          %tky        = lr_header->%tky
          %fail-cause = if_abap_behv=>cause-conflict
        ) TO failed-purchaseorder.

        APPEND VALUE #(
          %tky                    = lr_header->%tky
          %msg                    = lo_message
          %action-releaseDocument = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ELSE.
        APPEND VALUE #(
          %tky   = lr_header->%tky
          Status = c_status_approved
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrder
        UPDATE FIELDS ( Status )
        WITH lt_update.
    ENDIF.

    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR header IN lt_result ( %tky = header-%tky %param = header ) ).
  ENDMETHOD.

  METHOD cancelDocument.
    DATA lt_update  TYPE TABLE FOR UPDATE zmerp_r_purchaseorder.
    DATA lo_message TYPE REF TO zcx_merp_pur.

    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers REFERENCE INTO DATA(lr_header).
      " Only New or Approved documents can be cancelled (receipts started or finished -> no)
      IF lr_header->Status <> c_status_new AND lr_header->Status <> c_status_approved.
        APPEND VALUE #(
          %tky        = lr_header->%tky
          %fail-cause = if_abap_behv=>cause-conflict
        ) TO failed-purchaseorder.

        APPEND VALUE #(
          %tky                   = lr_header->%tky
          %msg                   = NEW zcx_merp_pur(
                                     textid   = zcx_merp_pur=>cancel_not_allowed
                                     severity = if_abap_behv_message=>severity-error )
          %action-cancelDocument = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ELSE.
        APPEND VALUE #(
          %tky   = lr_header->%tky
          Status = c_status_cancelled
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrder
        UPDATE FIELDS ( Status )
        WITH lt_update.
    ENDIF.

    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR header IN lt_result ( %tky = header-%tky %param = header ) ).
  ENDMETHOD.

  METHOD setHeaderDefaults.
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( CompanyCode WarehouseCode CurrencyCode DocumentDate PostingDate Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_generic_defaults) = zcl_merp_doc_util=>get_generic_header_defaults( ).
    DATA lt_update TYPE TABLE FOR UPDATE zmerp_r_purchaseorder.

    " Master data for all affected headers: one selector call per entity
    DATA(lt_company_keys) = VALUE zif_merp_md_comp_code_sel=>tt_company_keys(
      FOR header IN lt_headers WHERE ( CompanyCode IS NOT INITIAL )
      ( CompanyCode = header-CompanyCode )
    ).
    DATA(lt_warehouse_keys) = VALUE zif_merp_md_warehouse_sel=>tt_warehouse_keys(
      FOR header IN lt_headers WHERE ( WarehouseCode IS NOT INITIAL )
      ( WarehouseCode = header-WarehouseCode )
    ).

    DATA(lt_companies) = COND #(
      WHEN lt_company_keys IS NOT INITIAL
      THEN NEW zcl_merp_md_comp_code_sel( )->zif_merp_md_comp_code_sel~read_companies( lt_company_keys ) ).
    DATA(lt_warehouses) = COND #(
      WHEN lt_warehouse_keys IS NOT INITIAL
      THEN NEW zcl_merp_md_warehouse_sel( )->zif_merp_md_warehouse_sel~read_warehouses( lt_warehouse_keys ) ).

    LOOP AT lt_headers ASSIGNING FIELD-SYMBOL(<header>).
      DATA(ls_header) = <header>.

      IF ls_header-DocumentDate IS INITIAL.
        ls_header-DocumentDate = ls_generic_defaults-document_date.
      ENDIF.

      IF ls_header-PostingDate IS INITIAL.
        ls_header-PostingDate = ls_header-DocumentDate.
      ENDIF.

      IF ls_header-Status IS INITIAL.
        ls_header-Status = c_status_new.
      ENDIF.

      IF ls_header-CompanyCode IS NOT INITIAL.
        " Document currency follows the company code
        ASSIGN lt_companies[ CompanyCode = ls_header-CompanyCode ] TO FIELD-SYMBOL(<company>).
        IF sy-subrc = 0 AND <company>-CurrencyCode IS NOT INITIAL.
          ls_header-CurrencyCode = <company>-CurrencyCode.
        ENDIF.

        " Warehouse must belong to the selected company code
        IF ls_header-WarehouseCode IS NOT INITIAL.
          ASSIGN lt_warehouses[ WarehouseCode = ls_header-WarehouseCode ] TO FIELD-SYMBOL(<warehouse>).
          IF sy-subrc <> 0 OR <warehouse>-CompanyCode <> ls_header-CompanyCode.
            CLEAR ls_header-WarehouseCode.
          ENDIF.
        ENDIF.
      ENDIF.

      " Update only instances that really changed
      IF ls_header <> <header>.
        APPEND CORRESPONDING #( ls_header ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrder
        UPDATE FIELDS ( DocumentDate PostingDate Status CurrencyCode WarehouseCode )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD syncItemCurrency.
    DATA lt_update TYPE TABLE FOR UPDATE zmerp_r_purchaseorder\\PurchaseOrderItem.

    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers)
      ENTITY PurchaseOrder BY \_Items
        FIELDS ( HeaderUUID Currency )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items).

    LOOP AT lt_items REFERENCE INTO DATA(lr_item).
      ASSIGN lt_headers[ DocumentUUID = lr_item->HeaderUUID ] TO FIELD-SYMBOL(<header>).
      IF sy-subrc = 0 AND lr_item->Currency <> <header>-CurrencyCode.
        APPEND VALUE #(
          %tky     = lr_item->%tky
          Currency = <header>-CurrencyCode
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrderItem
        UPDATE FIELDS ( Currency )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD assignDocumentNumber.
*    DATA lx_nro_error TYPE REF TO cx_root.
*    DATA lt_numbers   TYPE string_table.
*
*    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
*      ENTITY PurchaseOrder
*      FIELDS ( DocumentNumber )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_headers).
*
*    DELETE lt_headers WHERE DocumentNumber IS NOT INITIAL.
*
*    IF lt_headers IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    " Bulk allocation via NRO utility with exception capture
*    TRY.
*        lt_numbers = zcl_merp_num_range_util=>get_next_po_( iv_count = lines( lt_headers ) ).
*      CATCH cx_number_ranges cx_root INTO lx_nro_error.
*        CLEAR lt_numbers.
*    ENDTRY.
*
*    IF lines( lt_numbers ) <> lines( lt_headers ).
*      failed-purchaseorder = VALUE #(
*        BASE failed-purchaseorder
*        FOR header IN lt_headers
*        ( %tky        = header-%tky
*          %fail-cause = if_abap_behv=>cause-unspecific )
*      ).
*
*      reported-purchaseorder = VALUE #(
*        BASE reported-purchaseorder
*        FOR header IN lt_headers
*        ( %tky = header-%tky
*          %msg = NEW zcx_merp_pur(
*                   textid   = zcx_merp_pur=>document_number_failed
*                   previous = lx_nro_error
*                   severity = if_abap_behv_message=>severity-error ) )
*      ).
*      RETURN.
*    ENDIF.
*
*    MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
*      ENTITY PurchaseOrder
*      UPDATE FIELDS ( DocumentNumber )
*      WITH VALUE #(
*        FOR header IN lt_headers INDEX INTO lv_index
*        ( %tky           = header-%tky
*          DocumentNumber = lt_numbers[ lv_index ] )
*      ).
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
          %msg                 = NEW zcx_merp_pur(
                                   textid   = zcx_merp_pur=>select_company
                                   severity = if_abap_behv_message=>severity-error )
          %element-CompanyCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->BusinessPartnerCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                         = lr_header->%tky
          %state_area                  = c_state_area_header
          %msg                         = NEW zcx_merp_pur(
                                           textid   = zcx_merp_pur=>select_business_partner
                                           severity = if_abap_behv_message=>severity-error )
          %element-BusinessPartnerCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->WarehouseCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_header->%tky
          %state_area            = c_state_area_header
          %msg                   = NEW zcx_merp_pur(
                                     textid   = zcx_merp_pur=>select_warehouse
                                     severity = if_abap_behv_message=>severity-error )
          %element-WarehouseCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->CurrencyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_header->%tky
          %state_area           = c_state_area_header
          %msg                  = NEW zcx_merp_pur(
                                    textid   = zcx_merp_pur=>select_currency
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
      FIELDS ( DocumentDate PostingDate DeliveryDate Status )
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
          %msg                  = NEW zcx_merp_pur(
                                    textid   = zcx_merp_pur=>enter_document_date
                                    severity = if_abap_behv_message=>severity-error )
          %element-DocumentDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ELSEIF lr_header->DocumentDate > lv_today.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_header->%tky
          %state_area           = c_state_area_dates
          %msg                  = NEW zcx_merp_pur(
                                    textid   = zcx_merp_pur=>document_date_future_invalid
                                    severity = if_abap_behv_message=>severity-error )
          %element-DocumentDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->PostingDate IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_header->%tky
          %state_area          = c_state_area_dates
          %msg                 = NEW zcx_merp_pur(
                                   textid   = zcx_merp_pur=>enter_posting_date
                                   severity = if_abap_behv_message=>severity-error )
          %element-PostingDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ELSEIF lr_header->DocumentDate IS NOT INITIAL AND lr_header->PostingDate < lr_header->DocumentDate.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                 = lr_header->%tky
          %state_area          = c_state_area_dates
          %msg                 = NEW zcx_merp_pur(
                                   textid   = zcx_merp_pur=>posting_date_sequence_invalid
                                   severity = if_abap_behv_message=>severity-error )
          %element-PostingDate = if_abap_behv=>mk-on
        ) TO reported-purchaseorder.
      ENDIF.

      IF lr_header->DeliveryDate IS NOT INITIAL.
        " Past delivery date is only an error while the document is still New,
        " otherwise later status changes (approve, receipts) would be blocked
        IF lr_header->Status = c_status_new AND lr_header->DeliveryDate < lv_today.
          lv_has_error = abap_true.
          APPEND VALUE #(
            %tky                  = lr_header->%tky
            %state_area           = c_state_area_dates
            %msg                  = NEW zcx_merp_pur(
                                      textid   = zcx_merp_pur=>delivery_date_past_invalid
                                      severity = if_abap_behv_message=>severity-error )
            %element-DeliveryDate = if_abap_behv=>mk-on
          ) TO reported-purchaseorder.
        ENDIF.

*        IF lr_header->DocumentDate IS NOT INITIAL AND lr_header->DeliveryDate < lr_header->DocumentDate.
*          lv_has_error = abap_true.
*          APPEND VALUE #(
*            %tky                  = lr_header->%tky
*            %state_area           = c_state_area_dates
*            %msg                  = NEW zcx_merp_pur(
*                                      textid   = zcx_merp_pur=>delivery_date_sequence_invalid
*                                      severity = if_abap_behv_message=>severity-error )
*            %element-DeliveryDate = if_abap_behv=>mk-on
*          ) TO reported-purchaseorder.
*        ENDIF.
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
      c_state_area_item TYPE string VALUE 'VALIDATE_ITEM',
      c_item_no_step    TYPE i VALUE 10.

    "! Recalculates total header net and gross amounts.
    METHODS calculateHeaderTotals FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrderItem~calculateHeaderTotals.

    "! Calculates net, VAT, and gross amounts for the item.
    METHODS calculateItemAmounts FOR DETERMINE ON MODIFY
      IMPORTING
        keys FOR PurchaseOrderItem~calculateItemAmounts.

    "! Sets item defaults (ItemNo, Currency, UoM, VatCode) based on header and selected ItemCode.
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
    " Read parent headers of the changed (or deleted) items
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrderItem BY \_PurchaseOrder
      FIELDS ( DocumentUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    IF lt_headers IS INITIAL.
      RETURN.
    ENDIF.

    " Read all items of those headers in one call
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder BY \_Items
      FIELDS ( HeaderUUID NetAmount GrossAmount )
      WITH CORRESPONDING #( lt_headers )
      RESULT DATA(lt_items).

    MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder
      UPDATE FIELDS ( TotalNetAmount TotalGrossAmount )
      WITH VALUE #(
        FOR header IN lt_headers
        ( %tky             = header-%tky
          TotalNetAmount   = REDUCE zmerp_net_amount(
                               INIT sum = CONV zmerp_net_amount( 0 )
                               FOR item IN lt_items WHERE ( HeaderUUID = header-DocumentUUID )
                               NEXT sum = sum + item-NetAmount )
          TotalGrossAmount = REDUCE zmerp_gross_amount(
                               INIT sum = CONV zmerp_gross_amount( 0 )
                               FOR item IN lt_items WHERE ( HeaderUUID = header-DocumentUUID )
                               NEXT sum = sum + item-GrossAmount ) )
      ).
  ENDMETHOD.

  METHOD calculateItemAmounts.
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrderItem
      FIELDS ( Quantity Price VatCode NetAmount VatAmount GrossAmount )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    IF lt_items IS INITIAL.
      RETURN.
    ENDIF.

    " Read VAT percentages for all used VAT codes in one selector call
    DATA(lt_vat_keys) = VALUE zif_merp_md_vat_rate_sel=>tt_vat_rate_keys(
      FOR item IN lt_items WHERE ( VatCode IS NOT INITIAL )
      ( VatCode = item-VatCode )
    ).
    DATA(lt_vat_rates) = COND #(
      WHEN lt_vat_keys IS NOT INITIAL
      THEN NEW zcl_merp_md_vat_rate_sel( )->zif_merp_md_vat_rate_sel~read_vat_rates( lt_vat_keys ) ).

    DATA lt_update TYPE TABLE FOR UPDATE zmerp_r_purchaseorder\\PurchaseOrderItem.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>).
      DATA(ls_item) = <item>.

      ASSIGN lt_vat_rates[ VatCode = ls_item-VatCode ] TO FIELD-SYMBOL(<vat_rate>).
      DATA(lv_percentage) = COND decfloat34( WHEN sy-subrc = 0 THEN <vat_rate>-Percentage ELSE 0 ).

      ls_item-NetAmount   = ls_item-Quantity * ls_item-Price.
      ls_item-VatAmount   = ls_item-NetAmount * lv_percentage / 100.
      ls_item-GrossAmount = ls_item-NetAmount + ls_item-VatAmount.

      " Update only instances that really changed
      IF ls_item <> <item>.
        APPEND CORRESPONDING #( ls_item ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrderItem
        UPDATE FIELDS ( NetAmount VatAmount GrossAmount )
        WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD setItemDefaults.
    TYPES: BEGIN OF ty_counter,
             header_uuid TYPE sysuuid_x16,
             last_no     TYPE i,
           END OF ty_counter.

    DATA lt_counters TYPE HASHED TABLE OF ty_counter WITH UNIQUE KEY header_uuid.
    DATA lt_update   TYPE TABLE FOR UPDATE zmerp_r_purchaseorder\\PurchaseOrderItem.

    " Items and their parent headers (document currency)
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrderItem
        FIELDS ( HeaderUUID ItemNo ItemCode UnitOfMeasure VatCode Currency )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items)
      ENTITY PurchaseOrderItem BY \_PurchaseOrder
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers).

    IF lt_items IS INITIAL.
      RETURN.
    ENDIF.

    " All items of the affected documents: highest used item number per document
    READ ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
      ENTITY PurchaseOrder BY \_Items
      FIELDS ( HeaderUUID ItemNo )
      WITH CORRESPONDING #( lt_headers )
      RESULT DATA(lt_siblings).

    LOOP AT lt_siblings REFERENCE INTO DATA(lr_sibling).
      ASSIGN lt_counters[ header_uuid = lr_sibling->HeaderUUID ] TO FIELD-SYMBOL(<counter>).
      IF sy-subrc <> 0.
        INSERT VALUE #( header_uuid = lr_sibling->HeaderUUID )
          INTO TABLE lt_counters ASSIGNING <counter>.
      ENDIF.

      IF lr_sibling->ItemNo > <counter>-last_no.
        <counter>-last_no = lr_sibling->ItemNo.
      ENDIF.
    ENDLOOP.

    " Item master data for all selected item codes in one selector call
    DATA(lt_item_keys) = VALUE zif_merp_md_item_sel=>tt_item_keys(
      FOR item IN lt_items WHERE ( ItemCode IS NOT INITIAL )
      ( ItemCode = item-ItemCode )
    ).
    DATA(lt_item_master) = COND #(
      WHEN lt_item_keys IS NOT INITIAL
      THEN NEW zcl_merp_md_item_sel( )->zif_merp_md_item_sel~read_items( lt_item_keys ) ).

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>).
      DATA(ls_item) = <item>.

      " Next free item number within the document
      IF ls_item-ItemNo IS INITIAL.
        ASSIGN lt_counters[ header_uuid = ls_item-HeaderUUID ] TO <counter>.
        IF sy-subrc = 0.
          <counter>-last_no += c_item_no_step.
          ls_item-ItemNo     = <counter>-last_no.
        ENDIF.
      ENDIF.

      " Item currency follows the document currency
      IF ls_item-Currency IS INITIAL.
        ASSIGN lt_headers[ DocumentUUID = ls_item-HeaderUUID
                           %is_draft    = ls_item-%is_draft ] TO FIELD-SYMBOL(<header>).
        IF sy-subrc = 0.
          ls_item-Currency = <header>-CurrencyCode.
        ENDIF.
      ENDIF.

      " UoM and VAT code are inherited from the item master
      IF ls_item-ItemCode IS NOT INITIAL.
        ASSIGN lt_item_master[ ItemCode = ls_item-ItemCode ] TO FIELD-SYMBOL(<master>).
        IF sy-subrc = 0.
          ls_item-UnitOfMeasure = <master>-BaseUnitOfMeasure.
          ls_item-VatCode       = <master>-DefaultVatCode.
        ENDIF.
      ENDIF.

      " Update only instances that really changed
      IF ls_item <> <item>.
        APPEND CORRESPONDING #( ls_item ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zmerp_r_purchaseorder IN LOCAL MODE
        ENTITY PurchaseOrderItem
        UPDATE FIELDS ( ItemNo Currency UnitOfMeasure VatCode )
        WITH lt_update.
    ENDIF.
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
          %msg              = NEW zcx_merp_pur(
                                textid   = zcx_merp_pur=>select_item
                                severity = if_abap_behv_message=>severity-error )
          %element-ItemCode = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->Quantity <= 0.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky              = lr_item->%tky
          %state_area       = c_state_area_item
          %msg              = NEW zcx_merp_pur(
                                textid   = zcx_merp_pur=>quantity_must_be_positive
                                severity = if_abap_behv_message=>severity-error )
          %element-Quantity = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->Price <= 0.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky           = lr_item->%tky
          %state_area    = c_state_area_item
          %msg           = NEW zcx_merp_pur(
                             textid   = zcx_merp_pur=>price_must_be_positive
                             severity = if_abap_behv_message=>severity-error )
          %element-Price = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->UnitOfMeasure IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_item->%tky
          %state_area            = c_state_area_item
          %msg                   = NEW zcx_merp_pur(
                                     textid   = zcx_merp_pur=>select_unit_of_measure
                                     severity = if_abap_behv_message=>severity-error )
          %element-UnitOfMeasure = if_abap_behv=>mk-on
        ) TO reported-purchaseorderitem.
      ENDIF.

      IF lr_item->VatCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky             = lr_item->%tky
          %state_area      = c_state_area_item
          %msg             = NEW zcx_merp_pur(
                               textid   = zcx_merp_pur=>select_vat_code
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

