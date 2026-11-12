// Testes das regras de segurança (app/firestore.rules) no emulador do Firebase.
// Rodar: cd app/firestore-tests && npm install && npm test   (precisa de Java 21)

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collectionGroup,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

let env;

const AREA = 'areas_verdes/parque';
const resumoVazio = {
  total: 0, somaNotas: 0, somaLimpeza: 0, somaConservacao: 0, somaAcessibilidade: 0,
};
const agora = () => Timestamp.now();

function avaliacao(uid, nota = 5) {
  return {
    autorId: uid, autorNome: 'Marina A.', nota,
    notaLimpeza: 4, notaConservacao: 3, notaAcessibilidade: 2,
    comentario: 'Lugar tranquilo.', criadoEm: agora(), atualizadoEm: agora(),
  };
}

const db = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-verde-urbano',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8'), host: '127.0.0.1', port: 8089 },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const f = ctx.firestore();
    await setDoc(doc(f, 'usuarios/admin'), { nome: 'Admin', papel: 'admin' });
    await setDoc(doc(f, AREA), { nome: 'Parque', status: 'publicada', resumo: resumoVazio });
    await setDoc(doc(f, 'areas_verdes/sugerida'), {
      nome: 'Horta', status: 'pendente', criadoPor: 'marina', resumo: resumoVazio,
    });
  });
});

describe('leitura pública (RNF03)', () => {
  test('sem login lê área publicada', () => assertSucceeds(getDoc(doc(db(), AREA))));
  test('sem login NÃO lê área pendente', () => assertFails(getDoc(doc(db(), 'areas_verdes/sugerida'))));
  test('quem sugeriu lê a própria sugestão pendente', () =>
    assertSucceeds(getDoc(doc(db('marina'), 'areas_verdes/sugerida'))));
  test('outro usuário NÃO lê sugestão alheia', () =>
    assertFails(getDoc(doc(db('joao'), 'areas_verdes/sugerida'))));
});

describe('usuários e controle de acesso', () => {
  test('cria o próprio perfil como usuario', () =>
    assertSucceeds(setDoc(doc(db('marina'), 'usuarios/marina'), { nome: 'Marina', papel: 'usuario' })));
  test('NÃO cria perfil já como admin', () =>
    assertFails(setDoc(doc(db('marina'), 'usuarios/marina'), { nome: 'Marina', papel: 'admin' })));
  test('NÃO se promove a admin depois', async () => {
    await setDoc(doc(db('marina'), 'usuarios/marina'), { nome: 'Marina', papel: 'usuario' });
    await assertFails(updateDoc(doc(db('marina'), 'usuarios/marina'), { papel: 'admin' }));
  });
  test('NÃO lê perfil de outra pessoa', () => assertFails(getDoc(doc(db('marina'), 'usuarios/admin'))));
});

describe('favoritos', () => {
  test('favorita área que existe', () =>
    assertSucceeds(setDoc(doc(db('marina'), 'usuarios/marina/favoritos/parque'), { adicionadoEm: agora() })));
  test('NÃO favorita área inexistente', () =>
    assertFails(setDoc(doc(db('marina'), 'usuarios/marina/favoritos/fantasma'), { adicionadoEm: agora() })));
  test('NÃO mexe nos favoritos de outro', () =>
    assertFails(setDoc(doc(db('joao'), 'usuarios/marina/favoritos/parque'), { adicionadoEm: agora() })));
});

describe('avaliações + resumo (transação)', () => {
  const resumoCom = (n) => ({
    total: 1, somaNotas: n, somaLimpeza: 4, somaConservacao: 3, somaAcessibilidade: 2,
  });

  async function avaliar(uid, nota, resumo) {
    const f = db(uid);
    const b = writeBatch(f);
    b.set(doc(f, `${AREA}/avaliacoes/${uid}`), avaliacao(uid, nota));
    if (resumo) b.update(doc(f, AREA), { resumo });
    return b.commit();
  }

  test('avalia e atualiza o resumo com a conta certa', () => assertSucceeds(avaliar('marina', 5, resumoCom(5))));
  test('NÃO avalia sem atualizar o resumo', () => assertFails(avaliar('marina', 5, null)));
  test('NÃO infla o resumo (diz que deu 5, soma 50)', () => assertFails(avaliar('marina', 5, resumoCom(50))));
  test('NÃO altera o resumo sem avaliação junto', () =>
    assertFails(updateDoc(doc(db('marina'), AREA), { resumo: resumoCom(5) })));
  test('NÃO aceita nota 6', () => assertFails(avaliar('marina', 6, resumoCom(6))));
  test('NÃO avalia em nome de outra pessoa', async () => {
    const f = db('joao');
    const b = writeBatch(f);
    b.set(doc(f, `${AREA}/avaliacoes/marina`), avaliacao('marina'));
    b.update(doc(f, AREA), { resumo: resumoCom(5) });
    await assertFails(b.commit());
  });

  test('edita a nota (5 → 3) ajustando o resumo', async () => {
    await avaliar('marina', 5, resumoCom(5));
    const f = db('marina');
    const b = writeBatch(f);
    b.update(doc(f, `${AREA}/avaliacoes/marina`), { nota: 3 });
    b.update(doc(f, AREA), { resumo: resumoCom(3) });
    await assertSucceeds(b.commit());
  });

  test('edita só o nome (anonimização LGPD) sem mexer no resumo', async () => {
    await avaliar('marina', 5, resumoCom(5));
    await assertSucceeds(
      updateDoc(doc(db('marina'), `${AREA}/avaliacoes/marina`), { autorNome: 'Usuário removido' }));
  });

  test('exclui a avaliação e o resumo volta a zero', async () => {
    await avaliar('marina', 5, resumoCom(5));
    const f = db('marina');
    const b = writeBatch(f);
    b.delete(doc(f, `${AREA}/avaliacoes/marina`));
    b.update(doc(f, AREA), { resumo: resumoVazio });
    await assertSucceeds(b.commit());
  });

  test('NÃO exclui avaliação de outra pessoa', async () => {
    await avaliar('marina', 5, resumoCom(5));
    const f = db('joao');
    const b = writeBatch(f);
    b.delete(doc(f, `${AREA}/avaliacoes/marina`));
    b.update(doc(f, AREA), { resumo: resumoVazio });
    await assertFails(b.commit());
  });

  test('sem login lista avaliações de todas as áreas (consulta por autor)', () =>
    assertSucceeds(getDocs(query(collectionGroup(db(), 'avaliacoes'), where('autorId', '==', 'marina')))));
});

