"! Goods Receipt lifecycle rules (status model and allowed operations).
"! Pure business logic without RAP dependencies.
CLASS zcl_merp_doc_gr_lifecycle DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CONSTANTS:
      " Goods Receipt lifecycle statuses
      c_status_new       TYPE zmerp_gr_status VALUE 'N',
      c_status_posted    TYPE zmerp_gr_status VALUE 'P',
      c_status_cancelled TYPE zmerp_gr_status VALUE 'X'.

    "! Only documents in 'New' status can be edited
    CLASS-METHODS can_edit
      IMPORTING iv_status         TYPE zmerp_gr_status
      RETURNING VALUE(rv_allowed) TYPE abap_bool.

    "! Only documents in 'New' status can be posted
    CLASS-METHODS can_post
      IMPORTING iv_status         TYPE zmerp_gr_status
      RETURNING VALUE(rv_allowed) TYPE abap_bool.

    "! Only 'New' or 'Posted' documents can be cancelled
    CLASS-METHODS can_cancel
      IMPORTING iv_status         TYPE zmerp_gr_status
      RETURNING VALUE(rv_allowed) TYPE abap_bool.

    "! Deletion is allowed only for 'New' or 'Cancelled' documents
    CLASS-METHODS can_delete
      IMPORTING iv_status         TYPE zmerp_gr_status
      RETURNING VALUE(rv_allowed) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_merp_doc_gr_lifecycle IMPLEMENTATION.

  METHOD can_edit.
    rv_allowed = xsdbool( iv_status = c_status_new ).
  ENDMETHOD.

  METHOD can_post.
    rv_allowed = xsdbool( iv_status = c_status_new ).
  ENDMETHOD.

  METHOD can_cancel.
    rv_allowed = xsdbool( iv_status = c_status_new OR iv_status = c_status_posted ).
  ENDMETHOD.

  METHOD can_delete.
    rv_allowed = xsdbool( iv_status = c_status_new OR iv_status = c_status_cancelled ).
  ENDMETHOD.

ENDCLASS.
