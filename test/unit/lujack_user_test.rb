require 'test_helper'

class LujackUserTest < ActiveSupport::TestCase
	test "should not save lujack user without username" do
		lujack_user = LujackUser.new
		assert_equal(lujack_user.save, false)
	end
end

