# Shell functions.

# Create a directory and enter it.
mkd() {
  mkdir -p "$@" && cd "${@[-1]}"
}

# cd to the front-most Finder window.
cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Open the current directory, or the given paths, in Finder.
o() {
  if (( $# == 0 )); then open .; else open "$@"; fi
}

# tree with hidden files and colour, ignoring .git and node_modules, paged.
tre() {
  tree -aC -I '.git|node_modules' --dirsfirst "$@" | less -FRNX
}

# Size of a file, or of every entry in the current directory.
fs() {
  setopt localoptions nullglob   # a directory without dotfiles is not an error
  if (( $# )); then
    du -sh -- "$@"
  else
    du -sh -- .[^.]* ./*
  fi
}

# Create PATH.tar.gz with the best available compressor: zopfli for small
# archives, pigz if present, gzip otherwise.
targz() {
  local tmp="${1%/}.tar" size cmd
  tar -cvf "$tmp" --exclude='.DS_Store' "$@" || return 1
  size=$(stat -f%z "$tmp" 2> /dev/null || stat -c%s "$tmp")
  if (( size < 52428800 )) && (( $+commands[zopfli] )); then
    cmd=zopfli
  elif (( $+commands[pigz] )); then
    cmd=pigz
  else
    cmd=gzip
  fi
  echo "Compressing $tmp ($(( size / 1000 )) kB) with $cmd"
  "$cmd" -v "$tmp" || return 1
  [[ -f $tmp ]] && rm "$tmp"
  echo "$tmp.gz created"
}

# Compare a file's size with its gzipped size.
gz() {
  local orig gzipped
  orig=$(wc -c < "$1")
  gzipped=$(gzip -c "$1" | wc -c)
  printf 'orig: %d bytes\ngzip: %d bytes (%.2f%%)\n' "$orig" "$gzipped" "$(( gzipped * 100.0 / orig ))"
}

# Colour word diff between any two files, outside of a repository too.
# Named cdiff so plain `diff` and its flags keep working.
cdiff() {
  git diff --no-index --color-words "$@"
}

# Data URL for a file.
dataurl() {
  local mime
  mime=$(file -b --mime-type "$1")
  [[ $mime == text/* ]] && mime="$mime;charset=utf-8"
  echo "data:$mime;base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Serve the current directory over HTTP, as UTF-8, and open it. Default port 8000.
server() {
  local port="${1:-8000}"
  sleep 1 && open "http://localhost:$port/" &
  python3 - "$port" <<-'EOF'
	import http.server, sys

	class Handler(http.server.SimpleHTTPRequestHandler):
	    def guess_type(self, path):
	        mime = super().guess_type(path)
	        if mime == "application/octet-stream":
	            mime = "text/plain"
	        return mime + ";charset=UTF-8"

	http.server.test(HandlerClass=Handler, port=int(sys.argv[1]))
	EOF
}

# dig, showing only the answer section.
digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# Common Name and Subject Alternative Names of a host's TLS certificate.
getcertnames() {
  if [[ -z $1 ]]; then
    echo "usage: getcertnames DOMAIN" >&2
    return 1
  fi
  local domain=$1 tmp cert
  tmp=$(echo -e "GET / HTTP/1.0\nEOT" | openssl s_client -connect "$domain:443" -servername "$domain" 2>&1)
  if [[ $tmp != *"-----BEGIN CERTIFICATE-----"* ]]; then
    echo "no certificate found for $domain" >&2
    return 1
  fi
  cert=$(echo "$tmp" | openssl x509 -text -certopt 'no_aux, no_header, no_issuer, no_pubkey, no_serial, no_sigdump, no_signame, no_validity, no_version')
  echo "Common Name:"
  echo "$cert" | grep 'Subject:' | sed -e 's/^.*CN=//' -e 's/\/emailAddress=.*//'
  echo
  echo "Subject Alternative Names:"
  echo "$cert" | grep -A 1 'Subject Alternative Name:' | sed -e '2s/DNS://g' -e 's/ //g' | tr ',' '\n' | tail -n +2
}
