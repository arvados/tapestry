module ParticipationConsentsHelper
  def radio_answers( dynamic_attribute, answer_array, options = {} )
    answer_array.inject("") do |r,a|
      value = a[0]
      label = a[1]
      r += radio_button_tag "other_answers[#{dynamic_attribute}]", value,
                             params[:other_answers] && params[:other_answers][dynamic_attribute] == value,
                             options
      r += label_tag "other_answers_#{dynamic_attribute}_#{value}", label
    end.html_safe
  end

  def text_area_answer( dynamic_attribute, options = {} )
    text_area_tag "other_answers[#{dynamic_attribute}]",
                  params['other_answers'] && params['other_answers'][dynamic_attribute],
                  options
  end

  def text_answer( dynamic_attribute, options = {} )
    text_field_tag "other_answers[#{dynamic_attribute}]",
                   params['other_answers'] && params['other_answers'][dynamic_attribute],
                   options
  end
end
