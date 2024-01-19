class ZCL_AUTO_HELPER definition
  public
  create public .

public section.

  class-methods CREATE_INVOICE
    importing
      !IV_FOGLALASID type CHAR5 .
  class-methods GENERATE_DATA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AUTO_HELPER IMPLEMENTATION.


  METHOD create_invoice.

    DATA: lv_fm_name TYPE rs38l_fnam.
    DATA: ls_foglalas TYPE zszakd_foglalas.
    DATA: ls_control_par  TYPE ssfctrlop,
          ls_job_output   TYPE ssfcrescl,
          lc_file         TYPE string,
          lt_lines        TYPE TABLE OF tline,
          li_pdf_fsize    TYPE i,
          ls_pdf_string_x TYPE xstring,
          ls_pdf          TYPE char80,
          lt_pdf          TYPE TABLE OF char80.
    SELECT SINGLE a~telj_ar, b~szemigszam, b~veznev, b~kernev, b~cim, b~email
  FROM zszakd_foglalas AS a INNER JOIN zszakd_ugyfelek AS b ON a~szemigszam = b~szemigszam
  INTO  @DATA(ls_print)
  WHERE foglalas_id = @iv_foglalasid.



    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZCSZ_SF_TESZT'
      IMPORTING
        fm_name            = lv_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ls_control_par-getotf    = 'X'.
    CALL FUNCTION lv_fm_name
      EXPORTING
       CONTROL_PARAMETERS = ls_control_par
*       OUTPUT_OPTIONS   =
*       USER_SETTINGS    = 'X'
        is_foglalas      = ls_foglalas
        veznev           = ls_print-veznev
        kernev           = ls_print-kernev
        cim              = ls_print-cim
        datum            = sy-datum
        teljes_ar        = ls_print-telj_ar
      IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
        job_output_info  = ls_job_output
*       JOB_OUTPUT_OPTIONS         =
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_filesize          = li_pdf_fsize
        bin_file              = ls_pdf_string_x
      TABLES
        otf                   = ls_job_output-otfdata
        lines                 = lt_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.

    " Convert xstring to binary

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = ls_pdf_string_x
      TABLES
        binary_tab = lt_pdf.

    lc_file = 'C:\Users\Csoma Zoltán\Desktop\bme'.

    " Save file using dataset, can be done with gui_services too

    OPEN DATASET lc_file FOR OUTPUT IN BINARY MODE.

    IF sy-subrc IS INITIAL.

      LOOP AT lt_pdf INTO ls_pdf.

        TRANSFER ls_pdf TO lc_file

          NO END OF LINE.

      ENDLOOP.

      CLOSE DATASET lc_file.

    ENDIF.


  ENDMETHOD.


  METHOD generate_data.

    DATA: lt_foglalas TYPE STANDARD TABLE OF zszakd_foglalas.
    DATA: lt_ugyfelek TYPE STANDARD TABLE OF zszakd_ugyfelek.

    lt_foglalas = VALUE #( ( foglalas_id = '00001' alv_szam = 'IJK8567WAKJG98234' szemigszam = '12345678'  datum_kezd = '08.12.2021' datum_veg = '12.12.2021' telj_ar =  40000 torolt =  'X' atvetel =  'X'  ) ).
    lt_ugyfelek = VALUE #( ( szemigszam = '12345678' veznev = 'Csoma' kernev = 'Zoli' cim = 'asdjajksdjasjkdjkasd' ) ).
    DELETE FROM zszakd_foglalas.
    DELETE FROM zszakd_ugyfelek .
    MODIFY zszakd_foglalas FROM TABLE lt_foglalas.
    MODIFY zszakd_ugyfelek FROM TABLE lt_ugyfelek.

  ENDMETHOD.
ENDCLASS.
