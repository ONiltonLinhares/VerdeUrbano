// Enums do domínio. No Firestore são gravados pelo nome (`.name`), nunca pelo
// índice — reordenar um enum aqui não corrompe dado antigo.
// Ver docs/modelagem-dados.md, seção 4.

enum TipoArea {
  parque('Parque'),
  praca('Praça'),
  horta('Horta comunitária'),
  bosque('Bosque');

  const TipoArea(this.rotulo);
  final String rotulo;
}

enum Atividade {
  caminhada('Caminhada'),
  corrida('Corrida'),
  trilhas('Trilhas'),
  playground('Playground'),
  quadras('Quadras'),
  descanso('Descanso');

  const Atividade(this.rotulo);
  final String rotulo;
}

enum Recurso {
  bancos('Bancos'),
  banheiros('Banheiros'),
  bebedouros('Bebedouros'),
  equipamentosEsportivos('Equipamentos esportivos'),
  estacionamento('Estacionamento');

  const Recurso(this.rotulo);
  final String rotulo;
}

enum RecursoAcessibilidade {
  rampas('Rampas de acesso'),
  caminhosAcessiveis('Caminhos acessíveis'),
  banheiroAdaptado('Banheiro adaptado'),
  iluminacao('Iluminação noturna');

  const RecursoAcessibilidade(this.rotulo);
  final String rotulo;
}

/// RF07: "não tem" é diferente de "ninguém informou ainda".
enum Disponibilidade {
  tem('Tem'),
  naoTem('Não tem'),
  naoInformado('Não informado');

  const Disponibilidade(this.rotulo);
  final String rotulo;
}

enum StatusArea { publicada, pendente, desativada }

enum PapelUsuario { usuario, admin }

enum StatusSinalizacao { pendente, resolvida, rejeitada }

enum Humor {
  agitado('Agitado'),
  cansado('Cansado'),
  neutro('Neutro'),
  calmo('Calmo'),
  revigorado('Revigorado');

  const Humor(this.rotulo);
  final String rotulo;
}

enum AtividadeRealizada {
  caminhei('Caminhei'),
  corri('Corri'),
  descansei('Descansei'),
  brinqueiComCriancas('Brinquei com as crianças'),
  encontreiAmigos('Encontrei amigos'),
  observeiNatureza('Observei a natureza');

  const AtividadeRealizada(this.rotulo);
  final String rotulo;
}

/// Converte string do banco em enum sem derrubar o app quando o valor é
/// desconhecido ou nulo (documento antigo, digitação no console etc.).
T enumPorNome<T extends Enum>(List<T> valores, Object? nome, T padrao) {
  if (nome is! String) return padrao;
  for (final v in valores) {
    if (v.name == nome) return v;
  }
  return padrao;
}
