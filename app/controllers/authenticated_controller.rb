class AuthenticatedController < ApplicationController
  prepend_before_action :authenticate_user!
end
