CLASS lhc_zc_auto_cds DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_auto_cds RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zc_auto_cds.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zc_auto_cds.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zc_auto_cds.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_auto_cds RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_auto_cds.
    METHODS customerdisplay FOR MODIFY
      IMPORTING keys FOR ACTION zc_auto_cds~customerdisplay.

ENDCLASS.

CLASS lhc_zc_auto_cds IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA: lt_autos TYPE STANDARD TABLE OF zcsz_autos_db.
    MOVE-CORRESPONDING entities TO lt_autos.
    LOOP AT lt_autos INTO DATA(ls_autos).
      IF ls_autos-car_id IS NOT INITIAL.
        INSERT zcsz_autos_db FROM ls_autos.
        IF sy-subrc = 0.
          reported-zc_auto_cds = VALUE #(
    ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = 'Sikeres mentés' ) )
  ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD update.
  ENDMETHOD.

  METHOD delete.
    DATA: lt_autos TYPE STANDARD TABLE OF zcsz_autos_db.
    MOVE-CORRESPONDING keys TO lt_autos.
    TRY.
        DATA(ls_auto) = lt_autos[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    DELETE zcsz_autos_db FROM ls_auto.
    IF sy-subrc = 0.

      reported-zc_auto_cds = VALUE #(
      ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = 'Sikeres törlés' && ls_auto-car_id  ) )
    ).
    ENDIF.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD customerdisplay.
    data: lt_lsapi_parameters TYPE tihttpnvp.
    cl_lsapi_manager=>navigate_to_intent(
    object          = 'zcustomer'
    action          = 'display'
    parameters      = lt_lsapi_parameters
    navigation_mode = if_lsapi=>gc_s_navigation_mode-new_app_window
  ).

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_auto_cds DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_auto_cds IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
