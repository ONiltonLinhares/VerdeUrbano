# Funcionalidades e Requisitos

## 2.1 Funcionalidades

## 2.2 Requisitos funcionais

## 2.3 Requisitos não funcionais

**RNF01 – Usabilidade:** O sistema deve permitir que o usuário acesse a rota até uma
área verde em, no máximo, três interações (abrir app → tocar no parque → tocar
em "Rota").

Justificativa: o estudo de caso define essa limitação como requisito central, já
que o app é usado majoritariamente em movimento e com atenção reduzida.

**RNF02 – Usabilidade / Acessibilidade visual:** A interface deve manter contraste
adequado e boa legibilidade sob luz solar direta, priorizando o modo claro como
padrão.

Justificativa: o app é usado predominantemente em ambientes externos e sob alta
luminosidade, o que pode comprometer a leitura de informações críticas (rota,
acessibilidade, horários).

**RNF03 – Segurança e privacidade (LGPD):** O sistema deve permitir a consulta do
mapa de áreas verdes sem exigir cadastro ou login do usuário.

Justificativa: reduz a coleta de dados pessoais desnecessários, alinhando-se ao
princípio de minimização de dados da LGPD.

**RNF04 – Segurança e privacidade (LGPD):** As informações do diário de bem-estar
devem ser armazenadas exclusivamente de forma local no dispositivo, sem envio a
servidores externos.

Justificativa: dados de bem-estar e geolocalização são classificados como
sensíveis pelo próprio estudo de caso; manter esses dados apenas localmente
evita exposição desnecessária e reforça a confiança do usuário.

**RNF05 – Conectividade:** O sistema deve permitir o download do mapa das áreas
verdes para uso offline.

Justificativa: a conectividade pode ser instável ou inexistente durante
caminhadas e visitas a parques, e a funcionalidade principal não pode
depender de conexão constante.

**RNF06 – Armazenamento de dados:** O sistema deve gerenciar de forma eficiente o
espaço ocupado pelos mapas baixados para uso offline, evitando consumo
desnecessário de armazenamento.

Justificativa: o estudo de caso aponta que, embora não haja limite de tamanho
definido, o app deve considerar o impacto do armazenamento local (mapas
offline + diário de bem-estar).

**RNF07 – Compatibilidade / Dispositivos:** O sistema deve ser compatível com
smartphones, sendo a versão mínima de sistema operacional definida
posteriormente pelo grupo.

Justificativa: o projeto é voltado a dispositivos móveis, já que o uso ocorre
majoritariamente durante deslocamentos e atividades externas; o estudo de caso
não especifica versão mínima, o que precisa ser decidido pela equipe.

**RNF08 – Acessibilidade (conteúdo):** O sistema deve apresentar informações de
acessibilidade dos locais (rampas, banheiros adaptados, iluminação) de forma
clara e padronizada em todas as fichas de local.

Justificativa: atende diretamente às necessidades das personas de idosos e
famílias com crianças, para quem essa informação é determinante na decisão de
visitar ou não um espaço.

## 2.4 CRUD

## 2.5 Priorização
