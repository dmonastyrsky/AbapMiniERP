CLASS zcx_merp_comp_code DEFINITION
  PUBLIC
  INHERITING FROM zcx_merp_master_data
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF enter_company_name,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '051',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_company_name,

      BEGIN OF enter_company_prefix,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '052',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_company_prefix,

      BEGIN OF company_code_in_use,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '151',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE 'MV_ATTR2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF company_code_in_use,

      BEGIN OF company_code_generation_failed,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '201',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF company_code_generation_failed.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_merp_comp_code IMPLEMENTATION.
ENDCLASS.

