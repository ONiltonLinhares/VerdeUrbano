# CLAUDE.md — VerdeUrbano

Guia para quem desenvolve o VerdeUrbano com ajuda de IA (Claude Code, Claude, Copilot etc.).
Leia antes de mudar qualquer coisa. Plano de trabalho: [`docs/roadmap.md`](docs/roadmap.md).

## O projeto

App mobile para encontrar **áreas verdes urbanas** (parques, praças, hortas, bosques), decidir se
o local serve para a visita (atividades, estrutura, acessibilidade) e chegar até ele em **até 3
toques**. Projeto acadêmico da disciplina *Programação para Dispositivos Móveis*, Unidade II.

- **Personas:** Marina Alves (prioritária: quer descobrir e chegar rápido) e Sr. Antônio
  (acessibilidade, leitura fácil). Ver `docs/personas.md`.
- **Requisitos:** RF01–RF17 e RNF01–RNF08 em `docs/requisitos.md`; CRUDs 1–6 (usuário, área
  verde, avaliação, foto, evento, favorito).
- **Protótipo de alta fidelidade:** `docs/prototipoAltaFidelidade.pdf`. As telas devem ser
  **fiéis a ele** (critério de nota a.iii).
- **Datas:** apresentações em **03/12/2026** e **10/12/2026**.

## Stack (obrigatória pela avaliação: não trocar)

- **Flutter ≥ 3.47 / Dart ≥ 3.14** (canal stable).
- **Firebase Authentication** (e-mail/senha) e **Cloud Firestore**. Sem Firebase Storage
  (exigiria o plano pago): fotos da comunidade vão em base64 no documento.
- **SQLite** (`sqflite`) para dados que ficam só no aparelho: diário e cópias offline.
- Mapa com **flutter_map + OpenStreetMap** (sem chave de API).
- Estado com **`ChangeNotifier` + `ListenableBuilder`** (sem Provider, Riverpod ou Bloc).

## Estrutura (`app/`)

```
app/
├── lib/
│   ├── main.dart            inicializa Firebase, sessão, dados locais
│   ├── firebase_options.dart gerado pelo `flutterfire configure` (não editar à mão)
│   ├── core/                tema (Cores, criarTema), erros, formatos, validadores, navegação, ações nativas
│   ├── models/              entidades do domínio + conversão Dart ↔ Firestore/SQLite
│   ├── data/                repositórios: Firestore (`*_repositorio.dart`) e SQLite (`banco_local.dart`)
│   ├── estado/              ChangeNotifiers globais: Sessao, AreasEstado, LocalizacaoEstado, ConectividadeEstado
│   ├── widgets/             componentes do guia visual (AreaCard, LinhaDisponibilidade…)
│   └── telas/               uma tela por arquivo, sufixo `_tela.dart` (folhas: `_folha.dart`)
├── test/                    testes Dart (`flutter test`)
├── firestore.rules          regras de segurança: FONTE DA VERDADE das regras de negócio no banco
├── firestore.indexes.json   índices (collection group usados na exclusão de conta)
└── firestore-tests/         testes das regras no emulador (Node)
docs/                        estudo de caso, requisitos, personas, protótipos, modelagem e artefatos técnicos
```

## Comandos

Rodar na pasta `app/`:

```bash
flutter pub get
flutter analyze                 # precisa terminar sem erros
flutter test                    # testes Dart
flutter run                     # emulador ou celular
dart format lib test            # formatação

flutterfire configure           # liga ao projeto Firebase (gera lib/firebase_options.dart)
firebase deploy --only firestore   # publica regras e índices

cd firestore-tests && npm install && npm test   # testa as regras (precisa de Java 21)
```

## Convenções de código

- **Português** em nomes de classes, métodos, variáveis, comentários e textos da tela
  (`AreaVerde`, `salvar()`, `estaAberta`). Termos técnicos do Flutter ficam em inglês.
- **Imports de UI:** `package:material_ui/material_ui.dart` (Flutter 3.47+). **Não** usar
  `package:flutter/material.dart`. Arquivos sem UI usam `package:flutter/foundation.dart`.
