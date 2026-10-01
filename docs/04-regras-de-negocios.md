# LogiFlow — Regras de Negócio (RN)

**Versão:** 1.0 · **Data:** 30/09/2026
**Formato do ID:** `RN-<ÁREA>-NN`.
Todos os valores numéricos (prazos, percentuais, limites) são **padrões iniciais** e devem ser implementados como **parâmetros configuráveis** (global, por empresa ou por contrato), salvo indicação contrária. Cada RN deve ter ao menos um teste automatizado nomeado com seu ID.

---

## 1. Regras Gerais e Multiempresa (GER)

| ID | Regra |
|---|---|
| RN-GER-01 | Todo dado de negócio pertence a exatamente uma empresa (tenant). Nenhum usuário de empresa lojista acessa dados de outra empresa. |
| RN-GER-02 | Usuários do tenant **operador** (a plataforma) acessam dados de todos os lojistas somente dentro das permissões do seu papel e sempre com registro de auditoria. |
| RN-GER-03 | Empresa **suspensa** não cria pedidos nem encomendas; consulta, rastreio e entregas já em curso continuam normalmente. |
| RN-GER-04 | CNPJ da empresa e CPF/CNPJ de destinatário devem ter dígitos verificadores válidos; CNPJ de empresa é único na plataforma. |
| RN-GER-05 | Valores monetários são em BRL, armazenados em centavos, arredondados "metade para cima" (*half-up*) na unidade de centavo ao final de cada cálculo composto. |
| RN-GER-06 | Pesos em gramas, dimensões em centímetros (inteiros ou 1 casa decimal), datas em UTC. Prazos são sempre expressos em **dias úteis**, salvo menção contrária. |
| RN-GER-07 | Dias úteis são de segunda a sexta, excluindo feriados do calendário. O sábado é dia útil apenas para serviços marcados como "entrega aos sábados". |
| RN-GER-08 | Registros de eventos de rastreio, movimentos de estoque, lançamentos financeiros e auditoria **nunca são alterados ou excluídos**; correções são feitas por novo registro compensatório. |
| RN-GER-09 | Exclusão de cadastros que já tenham movimentação é lógica (inativação), nunca física. |
| RN-GER-10 | Todo e-mail e telefone de destinatário é normalizado (minúsculas; E.164) antes de armazenar. |

## 2. Autenticação e Acesso (SEG)

| ID | Regra |
|---|---|
| RN-SEG-01 | A senha deve ter no mínimo 10 caracteres, com letras e números, e não pode constar em lista de senhas comuns. |
| RN-SEG-02 | Após 5 tentativas de login inválidas consecutivas, a conta é bloqueada por 15 minutos; o contador zera em login bem-sucedido. |
| RN-SEG-03 | O link de recuperação de senha é de uso único e expira em 30 minutos. O convite de usuário expira em 7 dias. |
| RN-SEG-04 | O *access token* expira em 15 minutos e o *refresh token* em 7 dias, sendo rotativo; o reuso de um *refresh token* já usado revoga toda a família de tokens da sessão. |
| RN-SEG-05 | Papéis iniciais: `SUPER_ADMIN`, `GESTOR`, `OPERADOR_EMPRESA`, `OPERADOR_HUB`, `DESPACHANTE`, `ROTEIRIZADOR`, `ENTREGADOR`, `FINANCEIRO`, `SUPORTE`. Cada papel tem permissões explícitas; o que não é permitido é negado. |
| RN-SEG-06 | `SUPER_ADMIN`, `GESTOR` e `FINANCEIRO` devem usar autenticação em dois fatores. |
| RN-SEG-07 | Chaves de API têm escopos (ex.: `pedidos:escrever`, `rastreio:ler`), ambiente (`live` ou `test`) e podem ser revogadas a qualquer momento. Chave `test` nunca acessa dados `live`. |
| RN-SEG-08 | Toda empresa deve ter ao menos um `GESTOR` ativo; o último gestor não pode ser desativado. |
| RN-SEG-09 | Ações sensíveis geram auditoria: alteração de tabela de frete, ajuste de estoque, cancelamento após separação, estorno, indenização, mudança de papel, geração/revogação de chave de API. |

## 3. Cadastros e Produtos (CAD)

