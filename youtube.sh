#!/usr/bin/env bash
COLOR=0
default_channel="https://www.youtube.com/TerminalRootTv"

usage() {
  cat <<EOF
usage: ${0##*/} [options] [video]

  Options:

     -a              show title
     -b              show publications
     --help          show info of the tags
     --no-color      unable colors

EOF
}

if [[ $1 = @(--help) ]];then
   usage
   exit 0
fi

[[ $1 = @(--version) ]] && sed -n '/^#.*version/p' $0 | sed 's/#.//' && exit 0
[[ $1 =~ ^http ]] && todos=1
[[ -z $1 ]] && todos=1


function youtube() {

while [[ "$1" ]];do
  [[ "$1" =~ ^http ]] && URL=$1
  [[ "$1" =~ ^--no-color$ ]] && COLOR=1
shift
done

if [[ "$COLOR" == "0" ]];then
  cor1="\e[36;1m" ; cor2="\e[33;1m" ; of="\e[m" ; cor3="\e[30;1m"
else
  cor1=;cor2=;of=;cor3=
fi

if [[ -z "$URL" ]];then
  if [[ -z "$default_channel" ]];then
    echo 'Informe a url do video.'
    exit 1
  else
    local recente=$(mktemp)
    wget "$default_channel/videos" -O "$recente" 2>/dev/null
    local idv=$(grep 'data-context-item-id' "$recente" | sed -n '1p' | sed 's/.*=\"//g' | sed 's/\"//g')
    local URL="https://youtube.com/watch?v=$idv"
    echo -ne  "${cor1}+recente...${of}\r"
  fi
fi

   #cor1="\e[32;1m" ; cor2="\e[37;1m" ; of="\e[m"
   vcsabia=$(mktemp)
   channel=$(mktemp)
   urll="http://www.youtube.com/channel"
   wget "$URL" -O "$vcsabia"  2>/dev/null

   titulo=$(grep '<title>' "$vcsabia" | sed 's/<[^>]*>//g' | sed 's/ - YouTube.*//g')
   publi=$(grep -i 'published' "$vcsabia" | sed 's/.\{46\}//' | sed 's/\".*//g')
   inscritos=$(sed -n '/subscriber-count/{p; q;}' "$vcsabia" | sed 's/<[^>]*>//g' | sed 's/.\{30\}//')
   id=$(grep -n 'isOwnerView' "$vcsabia" | sed 's/.*channelId//g;s/isOwnerView.*//g' | sed 's/.\{5\}//' | sed 's/\\.*//g')
   wget "$urll/$id" -O "$channel" 2>/dev/null
   canal=$(sed -n '/title/{p; q;}' "$channel" | sed 's/<title> //g;s/.\{1\}//' | sed -n '1p')
   likes=$(grep 'like-button-renderer-like-button' "$vcsabia" | sed 's/<[^>]*>//g' | sed -n '1p' | sed 's/ //g')
   dislikes=$(grep 'like-button-renderer-dislike-button' "$vcsabia" | sed 's/<[^>]*>//g' | sed -n '1p' | sed 's/ //g')
   dados=("$titulo" "$publi" "$inscritos" "$canal" "$likes" "$dislikes")

}

get_all() {

   echo -e "${cor1}TITULO: ${cor2}${dados[0]}"
   echo -e "${cor1}PUBLICADA: ${cor2}${dados[1]}"
   echo -e "${cor1}INSCRITOS: ${cor2}${dados[2]}"
   echo -e "${cor1}NOME DO CANAL: ${cor2}${dados[3]}"
   echo -e "${cor1}TODOS OS LIKES: ${cor2}${dados[4]}"
   echo -e "${cor1}TODOS OS DISLIKES: ${cor2}${dados[5]}"
}

echo -en 'Aguarde ..\r'
youtube "$@"

if [[ "$@" == "--no-color" ]];then
  set -- $(echo $@ | sed 's/\-\-no\-color/-ab/g')
fi

while getopts ':abcdef' flag; do

  case $flag in
     a) echo -e "${cor1}TITULO: ${cor2}${dados[0]}";;
     b) echo -e "${cor1}PUBLICAÇAO: ${cor2}${dados[1]}";;
     c) echo -e "${cor1}INSCRITOS: ${cor2}${dados[2]}";;
     d) echo -e "${cor1}NOME DO CANAL: ${cor2}${dados[3]}";;
     e) echo -e "${cor1}TODOS OS LIKES: ${cor2}${dados[4]}";;
     f) echo -e "${cor1}TODOS OS DISLIKES: ${cor2}${dados[5]}";;
     *) echo Opçao invalida ${OPTARG} >&2 ;;
  esac
  shift $(( $OPTIND -1 ))
done

if [[ "$todos" == "1" ]];then
     get_all
fi

