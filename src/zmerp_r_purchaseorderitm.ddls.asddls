@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZMERP_PO_ITM'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZMERP_R_PURCHASEORDERITM
  as select from ZMERP_PO_ITM
{
  key item_uuid as ItemUUID,
  header_uuid as HeaderUUID,
  item_no as ItemNo,
  item_code as ItemCode,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
  quantity as Quantity,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  unit_of_measure as UnitOfMeasure,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency as Currency,
  @Semantics.amount.currencyCode: 'Currency'
  price as Price,
  @Semantics.amount.currencyCode: 'Currency'
  net_amount as NetAmount,
  vat_code as VatCode,
  @Semantics.amount.currencyCode: 'Currency'
  vat_amount as VatAmount,
  @Semantics.amount.currencyCode: 'Currency'
  gross_amount as GrossAmount,
  delivery_completed as DeliveryCompleted,
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
