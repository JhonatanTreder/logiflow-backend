# LogiFlow — Requisitos Funcionais (RF)

**Versão:** 1.0 · **Data:** 30/09/2026
**Legenda de prioridade (MoSCoW):** **M** = Essencial · **S** = Importante · **C** = Desejável
**Formato do ID:** `RF-<MÓDULO>-<NN>`. Regras relacionadas estão no documento 04 (`RN-…`); fluxos no documento 05 (`UC-…`).

---

## AUT — Autenticação e Acesso

| ID | Requisito | Prio |
|---|---|---|
| RF-AUT-01 | O sistema deve permitir login com e-mail e senha. | M |
| RF-AUT-02 | O sistema deve emitir *access token* de curta duração e *refresh token* rotativo, permitindo renovar e encerrar sessão (logout). | M |
| RF-AUT-03 | O usuário deve poder recuperar a senha por link com validade limitada enviado por e-mail. | M |
| RF-AUT-04 | O sistema deve bloquear temporariamente a conta após tentativas consecutivas de login inválidas. | M |
| RF-AUT-05 | O sistema deve controlar acesso por papéis e permissões (RBAC) a telas, rotas e ações. | M |
| RF-AUT-06 | O Gestor deve criar, editar, desativar usuários da sua empresa e atribuir papéis. | M |
| RF-AUT-07 | O sistema deve permitir convidar usuários por e-mail com link de ativação. | S |
| RF-AUT-08 | O sistema deve oferecer autenticação em dois fatores (TOTP) opcional, obrigatória para papéis administrativos. | S |
| RF-AUT-09 | O Gestor deve gerar, listar e revogar chaves de API com escopos definidos. | M |
| RF-AUT-10 | O usuário deve visualizar e encerrar suas sessões ativas (dispositivo, IP, último acesso). | C |

## TEN — Empresas e Lojas

| ID | Requisito | Prio |
|---|---|---|
| RF-TEN-01 | O Super Admin deve cadastrar, editar, suspender e reativar empresas (tenants) com CNPJ, razão social e contatos. | M |
| RF-TEN-02 | Cada empresa deve poder ter uma ou mais lojas, cada uma com nome, domínio e origem de pedidos. | M |
| RF-TEN-03 | O Gestor deve cadastrar endereços de origem/coleta (um padrão e outros opcionais). | M |
| RF-TEN-04 | O Gestor deve configurar parâmetros da empresa: horário de corte, serviço padrão, frete grátis, seguro automático, dados do remetente nas etiquetas. | M |
| RF-TEN-05 | O Super Admin deve cadastrar contratos/planos de frete por empresa, vinculando tabelas, serviços e vigência. | M |
| RF-TEN-06 | O Gestor deve configurar endpoints de webhook e segredos de assinatura. | M |
| RF-TEN-07 | O Gestor deve personalizar a página de rastreio (logotipo, cores, mensagem, link da loja). | S |
| RF-TEN-08 | O sistema deve registrar histórico de alterações nas configurações da empresa. | S |

## CAT — Produtos e Estoque

| ID | Requisito | Prio |
|---|---|---|
| RF-CAT-01 | O sistema deve manter o cadastro de produtos (SKU, nome, peso, dimensões, valor, fragilidade, código de barras). | M |
| RF-CAT-02 | O sistema deve suportar variações de produto (ex.: cor/tamanho) como SKUs distintos agrupados. | S |
| RF-CAT-03 | O Operador deve importar produtos em lote por CSV, com relatório de erros por linha. | S |
| RF-CAT-04 | O sistema deve cadastrar armazéns/hubs com endereço, geolocalização e capacidade. | M |
| RF-CAT-05 | O sistema deve cadastrar localizações internas (corredor, prateleira, nível, posição) por armazém. | M |
| RF-CAT-06 | O Operador de Armazém deve registrar recebimento de mercadorias (entrada) com conferência de quantidade e endereçamento (*put-away*). | M |
| RF-CAT-07 | O sistema deve registrar toda movimentação de estoque (entrada, saída, transferência, ajuste, reserva, baixa) de forma imutável, com motivo e usuário. | M |
| RF-CAT-08 | O sistema deve calcular saldo disponível, reservado e total por SKU, localização e armazém. | M |
| RF-CAT-09 | O sistema deve reservar estoque automaticamente ao confirmar pedido e baixá-lo na separação. | M |
| RF-CAT-10 | O sistema deve permitir inventário cíclico e geral, com contagem, comparação e ajuste aprovado. | S |
| RF-CAT-11 | O sistema deve alertar quando o saldo ficar abaixo do estoque mínimo configurado. | S |
| RF-CAT-12 | O sistema deve controlar lote e validade, com regra FEFO na separação. | C |
| RF-CAT-13 | O sistema deve transferir estoque entre localizações e entre armazéns. | S |

