.686
.model flat, stdcall 
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib
include \masm32\macros\macros.asm

.data?

fileHandle dword ?
     
.data

    

    requestEntrada db "Insira o nome do arquivo bitmap de entrada: ", 0AH
    requestSaida db "Insira o nome do arquivo bitmap de saida: ", 0AH
    requestCor db "Informe o codigo da cor que deseja aumentar(0 - Azul, 1 - Verde, 2 - Vermelho): ", 0AH
    requestSoma db "Agora determine o valor da soma(0 a 255): ", 0AH
    codCor db 5 dup(0) ;usigned char, armazena o codigo da cor escolhida (resposta para requestCor)
    
    

    inputHandle dd 0
    outputHandle dd 0
    console_count dd 0
    tam_outputString dd 0
    inputString db 50 dup(0)
    outputString db 50 dup(0)
    fileBuffer db 0

    pixel db 3 dup(0)
    
.code    
start:

;----Handles para entrada e saida de dados

    xor ebx, ebx ; ebx = 0
    xor eax, eax ; eax = 0

    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    menu:
    
        invoke StrLen, addr outputString
        
        ;---Requisita arquivo de entrada e trata a string de caracteres problematicos
        invoke WriteConsole, outputHandle, addr requestEntrada, sizeof requestEntrada, addr console_count, NULL
        invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL

        mov esi, offset inputString ; 
        proximo:
            mov al, [esi] ; Mover caracter atual para al
            inc esi ; Apontar para o proximo caracter
            cmp al, 48 ; Verificar se menor que ASCII 48 - FINALIZAR
            jl terminar
            cmp al, 58 ; Verificar se menor que ASCII 58 - CONTINUAR
            jl proximo
        terminar:
            dec esi ; Apontar para caracter anterior
            xor al, al ; 0 ou NULL
            mov [esi], al ; Inserir NULL logo apos o termino do numero

        ;---Abertura do arquivo de entrada
        invoke CreateFile, addr inputString, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandle, eax

        ;---Leitura do arquivo de entrada
        invoke ReadFile, fileHandle, addr fileBuffer, 10, addr readCount, NULL ; Le 10 bytes do arquivo


        ;--- 
        invoke StrLen, addr requestCor ; pergunta a cor
        mov tam_outputString, eax
        invoke WriteConsole, outputHandle, offset requestCor, sizeof requestCor, offset console_count, NULL
        invoke ReadConsole, inputHandle, offset codCor, sizeof codCor, offset console_count, NULL

        cmp codCor, 49 ;49 (ASCII) = 1 (DEC)
       
        invoke dwtoa, eax, addr outputString


        encerrar:
            invoke ExitProcess, 0
end start
