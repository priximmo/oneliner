 
function s:filetype ()
 
  let s:file = expand("<afile>:t")
  if match (s:file, "\.sh$") != -1
    let s:comment = "#"
    let s:type = s:comment . "!" . system ("whereis -b bash | awk '{print $2}' | tr -d '\n'")
  elseif match (s:file, "\.py$") != -1
    let s:comment = "#"
    let s:type = s:comment . "!" . system ("whereis -b python | awk '{print $2}' | tr -d '\n'")
  elseif match (s:file, "\.pl$") != -1
    let s:comment = "#"
    let s:type = s:comment . "!" . system ("whereis -b perl | awk '{print $2}' | tr -d '\n'")
  elseif match (s:file, "\.vim$") != -1
    let s:comment = "\""
    let s:type = s:comment . " Vim File"
  else
    let s:comment = "#"
    let s:type = s:comment . " Text File"
  endif
  unlet s:file
 
endfunction
 
 
" FUNCTION:
" Insert the header when we create a new file.
" VARIABLES:
" author = User who create the file.
" file = Path to the file.
" created = Date of the file creation.
" modified = Date of the last modification.
 
function s:insert ()
 
  call s:filetype ()
 
  let s:author = s:comment . "  AUTEUR:   Xavier" 
  let s:file = s:comment . "  FILE:     " . expand("<afile>:p")
  let s:created = s:comment . "  CREATION:  " . strftime ("%H:%M:%S %d/%m/%Y")
  let s:modified = s:comment . "  MODIFIE: "
  let s:description = s:comment . "  DESCRIPTION: " 
  let s:version = s:comment . "  VERSION: " 
  let s:titre = s:comment . "  TITRE: " 
 
  call append (0, s:type)
  call append (1, "")
  call append (2, "###############################################################")
  call append (3, s:titre)
  call append (4, s:comment)
  call append (5, s:author)
  call append (6, s:version)
  call append (7, s:created)
  call append (8, s:modified)
  call append (9, s:comment)
  call append (10, s:description)
  call append (11, "###############################################################")
 
  unlet s:comment
  unlet s:type
  unlet s:author
  unlet s:file
  unlet s:created
  unlet s:modified
  unlet s:titre
  unlet s:description
  unlet s:version
 
endfunction
 
 
 
 
autocmd BufNewFile * call s:insert ()


