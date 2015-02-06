" Adjust those patterns to your usual attribution line from mutt:
    let pat = '^On.*, \(.*\) wrote:$'
    let aut = '.*, \zs.*\ze wrote:$'

    let &l:stl = (&l:stl ? &l:stl : &g:stl) .
	\ ' [From: '. matchstr(getline(search(pat, 'nw')), aut). ']'
