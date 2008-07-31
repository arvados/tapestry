class ContentAreasController < ApplicationController
  def index
    @content_areas = ContentArea.all
  end
end