## PED — Pedidos

| ID | Requisito | Prio |
|---|---|---|
| RF-PED-01 | O sistema deve receber pedidos via API, com itens, destinatário, endereço, valores e identificador externo. | M |
| RF-PED-02 | O sistema deve garantir idempotência na criação de pedidos (mesma chave ou mesmo número externo por loja). | M |
| RF-PED-03 | O Operador deve importar pedidos por CSV com validação e relatório de erros. | S |
| RF-PED-04 | O sistema deve validar e normalizar o endereço (CEP, UF, cidade) consultando serviço de CEP, com cache. | M |
| RF-PED-05 | O sistema deve geocodificar o endereço (latitude/longitude) e registrar a qualidade da geocodificação. | S |
| RF-PED-06 | O sistema deve listar pedidos com filtros (status, loja, período, destinatário, nº externo, UF) e busca textual. | M |
| RF-PED-07 | O sistema deve exibir o detalhe do pedido com itens, encomendas, eventos e financeiro vinculados. | M |
| RF-PED-08 | O usuário deve editar o endereço/contato do pedido enquanto permitido pelo status. | M |
| RF-PED-09 | O usuário deve cancelar pedido enquanto permitido pelas regras, liberando as reservas de estoque. | M |
| RF-PED-10 | O sistema deve permitir dividir um pedido em várias encomendas (por armazém, peso ou disponibilidade). | S |
| RF-PED-11 | O sistema deve informar à loja, por webhook, a mudança de status do pedido. | M |
| RF-PED-12 | O sistema deve registrar pedidos com erro de validação em uma fila de pendências para correção. | S |

## FRE — Frete e Cotação

| ID | Requisito | Prio |
|---|---|---|
| RF-FRE-01 | O sistema deve cadastrar zonas de frete por faixa de CEP e/ou UF/cidade. | M |
| RF-FRE-02 | O sistema deve cadastrar tabelas de preço por serviço, zona e faixa de peso, com prazo em dias úteis. | M |
| RF-FRE-03 | O sistema deve cadastrar serviços de entrega (Econômico, Expresso, Same-day, Retirada) e seus parâmetros. | M |
| RF-FRE-04 | O sistema deve calcular o peso cubado e o peso taxável de cada volume e da encomenda. | M |
| RF-FRE-05 | O sistema deve expor cotação (API e painel) retornando serviços disponíveis, preço, prazo e restrições. | M |
| RF-FRE-06 | O sistema deve calcular seguro com base no valor declarado. | M |
| RF-FRE-07 | O sistema deve aplicar taxas adicionais (área remota, volumoso, entrega agendada, frágil). | S |
| RF-FRE-08 | O sistema deve aplicar regras de frete grátis ou promocional configuradas por empresa. | S |
| RF-FRE-09 | O sistema deve versionar tabelas de frete com vigência, sem alterar encomendas já criadas. | M |
| RF-FRE-10 | O sistema deve calcular o prazo considerando horário de corte, dias úteis e feriados cadastrados. | M |
| RF-FRE-11 | O sistema deve manter um calendário de feriados (nacionais e locais). | S |
| RF-FRE-12 | O sistema deve oferecer um simulador de frete no painel (comparação entre serviços). | S |
| RF-FRE-13 | O sistema deve registrar a cotação usada na contratação (snapshot) para auditoria. | M |
| RF-FRE-14 | O sistema deve manter cache de cotações idênticas por curto período. | C |

## ENC — Encomendas

