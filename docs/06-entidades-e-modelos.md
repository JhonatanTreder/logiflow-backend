# LogiFlow — Entidades e Modelos (campos)

**Versão:** 1.2 · **Data:** 10/10/2026
Este documento lista **apenas os campos** de cada entidade. Relacionamentos, índices e regras de negócio estão nos documentos 01 (seção 7) e 04.

## Convenções

| Item | Padrão |
|---|---|
| Opcional | Tipo com `?` (ex.: `String?`). Sem `?` = obrigatório. |
| `id` | `UUID` (v7 ou equivalente) em todas as entidades; omitido nas tabelas abaixo. |
| `createdAt`, `updatedAt` | `DateTime` (UTC) em todas as entidades; omitidos nas tabelas. Entidades **imutáveis** (append-only) têm só `createdAt` e estão marcadas com 🔒. |
| `tenantId` | `UUID`, presente em toda entidade de **escopo tenant**; indicado no cabeçalho de cada entidade. Em tabelas filhas, o escopo é herdado do pai. |
| Dinheiro | `Int` em **centavos** (sufixo `Centavos`). |
| Peso / dimensões | Peso `Int` em **gramas** (`G`); dimensões `Decimal(6,1)` em **cm**. |
| Coordenadas | `Decimal(9,6)` (`latitude`, `longitude`). |
| CEP | `String` com 8 dígitos, sem hífen. |
| Tabelas no banco | `snake_case` no plural (via `@@map`); campos em `camelCase` no modelo. |

Legenda de escopo: **Tenant** = pertence a um tenant (`tenantId`) · **Tenant administrador** = pertence ao tenant que administra o armazém · **Via armazém** = herda o administrador do armazém/hub ao qual se liga, sem `tenantId` próprio · **Global** = compartilhado.

---

## 1. Acesso e Empresas · Fase 1

### Tenant (Global) — empresa
| Campo | Tipo | Observação |
|---|---|---|
| tipo | TipoTenant | `OPERADOR_LOGISTICO` ou `LOJISTA`. Descreve o papel da empresa na plataforma; administrar um armazém é relacionamento (`Armazem.tenantId`), não tipo |
| razaoSocial | String | |
| nomeFantasia | String? | |
| cnpj | String | Único; somente os 14 dígitos (sem máscara); formato validado na aplicação |
| status | StatusTenant | `ATIVO`, `INATIVO`, `BLOQUEADO`; padrão `ATIVO` |
| contatoEmail | String | |
| contatoTelefone | String | |
| cicloFaturamento | CicloFaturamento? | **Fase 7.** Só `LOJISTA`; nulo no operador logístico. Valores a definir (RN-FIN-03 prevê `SEMANAL`, `QUINZENAL`, `MENSAL`) |
| modeloCobranca | ModeloCobranca? | **Fase 7.** `FATURA`, `PRE_PAGO`; só `LOJISTA` |
| saldoPrePagoCentavos | Int | **Fase 7.** Padrão 0 |
| horarioCorte | String? | **Fase 2.** `HH:mm`, padrão `14:00`; usado no cálculo de prazo (RN-FRE-06), e não no faturamento |
| configuracoes | Json | **Fase 2.** Padrão `{}`; frete grátis, seguro automático, remetente nas etiquetas, branding |

> A primeira migration (Fase 1) contém apenas: `tipo`, `razaoSocial`, `nomeFantasia`, `cnpj`, `status`, `contatoEmail`, `contatoTelefone` e os campos de controle.

### Loja (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| nome | String | Único por tenant |
| dominio | String? | |
| enderecoOrigemId | UUID | → Endereco |
| ativa | Boolean | |

### Usuario (Tenant) — no schema Prisma o model chama-se `User` (tabela `users`)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| nome | String | |
| email | String | Único por tenant (`tenantId` + `email`) |
| senhaHash | String | Argon2id |
| papel | Papel | Padrão `USER` (sem permissões) |
| status | StatusUsuario | `ATIVO`, `INATIVO`, `CONVIDADO`, `BLOQUEADO` |
| totpAtivo | Boolean | |
| totpSecretCifrado | String? | |
| tentativasFalhas | Int | Zera no login válido |
| bloqueadoAte | DateTime? | |
| ultimoAcessoEm | DateTime? | |

### Sessao (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| usuarioId | UUID | |
| familiaId | UUID | Agrupa a rotação de refresh tokens |
| refreshTokenHash | String | |
| ip | String | |
| userAgent | String? | |
| expiraEm | DateTime | |
| ultimoUsoEm | DateTime | |
| revogadaEm | DateTime? | |

### TokenUsoUnico (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| usuarioId | UUID | |
| tipo | TipoToken | `RECUPERACAO_SENHA`, `CONVITE` |
| tokenHash | String | |
| expiraEm | DateTime | |
| usadoEm | DateTime? | |

### ApiKey (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| nome | String | |
| prefixo | String | Parte visível (ex.: `lf_live_ab12`) |
| hash | String | Chave nunca guardada em claro |
| ambiente | Ambiente | `LIVE`, `TEST`. **Decisão pendente:** só é necessário se sandbox e produção dividirem a mesma instalação e o mesmo banco (RN-SEG-07) |
| escopos | String[] | Ex.: `pedidos:escrever` |
| ultimoUsoEm | DateTime? | |
| revogadaEm | DateTime? | |

