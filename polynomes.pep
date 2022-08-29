; ************************************************************
;       Programme: polynomes.pep     version PEP8.2 sous Windows
;
;       INF2171 - TP1
;       Un programme qui permet d?effectuer quelques opérations 
;       sur polynômes avec les coefficients entiers modélisés 
;       par des listes doublement chaînées.
;
;       auteur:         Leonid Glazyrin
;       code permanent: GLAL77080105
;       courriel:       de891974@ens.uqam.ca
;       date:           8/4/2022
;       cours:          INF2171
; ***********************************************************
;
         LDA     0,i
         LDX     0,i
;-----------------------------------------------------
main:    SUBSP   6,i         ; reserver espace sur pile pour les heads
         STRO    msgPoly1,d  ; print()
         CALL    makeP       ; créer le premier polynôme p1
         CHARO   '\n',i      ; println()
         STRO    msgPoly1,d  ; print()
         CALL    printP      ; afficher le premier polynôme p1
         STX     head1,s
         CALL    mulNbP      ; multiplier p1 par -10
         STRO    msgPMult,d  ; print()
         CALL    printP      ; afficher le polynôme p = p1*(-10)
         STRO    msgPoly2,d  ; print()
         CALL    makeP       ; créer le deuxième polynôme p2
         STX     head2,s
         STRO    msgPoly2,d  ; print()
         CALL    printP      ; afficher le deuxième polynôme p2
         CALL    addPs       ; additionner p1 et p2
         LDX     head3,s
         STRO    msgPAddi,d  ; print()
         CALL    printP      ; afficher p = p1+p2
fin:     STOP                ; exit()
head1:   .EQUATE 0           ; polynome 1
head2:   .EQUATE 2           ; polynome 2
head3:   .EQUATE 4           ; polynome additionner pour valeur de retour par la pile
;--------------------------------------------------------
;
; makeP: crée une liste des termes d?un polynôme 
;        et retourne un pointeur vers son premier élément 
;     
; OUT:   X = adresse du pointeur head qui pointera vers premier terme
;
; ERR:   S'il y a debordement l'execution s'arrete
;        et un message correspondant est affiche
;
makeP:   SUBSP   4,i         ;reserver espace sur pile
         LDA     0,i
         STA     head,s      ;reiniialiser cette valeur a zero
loop1:   STRO    msgMenu,d   ;print()
         DECI    choix,s     ;input(choix)
         LDA     choix,s
         BRV     debord      ;if debordement break;
         CPA     1,i
         BREQ    choix1      ;if choix == 1
         CPA     2,i
         BREQ    choix2      ;if choix == 2
         STRO    errChoix,d  ;else print(error)
         BR      loop1       ;while(true)
choix1:  CALL    creer       ;creer()
         LDA     head,s
         CALL    inserer     ;inserer(head)
         STA     head,s      ;update la valeur head
         BR      loop1       ;while(true)
choix2:  LDX     head,s      ;X = P[head]
         RET4                ;return 
choix:   .EQUATE 0           ;stocker le choix
head:    .EQUATE 2           ;contient le pointeur tete
;--------------------------------------------------------
;
; creer: La fonction creer permet de saisir les données 
;        sur un terme ( un coefficient et un degré de terme) 
;        et crée un maillon de liste
;
; OUT:   X = adresse du nouveau maillon
;
; ERR:   S'il y a debordement l'execution s'arrete
;        et un message correspondant est affiche
;
creer:   SUBSP   8,i         ;reserver espace sur pile
         LDA     8,i
         CALL    new         ;new maillon
         STRO    msgCoeff,d  ;print
         DECI    coeffic,x   ;input(coefficient)
         LDA     coeffic,x
         BRV     debord      ;if coefficient cause debordement break;
         STRO    msgDegre,d  ;print
         DECI    degre,x     ;input(degre du terme)
         LDA     degre,x
         BRV     debord      ;if degre cause debordement break;
         LDA     NULL,i      ;ecraser les valeurs precedante
         STA     next,x      ;maillon.next = NULL
         STA     prev,x      ;maillon.prev = NULL
         ADDSP   8,i
         CHARO   '\n',i      ;print
         RET0                ;return
;--------------------------------------------------------
;
; inserer: insert un maillon dans la liste à la bonne position. 
;          La liste doit être organisée en ordre décroissant 
;          de degrés des termes.
;
; IN:    A = adresse du premier maillon (head)
;        X = adresse du nouveau maillon a inserer
;
; OUT:   A = adresse du maillon head, car il pourrait avoir ete modifie
;
inserer: SUBSP   2,i         ;reserver espace pour addresse head
         CPA     0,i         ;if A == 0
         BREQ    casVide     ;case chaine initiale vide
         SUBSP   8,i         ;reserver espace
         STA     addHead,s   ;tete av changer si le nouveau maillon devient head
