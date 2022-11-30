#!/bin/bash

counter=0
countertemp=0

declare -a tab
declare -a tabtemp

while true
do
        curl -s https://www.boursorama.com/bourse/devises/taux-de-change-euro-dollar-EUR-USD/ > z.txt
        #val=$(cat z.txt | grep -oP '</div><div class="c-list-trading__item c-list-trading__item--value u-color-stream-up / u-ellipsis"><span class="c-instrument c-instrument--last" data-ist-last>\w+,\w+</span> \$US                                </div></a></li><li class="c-list-trading__line c-list-trading__line--half"' | grep -oP '\w+,\w+')
        val=$(cat z.txt | grep -oP '<span class="c-instrument c-instrument--last" data-ist-last>\w+,\w+\w+\w+' | grep -oP '\w+,\w+')

        #cat z.txt | grep -oP '</div><div class="c-list-trading__item c-list-trading__item--value u-color-stream-up / u-ellipsis"><span class="c-instrument c-instrument--last" data-ist-last>\w+,\w+</span> \$US                                </div></a></li><li class="c-list-trading__line c-list-trading__line--half"' | grep -oP '\w+,\w+' > x.txt
        #sed '1d' x.txt > z.txt
        #val=$(cat z.txt)

        TAMP=$(echo $val | sed 's/,//')
        val=$(($TAMP))

        #curl -s https://fr.investing.com/currencies/eur-usd > z.txt
        #val=$(cat z.txt | grep -oP '<span class="text-2xl bg-negative-light" data-test="instrument-price-last">' | grep -oP '\w+,\w+'
        echo  " Price of USD : "
        echo $val/10000 | bc -l

        counter=$(( $counter + 1 ))
        countertemp=$(( $countertemp + 1 ))

        tab[$(($counter))]=$val
        tabtemp[$(($countertemp))]=$val
        moy=0
        tot=0
        max=0
        min=10000000

        for n in "${tabtemp[@]}"
        do
                tot=$(($tot + $n))
                if  ((min > $n))
                then
                        min=$n
                fi
                if  (($n > max))
                then
                        max=$n
                fi
        done

        moy=$(($tot / ($countertemp)))

        val=$(awk "BEGIN {x=$val; y=10000; z=x/y; print z}")
        min=$(awk "BEGIN {x=$min; y=10000; z=x/y; print z}")
        moy=$(awk "BEGIN {x=$moy; y=10000; z=x/y; print z}")
        max=$(awk "BEGIN {x=$max; y=10000; z=x/y; print z}")


        channel_id="-1001515068928"
        BOTToken="5541824540:AAEV8V2xGma0AN3ySJ-p5kWmFOiRYHF4sTk"
        sleep 10
        if (( $(($countertemp % 10)) == 0 ))
        then
                now=$(date)
                curl --data chat_id=$channel_id= --data-urlencode "text=Price of USD on $now:
${val}" "https://api.telegram.org/bot$BOTToken/sendMessage?parse_mode=HTML"
        fi

        if (( $(($countertemp % 1440)) == 0 ))
        then
                now=$(date)
                curl --data chat_id=$channel_id= --data-urlencode "text=Date : $now
Moyenne : ${moy}
Min : ${min}
Max : ${max}" "https://api.telegram.org/bot$BOTToken/sendMessage?parse_mode=HTML"
        tot=0
        max=0
        min=1000000
        tabtemp=()
        countertemp=0
        echo " Price moy of USD :"
        echo $moy/10000 | bc -l
        moy=0
fi
done


exit
