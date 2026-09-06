CLASS zcx_merp_master_data DEFINITION
  PUBLIC
  INHERITING FROM zcx_merp_base
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF select_company,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_company,

      BEGIN OF select_warehouse,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_warehouse,

      BEGIN OF select_vat_code,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_vat_code,

      BEGIN OF select_item_group,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_item_group,

      BEGIN OF select_item,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_item,

      BEGIN OF select_business_partner,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_business_partner,

      BEGIN OF select_country,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '020',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_country,

      BEGIN OF select_currency,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '021',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF select_currency,

      BEGIN OF business_partner_not_found,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '100',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF business_partner_not_found,

      BEGIN OF company_code_not_found,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '101',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF company_code_not_found,

      BEGIN OF item_not_found,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '102',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF item_not_found,

      BEGIN OF item_group_not_found,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '103',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF item_group_not_found,

      BEGIN OF vat_code_not_found,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '104',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF vat_code_not_found,

      BEGIN OF warehouse_not_found,
        msgid TYPE symsgid VALUE 'ZMC_MERP_MD',
        msgno TYPE symsgno VALUE '105',
        attr1 TYPE scx_attrname VALUE 'MV_ATTR1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF warehouse_not_found.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcx_merp_master_data IMPLEMENTATION.
ENDCLASS.

