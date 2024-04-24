function! s:vim_finished(path) abort
	if filereadable(path)
		echomsg '[skkeletal] Download Finished.'
	else
		echoerr '[skkeletal] Download Failed.'
	end
endfunction
function s:save_jisyo(path) abort
		let path = a:path
		let dl_title = 'skkeletal Jisyo Downloader'
		let dl_startmsg = 'Jisyo-download starting....'
		if !filereadable(path)
			if !executable('curl')
				let no_curl = 'curl is not executable.'
				if has('nvim')
					lua vim.notify(no_curl , vim.log.levels.ERROR, {'title': s:dl_title})
				else
					echoerr '[skkeletal] ' .. no_curl
				endif
				return
			endif

			if has('nvim')
				let curl_timeout = 5
				let notify_record = v:lua.vim.notify(dl_startmsg, 2, {'title': dl_title, 'timeout': v:false})
				call jobstart(['curl', '-m', curl_timeout, '--output', path, '--create-dirs', 'http://openlab.jp/skk/skk/dic/SKK-JISYO.L'],
							\{'on_exit': {j,d,e->filereadable(path)?
							\v:lua.vim.notify('Download Finished.', 2, {'title': dl_title, 'replace': notify_record, 'timeout': 2})
							\:v:lua.vim.notify('Download Failed.', 1, {'title': dl_title, 'replace': notify_record, 'timeout': 2})},
							\})
			else
				echomsg '[skkeletal] ' .. dl_startmsg
				let g:skkeletal_running_job = job_start(cmd, { "callback" : { j->s:vim_finished(path) } })
			endif
		endif
endfunction
function s:item_is_true(dict, key)
	return (!has_key(a:dict, a:key)) || a:dict[a:key]
endfunction
function! skkeletal#config(table) abort
	let opts = a:table

	if has_key(opts, 'globalJisyo')
		let path = expand(opts['globalJisyo'])
		call s:save_jisyo(path)
		call remove(opts, 'globalJisyo')
		let opts['globalDictionaries'] = [path]
	endif

	if has_key(opts, 'dvorak')
		if v:t_dict != type(opts['dvorak'])
			let opts['dvorak'] = {}
		endif
		if s:item_is_true(opts['dvorak'], 'dvorakJp')
			call skkeleton#register_kanatable('rom', {
						\ 'ca': ['か', ''],
						\ 'ci': ['き', ''],
						\ 'cu': ['く', ''],
						\ 'ce': ['け', ''],
						\ 'co': ['こ', ''],
						\ 'cna': ['きゃ', ''],
						\ 'cnu': ['きゅ', ''],
						\ 'cne': ['きぇ', ''],
						\ 'cno': ['きょ', ''],
						\ 'gna': ['ぎゃ', ''],
						\ 'gnu': ['ぎゅ', ''],
						\ 'gne': ['ぎぇ', ''],
						\ 'gno': ['ぎょ', ''],
						\ 'sha': ['しゃ', ''],
						\ 'shu': ['しゅ', ''],
						\ 'sho': ['しょ', ''],
						\ 'zha': ['じゃ', ''],
						\ 'zhu': ['じゅ', ''],
						\ 'zhe': ['じぇ', ''],
						\ 'zho': ['じょ', ''],
						\ 'nha': ['にゃ', ''],
						\ 'nhu': ['にゅ', ''],
						\ 'nhe': ['にぇ', ''],
						\ 'nho': ['にょ', ''],
						\ 'hna': ['ひゃ', ''],
						\ 'hnu': ['ひゅ', ''],
						\ 'hne': ['ひぇ', ''],
						\ 'hno': ['ひょ', ''],
						\ 'bna': ['びゃ', ''],
						\ 'bnu': ['びゅ', ''],
						\ 'bno': ['びょ', ''],
						\ 'mna': ['みゃ', ''],
						\ 'mnu': ['みゅ', ''],
						\ 'mne': ['みぇ', ''],
						\ 'mno': ['みょ', ''],
						\ 'rha': ['りゃ', ''],
						\ 'rhu': ['りゅ', ''],
						\ 'rhe': ['りぇ', ''],
						\ 'rho': ['りょ', ''],
						\ })
		endif
		if s:item_is_true(opts['dvorak'], 'registerSelectCandidateKeys')
			let opts['selectCandidateKeys'] = 'aoeuhtn'
		endif
		call remove(opts, 'dvorak')
	endif

	let output = skkeleton#config(opts)

	return output
endfunction
