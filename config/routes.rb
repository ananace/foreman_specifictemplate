Rails.application.routes.draw do
  get 'specifictemplate/set',
    :controller => 'specifictemplate',
    :action => 'update',
    :format => 'text'
end
