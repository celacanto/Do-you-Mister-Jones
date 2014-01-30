Do-you-Mister-Jones, um gerador de comentários do UOL
========================================================

Introdução
--------------------------------------------------------

Aqui se encontram códigos para gerar novos comentários do UOL. Eles tem como base 38824 comentários feitos no site. 

Os comentários gerados podem não fazer muito sentido, uma vez que a presença de uma palavra é determinada somente pelas duas anteriores. Isto tenderá a produzir um desconexo encadeamento lógico, o que deve aproxima-los dos originais.

Alguns comentários gerados
---------------------------------------------------------

> viva o amor, o respeito, cumpre sua pena numa prisão. .


> a sociedade que paga para manipular interesses próprios


> vergonha!!!!!!!! bandidos defendendo bandidos e criminosos na cadeia.


> tenho vergonha destas manobras... se fosse assim não tem vergonha

Sobre os códigos
--------------------------------------------------------

O código para obter os comentários é bem direto:

* A partir da página da matéria se obtém o ID da página dos comentários.
* Com o ID é possível acessar a página aonde os comentários são armazenados no formato json. 
* Coloca os dados do comentário em uma matrix.

Os códigos que geram um novo comentário tiveram como ponto de partida [a lógica descrita aqui](http://agiliq.com/blog/2009/06/generating-pseudo-random-text-with-markov-chains-u/).

Fiz algumas alterações, como: 
* Possibilidade de escolher o número de palavras de cada estado da cadeia de markov.
* Possibilidade de colocar todas as palavras em caixa baixa, o que aumenta a ocorrência de alguns estados.
* Remoção de trechos entre os parênteses (já que isso podia acarretar no comentário gerado abrir um parêntese e não fecha-lo, algo que como um membro do [r/oddlysatisfying](http://www.reddit.com/r/oddlysatisfying) nunca poderia permitir).
* Os comentários para terminarem devem ter um ponto final ou ser o fim de um comentário original (algumas pessoas não colocam ponto no fim, hor-ror).
* Correção para quando as pessoas esquecem de dar espaço depois do ponto (caos)
* Necessidade de começar o texto pelo início de um comentário.
 
Tabelas dos comentários
---------------------------------------------------------
 
Como a parte mais demorada disso é obter as tabelas de comentários, deixo [aqui uma pasta](https://github.com/celacanto/Do-you-Mister-Jones/tree/master/commentTables) com os comentários das matérias mais acessadas em diferentes semanas.

Exemplo de como usar o código
--------------------------------------------------------

Esse exemplo irá gerar um comentário aleatório a partir de todos os 38824 comentários presentes na tabela. A leitura e o cálculo das variáveis da cadeia de markov pode demorar um tempo, mas depois disso se pode gerar várias frases rapidamente (relativamente, isso é *R* e tal).

    source("makeMarkovInputs.R")
    source("createCommentUol.R")

    # arquivos das  tabelas com os comentários de cada semana
    tablesFiles <- list.files("../commentTables/", pattern = "\\.csv", full.names = TRUE)
    allWeeksTables <- lapply(tablesFiles, read.csv, stringsAsFactors = FALSE)
    # Junta as tabelas
    allcomments <- do.call(rbind, allWeeksTables) 

    # Isso deve demorar...
    # Se está calculando as probabilidades de transições (e de início) da cadeia de markov
    markovsProp <- markovCommentInput(allcomments, nWordsByState = 2, 
                                      removeNewLine = FALSE, 
                                      lowerCases = FALSE, 
                                      removeOpenCloseEstructures = TRUE)

    generateComment(markovsProp, sizeParameter = 5)









