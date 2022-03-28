#! /usr/bin/env bash
yad --list \
  --title="Manipulador e Conversor 1.0.0" \
  --text='Escolha uma opção, ou clique no "x" ao lado de "Manipulador" para cancelar.' \
  --column= "Converter em PDF" \
  --dclick-action="/home/$USER/.Conversor/Converter_em_PDF.sh %s" "Redimensionar Imagens" \
  --dclick-action="/home/$USER/.Conversor/RedimensionarImagens.sh %s" "Manipular PDFs" \
  --dclick-action="/home/$USER/.Conversor/ManipularPDF.sh %s" "Outras Opções" \
  --dclick-action="/home/$USER/.Conversor/OutrasOpcoes.sh %s"
