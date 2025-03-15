scriptencoding utf-8

let s:plugin_dir = expand('<sfile>:p:h:h')
let s:device_token_file = s:plugin_dir . "/.device_token"
let s:chat_token_file = s:plugin_dir . "/.chat_token"
let s:chat_config_file = s:plugin_dir ."/config.json"
let s:token_headers = [
  \ 'Accept: application/json',
  \ 'User-Agent: GithubCopilot/1.155.0',
  \ 'Accept-Encoding: gzip,deflate,br',
  \ 'Editor-Plugin-Version: copilot.vim/1.16.0',
  \ 'Editor-Version: vim/9.0.1',
  \ 'Content-Type: application/json',
  \ ]
let s:chat_buffer = -1
let s:chat_count = 1
let s:default_model = "gpt-4o"
let s:available_models = []

function! UserInputSeparator()
  let l:width = winwidth(0)-2
  let l:separator = " "
  let l:separator .= repeat('━', l:width)
  call appendbufline(s:chat_buffer, line('$'), l:separator)
  call appendbufline(s:chat_buffer, line('$'), '')
  let l:win_id = bufwinid(s:chat_buffer)
  if l:win_id != -1
    call win_execute(l:win_id, 'normal! G')
  endif
endfunction

function! LoadConfig()
  if filereadable(s:chat_config_file)
    let l:config = json_decode(join(readfile(s:chat_config_file), "\n"))
    let s:default_model = l:config.model
  else
    let l:config = {'model': s:default_model}
    call writefile([json_encode(l:config)], s:chat_config_file)
  endif
endfunction

function! ViewConfig()
  vsplit s:chat_config_file
endfunction

function! ViewModels()
  vsplit
  enew
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  call appendbufline(bufnr('%'), 0, 'Available Models:')
  call appendbufline(bufnr('%'), '$', s:available_models)
  nnoremap <buffer> <CR> :SelectModel<CR>
endfunction

function! SelectModel()
  let l:selected_model = getline('.')
  let s:default_model = l:selected_model
  let l:config = json_decode(join(readfile(s:chat_config_file), "\n"))
  let l:config.model = l:selected_model
  call writefile([json_encode(l:config)], s:chat_config_file)
endfunction

function ConfirmSignin()
    call FetchModels(GetChatToken())
endfunction

function! CopilotChat()
  call LoadConfig()
  call ConfirmSignin()
  vsplit
  enew
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nonumber
  setlocal norelativenumber
  setlocal wrap
  execute 'file CopilotChat-' . s:chat_count
  let s:chat_count += 1
  let s:chat_buffer = bufnr('%')

  nnoremap <buffer> <leader>cs :SubmitChatMessage<CR>
  nnoremap <buffer> <CR> :SubmitChatMessage<CR>

  syntax match CopilotWelcome /^Welcome to Copilot Chat!.*$/
  syntax match CopilotSeparatorIcon /^/
  syntax match CopilotSeparatorIcon /^/
  syntax match CopilotSeparatorLine / ━\+$/
  syntax match CopilotWaiting /Waiting*./
  
  highlight CopilotWelcome ctermfg=205 guifg=#ff69b4
  highlight CopilotWaiting ctermfg=205 guifg=#ff69b4
  highlight CopilotSeparatorIcon ctermfg=45 guifg=#00d7ff
  highlight CopilotSeparatorLine ctermfg=205 guifg=#ff69b4

  if !exists("g:syntax_on")
    syntax enable
  endif
  set termguicolors

  call appendbufline(s:chat_buffer, 0, 'Welcome to Copilot Chat! Type your message below:')
  call UserInputSeparator()

  normal! G
endfunction

function! SubmitChatMessage()
  let l:separator_line = search(' ━\+$', 'nw')
  let l:start_line = l:separator_line + 1
  let l:end_line = line('$')
  let l:message = join(getline(l:start_line, l:end_line), "\n")

  call AsyncRequest(l:message)
endfunction