### RecursoTenant (Global) — recursos habilitados (painel de permissões)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | Tenant que recebe o recurso |
| recurso | RecursoPlataforma | `ADMINISTRAR_ARMAZEM`, `SO_TRANSPORTE`, `COBRAR_ARMAZENAGEM` |
| concedidoPorId | UUID | Usuário `ADMIN` |
| revogadoEm | DateTime? | Nulo = recurso ativo; um recurso ativo por tenant |

---

## 2. Cadastros base · Fase 1

### Endereco (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| cep | String | |
| logradouro | String | |
| numero | String | `s/n` permitido |
| complemento | String? | |
| bairro | String | |
| cidade | String | |
| uf | String | 2 letras |
| codigoIbge | String? | |
| latitude | Decimal? | |
| longitude | Decimal? | |
| precisaoGeo | PrecisaoGeo | `ALTA`, `MEDIA`, `BAIXA`, `NAO_GEOCODIFICADO` |
| validado | Boolean | |
| aConfirmar | Boolean | Marcado quando a geocodificação é imprecisa |

### Destinatario (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| nome | String | |
| documento | String? | CPF/CNPJ validado |
| email | String? | Minúsculas |
| telefone | String? | E.164 |
| anonimizadoEm | DateTime? | LGPD |

### Produto (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| sku | String | Único por tenant (`tenantId` + `sku`) |
| nome | String | |
| descricao | String? | |
| codigoBarras | String? | |
| produtoPaiId | UUID? | Agrupa variações |
| pesoG | Int? | Obrigatório para ficar "completo" |
| alturaCm | Decimal? | |
| larguraCm | Decimal? | |
| comprimentoCm | Decimal? | |
| valorCentavos | Int | |
| fragil | Boolean | |
| perigoso | Boolean | |
| perecivel | Boolean | |
| controlaLote | Boolean | |
| estoqueMinimo | Int | Padrão 0 |
| ativo | Boolean | |

### Armazem (Tenant administrador) — armazém e hub
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | Tenant **administrador** (único); define estrutura e acessos (RN-ARM-01) |
| nome | String | |
| codigo | String | Único |
| tipo | TipoArmazem | `ARMAZEM`, `HUB_COLETA`, `HUB_TRIAGEM`, `HUB_ULTIMA_MILHA` |
| enderecoId | UUID | |
| capacidadeVolumes | Int? | |
| horarioFuncionamento | Json | |
| ativo | Boolean | |

### CoberturaHub (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| hubId | UUID | → Armazem |
| cepInicio | String | |
| cepFim | String | |

### Localizacao (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| armazemId | UUID | |
| codigo | String | Único por armazém |
| corredor | String | |
| prateleira | String | |
| nivel | String | |
| posicao | String? | |
| bloqueada | Boolean | Durante inventário |

### AcessoArmazem (Tenant) — vínculo de tenants ao armazém · Fase 3
| Campo | Tipo | Observação |
|---|---|---|
| armazemId | UUID | |
| tenantId | UUID | Tenant autorizado a usar o armazém |
| nivel | NivelAcessoArmazem | `DEPOSITANTE`; `OPERADOR` reservado (RN-ARM-07) |
| status | StatusAcesso | `ATIVO`, `SUSPENSO` |
| tabelaArmazenagemId | UUID? | Tabela de armazenagem aplicada ao depositante (Fase 7) |
| concedidoPorId | UUID | Usuário do administrador que concedeu |

> Único por (`armazemId`, `tenantId`). O administrador **não** aparece aqui: ele é o `Armazem.tenantId`.

---

## 3. Estoque · Fase 3

### SaldoEstoque (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| produtoId | UUID | |
| localizacaoId | UUID | |
| lote | String? | |
| validade | Date? | |
| quantidade | Int | `CHECK` ≥ 0 |
| reservada | Int | `CHECK` ≥ 0 e ≤ `quantidade` |

### MovimentoEstoque 🔒 (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | **Dono do estoque** movimentado (RN-ARM-06) |
| produtoId | UUID | |
| localizacaoId | UUID? | |
| tipo | TipoMovimento | |
| quantidade | Int | |
| motivo | String | Lista padronizada |
| referenciaTipo | String? | Ex.: `PEDIDO`, `RECEBIMENTO` |
| referenciaId | UUID? | |
| usuarioId | UUID | Quem executou; pode ser de outro tenant (administrador do armazém) |
| aprovadoPorId | UUID? | Ajustes grandes |

### RecebimentoMercadoria (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| armazemId | UUID | |
| avisoReferencia | String? | ASN |
| status | StatusRecebimento | `ABERTO`, `CONFERIDO`, `ENDERECADO`, `COM_DIVERGENCIA` |
| criadoPorId | UUID | |
| concluidoEm | DateTime? | |

### ItemRecebimento
| Campo | Tipo | Observação |
|---|---|---|
| recebimentoId | UUID | |
| produtoId | UUID | |
| quantidadeEsperada | Int? | |
| quantidadeConferida | Int | |
| lote | String? | |
| validade | Date? | |
| divergencia | Boolean | |

