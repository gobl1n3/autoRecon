# autoRecon
Personal attempt at scripting initial recon for domain testing. 
Bastardized from [lazyrecon]("https://github.com/jhaddix/lazyrecon/"). 
This project likely will later be renamed "Greed", as part of a larger group of projects I may or may not ever finish. 
Accepting any pull requests I think are cool. Only requirement is sneaking in a funny latin quote somewhere. 


This project assumes a few things: first, that you have the following tools installed in their respective folders in ~/Tools/:
* Sublist3r
* webscreenshot
* dirsearch
* SecLists
It also assumes the following tools are in your $PATH:
* Amass
* Arjun


Eventually, this will be part of a "Seven Deadly Sins" project. In which this tool is Greed because you want to know everything, Wrath tests out ever possible exploit from greed's output, Sloth tests DoS, etc etc. This idea is not fleshed out yet. I assume given my predisposition to not writing much code this will take significant time. 

You will have to run chmod +x ./autoRecon.sh in order to run this script. 