class ZCL_CSZ_INVOICE_HELPER definition
  public
  final
  create public .

public section.

  data GT_PDF_BINARY type SOLIX_TAB .
  data GS_BOOKING type ZAUTOS_INVOICE_INPUT .

  methods CONSTRUCTOR
    importing
      !IS_BOOKING type ZAUTOS_INVOICE_INPUT .
  methods MAIN .
  class-methods GET_FUNCTIONNAME
    importing
      !IV_FORMNAME type FPNAME
    returning
      value(RV_FUNCNAME) type FUNCNAME .
  class-methods CALL_FUNCNAME
    importing
      !IS_INVOICEFORM type ZKPS_CAR_ADOBE
      !IV_FUNCNAME type FUNCNAME
    returning
      value(RS_FORMOUTPUT) type FPFORMOUTPUT .
  class-methods CREATE_ATTACHMENT
    importing
      !IS_BOOKING type ZAUTOS_INVOICE_INPUT
      !IV_COMMIT type FLAG default 'X'
      !IV_PDF type FPCONTENT
    returning
      value(RV_OK) type FLAG .
protected section.

  constants GC_Z_CARBOOKINVOICE type FPNAME value 'Z_CARBOOKINVOICE' ##NO_TEXT.
  data GS_FORMINPUT type ZKPS_CAR_ADOBE .

  methods OPEN_JOB
    returning
      value(RV_OK) type FLAG .
  methods FILL_FORM_INPUT .
private section.
ENDCLASS.



CLASS ZCL_CSZ_INVOICE_HELPER IMPLEMENTATION.


  METHOD call_funcname.

    CALL FUNCTION iv_funcname
      EXPORTING
        s_carrent          = is_invoiceform
      IMPORTING
        /1bcdwb/formoutput = rs_formoutput
      EXCEPTIONS
        usage_error        = 1
        OTHERS             = 4.


  ENDMETHOD.


  METHOD constructor.
    gs_booking = is_booking.
  ENDMETHOD.


  METHOD fill_form_input.

    SELECT SINGLE * FROM zszakd_customer INTO @DATA(ls_customer)
      WHERE customer_uuid = @gs_booking-partnerid.

    gs_forminput = VALUE #( partnername = |{ ls_customer-last_name } { ls_customer-first_name }|
                            address_sh  = |{ ls_customer-postal_code }, { ls_customer-city } { ls_customer-street }|
                            fromdatum   = gs_booking-bookingfrom
                            tilldatum   = gs_booking-bookingto
                            price       = CONV #( gs_booking-price )
                            currency    = gs_booking-currency
                            brand       = gs_booking-brand
                            model       = gs_booking-model
                            platnumber  = gs_booking-platenumber ).
  ENDMETHOD.


  METHOD get_functionname.


    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = iv_formname
      IMPORTING
        e_funcname = rv_funcname.

  ENDMETHOD.


  METHOD main.
    DATA: lt_lines TYPE STANDARD TABLE OF tline.
    DATA: lt_body  TYPE bcsy_text.
    DATA: ls_result TYPE sfpjoboutput.
    DATA(lv_ok) = open_job( ).
    IF lv_ok = abap_false.
*      todo:
    ENDIF.

    DATA(lv_fname) = get_functionname( gc_z_carbookinvoice ).
    fill_form_input( ).
    DATA(ls_formoutput) = call_funcname( iv_funcname = lv_fname is_invoiceform = gs_forminput ).
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = ls_formoutput-pdf
      TABLES
        binary_tab = gt_pdf_binary.
    "long text kiolvasása és paraméter beírása
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = 'ST'
        language                = sy-langu
        name                    = 'ZEMAIL'
        object                  = 'TEXT'
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<fs_lines>).
*      REPLACE 'lv_ugyfel' WITH gs_forminput-partnername INTO <fs_lines>-tdline.
*      REPLACE 'lv_jarmu'  WITH gs_forminput-platnumber INTO <fs_lines>-tdline.
*      APPEND cl_abap_char_utilities=>cr_lf TO <fs_lines>-tdline.
*      APPEND VALUE #( line = <fs_lines>-tdline ) TO lt_body.

      DATA(lv_string) = COND #(
        WHEN contains( val  = <fs_lines>-tdline sub = 'lv_ugyfel' )
          THEN replace( val = <fs_lines>-tdline sub = 'lv_ugyfel' with = gs_forminput-partnername occ = 1 )
        WHEN contains( val  = <fs_lines>-tdline sub = 'lv_jarmu' )
          THEN replace( val = <fs_lines>-tdline sub = 'lv_jarmu' with = gs_forminput-platnumber occ = 1 )
        ELSE <fs_lines>-tdline ).
      lt_body = VALUE #( BASE lt_body ( |{ lv_string } { cl_abap_char_utilities=>cr_lf }| ) ).
    ENDLOOP.

*    "DATA(lt_body) = VALUE bcsy_text( ( line = | kedves{ lv_valtozo } | )
*                                      ( line =  )line = lt_lines ).

    zcl_kp_mailsender=>mail_send_proc(
        EXPORTING
          iv_subject  = 'Számla autóbérlés'
          it_body     = lt_body
*          Direkt hardcodeolva, nehogy létező címre küljük:
          iv_mail     = 'csoma.zoltan@cronos-consulting.hu'
          iv_sender   = 'peter.kormendi@ext.snt.hu'
*          Direkt hardcodeolva, nehogy létező címre küljük:
          iv_cc       = 'kormendi.peter@cronos-consulting.hu'
          iv_filename = 'autoberlesszamla.pdf'
          it_attach   = gt_pdf_binary
          iv_nocommit = 'X'
        RECEIVING
          rv_ok       = DATA(lv_sent) ).

    IF lv_sent = 'X'.
*      zcl_csz_gos_helper=>attach_doc(
*        EXPORTING
*          is_key         = VALUE #( objkey = CONV #( gs_forminput-bookingid ) classname = 'VBAK' )
*          iv_filename    = 'autoberlesszamla.pdf'
*          iv_description = 'tszt számlamentés GOS-ra'
*          iv_hex_string  = ls_formoutput-pdf
*      ).
    ENDIF.

    CALL FUNCTION 'FP_JOB_CLOSE'
      IMPORTING
        e_result       = ls_result
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD open_job.

    DATA(ls_parameters) = VALUE sfpoutputparams( nodialog = 'X' preview = 'X' dest = 'LP01' getpdf = 'X' ).

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_parameters
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    rv_ok = SWITCH #( sy-subrc WHEN 0 THEN abap_true ELSE abap_false ).

  ENDMETHOD.


  METHOD create_attachment.
    DATA: lv_mimetype TYPE w3conttype.
    IF is_booking-bookingid IS NOT INITIAL.
      DATA(ls_object) = VALUE gos_s_obj( instid = CONV #( is_booking-bookingid )
                                          catid = 'BO'
                                          typeid = 'VBRK' ).
    ENDIF.
    DATA(lr_gos_api) = cl_gos_api=>create_instance( is_object = ls_object ).
    lv_mimetype = 'PDF'.

  ENDMETHOD.
ENDCLASS.
