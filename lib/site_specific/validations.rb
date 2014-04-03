# Insert custom validation methods in this module: use underscored version of model class name suffixed by _validations.
# Then use it just like
#
# Example: for the model class InformedConsentResponse, define a method here called informed_consent_response_validations.
# For info on how to add errors (which makes the record invalid) see: 
# http://guides.rubyonrails.org/v3.2.17/active_record_validations_callbacks.html#errors-add
#
#   def informed_consent_response_validations
#     if self.other_answers[:sanity] == '2'
#       errors.add( :other_answers, :sanity_not_permitted)
#     end
#   end
#
# And in your local en.yml (or whichever language) add the following entry:
#
#   en:
#     activerecord:
#       errors:
#         models:
#           informed_consent_response:
#             attributes:
#               other_answers:
#                 sanity_not_permitted: 'You are not permitted to be sane.'
#
# And, for this example, in the app/views/participation_consents/show.html.erb, 
# you would add somewhere in the form the following markup:
#
#   <div class="consent-form-question">
#     <p>
#       Would you judge yourself to be sane?
#       <%= radio_answers( 'sanity', [['0', 'No'],
#                                     ['1', 'Sometimes'],
#                                     ['2', 'Yes']] ) %>
#     </p>
#   </div>
#
# NOTE that for the purpose of development you will want to add the following line to your development.rb:
#
#      ActiveSupport::Dependencies.explicitly_unloadable_constants << 'SiteSpecific::Validations'
#
# This line will make this file reload automatically when you change it, so you don't have to restart the Rails server.
module SiteSpecific
  module Validations
    extend ActiveSupport::Concern

    # *Do not remove this +included+ block!* It is what works the magic.
    included do
      method_name = "#{self.name.to_s.underscore}_validations"
      validate method_name if method_defined? method_name
    end

    # ---------
    # Custom methods can be inserted here....
    # ---------



  end
end