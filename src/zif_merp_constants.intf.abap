"! Global system constants for Mini ERP application
INTERFACE zif_merp_constants
  PUBLIC.

  " Business Partners Metadata (ZMERP_BUS_PART)
  CONSTANTS:
    c_prefix_bp   TYPE string                         VALUE '',
    c_length_bp   TYPE i                              VALUE 5,
    c_nro_bp      TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_BP',
    c_tab_bp      TYPE string                         VALUE 'ZMERP_BUS_PART',
    c_fld_bp      TYPE string                         VALUE 'PARTNER_CODE',
    c_dtab_bp     TYPE string                         VALUE 'ZMERP_BUS_PART_D',
    c_dfld_bp     TYPE string                         VALUE 'PARTNERCODE',
    c_cds_bp      TYPE string                         VALUE 'ZMERP_R_BUS_PARTNER'.

  " Company Codes Metadata (ZMERP_COMP_CODE)
  CONSTANTS:
    c_prefix_comp TYPE string                         VALUE '',
    c_length_comp TYPE i                              VALUE 4,
*   c_nro_comp    TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_COMP',
    c_tab_comp    TYPE string                         VALUE 'ZMERP_COMP_CODE',
    c_fld_comp    TYPE string                         VALUE 'COMPANY_CODE',
    c_dtab_comp   TYPE string                         VALUE 'ZMERP_COMP_D',
    c_dfld_comp   TYPE string                         VALUE 'COMPANYCODE',
    c_cds_comp    TYPE string                         VALUE 'ZMERP_R_COMPANY_CODE'.

  " Items Metadata (ZMERP_ITEM)
  CONSTANTS:
    c_prefix_item TYPE string                         VALUE '',
    c_length_item TYPE i                              VALUE 5,
    c_nro_item    TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_ITEM',
    c_tab_item    TYPE string                         VALUE 'ZMERP_ITEM',
    c_fld_item    TYPE string                         VALUE 'ITEM_CODE',
    c_dtab_item   TYPE string                         VALUE 'ZMERP_ITEM_D',
    c_dfld_item   TYPE string                         VALUE 'ITEMCODE',
    c_cds_item    TYPE string                         VALUE 'ZMERP_R_ITEM'.

  " Item Groups Metadata (ZMERP_ITEM_GROUP)
  CONSTANTS:
    c_prefix_ig   TYPE string                         VALUE '',
    c_length_ig   TYPE i                              VALUE 5,
    c_nro_ig      TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_IG',
    c_tab_ig      TYPE string                         VALUE 'ZMERP_ITEM_GROUP',
    c_fld_ig      TYPE string                         VALUE 'ITEM_GROUP_CODE',
    c_dtab_ig     TYPE string                         VALUE 'ZMERP_ITEM_GRP_D',
    c_dfld_ig     TYPE string                         VALUE 'ITEMGROUPCODE',
    c_cds_ig      TYPE string                         VALUE 'ZMERP_R_ITEM_GROUP'.

  " VAT Rates Metadata (ZMERP_VAT_RATE)
  CONSTANTS:
    c_prefix_vat  TYPE string                         VALUE 'V',
    c_length_vat  TYPE i                              VALUE 4,
    c_nro_vat     TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_VAT',
    c_tab_vat     TYPE string                         VALUE 'ZMERP_VAT_RATE',
    c_fld_vat     TYPE string                         VALUE 'VAT_CODE',
    c_dtab_vat    TYPE string                         VALUE 'ZMERP_VATR_D',
    c_dfld_vat    TYPE string                         VALUE 'VATCODE',
    c_cds_vat     TYPE string                         VALUE 'ZMERP_R_VAT_RATE'.

  " Warehouses Metadata (ZMERP_WAREHOUSE)
  CONSTANTS:
    c_prefix_wh   TYPE string                         VALUE 'WH',
    c_length_wh   TYPE i                              VALUE 5,
    c_nro_wh      TYPE cl_numberrange_runtime=>nr_object VALUE 'ZNR_WHSE',
    c_tab_wh      TYPE string                         VALUE 'ZMERP_WAREHOUSE',
    c_fld_wh      TYPE string                         VALUE 'WAREHOUSE_CODE',
    c_dtab_wh     TYPE string                         VALUE 'ZMERP_WHSE_D',
    c_dfld_wh     TYPE string                         VALUE 'WAREHOUSECODE',
    c_cds_wh      TYPE string                         VALUE 'ZMERP_R_WAREHOUSE'.

ENDINTERFACE.
