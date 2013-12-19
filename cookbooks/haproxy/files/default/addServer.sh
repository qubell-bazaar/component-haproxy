#!/bin/bash -x
server=$1
eval $(echo $2 | sed -e 's#^\(.*\)://\(.*\):\([0-9]*\)\(/.*\)$#proto="\1";balance_type="\2";fend_port="\3";url="\4"#')

base="/etc/haproxy"
backend_name=`md5sum <<< $proto$fend_port$url | cut -d " " -f1`
path="$fend_port/$proto-$fend_port"
server_name=`md5sum <<< $server | cut -d " " -f1`

###Check params###
if [ -z "$proto" -o -z "$fend_port" -o -z "$balance_type" -o -z "$server" ]; then
  echo "Not enought params to proceed"
  exit 1
fi

[ -z "$url" ] && url="/"

case $proto in
  http) mode="http" 
        proto="http";;
  tcp)  mode="tcp" 
        proto="tcp";;
  *) echo "Wrong proto" && exit 1 ;; 
esac

if [ "$mode" == tcp ] && [ "$url" != '/' ]; then
  echo "URL could be / only, when mode tcp"
  exit 1
fi

addFrontend(){
if [ ! -d "$base/$fend_port/" ]; then
    mkdir -p "$base/$path"
else
  echo "Frontend with $fend_port exists"
  exit 1;
fi

cat << EOF > "$base/$path/frontend.cfg"

frontend $proto-$fend_port
  bind *:$fend_port
  mode $mode
EOF
  if [ "$mode" == tcp ]; then
    cat << EOF >> "$base/$path/frontend.cfg"
  option tcplog
EOF
  else
    cat << EOF >> "$base/$path/frontend.cfg"
  option httplog
EOF
  fi
}

addBackend(){
if  [ -d "$base/$path/$backend_name" ]; then
  echo "Backend with such params exist"
  exit 1
else
  mkdir $base/$path/$backend_name 
fi
#default backend acl
if [ "$url" = "/" ]; then
  cat << EOF > "$base/$path/default.cfg"
  default_backend $backend_name
EOF
else
  #make block directive
  echo "acl-$backend_name" > "$base/$path/$backend_name/block.cfg"
fi
  #make acl
  cat << EOF > "$base/$path/$backend_name/acl.cfg"
  acl acl-$backend_name path_beg $url
  use_backend $backend_name if acl-$backend_name 
EOF

###todo:
#balance types check 
#based on check add appropriate options
#when tcp option httplod should be switched to option tcplog
  if [ "$mode" = tcp ]; then
    cat << EOF > "$base/$path/$backend_name/backend.cfg"

backend $backend_name
  balance $balance_type
EOF
  else
    cat << EOF > "$base/$path/$backend_name/backend.cfg"

backend $backend_name
  option forwardfor
  cookie SERVERID insert nocache indirect
  balance $balance_type
EOF
  fi
}

###addServer###
[ ! -e "$base/$path/frontend.cfg" ] && addFrontend;
[ ! -d "$base/$path/$backend_name" ] && addBackend;
###todo
#balance types check
#based on check add appropriate options
if [ "$mode" == tcp ]; then
  cat << EOF > "$base/$path/$backend_name/server.$server.cfg"
  server $server_name $server check
EOF
else
  cat << EOF > "$base/$path/$backend_name/server.$server.cfg"
  server $server_name $server check cookie $server_name
EOF
fi
