#!/usr/bin/env bash



# Colores
#Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

# Función Ctrl + C
ctrl_c() {
    echo -e "\n\n${red}Saliendo del programa${end}"
    tput cnorm; exit 1
}

trap ctrl_c INT

# Función de ayuda
function help_Panel() {
    echo -e "\t${blue}\U0001F3B0 Panel de ayuda de $0:${end}"
    echo -e "\n-h Mostrar el panel de ayuda."
    echo -e "${green}-m Ingresar la cantidad de dinero para apostar. ${end}"
    echo -e "${gray}-t Técnica a usar al apostar${end} ${yellow}(${end}${turquoise}martingala${end}${yellow}/${end}${turquoise}inverse Labrouchere${end}${yellow})${end}"
}
# Función de apuestas
# Martingala
martingala() {
    echo -e "${gray}Dinero actual:${end} ${green}${dinero}€${end}"
    echo -e "${green}¿Cuánto dinero quieres apostar? \U0001F4B8 -->${end}" && read initial_bet
    echo -e "${gray}¿Qué deseas apostar continuamente (Par/Impar)? -->${end}" && read par_impar

if [[ ! $initial_bet =~ ^[0-9]+$ ]]; then
    echo -e "${red}Introduce un número válido rey.${end}\n\n"
    exit 1

elif [ $initial_bet -gt $dinero ]; then
	echo -e "\n [!] No puedes apostar más dinero que no tienes." ; exit 1
fi


if [ "$par_impar" != "par" ] && [ "$par_impar" != "impar" ]; then
	echo "Introduce una opción válida (par/impar)"
	exit 1
fi


    echo -e "${gray}Vamos a jugar con una cantidad inicial de${end} ${green}${initial_bet}€${end} ${gray}a${end} ${blue}${par_impar}${end}\n\n"
      
    

   sleep 3


    backup_bet=$initial_bet
    lost_counter=0
    declare -i play_counter=1
    declare -a numeros_perjudicados=()
    tput civis # quitar
    while true; do
       
if [ $initial_bet -gt $dinero ]; then
	echo "No tienes suficiente saldo para realizar la apuesta."
	echo "GG! Saldo final: ${dinero}" 
	tput cnorm
	break
         fi

	dinero=$(($dinero-${initial_bet}))
        echo -e "${yellow}Acabas de apostar${end} ${green}${initial_bet}€${end}"
        echo -e "${gray}Tu balance actual es:${end} ${green}${dinero}€${end}"

        random_number=$(($RANDOM % 37))
        echo -e "${gray}El número que ha salido es:${end} ${blue}${random_number}${end}"

        if [ "$par_impar" == "par" ]; then
            if [ $random_number -eq 0 ]; then
		((lost_counter++))
		numeros_perjudicados+=($random_number)		

		echo "${red}El número es 0, has perdido.${end}"

                echo -e "${gray}Tu balance actual es:${end} ${green}${dinero}€\n${end}"
                initial_bet=$(($initial_bet*2))

            elif [ $((${random_number} % 2)) -eq 0 ]; then
               unset numeros_perjudicados[@]
		    echo -e "${green}¡El número es par, has ganado!${end}"
        
	       # Devolvemos la apuesta inicial + las ganancias
                dinero=$(($dinero + $initial_bet * 2))
                echo -e "${gray}Tu nuevo balance es:${end} ${green}${dinero}€\n${end}"
                initial_bet=$backup_bet
            else
                echo -e "${red}El número es impar, ¡has perdido!${end}"
                echo -e "${gray}Tu balance actual es:${end} ${green}${dinero}€\n${end}"
		((lost_counter++))
		numeros_perjudicados+=($random_number)
		initial_bet=$(($initial_bet*2))
            fi
        elif [ "$par_impar" == "impar" ]; then
            if [ $random_number -eq 0 ]; then
                echo "${red}El número es 0, has perdido.${end}"
		((lost_counter++))
		numeros_perjudicados+=($random_number)
		echo -e "${gray}Tu balance actual es:${end} ${green}${dinero}€${end}"
                initial_bet=$(($initial_bet*2))
            elif [ $((${random_number} % 2)) -eq 1 ]; then
		    unset numeros_perjudicados[@]
                echo -e "${green}¡El número es impar, has ganado!${end}"
                # Devolvemos la apuesta inicial + las ganancias
                dinero=$(($dinero + $initial_bet * 2))
		unset numeros_perjudicados
                echo -e "${gray}Tu nuevo balance es:${end} ${green}${dinero}€\n${end}"
                initial_bet=$backup_bet
            else
		    ((lost_counter++))
		    numeros_perjudicados+=($random_number)
		echo -e "${red}El número es par, ¡has perdido!${end}"
                echo -e "${gray}Tu balance actual es:${end} ${green}${dinero}€${end}\\\\n"
                initial_bet=$(($initial_bet*2))
            fi
        fi
   ((play_counter++))


    done
  
    numeros=$(printf "%s" "${numeros_perjudicados[@]/#/, }" | sed 's/^[, ]*//')
   echo -e "Has jugado un total de ${play_counter} veces y has sido perjudicado ${lost_counter} veces por los números: ${numeros}."
    tput cnorm # recuperar
}
# Indicadores (opcional)
declare -i counter=0

while getopts "m:t:h" caso; do
    case $caso in
        h) help_Panel ;;
        m) dinero=$OPTARG ;;
        t) technique="$OPTARG"
    esac
done

if [ $dinero ] && [ $technique ]; then
    if [ "$technique" == "martingala" ]; then
        martingala
    else
        echo -e "${red}⚠️  Técnica introducida inexistente.${end}\n\n"
        help_Panel
    fi
else
    help_Panel
    exit
fi
