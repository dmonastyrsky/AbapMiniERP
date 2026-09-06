CLASS zcx_merp_vat_rate DEFINITION
  PUBLIC
  INHERITING FROM zcx_merp_master_data
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF enter_vat_description,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '055',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_vat_description,

      BEGIN OF invalid_vat_percentage,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '070',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_vat_percentage,

      BEGIN OF vat_rate_in_use,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '154',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF vat_rate_in_use,

      BEGIN OF vat_rate_generation_failed,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '204',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF vat_rate_generation_failed.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_merp_vat_rate IMPLEMENTATION.
ENDCLASS.

