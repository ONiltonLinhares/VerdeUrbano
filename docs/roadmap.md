# Roadmap — VerdeUrbano até a entrega final

Atualizado em **19/11/2026**. Complementa o [`planejamento.md`](planejamento.md) (escopo, EAP,
sprints) com **o que falta, em que ordem e como saber que está pronto**.
Regras de código e de Git: [`../CLAUDE.md`](../CLAUDE.md).

| Marco | Data |
|---|---|
| App rodando com Firebase do grupo | **21/11** |
| Tudo funcional no emulador | **26/11** |
| Congelamento: só correção de bug | **02/12** |
| Apresentação 1 | **03/12** |
| Apresentação final + arguição | **10/12** |

---

## Onde estamos

| Parte | Situação |
|---|---|
| Modelos, `firestore.rules`, testes das regras, SQLite, modelagem de dados | ✅ na `main` (PR #1) |
| Telas do protótipo, login real, 6 CRUDs, offline, admin | ✅ na branch `feat/telas-unidade2`; `flutter analyze` sem erros e testes passando |
| Casos de uso, fluxo de navegação, planejamento, uso de IA | ✅ na mesma branch |
| Projeto Firebase do grupo configurado | 🟡 `verdeurbano-9a251` criado e ligado ao app; falta popular o banco (ver abaixo) |
| Regras do **aditivo** do estudo de caso | ⬜ grupo ainda não recebeu / não enviou |
| Responsabilidades no README, CHANGELOG da Unidade II | ⬜ |

---

## Fase 0 — Integrar e rodar (19/11 → 21/11) · prioridade máxima

Sem isso nada mais anda: **app que não compila é desconsiderado na correção**.

| ID | Tarefa | Pronto quando |
|---|---|---|
| R0.1 | Criar a branch `feat/telas-unidade2` a partir da `main` e copiar o conteúdo do pacote | Branch no GitHub |
| R0.2 | `flutter pub get` e `flutter analyze` | Zero **erros** (avisos podem ficar para a Fase 2) |
| R0.3 | Corrigir erros de compilação (mandar a saída do terminal para a IA, um erro por vez) | `flutter run` abre o app no emulador |
| R0.4 | Criar o projeto no Firebase Console, ativar **E-mail/senha** e o **Firestore** | Console pronto |
| R0.5 | `flutterfire configure` + `firebase deploy --only firestore` | Regras e índices publicados |
| R0.6 | Criar conta pelo app, mudar `papel` para `admin` no console, **Adicionar locais de exemplo** | 5 locais aparecendo no Início e no Mapa |
| R0.7 | Abrir o PR, revisar em dupla e fazer o merge na `main` | `main` com app rodando |

### Pendências do banco (deixadas para outro dia)

Já feito no console (19/11): projeto `verdeurbano-9a251`, login por e-mail/senha, Firestore
em `southamerica-east1`, `firestore.rules` publicadas, apps Web e Android registrados,
isenções de índice de grupo de coleções (`avaliacoes.autorId`, `fotos.autorId`,
`eventos.organizadorId`) e `app/lib/firebase_options.dart` real.

| ID | Tarefa | Pronto quando |
|---|---|---|
| B1 | Criar a pasta `web/` (`flutter create --platforms=web .`) para rodar no Chrome | `flutter run -d chrome` abre o login |
| B2 | Criar a primeira conta pelo app e trocar `papel` para `admin` em `usuarios/{uid}` no console | Aba Admin aparece no Perfil |
| B3 | Admin → **Adicionar locais de exemplo** | 5 locais no Início e no Mapa |
| B4 | Testar os CRUDs com o banco real (avaliação, foto, evento, sinalização, favoritos, exclusão de conta) | Sem erro de permissão/índice |
| B5 | (Android) Instalar o Android SDK e, se a chave Web der erro, rodar `flutterfire configure` | App abre no celular/emulador |

> **Commits:** dividam a integração. Ex.: um integrante sobe `data/` e `estado/`, outro as telas,
> outro os docs. Cada um pela própria conta (critério c.i).

---

## Fase 1 — Funcionalidades completas (22/11 → 26/11)

Cada frente testa **no emulador** o roteiro abaixo, corrige o que quebrar e marca ✅.
Responsáveis: preencher conforme a tabela de frentes do `planejamento.md`.

### Autenticação e perfil (CRUD 1 · a.ii, e.i)
- [ ] R1.1 Cadastro cria o documento `usuarios/{uid}` com `papel = usuario`
- [ ] R1.2 Login com senha errada mostra mensagem em português; sem internet também
- [ ] R1.3 Recuperar senha envia o e-mail
- [ ] R1.4 Editar nome e preferências; excluir conta anonimiza avaliações (conferir no console)
- [ ] R1.5 "Explorar sem conta" deixa usar mapa, local, rota e diário

### Descoberta (RF01–RF05, RF13 · e.ii, e.iii)
- [ ] R1.6 Início mostra distância, nota, horário e selo Acessível; ordena pelo mais perto
- [ ] R1.7 Busca ignora acentos ("praca" acha "Praça")
- [ ] R1.8 Filtros combinados (atividade + estrutura + acessibilidade + distância) e contador "Mostrar N locais"
- [ ] R1.9 Mapa: pinos, card do local, botão Minha localização
- [ ] R1.10 **3 toques:** abrir → card → Rota → app de mapas abre com o trajeto (RNF01)

### Página do local e comunidade (CRUDs 3, 4, 5, 6 · a.iv)
- [ ] R1.11 Avaliar, editar e excluir: a média e o total do local mudam na hora
- [ ] R1.12 Avaliar 2 vezes o mesmo local edita a anterior (não duplica)
- [ ] R1.13 Enviar foto pela câmera e pela galeria; foto grande é recusada com mensagem
- [ ] R1.14 Criar, editar, cancelar e excluir evento; evento no passado é recusado
- [ ] R1.15 Favoritar e desfavoritar; aparece em Salvos → Favoritos
- [ ] R1.16 Sinalizar informação; admin vê e marca como resolvida
- [ ] R1.17 Sugerir local (usuário comum) → aparece como pendente → admin publica

### Offline e falhas de conexão (RF11, RF12, RNF04–RNF06 · a.iv)
- [ ] R1.18 Baixar offline → modo avião → abrir o local pelo Salvos → aviso "cópia offline"
- [ ] R1.19 Modo avião: faixa "Sem internet", nenhuma tela trava girando para sempre
- [ ] R1.20 Diário: criar, editar, excluir; continua lá depois de fechar o app; nada no Firestore

### Aditivo do estudo de caso (a.iv · b.i)
- [ ] R1.21 Receber o aditivo e listar cada regra nova
- [ ] R1.22 Implementar cada regra **no app e no `firestore.rules`**, com teste
- [ ] R1.23 Acrescentar as regras em `docs/diagrama-casos-de-uso.md` (tabela RN)

### Fidelidade ao protótipo (a.iii · e)
- [ ] R1.24 Comparar tela a tela com `prototipoAltaFidelidade.pdf` (textos, ordem dos blocos, cores, fontes) e corrigir diferenças
- [ ] R1.25 Tirar prints de cada tela para a apresentação

---

## Fase 2 — Qualidade e documentação (27/11 → 02/12)

| ID | Tarefa | Critério |
|---|---|---|
| R2.1 | `flutter analyze` sem erros **e** sem avisos | a |
| R2.2 | `flutter test` verde (já existem testes de modelos, formatos, filtros, Login e acessibilidade) | a |
| R2.3 | `npm test` das regras verde; acrescentar casos do aditivo | a.iv |
| R2.4 | Teste de acessibilidade: fonte grande do Android (200%) e TalkBack nas telas principais | RNF |
| R2.5 | Exportar os diagramas Mermaid como imagem para os slides | b |
| R2.6 | Conferir os 6 artefatos do item b (tabela abaixo) | b |
| R2.7 | `docs/uso-de-ia.md` com os prompts e erros reais de **cada** integrante | b.vi |
| R2.8 | README: responsabilidades reais + links para PRs; CHANGELOG da Unidade II | c.ii |
| R2.9 | Gerar o APK de release (`flutter build apk`) e testar num celular de verdade | a |
| R2.10 | Slides + roteiro da demonstração (quem fala o quê, ~1 min por integrante) | Apresentação |

**02/12: congelamento.** Depois disso, só correção de bug, em PR.

---

## Fase 3 — Pós-apresentação 1 (04/12 → 09/12)

- R3.1 Corrigir o que a banca apontar em 03/12 (abrir uma issue para cada ponto)
- R3.2 Ensaiar a **arguição**: cada um explica o código que commitou (o professor pode perguntar
  sobre código gerado por IA)
- R3.3 Conferir o link do repositório no Teams antes do prazo (link fora do prazo = nota zero)

**Melhorias opcionais** (só se tudo acima estiver ✅): mapa em modo escuro, notificação de evento,
histórico de visitas a partir do diário, filtro "aberto agora".

---

## Checklist da avaliação

| Item | Peso | Onde está | ✅ |
|---|---|---|---|
| a.i Flutter + Dart | 3,0 | `app/` | |
| a.ii Firebase Auth + Firestore | | `estado/sessao.dart`, `data/` | |
| a.iii Telas fiéis ao protótipo | | `telas/` + R1.24 | |
| a.iv CRUDs, regras do aditivo, acesso, validações, falhas de conexão | | `data/`, `firestore.rules`, `core/erros.dart` | |
| b.i Casos de uso | 2,0 | `docs/diagrama-casos-de-uso.md` | |
| b.ii Diagrama de classes | | `docs/modelagem-dados.md` | |
| b.iii–iv Firestore + mapeamento Dart | | `docs/modelagem-dados.md` | |
| b.v Fluxo de navegação | | `docs/fluxo-navegacao.md` | |
| b.vi Uso de IA | | `docs/uso-de-ia.md` | |
| c.i Commits individuais | 1,0 | histórico do GitHub | |
| c.ii README e CHANGELOG atualizados | | raiz | |
| c.iii Checkpoints semanais | | presença nas aulas | |
| d.i–iii Escopo, EAP, sprints | 1,0 | `docs/planejamento.md` + este roadmap | |
| e.i–iv Login, Início, telas principais, navegação | 1,0 | `telas/` | |
| Apresentação e arguição | 2,0 | 03/12 e 10/12 | |

## Riscos

| Risco | Chance | O que fazer |
|---|---|---|
| Código não compila no Flutter 3.47 | Média | Fase 0 primeiro; mandar a saída do `flutter analyze` para a IA, um erro por vez |
| Aditivo chega tarde | Média | Pedir ao professor agora; deixar espaço nas regras e no doc |
| Commits concentrados numa pessoa | Alta | Dividir R0.x e Fase 1 por frente; cada um commita o seu |
| PC sem espaço para o emulador | Média | Celular pelo cabo USB ou Firebase Studio |
| Índice do Firestore faltando (exclusão de conta) | Baixa | `firebase deploy --only firestore` publica `firestore.indexes.json` |

## Definição de pronto

Uma tarefa só está pronta quando: roda no emulador; `flutter analyze` e `flutter test` sem erros;
regra nova também está no `firestore.rules`; PR revisado por outro integrante; CHANGELOG
atualizado; e, se usou IA, registro em `docs/uso-de-ia.md`.
