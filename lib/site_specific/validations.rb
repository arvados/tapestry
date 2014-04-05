# See: https://arvados.org/projects/tapestry/wiki/Customization
module SiteSpecific
  module Validations
    extend ActiveSupport::Concern

    # *Do not remove this +included+ block!* It is what works the magic.
    included do
      method_name = "#{self.name.to_s.underscore}_validations"
      validate method_name if method_defined? method_name
    end

  end
end