| ID | Regra |
|---|---|
| RN-CAD-01 | O SKU é único por empresa e imutável após o primeiro uso em pedido. |
| RN-CAD-02 | Todo produto deve ter peso (> 0 g) e dimensões (> 0 cm) para ser elegível a cotação; produto sem esses dados fica "incompleto" e bloqueia a criação da encomenda. |
| RN-CAD-03 | Produto marcado como frágil, perigoso ou perecível aplica taxa adicional e restrições de serviço (ver RN-FRE-12 e RN-FRE-13). |
| RN-CAD-04 | Endereço de entrega exige CEP (8 dígitos), logradouro, número (ou "s/n"), bairro, cidade e UF; o CEP deve ser compatível com cidade/UF consultados. |
| RN-CAD-05 | Endereço cuja geocodificação tenha baixa precisão é marcado "a confirmar" e pode exigir validação do Roteirizador antes de entrar em rota. |
| RN-CAD-06 | Cada destinatário é identificado por documento (CPF/CNPJ) quando informado; sem documento, a identificação é por e-mail + telefone. |

## 4. Pedidos (PED)

| ID | Regra |
|---|---|
| RN-PED-01 | O par (`loja`, `numeroExterno`) é único. Reenvio do mesmo pedido retorna o existente (idempotência) sem duplicar. |
| RN-PED-02 | Um pedido deve ter ao menos 1 item, quantidade ≥ 1 por item e endereço de entrega válido. |
| RN-PED-03 | Estados do pedido: `PENDENTE_VALIDACAO` → `CONFIRMADO` → `EM_PROCESSAMENTO` → `CONCLUIDO` / `CANCELADO` / `PARCIALMENTE_CONCLUIDO`. Pedido com erro de endereço permanece em `PENDENTE_VALIDACAO`. |
| RN-PED-04 | Pedido `PENDENTE_VALIDACAO` por mais de 72 h é cancelado automaticamente e a loja é notificada. |
| RN-PED-05 | Edição do endereço/contato é permitida até o status de encomenda `EMBALADA`. Mudança de CEP exige nova cotação; se o preço mudar, a diferença é cobrada/creditada na fatura. |
| RN-PED-06 | Edição de itens (quantidade ou SKU) é permitida apenas até `AGUARDANDO_SEPARACAO`; depois disso, só por cancelamento e novo pedido. |
| RN-PED-07 | O pedido pode ser dividido em várias encomendas quando os itens estão em armazéns diferentes ou o peso/volume excede os limites do serviço (RN-FRE-04). Cada encomenda tem rastreio próprio e cobrança própria. |
| RN-PED-08 | O pedido é `CONCLUIDO` quando todas as suas encomendas estiverem em estado final (`ENTREGUE`, `DEVOLVIDA`, `CANCELADA`, `EXTRAVIADA`); `PARCIALMENTE_CONCLUIDO` quando há mistura de estados finais bem-sucedidos e não bem-sucedidos. |
| RN-PED-09 | O valor declarado do pedido é, por padrão, a soma dos itens; a loja pode informar valor declarado diferente, respeitando o limite da RN-FRE-09. |

## 5. Estoque (EST)

| ID | Regra |
|---|---|
| RN-EST-01 | O saldo disponível é `quantidade total − quantidade reservada`. O saldo total e o disponível **nunca podem ser negativos**. |
| RN-EST-02 | A reserva é feita ao confirmar o pedido (todos os itens ou nenhum). Sem saldo suficiente, o pedido fica `CONFIRMADO` com itens "sem estoque" (*backorder*) e a loja é notificada, conforme configuração. |
| RN-EST-03 | A reserva é liberada ao cancelar o pedido ou o item, ou quando a encomenda é cancelada antes da separação. |
| RN-EST-04 | A baixa física do estoque ocorre na **confirmação da separação** do item (leitura do código), transformando reserva em saída. |
| RN-EST-05 | A seleção de localização na separação segue FEFO (se lote/validade), senão FIFO (entrada mais antiga primeiro). |
| RN-EST-06 | Todo ajuste manual de estoque exige motivo (lista padronizada) e usuário; ajuste acima de 5% do saldo ou de 50 unidades exige aprovação de um `GESTOR`/supervisor. |
| RN-EST-07 | Recebimento com divergência (quantidade ≠ esperada) é registrado como "divergência" e só é endereçado após decisão (aceitar, devolver, ajustar). |
| RN-EST-08 | Durante inventário de uma localização, ela fica "bloqueada para movimentação" até o fechamento da contagem. |
| RN-EST-09 | Item devolvido só retorna ao estoque vendável após inspeção como "apto" (RN-DEV-06). |
| RN-EST-10 | Quando o saldo disponível ≤ estoque mínimo, gera-se alerta único por SKU até que o saldo volte a superar o mínimo. |
| RN-EST-11 | Reservas de pedidos não despachados por mais de 7 dias geram alerta de revisão ao Operador da empresa. |

