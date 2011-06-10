Then /^the form should have inline error messages$/ do
  page.should have_css(".error")
end

When /^the "([^"]*)" field should have autocomplete off$/ do |field|
  field = page.find_field(field)
  field["autocomplete"].should == "off"
end

Then /^"([^"]*)" should have the error "([^"]*)"$/ do |field, error|
  field = page.find_field(field)
  field.find(:xpath, "following-sibling::p[@class='inline-errors'][contains(text(), '#{error}')]").should_not be_nil
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should have nothing in it$/ do |field, selector|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should be_nil
    else
      assert_nil(field_value)
    end
  end
end

Then /^I there should be a link to the help site$/ do
  page.should have_css("a[href*='help.example.com']")
end

Then /^"([^"]*)" should not be expanded$/ do |selector|
  page.has_css?("#{selector}")
  page.has_no_css?("#{selector}.expanded")
end

Then /^"([^"]*)" should be expanded/ do |selector|
  page.has_css?("#{selector}")
  page.has_css?("#{selector}.expanded")
end

When %r{^I click "([^"]*)"$} do |selector|
  find(selector).click
end

Then /^the page should (not )?include "([^"]*)"$/ do |should_not_contain, selector|
  if should_not_contain.present?
    page.should have_no_css(selector)
  else
    page.should have_css(selector)
  end
end
