
require 'mongoid/userstamp/user'

module Cenit
  module MultiTenancy
    module UserScope
      extend ActiveSupport::Concern

      include Mongoid::Userstamp::User

      included do
        Cenit::MultiTenancy.user_model self
      end
    end
  end
end