loop3:   STA     current,s   ;pointe vers le maillon avec lequelle on compare
         STX     addNew,s    ;pointe vers le maillon qu'on insere
         LDA     degre,x
         STA     deg,s       ;degre du maillon a inserer
         BREQ    constant    ;pour toujours ajouter les constantes a la fin
         LDX     current,s
         LDA     degre,x     ;degre du maillon auquel on compare
         BREQ    casLess     ;pour toujours laisser la constante en dernier
         CPA     deg,s
         BRGT    casMore     ;maillon a insere est de degre plus petit que current
         BRLT    casLess     ;maillon a inserer doit aller a la 'place' de current
         BREQ    casEgale    ;degre egaux
constant:LDX     current,s
         LDA     degre,x     ;verifier le cas ou il y a deja une constante
         CPA     deg,s
         BREQ    casEgale    ;degre egaux
         BR      casMore
casLess: LDA     prev,x      ;load maillon precedant
         BREQ    casFirst    ;if current.prev == NULL {casFirst()}
         STA     precAdd,s   
         LDA     addNew,s
         STA     prev,x      ;current.prev = newMaillon
         LDX     addNew,s
         LDA     current,s
         STA     next,x      ;newMaillon.next = current
         LDA     precAdd,s
         STA     prev,x      ;newMaillon.prev = current.prev
         LDX     prev,x 
         LDA     addNew,s
         STA     next,x      ;prevMaillon.next = newMaillon
         BR      finIns      ;fin
casFirst:LDX     current,s   ;cas ou le maillon a inserer doit devenir le head
         LDA     addNew,s
         STA     prev,x      ;head.prev == newMaillon
         LDX     addNew,s
         LDA     current,s
         STA     next,x      ;newMaillon.next == head
         STX     addHead,s   ;head = newMaillon
         BR      finIns      ;fin
casMore: LDA     next,x      ;A = current.next pour iterer sur le maillon suivant
         BREQ    ajoutFin    ;if current.next == NULL {break}
         LDX     addNew,s    ;remettre adresse du maillon a inserer dans X
         BR      loop3       ;while(true)
casEgale:LDA     coeffic,x   ;cas ou les degres sont egaux
         LDX     addNew,s
         ADDA    coeffic,x
         BRV     debord      ;si l'addition des coefficient cause un debordement
         LDX     current,s
         STA     coeffic,x   ;current.coefficient = current.coefficient + newMaillon.coefficient
         BR      finIns      ;fin
ajoutFin:LDA     addNew,s    ;ajout en fin de liste
         LDX     current,s
         STA     next,x      ;curent.next = newMaillon
         LDA     current,s
         LDX     addNew,s
         STA     prev,x      ;newMaillon.prev = current
         BR      finIns      ;fin
casVide: STX     addHead,s   
         LDA     addHead,s   ;charger X dans A car newMaillon devient head de la chaine
         RET2                ;return
finIns:  LDA     addHead,s   ;A = head
         ADDSP   10,i        ;desalouer espace pile
         RET0                ;return
addHead: .EQUATE 0           ;adresse tete
current: .EQUATE 2           ;adresse maillon courant
addNew:  .EQUATE 4           ;adresse maillon a inserer
deg:     .EQUATE 6           ;stocker le degre pour comparer
precAdd: .EQUATE 8           ;adresse maillon precedant au maillon courant
;--------------------------------------------------------
;
; printP:affiche le contenu d?une liste polynôme.
;
; IN:    X = addresse du premier terme (head)
;
printP:  BREQ    vide        ;print(polynome vide)
         SUBSP   4,i         ;reserver espace pile
         STA     saveA,s     ;sauvegarder les registres
         STX     headP,s
loop2:   LDA     coeffic,x
         BREQ    suiv        ;if coefficient == 0: continue
         BRGT    plus        ;if coefficient > 0: plus()
         BR      skip        ;else skip()
plus:    LDA     prev,x      ;si c'est un terme positif qui est premier dans la chaine
         BREQ    skip        ;on n'imprime pas de '+'
         LDX     prev,x 
         LDA     coeffic,x   ;si le terme precedant a '0' comme coefficient il ne sera pas imprimer
         BREQ    skip2       ;donc aussi pas besoin de '+'
         CHARO   '+',i       ;print('+')
