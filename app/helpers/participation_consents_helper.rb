module ParticipationConsentsHelper
  def radio_answers( dynamic_attribute, answer_array )
    answer_array.inject("") do |r,a|
      value = a[0]
      label = a[1]
      r += radio_button_tag "other_answers[#{dynamic_attribute}]", value, 
                             params[:other_answers] && params[:other_answers][dynamic_attribute] == value
      r += label_tag "other_answers_#{dynamic_attribute}_#{value}", label
    end.html_safe
  end
end
