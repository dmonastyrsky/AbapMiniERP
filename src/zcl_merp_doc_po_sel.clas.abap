CLASS zcl_merp_doc_po_sel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_merp_doc_po_sel.

  PRIVATE SECTION.
    TYPES tt_document_keys_unique TYPE HASHED TABLE OF zif_merp_doc_po_sel=>ty_document_key
                                       WITH UNIQUE KEY DocumentUUID.

    "! Selects items of the given documents. Keys must be unique (already existing documents).
    "! @parameter it_document_keys | Unique technical keys of existing documents
    "! @parameter rt_items         | Sorted table of all related items data
    METHODS select_items
      IMPORTING it_document_keys TYPE zif_merp_doc_po_sel=>tt_document_keys
      RETURNING VALUE(rt_items)  TYPE zif_merp_doc_po_sel=>tt_items.

    "! Cleanses, sorts and removes duplicates from input document keys
    "! @parameter it_keys | Raw table of technical keys
    "! @parameter rt_keys | Processed clean table of technical keys
    METHODS prepare_keys
      IMPORTING it_keys        TYPE zif_merp_doc_po_sel=>tt_document_keys
      RETURNING VALUE(rt_keys) TYPE zif_merp_doc_po_sel=>tt_document_keys.
ENDCLASS.


CLASS zcl_merp_doc_po_sel IMPLEMENTATION.

  METHOD zif_merp_doc_po_sel~read_header.
    DATA(lt_headers) = zif_merp_doc_po_sel~read_headers(
      VALUE #( ( DocumentUUID = iv_document_uuid ) )
    ).

    " An initial key is dropped by prepare_keys, so this one check also covers empty input
    TRY.
        rs_header = lt_headers[ DocumentUUID = iv_document_uuid ].
      CATCH cx_sy_itab_line_not_found.
        RAISE EXCEPTION TYPE zcx_merp_pur
          EXPORTING
            textid   = zcx_merp_pur=>purchase_order_not_found
            severity = if_abap_behv_message=>severity-error.
    ENDTRY.
  ENDMETHOD.


  METHOD zif_merp_doc_po_sel~read_headers.
    DATA(lt_clean_keys) = prepare_keys( it_document_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    " ty_header is derived from the same view, so INTO TABLE (without CORRESPONDING)
    " makes any structure mismatch visible at compile time instead of silently skipping fields
    SELECT FROM zmerp_r_purchaseorder AS po
      INNER JOIN @lt_clean_keys AS keys ON po~DocumentUUID = keys~DocumentUUID
      FIELDS po~*
      INTO TABLE @rt_headers.
  ENDMETHOD.


  METHOD zif_merp_doc_po_sel~read_document.
    " Raises if the purchase order does not exist
    rs_document-header = zif_merp_doc_po_sel~read_header( iv_document_uuid ).
    rs_document-items  = select_items( VALUE #( ( DocumentUUID = iv_document_uuid ) ) ).
  ENDMETHOD.


  METHOD zif_merp_doc_po_sel~read_documents.
    CLEAR: et_headers, et_items.

    et_headers = zif_merp_doc_po_sel~read_headers( it_document_keys ).
    IF et_headers IS INITIAL.
      RETURN.
    ENDIF.

    " Items are read only for headers that really exist
    et_items = select_items(
      VALUE #( FOR header IN et_headers ( DocumentUUID = header-DocumentUUID ) )
    ).
  ENDMETHOD.


  METHOD zif_merp_doc_po_sel~validate_documents.
    DATA lt_existing_keys TYPE tt_document_keys_unique.

    DATA(lt_clean_keys) = prepare_keys( it_document_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT po~DocumentUUID
      FROM zmerp_r_purchaseorder AS po
      INNER JOIN @lt_clean_keys AS keys ON po~DocumentUUID = keys~DocumentUUID
      INTO TABLE @lt_existing_keys.

    LOOP AT lt_clean_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF NOT line_exists( lt_existing_keys[ DocumentUUID = <ls_key>-DocumentUUID ] ).
        INSERT <ls_key> INTO TABLE rt_invalid_keys.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD select_items.
    " ty_item is derived from the same view, see the comment in read_headers
    SELECT FROM zmerp_r_purchaseorderitm AS itm
      INNER JOIN @it_document_keys AS keys ON itm~HeaderUUID = keys~DocumentUUID
      FIELDS itm~*
      INTO TABLE @rt_items.
  ENDMETHOD.


  METHOD prepare_keys.
    rt_keys = it_keys.
    DELETE rt_keys WHERE DocumentUUID IS INITIAL.
    SORT rt_keys BY DocumentUUID.
    DELETE ADJACENT DUPLICATES FROM rt_keys COMPARING DocumentUUID.
  ENDMETHOD.

ENDCLASS.
