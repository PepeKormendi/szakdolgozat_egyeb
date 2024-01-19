CLASS zcl_kp_mailsender DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS html_table_border TYPE string VALUE '<head><style> table {border-collapse: collapse;} td {border: 1px solid black; padding:2px 5px;} </style></head>' ##NO_TEXT.
    CONSTANTS html_table_beg TYPE string VALUE '<table>' ##NO_TEXT.
    CONSTANTS html_table_end TYPE string VALUE '</table>' ##NO_TEXT.
    CONSTANTS html_table_line_beg TYPE string VALUE '<tr>' ##NO_TEXT.
    CONSTANTS html_table_line_end TYPE string VALUE '</tr>' ##NO_TEXT.
    CONSTANTS html_table_cell_beg TYPE string VALUE '<td>' ##NO_TEXT.
    CONSTANTS html_table_cell_end TYPE string VALUE '</td>' ##NO_TEXT.
    CONSTANTS html_format_bold_beg TYPE string VALUE '<b>' ##NO_TEXT.
    CONSTANTS html_format_bold_end TYPE string VALUE '</b>' ##NO_TEXT.
    CONSTANTS html_new_line TYPE string VALUE '<br>' ##NO_TEXT.
    CONSTANTS html_paragraph_beg TYPE string VALUE '<p>' ##NO_TEXT.
    CONSTANTS html_paragraph_end TYPE string VALUE '</p>' ##NO_TEXT.
    CONSTANTS html_doctype TYPE string VALUE '<!DOCTYPE html><html>' ##NO_TEXT.
    CONSTANTS html_end TYPE string VALUE '</html>' ##NO_TEXT.
    CONSTANTS html_table_cell_beg_1px TYPE string VALUE '<td style="border: 1px solid black; padding: 3px;">' ##NO_TEXT.
    CONSTANTS html_table_beg_border TYPE string VALUE '<table border="1">' ##NO_TEXT.
    CONSTANTS html_table_style_5px TYPE string VALUE '<style>table {border-collapse: collapse;} table, td, th {padding: 0px 5px;}</style>' ##NO_TEXT.
    CONSTANTS html_link_tag TYPE string VALUE '<a href="&link">&text</a>' ##NO_TEXT.

    CLASS-METHODS create_table_line
      IMPORTING
        !it_fields     TYPE bcsy_text
        !iv_bold       TYPE xfeld DEFAULT ''
      RETURNING
        VALUE(rs_line) TYPE soli .
    CLASS-METHODS mail_send_proc
      IMPORTING
        !iv_subject  TYPE so_obj_des
        !it_body     TYPE bcsy_text
        !iv_mail     TYPE ad_smtpadr
        !iv_sender   TYPE ad_smtpadr
        !iv_cc       TYPE ad_smtpadr OPTIONAL
        !iv_filename TYPE sood-objdes OPTIONAL
        !it_attach   TYPE solix_tab OPTIONAL
        !iv_nocommit TYPE xfeld DEFAULT 'X'
      RETURNING
        VALUE(rv_ok) TYPE xfeld .
    CLASS-METHODS insert_link_tag
      CHANGING
        VALUE(cs_body) TYPE soli .
    CLASS-METHODS create_html_link
      IMPORTING
        !iv_link           TYPE string
        !iv_text           TYPE string DEFAULT ''
      EXPORTING
        VALUE(ev_link_tag) TYPE string .
    CLASS-METHODS create_table_line_dyn
      IMPORTING
        !is_data       TYPE data
        !iv_bold       TYPE xfeld DEFAULT ''
      RETURNING
        VALUE(rs_line) TYPE soli .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_KP_MAILSENDER IMPLEMENTATION.


  METHOD create_html_link.


    ev_link_tag = html_link_tag.
    REPLACE FIRST OCCURRENCE OF REGEX '&link' IN ev_link_tag
      WITH iv_link.
    IF iv_text IS INITIAL.
      REPLACE FIRST OCCURRENCE OF REGEX '&text' IN ev_link_tag
        WITH iv_link.
    ELSE.
      REPLACE FIRST OCCURRENCE OF REGEX '&text' IN ev_link_tag
        WITH iv_text.
    ENDIF.




  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD create_table_line.

