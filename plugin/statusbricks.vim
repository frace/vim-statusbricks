if exists('g:loaded_statusbricks')
    finish
else
    let g:loaded_statusbricks = 1
endif

" Didn't test against versions < 703...
if v:version < 703
   echom 'Plugin vim-statusbricks requires Vim 7.3'
endif

" ............................................................... Formatwrapper
function! BrickWrap(data, icon_align, icon_left, icon_right)
    if empty(a:data)
        return ''
    endif

    let l:brick = (a:icon_align ==# 'left') ? a:icon_left . a:data :
                \ (a:icon_align ==# 'right') ? a:data . a:icon_right :
                \ (a:icon_align ==# 'surround') ? a:icon_left . a:data . a:icon_right :
                \ (a:icon_align ==# 'none') ? a:data :
                \ ''

    if empty(l:brick)
        echom 'BrickWrap(): Argument "icon_align" must be "left", "right", "surround" or "none".'
        return ''
    endif

    return l:brick
endfunction

" .................................................................... Flag Git
function! statusbricks#FlagGit(icon)
    if &buflisted && empty(&buftype)
        if !exists('*gitbranch#name')
            echom "statusbricks#FlagGit(): You need to install the vim-gitbranch plugin."
            return ''
        endif

        if exists('b:gitbranch_path')
            let l:gitbranch = gitbranch#name()

            if l:gitbranch ==# 'master'
                return a:icon
            endif

            return a:icon . ' ' . l:gitbranch
        endif
    endif

    return ''
endfunction

" ................................................................... Flag Icon
function! statusbricks#FlagIcon(format)
    let l:icon = '⚑'

    if a:format ==# 'padded'
        if &number || &relativenumber
            let l:padding = repeat(' ', &numberwidth - 1)
            return l:padding . l:icon . ' '
        endif
        return l:icon
    elseif a:format ==# 'raw'
        return l:icon
    else
        echom 'statusbricks#FlagIcon(): Argument must be "padded" or "raw"'
        return ''
    endif
endfunction

" .................................................................. Flag list
function! statusbricks#FlagList(icon)
    if &buflisted && empty(&buftype)
        if &list
            return a:icon
        endif
        return ''
    endif

    return ''
endfunction

" ............................................................... Flag modified
function! statusbricks#FlagModified(icon)
    if &buflisted && empty(&buftype)
        let l:bufnum = winbufnr(winnr())
        let l:modified = getbufvar(l:bufnum, '&modified')

        if l:modified
            return a:icon
        endif
    endif

    return ''
endfunction

" .................................................................. Flag paste
function! statusbricks#FlagPaste(icon)
    if &paste
        return a:icon
    endif
    return ''
endfunction

" ............................................................... Flag readonly
function! statusbricks#FlagReadonly(icon)
    let l:bufnum = winbufnr(winnr())
    let l:readonly = getbufvar(l:bufnum, '&readonly')

    if l:readonly
        return a:icon
    endif

    return ''
endfunction

" ............................................................. Flag Whitespace
function! statusbricks#FlagWhitespace(icon)
    if &buflisted && empty(&buftype)
        let l:whitespace_trailing = search('\s\+$','n')

        if l:whitespace_trailing != 0
            return a:icon . l:whitespace_trailing
        endif

        return ''
    endif

    return ''
endfunction

" .......................................................... Report Buffercount
function! statusbricks#ReportBuffercount()
    if &buflisted && empty(&buftype)
        return len(filter(range(1,bufnr('$')),'buflisted(v:val)'))
    endif

    return ''
endfunction

" ......................................................... Report Buffernumber
function! statusbricks#ReportBuffernumber()
    if &buflisted && empty(&buftype)
        return winbufnr(winnr())
    endif

    return ''
endfunction

" ............................................................... Report Column
function! statusbricks#ReportColumn(format)
    if &buflisted && empty(&buftype)
        let l:column = getpos('.')[2]

        if a:format ==# 'padded'
            if &number || &relativenumber
                let l:column_length = len(l:column)
                let l:padding = repeat(' ', &numberwidth - l:column_length)

                return l:padding . l:column . ' '
            endif
            return l:column
        elseif a:format ==# 'raw'
            return l:column
        else
            echom 'statusbricks#ReportColumn(): Argument must be "padded" or "raw"'
            return ''
        endif
    endif

    return ''
endfunction

" ............................................................. Report Filesize
function! statusbricks#ReportFilesize()
    if &buflisted && empty(&buftype)
        let l:bytes = getfsize(expand('%:p'))

        if l:bytes <= 0
            return ''
        endif

        if l:bytes < 1024
            return l:bytes . ' B '
        endif
        return (l:bytes / 1024) . ' kB '
    endif

    return ''
endfunction

" ......................................................... Report Fileencoding
function! statusbricks#ReportFileencoding(case)
    if &buflisted && empty(&buftype)
        if empty(&fileencoding)
            return ''
        endif

        if a:case ==# 'lower'
            return &fileencoding
        elseif a:case ==# 'upper'
            return toupper(&fileencoding)
        else
            echom 'statusbricks#ReportFileencoding(): Argument must be "lower" or "upper"'
            return ''
        endif
    endif

    return ''
endfunction

" ........................................................... Report Fileformat
function! statusbricks#ReportFileformat(case)
    if &buflisted && empty(&buftype)
        if empty(&fileformat)
            return ''
        endif

        if a:case ==# 'lower'
            return &fileformat
        elseif a:case ==# 'upper'
            return toupper(&fileformat)
        else
            echom 'statusbricks#ReportFileformat(): Argument must be "lower" or "upper"'
            return ''
        endif
    endif

    return ''
endfunction

" ............................................................. Report Filename
function! statusbricks#ReportFullFilename(format, icon)
    if &buflisted && empty(&buftype)
        let l:full = expand('%:p')
        let l:tail = expand('%:t')
        let l:extension = expand('%:e')

        if a:format ==# 'full'
            return (empty(l:full) && empty(&filetype)) ? 'noname' . ' ' . a:icon . ' ' . 'noft' :
                \  (empty(l:full) && !empty(&filetype)) ? 'noname' . ' ' . a:icon . ' ' . &filetype :
                \  (!empty(l:full) && empty(l:extension) && empty(&filetype)) ? l:full . ' ' . a:icon . ' ' . 'noft' :
                \  (empty(l:extension) && !empty(&filetype)) ? l:full . ' ' . a:icon . ' ' . &filetype :
                \  (!empty(l:full) && !empty(l:extension) && empty(&filetype)) ? l:full :
                \  l:full
        elseif a:format ==# 'tail'
            return (empty(l:tail) && empty(&filetype)) ? 'noname' . ' ' . a:icon . ' ' . 'noft' :
                \  (empty(l:tail) && !empty(&filetype)) ? 'noname' . ' ' . a:icon . ' ' . &filetype :
                \  (!empty(l:tail) && empty(l:extension) && empty(&filetype)) ? l:tail . ' ' . a:icon . ' ' . 'noft' :
                \  (empty(l:extension) && !empty(&filetype)) ? l:tail . ' ' . a:icon . ' ' . &filetype :
                \  (!empty(l:tail) && !empty(l:extension) && empty(&filetype)) ? l:tail :
                \  l:tail
        else
            echom 'statusbricks#ReportFileformat(): Argument must be "full" or "tail"'
            return ''
        endif
    endif

    return ''
endfunction

" ............................................................. Report Filetype
function! statusbricks#ReportNoFileFiletype(case)
    if empty(&filetype)
        return ''
    endif

    if &buflisted && empty(&buftype)
        return ''
    endif

    if a:case ==# 'lower'
        return &filetype
    elseif a:case ==# 'upper'
        return toupper(&filetype)
    else
        echom 'statusbricks#ReportFiletype(): Argument must be "lower" or "upper"'
        return ''
    endif
endfunction

" ............................................................ Report Linecount
function! statusbricks#ReportLinecount(format)
    if &buflisted && empty(&buftype)
        let l:line_count = (line('.') == 1) ? '𝝰' :
                        \  (line('.') == line('$')) ? '𝝮' :
                        \  line('$')

        if a:format ==# 'padded'
            if &number || &relativenumber
                let l:line_length = (type(l:line_count) == 0) ? len(l:line_count) : 1
                let l:padding = repeat(' ', &numberwidth - l:line_length)
                return l:padding . l:line_count . ' '
            endif
            return '  ' . l:line_count . ' '
        elseif a:format ==# 'raw'
            return ' ' . l:line_count " CURIOUS: Without prepending a space it attaches a space to the end?
        else
            echom 'statusbricks#ReportLinecount(): Argument must be "padded" or "raw"'
            return ''
        endif
    endif

    return ''
endfunction

" ............................................................ Report Syntastic
function! statusbricks#ReportSyntastic()
    if &buflisted && empty(&buftype)
        if !exists('*SyntasticStatuslineFlag')
            echom "statusbricks#ReportSyntastic(): You need to install the syntastic plugin."
            return ''
        endif

        if empty(SyntasticStatuslineFlag())
            return ''
        endif

        return SyntasticStatuslineFlag()
    endif

    return ''
endfunction
" ...................................................................... Spacer
function! statusbricks#Spacer(width)
    if &number || &relativenumber
        if a:width >= 4
            let &numberwidth = a:width
            return repeat (' ', a:width + 1)
        elseif a:width == 'auto'
            return repeat(' ', &numberwidth + 1)
        else
            echom 'statusbricks#CreateSpacer(): Argument must be at least 4 or "auto"'
            return ''
        endif
    endif

    return ''
endfunction

" ........................................................................ Mode
" 1. Get mode from mode() inside statusline 'loop' (works fine)
" 2. Get mode from autocmd (can't get it to work with e.g. replace)
" 3. Get mode by mapping a script expression to keys (very hacky)
" 4. Get mode by looping infinitely and watch a global var/mode() (not tested)
