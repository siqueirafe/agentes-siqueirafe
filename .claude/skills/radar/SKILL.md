---
name: radar
description: Roda o radar do dia com o time de agentes, na ordem pesquisador, verificador, redator, guarda (e o agente do dono, se existir), e depois grava o dia no repositório com um commit. Use quando alguém pedir para rodar o radar ou quando a rotina das 7h disparar.
---

# Radar do dia

Você coordena o time. Quem pesquisa, confere, escreve e revisa são os
agentes de .claude/agents/. Você aciona cada um, confere o que ele
entregou e só então passa para a próxima etapa. Uma etapa por vez, nesta
ordem, sem pular nenhuma.

## Antes de começar

1. Descubra a data de hoje no formato AAAA-MM-DD. É ela que dá o nome dos
   arquivos do dia. Passe essa data no pedido para cada agente.
2. Leia CLAUDE.md e RADAR.md.

## Etapa 1: pesquisador

Acione o agente `pesquisador` com a data de hoje.

Confira se fontes/AAAA-MM-DD.md existe e se tem pelo menos três itens.
Se tiver menos, ou se o pesquisador disser que não há nada novo, anote
isso e siga mesmo assim.

## Etapa 2: verificador

Acione o agente `verificador` com a data de hoje.

Confira se verificacao/AAAA-MM-DD.md existe e se termina com a contagem
de CONFERE, NÃO CONFERE e NÃO ABRIU.

## Etapa 3: redator

Acione o agente `redator` com a data de hoje.

Confira se diario/AAAA-MM-DD.md e index.html existem e se o index.html
está com a data de hoje.

## Etapa 4: o agente do dono

Com Glob, liste .claude/agents/. Se existir algum agente além de
pesquisador, verificador, redator e guarda, acione cada um deles com a
data de hoje.

Inclua o que cada um devolver no fim do briefing, numa seção com o nome
dele. A seção do `puxa-conversa` se chama
`## PARA O NOSSO TIME DE MILHÕES`; a de qualquer outro agente leva o nome
do agente:

- em diario/AAAA-MM-DD.md, no fim do arquivo;
- em index.html, no fim do conteúdo do briefing, antes de `</article>`,
  dentro de `<section class="time">...</section>` (o quadro laranja do
  modelo), com o nome da seção num `<h2>`,
  em HTML simples.

Não altere mais nada do briefing. Se não houver agente além dos quatro,
pule para a etapa 5.

## Etapa 5: guarda

Acione o agente `guarda` com a data de hoje.

- Se a última linha for **NÃO PUBLIQUE**: pare aqui. Mostre o relatório
  do guarda inteiro e não faça commit. Os arquivos do dia continuam na
  pasta para quem for revisar.
- Se for **PODE PUBLICAR**: siga para a etapa 6.

## Etapa 6: gravar e enviar

1. `git add -A`
2. `git commit -m "radar de AAAA-MM-DD"`
3. Se houver remoto configurado (`git remote`), `git push`.

Se o push falhar, diga o motivo com as palavras do erro e pare. Não tente
contornar: não force o envio, não troque o remoto, não peça nem use senha
ou token.

## Etapa 7: o resumo

Mostre, em poucas linhas:

- a primeira linha do briefing (o placar);
- quantos itens conferiram (CONFERE) de quantos anotados;
- quantos agentes rodaram e quais;
- se o commit e o push foram feitos.

## Nunca

- Nunca enviar nada a ninguém além do commit e do push para o remoto
  deste repositório. A única exceção é o e-mail da rotina radar-diario
  para o dono do radar, descrito em CLAUDE.md, e ele é feito pela rotina,
  não por esta Skill.
- Nunca usar, pedir ou gravar chave, senha ou token.
- Nunca pular uma etapa nem mudar a ordem.
- Nunca apagar ou alterar o dia de uma data anterior.
