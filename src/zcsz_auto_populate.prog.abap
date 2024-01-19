*&---------------------------------------------------------------------*
*& Report ZCSZ_AUTO_POPULATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcsz_auto_populate.


DATA: lt_autos TYPE STANDARD TABLE OF zcsz_autos_db.

lt_autos = VALUE #( ( car_id = '0000000001' date_from = '20230202' date_to = '99991231' fuel = 'GAS' numseats = 5 )
( car_id = '0000000002' date_from = '20230302' date_to = '99991231' fuel = 'GAS' numseats = 5 )
( car_id = '0000000003' date_from = '20230402' date_to = '99991231' fuel = 'DIE' numseats = 5 )
( car_id = '0000000004' date_from = '20230502' date_to = '99991231' fuel = 'ASD' numseats = 5 )
( car_id = '0000000005' date_from = '20230602' date_to = '99991231' fuel = 'KAZ' numseats = 5 )
( car_id = '0000000006' date_from = '20230702' date_to = '99991231' fuel = 'GAS' numseats = 5 ) ).

INSERT zcsz_autos_db FROM TABLE lt_autos.
IF sy-subrc = 0.
ENDIF.