## 6. Frete e Cotação (FRE)

| ID | Regra |
|---|---|
| RN-FRE-01 | **Peso cubado (kg)** do volume = (comprimento × largura × altura, em cm) ÷ 6000. O divisor é configurável por serviço. |
| RN-FRE-02 | **Peso taxável** do volume = maior valor entre o peso real e o cubado, arredondado para cima à próxima faixa de 100 g. O peso taxável da encomenda é a soma dos volumes. |
| RN-FRE-03 | O preço-base é obtido pela tabela vigente do contrato: (serviço, zona de destino, faixa de peso taxável). Acima da última faixa, aplica-se o valor da última faixa + valor adicional por kg excedente. |
| RN-FRE-04 | Limites padrão por volume: peso real ≤ 30 kg; maior lado ≤ 105 cm; soma (C+L+A) ≤ 200 cm. Excedendo, o volume é "especial/volumoso": só atendido por serviço que o aceite e com taxa própria (RN-FRE-12); caso contrário a cotação é recusada. |
| RN-FRE-05 | A zona de destino é determinada pelo CEP, usando a regra mais específica (faixa de CEP > cidade > UF). CEP sem zona cadastrada → serviço indisponível. |
| RN-FRE-06 | O prazo = prazo da zona + tempo de manuseio da origem (padrão 1 dia útil). Pedido confirmado após o **horário de corte** (padrão 14:00, fuso `America/Sao_Paulo`) ou em dia não útil conta a partir do próximo dia útil. |
| RN-FRE-07 | O serviço **Same-day** exige corte às 11:00, destino na região de cobertura do hub e peso ≤ 10 kg; o **Expresso** tem prazo máximo de 3 dias úteis na sua região; o **Econômico** é o padrão de menor preço. |
| RN-FRE-08 | Preço total = preço-base + seguro + taxas adicionais − descontos/promoções. Nunca negativo. Frete grátis zera apenas o preço-base e as taxas aplicáveis, mantendo o custo de seguro quando contratado. |
| RN-FRE-09 | **Seguro** = 0,5% do valor declarado, mínimo R$ 1,00. Valor declarado máximo por encomenda: R$ 10.000,00 (acima disso, requer aprovação do Financeiro e serviço especial). |
| RN-FRE-10 | Frete grátis/promocional é definido por empresa (valor mínimo do pedido, região, serviço, período). Quando há mais de uma promoção aplicável, vale a de **maior benefício** ao cliente; não se acumulam. |
| RN-FRE-11 | Toda tabela de frete tem vigência (início/fim) e versão. Alterar preços cria nova versão; encomendas já criadas mantêm o preço contratado (snapshot da cotação). |
| RN-FRE-12 | Taxas adicionais (valores padrão configuráveis): frágil +5% do preço-base; volumoso +20%; área remota +R$ 8,00; entrega agendada +R$ 6,00; devolução ao remetente = 100% do preço-base do trecho de ida. |
| RN-FRE-13 | Produtos perigosos, perecíveis e itens proibidos (lista configurável) não são aceitos nos serviços padrão; a criação da encomenda é bloqueada. |
| RN-FRE-14 | A cotação tem validade de 24 h e deve ser registrada junto à encomenda (preço, prazo, tabela e versão). Passado o prazo, a cotação é recalculada. |
| RN-FRE-15 | Se a transportadora/serviço escolhido ficar indisponível, o sistema pode **trocar automaticamente** por serviço equivalente apenas se o preço não aumentar e o prazo não piorar; caso contrário, solicita decisão do Operador. |

## 7. Encomendas e Rastreio (ENC)