function HttpIt(method, url, headers, body)
  if has("win32")
    let l:ps_cmd = 'powershell -Command "'
    let l:ps_cmd .= '$headers = @{'
    for header in a:headers
      let [key, value] = split(header, ": ")
      let l:ps_cmd .= "'" . key . "'='" . value . "';"
    endfor
    let l:ps_cmd .= "};"
    if a:method != "GET"
      let l:ps_cmd .= '$body = ConvertTo-Json @{'
      for obj in keys(a:body)
        let l:ps_cmd .= obj . "='" . a:body[obj] . "';"
      endfor
      let l:ps_cmd .= "};"
    endif
    let l:ps_cmd .= "Invoke-WebRequest -Uri '" . a:url . "' -Method " .a:method . " -Headers $headers -Body $body -ContentType 'application/json' | Select-Object -ExpandProperty Content"
    let l:ps_cmd .= '"'
    let l:response = system(l:ps_cmd)
  else
    let l:token_data = json_encode(a:body)

    let l:curl_cmd = 'curl -s -X ' . a:method . ' --compressed '
    for header in a:headers
      let l:curl_cmd .= '-H "' . header . '" '
    endfor
    let l:curl_cmd .= "-d '" . l:token_data . "' " . a:url

    let l:response = system(l:curl_cmd)
    if v:shell_error != 0
      echom 'Error: ' . v:shell_error
      return ''
    endif
  endif
  return l:response
endfunction

function! GetDeviceToken()
  let l:token_url = 'https://github.com/login/device/code'
  let l:headers = [
    \ 'Accept: application/json',
    \ 'User-Agent: GithubCopilot/1.155.0',
    \ 'Accept-Encoding: gzip,deflate,br',
    \ 'Editor-Plugin-Version: copilot.vim/1.16.0',
    \ 'Editor-Version: Neovim/0.6.1',
    \ 'Content-Type: application/json',
    \ ]
  let l:data = {
    \ 'client_id': 'Iv1.b507a08c87ecfe98',
    \ 'scope': 'read:user'
    \ }

  return HttpIt("POST", l:token_url, l:headers, l:data)
endfunction

function! GetBearerToken()
  if filereadable(s:device_token_file)
    return join(readfile(s:device_token_file), "\n")
  else
    let l:response = GetDeviceToken()
    let l:json_response = json_decode(l:response)
    let l:device_code = l:json_response.device_code
    let l:user_code = l:json_response.user_code
    let l:verification_uri = l:json_response.verification_uri

    echo 'Please visit ' . l:verification_uri . ' and enter the code: ' . l:user_code
    call input("Press Enter to continue...\n")

    let l:token_poll_url = 'https://github.com/login/oauth/access_token'
    let l:token_poll_data = {
      \ 'client_id': 'Iv1.b507a08c87ecfe98',
      \ 'device_code': l:device_code,
      \ 'grant_type': 'urn:ietf:params:oauth:grant-type:device_code'
      \ }
    let l:access_token_response = HttpIt("POST", l:token_poll_url, s:token_headers, l:token_poll_data)
    let l:json_response = json_decode(l:access_token_response)
    let l:bearer_token = l:json_response.access_token
    call writefile([l:bearer_token], s:device_token_file)

    return l:bearer_token
  endif
endfunction

function! GetChatToken(fetch_new = v:false)
  if filereadable(s:chat_token_file) && a:fetch_new == v:false
    return join(readfile(s:chat_token_file), "\n")
  else
    let l:bearer_token = GetBearerToken()
    let l:token_url = 'https://api.github.com/copilot_internal/v2/token'
    let l:token_headers = [
      \ 'Content-Type: application/json',
      \ 'Editor-Version: vscode/1.80.1',
      \ 'Authorization: token ' . l:bearer_token,
      \ ]
    let l:token_data = {
      \ 'client_id': 'Iv1.b507a08c87ecfe98',
      \ 'scope': 'read:user'
      \ }
    let l:response = HttpIt("GET", l:token_url, l:token_headers, l:token_data)
    let l:json_response = json_decode(l:response)
    let l:chat_token = l:json_response.token
    call writefile([l:chat_token], s:chat_token_file)

    return l:chat_token
  endif
