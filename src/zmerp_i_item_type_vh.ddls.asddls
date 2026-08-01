@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Type Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZMERP_I_ITEM_TYPE_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZMERP_ITEM_TYPE' )       
{
  @ObjectModel.text.element: ['Description']
  @EndUserText.label: 'Item Type'
  key value_low as ItemTypeCode,

  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @EndUserText.label: 'Description'
  text as Description
}
where language = $session.system_language
