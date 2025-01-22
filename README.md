# Caça-Notícias

(Nome original - a formação de link do Github não aceita acentos e cedilhas :/)

Um simples script que roda em Linux para capturar notícias relacionadas a um termo [de busca].

Qualquer Terminal em Linux ou Mac podem rodar esse programa.

Para iniciá-lo:

`bash procura-noticias.sh`

### Os links de fontes de notícias

A lista de links (de sites) que o script percorre procurando um termo específico (definido pelo usuário) pode ser alterada, acrescentada ou decrescentada.

Se colocou em dois arquivos: O resumido com pouco mais de 100 links de jornais brasileiros e outro com mais de 5000 links de jornais nacionais e internacionais (que não foram revisados). 

Os links quebrados ou desativados não afetam à execução do programa. 

Arquivos: 

```
fontes_de_noticias.txt    # ~ 150 links
5000_links.txt            # > 5000 links

```

A saída (resultado) da execução do script será outro arquivo txt: `lista_links_google.txt` e outro com os links acumulados com data: `noticias_acumuladas.txt`. Os links gerados que estarão dentro destes arquivos de texto são link de busca do Google (nessa primeira versão do script), porém numa posterior versão aprimoraremos para links do próprio site. 

Disfrute.