### InventarioContagem (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| armazemId | UUID | |
| localizacaoId | UUID? | |
| produtoId | UUID | |
| quantidadeSistema | Int | |
| quantidadeContada | Int | |
| status | StatusInventario | `ABERTA`, `AJUSTADA`, `FECHADA` |
| aprovadoPorId | UUID? | |

---

## 4. Pedidos e Frete · Fase 2

### Pedido (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| lojaId | UUID | |
| numeroExterno | String | Único por loja |
| origem | OrigemPedido | `API`, `CSV`, `MANUAL` |
| status | StatusPedido | |
| destinatarioId | UUID | |
| enderecoEntregaId | UUID | |
| valorProdutosCentavos | Int | |
| valorDeclaradoCentavos | Int | |
| observacoes | String? | |
| canceladoEm | DateTime? | |
| motivoCancelamento | String? | |

### ItemPedido
| Campo | Tipo | Observação |
|---|---|---|
| pedidoId | UUID | |
| produtoId | UUID | |
| quantidade | Int | ≥ 1 |
| valorUnitarioCentavos | Int | |
| situacaoEstoque | SituacaoEstoqueItem | `RESERVADO`, `BACKORDER`, `SEPARADO`, `CANCELADO` |

### Contrato (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| nome | String | |
| vigenciaInicio | Date | |
| vigenciaFim | Date? | |
| ativo | Boolean | |

### ContratoServico
| Campo | Tipo | Observação |
|---|---|---|
| contratoId | UUID | |
| servicoId | UUID | |
| tabelaFreteId | UUID | |
| seguroPercentualBp | Int | Pontos-base (0,5% = 50) |
| seguroMinimoCentavos | Int | Padrão 100 |
| valorDeclaradoMaxCentavos | Int | Padrão 1.000.000 |

### ServicoEntrega (Global)
| Campo | Tipo | Observação |
|---|---|---|
| codigo | CodigoServico | `ECONOMICO`, `EXPRESSO`, `SAME_DAY`, `RETIRADA` |
| nome | String | |
| modal | Modal | `PROPRIO`, `TRANSPORTADORA` |
| transportadoraId | UUID? | |
| prazoBaseDiasUteis | Int | |
| divisorCubagem | Int | Padrão 6000 |
| horaCorte | String? | `HH:mm` |
| entregaSabado | Boolean | |
| pesoMaxVolumeG | Int | Padrão 30000 |
| maiorLadoMaxCm | Int | Padrão 105 |
| somaDimensoesMaxCm | Int | Padrão 200 |
| ativo | Boolean | |

### ZonaFrete (Global)
| Campo | Tipo | Observação |
|---|---|---|
| codigo | String | Único (ex.: `A`, `B`) |
| nome | String | |

### ZonaFreteRegra
| Campo | Tipo | Observação |
|---|---|---|
| zonaId | UUID | |
| tipo | TipoRegraZona | `FAIXA_CEP`, `CIDADE`, `UF` |
| cepInicio | String? | |
| cepFim | String? | |
| cidade | String? | |
| uf | String? | |

### TabelaFrete (Global)
| Campo | Tipo | Observação |
|---|---|---|
| servicoId | UUID | |
| nome | String | |
| versao | Int | Cada alteração gera nova versão |
| vigenciaInicio | Date | |
| vigenciaFim | Date? | |
| adicionalKgExcedenteCentavos | Int | Acima da última faixa |
| ativa | Boolean | |

### FaixaPreco
| Campo | Tipo | Observação |
|---|---|---|
| tabelaFreteId | UUID | |
| zonaId | UUID | |
| pesoMinG | Int | |
| pesoMaxG | Int | |
| precoCentavos | Int | |
| prazoDiasUteis | Int | |

### TaxaAdicional
| Campo | Tipo | Observação |
|---|---|---|
| tabelaFreteId | UUID | |
| tipo | TipoTaxa | `FRAGIL`, `VOLUMOSO`, `AREA_REMOTA`, `AGENDADA`, `MANUSEIO_CANCELAMENTO` |
| modo | ModoTaxa | `PERCENTUAL_BP`, `FIXO_CENTAVOS` |
| valor | Int | |

### PromocaoFrete (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| nome | String | |
| valorMinimoPedidoCentavos | Int? | |
| uf | String? | |
| zonaId | UUID? | |
| servicoId | UUID? | |
| tipoDesconto | TipoDesconto | `FRETE_GRATIS`, `PERCENTUAL_BP`, `FIXO_CENTAVOS` |
| valorDesconto | Int? | |
| vigenciaInicio | Date | |
| vigenciaFim | Date? | |
| ativa | Boolean | |

### Feriado (Global)
| Campo | Tipo | Observação |
|---|---|---|
| data | Date | |
| nome | String | |
| abrangencia | AbrangenciaFeriado | `NACIONAL`, `UF`, `MUNICIPAL` |
| uf | String? | |
| cidade | String? | |

### Cotacao (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| cepDestino | String | |
| volumes | Json | Dimensões e pesos usados |
| valorDeclaradoCentavos | Int | |
| resultado | Json | Serviços, preços, prazos |
| referenciasTabela | Json | Tabelas e versões aplicadas (snapshot) |
| expiraEm | DateTime | 24 h |

