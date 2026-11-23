# Fluxo de Navegação — VerdeUrbano

Atende ao item **b) v**: como as telas se conectam na prática. Arquivos em `app/lib/telas/`.

```mermaid
flowchart TD
    START([Abrir o app]) --> LOGADO0{Já entrou<br/>antes?}
    LOGADO0 -->|sim| INICIO
    LOGADO0 -->|não| LOGIN[🔐 Login<br/>login_tela.dart]
    LOGIN -->|Entrar| INICIO
    LOGIN -->|Explorar sem conta| INICIO
    LOGIN -->|Criar conta| CAD[Cadastro<br/>cadastro_tela.dart]
    CAD -->|conta criada| INICIO

    subgraph SHELL[Barra inferior — shell_tela.dart]
      INICIO[🏠 Início<br/>inicio_tela.dart]
      MAPA[🗺️ Mapa<br/>mapa_tela.dart]
      SALVOS[❤️ Salvos<br/>salvos_tela.dart]
      DIARIO[📖 Diário<br/>diario_tela.dart]
    end

    INICIO -->|ícone de filtro| FILTROS[[Filtros<br/>filtros_folha.dart]]
    MAPA -->|ícone de filtro| FILTROS
    INICIO -->|Ver no mapa| MAPA

    INICIO -->|toca no card| LOCAL[📍 Página do local<br/>local_tela.dart]
    MAPA -->|pino, Ver detalhes| LOCAL
    SALVOS -->|toca no item| LOCAL

    LOCAL -->|Rota · 9 min a pé| ROTA[Rota<br/>rota_tela.dart]
    MAPA -->|pino, Rota| ROTA
    ROTA -->|Iniciar navegação| GMAPS[[App de mapas]]
    LOCAL -->|compartilhar| SHARE[[Compartilhamento]]
    LOCAL -->|Baixar offline| SALVOS

    LOCAL -->|Salvar / Avaliar / Enviar foto /<br/>Criar evento / Sinalizar| PRECISA{Está logado?}
    PRECISA -->|não| LOGIN2[Login<br/>volta para a ação]
    PRECISA -->|sim| ACOES
    subgraph ACOES[Ações do usuário]
      AVAL[⭐ Avaliação<br/>avaliacao_tela.dart]
      FOTO[📷 Foto<br/>foto_tela.dart]
      EVENTO[📅 Evento<br/>evento_tela.dart]
      SIN[[Sinalizar<br/>sinalizar_folha.dart]]
    end

    LOCAL -->|Registrar como me senti| REG[📝 Registro do diário<br/>registro_diario_tela.dart]
    DIARIO -->|Novo registro / toca no item| REG
    REG -->|Quer avaliar o local?| AVAL

    INICIO -->|ícone de perfil| PERFIL[👤 Perfil<br/>perfil_tela.dart]
    PERFIL -->|Sugerir| FORM[Área verde<br/>area_form_tela.dart]
    PERFIL -->|admin| ADMIN[Administração<br/>admin_tela.dart]
    ADMIN -->|Nova área| FORM
    ADMIN -->|Abrir local| LOCAL
    LOCAL -->|menu admin, Editar| FORM
```

## Jornada principal em 3 toques (RNF01)

```mermaid
flowchart LR
    A[1. Abrir o app<br/>Início] --> B[2. Tocar no card<br/>Página do local] --> C[3. Tocar em Rota<br/>tempo a pé, bicicleta, ônibus]
```

Pelo mapa também são 3 toques: **aba Mapa → pino → Rota**.

## Correspondência com o protótipo de alta fidelidade

| Tela do protótipo | Arquivo |
|---|---|
| Início (feed "Que tal um respiro verde hoje?") | `inicio_tela.dart` + `widgets/area_card.dart` |
| Mapa com card do local | `mapa_tela.dart` |
| Página do local (atividades, estrutura, acessibilidade, fonte, avaliações) | `local_tela.dart` |
| Rota (a pé, bicicleta, ônibus · Iniciar navegação) | `rota_tela.dart` |
| Filtros (3 filtros selecionados · Mostrar 9 locais) | `filtros_folha.dart` |
| Salvos (Favoritos · Offline) | `salvos_tela.dart` |
| Diário de bem-estar ("Como você está depois da visita?") | `diario_tela.dart`, `registro_diario_tela.dart` |
| Guia visual (cores, Fraunces e Nunito Sans) | `core/tema.dart` |
| *Novas na Unidade II* | `login_tela`, `cadastro_tela`, `perfil_tela`, `avaliacao_tela`, `foto_tela`, `evento_tela`, `area_form_tela`, `admin_tela` |
