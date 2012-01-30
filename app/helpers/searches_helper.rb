module SearchesHelper
  
  def search_option(label, extra = nil, &block)
    render(:layout => "layouts/search_option.html", :locals => {:label => label, :extra => extra}) do
      yield
    end
  end
  
end