*    A bejövő szövegtáblából egy HTML tábla sort állít elő
*    A szöveg túlcsordulást nem vizsgálja!!!!!!!

    FIELD-SYMBOLS: <ls_field> TYPE soli.


    rs_line =  html_table_line_beg.

    LOOP AT it_fields ASSIGNING <ls_field>.
      IF iv_bold EQ 'X'.
        CONCATENATE
           rs_line
           html_table_cell_beg
           html_format_bold_beg
           <ls_field>-line
           html_format_bold_end
           html_table_cell_end
        INTO rs_line.
      ELSE.
        CONCATENATE
           rs_line
           html_table_cell_beg
           <ls_field>-line
           html_table_cell_end
        INTO rs_line.
      ENDIF.
    ENDLOOP.

    CONCATENATE
      rs_line
      html_table_line_end
    INTO rs_line.



  ENDMETHOD.


  METHOD create_table_line_dyn.

*    A bejövő struktúrából egy HTML tábla sort állít elő
*    A szöveg túlcsordulást nem vizsgálja!!!!!!!
*    Konverziós rutinokkal, pénznemmel egyébb finomságokkal nem foglalkozik



    DATA: lo_structdescr TYPE REF TO cl_abap_structdescr,
          lv_field_no    TYPE i,
          lv_act_field   TYPE i,
          lv_field_tx    TYPE char50.

    FIELD-SYMBOLS: <fs> TYPE any.


    lo_structdescr ?= cl_abap_datadescr=>describe_by_data( is_data ).
    lv_field_no = lines( lo_structdescr->components ).
    rs_line =  html_table_line_beg.


    CLEAR: lv_act_field .

    DO lv_field_no TIMES.
      ADD 1 TO lv_act_field.
      ASSIGN COMPONENT lv_act_field OF STRUCTURE is_data TO <fs>.
      IF <fs> IS ASSIGNED.
        WRITE <fs> TO lv_field_tx.
        UNASSIGN <fs>.
        IF iv_bold EQ 'X'.
          CONCATENATE
            rs_line
            html_table_cell_beg
            html_format_bold_beg
            lv_field_tx
            html_format_bold_end
            html_table_cell_end
         INTO rs_line.
        ELSE.
          CONCATENATE
            rs_line
            html_table_cell_beg
            lv_field_tx
            html_table_cell_end
         INTO rs_line.
        ENDIF.
        CONDENSE rs_line.
      ENDIF.
    ENDDO.


    CONCATENATE
      rs_line
      html_table_line_end
    INTO rs_line.



  ENDMETHOD.


  METHOD insert_link_tag.

*  Ez a módszer egy HTML linket készít az adott sorból
*  A szövegnek &text&-tel kell kezdődnie
*  A &text& és a &link& TAG-ek közti karaktersorozat lesz a link szövege
*  A &link& és az &end& TAG-ek közti karaktersorozat a link
*  A sor további részét változatlanul hozzárakja

    DATA: ls_result TYPE match_result,
          lv_tx_beg TYPE i,
          lv_tx_len TYPE i,
          lv_ln_beg TYPE i,
          lv_ln_len TYPE i,
          lv_len    TYPE i,
          lv_tx_1   TYPE i,
          lv_tx_2   TYPE i,
          lv_link   TYPE string,
          lv_text   TYPE string,
          link_tag  TYPE string.

    lv_len = strlen( cs_body ).
    FIND FIRST OCCURRENCE OF REGEX '&text&' IN cs_body RESULTS ls_result.
    CHECK sy-subrc EQ 0.
    lv_tx_beg = ls_result-offset + ls_result-length.
    FIND FIRST OCCURRENCE OF REGEX '&link&' IN cs_body RESULTS ls_result.
    CHECK sy-subrc EQ 0.
    lv_tx_len = ls_result-offset - lv_tx_beg.
    lv_ln_beg = ls_result-offset + ls_result-length.
    FIND FIRST OCCURRENCE OF REGEX '&end&' IN cs_body RESULTS ls_result.
    CHECK sy-subrc EQ 0.
    lv_ln_len = ls_result-offset - lv_ln_beg.
    lv_tx_1 = ls_result-offset + ls_result-length. "a link vége pozíció
    lv_tx_2 = lv_len - lv_tx_1.                    "a fennmaradó karakterek
    lv_text = cs_body+lv_tx_beg(lv_tx_len).
    lv_link = cs_body+lv_ln_beg(lv_ln_len).

    create_html_link(
      EXPORTING
        iv_link     = lv_link
        iv_text     = lv_text
      IMPORTING
        ev_link_tag = link_tag ).
    CONCATENATE link_tag cs_body+lv_tx_1(lv_tx_2)
    INTO cs_body.



  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD mail_send_proc.

    DATA: lo_sender       TYPE REF TO if_sender_bcs VALUE IS INITIAL,
          lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL,
          lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL.

    DATA: ld_oref   TYPE REF TO cx_root.
    DATA: lo_document TYPE REF TO cl_document_bcs VALUE IS INITIAL.


    CLEAR rv_ok.
