"! Purchase order selector. All methods read persisted (active) data only:
"! drafts and unsaved changes are not visible. Inside the purchase order's own
"! handlers use READ ENTITIES ... IN LOCAL MODE instead.
INTERFACE zif_merp_doc_po_sel
  PUBLIC.

  TYPES ty_header TYPE zmerp_r_purchaseorder.
  TYPES ty_item   TYPE zmerp_r_purchaseorderitm.
  TYPES ty_po_progress TYPE zmerp_i_po_progress.

  TYPES tt_headers TYPE SORTED TABLE OF ty_header WITH UNIQUE KEY DocumentUUID.
  TYPES tt_items   TYPE SORTED TABLE OF ty_item   WITH UNIQUE KEY ItemUUID
                                                  WITH NON-UNIQUE SORTED KEY ByHeader COMPONENTS HeaderUUID.
  TYPES tt_progress TYPE SORTED TABLE OF ty_po_progress WITH UNIQUE KEY PoItemUUID
                                                        WITH NON-UNIQUE SORTED KEY ByHeader COMPONENTS PoHeaderUUID.

  "! Deep structure representing a single complete document
  TYPES: BEGIN OF ty_document,
           header TYPE ty_header,
           items  TYPE tt_items,
         END OF ty_document.

  TYPES: BEGIN OF ty_document_key,
           DocumentUUID TYPE zmerp_r_purchaseorder-DocumentUUID,
         END OF ty_document_key,
         tt_document_keys TYPE STANDARD TABLE OF ty_document_key WITH EMPTY KEY,
         tt_document_keys_sorted TYPE SORTED TABLE OF ty_document_key WITH UNIQUE KEY DocumentUUID.

  TYPES: BEGIN OF ty_usage,
           DocumentUUID TYPE zmerp_r_purchaseorder-DocumentUUID,
           UsedInEntity TYPE zmerp_entity_name,
         END OF ty_usage,
         tt_usages TYPE SORTED TABLE OF ty_usage WITH UNIQUE KEY DocumentUUID UsedInEntity.

  "! Reads the header of a single purchase order (without items)
  "! @parameter iv_document_uuid | Requested purchase order document key
  "! @parameter rs_header        | Returned header data structure
  "! @raising zcx_merp_pur       | Raised if the requested purchase order does not exist
  METHODS read_header
    IMPORTING iv_document_uuid TYPE zmerp_r_purchaseorder-DocumentUUID
    RETURNING VALUE(rs_header) TYPE ty_header
    RAISING   zcx_merp_pur.

  "! Reads headers of a list of purchase orders (without items)
  "! @parameter it_document_keys | Table of purchase order document keys
  "! @parameter rt_headers       | Sorted table of existing purchase order headers data
  METHODS read_headers
    IMPORTING it_document_keys  TYPE tt_document_keys
    RETURNING VALUE(rt_headers) TYPE tt_headers.

  "! Reads a single purchase order document with its items
  "! @parameter iv_document_uuid | Requested purchase order document key
  "! @parameter rs_document      | Returned complete document data structure (Header + Items)
  "! @raising zcx_merp_pur       | Raised if the requested purchase order does not exist
  METHODS read_document
    IMPORTING iv_document_uuid TYPE zmerp_r_purchaseorder-DocumentUUID
    RETURNING VALUE(rs_document) TYPE ty_document
    RAISING   zcx_merp_pur.

  "! Reads a list of purchase orders with their items
  "! @parameter it_document_keys | Table of purchase order document keys
  "! @parameter et_headers       | Sorted table of existing purchase order headers data
  "! @parameter et_items         | Sorted table of all existing related items data
  METHODS read_documents
    IMPORTING it_document_keys TYPE tt_document_keys
    EXPORTING et_headers       TYPE tt_headers
              et_items         TYPE tt_items.

  "! Reads the receipt progress (ordered / received / open quantity and amounts) of all items of the given purchase orders
  "! @parameter it_document_keys | Table of purchase order document keys
  "! @parameter rt_progress      | Sorted table of progress rows (one row per purchase order item)
  METHODS read_progress
    IMPORTING it_document_keys   TYPE tt_document_keys
    RETURNING VALUE(rt_progress) TYPE tt_progress.

  "! Returns the purchase orders that have at least one posted goods receipt
  "! @parameter it_document_keys  | Table of purchase order document keys
  "! @parameter rt_document_keys  | Purchase orders with a received quantity on at least one item
  METHODS read_received_documents
    IMPORTING it_document_keys        TYPE tt_document_keys
    RETURNING VALUE(rt_document_keys) TYPE tt_document_keys_sorted.

  "! Reads where the given purchase orders are used (usage view): one row per document and using entity.
  "! Documents that are not used are not returned.
  "! @parameter it_document_keys | Keys to check
  "! @parameter rt_usages        | Documents in use with the entity that uses them
  METHODS read_usages
    IMPORTING it_document_keys TYPE tt_document_keys
    RETURNING VALUE(rt_usages) TYPE tt_usages.

  "! Validates purchase order document keys and returns missing/invalid keys
  "! @parameter it_document_keys | Table of purchase order document keys to validate
  "! @parameter rt_invalid_keys  | Table containing only keys that do not exist in DB
  METHODS validate_documents
    IMPORTING it_document_keys       TYPE tt_document_keys
    RETURNING VALUE(rt_invalid_keys) TYPE tt_document_keys.

ENDINTERFACE.
