*"* use this source file for your ABAP unit test classes
CLASS lcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA mo_sql_double TYPE REF TO if_osql_test_environment.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    METHODS setup.

    " Test methods
    METHODS test_get_vat_single        FOR TESTING RAISING cx_static_check.
    METHODS test_get_vat_bulk          FOR TESTING RAISING cx_static_check.
    METHODS test_validate_companies    FOR TESTING RAISING cx_static_check.
    METHODS test_check_dep_empty_keys  FOR TESTING RAISING cx_static_check.
    METHODS test_check_dep_invalid_cds FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS lcl_test IMPLEMENTATION.

  METHOD class_setup.
    " Initialize SQL Test Double environment with dynamic string conversion
    mo_sql_double = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #(
        ( CONV #( zif_merp_constants=>c_tab_ig ) )
        ( CONV #( zif_merp_constants=>c_cds_comp ) )
      ) ).
  ENDMETHOD.

  METHOD class_teardown.
    " Clean up SQL Double environment after all tests execution
    IF mo_sql_double IS BOUND.
      mo_sql_double->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    " Reset test database state before each test execution
    IF mo_sql_double IS BOUND.
      mo_sql_double->clear_doubles( ).
    ENDIF.
  ENDMETHOD.

  METHOD test_get_vat_single.
    " 1. Arrange
    DATA lt_mock_groups TYPE STANDARD TABLE OF zmerp_item_group.
    lt_mock_groups = VALUE #( ( item_group_code = 'GRP_A' default_vat_code = 'V1' ) ).
    mo_sql_double->insert_test_data( lt_mock_groups ).

    " 2. Act
    DATA(lv_vat_valid)   = zcl_merp_md_util=>get_item_group_default_vat( 'GRP_A' ).
    DATA(lv_vat_invalid) = zcl_merp_md_util=>get_item_group_default_vat( 'NON_EXIS' ).
    DATA(lv_vat_empty)   = zcl_merp_md_util=>get_item_group_default_vat( '' ).

    " 3. Assert
    cl_abap_unit_assert=>assert_equals(
      act = lv_vat_valid
      exp = 'V1'
      msg = 'Failed to retrieve correct VAT code for single item group' ).

    cl_abap_unit_assert=>assert_initial(
      act = lv_vat_invalid
      msg = 'VAT code should be initial for non-existing item group' ).

    cl_abap_unit_assert=>assert_initial(
      act = lv_vat_empty
      msg = 'VAT code should be initial when input key is empty' ).
  ENDMETHOD.

  METHOD test_get_vat_bulk.
    " 1. Arrange
    DATA lt_mock_groups TYPE STANDARD TABLE OF zmerp_item_group.
    lt_mock_groups = VALUE #(
      ( item_group_code = 'GRP_A' default_vat_code = 'V1' )
      ( item_group_code = 'GRP_B' default_vat_code = 'V2' )
    ).
    mo_sql_double->insert_test_data( lt_mock_groups ).

    " Pass input with duplicate keys to test deduplication
    DATA lt_input TYPE zcl_merp_md_util=>tt_item_group_codes.
    lt_input = VALUE #( ( 'GRP_A' ) ( 'GRP_B' ) ( 'GRP_A' ) ).

    " 2. Act
    DATA(lt_result) = zcl_merp_md_util=>get_item_groups_default_vat( lt_input ).

    " 3. Assert
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 2
      msg = 'Duplicate keys were not handled or result count mismatch' ).

    READ TABLE lt_result WITH TABLE KEY item_group_code = 'GRP_A' INTO DATA(ls_res_a).
    cl_abap_unit_assert=>assert_subrc( act = sy-subrc msg = 'GRP_A missing in result table' ).
    cl_abap_unit_assert=>assert_equals( act = ls_res_a-default_vat_code exp = 'V1' ).
  ENDMETHOD.

  METHOD test_validate_companies.
    " 1. Arrange
    DATA lt_mock_companies TYPE STANDARD TABLE OF zmerp_r_company_code.
    lt_mock_companies = VALUE #( ( CompanyCode = '1000' ) ).
    mo_sql_double->insert_test_data( lt_mock_companies ).

    DATA lt_input TYPE zcl_merp_md_util=>tt_company_codes.
    lt_input = VALUE #( ( '1000' ) ( '9999' ) ).

    " 2. Act
    DATA(lt_invalid) = zcl_merp_md_util=>validate_companies( lt_input ).

    " 3. Assert
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_invalid )
      exp = 1
      msg = 'Should return exactly 1 invalid company code' ).

    READ TABLE lt_invalid WITH TABLE KEY table_line = '9999' TRANSPORTING NO FIELDS.
    cl_abap_unit_assert=>assert_subrc(
      act = sy-subrc
      msg = 'Company 9999 should be flagged as invalid' ).
  ENDMETHOD.

  METHOD test_check_dep_empty_keys.
    " Act
    DATA(lt_res) = zcl_merp_md_util=>check_dependencies(
      it_keys           = VALUE #( )
      iv_usage_cds      = 'DUMMY_VIEW'
      iv_key_field_name = 'KEY_FIELD'
      is_textid         = VALUE #( ) ).

    " Assert
    cl_abap_unit_assert=>assert_initial(
      act = lt_res
      msg = 'Result must be initial when empty keys table is provided' ).
  ENDMETHOD.

  METHOD test_check_dep_invalid_cds.
    " Act - Passing an invalid CDS name triggers OSQL catch safely without a runtime dump
    DATA lt_keys TYPE string_table.
    lt_keys = VALUE #( ( `KEY_1` ) ). " Use backticks for STRING literals

    DATA(lt_res) = zcl_merp_md_util=>check_dependencies(
      it_keys           = lt_keys
      iv_usage_cds      = 'Z_NON_EXISTING_VIEW_NAME'
      iv_key_field_name = 'FIELD_NAME'
      is_textid         = VALUE #( msgid = 'ZMERP' msgno = '001' ) ).

    " Assert
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_res )
      exp = 1
      msg = 'Failed dynamic SQL execution should return error entry in result table' ).

    READ TABLE lt_res INDEX 1 INTO DATA(ls_blocked).
    cl_abap_unit_assert=>assert_equals( act = ls_blocked-key_value exp = `KEY_1` ).
    cl_abap_unit_assert=>assert_bound(
      act = ls_blocked-msg
      msg = 'Message reference object must be bound' ).
  ENDMETHOD.

ENDCLASS.
