Rails.application.routes.draw do
  # get 'specifictemplate',
  #   :controller => 'specifictemplate',
  #   :action => 'check'
  get 'specifictemplate/set',
    :controller => 'specifictemplate',
    :action => 'update',
    :format => 'text'
end
