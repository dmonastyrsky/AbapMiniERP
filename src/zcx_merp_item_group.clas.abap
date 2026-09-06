CLASS zcx_merp_item_group DEFINITION
  PUBLIC
  INHERITING FROM zcx_merp_master_data
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF select_default_vat_code,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '024',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_default_vat_code,

      BEGIN OF enter_item_group_description,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '054',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_item_group_description,

      BEGIN OF item_group_in_use,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '153',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF item_group_in_use,

      BEGIN OF item_group_generation_failed,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '203',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF item_group_generation_failed.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_merp_item_group IMPLEMENTATION.
ENDCLASS.

