# B3 Options Scheduler

Agendador publico e sem dados pessoais para executar um monitor privado de opcoes.

- O codigo do monitor permanece em um repositorio privado.
- Credenciais e chaves ficam armazenadas apenas em GitHub Actions Secrets.
- O relatorio nao e salvo nem publicado neste repositorio.
- As tentativas de reserva nao enviam mensagens duplicadas no mesmo dia.

O monitor gera um ranking educacional com dados EOD. Ele nao envia ordens e nao
representa recomendacao de investimento ou garantia de lucro.

## Relogio externo

O diretorio `cloudflare/` contem um Worker gratuito que dispara este workflow
por meio da API oficial do GitHub. O token usado pelo Worker deve ser de acesso
fino, limitado a este repositorio e somente com a permissao `Actions: write`.
