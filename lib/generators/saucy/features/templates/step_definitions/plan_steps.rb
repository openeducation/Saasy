When /^I choose the "([^"]*)" plan$/ do |plan_name|
  input_id = find(:xpath, "//li[contains(@class, 'plan')]//p[contains(text(), '#{plan_name}')]/../../input")["id"]
  choose(input_id)
end

Then /^the "([^"]*)" plan should be disabled$/ do |plan_name|
  input_id = find(:xpath, "//li[contains(@class, 'plan')]//p[contains(text(), '#{plan_name}')]/../../input")["id"]
  page.should have_css("##{input_id}[disabled='disabled']")
end

When /^I should see the "([^"]*)" plan before the "([^"]*)" plan$/ do |first_plan_name, second_plan_name|
  first_expression  = Regexp.escape(first_plan_name)
  second_expression = Regexp.escape(second_plan_name)
  joint_expression  = /#{first_expression}.*#{second_expression}/m
  page.body.should =~ joint_expression
end
