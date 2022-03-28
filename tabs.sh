#!/bin/bash
echo Yad Tabs
read
yad --plug 10000 --tabnum 1 --text "Dados Pessoais" --form --field Nome '' --field Idade:NUM '20\!0..110\!1\!0' --field "Nomes dos Genitores:LBL" --field Pai '' --field Mãe '' &> res1 &
yad --plug 10000 --tabnum 2 --text "Dados do Endereço" --form --field Pais:CB "$(tr '\n' '\!' < paises)" --field Cidade '' --field Bairro '' --field Logradouro '' &> res2 &
yad --notebook --key=10000 --tab="Pessoais" --tab="Endereço"


echo Yad tail
read
sudo tail -F /var/log/syslog | yad --text-info --tail --center --width=1000 --height=400