| ID | Requisito | Prio |
|---|---|---|
| RF-ENC-01 | O sistema deve gerar uma ou mais encomendas a partir de um pedido, escolhendo o serviço. | M |
| RF-ENC-02 | O sistema deve gerar código de rastreio único e imutável por encomenda. | M |
| RF-ENC-03 | A encomenda deve conter um ou mais volumes, cada um com peso, dimensões e código de barras próprio. | M |
| RF-ENC-04 | O sistema deve gerir o status da encomenda por máquina de estados com transições validadas. | M |
| RF-ENC-05 | O sistema deve registrar eventos de rastreio imutáveis a cada mudança relevante. | M |
| RF-ENC-06 | O sistema deve listar encomendas com filtros (status, serviço, hub, rota, período, prazo vencido) e exportar o resultado. | M |
| RF-ENC-07 | O sistema deve permitir alterar serviço ou prioridade antes do despacho, recalculando o frete. | S |
| RF-ENC-08 | O sistema deve permitir cancelar encomendas conforme regras de status. | M |
| RF-ENC-09 | O sistema deve permitir observações internas e anexos na encomenda. | S |
| RF-ENC-10 | O sistema deve permitir reagendar a entrega a pedido do destinatário ou da loja. | S |
| RF-ENC-11 | O sistema deve sinalizar encomendas com risco de atraso (SLA). | S |
| RF-ENC-12 | O sistema deve permitir marcar encomendas como "retirada pelo destinatário" (ponto de retirada no hub). | C |

## DES — Despacho e Expedição

| ID | Requisito | Prio |
|---|---|---|
| RF-DES-01 | O sistema deve manter fila de separação (*picking*) com prioridade por serviço, corte e SLA. | M |
| RF-DES-02 | O sistema deve gerar ordens de separação, com sequência otimizada pelas localizações. | M |
| RF-DES-03 | O sistema deve permitir separação em ondas (lotes de pedidos). | C |
| RF-DES-04 | O Operador deve confirmar separação item a item por leitura de código de barras/QR. | M |
| RF-DES-05 | O sistema deve tratar falta de item na separação (corte parcial, reposição, cancelamento do item). | S |
| RF-DES-06 | O Operador deve registrar embalagem: volumes, peso aferido e dimensões reais. | M |
| RF-DES-07 | O sistema deve detectar divergência entre peso declarado e aferido e recalcular o frete. | S |
| RF-DES-08 | O sistema deve gerar etiqueta de volume (PDF e ZPL) com código de barras, QR, destinatário, remetente, serviço e rota/hub. | M |
| RF-DES-09 | O sistema deve imprimir etiquetas em lote e reimprimir com registro. | M |
| RF-DES-10 | O sistema deve criar manifestos/romaneios agrupando volumes por transportadora, hub ou rota. | M |
| RF-DES-11 | O sistema deve conferir a saída: leitura dos volumes contra o manifesto antes do fechamento. | M |
| RF-DES-12 | O sistema deve registrar a coleta/entrega do manifesto com responsável, data/hora e assinatura. | M |
| RF-DES-13 | O sistema deve permitir agendar coletas na origem do lojista (janela, volumes estimados). | S |
| RF-DES-14 | O sistema deve exibir painel de despacho com pendências por horário de corte. | S |

## TRA — Transportadoras e Integrações de Transporte

| ID | Requisito | Prio |
|---|---|---|
| RF-TRA-01 | O sistema deve cadastrar transportadoras (parceiras) e seus serviços. | M |
| RF-TRA-02 | O sistema deve definir uma interface de *adapter* para integrações (cotar, postar, rastrear, cancelar). | M |
| RF-TRA-03 | O sistema deve incluir um adapter simulado (sandbox) que gere eventos de rastreio realistas. | M |
| RF-TRA-04 | O sistema deve selecionar automaticamente a transportadora/modal por regras (custo, prazo, região, peso, SLA). | S |
| RF-TRA-05 | O sistema deve importar eventos externos por webhook recebido ou *polling* agendado e traduzi-los ao padrão interno. | M |
| RF-TRA-06 | O sistema deve registrar o código de rastreio externo associado à encomenda. | M |
| RF-TRA-07 | O sistema deve manter indicadores de desempenho por transportadora (prazo cumprido, ocorrências). | S |
| RF-TRA-08 | O sistema deve manter tabelas de custo da transportadora (para margem). | S |
| RF-TRA-09 | O sistema deve permitir redespacho (entrega final por parceiro local). | C |

## HUB — Hubs e Transferências

