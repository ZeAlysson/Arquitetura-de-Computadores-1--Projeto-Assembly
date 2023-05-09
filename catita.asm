;Jose Alisson Rocha da Silva - 20200022829

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

.data
    ;---Mensagens de solicitacao de dados
    requestEntrada db "Insira o arquivo.bmp de entrada: ", 0
    requestColor db "Informe o codigo da cor que deseja aumentar(0 - Azul, 1 - Verde, 2 - Vermelho): ", 0
    codCor dword 0 ;Variavel para armazenar o codigo da cor escolhida (resposta para requestCor)
    requestSoma db "Agora determine o valor da soma(0 a 255): ", 0
    soma dword 0 ;Variavel para armazenar o valor a ser somado
    requestSaida db "Insira o arquivo.bmp de saida: ", 0

    fileName db 50 dup(0)
    outputFile db 50 dup(0)
    pixel db 3 dup(0);array de 3 bytes representando um pixel da imagem
    cabImg db 54 dup(0);representa os 54 bytes de cabeçalho do arquivo.bmp
    
    ;---Handles e contadores
    inputHandle dword 0
    outputHandle dword 0
    console_count dword 0 
    tamanhoOutputString dword 0  
    readCount dword 0
    writeCount dword 0
    inputHandleFile dword 0
    outputHandleFile dword 0
    inputString db 50 dup(0)
    