| ID | Regra |
|---|---|
| RN-ENC-01 | **Código de rastreio:** `LF` + 9 dígitos + 1 dígito verificador (módulo 11) + `BR` (13 caracteres), único em toda a plataforma, gerado na criação e imutável. |
| RN-ENC-02 | Cada volume possui código de barras próprio derivado do rastreio e do número do volume (`<rastreio>-<NN>`). |
| RN-ENC-03 | Uma encomenda só pode ser criada se: pedido `CONFIRMADO`, endereço válido, produtos completos (RN-CAD-02), serviço disponível e empresa ativa. |
| RN-ENC-04 | **Transições permitidas** (qualquer outra é rejeitada): `CRIADA→AGUARDANDO_SEPARACAO→EM_SEPARACAO→SEPARADA→EMBALADA→AGUARDANDO_DESPACHO→DESPACHADA→EM_TRANSITO`; `EM_TRANSITO→NO_HUB`; `NO_HUB→EM_TRANSITO`; `NO_HUB→EM_ROTA`; `EM_ROTA→ENTREGUE`; `EM_ROTA→TENTATIVA_FALHA`; `TENTATIVA_FALHA→NO_HUB`; `TENTATIVA_FALHA→EM_DEVOLUCAO`; `NO_HUB→AGUARDANDO_RETIRADA`; `AGUARDANDO_RETIRADA→ENTREGUE`/`EM_DEVOLUCAO`; `EM_TRANSITO→ENTREGUE` (entrega por transportadora); `EM_DEVOLUCAO→DEVOLVIDA`; `EM_TRANSITO→EXTRAVIADA`; cancelamento de `CRIADA` até `SEPARADA`. |
| RN-ENC-05 | Cada transição gera, na mesma transação, um `EventoRastreio` e um evento de domínio (outbox). |
| RN-ENC-06 | Estados finais (`ENTREGUE`, `DEVOLVIDA`, `CANCELADA`, `EXTRAVIADA`) não admitem novas transições, exceto `EXTRAVIADA → (localizada) NO_HUB` mediante ação do Suporte com justificativa. |
| RN-ENC-07 | Eventos externos (transportadora) fora de ordem cronológica são aceitos e ordenados por `ocorridoEm`, mas só alteram o status atual se forem mais recentes que o último evento aplicado. |
| RN-ENC-08 | O evento de rastreio contém: tipo, descrição amigável, local, origem (sistema/usuário/transportadora), data/hora real do ocorrido e data/hora de registro. |
| RN-ENC-09 | A encomenda mantém `prazoPrevisto` calculado na criação; só é recalculado em reagendamento aprovado ou mudança de serviço. Encomenda com `agora > prazoPrevisto` e sem estado final é "atrasada". |
| RN-ENC-10 | Encomenda "sob risco de atraso" é aquela cujo tempo restante para o prazo é menor que o tempo médio histórico das etapas restantes. |
| RN-ENC-11 | **Cancelamento:** até `SEPARADA` — sem custo; `EMBALADA` até `AGUARDANDO_DESPACHO` — com taxa de manuseio (padrão R$ 3,00) e retorno do item ao estoque; a partir de `DESPACHADA` — não há cancelamento: aplica-se solicitação de devolução/interceptação, com custos. |
| RN-ENC-12 | O reagendamento de entrega é permitido até 2 vezes por encomenda, com nova data de até 10 dias úteis à frente e dentro da janela de operação do hub. |
| RN-ENC-13 | Encomendas com serviço de prioridade maior (Same-day > Expresso > Econômico) têm precedência em filas de separação, despacho e rota. |

## 8. Despacho e Expedição (DES)

| ID | Regra |
|---|---|
| RN-DES-01 | A ordem de separação segue: (1) serviço, (2) proximidade do horário de corte/SLA, (3) antiguidade. |
| RN-DES-02 | A separação só é concluída quando todos os itens da encomenda forem lidos (código) na quantidade correta. Leitura de item que não pertence à ordem é rejeitada. |
| RN-DES-03 | Falta de item na separação: o operador registra falta; o sistema tenta outra localização/armazém; persistindo a falta, a encomenda é pausada e a loja notificada (aguardar, enviar parcial ou cancelar o item). |
| RN-DES-04 | Na embalagem, o peso aferido é obrigatório. Se o peso aferido diferir do declarado em mais de 10% (ou 100 g, o que for maior), o frete é recalculado e a diferença lançada na fatura (RN-FIN-06). |
| RN-DES-05 | A etiqueta só é gerada após embalagem concluída. Reimpressão é permitida e registrada; a etiqueta antiga continua válida até o despacho e é invalidada se o volume for reembalado. |
| RN-DES-06 | Um volume só pode constar em **um** manifesto aberto por vez. |
| RN-DES-07 | O manifesto só pode ser **fechado** após a conferência de 100% dos volumes por leitura; divergências são tratadas antes (retirar do manifesto ou localizar o volume). |
| RN-DES-08 | O fechamento do manifesto muda todas as encomendas para `DESPACHADA`, gera o evento de rastreio "Objeto despachado" e torna o manifesto imutável. |
| RN-DES-09 | Volumes não despachados até o fim do dia útil permanecem em `AGUARDANDO_DESPACHO` e geram alerta de "perda de corte" ao Despachante. |
| RN-DES-10 | A coleta agendada no lojista tem janela mínima de 2 h; cada empresa tem limite de coletas por dia conforme contrato. |

