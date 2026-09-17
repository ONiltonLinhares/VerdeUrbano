
## 2.1 Funcionalidades

Para o **VerdeUrbano**, as principais funcionalidades são:

1. **Mapa com localização e acesso à rota**

   **Descrição:** Exibir as áreas verdes no mapa, indicar a distância em relação ao usuário e oferecer acesso à rota até o local escolhido.

   **Necessidade do usuário que atende:** Identificar espaços próximos e encontrar o caminho para visitá-los com poucos passos.

   **Justificativa:** A pesquisa aponta a dificuldade de localizar áreas verdes como parte central do problema. Essa funcionalidade também atende ao uso espontâneo de Marina, permitindo planejar uma visita durante uma pausa no trabalho.

2. **Filtros por atividades e estrutura**

   **Descrição:** Permitir a filtragem dos locais por atividades, como caminhada, corrida, descanso e recreação infantil, e por recursos, como bancos, banheiros, bebedouros e equipamentos esportivos.

   **Necessidade do usuário que atende:** Encontrar espaços adequados ao objetivo da visita e às necessidades de cada pessoa.

   **Justificativa:** Marina procura opções para relaxar e sair da rotina, enquanto famílias, idosos e outros públicos podem precisar de estruturas específicas. Os filtros tornam a busca mais rápida e relevante.

3. **Página do local com informações detalhadas e acessibilidade**

   **Descrição:** Reunir fotos, horários de funcionamento, atividades, estrutura disponível e condições de acessibilidade, incluindo rampas, caminhos acessíveis e banheiros adaptados. Indicar a origem e a data de atualização das informações, diferenciando recursos confirmados daqueles ainda não informados.

   **Necessidade do usuário que atende:** Conhecer as condições do espaço antes da visita e avaliar se ele atende às suas necessidades.

   **Justificativa:** Marina já visitou locais que não correspondiam às suas expectativas. A pesquisa também destaca que idosos e pessoas com deficiência ou mobilidade reduzida precisam de informações antecipadas sobre a estrutura. Essa funcionalidade apoia uma decisão mais informada e reduz visitas frustradas.

4. **Avaliações e atualizações da comunidade**

   **Descrição:** Permitir que os usuários publiquem avaliações, fotos e relatos sobre limpeza, conservação, acessibilidade e condições observadas, além de sinalizar informações desatualizadas.

   **Necessidade do usuário que atende:** Consultar experiências recentes de outras pessoas e contribuir com a atualização dos dados dos locais.

   **Justificativa:** A pesquisa identifica a dificuldade de obter informações confiáveis sobre áreas verdes. As contribuições da comunidade complementam os dados disponíveis e ajudam Marina a comparar opções. Os relatos devem ser apresentados como experiências dos usuários, sem representar garantia de segurança ou acessibilidade.

5. **Consulta offline de locais salvos**

   **Descrição:** Permitir o download das informações essenciais e de um mapa da região de um local para consulta sem internet, exibindo a data da última atualização.

   **Necessidade do usuário que atende:** Manter acesso aos dados de uma visita planejada em áreas com conexão limitada.

   **Justificativa:** A pesquisa aponta que alguns espaços podem apresentar sinal de internet insuficiente. A consulta offline permite recuperar informações como endereço, horários e estrutura durante o passeio. Pode ser implementada em uma etapa posterior, priorizando inicialmente a descoberta, a escolha e o acesso aos locais.

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
