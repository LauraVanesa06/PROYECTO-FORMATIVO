require "application_system_test_case"

class PurchasedetailsTest < ApplicationSystemTestCase
  setup do
    @purchasedetail = purchasedetails(:one)
  end

  test "visiting the index" do
    visit purchasedetails_url
    assert_selector "h1", text: "Purchasedetails"
  end

  test "should create purchasedetail" do
    visit purchasedetails_url
    click_on "New purchasedetail"

    fill_in "Buy", with: @purchasedetail.buy_id
    fill_in "Cantidad", with: @purchasedetail.cantidad
    fill_in "Preciounidad", with: @purchasedetail.preciounidad
    fill_in "Supplier", with: @purchasedetail.supplier_id
    click_on "Create Purchasedetail"

    assert_text "Purchasedetail was successfully created"
    click_on "Back"
  end

  test "should update Purchasedetail" do
    visit purchasedetail_url(@purchasedetail)
    click_on "Edit this purchasedetail", match: :first

    fill_in "Buy", with: @purchasedetail.buy_id
    fill_in "Cantidad", with: @purchasedetail.cantidad
    fill_in "Preciounidad", with: @purchasedetail.preciounidad
    fill_in "Supplier", with: @purchasedetail.supplier_id
    click_on "Update Purchasedetail"

    assert_text "Purchasedetail was successfully updated"
    click_on "Back"
  end

  test "should destroy Purchasedetail" do
    visit purchasedetail_url(@purchasedetail)
    click_on "Destroy this purchasedetail", match: :first

    assert_text "Purchasedetail was successfully destroyed"
  end
end
