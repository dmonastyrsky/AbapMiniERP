@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Group Projection View'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['ItemGroupCode']

define root view entity ZMERP_C_ITEM_GROUP
  provider contract transactional_query
  as projection on ZMERP_R_ITEM_GROUP
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      key ItemGroupCode,

      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      Description,

      DefaultVatCode,

      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Redirected association */
      _DefaultVATRate : redirected to ZMERP_C_VAT_RATE
}
