# One Vim Plugin for Search and Collect Ci, Poems, Ancient Prose and so on.

## Install

*   Clone the repository into `.vim/plugin`

OR

*   Use the plugin manager tool, like `vim-plug`, and put the following line in your `.vimrc`

    ````
    Plug 'linghaihui/vim-gsc'
    ````

## Command

*   `:GscAppend + words`, it gets result from [xcz](http://lib.xcz.im) and it only get 30 works. it will append the result to current buffer, if you want put the result to the buffer respectively, you can use `:Gsc`

    You can set following options for the command.

    ```
    let g:gsc_show_url=0   " to decise show the url or not, default is 0.

    let g:gsc_show_item_serial=1   "to decise show the item serial before title or not, default is 1.

    let g:gsc_cache=1  "whether to cache the search result, deault is 1  

    let g:gsc_cache_path='/cache'  "the cache path

    let g:gsc_highlight = 1   "to support syntax highlight, it will influnce bothe the wx and xcz.

    let g:gsc_collect_path = '~/.vim_gsc_collect'   " the path to store the collect file, it will influnce both the wx and xcz.

    ```

*   `:GscWxAppend + words`, it gets result from the weixin micro app `i古诗词` and not only 30 works. it will append the result to current buffer, if you want put the result to the buffer respectively, you can use `:GscWx`

    Below is the QR code of `i古诗词`:

    <img alt="i古诗词小程序码" src="https://i.loli.net/2018/11/11/5be80d00518d4.jpg" width="150">

    Welcome to experience it!

    You can set more options for the command.

    ```
    let g:gsc_wx_show_audio = 1   "whether to show the audio url if the item has a audio, default is 1 

    let g:gsc_wx_show_translation = 1   "whether to show translation, default is 1

    let g:gsc_wx_show_intro = 1    "whether to show intro, default is 1

    let g:gsc_wx_show_annotation = 0   "whether to show annotation, default is 0

    let g:gsc_wx_show_appreciation = 0   "whether to show appreciation, default is 0

    let g:gsc_wx_show_master_comment =0   "whether to show master_comment, default is 0

    let g:gsc_wx_show_item_serial =1   "whether to show item serial before title, default is 1

    let g:gsc_wx_cache=1   "whether to cache the search result, deault is 1

    let g:gsc_wx_cache_path='/cache'  "the cache path

    ```

*   `:GscClearCache + [keyword]`,  clear the cache of xcz, if not specify keyword, it will delete all xcz cache.

*   `:GscWxClearCache + [keyword]`,  clear the cache of wx, if not specify keyword, it will delete all wx cache.

*   To search selected word in visual mode, you can add such `vnoremap <buffer> <Leader>gg :call GscSearchSelect('@')<CR>` in your config searching in wx,you can also add such `vnoremap <buffer> <Leader>cc :call GscSearchSelect('#')<CR>` for searching in xcz website. Of course, you can define your keys if you like.

*   `:GscWxRand + [num]`, fetch num works from wx randomly, if num is not set, num equals 1.

*   `:GscCollect + $title + $author + $content[2]`, collect the specified item, you must already fetch the work locally before collect it. 

*   `:GscCollectList + [num|filter_str]`, if you do not give the args, it will return all your collected works, if you give a number, it will return the top n works, if you give a string,  it will return all youur collected works which contains the filter_str as possible.

*   `:GscCollectEdit`, you can edit the collect file in a new tab.

*   `:GscAuthorInfo + author`, it will return the author info from xcz website.

*   `:GscAuthorWorks + author + [page + [page_size]]`, it will query the works by author name, if you give the page argument, it will return all works whose page is between 1 and page, you can give the page_size argument also.

*   `:GscQuotes + [page + [page_size + [author]]]`, it will query the quotes from xcz website, you can give three optional arguments. if you set the page to -1, it will return quotes randomly.

## Appearance

[![4OO2uV.png](https://z3.ax1x.com/2021/10/04/4OO2uV.png)](https://imgtu.com/i/4OO2uV)
