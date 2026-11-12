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
└── firestore.rules         regras de segurança do Firestore
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
