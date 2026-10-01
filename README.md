# LogiFlow

Plataforma de logística multiempresa para e-commerces: cotação de frete, pedidos e encomendas, estoque, separação e despacho, transferência entre hubs, roteirização e entrega de última milha, rastreio público, ocorrências, logística reversa, financeiro do frete, notificações e webhooks.

> **Projeto de estudo / uso pessoal.** Não é um produto para o mercado, mas tem escopo de produto completo para consolidar conhecimentos em arquitetura, modelagem de dados, APIs, front-end SPA, filas, tempo real, testes e DevOps.

![status](https://img.shields.io/badge/status-em%20planejamento-yellow)
![typescript](https://img.shields.io/badge/TypeScript-5.x-blue)
![angular](https://img.shields.io/badge/Angular-19%2B-red)
![postgres](https://img.shields.io/badge/PostgreSQL-16%2B-336791)

---

## Sumário

- [Status do projeto](#status-do-projeto)
- [Documentação](#documentação)
- [Visão geral](#visão-geral)
- [Stack](#stack)
- [Arquitetura em uma página](#arquitetura-em-uma-página)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Começando](#começando)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Scripts](#scripts)
- [Testes](#testes)
- [Roadmap](#roadmap)
- [Convenções](#convenções)
- [Licença](#licença)

---

## Status do projeto

A fase atual é **Fase 0 (Fundação)**: a documentação está pronta e o código ainda será iniciado. Os comandos da seção [Começando](#começando) descrevem o ambiente **alvo**; ajuste-os conforme o repositório for sendo criado e mantenha este README atualizado.

## Documentação

Toda a especificação está em [`docs/`](docs/):

| Documento | Conteúdo |
|---|---|
| [01 — Documentação do sistema](docs/01-documentacao-do-sistema.md) | Escopo, módulos, arquitetura, stack, modelo de dados, API, roadmap, glossário. |
| [02 — Requisitos funcionais](docs/02-requisitos-funcionais.md) | 184 RFs por módulo, com prioridade MoSCoW. |
| [03 — Requisitos não-funcionais](docs/03-requisitos-nao-funcionais.md) | Metas mensuráveis de desempenho, segurança, LGPD, acessibilidade etc. |
| [04 — Regras de negócio](docs/04-regras-de-negocios.md) | Regras numeradas (`RN-…`), catálogo de eventos e exemplo de cálculo de frete. |
| [05 — Casos de uso](docs/05-casos-de-uso.md) | Atores, 50 casos de uso, especificações detalhadas e fluxo crítico ponta a ponta. |

**Rastreabilidade:** UC → RF → RN → RNF. Todo teste de regra de negócio deve ser nomeado com o ID da regra (ex.: `RN-FRE-02`).

## Visão geral

Fluxo crítico simplificado:

```mermaid
flowchart LR
  A[Pedido do e-commerce] --> B[Cotação e encomenda]
  B --> C[Separação e embalagem]
  C --> D[Etiqueta e manifesto]
  D --> E[Hub]
  E --> F[Rota e entregador]
  F --> G[Entrega com comprovante]
  F -->|Falha| H[Nova tentativa ou devolução]
  H --> I[Logística reversa e estoque]
  G --> J[Fatura do lojista]
```

**Aplicações do front-end:**

| App | Público |
|---|---|
| `painel-lojista` | Gestores e operadores das empresas-clientes. |
| `painel-operacional` | Hub, despacho, roteirização, suporte e financeiro. |
| `app-entregador` | Entregadores (PWA *mobile-first*, offline parcial). |
| `rastreio-publico` | Destinatários (consulta pública por código). |

## Stack

**Obrigatórias:** HTML, CSS, JavaScript, TypeScript, Angular, TailwindCSS, PostgreSQL, Prisma ORM.

**Recomendadas:**

| Camada | Tecnologia |
|---|---|
| Back-end | Node.js 22 LTS, NestJS |
| Filas e cache | Redis, BullMQ |
| Tempo real | Socket.IO |
| Validação / contratos | Zod, OpenAPI (Swagger) |
| Monorepo | Nx + pnpm |
| Mapas e rotas | Leaflet + OpenStreetMap, OSRM |
| Arquivos | MinIO (S3) |
| Etiquetas | bwip-js, PDFKit |
| Testes | Jest/Vitest, Supertest, Testcontainers, Playwright, k6 |
| Observabilidade | Pino, OpenTelemetry, Prometheus, Grafana |
| Qualidade | ESLint, Prettier, Husky, Commitlint |
| Infra | Docker Compose, GitHub Actions |

## Arquitetura em uma página

- **Monólito modular** no back-end (Clean Architecture / DDD leve), com fronteiras de módulo verificadas por lint.
- **Multi-tenancy** por coluna `tenant_id`, aplicada automaticamente por uma Prisma Client Extension (e, opcionalmente, Row-Level Security).
- **Eventos de domínio com outbox** + filas BullMQ para notificações, webhooks, etiquetas em lote e faturamento.
- **Eventos de rastreio, movimentos de estoque, lançamentos financeiros e auditoria são imutáveis** (correção por novo registro).
- **Dinheiro em centavos (inteiro)**, datas em UTC, exibição em `America/Sao_Paulo`.
- **Adapters** para serviços externos (CEP, geocodificação, transportadoras, e-mail/SMS), com implementações *sandbox*.

Detalhes e decisões (ADRs) em [`docs/01-documentacao-do-sistema.md`](docs/01-documentacao-do-sistema.md).

## Estrutura do repositório

```
logiflow/
├─ apps/
│  ├─ api/                 # NestJS (monólito modular)
│  ├─ worker/              # filas e jobs agendados
│  ├─ painel-lojista/      # Angular
│  ├─ painel-operacional/  # Angular
│  ├─ app-entregador/      # Angular PWA
│  └─ rastreio-publico/    # Angular
├─ libs/
│  ├─ contracts/           # DTOs, schemas Zod, enums compartilhados
│  ├─ ui/                  # design system (Tailwind + componentes Angular)
│  ├─ util/                # datas, dinheiro, CEP, CPF/CNPJ
│  └─ api-client/          # cliente tipado gerado do OpenAPI
├─ prisma/
│  ├─ schema.prisma
│  ├─ migrations/
│  └─ seed.ts
├─ docker/                 # compose e configs (OSRM, Prometheus, Grafana)
├─ docs/                   # especificação do projeto e ADRs
└─ .github/workflows/
```

## Começando

### Pré-requisitos

- Node.js 22 LTS
- pnpm 9+
- Docker e Docker Compose
- Git

### Passo a passo (ambiente alvo)

```bash
# 1. Clonar e instalar dependências
git clone <url-do-repositorio> logiflow
cd logiflow
pnpm install

# 2. Configurar variáveis de ambiente
cp .env.example .env

# 3. Subir a infraestrutura local (PostgreSQL, Redis, MinIO, Mailpit, OSRM)
docker compose up -d

# 4. Criar o banco e popular dados de exemplo
pnpm prisma migrate dev
pnpm prisma db seed

# 5. Subir a API e o worker
pnpm nx serve api
pnpm nx serve worker

# 6. Subir os front-ends (em terminais separados)
pnpm nx serve painel-lojista
pnpm nx serve painel-operacional
pnpm nx serve app-entregador
pnpm nx serve rastreio-publico
```

### Endereços locais (sugeridos)

| Serviço | URL |
|---|---|
| API | http://localhost:3000/api/v1 |
| Documentação OpenAPI | http://localhost:3000/api/docs |
| Painel do lojista | http://localhost:4200 |
| Painel operacional | http://localhost:4201 |
| App do entregador | http://localhost:4202 |
| Rastreio público | http://localhost:4203 |
| Mailpit (e-mails de teste) | http://localhost:8025 |
| MinIO Console | http://localhost:9001 |

### Dados de exemplo (seed)

O *seed* deve criar, de forma determinística: um Super Admin, duas empresas lojistas com gestor e operador, tabelas de frete de exemplo, um hub com localizações, produtos, veículos e entregadores. As credenciais de desenvolvimento ficam documentadas no próprio `seed.ts`; **nunca as use fora do ambiente local**.

## Variáveis de ambiente

Exemplo de `.env.example`:

```dotenv
# Aplicação
NODE_ENV=development
PORT=3000
APP_BASE_URL=http://localhost:3000
TZ=UTC

# Banco de dados
DATABASE_URL=postgresql://logiflow:logiflow@localhost:5432/logiflow?schema=public

# Redis
REDIS_URL=redis://localhost:6379

# Autenticação
JWT_ACCESS_SECRET=troque-em-desenvolvimento
JWT_ACCESS_TTL=15m
JWT_REFRESH_SECRET=troque-em-desenvolvimento
JWT_REFRESH_TTL=7d

# Armazenamento de arquivos (MinIO/S3)
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=logiflow

# E-mail (Mailpit)
SMTP_HOST=localhost
SMTP_PORT=1025
MAIL_FROM=no-reply@logiflow.local

# Serviços externos (adapters)
CEP_PROVIDER=viacep
GEOCODER_PROVIDER=nominatim
OSRM_URL=http://localhost:5000
CARRIER_ADAPTER=sandbox

# Parâmetros de negócio (padrões; também configuráveis no sistema)
CUBAGE_DIVISOR=6000
DEFAULT_CUTOFF_TIME=14:00
```

> **Segurança:** o arquivo `.env` não deve ser versionado. Em qualquer ambiente fora do local, use segredos fortes e um gerenciador de segredos.

## Scripts

Scripts previstos (via `package.json` / Nx):

| Comando | Descrição |
|---|---|
| `pnpm nx serve <app>` | Executa uma aplicação em modo desenvolvimento. |
| `pnpm nx build <app>` | Gera o build de produção. |
| `pnpm nx run-many -t lint` | Lint em todos os projetos. |
| `pnpm nx run-many -t test` | Testes unitários e de integração. |
| `pnpm nx e2e <app>-e2e` | Testes E2E (Playwright). |
| `pnpm prisma migrate dev` | Cria/aplica migrações em desenvolvimento. |
| `pnpm prisma studio` | Interface visual do banco. |
| `pnpm simulate` | Simulador de pedidos e eventos de transportadora (demonstração e carga). |

## Testes

| Nível | Ferramentas | Foco |
|---|---|---|
| Unitário | Jest/Vitest | Cálculo de frete, máquina de estados, regras de estoque. |
| Integração | Supertest + Testcontainers | Módulos, repositórios e **isolamento entre tenants**. |
| E2E | Playwright | Fluxo crítico pedido → entrega e desvios (documento 05, seção 5). |
| Carga | k6 | Cotação, rastreio público, ingestão de pedidos. |

Metas: cobertura ≥ 80% em domínio e aplicação; toda RN crítica com teste nomeado pelo seu ID.

## Roadmap

| Fase | Entrega |
|---|---|
| 0 | Fundação: monorepo, Docker, CI, Prisma, autenticação básica |
| 1 | Cadastros: empresas, usuários, produtos, endereços |
| 2 | Pedido → encomenda: pedidos, cotação, encomendas, rastreio básico |
| 3 | Armazém e despacho: estoque, separação, etiquetas, manifestos |
| 4 | Transporte: transportadoras (adapters), hubs, eventos externos |
| 5 | Última milha: rotas, PWA do entregador, POD, mapa em tempo real |
| 6 | Exceções: ocorrências, devoluções, reentrega, indenização |
| 7 | Financeiro: faturas, repasses, conciliação |
| 8 | Ecossistema: notificações, webhooks, API pública, relatórios, auditoria |
| 9 | Endurecimento: observabilidade, carga, segurança, LGPD |

O **MVP** corresponde aos requisitos essenciais (**M**) das fases 0 a 5.

## Convenções

- **Git:** *trunk-based* com branches curtas (`feat/…`, `fix/…`), **Conventional Commits** e PRs com checklist.
- **Idioma:** domínio em português (`Encomenda`, `Despacho`); infraestrutura técnica em inglês.
- **Definition of Done:** testes passando, lint ok, migração revisada, OpenAPI atualizado e documentação (RF/RN/UC) atualizada quando houver mudança.
- **Mudanças de requisito:** altere primeiro os documentos em `docs/`, depois o código.

## Licença

Projeto pessoal de estudo. Defina a licença antes de tornar o repositório público (sugestão: MIT, se quiser permitir reuso).
