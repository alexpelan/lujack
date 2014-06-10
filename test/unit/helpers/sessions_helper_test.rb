require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
	include SessionsHelper

        test "initialize show try again doesnt modify false value" do
                @show_try_again = false
                initialize_show_try_again
                assert_equal(@show_try_again, false)
        end

        test "initialize show try again sets nil to true" do
                initialize_show_try_again
                assert_equal(@show_try_again, true)
        end

        test "initialize show try again doesnt modify true value" do
                @show_try_again = true
                initialize_show_try_again
                assert_equal(@show_try_again, true)
	end
end
