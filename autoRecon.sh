#!/bin/bash
header(){
    echo "
    ______     __  __     ______   ______     ______     ______     ______     ______     __   __    
    /\  __ \   /\ \/\ \   /\__  _\ /\  __ \   /\  == \   /\  ___\   /\  ___\   /\  __ \   /\ \-.\ .\   
    \ \  __ \  \ \ \_\ \  \/_/\ \/ \ \ \/\ \  \ \  __<   \ \  __\   \ \ \____  \ \ \/\ \  \ \ \-.\ .\  
     \ \_\ \_\  \ \_____\    \ \_\  \ \_____\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\  \ .\ 
      \/_/\/_/   \/_____/     \/_/   \/_____/   \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/  \/_/ 
                                                                                                    
    tool by gobl1n"
}

main(){
    clear
    header
    if [ -d "./$1"]
    then
     echo "starting"
    else
        mkdir ./$1
    fi
    mkdir ./$1/$foldername
    mkdir ./$1/$foldername/screenshots/
    touch ./$1/$foldername/unreachable.html
    touch ./$1/$foldername/responsive.txt
    touch ./$1/$foldername/dirs.txt

    autonrecon $1
}

autorecon() {
    #subdomain discovery
    python3 ~/Tools/Sublist3r/sublist3r.py -d $1 -t 5 -v -o ~/$1/$foldername/$1.txt
    curl -s "https://crt.sh?q=$1&output=json" | jq ".[].common_name,.[].name_value"| cut -d'"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g'| sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' | sort | uniq >> ~/$1/$foldername/$1.txt #credit to https://github.com/az7rb for this fcking parsing jesus christ
    amass enum -passive -d $1 | uniq >> ~/$1/$foldername/$1.txt #this still needs parsing
    #todo: add any more tools to this list for discovering subdomains

    ~/$1/$foldername/$1.txt | uniq > ~/$1/$foldername/$1.txt
    #begin finding endpoints which respond from the subdomains, screenshot when available
     cat ./$1/$foldername/$1.txt | sort -u | while read line; do
    if [ $(curl --write-out %{http_code} --silent --output /dev/null -m 5 $line) = 000 ]
        then
        echo $line >> ./$1/$foldername/unreachable.html
        else
        echo $line >> ./$1/$foldername/responsive.txt
        fi
    done
    python ~/Tools/webscreenshot/webscreenshot.py -o ./$1/$foldername/screenshots/ -i ./$1/$foldername/responsive.txt --timeout=10 -m
    #find endpoints
    cat ./$1/$foldername/responsive.txt | sort -u | while read line; do
        python3 ~/Tools/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar,sql -u $line --plain-text-report=$1/$foldername/dirs.txt
        #todo more tools? 
    done
    #arjun each response from dirsearch
    touch ./$1/$foldername/arjun.txt
    cat ./$1/$foldername/dirs.txt | sort -u | while read line; do
        arjun -u http://$line | uniq >> arjun.txt #maybe rework this line a bit
    #todo what to do with output? i stole enough of this from https://github.com/jhaddix/lazyrecon/, I'm not stealing his report as well
    #tempoutput
    cat ./$1/$foldername/arjun.txt

    #TODO: Final thing to implement: some form of notification service for the scan ending, since 
    #this can likely take a significant amount of time overall. Email? Discord webhook? TBD
    #Note: maybe write a method for each so either can be implemented as desired
}

if [[ -z $@ ]]; then
  echo "Error: no targets specified."
  echo "Usage: ./autoRecon.sh <target>"
  exit 1
fi

path=$(pwd)
foldername=autorecon
main $1
