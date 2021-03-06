#!/bin/bash

export PATH=/usr/local/bin:$PATH

test $# -ne 4 && echo "Usage: `basename $0` LAT LON NAME LIGHT/DARK" && exit $E_BADARGS

hash /usr/local/bin/webkit2png &> /dev/null
if [ $? -eq 1 ]; then
    echo "WebKit2Png not found."
	echo "brew install webkit2png"
    exit 1
fi

hash /usr/local/bin/convert &> /dev/null
if [ $? -eq 1 ]; then
    echo "ImageMagick not found."
	echo "brew install imagemagick"
    exit 1
fi

if [[ $4 =~ !(LIGHT|DARK) ]] ; then
    echo "Arg 4 must be one of LIGHT or DARK"
	echo $4
    exit $E_BADARGS
fi

cd `dirname $0`

# rawurl code from http://stackoverflow.com/questions/296536/urlencode-from-a-bash-script
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

export TEMPLATE_URL='http://forecast.io/embed/#lat=$LAT&lon=$LON&name=$NAME&static-skycons=1&hide-header=1'

export URL=$(echo $TEMPLATE_URL | sed -e "s/\$LAT/$1/" -e "s/\$LON/$2/" -e "s/\$NAME/$( rawurlencode "$3" )/")

echo "Converting to image"
webkit2png --width=500 --clipwidth=500 --height=245 --scale=1 -F --transparent --delay=5 -o tmpWeather -D /tmp $URL

echo "Running image smoothing"
if [[ $4 == "LIGHT" ]]; then
	convert -quiet -negate png:/tmp/tmpWeather-full.png png:/tmp/GeekWeather.png
	rm /tmp/tmpWeather-full.png
elif [[ $4 == "DARK" ]]; then
	mv /tmp/tmpWeather-full.png /tmp/GeekWeather.png
fi

exit 0

