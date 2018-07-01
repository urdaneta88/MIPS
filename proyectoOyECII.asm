.data
	original: .asciiz "ENTRADA.txt"
	modificado: .asciiz "MODIFICADO.txt" #nombre del archivo modificado
	buffer: .space 255
	mensaje: .asciiz "Si desea instroducir un error, a continuacion preciona la tecla 0: "
	mensaje2: .asciiz "La suma original es: "
	mensaje3: .asciiz "La suma despues es: "
	mensaje4: .asciiz "Se detecto un error en la transferecia."
	mensaje5: .asciiz "No se detecto ningun error en la transferencia."
	espacio: .asciiz " "
	salto: .asciiz "\n"
	
.text
	#$t1 sera la variable que guarda la direccion del buffer
	#$t2 sera la variable que guardara el contador de los caracteres del texto
	#$t3 sera la variable que guarda la posicion del error pos = p / 2
	#$t4 sera la constante con el valor de fin de linea, si hay un salto de linea no suma en contador
	#$t5 sera la constante para salto de linea
	#$s3 es un contador temp para escribir
	#$s4 es la suma original de los caracteres sumOri
	#$s5 es la suma despues de modificar el archivo sumDes
	#$s6 sera mi valor para ver si se desea o no escribir el error
	#$s7 sera el valor pasado por el usuario para comprobar si desea o no el error
	
	main:
	
	addi $t4, $zero, 10		#valor del fin de linea
	addi $t5, $zero, 13		#valor del salto de linea
	
	jal printMensaje		#muestro el mensaje por pantalla
	
	li $v0, 5
	syscall	
	move $s7, $v0 			#aqui guardo la variable del usuario
	
	
	beq $s7, 0, siError		#si el valor introducido por pantalla es 1 agrega el error
	add $s6,$zero,0			#si no es igual a 0 le sumo 0
	j finError
	siError:
		add $s6,$zero,10	#al sumar 10 cuando sea llamado mas adelante sumara el error
	finError:
	
	jal abrirArchivo		#llamo a la funcion para abrir y leer el archivo
	div $t3,$t2,2			#con esto tengo la posicion del error
	
	jal escribirArchivo		#llamo a la funcion y creo el nuevo archivo
	jal imprimirSuma		#imprimo el valor de la suma original y la suma despues
	jal imprimirTransmision		#imprimo si la transferencia de datos tuvo o no un error
	jal fin				#llamo al fin del programa

	abrirArchivo:
		li $v0, 13       		#llamada al sistema para leer un archivo
		la $a0, original 		#nombre del archivo a leer
		li $a1, 0       		#flag para solo lectura
		li $a2, 0
		syscall            		#llamada al sistema para abrir el archivo
	
		move $s0, $v0      		#guardo el descriptor en $s0	
		la $t1, buffer			#muevo la direccion del buffer a el registro $t1
		
		while:
			li $v0, 14		#llamada al sistema para leer un archivo	
			move $a1, $t1		#cargar la direccion de buffer que tiene el string
			li $a2, 1		#este es el tamaño del string
			move $a0, $s0		#file descriptor
			syscall
		
			lb $s1, 0($t1)
			add $s4, $s4, $s1	#aqui voy sumando los valores de los caracteres sumOri
			blez $s1, finwhile	#si llego al fin del archivo dejo de recorrerlo
			add $t1, $t1, 1		#buffer++ me muevo en la direccion del buffer
			beq $t4, $s1, while	#si el caracter es un fin de linea no sumo contador
			beq $t5, $s1, while	#si el caracter es un salto de linea no sumo contador
			add $t2, $t2, 1		#contador de caracteres ++
			
			
			j while
	
		finwhile:
	
			# cerrando el archivo
			li $v0, 16 		#llamada al sistema para cerrar el archivo
			move $a0, $t0 		# Restauro fd
			syscall
			jr $ra			#regreso al main
	
	
	escribirArchivo:
 		#voy a abrir un archivo que no existe
 		li $v0, 13 			#llamado al sistema para abrir el archivo
 		la $a0, modificado 		#nombre del archivo destino
		li $a1, 1 			#pongo el a1 en 1 parar escritura
		li $a2, 0
		syscall 			#open a file (file descriptor returned in $v0)
		
		move $t0, $v0 			#guardo el descriptor del archivo en $t0

		# Voy a escribir en el archivo que acabo de crear
		la $t1, buffer
		while2:
			li $v0, 15 		#el llamado al sistema porque voy a escibir
			lb $t6, 0($t1)		#cargo un byte del buffer para comprobar
			
			############AQUI INSERTO EL ERROR EN LA POSICION pos= p/2
			bne $s3,$t3, NO 
			add $t6,$t6, $s6		#aqui le sumo 10 o 0 a la posicion pos
			sb $t6, 0($t1)
			NO:
				la $a1, 0($t1) 		#la direccion del buffer desde donde voy a escribir
				li $a2, 1 		#el tamaño del buffer sera de un caracter
				move $a0, $t0 		#pongo el descriptor del archivo en $a0
				syscall 		#escribo en el archivo
				addi $t1, $t1, 1	#me muevo en el la direccion del buffer
				addi $s3, $s3, 1	#contador temp para escribir
				add $s5, $s5, $t6	#aqui voy sumando los valores de los caracteres despues de ser modificados sumDes
				bne $t6,$zero,while2
	
		# cerrando el archivo
		li $v0, 16 			#llamada al sistema para cerrar el archivo
		move $a0, $t0 			# Restauro fd
		syscall
		jr $ra				#regreso al main
		
	printMensaje:
		li $v0, 4 			#llamada para imprimir un str
		la $a0, mensaje 		#direccionamiento de str a imprimir
		syscall 			#imprimi el string
		jr $ra				#regreso al main

	imprimirSuma:
		li $v0, 4 			#llamada para imprimir un str
		la $a0, mensaje2 		#direccionamiento de str a imprimir el mensaje2
		syscall 			#imprimi el string
		
		li $v0, 1 			#llamada para imprimir un str
		move $a0, $s4 			#direccionamiento de str a imprimir el valor de $s4
		syscall 			#imprimi el string
		
		li $v0, 4 			#llamada para imprimir un str
		la $a0, espacio 		#direccionamiento de str a imprimir el espacio
		syscall 			#imprimi el string
		
		li $v0, 4 			#llamada para imprimir un str
		la $a0, mensaje3 		#direccionamiento de str a imprimir el mensaje3
		syscall 			#imprimi el string
		
		li $v0, 1 			#llamada para imprimir un str
		move $a0, $s5 			#direccionamiento de str a imprimir el valor de $s5
		syscall 			#imprimi el string
		
		jr $ra				#regreso al main
		
	imprimirTransmision:
	
		li $v0, 4 			#llamada para imprimir un str
		la $a0, salto 			#direccionamiento de str a imprimir el espacio
		syscall 			#imprimi el string
		
		beq $s4, $s5, SinError
		li $v0, 4 			#llamada para imprimir un str
		la $a0, mensaje4 		#direccionamiento de str a mensaje4 
		syscall 			#imprimi el string
		jr $ra
		
		SinError:
			li $v0, 4 		#llamada para imprimir un str
			la $a0, mensaje5 	#direccionamiento de str a mensaje4 
			syscall 		#imprimi el string
			jr $ra			#regreso al main

	fin:
		li $v0, 10 			#llamada al sistema para finalizar el programa
		syscall 