---

## 5. Encomendas e Rastreio · Fase 2

### Encomenda (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| pedidoId | UUID | |
| tipo | TipoEncomenda | `ENVIO`, `REVERSA` |
| encomendaOrigemId | UUID? | Preenchido na reversa |
| codigoRastreio | String | Único global e imutável |
| codigoRastreioExterno | String? | Transportadora |
| servicoId | UUID | |
| transportadoraId | UUID? | |
| cotacaoId | UUID | |
| status | StatusEncomenda | |
| prioridade | Int | Derivada do serviço |
| tipoOrigem | TipoOrigemEncomenda | `ARMAZEM` ou `COLETA_NA_ORIGEM` (recurso `SO_TRANSPORTE`) |
| armazemOrigemId | UUID? | Nulo em coleta na origem |
| enderecoOrigemId | UUID? | Endereço da loja, em coleta na origem |
| hubDestinoId | UUID? | |
| destinatarioId | UUID | |
| enderecoEntregaId | UUID | |
| pesoRealG | Int | |
| pesoTaxavelG | Int | |
| freteCentavos | Int | |
| seguroCentavos | Int | |
| taxasCentavos | Int | |
| descontoCentavos | Int | |
| totalCentavos | Int | |
| valorDeclaradoCentavos | Int | |
| prazoPrevisto | DateTime | |
| entregaRestritaTitular | Boolean | |
| reagendamentos | Int | Máx. 2 |
| tentativasEntrega | Int | Máx. 3 |
| entregueEm | DateTime? | |
| canceladaEm | DateTime? | |
| observacoes | String? | |

### ItemEncomenda
| Campo | Tipo | Observação |
|---|---|---|
| encomendaId | UUID | |
| itemPedidoId | UUID | |
| quantidade | Int | |

### Volume
| Campo | Tipo | Observação |
|---|---|---|
| encomendaId | UUID | |
| numero | Int | |
| codigoBarras | String | Único (`<rastreio>-<NN>`) |
| pesoDeclaradoG | Int | |
| pesoAferidoG | Int? | |
| alturaCm | Decimal | |
| larguraCm | Decimal | |
| comprimentoCm | Decimal | |
| unidadeConsolidadaId | UUID? | Gaiola/contêiner |

### EventoRastreio 🔒 (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| encomendaId | UUID | |
| codigo | CodigoEvento | Ver catálogo no documento 04 |
| descricaoPublica | String | |
| descricaoInterna | String? | |
| visivelPublico | Boolean | |
| cidade | String? | |
| uf | String? | |
| local | String? | |
| origem | OrigemEvento | `SISTEMA`, `USUARIO`, `TRANSPORTADORA` |
| usuarioId | UUID? | |
| idExterno | String? | Idempotência de eventos externos |
| ocorridoEm | DateTime | Data real do fato |
| payload | Json? | |

---

## 6. Despacho, Transporte e Hubs · Fases 3 e 4

### OrdemSeparacao (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| encomendaId | UUID | |
| armazemId | UUID | |
| status | StatusSeparacao | `PENDENTE`, `EM_ANDAMENTO`, `CONCLUIDA`, `PAUSADA`, `CANCELADA` |
| prioridade | Int | |
| operadorId | UUID? | |
| iniciadaEm | DateTime? | |
| concluidaEm | DateTime? | |

### ItemSeparacao
| Campo | Tipo | Observação |
|---|---|---|
| ordemId | UUID | |
| produtoId | UUID | |
| localizacaoId | UUID | |
| quantidadePlanejada | Int | |
| quantidadeSeparada | Int | |
| falta | Boolean | |

### Manifesto (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| tipo | TipoManifesto | `COLETA_TRANSPORTADORA`, `TRANSFERENCIA_HUB`, `ROTA` |
| status | StatusManifesto | `ABERTO`, `EM_CONFERENCIA`, `FECHADO`, `CANCELADO` |
| hubOrigemId | UUID | |
| hubDestinoId | UUID? | |
| transportadoraId | UUID? | |
| veiculoId | UUID? | |
| rotaId | UUID? | |
| responsavelColeta | String? | |
| assinaturaAnexoId | UUID? | |
| criadoPorId | UUID | |
| fechadoEm | DateTime? | |

### ManifestoVolume
| Campo | Tipo | Observação |
|---|---|---|
| manifestoId | UUID | |
| volumeId | UUID | |
| conferido | Boolean | |
| conferidoEm | DateTime? | |

### UnidadeConsolidada (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| hubId | UUID | |
| codigo | String | |
| status | StatusUnidade | `ABERTA`, `FECHADA`, `EM_TRANSITO`, `ABERTA_NO_DESTINO` |
| manifestoId | UUID? | |

### RecebimentoHub (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| hubId | UUID | |
| manifestoId | UUID? | |
| status | StatusRecebimentoHub | `EM_ANDAMENTO`, `CONCLUIDO`, `COM_DIVERGENCIA` |
| operadorId | UUID | |
| iniciadoEm | DateTime | |
| finalizadoEm | DateTime? | |