| ID | Requisito | Prio |
|---|---|---|
| RF-HUB-01 | O sistema deve cadastrar hubs com tipo (coleta, triagem, última milha), área de cobertura e horário de funcionamento. | M |
| RF-HUB-02 | O Operador de Hub deve registrar recebimento de volumes por leitura de etiqueta, identificando divergências (excesso, falta, avaria). | M |
| RF-HUB-03 | O sistema deve criar manifestos de transferência entre hubs (linehaul) com veículo e previsão. | M |
| RF-HUB-04 | O sistema deve consolidar volumes em contêineres/gaiolas (*unitização*) e tratá-los como unidade. | S |
| RF-HUB-05 | O sistema deve sugerir o hub de destino conforme CEP e área de cobertura. | M |
| RF-HUB-06 | O sistema deve exibir ocupação e filas do hub (volumes por status e por rota). | S |
| RF-HUB-07 | O sistema deve suportar cross-docking (recebimento seguido de saída direta). | C |
| RF-HUB-08 | O sistema deve gerir volumes aguardando retirada com contagem de prazo de guarda. | S |

## ROT — Rotas e Entregas

| ID | Requisito | Prio |
|---|---|---|
| RF-ROT-01 | O sistema deve cadastrar veículos (tipo, placa, capacidade de peso e volume, situação). | M |
| RF-ROT-02 | O sistema deve cadastrar entregadores (documentos, CNH/categoria, veículo habitual, vínculo). | M |
| RF-ROT-03 | O Roteirizador deve criar rotas manualmente, adicionando encomendas e ordenando paradas. | M |
| RF-ROT-04 | O sistema deve sugerir rotas automaticamente agrupando encomendas por região, capacidade e janelas de entrega. | S |
| RF-ROT-05 | O sistema deve ordenar paradas minimizando distância (heurística; evolução via OSRM). | S |
| RF-ROT-06 | O sistema deve atribuir rota a entregador e veículo, validando conflitos e capacidade. | M |
| RF-ROT-07 | O sistema deve registrar carregamento do veículo por leitura dos volumes (conferência de carga). | M |
| RF-ROT-08 | O app do entregador deve listar rotas e paradas do dia, com endereço, contato, observações e janela. | M |
| RF-ROT-09 | O entregador deve iniciar e finalizar a rota, com registro de horário e quilometragem. | M |
| RF-ROT-10 | O entregador deve registrar entrega com comprovante (código de confirmação, foto e/ou assinatura, nome do recebedor). | M |
| RF-ROT-11 | O entregador deve registrar tentativa sem sucesso informando motivo padronizado e evidência. | M |
| RF-ROT-12 | O app deve funcionar com conectividade intermitente, sincronizando ações pendentes. | S |
| RF-ROT-13 | O sistema deve receber e armazenar a posição do entregador durante a rota (com consentimento). | S |
| RF-ROT-14 | O Roteirizador deve reordenar, remover ou adicionar paradas com a rota em andamento. | S |
| RF-ROT-15 | O sistema deve permitir janelas de entrega e entregas agendadas. | S |
| RF-ROT-16 | O sistema deve fechar a rota (acerto): conferir entregues, falhas e devoluções ao hub. | M |
| RF-ROT-17 | O sistema deve exibir o mapa de rotas ao vivo no painel operacional. | S |
| RF-ROT-18 | O sistema deve calcular ETA por parada e atualizá-lo conforme o andamento. | S |

## RAS — Rastreio

| ID | Requisito | Prio |
|---|---|---|
| RF-RAS-01 | O sistema deve oferecer página pública de rastreio consultável pelo código de rastreio. | M |
| RF-RAS-02 | A página deve exibir linha do tempo de eventos em linguagem clara, previsão de entrega e status atual. | M |
| RF-RAS-03 | O sistema deve oferecer API pública de rastreio (individual e em lote até N códigos). | M |
| RF-RAS-04 | O destinatário deve poder rastrear também por nº do pedido + e-mail/CPF parcial. | S |
| RF-RAS-05 | Quando em rota, a página deve exibir a posição aproximada do entregador e paradas restantes. | S |
| RF-RAS-06 | A página deve aplicar a identidade visual da loja. | S |
| RF-RAS-07 | O destinatário deve poder solicitar reagendamento ou informar nova instrução de entrega pela página. | S |
| RF-RAS-08 | O sistema deve ocultar dados pessoais sensíveis na página pública (mascarar nome, endereço parcial). | M |
| RF-RAS-09 | O destinatário deve avaliar a entrega (nota e comentário). | C |

## OCO — Ocorrências e Devoluções

