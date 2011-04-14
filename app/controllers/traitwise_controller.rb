
# COPYRIGHT TRAITWISE
# LICENSE ???

class TraitwiseController < ApplicationController
  protect_from_forgery :only => [:index]

  def index
    @stream_from_tw = Traitwise.stream( current_user.hex, request, cookies )
  end

	def proxy
		render :text=>Traitwise.proxy( params[:q], request, cookies )
	end

end
