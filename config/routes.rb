Rails.application.routes.draw do
  get 'unattended/specifictemplate',
    :controller => 'specifictemplate',
    :action => 'update',
    :format => 'text'

  get 'specifictemplate/set',
    :controller => 'specifictemplate',
    :action => 'update',
    :format => 'text'
end
