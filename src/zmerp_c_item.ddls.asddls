@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Projection View'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['ItemCode']

define root view entity ZMERP_C_ITEM
  provider contract transactional_query
  as projection on ZMERP_R_ITEM
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      key ItemCode,

      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      Description,

      ItemTypeCode,
      ItemGroupCode,
      DefaultVatCode,
      BaseUnitOfMeasure,

      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Redirected associations */
      _ItemGroup      : redirected to ZMERP_C_ITEM_GROUP,
      _DefaultVATRate : redirected to ZMERP_C_VAT_RATE,
      _ItemType
}
