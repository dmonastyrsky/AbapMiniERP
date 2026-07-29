@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Type Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZMERP_I_ITEM_TYPE_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZMERP_ITEM_TYPE' )
{
  @UI.lineItem: [{ position: 10 }]
  @EndUserText.label: 'Item Type'  
  @ObjectModel.text.element: ['Description']
  @Search.defaultSearchElement: true
  key value_low as ItemTypeCode,

  @UI.lineItem: [{ position: 20 }]
  @EndUserText.label: 'Description'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  text as Description
}