## 9. Transportadoras e Hubs (TRA/HUB)

| ID | Regra |
|---|---|
| RN-TRA-01 | A escolha automática de transportadora considera, nesta ordem: serviço contratado → cobertura do CEP → restrições de peso/dimensão → menor custo dentro do prazo prometido → melhor desempenho histórico. |
| RN-TRA-02 | Transportadora com taxa de entrega no prazo < 85% nos últimos 30 dias entra em "observação" e perde prioridade na seleção automática. |
| RN-TRA-03 | Eventos de transportadoras são traduzidos para o catálogo interno de eventos; evento desconhecido gera registro "não mapeado" e alerta, sem alterar o status. |
| RN-HUB-01 | Cada CEP de destino pertence a um único hub de última milha (cobertura sem sobreposição); áreas de cobertura sobrepostas devem ter regra de desempate (menor distância). |
| RN-HUB-02 | O recebimento no hub exige leitura de cada volume; volume lido que não estava no manifesto é "excedente" e deve ser tratado como divergência. |
| RN-HUB-03 | Volume faltante no recebimento gera ocorrência automática de divergência e inicia a busca (prazo de 48 h) antes de se presumir extravio. |
| RN-HUB-04 | Volume aguardando retirada é guardado por até 7 dias corridos; no 5º dia o destinatário é notificado; ao fim do prazo, inicia-se a devolução. |
| RN-HUB-05 | Volumes unitizados (gaiola/contêiner) só são abertos no hub de destino; o evento da unidade se propaga a todos os volumes contidos. |

## 10. Rotas e Entrega (ROT)

| ID | Regra |
|---|---|
| RN-ROT-01 | Uma rota pertence a um único hub e a uma única data; contém no máximo 80 paradas (parâmetro) e respeita capacidade de peso e volume do veículo (com folga de 5%). |
| RN-ROT-02 | Um entregador só pode ter uma rota **em andamento** por vez; um veículo não pode estar em duas rotas com horários sobrepostos. |
| RN-ROT-03 | O entregador deve ter cadastro ativo, documento válido e CNH compatível com a categoria do veículo (ex.: A para moto, B para carro/van leve). Documento vencido bloqueia a atribuição. |
| RN-ROT-04 | Veículo em manutenção ou inativo não pode ser atribuído. |
| RN-ROT-05 | Encomendas na mesma rota com o mesmo endereço (mesmo destinatário) são agrupadas em uma única parada. |
| RN-ROT-06 | Só entram em rota encomendas em `NO_HUB`, com endereço validado, janela de entrega compatível e sem pendência de ocorrência bloqueante. |
| RN-ROT-07 | A rota só pode ser iniciada após a **conferência de carga** (100% dos volumes lidos no carregamento). Volume não carregado é retirado da rota e volta a `NO_HUB`. |
| RN-ROT-08 | Ao iniciar a rota, todas as encomendas passam a `EM_ROTA` e o destinatário é notificado "saiu para entrega". |
| RN-ROT-09 | A ordem das paradas é sugerida pelo sistema, mas o entregador/roteirizador pode alterá-la; toda alteração é registrada. Entregas Same-day e com janela estrita têm prioridade na ordenação. |
| RN-ROT-10 | Encerrar a rota exige que todas as paradas estejam resolvidas (entregue ou falha); volumes não entregues devem ser devolvidos e conferidos no hub, e a rota só fecha após essa conferência. Diferença gera ocorrência. |
| RN-ROT-11 | A posição do entregador é registrada a cada 30 s apenas com a rota em andamento; fora da rota, nenhuma coleta de localização. |
| RN-ROT-12 | Rotas planejadas e não iniciadas até 2 h após o horário previsto geram alerta ao Roteirizador. |

## 11. Entrega, Tentativas e POD (ENT)