.code
start:  
    xor eax, eax ; eax = 0
    xor ebx, ebx ; ebx = 0
    xor ecx, ecx ; ecx = 0
    xor edx, edx ; edx = 0

    ;---Handles para entrada e saida de dados
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ;---Solicita e ler arquivo de entrada
    invoke StrLen, addr requestEntrada
    mov tamanhoOutputString, eax
    invoke WriteConsole, outputHandle, addr requestEntrada, tamanhoOutputString, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr fileName, sizeof fileName, addr console_count, NULL
    ;---Trecho de codigo disponibilizado pelo professor para tratar a string de caracteres problematicos
    mov esi, offset fileName ; Armazenar apontador da string em esi
    proximo: 
        mov al, [esi] ; Mover caractere atual para al 
        inc esi ; Apontar para o proximo caractere 
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR 
        jne  proximo 
        dec esi ; Apontar para caracter anterior 
        xor al, al ; 0 ou NULL
        mov [esi], al ; Inserir NULL logo apos o termino do numero
   
    ;---Abertura do arquivo catita.bmp
    invoke CreateFile, addr fileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov inputHandleFile, eax



     ;---Solicita e ler o caractere da cor a ser alterada
    invoke StrLen, addr requestColor
    mov tamanhoOutputString, eax
    invoke WriteConsole, outputHandle, addr requestColor, tamanhoOutputString, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL 
    ;---Trecho de codigo disponibilizado pelo professor para tratar a string de caracteres problematicos
    mov esi, offset inputString ; Armazenar apontador da string em esi
    proximo2: 
        mov al, [esi] ; Mover caractere atual para al 
        inc esi ; Apontar para o proximo caractere 
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR 
        jne  proximo2 
        dec esi ; Apontar para caracter anterior 
        xor al, al ; 0 ou NULL
        mov [esi], al ; Inserir NULL logo apos o termino do numero
    ;Numeros precisam ser convertivos em tipos numericos entao:
    invoke atodw, addr inputString ;Valor convertido é armazenado em EAX e movido pra Variavel destinada codCor:
    mov codCor, eax 



    ;---Solicita e ler a soma para a cor a ser alterada
    invoke StrLen, addr requestSoma
    mov tamanhoOutputString, eax
    invoke WriteConsole, outputHandle, addr requestSoma, tamanhoOutputString, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL
    ;---Trecho de codigo disponibilizado pelo professor para tratar a string de caracteres problematicos
    mov esi, offset inputString ; Armazenar apontador da string em esi
    proximo3: 
        mov al, [esi] ; Mover caractere atual para al 
        inc esi ; Apontar para o proximo caractere 
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR 
        jne  proximo3 
        dec esi ; Apontar para caracter anterior 
        xor al, al ; 0 ou NULL
        mov [esi], al ; Inserir NULL logo apos o termino do numero
    ;Numeros precisam ser convertivos em tipos numericos entao:
    invoke atodw, addr inputString;valor convertido é armazenado em EAX e movido pra Variavel destinada soma:
    mov soma, eax



    ;---Solicita o nome do arquivo para saida
    invoke StrLen, addr requestSaida
    mov tamanhoOutputString, eax
    invoke WriteConsole, outputHandle, addr requestSaida, tamanhoOutputString, addr console_count, NULL
    invoke ReadConsole, inputHandle, addr outputFile, sizeof outputFile, addr console_count, NULL
    ;---Trecho de codigo disponibilizado pelo professor para tratar a string de caracteres problematicos
    mov esi, offset outputFile ; Armazenar apontador da string em esi
    proximo4: 
        mov al, [esi] ; Mover caractere atual para al 
        inc esi ; Apontar para o proximo caractere 
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR 
        jne  proximo4 
        dec esi ; Apontar para caracter anterior 
        xor al, al ; 0 ou NULL
        mov [esi], al ; Inserir NULL logo apos o termino do numero
    
    ;---Criando arquivo de saida
    invoke CreateFile, addr outputFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov outputHandleFile, eax
    invoke ReadFile, inputHandleFile, addr cabImg, sizeof cabImg, addr readCount, NULL
    ;---Escritura do arquivo
    invoke WriteFile, outputHandleFile, addr cabImg, sizeof cabImg, addr writeCount, NULL



    LoopLeituraPixel:;---Ler arquivo de 3 em 3 bytes/um pixel enquanto nao chegar ao final
        invoke ReadFile, inputHandleFile, addr pixel, sizeof pixel, addr readCount, NULL
        cmp readCount, 0 ;Checa se chegou no final do arquivo, se readCount = 0, fecha o arquivo e encerra o programa
        je encerra ;fecha o arquivo e encerra o programa apos ler o ultimo pixel

        ;---Chamada dos três parametros para a funcao ColorirPixel
        push soma ;chama valor a ser somado
        push codCor;chama codigo da cor
        push offset pixel;chama o pixel
        call ColorirPixel;chamada da funcao de modificacao    

        jmp LoopLeituraPixel

    ;Funcao que faz a soma   
    ColorirPixel:
        push ebp
        mov ebp, esp

        ;1) EBP+8: Parametro 1 contendo endereço de um array de 3 bytes representando um pixel(pixel db dup(3))
        mov ebx, DWORD PTR [ebp+8]

        ;2) EBP+12: Parametro 2 contendo um inteiro de 4 bytes representando uma cor a ser intensificada(codCor) 
        mov ecx, DWORD PTR [ebp+12]

        ;3) EBP+16: Parametro 3 contendo um inteiro de 4 byte representando o valor a ser somado a cor (soma)
        ;        DWORD PTR [ebp+16]

        
        mov al, [ebx][ecx] ; o numero do codigo da cor eh adicionado ao endereco do pixel e movido pra al
        add eax, DWORD PTR [ebp+16] ; realiza soma 
        cmp eax, 255
        jbe ArmazenaValor
        mov al, 255 ;se o valor da soma ultrapassar o valor máximo para um byte, o valor da cor eh definido como 255(maximo)
        ArmazenaValor:
        mov [ebx][ecx], al ;e se o valor nao ultrapassar o maximo, armazena o valor somado para o pixel

        mov esp, ebp
        pop ebp

        ;---Escreve o pixel alterado no arquivo de saida
        invoke WriteFile, outputHandleFile, addr pixel, sizeof pixel, addr writeCount, NULL
    
        ret 12  

    encerra:
        ;---Fechamento do arquivo e encerrando o programa
        invoke CloseHandle, inputHandleFile
        invoke CloseHandle, outputHandleFile
        invoke ExitProcess, 0    
end start
