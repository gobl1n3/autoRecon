#!/bin/bash
header(){
    echo "
     ______     __  __     ______   ______     ______     ______     ______     ______     __   __    
    /\  __ \   /\ \/\ \   /\__  _\ /\  __ \   /\  == \   /\  ___\   /\  ___\   /\  __ \   /\ \-.\ .\   
    \ \  __ \  \ \ \_\ \  \/_/\ \/ \ \ \/\ \  \ \  __<   \ \  __\   \ \ \____  \ \ \/\ \  \ \ \-.\ .\  
     \ \_\ \_\  \ \_____\    \ \_\  \ \_____\  \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\  \ .\ 
      \/_/\/_/   \/_____/     \/_/   \/_____/   \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/ \/__/ 
                                                                                                    
                                    tool by gobl1n. Omnis Vir Lupus.
    "
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
    touch ./$1/$foldername/unreachable.txt
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

    sort -u ~/$1/$foldername/$1.txt
    #begin finding endpoints which respond from the subdomains, screenshot when available
    cat ./$1/$foldername/$1.txt | sort -u | while read line; do
    if [ $(curl --write-out %{http_code} --silent --output /dev/null -m 5 $line) = 000 ]
        then
        echo $line >> ./$1/$foldername/unreachable.txt
        else
        echo $line >> ./$1/$foldername/responsive.txt
        fi
    done
    python ~/Tools/webscreenshot/webscreenshot.py -o ./$1/$foldername/screenshots/ -i ./$1/$foldername/responsive.txt --timeout=10 -m
    
    cat ./$1/$foldername/responsive.txt | sort -u | while read line; do
        python3 ~/Tools/dirsearch/dirsearch.py -e php,asp,aspx,jsp,html,zip,jar,sql -u $line --max-rate=5 | tee -a ./$1/$foldername/dirs.txt
        #todo more tools? also choose different wordlist? not sure how good the default is. We required SecLists, may as well use. 
    done
    
    touch ./$1/$foldername/arjun.txt
    cat ./$1/$foldername/dirs.txt | sort -u | while read line; do
        arjun -u http://$line | tee -a ./$1/$foldername/arjun.txt 
    
    #tempoutput
    cat ./$1/$foldername/arjun.txt

    #TODO: Final thing to implement: some form of notification service for the scan ending, since 
    #this can likely take a significant amount of time overall. Email? Discord webhook? 

    #email()
    #discordAlert()
}

email() {
 #TODO, maybe permanently
}

discordAlert() {
    url="your discord webhook" 
    curl -H "Content-Type: application/json" -X POST '{"content": "Scan complete."}' $url
}

if [[ -z $@ ]]; then
  echo "Error: no targets specified."
  echo "Usage: ./autoRecon.sh <target>"
  exit 1
fi

path=$(pwd)
foldername=autorecon
main $1
