"! Sales messages (Sales Order, Goods Issue and the link between them).
"! Messages shared by all documents are defined in ZCX_MERP_DOC.
CLASS zcx_merp_sd DEFINITION
  PUBLIC
  INHERITING FROM zcx_merp_doc
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      " --- Business Partner (123) ---
      " &1 = business partner code
      BEGIN OF bp_is_not_customer,
        msgid TYPE symsgid VALUE 'ZMC_MERP_DOC',
        msgno TYPE symsgno VALUE '123',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF bp_is_not_customer,

      " --- Sales Order Status (138) ---
      " &1 = sales order number
      BEGIN OF reject_not_allowed,
        msgid TYPE symsgid VALUE 'ZMC_MERP_DOC',
        msgno TYPE symsgno VALUE '138',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF reject_not_allowed,

      " --- Dependency Checks (151) ---
      " &1 = document number, &2 = entity that uses the document
      BEGIN OF sales_order_in_use,
        msgid TYPE symsgid VALUE 'ZMC_MERP_DOC',
        msgno TYPE symsgno VALUE '151',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF sales_order_in_use.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_merp_sd IMPLEMENTATION.
ENDCLASS.
