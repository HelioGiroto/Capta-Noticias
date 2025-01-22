#!/bin/bash
# PROCURA-NOTICIAS.SH
# Script em bash que faz busca em lista de jornais na internet em busca de termo(s) específico(s)
# Gerando uma lista de links 

# Autor: Hélio Giroto
# Data: 17/01/2025

# Ambiente que roda: Qualquer sistema *Unix (Linux, FreeBSD e Mac) 

# Requerimentos:
	# Este script depende apenas, além dos comandos requeridos instalados no Linux:
	# 	sudo apt install lynx sed grep uniq
	# ... e requer tb o arquivo texto com todos os links de sites de notícias chamado: fontes_de_noticias.txt


IFS='
'

# for URL in $(cat fontes); do echo $URL; lynx --dump --nolist $URL | grep -ic 'comex'; done
# for ARQ in $(cat fontes); do echo $URL; curl -s $URL | grep -ic 'comex'; done
# lynx --dump --nolist "https://www.estadao.com.br" | grep -ic 'Brasil'
# lynx -dump -nolist "https://www.estadao.com.br" | grep --color -C1 -i 'Brasil'
#  lynx -dump -nolist "www.brasildefato.com.br" | grep --color -C1 -i 'importaç.+\|exportaç.+\|comércio exterior\|comércio internacional'

# cria arquivo vazio para receber resultados das pesquisas: 
:> resultado_procura.dat

# todos os termos que serão pesquisados 
# separados por 'pipe' que significa OR ... (ou.. ou...) - 
# só pode ser usado com flag -E no grep (senão deve escapar os pipes)
# se pode usar expressões regulares (., +, etc): 
PROCURA="importaç.+|exportaç.+|comércio exterior|comércio internacional"

# percorre a lista de sites de notícias:
for URL in $(cat fontes_de_noticias.txt); 
do 
	# em cada item (site) da lista realiza o mesmo...:
	# imprime o nome do site que está realizando a busca
	echo $URL | tee -a resultado_procura.dat
	
	# pesquisa dentro de cada site os termos em 'PROCURA' 
	# direciona saída para tela e para arquivo .dat
	lynx --dump --nolist $URL| grep -E --color -C1 -i $PROCURA | tee -a resultado_procura.dat
	# lynx --dump --nolist $URL | grep -ic 'importaç.+' | tee -a resultado_procura.dat
	
	# ao final de cada item/site da lista, imprime um marcador de separação
	echo "---" | tee -a resultado_procura.dat
	
done

#########

# Após percorrer todos os sites da lista e gerar o arquivo de saída, 
# vai filtrar, gerando outro arquivo que...
# indique um link que contenha a notícia encontrada:
# AJUSTES NO TEXTO:
# une a linha com o marcador de separação (---) com a linha de cima. 
# nisso, forçará que os links que NÃO possuam resultado positivo na pesquisa do termo fiquem de fora
# porque tudo o que for link com --- ao final será descartado pelo filtro:
sed -z 's/\n---/---/g' resultado_procura.dat | grep -v 'http.*---' > resultados_filtrados.dat
# o arquivo a ser manipulado a partir daqui é o resultados_filtrados.dat

# https://unix.stackexchange.com/questions/26284/how-can-i-use-sed-to-replace-a-multi-line-string
# https://backreference.org/2009/12/23/how-to-match-newlines-in-sed/index.html


# mais ajustes (OBS.: não pode juntar os dois sed's senão não apaga todas as linhas em branco):
# desfaz o comando anterior...
# (agora coloca todos os marcadores de separação '---' novamente na linha de baixo)
sed -i 's/---/\n---/g' resultados_filtrados.dat
# apaga linhas em branco / vazias
sed -i '/^$/d' resultados_filtrados.dat
# remove os espaços do início das linhas:
sed -i 's/^ *//g' resultados_filtrados.dat
# NAO deleta tudo o que começar com -- e com letra (removendo linhas com fotos, nros, etc que o lynx deixa passar)
# sed com opções tipo OR (muito semelhante ao grep -E). Mas com o sed tem que escapar os pipes:
# I = ignore case (letras maiúsculas ou minúsculas)
sed -i '/^--\|^[a-z]/I!d' resultados_filtrados.dat
# grep -Ei '^[a-z]|---' resultados_filtrados.dat 

