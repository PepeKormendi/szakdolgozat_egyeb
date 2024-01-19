CLASS lhc_partner DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR partner RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR partner RESULT result.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION partner~resume.

ENDCLASS.

CLASS lhc_partner IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD resume.

  ENDMETHOD.

ENDCLASS.
