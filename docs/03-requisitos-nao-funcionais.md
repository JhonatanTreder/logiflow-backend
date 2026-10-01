# LogiFlow — Requisitos Não-Funcionais (RNF)

**Versão:** 1.0 · **Data:** 30/09/2026
**Formato do ID:** `RNF-<CATEGORIA>-NN`. Prioridade: **M** essencial · **S** importante · **C** desejável.
Cada requisito é **mensurável** e indica como será **verificado**. Metas de capacidade consideram o uso pessoal/estudo, mas o sistema deve ser projetado para escalar além disso sem reescrita.

**Premissas de dimensionamento (referência para as metas):**
- Até **200 empresas** (tenants), **50 mil encomendas/dia** no pico simulado, **5 milhões de encomendas** acumuladas no banco.
- Até **500 usuários simultâneos** nos painéis e **300 entregadores** conectados em rota.
- Rastreio público: até **100 requisições/s** em pico.

---

## 1. Desempenho (PER)

| ID | Requisito | Meta | Verificação | Prio |
|---|---|---|---|---|
| RNF-PER-01 | Tempo de resposta de endpoints de leitura simples (por ID, listas paginadas) | p95 ≤ 300 ms; p99 ≤ 800 ms | k6 + métricas Prometheus | M |
| RNF-PER-02 | Cotação de frete | p95 ≤ 400 ms (cache frio), ≤ 100 ms (cache quente) | k6 | M |
| RNF-PER-03 | Criação de pedido/encomenda | p95 ≤ 600 ms (sem trabalho assíncrono bloqueante) | k6 | M |
| RNF-PER-04 | Rastreio público | p95 ≤ 200 ms com cache; TTFB da página ≤ 500 ms | k6 + Lighthouse | M |
| RNF-PER-05 | Geração de etiquetas | 1 etiqueta ≤ 1 s; lote de 500 ≤ 60 s (assíncrono) | Teste de carga | S |
| RNF-PER-06 | Roteirização automática | Até 150 paradas em ≤ 30 s (assíncrono, com progresso) | Teste de carga | S |
| RNF-PER-07 | Painéis Angular | LCP ≤ 2,5 s em 4G simulada; bundle inicial ≤ 300 kB (gzip) por app; rotas *lazy* | Lighthouse CI | S |
| RNF-PER-08 | Atualização em tempo real | Latência de posição/evento até a tela ≤ 2 s (p95) | Teste E2E medido | S |
| RNF-PER-09 | Consultas SQL | Nenhuma consulta de rotina com *seq scan* em tabelas > 100 mil linhas; `EXPLAIN` revisado nas 20 consultas mais frequentes | Revisão + `pg_stat_statements` | S |
| RNF-PER-10 | Importações e exportações grandes | 10 mil linhas CSV em ≤ 60 s, sem bloquear a API | Teste de carga | S |

## 2. Escalabilidade (ESC)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-ESC-01 | A API deve ser *stateless*, permitindo múltiplas instâncias atrás de balanceador. | Sessão apenas em token/Redis | M |
| RNF-ESC-02 | Workers de fila devem escalar horizontalmente de forma independente da API. | Processos separados | M |
| RNF-ESC-03 | Tabelas de crescimento contínuo (`evento_rastreio`, `audit_log`, `movimento_estoque`, `webhook_entrega`) devem ter estratégia de particionamento por data ou arquivamento. | Particionamento mensal avaliado em 5 M de linhas | S |
| RNF-ESC-04 | Leitura pesada de relatórios deve poder ser direcionada a réplica de leitura ou *materialized views*. | Configurável | C |
| RNF-ESC-05 | O WebSocket deve escalar com adaptador Redis (pub/sub). | ≥ 2 instâncias | S |
| RNF-ESC-06 | Limites de uso por tenant (requisições, webhooks, armazenamento) para evitar "vizinho barulhento". | Configuráveis | S |

