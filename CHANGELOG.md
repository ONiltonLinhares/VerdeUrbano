# CHANGELOG

## [03/09/2026]

### Adicionado
- Estudo de caso do VerdeUrbano.


## [10/09/2026]

### Adicionado
- Benchmark de soluções relacionadas ao projeto.
- Pesquisa do projeto.
- Arquivo de apresentação das atividades realizadas.

### Atualizado
- README do projeto.


## [17/09/2026]

### Adicionado
- Funcionalidades
- Requisitos funcionais
- Requisitos não funcionais
- CRUD
- Priorização
- Arquivo de apresentação das atividades realizadas

### Atualizado
-README do projeto


## [30/09/2026]

### Adicionado
- Protótipo baixa fidelidade
- Protótipo alta fidelidade
- justificativas.md
- Arquivo de apresentação das atividades realizadas

### Atualizado   
- README do projeto


## [01/10/2026]

### Adicionado
- Apresentação final da Unidade I

### Atualizado
- Nomes dos arquivos da pasta docs, conforme a entrega final
- Correção ortográfica do CHANGELOG


## [11/11/2026] — Unidade II

### Adicionado
- Projeto Flutter na pasta `app/` com Firebase Auth, Cloud Firestore e SQLite local
- Modelagem de dados (`docs/modelagem-dados.md`): diagrama de classes, coleções do Firestore e mapeamento Dart ↔ Firestore
- Classes de domínio: AreaVerde, Usuario, Avaliacao, Favorito, Sinalizacao, RegistroDiario
- Regras de segurança do Firestore (`app/firestore.rules`)
- Tema com as cores e fontes do guia visual do protótipo de alta fidelidade
- Tela de login e navegação com as 4 abas (Início, Mapa, Salvos, Diário)
- Testes automatizados do mapeamento dos modelos

### Atualizado
- README com a estrutura do app e instruções para rodar


## [12/11/2026] — Revisão da modelagem de dados

### Adicionado
- Entidades `Foto` (CRUD 4) e `Evento` (CRUD 5), que estavam definidas na Unidade I e faltavam na modelagem
- Regras do Firestore que conferem a conta do resumo de avaliações (ninguém consegue inflar a nota de um local)
- Validação no banco: tamanho de texto, nota de 1 a 5, evento só no futuro, favorito só de área existente
- Testes das regras de segurança no emulador do Firebase (`app/firestore-tests/`, 39 casos)
- Busca por nome, bairro ou cidade sem diferenciar maiúscula e acento (RF13)
- Seções de exclusão de conta (LGPD) e de limitações conhecidas na modelagem

### Alterado
- Horário em minutos desde a meia-noite (`int`) em vez de texto, com dias de funcionamento
- Somas do resumo de avaliações de `double` para `int` (notas são inteiras)
- Favorito guarda só a referência da área, para não ficar desatualizado
- Diagrama de classes regenerado


## [12/11/2026] — Sprint 2: telas e CRUDs

### Adicionado
- Telas do protótipo: Início, Mapa, Filtros, Página do local, Rota, Salvos e Diário
- Login, cadastro, recuperação de senha, perfil e exclusão de conta com Firebase Auth
- CRUDs ligados ao Firestore: áreas verdes (admin e sugestão de morador), avaliações com resumo em transação, fotos da comunidade, eventos e mutirões, favoritos
- Sinalização de informação incorreta e área do administrador (aprovar sugestões, moderar)
- Diário de bem-estar e cópias offline usando o SQLite (`banco_local.dart`)
- Tratamento de falhas de conexão: faixa "Sem internet", mensagens em português, limite de tempo nas operações, cópia offline
- Permissões de localização, câmera e galeria (Android e iOS), índices do Firestore (`firestore.indexes.json`) e `firebase.json`
- Testes de formatação e validação (`test/formatos_test.dart`)
- Documentação: casos de uso, fluxo de navegação, planejamento (escopo, EAP, sprints) e registro de uso de IA

### Alterado
- `main.dart`: inicia sessão, áreas e dados locais; quem já entrou vai direto para o Início
- `login_tela.dart` e `shell_tela.dart`: placeholders trocados pelas telas reais
- `pubspec.yaml`: dependência `image_picker`


## [19/11/2026] — Organização do desenvolvimento

### Adicionado
- `CLAUDE.md`: stack, estrutura, comandos, convenções, regras de negócio e fluxo de Git para quem desenvolve com IA
- `docs/roadmap.md`: fases até 10/12, roteiro de testes por funcionalidade, checklist da avaliação e riscos
- Testes de filtros e busca (`test/filtros_test.dart`) e de widgets do Login e da acessibilidade (`test/telas_test.dart`)

### Corrigido
- Sessão lê o usuário direto do Firebase Auth: logo após o login, favoritar ou avaliar não falha mais por o stream ainda não ter avisado
- Foto com base64 corrompido não derruba mais a página do local