# obtem o nro de repetições que o laço vai percorrer:
# obtendo quantos sites foram encontrados: 
REPETIR=$(grep -c 'http' resultados_filtrados.dat)

# dentro do que foi filtrado para o arq .dat 
# se fará um "slice vertical", i. é, a cada trecho de texto que estiver entre --- e --- 
# será separado e colocado num outro arquivo .dat
for NRO in $(seq $REPETIR)
do
# tudo isso vai no laço até terminar o arquivo:
	# pega do inicio do arquivo até o prox/primeiro '---' :
	# sed -n '1,/---/p' resultados_filtrados.dat  > primeiro
	# sed '/---/Q' resultados_filtrados.dat		# = tb 

	# em seguida deleta este trecho pego acima:
	# sed -i '1,/---/d' resultados_filtrados.dat

	# do arquivo resultados_filtrados.dat pega o 1o. trecho da 1a linha até o próx ---:
	# saida para o arquivo "resultado_$NRO.dat":
	sed -n '1,/---/p' resultados_filtrados.dat > "resultado_$NRO.dat"	
	# em seguida deleta este trecho pego acima do arq dat filtrado (fonte):
	sed -i '1,/---/d' resultados_filtrados.dat

	# agora manipula este dat gerado (fatiado) da seguinte forma (aproveitando o mesmo laço/for):
	# obtem o nome do site deste trecho:
	SITE=$(grep 'http' "resultado_$NRO.dat")
	# deleta o marcador de separação (---)
	# a linha que contem 2 traços (--), gerada automaticamente pelo lynx, -
	# ... separa duas notícias como resultado de pesquisa encontrada no mesmo site
	# por isso, será substituida pelo url para, em seguida, -
	# ... as linhas serem juntadas/unidas para formar um novo link do google
	# agora junta (JOIN) as linhas para formar o link do google:
	# junta o link (url) do site de noticia com a frase encontrada na pesquisa pelo termo
	# ex: estadao.com.br + "exportação para a China em 2024"
	# no sed troquei o '/' por '|' para nao dar conflito já que o site tem barras no url: ...//www....
	cat "resultado_$NRO.dat" | sed '/---/d' | sed "s|--|$SITE|" | sed '/http/N;{s/\n/+"/}; s/ /+/g' | uniq >> lista_links_google.dat
	# cat primeiro.tmp | sed '/---/d' | sed "s|--|$SITE|" | sed '/http/N;{s/\n/+/}; s/ /+/g'

	# agora deve ir repetindo toda a operação acima até terminar as linhas de resultados_filtrados.dat...
	
done


# limpa linhas que nao tenham links:
sed -i '/http/!d' lista_links_google.dat

# manipula cada linka formando o link google completo:
# formato do link: # https://www.google.com/search?q=site:liberal.com.br+"Exportações+Rússia"
sed 's/http.*:..www.//g; s|^|https://www.google.com/search?q=site:|; s/.$/&"/' lista_links_google.dat > lista_links_google.txt

# o arquivo de resultado final com links a serem abertos é este: lista_links_google.txt

# apaga todos os arquivos .dat - agora desnecessários:
# COMENTAR linha abaixo se for fazer testes:	
rm *.dat

# junta todos os arquivos para o arquivo de notícias acumuladas:
echo "===" >> noticias_acumuladas.txt
echo $(date) >> noticias_acumuladas.txt
cat lista_links_google.txt >> noticias_acumuladas.txt

# abre o arquivo com os resultados conclusivos:
# gedit lista_links_google.txt
vim lista_links_google.txt  # opção para abrir (ou nano, etc...)

# ver https://www.grymoire.com/Unix/Sed.html#uh-29

# FIM
