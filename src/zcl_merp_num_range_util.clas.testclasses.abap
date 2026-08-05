" use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA mo_sql_double TYPE REF TO if_osql_test_environment.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    METHODS setup.

    " Formatting Utility Tests
    METHODS test_add_leading_zeros   FOR TESTING RAISING cx_static_check.
    METHODS test_format_code_normal  FOR TESTING RAISING cx_static_check.
    METHODS test_format_code_overflow FOR TESTING RAISING cx_static_check.
    METHODS test_format_wh_code      FOR TESTING RAISING cx_static_check.

    " Max-Search Code Generation Tests
    METHODS test_get_next_wh_empty_db FOR TESTING RAISING cx_static_check.
    METHODS test_get_next_wh_with_data FOR TESTING RAISING cx_static_check.
    METHODS test_get_next_vat_with_prefix FOR TESTING RAISING cx_static_check.

    " Advanced Edge Case Tests
    METHODS test_get_next_wh_corrupt_data FOR TESTING RAISING cx_static_check.
    METHODS test_get_next_wh_case_insens  FOR TESTING RAISING cx_static_check.
    METHODS test_get_next_wh_max_reached  FOR TESTING RAISING cx_static_check.
    METHODS test_format_with_bad_input    FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS lcl_test IMPLEMENTATION.

  METHOD class_setup.
    " Initialize SQL Test Double for physical tables accessed via Dynamic OSQL
    mo_sql_double = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #(
        ( CONV #( zif_merp_constants=>c_tab_wh ) )
        ( CONV #( zif_merp_constants=>c_dtab_wh ) )
        ( CONV #( zif_merp_constants=>c_tab_vat ) )
        ( CONV #( zif_merp_constants=>c_dtab_vat ) )
      ) ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_sql_double IS BOUND.
      mo_sql_double->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    IF mo_sql_double IS BOUND.
      mo_sql_double->clear_doubles( ).
    ENDIF.
  ENDMETHOD.

  METHOD test_add_leading_zeros.
    " Act
    DATA(lv_res) = zcl_merp_num_range_util=>add_leading_zeros(
      iv_value  = 42
      iv_length = 5 ).

    " Assert
    cl_abap_unit_assert=>assert_equals(
      act = lv_res
      exp = '00042'
      msg = 'Failed to pad numeric value with leading zeros' ).
  ENDMETHOD.

  METHOD test_format_code_normal.
    " Act
    DATA(lv_res) = zcl_merp_num_range_util=>format_code(
      iv_number       = 5
      iv_prefix       = 'WH'
      iv_total_length = 5 ).

    " Assert
    cl_abap_unit_assert=>assert_equals(
      act = lv_res
      exp = 'WH005'
      msg = 'Standard code formatting with prefix failed' ).
  ENDMETHOD.

  METHOD test_format_code_overflow.
    " Act - Target numeric length is 2 (Total 4 minus Prefix 2). Number 100 exceeds 2 digits.
    DATA(lv_res) = zcl_merp_num_range_util=>format_code(
      iv_number       = 100
      iv_prefix       = 'WH'
      iv_total_length = 4 ).

    " Assert
    cl_abap_unit_assert=>assert_initial(
      act = lv_res
      msg = 'Overflow condition should return initial string' ).
  ENDMETHOD.

  METHOD test_format_wh_code.
    " Act
    DATA(lv_res) = zcl_merp_num_range_util=>format_warehouse_code( 12 ).

    " Assert
    cl_abap_unit_assert=>assert_equals(
      act = lv_res
      exp = 'WH012'
      msg = 'Warehouse domain convenience formatter failed' ).
  ENDMETHOD.

  METHOD test_get_next_wh_empty_db.
    " Act
    DATA(lv_next_code) = zcl_merp_num_range_util=>get_next_warehouse_code( ).

    " Assert
    DATA(lv_expected) = zcl_merp_num_range_util=>format_warehouse_code( 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_next_code
      exp = lv_expected
      msg = 'Empty database initial generation sequence failed' ).
  ENDMETHOD.

  METHOD test_get_next_wh_with_data.
    " 1. Arrange
    DATA lt_active TYPE STANDARD TABLE OF zmerp_warehouse.
    lt_active = VALUE #( ( warehouse_code = 'WH00003' ) ).
    mo_sql_double->insert_test_data( lt_active ).

    DATA lt_draft TYPE STANDARD TABLE OF zmerp_whse_d.
    lt_draft = VALUE #( ( warehousecode = 'WH00005' ) ).
    mo_sql_double->insert_test_data( lt_draft ).

    " 2. Act
    DATA(lv_next_code) = zcl_merp_num_range_util=>get_next_warehouse_code( ).

    " 3. Assert
    DATA(lv_expected) = zcl_merp_num_range_util=>format_warehouse_code( 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_next_code
      exp = lv_expected
      msg = 'Sequence generation failed to respect maximum between active and draft tables' ).
  ENDMETHOD.

  METHOD test_get_next_vat_with_prefix.
    " 1. Arrange
    DATA lt_active TYPE STANDARD TABLE OF zmerp_vat_rate.
    lt_active = VALUE #( ( vat_code = 'V009' ) ).
    mo_sql_double->insert_test_data( lt_active ).

    " 2. Act
    DATA(lv_next_code) = zcl_merp_num_range_util=>get_next_vat_code( ).

    " 3. Assert
    cl_abap_unit_assert=>assert_equals(
      act = lv_next_code
      exp = 'V010'
      msg = 'Prefix handling with numeric suffix increment failed for VAT code' ).
  ENDMETHOD.

  METHOD test_get_next_wh_corrupt_data.
    " 1. Arrange
    " Ensure that corrupted or non-numeric DB records are gracefully ignored during max calculation
    DATA lt_active TYPE STANDARD TABLE OF zmerp_warehouse.
    lt_active = VALUE #( ( warehouse_code = 'WH00ABC' )
                         ( warehouse_code = 'WH00003' ) ).
    mo_sql_double->insert_test_data( lt_active ).

    " 2. Act
    DATA(lv_next_code) = zcl_merp_num_range_util=>get_next_warehouse_code( ).

    " 3. Assert
    DATA(lv_expected) = zcl_merp_num_range_util=>format_warehouse_code( 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_next_code
      exp = lv_expected
      msg = 'System should robustly ignore non-numeric database values and increment the valid maximum' ).
  ENDMETHOD.

  METHOD test_get_next_wh_case_insens.
    " 1. Arrange
    " Verify that lowercase prefixes in DB are evaluated properly without breaking the counter
    DATA lt_active TYPE STANDARD TABLE OF zmerp_warehouse.
    lt_active = VALUE #( ( warehouse_code = 'wh00004' ) ).
    mo_sql_double->insert_test_data( lt_active ).

    " 2. Act
    DATA(lv_next_code) = zcl_merp_num_range_util=>get_next_warehouse_code( ).

    " 3. Assert
    DATA(lv_expected) = zcl_merp_num_range_util=>format_warehouse_code( 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_next_code
      exp = lv_expected
      msg = 'Prefix casing in DB should be handled case-insensitively and return standard uppercase code' ).
  ENDMETHOD.

  METHOD test_get_next_wh_max_reached.
    " 1. Arrange
    " Assert that a standard check exception is thrown once the maximum number range sequence is exhausted
    DATA lt_active TYPE STANDARD TABLE OF zmerp_warehouse.
    lt_active = VALUE #( ( warehouse_code = 'WH99999' ) ).
    mo_sql_double->insert_test_data( lt_active ).

    " 2. Act & 3. Assert
    TRY.
        zcl_merp_num_range_util=>get_next_warehouse_code( ).
        cl_abap_unit_assert=>fail( msg = 'Exception expected when number range sequence is exhausted' ).
      CATCH cx_static_check.
        " Test passes successfully if exception is caught
    ENDTRY.
  ENDMETHOD.

  METHOD test_format_with_bad_input.
    " Act
    " Invalid structural inputs like negative integers must not produce broken formats (e.g., WH-005)
    DATA(lv_res) = zcl_merp_num_range_util=>format_code(
      iv_number       = -5
      iv_prefix       = 'WH'
      iv_total_length = 5 ).

    " Assert
    cl_abap_unit_assert=>assert_initial(
      act = lv_res
      msg = 'Negative numeric inputs should result in an initial string output' ).
  ENDMETHOD.

ENDCLASS.