## 3. Disponibilidade e Confiabilidade (DIS)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-DIS-01 | Disponibilidade alvo da API e do rastreio público (em produção) | ≥ 99,5% mensal; rastreio ≥ 99,9% | S |
| RNF-DIS-02 | Degradação graciosa: falha de serviço externo (CEP, geocodificação, e-mail, transportadora) não deve derrubar fluxos principais | *Circuit breaker*, *timeouts* ≤ 5 s, filas com *retry* | M |
| RNF-DIS-03 | Nenhuma perda de evento de domínio: eventos persistidos (outbox) e processados *at-least-once* | 0 eventos perdidos em teste de falha | M |
| RNF-DIS-04 | Operações repetíveis devem ser idempotentes (consumo de eventos, webhooks recebidos, criação de pedido) | Testes de repetição | M |
| RNF-DIS-05 | Backup automático do PostgreSQL | Diário completo + WAL contínuo; **RPO ≤ 15 min**, **RTO ≤ 2 h** | S |
| RNF-DIS-06 | Restauração testada periodicamente | Teste a cada trimestre | S |
| RNF-DIS-07 | Health checks de *liveness* e *readiness*; reinício automático | Endpoints `/health/*` | M |
| RNF-DIS-08 | Migrações de banco compatíveis com *deploy* sem parada (expand/contract) | Convenção de migração | C |
| RNF-DIS-09 | O app do entregador deve funcionar offline por até 8 h e sincronizar sem perda ou duplicação | Teste E2E offline | S |

## 4. Consistência e Integridade de Dados (INT)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-INT-01 | Operações de estoque devem ser atômicas e livres de condição de corrida (sem saldo negativo) | Teste de concorrência com 100 requisições paralelas | M |
| RNF-INT-02 | Transições de estado da encomenda devem ser transacionais e validadas no domínio e no banco (`CHECK`/enum) | Testes de máquina de estados | M |
| RNF-INT-03 | Dinheiro armazenado em inteiros (centavos); nenhuma operação com `float` | Lint/revisão + testes | M |
| RNF-INT-04 | Integridade referencial por chaves estrangeiras; `ON DELETE` explícito | Schema Prisma revisado | M |
| RNF-INT-05 | Eventos de rastreio, movimentos de estoque, lançamentos financeiros e auditoria são **imutáveis** (correção por novo registro) | Permissões de banco / testes | M |
| RNF-INT-06 | Timestamps em UTC; conversão para `America/Sao_Paulo` apenas na apresentação | Testes de fuso | M |
| RNF-INT-07 | Unicidade garantida no banco: código de rastreio, SKU por tenant, número externo por loja | Constraints únicas | M |

## 5. Segurança (SEG)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-SEG-01 | Todo tráfego externo em TLS 1.2+ (preferir 1.3); HSTS ativo | Scan SSL | M |
| RNF-SEG-02 | Senhas armazenadas com Argon2id (ou bcrypt custo ≥ 12); política mínima de 10 caracteres | Revisão + testes | M |
| RNF-SEG-03 | *Access token* ≤ 15 min; *refresh token* rotativo com detecção de reuso; revogação imediata no logout | Testes de autenticação | M |
| RNF-SEG-04 | Isolamento total de dados entre tenants | Suíte automatizada que tenta acesso cruzado em **todos** os endpoints (IDOR) | M |
| RNF-SEG-05 | Autorização verificada no servidor em toda rota (negar por padrão) | Guards globais + testes por papel | M |
| RNF-SEG-06 | Proteção contra OWASP Top 10: validação de entrada, injeção SQL (queries parametrizadas), XSS (escape/CSP), SSRF, mass assignment | Checklist + ZAP/ferramenta SAST | M |
| RNF-SEG-07 | Chaves de API armazenadas apenas como *hash*; exibidas uma única vez | Revisão | M |
| RNF-SEG-08 | Webhooks de saída assinados (HMAC-SHA256) com *timestamp* e janela anti-replay (5 min) | Testes | M |
| RNF-SEG-09 | Webhooks proíbem destinos em IPs privados/localhost (anti-SSRF) e exigem HTTPS | Testes | M |
| RNF-SEG-10 | Limitação de taxa e proteção contra força bruta em login, recuperação de senha e rastreio público | Rate limit configurado | M |
| RNF-SEG-11 | Cabeçalhos de segurança (CSP, X-Content-Type-Options, Referrer-Policy, frame-ancestors) e CORS restrito | Scan de cabeçalhos | M |
| RNF-SEG-12 | Segredos fora do repositório; rotação possível sem *deploy* de código | Varredura (gitleaks) no CI | M |
| RNF-SEG-13 | Dependências verificadas continuamente (npm audit/Dependabot); vulnerabilidades críticas corrigidas em ≤ 7 dias | CI | S |
| RNF-SEG-14 | Uploads (fotos, anexos): validação de tipo real (magic bytes), tamanho ≤ 10 MB, armazenamento fora da raiz web e URLs assinadas com expiração | Testes | M |
| RNF-SEG-15 | Dados sensíveis (CPF, telefone, endereço) criptografados em repouso quando aplicável (disco/coluna) e mascarados em logs e telas públicas | Revisão | S |
| RNF-SEG-16 | Auditoria completa de ações sensíveis, inviolável pelo usuário | Tabela *append-only* | M |

