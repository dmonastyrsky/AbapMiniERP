CLASS zcl_merp_md_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_item_group_default_vat
      IMPORTING
        iv_item_group_code TYPE zmerp_item_group_code
      RETURNING
        VALUE(rv_vat_code) TYPE zmerp_vat_code.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_merp_md_util IMPLEMENTATION.

  METHOD get_item_group_default_vat.
    IF iv_item_group_code IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE default_vat_code
      FROM zmerp_item_group
      WHERE item_group_code = @iv_item_group_code
      INTO @rv_vat_code.
  ENDMETHOD.

ENDCLASS.