### DivergenciaRecebimento
| Campo | Tipo | Observação |
|---|---|---|
| recebimentoId | UUID | |
| volumeId | UUID? | |
| tipo | TipoDivergencia | `EXCEDENTE`, `FALTANTE`, `AVARIADO` |
| descricao | String? | |
| ocorrenciaId | UUID? | |

### Transportadora (Global)
| Campo | Tipo | Observação |
|---|---|---|
| nome | String | |
| codigo | String | Único |
| adapter | String | Nome do adapter (`sandbox`, ...) |
| configCifrada | Json? | Credenciais |
| emObservacao | Boolean | |
| ativa | Boolean | |

---

## 7. Rotas e Entregas · Fase 5

### Veiculo (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| placa | String | Única |
| tipo | TipoVeiculo | `MOTO`, `CARRO`, `VAN`, `CAMINHAO_LEVE` |
| cnhExigida | CategoriaCnh | |
| capacidadePesoG | Int | |
| capacidadeVolumeCm3 | Int | |
| hubId | UUID | |
| status | StatusVeiculo | `ATIVO`, `MANUTENCAO`, `INATIVO` |

### Entregador (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| usuarioId | UUID | Único |
| hubId | UUID | |
| documento | String | CPF |
| cnhNumero | String | |
| cnhCategoria | CategoriaCnh | |
| cnhValidade | Date | |
| veiculoPadraoId | UUID? | |
| vinculo | VinculoEntregador | |
| consentimentoLocalizacaoEm | DateTime? | |
| status | StatusEntregador | `ATIVO`, `INATIVO`, `SUSPENSO` |

### Rota (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| hubId | UUID | |
| data | Date | |
| status | StatusRota | `RASCUNHO`, `PLANEJADA`, `EM_ANDAMENTO`, `CONCLUIDA`, `CANCELADA` |
| entregadorId | UUID? | |
| veiculoId | UUID? | |
| distanciaPlanejadaM | Int? | |
| distanciaPercorridaM | Int? | |
| kmInicial | Int? | |
| kmFinal | Int? | |
| cargaConferidaEm | DateTime? | |
| planejadaPorId | UUID | |
| iniciadaEm | DateTime? | |
| finalizadaEm | DateTime? | |

### ParadaRota
| Campo | Tipo | Observação |
|---|---|---|
| rotaId | UUID | |
| ordem | Int | |
| enderecoId | UUID | |
| janelaInicio | DateTime? | |
| janelaFim | DateTime? | |
| etaEm | DateTime? | |
| status | StatusParada | `PENDENTE`, `ENTREGUE`, `FALHA`, `PARCIAL` |
| instrucoes | String? | |
| ordemAlterada | Boolean | |

### ParadaEncomenda
| Campo | Tipo | Observação |
|---|---|---|
| paradaId | UUID | |
| encomendaId | UUID | |

### TentativaEntrega 🔒 (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| encomendaId | UUID | |
| rotaId | UUID | |
| paradaId | UUID? | |
| numero | Int | |
| resultado | ResultadoTentativa | `ENTREGUE`, `FALHA` |
| motivoFalha | MotivoFalha? | |
| contaComoTentativa | Boolean | |
| nomeRecebedor | String? | |
| documentoRecebedor | String? | Últimos dígitos |
| relacaoRecebedor | String? | |
| codigoConfirmacaoValido | Boolean | |
| latitude | Decimal? | |
| longitude | Decimal? | |
| distanciaDoEnderecoM | Int? | |
| justificativaDistancia | String? | |
| observacao | String? | |
| idClienteOffline | UUID | Idempotência da sincronização |
| registradaEm | DateTime | |
| sincronizadaEm | DateTime? | |

### CodigoConfirmacao
| Campo | Tipo | Observação |
|---|---|---|
| encomendaId | UUID | |
| codigoHash | String | 4 dígitos, guardado como hash |
| expiraEm | DateTime | Com o fim da rota |
| usadoEm | DateTime? | |

### PosicaoEntregador 🔒 (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| rotaId | UUID | |
| entregadorId | UUID | |
| latitude | Decimal | |
| longitude | Decimal | |
| precisaoM | Int? | |
| registradaEm | DateTime | |

### Anexo (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| tipoReferencia | TipoReferenciaAnexo | `ENTREGA`, `OCORRENCIA`, `DEVOLUCAO`, `RECEBIMENTO`, `FATURA`, `MANIFESTO` |
| referenciaId | UUID | |
| chaveStorage | String | Caminho no S3/MinIO |
| mime | String | |
| tamanhoBytes | Int | Máx. 10 MB |
| hashSha256 | String | |
| enviadoPorId | UUID? | |

---

## 8. Ocorrências e Devoluções · Fase 6