## 6. Privacidade e Conformidade — LGPD (LGP)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-LGP-01 | Coletar apenas dados necessários à entrega (minimização) e registrar a finalidade | Inventário de dados | M |
| RNF-LGP-02 | Atender requisições de acesso/exportação e eliminação/anonimização de titulares | Prazo interno ≤ 15 dias; funcionalidade no painel | S |
| RNF-LGP-03 | Política de retenção: dados pessoais do destinatário anonimizados 24 meses após conclusão; dados fiscais/financeiros mantidos 5 anos | Job automático + teste | S |
| RNF-LGP-04 | Geolocalização do entregador coletada somente durante a rota ativa, com ciência/consentimento registrado | Fluxo de consentimento | M |
| RNF-LGP-05 | Logs não devem conter dados pessoais em texto claro (CPF, e-mail completo, endereço) | Revisão + testes de logging | M |
| RNF-LGP-06 | Comunicação de incidente: procedimento documentado e trilha de auditoria suficiente para reconstrução | Runbook | C |

## 7. Usabilidade (USA)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-USA-01 | Interfaces consistentes, baseadas em design system único | Biblioteca `ui` | M |
| RNF-USA-02 | Tarefas frequentes devem exigir poucos passos: criar encomenda ≤ 3 telas; registrar entrega ≤ 4 toques | Teste de usabilidade com roteiro | S |
| RNF-USA-03 | Telas de operação (bipagem) devem funcionar por teclado/leitor de código de barras sem uso de mouse, com feedback sonoro/visual imediato | Teste manual | S |
| RNF-USA-04 | App do entregador *mobile-first*, botões ≥ 44×44 px, uso em luz solar (alto contraste) e com uma mão | Revisão | M |
| RNF-USA-05 | Mensagens de erro claras, em português, com ação sugerida; sem expor detalhes técnicos | Revisão | M |
| RNF-USA-06 | Estados de carregamento, vazio e erro tratados em todas as listas e formulários | Checklist de componentes | S |
| RNF-USA-07 | Idioma padrão pt-BR; textos externalizados para suporte futuro a en-US | i18n Angular | S |
| RNF-USA-08 | Tema claro e escuro | Tokens Tailwind | C |

## 8. Acessibilidade (ACE)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-ACE-01 | Conformidade com **WCAG 2.1 nível AA** na página de rastreio e nos painéis | Auditoria axe-core (0 violações críticas) | M |
| RNF-ACE-02 | Navegação completa por teclado; foco visível; ordem lógica | Teste manual + Playwright | M |
| RNF-ACE-03 | Contraste mínimo 4,5:1 para texto; informação nunca só por cor (status com ícone/texto) | Verificação de tokens | M |
| RNF-ACE-04 | Semântica correta (landmarks, labels, ARIA apenas quando necessário) e compatibilidade com leitores de tela | Teste com NVDA/VoiceOver | S |

## 9. Compatibilidade e Portabilidade (COM)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-COM-01 | Suporte às duas últimas versões estáveis de Chrome, Edge, Firefox e Safari | Matriz de testes | M |
| RNF-COM-02 | App do entregador compatível com Android 10+ (Chrome) e iOS 16+ (Safari) | Teste em dispositivos | M |
| RNF-COM-03 | Layout responsivo de 360 px a 2560 px | Breakpoints Tailwind | M |
| RNF-COM-04 | Execução em contêineres; ambiente de desenvolvimento subindo com um único comando (`docker compose up`) | README validado | M |
| RNF-COM-05 | Configuração exclusivamente por variáveis de ambiente (12-factor) | Revisão | M |
| RNF-COM-06 | Etiquetas imprimíveis em A4/A6 (PDF) e impressoras térmicas 10×15 cm (ZPL) | Teste de impressão | S |
| RNF-COM-07 | PostgreSQL 16+; sem dependência de extensão proprietária (PostGIS opcional) | Documentação | M |

