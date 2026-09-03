@EndUserText.label: 'Purchase Order Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['DocumentNumber']

define root view entity ZMERP_C_PURCHASEORDER
  provider contract transactional_query
  as projection on ZMERP_R_PURCHASEORDER
{
  key DocumentUUID,

      /* zmerp_s_doc_hdr_common */
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      DocumentNumber,

      DocumentDate,
      PostingDate,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMERP_I_COMPANY_CODE_VH', element: 'CompanyCode' }, useForValidation: true }]
      CompanyCode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMERP_I_WAREHOUSE_VH', element: 'WarehouseCode' }, useForValidation: true }]
      WarehouseCode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMERP_I_BUS_PARTNER_VH', element: 'PartnerCode' }, useForValidation: true }]
      BusinessPartner,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      Currency,

      TotalNetAmount,
      TotalGrossAmount,
      ResponsiblePerson,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Remarks,

      /* zmerp_po_hdr */
      @Search.defaultSearchElement: true
      SupplierReference,

      DeliveryDate,

      @ObjectModel.text.element: ['StatusDescription']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMERP_I_PO_STATUS_VH', element: 'Status' }, useForValidation: true }]
      Status,

      @EndUserText.label: 'Status Description'
      _Status.Description as StatusDescription,

      /* zmerp_s_admin */
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Redirected associations */
      _Items            : redirected to composition child ZMERP_C_PURCHASEORDERITM,
      _CompanyCode,
      _Warehouse,
      _BusinessPartner,
      _Currency,

      /* Exposed text association */
      _Status
}