### Ocorrencia (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| encomendaId | UUID | |
| tipo | TipoOcorrencia | `AVARIA`, `EXTRAVIO`, `ENDERECO_INSUFICIENTE`, `DIVERGENCIA`, `RECUSA`, `ATRASO`, `FALTA_ITEM`, `OUTROS` |
| gravidade | Gravidade | `CRITICA`, `NORMAL`, `BAIXA` |
| status | StatusOcorrencia | `ABERTA`, `EM_ANALISE`, `AGUARDANDO_TERCEIRO`, `RESOLVIDA`, `IMPROCEDENTE` |
| bloqueante | Boolean | |
| origem | OrigemOcorrencia | `AUTOMATICA`, `MANUAL` |
| responsavelId | UUID? | |
| prazoSlaEm | DateTime | |
| escaladaEm | DateTime? | |
| resolucao | ResolucaoOcorrencia? | `REENTREGA`, `CORRECAO_ENDERECO`, `DEVOLUCAO`, `INDENIZACAO`, `IMPROCEDENTE` |
| comentarioResolucao | String? | Obrigatório ao encerrar |
| resolvidaEm | DateTime? | |

### ComentarioOcorrencia
| Campo | Tipo | Observação |
|---|---|---|
| ocorrenciaId | UUID | |
| usuarioId | UUID | |
| texto | String | |
| interno | Boolean | |

### Devolucao (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| encomendaOrigemId | UUID | |
| encomendaReversaId | UUID? | |
| motivo | MotivoDevolucao | `ARREPENDIMENTO`, `DEFEITO`, `PRODUTO_ERRADO`, `RECUSA`, `TENTATIVAS_ESGOTADAS`, `ENDERECO_NAO_LOCALIZADO` |
| status | StatusDevolucao | `SOLICITADA`, `AUTORIZADA`, `EM_COLETA`, `EM_TRANSITO`, `RECEBIDA`, `INSPECIONADA`, `CONCLUIDA`, `RECUSADA` |
| solicitadaPor | SolicitanteDevolucao | `DESTINATARIO`, `LOJA`, `SISTEMA` |
| responsavelCusto | ResponsavelCusto | `LOJA`, `DESTINATARIO`, `TRANSPORTE` |
| autorizadaPorId | UUID? | |
| concluidaEm | DateTime? | |

### InspecaoDevolucaoItem
| Campo | Tipo | Observação |
|---|---|---|
| devolucaoId | UUID | |
| produtoId | UUID | |
| quantidade | Int | |
| classificacao | ClassificacaoItem | `APTO`, `AVARIADO`, `DESCARTE` |
| observacao | String? | |
| inspetorId | UUID | |

### Indenizacao (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| ocorrenciaId | UUID | |
| valorMercadoriaCentavos | Int | |
| valorFreteCentavos | Int | |
| valorTotalCentavos | Int | |
| status | StatusIndenizacao | `SOLICITADA`, `EM_ANALISE`, `APROVADA`, `NEGADA`, `CREDITADA` |
| aprovadaNivel1PorId | UUID? | |
| aprovadaNivel2PorId | UUID? | Acima de R$ 1.000,00 |
| lancamentoCreditoId | UUID? | |

---

## 9. Financeiro · Fase 7

### LancamentoFinanceiro 🔒 (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | **Devedor** |
| emissorTenantId | UUID | **Credor**: plataforma (frete) ou administrador do armazém (armazenagem), RN-FIN-12 |
| encomendaId | UUID? | |
| faturaId | UUID? | Preenchido no fechamento |
| natureza | NaturezaLancamento | `RECEITA`, `CUSTO`, `CREDITO`, `ESTORNO` |
| tipo | TipoLancamento | `FRETE`, `SEGURO`, `TAXA`, `DIFERENCA_PESO`, `DEVOLUCAO`, `REENTREGA`, `REDESPACHO`, `CANCELAMENTO`, `INDENIZACAO`, `ARMAZENAGEM`, `MANUSEIO`, `OUTROS` |
| valorCentavos | Int | |
| lancamentoOriginalId | UUID? | Em estornos |
| motivo | String? | |
| competenciaEm | DateTime | |

### Fatura (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | **Devedor** |
| emissorTenantId | UUID | **Credor** (RN-FIN-12) |
| periodoInicio | Date | |
| periodoFim | Date | |
| status | StatusFatura | `RASCUNHO`, `FECHADA`, `PAGA`, `VENCIDA`, `CANCELADA` |
| totalCentavos | Int | |
| multaCentavos | Int | |
| jurosCentavos | Int | |
| vencimento | Date | |
| fechadaEm | DateTime? | |
| pagaEm | DateTime? | |
| pdfAnexoId | UUID? | |

> Os itens da fatura são os `LancamentoFinanceiro` com `faturaId` preenchido; não há tabela separada de itens.

### PagamentoFatura (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| faturaId | UUID | |
| valorCentavos | Int | |
| metodo | String | Registro manual/simulado |
| pagoEm | DateTime | |
| registradoPorId | UUID | |

### RepasseEntregador (Via armazém)
| Campo | Tipo | Observação |
|---|---|---|
| entregadorId | UUID | |
| periodoInicio | Date | |
| periodoFim | Date | |
| totalCentavos | Int | |
| status | StatusRepasse | `ABERTO`, `FECHADO`, `PAGO` |

### ItemRepasse
| Campo | Tipo | Observação |
|---|---|---|
| repasseId | UUID | |
| rotaId | UUID | |
| tentativaId | UUID? | |
| tipo | TipoItemRepasse | `ENTREGA`, `FALHA_VALIDA`, `KM` |
| valorCentavos | Int | |