## 10. Manutenibilidade e Qualidade de Código (MAN)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-MAN-01 | Arquitetura modular com dependências em direção ao domínio; fronteiras entre módulos verificadas por regra de lint (Nx *module boundaries* / dependency-cruiser) | 0 violações no CI | M |
| RNF-MAN-02 | TypeScript em modo `strict`; proibido `any` implícito | `tsconfig` + lint | M |
| RNF-MAN-03 | Cobertura de testes | ≥ 80% domínio/aplicação; ≥ 60% global | S |
| RNF-MAN-04 | Todo requisito crítico de regra de negócio com teste identificado pelo ID da RN | Revisão de PR | S |
| RNF-MAN-05 | Lint, formatação e *commit lint* automáticos (pre-commit + CI) | Husky + CI | M |
| RNF-MAN-06 | Complexidade ciclomática por função ≤ 10 (exceções justificadas) | ESLint `complexity` | C |
| RNF-MAN-07 | Documentação viva: OpenAPI gerado do código; ADRs para decisões relevantes; README por módulo | Revisão | S |
| RNF-MAN-08 | Tipos e contratos compartilhados entre front e back em lib única, evitando divergência | Lib `contracts` | M |
| RNF-MAN-09 | Migrações versionadas, revisadas e reversíveis quando viável | `prisma migrate` | M |
| RNF-MAN-10 | Versionamento semântico dos releases e *changelog* automatizado | Conventional Commits | C |

## 11. Observabilidade (OBS)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-OBS-01 | Logs estruturados (JSON) com `traceId`, `tenantId`, `userId`, nível e módulo | Revisão | M |
| RNF-OBS-02 | Métricas técnicas (latência, taxa de erro, saturação) e de negócio (encomendas/h, atrasos, falhas de webhook) | Painéis Grafana | S |
| RNF-OBS-03 | Tracing distribuído entre API, filas e chamadas externas (OpenTelemetry) | Trace de ponta a ponta | C |
| RNF-OBS-04 | Alertas para: erro 5xx > 2%, fila acumulada > 5 min, falha de backup, job de fechamento falho | Regras de alerta | S |
| RNF-OBS-05 | Correlação de erro mostrado ao usuário com `traceId` para suporte | Resposta Problem Details | M |

## 12. Testabilidade (TES)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-TES-01 | Serviços externos acessados por interfaces (ports) com implementações *fake*/sandbox | Adapters mock | M |
| RNF-TES-02 | Relógio e gerador de IDs/códigos injetáveis para testes determinísticos (prazos, cortes, rastreio) | Abstrações `Clock`, `IdGenerator` | M |
| RNF-TES-03 | Banco de testes isolado e descartável (Testcontainers), com *seeds* mínimos | CI | M |
| RNF-TES-04 | Ambiente de simulação: gerador de pedidos e simulador de eventos de transportadora para demonstração e carga | Script `simulate` | S |

## 13. Interoperabilidade (IOP)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-IOP-01 | API aderente a REST e documentada com OpenAPI 3.1; erros em RFC 9457 | Validação de contrato | M |
| RNF-IOP-02 | Compatibilidade retroativa dentro de uma versão da API; depreciação anunciada com ≥ 90 dias | Política documentada | S |
| RNF-IOP-03 | Formatos padrão: datas ISO 8601, moeda ISO 4217 (BRL), países ISO 3166, CEP com 8 dígitos | Testes de serialização | M |
| RNF-IOP-04 | Exportações em CSV (UTF-8 com BOM, `;` como separador opcional) compatíveis com Excel pt-BR | Teste de importação | S |

## 14. Custo e Operação (CUS)

| ID | Requisito | Meta | Prio |
|---|---|---|---|
| RNF-CUS-01 | Stack baseada em software livre/gratuito para estudo (OSM, OSRM, MinIO, Mailpit, PostgreSQL) | Sem custo obrigatório | S |
| RNF-CUS-02 | Execução completa em máquina local com ≤ 8 GB de RAM | Docker Compose enxuto | S |
| RNF-CUS-03 | Rotinas de limpeza (filas concluídas, arquivos temporários, tokens expirados) para controle de armazenamento | Jobs agendados | S |

---

## Matriz de rastreabilidade (resumo RNF → verificação)

| Categoria | Principais ferramentas de verificação |
|---|---|
| Desempenho / Escalabilidade | k6, Prometheus, Lighthouse CI, `EXPLAIN ANALYZE` |
| Disponibilidade / Integridade | Testes de caos simples (derrubar Redis/serviço externo), testes de concorrência, restore de backup |
| Segurança / LGPD | Testes automatizados de IDOR, OWASP ZAP, gitleaks, dependabot, revisão de logs |
| Usabilidade / Acessibilidade | axe-core, Playwright, testes manuais com roteiro, Lighthouse |
| Manutenibilidade / Testabilidade | ESLint, Nx boundaries, cobertura (Jest/Vitest), revisão de PR |
| Observabilidade | Painéis Grafana, alertas simulados, correlação por `traceId` |
