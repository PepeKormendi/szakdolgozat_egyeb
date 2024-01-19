@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Partner composite'
define root view entity ZSZAKD_I_CUSTOMER
  as select from zszakd_customer

{

      @ObjectModel.text.element: ['Fullname']
  key customer_uuid                                 as CustomerUuid,
      first_name                                    as FirstName,
      last_name                                     as LastName,
//      @Semantics.address.street: true
      street                                        as Street,
      @Semantics.address.zipCode: true
      postal_code                                   as PostalCode,
      @Semantics.address.city: true
      city                                          as City,
      @Semantics.address.country: true
      country_code                                  as CountryCode,
      @Semantics.telephone.type: [#PREF]
      phone_number                                  as PhoneNumber,
      @Semantics.eMail.address: true
      email_address                                 as EmailAddress,
      @Semantics.name.fullName: true
      concat_with_space( last_name, first_name, 1 ) as Fullname,
      @Semantics.user.createdBy: true
      local_created_by                              as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at                              as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by                         as LocalLastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                         as LocalLastChangedAt,

      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                               as LastChangedAt

}