| ID | Requisito | Prio |
|---|---|---|
| RF-OCO-01 | O sistema deve registrar ocorrências (avaria, extravio, endereço insuficiente, destinatário ausente, recusa, área de risco, atraso) vinculadas à encomenda. | M |
| RF-OCO-02 | O sistema deve abrir ocorrências automaticamente por regras (tentativas esgotadas, divergência, atraso, extravio presumido). | M |
| RF-OCO-03 | O Suporte deve tratar ocorrências com status, responsável, prazo (SLA), comentários e anexos. | M |
| RF-OCO-04 | O sistema deve permitir solução de ocorrência: reentrega, correção de endereço, devolução, indenização. | M |
| RF-OCO-05 | O sistema deve iniciar a logística reversa por pedido do destinatário/loja (troca, arrependimento, recusa). | M |
| RF-OCO-06 | O sistema deve gerar etiqueta reversa e encomenda de retorno, com coleta no endereço ou postagem em ponto. | M |
| RF-OCO-07 | O Operador de Hub deve receber e inspecionar a devolução, classificando o estado (apto, avariado, descarte). | M |
| RF-OCO-08 | O sistema deve reintegrar ao estoque os itens aptos e baixar os descartados. | M |
| RF-OCO-09 | O sistema deve gerir pedidos de indenização (solicitação, análise, aprovação, valor, pagamento). | S |
| RF-OCO-10 | O sistema deve notificar a loja e o destinatário a cada mudança relevante da ocorrência. | S |
| RF-OCO-11 | O sistema deve manter motivos de ocorrência padronizados e configuráveis. | S |

## FIN — Financeiro

| ID | Requisito | Prio |
|---|---|---|
| RF-FIN-01 | O sistema deve registrar para cada encomenda o preço cobrado (frete, seguro, taxas) e o custo operacional/da transportadora. | M |
| RF-FIN-02 | O sistema deve manter extrato de lançamentos por empresa, com filtros e exportação. | M |
| RF-FIN-03 | O sistema deve fechar faturas periódicas (semanal, quinzenal, mensal) por empresa, com itens detalhados. | M |
| RF-FIN-04 | O sistema deve gerar PDF/CSV da fatura e enviá-la por e-mail. | S |
| RF-FIN-05 | O sistema deve registrar pagamentos de faturas (manual/simulado) e calcular multa e juros por atraso. | S |
| RF-FIN-06 | O sistema deve lançar cobranças adicionais (devolução, redespacho, reentrega, divergência de peso). | M |
| RF-FIN-07 | O sistema deve lançar créditos/estornos (indenização, falha de serviço). | S |
| RF-FIN-08 | O sistema deve conciliar o custo informado pelas transportadoras com o custo previsto e sinalizar divergências. | S |
| RF-FIN-09 | O sistema deve calcular repasse de entregadores por entrega/parada/quilometragem e fechar períodos. | S |
| RF-FIN-10 | O sistema deve exibir relatório de margem por empresa, serviço, região e transportadora. | S |
| RF-FIN-11 | O sistema deve suportar saldo pré-pago por empresa como alternativa à fatura. | C |
| RF-FIN-12 | O sistema deve suspender a emissão de novas encomendas por inadimplência conforme política. | C |

## NOT — Notificações e Webhooks

| ID | Requisito | Prio |
|---|---|---|
| RF-NOT-01 | O sistema deve manter templates de mensagens por evento e canal, com variáveis e idioma. | M |
| RF-NOT-02 | O sistema deve enviar e-mails ao destinatário nos eventos principais (despachada, saiu para entrega, entregue, tentativa falha). | M |
| RF-NOT-03 | O sistema deve enviar SMS/WhatsApp por adapter (simulado no ambiente de estudo). | C |
| RF-NOT-04 | O sistema deve exibir notificações internas (in-app) aos usuários do painel. | S |
| RF-NOT-05 | O sistema deve enviar webhooks de saída assinados (HMAC) para os endpoints cadastrados. | M |
| RF-NOT-06 | O sistema deve repetir webhooks falhos com *backoff* e desativar endpoints com falha persistente. | M |
| RF-NOT-07 | O Gestor deve consultar o log de entregas de webhook e reenviá-las manualmente. | S |
| RF-NOT-08 | O destinatário e o usuário devem gerenciar preferências de notificação (canais e tipos). | S |
| RF-NOT-09 | O sistema deve respeitar descadastro (opt-out) e horários de silêncio para SMS/WhatsApp. | S |

## REL — Relatórios e Dashboards

