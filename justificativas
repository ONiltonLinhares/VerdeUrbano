# Justificativas: VerdeUrbano

Principais decisões de interface e arquitetura do protótipo de alta fidelidade, ligadas ao estudo de caso, às personas e aos requisitos do projeto.

## 1. Cores

- **Verde floresta (#1E5A43) como cor principal**, porque o estudo de caso pede que o verde tenha destaque na identidade.
- **Tons de terra (#9A4F26) e areia (#F3EDE2) como complemento**, trazendo a sensação de natureza e calma.
- **Modo claro como padrão**, porque o app é usado na rua e sob luz do sol (RNF02).
- **Contraste alto em todos os textos**, acima do mínimo recomendado pela WCAG (4,5:1), para leitura fácil mesmo com reflexo na tela.
- **A cor nunca aparece sozinha**: ícones e textos acompanham os estados, para que pessoas com daltonismo também entendam.
- **Sem cores agressivas ou excesso de elementos**, para manter a personalidade natural, calma e acolhedora.

## 2. Tipografia

- **Fraunces nos títulos**: fonte com serifa suave que deixa o app acolhedor e menos técnico.
- **Nunito Sans no texto**: fonte simples, arredondada e fácil de ler em telas pequenas e em movimento.
- **Hierarquia clara**: títulos grandes (28 a 30 px), subtítulos médios (20 px) e texto de leitura com no mínimo 15 px.
- **Ações importantes em negrito**, como o botão "Rota", para serem encontradas rapidamente.

## 3. Organização das informações

- **Fotos em primeiro lugar**, porque a persona Marina decide pelo visual antes de ler descrições.
- **A página do local segue a ordem de uma decisão**: o que é e onde fica, o botão de Rota, as atividades, a estrutura, a acessibilidade e, por fim, as avaliações.
- **Acessibilidade em um bloco destacado**, porque é uma informação decisiva para idosos e famílias.
- **Separação entre "tem", "não tem" e "não informado"**, para o usuário saber quando um recurso não existe e quando ninguém informou ainda (RF07).
- **Fonte e data de atualização visíveis**, junto com a opção de sinalizar informação errada (RF08 e RF10).

## 4. Navegação

- **Rota em até 3 toques**: abrir o app, tocar no parque e tocar em "Rota" (RNF01).
- **Barra inferior com 4 abas**: Início, Mapa, Salvos e Diário.
- **As abas acompanham os momentos de uso**: antes da visita (Início e Mapa), durante (Rota e Offline) e depois (Diário).
- **Busca e filtros rápidos já na tela inicial**, sem precisar abrir outra tela (RF04, RF05 e RF13).
- **Botão de voltar sempre no mesmo lugar**, no canto superior esquerdo.

## 5. Componentes

- **Cards de local** com foto, distância, nota, horário e selo "Acessível".
- **Botão principal verde** para a ação mais importante (Rota) e **botões com contorno** para ações secundárias.
- **Etiquetas selecionáveis** para atividades e filtros.
- **Pinos no mapa** que mostram um cartão com o local escolhido.
- **Escala de humor com rostos** no diário de bem-estar.
- **Avisos rápidos** de confirmação, como "Salvo offline" e "Registro salvo".
- **Telas de lista vazia**, como "Nenhum favorito ainda", para orientar o usuário sobre o que fazer.

## 6. Acessibilidade

- **Botões com no mínimo 44 × 44 px**, facilitando o toque para idosos e para quem está em movimento.
- **Ícones sempre com texto** nas ações principais.
- **Compatível com leitores de tela**: botões só com ícone têm descrição para quem usa TalkBack ou VoiceOver.
- **Informações de acessibilidade padronizadas** em todos os locais: rampas, caminhos acessíveis, banheiro adaptado e iluminação (RNF08).
- **Contraste e tamanho de texto** pensados para pessoas com baixa visão.

## 7. Contexto de uso

- **Uso ao ar livre e sob o sol**: modo claro e contraste alto.
- **Atenção reduzida, caminhando ou correndo**: poucos passos, botões grandes e textos curtos.
- **Internet instável nos parques**: opção de baixar o local e o mapa para usar offline (RF11, RF12 e RNF05).
- **Pouco espaço no celular**: indicação do espaço usado e remoção automática de mapas antigos (RNF06).
- **Privacidade**: o mapa funciona sem login (RNF03) e o diário de bem-estar fica salvo só no aparelho (RNF04).
- **Famílias com crianças**: filtro de playground e atividades voltadas para crianças.

## 8. Arquitetura do sistema

Proposta para o grupo validar. As tecnologias são sugestões e podem ser trocadas.

- **App para celular (Android e iOS)**: feito com uma tecnologia multiplataforma, como Flutter ou React Native, para ter um só código para os dois sistemas (RNF07).
- **Armazenamento no próprio celular**: guarda o diário de bem-estar, os favoritos e os mapas baixados para uso offline.
- **Recursos do celular**: GPS para calcular a distância (com autorização do usuário), compartilhamento nativo e abertura do app de mapas para a navegação.
- **Servidor (API)**: envia os dados dos locais, aplica os filtros e recebe avaliações, fotos e sinalizações.
- **Banco de dados com localização**: permite buscar os locais mais próximos do usuário e guarda a fonte e a data de cada informação.
- **Armazenamento de fotos**: guarda as imagens enviadas pela comunidade.
- **Moderação**: revisa sinalizações e relatos antes de alterar a página de um local.
- **Login só para publicar** avaliações e fotos. Consultar o mapa e os locais não exige conta.

## 9. Coerência com o projeto

- **Estudo de caso**: 4 telas principais, rota em 3 toques, modo claro, uso offline e diário salvo só no celular.
- **Pesquisa**: acessibilidade, estrutura, atividades, iluminação e avaliações aparecem em todos os locais.
- **Benchmark**: a busca e a rota simples vêm do Google Maps, os filtros e as fotos vêm do AllTrails, e o tom de exploração vem do Seek.
- **Personas**: Marina tem fotos, decisão rápida, favoritos e compartilhamento; o Sr. Antônio tem informações de acessibilidade claras e botões grandes.
- **Requisitos**: todos os requisitos funcionais (RF01 a RF17) e não funcionais (RNF01 a RNF08) aparecem nas telas.
- **Identidade**: verde em destaque, tons de terra, ilustrações de natureza e o slogan "O guia que transforma a selva de pedra em um quintal verde".
