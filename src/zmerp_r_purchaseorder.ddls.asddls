@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZMERP_PO_HDR'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZMERP_R_PURCHASEORDER
  as select from ZMERP_PO_HDR
{
  key document_uuid as DocumentUUID,
  document_number as DocumentNumber,
  document_date as DocumentDate,
  posting_date as PostingDate,
  company_code as CompanyCode,
  warehouse_code as WarehouseCode,
  business_partner as BusinessPartner,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency as Currency,
  @Semantics.amount.currencyCode: 'Currency'
  total_net_amount as TotalNetAmount,
  @Semantics.amount.currencyCode: 'Currency'
  total_gross_amount as TotalGrossAmount,
  @Semantics.user.createdBy: true
  responsible_person as ResponsiblePerson,
  remarks as Remarks,
  supplier_reference as SupplierReference,
  delivery_date as DeliveryDate,
  status as Status,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
