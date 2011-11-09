
# Parts COPYRIGHT TRAITWISE
# LICENSE ???
# Parts copyright Ward Vandewege, 2011
# Same license as entire project

class TraitwiseController < ApplicationController
  protect_from_forgery :only => [:index]

  def index
    @stream_from_tw = Traitwise.stream( current_user.hex, request, cookies, current_user )
  end

  def iframe
    @stream_from_tw = Traitwise.stream( current_user.hex, request, cookies, current_user )
    render :layout => "none"
  end

  def proxy
    begin
      render :text=>Traitwise.proxy( params[:q], request, cookies )
    rescue Exception => e
      current_user.log("Error connecting to the Traitwise service: #{e.exception} #{e.inspect()}")
      flash[:error] = 'There was an error connecting to the Traitwise service. Please try again later.'
      redirect_to root_path
      return
    end
  end

end