*Prepare Mail Object
    CLASS cl_bcs DEFINITION LOAD.

    TRY.
        lo_send_request = cl_bcs=>create_persistent( ).
      CATCH cx_send_req_bcs INTO ld_oref.
    ENDTRY.

* Message body and subject
    TRY.
        lo_document = cl_document_bcs=>create_document(
*          i_type    = 'HTM'    "HTM, RAW, TXT
          i_type    = 'RAW'    "HTM, RAW, TXT
          i_text    = it_body
          i_subject = iv_subject ).
      CATCH cx_document_bcs INTO ld_oref.
    ENDTRY.


    "attach file
    IF it_attach IS NOT INITIAL .
      TRY.
          lo_document->add_attachment(
            EXPORTING
              i_attachment_type    = 'BIN'
              i_attachment_subject = iv_filename
              i_att_content_hex    = it_attach ).
        CATCH cx_document_bcs INTO ld_oref.
      ENDTRY.
    ENDIF.

* Pass the document to send request
    TRY.
        lo_send_request->set_document( lo_document ).
      CATCH cx_send_req_bcs INTO ld_oref.
    ENDTRY.
    TRY.
        lo_sender = cl_cam_address_bcs=>create_internet_address( iv_sender ).
      CATCH cx_address_bcs INTO ld_oref.
        RETURN.
    ENDTRY.
    TRY.
        lo_send_request->set_sender(
          EXPORTING
            i_sender = lo_sender ).
      CATCH cx_send_req_bcs INTO ld_oref.
    ENDTRY.
* Set recipients
    TRY.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( iv_mail ).
      CATCH cx_address_bcs INTO ld_oref..
        RETURN.
    ENDTRY.
    TRY.
        lo_send_request->add_recipient(
          EXPORTING
            i_recipient = lo_recipient
            i_express   = 'X' ).
      CATCH cx_send_req_bcs INTO ld_oref.
    ENDTRY.

    IF iv_cc IS NOT INITIAL.
      TRY.
          lo_recipient = cl_cam_address_bcs=>create_internet_address( iv_cc ).
        CATCH cx_address_bcs INTO ld_oref..
          RETURN.
      ENDTRY.
      TRY.
          lo_send_request->add_recipient(
            EXPORTING
              i_recipient = lo_recipient
              i_express   = 'X' ).
        CATCH cx_send_req_bcs INTO ld_oref.
      ENDTRY.
    ENDIF.


    TRY.
** Send email
        lo_send_request->send(
          EXPORTING
            i_with_error_screen = 'X'
          RECEIVING
            result              = rv_ok ).

        IF iv_nocommit = ''.
          COMMIT WORK.
          WAIT UP TO 1 SECONDS.
        ENDIF.

      CATCH cx_send_req_bcs.
        CLEAR rv_ok.    "mail küldése sikertelen
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
