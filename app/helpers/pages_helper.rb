module PagesHelper
  def each_step_with_completion
    @steps.each do |step|
      step_completion = @step_completions.detect {|c| c.enrollment_step == step }
      yield step, step_completion
    end
  end

  def completion_time_for step
    step_completion = @step_completions.detect {|c| c.enrollment_step == step }
    if step == @next_step
      'Current step'
    elsif step_completion
      "Completed #{distance_of_time_in_words_to_now(step_completion.created_at)} ago"
    else
      'Not started'
    end
  end

  def is_completed step
    nil != @step_completions.detect {|c| c.enrollment_step == step }
  end

  def step_item_class step
    if is_completed(step)
      'completed'
    elsif step == @next_step
      'next'
    else
      'locked'
    end
  end
end
