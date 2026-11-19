# 🌿 VerdeUrbano

## Atividade

Estruturação inicial do projeto **VerdeUrbano**.

---

## 👥 Integrantes

- Douglas Cruz de Araújo
- Téssio Lima
- João Lucas Resende
- Nilton Linhares
- Richard Souza

## 🎓 Turma

**GP0161NOT05A**

---

## 📱 Sobre a atividade

A atividade teve como objetivo definir e estruturar os principais elementos iniciais do projeto **VerdeUrbano**, uma proposta de aplicativo voltado à localização de áreas verdes urbanas, como parques, praças e hortas comunitárias.

Durante a atividade, foram realizadas pesquisas e levantamentos para compreender melhor o público-alvo, as necessidades dos usuários e referências para o desenvolvimento da proposta.

---

## 📋 Responsabilidades

### Douglas Cruz de Araújo
Responsável pela elaboração e organização deste **README**, reunindo as informações e atividades realizadas pelo grupo durante a atividade.

### Téssio Lima
Responsável pela criação e definição das **personas do projeto**, representando os principais perfis de usuários da aplicação, criação do CRUD.

### João Lucas Rezende
Responsável pela realização das pesquisas relacionadas ao projeto , pelo levantamento de informações relevantes para a atividade, funcionalidades, requisitos funcionais, priorização, criação dos protótipos de baixa e alta fidelidade e justificativas.

### Nilton Linhares
Responsável pela realização do **benchmark**, analisando soluções e aplicações semelhantes como referência para o projeto.

### Richard Souza
Responsável, em conjunto com Téssio Lima, pela criação e definição das **personas do projeto**, requisitos não funcionais.

---

# 📱 Unidade II — Aplicativo

**Stack:** Dart · Flutter · Firebase (Authentication + Cloud Firestore), como exigido pela disciplina.

## Estrutura

```
app/                        projeto Flutter
├── lib/
│   ├── main.dart           inicialização do Firebase e do app
│   ├── core/tema.dart      cores e tipografia do guia visual (Unidade I)
│   ├── models/             classes de domínio (Dart ↔ Firestore)
│   ├── data/               banco local SQLite (diário e locais offline)
│   └── telas/              telas do app
├── test/                   testes automatizados
├── firestore.rules         regras de segurança do Firestore
└── firestore-tests/        testes das regras no emulador (npm test, precisa de Java 21)
docs/modelagem-dados.md     diagrama de classes, coleções do Firestore e mapeamento
```

## Como rodar

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install) e um emulador Android.
2. Na pasta `app/`:
   ```bash
   flutter pub get
   flutter run
   ```
3. Testes: `flutter test`

> Enquanto o Firebase não estiver configurado (`flutterfire configure`), o app abre uma tela de aviso em vez de fechar.

## Telas e funcionalidades (Sprint 2)

| Aba / tela | O que faz | Requisitos |
|---|---|---|
| Login, Cadastro, Perfil | Firebase Auth (e-mail e senha), recuperar senha, preferências, sugestões de local, excluir conta | CRUD 1, RNF03 |
| Início | "Que tal um respiro verde hoje?", busca, filtros rápidos, cards com distância, nota, horário e selo Acessível | RF01, RF02, RF13 |
| Mapa | OpenStreetMap com pinos; card com **Rota** e **Ver detalhes** | RF01–RF03 |
| Filtros | Atividades, estrutura, acessibilidade e distância máxima | RF04, RF05 |
| Página do local | Atividades, estrutura, acessibilidade (Tem / Não tem / Não informado), fonte e data, fotos, eventos e avaliações | RF06–RF10, CRUDs 3–5 |
| Rota | Tempo a pé, bicicleta e ônibus; "Iniciar navegação" abre o app de mapas | RF03, RNF01 |
| Salvos | Favoritos sincronizados e locais baixados para uso offline | RF11, RF12, RF14–RF16 |
| Diário | Registro de bem-estar só no aparelho (SQLite) | RNF04 |
| Administração | Cadastrar e editar áreas, aprovar sugestões, moderar sinalizações, dados de exemplo | CRUD 2, RF10 |

Pastas novas em `app/lib/`: `core/` (erros, formatos, validações, navegação, ações nativas),
`data/` (repositórios do Firestore e do SQLite), `estado/` (sessão, áreas e filtros, localização,
conexão) e `widgets/` (componentes do guia visual).

### Configurar o Firebase (uma vez)

1. No [Firebase Console](https://console.firebase.google.com), crie o projeto, ative **Authentication → E-mail/senha** e crie o **Cloud Firestore**.
2. Na pasta `app/`: `dart pub global activate flutterfire_cli` e `flutterfire configure` (gera `lib/firebase_options.dart`).
3. Publique regras e índices: `firebase deploy --only firestore` na pasta `app/` (ou cole `firestore.rules` no console).
4. Crie uma conta pelo app e, no console, mude `usuarios/{uid}.papel` para `admin`.
5. No app: **Perfil → Área do administrador → Adicionar locais de exemplo**.

### Documentação técnica (`docs/`)

| Item da avaliação | Arquivo |
|---|---|
| b.i Casos de uso + regras de negócio | [docs/diagrama-casos-de-uso.md](docs/diagrama-casos-de-uso.md) |
| b.ii–iv Classes, Firestore e mapeamento Dart → Firestore | [docs/modelagem-dados.md](docs/modelagem-dados.md) |
| b.v Fluxo de navegação | [docs/fluxo-navegacao.md](docs/fluxo-navegacao.md) |
| b.vi Uso de IA | [docs/uso-de-ia.md](docs/uso-de-ia.md) |
| d Escopo, EAP e sprints | [docs/planejamento.md](docs/planejamento.md) |
| Roadmap até a entrega (fases, checklist da avaliação) | [docs/roadmap.md](docs/roadmap.md) |
| Guia de desenvolvimento com IA (convenções, regras, Git) | [CLAUDE.md](CLAUDE.md) |

