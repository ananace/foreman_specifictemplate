Rails.application.routes.draw do
  put 'specifictemplate/:template_name',
    :controller => 'specifictemplate',
    :action => 'update'
  delete 'specifictemplate',
    :controller => 'specifictemplate',
    :action => 'remove'
end