| ID | Requisito | Prio |
|---|---|---|
| RF-REL-01 | O sistema deve exibir dashboard operacional (volumes por status, atrasos, corte do dia, rotas ativas). | M |
| RF-REL-02 | O sistema deve exibir dashboard do lojista (pedidos, entregues, em trânsito, ocorrências, custo de frete). | M |
| RF-REL-03 | O sistema deve calcular indicadores: prazo cumprido (OTIF), entrega na 1ª tentativa, tempo médio por etapa, taxa de devolução, custo por entrega. | M |
| RF-REL-04 | O sistema deve exibir produtividade por entregador e por operador. | S |
| RF-REL-05 | O sistema deve gerar relatórios de ocorrências, SLA e desempenho de transportadoras. | S |
| RF-REL-06 | O sistema deve exportar relatórios em CSV, XLSX e PDF. | S |
| RF-REL-07 | Todos os relatórios devem aceitar filtros por período, loja, região e serviço. | M |
| RF-REL-08 | O sistema deve agendar envio periódico de relatórios por e-mail. | C |
| RF-REL-09 | O sistema deve exibir mapa de calor de entregas e falhas por região. | C |

## INT — Integrações e API Pública

| ID | Requisito | Prio |
|---|---|---|
| RF-INT-01 | O sistema deve expor API REST pública versionada cobrindo cotação, pedidos, encomendas, rastreio e webhooks. | M |
| RF-INT-02 | O sistema deve publicar a documentação OpenAPI interativa. | M |
| RF-INT-03 | O sistema deve oferecer ambiente *sandbox* com chaves de teste e dados isolados. | S |
| RF-INT-04 | O sistema deve aplicar limite de requisições por chave/IP, com respostas e cabeçalhos padronizados. | M |
| RF-INT-05 | O sistema deve oferecer conectores prontos para plataformas de e-commerce (ex.: WooCommerce, loja genérica via webhook). | C |
| RF-INT-06 | O sistema deve importar e exportar dados em CSV com modelos baixáveis. | S |
| RF-INT-07 | O sistema deve integrar com serviço de CEP e geocodificação por adapters substituíveis. | M |
| RF-INT-08 | O sistema deve integrar com serviço de roteamento (OSRM) para distâncias e tempos. | C |

## AUD — Auditoria e Administração

| ID | Requisito | Prio |
|---|---|---|
| RF-AUD-01 | O sistema deve registrar auditoria de ações sensíveis (quem, o quê, quando, IP, antes/depois). | M |
| RF-AUD-02 | O Super Admin deve consultar e filtrar os logs de auditoria. | M |
| RF-AUD-03 | O sistema deve manter parâmetros globais (prazos, limites, motivos, feriados) editáveis com histórico. | S |
| RF-AUD-04 | O sistema deve exibir o estado das filas e jobs (pendentes, falhos), com reprocessamento manual. | S |
| RF-AUD-05 | O sistema deve atender solicitações LGPD: exportar e anonimizar dados de um titular. | S |
| RF-AUD-06 | O sistema deve aplicar política de retenção e anonimização automática de dados pessoais. | S |
| RF-AUD-07 | O sistema deve permitir *feature flags* por empresa. | C |
| RF-AUD-08 | O Super Admin deve ter painel com visão agregada da plataforma (empresas, volume, erros). | S |

---

## Resumo quantitativo

| Módulo | M | S | C | Total |
|---|---|---|---|---|
| AUT | 7 | 2 | 1 | 10 |
| TEN | 6 | 2 | 0 | 8 |
| CAT | 7 | 5 | 1 | 13 |
| PED | 8 | 4 | 0 | 12 |
| FRE | 9 | 4 | 1 | 14 |
| ENC | 7 | 4 | 1 | 12 |
| DES | 9 | 4 | 1 | 14 |
| TRA | 5 | 3 | 1 | 9 |
| HUB | 4 | 3 | 1 | 8 |
| ROT | 10 | 8 | 0 | 18 |
| RAS | 4 | 4 | 1 | 9 |
| OCO | 8 | 3 | 0 | 11 |
| FIN | 4 | 6 | 2 | 12 |
| NOT | 4 | 4 | 1 | 9 |
| REL | 4 | 3 | 2 | 9 |
| INT | 4 | 2 | 2 | 8 |
| AUD | 2 | 5 | 1 | 8 |
| **Total** | **102** | **66** | **16** | **184** |

> Sugestão: crie um *issue* por RF no seu backlog, com label de módulo e prioridade.
