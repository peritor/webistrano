require File.dirname(__FILE__) + '/../test_helper'
require 'stylesheets_controller'

# Re-raise errors caught by the controller.
class StylesheetsController; def rescue_action(e) raise e end; end

class StylesheetsControllerTest < Test::Unit::TestCase
  def setup
    @controller = StylesheetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
