class MessagesController < ApplicationController

  def new
    @message = Message.new
    @message.email = current_user.email
  end

  def create
    @message = Message.new(params[:message])
    if @message.valid?
      begin
        UserMailer.support_message(@message,current_user).deliver
      rescue Exception => e
        current_user.log("Message from #{current_user.email} could not be delivered: #{e.inspect()}")
      end

      flash[:notice] = "Message sent! Thank you for contacting us, we will get back to you as soon as possible."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
end

