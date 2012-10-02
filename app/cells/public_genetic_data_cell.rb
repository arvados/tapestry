class PublicGeneticDataCell < Cell::Rails

  def list(opts)
    @options = opts
    @datasets = opts[:datasets]
    @current_user = opts[:current_user]
    render
  end

end