endfunction

function! FetchModels(chat_token)
  let l:chat_headers = [
    \ "Content-Type: application/json",
    \ "Authorization: Bearer " . a:chat_token,
    \ "Editor-Version: vscode/1.80.1"
    \ ]

  let l:response = HttpIt("GET", "https://api.githubcopilot.com/models", l:chat_headers, {})
  try
    let l:json_response = json_decode(l:response)
    let l:model_list = []
    for item in l:json_response.data
        if has_key(item, 'id')
            call add(l:model_list, item.id)
        endif
    endfor
    let s:available_models = l:model_list
  endtry

  return l:response
endfunction

function! ValidateToken()
  let l:chat_token = GetChatToken()
  let l:response = FetchModels(l:chat_token)

  return l:chat_token
endfunction

function! UpdateWaitingDots()
  let l:current_text = getbufline(s:chat_buffer, '$')[0]
  if l:current_text =~ '^Waiting for response'
      let l:dots = len(matchstr(l:current_text, '\..*$'))
      let l:new_dots = (l:dots % 3) + 1
      call setbufline(s:chat_buffer, '$', 'Waiting for response' . repeat('.', l:new_dots))
  endif
  return 1
endfunction

function! AsyncRequest(message)
  let l:chat_token = ValidateToken()
  let s:curl_output = []
  let l:url = 'https://api.githubcopilot.com/chat/completions'

  call appendbufline(s:chat_buffer, line('$'), 'Waiting for response')
  let s:waiting_timer = timer_start(500, {-> UpdateWaitingDots()}, {'repeat': -1})

  " for knowledge bases its just an attachment as the content
  "{'content': '<attachment id="kb:Name">\n#kb:\n</attachment>', 'role': 'user'}
  " for files similar
  let l:messages = [{'content': a:message, 'role': 'user'}]
  let l:data = json_encode({
        \ 'intent': v:false,
        \ 'model': s:default_model,
        \ 'temperature': 0,
        \ 'top_p': 1,
        \ 'n': 1,
        \ 'stream': v:true,
        \ 'messages': l:messages
        \ })
  
  let l:curl_cmd = [
      \ "curl",
      \ "-s",
      \ "-X",
      \ "POST",
      \ "-H",
      \ "Content-Type: application/json",
      \ "-H", "Authorization: Bearer " . l:chat_token,
      \ "-H", "Editor-Version: vscode/1.80.1",
      \ "-d",
      \ l:data,
      \ l:url]
  
  let job = job_start(l:curl_cmd, {'out_cb': function('HandleCurlOutput'), 'exit_cb': function('HandleCurlClose'), 'err_cb': function('HandleCurlError')})
  return job
endfunction

function! HandleCurlError(channel, msg)
  echom "handling curl error"
  echom a:msg
endfunction

function! HandleCurlClose(channel, msg)
  let l:result = ''
  for line in s:curl_output
    if line =~ '^data: {'
      let l:json_completion = json_decode(line[6:])
      try
        let l:content = l:json_completion.choices[0].delta.content
        if type(l:content) != type(v:null)
          let l:result .= l:content
        endif
      catch
        let l:result .= "\n"
      endtry
    endif
  endfor

  let l:width = winwidth(0)-2
  let l:separator = " "
  let l:separator .= repeat('━', l:width)
  call appendbufline(s:chat_buffer, '$', l:separator)
  call appendbufline(s:chat_buffer, '$', split(l:result, "\n"))
  call UserInputSeparator()
endfunction

function! HandleCurlOutput(channel, msg)
  call add(s:curl_output, a:msg)
endfunction

command! CopilotChat call CopilotChat()
command! SubmitChatMessage call SubmitChatMessage()
command! CopilotConfig call ViewConfig()
command! CopilotModels call ViewModels()
command! SelectModel call SelectModel()

nnoremap <leader>cc :CopilotChat<CR>