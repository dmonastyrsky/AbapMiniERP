CLASS zcx_merp_warehouse DEFINITION
  PUBLIC
  INHERITING FROM zcx_merp_master_data
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF enter_warehouse_name,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '056',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_warehouse_name,

      BEGIN OF warehouse_in_use,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '155',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF warehouse_in_use,

      BEGIN OF warehouse_generation_failed,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '205',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF warehouse_generation_failed.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_merp_warehouse IMPLEMENTATION.
ENDCLASS.