### TabelaArmazenagem (Tenant administrador) · Fase 7
| Campo | Tipo | Observação |
|---|---|---|
| armazemId | UUID | |
| nome | String | |
| versao | Int | Cada alteração gera nova versão |
| vigenciaInicio | Date | |
| vigenciaFim | Date? | |
| ativa | Boolean | |

### ItemTabelaArmazenagem
| Campo | Tipo | Observação |
|---|---|---|
| tabelaArmazenagemId | UUID | |
| tipo | TipoCobrancaArmazenagem | `OCUPACAO_POSICAO_DIA`, `OCUPACAO_M3_DIA`, `MANUSEIO_RECEBIMENTO`, `MANUSEIO_SEPARACAO`, `MANUSEIO_EXPEDICAO` |
| valorCentavos | Int | |
| diasCarencia | Int | Padrão 0 |
| minimoMensalCentavos | Int? | |

### OcupacaoDiaria 🔒 (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| armazemId | UUID | |
| tenantId | UUID | Depositante |
| data | Date | Única por (`armazemId`, `tenantId`, `data`) |
| posicoesOcupadas | Int | |
| volumeM3 | Decimal | `Decimal(12,3)` |

---

## 10. Notificações, Integração e Administração · Fase 8

### WebhookEndpoint (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| url | String | HTTPS obrigatório |
| segredoCifrado | String | Chave do HMAC |
| eventos | String[] | |
| ativo | Boolean | |
| falhasConsecutivas | Int | Desativa ao chegar em 50 |
| desativadoEm | DateTime? | |

### WebhookEntrega (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| endpointId | UUID | |
| eventoId | UUID | Id do evento (idempotência no receptor) |
| tipoEvento | String | |
| payload | Json | |
| tentativa | Int | |
| status | StatusEntregaWebhook | `PENDENTE`, `SUCESSO`, `FALHA` |
| statusHttp | Int? | |
| erro | String? | |
| proximaTentativaEm | DateTime? | |
| enviadoEm | DateTime? | |

### TemplateNotificacao (Tenant ou Global)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID? | Nulo = padrão da plataforma |
| codigoEvento | String | |
| canal | CanalNotificacao | `EMAIL`, `SMS`, `WHATSAPP`, `IN_APP` |
| idioma | String | Padrão `pt-BR` |
| assunto | String? | |
| corpo | String | Com variáveis |
| ativo | Boolean | |

### Notificacao (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| encomendaId | UUID? | |
| templateId | UUID | |
| canal | CanalNotificacao | |
| destino | String | E-mail ou telefone |
| chaveDeduplicacao | String | Única (evento + destinatário + canal) |
| status | StatusNotificacao | `PENDENTE`, `ENVIADA`, `FALHA`, `DESCARTADA` |
| tentativas | Int | |
| erro | String? | |
| enviadaEm | DateTime? | |

### PreferenciaNotificacao (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| destino | String | |
| canal | CanalNotificacao | |
| tipoEvento | String? | Nulo = todos |
| optOut | Boolean | |

### OutboxEvent 🔒 (Global)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID? | |
| tipo | String | Ex.: `encomenda.despachada` |
| agregadoTipo | String | |
| agregadoId | UUID | |
| payload | Json | |
| tentativas | Int | |
| processadoEm | DateTime? | |

### AuditLog 🔒 (Global)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID? | |
| usuarioId | UUID? | |
| acao | String | |
| entidade | String | |
| entidadeId | UUID? | |
| antes | Json? | |
| depois | Json? | |
| ip | String? | |
| userAgent | String? | |
| traceId | String? | |

### ParametroSistema
| Campo | Tipo | Observação |
|---|---|---|
| chave | String | Única por escopo |
| escopo | EscopoParametro | `GLOBAL`, `TENANT` |
| tenantId | UUID? | |
| valor | Json | |
| descricao | String? | |
| atualizadoPorId | UUID? | Histórico via `AuditLog` |

### SolicitacaoLgpd (Tenant)
| Campo | Tipo | Observação |
|---|---|---|
| tenantId | UUID | |
| tipo | TipoSolicitacaoLgpd | `ACESSO`, `ELIMINACAO` |
| titularReferencia | String | Documento ou e-mail (preferir hash) |
| status | StatusSolicitacao | `ABERTA`, `EM_EXECUCAO`, `CONCLUIDA`, `NEGADA` |
| prazoEm | DateTime | |
| executadaPorId | UUID? | |
| concluidaEm | DateTime? | |

---

## 11. Enumerações (resumo)