- **Cores e fontes só pelo tema:** `Cores.floresta`, `Cores.terra`, `Theme.of(context).textTheme…`.
  Nada de `Color(0x...)` novo espalhado; se precisar, crie em `core/tema.dart`.
- **Telas não falam com o Firebase.** Tela → repositório (`data/`) ou estado (`estado/`).
  Repositórios são singletons: `AreasRepositorio.instancia`.
- **Erros:** todo acesso remoto passa por `comLimiteDeTempo(...)` e converte o erro com
  `mensagemDeErro(e)` → `ErroApp` (mensagem em português). A tela mostra com `avisar(context, ...)`.
- **Streams do Firestore** são criados uma vez no `State` (`late final _stream = ...`), nunca dentro do `build`.
- Depois de `await`, checar `mounted` / `context.mounted` antes de usar o `context`.
- Botões com alvo de toque ≥ 48 px; ícone sempre acompanhado de texto ou `tooltip` (acessibilidade).
- Estado com 3 valores (`Disponibilidade.tem / naoTem / naoInformado`): "não informado" **nunca**
  vira "não tem" (RF07).

## Regras de negócio que não podem quebrar

Estão no código **e** no `firestore.rules`. Mudou uma, mude as duas e os testes.

1. Ver mapa, local, rota e diário **sem login** (RNF03). Ações da comunidade exigem login (`garantirLogin`).
2. **1 avaliação por usuário por local** (id do doc = uid). Avaliação e `resumo` da área são
   gravados **na mesma transação** com `ResumoAvaliacoes.adicionar/substituir/remover`.
3. Ninguém vira admin pelo app: `papel` só muda pelo console do Firebase.
4. Morador sugere local como `pendente`; só admin publica, edita, desativa ou exclui.
5. Evento só no futuro e com fim depois do início; só o organizador edita.
6. Foto ≤ `Foto.tamanhoMaximoBytes` (~700 KB) já comprimida pelo `image_picker`.
7. **Diário nunca vai para o servidor** (RNF04). Offline: no máximo 20 locais (RNF06).
8. Excluir conta: apaga perfil, favoritos e fotos; anonimiza avaliações e eventos (LGPD).

## Ao mudar o modelo de dados

Atualizar **junto, no mesmo PR**: `lib/models/` → `firestore.rules` → `firestore-tests/` →
`test/models_test.dart` → `docs/modelagem-dados.md` (diagrama e mapeamento Dart ↔ Firestore).

## Git e nota individual (leia!)

A nota individual vem dos **commits de cada um, pela própria conta do GitHub** (critério c.i).
Por isso:

- **Uma branch por tarefa**: `feat/<assunto>`, `fix/<assunto>`, `docs/<assunto>`. Nada direto na `main`.
- **Pull Request** revisado por outro integrante antes do merge.
- Commits pequenos, mensagem em português no imperativo: `Adiciona filtro de distância no mapa`.
- Quem pediu à IA é quem commita: **não** commitar trabalho de outro integrante pela sua conta.
- A cada PR: atualizar `CHANGELOG.md` (data + Adicionado/Alterado/Corrigido) e, se usou IA,
  `docs/uso-de-ia.md` (prompt, erro da IA e como foi resolvido: critério b.vi).
- Atualizar a seção de responsabilidades do `README.md` com o que você **realmente** fez (c.ii).

## Instruções para a IA

- Antes de codar, ler os arquivos envolvidos e o trecho relevante do `firestore.rules`.
- Seguir o protótipo: textos, ordem dos blocos e componentes já existem em `widgets/`; reutilizar.
- Não adicionar dependências sem necessidade; se adicionar, justificar em `docs/uso-de-ia.md`.
- Não editar `firebase_options.dart`, `pubspec.lock` à mão, nem pastas `android/`/`ios/` além do necessário.
- Não reescrever arquivos inteiros de outros integrantes; preferir mudanças pequenas.
- Ao terminar: `flutter analyze` e `flutter test` sem erros, e dizer o que testar no emulador.
- Código gerado por IA com bug que impeça a execução **tira ponto** (obs. do item a): na dúvida, simplificar.