| ID | Regra |
|---|---|
| RN-ENT-01 | Comprovante de entrega (POD) obrigatório: **código de confirmação** do destinatário (4 dígitos enviado por notificação) **ou** assinatura **ou** foto do local/recebedor, além do nome do recebedor. |
| RN-ENT-02 | Para valor declarado ≥ R$ 500,00 exige-se foto **e** nome com documento (últimos 3 dígitos do CPF). Para itens com "entrega restrita ao titular", exige-se documento do próprio destinatário. |
| RN-ENT-03 | A entrega só pode ser registrada a até 300 m do endereço geocodificado; fora disso exige justificativa e fica marcada para revisão. |
| RN-ENT-04 | **Motivos padronizados de falha:** destinatário ausente, endereço não localizado, endereço insuficiente, recusa do recebedor, estabelecimento fechado, área de risco, falta de tempo na rota, avaria constatada. Evidência (foto) obrigatória para "ausente", "recusa" e "área de risco". |
| RN-ENT-05 | Após tentativa falha, a próxima tentativa ocorre no **próximo dia útil**, salvo reagendamento. O destinatário é notificado a cada falha. |
| RN-ENT-06 | Máximo de **3 tentativas** de entrega. Esgotadas, a encomenda segue para `EM_DEVOLUCAO`. Falhas por "falta de tempo na rota" ou "área de risco" **não** contam como tentativa. |
| RN-ENT-07 | "Endereço insuficiente/não localizado" abre ocorrência e pausa a encomenda até correção pela loja ou destinatário (prazo de 5 dias úteis; após, devolução). |
| RN-ENT-08 | "Recusa do recebedor" inicia devolução imediata, sem novas tentativas. |
| RN-ENT-09 | O código de confirmação expira com a rota; um novo é gerado em nova tentativa. |
| RN-ENT-10 | Avaria constatada na entrega impede a conclusão normal: abre ocorrência `AVARIA`, o recebedor pode recusar, e o volume é devolvido ao hub com fotos. |

## 12. Ocorrências (OCO)

| ID | Regra |
|---|---|
| RN-OCO-01 | Tipos de ocorrência: `AVARIA`, `EXTRAVIO`, `ENDERECO_INSUFICIENTE`, `DIVERGENCIA`, `RECUSA`, `ATRASO`, `FALTA_ITEM`, `OUTROS`. |
| RN-OCO-02 | Abertura automática: tentativas esgotadas; divergência de recebimento; encomenda atrasada há mais de 2 dias úteis do prazo; ausência de eventos por 5 dias úteis em trânsito; "endereço insuficiente". |
| RN-OCO-03 | SLA de tratamento (padrão): crítica 4 h (extravio, avaria de alto valor), normal 24 h, baixa 72 h. Estouro do SLA escala para o supervisor e é indicador. |
| RN-OCO-04 | Uma encomenda pode ter várias ocorrências; ocorrências **bloqueantes** (extravio, endereço insuficiente, avaria) impedem entrada em rota até a resolução. |
| RN-OCO-05 | Ocorrência só é encerrada com **resolução** (reentrega, correção, devolução, indenização, improcedente) e comentário obrigatório. |
| RN-OCO-06 | **Extravio:** sem evento por 15 dias corridos em trânsito → "suspeita de extravio"; após 30 dias, ou localização impossível confirmada → `EXTRAVIADA` e liberação de indenização. |

## 13. Devoluções e Logística Reversa (DEV)

| ID | Regra |
|---|---|
| RN-DEV-01 | Motivos: arrependimento (até 7 dias corridos do recebimento, conforme CDC), defeito/avaria, produto errado, recusa na entrega, tentativas esgotadas, endereço não localizado. |
| RN-DEV-02 | A devolução gera uma **encomenda reversa** vinculada à original, com código de rastreio próprio e fluxo invertido (coleta → hub → origem). |
| RN-DEV-03 | Custo da reversa: assumido pela loja em arrependimento, defeito e produto errado; por quem deu causa nos demais casos. O custo é lançado na fatura da empresa. |
| RN-DEV-04 | Devolução por tentativas esgotadas ou recusa retorna ao remetente com cobrança de 100% do preço-base do trecho de ida (RN-FRE-12). |
| RN-DEV-05 | A devolução recebida no hub é obrigatoriamente **inspecionada** e classificada como: `APTO`, `AVARIADO` ou `DESCARTE`, com fotos quando não apto. |
| RN-DEV-06 | Somente itens `APTO` reentram no estoque vendável; `AVARIADO` vai para quarentena; `DESCARTE` gera baixa com motivo. |
| RN-DEV-07 | A conclusão da devolução (encomenda reversa `DEVOLVIDA` + inspeção) emite evento à loja para que ela estorne/reembolse o cliente; o LogiFlow não processa o reembolso financeiro da venda. |
| RN-DEV-08 | Encomenda original `DEVOLVIDA` não pode ser devolvida novamente. |

## 14. Indenização (IND)

