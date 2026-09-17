
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

**RF01 — Visualização no mapa:** O sistema deve exibir parques, praças e outras áreas verdes em um mapa, indicando a localização de cada espaço.

**RF02 — Distância dos locais:** O sistema deve informar a distância entre a localização do usuário e as áreas verdes, mediante autorização de acesso à localização.

**RF03 — Acesso à rota:** O sistema deve permitir que o usuário acesse a rota até a área verde selecionada.

**RF04 — Filtro por atividades:** O sistema deve permitir a filtragem dos locais por atividades disponíveis, como caminhada, corrida, descanso e recreação infantil.

**RF05 — Filtro por estrutura:** O sistema deve permitir a filtragem dos locais por recursos disponíveis, como bancos, banheiros, bebedouros e equipamentos esportivos.

**RF06 — Detalhes do local:** O sistema deve apresentar uma página para cada área verde com fotos, endereço, horários de funcionamento, atividades e estrutura disponível.

**RF07 — Informações de acessibilidade:** O sistema deve apresentar informações sobre rampas, caminhos acessíveis e banheiros adaptados, diferenciando a ausência de um recurso da falta de informação sobre ele.

**RF08 — Origem e atualização dos dados:** O sistema deve exibir a origem e a data da última atualização das informações de cada local.

**RF09 — Avaliações dos usuários:** O sistema deve permitir que os usuários publiquem e consultem avaliações, fotos e relatos sobre limpeza, conservação, acessibilidade e condições observadas nos locais.

**RF10 — Sinalização de informações desatualizadas:** O sistema deve permitir que os usuários sinalizem informações incorretas ou desatualizadas sobre uma área verde.

**RF11 — Download para consulta offline:** O sistema deve permitir que o usuário salve informações essenciais de um local e um mapa da região para consulta sem conexão com a internet.

**RF12 — Acesso aos dados offline:** O sistema deve permitir a consulta dos conteúdos baixados sem conexão com a internet, exibindo a data da última atualização.


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
Mapeamento do CRUD para o aplicativo Verde Urbana, focado em conectar moradores urbanos a áreas verdes (parques, praças e hortas comunitárias):

**1. Perfil do Usuário**

C (Criar): Cadastro inicial do usuário (nome, e-mail, senha, preferências de atividades ao ar livre).  

R (Consultar): Exibição das informações do perfil e estatísticas de uso/locais visitados.

U (Atualizar): Edição de dados pessoais, foto de perfil, alteração de senha e atualização de preferências.

D (Excluir): Exclusão definitiva da conta e anonimização dos dados armazenados (garantindo conformidade com a LGPD).

**2. Áreas Verdes (Parques, Praças e Hortas)**

C (Criar): Cadastro de novos espaços verdes (realizado por administradores ou sugerido por moradores no caso de hortas comunitárias/praças não mapeadas).

R (Consultar): Busca e visualização das áreas verdes no mapa ou lista, contendo detalhes de infraestrutura, horários de funcionamento, níveis de segurança, acessibilidade e rota.

U (Atualizar): Edição de informações do local (ex.: mudança no horário de funcionamento, alteração na infraestrutura disponível ou inclusão de novos pontos de interesse).

D (Excluir): Remoção do registro de um local caso ele seja desativado permanentemente, fechado ao público ou cadastrado em duplicidade.

**3. Avaliações e Relatos de Infraestrutura / Segurança**

C (Criar): Envio de comentários, notas de avaliação (estrelas), alertas de segurança em tempo real e relatos sobre as condições do local.

R (Consultar): Leitura das avaliações e alertas deixados por outros usuários na página de detalhes de cada área verde.

U (Atualizar): Edição do texto de um comentário ou alteração da nota previamente enviada pelo autor.

D (Excluir): Exclusão do comentário pelo próprio autor ou remoção por moderadores caso o conteúdo viole as diretrizes da comunidade.

**4. Fotos do Local**

C (Criar): Upload de fotos tiradas pelos usuários nos locais (ex.: status da horta, preservação da praça).

R (Consultar): Exibição da galeria de fotos na ficha do parque ou praça.

U (Atualizar): Alteração da legenda da foto ou substituição da imagem por parte do usuário que realizou o envio.

D (Excluir): Remoção da foto pelo usuário ou pela moderação (em casos de imagens impróprias ou desatualizadas).

**5. Eventos e Mutirões (Hortas Comunitárias e Atividades ao Ar Livre)**

C (Criar): Agendamento de eventos, como aulas de ioga, grupos de corrida, mutirões de plantio ou feiras orgânicas.

R (Consultar): Visualização da agenda de eventos vinculados às áreas verdes.

U (Atualizar): Alteração de data, horário ou descrição do evento pelo organizador.

D (Excluir): Cancelamento e exclusão do evento da agenda comunitária.

**6. Favoritos e Locais Salvos**

C (Criar): Adição de uma área verde à lista pessoal de "Favoritos" ou "Quero Visitar".

R (Consultar): Listagem e consulta rápida dos locais salvos pelo usuário.

U (Atualizar): Não aplicável. A relação de favorito é binária (o local está na lista ou não está). Não há campos de dados editáveis nessa funcionalidade.

D (Excluir): Remoção de um parque ou praça da lista de favoritos (desmarcar o item).


## 2.5 Priorização

**2.5 Priorização**

As funcionalidades do VerdeUrbano foram classificadas considerando o problema identificado na pesquisa e as necessidades da persona prioritária, Marina Alves.

**Essenciais**

- **Mapa com localização, distância e acesso à rota:** permite encontrar áreas verdes próximas e chegar ao local escolhido, atendendo à proposta central do aplicativo.
- **Página do local com informações detalhadas e acessibilidade:** permite verificar horários, estrutura e condições de acessibilidade antes da visita, ajudando o usuário a escolher um espaço adequado às suas necessidades.

**Importantes**

- **Filtros por atividades e estrutura:** agilizam a busca por locais adequados às preferências do usuário. Sem os filtros, ainda é possível encontrar espaços pelo mapa e consultar suas características.
- **Avaliações e atualizações da comunidade:** complementam as informações dos locais com experiências recentes e permitem sinalizar dados desatualizados.

**Secundárias**

- **Consulta offline de locais salvos:** facilita o acesso às informações em áreas com conexão limitada, mas pode ser desenvolvida após as funcionalidades centrais de descoberta e planejamento de visitas.
