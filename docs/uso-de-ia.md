# Registro de Uso de IA — VerdeUrbano

Atende ao item **b) vi** e à observação 7 da avaliação: a IA Generativa foi usada **como
ferramenta de apoio**. Todo código gerado foi revisado e precisa ser explicado pelo grupo na arguição.

> **Como manter:** a cada uso relevante de IA, acrescente uma linha nas tabelas abaixo
> (quem usou, o que pediu, o que deu errado e como foi resolvido).

## 1. Ferramentas

| Ferramenta | Para quê | Quem usou |
|---|---|---|
| Claude (Anthropic) | Telas do protótipo, autenticação, repositórios Firebase/SQLite, CRUDs e documentos de `/docs` (casos de uso, fluxo, planejamento) sobre os modelos e regras já feitos pelo grupo | João Lucas Resende |
| _(adicionar)_ | | |

## 2. Prompts mais eficientes

| # | Objetivo | Prompt (resumo) | Por que funcionou |
|---|---|---|---|
| 1 | Dar contexto completo | Enunciado da avaliação (prints) + repositório com estudo de caso, requisitos, personas e protótipos | A IA seguiu RF/RNF e as telas do protótipo em vez de inventar um app genérico. |
| 2 | Não conflitar com o trabalho do grupo | "Faça por cima do projeto que já existe, para não dar conflito no merge" + zip do repositório | O código novo usou os modelos, o `banco_local.dart`, o tema e as regras do Firestore existentes, criando arquivos novos em vez de reescrever os antigos. |
| 3 | Respeitar as regras do banco | Pedir que a gravação de avaliações siga o `firestore.rules` (resumo coerente na mesma transação) | Levou ao uso de `runTransaction` com `ResumoAvaliacoes.adicionar/substituir/remover`. |
| _(adicionar)_ | | | |

**Boas práticas:** mandar enunciado e documentos junto; pedir uma funcionalidade por vez;
pedir que a IA explique o código; rodar `flutter analyze`, `flutter test` e testar no emulador
antes de commitar.

## 3. Erros gerados pela IA e como foram resolvidos

| # | Erro | Como percebemos | Solução |
|---|---|---|---|
| 1 | Na primeira versão, o projeto foi gerado com estrutura própria, diferente da que o grupo já tinha em `app/`. Juntar os dois daria conflito no merge. | Comparação com o repositório | Refeito em cima da estrutura do grupo (`models/`, `data/`, `telas/`, `core/tema.dart`, imports de `material_ui`). |
| 2 | `StreamBuilder` recebendo a consulta do Firestore direto no `build`, recriando a consulta a cada redesenho (tela piscando e leituras extras). | Revisão do código | O stream é criado uma vez no `State` (`late final _stream`). |
| 3 | Edição de avaliação regravava `criadoEm`; a regra exige que esse campo não mude. | Leitura do `firestore.rules` | Edição usa `update` sem o campo `criadoEm`. |
| 4 | Favoritar aguardava a escrita com limite de tempo: sem internet, o Firestore só confirma quando a conexão volta, e o app mostrava erro mesmo com o favorito salvo no cache. | Análise do comportamento offline | A escrita não é aguardada; o cache atualiza a tela na hora e sincroniza depois. |
| 5 | Exclusão definitiva de área apagava as avaliações em lote, mas a regra exige o resumo caindo junto com cada exclusão. | Leitura do `firestore.rules` | Cada avaliação é removida pela mesma transação usada pelo autor; depois fotos, eventos e a área. |
| 6 | Pacotes que ainda usam `package:flutter/material.dart` (ex.: `flutter_map`) não acham o tema do `material_ui`. | Guia de migração do Flutter 3.47 | `MaterialUiCompatibilityBridge` no `MaterialApp.builder`. |
| 7 | Pedido de localização antes de a tela existir. | Revisão | A permissão é pedida depois do primeiro quadro, na `ShellTela`. |
| 8 | A sessão guardava o usuário só quando o stream do Firebase Auth avisava; logo depois do login, ações como favoritar ainda viam "deslogado" e o app quebrava no `uid!`. | Revisão do fluxo de login dentro de uma ação | `Sessao` lê `FirebaseAuth.instance.currentUser`, que já está preenchido quando o login termina. |
| 9 | `Foto.bytes` decodifica o base64 sem tratamento: um documento corrompido derrubaria a página do local. | Revisão do código | `bytesDaFoto()` devolve `null` e a tela mostra um ícone no lugar. |
| _(adicionar — ex.: erros ao rodar `flutter run`)_ | | | |

## 4. Bibliotecas e justificativa

| Pacote | Para quê | Por que este |
|---|---|---|
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Login e banco | Stack obrigatória; Firestore tem cache offline nativo. |
| `material_ui` | Componentes Material | Pacote oficial que substitui `package:flutter/material.dart` a partir do Flutter 3.47. |
| `flutter_map` + `latlong2` | Mapa | OpenStreetMap: **sem chave de API e sem custo** (Google Maps exige conta de faturamento). |
| `geolocator` | Distância até o local (RF02) | Permissão e cálculo de distância entre coordenadas. |
| `url_launcher` | Abrir a rota no app de mapas (RF03) | O app de mapas já faz o trajeto a pé, de bicicleta e de ônibus. |
| `share_plus` | Compartilhar local (RF17) | Compartilhamento nativo do Android e do iOS. |
| `connectivity_plus` | Saber se está sem internet | Mostra a faixa "Sem internet" (tratamento de falhas). |
| `sqflite` + `path` | Diário e locais offline | Banco local; o diário nunca sai do aparelho (RNF04). |
| `image_picker` | Fotos da comunidade (CRUD 4) | Câmera e galeria, já reduzindo e comprimindo a imagem para caber no limite do Firestore. |
| `google_fonts` | Fraunces e Nunito Sans | Tipografia definida no guia visual do protótipo. |

**Sem gerenciador de estado externo:** o estado usa `ChangeNotifier` + `ListenableBuilder`, que já
vêm no Flutter. Menos dependências e mais fácil de explicar na arguição.