| Enum | Valores |
|---|---|
| Papel | `USER`, `ADMIN`, `DONO_EMPRESA`, `OPERADOR_EMPRESA`, `OPERADOR_ARMAZEM`, `DESPACHANTE`, `ROTEIRIZADOR`, `ENTREGADOR`, `CONTADOR`, `SUPORTE`, `CLIENTE` (`USER` é o padrão e não tem permissões; `CLIENTE` está reservado, sem uso definido) |
| TipoTenant | `OPERADOR_LOGISTICO`, `LOJISTA` |
| StatusTenant | `ATIVO`, `INATIVO`, `BLOQUEADO` |
| NivelAcessoArmazem | `DEPOSITANTE`, `OPERADOR` (reservado) |
| StatusAcesso | `ATIVO`, `SUSPENSO` |
| RecursoPlataforma | `ADMINISTRAR_ARMAZEM`, `SO_TRANSPORTE`, `COBRAR_ARMAZENAGEM` |
| TipoOrigemEncomenda | `ARMAZEM`, `COLETA_NA_ORIGEM` |
| TipoCobrancaArmazenagem | `OCUPACAO_POSICAO_DIA`, `OCUPACAO_M3_DIA`, `MANUSEIO_RECEBIMENTO`, `MANUSEIO_SEPARACAO`, `MANUSEIO_EXPEDICAO` |
| StatusPedido | `PENDENTE_VALIDACAO`, `CONFIRMADO`, `EM_PROCESSAMENTO`, `CONCLUIDO`, `PARCIALMENTE_CONCLUIDO`, `CANCELADO` |
| StatusEncomenda | `CRIADA`, `AGUARDANDO_COLETA`, `COLETADA`, `AGUARDANDO_SEPARACAO`, `EM_SEPARACAO`, `SEPARADA`, `EMBALADA`, `AGUARDANDO_DESPACHO`, `DESPACHADA`, `EM_TRANSITO`, `NO_HUB`, `EM_ROTA`, `TENTATIVA_FALHA`, `AGUARDANDO_RETIRADA`, `ENTREGUE`, `EM_DEVOLUCAO`, `DEVOLVIDA`, `CANCELADA`, `EXTRAVIADA` |
| TipoMovimento | `ENTRADA`, `SAIDA`, `TRANSFERENCIA`, `AJUSTE_POSITIVO`, `AJUSTE_NEGATIVO`, `RESERVA`, `LIBERACAO_RESERVA`, `BAIXA_DESCARTE`, `DEVOLUCAO` |
| MotivoFalha | `DESTINATARIO_AUSENTE`, `ENDERECO_NAO_LOCALIZADO`, `ENDERECO_INSUFICIENTE`, `RECUSA_RECEBEDOR`, `ESTABELECIMENTO_FECHADO`, `AREA_DE_RISCO`, `FALTA_DE_TEMPO`, `AVARIA_CONSTATADA` |
| CategoriaCnh | `A`, `B`, `C`, `D`, `E` |
| Demais enums | Os valores estão listados na coluna *Observação* de cada campo acima. |

---

## 12. Visão geral das entidades por fase

| Fase | Entidades |
|---|---|
| 1 | Tenant, Loja, Usuario, Sessao, TokenUsoUnico, ApiKey, RecursoTenant, Endereco, Destinatario, Produto, Armazem, CoberturaHub, Localizacao |
| 2 | Pedido, ItemPedido, Contrato, ContratoServico, ServicoEntrega, ZonaFrete, ZonaFreteRegra, TabelaFrete, FaixaPreco, TaxaAdicional, PromocaoFrete, Feriado, Cotacao, Encomenda, ItemEncomenda, Volume, EventoRastreio |
| 3 | AcessoArmazem, SaldoEstoque, MovimentoEstoque, RecebimentoMercadoria, ItemRecebimento, InventarioContagem, OrdemSeparacao, ItemSeparacao, Manifesto, ManifestoVolume |
| 4 | Transportadora, UnidadeConsolidada, RecebimentoHub, DivergenciaRecebimento |
| 5 | Veiculo, Entregador, Rota, ParadaRota, ParadaEncomenda, TentativaEntrega, CodigoConfirmacao, PosicaoEntregador, Anexo |
| 6 | Ocorrencia, ComentarioOcorrencia, Devolucao, InspecaoDevolucaoItem, Indenizacao |
| 7 | LancamentoFinanceiro, Fatura, PagamentoFatura, RepasseEntregador, ItemRepasse, TabelaArmazenagem, ItemTabelaArmazenagem, OcupacaoDiaria |
| 8 | WebhookEndpoint, WebhookEntrega, TemplateNotificacao, Notificacao, PreferenciaNotificacao, OutboxEvent, AuditLog, ParametroSistema, SolicitacaoLgpd |

> **Fase 1 (o que você vai escrever primeiro):** comece por `Tenant` e `Usuario`; as demais entram conforme as fases avançam. Não modele tudo de uma vez.

---

## 13. Histórico de alterações

| Versão | Mudança |
|---|---|
| 1.1 | Tenant: `OPERADOR_LOGISTICO`, status `ATIVO`/`INATIVO`/`BLOQUEADO`, campos financeiros e de frete marcados por fase (nulos para o operador logístico). Papéis alinhados ao schema. Novo modelo de armazém compartilhado: `Armazem.tenantId` (administrador) e `AcessoArmazem`. Escopo "Operador" substituído por "Via armazém". |
| 1.2 | Novo: `RecursoTenant` (painel de permissões), coleta na origem (`tipoOrigem`, estados `AGUARDANDO_COLETA` e `COLETADA`), cobrança de armazenagem (`TabelaArmazenagem`, `ItemTabelaArmazenagem`, `OcupacaoDiaria`, `emissorTenantId` em lançamento e fatura). |