describe('sugestão de área por morador', () => {
  const nova = (extra) => ({ nome: 'Praça', status: 'pendente', criadoPor: 'marina', resumo: resumoVazio, ...extra });
  test('sugere como pendente', () => assertSucceeds(setDoc(doc(db('marina'), 'areas_verdes/nova'), nova())));
  test('NÃO publica direto', () =>
    assertFails(setDoc(doc(db('marina'), 'areas_verdes/nova'), nova({ status: 'publicada' }))));
  test('NÃO cria já com avaliações falsas', () =>
    assertFails(setDoc(doc(db('marina'), 'areas_verdes/nova'), nova({ resumo: { ...resumoVazio, total: 99 } }))));
  test('admin publica', () =>
    assertSucceeds(updateDoc(doc(db('admin'), 'areas_verdes/sugerida'), { status: 'publicada' })));
});

describe('fotos da comunidade', () => {
  const foto = (uid) => ({
    autorId: uid, autorNome: 'Marina', imagemBase64: 'aGVsbG8=', legenda: 'Lago',
    criadoEm: agora(), atualizadoEm: agora(),
  });
  test('envia foto', () => assertSucceeds(setDoc(doc(db('marina'), `${AREA}/fotos/f1`), foto('marina'))));
  test('NÃO envia foto gigante (> 1 MiB)', () =>
    assertFails(setDoc(doc(db('marina'), `${AREA}/fotos/f1`), { ...foto('marina'), imagemBase64: 'a'.repeat(970000) })));
  test('outro usuário NÃO edita a legenda', async () => {
    await setDoc(doc(db('marina'), `${AREA}/fotos/f1`), foto('marina'));
    await assertFails(updateDoc(doc(db('joao'), `${AREA}/fotos/f1`), { legenda: 'feio' }));
  });
  test('admin remove foto imprópria', async () => {
    await setDoc(doc(db('marina'), `${AREA}/fotos/f1`), foto('marina'));
    await assertSucceeds(deleteDoc(doc(db('admin'), `${AREA}/fotos/f1`)));
  });
});

describe('eventos e mutirões', () => {
  const daqui = (horas) => Timestamp.fromMillis(Date.now() + horas * 3600_000);
  const evento = (extra) => ({
    titulo: 'Ioga no parque', descricao: '', tipo: 'ioga',
    inicio: daqui(24), fim: daqui(25), organizadorId: 'marina', organizadorNome: 'Marina',
    status: 'agendado', ...extra,
  });
  test('agenda evento futuro', () => assertSucceeds(setDoc(doc(db('marina'), `${AREA}/eventos/e1`), evento())));
  test('NÃO agenda no passado', () =>
    assertFails(setDoc(doc(db('marina'), `${AREA}/eventos/e1`), evento({ inicio: daqui(-2), fim: daqui(-1) }))));
  test('NÃO termina antes de começar', () =>
    assertFails(setDoc(doc(db('marina'), `${AREA}/eventos/e1`), evento({ fim: daqui(23) }))));
  test('organizador cancela', async () => {
    await setDoc(doc(db('marina'), `${AREA}/eventos/e1`), evento());
    await assertSucceeds(updateDoc(doc(db('marina'), `${AREA}/eventos/e1`), { status: 'cancelado' }));
  });
  test('outra pessoa NÃO cancela', async () => {
    await setDoc(doc(db('marina'), `${AREA}/eventos/e1`), evento());
    await assertFails(updateDoc(doc(db('joao'), `${AREA}/eventos/e1`), { status: 'cancelado' }));
  });
});

describe('sinalizações (moderação)', () => {
  const sin = { areaId: 'parque', autorId: 'marina', descricao: 'Banheiro fechado', status: 'pendente', criadoEm: agora() };
  test('usuário sinaliza', () => assertSucceeds(setDoc(doc(db('marina'), 'sinalizacoes/s1'), sin)));
  test('sem login NÃO sinaliza', () => assertFails(setDoc(doc(db(), 'sinalizacoes/s1'), sin)));
  test('usuário NÃO marca como resolvida', async () => {
    await setDoc(doc(db('marina'), 'sinalizacoes/s1'), sin);
    await assertFails(updateDoc(doc(db('marina'), 'sinalizacoes/s1'), { status: 'resolvida' }));
  });
  test('admin resolve', async () => {
    await setDoc(doc(db('marina'), 'sinalizacoes/s1'), sin);
    await assertSucceeds(updateDoc(doc(db('admin'), 'sinalizacoes/s1'), { status: 'resolvida' }));
  });
});
