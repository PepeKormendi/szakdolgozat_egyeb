@EndUserText.label: 'Partner consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['CustomerUuid']
define root view entity ZSZAKD_C_CUSTOMER
  provider contract transactional_query
  as projection on ZSZAKD_I_CUSTOMER
{
  key CustomerUuid,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZSZAKD_I_VH_FIRSTNAME' , element: 'FirstName' }, distinctValues: true }]
      FirstName,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZSZAKD_I_VH_LASTNAME' , element: 'LastName' }, distinctValues: true }]
      LastName,
      Street,
      PostalCode,
      City,
      CountryCode,
      PhoneNumber,
      EmailAddress,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