skip2:   LDX     next,x      ;restaurer X
skip:    LDA     coeffic,x   ;coefficient = maillon.coefficient
         CPA     1,i         ;if coefficient == 1
         BREQ    noCoef      ;on ne l'imprime pas
         DECO    coeffic,x   ;print(coefficient)
noCoef:  LDA     degre,x     ;if degre == 0
         BREQ    suiv        ;on ne l'imprime pas
         CHARO   'x',i       ;print('x')
         CPA     1,i         ;if degre == 1
         BREQ    suiv        ;on n'imprime pas l'exposant
         CHARO   '^',i       ;print('^')
         DECO    degre,x     ;print(degre)
suiv:    ADDA    next,x      ;gerer le cas special ou un terme existe mais degre 0
         ADDA    prev,x      ;et il le seul terme dans la chaine
         BREQ    finPrint       
         LDX     next,x      ;sinon on va au terme suivant
         BREQ    finPrint    ;if next == NULL
         BR      loop2       ;break
finPrint:LDX     headP,s     ;restaurer les registres
         LDA     saveA,s
         CHARO   '\n',i
         RET4                ;return
vide:    STRO    msgPVide,d  ;gerer cas chaine vide
         RET0                ;return
headP:   .EQUATE 0           ;sauvegarder addresse head de la chaine
saveA:   .EQUATE 2           ;sauvegarder et restaurer registre A
;---------------------------------------------------------
;
; addPs: additionne deux polynômes en retournant 
;        l?adresse du polynôme résultat crée
;
; IN:    tete1 = adresse head du premier polynome, passe par la pile
;        tete2 = adresse head du deuxieme polynome, passe par la pile
; OUT:   retour = adresse du polynome resultant de l'addition, passe par la pile
;
addPs:   SUBSP   10,i        ;reserver espace sur la pile
         LDA     NULL,i      
         STA     temHead,s   ;reinitialiser son contenu entre les utilisations
         LDA     -1,i        ;initialiser le compteur de polynomes
         STA     count,s     ;a -1 pour optimiser le BREQ 
         LDX     tete1,s     ;if polynome 1 vide
         BREQ    finAdd
         BR      loop5       ;else
second:  LDX     tete2,s     ;pour additionner le deuxieme polynome
         BREQ    finAdd      ;if polynome 2 vide
loop5:   STX     origin,s    ;X = current
         LDA     coeffic,x   ;copier toute les valeurs pour les mettres dans le nouveau maillon
         STA     temCoef,s
         LDA     degre,x
         STA     temDeg,s
creer3:  LDA     8,i         ;version differente de creer
         CALL    new         ;new Maillon
         LDA     temCoef,s   ;coller toute les valeurs dans le nouveau maillon
         STA     coeffic,x
         LDA     temDeg,s
         STA     degre,x
         LDA     NULL,i      ;ecraser les valeurs precedante
         STA     next,x      ;newMaillon.next = NULL
         STA     prev,x      ;newMaillon.prev = NULL
         LDA     temHead,s   ;A = head de la nouvelle chaine polynome 3
         CALL    inserer     ;inserer() ce maillon dans la nouvelle chaine
         STA     temHead,s   ;update head de polynome 3
         LDX     origin,s    ;X = current.next
         LDX     next,x      ;pour traiter le prochain maillon
         BREQ    finAdd      ;fin
         BR      loop5       ;while(true)
finAdd:  LDA     count,s
         ADDA    1,i
         STA     count,s     ;if count == 0; 
         BREQ    second      ;le deuxieme polynome vient d'etre additionner donc fini
         LDA     temHead,s   ;A = head du polynome 3
         STA     retour,s    ;stocker A sur la pile
         ADDSP   10,i        ;desalouer
         RET0                ;return  
tete1:   .EQUATE 12          ;head du polynome 1
tete2:   .EQUATE 14          ;head du polynome 2
retour:  .EQUATE 16          ;valeur de retour
origin:  .EQUATE 0           ;sert a pointer vers maillon courant
temCoef: .EQUATE 2           ;sert pour copier/coller coefficient
temDeg:  .EQUATE 4           ;sert pour copier/coller degre
temHead: .EQUATE 6           ;head de polynome 3
count:   .EQUATE 8           ;compte le nombre de polynome qui ont ete additionne
;--------------------------------------------------------
;
; mulNbP:multiplie un polynôme par une constante (-10)
;        et retourne le polynôme résultat
; 
; IN:    X = addresse du maillon tete du polynome a multiplier
; OUT:   X = addresse du maillon tete du polynome resultant de la multiplication
;
mulNbP:  CPX     0,i         ;pour eviter le cas quand A == 0
         BREQ    vide3       ;if polynome vide
         SUBSP   10,i        ;allouer espace
         LDA     NULL,i
         STA     tempHead,s  ;reinitialiser la valeur entre les executions
