require 'test_helper'

class PagesControllerTest < ActionController::TestCase
	test 'about should route to about' do
		assert_routing "/about", controller: "pages", action: "about"
	end	

end
