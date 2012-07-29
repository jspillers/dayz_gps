$.ajaxSetup
  beforeSend: (xhr) ->
    xhr.setRequestHeader "Accept", "application/json"
  cache: false