loop4:   STX     original,s  ;sauvegarder current
         LDA     coeffic,x   ;sauvegarder les valeurs pour les transferer dans la copie
         STA     tempCoef,s
         LDA     degre,x
         STA     tempDeg,s
creer2:  LDA     8,i         ;version differente de creer
         CALL    new         ;new Maillon
         LDA     tempCoef,s
         ASLA                ;coefficient * 2
         BRV     debord      ;if debordement
         STA     temp2x,s    ;besoin pour 4*2 + 2 <--
         ASLA                ;coefficient * 2 (x4)
         BRV     debord      ;if debordement
         ASLA                ;coefficent * 2  (x8)
         BRV     debord      ;if debordement
         ADDA    temp2x,s    ;4xcoeffcient + 2xcoefficient
         BRV     debord      ;if debordement
         NEGA                ;car on multiplie par (-)10
         BRV     debord      ;cas ou nombre est -32768 et ne peut devenir 32768
         STA     coeffic,x   ;newMaillon.coefficient = 10*current.coefficient
         LDA     tempDeg,s
         STA     degre,x     ;newMaillon.degre = current.degre
         LDA     NULL,i      ;ecraser les valeurs precedante
         STA     next,x      ;newMaillon.next = NULL
         STA     prev,x      ;newMaillon.prev = NULL
         LDA     tempHead,s  ;A = head du nouveau polynome
         CALL    inserer     ;inserer()
         STA     tempHead,s  ;update head du nouveau polynome
         LDX     original,s
         LDX     next,x      ;X = current.next
         BREQ    finMul      ;if next == NULL{break}
         BR      loop4       ;while(true)
finMul:  LDX     tempHead,s  ;retourner l'adresse du polynome qui est p1*(-10)
         ADDSP   10,i        ;desalouer
vide3:   RET0                ;return
original:.EQUATE 0           ;pointe vers maillon courant sur la chaine a multiplier
tempCoef:.EQUATE 2           ;pour copier/coller coefficient
tempDeg: .EQUATE 4           ;pour copier/coller degre
tempHead:.EQUATE 6           ;pointe vers premier maillon du nouveau polynome
temp2x:  .EQUATE 8           ;pour stocker coefficient * 2
;--------------------------------------------------------
;
; debord:au cas ou il y a debordement
;
debord:  STRO    errDebor,d  ;print(error message)
         STOP                ;exit(1)
;--------------------------------------------------------
;
; Constantes Globales
;
NULL:    .EQUATE 0           ;sert a pointer vers 0 pour representer NULL
;-----------------------------------------------------
;
; Messages Strings
;
msgPoly1:.ASCII  "Polynôme 1\n\x00"
msgPoly2:.ASCII  "\nPolynôme 2\n\x00"
msgMenu: .ASCII  "***************************\n* 1 - Saisir un terme     *\n* "
         .ASCII  "2 - Terminer            *\n***************************\nVotre choix : \x00"
msgPVide:.ASCII  "Polynôme vide\n\x00"
msgPAddi:.ASCII  "\nAddition p1(x) + p2(x) : \n\x00"
msgPMult:.ASCII  "\nMultiplication du polynôme 1 par -10 :\n\x00"
msgCoeff:.ASCII  "\nCoefficient : \n\x00"
msgDegre:.ASCII  "Degre : \n\x00"
errChoix:.ASCII  "\nErreur: Option invalide\n\n\x00"
errDebor:.ASCII  "\nDebordement !\x00"
;-----------------------------------------------------
;
;******* Structure du polynome modelisee par une liste doublement chainee
;
coeffic: .EQUATE 0           ;le coefficient du terme
degre:   .EQUATE 2           ;le degre du terme
next:    .EQUATE 4           ;l'adresse du maillon du prochain terme
prev:    .EQUATE 6           ;l'adresse du maillon du terme precedant
;-----------------------------------------------------
;
;******* operator new
;        Precondition: A contains number of bytes
;        Postcondition: X contains pointer to bytes
new:     LDX     hpPtr,d     ;returned pointer
         ADDA    hpPtr,d     ;allocate from heap
         STA     hpPtr,d     ;update hpPtr
         RET0                
hpPtr:   .ADDRSS heap        ;address of next free byte
heap:    .BLOCK  1           ;first byte in the heap
         .END            