| ID | Regra |
|---|---|
| RN-IND-01 | Elegível em caso de extravio, avaria total/parcial ou roubo atribuível à operação, com ocorrência aberta e evidências. |
| RN-IND-02 | Valor = menor entre (valor declarado dos itens afetados + frete pago) e o limite contratual; sem seguro contratado, limite de 10 × o frete pago, máximo R$ 500,00. |
| RN-IND-03 | A solicitação deve ser feita em até 90 dias corridos após a data prevista de entrega. |
| RN-IND-04 | Indenização acima de R$ 1.000,00 exige aprovação em dois níveis (Suporte → Financeiro/Gestor da plataforma). |
| RN-IND-05 | A indenização aprovada gera crédito na fatura da empresa (estorno de frete + valor da mercadoria), nunca pagamento externo automático. |
| RN-IND-06 | Item indenizado por avaria, quando recuperado, volta ao fluxo de inspeção; item extraviado e posteriormente localizado exige devolução/ajuste do crédito. |

## 15. Financeiro (FIN)

| ID | Regra |
|---|---|
| RN-FIN-01 | Cada encomenda gera lançamentos separados de **receita** (frete, seguro, taxas) e **custo** (transportadora/operação). O lançamento de receita é efetivado no **despacho**; no cancelamento anterior ao despacho, não há cobrança. |
| RN-FIN-02 | Lançamentos são imutáveis; correções são feitas por estorno + novo lançamento, com referência ao original. |
| RN-FIN-03 | Ciclos de faturamento: semanal (fechamento na segunda-feira), quinzenal (dias 1 e 16) ou mensal (dia 1), definido no contrato. O fechamento considera lançamentos até 23:59:59 do dia anterior. |
| RN-FIN-04 | Vencimento da fatura: 7 dias corridos após o fechamento. Atraso: multa de 2% + juros de 1% ao mês *pro rata die*. |
| RN-FIN-05 | Fatura fechada é imutável; ajustes posteriores entram na próxima fatura. |
| RN-FIN-06 | Cobranças adicionais (diferença de peso, devolução, reentrega, redespacho, taxa de cancelamento) devem referenciar a encomenda e o motivo, sendo itemizadas na fatura. |
| RN-FIN-07 | Fatura vencida há 15 dias bloqueia novas encomendas da empresa (RN-GER-03 parcial: bloqueio de criação), exceto devoluções e entregas em andamento. Pagamento libera o bloqueio automaticamente. |
| RN-FIN-08 | Conciliação: se o custo cobrado pela transportadora divergir do esperado em mais de 3% ou R$ 2,00, gera pendência de conciliação. |
| RN-FIN-09 | **Margem** = receita − custo (transportadora + repasse de entregador + taxas). Margem negativa por encomenda é sinalizada em relatório. |
| RN-FIN-10 | **Repasse do entregador (padrão):** valor fixo por entrega concluída, mais adicional por quilômetro; tentativa falha válida paga 50% do valor da entrega; fechamento semanal. Valores definidos por hub/veículo. |
| RN-FIN-11 | No modelo pré-pago, a encomenda só é criada se houver saldo suficiente; o valor é debitado no despacho. |

## 16. Notificações e Webhooks (NOT)

| ID | Regra |
|---|---|
| RN-NOT-01 | Notificações obrigatórias ao destinatário: despachada, saiu para entrega, entregue, tentativa falha, aguardando retirada. Demais são opcionais por configuração da empresa. |
| RN-NOT-02 | Não enviar SMS/WhatsApp entre 20:00 e 08:00 (exceto "saiu para entrega" dentro da janela da rota) nem a quem tiver feito opt-out. |
| RN-NOT-03 | A mesma notificação (evento + destinatário + canal) não pode ser enviada duas vezes (deduplicação). |
| RN-NOT-04 | Webhooks de saída: tentativas em 1 min, 5 min, 30 min, 2 h, 6 h e 24 h; resposta 2xx = sucesso; demais = falha. |
| RN-NOT-05 | Endpoint com 50 falhas consecutivas é desativado automaticamente e o Gestor é notificado. |
| RN-NOT-06 | Os eventos de um mesmo recurso devem ser entregues em ordem de ocorrência por endpoint; o receptor deve usar o `id` do evento para idempotência. |
| RN-NOT-07 | Assinatura: `HMAC-SHA256(segredo, timestamp + "." + corpo)`; requisições com mais de 5 min de diferença devem ser rejeitadas pelo receptor. |

## 17. Rastreio Público e Privacidade (RAS/PRI)

