" Disabilita la compatibilità con vi che può causare problemi inaspettati.
set nocompatible

" Abilita il rilevamento del tipo di file. Vim sarà in grado di aiutarti a rilevare il tipo di file in uso.
filetype on

" Abilita i plugin e carica i plugin per il tipo di file rilevato.
filetype plugin on

" Carica il file di indentazione per il tipo di file rilevato.
filetype indent on

" Abilta l'evidenziazione della sintassi.
syntax on

" Aggiungi i numeri a ciascuna riga nella parte sinistra.
set number

" Evidenzia orizzontalmente la riga dove si trova il cursore.
set cursorline

" Disabilita l'evidenziazione verticale del cursore.
"set nocursorcolumn

" Imposta lo shift a 2 spazi.
set shiftwidth=2

" Imposta il tab a 2 colonne.
set tabstop=2

" Usa gli spazi invece del carattere di tabulazione.
set expandtab

" Non salvare file di backup.
set nobackup

" Non consentire al cursore di spostarsi sopra o sotto N numeri di righe durante lo scorrimento.
set scrolloff=10

" Non andare a capo sulle righe. Consenti righe tanto lunghe quanto la massima estensione possibile.
set nowrap

" Durante la ricerca incrementale in un file, evidenzia i caratteri che trovano corrispondenza mentre digiti.
set incsearch

" Ignora le maiuscole durante la ricerca.
set ignorecase

" Ignora l'opzione ignorecase se nella ricerca digiti lettere maiuscole.
" Questo ti consente di cercare specificamente lettere maiuscole.
set smartcase

" Mostra la parte del comando che digiti nell'ultima riga dello schermo.
set showcmd

" Mostra la modalità nella quale ti trovi nell'ultima riga.
set showmode

" Mostra le parole corrispondenti durante una ricerca.
set showmatch

" Usa l'evidenziazione durante una ricerca.
set hlsearch

" Imposta il numero di comandi da salvare nella cronologia (default è 20).
set history=1000

" Abilita il menu di autocompletamento quando digiti TAB.
set wildmenu

" Rende il comportamento di wildmenu simile a quello del completamento in Bash.
set wildmode=list:longest

" Ci sono alcuni file che non vogliamo mai editare in Vim.
" Wildmenu ignorerà i file con queste estensioni.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" PLUGINS ---------------------------------------------------------------- {{{

" Il codice per i plugin va qui.
call plug#begin('~/.vim/plugged')

  Plug 'dense-analysis/ale'

  Plug 'preservim/nerdtree'

call plug#end()
" }}}


"" Disabilita la compatibilità con vi che può causare problemi inaspettati. MAPPINGS --------------------------------------------------------------- {{{

" Il codice per le mappature va qui.
map <tab> :tabnext<cr>                                                                                    
map <s-tab> :tabprevious<cr>
map <F5> :set paste \| insert <CR>                                                                        
map <F6> :set nopaste \| :set ruler<CR>
map <C-o> :tabe 
map <C-q> :qall!
map <F10> :g/^ *$/d
noremap <F3> :set invnumber<CR>
inoremap <F3> <C-O>:set invnumber<CR>
" }}}


" VIMSCRIPT -------------------------------------------------------------- {{{

" Questo abilita la piegatura del codice.
" Usa il metodo di marcatura (marker) per la piegatura.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Codice per altri Vimscripts va qui.
" Abilita il metodo di marcatura per la piegatura.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Se il tipo di file corrente è HTML, imposta l'indentazione a 2 spazi.
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 expandtab

" Se la versione di Vim è maggiore/uguale a 7.3 abilita undofile.
" Questo ti consente di ripristinare le modifiche a un file anche dopo averlo salvato.
if version >= 703
    set undodir=~/.vim/backup
    set undofile
    set undoreload=10000
endif

" Puoi dividere una finestra in sezioni digitando `:split` o `:vsplit`.
" Visualizza la riga e la colonna del cursore solo nella finestra attiva.
augroup cursor_off
    autocmd!
    autocmd WinLeave,TabLeave * set cursorline
    autocmd WinEnter,TabEnter * set nocursorline nocursorcolumn
augroup END

" Se è in esecuzione una versione GUI di Vim imposta queste opzioni.
if has('gui_running')

    " Imposta la tonalità dello sfondo.
    set background=dark

    " Imposta lo schema di colorazione.
    colorscheme molokai

    " Imposta un font personalizzato che devi avere installato nel tuo computer.
    " Sitassi: set guifont=<font_name>\ <font_weight>\ <size>
    set guifont=Monospace\ Regular\ 12

    " In modalità predefinita visualizza altre informazioni oltre al nome del file.
    " Nascondi la barra degli strumenti.
    set guioptions-=T

    " Nascondi la barra di scorrimento di sinistra.
    set guioptions-=L

    " Nascondi la barra di scorrimento di destra.
    set guioptions-=r

    " Nascondi la barra del menu.
    set guioptions-=m

    " Nascondi la barra di scorrimento inferiore.
    set guioptions-=b

    " Mappa il tasto F4 per attivare/disattivare il menu, la barra degli strumenti e la barra di scorrimento.
    " <Bar> è il carattere pipe (|).
    " <CR> è il tasto ENTER.
    nnoremap <F4> :if &guioptions=~#'mTr'<Bar>
        \set guioptions-=mTr<Bar>
        \else<Bar>
        \set guioptions+=mTr<Bar>
        \endif<CR>

endif
" }}}


" STATUS LINE ------------------------------------------------------------ {{{

" Il codice per la riga di stato va qui.
" Pulisci lo riga di stato quando Vim viene ricaricato.
set statusline=

" Lato sinistro della riga di stato.
set statusline+=\ %F\ %M\ %Y\ %R

" Usa un separatore per dividere la parte destra dalla sinistra.
set statusline+=%=

" Lato destro della riga di stato.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Mostra lo stato sulla penultima riga.
set laststatus=2
" }}}
