class PublicGeneticDataController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire
  def index
    @datasets = UserFile.joins(:user).merge(User.enrolled.not_suspended) |
      Dataset.published.joins(:participant).merge(User.enrolled.not_suspended)
    @datasets.sort! { |b,a|
      (a.respond_to?(:published_at) ? a.published_at : a.created_at) <=>
      (b.respond_to?(:published_at) ? b.published_at : b.created_at)
    }
  end
end