| ID | Regra |
|---|---|
| RN-RAS-01 | A página pública exibe: status, linha do tempo, previsão, cidade/UF dos eventos e dados da loja. **Não exibe** CPF, telefone, e-mail, endereço completo ou nome completo (apenas primeiro nome e inicial). |
| RN-RAS-02 | O mapa de posição do entregador só é exibido quando a encomenda está `EM_ROTA` e a ≤ 10 paradas do destino, com posição suavizada (arredondada a ~100 m). |
| RN-RAS-03 | Eventos internos sensíveis (ex.: divergência, comentários internos, ocorrência de risco) não aparecem no rastreio público; apenas um evento público equivalente. |
| RN-RAS-04 | Consultas por pedido + e-mail/CPF parcial têm limite de 10 tentativas/hora por IP. |
| RN-PRI-01 | Dados pessoais de destinatário são anonimizados 24 meses após a conclusão da encomenda, mantendo dados agregados e fiscais. |
| RN-PRI-02 | Atender solicitação de titular (acesso/eliminação) em até 15 dias, registrando a execução em auditoria; dados sob obrigação legal/fiscal não são eliminados. |
| RN-PRI-03 | O entregador visualiza apenas as informações necessárias à entrega (nome, endereço, telefone mascarável com chamada via app) pela duração da rota. |

## 18. Indicadores e Cálculos (KPI)

| ID | Definição |
|---|---|
| RN-KPI-01 | **OTIF (entregue no prazo)** = encomendas `ENTREGUE` com `entregueEm ≤ prazoPrevisto` ÷ total de encomendas entregues no período. |
| RN-KPI-02 | **Sucesso na 1ª tentativa** = entregas concluídas na 1ª tentativa ÷ total de encomendas que saíram para rota. |
| RN-KPI-03 | **Taxa de devolução** = encomendas `DEVOLVIDA` ÷ encomendas despachadas no período. |
| RN-KPI-04 | **Lead time** = `entregueEm − criadaEm`, com decomposição por etapa (separação, despacho, trânsito, última milha). |
| RN-KPI-05 | **Custo por entrega** = (custos totais atribuídos) ÷ (entregas concluídas). |
| RN-KPI-06 | **Taxa de ocorrência** = encomendas com ≥ 1 ocorrência ÷ total de encomendas. |
| RN-KPI-07 | Indicadores são calculados em dias corridos de calendário `America/Sao_Paulo`, sempre vinculados ao evento (data) de referência e ao filtro de período declarado. |

---

## Apêndice A — Catálogo de eventos de rastreio (públicos)

| Código | Texto público (exemplo) |
|---|---|
| `PEDIDO_RECEBIDO` | Pedido recebido pela transportadora |
| `EM_SEPARACAO` | Seu pedido está sendo separado |
| `EMBALADO` | Pedido embalado e etiquetado |
| `DESPACHADO` | Objeto despachado |
| `EM_TRANSITO` | Objeto em trânsito — de {origem} para {destino} |
| `CHEGOU_HUB` | Objeto chegou ao centro de distribuição {cidade/UF} |
| `SAIU_ENTREGA` | Objeto saiu para entrega ao destinatário |
| `TENTATIVA_FALHA` | Não foi possível entregar: {motivo público} |
| `AGUARDANDO_RETIRADA` | Objeto aguardando retirada em {local} |
| `ENTREGUE` | Objeto entregue ao destinatário |
| `EM_DEVOLUCAO` | Objeto em devolução ao remetente |
| `DEVOLVIDO` | Objeto devolvido ao remetente |
| `EXTRAVIADO` | Objeto não localizado — ocorrência aberta |
| `CANCELADO` | Envio cancelado |

## Apêndice B — Exemplo de cálculo de frete (para testes)

Dados: 1 volume 40 × 30 × 20 cm, peso real 2,3 kg; destino zona B; serviço Econômico; valor declarado R$ 300,00; produto frágil.

1. Peso cubado = (40 × 30 × 20) ÷ 6000 = **4,0 kg**.
2. Peso taxável = máx(2,3; 4,0) = **4,0 kg** → faixa 2–5 kg.
3. Preço-base (tabela fictícia, faixa 2–5 kg, zona B) = R$ 24,00.
4. Frágil = +5% do preço-base = R$ 1,20.
5. Seguro = 0,5% × 300,00 = R$ 1,50.
6. **Total = 24,00 + 1,20 + 1,50 = R$ 26,70.**
7. Prazo: zona B = 4 dias úteis + manuseio 1 dia = **5 dias úteis** (contados a partir do próximo dia útil se confirmado após as 14:00).
